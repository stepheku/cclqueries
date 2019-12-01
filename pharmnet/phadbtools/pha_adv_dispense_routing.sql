/*
pha_adv_dispense_routing.sql
~~~~~~~~~~~~~~~~~~~~
Grabs advanced dispense routing settings in PhaDbTools
*/
select r.active_ind
    , org = o.org_name
    , location = uar_get_code_display(l.location_cd)
    , disp_type = uar_get_code_display(r.disp_event_type_cd)
    , tab = if ( r.prn_ind = 1 ) "PRN"
        elseif ( r.prn_ind = 0 ) "Routine" endif
    , service_resource =  if ( r.service_resource_cd = 0 ) uar_get_code_display(l.location_cd)
        else uar_get_code_display(r.service_resource_cd) endif
    , service_resource_type = if ( r.service_resource_cd = 0 ) "Floorstock"
        else "Pharmacy" endif 
    , r.default_ind
from rx_loc_resource_reltn r
    , code_value c
    , location l
    , organization o
plan r 
join l where l.location_cd = r.location_cd
    and l.active_ind = 1
join c where c.code_value = r.location_cd
    and c.active_ind = 1
join o where o.organization_id = l.organization_id
order by o.org_name
    , c.display_key
    , r.prn_ind
    , r.disp_event_type_cd
    , r.sequence_nbr
