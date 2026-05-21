// LOADOUT ITEM DATUMS FOR THE MASK SLOT

/datum/loadout_category/face
	category_name = "Face"
	category_ui_icon = FA_ICON_MASK
	type_to_generate = /datum/loadout_item/mask
	tab_order = /datum/loadout_category/glasses::tab_order + 1

/datum/loadout_item/mask
	abstract_type = /datum/loadout_item/mask

/datum/loadout_item/mask/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(initial(outfit_important_for_life.mask))
		..()
		return TRUE

/datum/loadout_item/mask/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.mask)
			LAZYADD(outfit.backpack_contents, outfit.mask)
		outfit.mask = item_path
	else
		outfit.mask = item_path

/*
*	ITEMS BELOW HERE
*/

/datum/loadout_item/mask/whistlesec
	name = "Police Whistle"
	item_path = /obj/item/clothing/mask/whistle
	restricted_roles = list(ALL_JOBS_SEC)

/*
*	DONATOR
*/

/datum/loadout_item/mask/donator
	abstract_type = /datum/loadout_item/mask/donator
	donator_only = TRUE

/datum/loadout_item/mask/masquerade
	name = "Masquerade Mask"
	item_path = /obj/item/clothing/mask/masquerade
	group = "Costumes"

/datum/loadout_item/mask/masquerade/two_colors
	name = "Masquerade Mask - Split"
	item_path = /obj/item/clothing/mask/masquerade/two_colors
	group = "Costumes"
