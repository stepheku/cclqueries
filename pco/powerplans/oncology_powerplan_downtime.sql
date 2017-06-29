select powerplan_description = pwcat.description
    , powerplan_display = pwcat.display_description
    , plan_type = uar_get_code_display(pwcat.pathway_type_cd)
    , pwcat.version
    , pwcat.beg_effective_dt_tm "mm/dd/yyyy hh:mm:ss"
    , end_effective_dt_tm = if(pwcat.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) "Current"
        else format(pwcat.end_effective_dt_tm, "mm/dd/yyyy hh:mm:ss")
        endif
    , phase = pwcat2.description
    , phase_duration = concat(trim(cnvtstring(pwcat2.duration_qty)), " ", uar_get_code_display(pwcat2.duration_unit_cd))
    , reference_text = substring(0,32000,lb.long_blob)
    , treatment_sched = pwcat3.description
    , parent_entity_name = evaluate2(if(pwcat.type_mean = "PATHWAY") pc.parent_entity_name
        elseif(pwcat.type_mean = "CAREPLAN") pc2.parent_entity_name endif)
    , component_type = evaluate2(
        if(pwcat.type_mean = "PATHWAY")
            if(pc.parent_entity_name = "ORDER_CATALOG_SYNONYM") "Order catalog synonym"
            elseif(pc.parent_entity_name = "LONG_TEXT") "Note"
            elseif(pc.parent_entity_name = "OUTCOME_CATALOG") "Outcome / indicator" endif
        elseif(pwcat.type_mean = "CAREPLAN")
            if(pc2.parent_entity_name = "ORDER_CATALOG_SYNONYM") "Order catalog synonym"
            elseif(pc2.parent_entity_name = "LONG_TEXT") "Note"
            elseif(pc2.parent_entity_name = "OUTCOME_CATALOG") "Outcome / indicator" endif
        endif)
    , start_offset = concat(trim(cnvtstring(pc.offset_quantity)), " ", uar_get_code_display(pc.offset_unit_cd))
    , target_duration = concat(trim(cnvtstring(pc.duration_qty)), " ", uar_get_code_display(pc.duration_unit_cd))
    , include = evaluate2(
        if(pwcat.type_mean = "PATHWAY") pc.include_ind
        elseif(pwcat.type_mean = "CAREPLAN") pc2.include_ind
        endif)
    , sequence = evaluate2(
        if(pwcat.type_mean = "PATHWAY") pc.sequence
        elseif(pwcat.type_mean = "CAREPLAN") pc2.sequence
        endif)
    , synonym = evaluate2(
        if(pwcat.type_mean = "PATHWAY")
            if(pc.parent_entity_name = "ORDER_CATALOG_SYNONYM") ocs.mnemonic
            elseif(pc.parent_entity_name = "LONG_TEXT") TRIM(substring(0,255,lt.long_text),7)
            elseif(pc.parent_entity_name = "OUTCOME_CATALOG") oc.description endif
        elseif(pwcat.type_mean = "CAREPLAN")
            if(pc2.parent_entity_name = "ORDER_CATALOG_SYNONYM") ocs3.mnemonic
            elseif(pc2.parent_entity_name = "LONG_TEXT") TRIM(substring(0,255,lt3.long_text),7) endif
        endif)
    , iv_builder_component = ocs2.mnemonic
    , order_sentence = evaluate2(
        if(pwcat.type_mean = "PATHWAY")
            if(pc.parent_entity_name = "OUTCOME_CATALOG") oc.expectation
            else os.order_sentence_display_line
            endif
        elseif(pwcat.type_mean = "CAREPLAN") os2.order_sentence_display_line
        endif)
    , order_comments = evaluate2(
        if(pwcat.type_mean = "PATHWAY") substring(0,255,lt2.long_text)
        elseif(pwcat.type_mean = "CAREPLAN") substring(0,255,lt4.long_text)
        endif)
    , chemo_offset = concat(trim(cnvtstring(pwcompr.offset_quantity)), " ", uar_get_code_display(pwcompr.offset_unit_cd))
