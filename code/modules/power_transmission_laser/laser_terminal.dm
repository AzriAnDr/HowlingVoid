/**
 * # Laser Terminal
 *
 * A receiver that can be placed on lavaland to receive power from the PTL.
 * Converts incoming laser power into usable power for the local grid.
 */

GLOBAL_LIST_EMPTY(ptl_terminals)

/obj/item/circuitboard/machine/laser_terminal
	name = "Laser Terminal"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/laser_terminal
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 2,
	)

/obj/machinery/power/laser_terminal
	name = "laser terminal"
	desc = "A terminal designed to capture power sent by the power transmission laser."
	icon = 'icons/obj/machines/ptl_terminal.dmi'
	icon_state = "ptl_terminal_0"
	base_icon_state = "ptl_terminal_0"
	pixel_y = 10
	density = TRUE
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/machine/laser_terminal
	can_change_cable_layer = TRUE

	/// How much of the received energy we end up outputting to the grid
	var/conversion_efficiency = 0.5
	/// List of lasers targeting us
	var/list/lasers = list()
	/// The amount of power coming into the terminal
	var/total_input = 0
	/// ID of the terminal so you know which one you're targeting
	var/id = 0

/obj/machinery/power/laser_terminal/Initialize(mapload)
	. = ..()
	id = rand(1000, 9999)
	GLOB.ptl_terminals += src
	connect_to_network()

/obj/machinery/power/laser_terminal/Destroy()
	GLOB.ptl_terminals -= src
	for(var/obj/machinery/power/transmission_laser/ptl in lasers)
		if(ptl.target == src)
			ptl.untarget()
	return ..()

/obj/machinery/power/laser_terminal/RefreshParts()
	. = ..()
	var/cap_rating = 0
	for(var/datum/stock_part/capacitor/cap in component_parts)
		cap_rating += cap.tier
	// Goes from half to full conversion depending on capacitor level
	conversion_efficiency = cap_rating / 8

/obj/machinery/power/laser_terminal/examine(mob/user)
	. = ..()
	. += span_notice("Terminal ID: [id]")
	. += span_notice("Input Power: [display_power(total_input)]")
	. += span_notice("Output Power: [display_power(total_input * conversion_efficiency)]")
	. += span_notice("Conversion efficiency: [conversion_efficiency * 100]%")

/obj/machinery/power/laser_terminal/on_ptl_target(obj/machinery/power/transmission_laser/ptl)
	lasers |= ptl

/obj/machinery/power/laser_terminal/on_ptl_untarget(obj/machinery/power/transmission_laser/ptl)
	lasers -= ptl

/obj/machinery/power/laser_terminal/on_ptl_tick(obj/machinery/power/transmission_laser/ptl, output_level)
	// Power is added in process() to batch from all PTLs

/obj/machinery/power/laser_terminal/update_overlays()
	. = ..()
	if(total_input > 0)
		. += "ptl_terminal_graph"
		. += "ptl_terminal_blinkers"
		. += "ptl_terminal_light"

	switch(total_input)
		if(1 MEGA WATTS to 10 MEGA WATTS)
			. += "ptl_terminal_bar_1"
		if(10 MEGA WATTS to 20 MEGA WATTS)
			. += "ptl_terminal_bar_2"
		if(20 MEGA WATTS to 50 MEGA WATTS)
			. += "ptl_terminal_bar_3"
		if(50 MEGA WATTS to 100 MEGA WATTS)
			. += "ptl_terminal_bar_4"
		if(100 MEGA WATTS to 1 GIGA WATTS)
			. += "ptl_terminal_bar_5"
		if(1 GIGA WATTS to INFINITY)
			. += "ptl_terminal_bar_6"

/obj/machinery/power/laser_terminal/process(seconds_per_tick)
	var/tick_input = 0
	for(var/obj/machinery/power/transmission_laser/ptl in lasers)
		if(ptl.firing)
			tick_input += ptl.output_level
	total_input = tick_input
	if(total_input > 0)
		add_avail(total_input * conversion_efficiency)
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/power/laser_terminal/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, icon_state, icon_state, tool)

/obj/machinery/power/laser_terminal/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(panel_open)
		to_chat(user, span_warning("Close the maintenance panel first!"))
		return
	. = default_unfasten_wrench(user, tool)
	if(anchored)
		connect_to_network()
	else
		disconnect_from_network()

/obj/machinery/power/laser_terminal/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/power/laser_terminal/multitool_act(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("Unit ID: [id]\nInput Power: [display_power(total_input)]\nOutput Power: [display_power(total_input * conversion_efficiency)]"))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/laser_terminal/ptl_data()
	return "Terminal #[id]"