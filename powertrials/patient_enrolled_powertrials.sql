/*
patient_enrolled_powertrials.sql
~~~~~~~~~~~~~~~~~~~~
Identifies patients enrolled in PowerTrials
*/
select pt = p.name_full_formatted
    , protocol = pm.primary_mnemonic
    , enrollment_id = ppr.prot_accession_nbr
    , pa.amendment_nbr
    , pa.amendment_dt_tm
from pt_prot_reg ppr
    , prot_master pm
    , person p
    , prot_role pr
    , prot_amendment pa
plan pm where pm.end_effective_dt_tm > sysdate
    and pm.prot_master_id != 0
    and pm.end_effective_dt_tm > sysdate
join ppr where ppr.prot_master_id = pm.prot_master_id
    and ppr.end_effective_dt_tm > sysdate
    and ppr.off_study_dt_tm > sysdate
join p where p.person_id = ppr.person_id
join pa where pa.prot_master_id = pm.prot_master_id
    and pa.amendment_dt_tm < CNVTDATETIME("31-DEC-2100 00:00:00")
join pr where pr.prot_amendment_id = pa.prot_amendment_id
    and pr.end_effective_dt_tm > sysdate
    and pr.prot_role_cd = value(uar_get_code_by("MEANING", 17441, "PRIMARY"))
    and pr.primary_contact_ind = 1
order by p.name_full_formatted
    , pm.primary_mnemonic_key
with uar_code(d)