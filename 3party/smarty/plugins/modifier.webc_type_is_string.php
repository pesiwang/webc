<?php
function smarty_modifier_webc_type_is_string($string, $format = null, $default_date = '', $formatter = 'auto')
{
	return (strcmp($string, 'STRING') == 0);
}
