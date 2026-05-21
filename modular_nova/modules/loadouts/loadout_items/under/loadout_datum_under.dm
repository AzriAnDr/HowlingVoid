// LOADOUT ITEM DATUMS FOR THE UNDER (UNIFORM) SLOT

/datum/loadout_category/undersuit
	category_name = "Undersuit"
	category_ui_icon = FA_ICON_SHIRT
	type_to_generate = /datum/loadout_item/under
	tab_order = /datum/loadout_category/suits::tab_order + 1

/datum/loadout_item/under
	abstract_type = /datum/loadout_item/under

/datum/loadout_item/under/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(initial(outfit_important_for_life.uniform))
		.. ()
		return TRUE

/datum/loadout_item/under/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.uniform)
			LAZYADD(outfit.backpack_contents, outfit.uniform)
		outfit.uniform = item_path
	else
		outfit.uniform = item_path
	outfit.modified_outfit_slots |= ITEM_SLOT_ICLOTHING

/*
*	ITEMS BELOW HERE
*/

/*
 *	JUMPSUITS
 *	To cheat at alphabetization, these have extra spaces at the front of their name.
 *	In-game users won't see these spaces, but it'll still force these to sort as they appear below.
*/

/datum/loadout_item/under/jumpsuit
	abstract_type = /datum/loadout_item/under/jumpsuit

/datum/loadout_item/under/jumpsuit/random
	name = "  Jumpsuit - Random"
	item_path = /obj/item/clothing/under/color/random
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/under/jumpsuit/random/get_item_information()
	. = ..()
	.[FA_ICON_DICE] = TOOLTIP_RANDOM_COLOR

/datum/loadout_item/under/jumpsuit/random_skirt
	name = " Jumpskirt - Random"
	item_path = /obj/item/clothing/under/color/jumpskirt/random
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/under/jumpsuit/random_skirt/get_item_information()
	. = ..()
	.[FA_ICON_DICE] = TOOLTIP_RANDOM_COLOR

/*
 *	Unsorted
 *	For the love of god try to sort it first.
*/

/datum/loadout_item/under/formal
	abstract_type = /datum/loadout_item/under/formal
	group = "Formalwear"

/datum/loadout_item/under/jumpsuit/hlscientist
	name = "Buttondown Suit - Science Team"
	item_path = /obj/item/clothing/under/rank/rnd/scientist/nova/hlscience
	group = "Formalwear" //This datum needs retyping to be /under/formal!

/datum/loadout_item/under/formal/pencil
	name = "Pencilskirt"
	item_path = /obj/item/clothing/under/suit/nova/pencil

/datum/loadout_item/under/formal/pencil/checkered
	name = "Pencilskirt  (Checkered)" //This is recolorable, put it right after the base type
	item_path = /obj/item/clothing/under/suit/nova/pencil/checkered

/datum/loadout_item/under/formal/pencil/burgandy
	name = "Pencilskirt (Burgundy)"
	item_path = /obj/item/clothing/under/suit/nova/pencil/burgundy
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/under/formal/pencil/charcoal
	name = "Pencilskirt (Charcoal)"
	item_path = /obj/item/clothing/under/suit/nova/pencil/charcoal
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/under/formal/pencil/green
	name = "Pencilskirt (Green)"
	item_path = /obj/item/clothing/under/suit/nova/pencil/green
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/under/formal/pencil/navy
	name = "Pencilskirt (Navy)"
	item_path = /obj/item/clothing/under/suit/nova/pencil/navy
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/under/formal/pencil/tan
	name = "Pencilskirt (Tan)"
	item_path = /obj/item/clothing/under/suit/nova/pencil/tan
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/under/bunny
	abstract_type = /datum/loadout_item/under/bunny
	group = "Bunny Suits"

/datum/loadout_item/under/formal/recolorable_suit
	name = "Suit  (Colorable)"
	item_path = /obj/item/clothing/under/suit/nova/recolorable
