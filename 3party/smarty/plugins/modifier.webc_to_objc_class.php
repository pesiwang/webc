<?php
function smarty_modifier_webc_to_objc_class($string, $pointer = true)
{
	switch($string){
		case 'STRING':
			return $pointer ? 'NSString*' : 'NSString';
			break;
		case 'INTEGER':
			return 'NSInteger';
			break;
		case 'BOOL':
			return 'BOOL';
			break;
		default:
			return 'WebcStruct' . ucfirst(preg_replace('/_([a-z])/ei', "strtoupper('\\1')", $string)) . ($pointer ? '*' : '');
			break;
	}
}
