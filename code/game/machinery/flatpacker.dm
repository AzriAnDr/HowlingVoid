///Incremets an an value assosiated by an key in the list creating that value if nessassary
#define CREATE_AND_INCREMENT(L, I, increment) if(!(I in L)) { L[I] = 0; } L[I] += increment;

/obj/machinery/flatpacker
	name = "flatpacker"
	desc = "It produces items using iron, glass, plastic and maybe some more."
	icon = 'icons/obj/machines/lathes.dmi'
	base_icon_state = "flatpacker"
	icon_state = "flatpacker"
	density = TRUE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	circuit = /obj/item/circuitboard/machine/flatpacker

	/// Are we busy printing?
	var/busy = FALSE
	/// Coefficient applied to machine stock-part materials. Lower values result in lower material consumption.
	var/creation_efficiency = 2
	/// Coefficient applied to console frame materials. Better servos reduce the frame overhead.
	var/computer_creation_efficiency = 1
	///The container to hold materials
	var/datum/remote_materials/materials
	/// The inserted board
	var/obj/item/circuitboard/inserted_board
	/// List of components that need to be packed along with the circuitboard
	var/list/obj/item/flatpacked_components = list()
	/// Materials needed to print this board
	var/list/needed_mats = list()
	/// The highest tier of this board
	var/print_tier = 1
	/// Our max print tier
	var/max_part_tier = 1
	/// The highest tier of machine components we can pack based on our installed micro lasers.
	var/max_component_tier = 1
	/// The selected tier for generic machine stock parts inside the produced flatpack.
	var/selected_component_tier = 1
	/// The selected deploy direction for flatpacked computer boards.
	var/selected_computer_direction = SOUTH
	/// time needed to produce a flatpacked machine
	var/flatpack_time = 4.5 SECONDS

/obj/machinery/flatpacker/Initialize(mapload)
	register_context()

	materials = new ( \
		src, \
		mapload, \
		mat_container_flags = MATCONTAINER_EXAMINE, \
		mat_container_signals = list(COMSIG_MATCONTAINER_ITEM_CONSUMED = TYPE_PROC_REF(/obj/machinery/flatpacker, AfterMaterialInsert)) \
	)
	RegisterSignal(src, COMSIG_SILO_ITEM_CONSUMED, TYPE_PROC_REF(/obj/machinery/flatpacker, AfterSiloMaterialInsert))

	return ..()

/obj/machinery/flatpacker/Destroy()
	QDEL_NULL(materials)
	QDEL_NULL(inserted_board)
	QDEL_LIST(flatpacked_components)
	return ..()

/obj/machinery/flatpacker/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(!QDELETED(inserted_board))
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Eject board"

		var/obj/item/circuitboard/machine/machine_board = inserted_board
		if(istype(machine_board) && !isnull(held_item) && (held_item.type in machine_board.flatpack_components))
			context[SCREENTIP_CONTEXT_LMB] = "Insert flatpack component"
			return CONTEXTUAL_SCREENTIP_SET

		. = CONTEXTUAL_SCREENTIP_SET

	if(!isnull(held_item))
		if(istype(held_item, /obj/item/circuitboard/machine) || istype(held_item, /obj/item/circuitboard/computer))
			context[SCREENTIP_CONTEXT_LMB] = "Insert board"
			return CONTEXTUAL_SCREENTIP_SET
		else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
			return CONTEXTUAL_SCREENTIP_SET
		else if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
			context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
			return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/flatpacker/examine(mob/user)
	. += ..()
	if(!in_range(user, src) && !isobserver(user))
		return

	. += span_notice("The status display reads:")
	. += span_notice("Capable of packing up to <b>Tier [max_part_tier]</b>.")
	. += span_notice("Storing up to <b>[materials.mat_container.max_amount]</b> material units.")
	. += span_notice("Machine component consumption at <b>[creation_efficiency * 100]%</b>.")
	. += span_notice("Console frame consumption at <b>[computer_creation_efficiency * 100]%</b>.")

	. += span_notice("Its maintenance panel can be [EXAMINE_HINT("screwed")] [panel_open ? "close" : "open"].")
	if(panel_open)
		. += span_notice("It can be [EXAMINE_HINT("pried")] apart.")
	if(!QDELETED(inserted_board))
		. += span_notice("The board can be ejected via [EXAMINE_HINT("Ctrl Click")].")
		var/obj/item/circuitboard/machine/machine_board = inserted_board
		if(istype(machine_board) && length(machine_board.flatpack_components))
			var/list/obj/item/to_insert
			for(var/obj/item/component as anything in machine_board.flatpack_components)
				var/inserted = get_flatpack_component_count(component)
				var/required = machine_board.req_components[component]
				if(inserted == required)
					continue
				LAZYADDASSOC(to_insert, get_flatpack_component_name(component), "[inserted]/[required]")
			if(length(to_insert))
				. += span_warning("The following components must be inserted by hand before packaging:")
				for(var/component_name in to_insert)
					. += span_warning("[component_name]: [to_insert[component_name]].")

