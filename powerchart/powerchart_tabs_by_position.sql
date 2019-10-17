/*
powerchart_tabs_by_position.sql
~~~~~~~~~~~~~~~~~~~~
shows the tabs that are viewable in PowerChart based on position 
(such as if we need to compare/contrast between what tabs are 
viewable in PowerChart between positions)
*/
select v.application_number
    , application_name = a.description
    , position = uar_get_code_display(v.position_cd)
    , display_seq = nvp.pvc_value
    , tab_name = nvp2.pvc_value
from view_prefs v
    , application a
    , name_value_prefs nvp
    , name_value_prefs nvp2
plan v where v.active_ind = 1
    and v.frame_type = 'CHART'
    and v.position_cd in (
        select c.code_value
        from code_value c
        where c.code_set = 88
            and c.active_ind = 1
            /* and c.display_key like '*POSITION NAME IN CAPS*' */
            and c.end_effective_dt_tm > sysdate
        )
join a where a.application_number = v.application_number
    and a.application_number = 600005
join nvp where nvp.parent_entity_id = v.view_prefs_id
    and nvp.active_ind = 1
    and nvp.parent_entity_name = 'VIEW_PREFS'
    and nvp.pvc_name = 'DISPLAY_SEQ'
join nvp2 where nvp2.parent_entity_id = nvp.parent_entity_id
    and nvp2.active_ind = 1
    and nvp2.parent_entity_name = 'VIEW_PREFS'
    and nvp2.pvc_name = 'VIEW_CAPTION'
order by uar_get_code_display(v.position_cd)
    , a.description
    , cnvtreal(nvp.pvc_value)
