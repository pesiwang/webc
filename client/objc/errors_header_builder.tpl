#import <Foundation/Foundation.h>

@interface <%$server->namespace|strtoupper%>Error : NSObject
@property (assign, nonatomic) NSInteger result;
@property (strong, nonatomic) NSString* message;
- (id)initWithResult:(NSInteger)result withMessage:(NSString*)message;
@end
