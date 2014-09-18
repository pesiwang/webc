<?php
namespace webc;
require_once __DIR__ . '/../builder.php';

class BootstrapBuilder extends Builder
{
	public function execute()
	{
		$this->output('bootstrap_builder.pht');
	}
}
