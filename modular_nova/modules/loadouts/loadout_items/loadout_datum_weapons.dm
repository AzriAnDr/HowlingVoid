/datum/loadout_category/weapons
	category_name = "Weapons"
	category_ui_icon = FA_ICON_GUN
	type_to_generate = /datum/loadout_item/weapons
	tab_order = /datum/loadout_category/inhands::tab_order + 1

/datum/loadout_item/weapons/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	return FALSE

/datum/loadout_item/weapons/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(outfit.r_hand && !outfit.l_hand)
		outfit.l_hand = item_path
	else
		if(outfit.r_hand)
			LAZYADD(outfit.backpack_contents, outfit.r_hand)
		outfit.r_hand = item_path

/datum/loadout_item/weapons
	abstract_type = /datum/loadout_item/weapons
	mechanical_item = TRUE
	blacklisted_roles = list(JOB_PRISONER)

/*
*	GHETTO GUNS
*/

/datum/loadout_item/weapons/ghetto_guns
	abstract_type = /datum/loadout_item/weapons/ghetto_guns
	group = "Improvised Ballistics"

/datum/loadout_item/weapons/forge_weapons
	abstract_type = /datum/loadout_item/weapons/forge_weapons
	group = "Forge Weapons"

/datum/loadout_item/weapons/assorted_weapons
	abstract_type = /datum/loadout_item/weapons/assorted_weapons
	group = "Assorted Weapons"
