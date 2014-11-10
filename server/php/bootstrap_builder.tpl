<?php
define('PROJECT_ROOT', __DIR__);

class Bootstrap{
	static public function run(){
		$json = json_decode(($_SERVER['REQUEST_METHOD'] == 'GET') ? $_SERVER['QUERY_STRING'] : file_get_contents('php://input'), true);
		if(!is_array($json)){
			die('Bad Request');
			return;
		}

		$parsedUrl = parse_url($_SERVER['REQUEST_URI']);
		$pathInfos = explode('/', ltrim($parsedUrl['path'], '/'));
		if(!is_array($pathInfos) || (count($pathInfos) != 2)){
			die('Bad Request');
			return;
		}
		$version = $pathInfos[0];
		$requestInterfaceName = $pathInfos[1];

		require __DIR__ . '/lib/webc/' . $version . '/structs.class.php';
		require __DIR__ . '/lib/webc/' . $version . '/errors.class.php';

		$appFile = __DIR__ . '/app/' . $version . '/' . preg_replace('/\\./', '/', $requestInterfaceName) . '.php';

		$theClass = ucfirst(preg_replace('/\\.([a-z])/ei', "strtoupper('\\1')", $requestInterfaceName));
		$appClass = '\\webc\\Application' . $theClass;
		$requestClass = '\\webc\\Struct' . $theClass . 'Request';
		$responseClass = '\\webc\\Struct' . $theClass . 'Response';

		if(!file_exists($appFile)){
			die('Internal Server Error');
			return;
		}

		require_once $appFile;
		$request = new $requestClass();
		$response = new $responseClass();

		try{
			$request->fromArray($json);
		}
		catch(Exception $e){
			die('Bad Request');
		}

		$app = new $appClass();
		$result = $app->run($request, $response);
		header('Content-Type:text/plain;charset=utf-8');

		if($result == 0){
			echo json_encode(array('result' => $result, 'payload' => $response->toArray()));
		}
		else{
			echo json_encode(array('result' => $result));
		}
	}
}

Bootstrap::run();
