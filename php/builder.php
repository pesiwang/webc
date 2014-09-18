<?php
namespace webc;

class OServer 
{
	public $host;
	public $port;
	public $protocol;
	public $namespace;
}

class OParam
{
	public $name;
	public $type;
	public $validation;
	public $default;
}

class OStructure
{
	public $name;
	public $params;
}

class OInterface
{
	public $name;
	public $requestParams;
	public $responseParams;
}

abstract class Builder
{
	protected $_xml;
	protected $_smarty;
	protected $_doc;

	protected $_server;

	public function __construct($xml)
	{
		$this->_xml = $xml;
		$this->_doc = array();

		$this->_server = new OServer();
		$this->_server->host = (string)($this->_xml->server->host);
		$this->_server->port = (int)($this->_xml->server->port);
		$this->_server->protocol = (string)($this->_xml->server->protocol);
		$this->_server->namespace = (string)($this->_xml->server->namespace);

		$this->_smarty = new \Smarty();
		$this->_smarty->template_dir = __DIR__ . '/builder/';
		$this->_smarty->compile_dir = '/tmp';
		$this->_smarty->left_delimiter = '<%';
		$this->_smarty->right_delimiter = '%>';
		$this->_smarty->caching = false;
		$this->_smarty->assign('server', $this->_server);
	}

	abstract public function execute();

	public function output($tpl)
	{
		$this->_smarty->assign('doc', $this->_doc);
		$this->_smarty->display($tpl);
	}
}
