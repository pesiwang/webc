<?php
class <%$interface->getClassName()%> {

	public function run(Array $inputData, Array &$outputData) {
		$request = new <%$interface->getRequest()->getClassName()%>();
		$response = new <%$interface->getResponse()->getClassName()%>();

		$request->unserialize($inputData);
		$code = $this->process($request, $response);
		if($code != 0)
			return $code;

		$outputData = $response->serialize();
		return $code;
	}

	private function process(<%$interface->getRequest()->getClassName()%> $request, <%$interface->getResponse()->getClassName()%> $response) {
	}
}
