/*
prescription_order_sentences_powerplan.sql
~~~~~~~~~~~~~~~~~~~~
This query grabs any prescription orders in PowerPlans and 
displays the dispense quantity and dispense quantity unit
*/
select powerplan = if(pwcat2.pathway_catalog_id = 0) pwcat.description
       else pwcat2.description
       endif
    , active_ind = if(pwcat2.pathway_catalog_id = 0) pwcat.active_ind
       else pwcat2.active_ind
       endif
    , phase = if(pwcat2.pathway_catalog_id = 0) ""
       else pwcat.description
       endif
    , synonym = ocs.mnemonic
    , synonym_type = uar_get_code_display(ocs.mnemonic_type_cd)
    , pcos.order_sentence_seq
    , os.order_sentence_display_line
    , dispense_qty = disp.oe_field_display_value
    , dispense_qty_unit = disp_unit.oe_field_display_value
from order_sentence os
    , order_sentence_detail disp
    , order_sentence_detail disp_unit
    , pathway_comp pc
    , pw_cat_reltn pcr
    , pathway_catalog pwcat
    , pathway_catalog pwcat2
    , pw_comp_os_reltn pcos
    , order_catalog_synonym ocs
plan os
join pcos where pcos.order_sentence_id = os.order_sentence_id
join disp where disp.order_sentence_id = outerjoin(os.order_sentence_id)
    and disp.oe_field_meaning_id = outerjoin(2015) ; Dispense Quantity
join disp_unit where disp_unit.order_sentence_id = outerjoin(os.order_sentence_id)
    and disp_unit.oe_field_meaning_id = outerjoin(2102) ; Dispense Quantity Unit
join pc where pc.pathway_comp_id = pcos.pathway_comp_id
    and pc.active_ind = 1
    and pc.comp_type_cd = value(uar_get_code_by("MEANING", 16750, "PRESCRIPTION"))
    and pc.parent_entity_name = 'ORDER_CATALOG_SYNONYM'
join ocs where ocs.synonym_id = pc.parent_entity_id
join pwcat where pwcat.pathway_catalog_id = pc.pathway_catalog_id
    and pwcat.active_ind = 1
    and pwcat.end_effective_dt_tm > sysdate
    and pwcat.beg_effective_dt_tm < sysdate
join pcr where pcr.pw_cat_t_id = outerjoin(pwcat.pathway_catalog_id)
    and pcr.type_mean = outerjoin("GROUP")
join pwcat2 where pwcat2.pathway_catalog_id = outerjoin(pcr.pw_cat_s_id)