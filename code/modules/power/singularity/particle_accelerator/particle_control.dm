/obj/machinery/particle_accelerator/control_box
	name = "Particle Accelerator Control Console"
	desc = "This controls the density of accelerated particles."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "control_box"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 500
	active_power_usage = 10000
	dir = NORTH
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	var/strength_upper_limit = 2
	var/interface_control = TRUE
	var/list/obj/structure/particle_accelerator/connected_parts
	var/assembled = FALSE
	var/construction_state = PA_CONSTRUCTION_UNSECURED
	var/active = FALSE
	var/strength = 0

/obj/machinery/particle_accelerator/control_box/Initialize(mapload)
	. = ..()
	set_wires(new /datum/wires/particle_accelerator/control_box(src))
	connected_parts = list()

/obj/machinery/particle_accelerator/control_box/Destroy()
	if(active)
		toggle_power()
	for(var/obj/structure/particle_accelerator/part as anything in connected_parts)
		part.master = null
	connected_parts.Cut()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/particle_accelerator/control_box/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	if(construction_state == PA_CONSTRUCTION_PANEL_OPEN)
		wires.interact(user)
		return TRUE

/obj/machinery/particle_accelerator/control_box/proc/update_state()
	if(construction_state < PA_CONSTRUCTION_COMPLETE)
		use_power = NO_POWER_USE
		assembled = FALSE
		active = FALSE
		for(var/obj/structure/particle_accelerator/part as anything in connected_parts)
			part.strength = null
			part.powered = FALSE
			part.update_appearance()
		connected_parts.Cut()
		return
	if(!part_scan())
		use_power = IDLE_POWER_USE
		active = FALSE
		connected_parts.Cut()

/obj/machinery/particle_accelerator/control_box/update_icon_state()
	if(active && strength == 3)
		icon_state = "control_boxp3"
	else if(active)
		icon_state = "control_boxp1"
	else if(use_power)
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

/obj/machinery/particle_accelerator/control_box/proc/strength_change()
	for(var/obj/structure/particle_accelerator/part as anything in connected_parts)
		part.strength = strength
		part.update_appearance()

/obj/machinery/particle_accelerator/control_box/proc/add_strength()
	if(!assembled || strength >= strength_upper_limit)
		return
	strength++
	strength_change()
	message_admins("PA Control Computer increased to [strength] by [ADMIN_LOOKUPFLW(usr)] in [ADMIN_VERBOSEJMP(src)].")
	log_game("PA Control Computer increased to [strength] by [key_name(usr)] in [AREACOORD(src)].")
	investigate_log("increased to [strength] by [key_name(usr)] at [AREACOORD(src)].", INVESTIGATE_ENGINE)

/obj/machinery/particle_accelerator/control_box/proc/remove_strength()
	if(!assembled || strength <= 0)
		return
	strength--
	strength_change()
	message_admins("PA Control Computer decreased to [strength] by [ADMIN_LOOKUPFLW(usr)] in [ADMIN_VERBOSEJMP(src)].")
	log_game("PA Control Computer decreased to [strength] by [key_name(usr)] in [AREACOORD(src)].")
	investigate_log("decreased to [strength] by [key_name(usr)] at [AREACOORD(src)].", INVESTIGATE_ENGINE)

/obj/machinery/particle_accelerator/control_box/power_change()
	. = ..()
	if(machine_stat & NOPOWER)
		active = FALSE
		use_power = NO_POWER_USE
	else if(!machine_stat && construction_state == PA_CONSTRUCTION_COMPLETE)
		use_power = IDLE_POWER_USE

/obj/machinery/particle_accelerator/control_box/process(seconds_per_tick)
	if(!active)
		return
	if(connected_parts.len < 6)
		investigate_log("lost a connected part; it powered down.", INVESTIGATE_ENGINE)
		toggle_power()
		update_appearance()
		return
	for(var/obj/structure/particle_accelerator/particle_emitter/emitter as anything in connected_parts)
		emitter.emit_particle(strength)

/obj/machinery/particle_accelerator/control_box/proc/part_scan()
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

/obj/machinery/particle_accelerator/control_box/proc/check_part(turf/checked_turf, part_type)
	var/obj/structure/particle_accelerator/part = locate(/obj/structure/particle_accelerator) in checked_turf
	if(!istype(part, part_type) || part.construction_state != PA_CONSTRUCTION_COMPLETE)
		return FALSE
	if(!part.connect_master(src))
		return FALSE
	connected_parts += part
	return TRUE

/obj/machinery/particle_accelerator/control_box/proc/toggle_power()
	active = !active
	investigate_log("turned [active ? "ON" : "OFF"] by [usr ? key_name(usr) : "outside forces"] at [AREACOORD(src)].", INVESTIGATE_ENGINE)
	message_admins("PA Control Computer turned [active ? "ON" : "OFF"] by [usr ? ADMIN_LOOKUPFLW(usr) : "outside forces"] in [ADMIN_VERBOSEJMP(src)].")
	log_game("PA Control Computer turned [active ? "ON" : "OFF"] by [usr ? "[key_name(usr)]" : "outside forces"] at [AREACOORD(src)].")
	use_power = active ? ACTIVE_POWER_USE : IDLE_POWER_USE
	for(var/obj/structure/particle_accelerator/part as anything in connected_parts)
		part.strength = active ? strength : null
		part.powered = active
		part.update_appearance()
	return TRUE

/obj/machinery/particle_accelerator/control_box/examine(mob/user)
	. = ..()
	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			. += span_notice("Looks like it is not attached to the flooring.")
		if(PA_CONSTRUCTION_UNWIRED)
			. += span_notice("It is missing some cables.")
		if(PA_CONSTRUCTION_PANEL_OPEN)
			. += span_notice("The panel is open.")

/obj/machinery/particle_accelerator/control_box/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	var/did_something = FALSE
	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			if(item.tool_behaviour == TOOL_WRENCH && !isinspace())
				item.play_tool_sound(src, 75)
				set_anchored(TRUE)
				user.visible_message(span_notice("[user] secures [src] to the floor."), span_notice("You secure the external bolts."))
				construction_state = PA_CONSTRUCTION_UNWIRED
				did_something = TRUE
		if(PA_CONSTRUCTION_UNWIRED)
			if(item.tool_behaviour == TOOL_WRENCH)
				item.play_tool_sound(src, 75)
				set_anchored(FALSE)
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

/obj/machinery/particle_accelerator/control_box/blob_act(obj/structure/blob/blob)
	if(prob(50))
		qdel(src)

/obj/machinery/particle_accelerator/control_box/interact(mob/user)
	if(construction_state == PA_CONSTRUCTION_PANEL_OPEN)
		wires.interact(user)
	else
		..()

/obj/machinery/particle_accelerator/control_box/proc/is_interactive(mob/user)
	if(!interface_control)
		to_chat(user, span_alert("ERROR: Request timed out. Check wire contacts."))
		return FALSE
	return construction_state == PA_CONSTRUCTION_COMPLETE

/obj/machinery/particle_accelerator/control_box/ui_status(mob/user)
	if(is_interactive(user))
		return ..()
	return UI_CLOSE

/obj/machinery/particle_accelerator/control_box/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ParticleAccelerator", name)
		ui.open()

/obj/machinery/particle_accelerator/control_box/ui_data(mob/user)
	var/list/data = list()
	data["assembled"] = assembled
	data["power"] = active
	data["strength"] = strength
	return data

/obj/machinery/particle_accelerator/control_box/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
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
