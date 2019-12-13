/*
route_form_compatibility.sql
~~~~~~~~~~~~~~~~~~~~
Grabs route-dose form compatibility set in PhaDbTools
*/
select form = uar_get_code_display(r.form_cd)
    , route = uar_get_code_display(r.route_cd)
    , med_ind = if (cve.field_value in ("1", "3", "5", "7")) 1 endif
    , intermittent_ind = if (cve.field_value in ("2", "3", "6", "7")) 1 endif
    , continuous_ind = if (cve.field_value in ("4", "5", "6", "7")) 1 endif
from route_form_r r
    , code_value cv1
    , code_value_extension cve
    , code_value cv2
plan r
join cv1 where cv1.code_value = r.form_cd
    and cv1.active_ind = 1
    and cv1.code_set = 4002
join cv2 where cv2.code_value = r.route_cd
    and cv2.active_ind = 1
    and cv2.code_set = 4001
join cve where cve.code_value = outerjoin(cv2.code_value)
    and cve.code_set = outerjoin(4001)
    and cve.field_name = outerjoin('ORDERED AS')
order by uar_get_code_display(r.route_cd)
