/*
pharmnet_ndc_bill_item_modifiers.sql
~~~~~~~~~~~~~~~~~~~~
Grabs bill item modifiers against PharmNet NDCs
*/
select bi.bill_item_id
    , mfoi.sequence
    , ndc = mi.value
    , inner_ndc = mi6.value
    , mi2.item_id
    , product_desc = mi2.value
    , ndc_desc = mi3.value
    , product_cdm = mi4.value
    , manf_item_id = bi.ext_parent_reference_id
    , bill_item_modifier = uar_get_code_display(bim1.key1_id)
    , value = bim1.key6
    , qcf = bim1.bim1_nbr
from bill_item bi
    , bill_item_modifier bim1
    , med_def_flex mdf
    , med_flex_object_idx mfoi
    , med_product mp
    , med_identifier mi
    , medication_definition md
    , item_definition id
    , med_identifier mi2
    , med_identifier mi3
    , med_identifier mi4
    , med_identifier mi6
    , item_definition id2
plan id where id.active_ind = 1
join md where md.item_id = id.item_id
join mi where mi.item_id = md.item_id
    and mi.active_ind = 1
    and mi.med_product_id != 0
    and mi.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "NDC"))
join mi2 where mi2.item_id = mi.item_id
    and mi2.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "DESC"))
    and mi2.med_product_id = 0
    and mi2.active_ind = 1
    and mi2.primary_ind = 1
join mi3 where mi3.item_id = md.item_id
    and mi3.active_ind = 1
    and mi3.primary_ind = 1
    and mi3.med_product_id = mi.med_product_id
    and mi3.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "DESC"))
join mi4 where mi4.item_id = mi.item_id
    and mi4.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "CDM"))
    and mi4.med_product_id = 0
    and mi4.active_ind = 1
    and mi4.primary_ind = 1
join mi6 where mi6.item_id = outerjoin(mi.item_id)
    and mi6.primary_ind = outerjoin(1)
    and mi6.active_ind = outerjoin(1)
    and mi6.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING", 11000, "INNER_NDC")))
    and mi6.med_product_id = outerjoin(mi.med_product_id)
join mdf where mdf.flex_type_cd = value(uar_get_code_by("MEANING", 4062, "SYSTEM"))
    and mdf.item_id = mi.item_id
join mfoi where mi.med_product_id = mfoi.parent_entity_id
    and mfoi.med_def_flex_id = mdf.med_def_flex_id
    and mfoi.parent_entity_name = "MED_PRODUCT"
    and mfoi.active_ind = 1
join mp where mp.med_product_id = mi.med_product_id
join id2 where id2.item_id = mp.manf_item_id
    and id2.active_ind = 1
    and id2.item_type_cd = value(uar_get_code_by("MEANING", 11001, "ITEM_MANF"))
join bi where bi.active_ind = outerjoin(1)
    and bi.ext_parent_contributor_cd = outerjoin(value(uar_get_code_by("MEANING", 13016, "MANF ITEM")))
    and bi.ext_parent_reference_id = outerjoin(mp.manf_item_id)
join bim1 where bim1.bill_item_id = outerjoin(bi.bill_item_id)
    and bim1.active_ind = outerjoin(1)
    and bim1.end_effective_dt_tm > outerjoin(sysdate)
order by md.updt_dt_tm desc
    , mfoi.sequence
