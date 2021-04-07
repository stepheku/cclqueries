/*
reg_custom_worklists.sql
~~~~~~~~~~~~~~~~~~~~
Grabs custom built worklists in pmoffice
*/
select worklist = p.display
    , p.script
    , p.exec_script_ind
    , exec_script = trim(lt.long_text)
from pm_que_work_list p
    , long_text_reference lt
plan p where ;p.display_key like "*REFERRAL*ENCOUNTER*"
    p.active_ind = 1
    and p.beg_effective_dt_tm < sysdate
    and p.end_effective_dt_tm > sysdate
join lt where lt.long_text_id = outerjoin(p.exec_script_long_text_id)
order by p.display_key
with time = 60, uar_code(d)