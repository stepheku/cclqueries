/*
phased_powerplan_erx_order_sentence_display.sql
~~~~~~~~~~~~~~~~~~~~
Within phased powerplans, this query will grab prescriptions and 
their order sentences and evaluate what the likely erx order sentence 
will be and the text length
*/

select powerplan_description = pwcat.description
    , plan_type = uar_get_code_display(pwcat.pathway_type_cd)
    , phase = pwcat2.description
    , synonym = evaluate2(
        if(pwcat.type_mean = "PATHWAY")
            if(pc.parent_entity_name = "ORDER_CATALOG_SYNONYM") ocs.mnemonic
            elseif(pc.parent_entity_name = "LONG_TEXT") TRIM(substring(0,255,lt.long_text),7)
            elseif(pc.parent_entity_name = "OUTCOME_CATALOG") oc.description 
            endif
        elseif(pwcat.type_mean = "CAREPLAN")
            if(pc2.parent_entity_name = "ORDER_CATALOG_SYNONYM") ocs3.mnemonic
            elseif(pc2.parent_entity_name = "LONG_TEXT") TRIM(substring(0,255,lt3.long_text),7) 
            endif
        endif)
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
    , erx_text_len = textlen(trim(concat(
          evaluate2(if(textlen(trim(osd1.oe_field_display_value)) > 0) 
                      concat(" ", trim(osd1.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd2.oe_field_display_value)) > 0) 
                      concat(" ", trim(osd2.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd3.oe_field_display_value)) > 0) 
                      concat(" ", trim(osd3.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd4.oe_field_display_value)) > 0) 
                      concat(" ", trim(osd4.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd5.oe_field_display_value)) > 0) 
                      concat(" ", trim(osd5.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd6.oe_field_display_value)) > 0) 
                      concat(" ", trim(osd6.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd7.oe_field_display_value)) > 0) 
                      concat(" ", trim(osd7.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(trim(osd8.oe_field_display_value) = "Yes") 
                      ",PRN"
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd9.oe_field_display_value)) > 0) 
                      concat(":", trim(osd9.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd11.oe_field_display_value)) > 0) 
                      concat(",Instr:", trim(osd11.oe_field_display_value))
                    else trim("", 2) endif)
    ), 2))
    , erx_text = trim(concat(
          evaluate2(if(textlen(trim(osd1.oe_field_display_value)) > 0) 
                      concat(" ", trim(osd1.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd2.oe_field_display_value)) > 0) 
                      concat(" ", trim(osd2.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd3.oe_field_display_value)) > 0) 
                      concat(" ", trim(osd3.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd4.oe_field_display_value)) > 0) 
                      concat(" ", trim(osd4.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd5.oe_field_display_value)) > 0) 
                      concat(" ", trim(osd5.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd6.oe_field_display_value)) > 0) 
                      concat(" ", trim(osd6.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd7.oe_field_display_value)) > 0) 
                      concat(" ", trim(osd7.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(trim(osd8.oe_field_display_value) = "Yes") 
                      ",PRN"
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd9.oe_field_display_value)) > 0) 
                      concat(":", trim(osd9.oe_field_display_value))
                    else trim("", 2) endif)
        , evaluate2(if(textlen(trim(osd11.oe_field_display_value)) > 0) 
                      concat(",Instr:", trim(osd11.oe_field_display_value))
                    else trim("", 2) endif)
    ), 2)
from pathway_catalog pwcat
    , pathway_catalog pwcat2
    , pw_cat_reltn pcr
    , pathway_comp pc
    , pathway_comp pc2
    , order_catalog_synonym ocs
    , order_catalog_synonym ocs3
    , pw_comp_os_reltn pcos
    , pw_comp_os_reltn pcos2
    , order_sentence os
    , order_sentence os2
    , long_text lt
    , long_text lt2
    , long_text lt3
    , long_text lt4
    , order_catalog_synonym ocs2
    , outcome_catalog oc
    , order_sentence_detail osd1 /*Strength Dose*/
    , order_sentence_detail osd2 /*Strength Dose Unit*/
    , order_sentence_detail osd3 /*Volume Dose*/
    , order_sentence_detail osd4 /*Volume Dose Unit*/
    , order_sentence_detail osd5 /*Freetext Dose*/
    , order_sentence_detail osd6 /*Route of Administration*/
    , order_sentence_detail osd7 /*Frequency*/
    , order_sentence_detail osd8 /*Scheduled / PRN*/
    , order_sentence_detail osd9 /*PRN Instructions*/
    , order_sentence_detail osd10 /*PRN Reason*/
    , order_sentence_detail osd11 /*Special Instructions*/
    , order_sentence_detail osd12 /*Duration*/
    , order_sentence_detail osd13 /*Duration Unit*/