/obj/machinery/flatpacker/update_overlays()
	. = ..()

	if(!QDELETED(inserted_board))
		. += mutable_appearance(icon, "[base_icon_state]_c")

/**
 * Returns the name of this component. Vending canistors & maybe other types in the future require special parsing
 *
 * Arguments
 * * obj/item/component - the component typepath we are trying to get the name
 */
/obj/machinery/flatpacker/proc/get_flatpack_component_name(obj/item/component)
	PRIVATE_PROC(TRUE)

	if(ispath(component, /obj/item/vending_refill))
		var/obj/item/vending_refill/canister = component

		return "\improper [canister::machine_name] restocking unit"

	return component::name

/**
 * Returns count of inserted flatpack component parts
 *
 * Arguments
 * * obj/item/type - the component type we are trying to count
 */
/obj/machinery/flatpacker/proc/get_flatpack_component_count(obj/item/type)
	PRIVATE_PROC(TRUE)

	. = 0
	for(var/obj/item/test as anything in flatpacked_components)
		if(test.type == type)
			. += 1

/obj/machinery/flatpacker/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == inserted_board)
		inserted_board = null
		needed_mats = list()
		print_tier = 1
		selected_component_tier = 1
		selected_computer_direction = SOUTH
		update_appearance(UPDATE_OVERLAYS)
	if(gone in flatpacked_components)
		flatpacked_components -= gone

/obj/machinery/flatpacker/RefreshParts()
	. = ..()

	var/mat_capacity = 0
	for(var/datum/stock_part/matter_bin/new_matter_bin in component_parts)
		mat_capacity += new_matter_bin.tier * 25 * SHEET_MATERIAL_AMOUNT
	materials.set_local_size(mat_capacity)

	var/datum/stock_part/servo/servo = locate() in component_parts
	max_part_tier = servo.tier
	flatpack_time = initial(flatpack_time) - servo.tier / 2 // T4 = 2 seconds off
	computer_creation_efficiency = clamp(round(1.1 - (servo.tier * 0.1), 0.1), 0.7, 1)
	var/efficiency = initial(creation_efficiency)
	var/laser_tier = 1
	var/found_laser = FALSE
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		laser_tier = found_laser ? min(laser_tier, laser.tier) : laser.tier
		found_laser = TRUE
		efficiency -= laser.tier * 0.2
	max_component_tier = found_laser ? laser_tier : 1
	selected_component_tier = clamp(selected_component_tier, 1, max_component_tier)
	creation_efficiency = max(1.2, round(efficiency, 0.1))
	recalculate_needed_materials()

