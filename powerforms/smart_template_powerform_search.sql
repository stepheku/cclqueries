/*
smart_template_powerform_search.sql
~~~~~~~~~~~~~~~~~~~~
Searches for a smart template program usage within PowerForms
*/

select form = dfr.description  
    , section = dsr.description  
    , template = cv1.definition
    , read_only = nvp3.pvc_value
    , dta = dta.description
    , event_code = uar_get_code_display(dta.event_cd)

from code_value cv1  
    , name_value_prefs nvp  
    , dcp_input_ref dir  
    , dcp_section_ref dsr  
    , dcp_forms_def dfd  
    , dcp_forms_ref dfr  
    , name_value_prefs nvp2
    , name_value_prefs nvp3
    , discrete_task_assay dta

plan cv1 where cv1.code_set = 16529  
    and cv1.active_ind = 1  
    and cv1.begin_effective_dt_tm <= cnvtdatetime(curdate, curtime3)  
    and cv1.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)  
    /*Smart template program name*/
    and cnvtlower(cv1.definition) = "smart_template_program_name"

join nvp where nvp.merge_id = cv1.code_value  
    and nvp.merge_name = "CODE_VALUE"  
    and nvp.pvc_name = "template_cd"  
    and nvp.active_ind = 1  

join dir where dir.dcp_input_ref_id = nvp.parent_entity_id  
    and dir.active_ind = 1  

join nvp2 where nvp2.parent_entity_id = dir.dcp_input_ref_id
    and nvp2.active_ind = 1
    and nvp2.pvc_name = 'discrete_task_assay'

join dta where dta.task_assay_cd = nvp2.merge_id

join nvp3 where nvp3.parent_entity_id = dir.dcp_input_ref_id
    and nvp3.active_ind = 1
    and nvp3.pvc_name = "read_only"

join dsr where dsr.dcp_section_ref_id = dir.dcp_section_ref_id  
    and dsr.dcp_section_instance_id = dir.dcp_section_instance_id  
    and dsr.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)  
    and dsr.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)  

join dfd where dfd.dcp_section_ref_id = dsr.dcp_section_ref_id  
    and dfd.active_ind = 1  

join dfr where dfr.dcp_forms_ref_id = dfd.dcp_forms_ref_id  
    and dfr.dcp_form_instance_id = dfd.dcp_form_instance_id  
    and dfr.active_ind = 1  
    and dfr.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)  
    and dfr.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)  

order by  
    dfr.description  
    , dsr.description  
    , cv1.definition  

with format(date, "mm/dd/yyyy hh:mm:ss;;q")  
