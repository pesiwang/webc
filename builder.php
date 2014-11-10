<?php
namespace webc;
date_default_timezone_set('Asia/Shanghai');
require_once __DIR__ . '/3party/smarty/Smarty.class.php';

class ObjServer 
{
	public $host;
	public $port;
	public $protocol;
}

class ObjParam
{
	public $name;
	public $type;       //OBJECT|ARRAY|INTEGER|BOOL|STRING
	public $reference;
}

class ObjError
{
	public $name;
	public $code;
	public $message;
}

class ObjStruct
{
	public $name;
	public $params;
}

class ObjInterface
{
	public $name;
	public $request;
	public $response;
}

class Builder
{
	private $_xml;
	private $_server;
	private $_errors;
	private $_structs;
	private $_interfaces;
	private $_version;
	private $_extra;

	private $_knownStructs;

	public function __construct($version, $extra){
		$this->_version = $version;
		$this->_extra = $extra;
	}

	public function compile($xmlFile, $tplFile){
		$this->_xml = @simplexml_load_file($xmlFile, null, LIBXML_NOCDATA);
		if($this->_xml === FALSE)
			throw new \Exception('bad xml file');

		$this->_compileServer();
		$this->_compileErrors();
		$this->_compileStructs();
		$this->_compileInterfaces();

		$smarty = new \Smarty();
		$smarty->compile_dir = '/tmp';
		$smarty->left_delimiter = '<%';
		$smarty->right_delimiter = '%>';
		$smarty->caching = false;
		$smarty->assign('server', $this->_server);
		$smarty->assign('errors', $this->_errors);
		$smarty->assign('structs', $this->_structs);
		$smarty->assign('interfaces', $this->_interfaces);
		$smarty->assign('version', $this->_version);
		$smarty->assign('extra', $this->_extra);
		$smarty->display($tplFile);
	}

	private function _compileServer(){
		if($this->_xml->server == NULL)
			throw new \Exception("no [server] block found in xml");
		if($this->_xml->server->host == NULL)
			throw new \Exception("no [host] node found in [server] block");
		if($this->_xml->server->port == NULL)
			throw new \Exception("no [port] node found in [server] block");
		if($this->_xml->server->protocol == NULL)
			throw new \Exception("no [protocol] node found in [server] block");

		$this->_server = new ObjServer();
		$this->_server->host = (string)($this->_xml->server->host);
		$this->_server->port = (int)($this->_xml->server->port);
		$this->_server->protocol = (string)($this->_xml->server->protocol);
	}

	private function _compileErrors(){
		foreach($this->_xml->error as $item){
			if(NULL == $item->attributes()->name){
				throw new \Exception("no [name] attribute found in [error] block");
			}
			if(NULL == $item->attributes()->code){
				throw new \Exception("no [code] attribute found in [error] block");
			}
			if(NULL == $item->attributes()->message){
				throw new \Exception("no [message] attribute found in [error] block");
			}

			$error = new ObjError();
			$error->name = (string)($item->attributes()->name);
			$error->code = (string)($item->attributes()->code);
			$error->message = (string)($item->attributes()->message);
			$this->_errors[] = $error;
		}
	}

	private function _compileStruct($parentName, $item){
		if(NULL == $item->attributes()->name)
			throw new \Exception("no [name] attribute found in [struct] block");
		if(NULL == $item->param)
			throw new \Exception("no [param] node found in [struct] block");

		$struct = new ObjStruct();
		$struct->name = (string)($item->attributes()->name);
		if(strlen($parentName) <= 0)
			$struct->name = (string)($item->attributes()->name);
		else
			$struct->name = $parentName . '_' . (string)($item->attributes()->name);

		$struct->params = array();

		foreach($item->param as $subItem){
			if(NULL == $subItem->attributes()->name)
				throw new \Exception("no [name] attribute found in [param] block");
			if(NULL == $subItem->attributes()->type)
				throw new \Exception("no [type] attribute found in [param] block");

			$param = new ObjParam();
			$param->name = (string)($subItem->attributes()->name);
			$param->type = (string)($subItem->attributes()->type);
			$param->reference = (NULL != $subItem->attributes()->reference) ? (string)($subItem->attributes()->reference) : NULL;

			if((($param->type == 'OBJECT') || ($param->type == 'ARRAY')) && ($param->reference == NULL)){
				$subStruct = $this->_compileStruct($struct->name, $subItem);
				$param->reference = $subStruct->name;
			}

			$struct->params[] = $param;
		}
		$this->_structs[$struct->name] = $struct;
		$this->_knownStructs[$struct->name] = 1;

		return $struct;
	}

	private function _compileStructs(){
		$this->_knownStructs = array();

		foreach($this->_xml->struct as $item)
			$this->_compileStruct('', $item);

		foreach($this->_structs as &$struct){
			foreach($struct->params as $param){
				if(NULL == $param->reference)
					continue;

				if(!isset($this->_knownStructs[$param->reference]))
					throw new \Exception('refering to unknown struct ' . $param->reference . ' in [' . $struct->name . ']');
			}
		}
	}

	private function _compileInterfaces(){
		foreach($this->_xml->interface as $item){
			$interface = new ObjInterface();
			if(NULL == $item->attributes()->name)
				throw new \Exception("no [name] attribute found in [interface] block");
			$interface->name = (string)($item->attributes()->name);

			$interface->request = (NULL != $item->attributes()->request) ? (string)($item->attributes()->request) : str_replace('.', '_', $interface->name) . '_request';
			$interface->response = (NULL != $item->attributes()->response) ? (string)($item->attributes()->response) : str_replace('.', '_', $interface->name) . '_response';

			if(!isset($this->_knownStructs[$interface->request]))
				throw new \Exception('refering to unknown struct ' . $interface->request);
			if(!isset($this->_knownStructs[$interface->response]))
				throw new \Exception('refering to unknown struct ' . $interface->response);

			$this->_interfaces[] = $interface;
		}
	}
}

if($argc < 4)
	die("usage: php " . $argv[0] . " <xml> <tpl> <version>\n");

try{
	$extra = ($argc > 4) ? $argv[4] : null;
	$builder = new Builder($argv[3], $extra);
	$builder->compile($argv[1], $argv[2]);
}
catch(\Exception $e){
	die("compilation failed, reason:" . $e->getMessage() . "\n");
}