from pathway_catalog pwcat
    , pathway_catalog pwcat2
    , pathway_catalog pwcat3
    , pw_cat_reltn pcr
    , pathway_comp pc
    , pathway_comp pc2
    , order_catalog_synonym ocs
    , order_catalog_synonym ocs3
    , pw_comp_cat_reltn r
    , pw_comp_reltn pwcompr
    , pw_comp_os_reltn pcos
    , pw_comp_os_reltn pcos2
    , order_sentence os
    , order_sentence os2
    , long_text lt
    , long_text lt2
    , long_text lt3
    , long_text lt4
    , ref_text_reltn rtr
    , ref_text rt
    , long_blob lb
    , order_catalog_synonym ocs2
    , outcome_catalog oc
plan pwcat where pwcat.active_ind = 1
    and pwcat.type_mean in ("CAREPLAN", "PATHWAY")
    and pwcat.description_key like 'ONC*PRE-TREAT*'
    and pwcat.description_key not like 'ONCOLOGY*'
    and pwcat.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    and pwcat.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3) /*Removes "Testing" and "Production, archived versions"*/
    and pwcat.ref_owner_person_id = 0 /*Filter out pre-CPOE-built PowerPlans*/
join pcr where pcr.pw_cat_s_id = outerjoin(pwcat.pathway_catalog_id)
join pwcat2 where pwcat2.pathway_catalog_id = outerjoin(pcr.pw_cat_t_id)
    and pwcat2.sub_phase_ind = outerjoin(0) /*Looks specifically for sub-phases (instead of PowerPlans within PowerPlans)*/
    and pwcat2.active_ind = outerjoin(1)
join pc where pc.pathway_catalog_id = outerjoin(pwcat2.pathway_catalog_id)
    and pc.active_ind = outerjoin(1)
join pc2 where pc2.pathway_catalog_id = outerjoin(pwcat.pathway_catalog_id)
    and pc2.active_ind = outerjoin(1)
join ocs where ocs.synonym_id = outerjoin(pc.parent_entity_id)
join oc where oc.outcome_catalog_id = outerjoin(pc.parent_entity_id)
join lt where lt.long_text_id = outerjoin(pc.parent_entity_id)
join r where r.pathway_comp_id = outerjoin(pc.pathway_comp_id)
join ocs3 where ocs3.synonym_id = outerjoin(pc2.parent_entity_id)
join lt3 where lt3.long_text_id = outerjoin(pc2.parent_entity_id)

/*Reference text stuff*/
join rtr where rtr.parent_entity_id = outerjoin(pwcat.pathway_catalog_id)
    and rtr.parent_entity_name = outerjoin("PATHWAY_CATALOG")
    and rtr.active_ind = outerjoin(1)
join rt where rt.refr_text_id = outerjoin(rtr.refr_text_id)
    and rt.text_entity_name = outerjoin("LONG_BLOB")
    and rt.active_ind = outerjoin(1)
join lb where lb.long_blob_id = outerjoin(rt.text_entity_id)
    and lb.active_ind = outerjoin(1)
    
/*Order sentence stuff*/
join pcos where pcos.pathway_comp_id = outerjoin(pc.pathway_comp_id)
join os where os.order_sentence_id = outerjoin(pcos.order_sentence_id)
join lt2 where lt2.long_text_id = outerjoin(os.ord_comment_long_text_id)
join ocs2 where ocs2.synonym_id = outerjoin(pcos.iv_comp_syn_id)

/*Order sentence stuff for non-phased powerplans*/
join pcos2 where pcos2.pathway_comp_id = outerjoin(pc2.pathway_comp_id)
join os2 where os2.order_sentence_id = outerjoin(pcos2.order_sentence_id)
join lt4 where lt4.long_text_id = outerjoin(os2.ord_comment_long_text_id)

join pwcat3 where pwcat3.pathway_catalog_id = outerjoin(r.pathway_catalog_id)
    and pwcat3.active_ind = outerjoin(1)
join pwcompr where pwcompr.pathway_comp_t_id = outerjoin(r.pathway_comp_id)
    and pwcompr.pathway_catalog_id = outerjoin(r.pathway_catalog_id)
order by 
 pwcat.description_key
    /*Not sure how to order by phase*/
    , pwcat2.pathway_catalog_id
    , phase
    , pc.sequence
    , pwcat3.description_key
