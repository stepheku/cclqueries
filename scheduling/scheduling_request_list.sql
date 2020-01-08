/*
scheduling_request_list.sql
~~~
Grabs all of the items that are in the request list of SchApptBook
*/
select pt = p.name_full_formatted
    , se.sch_event_id
    , sea.sch_action_id
    , action = uar_get_code_display(sea.req_action_cd)
    , appointment_type = uar_get_code_display(se.appt_type_cd)
    , o.ordered_as_mnemonic
    , sen.request_made_dt_tm
    , sen.beg_effective_dt_tm
    , request_start_dt_tm = sed1.oe_field_dt_tm_value
    , special_instructions = sed2.oe_field_display_value
    , reason_for_exam = sed3.oe_field_display_value
    , scheduling_ordering_physician = sed4.oe_field_display_value
    , scheduling_order_type = sed5.oe_field_display_value
    , powerplan_activity = sed6.oe_field_display_value
    , powerplan_scheduled_phase = sed7.oe_field_display_value
    , sch_onc_priority = sed8.oe_field_display_value
from sch_event se
    , sch_event_patient sep
    , sch_event_detail sed1
    , sch_event_detail sed2
    , sch_event_detail sed3
    , sch_event_detail sed4
    , sch_event_detail sed5
    , sch_event_detail sed6
    , sch_event_detail sed7
    , sch_event_detail sed8
    , person p
    , sch_entry sen
    , sch_event_action sea
    , sch_event_attach seat
    , orders o
    , sch_action_loc sal
    , code_value cv
plan se where se.sch_state_cd = value(uar_get_code_by("MEANING", 14233, "REQUEST"))
    and se.active_ind = 1
    and se.end_effective_dt_tm > sysdate
    and se.version_dt_tm > sysdate
;    and se.appt_type_cd in (
;        select cv.code_value
;        from code_value cv
;        where cv.code_set = 14230
;            and cv.active_ind = 1
;            and cv.display_key like '*CHEMO*'
;        )
join sep where sep.sch_event_id = se.sch_event_id
    and sep.version_dt_tm > sysdate
join p where p.person_id = sep.person_id
    and p.active_ind = 1
    and p.end_effective_dt_tm > sysdate
join sen where sen.sch_event_id = se.sch_event_id
join seat where seat.sch_event_id = outerjoin(se.sch_event_id)
    and seat.active_ind = outerjoin(1)
    and seat.end_effective_dt_tm > outerjoin(sysdate)
    and seat.version_dt_tm > outerjoin(sysdate)
join o where o.order_id = outerjoin(seat.order_id)
/*Requested Start Date/Time*/
join sed1 where sed1.sch_event_id = outerjoin(se.sch_event_id)
    and sed1.version_dt_tm > outerjoin(sysdate)
    and sed1.oe_field_id = outerjoin(value(uar_get_code_by_cki("CKI.CODEVALUE!1301371")))

/*Special Instructions*/
join sed2 where sed2.sch_event_id = outerjoin(se.sch_event_id)
    and sed2.version_dt_tm > outerjoin(sysdate)
    and sed2.oe_field_id = outerjoin(value(uar_get_code_by_cki("CKI.CODEVALUE!1301414")))

/*Reason For Exam*/
join sed3 where sed3.sch_event_id = outerjoin(se.sch_event_id)
    and sed3.version_dt_tm > outerjoin(sysdate)
    and sed3.oe_field_id = outerjoin(value(uar_get_code_by_cki("CKI.CODEVALUE!1301432"))) 

/*Scheduling Ordering Physician*/
join sed4 where sed4.sch_event_id = outerjoin(se.sch_event_id)
    and sed4.version_dt_tm > outerjoin(sysdate)
    and sed4.oe_field_id = outerjoin(value(uar_get_code_by_cki("CKI.CODEVALUE!1306686")))

/*Scheduling Order Type*/
join sed5 where sed5.sch_event_id = outerjoin(se.sch_event_id)
    and sed5.version_dt_tm > outerjoin(sysdate)
    and sed5.oe_field_id = outerjoin(value(uar_get_code_by_cki("CKI.CODEVALUE!1306687")))

/*PowerPlan Activity*/
join sed6 where sed6.sch_event_id = outerjoin(se.sch_event_id)
    and sed6.version_dt_tm > outerjoin(sysdate)
    and sed6.oe_field_id = outerjoin(value(uar_get_code_by("DISPLAY_KEY", 16449, "POWERPLANACTIVITY"))) 

/*PowerPlan Scheduled Phase*/
join sed7 where sed7.sch_event_id = outerjoin(se.sch_event_id)
    and sed7.version_dt_tm > outerjoin(sysdate)
    and sed7.oe_field_id = outerjoin(value(uar_get_code_by("DISPLAY_KEY", 16449, "POWERPLANSCHEDULEDPHASE"))) 

/*Sch Onc Priority*/
join sed8 where sed8.sch_event_id = outerjoin(se.sch_event_id)
    and sed8.version_dt_tm > outerjoin(sysdate)
    and sed8.oe_field_id = outerjoin(value(uar_get_code_by("DISPLAY_KEY", 16449, "SCHONCPRIORITY")))
join sea where sea.sch_event_id = se.sch_event_id
join sal where sal.sch_action_id = sea.sch_action_id
    and sal.beg_effective_dt_tm < sysdate
    and sal.end_effective_dt_tm > sysdate
    and sal.version_dt_tm > sysdate
    and sal.location_cd in (
        select cv.code_value
        from code_value cv
        where cv.code_set = 220
            and cv.active_ind = 1
            and cv.end_effective_dt_tm > sysdate
            ;and cv.display_key like '*LOCATION HERE IN CAPS*'
        )
join cv where cv.code_value = se.appt_synonym_cd
/*Obsoleted appt_synonym_cd seems to delete the code_value completely
instead of inactivating, this is why the code_value table is being joined*/
with uar_code(d), format(date, "mm/dd/yyyy hh:mm:ss")