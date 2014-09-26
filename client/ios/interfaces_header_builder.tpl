#import "webc_structs.h"
#import "webc_errors.h"

@interface <%$server->namespace|strtoupper%>Client : NSObject
<%foreach $interfaces as $interface%>
+ (<%$server->namespace|strtoupper%>Struct<%$interface->response|webc_name2camel%>*)call<%$interface->name|webc_name2camel%>:(<%$server->namespace|strtoupper%>Struct<%$interface->request|webc_name2camel%>*)request;
<%/foreach%>
@end
