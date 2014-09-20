<?php
function smarty_modifier_webc_is_struct($string)
{
	return (strcmp($string, strtoupper($string)) != 0);
}
