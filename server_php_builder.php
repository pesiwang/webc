<?php
require_once __DIR__ . '/builder.class.php';
require_once __DIR__ . '/3party/smarty/Smarty.class.php';

class ServerPhpBuilder extends Builder {

	public function build() {
		$smarty = $this->getSmarty();
		$content = $smarty->fetch(__DIR__ . '/server/php/webc.class.tpl');
		$this->saveFile('/lib/webc.class.php', $content);

		$smarty = $this->getSmarty();
		$content = $smarty->fetch(__DIR__ . '/server/php/bootstrap.tpl');
		$this->saveFile('/bootstrap.php', $content);

		foreach ($this->_sourceFiles as $sourceFile) {
			$parser = $this->getParser($sourceFile);
			$smarty = $this->getSmarty();
			$smarty->assign('structs', $parser->getStructs());
			$content = $smarty->fetch(__DIR__ . '/server/php/objects.class.tpl');
			$this->saveFile('/app/v' . $parser->getVersion() . '/lib/objects.class.php', $content);

			foreach($parser->getInterfaces() as $interface) {
				$smarty = $this->getSmarty();
				$smarty->assign('interface', $interface);
				$content = $smarty->fetch(__DIR__ . '/server/php/interface.class.tpl');
				$this->saveFile('/app/v' . $parser->getVersion() . '/interfaces/' . str_replace('.', '/', $interface->getName()) . '.class.php', $content);
			}
		}
	}
}

if($argc < 3)
	die("usage: php " . $argv[0] . " <source_folder> <target_folder>\n");

try{
	$builder = new ServerPhpBuilder($argv[1], $argv[2]);
	$builder->build();
}
catch(Exception $e){
	die("compilation failed, reason:" . $e->getMessage() . "\n");
}
