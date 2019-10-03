/*
facility_flexing.sql
~~~~~~~~~~~~~~~~~~~
This query checks powerplan facility flexing. Un-comment out the
line that designates the powerplan name or the facility display and
make sure to use capitalized and wildcards

for example:
and pwcat.description_key like '*ONCP*AC*'
*/

select powerplan = pwcat.description
    , powerplan_cmt = substring(1,100,lt.long_text)
    , pwcat.pathway_catalog_id
    , facility = evaluate2(if(nullind(c.code_value) = 1) "No facilities"
        elseif(c.code_value = 0) "All facilities"
        elseif(c.code_value > 0) uar_get_code_display(f.parent_entity_id)
        endif)
from pathway_catalog pwcat
    , pw_cat_flex f
    , code_value c
    , long_text lt
plan pwcat where pwcat.active_ind = 1
    and pwcat.type_mean in ("CAREPLAN", "PATHWAY")
    and pwcat.end_effective_dt_tm > cnvtdatetime(sysdate)
    and pwcat.beg_effective_dt_tm < cnvtdatetime(sysdate)
    and pwcat.ref_owner_person_id = 0 
        /*Filter out pre-CPOE-built PowerPlans*/
    ;and pwcat.description_key like '*POWERPLAN NAME IN CAPS*'
join f where f.pathway_catalog_id = pwcat.pathway_catalog_id
join c where c.code_value = outerjoin(f.parent_entity_id)
	;and c.display_key like '*FACILITY DISPLAY IN CAPS*'
join lt where lt.long_text_id = outerjoin(pwcat.long_text_id)
    and lt.active_ind = outerjoin(1)
order by pwcat.description
