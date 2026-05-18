/// Neck Slot Items (Deletes overrided items)
/datum/loadout_category/neck
	category_name = "Neck"
	category_ui_icon = FA_ICON_USER_TIE
	type_to_generate = /datum/loadout_item/neck
	tab_order = /datum/loadout_category/head::tab_order + 2

/datum/loadout_item/neck
	abstract_type = /datum/loadout_item/neck

/datum/loadout_item/neck/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	outfit.neck = item_path