/obj/machinery/flatpacker/proc/AfterMaterialInsert(container, obj/item/item_inserted, last_inserted_id, mats_consumed, amount_inserted, atom/context)
	SIGNAL_HANDLER

	//we use initial(active_power_usage) because higher tier parts will have higher active usage but we have no benefit from it
	if(directly_use_energy(ROUND_UP((amount_inserted / (MAX_STACK_SIZE * SHEET_MATERIAL_AMOUNT)) * 0.4 * initial(active_power_usage))))
		flick_overlay_view(mutable_appearance('icons/obj/machines/lathes.dmi', "flatpacker_bar"), 1 SECONDS)

		var/datum/material/highest_mat_ref
		var/highest_mat = 0
		for(var/datum/material/mat as anything in mats_consumed)
			var/present_mat = mats_consumed[mat]
			if(present_mat > highest_mat)
				highest_mat = present_mat
				highest_mat_ref = mat

		flick_overlay_view(material_insertion_animation(highest_mat_ref), 1 SECONDS)

/obj/machinery/flatpacker/proc/AfterSiloMaterialInsert(obj/machinery/flatpacker/machine, container, obj/item/item_inserted, last_inserted_id, list/mats_consumed, amount_inserted)
	SIGNAL_HANDLER

	AfterMaterialInsert(container, item_inserted, last_inserted_id, mats_consumed, amount_inserted, src)

/obj/machinery/flatpacker/proc/get_material_efficiency_for_board(obj/item/circuitboard/board)
	PRIVATE_PROC(TRUE)

	if(istype(board, /obj/item/circuitboard/computer))
		return computer_creation_efficiency
	return creation_efficiency

/**
 * Attempts to find the total material cost of a typepath (including our creation efficiency), modifying a list
 * The list is modified as an assoc list: Material datum typepath = Cost
 * If the type is found on a techweb, uses material costs from there
 * Otherwise, the typepath is created in nullspace and fetches materials from the initialized one, then deleted.
 *
 * Args:
 * * part_type - Typepath of the item we are trying to find the costs of
 * * costs - Assoc list we modify and return
 * * count - the number of parts to compute the cost of
 */
/obj/machinery/flatpacker/proc/analyze_cost(part_type, costs, count)
	PRIVATE_PROC(TRUE)

	var/comp_type = part_type
	if(ispath(part_type, /datum/stock_part))
		part_type = get_selected_stock_part_type(part_type)
		var/datum/stock_part/as_part = GLOB.stock_part_datums[part_type]
		comp_type = initial(as_part.physical_object_type)
		if(as_part.tier > print_tier)
			print_tier = as_part.tier

	var/list/mat_list
	var/obj/item/null_comp
	if(!isnull(SSresearch.item_to_design[comp_type]))
		mat_list = SSresearch.item_to_design[comp_type][1].materials
	else
		var/datum/stock_part/part = GLOB.stock_part_datums_per_object[comp_type]
		if(part)
			mat_list = part.physical_object_reference.custom_materials
		else
			null_comp = new comp_type
			mat_list = null_comp.custom_materials

	for(var/atom/mat as anything in mat_list)
		CREATE_AND_INCREMENT(costs, mat.type, mat_list[mat] * count)

	if(null_comp)
		qdel(null_comp)
	return costs

