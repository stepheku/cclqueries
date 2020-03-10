/*
pharmnet_iv_sets_corresponding_products.sql
~~~~~~~~~~~~~~~~~~~~
Query grabs all PharmNet IV sets that are viewed to a specific facility and gets 
the corresponding PharmNet products assigned with their dose and gives OE defaults
of the IV set
*/

select iv_set = mi.value
    , mis.sequence
    , mi2.item_id
    , product_desc = mi2.value
    , dose = evaluate2(
        if (textlen(trim(mod.freetext_dose)) = 0)
            if (mod.volume = 0 and mod.strength > 0)
                concat(trim(cnvtstring(mod.strength)), " ", trim(uar_get_code_display(mod.strength_unit_cd)))
            elseif (mod.strength = 0 and mod.volume > 0)
                concat(trim(cnvtstring(mod.volume)), " ", trim(uar_get_code_display(mod.volume_unit_cd)))
            else
                concat(trim(cnvtstring(mod.strength)), " ", trim(uar_get_code_display(mod.strength_unit_cd)), " / ",
                    trim(cnvtstring(mod.volume)), " ", trim(uar_get_code_display(mod.volume_unit_cd)))
            endif
        else
            trim(mod.freetext_dose)
        endif )
    , route = uar_get_code_display(mod2.route_cd)
    , frequency = uar_get_code_display(mod2.frequency_cd)
    , infuse_over = evaluate2(
        if (mod2.infuse_over != -1)
            concat(trim(cnvtstring(mod2.infuse_over)), " ", trim(uar_get_code_display(mod2.infuse_over_cd)))
        else ""
        endif )
    , mdi.med_filter_ind
    , mdi.intermittent_filter_ind
    , mdi.continuous_filter_ind
from item_definition id
    , medication_definition md
    , med_identifier mi
    , med_def_flex mdf
    , med_flex_object_idx mfoi
    , med_ingred_set mis
    , med_identifier mi2
    /*OE defaults for individual ingredients*/
    , med_def_flex mdf2
    , med_oe_defaults mod
    , med_flex_object_idx mfoi2
    /*OE default for IV set*/
    , med_def_flex mdf3
    , med_oe_defaults mod2
    , med_flex_object_idx mfoi3
    /*Dispense tab for IV set*/
    , med_def_flex mdf4
    , med_dispense mdi
    , med_flex_object_idx mfoi4
plan id where id.active_ind = 1
join md where md.item_id = id.item_id
    and md.med_type_flag = 3 /*IV set*/
join mi where mi.item_id = md.item_id
    and mi.med_product_id = 0
    and mi.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "DESC"))
    and mi.active_ind = 1
    and mi.primary_ind = 1
join mdf where mdf.item_id = md.item_id
    and mdf.active_ind = 1
join mfoi where mfoi.med_def_flex_id = mdf.med_def_flex_id
    and mfoi.flex_object_type_cd = value(uar_get_code_by("MEANING", 4063, "ORDERABLE"))
    and ( mfoi.parent_entity_id = 0 /*In case "All Facilities" is selected in PhaDbProductMgr*/
        or mfoi.parent_entity_id in ( /*Looking for SPH St Paul's facility*/
            select cv.code_value
            from code_value cv
            where cv.active_ind = 1
                and cv.code_set = 220
                and cv.cdf_meaning = "FACILITY"
                /*and cv.display_key like "*FACILITY*NAME*HERE*"*/
            )
        )
join mis where mis.parent_item_id = md.item_id
join mi2 where mi2.item_id = mis.child_item_id
    and mi2.active_ind = 1
    and mi2.primary_ind = 1
    and mi2.med_product_id = 0
    and mi2.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "DESC"))
/*OE defaults for individual ingredients*/
join mdf2 where mdf2.item_id = md.item_id
    and mdf2.flex_type_cd = value(uar_get_code_by("MEANING", 4062, "SYSPKGTYP"))
    and mdf2.sequence = mis.sequence
join mfoi2 where mfoi2.med_def_flex_id = mdf2.med_def_flex_id
    and mfoi2.active_ind = 1
    and mfoi2.parent_entity_name = "MED_OE_DEFAULTS"
    and mfoi2.flex_object_type_cd = value(uar_get_code_by("MEANING", 4063, "OEDEF"))
join mod where mod.med_oe_defaults_id = mfoi2.parent_entity_id
/*OE defaults for IV set*/
join mdf3 where mdf3.item_id = md.item_id
    and mdf3.flex_type_cd = value(uar_get_code_by("MEANING", 4062, "SYSTEM"))
    and mdf3.sequence = 0
join mfoi3 where mfoi3.med_def_flex_id = mdf3.med_def_flex_id
    and mfoi3.active_ind = 1
    and mfoi3.parent_entity_name = "MED_OE_DEFAULTS"
    and mfoi3.flex_object_type_cd = value(uar_get_code_by("MEANING", 4063, "OEDEF"))
join mod2 where mod2.med_oe_defaults_id = mfoi3.parent_entity_id
/*Dispense tab for IV set*/
join mdf4 where mdf4.item_id = md.item_id
    and mdf4.flex_type_cd = value(uar_get_code_by("MEANING", 4062, "SYSPKGTYP"))
    and mdf4.sequence = 0
join mfoi4 where mfoi4.med_def_flex_id = mdf4.med_def_flex_id
    and mfoi4.active_ind = 1
    and mfoi4.parent_entity_name = "MED_DISPENSE"
    and mfoi4.flex_object_type_cd = value(uar_get_code_by("MEANING", 4063, "DISPENSE"))
join mdi where mdi.med_dispense_id = mfoi4.parent_entity_id
order by mi.value_key
    , mis.sequence
