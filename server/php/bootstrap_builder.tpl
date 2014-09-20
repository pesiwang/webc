<?php
require __DIR__ . '/lib/structures.class.php';
require __DIR__ . '/lib/interfaces.class.php';
class Bootstrap{
	static public function run(){
		$request = json_decode(($_SERVER['REQUEST_METHOD'] == 'GET') ? $_SERVER['QUERY_STRING'] : file_get_contents('php://input'));
		if(!is_object($request)){
			die('Bad Request');
			return;
		}

		$parsedUrl = parse_url($_SERVER['REQUEST_URI']);
		$requestInterfaceName = ltrim($parsedUrl['path'], '/');

		$appFile = __DIR__ . '/app/' . preg_replace('/\\./', '/', $requestInterfaceName) . '.php';
		$appClass = '\\' . ucfirst(preg_replace('/\\.([a-z])/ei', "strtoupper('\\1')", $requestInterfaceName));
		$responseClass = '\\<%$server->namespace%>' . $appClass . 'Response';

		if(!file_exists($appFile)){
			die('no such file:' . $appFile);
			return;
		}

		require_once $appFile;
		$response = new $responseClass();

		$app = new $appClass();
		$app->run($request, $response);

		header('Content-Type:text/plain;charset=utf-8');
		echo json_encode($response);
	}
}

Bootstrap::run();
