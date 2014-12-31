<?php
require_once __DIR__ . '/test.class.php';

class TestManager {
	public function usage() {
		echo "usage: php test.php <interface>\n";
		echo "Availiable interfaces are listed below:\n";
<%foreach $interfaces as $interface%>
		echo "\t<%$interface->getName()%>\n";
<%/foreach%>
	}

	public function test($interface) {
		WebcTest::setup("<%$host%>", 80);

		$method = 'test' . ucfirst(preg_replace('/\\.([a-z])/ei', "strtoupper('\\1')", $interface));
		if (!method_exists('WebcTest', $method)) {
			$this->error("undefined interface {$interface}");
			return;
		}

		$outcome = WebcTest::$method();
		if (is_a($outcome, 'WebcError')) {
			$this->error("Failed, code = " . $outcome->getCode() . " msg = " . $outcome->getMsg());
			return;
		}

		$this->info("Succ");
		WebcTest::printObject($outcome->getName(), $outcome);
	}

	private function error($msg) {
		echo "\033[01;31m" . $msg . "\033[0m\n";
	}

	private function info($msg) {
		echo "\033[01;32m" . $msg . "\033[0m\n";
	}
}

$testManager = new TestManager();
if ($argc < 2) {
	$testManager->usage();
}
else {
	$testManager->test($argv[1]);
}
