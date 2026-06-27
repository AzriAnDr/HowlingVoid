#define RAD_COLLECTOR_EFFICIENCY 80
#define RAD_COLLECTOR_COEFFICIENT (125 KILO JOULES)
#define RAD_COLLECTOR_PLASMA_DRAIN 0.001
#define RAD_COLLECTOR_MINIMUM_PLASMA 0.0001

/// Converts strong radiation pulses and plasma fuel into smoothed electrical output.
/obj/machinery/power/energy_accumulator/rad_collector
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking radiation and plasma to produce power."
	icon = 'icons/obj/machines/engine/singularity.dmi'
	icon_state = "ca"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_ENGINE_EQUIP)
	max_integrity = 350
	integrity_failure = 0.2
	circuit = /obj/item/circuitboard/machine/rad_collector
	rad_insulation = RAD_EXTREME_INSULATION
	var/obj/item/tank/internals/plasma/loaded_tank
	var/active = FALSE
	var/locked = FALSE
	var/drainratio = 1
	var/obj/item/radio/radio

/obj/machinery/power/energy_accumulator/rad_collector/anchored
	anchored = TRUE

/obj/machinery/power/energy_accumulator/rad_collector/Initialize(mapload)
	. = ..()
	radio = new /obj/item/radio(src)
	radio.set_listening(FALSE)
	radio.set_frequency(FREQ_ENGINEERING)
	RegisterSignal(src, COMSIG_IN_RANGE_OF_IRRADIATION, PROC_REF(on_radiation_pulse))

/obj/machinery/power/energy_accumulator/rad_collector/Destroy()
	UnregisterSignal(src, COMSIG_IN_RANGE_OF_IRRADIATION)
	QDEL_NULL(radio)
	return ..()

/obj/machinery/power/energy_accumulator/rad_collector/process(seconds_per_tick)
	if(!active || !loaded_tank)
		return

	var/datum/gas_mixture/tank_mix = loaded_tank.return_air()
	var/plasma_moles = get_tank_gas_moles(tank_mix, /datum/gas/plasma)
	if(plasma_moles < RAD_COLLECTOR_MINIMUM_PLASMA)
		investigate_log("ran out of plasma fuel.", INVESTIGATE_ENGINE)
		playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
		radio?.talk_into(src, "Insufficient plasma in [get_area(src)] [src], ejecting [loaded_tank].", FREQ_ENGINEERING)
		eject()
		return

	var/gas_drained = min(RAD_COLLECTOR_PLASMA_DRAIN * drainratio * seconds_per_tick, plasma_moles)
	adjust_tank_gas_moles(tank_mix, /datum/gas/plasma, -gas_drained)
	adjust_tank_gas_moles(tank_mix, /datum/gas/tritium, gas_drained)
	return ..()

/obj/machinery/power/energy_accumulator/rad_collector/interact(mob/user)
	if(!anchored)
		balloon_alert(user, "secure it first!")
		return
	if(locked)
		to_chat(user, span_warning("The controls are locked!"))
		return
	toggle_power(user)

/obj/machinery/power/energy_accumulator/rad_collector/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(item, /obj/item/tank/internals/plasma))
		if(!anchored)
			to_chat(user, span_warning("[src] needs to be secured to the floor first!"))
			return TRUE
		if(loaded_tank)
			to_chat(user, span_warning("There is already a plasma tank loaded!"))
			return TRUE
		if(panel_open)
			to_chat(user, span_warning("Close the maintenance panel first!"))
			return TRUE
		if(!user.transferItemToLoc(item, src))
			return TRUE
		loaded_tank = item
		update_appearance()
		return TRUE

	if(item.GetID())
		if(!allowed(user))
			to_chat(user, span_danger("Access denied."))
			return TRUE
		if(!active)
			to_chat(user, span_warning("The controls can only be locked while [src] is active!"))
			return TRUE
		locked = !locked
		to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the controls."))
		return TRUE

	return ..()

/obj/machinery/power/energy_accumulator/rad_collector/can_be_unfasten_wrench(mob/user, silent)
	if(loaded_tank)
		if(!silent)
			to_chat(user, span_warning("Remove the plasma tank first!"))
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/power/energy_accumulator/rad_collector/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool)
	return TRUE

/obj/machinery/power/energy_accumulator/rad_collector/screwdriver_act(mob/living/user, obj/item/tool)
	if(..())
		return TRUE
	if(loaded_tank)
		to_chat(user, span_warning("Remove the plasma tank first!"))
		return TRUE
	default_deconstruction_screwdriver(user, icon_state, icon_state, tool)
	return TRUE

