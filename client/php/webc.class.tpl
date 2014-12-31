<?php
abstract class WebcObject {
	const TYPE_INTEGER = 0x01;
	const TYPE_STRING = 0x02;
	const TYPE_BOOL = 0x03;
	const TYPE_STRUCT = 0x11;
	const TYPE_ARRAY = 0x12;
	const TYPE_NULL = 0xFF;

	abstract public function serialize();
	abstract public function unserialize(Array $data);

	protected function getName() {
		$name = preg_replace('/^Webc[A-Z][a-z0-9]+/', '', get_class($this));
		return lcfirst(preg_replace('/([a-z0-9])([A-Z])/e', "'\\1_' . strtolower('\\2')", $name));
	}

	static public function smartObject($data) {
		if (!is_array($data) || !is_int($data['t'])) {
			throw new Exception('bad protocol');
		}
		switch($data['t']) {
			case TYPE_INTEGER:
				$className = 'WebcInteger';
				break;
			case TYPE_STRING:
				$className = 'WebcString';
				break;
			case TYPE_BOOL:
				$className = 'WebcBool';
				break;
			case TYPE_STRUCT:
				if (!is_string($data['n'])) {
					throw new Exception('bad protocol');
				}
				$className = 'WebcStruct' . ucfirst(preg_replace('/_([a-z])/ei', "strtoupper('\\1')", $data['n']));
				break;
			case TYPE_ARRAY:
				$className = 'WebcArray';
				break;
			case TYPE_NULL:
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
		$data = array('n' => $this->getName(), 't' => WebcObject::TYPE_STRUCT, 'p' => array());
		foreach($this as $k => &$obj) {
			if (!is_a($obj, 'WebcObject')) {
				continue;
			}
			$data['p'][$k] = $obj->serialize();
		}
		return $data;
	}

	public function unserialize(Array $data) {
		if (!is_int($data['t']) || ($data['t'] != WebcObject::TYPE_STRUCT) || !is_array($data['p'])) {
			throw new Exception('unserialize failed, protocol mismatch');
		}
		foreach($this as $k => &$obj) {
			if (is_array($data['p'][$k])) {
				$this->$k->unserialize($data['p'][$k]);
			}
		}
	}
}

class WebcArray extends WebcObject {
	protected $_objects = array();

	public function addObject(WebcObject $object) {
		$this->_objects[] = $object;
	}

	public function serialize() {
		$data = array('t' => WebcObject::TYPE_ARRAY, 'p' => array());
		foreach($this->_objects as $obj) {
			if (!is_a($obj, 'WebcObject')) {
				continue;
			}
			$data['p'][] = $obj->serialize();
		}
		return $data;
	}

	public function unserialize(Array $data) {
		if (!is_int($data['t']) || ($data['t'] != WebcObject::TYPE_ARRAY) || !is_array($data['p'])) {
			throw new Exception('unserialize failed, protocol mismatch');
		}

		$this->_objects = array();
		foreach($data['p'] as $subData) {
			$this->_objects[] = WebcObject::smartObject($subData);
		}
	}
}

class WebcInteger extends WebcObject {
	protected $_val = 0;

	public function set($val) {
		if (!is_int($val)) {
			throw new Execption('type mismatch, int expected');
		}
		$this->_val = $val;
	}

	public function get() {
		return $this->_val;
	}

	public function serialize() {
		return array('t' => WebcObject::TYPE_INTEGER, 'p' => $this->_val);
	}

	public function unserialize(Array $data) {
		if (!is_int($data['t']) || ($data['t'] != WebcObject::TYPE_INTEGER) || !is_int($data['p'])) {
			throw new Exception('unserialize failed, protocol mismatch');
		}
		$this->_val = $data['p'];
	}
}

class WebcString extends WebcObject {
	protected $_val = "";

	public function set($val) {
		if (!is_string($val)) {
			throw new Execption('type mismatch, string expected');
		}
		$this->_val = $val;
	}

	public function get() {
		return $this->_val;
	}

	public function serialize() {
		return array('t' => WebcObject::TYPE_STRING, 'p' => $this->_val);
	}

	public function unserialize(Array $data) {
		if (!is_int($data['t']) || ($data['t'] != WebcObject::TYPE_STRING) || !is_string($data['p'])) {
			throw new Execption('unserialize failed, protocol mismatch');
		}
		$this->_val = $data['p'];
	}
}

class WebcBool extends WebcObject {
	protected $_val = false;

	public function set($val) {
		if (!is_bool($val)) {
			throw new Execption('type mismatch, bool expected');
		}
		$this->_val = $val;
	}

	public function get() {
		return $this->_val;
	}

	public function serialize() {
		return array('t' => WebcObject::TYPE_BOOL, 'p' => $this->_val);
	}

	public function unserialize(Array $data) {
		if (!is_int($data['t']) || ($data['t'] != WebcObject::TYPE_BOOL) || !is_bool($data['p'])) {
			throw new Execption('unserialize failed, protocol mismatch');
		}
		$this->_val = $data['p'];
	}
}

class WebcNull extends WebcObject {
	public function serialize() {
		return array('t' => WebcObject::TYPE_NULL);
	}

	public function unserialize(Array $data) {
	}
}
