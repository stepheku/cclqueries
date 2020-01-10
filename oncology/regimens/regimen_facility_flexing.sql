/*
regimen_facility_flexing.sql
~~~~~~~~~~~~~~~~~~~~
Checks for regimen facility flexing/virtual views
*/
select regimen = rcs.synonym_display
    , facility = if (nullind(r.regimen_cat_facility_r_id) = 1) "No facilities"
        elseif (nullind(r.regimen_cat_facility_r_id) = 0 and r.location_cd = 0) "All facilities"
        else uar_get_code_display(r.location_cd)
        endif
from regimen_catalog rc
    , regimen_cat_synonym rcs
    , regimen_cat_facility_r r
plan rc where rc.active_ind = 1
join rcs where rcs.regimen_catalog_id = rc.regimen_catalog_id
    and rcs.primary_ind = 1
join r where r.regimen_catalog_id = outerjoin(rc.regimen_catalog_id)