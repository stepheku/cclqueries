/*
units_of_measure.sql
~~~~~~~~~~~~~~~~~~~~
Units of measure, set in PhaDbTools
*/
select c.code_set
	, c.code_value
	, c.display
	, c.description
    , strength = btest(cnvtint(cve.field_value), 0)
    , volume = btest(cnvtint(cve.field_value), 1)
    , quantity = btest(cnvtint(cve.field_value), 2)
    , duration = btest(cnvtint(cve.field_value), 3)
    , rate = btest(cnvtint(cve.field_value), 4)
    , normalized = btest(cnvtint(cve.field_value), 5)
    , documentation_dose_rate = btest(cnvtint(cve.field_value), 6)
from code_value c
    , code_value_extension cve
plan c where c.code_set = 54
    and c.active_ind = 1
join cve where cve.code_value = c.code_value
order by c.display_key
