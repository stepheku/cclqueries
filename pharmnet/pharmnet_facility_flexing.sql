/*
pharmnet_facility_flexing.sql
~~~~~~~~~~~~~~~~~~~~
Grabs facility flexing for PharmNet items (includes products, IV sets, etc)
*/

select md.item_id
    , product_description = mi.value
    , med_type = evaluate2(if(md.med_type_flag = 0) "Product" 
        elseif(md.med_type_flag = 1) "Repackaged item" 
        elseif(md.med_type_flag = 2) "Compound" 
        elseif(md.med_type_flag = 3) "IV set" 
        elseif (md.med_type_flag = 4) "Order set" endif)
    , facility_view = evaluate2(if(nullind(cv1.code_value) = 1) "All facilities"
        elseif(cv1.code_value > 0) uar_get_code_display(mfoi.parent_entity_id)
        endif)
from item_definition id
    , medication_definition md
    , med_identifier mi
    , med_def_flex mdf
    , med_flex_object_idx mfoi
    , code_value cv1
plan id where id.active_ind = 1
join md where md.item_id = id.item_id
join mi where mi.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "DESC"))
    and mi.item_id = md.item_id
    and mi.active_ind = 1
    and mi.primary_ind = 1
    and mi.med_product_id = 0
    ;and mi.value_key like '*PRODUCT DESCRIPTION IN CAPS*'
join mdf where mdf.item_id = md.item_id
    and mdf.active_ind = 1  
join mfoi where mdf.med_def_flex_id = mfoi.med_def_flex_id
    and mfoi.active_ind = 1
    and mfoi.flex_object_type_cd = value(uar_get_code_by("MEANING", 4063, "ORDERABLE"))
join cv1 where cv1.code_value = outerjoin(mfoi.parent_entity_id)
    and cv1.code_set = outerjoin(220)
    ;and cv1.display_key like '*FACILITY DISPLAY IN CAPS*'
order by md.item_id
