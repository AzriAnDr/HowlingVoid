/**
 * # Power Transmission Laser (PTL/BFL)
 *
 * A massive laser that can sell power to CentCom or target megafauna on lavaland.
 * Ported from Paradise-SS220 goonstation module.
 *
 * Engineering can build this to sell excess power for credits, or use it to
 * assist mining by targeting megafauna on lavaland.
 */

#define PTL_MINIMUM_POWER (1 MEGA WATTS)
#define PTL_DEFAULT_CAPACITY (2000 GIGA JOULES)
#define PTL_EYE_DAMAGE_THRESHOLD (5 MEGA WATTS)
#define PTL_RAD_THRESHOLD (30 MEGA WATTS)

// Selling defines
#define PTL_MINIMUM_BAR 0
#define PTL_PROCESS_CAP (6 - PTL_MINIMUM_BAR)
#define PTL_A1_CURVE 20
#define PTL_HIGH_CUT_RATIO 0.75
#define PTL_MEDIUM_CUT_RATIO 0.25

GLOBAL_LIST_EMPTY(ptl_lasers)

/obj/item/circuitboard/machine/transmission_laser
	name = "Power Transmission Laser"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/transmission_laser
	req_components = list(
		/obj/item/stock_parts/capacitor = 3,
		/obj/item/stock_parts/micro_laser = 3,
	)

/obj/machinery/power/transmission_laser
	name = "power transmission laser"
	desc = "Sends power over a giant laser beam to an NT power processing facility. Can also target megafauna on lavaland."
	icon = 'icons/obj/machines/pt_laser.dmi'
	icon_state = "ptl"
	base_icon_state = "ptl"
	max_integrity = 500
	density = TRUE
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/machine/transmission_laser
	can_change_cable_layer = TRUE
	pixel_y = -64

	/// How far we shoot the beam. If it isn't blocked it should go to the end of the z level.
	var/range = 0
	/// Amount of power we are outputting
	var/output_level = 0
	/// The total capacity of the laser
	var/capacity = PTL_DEFAULT_CAPACITY
	/// Our current stored energy
	var/charge = 0
	/// Are we trying to provide power to the laser
	var/input_attempt = TRUE
	/// Are we currently inputting power into the laser
	var/inputting = TRUE
	/// The amount of energy coming in from the inputs last tick
	var/input_available = 0
	/// Have we been switched on?
	var/turned_on = FALSE
	/// Are we attempting to fire the laser currently?
	var/firing = FALSE
	/// We need to create a list of all lasers we are creating so we can delete them in the end
	var/list/laser_effects = list()
	/// Our max load we can set
	var/max_grid_load = 0
	/// The load we place on the power grid we are connected to
	var/current_grid_load = 0
	/// Signifies which unit we are using for input power
	var/power_format_multi = 1
	/// Signifies which unit we are using for output power
	var/power_format_multi_output = 1 MEGA WATTS

	/// How much energy have we sold in total (Joules)
	var/total_energy = 0
	/// How many credits we have earned in total
	var/total_earnings = 0
	/// The amount of money we haven't sent yet
	var/unsent_earnings = 0

	/// Gives our power input when multiplied with power_format_multi
	var/input_number = 0
	/// Gives our power output when multiplied with power_format_multi_output
	var/output_number = 1
	/// Our set input pulling
	var/input_pulling = 0

	/// Targetable areas in lavaland
	var/static/list/targetable_areas = list(
		/area/lavaland/surface/outdoors,
		/area/icemoon/surface/outdoors,
	)
	/// PTL target
	var/atom/target

/obj/machinery/power/transmission_laser/north
	pixel_x = -64
	pixel_y = 0
	dir = NORTH

/obj/machinery/power/transmission_laser/east
	pixel_y = 0
	dir = EAST

/obj/machinery/power/transmission_laser/west
	pixel_x = -64
	pixel_y = 0
	dir = WEST

/obj/machinery/power/transmission_laser/Initialize(mapload)
	. = ..()
	GLOB.ptl_lasers += src
	range = get_dist(get_front_turf(), get_edge_target_turf(get_front_turf(), dir))
	connect_to_network()
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/power/transmission_laser/Destroy()
	GLOB.ptl_lasers -= src
	if(length(laser_effects))
		destroy_lasers()
	if(target)
		untarget()
	return ..()

/obj/machinery/power/transmission_laser/examine(mob/user)
	. = ..()
	. += span_notice("It currently has [unsent_earnings] unsent credits.")
	. += span_notice("It has generated [total_earnings] total credits.")
	. += span_notice("It has sold [display_energy(total_energy)] total.")

