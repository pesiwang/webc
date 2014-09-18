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
		$this->output('appdetail_builder.pht');
	}
}
