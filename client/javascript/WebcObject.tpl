var WEBC_OBJECT_TYPE_INTEGER = 0x01;
var WEBC_OBJECT_TYPE_STRING = 0x02;
var WEBC_OBJECT_TYPE_BOOL = 0x03;
var WEBC_OBJECT_TYPE_STRUCT = 0x11;
var WEBC_OBJECT_TYPE_ARRAY = 0x12;
var WEBC_OBJECT_TYPE_NULL = 0xFF;

var WEBC_PROTO_KEY_NAME = "n";
var WEBC_PROTO_KEY_TYPE = "t";
var WEBC_PROTO_KEY_PAYLOAD = "p";

function WebcException(message) {
	this.message = message;
	this.name = "WebcException";
}

var WebcObject = {
	createNew: function() {
		var thiz = {};
		thiz.serialize = function () {throw new WebcException("serialize are supposed to be called in subclasses");};
		thiz.unserialize = function (data) {throw new WebcException("unserialize are supposed to be called in subclasses");};
		thiz.getName = function() { throw new WebcException("getName are supposed to be called in subclasses"); }
		return thiz;
	},
	smartObject: function(data) {
		if (!data.hasOwnProperty(WEBC_PROTO_KEY_TYPE)) {
			throw new WebcException("bad protocol");
		}
		var className = "";
		switch(data[WEBC_PROTO_KEY_TYPE]) {
			case WEBC_OBJECT_TYPE_INTEGER:
				className = "WebcInteger";
				break;
			case WEBC_OBJECT_TYPE_STRING:
				className = "WebcString";
				break;
			case WEBC_OBJECT_TYPE_BOOL:
				className = "WebcBool";
				break;
			case WEBC_OBJECT_TYPE_STRUCT:
				{
					if (!data.hasOwnProperty(WEBC_PROTO_KEY_NAME)) {
						throw new WebcException("bad protocol");
					}
					className = "WebcStruct" + data[WEBC_PROTO_KEY_NAME].replace(/\\.([A-Z])/g, "$1".toLowerCase());
				}
				break;
			case WEBC_OBJECT_TYPE_ARRAY:
				className = "WebcArray";
				break;
			case WEBC_OBJECT_TYPE_NULL:
				className = "WebcNull";
				break;
			default:
				throw new WebcException("bad protocol");
				break;
		}

		var obj = eval(className + ".createNew()");
		obj.unserialize(data);
		return obj;
	}
};

var WebcInteger = {
	createNew: function() {
		var obj = WebcObject.createNew();
		obj._val = 0;
		obj.getName = function() {
			return "WebcInteger";
		};
		obj.set = function(val) {
			this._val = val;
			return this;
		};
		obj.get = function() {
			return this._val;
		};
		obj.serialize = function() {
			var json = {};
			json[WEBC_PROTO_KEY_TYPE] = WEBC_OBJECT_TYPE_INTEGER;
			json[WEBC_PROTO_KEY_PAYLOAD] = this._val;
			return json;
		};
		obj.unserialize = function(data) {
			if (!data.hasOwnProperty(WEBC_PROTO_KEY_TYPE) || (data[WEBC_PROTO_KEY_TYPE] != WEBC_OBJECT_TYPE_INTEGER) || !data.hasOwnProperty(WEBC_PROTO_KEY_PAYLOAD)) {
				throw new WebcException("bad protocol");
			}

			this._val = data[WEBC_PROTO_KEY_PAYLOAD];
		};
		return obj;
	}
};

var WebcString = {
	createNew: function() {
		var obj = WebcObject.createNew();
		obj._val = "";
		obj.getName = function() {
			return "WebcString";
		};
		obj.set = function(val) {
			this._val = val;
			return this;
		};
		obj.get = function() {
			return this._val;
		};
		obj.serialize = function() {
			var json = {};
			json[WEBC_PROTO_KEY_TYPE] = WEBC_OBJECT_TYPE_STRING;
			json[WEBC_PROTO_KEY_PAYLOAD] = this._val;
			return json;
		};
		obj.unserialize = function(data) {
			if (!data.hasOwnProperty(WEBC_PROTO_KEY_TYPE) || (data[WEBC_PROTO_KEY_TYPE] != WEBC_OBJECT_TYPE_STRING) || !data.hasOwnProperty(WEBC_PROTO_KEY_PAYLOAD)) {
				throw new WebcException("bad protocol");
			}

			this._val = data[WEBC_PROTO_KEY_PAYLOAD];
		};
		return obj;
	}
};

