//
//  WebcObject.m
//  testdrive
//
//  Created by Chen Rui on 1/4/15.
//  Copyright (c) 2015 Vanchu. All rights reserved.
//

#import "WebcObject.h"
#import <objc/runtime.h>

static const NSString* PROTO_KEY_NAME = @"n";
static const NSString* PROTO_KEY_TYPE = @"t";
static const NSString* PROTO_KEY_PAYLOAD = @"p";

@implementation WebcObject
- (NSString *)getOriginalName {
	NSString *className = NSStringFromClass(self.class);
	NSMutableString *name = [NSMutableString new];
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([A-Z][a-z0-9]*)" options:0 error:nil];
	NSArray *matches = [regex matchesInString:className options:0 range:NSMakeRange(0, className.length)];

	for (NSTextCheckingResult *match in matches) {
		if (name.length > 0) {
			[name appendString:@"."];
		}
		[name appendString:[[className substringWithRange:match.range] lowercaseString]];
	}
	return name;
}

+ (WebcObject *)smartObject:(NSDictionary *)data {
	if ([data objectForKey:PROTO_KEY_TYPE] == nil) {
		[NSException raise:@"bad protocol" format:@"missing type key"];
	}
	NSString *className = nil;
	NSInteger type = [[data objectForKey:PROTO_KEY_TYPE] integerValue];
	switch (type) {
		case WebcObjectTypeInteger:
			className = @"WebcInteger";
			break;
		case WebcObjectTypeString:
			className = @"WebcString";
			break;
		case WebcObjectTypeBool:
			className = @"WebcBool";
			break;
		case WebcObjectTypeStruct:
			{
				if ([data objectForKey:PROTO_KEY_NAME] == nil) {
					[NSException raise:@"bad protocol" format:@"missing name key"];
				}
				
				NSMutableString *name = [data objectForKey:PROTO_KEY_NAME];
				BOOL shouldCapitalize = YES;
				for (NSUInteger i = 0; i < name.length; ++i) {
					unichar ch = [name characterAtIndex:i];
					if (ch == '.') {
						[name replaceCharactersInRange:NSMakeRange(i, 1) withString:@""];
						shouldCapitalize = YES;
					}
					else {
						if (shouldCapitalize) {
							ch = toupper(ch);
							[name replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithCharacters:&ch length:1]];
						}
						shouldCapitalize = NO;
					}
				}
				
				className = [NSString stringWithFormat:@"WebcStruct%@", name];
			}
			break;
		case WebcObjectTypeArray:
			className = @"WebcArray";
			break;
		case WebcObjectTypeNull:
			className = @"WebcNull";
			break;
		default:
			[NSException raise:@"bad protocol" format:@"Unrecognized type %ld", (long)type];
			break;
	}
	Class class = NSClassFromString(className);
	if (class == nil) {
		[NSException raise:@"bad protocol" format:@"no such class named %@", className];
	}
	WebcObject *obj = [class new];
	[obj unserialize:data];
	return obj;
}

- (void)unserialize:(NSDictionary *)data {
	[NSException raise:@"Internal Error" format:@"unserialize is not supposed to be called here"];
}

- (NSDictionary *)serialize {
	[NSException raise:@"Internal Error" format:@"serialize is not supposed to be called here"];
	return nil;
}
@end

#pragma mark - WebcInteger
@interface WebcInteger()
{
	NSInteger _val;
}
@end

@implementation WebcInteger

- (instancetype)init {
	if (self = [super init]) {
		_val = 0;
	}
	return self;
}

- (instancetype)set:(NSInteger)val {
	_val = val;
	return self;
}

- (NSInteger)get {
	return _val;
}

- (NSDictionary *)serialize {
	return @{PROTO_KEY_TYPE: @(WebcObjectTypeInteger), PROTO_KEY_PAYLOAD: @(_val)};
}

- (void)unserialize:(NSDictionary *)data {
	if (![data isKindOfClass:NSDictionary.class] || ([data objectForKey:PROTO_KEY_TYPE] == nil) || ([data objectForKey:PROTO_KEY_PAYLOAD] == nil)) {
		[NSException raise:@"bad protocol" format:@"missing type/payload for a WebcInteger"];
	}
	_val = [[data objectForKey:PROTO_KEY_PAYLOAD] integerValue];
}
@end

#pragma mark - WebcString

@interface WebcString()
{
	NSString *_val;
}
@end

@implementation WebcString

- (instancetype)init {
	if (self = [super init]) {
		_val = @"";
	}
	return self;
}

- (instancetype)set:(NSString *)val {
	_val = val;
	return self;
}

- (NSString *)get {
	return _val;
}

- (NSDictionary *)serialize {
	return @{PROTO_KEY_TYPE: @(WebcObjectTypeString), PROTO_KEY_PAYLOAD: _val};
}

- (void)unserialize:(NSDictionary *)data {
	if (![data isKindOfClass:NSDictionary.class] || ([data objectForKey:PROTO_KEY_TYPE] == nil) || ([data objectForKey:PROTO_KEY_PAYLOAD] == nil)) {
		[NSException raise:@"bad protocol" format:@"missing type/payload for a WebcString"];
	}
	_val = [data objectForKey:PROTO_KEY_PAYLOAD];
}
@end

#pragma mark - WebcBool

