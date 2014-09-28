#import <Foundation/Foundation.h>

<%foreach $errors as $error%>
#define <%$server->namespace|strtoupper%>_<%$error->name%> <%$error->code%>
<%/foreach%>

@interface <%$server->namespace|strtoupper%>ErrorManager : NSObject
+ (NSString*)getMessageWithCode:(NSInteger)code;
@end
