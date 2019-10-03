select powerplan = pwcat.description
    , powerplan_cmt = substring(1,100,lt.long_text)
    , phase_name = pwcat2.description
    , display_method = uar_get_code_display(pwcat2.display_method_cd)
    , duration = pwcat2.duration_qty
    , duration_unit = uar_get_code_display(pwcat2.duration_unit_cd)
    , reference_text = lb.long_blob
    , check_alerts_on_planning = pwcat2.alerts_on_plan_ind
    , check_alerts_on_plan_updt = pwcat2.alerts_on_plan_upd_ind
    , route_for_review = pwcat2.route_for_review_ind
    , classification = uar_get_code_display(pwcat2.pathway_class_cd)
    , doc_resched_reason = evaluate2(if(pwcat2.reschedule_reason_accept_flag = 0) "Off"
        elseif(pwcat2.reschedule_reason_accept_flag = 1) "Optional"
        elseif(pwcat2.reschedule_reason_accept_flag = 2) "Required" endif)
from pathway_catalog pwcat
    , pathway_catalog pwcat2
    , pw_cat_reltn pcr
    , long_blob lb
    , long_text lt
    , ref_text_reltn rtr
    , ref_text rt
plan pwcat where pwcat.active_ind = 1
    and pwcat.type_mean in ("CAREPLAN", "PATHWAY")
    and (pwcat.description like 'ONC*'
        or pwcat.description like 'INF*')
    and pwcat.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    and pwcat.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3) /*Removes "Testing" and "Production, archived versions"*/
    and pwcat.ref_owner_person_id = 0 /*Filter out pre-CPOE-built PowerPlans*/
join lt where lt.long_text_id = outerjoin(pwcat.long_text_id)
    and lt.active_ind = outerjoin(1)
join pcr where pcr.pw_cat_s_id = pwcat.pathway_catalog_id
join pwcat2 where pcr.pw_cat_t_id = pwcat2.pathway_catalog_id
        and pwcat2.sub_phase_ind = 0 /*Looks specifically for sub-phases (instead of PowerPlans within PowerPlans)*/
join rtr where rtr.parent_entity_id = outerjoin(pwcat2.pathway_catalog_id)
    and rtr.parent_entity_name = outerjoin("PATHWAY_CATALOG")
    and rtr.active_ind = outerjoin(1)
join rt where rt.refr_text_id = outerjoin(rtr.refr_text_id)
    and rt.text_entity_name = outerjoin("LONG_BLOB")
    and rt.active_ind = outerjoin(1)
join lb where lb.long_blob_id = outerjoin(rt.text_entity_id)
    and lb.active_ind = outerjoin(1)
