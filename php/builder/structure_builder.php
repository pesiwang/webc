<?php
namespace webc;
require_once __DIR__ . '/../builder.php';

class StructureBuilder extends Builder
{
	public function execute()
	{
		$knownStructures = array();

		foreach($this->_xml->structure as $item){
			if(NULL == $item->attributes()->name)
				throw new \Exception("missing 'name' attribute in structure");
			if(NULL == $item->param)
				throw new \Exception("missing 'param' fields in structure");
			
			$structure = new OStructure();
			$structure->name = (string)($item->attributes()->name);
			$knownStructures[$structure->name] = 1;
			$structure->params = array();

			foreach($item->param as $param){
				$entityParam = new OParam();
				$entityParam->name = (string)($param->attributes()->name);
				$entityParam->type = (string)($param->attributes()->type);
				$entityParam->validation = (string)($param->attributes()->validate);
				$entityParam->default = (string)$param;
				$structure->params[] = $entityParam;
			}

			$this->_doc[] = $structure;
		}

		foreach($this->_doc as $structure){
			foreach($structure->params as $param){
				if(strcmp($param->type, strtoupper($param->type)) == 0)
					continue;
				if(!isset($knownStructures[$param->type]))
					throw new \Exception('unknown type ' . $param->type);
			}
		}

		$this->output('structure_builder.pht');
	}
}
