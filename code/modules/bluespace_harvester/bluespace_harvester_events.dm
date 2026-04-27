/**
 * Bluespace Harvester Events
 *
 * Random events that can occur during harvester operation.
 */

/datum/bluespace_tap_event
	var/name = "Unknown Anomaly"
	var/obj/machinery/power/bluespace_tap/tap

/datum/bluespace_tap_event/New(obj/machinery/power/bluespace_tap/_tap)
	tap = _tap
	if(!tap)
		stack_trace("a /datum/bluespace_tap_event was called without an involved bluespace tap.")
		return
	if(!istype(tap))
		stack_trace("a /datum/bluespace_tap_event was called with (name: [tap], type: [tap.type]) instead of a bluespace tap!")
		return

/datum/bluespace_tap_event/proc/start_event()
	tap.investigate_log("event [src] has been triggered", INVESTIGATE_ENGINE)
	alert_engi()
	on_start()

/datum/bluespace_tap_event/proc/alert_engi()
	return

/datum/bluespace_tap_event/proc/on_start()
	return

/datum/bluespace_tap_event/Destroy(force)
	tap = null
	return ..()

/datum/bluespace_tap_event/gas
	name = "Gas Event"

/datum/bluespace_tap_event/gas/alert_engi()
	tap.radio.talk_into(tap, "Bluespace harvester has released a class [src] gas pocket!", FREQ_ENGINEERING)

/datum/bluespace_tap_event/gas/on_start()
	var/datum/gas_mixture/air = new()
	var/picked_gas = pick("N2O", "N2", "O2", "CO2", "Plasma", "Unknown")
	switch(picked_gas)
		if("N2")
			name = "G-1"
			air.gases[/datum/gas/nitrogen] = list(250, 0)
		if("O2")
			name = "G-2"
			air.gases[/datum/gas/oxygen] = list(250, 0)
		if("N2O")
			name = "G-3"
			air.gases[/datum/gas/nitrous_oxide] = list(200, 0)
		if("CO2")
			name = "G-4"
			air.gases[/datum/gas/carbon_dioxide] = list(250, 0)
		if("Plasma")
			name = "G-5"
			air.gases[/datum/gas/plasma] = list(250, 0)
		if("Unknown")
			name = "G-6"
			air.gases[/datum/gas/bz] = list(250, 0)

	air.temperature = T20C
	var/turf/open/tap_turf = get_turf(tap)
	if(istype(tap_turf))
		tap_turf.assume_air(air)

/datum/bluespace_tap_event/dirty
	name = "F-1"

/datum/bluespace_tap_event/dirty/alert_engi()
	tap.radio.talk_into(tap, "Bluespace harvester has struck a congealed mass of filth!", FREQ_ENGINEERING)

/datum/bluespace_tap_event/dirty/on_start()
	tap.dirty = TRUE
	var/list/gunk = list(/datum/reagent/carbon, /datum/reagent/consumable/flour, /datum/reagent/blood)
	var/datum/reagents/smoke_reagents = new /datum/reagents(50)
	smoke_reagents.my_atom = tap
	smoke_reagents.add_reagent(pick(gunk), 50)
	tap.update_icon()

	playsound(tap.loc, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	do_chem_smoke(range = 3, holder = tap, location = get_turf(tap), carry = smoke_reagents)

/datum/bluespace_tap_event/radiation
	name = "R-1"

/datum/bluespace_tap_event/radiation/alert_engi()
	tap.radio.talk_into(tap, "Bluespace harvester has released a spike of radiation!", FREQ_ENGINEERING)

/datum/bluespace_tap_event/radiation/on_start()
	radiation_pulse(tap, max_range = 5, threshold = 0.3)

/datum/bluespace_tap_event/electric_arc
	name = "E-1"

/datum/bluespace_tap_event/electric_arc/alert_engi()
	tap.radio.talk_into(tap, "Class [src] power spike detected in bluespace harvester operation!", FREQ_ENGINEERING)

/datum/bluespace_tap_event/electric_arc/on_start()
	var/shock_type = pick("single", "mass")
	switch(shock_type)
		if("single")
			var/list/shock_mobs = list()
			for(var/mob/living/target in view(get_turf(tap), 5))
				shock_mobs += target
			if(length(shock_mobs))
				var/mob/living/victim = pick(shock_mobs)
				victim.electrocute_act(rand(5, 25), "electrical arc")
				playsound(get_turf(victim), 'sound/machines/defib/defib_zap.ogg', 75, TRUE)
				tap.Beam(victim, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)
		if("mass")
			name = "E-2"
			for(var/mob/living/victim in view(get_turf(tap), 5))
				victim.electrocute_act(rand(5, 25), "electrical arc")
				playsound(get_turf(victim), 'sound/machines/defib/defib_zap.ogg', 75, TRUE)
				tap.Beam(victim, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)