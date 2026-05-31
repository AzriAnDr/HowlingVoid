// LOADOUT ITEM DATUMS FOR /datum/loadout_item/toys/plush SUBTYPES ONLY

/datum/loadout_item/toys/plush
	group = "Plushies"
	abstract_type = /datum/loadout_item/toys/plush
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_ALLOW_NAMING

/datum/loadout_item/toys/plush/lizard_random
	name = "Plush (Lizard, Random)"
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING
	ui_icon = 'icons/obj/fluff/previews.dmi'
	ui_icon_state = "plushie_lizard_random"
	item_path = /obj/item/toy/plush/lizard_plushie
