/obj/machinery/power/particle_accelerator/control_box
	name = "Particle Accelerator Control Console"
	desc = "This controls the density of accelerated particles."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "control_box"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 500
	active_power_usage = 100000
	can_change_cable_layer = TRUE
	dir = NORTH
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	processing_flags = START_PROCESSING_MANUALLY
	var/strength_upper_limit = 2
	var/interface_control = TRUE
	var/list/obj/structure/particle_accelerator/connected_parts
	var/assembled = FALSE
	var/construction_state = PA_CONSTRUCTION_UNSECURED
	var/active = FALSE
	var/powered = FALSE
	var/strength = 0
	var/static/list/strength_power_usage = list(
		50000,
		125000,
		250000,
		500000,
	)

/obj/machinery/power/particle_accelerator/control_box/Initialize(mapload)
	. = ..()
	set_wires(new /datum/wires/particle_accelerator/control_box(src))
	connected_parts = list()
	active_power_usage = get_required_power()
	if(mapload && anchored)
		connect_to_network()

/obj/machinery/power/particle_accelerator/control_box/Destroy()
	if(active)
		toggle_power()
	for(var/obj/structure/particle_accelerator/part as anything in connected_parts)
		part.master = null
	connected_parts.Cut()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/power/particle_accelerator/control_box/multitool_act(mob/living/user, obj/item/tool)
	if(construction_state == PA_CONSTRUCTION_PANEL_OPEN)
		wires.interact(user)
		return TRUE
	return ..()

/obj/machinery/power/particle_accelerator/control_box/proc/update_state()
	if(construction_state < PA_CONSTRUCTION_COMPLETE)
		set_active(FALSE)
		assembled = FALSE
		for(var/obj/structure/particle_accelerator/part as anything in connected_parts)
			part.strength = null
			part.powered = FALSE
			part.update_appearance()
		connected_parts.Cut()
		return
	if(!part_scan())
		set_active(FALSE)
		connected_parts.Cut()
		return
	active_power_usage = get_required_power()

/obj/machinery/power/particle_accelerator/control_box/update_icon_state()
	if(active && powered && strength == 3)
		icon_state = "control_boxp3"
	else if(active && powered)
		icon_state = "control_boxp1"
	else if(active)
		icon_state = assembled ? "control_boxp" : "ucontrol_boxp"
	else if(assembled)
		icon_state = assembled ? "control_boxp" : "ucontrol_boxp"
	else
		switch(construction_state)
			if(PA_CONSTRUCTION_UNSECURED, PA_CONSTRUCTION_UNWIRED)
				icon_state = "control_box"
			if(PA_CONSTRUCTION_PANEL_OPEN)
				icon_state = "control_boxw"
			else
				icon_state = "control_boxc"
	return ..()

/obj/machinery/power/particle_accelerator/control_box/proc/strength_change()
	active_power_usage = get_required_power()
	for(var/obj/structure/particle_accelerator/part as anything in connected_parts)
		part.strength = strength
		part.update_appearance()

/obj/machinery/power/particle_accelerator/control_box/proc/add_strength()
	if(!assembled || strength >= strength_upper_limit)
		return
	strength++
	strength_change()
	message_admins("PA Control Computer increased to [strength] by [ADMIN_LOOKUPFLW(usr)] in [ADMIN_VERBOSEJMP(src)].")
	log_game("PA Control Computer increased to [strength] by [key_name(usr)] in [AREACOORD(src)].")
	investigate_log("increased to [strength] by [key_name(usr)] at [AREACOORD(src)].", INVESTIGATE_ENGINE)

/obj/machinery/power/particle_accelerator/control_box/proc/remove_strength()
	if(!assembled || strength <= 0)
		return
	strength--
	strength_change()
	message_admins("PA Control Computer decreased to [strength] by [ADMIN_LOOKUPFLW(usr)] in [ADMIN_VERBOSEJMP(src)].")
	log_game("PA Control Computer decreased to [strength] by [key_name(usr)] in [AREACOORD(src)].")
	investigate_log("decreased to [strength] by [key_name(usr)] at [AREACOORD(src)].", INVESTIGATE_ENGINE)

