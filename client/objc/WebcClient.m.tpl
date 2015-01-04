//
//  WebcClient.m
//  testdrive
//
//  Created by Chen Rui on 1/4/15.
//  Copyright (c) 2015 Vanchu. All rights reserved.
//

#import "WebcClient.h"

@implementation WebcError

- (instancetype)initWithCode:(NSInteger)code andMsg:(NSString *)msg {
	if (self = [super init]) {
		_code = code;
		_msg = msg;
	}
	return self;
}

@end

static NSString *webcHost = @"";
static NSInteger webcPort = 80;
static NSString *webcProtocol = @"http";

@implementation WebcClient

+ (void)setupWithHost:(NSString *)host {
	[WebcClient setupWithHost:host andPort:80];
}

+ (void)setupWithHost:(NSString *)host andPort:(NSInteger)port {
	[WebcClient setupWithHost:host andPort:port andProtocol:@"http"];
}

+ (void)setupWithHost:(NSString *)host andPort:(NSInteger)port andProtocol:(NSString *)protocol {
	webcHost = host;
	webcPort = port;
	webcProtocol = protocol;
}

+ (void)_invoke:(NSString *)interface withVersion:(NSInteger)version withRequest:(NSDictionary *)request withResponseCallback:(void (^)(NSDictionary *response))responseCallback withErrorCallback:(void (^)(WebcError *error))errorCallback {
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%ld/%ld/%@", webcProtocol, webcHost, (long)webcPort, (long)version, interface]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
		[urlRequest setHTTPMethod:@"POST"];
		[urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:request options:0 error:nil]];
		[urlRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
		
		NSURLResponse *urlResponse = nil;
		NSError *error = nil;
		NSData *json = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];
		
		if ((error) || (json == nil)) {
			dispatch_async(dispatch_get_main_queue(), ^{
				errorCallback([[WebcError alloc] initWithCode:-1 andMsg:@"Network Error"]);
			});
			return;
		}
		
		NSDictionary *data = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
		if ((data == nil) || ([data objectForKey:@"r"] == nil) || ([data objectForKey:@"p"] == nil)) {
			dispatch_async(dispatch_get_main_queue(), ^{
				errorCallback([[WebcError alloc] initWithCode:-1 andMsg:@"Protocol Error"]);
			});
			return;
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			NSInteger result = [[data objectForKey:@"r"] integerValue];
			id payload = [data objectForKey:@"p"];

			if (![payload isKindOfClass:NSDictionary.class]) {
				errorCallback([[WebcError alloc] initWithCode:result andMsg:payload]);
			}
			else {
				responseCallback(payload);
			}
		});
	});
}
<%foreach $interfaces as $interface%>

+ (void)invoke<%$interface->getName(true)%>WithRequest:(<%$interface->getRequest()->getClassName()%>*)request withResponseCallback:(void (^)(<%$interface->getResponse()->getClassName()%>* response))responseCallback withErrorCallback:(void (^)(WebcError *error))errorCallback {
	@try {
		[WebcClient _invoke:@"<%$interface->getName()%>" withVersion:<%$interface->getVersion()%> withRequest:[request serialize] withResponseCallback:^(NSDictionary *response) {
			<%$interface->getResponse()->getClassName()%>* structResponse = [<%$interface->getResponse()->getClassName()%> new];
			[structResponse unserialize:response];
			responseCallback(structResponse);
		} withErrorCallback:^(WebcError *error) {
			errorCallback(error);
		}];
	}
	@catch (NSException* exception) {
		errorCallback([[WebcError alloc] initWithCode:-1 andMsg:@"Protocol Error"]);
	}
}
<%/foreach%>
@end
