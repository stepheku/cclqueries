/*
form_form_compatibility.sql
~~~~~~~~~~~~~~~~~~~~
Grabs dose form compatibility. This is typically used with conversions between
inpatient and outpatient venues
*/
select child_value = cv1.display
    , parent_value = cv2.display
    , cvg.collation_seq
from code_value_group cvg
    , code_value cv1
    , code_value cv2
plan cvg
join cv1 where cv1.code_set = 4002
    and cv1.code_value = cvg.child_code_value
    and cv1.active_ind = 1
join cv2 where cv2.code_set = 2
    and cv2.code_value = cvg.parent_code_value
    and cv2.active_ind = 1