/obj/machinery/power/particle_accelerator/control_box/process(seconds_per_tick)
	if(!active)
		return PROCESS_KILL
	if(!powernet)
		connect_to_network()
	if(!powernet)
		set_powered(FALSE)
		return
	if(connected_parts.len < 6)
		investigate_log("lost a connected part; it powered down.", INVESTIGATE_ENGINE)
		set_active(FALSE)
		update_appearance()
		return

	var/power_usage = get_required_power() * seconds_per_tick
	if(surplus() < power_usage)
		set_powered(FALSE)
		return

	add_load(power_usage)
	set_powered(TRUE)

	var/list/ready_emitters = list()
	for(var/obj/structure/particle_accelerator/part as anything in connected_parts)
		if(!istype(part, /obj/structure/particle_accelerator/particle_emitter))
			continue
		var/obj/structure/particle_accelerator/particle_emitter/emitter = part
		if(!emitter.can_emit_particle())
			continue
		ready_emitters += emitter

	if(!length(ready_emitters))
		return

	for(var/obj/structure/particle_accelerator/particle_emitter/emitter as anything in ready_emitters)
		emitter.emit_particle(strength)

/obj/machinery/power/particle_accelerator/control_box/proc/get_required_power()
	var/index = clamp(strength + 1, 1, length(strength_power_usage))
	return strength_power_usage[index]

/obj/machinery/power/particle_accelerator/control_box/proc/get_available_power()
	if(!powernet)
		connect_to_network()
	return powernet ? energy_to_power(surplus()) : 0

/obj/machinery/power/particle_accelerator/control_box/proc/set_powered(new_powered)
	if(powered == new_powered)
		return
	powered = new_powered
	for(var/obj/structure/particle_accelerator/part as anything in connected_parts)
		part.powered = powered
		part.update_appearance()
	update_appearance()

/obj/machinery/power/particle_accelerator/control_box/should_have_node()
	return anchored

/obj/machinery/power/particle_accelerator/control_box/proc/part_scan()
	var/left_dir = turn(dir, -90)
	var/right_dir = turn(dir, 90)
	var/opposite_dir = turn(dir, 180)
	var/turf/current_turf = loc
	assembled = FALSE
	critical_machine = FALSE

	var/obj/structure/particle_accelerator/fuel_chamber/fuel_chamber = locate() in orange(1, src)
	if(!fuel_chamber)
		return FALSE

	setDir(fuel_chamber.dir)
	connected_parts.Cut()

	current_turf = get_step(current_turf, right_dir)
	if(!check_part(current_turf, /obj/structure/particle_accelerator/fuel_chamber))
		return FALSE
	current_turf = get_step(current_turf, opposite_dir)
	if(!check_part(current_turf, /obj/structure/particle_accelerator/end_cap))
		return FALSE
	current_turf = get_step(current_turf, dir)
	current_turf = get_step(current_turf, dir)
	if(!check_part(current_turf, /obj/structure/particle_accelerator/power_box))
		return FALSE
	current_turf = get_step(current_turf, dir)
	if(!check_part(current_turf, /obj/structure/particle_accelerator/particle_emitter/center))
		return FALSE
	current_turf = get_step(current_turf, left_dir)
	if(!check_part(current_turf, /obj/structure/particle_accelerator/particle_emitter/left))
		return FALSE
	current_turf = get_step(current_turf, right_dir)
	current_turf = get_step(current_turf, right_dir)
	if(!check_part(current_turf, /obj/structure/particle_accelerator/particle_emitter/right))
		return FALSE

	assembled = TRUE
	critical_machine = TRUE
	return TRUE

/obj/machinery/power/particle_accelerator/control_box/proc/check_part(turf/checked_turf, part_type)
	var/obj/structure/particle_accelerator/part = locate(/obj/structure/particle_accelerator) in checked_turf
	if(!istype(part, part_type) || part.construction_state != PA_CONSTRUCTION_COMPLETE)
		return FALSE
	if(!part.connect_master(src))
		return FALSE
	connected_parts += part
	return TRUE

/obj/machinery/power/particle_accelerator/control_box/proc/set_active(new_active)
	if(new_active && !part_scan())
		return FALSE
	if(active == new_active)
		return TRUE

	active = new_active
	if(active)
		active_power_usage = get_required_power()
		if(!powernet)
			connect_to_network()
		begin_processing()
	else
		set_powered(FALSE)
		end_processing()
	for(var/obj/structure/particle_accelerator/part as anything in connected_parts)
		part.strength = active ? strength : null
		part.powered = active && powered
		part.update_appearance()
	update_appearance()
	return TRUE

/obj/machinery/power/particle_accelerator/control_box/proc/toggle_power()
	if(!set_active(!active))
		return FALSE
	investigate_log("turned [active ? "ON" : "OFF"] by [usr ? key_name(usr) : "outside forces"] at [AREACOORD(src)].", INVESTIGATE_ENGINE)
	message_admins("PA Control Computer turned [active ? "ON" : "OFF"] by [usr ? ADMIN_LOOKUPFLW(usr) : "outside forces"] in [ADMIN_VERBOSEJMP(src)].")
	log_game("PA Control Computer turned [active ? "ON" : "OFF"] by [usr ? "[key_name(usr)]" : "outside forces"] at [AREACOORD(src)].")
	return TRUE

