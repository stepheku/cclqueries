/*
order_catalog_synonym_standardizing_dosing_extract.sql
~~~~~~~~~~~~~~~~~~~~
Extracts active order catalog synonyms and associated standardized
dose parameters
*/

select oc.primary_mnemonic
    , synonym = ocs.mnemonic
    , synonym_type = uar_get_code_display(ocs.mnemonic_type_cd)
    , route = uar_get_code_display(sod.route_cd)
    , range_operator = evaluate2(
        if(sod.relational_operator_flag = 0) "="
        elseif(sod.relational_operator_flag = 1) "<"
        elseif(sod.relational_operator_flag = 2) ">"
        elseif(sod.relational_operator_flag = 3) "<="
        elseif(sod.relational_operator_flag = 4) ">="
        elseif(sod.relational_operator_flag = 5) "!="
        elseif(sod.relational_operator_flag = 6) "between"
        elseif(sod.relational_operator_flag = 7) "outside or not between (inclusive)"
        elseif(sod.relational_operator_flag = 8) "In"
        elseif(sod.relational_operator_flag = 9) "Not In"
        endif)
    , sod.compare_value1
    , sod.compare_value2
    , sod.std_dose_value
    , std_dose_unit = uar_get_code_display(sod.std_dose_unit_cd)
from order_catalog_synonym ocs
    , order_catalog oc
    , standardized_order_dose sod
plan ocs where ocs.active_ind = 1
join oc where oc.catalog_cd = ocs.catalog_cd
    and oc.active_ind = 1
join sod where sod.synonym_id = ocs.synonym_id
    and sod.active_ind = 1
order by oc.primary_mnemonic
    , ocs.mnemonic_key_cap
    , sod.route_cd
    , sod.compare_value1