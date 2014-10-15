<?php
namespace <%$server->namespace%>;
require_once __DIR__ . '/lib/interfaces.class.php';

class Test
{
	static $stdin;

	static public function run($interface){
		self::$stdin = fopen('php://stdin', 'r');

		switch($interface){
<%foreach $interfaces as $interface%>
			case '<%$interface->name%>':
				self::_run<%$interface->name|webc_name2camel%>();
				break;
<%/foreach%>
			default:
				self::_showAllInterfaces();
				break;
		}
	}

<%foreach $interfaces as $interface%>
	static private function _run<%$interface->name|webc_name2camel%>(){
		$request = new Struct<%$interface->request|webc_name2camel%>();
		$response = new Struct<%$interface->response|webc_name2camel%>();
		self::_prepareStruct(1, 'Struct<%$interface->request|webc_name2camel%>', &$request);

		$error = Client::call<%$interface->name|webc_name2camel%>($request, &$response);
		if($error->getResult() == Error::SUCC){
			echo "TESTING RESULT: SUCC\n";
			var_dump($response);
		}
		else{
			echo "TESTING RESULT: FAILED\n";
			echo $error->getMessage(), "\n";
		}
	}
<%/foreach%>

	static private function _prepareStruct($indent, $prefix, Struct &$struct){
		foreach($struct as $key => &$value){
			self::_printInputPrompt($indent, $prefix, $key, $value);
			if(is_a($value, '\<%$server->namespace%>\Struct'))
				self::_prepareStruct($indent + 1, $prefix . '.' . $key, &$value);
			else{
				$input = fscanf(self::$stdin, "%s\n");
				if(is_array($input) && (count($input) > 0)){
					$input = trim($input[0]);
					$setFunc = 'set' . $key;
					if(is_bool($value))
						$struct->$setFunc((strcasecmp($input, 'false') == 0) ? false : true);
					else if(is_int($value))
						$struct->$setFunc(intval($input));
					else
						$struct->$setFunc($input);
				}
			}
		}
	}

	static private function _printInputPrompt($indent, $prefix, $key, $value){
		for($i = 0; $i < $indent - 1; ++$i)
			echo '   ';
		echo '|--', $prefix, '.', $key;

		if(is_a($value, '\<%$server->namespace%>\Struct'))
			echo '(OBJECT)', "\n";
		else if(is_bool($value))
			echo '(BOOL):';
		else if(is_int($value))
			echo '(INTEGER):';
		else
			echo '(STRING):';
	}

	static private function _showAllInterfaces(){
		echo "usage: php test.php <interface>\n";
		echo "======Available Interfaces======\n";
<%foreach $interfaces as $interface%>
		echo "<%$interface->name%>\n";
<%/foreach%>
	}
}

$interface = '';
if($argc >= 2)
	$interface = $argv[1];

Test::run($interface);
