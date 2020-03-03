/*
prescription_order_sentences_disp_qty_disp_unit.sql
~~~~~~~~~~~~~~~~~~~~
This identifies all prescription order sentences with the dispense 
quantity and dispense quantity unit.
*/
select synonym = ocs.mnemonic
    , synonym_type = uar_get_code_display(ocs.mnemonic_type_cd)
    , ocsr.order_sentence_disp_line
    , dispense_qty = disp.oe_field_display_value
    , dispense_qty_unit = disp_unit.oe_field_display_value
from order_catalog_synonym ocs
    , ord_cat_sent_r ocsr
    , order_sentence os
    , order_sentence_detail disp
    , order_sentence_detail disp_unit
plan ocs where ocs.active_ind = 1
    and ocs.activity_type_cd = value(uar_get_code_by("MEANING", 106, "PHARMACY"))
join ocsr where ocsr.synonym_id = ocs.synonym_id
join os where os.order_sentence_id = ocsr.order_sentence_id
    and os.usage_flag = 2
join disp where disp.order_sentence_id = outerjoin(os.order_sentence_id)
    and disp.oe_field_meaning_id = outerjoin(2015) ; Dispense Quantity
join disp_unit where disp_unit.order_sentence_id = outerjoin(os.order_sentence_id)
    and disp_unit.oe_field_meaning_id = outerjoin(2102) ; Dispense Quantity Unit