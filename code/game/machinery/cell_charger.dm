/obj/machinery/cell_charger
	name = "cell charger"
	desc = "It charges power cells."
	icon = 'icons/obj/machines/cell_charger.dmi'
	icon_state = "ccharger"
	power_channel = AREA_USAGE_EQUIP
	circuit = /obj/item/circuitboard/machine/cell_charger
	pass_flags = PASSTABLE
	var/obj/item/stock_parts/power_store/cell/charging = null
	var/charge_rate = STANDARD_CELL_RATE //NOVA EDIT CHANGE - ORIGINAL: 0.25 * STANDARD_CELL_RATE

/obj/machinery/cell_charger/update_overlays()
	. = ..()

	if(!charging)
		return

	if(!(machine_stat & (BROKEN|NOPOWER)))
		var/newlevel = round(charging.percent() * 4 / 100)
		. += "ccharger-o[newlevel]"
	if(!charging.charging_icon)
		. += image(charging.icon, charging.icon_state)
	else
		. += image('icons/obj/machines/cell_charger.dmi', charging.charging_icon)

/obj/machinery/cell_charger/examine(mob/user)
	. = ..()
	. += "There's [charging ? "\a [charging]" : "no cell"] in the charger."
	if(charging)
		. += "Current charge: [round(charging.percent(), 1)]%."
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Charging power: <b>[display_power(charge_rate, convert = FALSE)]</b>.")

/obj/machinery/cell_charger/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(charging)
		return FALSE
	if(default_unfasten_wrench(user, tool))
		update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/cell_charger/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(W, /obj/item/stock_parts/power_store/cell) && !panel_open)
		if(machine_stat & BROKEN)
			to_chat(user, span_warning("[src] is broken!"))
			return
		if(!anchored)
			to_chat(user, span_warning("[src] isn't attached to the ground!"))
			return
		if(charging)
			to_chat(user, span_warning("There is already a cell in the charger!"))
			return
		//NOVA EDIT ADDITION
		var/obj/item/stock_parts/power_store/cell/inserting_cell = W
		if(inserting_cell.chargerate <= 0)
			to_chat(user, span_warning("[inserting_cell] cannot be recharged!"))
			return
		//NOVA EDIT END
		else
			var/area/a = loc.loc // Gets our locations location, like a dream within a dream
			if(!isarea(a))
				return
			if(a.power_equip == 0) // There's no APC in this area, don't try to cheat power!
				to_chat(user, span_warning("[src] blinks red as you try to insert the cell!"))
				return
			if(!user.transferItemToLoc(W,src))
				return

			charging = W
			user.visible_message(span_notice("[user] inserts a cell into [src]."), span_notice("You insert a cell into [src]."))
			update_appearance()
	else
		if(!charging && default_deconstruction_screwdriver(user, icon_state, icon_state, W))
			return
		if(default_deconstruction_crowbar(W))
			return
		return ..()

/obj/machinery/cell_charger/on_deconstruction(disassembled)
	if(charging)
		charging.forceMove(drop_location())

/obj/machinery/cell_charger/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == charging)
		charging = null

/obj/machinery/cell_charger/Destroy()
	QDEL_NULL(charging)
	return ..()

/obj/machinery/cell_charger/proc/removecell(new_loc)
	. = charging
	charging.update_appearance()
	charging.forceMove(new_loc)
	charging = null
	update_appearance()

/obj/machinery/cell_charger/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || !charging)
		return

	charging.add_fingerprint(user)
	user.visible_message(span_notice("[user] removes [charging] from [src]."), span_notice("You remove [charging] from [src]."))
	user.put_in_hands(removecell(drop_location()))

/obj/machinery/cell_charger/attack_tk(mob/user)
	if(!charging)
		return

	to_chat(user, span_notice("You telekinetically remove [charging] from [src]."))
	removecell(drop_location())
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/cell_charger/attack_ai(mob/user)
	return

/obj/machinery/cell_charger/emp_act(severity)
	. = ..()

	if(machine_stat & (BROKEN|NOPOWER) || . & EMP_PROTECT_CONTENTS)
		return

	if(charging)
		charging.emp_act(severity)

