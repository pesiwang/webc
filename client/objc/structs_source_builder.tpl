#import "WebcStructs.h"
<%foreach $structs as $struct%>

@implementation <%$server->namespace|strtoupper%>Struct<%$struct->name|webc_name2camel%>
- (id)init{
	self = [super init];
	if(self){
<%foreach $struct->params as $param%>
<%if ($param->type=='OBJECT')%>
		self.<%$param->name%> = [[<%$server->namespace|strtoupper%>Struct<%$param->reference|webc_name2camel%> alloc] init];
<%else if ($param->type=='ARRAY')%>
		self.<%$param->name%> = (NSMutableArray<<%$server->namespace|strtoupper%>Struct<%$param->reference|webc_name2camel%>>*)[[NSMutableArray alloc] init];
<%else if ($param->type=='STRING')%>
		self.<%$param->name%> = @"";
<%else if ($param->type=='BOOL')%>
		self.<%$param->name%> = NO;
<%else%>
		self.<%$param->name%> = 0;
<%/if%>
<%/foreach%>
	}
	return self;
}
@end
<%/foreach%>
