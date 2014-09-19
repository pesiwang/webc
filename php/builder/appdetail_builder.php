<?php
namespace webc;
require_once __DIR__ . '/../builder.php';

class AppdetailBuilder extends Builder
{
	public function setAppName($name)
	{
		$this->_doc = $name;
	}
	public function execute()
	{
		$this->output('appdetail_builder.tpl');
	}
}

if($argc < 3)
	die("usage: php " . $argv[0] . " <xml> <appname>\n");

try{
	$builder = new AppdetailBuilder($argv[1]);
	$builder->setAppName($argv[2]);
	$builder->execute();
}
catch(Exception $e){
	die("compilation failed, reason:" . $e->getMessage() . "\n");
}
