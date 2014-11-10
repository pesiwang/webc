#import "JSONModel.h"

<%foreach $structs as $struct%>
@class WebcStruct<%$struct->name|webc_name2camel%>;
<%/foreach%>
<%foreach $structs as $struct%>
@protocol WebcStruct<%$struct->name|webc_name2camel%>
@end
<%/foreach%>
<%foreach $structs as $struct%>

@interface WebcStruct<%$struct->name|webc_name2camel%> : JSONModel
<%foreach $struct->params as $param%>
<%if ($param->type=='OBJECT')%>
@property (<%$param->reference|webc_to_objc_property%>, nonatomic) <%$param->reference|webc_to_objc_class%> <%$param->name%>;
<%else if ($param->type=='ARRAY')%>
@property (strong, nonatomic) NSMutableArray<<%$param->reference|webc_to_objc_class:false%>>* <%$param->name%>;
<%else%>
@property (<%$param->type|webc_to_objc_property%>, nonatomic) <%$param->type|webc_to_objc_class:%> <%$param->name%>;
<%/if%>
<%/foreach%>
@end
<%/foreach%>
