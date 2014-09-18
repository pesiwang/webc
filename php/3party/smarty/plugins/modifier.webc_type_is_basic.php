<?php
function smarty_modifier_webc_type_is_basic($string, $format = null, $default_date = '', $formatter = 'auto')
{
	return (strcmp($string, strtoupper($string)) == 0);
}