plan pwcat where pwcat.active_ind = 1
    and pwcat.type_mean in ("CAREPLAN", "PATHWAY")
    and pwcat.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    and pwcat.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    and pwcat.ref_owner_person_id = 0
join pcr where pcr.pw_cat_s_id = outerjoin(pwcat.pathway_catalog_id)
join pwcat2 where pwcat2.pathway_catalog_id = outerjoin(pcr.pw_cat_t_id)
    and pwcat2.sub_phase_ind = outerjoin(0)
    and pwcat2.active_ind = outerjoin(1)
join pc where pc.pathway_catalog_id = outerjoin(pwcat2.pathway_catalog_id)
    and pc.active_ind = outerjoin(1)
join pc2 where pc2.pathway_catalog_id = outerjoin(pwcat.pathway_catalog_id)
    and pc2.active_ind = outerjoin(1)
    and pc2.comp_type_cd = value(uar_get_code_by("MEANING", 16750, "PRESCRIPTION"))
join ocs where ocs.synonym_id = outerjoin(pc.parent_entity_id)
join oc where oc.outcome_catalog_id = outerjoin(pc.parent_entity_id)
join lt where lt.long_text_id = outerjoin(pc.parent_entity_id)
join ocs3 where ocs3.synonym_id = outerjoin(pc2.parent_entity_id)
join lt3 where lt3.long_text_id = outerjoin(pc2.parent_entity_id)

/*Order sentence stuff*/
join pcos where pcos.pathway_comp_id = outerjoin(pc.pathway_comp_id)
join os where os.order_sentence_id = outerjoin(pcos.order_sentence_id)
join lt2 where lt2.long_text_id = outerjoin(os.ord_comment_long_text_id)
join ocs2 where ocs2.synonym_id = outerjoin(pcos.iv_comp_syn_id)

/*Order sentence stuff for non-phased powerplans*/
join pcos2 where pcos2.pathway_comp_id = outerjoin(pc2.pathway_comp_id)
join os2 where os2.order_sentence_id = outerjoin(pcos2.order_sentence_id)
join lt4 where lt4.long_text_id = outerjoin(os2.ord_comment_long_text_id)

join osd1 where osd1.order_sentence_id = outerjoin(os2.order_sentence_id)
    and osd1.oe_field_meaning_id = outerjoin(2056) /* Strength Dose */
join osd2 where osd2.order_sentence_id = outerjoin(os2.order_sentence_id)
    and osd2.oe_field_meaning_id = outerjoin(2057) /* Strength Dose Unit */
join osd3 where osd3.order_sentence_id = outerjoin(os2.order_sentence_id)
    and osd3.oe_field_meaning_id = outerjoin(2058) /* Volume Dose */
join osd4 where osd4.order_sentence_id = outerjoin(os2.order_sentence_id)
    and osd4.oe_field_meaning_id = outerjoin(2059) /* Volume Dose Unit */
join osd5 where osd5.order_sentence_id = outerjoin(os2.order_sentence_id)
    and osd5.oe_field_meaning_id = outerjoin(2063) /* Freetext Dose */
join osd6 where osd6.order_sentence_id = outerjoin(os2.order_sentence_id)
    and osd6.oe_field_meaning_id = outerjoin(2050) /* Route of Administration */
join osd7 where osd7.order_sentence_id = outerjoin(os2.order_sentence_id)
    and osd7.oe_field_meaning_id = outerjoin(2011) /* Frequency */
join osd8 where osd8.order_sentence_id = outerjoin(os2.order_sentence_id)
    and osd8.oe_field_meaning_id = outerjoin(2037) /* Scheduled / PRN */
join osd9 where osd9.order_sentence_id = outerjoin(os2.order_sentence_id)
    and osd9.oe_field_meaning_id = outerjoin(2101) /* PRN Instructions */
join osd10 where osd10.order_sentence_id = outerjoin(os2.order_sentence_id)
    and osd10.oe_field_meaning_id = outerjoin(142) /* PRN Reason */
join osd11 where osd11.order_sentence_id = outerjoin(os2.order_sentence_id)
    and osd11.oe_field_meaning_id = outerjoin(1103) /* Special Instructions */
join osd12 where osd12.order_sentence_id = outerjoin(os2.order_sentence_id)
    and osd12.oe_field_meaning_id = outerjoin(2061) /* Duration */
join osd13 where osd13.order_sentence_id = outerjoin(os2.order_sentence_id)
    and osd13.oe_field_meaning_id = outerjoin(2062) /* Duration Unit */

order by pwcat.description_key
    , pwcat2.pathway_catalog_id
    , phase
    , pc.sequence

with time = 60
