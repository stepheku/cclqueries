# Order entry formats queries
These queries are specific to Order entry formats
## Contents
* [order_entry_format_fields_flexing.sql](./order_entry_format_fields_flexing.sql): This query grabs all Pharmacy order entry formats with an action type of "Order" and the associated format fields (and associated order entry fields)  Ths accept_format_flexing table is also joined to give flexing information. Any field that is not flexed, has a blank field for flex_type and onwards 
* [order_entry_format_fields.sql](./order_entry_format_fields.sql): This query grabs all order entry formats with all order action types and with the associated format fields (and associated order entry fields) 
