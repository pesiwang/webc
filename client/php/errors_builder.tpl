<?php
namespace <%$server->namespace%>;

<%foreach $errors as $error%>
define(__NAMESPACE__ . '\<%$error->name%>', <%$error->code%>);
<%/foreach%>

class ErrorManager
{
	static public function getMessageWithCode($code){
		switch($code){
<%foreach $errors as $error%>
			case <%$error->code%>:
				return '<%$error->message%>';
				break;
<%/foreach%>
			default:
				break;
		}
		return '未知错误';
	}
}
