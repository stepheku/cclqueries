/*
order_catalog_primaries_associated_schedules.sql
~~~~~~~~~~~~~~~~~~~~
Order catalog primaries that are marked as "Schedulable" and all
associated Schedules
*/
select catalog_type = uar_get_code_display(oc.catalog_type_cd)
    , activity_type = uar_get_code_display(oc.activity_type_cd)
    , oc.primary_mnemonic
    , schedule = if(der.entity2_id = 0 and nullind(der.entity2_id) = 0) "Future"
        else uar_get_code_display(der.entity2_id)
        endif
from order_catalog oc
    , dcp_entity_reltn der
plan oc where oc.schedule_ind = 1
    and oc.active_ind = 1
join der where der.entity1_id = oc.catalog_cd
    and der.entity_reltn_mean = 'ORC/SCHENCTP'
    and der.active_ind = 1
    and der.end_effective_dt_tm > sysdate
    and der.begin_effective_dt_tm < sysdate