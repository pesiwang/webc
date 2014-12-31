<?php
require_once __DIR__ . '/builder.class.php';
require_once __DIR__ . '/3party/smarty/Smarty.class.php';

class ClientPhpBuilder extends Builder {

	public function build() {
		$smarty = $this->getSmarty();
		$content = $smarty->fetch(__DIR__ . '/client/php/webc.class.tpl');
		$this->saveFile('/webc.class.php', $content);

		$parser = null;
		foreach ($this->_sourceFiles as $sourceFile) {
			if($parser == null) {
				$parser = $this->getParser($sourceFile);
			}
			else {
				$tmpParser = $this->getParser($sourceFile);
				$parser->merge($tmpParser);
			}
		}

		$smarty = $this->getSmarty();
		$smarty->assign('structs', $parser->getStructs());
		$content = $smarty->fetch(__DIR__ . '/client/php/objects.class.tpl');
		$this->saveFile('/objects.class.php', $content);

		$smarty = $this->getSmarty();
		$smarty->assign('interfaces', $parser->getInterfaces());
		$content = $smarty->fetch(__DIR__ . '/client/php/client.class.tpl');
		$this->saveFile('/client.class.php', $content);
	}
}

if($argc < 3)
	die("usage: php " . $argv[0] . " <source_folder> <target_folder>\n");

try{
	$builder = new ClientPhpBuilder($argv[1], $argv[2]);
	$builder->build();
}
catch(Exception $e){
	die("compilation failed, reason:" . $e->getMessage() . "\n");
}
