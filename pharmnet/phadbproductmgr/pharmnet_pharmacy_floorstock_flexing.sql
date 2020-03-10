/*
pharmnet_pharmacy_floorstock_flexing.sql
~~~~~~~~~~~~~~~~~~~~
Grabs the non-floorstock (pharmacy) and floorstock assignments of PharmNet
products
*/
select md.item_id
    , product_desc = mi.value
    , med_type = if(md.med_type_flag = 0) "Product" 
        elseif(md.med_type_flag = 1) "Repackaged item" 
        elseif(md.med_type_flag = 2) "Compound" 
        elseif(md.med_type_flag = 3) "IV set" 
        elseif(md.med_type_flag = 4) "Order set" endif
    , flrstock_loc = uar_get_code_display(sa.location_cd)
from item_definition id
    , medication_definition md
    , med_identifier mi
    , stored_at sa
    , code_value cv
plan id where id.active_ind = 1
join md where md.item_id = id.item_id
join mi where mi.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "DESC"))
    and mi.item_id = md.item_id
    and mi.active_ind = 1
    and mi.primary_ind = 1
    and mi.med_product_id = 0
join sa where sa.item_id = mi.item_id
join cv where sa.location_cd = cv.code_value
    and cv.active_ind = 1
    and cv.cdf_meaning in ('PHARM', 'NURSEUNIT', 'AMBULATORY')
order by mi.value_key