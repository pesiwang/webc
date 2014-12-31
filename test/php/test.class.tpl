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

class WebcTest
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

	static public function printObject($name, WebcObject $obj, $depth = 0) {
		for ($idx = 0; $idx < $depth; ++$idx) {
			echo "\t";
		}
		echo $name;
		if (is_a($obj, 'WebcStruct')) {
			echo "(Struct)\n";
			foreach($obj as $subName => $subObj) {
				self::printObject($subName, $subObj, $depth + 1);
			}
		}
		else if (is_a($obj, 'WebcArray')) {
			echo "(Array)\n";
			foreach($obj->getObjects() as $subObj) {
				self::printObject($subObj->getName(), $subObj, $depth + 1);
			}
		}
		else if (is_a($obj, 'WebcInteger')) {
			echo "(Integer) = " . $obj->get() . "\n";
		}
		else if (is_a($obj, 'WebcString')) {
			echo "(String) = " . $obj->get() . "\n";
		}
		else if (is_a($obj, 'WebcBool')) {
			echo "(Bool) = " . ($obj->get() ? "true" : "false") . "\n";
		}
	}

	static public function fillObject($name, WebcObject $obj, $depth = 0) {
		for ($idx = 0; $idx < $depth; ++$idx) {
			echo "\t";
		}
		echo $name;
		if (is_a($obj, 'WebcStruct')) {
			echo "(Struct)\n";
			foreach($obj as $subName => &$subObj) {
				self::fillObject($subName, $subObj, $depth + 1);
			}
		}
		else if (is_a($obj, 'WebcInteger')) {
			echo "(Integer):";	
			$obj->set((int)(rtrim(fgets(STDIN), "\n")));
		}
		else if (is_a($obj, 'WebcString')) {
			echo "(String):";
			$obj->set(rtrim(fgets(STDIN), "\n"));
		}
		else if (is_a($obj, 'WebcBool')) {
			echo "(Bool):";
			$val = rtrim(fgets(STDIN), "\n");
			if ((strcasecmp($val, "true") == 0) || (strcasecmp($val, "yes") == 0) || (strcasecmp($val, "1") == 0)) {
				$obj->set(true);
			}
			else {
				$obj->set(false);
			}
		}
	}

<%foreach $interfaces as $interface%>

	static public function test<%$interface->getName(true)%>() {
		$request = new <%$interface->getRequest()->getClassName()%>();
		self::fillObject($request->getName(), $request);

		$response = new <%$interface->getResponse()->getClassName()%>();
		$error = self::_call('<%$interface->getName()%>', <%$interface->getVersion()%>, $request, $response);
		if ($error->getCode() == 0)
			return $response;
		return $error;
	}
<%/foreach%>
}
