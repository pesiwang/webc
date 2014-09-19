<?php
namespace <%$server->namespace%>;
<%foreach $doc as $interface%>

class <%$interface->name|webc_name2camel%>Request
{
<%foreach $interface->requestParams as $param%>
	private $<%$param->name%>;
<%/foreach%>

	public function __construct(){
<%foreach $interface->requestParams as $param%>
		$this-><%$param->name%> = <%if !$param->type|webc_type_is_basic%>new <%$param->type|webc_name2camel%>()<%else%><%if (strlen($param->default) == 0)%>NULL<%else%><%if $param->type|webc_type_is_string%>'<%$param->default%>'<%else%><%$param->default%><%/if%><%/if%><%/if%>;
<%/foreach%>
	}
<%foreach $interface->requestParams as $param%>

	public function get<%$param->name|webc_name2camel%>(){
		return $this-><%$param->name%>;
	}

	public function set<%$param->name|webc_name2camel%>($<%$param->name%>){
<%if (strlen($param->validation) > 0)%>
		if(false === filter_var($<%$param->name%>, FILTER_VALIDATE_REGEXP, array('options' => array('regexp' => '/<%$param->validation%>/'))))
			throw new Exception('validation failed');
<%/if%>
		$this-><%$param->name%> = $<%$param->name%>;
		return $this;
	}
<%/foreach%>
}

class <%$interface->name|webc_name2camel%>Response
{
<%foreach $interface->responseParams as $param%>
	private $<%$param->name%>;
<%/foreach%>

	public function __construct(){
<%foreach $interface->responseParams as $param%>
		$this-><%$param->name%> = <%if !$param->type|webc_type_is_basic%>new <%$param->type|webc_name2camel%>()<%else%><%if (strlen($param->default) == 0)%>NULL<%else%><%if $param->type|webc_type_is_string%>'<%$param->default%>'<%else%><%$param->default%><%/if%><%/if%><%/if%>;
<%/foreach%>
	}
<%foreach $interface->responseParams as $param%>

	public function get<%$param->name|webc_name2camel%>(){
		return $this-><%$param->name%>;
	}

	public function set<%$param->name|webc_name2camel%>($<%$param->name%>){
<%if (strlen($param->validation) > 0)%>
		if(false === filter_var($<%$param->name%>, FILTER_VALIDATE_REGEXP, array('options' => array('regexp' => '/<%$param->validation%>/'))))
			throw new Exception('validation failed');
<%/if%>
		$this-><%$param->name%> = $<%$param->name%>;
		return $this;
	}
<%/foreach%>
}

<%/foreach%>
