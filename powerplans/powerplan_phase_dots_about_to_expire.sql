/*
powerplan_phase_dots_about_to_expire.sql
~~~~~~~~~~~~~~~~~~~~
Query identifies PowerPlans, PowerPlan phases and/or associated DOTs that are about to expire
per the PowerPlan Expiration Criteria set up in DCPtools
*/

select pt_name = p.name_full_formatted
    , facility = uar_get_code_display(e.loc_facility_cd)
    , fin = fin.alias
    , powerplan = pw.pw_group_desc
    , pw.pathway_id
    , phase_or_dot = pw.description
    , phase_or_dot_status = uar_get_code_display(pw.pw_status_cd)
    , pw.order_dt_tm
    , pw.start_dt_tm
    , exp_criteria = 
        if(pwc.version_pw_cat_id != 0) 
            pwc.time_qty
        else 
            def_pwc.time_qty 
        endif
    , exp_criteria_unit = 
        if(pwc.version_pw_cat_id != 0) 
            uar_get_code_display(pwc.time_unit_cd)
        else 
            uar_get_code_display(def_pwc.time_unit_cd) 
        endif
    , date_of_expiration = 
        if(pwc.version_pw_cat_id != 0)
            if (pw.start_dt_tm > 0)
                format(cnvtlookahead(build(pwc.time_qty, ",H"), pw.start_dt_tm), ";;q")
            elseif (pw.order_dt_tm > 0)
                format(cnvtlookahead(build(pwc.time_qty, ",H"), pw.order_dt_tm), ";;q")
            endif
        else
            if (pw.start_dt_tm > 0)
                format(cnvtlookahead(build(def_pwc.time_qty, ",H"), pw.start_dt_tm), ";;q")
            elseif (pw.order_dt_tm > 0)
                format(cnvtlookahead(build(def_pwc.time_qty, ",H"), pw.order_dt_tm), ";;q")
            endif
        endif
from pathway pw
    , pw_maintenance_criteria pwc
    , pw_maintenance_criteria def_pwc
    , pathway_catalog pwcat
    , dummyt d
    , person p
    , encounter e
    , encntr_alias fin
plan pw where pw.order_dt_tm between 
        /*From Date/Time*/
        cnvtdatetime(cnvtdate(090119) /*MMDDYY*/, 0) and
        /*To Date/Time*/
        cnvtdatetime(cnvtdate(042820) /*MMDDYY*/, 0)
        
    and pw.pw_status_cd in (
        /*PowerPlan Expiration criteria specifically only affects Future and Planned
        status PowerPlans/Phases/DOTs*/
        value(uar_get_code_by("MEANING", 16769, "FUTURE"))
        , value(uar_get_code_by("MEANING", 16769, "PLANNED"))
        )
join pwcat where pwcat.pathway_catalog_id = pw.pw_cat_group_id
join pwc where pwc.version_pw_cat_id = outerjoin(pwcat.version_pw_cat_id)
    and pwc.type_mean = outerjoin('EXPIRATION')
join def_pwc where def_pwc.type_mean = 'EXPIRATION'
    and def_pwc.version_pw_cat_id = 0
join p where p.person_id = pw.person_id
    and p.active_ind = 1
    and p.end_effective_dt_tm > sysdate
join e where e.encntr_id = pw.encntr_id
    and e.active_ind = 1
    and e.end_effective_dt_tm > sysdate
join fin where fin.encntr_id = e.encntr_id
    and fin.active_ind = 1
    and fin.end_effective_dt_tm > sysdate
    and fin.encntr_alias_type_cd = value(uar_get_code_by("MEANING", 319, "FIN NBR"))
join d ;where
    /*Grab any record where the date/time difference from current date/time is negative, this
    indicates any condition would be true, which we should probably be aware of*/
    datetimediff(cnvtlookahead(build(pwc.time_qty, ",H"), pw.start_dt_tm), sysdate) < 0 and
    datetimediff(cnvtlookahead(build(pwc.time_qty, ",H"), pw.order_dt_tm), sysdate) < 0 and
    datetimediff(cnvtlookahead(build(def_pwc.time_qty, ",H"), pw.start_dt_tm), sysdate) < 0 and
    datetimediff(cnvtlookahead(build(def_pwc.time_qty, ",H"), pw.order_dt_tm), sysdate) < 0
with format(date, ";;q")
