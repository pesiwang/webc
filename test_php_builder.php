<?php
require_once __DIR__ . '/builder.class.php';
require_once __DIR__ . '/3party/smarty/Smarty.class.php';

class TestPhpBuilder extends Builder {
	private $_host;

	public function __construct($sourceFolder, $targetFolder, $host) {
		parent::__construct($sourceFolder, $targetFolder);
		$this->_host = $host;
	}

	public function build() {
		$smarty = $this->getSmarty();
		$content = $smarty->fetch(__DIR__ . '/test/php/webc.class.tpl');
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
		$content = $smarty->fetch(__DIR__ . '/test/php/objects.class.tpl');
		$this->saveFile('/objects.class.php', $content);

		$smarty = $this->getSmarty();
		$smarty->assign('interfaces', $parser->getInterfaces());
		$content = $smarty->fetch(__DIR__ . '/test/php/test.class.tpl');
		$this->saveFile('/test.class.php', $content);

		$smarty = $this->getSmarty();
		$smarty->assign('interfaces', $parser->getInterfaces());
		$smarty->assign('host', $this->_host);
		$content = $smarty->fetch(__DIR__ . '/test/php/test.tpl');
		$this->saveFile('/test.php', $content);
	}
}

if($argc < 4)
	die("usage: php " . $argv[0] . " <source_folder> <target_folder> <host>\n");

try{
	$builder = new TestPhpBuilder($argv[1], $argv[2], $argv[3]);
	$builder->build();
}
catch(Exception $e){
	die("compilation failed, reason:" . $e->getMessage() . "\n");
}
