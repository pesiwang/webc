<?php
namespace webc;
require_once __DIR__ . '/../../builder.php';

class InterfaceBuilder extends Builder
{
	private $_knownStructures = array();

	public function execute()
	{
		foreach($this->_xml->structure as $item){
			if(NULL == $item->attributes()->name)
				throw new \Exception("missing 'name' attribute in structure");
			$this->_knownStructures[(string)($item->attributes()->name)] = 1;
		}

		foreach($this->_xml->interface as $item){
			$interface = new OInterface();
			if(NULL == $item->attributes()->name)
				throw new \Exception("missing 'name' attribute in interface");

			$interface->name = (string)($item->attributes()->name);
			$interface->requestParams = $this->_buildParams($item->request->param);
			$interface->responseParams = $this->_buildParams($item->response->param);
			$this->_doc[] = $interface;
		}

		$this->output(__DIR__ . '/interface_source_builder.tpl');
	}

	private function _buildParams($xml){
		if(NULL == $xml)
			throw new \Exception('cannot build params from empty xml');

		$params = array();
		foreach($xml as $param){
			$entityParam = new OParam();
			$entityParam->name = (string)($param->attributes()->name);
			$entityParam->type = (string)($param->attributes()->type);
			$entityParam->validation = (string)($param->attributes()->validate);
			$entityParam->default = (string)$param;
			$params[] = $entityParam;

			if(strcmp($entityParam->type, strtoupper($entityParam->type)) != 0){
				if(!isset($this->_knownStructures[$entityParam->type]))
					throw new \Exception('unknown type ' . $entityParam->type);
			}
		}
		return $params;
	}
}

if($argc < 2)
	die("usage: php " . $argv[0] . " <xml>\n");

try{
	$builder = new InterfaceBuilder($argv[1]);
	$builder->execute();
}
catch(Exception $e){
	die("compilation failed, reason:" . $e->getMessage() . "\n");
}