/obj/machinery/power/transmission_laser/RefreshParts()
	. = ..()
	// Better capacitors increase capacity
	var/cap_rating = 0
	for(var/datum/stock_part/capacitor/cap in component_parts)
		cap_rating += cap.tier
	capacity = initial(capacity) * (cap_rating / 3)

	// Better lasers increase power efficiency (less eye damage threshold)
	var/laser_rating = 0
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		laser_rating += laser.tier

/obj/machinery/power/transmission_laser/update_overlays()
	. = ..()
	if((machine_stat & BROKEN) || !charge)
		. += "unpowered"
		return
	if(input_available > 0)
		. += "green_light"
		. += emissive_appearance(icon, "green_light", src)
	if(turned_on)
		. += "red_light"
		. += emissive_appearance(icon, "red_light", src)
		if(firing)
			. += "firing"
			. += emissive_appearance(icon, "firing", src)

	var/charge_level = return_charge()
	if(charge_level == 6)
		. += "charge_full"
		. += emissive_appearance(icon, "charge_full", src)
	else if(charge_level > 0)
		. += "charge_[charge_level]"
		. += emissive_appearance(icon, "charge_[charge_level]", src)

/// Returns the charge level from [0 to 6]
/obj/machinery/power/transmission_laser/proc/return_charge()
	if(!output_level)
		return 0
	return min(round((charge / abs(output_level)) * 6), 6)

/obj/machinery/power/transmission_laser/proc/get_front_turf()
	var/turf/center = locate(x + 1 + round(pixel_x / 32), y + 1 + round(pixel_y / 32), z)
	return get_step(center, dir)

/obj/machinery/power/transmission_laser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PowerTransmissionLaser")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/power/transmission_laser/ui_data(mob/user)
	var/list/data = list()

	data["output"] = output_level
	data["total_earnings"] = total_earnings
	data["unsent_earnings"] = unsent_earnings
	data["total_energy"] = total_energy
	data["held_power"] = charge
	data["max_capacity"] = capacity
	data["max_grid_load"] = max_grid_load

	data["accepting_power"] = turned_on
	data["sucking_power"] = inputting
	data["firing"] = firing
	data["target"] = target ? target.ptl_data() : ""

	data["power_format"] = power_format_multi
	data["input_number"] = input_number
	data["avalible_input"] = input_available
	data["output_number"] = output_number
	data["output_multiplier"] = power_format_multi_output
	data["input_total"] = input_number * power_format_multi
	data["output_total"] = output_number * power_format_multi_output

	return data

/obj/machinery/power/transmission_laser/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_input")
			turned_on = !turned_on
			update_appearance(UPDATE_OVERLAYS)
		if("toggle_output")
			firing = !firing
			if(!firing)
				destroy_lasers()
			else
				setup_lasers()
			update_appearance(UPDATE_OVERLAYS)
		if("target")
			select_target(usr)

		if("set_input")
			input_number = clamp(params["set_input"], 0, 999)
		if("set_output")
			output_number = clamp(params["set_output"], 1, 999)

		if("inputW")
			power_format_multi = 1
		if("inputKW")
			power_format_multi = 1 KILO WATTS
		if("inputMW")
			power_format_multi = 1 MEGA WATTS
		if("inputGW")
			power_format_multi = 1 GIGA WATTS

		if("outputW")
			power_format_multi_output = 1
		if("outputKW")
			power_format_multi_output = 1 KILO WATTS
		if("outputMW")
			power_format_multi_output = 1 MEGA WATTS
		if("outputGW")
			power_format_multi_output = 1 GIGA WATTS

/// Target a megafauna or laser terminal
/obj/machinery/power/transmission_laser/proc/select_target(mob/user)
	var/list/target_list = list()

	// Find megafauna in targetable areas
	for(var/mob/living/basic/boss/megafauna in GLOB.mob_living_list)
		var/area/boss_loc = get_area(megafauna)
		for(var/area_type in targetable_areas)
			if(istype(boss_loc, area_type))
				target_list["[megafauna.name] ([get_area_name(megafauna)])"] = megafauna
				break

	// Find laser terminals
	for(var/obj/machinery/power/laser_terminal/receptacle in GLOB.ptl_terminals)
		target_list["[receptacle.name]: [receptacle.id]"] = receptacle

	// Target CC to sell power
	target_list["Collection Terminal (Sell Power)"] = null

	var/choose = tgui_input_list(user, "Select target", "Target", target_list)
	if(!choose)
		return
	untarget()
	target = target_list[choose]
	if(target)
		target.on_ptl_target(src)

