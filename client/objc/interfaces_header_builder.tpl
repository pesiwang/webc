#import "WebcStructs.h"
#import "WebcErrors.h"

@interface WebcClient : NSObject
<%foreach $interfaces as $interface%>
+ (WebcError*)call<%$interface->name|webc_name2camel%>:(WebcStruct<%$interface->request|webc_name2camel%>*)request withResponse:(WebcStruct<%$interface->response|webc_name2camel%>**)response;
+ (void)invoke<%$interface->name|webc_name2camel%>:(WebcStruct<%$interface->request|webc_name2camel%>*)request withResponseCallback:(void (^)(WebcStruct<%$interface->response|webc_name2camel%>* response, WebcError* error))responseBlock;
<%/foreach%>
@end
