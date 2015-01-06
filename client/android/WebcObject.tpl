package com.vanchu.lib.webc;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONArray;
import org.json.JSONObject;

public abstract class WebcObject {
	protected final static int TYPE_INTEGER = 0x01;
	protected final static int TYPE_STRING = 0x02;
	protected final static int TYPE_BOOL = 0x03;
	protected final static int TYPE_STRUCT = 0x11;
	protected final static int TYPE_ARRAY = 0x12;
	protected final static int TYPE_NULL = 0xFF;
	
	protected final static String PROTO_KEY_NAME = "n";
	protected final static String PROTO_KEY_TYPE = "t";
	protected final static String PROTO_KEY_PAYLOAD = "p";
    
    abstract public JSONObject serialize() throws Exception;
    abstract public void unserialize(JSONObject data) throws Exception;
    
    protected String getName() {
		String className = "";
		Matcher matcher = Pattern.compile("([A-Z][a-z0-9]*)").matcher(this.getClass().getSimpleName().replaceFirst("^Webc[A-Z][a-z0-9]+", ""));
		while(matcher.find()) {
			if (className.length() > 0)
				className += ".";
			className += matcher.group(1).toLowerCase();
		}
		return className;
	}
    
    static public WebcObject smartObject(JSONObject data) throws Exception {
    	if (!data.has(PROTO_KEY_TYPE)) {
    		throw new Exception("bad protocol");
    	}
    	
    	String className = null;    	
    	switch(data.getInt(PROTO_KEY_TYPE)) {
    		case TYPE_INTEGER:
    			break;
    		 case TYPE_STRING:
    			 className = "WebcString";
                 break;
             case TYPE_BOOL:
            	 className = "WebcBool";
                 break;
             case TYPE_STRUCT:
             	{
					if (!data.has(PROTO_KEY_NAME)) {
						throw new Exception("bad protocol");
					}
             		className = "WebcStruct";
             		Matcher matcher = Pattern.compile("_?([a-z0-9]+)").matcher(data.getString(PROTO_KEY_NAME));
            		while(matcher.find()) {
            			className += matcher.group(1).substring(0, 1).toUpperCase() + matcher.group(1).substring(1);
            		}
             	}
                 break;
             case TYPE_ARRAY:
            	 className = "WebcArray";
                 break;
             case TYPE_NULL:
            	 className = "WebcNull";
                 break;
             default:
                 throw new Exception("bad protocol"); 
    	}
    	WebcObject obj = (WebcObject) Class.forName(className).newInstance();
    	obj.unserialize(data);
    	return obj;
    }
    
    public static class WebcInteger extends WebcObject {
    	private int _val = 0;
    	
    	public WebcInteger set(int val) {
    		this._val = val;
    		return this;
    	}
    	
    	public int get() {
    		return this._val;
    	}
    	
    	@Override
    	public JSONObject serialize() throws Exception {
    		JSONObject json = new JSONObject();
    		json.put(PROTO_KEY_TYPE, WebcObject.TYPE_INTEGER);
    		json.put(PROTO_KEY_PAYLOAD, this._val);
    		return json;
    	}

    	@Override
    	public void unserialize(JSONObject data) throws Exception {
    		if (!data.has(PROTO_KEY_TYPE) || (data.getInt(PROTO_KEY_TYPE) != WebcObject.TYPE_INTEGER) || !data.has(PROTO_KEY_PAYLOAD)) {
    			throw new Exception("unserialize failed, protocol mismatch");
    		}
    		
    		this._val = data.getInt(PROTO_KEY_PAYLOAD);
    	}    	
    }
    
    public static class WebcString extends WebcObject {
    	private String _val = "";
    	
    	public WebcString set(String val) {
    		this._val = val;
    		return this;
    	}
    	
    	public String get() {
    		return this._val;
    	}
    	
    	@Override
    	public JSONObject serialize() throws Exception {
    		JSONObject json = new JSONObject();
    		json.put(PROTO_KEY_TYPE, WebcObject.TYPE_STRING);
    		json.put(PROTO_KEY_PAYLOAD, this._val);
    		return json;
    	}

    	@Override
    	public void unserialize(JSONObject data) throws Exception {
    		if (!data.has(PROTO_KEY_TYPE) || (data.getInt(PROTO_KEY_TYPE) != WebcObject.TYPE_STRING) || !data.has(PROTO_KEY_PAYLOAD)) {
    			throw new Exception("unserialize failed, protocol mismatch");
    		}
    		
    		this._val = data.getString(PROTO_KEY_PAYLOAD);
    	}
    }
    
    public static class WebcBool extends WebcObject {
    	private Boolean _val = false;
    	
