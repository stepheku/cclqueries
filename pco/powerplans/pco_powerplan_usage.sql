/*
pco_powerplan_usage.sql
~~~~~~~~~~~~~~~~~~~~
Grabs oncology powerplan usage and displays patients' name, MRN, FIN
and PowerPlan name

Inline table PW is used to grab the highest pathway_id belonging to the
grouped pw_group_nbr (multi-phase powerplans on this table have separate 
line items for each phase and DOT, which would over-report usage)

pathway table (pw2) is then used to grab the phase-specific details such
as order_dt_tm
*/

select pt = p.name_full_formatted
    , mrn = mrn.alias
    , fin = fin.alias
    , powerplan = pw.pw_group_desc
    , pw2.order_dt_tm
from ( ( 
        /*In-line table is necessary because pathway table are
        structured in where individual DOTs and individual 
        phases each have a separate line item, so searching for
        1 instance of a PowerPlan use will generally return 6 line
        items
        
        select distinct doesn't produce proper results, so just 
        grabbing the max pathway_id for each pw_group_nbr - filtering
        just by phase name is also possible
        */
        select pathway_id = max(pw.pathway_id)
            , pw.person_id
            , pw.encntr_id
            , pw.pw_group_desc
            , pw.pw_group_nbr
        from pathway pw
        where pw.type_mean != 'DOT'
            and ( pw.pw_group_desc like 'ONC*'
                or pw.pw_group_desc like 'INF*'
                ) 
            /*Add specific PowerPlan name here, using caps and wildcards*/
            ;and cnvtupper(pw.pw_group_desc) like '*POWERPLAN_NAME_HERE*'
        group by pw.person_id
            , pw.encntr_id
            , pw.pw_group_desc
            , pw.pw_group_nbr
        with sqltype("f8", "f8", "f8", "vc", "f8")
    ) pw ) 
    , pathway pw2
    , person p
    , encounter e
    , encntr_alias mrn
    , encntr_alias fin
plan pw
join pw2 where pw2.pathway_id = pw.pathway_id
    /*Date boundaries if needed. If this is left commented, this query
    will search for all oncology powerplans*/
;    and pw2.order_dt_tm between cnvtdatetime(cnvtdate(MMDDYY), 0)
;        and cnvtdatetime(cnvtdate(MMDDYY), 0)
join p where p.person_id = pw.person_id
    and p.active_ind = 1
    and p.end_effective_dt_tm > sysdate
join e where e.encntr_id = pw.encntr_id
    and e.active_ind = 1
    and e.end_effective_dt_tm > sysdate
join mrn where mrn.encntr_id = e.encntr_id
    and mrn.encntr_alias_type_cd = value(uar_get_code_by("MEANING", 319, "MRN"))
    and mrn.active_ind = 1
    and mrn.end_effective_dt_tm > sysdate
join fin where fin.encntr_id = e.encntr_id
    and fin.encntr_alias_type_cd = value(uar_get_code_by("MEANING", 319, "FIN NBR"))
    and fin.active_ind = 1
    and fin.end_effective_dt_tm > sysdate
with format(date, "mm/dd/yyyy hh:mm:ss"), time = 60 
