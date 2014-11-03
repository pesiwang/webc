package com.vanchu.libs.webc.<%$server->namespace%>;

public class Struct{
<%foreach $structs as $struct%>
	public static class <%$struct->name|webc_name2camel%> extends Struct{
<%foreach $struct->params as $param%>
		public <%if ($param->type=='OBJECT')%><%$param->reference|webc_name2camel%><%else if ($param->type=='ARRAY')%>ArrayList<<%$param->reference|webc_name2camel%>><%else if ($param->type=='STRING')%>String<%else if ($param->type=='BOOL')%>Boolean<%else%>int<%/if%> <%$param->name%>;
<%/foreach%>

		public <%$struct->name|webc_name2camel%>(){
<%foreach $struct->params as $param%>
<%if ($param->type=='OBJECT')%>
			this.<%$param->name%> = new <%$param->reference|webc_name2camel%>();
<%else if ($param->type=='ARRAY')%>
			this.<%$param->name%> = new ArrayList<<%$param->reference|webc_name2camel%>>();
<%else if ($param->type=='STRING')%>
			this.<%$param->name%> = "";
<%else if ($param->type=='BOOL')%>
			this.<%$param->name%> = false;
<%else%>
			this.<%$param->name%> = 0;
<%/if%>
<%/foreach%>
		}
	}
<%/foreach%>
}
