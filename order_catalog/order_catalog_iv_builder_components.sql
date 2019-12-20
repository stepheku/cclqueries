/*
order_catalog_iv_builder_components.sql
~~~~~~~~~~~~~~~~~~~~
Extracts active IV builders and associated components
*/
select oc.primary_mnemonic
    , cc.comp_seq
    , ocs.mnemonic
from cs_component cc
    , order_catalog_synonym ocs
    , order_catalog oc
plan oc where oc.orderable_type_flag = 8
    and oc.active_ind = 1
    and oc.activity_type_cd = value(uar_get_code_by("MEANING", 106, "PHARMACY"))
join cc where cc.catalog_cd = oc.catalog_cd
join ocs where ocs.synonym_id = cc.comp_id
order by oc.primary_mnemonic
    , cc.comp_seq
with uar_code(d)
