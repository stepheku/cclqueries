/*
pharmnet_product_notes.sql
~~~~~~~~~~~~~~~~~~~~
Grabs active PharmNet products and associated product notes, given either
a product description or a search parameter in for product notes
*/
select md.item_id
    , product_desc = mi.value
    , med_type = evaluate2(if(md.med_type_flag = 0) "Product" 
        elseif(md.med_type_flag = 1) "Repackaged item" 
        elseif(md.med_type_flag = 2) "Compound" 
        elseif(md.med_type_flag = 3) "IV set" 
        elseif (md.med_type_flag = 4) "Order set" endif)
    , comment1 = trim(lt1.long_text)
    , fill_list_ind = if(mod.comment1_type in (1,3,5,7)) "1" endif
    , mar_ind = if(mod.comment1_type in (2,3,6,7)) "1" endif
    , label_ind = if(mod.comment1_type in (4,5,6,7)) "1" endif
    , comment2 = trim(lt2.long_text)
    , fill_list_ind = if(mod.comment2_type in (1,3,5,7)) "1" endif
    , mar_ind = if(mod.comment2_type in (2,3,6,7)) "1" endif
    , label_ind = if(mod.comment2_type in (4,5,6,7)) "1" endif
from item_definition id
    , med_identifier mi
    , medication_definition md
    , med_def_flex mdf
    , med_flex_object_idx mfoi
    , med_oe_defaults mod
    , long_text lt1
    , long_text lt2
plan id where id.active_ind = 1
join md where md.item_id = id.item_id
join mi where mi.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "DESC"))
    and mi.item_id = md.item_id
    and mi.active_ind = 1
    and mi.primary_ind = 1
    and mi.med_product_id = 0
    ;and mi.value_key like '*PRODUCT DESCRIPTION IN ALL CAPS*'
join mdf where mdf.item_id = md.item_id
    and mdf.flex_type_cd = value(uar_get_code_by("MEANING", 4062, "SYSTEM"))
    and mdf.active_ind = 1
join mfoi where mdf.med_def_flex_id = mfoi.med_def_flex_id
    and mfoi.active_ind = 1
    and mfoi.flex_object_type_cd = value(uar_get_code_by("MEANING", 4063, "OEDEF"))
join mod where mfoi.parent_entity_id = mod.med_oe_defaults_id 
    and mod.active_ind = 1
join lt1 where lt1.long_text_id = mod.comment1_id
    ;and cnvtupper(lt1.long_text) like '*COMMENT IN CAPS*'
join lt2 where lt2.long_text_id = mod.comment2_id
    ;and cnvtupper(lt2.long_text) like '*COMMENT IN CAPS*'
order by mi.value_key