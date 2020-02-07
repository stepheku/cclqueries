/*
order_entry_format_fields.sql
~~~~~~~~~~~~~~~~~~~~
This query grabs all order entry formats with all order action types and 
with the associated format fields (and associated order
entry fields)
*/

select oef.oe_format_name
    , action = uar_get_code_display(oef.action_type_cd)
    , order_entry_field = oef2.description
    , field_label_text = off.label_text
    , accept = if(off.accept_flag = 0) "Required"
        elseif(off.accept_flag = 1) "Optional"
        elseif(off.accept_flag = 2) "No display"
        elseif(off.accept_flag = 3) "Display only"
        endif
    , off.default_value
    , off.group_seq
from order_entry_format oef
    , order_entry_fields oef2
    , oe_format_fields off
plan oef 
join off where off.oe_format_id = oef.oe_format_id
    and off.action_type_cd = oef.action_type_cd
join oef2 where oef2.oe_field_id = off.oe_field_id
order by oef.oe_format_name
    , off.group_seq