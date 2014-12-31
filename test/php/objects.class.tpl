<?php
require_once __DIR__ . '/webc.class.php';
<%foreach $structs as $struct%>

class <%$struct->getClassName()%> extends WebcStruct {
<%foreach $struct->getObjects() as $obj%>
	public $<%$obj->getAbbrName()%>;
<%/foreach%>

	public function __construct() {
<%foreach $struct->getObjects() as $obj%>
<%if is_a($obj, 'WebcReference')%>
		$this-><%$obj->getAbbrName()%> = new <%$obj->getTarget()->getClassName()%>();
<%else%>
		$this-><%$obj->getAbbrName()%> = new <%$obj->getClassName()%>();
<%/if%>
<%/foreach%>
	}
}
<%/foreach%>
