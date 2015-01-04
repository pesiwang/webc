<?php
require_once __DIR__ . '/builder.class.php';
require_once __DIR__ . '/3party/smarty/Smarty.class.php';

class ClientObjcBuilder extends Builder {

	public function build() {
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
		$content = $smarty->fetch(__DIR__ . '/client/objc/WebcObject.h.tpl');
		$this->saveFile('/WebcObject.h', $content);

		$smarty = $this->getSmarty();
		$smarty->assign('structs', $parser->getStructs());
		$content = $smarty->fetch(__DIR__ . '/client/objc/WebcObject.m.tpl');
		$this->saveFile('/WebcObject.m', $content);

		$smarty = $this->getSmarty();
		$smarty->assign('interfaces', $parser->getInterfaces());
		$content = $smarty->fetch(__DIR__ . '/client/objc/WebcClient.h.tpl');
		$this->saveFile('/WebcClient.h', $content);

		$smarty = $this->getSmarty();
		$smarty->assign('interfaces', $parser->getInterfaces());
		$content = $smarty->fetch(__DIR__ . '/client/objc/WebcClient.m.tpl');
		$this->saveFile('/WebcClient.m', $content);
	}
}

if($argc < 3)
	die("usage: php " . $argv[0] . " <source_folder> <target_folder>\n");

try{
	$builder = new ClientObjcBuilder($argv[1], $argv[2]);
	$builder->build();
}
catch(Exception $e){
	die("compilation failed, reason:" . $e->getMessage() . "\n");
}
