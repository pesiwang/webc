<?php
define('PROJECT_ROOT', __DIR__);

class Bootstrap{
	static private function parseInput() {
		$json = json_decode(($_SERVER['REQUEST_METHOD'] == 'GET') ? $_SERVER['QUERY_STRING'] : file_get_contents('php://input'), true);
		if (!is_array($json))
			return null;
		return $json;
	}

	static private function parseRequest() {
		$parsedUrl = parse_url($_SERVER['REQUEST_URI']);
		$pathInfos = explode('/', ltrim($parsedUrl['path'], '/'));
		if(!is_array($pathInfos) || (count($pathInfos) != 2))
			return array(null, null);
		return array($pathInfos[0], $pathInfos[1]);
	}

	static private function instanceApp($version, $interfaceName) {
		$objFile = __DIR__ . '/app/v' . $version . '/lib/objects.class.php';
		$appFile = __DIR__ . '/app/v' . $version . '/interfaces/' . str_replace('.', '/', $interfaceName) . '.class.php';

		if (!file_exists($objFile) || !file_exists($appFile)) {
			return null;
		}

		require_once $objFile;
		require_once $appFile;

		$theClass = 'WebcInterface' . ucfirst(preg_replace('/\\.([a-z])/ei', "strtoupper('\\1')", $interfaceName));
		return new $theClass();
	}

	static private function error($code, $msg) {
		header('Content-Type:text/plain;charset=utf-8');
		echo json_encode(array('r' => $code, 'p' => $msg));
	}

	static public function run(){
		$inputData = self::parseInput();
		if (!is_array($inputData)) {
			return self::error(-1, 'Bad request');
		}

		list($version, $interfaceName) = self::parseRequest();
		if (!isset($version) || !isset($interfaceName)) {
			return self::error(-1, 'Bad request');
		}

		$app = self::instanceApp($version, $interfaceName);

		if (!isset($app)) {
			return self::error(-1, 'Internal Server Error');
		}

		try {
			$outputData = array();
			$result = $app->run($inputData, $outputData);

			if($result != 0){
				return self::error($result, 'Business Error');
			}

			header('Content-Type:text/plain;charset=utf-8');
			echo json_encode(array('r' => $result, 'p' => $outputData));
		}
		catch(Exception $e) {
			self::error(-1, 'Internal Server Error : ' . $e->getMessage());
		}
	}
}

Bootstrap::run();