/obj/machinery/cell_charger/RefreshParts()
	. = ..()
	charge_rate = STANDARD_CELL_RATE //NOVA EDIT CHANGE - ORIGINAL: 0.25 * STANDARD_CELL_RATE
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		charge_rate *= capacitor.tier

/obj/machinery/cell_charger/process(seconds_per_tick)
	if(!charging || charging.percent() >= 100 || !anchored || !is_operational)
		return

	var/main_draw = charge_rate * seconds_per_tick
	if(!main_draw)
		return

	//charge cell, account for heat loss from work done
	var/charge_given = charge_cell(main_draw, charging, grid_only = TRUE)
	if(charge_given)
		use_energy((charge_given + active_power_usage) * 0.01)

	update_appearance()

/obj/machinery/cell_charger_multi
	name = "multi-cell charging rack"
	desc = "A cell charging rack for multiple batteries."
	icon = 'icons/obj/machines/cell_charger.dmi'
	icon_state = "cchargermulti"
	base_icon_state = "cchargermulti"
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 60
	power_channel = AREA_USAGE_EQUIP
	circuit = /obj/item/circuitboard/machine/cell_charger_multi
	pass_flags = PASSTABLE
	/// The batteries currently charging in the rack.
	var/list/charging_batteries
	/// Number of concurrent batteries that can be charged.
	var/max_batteries = 4
	/// Base charge rate before stock parts are applied.
	var/charge_rate = STANDARD_CELL_RATE

/obj/machinery/cell_charger_multi/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/cell_charger_multi/update_overlays()
	. = ..()

	if(!LAZYLEN(charging_batteries))
		return

	for(var/i = LAZYLEN(charging_batteries), i >= 1, i--)
		var/obj/item/stock_parts/power_store/cell/charging = LAZYACCESS(charging_batteries, i)
		var/newlevel = round(charging.percent() * 4 / 100)
		var/mutable_appearance/charge_overlay = mutable_appearance(icon, "[base_icon_state]-o[newlevel]")
		var/mutable_appearance/cell_overlay = mutable_appearance(icon, "[base_icon_state]-cell")
		charge_overlay.pixel_w = 5 * (i - 1)
		cell_overlay.pixel_w = 5 * (i - 1)
		. += new /mutable_appearance(charge_overlay)
		. += new /mutable_appearance(cell_overlay)

/obj/machinery/cell_charger_multi/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Remove all cells"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/cell_charger_multi/click_alt(mob/user, list/modifiers)
	if(!can_interact(user) || !LAZYLEN(charging_batteries))
		return
	to_chat(user, span_notice("You press the quick release as all the cells pop out!"))
	for(var/i in charging_batteries)
		removecell()
	return CLICK_ACTION_SUCCESS

/obj/machinery/cell_charger_multi/examine(mob/user)
	. = ..()
	if(!LAZYLEN(charging_batteries))
		. += "There are no cells in [src]."
	else
		. += "There are [LAZYLEN(charging_batteries)] cells in [src]."
		for(var/obj/item/stock_parts/power_store/cell/charging in charging_batteries)
			. += "There's [charging] cell in the charger, current charge: [round(charging.percent(), 1)]%."
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Charging power: <b>[display_power(charge_rate, convert = FALSE)]</b> per cell.")
	. += span_notice("Alt click it to remove all the cells at once!")