/obj/machinery/power/energy_accumulator/rad_collector/crowbar_act(mob/living/user, obj/item/tool)
	if(loaded_tank)
		if(locked)
			to_chat(user, span_warning("The controls are locked!"))
			return TRUE
		eject()
		return TRUE
	if(default_deconstruction_crowbar(tool))
		return TRUE
	to_chat(user, span_warning("There is not a tank loaded!"))
	return TRUE

/obj/machinery/power/energy_accumulator/rad_collector/analyzer_act(mob/living/user, obj/item/tool)
	if(loaded_tank)
		loaded_tank.analyzer_act(user, tool)
	return TRUE

/obj/machinery/power/energy_accumulator/rad_collector/return_analyzable_air()
	return loaded_tank?.return_analyzable_air()

/obj/machinery/power/energy_accumulator/rad_collector/examine(mob/user)
	. = ..()
	if(active)
		. += span_notice("The display reports <b>[display_energy(stored_energy)]</b> stored and <b>[display_power(calculate_sustainable_power(), convert = FALSE)]</b> sustainable output.")
		. += span_notice("The plasma within its tank is being irradiated into tritium.")
	else
		. += span_notice("The display reads: \"Power production mode. Please insert plasma.\"")

/obj/machinery/power/energy_accumulator/rad_collector/atom_break(damage_flag)
	if(!(machine_stat & BROKEN) && !(obj_flags & NO_DEBRIS_AFTER_DECONSTRUCTION))
		eject()
	return ..()

/obj/machinery/power/energy_accumulator/rad_collector/update_overlays()
	. = ..()
	if(loaded_tank)
		. += "ptank"
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(active)
		. += "on"

/obj/machinery/power/energy_accumulator/rad_collector/proc/eject()
	locked = FALSE
	var/obj/item/tank/internals/plasma/ejected_tank = loaded_tank
	if(!ejected_tank)
		return
	ejected_tank.forceMove(drop_location())
	ejected_tank.layer = initial(ejected_tank.layer)
	ejected_tank.plane = initial(ejected_tank.plane)
	loaded_tank = null
	if(active)
		toggle_power()
	else
		update_appearance()

/obj/machinery/power/energy_accumulator/rad_collector/proc/toggle_power(mob/user)
	active = !active
	if(user)
		user.visible_message(
			span_notice("[user] turns [src] [active ? "on" : "off"]."),
			span_notice("You turn [src] [active ? "on" : "off"]."),
		)
	investigate_log("turned [active ? "on" : "off"][user ? " by [key_name(user)]" : ""].", INVESTIGATE_ENGINE)
	if(active)
		icon_state = "ca_on"
		flick("ca_active", src)
	else
		icon_state = "ca"
		flick("ca_deactive", src)
	update_appearance()

/obj/machinery/power/energy_accumulator/rad_collector/proc/absorb_radiation(pulse_strength)
	if(!loaded_tank || !active || pulse_strength <= RAD_COLLECTOR_EFFICIENCY)
		return
	stored_energy += (pulse_strength - RAD_COLLECTOR_EFFICIENCY) * RAD_COLLECTOR_COEFFICIENT

/obj/machinery/power/energy_accumulator/rad_collector/proc/on_radiation_pulse(datum/source, datum/radiation_pulse_information/pulse_information, current_insulation)
	SIGNAL_HANDLER
	if(current_insulation <= pulse_information.threshold)
		return
	var/pulse_strength = pulse_information.chance + (pulse_information.max_range * 5) + max(0, (current_insulation - pulse_information.threshold) * 100)
	absorb_radiation(pulse_strength)

/obj/machinery/power/energy_accumulator/rad_collector/proc/get_tank_gas_moles(datum/gas_mixture/tank_mix, gas_path)
	return tank_mix.gases[gas_path] ? tank_mix.gases[gas_path][MOLES] : 0

/obj/machinery/power/energy_accumulator/rad_collector/proc/adjust_tank_gas_moles(datum/gas_mixture/tank_mix, gas_path, amount)
	tank_mix.assert_gas(gas_path)
	tank_mix.gases[gas_path][MOLES] = max(0, tank_mix.gases[gas_path][MOLES] + amount)
	tank_mix.garbage_collect(list(gas_path))

#undef RAD_COLLECTOR_EFFICIENCY
#undef RAD_COLLECTOR_COEFFICIENT
#undef RAD_COLLECTOR_PLASMA_DRAIN
#undef RAD_COLLECTOR_MINIMUM_PLASMA
