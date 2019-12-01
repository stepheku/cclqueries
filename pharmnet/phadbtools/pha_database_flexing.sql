/*
pha_database_flexing.sql
~~~~~~~~~~~~~~~~~~~~
Grabs database flexing set in PhaDbTools
*/
select code_set = s.description
    , current_value = uar_get_code_display(p.ref_entity_id)
    , new_value = uar_get_code_display(p.new_entity_id)
    , facility_location = uar_get_code_display(p.flex_entity_id)
from pha_flex p
    , code_value c
    , code_value_set s
plan p where p.active_ind = 1
join c where c.code_value = p.ref_entity_id
    and c.active_ind = 1
join s where s.code_set = c.code_set
order by s.code_set
    , uar_get_code_display(p.flex_entity_id)
with format(date,"mm/dd/yyyy hh:mm:ss")