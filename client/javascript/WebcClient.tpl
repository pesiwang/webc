function WebcError(code, msg) {
	this.code = code;
	this.msg = msg;
};

var WebcClient = {
	_host: 'localhost',
	_port: 80,
	_protocol: 'http',
	setup: function(host, port, protocol) {
		this._host = host;
		if (port)
			this._port = port;
		if (protocol)
			this._protocol = protocol;
	},
<%foreach $interfaces as $interface%>
	invoke<%$interface->getName(true)%>: function(request, responseCallback, failureCallback) {
		try {
			WebcClient._invoke("<%$interface->getName()%>", <%$interface->getVersion()%>, request, function(json) {
				var response = <%$interface->getResponse()->getClassName()%>.createNew();
				response.unserialize(json);
				responseCallback(response);

			}, function(error) {
				failureCallback(error);
			});
		}
		catch(e) {
			failureCallback(new WebcError(-1, "Protocol Error"));
		}
	},
<%/foreach%>
	_invoke: function(interfaceName, version, request, responseCallback, failureCallback) {
		var xmlHttpRequest;
		if (window && window.XMLHttpRequest) {
			xmlHttpRequest = new XMLHttpRequest();
		}
		else {
			if (window && window.ActiveXObject) {
				xmlHttpRequest = new ActiveXObject("Microsoft.XMLHTTP");
			}
		}
		if (!xmlHttpRequest) {
			failureCallback(new WebcError(-1, "Internal error"));
			return;
		}

		xmlHttpRequest.onreadystatechange = function() {
			if(xmlHttpRequest.readyState == 4) {
				try{
					var data = JSON.parse(xmlHttpRequest.responseText);
					if (!data || !data.hasOwnProperty("r") || !data.hasOwnProperty("p")) {
						failureCallback(new WebcError(-1, "network error"));
						return;
					}

					if(data["r"] != 0) {
						failureCallback(new WebcError(data["r"], "Business error"));
						return;
					}

					responseCallback(data["p"]);
				}
				catch(e) {
					failureCallback(new WebcError(-1, "network error"));
				}
			}
		}
		var url = this._protocol + "://" + this._host + ":" + this._port + "/" + version + "/" + interfaceName;
		xmlHttpRequest.open("POST", url, true);
		xmlHttpRequest.send(JSON.stringify(request.serialize()));
	}
};
