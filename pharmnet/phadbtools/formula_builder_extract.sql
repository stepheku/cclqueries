/*
formula_builder_extract.sql
~~~~~~~~~~~~~~~~~~~~
Extracts all available formulas in Formula Builder
*/

select method = uar_get_code_display(rm.method_cd)
    , rf.formula_txt
    , rf.rx_formula_id
    , usable_results_min = rmr5.min_value
    , usable_results_max = rmr5.max_value
    , usable_results_uom = uar_get_code_display(rmr5.value_uom_cd)
    , demog_age_min = rmr1.min_value
    , demog_age_max = rmr1.max_value
    , demog_age_uom = uar_get_code_display(rmr1.value_uom_cd)
    , demog_height_min = rmr2.min_value
    , demog_height_max = rmr2.max_value
    , demog_height_uom = uar_get_code_display(rmr2.value_uom_cd)
    , demog_weight_min = rmr3.min_value
    , demog_weight_max = rmr3.max_value
    , demog_weight_uom = uar_get_code_display(rmr3.value_uom_cd)
    , demog_scr_min = rmr4.min_value
    , demog_scr_max = rmr4.max_value
    , demog_scr_uom = uar_get_code_display(rmr4.value_uom_cd)
    , ethnicity = uar_get_code_display(rfr7.ethnicity_cd)
    , race = uar_get_code_display(rfr6.race_cd)
    , gender = uar_get_code_display(rfr5.gender_cd)
	, age = if (rfr1.min_value > 0 or rfr1.max_value > 0)
				if (rfr1.operator_flag = 1) 
					concat("Less than ", trim(cnvtstring(rfr1.max_value)), " "
							, trim(uar_get_code_display(rfr1.value_uom_cd)))
				elseif (rfr1.operator_flag = 2)
					concat("Between ", trim(cnvtstring(rfr1.min_value)), " "
							, trim(uar_get_code_display(rfr1.value_uom_cd))
							, " and "
							, trim(cnvtstring(rfr1.max_value)), " "
							, trim(uar_get_code_display(rfr1.value_uom_cd)))
				elseif (rfr1.operator_flag = 3)
					concat("Greater than or equal to ", trim(cnvtstring(rfr1.min_value)), " "
							, trim(uar_get_code_display(rfr1.value_uom_cd)))
				endif
			endif
	, height = if (rfr2.min_value > 0 or rfr2.max_value > 0)
				if (rfr2.operator_flag = 1) 
					concat("Less than ", trim(cnvtstring(rfr2.max_value)), " "
							, trim(uar_get_code_display(rfr2.value_uom_cd)))
				elseif (rfr2.operator_flag = 2)
					concat("Between ", trim(cnvtstring(rfr2.min_value)), " "
							, trim(uar_get_code_display(rfr2.value_uom_cd))
							, " and "
							, trim(cnvtstring(rfr2.max_value)), " "
							, trim(uar_get_code_display(rfr2.value_uom_cd)))
				elseif (rfr2.operator_flag = 3)
					concat("Greater than or equal to ", trim(cnvtstring(rfr2.min_value)), " "
							, trim(uar_get_code_display(rfr2.value_uom_cd)))
				endif
			endif
	, weight_ratio = if (rfr3.min_value > 0 or rfr3.max_value > 0)
				if (rfr3.operator_flag = 1) 
					concat("Less than ", trim(cnvtstring(rfr3.max_value)), " "
							, trim(uar_get_code_display(rfr3.value_uom_cd)))
				elseif (rfr3.operator_flag = 2)
					concat("Between ", trim(cnvtstring(rfr3.min_value)), " "
							, trim(uar_get_code_display(rfr3.value_uom_cd))
							, " and "
							, trim(cnvtstring(rfr3.max_value)), " "
							, trim(uar_get_code_display(rfr3.value_uom_cd)))
				elseif (rfr3.operator_flag = 3)
					concat("Greater than or equal to ", trim(cnvtstring(rfr3.min_value)), " "
							, trim(uar_get_code_display(rfr3.value_uom_cd)))
				endif
			endif
	, scr = if (rfr4.min_value > 0 or rfr4.max_value > 0)
				if (rfr4.operator_flag = 1) 
					concat("Less than ", trim(cnvtstring(rfr4.max_value)), " "
							, trim(uar_get_code_display(rfr4.value_uom_cd)))
				elseif (rfr4.operator_flag = 2)
					concat("Between ", trim(cnvtstring(rfr4.min_value)), " "
							, trim(uar_get_code_display(rfr4.value_uom_cd))
							, " and "
							, trim(cnvtstring(rfr4.max_value)), " "
							, trim(uar_get_code_display(rfr4.value_uom_cd)))
				elseif (rfr4.operator_flag = 3)
					concat("Greater than or equal to ", trim(cnvtstring(rfr4.min_value)), " "
							, trim(uar_get_code_display(rfr4.value_uom_cd)))
				endif
			endif
