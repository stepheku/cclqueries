/*
dispense_category_print_location.sql
~~~~~~~~~~~~~~~~~~~~
This query identifies all relationships with the dispense category, 
location and printer for the associated location
*/
select dispense_category = uar_get_code_display(d.dispense_category_cd)
	, pharmacy = uar_get_code_display(d.code_value)
	, label_printer = d1.name
	, report_printer = d2.name
from 
(	(SELECT
		dc.dispense_category_cd
		, cv1.display_key
		, cv2.code_value
	FROM dispense_category dc
		, code_value cv1
		, code_value cv2
	where cv1.code_value = dc.dispense_category_cd
		and cv1.active_ind = 1
		and cv2.active_ind = 1
		and cv2.cdf_meaning = 'PHARM'
		and cv2.code_value != 798 ; Block code_value "Pharmacy(s)", maybe a placeholder
	WITH SQLTYPE("F8","VC40","F8")) D
	)
	, rx_printer_location_r   r
	, device d1
	, device d2
plan d
join r where r.dispense_category_cd = outerjoin(d.dispense_category_cd)
	and r.location_cd = outerjoin(d.code_value)
join d1 where d1.device_cd = outerjoin(r.device_cd)
join d2 where d2.device_cd = outerjoin(r.trans_notify_device_cd)
order by d.display_key, d.code_value
