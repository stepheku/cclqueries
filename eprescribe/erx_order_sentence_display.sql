/*
erx_order_sentence_display.sql
~~~~~~~~~~~~~~~~~~~~
This query will grab prescription order sentences and evaluate 
what the likely erx order sentence will be and the text length
*/

select primary = oc.primary_mnemonic
    , synonym_type = uar_get_code_display(ocs.mnemonic_type_cd)
    , synonym = ocs.mnemonic
    , os.order_sentence_display_line
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
from order_catalog_synonym ocs
    , order_catalog oc
    , ord_cat_sent_r r
    , order_sentence os
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
plan ocs where ocs.active_ind = 1
    and ocs.activity_type_cd = value(uar_get_code_by("MEANING", 106, "PHARMACY"))
join oc where oc.catalog_cd = ocs.catalog_cd
    and oc.orderable_type_flag != 8 /*IV builders*/
join r where r.synonym_id = ocs.synonym_id
join os where os.order_sentence_id = r.order_sentence_id
    and os.usage_flag = 2
join osd1 where osd1.order_sentence_id = outerjoin(os.order_sentence_id)
    and osd1.oe_field_meaning_id = outerjoin(2056) /* Strength Dose */
join osd2 where osd2.order_sentence_id = outerjoin(os.order_sentence_id)
    and osd2.oe_field_meaning_id = outerjoin(2057) /* Strength Dose Unit */
join osd3 where osd3.order_sentence_id = outerjoin(os.order_sentence_id)
    and osd3.oe_field_meaning_id = outerjoin(2058) /* Volume Dose */
join osd4 where osd4.order_sentence_id = outerjoin(os.order_sentence_id)
    and osd4.oe_field_meaning_id = outerjoin(2059) /* Volume Dose Unit */
join osd5 where osd5.order_sentence_id = outerjoin(os.order_sentence_id)
    and osd5.oe_field_meaning_id = outerjoin(2063) /* Freetext Dose */
join osd6 where osd6.order_sentence_id = outerjoin(os.order_sentence_id)
    and osd6.oe_field_meaning_id = outerjoin(2050) /* Route of Administration */
join osd7 where osd7.order_sentence_id = outerjoin(os.order_sentence_id)
    and osd7.oe_field_meaning_id = outerjoin(2011) /* Frequency */
join osd8 where osd8.order_sentence_id = outerjoin(os.order_sentence_id)
    and osd8.oe_field_meaning_id = outerjoin(2037) /* Scheduled / PRN */
join osd9 where osd9.order_sentence_id = outerjoin(os.order_sentence_id)
    and osd9.oe_field_meaning_id = outerjoin(2101) /* PRN Instructions */
join osd10 where osd10.order_sentence_id = outerjoin(os.order_sentence_id)
    and osd10.oe_field_meaning_id = outerjoin(142) /* PRN Reason */
join osd11 where osd11.order_sentence_id = outerjoin(os.order_sentence_id)
    and osd11.oe_field_meaning_id = outerjoin(1103) /* Special Instructions */
join osd12 where osd12.order_sentence_id = outerjoin(os.order_sentence_id)
    and osd12.oe_field_meaning_id = outerjoin(2061) /* Duration */
join osd13 where osd13.order_sentence_id = outerjoin(os.order_sentence_id)
    and osd13.oe_field_meaning_id = outerjoin(2062) /* Duration Unit */
with time = 60