/obj/machinery/flatpacker/proc/get_selected_stock_part_type(part_type)
	PRIVATE_PROC(TRUE)

	if(selected_component_tier <= 1)
		return part_type

	var/static/list/stock_part_tiers = list(
		/datum/stock_part/scanning_module = list(
			/datum/stock_part/scanning_module,
			/datum/stock_part/scanning_module/tier2,
			/datum/stock_part/scanning_module/tier3,
			/datum/stock_part/scanning_module/tier4,
		),
		/datum/stock_part/capacitor = list(
			/datum/stock_part/capacitor,
			/datum/stock_part/capacitor/tier2,
			/datum/stock_part/capacitor/tier3,
			/datum/stock_part/capacitor/tier4,
		),
		/datum/stock_part/servo = list(
			/datum/stock_part/servo,
			/datum/stock_part/servo/tier2,
			/datum/stock_part/servo/tier3,
			/datum/stock_part/servo/tier4,
		),
		/datum/stock_part/micro_laser = list(
			/datum/stock_part/micro_laser,
			/datum/stock_part/micro_laser/tier2,
			/datum/stock_part/micro_laser/tier3,
			/datum/stock_part/micro_laser/tier4,
		),
		/datum/stock_part/matter_bin = list(
			/datum/stock_part/matter_bin,
			/datum/stock_part/matter_bin/tier2,
			/datum/stock_part/matter_bin/tier3,
			/datum/stock_part/matter_bin/tier4,
		),
	)

	var/list/available_tiers = stock_part_tiers[part_type]
	if(!available_tiers)
		return part_type

	return available_tiers[selected_component_tier]

/obj/machinery/flatpacker/proc/add_computer_frame_costs()
	PRIVATE_PROC(TRUE)

	CREATE_AND_INCREMENT(needed_mats, /datum/material/iron, SHEET_MATERIAL_AMOUNT * 5)
	CREATE_AND_INCREMENT(needed_mats, /datum/material/glass, SHEET_MATERIAL_AMOUNT * 2)

	var/static/list/cable_piece_materials
	if(isnull(cable_piece_materials))
		var/obj/item/stack/cable_coil/cable_piece = new(null, 1)
		cable_piece_materials = cable_piece.mats_per_unit.Copy()
		qdel(cable_piece)

	for(var/material_type in cable_piece_materials)
		CREATE_AND_INCREMENT(needed_mats, material_type, cable_piece_materials[material_type] * 5)

/obj/machinery/flatpacker/proc/recalculate_needed_materials()
	PRIVATE_PROC(TRUE)

	needed_mats = list()
	print_tier = 1

	if(QDELETED(inserted_board))
		return

	selected_component_tier = clamp(selected_component_tier, 1, max_component_tier)

	var/obj/item/circuitboard/machine/machine_board = inserted_board
	if(istype(machine_board))
		for(var/type in machine_board.req_components)
			if(type in machine_board.flatpack_components)
				continue
			needed_mats = analyze_cost(type, needed_mats, machine_board.req_components[type])

		// 5 sheets of iron and 5 of cable coil
		CREATE_AND_INCREMENT(needed_mats, /datum/material/iron, (SHEET_MATERIAL_AMOUNT * 5 + (SHEET_MATERIAL_AMOUNT / 20)))
		CREATE_AND_INCREMENT(needed_mats, /datum/material/glass, (SHEET_MATERIAL_AMOUNT / 20))
		return

	if(istype(inserted_board, /obj/item/circuitboard/computer))
		add_computer_frame_costs()

/obj/machinery/flatpacker/proc/generate_replacement_parts()
	PRIVATE_PROC(TRUE)

	var/list/replacement_parts = list()
	if(QDELETED(inserted_board))
		return replacement_parts

	var/obj/item/circuitboard/machine/machine_board = inserted_board
	if(!istype(machine_board))
		return replacement_parts

	for(var/component in machine_board.req_components)
		var/amount = machine_board.req_components[component]
		if(!amount)
			continue

		if(machine_board.def_components && machine_board.def_components[component])
			component = machine_board.def_components[component]

		if(ispath(component, /obj/item/stack))
			continue

		if(ispath(component, /datum/stock_part))
			component = get_selected_stock_part_type(component)
			var/datum/stock_part/stock_part_datum = GLOB.stock_part_datums[component]
			if(isnull(stock_part_datum))
				CRASH("[component] didn't have a matching stock part datum")
			component = stock_part_datum

		for(var/_ in 1 to amount)
			replacement_parts += component

	return replacement_parts

