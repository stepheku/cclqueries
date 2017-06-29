select powerplan = pwcat.description
    , powerplan_cmt = substring(1,100,lt.long_text)
    , prompt_user_plan_start_dttm = pwcat.prompt_on_selection_ind
    , open_by_default = evaluate(pwcat.open_by_default_ind,1,"Not-System Defined","System Defined")
    , default_visit_type = evaluate2(if(pwcat.default_visit_type_flag = 0) "None"
        elseif(pwcat.default_visit_type_flag = 1) "This Visit"
        elseif(pwcat.default_visit_type_flag = 2) "Future Inpatient Visit"
        elseif(pwcat.default_visit_type_flag = 3) "Future Outpatient Visit" endif)
    , phase_name = pwcat2.description
    , primary_phase = pwcat2.primary_ind
    , optional_phase = pwcat2.optional_ind
    , future_phase = pwcat2.future_ind
    , this_visit_outpt = uar_get_code_display(pwcat2.default_action_outpt_now_cd)
    , this_visit_inpt = uar_get_code_display(pwcat2.default_action_inpt_now_cd)
    , future_visit_outpt = uar_get_code_display(pwcat2.default_action_outpt_future_cd)
    , future_visit_inpt = uar_get_code_display(pwcat2.default_action_inpt_future_cd)
    , phase_start_time = pwcat2.default_start_time_txt
from pathway_catalog pwcat
    , pathway_catalog pwcat2
    , pw_cat_reltn pcr
    , long_text lt
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
