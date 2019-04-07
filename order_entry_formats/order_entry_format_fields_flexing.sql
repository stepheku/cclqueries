/*
order_entry_format_fields_flexing.sql
~~~~~~~~~~~~~~~~~~~~
This query grabs all Pharmacy order entry formats with an action type of 
"Order" and the associated format fields (and associated order entry fields)

Ths accept_format_flexing table is also joined to give flexing information. 
Any field that is not flexed, has a blank field for flex_type and onwards 
*/

select oefp.oe_format_name
    , order_entry_field = oef2.description
    , off.label_text
    , flex_type = evaluate2(
        if(aff.flex_type_flag = 0 and aff.flex_cd > 0) "Ordering Location"
        elseif(aff.flex_type_flag = 1) "Patient Location"
        elseif(aff.flex_type_flag = 2) "Application"
        elseif(aff.flex_type_flag = 3) "Position"
        elseif(aff.flex_type_flag = 4) "Encounter Type"
        endif
    )
    , accept_flag = evaluate2(
        if(aff.accept_flag = 0 and aff.flex_cd > 0) "Required"
        elseif(aff.accept_flag = 1) "Optional"
        elseif(aff.accept_flag = 2) "No Display"
        elseif(aff.accept_flag = 3) "Display Only"
        endif
    )
    , flex_value = uar_get_code_display(aff.flex_cd)
    , aff.default_value
from order_entry_format_parent oefp
    , order_entry_format oef
    , order_entry_fields oef2
    , oe_format_fields off
    , accept_format_flexing aff
plan oefp where oefp.catalog_type_cd = value(uar_get_code_by("MEANING", 6000, "PHARMACY"))
join oef where oef.oe_format_id = oefp.oe_format_id
    and oef.action_type_cd = value(uar_get_code_by("MEANING", 6003, "ORDER"))
join off where off.oe_format_id = oef.oe_format_id
    and off.action_type_cd = oef.action_type_cd
join oef2 where oef2.oe_format_id = off.oe_format_id
join aff where aff.oe_field_id = outerjoin(off.oe_field_id)
    and aff.oe_format_id = outerjoin(off.oe_format_id)
    and aff.action_type_cd = outerjoin(off.action_type_cd)
order by oefp.oe_format_name
    , off.group_seq