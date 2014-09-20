#import "JSONModel.h"

<%foreach $doc as $structure%>
@class ST_<%$structure->name|webc_name2camel%>;
<%/foreach%>
<%foreach $doc as $structure%>

@interface ST_<%$structure->name|webc_name2camel%> : JSONModel
<%foreach $structure->params as $param%>
@property (<%if ($param->type|webc_type_is_structure)||($param->type|webc_type_is_string)%>strong<%else%>assign<%/if%>, nonatomic) <%$param->type|webc_type_to_objc_class%> <%$param->name%>;
<%/foreach%>
@end
<%/foreach%>