    	public WebcBool set(Boolean val) {
    		this._val = val;
    		return this;
    	}
    	
    	public Boolean get() {
    		return this._val;
    	}

    	@Override
    	public JSONObject serialize() throws Exception {
    		JSONObject json = new JSONObject();
    		json.put(PROTO_KEY_TYPE, WebcObject.TYPE_BOOL);
    		json.put(PROTO_KEY_PAYLOAD, this._val);
    		return json;
    	}

    	@Override
    	public void unserialize(JSONObject data) throws Exception {
    		if (!data.has(PROTO_KEY_TYPE) || (data.getInt(PROTO_KEY_TYPE) != WebcObject.TYPE_BOOL) || !data.has(PROTO_KEY_PAYLOAD)) {
    			throw new Exception("unserialize failed, protocol mismatch");
    		}
    		
    		this._val = data.getBoolean(PROTO_KEY_PAYLOAD);
    	}
    }
    
    public static class WebcStruct extends WebcObject {
		
    	@Override
    	public JSONObject serialize() throws Exception {
    		JSONObject payload = new JSONObject();
			for(Field field : this.getClass().getDeclaredFields()) {
				Object obj = field.get(this);
				if(obj instanceof WebcObject) {
					payload.put(field.getName(), ((WebcObject)obj).serialize());
				}
			}

    		JSONObject json = new JSONObject();
    		json.put(PROTO_KEY_NAME, this.getName());
    		json.put(PROTO_KEY_TYPE, WebcObject.TYPE_STRUCT);
    		json.put(PROTO_KEY_PAYLOAD, payload);
    		return json;
    	}

    	@Override
    	public void unserialize(JSONObject data) throws Exception {
    		if (!data.has(PROTO_KEY_TYPE) || (data.getInt(PROTO_KEY_TYPE) != WebcObject.TYPE_STRUCT) || !data.has(PROTO_KEY_PAYLOAD)) {
    			throw new Exception("unserialize failed, protocol mismatch");
    		}

    		JSONObject payload = data.getJSONObject(PROTO_KEY_PAYLOAD);
			for(Field field : this.getClass().getDeclaredFields()) {
				Object obj = field.get(this);
				if ((obj instanceof WebcObject) && payload.has(field.getName())) {
					((WebcObject)obj).unserialize(payload.getJSONObject(field.getName()));
				}
			}

    	}
    	
		//----------------User Objects--------------//
<%foreach $structs as $struct%>

		public static class <%$struct->getClassName()%> extends WebcStruct {
<%foreach $struct->getObjects() as $obj%>
<%if is_a($obj, 'WebcReference')%>
			public <%$obj->getTarget()->getClassName()%> <%$obj->getAbbrName()%> = new <%$obj->getTarget()->getClassName()%>();
<%else%>
			public <%$obj->getClassName()%> <%$obj->getAbbrName()%> = new <%$obj->getClassName()%>();
<%/if%>
<%/foreach%>
		}
<%/foreach%>
    }
    
    public static class WebcArray extends WebcObject {
    	private ArrayList<WebcObject> _objects = new ArrayList<WebcObject>(); 

		public void addObject(WebcObject object) {
			this._objects.add(object);
		}

		public ArrayList<WebcObject> getObjects() {
			return this._objects;
		}

    	@Override
    	public JSONObject serialize() throws Exception {
    		JSONArray payload = new JSONArray();
    		for(WebcObject object : this._objects) {
    			payload.put(object.serialize());
    		}
    		
    		JSONObject json = new JSONObject();
    		json.put(PROTO_KEY_TYPE, WebcObject.TYPE_ARRAY);
    		json.put(PROTO_KEY_PAYLOAD, payload);
    		return json;
    	}

    	@Override
    	public void unserialize(JSONObject data) throws Exception {
    		if (!data.has(PROTO_KEY_TYPE) || (data.getInt(PROTO_KEY_TYPE) != WebcObject.TYPE_ARRAY) || !data.has(PROTO_KEY_PAYLOAD)) {
    			throw new Exception("unserialize failed, protocol mismatch");
    		}

    		JSONArray payload = data.getJSONArray(PROTO_KEY_PAYLOAD);
    		for(int i = 0; i < payload.length(); ++i) {
    			JSONObject json = payload.getJSONObject(i);
    			WebcObject object = WebcObject.smartObject(json);
    			this._objects.add(object);
    		}
    	}
    }
    
    public static class WebcNull extends WebcObject {

    	@Override
    	public JSONObject serialize() throws Exception {
    		JSONObject json = new JSONObject();
    		json.put(PROTO_KEY_TYPE, WebcObject.TYPE_NULL);
    		return json;
    	}

    	@Override
    	public void unserialize(JSONObject data) throws Exception {
    	}
    }
}
