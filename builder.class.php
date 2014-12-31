<?php
require_once __DIR__ . '/parser.class.php';
require_once __DIR__ . '/3party/smarty/Smarty.class.php';

abstract class Builder {
	protected $_sourceFiles;
	protected $_targetFolder;

	public function __construct($sourceFolder, $targetFolder) {
		$this->_targetFolder = $targetFolder;
		if (!is_dir($sourceFolder) || !is_readable($sourceFolder)) {
			throw new Exception('source folder not exists');
		}
		if (!is_dir($this->_targetFolder) || !is_writable($this->_targetFolder)) {
			throw new Exception('target folder not exists or not writable');
		}

		$this->_sourceFiles = array();
		if ($handle = opendir($sourceFolder)) {
			while (false !== ($entry = readdir($handle))) {
				if (preg_match('/\\.xml$/i', $entry)) {
					$this->_sourceFiles[] = $sourceFolder . '/' . $entry;
				}
			}
		    closedir($handle);
		}
	}

	protected function getParser($sourceFile) {
		$parser = new Parser($sourceFile);
		return $parser;
	}

	protected function getSmarty() {
		$smarty = new \Smarty();
		$smarty->compile_dir = '/tmp';
		$smarty->left_delimiter = '<%';
		$smarty->right_delimiter = '%>';
		$smarty->caching = false;
		return $smarty;
	}

	protected function saveFile($file, $content, $overwrite = true) {
		$dir = $this->_targetFolder . '/' . dirname($file);
		if (!file_exists($dir)) {
			mkdir($dir, 0777, true);
		}
		if (!$overwrite && file_exists($this->_targetFolder . '/' . $file)) {
			echo "skipping " . $this->_targetFolder . '/' . $file, "\n";
		}
		else {
			file_put_contents($this->_targetFolder . '/' . $file, $content);
		}
	}

	abstract function build();
}
