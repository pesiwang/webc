<?php
require __DIR__ . '/lib/structures.class.php';
require __DIR__ . '/lib/interfaces.class.php';
class Bootstrap{
	static public function run(){
		$json = json_decode(($_SERVER['REQUEST_METHOD'] == 'GET') ? $_SERVER['QUERY_STRING'] : file_get_contents('php://input'), true);
		if((NULL == $json) || (FALSE == $json)){
			die('Bad Request');
			return;
		}

		$parsedUrl = parse_url($_SERVER['REQUEST_URI']);
		$requestInterfaceName = ltrim($parsedUrl['path'], '/');

		$appFile = __DIR__ . '/app/' . preg_replace('/\\./', '/', $requestInterfaceName) . '.php';
		$appClass = '\\' . ucfirst(preg_replace('/\\.([a-z])/ei', "strtoupper('\\1')", $requestInterfaceName));
		$requestClass = '\\<%$server->namespace%>' . $appClass . 'Request';
		$responseClass = '\\<%$server->namespace%>' . $appClass . 'Response';

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

	static private function _fromArray(&$structure, $array){
		foreach($structure as $k => &$v){
			if(!isset($array[$k]))
				continue;

			if(is_object($v))
				self::_fromArray($v, $array[$k]);
			else
				$v = $array[$k];
		}
	}

	static private function _toArray($structure, &$array){
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
