//
//  WebcClient.h
//  testdrive
//
//  Created by Chen Rui on 1/4/15.
//  Copyright (c) 2015 Vanchu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebcObject.h"

@interface WebcError : NSObject
@property (assign, nonatomic, readonly) NSInteger code;
@property (strong, nonatomic, readonly) NSString *msg;
- (instancetype)initWithCode:(NSInteger)code andMsg:(NSString *)msg;
@end

@interface WebcClient : NSObject
+ (void)setupWithHost:(NSString *)host;
+ (void)setupWithHost:(NSString *)host andPort:(NSInteger)port;
+ (void)setupWithHost:(NSString *)host andPort:(NSInteger)port andProtocol:(NSString *)protocol;
<%foreach $interfaces as $interface%>
+ (void)invoke<%$interface->getName(true)%>WithRequest:(<%$interface->getRequest()->getClassName()%>*)request withResponseCallback:(void (^)(<%$interface->getResponse()->getClassName()%>* response))responseCallback withErrorCallback:(void (^)(WebcError *error))errorCallback;
<%/foreach%>
@end
