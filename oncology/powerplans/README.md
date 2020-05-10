
## Contents
* [pco_powerplan_usage.sql](./pco_powerplan_usage.sql): Grabs oncology powerplan usage and displays patients' name, MRN, FIN and PowerPlan name  Inline table PW is used to grab the highest pathway_id belonging to the grouped pw_group_nbr (multi-phase powerplans on this table have separate line items for each phase and DOT, which would over-report usage)  pathway table (pw2) is then used to grab the phase-specific details such as order_dt_tm 
* [powerplan_facility_flexing.sql](./powerplan_facility_flexing.sql): This query checks powerplan facility flexing. Un-comment out the line that designates the powerplan name or the facility display and make sure to use capitalized and wildcards  for example: and pwcat.description_key like '*ONCP*AC*' 
* [pco_powerplan_basic_attributes.sql](./pco_powerplan_basic_attributes.sql): This query grabs any currently active powerplan and powerplan-level attributes (such as default view, or copy forward) in addition to reference text and powerplan commaents 
* [pco_powerplan_linked_groups.sql](./pco_powerplan_linked_groups.sql): This query identifies linked components built in oncology Powerplans 
* [pco_powerplan_extract.sql](./pco_powerplan_extract.sql): This query pulls the orderables and corresponding order sentences for oncology powerplans. Note that this purposely excludes order-DOT assignment 
* [oncology_powerplan_downtime.sql](./oncology_powerplan_downtime.sql): 
