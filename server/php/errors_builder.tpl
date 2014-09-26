<?php
namespace <%$server->namespace%>;

<%foreach $errors as $error%>
define(__NAMESPACE__ . '\<%$error->name%>', <%$error->code%>);
<%/foreach%>