/obj/machinery/cell_charger_multi/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/stock_parts/power_store/cell) && !panel_open)
		if(machine_stat & BROKEN)
			to_chat(user, span_warning("[src] is broken!"))
			return
		if(!anchored)
			to_chat(user, span_warning("[src] isn't attached to the ground!"))
			return
		var/obj/item/stock_parts/power_store/cell/inserting_cell = attacking_item
		if(inserting_cell.chargerate <= 0)
			to_chat(user, span_warning("[inserting_cell] cannot be recharged!"))
			return
		if(LAZYLEN(charging_batteries) >= max_batteries)
			to_chat(user, span_warning("[src] is full, and cannot hold anymore cells!"))
			return
		var/area/current_area = loc.loc
		if(!isarea(current_area))
			return
		if(current_area.power_equip == 0)
			to_chat(user, span_warning("[src] blinks red as you try to insert the cell!"))
			return
		if(!user.transferItemToLoc(attacking_item, src))
			return

		LAZYADD(charging_batteries, attacking_item)
		user.visible_message(span_notice("[user] inserts a cell into [src]."), span_notice("You insert a cell into [src]."))
		update_appearance()
		return

	if(!LAZYLEN(charging_batteries) && default_deconstruction_screwdriver(user, icon_state, icon_state, attacking_item))
		return
	if(default_deconstruction_crowbar(attacking_item))
		return
	if(!LAZYLEN(charging_batteries) && default_unfasten_wrench(user, attacking_item))
		return
	return ..()

/obj/machinery/cell_charger_multi/process(seconds_per_tick)
	if(!LAZYLEN(charging_batteries) || !anchored || (machine_stat & (BROKEN|NOPOWER)))
		return

	var/list/charging_queue
	for(var/obj/item/stock_parts/power_store/cell/battery_slot in charging_batteries)
		if(battery_slot.percent() >= 100)
			continue
		LAZYADD(charging_queue, battery_slot)

	if(!LAZYLEN(charging_queue))
		return

	use_energy(charge_rate / length(charging_queue) * seconds_per_tick * 0.01)

	for(var/obj/item/stock_parts/power_store/cell/charging_cell in charging_queue)
		charge_cell(charge_rate * seconds_per_tick, charging_cell)

	LAZYNULL(charging_queue)
	update_appearance()

/obj/machinery/cell_charger_multi/attack_tk(mob/user)
	if(!LAZYLEN(charging_batteries))
		return

	to_chat(user, span_notice("You telekinetically remove [removecell(user)] from [src]."))

	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/cell_charger_multi/RefreshParts()
	. = ..()
	var/tier_total
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		tier_total += capacitor.tier
	charge_rate = tier_total * (initial(charge_rate) / 6)

/obj/machinery/cell_charger_multi/emp_act(severity)
	. = ..()

	if(machine_stat & (BROKEN|NOPOWER) || . & EMP_PROTECT_CONTENTS)
		return

	for(var/obj/item/stock_parts/power_store/cell/charging in charging_batteries)
		charging.emp_act(severity)

/obj/machinery/cell_charger_multi/on_deconstruction(disassembled)
	for(var/obj/item/stock_parts/power_store/cell/charging in charging_batteries)
		charging.forceMove(drop_location())
	LAZYNULL(charging_batteries)
	return ..()

/obj/machinery/cell_charger_multi/attack_ai(mob/user)
	return

/obj/machinery/cell_charger_multi/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	var/obj/item/stock_parts/power_store/cell/charging = removecell(user)

	if(!charging)
		return

	user.put_in_hands(charging)
	charging.add_fingerprint(user)

	user.visible_message(span_notice("[user] removes [charging] from [src]."), span_notice("You remove [charging] from [src]."))

/obj/machinery/cell_charger_multi/proc/removecell(mob/user)
	if(!LAZYLEN(charging_batteries))
		return FALSE
	var/obj/item/stock_parts/power_store/cell/charging
	if(LAZYLEN(charging_batteries) > 1 && user)
		var/list/buttons = list()
		for(var/obj/item/stock_parts/power_store/cell/battery in charging_batteries)
			buttons["[battery.name] ([round(battery.percent(), 1)]%)"] = battery
		var/cell_name = tgui_input_list(user, "Please choose what cell you'd like to remove.", "Remove a cell", buttons)
		charging = buttons[cell_name]
	else
		charging = LAZYACCESS(charging_batteries, 1)
	if(!charging)
		return FALSE
	charging.forceMove(drop_location())
	charging.update_appearance()
	LAZYREMOVE(charging_batteries, charging)
	update_appearance()
	return charging

/obj/machinery/cell_charger_multi/Destroy()
	for(var/obj/item/stock_parts/power_store/cell/charging in charging_batteries)
		QDEL_NULL(charging)
	LAZYNULL(charging_batteries)
	return ..()
