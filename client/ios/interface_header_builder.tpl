#import "JSONModel.h"
<%foreach $doc as $interface%>

@interface Webc_<%$interface->name|webc_name2camel%>Request : JSONModel
<%foreach $interface->requestParams as $param%>
@property (<%if ($param->type|webc_type_is_structure)||($param->type|webc_type_is_string)%>strong<%else%>assign<%/if%>, nonatomic) <%$param->type|webc_type_to_objc_class%> <%$param->name%>;
<%/foreach%>
@end

@interface Webc_<%$interface->name|webc_name2camel%>Response : JSONModel
<%foreach $interface->responseParams as $param%>
@property (<%if ($param->type|webc_type_is_structure)||($param->type|webc_type_is_string)%>strong<%else%>assign<%/if%>, nonatomic) <%$param->type|webc_type_to_objc_class%> <%$param->name%>;
<%/foreach%>
@end
<%/foreach%>
