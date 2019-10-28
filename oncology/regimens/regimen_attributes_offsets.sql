/*
regimen_attributes_offsets.sql
~~~~~~~~~~~~~~~~~~~~
Identifies oncology-related regimens, the powerplans that are associated 
with each powerplan, their appearance and any offset values
*/

select regimen = rcs.synonym_display
    , description = trim(rc.regimen_description)
    , rc.extend_treatment_ind
    , rc.add_plan_ind
    , rcd.regimen_detail_sequence
    , component = 
        if (pc.pathway_catalog_id > 0) 
            if (rcd.cycle_nbr != 0 and (pc2.cycle_end_nbr = 0 and pc2.standard_cycle_nbr = 0)) 
                concat(trim(pc2.display_description), ' - Cycle ', trim(cnvtstring(rcd.cycle_nbr)))
            elseif (rcd.cycle_nbr != 0 and (pc2.cycle_end_nbr != 0 and pc2.standard_cycle_nbr != 0))
                concat(trim(pc2.display_description), ' - Cycle ', 
                       trim(cnvtstring(rcd.cycle_nbr)), ' of ', trim(cnvtstring(pc2.cycle_end_nbr)))
            else pc2.display_description /*No cycle number designated*/
            endif
        elseif (ltr.long_text_id > 0) trim(substring(0, 1024, ltr.long_text))
        endif
    , rcdr.offset_value
    , offset_unit = uar_get_code_display(rcdr.offset_unit_cd)
    , anchor_element = 
            if (rcd2.cycle_nbr != 0 and (pc4.cycle_end_nbr = 0 and pc4.standard_cycle_nbr = 0)) 
                concat(trim(pc4.display_description), ' - Cycle ', trim(cnvtstring(rcd2.cycle_nbr)))
            elseif (rcd2.cycle_nbr != 0 and (pc4.cycle_end_nbr != 0 and pc4.standard_cycle_nbr != 0))
                concat(trim(pc4.display_description), ' - Cycle ', 
                       trim(cnvtstring(rcd2.cycle_nbr)), ' of ', trim(cnvtstring(pc4.cycle_end_nbr)))
        else pc4.display_description /*No cycle number designated*/
        endif
from regimen_catalog rc
    , regimen_cat_synonym rcs
    , regimen_cat_detail rcd
    , pathway_catalog pc /*Pass-through*/
    , pathway_catalog pc2
    , long_text_reference ltr
    , regimen_cat_detail_r rcdr /*Plan offsets*/
    , regimen_cat_detail rcd2
    , pathway_catalog pc3 /*Pass-through*/
    , pathway_catalog pc4
plan rc where rc.active_ind = 1
    and rc.end_effective_dt_tm > sysdate
join rcs where rcs.regimen_catalog_id = rc.regimen_catalog_id
    and rcs.primary_ind = 1
    and rcs.synonym_key like 'ONC*'
join rcd where rcd.regimen_catalog_id = rc.regimen_catalog_id
    and rcd.active_ind = 1
join pc where pc.pathway_catalog_id = outerjoin(rcd.entity_id)
join pc2 where pc2.version_pw_cat_id = outerjoin(pc.version_pw_cat_id)
    and pc2.active_ind = outerjoin(1)
    and pc2.end_effective_dt_tm > outerjoin(sysdate)
    and pc2.beg_effective_dt_tm < outerjoin(sysdate)
join ltr where ltr.long_text_id = outerjoin(rcd.entity_id)
    and ltr.active_ind = outerjoin(1)
    and ltr.parent_entity_name = outerjoin('REGIMEN_CAT_DETAIL')
join rcdr where rcdr.regimen_cat_detail_t_id = outerjoin(rcd.regimen_cat_detail_id)
    and rcdr.type_mean = outerjoin('OFFSET')
join rcd2 where rcd2.regimen_cat_detail_id = outerjoin(rcdr.regimen_cat_detail_s_id)
    and rcd2.active_ind = outerjoin(1)
join pc3 where pc3.pathway_catalog_id = outerjoin(rcd2.entity_id)
join pc4 where pc4.version_pw_cat_id = outerjoin(pc3.version_pw_cat_id)
    and pc4.active_ind = outerjoin(1)
    and pc4.end_effective_dt_tm > outerjoin(sysdate)
    and pc4.beg_effective_dt_tm < outerjoin(sysdate)
order by rcs.synonym_key
    , rcd.regimen_detail_sequence
