/*
pco_powerplan_basic_attributes.sql
~~~~~~~~~~~~~~~~~~~
This query grabs any currently active powerplan and powerplan-level
attributes (such as default view, or copy forward) in addition to 
reference text and powerplan commaents
*/

select powerplan = pwcat.description
    , plan_type = uar_get_code_display(pwcat.pathway_type_cd)
    , pwcat.cross_encntr_ind
    , reference_text = lb.long_blob
    , powerplan_comment = lt.long_text
    , allow_dx_propagation = pwcat.diagnosis_capture_ind
    , hide_flexd_cmp = pwcat.hide_flexed_comp_ind
    , default_view = evaluate2(if(pwcat.default_view_mean = "CHEMO*") "Chemotherapy Review"
        elseif(pwcat.default_view_mean is null) "None" endif)
    , prompt_ord_physician = pwcat.provider_prompt_ind
    , copy_fwd = pwcat.allow_copy_forward_ind
    , classification = uar_get_code_display(pwcat.pathway_class_cd)
    , dont_allow_proposal = pwcat.restricted_actions_bitmask
    , use_cycle_numbers = pwcat.cycle_ind
    , std_nbr_of_cycles = pwcat.standard_cycle_nbr
    , beg_cycle_nbr = pwcat.cycle_begin_nbr
    , end_cycle_nbr = pwcat.cycle_end_nbr
    , cycle_incrm_nbr = pwcat.cycle_increment_nbr
    , disp_std_nbr_or_end_val = pwcat.cycle_display_end_ind
    , restr_ability_to_mod_std_nbr_or_end_val = pwcat.cycle_lock_end_ind
    , cycle_disp_val = uar_get_code_display(pwcat.cycle_label_cd)
from pathway_catalog pwcat
    , long_blob lb
    , ref_text_reltn rtr
    , ref_text rt
    , long_text lt
plan pwcat where pwcat.active_ind = 1
    and pwcat.type_mean in ("CAREPLAN", "PATHWAY")
    and (pwcat.description_key like 'ONC*'
        or pwcat.description_key like 'INF*')
    and pwcat.end_effective_dt_tm > cnvtdatetime(sysdate)
    and pwcat.beg_effective_dt_tm < cnvtdatetime(sysdate) 
        /*Removes "Testing" and "Production, archived versions"*/
    and pwcat.ref_owner_person_id = 0 
        /*Filter out pre-CPOE-built PowerPlans*/
join rtr where rtr.parent_entity_id = outerjoin(pwcat.pathway_catalog_id)
    and rtr.parent_entity_name = outerjoin("PATHWAY_CATALOG")
    and rtr.active_ind = outerjoin(1)
join rt where rt.refr_text_id = outerjoin(rtr.refr_text_id)
    and rt.text_entity_name = outerjoin("LONG_BLOB")
    and rt.active_ind = outerjoin(1)
join lb where lb.long_blob_id = outerjoin(rt.text_entity_id)
    and lb.active_ind = outerjoin(1)
join lt where lt.long_text_id = outerjoin(pwcat.long_text_id)
    and lt.active_ind = outerjoin(1)