/obj/machinery/flatpacker/base_item_interaction(mob/living/user, obj/item/attacking_item, list/modifiers)
	if(attacking_item.flags_1 & HOLOGRAM_1)
		return ITEM_INTERACT_SKIP_TO_ATTACK

	if(istype(attacking_item, /obj/item/circuitboard/machine) || istype(attacking_item, /obj/item/circuitboard/computer))
		if(busy)
			balloon_alert(user, "busy!")
			return ITEM_INTERACT_BLOCKING
		if (!user.transferItemToLoc(attacking_item, src))
			return ITEM_INTERACT_BLOCKING

		// If insertion was successful and there's already a diskette in the console, eject the old one.
		if(inserted_board)
			inserted_board.forceMove(drop_location())
		inserted_board = attacking_item

		recalculate_needed_materials()

		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_SUCCESS
	var/obj/item/circuitboard/machine/machine_board = inserted_board
	if(istype(machine_board) && !QDELETED(inserted_board) && (attacking_item.type in machine_board.flatpack_components))
		if(get_flatpack_component_count(attacking_item.type) == machine_board.req_components[attacking_item.type])
			balloon_alert(user, "max count reached!")
			return ITEM_INTERACT_BLOCKING

		if(!user.transferItemToLoc(attacking_item, src))
			to_chat(user, span_warning("[attacking_item] is stuck in hand!"))
			return ITEM_INTERACT_BLOCKING

		LAZYADD(flatpacked_components, attacking_item)
		return ITEM_INTERACT_SUCCESS

	return ..()

/obj/machinery/flatpacker/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_o", base_icon_state, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/flatpacker/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/flatpacker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Flatpacker")
		ui.open()

/obj/machinery/flatpacker/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/sheetmaterials),
		get_asset_datum(/datum/asset/spritesheet_batched/research_designs),
	)

/obj/machinery/flatpacker/ui_static_data(mob/user)
	return materials.mat_container.ui_static_data()

/obj/machinery/flatpacker/ui_data(mob/user)
	. = list()

	.["materials"] = materials.mat_container.ui_data()
	.["busy"] = busy

	var/list/design
	if(!QDELETED(inserted_board))
		var/material_efficiency = get_material_efficiency_for_board(inserted_board)
		var/list/cost_mats = list()
		for(var/datum/material/mat_type as anything in needed_mats)
			var/list/new_entry = list()
			new_entry["name"] = initial(mat_type.name)
			new_entry["amount"] = OPTIMAL_COST(needed_mats[mat_type] * material_efficiency)
			cost_mats += list(new_entry)

		var/atom/build = initial(inserted_board.build_path)
		var/obj/item/circuitboard/machine/machine_board = inserted_board

		var/disableReason = ""
		if(print_tier > max_part_tier)
			disableReason = "This design is too advanced for this machine. "
		else if(!materials.mat_container.has_materials(needed_mats, material_efficiency))
			disableReason = "Not enough materials. "
		else if(istype(machine_board))
			for(var/obj/item/component as anything in machine_board.flatpack_components)
				var/diff = machine_board.req_components[component] - get_flatpack_component_count(component)
				if(diff)
					disableReason = "Please insert [diff] [get_flatpack_component_name(component)]"
					break
		design = list(
			"name" = initial(build.name),
			"requiredMaterials" = cost_mats,
			"icon" = icon2base64(icon(initial(build.icon), initial(build.icon_state), frame = 1)),
			"disableReason" = disableReason,
			"selectedPartTier" = selected_component_tier,
			"maxPartTier" = max_component_tier,
			"supportsPartTierSelection" = !!istype(inserted_board, /obj/item/circuitboard/machine),
			"selectedDirection" = dir2text(selected_computer_direction),
			"supportsDirectionSelection" = !!istype(inserted_board, /obj/item/circuitboard/computer),
		)
	.["design"] = design

