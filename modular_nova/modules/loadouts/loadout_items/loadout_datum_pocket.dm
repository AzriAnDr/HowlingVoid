// LOADOUT ITEM DATUMS FOR POCKET ITEMS, PLACED DIRECTLY INTO THE BACKPACK

/datum/loadout_category/pocket
	tab_order = /datum/loadout_category/toys::tab_order + 1

/datum/loadout_item/pocket_items/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE) // these go in the backpack
	return FALSE

/datum/loadout_item/pocket_items/wallet/get_item_information()
	. = ..()
	.[FA_ICON_BOX] = "Auto-Filled"

/*
*	ITEMS BELOW HERE
*/

/datum/loadout_item/pocket_items/lighter
	name = "Lighter - Zippo"

/datum/loadout_item/pocket_items/dye
	group = "Cosmetics"

/datum/loadout_item/pocket_items/lipstick
	group = "Cosmetics"

/datum/loadout_item/pocket_items/donator
	abstract_type = /datum/loadout_item/pocket_items/donator
	donator_only = TRUE
