<?php
require __DIR__ . '/lib/structs.class.php';
define('PROJECT_ROOT', __DIR__);

class Bootstrap{
	static public function run(){
		$json = json_decode(($_SERVER['REQUEST_METHOD'] == 'GET') ? $_SERVER['QUERY_STRING'] : file_get_contents('php://input'), true);
		if(!is_array($json)){
			die('Bad Request');
			return;
		}

		$parsedUrl = parse_url($_SERVER['REQUEST_URI']);
		$requestInterfaceName = ltrim($parsedUrl['path'], '/');

		$appFile = __DIR__ . '/app/' . preg_replace('/\\./', '/', $requestInterfaceName) . '.php';

		$theClass = ucfirst(preg_replace('/\\.([a-z])/ei', "strtoupper('\\1')", $requestInterfaceName));
		$appClass = '\\<%$server->namespace%>\\Application' . $theClass;
		$requestClass = '\\<%$server->namespace%>\\Struct' . $theClass . 'Request';
		$responseClass = '\\<%$server->namespace%>\\Struct' . $theClass . 'Response';

		if(!file_exists($appFile)){
			die('no such file:' . $appFile);
			return;
		}

		require_once $appFile;
		$request = new $requestClass();
		$response = new $responseClass();

		try{
			$request->fromArray($json);
		}
		catch(Exception $e){
			die('Invalid Struct: ' . $e->getMessage());
		}

		$app = new $appClass();
		$app->run($request, $response);

		header('Content-Type:text/plain;charset=utf-8');
		echo json_encode($response->toArray());
	}
}

Bootstrap::run();
