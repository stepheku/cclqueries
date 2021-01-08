/*
administered_immunizations_query.sql
~~~~~~~~~~~~~~~~~~~~
Identifies patients who have been administered an 
immunization (either on the MAR or documented in the Immunization Record)
*/
select pt = p.name_full_formatted
    , event = uar_get_code_description(ce.event_cd)
    , oc.primary_mnemonic
    , ce.performed_dt_tm
    , cmr.substance_exp_dt_tm
    , cmr.substance_lot_number
    , manufacturer = uar_get_code_display(cmr.substance_manufacturer_cd)
from order_catalog oc
    , code_value_extension cve
    , clinical_event ce
    , person p
    , ce_med_result cmr
plan oc where oc.active_ind = 1
join cve where cve.code_value = oc.catalog_cd
    and cve.code_set = 200
    and cve.field_name = "IMMUNIZATIONIND"
    and cve.field_value = "1"
join ce where ce.catalog_cd = oc.catalog_cd
    and ce.result_status_cd in (
		value(uar_get_code_by("MEANING", 8, "AUTH"))
		, value(uar_get_code_by("MEANING", 8, "MODIFIED"))
	)
    and ce.event_class_cd in (
        value(uar_get_code_by("MEANING", 53, "IMMUN"))
        , value(uar_get_code_by("MEANING", 53, "MED"))
    )
    and ce.performed_dt_tm > cnvtdatetime(curdate-30, 0)
join cmr where cmr.event_id = ce.event_id
join p where p.person_id = ce.person_id
with uar_code(d), format(date, ";;q")