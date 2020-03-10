/*
pharmnet_therapeutic_substitution.sql
~~~~~~~~~~~~~~~~~~~~
Therapeutic substitution rows (with from- and to-)
*/
select facility = uar_get_code_display(f.facility_cd)
    , venue = uar_get_code_display(f.venue_cd)
    , substitution_action = if(f.sbsttn_actn_flag = 0) "Optional"
        elseif(f.sbsttn_actn_flag = 1) "Required"
        elseif(f.sbsttn_actn_flag = 2) "Required, Silent"
        endif
    , f.retain_details_ind
    , from_primary = uar_get_code_display(f.from_catalog_cd)
    , from_synonym = ocs.mnemonic
    , from_synonym_type = uar_get_code_display(ocs.mnemonic_type_cd)
    , from_pharmnet_desc = mi.value
    , from_route = uar_get_code_display(f.from_rte_cd)
    , from_freq = uar_get_code_display(f.from_freq_cd)
    , from_dose = 
        if (f.from_volume_unit_cd > 0) 
            concat(trim(cnvtstring(f.from_volume_value)), ' ', 
                    uar_get_code_display(f.from_volume_unit_cd))
        else concat(trim(cnvtstring(f.from_strength_value)), ' ', 
                    uar_get_code_display(f.from_strength_unit_cd))
        endif
    , substitution_comment_text = trim(lt.long_text)
    , to_primary = uar_get_code_display(t.to_catalog_cd)
    , to_synonym = ocs2.mnemonic
    , to_synonym_type = uar_get_code_display(ocs2.mnemonic_type_cd)
    , to_pharmnet_desc = mi2.value
    , to_route = uar_get_code_display(t.to_rte_cd)
    , to_freq = uar_get_code_display(t.to_freq_cd)
    , to_dose = 
        if (t.to_volume_unit_cd > 0) 
            concat(trim(cnvtstring(t.to_volume_value)), ' ', 
                    uar_get_code_display(t.to_volume_unit_cd))
        else concat(trim(cnvtstring(t.to_strength_value)), ' ', 
                    uar_get_code_display(t.to_strength_unit_cd))
        endif
from rx_therap_sbsttn_from f
    , order_catalog_synonym ocs
    , med_identifier mi
    , rx_therap_sbsttn_to t
    , long_text lt
    , order_catalog_synonym ocs2
    , med_identifier mi2
plan f where f.active_ind = 1
    and f.begin_effective_dt_tm < sysdate
    and f.end_effective_dt_tm > sysdate
join ocs where ocs.synonym_id = outerjoin(f.from_synonym_id)
join mi where mi.item_id = outerjoin(f.from_item_id)
    and mi.active_ind = outerjoin(1)
    and mi.primary_ind = outerjoin(1)
    and mi.med_product_id = outerjoin(0)
    and mi.med_identifier_type_cd = outerjoin(
        value(uar_get_code_by("MEANING", 11000, "DESC")))
join lt where lt.long_text_id = f.comment_long_text_id
join t where t.therap_sbsttn_from_id = f.therap_sbsttn_from_id
    and t.active_ind = 1
join ocs2 where ocs2.synonym_id = outerjoin(t.to_synonym_id)
join mi2 where mi2.item_id = outerjoin(t.to_item_id)
    and mi2.active_ind = outerjoin(1)
    and mi2.primary_ind = outerjoin(1)
    and mi2.med_product_id = outerjoin(0)
    and mi2.med_identifier_type_cd = outerjoin(
        value(uar_get_code_by("MEANING", 11000, "DESC")))
order by uar_get_code_display(f.facility_cd)
    , uar_get_code_display(f.venue_cd)
    , uar_get_code_display(f.from_catalog_cd)
    , ocs.mnemonic
    , mi.value
    , uar_get_code_display(f.from_rte_cd)
    , uar_get_code_display(f.from_freq_cd)
with uar_code(d)