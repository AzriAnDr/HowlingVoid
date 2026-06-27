
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox"
	name = "ore box"
	desc = "A heavy wooden box, which can be filled with a lot of ores or boulders"
	density = TRUE
	pressure_resistance = 5 * ONE_ATMOSPHERE
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 4)

/obj/structure/ore_box/Initialize(mapload)
	. = ..()
	register_context()

///Dumps all contents of this ore box on the turf
/obj/structure/ore_box/proc/dump_box_contents()
	var/drop = drop_location()
	for(var/obj/item/weapon in src)
		weapon.forceMove(drop)

/obj/structure/ore_box/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/mineral/wood(loc, 4)

	dump_box_contents()

/obj/structure/ore_box/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		return

	if(held_item.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET
	else if(istype(held_item, /obj/item/stack/ore) || istype(held_item, /obj/item/boulder))
		context[SCREENTIP_CONTEXT_LMB] = "Insert Item"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.atom_storage)
		context[SCREENTIP_CONTEXT_LMB] = "Transfer Contents"
		return CONTEXTUAL_SCREENTIP_SET


/obj/structure/ore_box/examine(mob/living/user)
	. = ..()
	if(in_range(src, user) || isobserver(user))
		. += span_notice("Can be [EXAMINE_HINT("pried")] apart.")
		ui_interact(user)

/obj/structure/ore_box/crowbar_act(mob/living/user, obj/item/I)
	. = ITEM_INTERACT_BLOCKING
	if(I.use_tool(src, user, 50, volume = 50))
		user.visible_message(span_notice("[user] pries \the [src] apart."),
			span_notice("You pry apart \the [src]."),
			span_hear("You hear splitting wood."))
		deconstruct(TRUE)
		return ITEM_INTERACT_SUCCESS

/obj/structure/ore_box/attackby(obj/item/weapon, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(weapon, /obj/item/stack/ore) || istype(weapon, /obj/item/boulder))
		user.transferItemToLoc(weapon, src)
		return TRUE
	else if(weapon.atom_storage)
		weapon.atom_storage.remove_type(/obj/item/stack/ore, src, INFINITY, TRUE, FALSE, user, null)
		to_chat(user, span_notice("You empty the ore in [weapon] into \the [src]."))
		return TRUE
	else
		return ..()

/obj/structure/ore_box/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/item/boulder) && ismecha(loc)) //Boulders being put into a mech's orebox get processed
		var/obj/item/boulder/to_process = arrived
		to_process.convert_to_ore(src)
		qdel(to_process)

/obj/structure/ore_box/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OreBox", name)
		ui.open()

/obj/structure/ore_box/ui_data()
	var/list/materials = list()
	var/name
	var/amount
	for(var/obj/item/stack/ore/potental_ore as anything in contents)
		if(istype(potental_ore, /obj/item/stack/ore))
			name = potental_ore.name
			amount = potental_ore.amount
		else
			name = "Boulders"
			amount = 1

		var/item_found = FALSE
		for(var/list/item as anything in materials)
			if(item["name"] == name)
				item_found = TRUE
				item["amount"] += amount
				break
		if(!item_found)
			materials += list(list("name" = name, "amount" = amount))

	return list("materials" = materials)

/obj/structure/ore_box/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(action == "removeall")
		dump_box_contents()
		return TRUE

/// Special override for notify_contents = FALSE.
/obj/structure/ore_box/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents = FALSE)
	return ..()

/obj/item/ore_box_reinforcement
	name = "ore box reinforcement kit"
	desc = "A case containing reinforced thermally-resistant plastic parts for standard wooden ore boxes used across the universe. \
		Contains all the parts and proprietary tools required to make an ore box significantly less prone to combustion-based disassembly."
	icon = 'icons/obj/weapons/crusher_conversion_kit.dmi'
	icon_state = "crusher_kit"
	lefthand_file = 'icons/mob/inhands/weapons/crusher_kit_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/crusher_kit_righthand.dmi'
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 4)
	w_class = WEIGHT_CLASS_BULKY

/obj/item/ore_box_reinforcement/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/structure/ore_box))
		return NONE

	var/obj/structure/ore_box/our_box = interacting_with
	if(length(our_box.contents))
		balloon_alert(user, "empty ore box first!")
		return NONE

	playsound(src, 'sound/items/tools/drill_use.ogg', 80, TRUE, -1)
	var/obj/structure/ore_box/reinforced/new_box = new(get_turf(our_box))
	var/mob/being_pulled_by = our_box.pulledby
	being_pulled_by?.start_pulling(new_box)
	qdel(our_box)
	. = ITEM_INTERACT_SUCCESS
	qdel(src)

/obj/structure/ore_box/reinforced
	icon = 'icons/ore_box_reinforcement/ore_box.dmi'
	icon_state = "orebox_plastic"
	name = "reinforced ore box"
	desc = "A heavy box, reinforced with high-performance thermoplastics, which can be filled with a lot of ores or boulders. \
		Unfortunately, the reinforcement is prone to shattering upon disassembly."
	max_integrity = 350
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 4, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 4)
