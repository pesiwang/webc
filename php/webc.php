<?php
date_default_timezone_set('Asia/Shanghai');
if($argc < 3)
	die("usage: php " . $argv[0] . " <web.xml> <instruction:structure|interface|bootstrap|applist|appdetail>\n");

require_once __DIR__ . '/3party/smarty/Smarty.class.php';

try{
	$xml = @simplexml_load_file($argv[1], null, LIBXML_NOCDATA);
	if($xml === FALSE)
		throw new Exception('bad xml file');

	$builder = NULL;
	switch($argv[2]){
		case 'structure':
			{
				require_once __DIR__ . '/builder/structure_builder.php';
				$builder = new \webc\StructureBuilder($xml);
			}
			break;
		case 'interface':
			{
				require_once __DIR__ . '/builder/interface_builder.php';
				$builder = new \webc\InterfaceBuilder($xml);
			}
			break;
		case 'bootstrap':
			{
				require_once __DIR__ . '/builder/bootstrap_builder.php';
				$builder = new \webc\BootstrapBuilder($xml);
			}
			break;
		case 'applist':
			{
				require_once __DIR__ . '/builder/applist_builder.php';
				$builder = new \webc\ApplistBuilder($xml);
			}
			break;
		case 'appdetail':
			{
				if($argc < 4)
					throw new Exception('appdetail requires 4 argvs');

				require_once __DIR__ . '/builder/appdetail_builder.php';
				$builder = new \webc\AppdetailBuilder($xml);
				$builder->setAppName($argv[3]);
			}
			break;
		default:
			break;
	}
	if(NULL != $builder)
		$builder->execute();
}
catch(Exception $e){
	die("compilation failed, reason:" . $e->getMessage() . "\n");
}
