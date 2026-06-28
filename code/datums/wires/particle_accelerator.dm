/datum/wires/particle_accelerator/control_box
	holder_type = /obj/machinery/power/particle_accelerator/control_box
	proper_name = "Particle Accelerator"

/datum/wires/particle_accelerator/control_box/New(atom/holder)
	wires = list(
		WIRE_POWER,
		WIRE_STRENGTH,
		WIRE_LIMIT,
		WIRE_INTERFACE,
	)
	add_duds(2)
	return ..()

/datum/wires/particle_accelerator/control_box/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/machinery/power/particle_accelerator/control_box/control_box = holder
	return control_box.construction_state == PA_CONSTRUCTION_PANEL_OPEN

/datum/wires/particle_accelerator/control_box/on_pulse(wire, mob/living/user)
	var/obj/machinery/power/particle_accelerator/control_box/control_box = holder
	switch(wire)
		if(WIRE_POWER)
			control_box.toggle_power()
		if(WIRE_STRENGTH)
			control_box.add_strength()
		if(WIRE_INTERFACE)
			control_box.interface_control = !control_box.interface_control
		if(WIRE_LIMIT)
			control_box.visible_message("[icon2html(control_box, viewers(holder))]<b>[control_box]</b> makes a large whirring noise.")

/datum/wires/particle_accelerator/control_box/on_cut(wire, mend, mob/living/source)
	var/obj/machinery/power/particle_accelerator/control_box/control_box = holder
	switch(wire)
		if(WIRE_POWER)
			if(control_box.active == !mend)
				control_box.toggle_power()
		if(WIRE_STRENGTH)
			for(var/i in 1 to 2)
				control_box.remove_strength()
		if(WIRE_INTERFACE)
			if(!mend)
				control_box.interface_control = FALSE
		if(WIRE_LIMIT)
			control_box.strength_upper_limit = mend ? 2 : 3
			if(control_box.strength_upper_limit < control_box.strength)
				control_box.remove_strength()

/datum/wires/particle_accelerator/control_box/emp_pulse()
	return
