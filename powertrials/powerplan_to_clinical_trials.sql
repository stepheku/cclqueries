/*
powerplan_to_clinical_trials.sql
~~~~~~~~~~~~~~~~~~~~
Extracts settings set in "Link Plans to Clinical Trials/Studies"
window of the PowerPlan tool, displays PowerPlan, linked Clinical Trial
and additional settings
*/

select clinical_trial = pm.primary_mnemonic
    , powerplan = pc.description
    , minimum_enrollment = 
        if (p.minimum_enrollment_status_flag = 0) "None"
        elseif (p.minimum_enrollment_status_flag = 1) "Consent Pending"
        elseif (p.minimum_enrollment_status_flag = 2) "Enrolled"
        endif
    , ordering_policy = 
        if (p.ordering_policy_flag = 0) "No Action"
        elseif (p.ordering_policy_flag = 1) "Warn - Consent Pending"
        elseif (p.ordering_policy_flag = 2) "Warn"
        elseif (p.ordering_policy_flag = 3) "Stop"
        endif
    , p.require_override_reason_ind
from pw_pt_reltn p
    , pathway_catalog pc
    , prot_master pm
plan p where p.active_ind = 1
    and p.end_effective_dt_tm > sysdate
join pc where pc.pathway_catalog_id = p.pathway_catalog_id
    and pc.active_ind = 1
    and pc.end_effective_dt_tm > sysdate
    and pc.beg_effective_dt_tm < sysdate
join pm where pm.prot_master_id = p.prot_master_id
with uar_code(d)