/*
pco_powerplan_phase_offsets.sql
~~~~~~~~~~~~~~~~~~~~
Gets the phase offsets set in Oncology PowerPlans
*/
select powerplan = pwcat.display_description
    , phase = pwcat2.description
    , phase_duration_qty = pwcat2.duration_qty
    , phase_duration_unit = uar_get_code_display(pwcat2.duration_unit_cd)
    , pcr2.offset_qty
    , offset_unit = uar_get_code_display(pcr2.offset_unit_cd)
    , anchor_phase = pwcat3.description
from pathway_catalog pwcat
    , pathway_catalog pwcat2
    , pw_cat_reltn pcr
    , pw_cat_reltn pcr2
    , pathway_catalog pwcat3
plan pwcat where pwcat.active_ind = 1
    and pwcat.end_effective_dt_tm > sysdate
    and pwcat.version in (
        /*pathway_catalog.version is here to grab the latest parent PowerPlan
        version. Different versions of the same PowerPlan may be in an active
        status. This is to account for that and just grab the most recent
        version
 
        This is the same reason why pwcat.beg_effective_dt_tm is not
        being filtered against in this query. pwcat.beg_effective_dt_tm
        is typically set to 12-31-2100 if a PowerPlan is in a testing status
        */
        select max(pwcat4.version)
        from pathway_catalog pwcat4
        where pwcat4.version_pw_cat_id = pwcat.version_pw_cat_id
            and pwcat4.active_ind = 1
    )
    and pwcat.beg_effective_dt_tm < sysdate
    and pwcat.version_pw_cat_id > 0
    and pwcat.description_key like "ONCP*"
    and pwcat.description_key not like "ZZ*"

join pcr where pcr.pw_cat_s_id = outerjoin(pwcat.pathway_catalog_id)
    and pcr.type_mean = outerjoin("GROUP")
join pwcat2 where pwcat2.pathway_catalog_id = outerjoin(pcr.pw_cat_t_id)
    and pwcat2.type_mean = outerjoin("PHASE")
    and pwcat2.active_ind = outerjoin(1)
    and pwcat2.end_effective_dt_tm > outerjoin(sysdate)
join pcr2 where pcr2.pw_cat_t_id = outerjoin(pwcat2.pathway_catalog_id)
    and pcr2.type_mean = outerjoin('PHASEOFFSET')
join pwcat3 where pwcat3.pathway_catalog_id = outerjoin(pcr2.pw_cat_s_id)
    and pwcat3.type_mean = outerjoin("PHASE")