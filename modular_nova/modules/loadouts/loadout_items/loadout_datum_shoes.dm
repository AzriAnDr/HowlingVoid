// LOADOUT ITEM DATUMS FOR THE SHOE SLOT

/datum/loadout_category/shoes
	tab_order = /datum/loadout_category/hands::tab_order + 1

/datum/loadout_item/shoes
	abstract_type = /datum/loadout_item/shoes

/datum/loadout_item/shoes/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(initial(outfit_important_for_life.shoes))
		.. ()
		return TRUE

/datum/loadout_item/shoes/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.shoes)
			LAZYADD(outfit.backpack_contents, outfit.shoes)
		outfit.shoes = item_path
	else
		outfit.shoes = item_path

/*
*	ITEMS BELOW HERE
*/

/datum/loadout_item/shoes/laceup
	name = "Laceup Shoes"

/datum/loadout_item/shoes/sandals_laced
	name = "Sandals - Velcro"

/datum/loadout_item/shoes/sandals_laced_black
	name = "Sandals - Velcro (Black)"

/datum/loadout_item/shoes/cowboy_black
	name = "Boots - Cowboy, Laced (Black)"

/datum/loadout_item/shoes/cowboy_brown
	name = "Boots - Cowboy, Laced (Brown)"

/datum/loadout_item/shoes/cowboy_white
	name = "Boots - Cowboy, Laced (White)"

/datum/loadout_item/shoes/black_sneakers
	name = "Sneakers (Black)"
	item_path = /obj/item/clothing/shoes/sneakers/black
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/shoes/blue_sneakers
	name = "Sneakers (Blue)"
	item_path = /obj/item/clothing/shoes/sneakers/blue
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/shoes/brown_sneakers
	name = "Sneakers (Brown)"
	item_path = /obj/item/clothing/shoes/sneakers/brown
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/shoes/green_sneakers
	name = "Sneakers (Green)"
	item_path = /obj/item/clothing/shoes/sneakers/green
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/shoes/orange_sneakers
	name = "Sneakers (Orange)"
	item_path = /obj/item/clothing/shoes/sneakers/orange
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/shoes/purple_sneakers
	name = "Sneakers (Purple)"
	item_path = /obj/item/clothing/shoes/sneakers/purple
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/shoes/white_sneakers
	name = "Sneakers (White)"
	item_path = /obj/item/clothing/shoes/sneakers/white
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/shoes/yellow_sneakers
	name = "Sneakers (Yellow)"
	item_path = /obj/item/clothing/shoes/sneakers/yellow
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/*
*	LEG WRAPS
*/

/datum/loadout_item/shoes/glow_shoes
	name = "Glowing Shoes (Colorable)"
	group = "Costumes"

/datum/loadout_item/shoes/jackboots_sec_blue
	name = "Security Jackboots (Blue)"
	item_path = /obj/item/clothing/shoes/jackboots/sec/blue
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/shoes/clown_shoes
	abstract_type = /datum/loadout_item/shoes/clown_shoes
	restricted_roles = list(JOB_CLOWN)
	group = "Job-Locked"

/datum/loadout_item/shoes/clown_shoes/pink_heels_mute
	name = "Pink Clown Heels (No Clown Effects)"
	item_path = /obj/item/clothing/shoes/pink_clown_heels
	restricted_roles = null
	group = "Costumes"

/datum/loadout_item/shoes/clown_shoes/pink_heels_mute/get_item_information()
	. = ..()
	.[FA_ICON_VOLUME_MUTE] = "No Clown Effects"

/*
*	erp_item
*/

/datum/loadout_item/shoes/donator
	abstract_type = /datum/loadout_item/shoes/donator
	donator_only = TRUE

/datum/loadout_item/shoes/jackboots
	name = "Boots - Jackboots"
	item_path = /obj/item/clothing/shoes/jackboots

/datum/loadout_item/shoes/kneeboot
	name = "Boots - Jackboots, Knee"
	item_path = /obj/item/clothing/shoes/jackboots/knee

/datum/loadout_item/shoes/work_boots
	name = "Boots - Work"
	item_path = /obj/item/clothing/shoes/workboots
