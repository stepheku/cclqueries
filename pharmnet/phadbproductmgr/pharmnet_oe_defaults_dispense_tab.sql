/*
pharmnet_oe_defaults_dispense_tab.sql
~~~~~~~~~~~~~~~~~~~~
Obtains active PharmNet products/IV sets and the contents on the
OE defaults tab and Dispense tab
*/
select md.item_id
    , product_description = mi.value
    , med_type = evaluate2(if(md.med_type_flag = 0) "Product" 
        elseif(md.med_type_flag = 1) "Repackaged item" 
        elseif(md.med_type_flag = 2) "Compound" 
        elseif(md.med_type_flag = 3) "IV set" 
        elseif (md.med_type_flag = 4) "Order set" endif)
    , str = md.given_strength
    , dose_form = uar_get_code_display(md.form_cd)
    , legend = uar_get_code_display(mdi.legal_status_cd)
    , oe_freetxt_dose = mod.freetext_dose
    , oe_str = mod.strength
    , oe_str_unit = uar_get_code_display(mod.strength_unit_cd)
    , oe_vol = mod.volume
    , oe_vol_unit = uar_get_code_display(mod.volume_unit_cd)
    , oe_route = uar_get_code_display(mod.route_cd)
    , oe_freq = uar_get_code_display(mod.frequency_cd)
    , oe_infuse_over = mod.infuse_over
    , oe_infuse_units = uar_get_code_display(mod.infuse_over_cd)
    , oe_freetxt_infuse = mod.freetext_rate_txt
    , oe_norm_rate = mod.normalized_rate_nbr
    , oe_norm_rate_units = uar_get_code_display(mod.normalized_rate_unit_cd)
    , oe_rate = mod.rate_nbr
    , oe_rate_units = uar_get_code_display(mod.rate_unit_cd)
    , oe_duration = mod.duration
    , oe_duration_units = uar_get_code_display(mod.duration_unit_cd)
    , oe_stop_type = uar_get_code_display(mod.stop_type_cd)
    , oe_prn_ind = mod.prn_ind
    , oe_prn_indica = uar_get_code_display(mod.prn_reason_cd)
    , oe_order_as = ocs.mnemonic
    , oe_default_screen = mdi.oe_format_flag
    , oe_default_screen = if (mdi.oe_format_flag = 0) ""
        elseif (mdi.oe_format_flag = 1) "Medication"
        elseif (mdi.oe_format_flag = 2) "Continuous"
        elseif (mdi.oe_format_flag = 3) "Intermittent"
        endif
    , oe_filter_med = mdi.med_filter_ind
    , oe_filter_cont = mdi.continuous_filter_ind
    , oe_filter_tpn = mdi.tpn_filter_ind
    , oe_filter_int = mdi.intermittent_filter_ind
    , oe_cmt_1_fill_list = evaluate2(if(mod.comment1_type=1 or mod.comment1_type=3 
        or mod.comment1_type=5 or mod.comment1_type=7) "1" endif)
    , oe_cmt_1_mar = evaluate2(if(mod.comment1_type=2 or mod.comment1_type=3 
        or mod.comment1_type=6 or mod.comment1_type=7) "1" endif)
    , oe_cmt_1_label = evaluate2(if(mod.comment1_type=4 or mod.comment1_type=5 
        or mod.comment1_type=6 or mod.comment1_type=7) "1" endif)
    , oe_cmt_2_fill_list = evaluate2(if(mod.comment2_type=1 or mod.comment2_type=3 
        or mod.comment2_type=5 or mod.comment2_type=7) "1" endif)
    , oe_cmt_2_mar = evaluate2(if(mod.comment2_type=2 or mod.comment2_type=3 
        or mod.comment2_type=6 or mod.comment2_type=7) "1" endif)
    , oe_cmt_2_label = evaluate2(if(mod.comment2_type=4 or mod.comment2_type=5 
        or mod.comment2_type=6 or mod.comment2_type=7) "1" endif)
    , disp_str = mdi.strength
    , disp_str_unit = uar_get_code_display(mdi.strength_unit_cd)
    , disp_vol = mdi.volume
    , disp_vol_unit = uar_get_code_display(mdi.volume_unit_cd)
    , disp_qty = mpt.dispense_qty
    , disp_unit = uar_get_code_display(mpt.uom_cd)
    , disp_cat = uar_get_code_display(mod.dispense_category_cd)
    , disp_factor = mdi.dispense_factor
    , disp_per_pkg = mdi.pkg_qty_per_pkg
    , disp_formulary_status = uar_get_code_display(mdi.formulary_status_cd)
    , disp_pric_sch = mod.price_sched_id
    , disp_pric_sch_d = ps.price_sched_desc
    , disp_in_ttl_vol = mdi.used_as_base_ind
    , disp_divisible = mdi.divisible_ind
    , disp_inf_div = mdi.infinite_div_ind
    , disp_min_div_fac = mdi.base_issue_factor
    , disp_def_par_doses = md.default_par_doses
    , disp_max_par_suppl = md.max_par_supply
    , disp_poc_charge_fl = mdi.poc_charge_flag
from item_definition id
    , medication_definition md
    , med_identifier mi
    , med_def_flex mdf
    , med_flex_object_idx mfoi
    , med_oe_defaults mod
    , med_def_flex mdf2
    , med_flex_object_idx mfoi2
    , med_dispense mdi
    , med_package_type mpt
    , price_sched ps
    , order_catalog_synonym ocs
plan id where id.active_ind = 1
join md where md.item_id = id.item_id
join mi where mi.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "DESC"))
    and mi.item_id = md.item_id
    and mi.active_ind = 1
    and mi.primary_ind = 1
    and mi.med_product_id = 0
join mdf where mdf.item_id = md.item_id
    and mdf.active_ind = 1  
    and mdf.flex_type_cd = value(uar_get_code_by("MEANING", 4062, "SYSTEM"))
join mfoi where mdf.med_def_flex_id = mfoi.med_def_flex_id 
    and mfoi.flex_object_type_cd = value(uar_get_code_by("MEANING", 4063, "OEDEF"))
join mod where mfoi.parent_entity_id = mod.med_oe_defaults_id 
    and mod.active_ind = 1
join mdf2 where mdf2.item_id = md.item_id
    and mdf2.active_ind = 1
    and mdf2.flex_type_cd = value(uar_get_code_by("MEANING", 4062, "SYSPKGTYP"))
    and mdf2.pharmacy_type_cd = value(uar_get_code_by("MEANING", 4500, "INPATIENT"))
    and mdf2.sequence = 0
join mfoi2 where 
    mdf2.med_def_flex_id = mfoi2.med_def_flex_id 
    and mfoi2.flex_object_type_cd = value(uar_get_code_by("MEANING", 4063, "DISPENSE"))
    and mfoi2.active_ind = 1
join mdi where mfoi2.parent_entity_id = mdi.med_dispense_id
join mpt where mpt.med_package_type_id = mdf2.med_package_type_id
join ps where ps.price_sched_id = outerjoin(mod.price_sched_id)
    and ps.active_ind = outerjoin(1)
join ocs where ocs.synonym_id = outerjoin(mod.ord_as_synonym_id)
order by md.item_id