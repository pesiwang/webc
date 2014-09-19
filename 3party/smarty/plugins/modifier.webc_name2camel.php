<?php
function smarty_modifier_webc_name2camel($string, $format = null, $default_date = '', $formatter = 'auto')
{
	$newName = preg_replace('/_([a-z])/ei', "strtoupper('\\1')", $string);
	return ucfirst(preg_replace('/\\.([a-z])/ei', "strtoupper('\\1')", $newName));
}
