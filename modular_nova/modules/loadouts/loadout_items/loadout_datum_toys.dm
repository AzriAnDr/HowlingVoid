// LOADOUT ITEM DATUMS FOR TOY ITEMS, PLACED DIRECTLY INTO THE BACKPACK

/datum/loadout_category/toys
	category_name = "Toys"
	category_ui_icon = FA_ICON_TROPHY
	type_to_generate = /datum/loadout_item/toys
	tab_order = /datum/loadout_category/weapons::tab_order + 1
	/// How many toys are allowed at maximum.
	VAR_PRIVATE/max_allowed = 3

/datum/loadout_category/toys/New()
	. = ..()
	category_info = "([max_allowed] allowed)"

/datum/loadout_category/toys/handle_duplicate_entires(
	datum/preference_middleware/loadout/manager,
	datum/loadout_item/conflicting_item,
	datum/loadout_item/added_item,
	list/datum/loadout_item/all_loadout_items,
)
	var/list/datum/loadout_item/toys/other_toys = list()
	for(var/datum/loadout_item/toys/other_toy in all_loadout_items)
		other_toys += other_toy

	if(length(other_toys) >= max_allowed)
		// We only need to deselect something if we're above the limit
		// (And if we are we prioritize the first item found, FIFO)
		manager.deselect_item(other_toys[1])
	return TRUE

/datum/loadout_item/toys
	abstract_type = /datum/loadout_item/toys

/datum/loadout_item/toys/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)  // these go in the backpack
	return FALSE

/*
*	ITEMS BELOW HERE
*/

/datum/loadout_item/toys/dice
	group = "Dice"
	abstract_type = /datum/loadout_item/toys/dice
