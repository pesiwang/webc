<?php
namespace <%$server->namespace%>;

require_once __DIR__ . '/structs.class.php';
require_once __DIR__ . '/errors.class.php';

class Client
{
	static protected function _call($interface, Struct $request, Struct &$response){
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, "<%$server->protocol%>://<%$server->host%>:<%$server->port%>/" . $interface . "/<%$version%>");
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($request->toArray()));
		curl_setopt($ch, CURLOPT_CONNECTTIMEOUT ,0); 
		curl_setopt($ch, CURLOPT_TIMEOUT, 30);
		$rawData = curl_exec($ch);
		
		$json = json_decode($rawData, true);
        if(!is_array($json))
			return new Error(-1, "call failure, underlying body = ${rawData}");

		if($json['result'] != 0)
			return new Error($json['result']);
	        
        $response->fromArray($json['payload']);
		return new Error(0);
	}
<%foreach $interfaces as $interface%>

	static public function call<%$interface->name|webc_name2camel%>(Struct<%$interface->request|webc_name2camel%> $request, Struct<%$interface->response|webc_name2camel%> &$response){
		return self::_call('<%$interface->name%>', $request, $response);
	}
<%/foreach%>
}
