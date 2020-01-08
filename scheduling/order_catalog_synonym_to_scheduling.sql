/*
order_catalog_synonym_to_scheduling.sql
~~~~~~~~~~~~~~~~~~~~
Grabs order catalog synonyms that are linked to a scheduling
appointment type
*/

select primary = oc.primary_mnemonic
    , synonym = ocs.mnemonic
    , synonym_oef = oef1.oe_format_name
    , s.synonym_id
    , appt_type = uar_get_code_display(s.appt_type_cd)
    , appt_oef = oef2.oe_format_name
from sch_appt_ord s
    , sch_appt_type sat
    , order_catalog_synonym ocs
    , order_catalog oc
    , order_entry_format oef1
    , order_entry_format oef2
plan s where s.active_ind = 1
    and s.end_effective_dt_tm > sysdate
    and s.version_dt_tm > sysdate
join sat where sat.appt_type_cd = s.appt_type_cd
    and sat.active_ind = 1
join ocs where ocs.synonym_id = s.synonym_id
    and ocs.active_ind = 1
join oc where oc.catalog_cd = ocs.catalog_cd
    and oc.active_ind = 1
    and oc.schedule_ind = 1
join oef1 where oef1.oe_format_id = outerjoin(ocs.oe_format_id)
    and oef1.action_type_cd = outerjoin(value(uar_get_code_by("MEANING", 6003, "ORDER")))
join oef2 where oef2.oe_format_id = outerjoin(sat.oe_format_id)
    and oef2.action_type_cd = outerjoin(value(uar_get_code_by("MEANING", 14232, "APPOINTMENT")))
order by oc.primary_mnemonic
    , ocs.mnemonic_key_cap
with format(date, "mm/dd/yyyy hh:mm:ss"), uar_code(d)
