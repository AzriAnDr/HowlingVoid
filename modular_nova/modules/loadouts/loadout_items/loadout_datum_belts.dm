// LOADOUT ITEM DATUMS FOR THE BELT SLOT

/datum/loadout_category/belt
	category_name = "Belt"
	category_ui_icon = FA_ICON_SCREWDRIVER_WRENCH
	type_to_generate = /datum/loadout_item/belts
	tab_order = /datum/loadout_category/accessories::tab_order + 1

/datum/loadout_item/belts
	abstract_type = /datum/loadout_item/belts

/datum/loadout_item/belts/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)  // don't bother storing in backpack, can't fit
	if(initial(outfit_important_for_life.belt))
		return TRUE

/datum/loadout_item/belts/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.belt)
			LAZYADD(outfit.backpack_contents, outfit.belt)

	outfit.belt = item_path

/*
*	ITEMS BELOW HERE
*/

/datum/loadout_item/belts/cin_surplus_chestrig_desert
	name = "Belt - CIN Surplus (Desert)"
	item_path = /obj/item/storage/belt/military/cin_surplus/desert
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/belts/cin_surplus_chestrig_forest
	name = "Belt - CIN Surplus (Forest)"
	item_path = /obj/item/storage/belt/military/cin_surplus/forest
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/belts/cin_surplus_chestrig_marine
	name = "Belt - CIN Surplus (Marine)"
	item_path = /obj/item/storage/belt/military/cin_surplus/marine
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING
