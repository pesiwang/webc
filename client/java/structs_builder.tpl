package com.vanchu.libs.webc;

public abstract class Struct{
	public abstract Boolean checkIntegrity();
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
<%/if%>
<%/foreach%>
		}

		public Boolean checkIntegrity(){
<%foreach $struct->params as $param%>
<%if ($param->type=='OBJECT')%>
			if(!this.<%$param->name%>.checkIntegrity())
				return false;
<%else if ($param->type=='ARRAY')%>
			for(<%$param->reference|webc_name2camel%> element : this.<%$param->name%>){
				if(!element.checkIntegrity())
					return false;
			}
<%else if ($param->type=='STRING')%>
			if(this.<%$param->name%> == null)
				return false;
<%/if%>
<%/foreach%>
			return true;
		}
	}
<%/foreach%>
}
