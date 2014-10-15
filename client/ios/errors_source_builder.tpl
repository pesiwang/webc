#import "webc_errors.h"

@implementation <%$server->namespace|strtoupper%>ErrorManager 
- (id)initWithResult:(NSInteger)result withMessage:(NSString*)message{
	_result = result;
	_message = message;
	if((result != 0) && (message != nil)){
		switch(_result){
<%foreach $errors as $error%>
			case <%$server->namespace|strtoupper%>_<%$error->name%>:
				_message = @"<%$error->message%>";
				break;
<%/foreach%>
			default:
				_message = @"未知错误";
				break;
		}
	}
}
@end
