/obj/item/flatpack
	name = "flatpack"
	desc = "A box containing a compactly packed machine or console. Use multitool to deploy."
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "flatpack"
	density = TRUE
	w_class = WEIGHT_CLASS_HUGE //cart time
	throw_range = 2
	item_flags = SLOWS_WHILE_IN_HAND | IMMUTABLE_SLOW
	slowdown = 2.5
	drag_slowdown = 3.5 //use the cart stupid
	custom_premium_price = PAYCHECK_COMMAND * 1.5

	/// The board we deploy
	var/obj/item/circuitboard/board
	/// Which direction a flatpacked computer should face when deployed.
	var/deploy_direction = SOUTH

/obj/item/flatpack/Initialize(mapload, obj/item/circuitboard/new_board)
	if(isnull(board) && isnull(new_board))
		return INITIALIZE_HINT_QDEL //how

	. = ..()

	var/static/list/tool_behaviors = list(
			TOOL_MULTITOOL = list(
				SCREENTIP_CONTEXT_LMB = "Deploy",
			),
		)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)

	board = !isnull(new_board) ? new_board : new board(src) // i got board
	if(board.loc != src)
		board.forceMove(src)
	var/obj/machinery/build = initial(board.build_path)
	name = "flatpack ([initial(build.name)])"

/obj/item/flatpack/Destroy()
	QDEL_NULL(board)
	. = ..()

/obj/item/flatpack/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return

	if(loc == user)
		. += span_warning("You can't deploy while holding it in your hand.")
	else if(isturf(loc))
		var/turf/location = loc
		if(!isopenturf(location))
			. += span_warning("Can't deploy in this location")
		else if(location.is_blocked_turf(source_atom = src))
			. += span_warning("No space for deployment")

	if(istype(board, /obj/item/circuitboard/computer))
		. += span_notice("It is configured to deploy facing <b>[dir2text(deploy_direction)]</b>.")

/obj/item/flatpack/multitool_act(mob/living/user, obj/item/tool)
	. = NONE

	if(isnull(board))
		return ITEM_INTERACT_BLOCKING
	if(!isturf(loc))
		balloon_alert(user, "must deploy on the floor")
		return ITEM_INTERACT_BLOCKING
	var/turf/location = loc
	if(!isopenturf(location))
		balloon_alert(user, "can't deploy here")
		return ITEM_INTERACT_BLOCKING
	else if(location.is_blocked_turf(source_atom = src))
		balloon_alert(user, "no space for deployment")
		return ITEM_INTERACT_BLOCKING
	balloon_alert_to_viewers("deploying!")
	if(!do_after(user, 1 SECONDS, target = src))
		return ITEM_INTERACT_BLOCKING

	new /obj/effect/temp_visual/mook_dust(loc)
	var/obj/item/circuitboard/leaving_circuit = board
	var/obj/machinery/deployed_machine
	if(istype(leaving_circuit, /obj/item/circuitboard/machine))
		deployed_machine = deploy_machine_flatpack(leaving_circuit, user)
	else if(istype(leaving_circuit, /obj/item/circuitboard/computer))
		deployed_machine = deploy_computer_flatpack(leaving_circuit, user)
	else
		return ITEM_INTERACT_BLOCKING
	if(isnull(deployed_machine))
		return ITEM_INTERACT_BLOCKING
	loc.visible_message(span_warning("[src] deploys!"))
	playsound(src, 'sound/machines/terminal/terminal_eject.ogg', 70, TRUE)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/flatpack/proc/deploy_machine_flatpack(obj/item/circuitboard/machine/leaving_circuit, mob/living/user)
	if(contents.len > 1)
		if(!length(leaving_circuit.replacement_parts))
			leaving_circuit.replacement_parts = leaving_circuit.flatten_component_list()
	if(length(leaving_circuit.replacement_parts))
		normalize_replacement_parts(leaving_circuit)
	if(contents.len > 1)
		for(var/obj/item/flatpack_component in src)
			if(flatpack_component == leaving_circuit)
				continue
			for(var/i in 1 to leaving_circuit.replacement_parts.len)
				var/machine_component = leaving_circuit.replacement_parts[i]
				if(!ispath(machine_component, /obj/item))
					continue
				if(flatpack_component.type == machine_component)
					leaving_circuit.replacement_parts[i] = flatpack_component
					break

	board = null
	var/obj/machinery/new_machine = new leaving_circuit.build_path(loc, board = leaving_circuit)
	new_machine.on_construction(user)
	return new_machine