/// Stop targeting
/obj/machinery/power/transmission_laser/proc/untarget()
	SIGNAL_HANDLER
	if(target)
		target.on_ptl_untarget(src)
	target = null

/obj/machinery/power/transmission_laser/process(seconds_per_tick)
	max_grid_load = surplus()
	input_available = surplus()

	if(machine_stat & BROKEN)
		return

	if(powernet && input_attempt && turned_on)
		input_pulling = min(input_available, input_number * power_format_multi, capacity - charge)

		if(inputting)
			if(input_pulling > 0)
				add_load(input_pulling)
				charge += input_pulling
			else
				inputting = FALSE
		else
			if(input_attempt && input_pulling > 0)
				inputting = TRUE
	else
		inputting = FALSE

	if(charge < PTL_MINIMUM_POWER)
		firing = FALSE
		output_level = 0
		destroy_lasers()
		update_appearance(UPDATE_OVERLAYS)
		return

	if(!firing)
		return

	output_level = min(charge, output_number * power_format_multi_output)

	if(firing)
		if(!target)
			sell_power(output_level * (seconds_per_tick * 2))
		else
			if(!QDELETED(target))
				INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, on_ptl_tick), src, output_level)
			else
				target = null

		if(output_level > PTL_EYE_DAMAGE_THRESHOLD)
			for(var/mob/living/carbon/someone in oview(min(output_level / PTL_EYE_DAMAGE_THRESHOLD, 8), get_front_turf()))
				var/turf/front = get_front_turf()
				var/turf/step_turf = get_step(get_front_turf(), dir)
				var/d_x = someone.x - front.x
				var/d_y = someone.y - front.y
				if(someone.dir == dir || (((dir == NORTH || dir == SOUTH) && (SIGN(d_y) != SIGN(step_turf.y - front.y)))) || ((dir == WEST || dir == EAST) && (SIGN(d_x) != SIGN(step_turf.x - front.x))))
					continue
				var/look_angle
				var/angle_to_bore = arctan(-d_x, -d_y)
				switch(someone.dir)
					if(NORTH)
						look_angle = 90
					if(SOUTH)
						look_angle = -90
					if(EAST)
						look_angle = 0
					if(WEST)
						look_angle = 180
				var/flashmod = max(cos(look_angle - angle_to_bore), 0)
				someone.flash_act(min(round(output_level / PTL_EYE_DAMAGE_THRESHOLD), 3) * flashmod, TRUE, TRUE)

		if(output_level > PTL_RAD_THRESHOLD)
			radiation_pulse(get_front_turf(), (output_level / PTL_RAD_THRESHOLD) * 200, RAD_MEDIUM_INSULATION)

	charge -= output_level

/obj/machinery/power/transmission_laser/proc/sell_power(joules)
	var/mega_joules = joules / (1 MEGA WATTS)
	SSblackbox.record_feedback("amount", "ptl_power_sold", joules)

	var/generated_cash = (2 * mega_joules * PTL_PROCESS_CAP) / ((2 * mega_joules) + (PTL_PROCESS_CAP * PTL_A1_CURVE))
	if(mega_joules)
		generated_cash += (4 * mega_joules * PTL_MINIMUM_BAR) / (4 * mega_joules + PTL_MINIMUM_BAR)
	if(generated_cash < 0)
		return

	total_energy += joules
	total_earnings += generated_cash
	unsent_earnings += generated_cash

	if(unsent_earnings > 200)
		var/cargo_cut = round(unsent_earnings * PTL_MEDIUM_CUT_RATIO)
		var/engineering_cut = round(unsent_earnings * PTL_HIGH_CUT_RATIO)
		var/recorded_power_income = 0

		var/datum/bank_account/cargo_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
		var/datum/bank_account/engineering_account = SSeconomy.get_dep_account(ACCOUNT_ENG)

		if(cargo_account)
			cargo_account.adjust_money(cargo_cut, "PTL: Power Sale")
			SSeconomy.record_department_income(ACCOUNT_CAR, "ptl_power_sales", cargo_cut)
			recorded_power_income += cargo_cut
			unsent_earnings -= cargo_cut

		if(engineering_account)
			engineering_account.adjust_money(engineering_cut, "PTL: Power Sale")
			SSeconomy.record_department_income(ACCOUNT_ENG, "ptl_power_sales", engineering_cut)
			recorded_power_income += engineering_cut
			unsent_earnings -= engineering_cut

		if(recorded_power_income)
			SSeconomy.record_gsp("ptl_power_sales", recorded_power_income)