from rx_formula rf
    , rx_formula_range rfr1 /*Age*/
    , rx_formula_range rfr2 /*Height*/
    , rx_formula_range rfr3 /*Weight Ratio*/
    , rx_formula_range rfr4 /*Serum Creatinine*/
    , rx_formula_range rfr5 /*Gender*/
    , rx_formula_range rfr6 /*Race*/
    , rx_formula_range rfr7 /*Ethnicity*/
    , rx_formula_range rfr8 /*Default Percent*/
    , rx_method rm
    , rx_method_range rmr1 /*Age*/
    , rx_method_range rmr2 /*Height*/
    , rx_method_range rmr3 /*Weight*/
    , rx_method_range rmr4 /*Serum Creatinine*/
    , rx_method_range rmr5 /*Result*/
plan rf where rf.active_ind = 1
    and rf.end_effective_dt_tm > sysdate
join rfr1 where rfr1.rx_formula_id = outerjoin(rf.rx_formula_id)
    and rfr1.active_ind = outerjoin(1)
    and rfr1.end_effective_dt_tm > outerjoin(sysdate)
    and rfr1.demog_type_flag = outerjoin(1) /*Age*/
join rfr2 where rfr2.rx_formula_id = outerjoin(rf.rx_formula_id)
    and rfr2.active_ind = outerjoin(1)
    and rfr2.end_effective_dt_tm > outerjoin(sysdate)
    and rfr2.demog_type_flag = outerjoin(2) /*Height*/
join rfr3 where rfr3.rx_formula_id = outerjoin(rf.rx_formula_id)
    and rfr3.active_ind = outerjoin(1)
    and rfr3.end_effective_dt_tm > outerjoin(sysdate)
    and rfr3.demog_type_flag = outerjoin(3) /*Weight Ratio*/
join rfr4 where rfr4.rx_formula_id = outerjoin(rf.rx_formula_id)
    and rfr4.active_ind = outerjoin(1)
    and rfr4.end_effective_dt_tm > outerjoin(sysdate)
    and rfr4.demog_type_flag = outerjoin(4) /*Serum Creatinine*/
join rfr5 where rfr5.rx_formula_id = outerjoin(rf.rx_formula_id)
    and rfr5.active_ind = outerjoin(1)
    and rfr5.end_effective_dt_tm > outerjoin(sysdate)
    and rfr5.demog_type_flag = outerjoin(5) /*Gender*/
join rfr6 where rfr6.rx_formula_id = outerjoin(rf.rx_formula_id)
    and rfr6.active_ind = outerjoin(1)
    and rfr6.end_effective_dt_tm > outerjoin(sysdate)
    and rfr6.demog_type_flag = outerjoin(6) /*Race*/
join rfr7 where rfr7.rx_formula_id = outerjoin(rf.rx_formula_id)
    and rfr7.active_ind = outerjoin(1)
    and rfr7.end_effective_dt_tm > outerjoin(sysdate)
    and rfr7.demog_type_flag = outerjoin(7) /*Ethnicity*/
join rfr8 where rfr8.rx_formula_id = outerjoin(rf.rx_formula_id)
    and rfr8.active_ind = outerjoin(1)
    and rfr8.end_effective_dt_tm > outerjoin(sysdate)
    and rfr8.demog_type_flag = outerjoin(8) /*Default Percent*/

join rm where rm.rx_method_id = rf.rx_method_id
    and rm.active_ind = 1
    and rm.end_effective_dt_tm > sysdate
join rmr1 where rmr1.rx_method_id = outerjoin(rm.rx_method_id)
    and rmr1.active_ind = outerjoin(1)
    and rmr1.end_effective_dt_tm > outerjoin(sysdate)
    and rmr1.demog_type_flag = outerjoin(1) /*Age*/
join rmr2 where rmr2.rx_method_id = outerjoin(rm.rx_method_id)
    and rmr2.active_ind = outerjoin(1)
    and rmr2.end_effective_dt_tm > outerjoin(sysdate)
    and rmr2.demog_type_flag = outerjoin(2) /*Height*/
join rmr3 where rmr3.rx_method_id = outerjoin(rm.rx_method_id)
    and rmr3.active_ind = outerjoin(1)
    and rmr3.end_effective_dt_tm > outerjoin(sysdate)
    and rmr3.demog_type_flag = outerjoin(3) /*Weight*/
join rmr4 where rmr4.rx_method_id = outerjoin(rm.rx_method_id)
    and rmr4.active_ind = outerjoin(1)
    and rmr4.end_effective_dt_tm > outerjoin(sysdate)
    and rmr4.demog_type_flag = outerjoin(4) /*Serum Creatinine*/
join rmr5 where rmr5.rx_method_id = outerjoin(rm.rx_method_id)
    and rmr5.active_ind = outerjoin(1)
    and rmr5.end_effective_dt_tm > outerjoin(sysdate)
    and rmr5.demog_type_flag = outerjoin(5) /*Result*/
order by rm.method_cd
    , rf.rx_formula_id