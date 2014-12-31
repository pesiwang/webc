<?php
date_default_timezone_set('Asia/Shanghai');

class WebcObject {
	protected $_name;
	
	public function __construct($name) {
		$this->_name = $name;
	}

	public function getOriginalName() {
		return $this->_name;
	}

	public function getAbbrName() {
		$names = explode('_', $this->_name);
		return $names[count($names) - 1];
	}

	public function getFullName($asCamel = false) {
		if (!$asCamel)
			return $this->_name;
		return ucfirst(preg_replace('/_([a-z])/ei', "strtoupper('\\1')", $this->_name));
	}

	public function getClassName() {
		if (is_a($this, 'WebcStruct')) {
			return 'WebcStruct' . $this->getFullName(true);
		}
		if (is_a($this, 'WebcArray')) {
			return 'WebcArray';
		}
		if (is_a($this, 'WebcInteger')) {
			return 'WebcInteger';
		}
		if (is_a($this, 'WebcString')) {
			return 'WebcString';
		}
		if (is_a($this, 'WebcBool')) {
			return 'WebcBool';
		}
		if (is_a($this, 'WebcNull')) {
			return 'WebcNull';
		}
		throw new Exception('not a WebcObject subclass');
	}
}

class WebcInteger extends WebcObject {
}

class WebcBool extends WebcObject {
}

class WebcString extends WebcObject {
}

class WebcArray extends WebcObject {
}

class WebcNull extends WebcObject {
}

class WebcReference extends WebcObject {
	private $_target = null;

	public function setTarget($target) {
		$this->_target = $target;
		return $this;
	}

	public function getTarget() {
		return $this->_target;
	}
}

class WebcStruct extends WebcObject {
	private $_objects = null;

	public function addObject(WebcObject $obj) {
		if (!is_array($this->_objects)) {
			$this->_objects = array();
		}
		$this->_objects[] = $obj;
		$this->_reference = null;
	}

	public function getObjects() {
		return $this->_objects;
	}
}

class WebcInterface {
	private $_name;
	private $_request = null;
	private $_response = null;
	private $_version;

	public function __construct($name, $version, WebcObject $request, WebcObject $response) {
		$this->_name = $name;
		$this->_version = $version;
		$this->_request = $request;
		$this->_response = $response;
	}

	public function getName($asCamel = false) {
		if (!$asCamel) {
			return $this->_name;
		}
		return ucfirst(preg_replace('/\\.([a-z])/ei', "strtoupper('\\1')", $this->_name));
	}

	public function getClassName() {
		return 'WebcInterface' . $this->getName(true);
	}

	public function getVersion() {
		return $this->_version;
	}

	public function getRequest() {
		return $this->_request;
	}

	public function getResponse() {
		return $this->_response;
	}
}

class Parser {
	private $_structs = array();
	private $_references = array();
	private $_interfaces = array();
	private $_version;

	public function __construct($xmlFile) {
		$xml = @simplexml_load_file($xmlFile, null, LIBXML_NOCDATA);
		if($xml === FALSE)
			throw new Exception('bad xml file(' . $xmlFile . ')');

		//step 1. parse version
		$this->_version = (int)($xml->version);

		//step 2. parse & check objects
		foreach($xml->objects->children() as $item) {
			$this->parseObject($item, '');
		}

		//step 3. resolve references
		foreach($this->_references as $name => &$reference) { 
			if (!isset($this->_structs[$reference->getTarget()])) {
				throw new Exception('referring to undefined struct object (' . $reference->getTarget() . ')');
			}
			$reference->setTarget($this->_structs[$reference->getTarget()]);
		}

		//step 4. parse interfaces
		foreach($xml->interfaces->children() as $item) {
			$this->parseInterface($item);
		}

		//step 5. filter unused structs
		$this->filter();
	}

	public function merge(Parser $otherParser) {
		foreach($otherParser->getInterfaces() as $name => $interface) {
			if (!isset($this->_interfaces[$name])) {
				$this->_interfaces[$name] = $interface;
			}
		}

		foreach($otherParser->getStructs() as $name => $struct) {
			if (!isset($this->_structs[$name])) {
				$this->_structs[$name] = $struct;
			}
		}
		$this->filter();
	}

