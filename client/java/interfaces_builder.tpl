package com.vanchu.libs.webc.<%$server->namespace%>;

import java.io.IOException;
import java.io.UnsupportedEncodingException;

import org.apache.http.HttpResponse;
import org.apache.http.ParseException;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.concurrent.FutureCallback;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.nio.client.CloseableHttpAsyncClient;
import org.apache.http.impl.nio.client.HttpAsyncClients;
import org.apache.http.util.EntityUtils;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

public class Client{
	private final static Gson gson = new GsonBuilder().create();

	public interface Callback{
		public void onSuccess(JsonObject json);
		public void onFailure(Error error);
	}
<%foreach $interfaces as $interface%>

	public interface <%$interface->name|webc_name2camel%>Callback{
		public void onSuccess(Struct.<%$interface->response|webc_name2camel%> response);
		public void onFailure(Error error);
	}
<%/foreach%>

	static private void _invoke(String interfaceName, Struct request, Callback callback){
		RequestConfig config = RequestConfig.custom().setSocketTimeout(30000).setConnectionRequestTimeout(30000).build();
		CloseableHttpAsyncClient client = HttpAsyncClients.custom().setDefaultRequestConfig(config).build();
		HttpPost post = new HttpPost("<%$server->protocol%>://<%$server->host%>:<%$server->port%>/" + interfaceName);

		try {
			post.setEntity(new StringEntity(gson.toJson(request)));
		} catch (UnsupportedEncodingException e) {
			callback.onFailure(new Error(-1, "bad request"));
			return;
		}
		client.start();
		client.execute(post, new FutureCallback<HttpResponse>(){
				@Override
				public void cancelled() {
					callback.onFailure(new Error(-1, "request cancelled"));
					}

				@Override
				public void completed(HttpResponse response) {
					try {
						String responseStr = EntityUtils.toString(response.getEntity(), "UTF-8");
						JsonObject responseDoc = new JsonParser().parse(responseStr).getAsJsonObject();
						int result = responseDoc.get("result").getAsInt();
						if(result != 0){
							callback.onFailure(new Error(result, null));
							return;
						}
						JsonObject payload = responseDoc.get("payload").getAsJsonObject();
						callback.onSuccess(payload);
					} catch (ParseException e) {
						callback.onFailure(new Error(-1, "corrupted data(incorrect json format)"));
					} catch (IOException e) {
						callback.onFailure(new Error(-1, "corrupted data(incomplete)"));
					} catch (Exception e){
						callback.onFailure(new Error(-1, "corrupted data(not webc protocol)"));
					}
				}

				@Override
				public void failed(Exception exception) {
					callback.onFailure(new Error(-1, "network error"));
				}			
		});
	}
<%foreach $interfaces as $interface%>

	static public void invoke<%$interface->name|webc_name2camel%>(Struct.<%$interface->request|webc_name2camel%> request, <%$interface->name|webc_name2camel%>Callback callback){
		Client._invoke("<%$interface->name%>", request, new Callback(){
			@Override
			public void onSuccess(JsonObject json) {
				Struct.<%$interface->response|webc_name2camel%> response = gson.fromJson(json, Struct.<%$interface->response|webc_name2camel%>.class);
				if(response == null){
					callback.onFailure(new Error(-1, "corrupted data(protocol mismatch)"));
					return;
				}
				callback.onSuccess(response);
			}

			@Override
			public void onFailure(Error error) {
				callback.onFailure(error);				
			}
		});
	}
<%/foreach%>
}
