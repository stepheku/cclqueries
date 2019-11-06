/*
position_priv_and_exceptions.sql
~~~~~~
This grabs the position-based privilege and exceptions
*/
select priv          = uar_get_code_display(p.privilege_cd)
    , position       = uar_get_code_display(pr.position_cd)
    , value          = uar_get_code_display(p.priv_value_cd)
    , exception_type = uar_get_code_display(pe.exception_type_cd)
    , exception      = uar_get_code_display(pe.exception_id)
from privilege p
    , priv_loc_reltn pr
    , privilege_exception pe
    , code_value pos
plan pos where pos.code_set = 88
    and pos.active_ind = 1
    and pos.end_effective_dt_tm > sysdate
join pr where pr.active_ind = 1
    and pr.position_cd = pos.code_value
join p where p.priv_loc_reltn_id = pr.priv_loc_reltn_id
join pe where pe.privilege_id = outerjoin(p.privilege_id)
order by position, priv
