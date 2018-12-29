/*
Record structures and the report writer section

The purpose of this program is to learn about using record structures,
populating them and the report writer section

Dosage Calculator audit information is stored in the database as an XML
string. The string is extractable but not normally parse-able

The goal is to look for all pharmacy orders beyond a certain date using 
a query, then populating the record structure temp_1 with the order_id 
and dose_calc_xml

Then, we loop through the orders list in the record structure to use the
cnvtxmltorec() function. This creates a new record structure each time called
DosageInformation. We can then use that record structure that is created to
populate final_dose and calculated_dose back to temp_1 

Finally, the temp_1 contents are written out into a report and displayed
in a spreadsheet view
*/

drop program 1_new_hire_exercise_3 go
create program 1_new_hire_exercise_3
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start date" = "CURDATE"               ;* Start date of orders

with OUTDEV, start_date

record temp_1 (
     1 orders[*]
          2 order_id = f8
		  2 dose_calc_xml = vc
		  2 final_dose = f8
		  2 calculated_dose = f8
	) 

declare cnt_ord = i4

select into "nl:"
from orders o
	, person p
	, order_ingredient oi
	, long_text lt
plan o where o.orig_order_dt_tm > cnvtdatetime($start_date)
	and o.product_id = 0
	and o.activity_type_cd = value(uar_get_code_by("MEANING", 106, "PHARMACY"))
	and o.order_status_cd != value(uar_get_code_by("MEANING", 6004, "DELETED"))
	and o.template_order_flag != 4
join oi where oi.order_id = o.order_id
	and oi.action_sequence = o.last_ingred_action_sequence
	and oi.dose_calculator_long_text_id != 0
join lt where lt.long_text_id = oi.dose_calculator_long_text_id
join p where p.person_id = o.person_id
	and p.active_ind = 1
	and p.end_effective_dt_tm > sysdate

head report
	stat = alterlist(temp_1->orders, 100)
	
detail
	cnt_ord = cnt_ord + 1 
	temp_1->orders[cnt_ord].order_id = o.order_id
	temp_1->orders[cnt_ord].dose_calc_xml = lt.long_text

foot report
	stat = alterlist(temp_1->orders, cnt_ord)

with nocounter, separator=" ", format

/*for-loop in the record structure under the orders list
and then use cnvtxmltorec outside the report writer section*/

for (xx = 1 to size(temp_1->orders, 5))
	set stat                               = cnvtxmltorec(temp_1->orders[xx].dose_calc_xml)
	set temp_1->orders[xx].final_dose      = DosageInformation->Dose[0].FinalDose
	set temp_1->orders[xx].calculated_dose = DosageInformation->Dose[0].CalculatedDose
	call echo(
		build(
			"For order_id: ",
			temp_1->orders[xx].order_id,
			", final_dose: ",
			temp_1->orders[xx].final_dose,
			", and calculate_dose: ",
			temp_1->orders[xx].calculated_dose
		)
	)
endfor

/*write into a report*/
select into $outdev
from
	(dummyt d with seq=value(size(temp_1->orders, 5)))
plan d

head report
	/*column header labels*/
	col 0 "order_id"
	col 100 "final_dose"
	col 200 "calculate_dose"

	/*line break*/
    row +1
detail
    /*populate variables that will go in as values*/
	order_id = temp_1->orders[d.seq].order_id
	final_dose = temp_1->orders[d.seq].final_dose
	calculate_dose = temp_1->orders[d.seq].calculated_dose

    /*write the values out*/
	col 0 order_id
	col 100 final_dose
	col 200 calculate_dose
	
    /*line break*/
    row +1
with nocounter, separator=" ", maxcol=1000

/*final select to send to spreadsheet view*/
select into "nl:" from dummyt d with nocounter

end
go
