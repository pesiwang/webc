<?php
namespace webc;

class Error
{
	const SUCC = 0x0000;
<%foreach $errors as $error%>
	const <%$error->name%> = <%$error->code%>;
<%/foreach%>
}
