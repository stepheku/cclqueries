/*
pharmnet_parent_identifiers.sql
~~~~~~~~~~~~~~~~~~~~
Obtains all parent-level identifiers in PhaDbProductMgr. This can be modified
to obtain specific modifier types. Note that parent-level implies that this 
query will not obtain NDC-level identifiers
*/

select mi.item_id
    , product_desc = mi.value
    , identifier_type = uar_get_code_display(mi2.med_identifier_type_cd)
    , identifier_value = mi2.value
from med_identifier mi
    , med_identifier mi2
    , item_definition id
    , medication_definition md
plan id where id.active_ind = 1
join md where md.item_id = id.item_id
join mi where mi.item_id = md.item_id
    and mi.active_ind = 1
    and mi.primary_ind = 1
    and mi.med_product_id = 0
    and mi.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "DESC"))
join mi2 where mi2.item_id = mi.item_id
    and mi2.med_product_id = 0
    and mi2.active_ind = 1
    and mi2.primary_ind = 1
    
    /*Remove comments for any specific identifiers you wish to look for */
    /* - Remove here to filter for specific identifiers
    and mi2.med_identifier_type_cd in (
        0
        ; , value(uar_get_code_by("MEANING", 11000, "DESC")) /*Description*/
        ; , value(uar_get_code_by("MEANING", 11000, "BRAND_NAME"))
        ; , value(uar_get_code_by("MEANING", 11000, "CDM"))
        ; , value(uar_get_code_by("MEANING", 11000, "DESC_SHORT")) /*Rx Mnemonic*/
        ; , value(uar_get_code_by("MEANING", 11000, "HCPCS"))
        ; , value(uar_get_code_by("MEANING", 11000, "GENERIC_NAME"))
        ; , value(uar_get_code_by("MEANING", 11000, "PYXIS"))
        ; , value(uar_get_code_by("MEANING", 11000, "RX DEVICE1"))
        ; , value(uar_get_code_by("MEANING", 11000, "RX DEVICE2"))
        ; , value(uar_get_code_by("MEANING", 11000, "RX DEVICE3"))
        ; , value(uar_get_code_by("MEANING", 11000, "RX DEVICE4"))
        ; , value(uar_get_code_by("MEANING", 11000, "RX DEVICE5"))
        ; , value(uar_get_code_by("MEANING", 11000, "RX MISC1"))
        ; , value(uar_get_code_by("MEANING", 11000, "RX MISC2"))
        ; , value(uar_get_code_by("MEANING", 11000, "RX MISC3"))
        ; , value(uar_get_code_by("MEANING", 11000, "RX MISC4"))
        ; , value(uar_get_code_by("MEANING", 11000, "RX MISC5"))
    )
    */ ; - Remove here to filter for specific identifiers
order by mi.value_key
    , mi2.med_identifier_type_cd
    , mi2.value_key