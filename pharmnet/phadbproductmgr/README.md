
## Contents
* [pharmnet_clinical_tab.sql](./pharmnet_clinical_tab.sql): Grabs active PharmNet products and contents of the clinical tab 
* [pharmnet_facility_flexing.sql](./pharmnet_facility_flexing.sql): Grabs facility flexing for PharmNet items (includes products, IV sets, etc) 
* [pharmnet_ndc_bill_item_modifiers.sql](./pharmnet_ndc_bill_item_modifiers.sql): Grabs bill item modifiers against PharmNet NDCs 
* [pharmnet_oe_defaults_dispense_tab.sql](./pharmnet_oe_defaults_dispense_tab.sql): Obtains active PharmNet products/IV sets and the contents on the OE defaults tab and Dispense tab 
* [pharmnet_parent_identifiers.sql](./pharmnet_parent_identifiers.sql): Obtains all parent-level identifiers in PhaDbProductMgr. This can be modified to obtain specific modifier types. Note that parent-level implies that this query will not obtain NDC-level identifiers 
* [pharmnet_pharmacy_floorstock_flexing.sql](./pharmnet_pharmacy_floorstock_flexing.sql): Grabs the non-floorstock (pharmacy) and floorstock assignments of PharmNet products 
* [pharmnet_product_notes.sql](./pharmnet_product_notes.sql): Grabs active PharmNet products and associated product notes, given either a product description or a search parameter in for product notes 
* [pharmnet_therapeutic_substitution.sql](./pharmnet_therapeutic_substitution.sql): Therapeutic substitution rows (with from- and to-) 