/obj/machinery/power/particle_accelerator/control_box/examine(mob/user)
	. = ..()
	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			. += span_notice("Looks like it is not attached to the flooring.")
		if(PA_CONSTRUCTION_UNWIRED)
			. += span_notice("It is missing some cables.")
		if(PA_CONSTRUCTION_PANEL_OPEN)
			. += span_notice("The panel is open.")
		if(PA_CONSTRUCTION_COMPLETE)
			. += span_notice("Required power is <b>[display_power(get_required_power(), convert = FALSE)]</b>.")
			if(powernet)
				. += span_notice("Available excess power is <b>[display_power(surplus())]</b>.")
			else
				. += span_warning("It is not connected to a power cable.")

/obj/machinery/power/particle_accelerator/control_box/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	var/did_something = FALSE
	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			if(item.tool_behaviour == TOOL_WRENCH && !isinspace())
				item.play_tool_sound(src, 75)
				set_anchored(TRUE)
				connect_to_network()
				user.visible_message(span_notice("[user] secures [src] to the floor."), span_notice("You secure the external bolts."))
				construction_state = PA_CONSTRUCTION_UNWIRED
				did_something = TRUE
		if(PA_CONSTRUCTION_UNWIRED)
			if(item.tool_behaviour == TOOL_WRENCH)
				item.play_tool_sound(src, 75)
				set_anchored(FALSE)
				disconnect_from_network()
				user.visible_message(span_notice("[user] detaches [src] from the floor."), span_notice("You remove the external bolts."))
				construction_state = PA_CONSTRUCTION_UNSECURED
				did_something = TRUE
			else if(istype(item, /obj/item/stack/cable_coil))
				if(item.use_tool(src, user, 0, amount = 1))
					user.visible_message(span_notice("[user] adds wires to [src]."), span_notice("You add some wires."))
					construction_state = PA_CONSTRUCTION_PANEL_OPEN
					did_something = TRUE
		if(PA_CONSTRUCTION_PANEL_OPEN)
			if(item.tool_behaviour == TOOL_WIRECUTTER)
				user.visible_message(span_notice("[user] removes some wires from [src]."), span_notice("You remove some wires."))
				construction_state = PA_CONSTRUCTION_UNWIRED
				did_something = TRUE
			else if(item.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message(span_notice("[user] closes [src]'s access panel."), span_notice("You close the access panel."))
				construction_state = PA_CONSTRUCTION_COMPLETE
				did_something = TRUE
		if(PA_CONSTRUCTION_COMPLETE)
			if(item.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message(span_notice("[user] opens [src]'s access panel."), span_notice("You open the access panel."))
				construction_state = PA_CONSTRUCTION_PANEL_OPEN
				did_something = TRUE

	if(did_something)
		update_state()
		update_appearance()
		return TRUE
	return ..()

/obj/machinery/power/particle_accelerator/control_box/blob_act(obj/structure/blob/blob)
	if(prob(50))
		qdel(src)

/obj/machinery/power/particle_accelerator/control_box/interact(mob/user)
	if(construction_state == PA_CONSTRUCTION_PANEL_OPEN)
		wires.interact(user)
	else
		..()

/obj/machinery/power/particle_accelerator/control_box/proc/is_interactive(mob/user)
	if(!interface_control)
		to_chat(user, span_alert("ERROR: Request timed out. Check wire contacts."))
		return FALSE
	return construction_state == PA_CONSTRUCTION_COMPLETE

/obj/machinery/power/particle_accelerator/control_box/ui_status(mob/user)
	if(is_interactive(user))
		return ..()
	return UI_CLOSE

/obj/machinery/power/particle_accelerator/control_box/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ParticleAccelerator", name)
		ui.open()

/obj/machinery/power/particle_accelerator/control_box/ui_data(mob/user)
	var/list/data = list()
	data["assembled"] = assembled
	data["power"] = active
	data["powered"] = powered
	data["strength"] = strength
	data["power_required"] = get_required_power()
	data["power_available"] = get_available_power()
	data["powernet_connected"] = !!powernet
	data["power_enough"] = data["power_available"] >= data["power_required"]
	return data

/obj/machinery/power/particle_accelerator/control_box/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	switch(action)
		if("power")
			if(wires.is_cut(WIRE_POWER))
				return
			toggle_power()
			. = TRUE
		if("scan")
			part_scan()
			. = TRUE
		if("add_strength")
			if(wires.is_cut(WIRE_STRENGTH))
				return
			add_strength()
			. = TRUE
		if("remove_strength")
			if(wires.is_cut(WIRE_STRENGTH))
				return
			remove_strength()
			. = TRUE
	update_appearance()
