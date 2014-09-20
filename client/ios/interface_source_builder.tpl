#import "webc_interfaces.class.h"
<%foreach $doc as $interface%>

@implementation Webc_<%$interface->name|webc_name2camel%>Request
- (id)init{
	self = [super init];
	if(self){
<%foreach $interface->requestParams as $param%>
		_<%$param->name%> = <%if $param->type|webc_type_is_structure%>[[ST_<%$param->type|webc_name2camel%> alloc] init]<%else%><%if (strlen($param->default) == 0)%>nil<%else%><%if $param->type|webc_type_is_string%>@"<%$param->default%>"<%else%><%$param->default%><%/if%><%/if%><%/if%>;
<%/foreach%>
	}
	return self;
}
<%foreach $interface->requestParams as $param%>

- (void)set<%$param->name|ucfirst%>:(<%$param->type|webc_type_to_objc_class%>)<%$param->name%>
{
<%if (strlen($param->validation) > 0)&&(!$param->type|webc_type_is_structure)%>
	NSRegularExpression *regexp = [[NSRegularExpression alloc] initWithPattern:@"<%$param->validation%>" options:0 error:nil];
	NSString* stringToCheck = <%if $param->type=='STRING'%><%$param->name%><%else%>[NSString stringWithFormat:@"%ld", (long)<%$param->name%>]<%/if%>;
	if([regexp numberOfMatchesInString:stringToCheck options:0 range:NSMakeRange(0, stringToCheck.length)] <= 0)
		return;
<%/if%>
	_<%$param->name%> = <%$param->name%>;
}
<%/foreach%>
@end

@implementation Webc_<%$interface->name|webc_name2camel%>Response
- (id)init{
	self = [super init];
	if(self){
<%foreach $interface->responseParams as $param%>
		_<%$param->name%> = <%if $param->type|webc_type_is_structure%>[[ST_<%$param->type|webc_name2camel%> alloc] init]<%else%><%if (strlen($param->default) == 0)%>nil<%else%><%if $param->type|webc_type_is_string%>@"<%$param->default%>"<%else%><%$param->default%><%/if%><%/if%><%/if%>;
<%/foreach%>
	}
	return self;
}
<%foreach $interface->responseParams as $param%>

- (void)set<%$param->name|ucfirst%>:(<%$param->type|webc_type_to_objc_class%>)<%$param->name%>
{
<%if (strlen($param->validation) > 0)&&(!$param->type|webc_type_is_structure)%>
	NSRegularExpression *regexp = [[NSRegularExpression alloc] initWithPattern:@"<%$param->validation%>" options:0 error:nil];
	NSString* stringToCheck = <%if $param->type=='STRING'%><%$param->name%><%else%>[NSString stringWithFormat:@"%ld", (long)<%$param->name%>]<%/if%>;
	if([regexp numberOfMatchesInString:stringToCheck options:0 range:NSMakeRange(0, stringToCheck.length)] <= 0)
		return;
<%/if%>
	_<%$param->name%> = <%$param->name%>;
}
<%/foreach%>
@end

<%/foreach%>
