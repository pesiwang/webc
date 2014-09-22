#import "webc_interfaces.h"

@interface <%$server->namespace|strtoupper%>Client()
+ (NSData *)_call:(NSString*)interface withRequest:(NSData*)request;
@end

@implementation <%$server->namespace|strtoupper%>Client

+ (NSData *)_call:(NSString*)interface withRequest:(NSData*)request
{
	NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] init];
	[urlRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"<%$server->protocol%>://<%$server->host%>:<%$server->port%>/%@", interface]]];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:request];
	[urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[urlRequest setTimeoutInterval:30.0];

	NSHTTPURLResponse* httpResponse = nil;
	NSError* error = nil;
	NSData* responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&httpResponse error:&error];
	if(error || !responseData)
		return nil;
	
	return responseData;
}

<%foreach $interfaces as $interface%>
+ (<%$server->namespace|strtoupper%>Struct<%$interface->response|webc_name2camel%>*)call<%$interface->name|webc_name2camel%>:(<%$server->namespace|strtoupper%>Struct<%$interface->request|webc_name2camel%>*)request
{
	NSData *responseData = [<%$server->namespace|strtoupper%>Client _call:@"<%$interface->name%>" withRequest:[[request toJSONString] dataUsingEncoding:NSUTF8StringEncoding]];
	if(!responseData)
		return nil;
			
	NSError* error = nil;
	<%$server->namespace|strtoupper%>Struct<%$interface->response|webc_name2camel%>* response = [[<%$server->namespace|strtoupper%>Struct<%$interface->response|webc_name2camel%> alloc] initWithData:responseData error:&error];

	if(error || !responseData)
		return nil;
						
	return response;
}
<%/foreach%>
@end
