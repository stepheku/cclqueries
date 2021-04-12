/*
powertrials_user_roles.sql
~~~~~~~~~~~~~~~~~~~~
Gets user roles for PowerTrials protocols
*/
select user = p.name_full_formatted
    , position = uar_get_code_display(pr.position_cd)
    , protocol_name = pm.primary_mnemonic
    , role = uar_get_code_display(pr.prot_role_cd)
    , role_type = uar_get_code_display(pr.prot_role_type_cd)
from prot_role pr
    , prsnl p
    , prot_amendment pa
    , prot_master pm
plan pr where (pr.person_id != 0 or pr.position_cd != 0)
join p where p.person_id = pr.person_id
join pa where pa.prot_amendment_id = pr.prot_amendment_id
join pm where pm.prot_master_id = pa.prot_master_id
order by pm.primary_mnemonic_key
    , p.name_full_formatted
with uar_code(d)