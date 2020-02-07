/*
pco_powerplan_linked_groups.sql
~~~~~~~~~~~~~~~~~~~
This query identifies linked components built in oncology Powerplans
*/

select powerplan = pwcat.description
    , phase_name = pwcat2.description
    , pc.sequence
    , synonym = ocs.mnemonic
    , order_sentence = os.order_sentence_display_line    
    , linking_rule = dm.description
    , linking_value = pcg.linking_rule_quantity
    , linking_grp_desc = pcg.description
from pathway_catalog pwcat
    , pathway_catalog pwcat2
    , pw_cat_reltn pcr
    , pathway_comp pc
    , order_catalog_synonym ocs
    , pw_comp_group pcg
    , dm_flags dm
    , pw_comp_os_reltn pcos
    , order_sentence os
plan pwcat where pwcat.active_ind = 1
    and pwcat.type_mean in ("CAREPLAN", "PATHWAY")
    and pwcat.description_key like 'ONC*'
    and pwcat.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    and pwcat.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    and pwcat.ref_owner_person_id = 0
join pcr where pcr.pw_cat_s_id = pwcat.pathway_catalog_id
join pwcat2 where pcr.pw_cat_t_id = pwcat2.pathway_catalog_id
    and pwcat2.sub_phase_ind = 0
join pc where pc.pathway_catalog_id = pwcat2.pathway_catalog_id
    and pc.active_ind = 1
    and pc.parent_entity_name = 'ORDER_CATALOG_SYNONYM'
join ocs where ocs.synonym_id = pc.parent_entity_id
    and ocs.active_ind = 1
join pcg where pcg.pathway_catalog_id = pc.pathway_catalog_id
    and pcg.pathway_comp_id = pc.pathway_comp_id
    and pcg.type_mean = 'LINKEDCOMP'
join dm where dm.table_name = 'PW_COMP_GROUP'
    and dm.column_name = 'LINKING_RULE_FLAG'
    and dm.flag_value = pcg.linking_rule_flag
join pcos where pcos.pathway_comp_id = outerjoin(pc.pathway_comp_id)
join os where os.order_sentence_id = outerjoin(pcos.order_sentence_id)
order by pwcat.description_key
    , pwcat2.pathway_catalog_id
    , pc.sequence