/*
order_catalog_iv_builder_components.sql
~~~~~~~~~~~~~~~~~~~~
Extracts active IV builders and associated components
*/
select oc.primary_mnemonic
	, ocs.synonym_id
	, component = ocs.mnemonic
	, os.order_sentence_display_line
	, intermittent = evaluate(ocs2.intermittent_ind,1,"Intermittent",0,"Continuous","Check value")
	, ord_sent_order_comment = substring(1, 255, lt.long_text)
from order_catalog_synonym ocs
	, cs_component csp
	, order_catalog oc
	, order_catalog_synonym ocs2
	, order_sentence os
	, long_text lt
plan oc where oc.activity_type_cd = value(uar_get_code_by("MEANING", 106, "PHARMACY"))
	and oc.orderable_type_flag = 8 /*IV builder*/
	and oc.active_ind = 1
join ocs2 where ocs2.catalog_cd = oc.catalog_cd
join csp where csp.catalog_cd = oc.catalog_cd
	and csp.comp_id != 0
join ocs where ocs.synonym_id = csp.comp_id
join os where os.order_sentence_id = outerjoin (csp.order_sentence_id)
join lt where lt.long_text_id = outerjoin(os.ord_comment_long_text_id)
order by cnvtupper(oc.primary_mnemonic)
	, ocs.mnemonic
	, os.order_sentence_display_line
with uar_code(d)