	public function filter() {
		$structsStatus = array_fill_keys(array_keys($this->_structs), 0);
		foreach($this->_interfaces as &$interface) {
			$this->filterStructs($interface->getRequest(), $structsStatus);
			$this->filterStructs($interface->getResponse(), $structsStatus);
		}

		foreach($structsStatus as $name => $inUse) {
			if ($inUse == 0) {
				echo "Warning: unused Struct {$name}\n";
				unset($this->_structs[$name]);
			}
		}
	}

	private function filterStructs(WebcObject $obj, &$structsStatus) {
		$name = null;
		while (is_a($obj, 'WebcReference')) {
			$obj = $obj->getTarget();
		}
		if (!is_a($obj, 'WebcStruct')) {
			return;
		}

		$name = $obj->getOriginalName();
		$structsStatus[$obj->getOriginalName()] = 1;
		foreach($obj->getObjects() as $subObj) {
			$this->filterStructs($subObj, $structsStatus);
		}
	}

	public function getStructs() {
		return $this->_structs;
	}

	public function getReferences() {
		return $this->_references;
	}

	public function getInterfaces() {
		return $this->_interfaces;
	}

	public function getVersion() {
		return $this->_version;
	}

	//-----------------------Private Functions------------------------//
	private function parseObject(SimpleXMLElement $item, $namePrefix) {
		if (!isset($item['name'])) {
			throw new Exception('missing "name" attribute in tag ' . (string)($item->getName()));
		}
		$fullName = $namePrefix . (string)($item['name']);
		if (isset($this->_structs[$fullName])) {
			return;
		}

		$obj = null;
		if (strcmp((string)($item->getName()), 'struct') == 0) {
			$obj = $this->parseStructOrReference($item, $namePrefix);
		}
		else if (strcmp((string)($item->getName()), 'array') == 0) {
			$obj = new WebcArray($fullName);
		}
		else if (strcmp((string)($item->getName()), 'integer') == 0) {
			$obj = new WebcInteger($fullName);
		}
		else if (strcmp((string)($item->getName()), 'string') == 0) {
			$obj = new WebcString($fullName);
		}
		else if (strcmp((string)($item->getName()), 'bool') == 0) {
			$obj = new WebcBool($fullName);
		}
		else {
			throw new Exception('unrecognized tag ' . (string)($item->getName()));
		}

		return $obj;
	}

	private function parseStructOrReference(SimpleXMLElement $item, $namePrefix) {
		$obj = null;
		if (isset($item['reference'])) {
			if (count($item->children()) > 0) {
				throw new Exception('reference and embeded struct cannot coexists in tag ' . (string)($item->getName()));
			}

			$obj = new WebcReference($namePrefix . (string)($item['name']));
			$obj->setTarget((string)($item['reference']));
			$this->_references[$namePrefix . (string)($item['name'])] = $obj;
		}
		else if (count($item->children()) > 0) {
			$obj = new WebcStruct($namePrefix . (string)($item['name']));
			foreach($item->children() as $subItem) {
				$obj->addObject($this->parseObject($subItem, $obj->getFullName() . '_'));
			}
			$this->_structs[$namePrefix . (string)($item['name'])] = $obj;
		}
		else {
			throw new Exception('empty object detected in tag ' . (string)($item->getFullName()));
		}
		return $obj;
	}

	private function parseInterface(SimpleXMLElement $item) {
		if (!isset($item['name'])) {
			throw new Exception('missing "name" attribute in interface');
		}
		if (!isset($item['request'])) {
			throw new Exception('missing "request" attribute in interface');
		}
		if (!isset($item['response'])) {
			throw new Exception('missing "response" attribute in interface');
		}

		$name = (string)($item['name']);
		$request = (string)($item['request']);
		$response = (string)($item['response']);

		if (isset($this->_interfaces[$name])) {
			throw new Exception('duplicated interface ' . $name);
		}

		$interfaceRequest = new WebcNull($request);
		$interfaceResponse = new WebcNull($response);
		if (strlen($request) > 0) {
			if (!isset($this->_structs[$request])) {
				throw new Exception('referring to undefined object (' . $request . ') in request attribute of interface ' . $name);
			}
			$interfaceRequest = $this->_structs[$request];
		}

		if (strlen($response) > 0) {
			if (!isset($this->_structs[$response])) {
				throw new Exception('referring to undefined object (' . $response . ') in response attribute of interface ' . $name);
			}
			$interfaceResponse = $this->_structs[$response];
		}
		$interface = new WebcInterface($name, $this->_version, $interfaceRequest, $interfaceResponse);
		$this->_interfaces[$name] = $interface;
	}
}
