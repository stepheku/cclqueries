/*
pco_powerplan_synonym_virtual_view_phased.sql
~~~~~~~~~~~~~~~~~~~~
Grabs the virtual view settings of any synonym in oncology powerplans. 
This is specifically for multi-phase PowerPlans (i.e., multiple phases 
or DOTs)

Make sure when this is in Excel, to run a pivot table against this to 
see what's viewed correctly and what isn't
*/
select distinct 
    primary = oc.primary_mnemonic
    , catalog_type = uar_get_code_display(ocs.catalog_type_cd)
    , activity_type = uar_get_code_display(ocs.activity_type_cd)
    , powerplan_component = uar_get_code_display(pc.comp_type_cd)
    , synonym = ocs.mnemonic
    , synonym_type = uar_get_code_display(ocs.mnemonic_type_cd)
    , facility = if(nullind(r.facility_cd) = 1) "No facilities"
        else uar_get_code_display(r.facility_cd)
        endif
from pathway_catalog pwcat
    , pathway_catalog pwcat2
    , pw_cat_reltn pcr
    , pathway_comp pc
    , order_catalog_synonym ocs
    , order_catalog oc
    , ( ( select r.synonym_id
                , r.facility_cd
            from ocs_facility_r r
                , code_value c
            where r.facility_cd = c.code_value
                and c.code_set = 220
                and c.active_ind = 1
            with sqltype("f8", "f8")) r ) 
plan pwcat where pwcat.active_ind = 1
    and pwcat.type_mean in ("CAREPLAN", "PATHWAY")
    and pwcat.description_key like 'ONC*'
    and pwcat.description_key not like 'ONCOLOGY*'
    and pwcat.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    and pwcat.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    and pwcat.ref_owner_person_id = 0
join pcr where pcr.pw_cat_s_id = outerjoin(pwcat.pathway_catalog_id)
join pwcat2 where pwcat2.pathway_catalog_id = outerjoin(pcr.pw_cat_t_id)
    and pwcat2.sub_phase_ind = outerjoin(0)
    and pwcat2.active_ind = outerjoin(1)
join pc where pc.pathway_catalog_id = pwcat2.pathway_catalog_id
    and pc.active_ind = 1
    and pc.parent_entity_name = "ORDER_CATALOG_SYNONYM"
join ocs where ocs.synonym_id = pc.parent_entity_id
join oc where oc.catalog_cd = ocs.catalog_cd
join r where r.synonym_id = outerjoin(ocs.synonym_id)
order by oc.primary_mnemonic
    , ocs.mnemonic_key_cap