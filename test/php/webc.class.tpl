<?php
abstract class WebcObject {
	const TYPE_INTEGER = 0x01;
	const TYPE_STRING = 0x02;
	const TYPE_BOOL = 0x03;
	const TYPE_STRUCT = 0x11;
	const TYPE_ARRAY = 0x12;
	const TYPE_NULL = 0xFF;

	const PROTO_KEY_NAME = 'n';
	const PROTO_KEY_TYPE = 't';
	const PROTO_KEY_PAYLOAD = 'p';

	abstract public function serialize();
	abstract public function unserialize(Array $data);

	public function getName() {
		$name = preg_replace('/^Webc[A-Z][a-z0-9]+/', '', get_class($this));
		return lcfirst(preg_replace('/([a-z0-9])([A-Z])/e', "'\\1_' . strtolower('\\2')", $name));
	}

	static public function smartObject($data) {
		if (!is_array($data) || !is_int($data[WebcObject::PROTO_KEY_TYPE])) {
			throw new Exception('bad protocol');
		}
		switch($data[WebcObject::PROTO_KEY_TYPE]) {
			case self::TYPE_INTEGER:
				$className = 'WebcInteger';
				break;
			case self::TYPE_STRING:
				$className = 'WebcString';
				break;
			case self::TYPE_BOOL:
				$className = 'WebcBool';
				break;
			case self::TYPE_STRUCT:
				if (!is_string($data[WebcObject::PROTO_KEY_NAME])) {
					throw new Exception('bad protocol');
				}
				$className = 'WebcStruct' . ucfirst(preg_replace('/_([a-z])/ei', "strtoupper('\\1')", $data[WebcObject::PROTO_KEY_NAME]));
				break;
			case self::TYPE_ARRAY:
				$className = 'WebcArray';
				break;
			case self::TYPE_NULL:
				$className = 'WebcNull';
				break;
			default:
				throw new Exception('bad protocol');
				break;
		}

		if (!class_exists($className)) {
			throw new Exception('call to undefined class ' . $className);
		}
		$obj = new $className();
		$obj->unserialize($data);
		return $obj;
	}
}

class WebcStruct extends WebcObject {
	public function serialize() {
		$data = array(WebcObject::PROTO_KEY_NAME => $this->getName(), WebcObject::PROTO_KEY_TYPE => WebcObject::TYPE_STRUCT, WebcObject::PROTO_KEY_PAYLOAD => array());
		foreach($this as $k => &$obj) {
			if (!is_a($obj, 'WebcObject')) {
				continue;
			}
			$data[WebcObject::PROTO_KEY_PAYLOAD][$k] = $obj->serialize();
		}
		return $data;
	}

	public function unserialize(Array $data) {
		if (!is_int($data[WebcObject::PROTO_KEY_TYPE]) || ($data[WebcObject::PROTO_KEY_TYPE] != WebcObject::TYPE_STRUCT) || !is_array($data[WebcObject::PROTO_KEY_PAYLOAD])) {
			throw new Exception('unserialize failed, protocol mismatch');
		}
		foreach($this as $k => &$obj) {
			if (isset($data[WebcObject::PROTO_KEY_PAYLOAD][$k]) && is_array($data[WebcObject::PROTO_KEY_PAYLOAD][$k])) {
				$this->$k->unserialize($data[WebcObject::PROTO_KEY_PAYLOAD][$k]);
			}
		}
	}
}

class WebcArray extends WebcObject {
	protected $_objects = array();

	public function addObject(WebcObject $object) {
		$this->_objects[] = $object;
	}

	public function getObjects() {
		return $this->_objects;
	}

	public function serialize() {
		$data = array(WebcObject::PROTO_KEY_TYPE => WebcObject::TYPE_ARRAY, WebcObject::PROTO_KEY_PAYLOAD => array());
		foreach($this->_objects as $obj) {
			if (!is_a($obj, 'WebcObject')) {
				continue;
			}
			$data[WebcObject::PROTO_KEY_PAYLOAD][] = $obj->serialize();
		}
		return $data;
	}

	public function unserialize(Array $data) {
		if (!is_int($data[WebcObject::PROTO_KEY_TYPE]) || ($data[WebcObject::PROTO_KEY_TYPE] != WebcObject::TYPE_ARRAY) || !is_array($data[WebcObject::PROTO_KEY_PAYLOAD])) {
			throw new Exception('unserialize failed, protocol mismatch');
		}

		$this->_objects = array();
		foreach($data[WebcObject::PROTO_KEY_PAYLOAD] as $subData) {
			$this->_objects[] = WebcObject::smartObject($subData);
		}
	}
}

class WebcInteger extends WebcObject {
	protected $_val = 0;

	public function set($val) {
		if (!is_int($val)) {
			throw new Exception('type mismatch, int expected');
		}
		$this->_val = $val;
	}

	public function get() {
		return $this->_val;
	}

	public function serialize() {
		return array(WebcObject::PROTO_KEY_TYPE => WebcObject::TYPE_INTEGER, WebcObject::PROTO_KEY_PAYLOAD => $this->_val);
	}

	public function unserialize(Array $data) {
		if (!is_int($data[WebcObject::PROTO_KEY_TYPE]) || ($data[WebcObject::PROTO_KEY_TYPE] != WebcObject::TYPE_INTEGER) || !is_int($data[WebcObject::PROTO_KEY_PAYLOAD])) {
			throw new Exception('unserialize failed, protocol mismatch');
		}
		$this->_val = $data[WebcObject::PROTO_KEY_PAYLOAD];
	}
}

class WebcString extends WebcObject {
	protected $_val = "";

	public function set($val) {
		if (!is_string($val)) {
			throw new Exception('type mismatch, string expected');
		}
		$this->_val = $val;
	}

	public function get() {
		return $this->_val;
	}

	public function serialize() {
		return array(WebcObject::PROTO_KEY_TYPE => WebcObject::TYPE_STRING, WebcObject::PROTO_KEY_PAYLOAD => $this->_val);
	}

	public function unserialize(Array $data) {
		if (!is_int($data[WebcObject::PROTO_KEY_TYPE]) || ($data[WebcObject::PROTO_KEY_TYPE] != WebcObject::TYPE_STRING) || !is_string($data[WebcObject::PROTO_KEY_PAYLOAD])) {
			throw new Exception('unserialize failed, protocol mismatch');
		}
		$this->_val = $data[WebcObject::PROTO_KEY_PAYLOAD];
	}
}

class WebcBool extends WebcObject {
	protected $_val = false;

	public function set($val) {
		if (!is_bool($val)) {
			throw new Exception('type mismatch, bool expected');
		}
		$this->_val = $val;
	}

	public function get() {
		return $this->_val;
	}

	public function serialize() {
		return array(WebcObject::PROTO_KEY_TYPE => WebcObject::TYPE_BOOL, WebcObject::PROTO_KEY_PAYLOAD => $this->_val);
	}

	public function unserialize(Array $data) {
		if (!is_int($data[WebcObject::PROTO_KEY_TYPE]) || ($data[WebcObject::PROTO_KEY_TYPE] != WebcObject::TYPE_BOOL) || !is_bool($data[WebcObject::PROTO_KEY_PAYLOAD])) {
			throw new Exception('unserialize failed, protocol mismatch');
		}
		$this->_val = $data[WebcObject::PROTO_KEY_PAYLOAD];
	}
}

class WebcNull extends WebcObject {
	public function serialize() {
		return array(WebcObject::PROTO_KEY_TYPE => WebcObject::TYPE_NULL);
	}

	public function unserialize(Array $data) {
	}
}
