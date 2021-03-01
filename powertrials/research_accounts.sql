/*
research_accounts.sql
~~~~~~~~~~~~~~~~~~~~
Grabs active research accounts that would be used to populate order entry
field "Research Account"
*/
select ra.*
from research_account ra
plan ra where ra.active_ind = 1
    and ra.end_effective_dt_tm > sysdate
order by ra.description
with uar_code(d)