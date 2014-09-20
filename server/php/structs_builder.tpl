<?php
namespace <%$server->namespace%>;
<%foreach $structs as $struct%>

class Struct<%$struct->name|webc_name2camel%>
{
<%foreach $struct->params as $param%>
	public $<%$param->name%>;
<%/foreach%>

	public function __construct(){
<%foreach $struct->params as $param%>
<%if ($param->type=='OBJECT')&&($param->reference|webc_is_struct)%>
		$this-><%$param->name%> = new Struct<%$param->reference|webc_name2camel%>();
<%else if ($param->type=='ARRAY')%>
		$this-><%$param->name%> = array();
<%/if%>
<%/foreach%>
	}
<%foreach $struct->params as $param%>

	public function set<%$param->name|webc_name2camel%>($<%$param->name%>){
<%if isset($param->validation)%>
		if(false === filter_var($<%$param->name%>, FILTER_VALIDATE_REGEXP, array('options' => array('regexp' => '/<%$param->validation%>/'))))
			throw new \Exception('validation failed on field [<%$param->name%>]');
<%/if%>
		$this-><%$param->name%> = $<%$param->name%>;
		return $this;
	}
<%/foreach%>
}
<%/foreach%>
