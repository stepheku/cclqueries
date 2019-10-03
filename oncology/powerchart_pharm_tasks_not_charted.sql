/*
This query is helpful if a site is charge on administration (COA) and needs to
keep track of what pharmacy-specific tasks have not yet been charted on in PowerChart
*/

select t.task_dt_tm
    , task_status = uar_get_code_display(t.task_status_cd)
    , ptname = p.name_full_formatted
    , fin = ea.alias
    , location = uar_get_code_display(t.location_cd)
    , o.ordered_as_mnemonic
    , o.simplified_display_line
    , dot = pw.description
    , powerplan = pw.pw_group_desc
from task_activity t
    , orders o
    , person p
    , encounter e
    , encntr_alias ea
    , act_pw_comp apc
    , pathway pw
plan t where t.location_cd in (
        /*Add in location_cd code values here*/
        )
    and t.task_dt_tm > cnvtdatetime(curdate-30,0)
    and t.task_dt_tm < cnvtdatetime(curdate+1,0)
    and t.catalog_type_cd = value(uar_get_code_by("MEANING", 6000, "PHARMACY"))
    and t.task_type_cd = value(uar_get_code_by("MEANING", 6026, "MED")) /*Exclude infusion documentation*/
    and t.task_status_cd not in ( 
          value(uar_get_code_by("MEANING", 79, "COMPLETE"))
        , value(uar_get_code_by("MEANING", 79, "CANCELED"))
        , value(uar_get_code_by("MEANING", 79, "DELETED"))
        )
    and t.task_class_cd != value(uar_get_code_by("MEANING", 6025, "PRN"))
join o where o.order_id = t.order_id
    and o.catalog_cd != value(uar_get_code_by("DISPLAY", 200, "Zero Hour Chemo"))
    /*Zero Hour Chemo is a placeholder pharmacy orderable that serves as an anchor
    for each DOT for start date/time offsets*/
join apc where apc.parent_entity_id = outerjoin(o.order_id)
    and apc.parent_entity_name = outerjoin("ORDERS")
join pw where pw.pathway_id = outerjoin(apc.pathway_id)
join p where p.person_id = t.person_id
    and p.active_ind = 1
    and p.end_effective_dt_tm > sysdate
join e where e.encntr_id = t.encntr_id
    and e.active_ind = 1
    and e.end_effective_dt_tm > sysdate
join ea where ea.encntr_id = e.encntr_id
    and ea.active_ind = 1
    and ea.end_effective_dt_tm > sysdate
    and ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING", 319, "FIN NBR"))
order by t.task_dt_tm
with format(date,"mm/dd/yyyy hh:mm:ss")
