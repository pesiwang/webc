#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WebcObjectType) {
	WebcObjectTypeInteger = 0x01,
	WebcObjectTypeString = 0x02,
	WebcObjectTypeBool = 0x03,
	WebcObjectTypeStruct = 0x11,
	WebcObjectTypeArray = 0x12,
	WebcObjectTypeNull = 0xFF
};

@protocol WebcObject <NSObject>
@required
- (NSDictionary *)serialize;
- (void)unserialize:(NSDictionary *)data;
@end

@interface WebcObject : NSObject<WebcObject>
- (NSString *)getOriginalName;
+ (WebcObject *)smartObject:(NSDictionary *)data;
@end

@interface WebcInteger : WebcObject<WebcObject>
- (instancetype)set:(NSInteger)val;
- (NSInteger)get;
@end

@interface WebcString : WebcObject<WebcObject>
- (instancetype)set:(NSString *)val;
- (NSString *)get;
@end

@interface WebcBool : WebcObject<WebcObject>
- (instancetype)set:(BOOL)val;
- (BOOL)get;
@end

@interface WebcStruct : WebcObject<WebcObject>
@end

@interface WebcArray : WebcObject<WebcObject>
- (void)addObject:(WebcObject *)object;
- (NSArray<WebcObject> *)getObjects;
@end

@interface WebcNull : WebcObject<WebcObject>
@end

#pragma mark - User Definied Structs
<%foreach $structs as $struct%>
@class <%$struct->getClassName()%>;
<%/foreach%>
<%foreach $structs as $struct%>

@interface <%$struct->getClassName()%> : WebcStruct
<%foreach $struct->getObjects() as $obj%>
<%if is_a($obj, 'WebcReference')%>
@property (strong, nonatomic) <%$obj->getTarget()->getClassName()%>* <%$obj->getAbbrName()%>;
<%else%>
@property (strong, nonatomic) <%$obj->getClassName()%>* <%$obj->getAbbrName()%>;
<%/if%>
<%/foreach%>
@end
<%/foreach%>
