/*
pharmnet_clinical_tab.sql
~~~~~~~~~~~~~~~~~~~~
Grabs active PharmNet products and contents of the clinical tab
*/
select md.item_id
    , product_desc = mi.value
    , med_type = if(md.med_type_flag = 0) "Product" 
        elseif(md.med_type_flag = 1) "Repackaged item" 
        elseif(md.med_type_flag = 2) "Compound" 
        elseif(md.med_type_flag = 3) "IV set" 
        elseif(md.med_type_flag = 4) "Order set" endif
    , order_catalog_primary = oc.primary_mnemonic
    , generic_formulation = mdn.drug_name
    , drug_formulation = n.source_string
    , mmdc = md.cki
    , therapeutic_class = ac.long_description
    , oc_dc_interaction = oc.op_dc_interaction_days
    , oc_dc_display = oc.op_dc_display_days
from item_definition id
    , medication_definition md
    , med_identifier mi
    , nomenclature n
    , order_catalog_item_r ocir
    , order_catalog_synonym ocs
    , order_catalog oc
    , alt_sel_list al
    , alt_sel_cat ac
    , mltm_mmdc_name_map m
    , mltm_drug_name_map mdnm
    , mltm_drug_name_map mdnm2
    , mltm_drug_name mdn
plan id where id.active_ind = 1
join md where md.item_id = id.item_id
join mi where mi.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "DESC"))
    and mi.item_id = md.item_id
    and mi.active_ind = 1
    and mi.primary_ind = 1
    and mi.med_product_id = 0
join n where n.nomenclature_id = outerjoin(md.mdx_gfc_nomen_id)
    and n.source_identifier = outerjoin(trim(substring(12,5,md.cki)))
    and n.principle_type_cd = outerjoin(value(uar_get_code_by("MEANING", 401, "GENFORM")))
    and n.source_vocabulary_cd = outerjoin(value(uar_get_code_by("MEANING", 400, "MUL.MMDC")))
    and n.primary_vterm_ind = outerjoin(1)
join ocir where ocir.item_id = md.item_id
join oc where oc.catalog_cd = ocir.catalog_cd
join ocs where ocs.synonym_id = ocir.synonym_id
join al where al.synonym_id = outerjoin(ocs.synonym_id)
join ac where ac.alt_sel_category_id = outerjoin(al.alt_sel_category_id)
join m where outerjoin(cnvtint(n.source_identifier)) = m.main_multum_drug_code 
    and m.function_id = outerjoin(59)
join mdnm where outerjoin(m.drug_synonym_id) = mdnm.drug_synonym_id
join mdnm2 where outerjoin(mdnm.drug_identifier) = mdnm2.drug_identifier
    and mdnm2.function_id = outerjoin(16)
join mdn where mdn.drug_synonym_id = outerjoin(mdnm2.drug_synonym_id)
order by mi.value_key