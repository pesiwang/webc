<?php
namespace <%$server->namespace%>;

class Error
{
	const SUCC = 0x0000;
<%foreach $errors as $error%>
	const <%$error->name%> = <%$error->code%>;
<%/foreach%>

	private $_result;
	private $_message;

	public function getResult(){
		return $this->_result;
	}

	public function getMessage(){
		return $this->_message;
	}

	public function __construct($result, $message = null){
		$this->_result = $result;
		$this->_message = $message;
		if(($this->_result != 0) && ($this->_message == null)){
			switch($this->_result){
<%foreach $errors as $error%>
				case <%$error->code%>:
					$this->_message = '<%$error->message%>';
					break;
<%/foreach%>
				default:
					$this->_message = '未知错误';
					break;
			}
		}
	}
}
