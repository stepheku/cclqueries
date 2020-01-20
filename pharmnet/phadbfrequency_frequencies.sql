/*
phadbfrequency_frequencies.sql
~~~~~~~~~~~~~~~~~~~~
Frequencies that have been built out in PhaDBFreq
*/

select frequency = uar_get_code_display(f.frequency_cd)
    , activity_type = uar_get_code_display(f.activity_type_cd)
    , oc.primary_mnemonic
    , frequency_type = 
        if (f.frequency_type = 1) "Time of day"
        elseif (f.frequency_type = 2) "Day of week"
        elseif (f.frequency_type = 3) "Interval"
        elseif (f.frequency_type = 4) "One time"
        elseif (f.frequency_type = 5) "Unscheduled"
        endif
    , time_of_day = 
        if (tod.time_of_day > 0)
        format(cnvtlookahead(
            concat("{", trim(cnvtstring(tod.time_of_day)), ", MIN}"),
            cnvtdatetime(curdate, 0)), "hh:mm;;m")
        endif
    , day_of_week = 
        if (dow.day_of_week = 1) "Sunday"
        elseif (dow.day_of_week = 2) "Monday"
        elseif (dow.day_of_week = 3) "Tuesday"
        elseif (dow.day_of_week = 4) "Wednesday"
        elseif (dow.day_of_week = 5) "Thursday"
        elseif (dow.day_of_week = 6) "Friday"
        elseif (dow.day_of_week = 7) "Saturday"
        endif
    , interval = 
        if (f.frequency_type = 3)
        	concat(trim(cnvtstring(f.interval)), 
            if (f.interval_units = 1) " Minutes"
            elseif (f.interval_units = 2) " Hours"
            elseif (f.interval_units = 3) " Days"
            endif )
        endif
    , round_to = 
        if (f.round_to > 0)
            concat(trim(cnvtstring(f.round_to)), " minute(s)")
        endif
    , min_interval = f.min_interval_nbr
    , min_interval_unit = uar_get_code_display(f.min_interval_unit_cd)
    , f.min_event_per_day
    , f.max_event_per_day
    , start_time_assign = 
        if(f.first_dose_method = 1) "Current time"
        elseif(f.first_dose_method = 2) "Next time"
        elseif(f.first_dose_method = 3) "Previous time"
        elseif(f.first_dose_method = 4) "Closest time"
        elseif(f.first_dose_method = 5) "Next, if within"
        endif
	, next_within = 
		if (f.first_dose_method = 5 and f.first_dose_range > 0)
			concat(trim(cnvtstring(f.first_dose_range)), 
			if (f.first_dose_range_units = 1) " minutes"
			elseif (f.first_dose_range_units = 2) " hrs"
			elseif (f.first_dose_range_units = 3) " days"
			elseif (f.first_dose_range_units = 4) " weeks"
			endif )
		endif
from frequency_schedule f
    , order_catalog oc
    , scheduled_time_of_day tod
    , scheduled_day_of_week dow
plan f where f.active_ind = 1
    and f.parent_entity != 'ORDERS'
join oc where oc.catalog_cd = outerjoin(f.parent_entity_id)
    and oc.active_ind = outerjoin(1)
join tod where tod.activity_type_cd = outerjoin(f.activity_type_cd)
    and tod.frequency_cd = outerjoin(f.frequency_cd)
    and tod.freq_qualifier = outerjoin(f.freq_qualifier)
    and tod.parent_entity = outerjoin(f.parent_entity)
    and tod.parent_entity_id = outerjoin(f.parent_entity_id)
    and tod.facility_cd = outerjoin(f.facility_cd)
join dow where dow.activity_type_cd = outerjoin(f.activity_type_cd)
    and dow.frequency_cd = outerjoin(f.frequency_cd)
    and dow.freq_qualifier = outerjoin(f.freq_qualifier)
    and dow.parent_entity = outerjoin(f.parent_entity)
    and dow.parent_entity_id = outerjoin(f.parent_entity_id)
    and dow.facility_cd = outerjoin(f.facility_cd)
order by uar_get_code_display(f.frequency_cd)
    , uar_get_code_display(f.activity_type_cd)
    , cnvtupper(oc.primary_mnemonic)
    , dow.day_of_week
    , tod.time_of_day
with format(date, "mm/dd/yyyy hh:mm:ss")