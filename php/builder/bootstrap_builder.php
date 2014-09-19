<?php
namespace webc;
require_once __DIR__ . '/../builder.php';

class BootstrapBuilder extends Builder
{
	public function execute()
	{
		$this->output('bootstrap_builder.tpl');
	}
}

if($argc < 2)
	die("usage: php " . $argv[0] . " <xml>\n");
		    
try{
	$builder = new BootstrapBuilder($argv[1]);
	$builder->execute();
}
catch(Exception $e){
	die("compilation failed, reason:" . $e->getMessage() . "\n");
}
