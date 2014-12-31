<?php
require_once __DIR__ . '/objects.class.php';

class WebcError {
	private $_code;
	private $_msg;

	public function __construct($code, $msg) {
		$this->_code = $code;
		$this->_msg = $msg;
	}

	public function getCode() {
		return $this->_code;
	}

	public function getMsg() {
		return $this->_msg;
	}
}

class WebcClient
{
	static protected $_host;
	static protected $_port;
	static protected $_protocol;

	static public function setup($host, $port = 80, $protocol = 'http') {
		self::$_host = $host;
		self::$_port = $port;
		self::$_protocol = $protocol;
	}

	static protected function _call($interface, $version, $request, &$response){
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, self::$_protocol . "://" . self::$_host . ":" . self::$_port . "/${version}/" . $interface);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($request->serialize()));
		curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 10); 
		curl_setopt($ch, CURLOPT_TIMEOUT, 30);
		$rawData = curl_exec($ch);
		
		$json = json_decode($rawData, true);
        if(!is_array($json))
			return new WebcError(-1, 'Bad body received:' . $rawData);

		if($json['r'] != 0)
			return new WebcError($json['r'], $json['p']);

       	$response->unserialize($json['p']);
		return new WebcError(0, 'Succ');
	}
<%foreach $interfaces as $interface%>

	static public function call<%$interface->getName(true)%>(<%$interface->getRequest()->getClassName()%> $request, <%$interface->getResponse()->getClassName()%> $response) {
		return self::_call('<%$interface->getName()%>', <%$interface->getVersion()%>, $request, $response);
	}
<%/foreach%>
}
