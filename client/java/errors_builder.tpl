package com.vanchu.libs.webc;

public class Error
{
	static final int SUCC = 0x0000;
<%foreach $errors as $error%>
	static final int <%$error->name%> = <%$error->code%>;
<%/foreach%>

	private int _result;
	private String _message;

	public int getResult(){
		return this._result;
	}

	public String getMessage(){
		return this._message;
	}

	public Error(int result, String message){
		this._result = result;
		this._message = message;
		if((this._result != 0) && (this._message == null)){
			switch(this._result){
<%foreach $errors as $error%>
				case <%$error->code%>:
					this._message = "<%$error->message%>";
					break;
<%/foreach%>
				default:
					this._message = "未知错误";
					break;
			}
		}
	}
}
