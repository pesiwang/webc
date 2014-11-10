#import "WebcInterfaces.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface WebcClient()
+ (NSData *)_call:(NSString*)interface withRequest:(NSData*)request;
+ (void)_invoke:(NSString*)interface withRequest:(NSData*)request withResponseCallback:(void (^)(NSData* response))responseBlock;
@end

@implementation WebcClient

+ (NSData *)_call:(NSString*)interface withRequest:(NSData*)request
{
	ASIFormDataRequest *asiRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"<%$server->protocol%>://<%$server->host%>:<%$server->port%>/<%$version%>/%@", interface]]];
	asiRequest.postBody = [NSMutableData dataWithData:request];
	asiRequest.postLength = request.length;
	asiRequest.timeOutSeconds = 30.0f;
	asiRequest.cachePolicy = ASIDoNotWriteToCacheCachePolicy|ASIDoNotReadFromCacheCachePolicy;
	asiRequest.allowCompressedResponse = YES;
	[asiRequest startSynchronous];
	if ([asiRequest error]) {
		return nil;
	}
	return asiRequest.responseData;
}

+ (void)_invoke:(NSString*)interface withRequest:(NSData*)request withResponseCallback:(void (^)(NSData* response))responseBlock
{
	ASIFormDataRequest* asiRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"<%$server->protocol%>://<%$server->host%>:<%$server->port%>/<%$version%>/%@", interface]]];
	__block ASIFormDataRequest* _asiRequest = asiRequest;
	asiRequest.postBody = [NSMutableData dataWithData:request];
	asiRequest.postLength = request.length;
	asiRequest.timeOutSeconds = 30.0f;
	asiRequest.cachePolicy = ASIDoNotWriteToCacheCachePolicy|ASIDoNotReadFromCacheCachePolicy;
	asiRequest.allowCompressedResponse = YES;
	[asiRequest setCompletionBlock:^{
		responseBlock(_asiRequest.responseData);
	}];
	[asiRequest setFailedBlock:^{
		responseBlock(nil);
	}];
	[asiRequest startAsynchronous];
}
<%foreach $interfaces as $interface%>

+ (WebcError*)call<%$interface->name|webc_name2camel%>:(WebcStruct<%$interface->request|webc_name2camel%>*)request withResponse:(WebcStruct<%$interface->response|webc_name2camel%>**)response;
{
	NSData *responseData = [WebcClient _call:@"<%$interface->name%>" withRequest:[[request toJSONString] dataUsingEncoding:NSUTF8StringEncoding]];
	if(!responseData)
		return [[WebcError alloc] initWithResult:-1 withMessage:@"network failure"];

	NSError* error = nil;
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
	if (json == nil)
		return [[WebcError alloc] initWithResult:-1 withMessage:@"bad data"];

	NSInteger result = [[json objectForKey:@"result"] integerValue];
	if(result != 0)
		return [[WebcError alloc] initWithResult:result withMessage:nil];

	NSDictionary* payload = [json objectForKey:@"payload"];
	*response = [[WebcStruct<%$interface->response|webc_name2camel%> alloc] initWithDictionary:payload error:&error];
	if(error || !response)
		return [[WebcError alloc] initWithResult:-1 withMessage:@"bad data"];

	return [[WebcError alloc] initWithResult:0 withMessage:nil];
}

+ (void)invoke<%$interface->name|webc_name2camel%>:(WebcStruct<%$interface->request|webc_name2camel%>*)request withResponseCallback:(void (^)(WebcStruct<%$interface->response|webc_name2camel%>* response, WebcError* error))responseBlock
{
	[WebcClient _invoke:@"<%$interface->name%>" withRequest:[[request toJSONString] dataUsingEncoding:NSUTF8StringEncoding] withResponseCallback:^(NSData* responseData){
		if(!responseData){
			responseBlock(nil, [[WebcError alloc] initWithResult:-1 withMessage:@"network failure"]);
			return;
		}

		NSError* error = nil;
		NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
		if (json == nil){
			responseBlock(nil, [[WebcError alloc] initWithResult:-1 withMessage:@"bad data"]);
			return;
		}
								
		NSInteger result = [[json objectForKey:@"result"] integerValue];
		if(result != 0){
			responseBlock(nil, [[WebcError alloc] initWithResult:result withMessage:nil]);
			return;
		}
												
		NSDictionary* payload = [json objectForKey:@"payload"];
		WebcStruct<%$interface->response|webc_name2camel%>* response = [[WebcStruct<%$interface->response|webc_name2camel%> alloc] initWithDictionary:payload error:&error];
		if(error || !response){
			responseBlock(nil, [[WebcError alloc] initWithResult:-1 withMessage:@"bad data"]);
			return;
		}
		responseBlock(response, [[WebcError alloc] initWithResult:0 withMessage:nil]);
	}];
}
<%/foreach%>

@end
