#import "WebcStructs.h"
#import "WebcErrors.h"

@interface <%$server->namespace|strtoupper%>Client : NSObject
<%foreach $interfaces as $interface%>
+ (<%$server->namespace|strtoupper%>Error*)call<%$interface->name|webc_name2camel%>:(<%$server->namespace|strtoupper%>Struct<%$interface->request|webc_name2camel%>*)request withResponse:(<%$server->namespace|strtoupper%>Struct<%$interface->response|webc_name2camel%>**)response;
+ (void)invoke<%$interface->name|webc_name2camel%>:(<%$server->namespace|strtoupper%>Struct<%$interface->request|webc_name2camel%>*)request withResponseCallback:(void (^)(<%$server->namespace|strtoupper%>Struct<%$interface->response|webc_name2camel%>* response, <%$server->namespace|strtoupper%>Error* error))responseBlock;
<%/foreach%>
@end
