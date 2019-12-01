/*
route_form_compatibility.sql
~~~~~~~~~~~~~~~~~~~~
Grabs route-dose form compatibility set in PhaDbTools
*/
select form = uar_get_code_display(r.form_cd)
    , route = uar_get_code_display(r.route_cd)
from route_form_r r
    , code_value cv1
    , code_value cv2
plan r
join cv1 where cv1.code_value = r.form_cd
    and cv1.active_ind = 1
    and cv1.code_set = 4002
join cv2 where cv2.code_value = r.route_cd
    and cv2.active_ind = 1
    and cv2.code_set = 4001