#import "webc_errors.h"

@interface <%$server->namespace|strtoupper%>ErrorManager 
+ (NSString*)getMessageWithCode:(NSInteger)code
{
	switch(code){
<%foreach $errors as $error%>
		case <%$server->namespace|strtoupper%>_<%$error->name%>:
			return @"<%$error->message%>"
			break;
<%/foreach%>
		default:
			break;
	}
	return @"未知错误";
}
@end
