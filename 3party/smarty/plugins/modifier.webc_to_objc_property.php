<?php
function smarty_modifier_webc_to_objc_property($string)
{
	switch($string){
		case 'STRING':
			return 'strong';
			break;
		case 'INTEGER':
		case 'BOOL':
			return 'assign';
			break;
		default:
			return 'strong';
			break;
	}
}