@interface WebcBool()
{
	BOOL _val;
}
@end

@implementation WebcBool

- (instancetype)init {
	if (self = [super init]) {
		_val = NO;
	}
	return self;
}

- (instancetype)set:(BOOL)val {
	_val = val;
	return self;
}

- (BOOL)get {
	return _val;
}

- (NSDictionary *)serialize {
	return @{PROTO_KEY_TYPE: @(WebcObjectTypeBool), PROTO_KEY_PAYLOAD: @(_val)};
}

- (void)unserialize:(NSDictionary *)data {
	if (![data isKindOfClass:NSDictionary.class] || ([data objectForKey:PROTO_KEY_TYPE] == nil) || ([data objectForKey:PROTO_KEY_PAYLOAD] == nil)) {
		[NSException raise:@"bad protocol" format:@"missing type/payload for a WebcBool"];
	}
	_val = [[data objectForKey:PROTO_KEY_PAYLOAD] boolValue];
}
@end

#pragma mark - WebcStruct 

@interface WebcStruct()
@end

@implementation WebcStruct

- (instancetype)init {
	if (self = [super init]) {
	}
	return self;
}

- (NSDictionary *)serialize {
	NSMutableDictionary *payload = [NSMutableDictionary new];
	
	unsigned int numOfProperties = 0;
	objc_property_t *properties = class_copyPropertyList(self.class, &numOfProperties);
	for (unsigned int pi = 0; pi < numOfProperties; ++pi) {
		NSString *propertyName = [NSString stringWithUTF8String:property_getName(properties[pi])];
		id v = [self valueForKey:propertyName];
		if ([v isKindOfClass:WebcObject.class]) {
			[payload setObject:[((WebcObject *)v) serialize] forKey:propertyName];
		}
	}
	free(properties);
	return @{PROTO_KEY_NAME: [self getOriginalName], PROTO_KEY_TYPE: @(WebcObjectTypeStruct), PROTO_KEY_PAYLOAD: payload};
}

- (void)unserialize:(NSDictionary *)data {
	if (![data isKindOfClass:NSDictionary.class] || ([data objectForKey:PROTO_KEY_TYPE] == nil) || ([data objectForKey:PROTO_KEY_PAYLOAD] == nil)) {
		[NSException raise:@"bad protocol" format:@"missing type/payload for a WebcStruct"];
	}
	
	NSDictionary *payload = [data objectForKey:PROTO_KEY_PAYLOAD];
	unsigned int numOfProperties = 0;
	objc_property_t *properties = class_copyPropertyList(self.class, &numOfProperties);
	for (unsigned int pi = 0; pi < numOfProperties; ++pi) {
		NSString *propertyName = [NSString stringWithUTF8String:property_getName(properties[pi])];
		id v = [self valueForKey:propertyName];
		if (([v isKindOfClass:WebcObject.class]) && ([payload objectForKey:propertyName] != nil)) {
			[((WebcObject *)v) unserialize:[payload objectForKey:propertyName]];
		}
	}
	free(properties);
}
@end

#pragma mark - WebcArray

@interface WebcArray()
{
	NSMutableArray<WebcObject> *_objects;
}
@end

@implementation WebcArray

- (instancetype)init {
	if (self = [super init]) {
		_objects = (NSMutableArray<WebcObject> *)[NSMutableArray new];
	}
	return self;
}

- (void)addObject:(WebcObject *)object {
	[_objects addObject:object];
}

- (NSArray<WebcObject> *)getObjects {
	return _objects;
}

- (NSDictionary *)serialize {
	NSMutableArray* payload = [NSMutableArray new];
	for (WebcObject *object in _objects) {
		[payload addObject:[object serialize]];
	}
	
	return @{PROTO_KEY_TYPE: @(WebcObjectTypeArray), PROTO_KEY_PAYLOAD: payload};
}

- (void)unserialize:(NSDictionary *)data {
	if (![data isKindOfClass:NSDictionary.class] || ([data objectForKey:PROTO_KEY_TYPE] == nil) || ([data objectForKey:PROTO_KEY_PAYLOAD] == nil)) {
		[NSException raise:@"bad protocol" format:@"missing type/payload for a WebcStruct"];
	}
	
	NSArray *payload = [data objectForKey:PROTO_KEY_PAYLOAD];
	for (NSDictionary *item in payload) {
		[_objects addObject:[WebcObject smartObject:item]];
	}
}
@end

#pragma mark - WebcNull

@interface WebcNull()
@end

@implementation WebcNull

- (instancetype)init {
	if (self = [super init]) {
	}
	return self;
}

- (NSDictionary *)serialize {
	return @{PROTO_KEY_TYPE: @(WebcObjectTypeNull)};
}

- (void)unserialize:(NSDictionary *)data {
}

@end

#pragma mark - User Defined Structs
<%foreach $structs as $struct%>

@implementation <%$struct->getClassName()%>
- (instancetype)init {
	if (self = [super init]) {
<%foreach $struct->getObjects() as $obj%>
<%if is_a($obj, 'WebcReference')%>
		self.<%$obj->getAbbrName()%> = [<%$obj->getTarget()->getClassName()%> new];
<%else%>
		self.<%$obj->getAbbrName()%> = [<%$obj->getClassName()%> new];
<%/if%>
<%/foreach%>
	}
	return self;
}
@end
<%/foreach%>
