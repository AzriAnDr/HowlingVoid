// LOADOUT ITEM DATUMS FOR THE HANDS SLOT

/datum/loadout_category/hands
	category_name = "Hands"
	category_ui_icon = FA_ICON_HAND
	type_to_generate = /datum/loadout_item/gloves
	tab_order = /datum/loadout_category/belt::tab_order + 1

/datum/loadout_item/gloves
	abstract_type = /datum/loadout_item/gloves

/datum/loadout_item/gloves/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(initial(outfit_important_for_life.gloves))
		.. ()
		return TRUE

/datum/loadout_item/gloves/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.gloves)
			LAZYADD(outfit.backpack_contents, outfit.gloves)
		outfit.gloves = item_path
	else
		outfit.gloves = item_path

/*
*	ITEMS BELOW HERE
*/

/datum/loadout_item/gloves/yellow
	name = "Gloves (Yellow)"
	item_path = /obj/item/clothing/gloves/color/ffyellow

/datum/loadout_item/gloves/yellow/get_item_information()
	. = ..()
	.[FA_ICON_BOLT] = "Non-Insulating"

/datum/loadout_item/gloves/donator
	abstract_type = /datum/loadout_item/gloves/donator
	donator_only = TRUE