/obj/machinery/flatpacker/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("build")
			if(busy)
				return

			if(QDELETED(inserted_board))
				return
			if(print_tier > max_part_tier)
				say("Design too complex.")
				return
			var/obj/item/circuitboard/machine/machine_board = inserted_board
			if(istype(machine_board))
				for(var/obj/item/component as anything in machine_board.flatpack_components)
					if(machine_board.req_components[component] != get_flatpack_component_count(component))
						say("Not enough [get_flatpack_component_name(component)].")
						return
			if(!materials.can_use_resource(user_data = ID_DATA(ui.user)))
				return
			var/material_efficiency = get_material_efficiency_for_board(inserted_board)
			if(!materials.mat_container.has_materials(needed_mats, material_efficiency))
				say("Not enough materials to begin production.")
				return
			playsound(src, 'sound/items/tools/rped.ogg', 50, TRUE)
			busy = TRUE
			flick_overlay_view(mutable_appearance('icons/obj/machines/lathes.dmi', "flatpacker_bar"), flatpack_time)
			addtimer(CALLBACK(src, PROC_REF(finish_build), inserted_board, ID_DATA(ui.user)), flatpack_time)
			return TRUE

		if("ejectBoard")
			try_put_in_hand(inserted_board, ui.user)
			return TRUE

		if("setPartTier")
			if(QDELETED(inserted_board) || !istype(inserted_board, /obj/item/circuitboard/machine))
				return

			var/new_tier = text2num(params["tier"])
			if(isnull(new_tier))
				return

			selected_component_tier = clamp(new_tier, 1, max_component_tier)
			recalculate_needed_materials()
			return TRUE

		if("setDirection")
			if(QDELETED(inserted_board) || !istype(inserted_board, /obj/item/circuitboard/computer))
				return

			var/new_direction = text2dir(params["direction"])
			if(!(new_direction in GLOB.cardinals))
				return

			selected_computer_direction = new_direction
			return TRUE

		if("eject")
			var/datum/material/material = locate(params["ref"])
			if(!istype(material))
				return

			var/amount = params["amount"]
			if(isnull(amount))
				return

			amount = text2num(amount)
			if(isnull(amount))
				return

			//we use initial(active_power_usage) because higher tier parts will have higher active usage but we have no benefit from it
			if(!directly_use_energy(ROUND_UP((amount / MAX_STACK_SIZE) * 0.4 * initial(active_power_usage))))
				say("No power to dispense sheets")
				return

			materials.eject_sheets(material, amount, user_data = ID_DATA(ui.user))
			return TRUE

/**
 * Turns the supplied board into a flatpack, and sets the machine as not busy
 * Arguments
 *
 * * board - the board to put inside the flatpack
 */
/obj/machinery/flatpacker/proc/finish_build(obj/item/circuitboard/board, alist/user_data)
	PRIVATE_PROC(TRUE)

	busy = FALSE

	if(!materials.use_materials(needed_mats, get_material_efficiency_for_board(board), user_data = user_data))
		say("Unable to access materials for production.")
		SStgui.update_uis(src)
		return

	var/obj/item/circuitboard/machine/machine_board = board
	if(istype(machine_board))
		machine_board.replacement_parts = generate_replacement_parts()
	var/computer_deploy_direction = selected_computer_direction
	var/obj/item/flatpack/box = new (drop_location(), board)
	if(istype(board, /obj/item/circuitboard/computer))
		box.deploy_direction = computer_deploy_direction
	if(istype(machine_board))
		for(var/obj/item/component as anything in flatpacked_components)
			component.forceMove(box)

	SStgui.update_uis(src)

/obj/machinery/flatpacker/click_ctrl(mob/user)
	if(QDELETED(inserted_board) || busy)
		return CLICK_ACTION_BLOCKING

	try_put_in_hand(inserted_board, user)
	var/drop = drop_location()
	for(var/obj/item/component as anything in flatpacked_components)
		component.forceMove(drop)

	return CLICK_ACTION_SUCCESS

#undef CREATE_AND_INCREMENT
