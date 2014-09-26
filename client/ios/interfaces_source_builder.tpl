#import "webc_interfaces.h"
#import "ASIHTTPRequest.h"

@interface <%$server->namespace|strtoupper%>Client()
+ (NSData *)_call:(NSString*)interface withRequest:(NSData*)request;
@end

@implementation <%$server->namespace|strtoupper%>Client

+ (NSData *)_call:(NSString*)interface withRequest:(NSData*)request
{
	ASIFormDataRequest *asiRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"<%$server->protocol%>://<%$server->host%>:<%$server->port%>/%@", interface]]];
	asiRequest.postBody = [NSMutableData dataWithData:request];
	asiRequest.postLength = request.length;
	[asiRequest startSynchronous];
	if ([asiRequest error]) {
		return nil;
	}
	return asiRequest.responseData;
}

+ (void)_invoke((NSString*)interface withRequest:(NSData*)request withResponseCallback:(void (^)(NSData* response))responseBlock
{
	__block ASIFormDataRequest *asiRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"<%$server->protocol%>://<%$server->host%>:<%$server->port%>/%@", interface]]];
	asiRequest.postBody = [NSMutableData dataWithData:request];
	asiRequest.postLength = request.length;
	[asiRequest setCompletionBlock:^{
		responseBlock(asiRequest.responseData);
	}];
	[asiRequest setFailedBlock:^{
		responseBlock(nil);
	}];
	[asiRequest startAsynchronous];
}

<%foreach $interfaces as $interface%>
+ (<%$server->namespace|strtoupper%>Struct<%$interface->response|webc_name2camel%>*)call<%$interface->name|webc_name2camel%>:(<%$server->namespace|strtoupper%>Struct<%$interface->request|webc_name2camel%>*)request
{
	NSData *responseData = [<%$server->namespace|strtoupper%>Client _call:@"<%$interface->name%>" withRequest:[[request toJSONString] dataUsingEncoding:NSUTF8StringEncoding]];
	if(!responseData)
		return nil;
			
	NSError* error = nil;
	<%$server->namespace|strtoupper%>Struct<%$interface->response|webc_name2camel%>* response = [[<%$server->namespace|strtoupper%>Struct<%$interface->response|webc_name2camel%> alloc] initWithData:responseData error:&error];

	if(error || !response)
		return nil;
						
	return response;
}
<%/foreach%>

+ (void)invoke<%$interface->name|webc_name2camel%>:(<%$server->namespace|strtoupper%>Struct<%$interface->request|webc_name2camel%>*)request withResponseCallback:(void (^)(<%$server->namespace|strtoupper%>Struct<%$interface->response|webc_name2camel%>* response))responseBlock
{
	[<%$server->namespace|strtoupper%>Client _invoke:@"<%$interface->name%>" withRequest:[[request toJSONString] dataUsingEncoding:NSUTF8StringEncoding] withResponseCallback:^(NSData* responseData){
		if(!responseData){
			responseBlock(nil);
			return;
		}

		NSError* error = nil;
		<%$server->namespace|strtoupper%>Struct<%$interface->response|webc_name2camel%>* response = [[<%$server->namespace|strtoupper%>Struct<%$interface->response|webc_name2camel%> alloc] initWithData:responseData error:&error];
		if(error || !response){
			responseBlock(nil);
			return;
		}

		responseBlock(response);
	}];
}

@end