/// Setup or refresh the beam visual
/obj/machinery/power/transmission_laser/proc/setup_lasers()
	if(target)
		target.on_ptl_fire()
	var/turf/last_step = get_step(get_front_turf(), dir)
	for(var/num in 1 to range)
		if(!(locate(/obj/effect/transmission_beam) in last_step))
			var/obj/effect/transmission_beam/new_beam = new(last_step, src)
			new_beam.host = src
			new_beam.dir = dir
			laser_effects += new_beam
		last_step = get_step(last_step, dir)

/obj/machinery/power/transmission_laser/proc/destroy_lasers()
	if(target)
		target.on_ptl_stop()
	for(var/obj/effect/transmission_beam/listed_beam as anything in laser_effects)
		laser_effects -= listed_beam
		qdel(listed_beam)

/obj/machinery/power/transmission_laser/screwdriver_act(mob/living/user, obj/item/tool)
	if(firing)
		to_chat(user, span_info("Turn the laser off first."))
		return ITEM_INTERACT_BLOCKING
	return default_deconstruction_screwdriver(user, icon_state, icon_state, tool)

/obj/machinery/power/transmission_laser/crowbar_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		return ITEM_INTERACT_BLOCKING
	return default_deconstruction_crowbar(tool)

/obj/machinery/power/transmission_laser/wrench_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		return ITEM_INTERACT_BLOCKING
	return default_unfasten_wrench(user, tool)

// Transmission beam effect
/obj/effect/transmission_beam
	name = "shimmering beam"
	icon = 'icons/obj/machines/pt_beam.dmi'
	icon_state = "ptl_beam"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	/// Ref to the PTL creating this beam
	var/obj/machinery/power/transmission_laser/host

/obj/effect/transmission_beam/Initialize(mapload, obj/machinery/power/transmission_laser/creator)
	. = ..()
	host = creator
	update_appearance()

/obj/effect/transmission_beam/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "ptl_beam", src)

/obj/effect/transmission_beam/ex_act(severity)
	return FALSE

// PTL atom procs - these allow atoms to be targeted by the PTL
/atom/proc/on_ptl_target(obj/machinery/power/transmission_laser/ptl)
	if(ptl.firing)
		on_ptl_fire()
	return

/atom/proc/on_ptl_tick(obj/machinery/power/transmission_laser/ptl, output_level)
	return

/atom/proc/on_ptl_untarget(obj/machinery/power/transmission_laser/ptl)
	return

/atom/proc/on_ptl_fire(obj/machinery/power/transmission_laser/ptl)
	return

/atom/proc/on_ptl_stop(obj/machinery/power/transmission_laser/ptl)
	return

/atom/proc/ptl_data()
	return name

// Megafauna PTL targeting
/mob/living/basic/boss/on_ptl_target(obj/machinery/power/transmission_laser/ptl)
	if(ptl.firing)
		on_ptl_fire(ptl)
	RegisterSignal(src, COMSIG_LIVING_DEATH, PROC_REF(on_ptl_death))

/mob/living/basic/boss/on_ptl_tick(obj/machinery/power/transmission_laser/ptl, output_level)
	var/damage = output_level / (10 MEGA WATTS)
	if(damage > 0)
		apply_damage(damage, BURN, spread_damage = TRUE)

/mob/living/basic/boss/proc/on_ptl_death(datum/source)
	SIGNAL_HANDLER
	for(var/obj/machinery/power/transmission_laser/ptl in GLOB.ptl_lasers)
		if(ptl.target == src)
			ptl.untarget()

/mob/living/basic/boss/on_ptl_untarget(obj/machinery/power/transmission_laser/ptl)
	on_ptl_stop(ptl)
	UnregisterSignal(src, COMSIG_LIVING_DEATH)

/mob/living/basic/boss/on_ptl_fire(obj/machinery/power/transmission_laser/ptl)
	visible_message(span_danger("A massive energy beam locks onto [src]!"))

/mob/living/basic/boss/on_ptl_stop(obj/machinery/power/transmission_laser/ptl)
	visible_message(span_notice("The energy beam targeting [src] dissipates."))

#undef PTL_MINIMUM_POWER
#undef PTL_DEFAULT_CAPACITY
#undef PTL_EYE_DAMAGE_THRESHOLD
#undef PTL_RAD_THRESHOLD
#undef PTL_MINIMUM_BAR
#undef PTL_PROCESS_CAP
#undef PTL_A1_CURVE
#undef PTL_HIGH_CUT_RATIO
#undef PTL_MEDIUM_CUT_RATIO
