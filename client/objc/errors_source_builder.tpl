#import "WebcErrors.h"

@implementation <%$server->namespace|strtoupper%>Error
- (id)initWithResult:(NSInteger)result withMessage:(NSString*)message{
	self = [super init];
	if(self){
		_result = result;
		_message = message;
		if((result != 0) && (message != nil)){
			switch(_result){
<%foreach $errors as $error%>
				case <%$error->code%>:
					_message = @"<%$error->message%>";
					break;
<%/foreach%>
				default:
					_message = @"未知错误";
					break;
			}
		}
	}
	return self;
}
@end
