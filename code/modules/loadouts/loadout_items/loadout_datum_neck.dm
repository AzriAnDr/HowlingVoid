// LOADOUT ITEM DATUMS FOR THE NECK SLOT

/datum/loadout_category/neck
	tab_order = /datum/loadout_category/ears::tab_order + 1

/datum/loadout_item/neck/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(initial(outfit_important_for_life.neck))
		.. ()
		return TRUE

/datum/loadout_item/neck/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.neck)
			LAZYADD(outfit.backpack_contents, outfit.neck)
		outfit.neck = item_path
	else
		outfit.neck = item_path

/*
*	ITEMS BELOW HERE
*/

/datum/loadout_item/neck/tarkon_gauntlet
	name = "Tarkon Confidante Gauntlet"
	item_path = /obj/item/clothing/neck/security_cape/tarkon
	blacklisted_roles = list(ALL_JOBS_SEC, ALL_JOBS_COM, JOB_PRISONER)

/*
*	COLLARS
*/

/// THIN
/datum/loadout_item/neck/scarf_greyscale
	name = "Scarf  (Colorable)"

/datum/loadout_item/neck/scarf_black
	name = "Scarf (Black)"
	item_path = /obj/item/clothing/neck/scarf/black
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/neck/scarf_cyan
	name = "Scarf (Cyan)"
	item_path = /obj/item/clothing/neck/scarf/cyan
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/neck/scarf_dark_blue
	name = "Scarf (Dark Blue)"
	item_path = /obj/item/clothing/neck/scarf/darkblue
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/neck/scarf_green
	name = "Scarf (Green)"
	item_path = /obj/item/clothing/neck/scarf/green
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/neck/scarf_pink
	name = "Scarf (Pink)"
	item_path = /obj/item/clothing/neck/scarf/pink
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/neck/scarf_purple
	name = "Scarf (Purple)"
	item_path = /obj/item/clothing/neck/scarf/purple
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/neck/scarf_red
	name = "Scarf (Red)"
	item_path = /obj/item/clothing/neck/scarf/red
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/neck/scarf_orange
	name = "Scarf (Orange)"
	item_path = /obj/item/clothing/neck/scarf/orange
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/neck/scarf_yellow
	name = "Scarf (Yellow)"
	item_path = /obj/item/clothing/neck/scarf/yellow
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/neck/scarf_zebra
	name = "Scarf (Zebra)"
	item_path = /obj/item/clothing/neck/scarf/zebra
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/neck/scarf_christmas
	name = "Scarf - Christmas"
	item_path = /obj/item/clothing/neck/scarf/christmas
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/neck/greyscale_large
	name = "Scarf - Large  (Colorable)"

/datum/loadout_item/neck/scarf_red_striped
	name = "Scarf - Large (Red)"
	item_path = /obj/item/clothing/neck/large_scarf/red
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/neck/scarf_blue_striped
	name = "Scarf - Large (Blue)"
	item_path = /obj/item/clothing/neck/large_scarf/blue
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/neck/scarf_green_striped
	name = "Scarf - Large (Green)"
	item_path = /obj/item/clothing/neck/large_scarf/green
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/neck/necktie
	name = "Tie  (Colorable)"

/datum/loadout_item/neck/necktie_loose
	name = "Tie - Loose"

/datum/loadout_item/neck/necktie_disco
	name = "Tie - Ugly"

/datum/loadout_item/neck/security_gauntlet
	name = "Security Gauntlet"
	item_path = /obj/item/clothing/neck/security_cape/armplate
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/*
*	DONATOR
*/

/datum/loadout_item/neck/donator
	abstract_type = /datum/loadout_item/neck/donator
	donator_only = TRUE

/datum/loadout_item/neck/donator/mantle
	abstract_type = /datum/loadout_item/neck/donator/mantle
