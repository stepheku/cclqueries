/*
regimen_attributes.sql
~~~~~~~~~~~~~~~~~~~~
Identifies regimens and displays any active attributes (e.g., Clinical Trials,
Line of Therapy, etc)
*/
select regimen = rcs.synonym_display
    , rc.extend_treatment_ind
    , rc.add_plan_ind
    , attribute = rca.attribute_display
    , display_mode = if(rcar.display_flag = 0) "Unknown"
        elseif(rcar.display_flag = 1) "Display Only"
        elseif(rcar.display_flag = 2) "Optional"
        elseif(rcar.display_flag = 3) "Required"
        endif
    , default_value = if(rca.code_set = 0) cnvtstring(rcar.default_value_id)
        else uar_get_code_display(rcar.default_value_id)
        endif
    , rcar.default_value_id
from regimen_catalog rc
    , regimen_cat_synonym rcs
    , regimen_cat_attribute rca
    , regimen_cat_attribute_r rcar
plan rc where rc.active_ind = 1
    and rc.end_effective_dt_tm > sysdate
join rcs where rcs.regimen_catalog_id = rc.regimen_catalog_id
    and rcs.primary_ind = 1
;    and rcs.synonym_key like '*ONC*' /*Regimen name in CAPs with asterisks*/
join rcar where rcar.regimen_catalog_id = rc.regimen_catalog_id
    and rcar.active_ind = 1
join rca where rca.regimen_cat_attribute_id = rcar.regimen_cat_attribute_id
    and rca.active_ind = 1