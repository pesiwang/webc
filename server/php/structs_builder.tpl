<?php
namespace webc;

class Struct
{
	public function toArray(){
		$arr = array();
		foreach($this as $k => $v){
			if(is_a($v, '\\webc\\Struct'))
				$arr[$k] = $v->toArray();
			else
				$arr[$k] = $v;
		}
		return $arr;
	}

	public function fromArray($arr){

		foreach($this as $k => &$v){
			if(!isset($arr[$k]))
				throw new \Exception("field($k) not found");
			if(is_a($v, '\\webc\\Struct'))
				$v->fromArray($arr[$k]);
			else
				$v = $arr[$k];
		}
	}
}

class Structs extends Struct
{
	protected $_objects;

	public function __construct(){
		$this->_objects = array();
	}

	public function toArray(){
		$arr = array();
		foreach($this->_objects as $v){
			if(is_a($v, '\\webc\\Struct')){
				$arr[] = $v->toArray();
			}
			else{
				$arr[] = $v;
			}
		}
		return $arr;
	}

	public function fromArray($arr){
		$this->_objects = $arr;
	}

	public function getObjects(){
		return $this->_objects;
	}

	public function addObject($object){
		$this->_objects[] = $object;
	}
}

<%foreach $structs as $struct%>

class Struct<%$struct->name|webc_name2camel%> extends Struct
{
<%foreach $struct->params as $param%>
	public $<%$param->name%>;
<%/foreach%>

	public function __construct(){
<%foreach $struct->params as $param%>
<%if ($param->type=='OBJECT')%>
		$this-><%$param->name%> = new Struct<%$param->reference|webc_name2camel%>();
<%else if ($param->type=='ARRAY')%>
		$this-><%$param->name%> = new Structs<%$param->reference|webc_name2camel%>();
<%else if ($param->type=='STRING')%>
		$this-><%$param->name%> = '';
<%else if ($param->type=='BOOL')%>
		$this-><%$param->name%> = false;
<%else%>
		$this-><%$param->name%> = 0;
<%/if%>
<%/foreach%>
	}
}

class Structs<%$struct->name|webc_name2camel%> extends Structs
{
	public function fromArray($arr)
	{
		$this->_objects = array();
		foreach($arr as $v){
			$obj = new Struct<%$struct->name|webc_name2camel%>();
			$obj->fromArray($v);
			$this->_objects[] = $obj;
		}
	}
}
<%/foreach%>
