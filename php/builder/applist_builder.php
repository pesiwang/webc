<?php
namespace webc;
require_once __DIR__ . '/../builder.php';

class ApplistBuilder extends Builder
{
	public function execute()
	{
		foreach($this->_xml->interface as $item){
			if(NULL == $item->attributes()->name)
				throw new \Exception("missing 'name' attribute in interface");
			$this->_doc[] = (string)($item->attributes()->name);
		}

		$this->output('applist_builder.tpl');
	}
}

if($argc < 2)
	die("usage: php " . $argv[0] . " <xml>\n");
		    
try{
	$builder = new ApplistBuilder($argv[1]);
	$builder->execute();
}
catch(Exception $e){
	die("compilation failed, reason:" . $e->getMessage() . "\n");
}