/// Converts old flatpack stock-part typepaths into the datum form machinery RefreshParts() expects.
/obj/item/flatpack/proc/normalize_replacement_parts(obj/item/circuitboard/machine/leaving_circuit)
	PRIVATE_PROC(TRUE)

	for(var/i in 1 to length(leaving_circuit.replacement_parts))
		var/replacement_part = leaving_circuit.replacement_parts[i]
		if(!ispath(replacement_part, /obj/item))
			continue
		if(leaving_circuit.req_components && (replacement_part in leaving_circuit.req_components))
			continue

		var/datum/stock_part/stock_part_datum = GLOB.stock_part_datums_per_object[replacement_part]
		if(!isnull(stock_part_datum))
			leaving_circuit.replacement_parts[i] = stock_part_datum

/obj/item/flatpack/proc/deploy_computer_flatpack(obj/item/circuitboard/computer/leaving_circuit, mob/living/user)
	board = null
	var/obj/machinery/computer/new_computer = new leaving_circuit.build_path(loc)
	if(deploy_direction in GLOB.cardinals)
		new_computer.setDir(deploy_direction)
	new_computer.clear_components()
	new_computer.set_anchored(TRUE)
	new_computer.component_parts = list(leaving_circuit)
	new_computer.circuit = leaving_circuit
	leaving_circuit.forceMove(new_computer)
	new_computer.RefreshParts()
	new_computer.on_construction(user)
	return new_computer

///Maximum number of flatpacks in a cart
#define MAX_FLAT_PACKS 3

/obj/structure/flatpack_cart
	name = "flatpack cart"
	desc = "A cart specifically made to hold flatpacks from a flatpacker, evenly distributing weight. Convenient!"
	icon = 'icons/obj/structures.dmi'
	icon_state = "flatcart"
	density = TRUE
	opacity = FALSE
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 8, /datum/material/alloy/plasteel = SHEET_MATERIAL_AMOUNT)

/obj/structure/flatpack_cart/Initialize(mapload)
	. = ..()

	register_context()

	AddElement(/datum/element/noisy_movement, volume = 45) // i hate noise

/obj/structure/flatpack_cart/atom_deconstruct(disassembled)
	for(var/atom/movable/content as anything in contents)
		content.forceMove(drop_location())

/obj/structure/flatpack_cart/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		return

	if(istype(held_item, /obj/item/flatpack))
		context[SCREENTIP_CONTEXT_LMB] = "Load pack"
		return CONTEXTUAL_SCREENTIP_SET

/obj/structure/flatpack_cart/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return

	. += "From bottom to top, this cart contains:"
	for(var/obj/item/flatpack as anything in contents)
		. += flatpack.name

/obj/structure/flatpack_cart/update_overlays()
	. = ..()

	var/offset = 0
	for(var/item in contents)
		var/mutable_appearance/flatpack_overlay = mutable_appearance(icon, "flatcart_flat", layer = layer + (offset * 0.01))
		flatpack_overlay.pixel_z = offset
		offset += 4
		. += flatpack_overlay

/obj/structure/flatpack_cart/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.put_in_hands(contents[length(contents)]) //topmost box
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/flatpack_cart/item_interaction(mob/living/user, obj/item/attacking_item, params)
	if(!istype(attacking_item, /obj/item/flatpack) || user.combat_mode || attacking_item.flags_1 & HOLOGRAM_1 || attacking_item.item_flags & ABSTRACT)
		return ITEM_INTERACT_SKIP_TO_ATTACK

	if (length(contents) >= MAX_FLAT_PACKS)
		balloon_alert(user, "full!")
		return ITEM_INTERACT_BLOCKING
	if (!user.transferItemToLoc(attacking_item, src))
		return ITEM_INTERACT_BLOCKING
	update_appearance(UPDATE_OVERLAYS)
	return ITEM_INTERACT_SUCCESS

#undef MAX_FLAT_PACKS

// Engineering flatpacks

/obj/item/flatpack/flatpacker // a roundstart flatpacker is NICE you can gahdamn tell the time and everythin'
	name = "flatpacker"
	board = /obj/item/circuitboard/machine/flatpacker
	custom_premium_price = PAYCHECK_COMMAND

/obj/item/flatpack/shuttle_engine
	name = "shuttle propulsion engine"
	board = /obj/item/circuitboard/machine/engine/propulsion
	custom_premium_price = PAYCHECK_CREW * 2

// Cargo flatpacks

/obj/item/flatpack/mailsorter // to have a roundstart mail sorter at cargo
	name = "mail sorter"
	board = /obj/item/circuitboard/machine/mailsorter

/obj/item/flatpack/bullet_drive
	name = "flatpacked bullet drive"
	board = /obj/item/circuitboard/machine/dish_drive/bullet
	custom_premium_price = PAYCHECK_CREW * 1.5
