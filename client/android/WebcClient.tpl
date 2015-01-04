package com.vanchu.lib.webc;
import java.io.IOException;
import java.net.HttpURLConnection;

import org.json.JSONObject;
import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.ParseException;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.entity.GzipDecompressingEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;
import android.os.Handler;
import android.os.Message;
import com.vanchu.lib.webc.WebcObject.WebcNull;
import com.vanchu.lib.webc.WebcObject.WebcStruct.*;

public class WebcClient {
	static public final Integer DEFAULT_PORT = 80;
	static public final String DEFAULT_PROTOCOL = "http";
	
	static private String _host;
	static private Integer _port;
	static private String _protocol;
	
	static public void setup(String host, Integer port, String protocol) {
		_host = host;
		_port = port;
		_protocol = protocol;
	}
	
	public static class Error {
		private Integer _code;
		private String _msg;
		
		public Error(Integer code, String msg) {
			this._code = code;
			this._msg = msg;
		}
		
		public Integer getCode() {
			return this._code;
		}
		
		public String getMsg() {
			return this._msg;
		}
	}
	
	public interface InternalCallback {
		public void onSuccess(JSONObject json);
		public void onFailure(Error error);
	}
<%foreach $interfaces as $interface%>

	public interface <%$interface->getName(true)%>Callback{
		public void onSuccess(<%$interface->getResponse()->getClassName()%> response);
		public void onFailure(Error error);
	}
<%/foreach%>
	
	static private void _invoke(final String interfaceName, final Integer version, final WebcObject request, final InternalCallback callback){
		new Thread(){
			@Override
			public void run(){
				BasicHttpParams httpParams = new BasicHttpParams();
				HttpConnectionParams.setConnectionTimeout(httpParams, 10000);
				HttpConnectionParams.setSoTimeout(httpParams, 10000);
				DefaultHttpClient httpClient = new DefaultHttpClient(httpParams);

				HttpPost httpPost = new HttpPost(_protocol + "://" + _host + ":" + _port + "/" + version + "/" + interfaceName);
				httpPost.addHeader("Accept-Encoding", "gzip");
				try {
					httpPost.setEntity(new StringEntity(request.serialize().toString()));
				} catch (Exception e) {
					callback.onFailure(new Error(-1, "bad request"));
					return;
				}

				HttpResponse httpResponse = null;
				try {
					httpResponse = httpClient.execute(httpPost);
				} catch (ClientProtocolException e1) {
					e1.printStackTrace();
					callback.onFailure(new Error(-1, "network error"));
					return;
				} catch (IOException e1) {
					e1.printStackTrace();
					callback.onFailure(new Error(-1, "network error"));
					return;
				}
				int statusCode = httpResponse.getStatusLine().getStatusCode();
				if (statusCode == HttpURLConnection.HTTP_OK) {
					try {
						String responseStr;
						Header header = httpResponse.getFirstHeader(HTTP.CONTENT_ENCODING);
						if (header != null && header.getValue().equalsIgnoreCase("gzip")) {
							GzipDecompressingEntity entity = new GzipDecompressingEntity(
								httpResponse.getEntity());
							responseStr = EntityUtils.toString(entity, HTTP.UTF_8);
						} else {
							responseStr = EntityUtils.toString(httpResponse.getEntity(), HTTP.UTF_8);
						}
						
						JSONObject responseDoc = new JSONObject(responseStr);
						int result = responseDoc.getInt("r");
						if(result != 0){
							callback.onFailure(new Error(result, null));
							return;
						}
						JSONObject payload = responseDoc.getJSONObject("p");
						callback.onSuccess(payload);
					} catch (ParseException e) {
						callback.onFailure(new Error(-1, "corrupted data(incorrect json format)"));
					} catch (IOException e) {
						callback.onFailure(new Error(-1, "corrupted data(incomplete)"));
					} catch (Exception e){
						callback.onFailure(new Error(-1, "corrupted data(not webc protocol)"));
					}
					
				} else {
					callback.onFailure(new Error(-1, "network error"));
				}
			}
		}.start();
	}
<%foreach $interfaces as $interface%>

    static public void invoke<%$interface->getName(true)%>(<%$interface->getRequest()->getClassName()%> request, final <%$interface->getName(true)%>Callback callback) {
		final Handler handler = new Handler() {
			@Override
			public void handleMessage(Message msg) {
				switch (msg.what) {
					case 0:
                		<%$interface->getResponse()->getClassName()%> response = new <%$interface->getResponse()->getClassName()%>();
						try {
							response.unserialize((JSONObject)(msg.obj));
		                	callback.onSuccess(response);
						} catch (Exception e) {
							callback.onFailure(new Error(-1, "protocol error"));
						}
						break;
					case 1:
						callback.onFailure(((Error)msg.obj));
						break;
					default:
						break;
				}
			}
		};

    	WebcClient._invoke("<%$interface->getName()%>", <%$interface->getVersion()%>, request, new InternalCallback(){
            @Override
            public void onSuccess(JSONObject json) {
				handler.obtainMessage(0, json).sendToTarget();
            }

            @Override
            public void onFailure(Error error) {
				handler.obtainMessage(1, error).sendToTarget();
            }
        });
    }
<%/foreach%>
}
