// LOADOUT ITEM DATUMS FOR THE ACCESSORY SLOT

/datum/loadout_category/accessories
	category_ui_icon = FA_ICON_ID_BADGE
	tab_order = /datum/loadout_category/undersuit::tab_order + 1

/datum/loadout_item/accessory/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, visuals_only = FALSE)
	if(initial(outfit_important_for_life.accessory))
		.. ()
		return TRUE

/datum/loadout_item/accessory/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.accessory)
			LAZYADD(outfit.backpack_contents, outfit.accessory)
		outfit.accessory = item_path
	else
		outfit.accessory = item_path

/*
*	ITEMS BELOW HERE
*/

/datum/loadout_item/accessory/armband_security
	name = "Armband - Security Deputy"
	item_path = /obj/item/clothing/accessory/armband/deputy
	restricted_roles = list(ALL_JOBS_SEC)

/datum/loadout_item/accessory/holobadge
	name = "Holobadge"
	item_path = /obj/item/clothing/accessory/badge/holo
	restricted_roles = list(ALL_JOBS_SEC)

/datum/loadout_item/accessory/holobadge/blue
	name = "Holobadge (Blue)"
	item_path = /obj/item/clothing/accessory/badge/holo/blue
	restricted_roles = list(ALL_JOBS_SEC)

/datum/loadout_item/accessory/holobadge/lanyard
	name = "Holobadge (Lanyard)"
	item_path = /obj/item/clothing/accessory/badge/holo/cord
	restricted_roles = list(ALL_JOBS_SEC)

/*
*	ARMOURLESS
*/

/datum/loadout_item/accessory/bone_charm
	name = "Heirloom Bone Talisman"
	item_path = /obj/item/clothing/accessory/talisman/armourless

/datum/loadout_item/accessory/bone_charm/get_item_information()
	. = ..()
	.[FA_ICON_SHIELD_ALT] = TOOLTIP_NO_ARMOR

/datum/loadout_item/accessory/bone_codpiece
	name = "Heirloom Skull Codpiece"
	item_path = /obj/item/clothing/accessory/skullcodpiece/armourless

/datum/loadout_item/accessory/bone_codpiece/get_item_information()
	. = ..()
	.[FA_ICON_SHIELD_ALT] = TOOLTIP_NO_ARMOR

/datum/loadout_item/accessory/sinew_kilt
	name = "Heirloom Sinew Skirt"
	item_path = /obj/item/clothing/accessory/skilt/armourless

/datum/loadout_item/accessory/sinew_kilt/get_item_information()
	. = ..()
	.[FA_ICON_SHIELD_ALT] = TOOLTIP_NO_ARMOR

/*
*
* Accessory Medals
*
*/
/datum/loadout_item/accessory/medal
	abstract_type = /datum/loadout_item/accessory/medal
	group = "Medals"
