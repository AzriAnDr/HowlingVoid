/datum/armor/particle_accelerator
	melee = 30
	bullet = 20
	laser = 20
	fire = 90
	acid = 80

/obj/structure/particle_accelerator
	name = "Particle Accelerator"
	desc = "Part of a Particle Accelerator."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "none"
	anchored = FALSE
	density = TRUE
	max_integrity = 500
	armor_type = /datum/armor/particle_accelerator
	var/obj/machinery/power/particle_accelerator/control_box/master
	var/construction_state = PA_CONSTRUCTION_UNSECURED
	var/reference
	var/powered = FALSE
	var/strength

/obj/structure/particle_accelerator/examine(mob/user)
	. = ..()
	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			. += span_notice("Looks like it is not attached to the flooring.")
		if(PA_CONSTRUCTION_UNWIRED)
			. += span_notice("It is missing some cables.")
		if(PA_CONSTRUCTION_PANEL_OPEN)
			. += span_notice("The panel is open.")

/obj/structure/particle_accelerator/Destroy()
	construction_state = PA_CONSTRUCTION_UNSECURED
	if(master)
		master.connected_parts -= src
		master.assembled = FALSE
		master = null
	return ..()

/obj/structure/particle_accelerator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_rotation)

/obj/structure/particle_accelerator/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
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

/obj/structure/particle_accelerator/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(drop_location(), 5)

/obj/structure/particle_accelerator/Move()
	. = ..()
	if(master && master.active)
		master.toggle_power()
		investigate_log("was moved while active; it powered down.", INVESTIGATE_ENGINE)

/obj/structure/particle_accelerator/update_icon_state()
	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED, PA_CONSTRUCTION_UNWIRED)
			icon_state = "[reference]"
		if(PA_CONSTRUCTION_PANEL_OPEN)
			icon_state = "[reference]w"
		if(PA_CONSTRUCTION_COMPLETE)
			if(powered)
				icon_state = "[reference]p[strength]"
			else
				icon_state = "[reference]c"
	return ..()

/obj/structure/particle_accelerator/proc/update_state()
	if(master)
		master.update_state()

/obj/structure/particle_accelerator/proc/connect_master(obj/machinery/power/particle_accelerator/control_box/control_box)
	if(control_box.dir != dir)
		return FALSE
	master = control_box
	return TRUE

/obj/structure/particle_accelerator/end_cap
	name = "Alpha Particle Generation Array"
	desc = "This is where alpha particles are generated from \[REDACTED\]."
	icon_state = "end_cap"
	reference = "end_cap"

/obj/structure/particle_accelerator/power_box
	name = "Particle Focusing EM Lens"
	desc = "This uses electromagnetic waves to focus alpha particles."
	icon_state = "power_box"
	reference = "power_box"

/obj/structure/particle_accelerator/fuel_chamber
	name = "EM Acceleration Chamber"
	desc = "This is where the alpha particles are accelerated to radical speeds."
	icon_state = "fuel_chamber"
	reference = "fuel_chamber"
