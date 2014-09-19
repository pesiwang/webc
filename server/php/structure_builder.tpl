<?php
namespace <%$server->namespace%>;
<%foreach $doc as $structure%>

class ST_<%$structure->name|webc_name2camel%>
{
<%foreach $structure->params as $param%>
	public $<%$param->name%>;
<%/foreach%>

	public function __construct(){
<%foreach $structure->params as $param%>
		$this-><%$param->name%> = <%if !$param->type|webc_type_is_basic%>new ST_<%$param->type|webc_name2camel%>()<%else%><%if (strlen($param->default) == 0)%>NULL<%else%><%if $param->type|webc_type_is_string%>'<%$param->default%>'<%else%><%$param->default%><%/if%><%/if%><%/if%>;
<%/foreach%>
	}
<%foreach $structure->params as $param%>

	public function get<%$param->name|webc_name2camel%>(){
		return $this-><%$param->name%>;
	}

	public function set<%$param->name|webc_name2camel%>($<%$param->name%>){
<%if (strlen($param->validation) > 0)%>
		if(false === filter_var($<%$param->name%>, FILTER_VALIDATE_REGEXP, array('options' => array('regexp' => '/<%$param->validation%>/'))))
			throw new \Exception('validation failed');
<%/if%>
		$this-><%$param->name%> = $<%$param->name%>;
		return $this;
	}
<%/foreach%>
}
<%/foreach%>