var WebcBool = {
	createNew: function() {
		var obj = WebcObject.createNew();
		obj._val = false;
		obj.getName = function () {
			return "WebcBool";
		};
		obj.set = function(val) {
			this._val = val;
			return this;
		};
		obj.get = function() {
			return this._val;
		};
		obj.serialize = function() {
			var json = {};
			json[WEBC_PROTO_KEY_TYPE] = WEBC_OBJECT_TYPE_BOOL;
			json[WEBC_PROTO_KEY_PAYLOAD] = this._val;
			return json;
		};
		obj.unserialize = function(data) {
			if (!data.hasOwnProperty(WEBC_PROTO_KEY_TYPE) || (data[WEBC_PROTO_KEY_TYPE] != WEBC_OBJECT_TYPE_BOOL) || !data.hasOwnProperty(WEBC_PROTO_KEY_PAYLOAD)) {
				throw new WebcException("bad protocol");
			}

			this._val = data[WEBC_PROTO_KEY_PAYLOAD];
		};
		return obj;
	}
};

var WebcStruct = {
	createNew: function() {
		var obj = WebcObject.createNew();
		obj.serialize = function() {
			var payload = {};
			for (var property in this) {
				if(this.hasOwnProperty(property)) {
					var subObj = this[property];
					if (subObj.hasOwnProperty("serialize") && subObj.hasOwnProperty("unserialize")) {
						payload[property] = subObj.serialize();
					}
				}
			}
			var json = {};
			json[WEBC_PROTO_KEY_NAME] = obj.getName();
			json[WEBC_PROTO_KEY_TYPE] = WEBC_OBJECT_TYPE_STRUCT;
			json[WEBC_PROTO_KEY_PAYLOAD] = payload;
			return json;
		};
		obj.unserialize = function(data) {
			if (!data.hasOwnProperty(WEBC_PROTO_KEY_TYPE) || (data[WEBC_PROTO_KEY_TYPE] != WEBC_OBJECT_TYPE_STRUCT) || !data.hasOwnProperty(WEBC_PROTO_KEY_PAYLOAD)) {
				throw new WebcException("bad protocol");
			}
			var payload = data[WEBC_PROTO_KEY_PAYLOAD];
			for (var property in this) {
				if(this.hasOwnProperty(property) && payload.hasOwnProperty(property)) {
					this[property].unserialize(payload[property]);
				}
			}
		};
		return obj;
	}
};

var WebcArray = {
	createNew: function() {
		var obj = WebcObject.createNew();
		obj._objects = [];
		obj.getName = function () {
			return "WebcArray";
		};
		obj.addObject = function(object) {
			this._objects.push(object);
			return this;
		};
		obj.getObjects = function() {
			return this._objects;
		};
		obj.serialize = function() {
			var payload = [];
			for (var object in this._objects) {
				payload.push(object.serialize());
			}

			var json = {};
			json[WEBC_PROTO_KEY_TYPE] = WEBC_OBJECT_TYPE_ARRAY;
			json[WEBC_PROTO_KEY_PAYLOAD] = payload;
			return json;
		};
		obj.unserialize = function(data) {
			if (!data.hasOwnProperty(WEBC_PROTO_KEY_TYPE) || (data[WEBC_PROTO_KEY_TYPE] != WEBC_OBJECT_TYPE_ARRAY) || !data.hasOwnProperty(WEBC_PROTO_KEY_PAYLOAD)) {
				throw new WebcException("bad protocol");
			}
			var payload = data[WEBC_PROTO_KEY_PAYLOAD];
			for (var i in payload) {
				this._objects.push(WebcObject.smartObject(payload[i]));
			}
		};
		return obj;
	}
};

var WebcNull = {
	createNew: function() {
		var obj = WebcObject.createNew();
		obj.getName = function() {
			return "WebcNull";
		};
		obj.serialize = function() {
			var payload = {};
			payload[WEBC_PROTO_KEY_TYPE] = WEBC_OBJECT_TYPE_NULL;
			return payload;
		};
		obj.unserialize = function(data) {
		};
		return obj;
	}
};

//----------------User Objects--------------//
<%foreach $structs as $struct%>

var <%$struct->getClassName()%> = {
	createNew: function() {
		var obj = WebcStruct.createNew();
		obj.getName = function () {
			return "<%$struct->getClassName()%>";
		};
<%foreach $struct->getObjects() as $obj%>
<%if is_a($obj, 'WebcReference')%>
		obj.<%$obj->getAbbrName()%> = <%$obj->getTarget()->getClassName()%>.createNew();
<%else%>
		obj.<%$obj->getAbbrName()%> = <%$obj->getClassName()%>.createNew();
<%/if%>
<%/foreach%>
		return obj;
	}
};
<%/foreach%>
