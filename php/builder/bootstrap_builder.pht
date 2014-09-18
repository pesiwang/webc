<?php
require __DIR__ . '/lib/structure.class.php';
require __DIR__ . '/lib/interface.class.php';
class Bootstrap{
	static public function run($appDir){
		$json = json_decode(file_get_contents('php://input'), true);
		if((NULL == $json) || (FALSE == $json)){
			return;
		}

		$appFile = __DIR__ . '/app/' . preg_replace('/\\./', '/', $_SERVER['REQUEST_URI']) . '.php';
		$appClass = '\\<%$server->namespace%>\\' . ucfirst(preg_replace('/\\.([a-z])/ei', "strtoupper('\\1')", $_SERVER['REQUEST_URI']));
		$requestClass = '\\<%$server->namespace%>\\' . $appClass . 'Request';
		$responseClass = '\\<%$server->namespace%>\\' . $appClass . 'Response';

		if(!file_exists($appFile)){
			die('no such file:' . $appFile);
			return;
		}

		require_once $appFile;
		$request = new $requestClass();
		$response = new $responseClass();
		self::_fromArray($request, $json);

		$app = new $appClass();
		$app->run($request, $response);

		header('Content-Type:text/plain;charset=utf-8');
		$json = array();
		self::_toArray($response, $json);
		echo json_encode($json);
	}

	static private function _fromArray($structure, $array){
		foreach($structure as $k => &$v){
			if(!isset($array[$k]))
				continue;

			if(is_object($v))
				self::_fromArray($v, $array[$k]);
			else
				$v = $array[$k];
		}
	}

	static private function _toArray($structure, $array){
		foreach($structure as $k => &$v){
			if(is_object($v)){
				$subArray = array();
				self::_toArray($v, $subArray);
				$array[$k] = $subArray;
			}
			else{
				$array[$k] = $v;
			}
		}
	}
}

Bootstrap::run();
