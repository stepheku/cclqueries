/*
powertrials_active_protocols.sql
~~~~~~~~~~~~~~~~~~~~
Basic query that identifies currently active PowerTrials protocols
*/
select program_type = uar_get_code_display(pm.program_cd)
    , initiating_service = uar_get_code_display(pm.initiating_service_cd)
    , sub_initiating_service = uar_get_code_display(pm.sub_initiating_service_cd)
    , protocol_status = uar_get_code_display(pm.prot_status_cd)
    , protocol_type = uar_get_code_display(pm.prot_type_cd)
    , protocol_phase = uar_get_code_display(pm.prot_phase_cd)
    , protocol_name = pm.primary_mnemonic
from prot_master pm
plan pm where pm.end_effective_dt_tm > sysdate
    and pm.prot_master_id != 0
