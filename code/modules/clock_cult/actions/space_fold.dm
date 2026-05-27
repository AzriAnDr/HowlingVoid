#define EMINENCE_EVENTS list( \
	/datum/round_event_control/brand_intelligence = 5, \
	/datum/round_event_control/bureaucratic_error = 3, \
	/datum/round_event_control/gravity_generator_blackout = 4, \
	/datum/round_event_control/communications_blackout = 6, \
	/datum/round_event_control/electrical_storm = 2, \
	/datum/round_event_control/ion_storm = 6, \
	/datum/round_event_control/grey_tide = 3, \
	/datum/round_event_control/grid_check = 6, \
	/datum/round_event_control/scrubber_overflow/catastrophic = 4, \
	/datum/round_event_control/radiation_storm = 8, \
	/datum/round_event_control/carp_migration = 6, \
	/datum/round_event_control/wormholes = 6, \
	/datum/round_event_control/immovable_rod = 9, \
	/datum/round_event_control/anomaly/anomaly_dimensional = 2, \
	/datum/round_event_control/anomaly/anomaly_bluespace = 4, \
	/datum/round_event_control/anomaly/anomaly_ectoplasm = 4, \
	/datum/round_event_control/anomaly/anomaly_flux = 3, \
	/datum/round_event_control/anomaly/anomaly_pyro = 5, \
)

/datum/action/innate/clockcult/space_fold
	name = "Space Fold"
	button_icon_state = "Geis"
	desc = "Fold local space so that certain events befall the station. Charges regenerate over time."
	var/list/used_event_list = list()
	var/charges = 10
	var/static/list/event_list
	COOLDOWN_DECLARE(charge_cooldown)

/datum/action/innate/clockcult/space_fold/New(Target)
	. = ..()
	if(isnull(event_list))
		event_list = list()
		var/list/event_costs = EMINENCE_EVENTS
		for(var/datum/round_event_control/entry as anything in SSevents.control)
			if(entry.type in event_costs)
				event_list[entry] = event_costs[entry.type]

/datum/action/innate/clockcult/space_fold/Grant(mob/grant_to)
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	COOLDOWN_START(src, charge_cooldown, 1 SECONDS)

/datum/action/innate/clockcult/space_fold/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/innate/clockcult/space_fold/process(seconds_per_tick)
	if(COOLDOWN_FINISHED(src, charge_cooldown))
		charges++
		COOLDOWN_START(src, charge_cooldown, 1 MINUTES)

	if(charges >= initial(charges))
		STOP_PROCESSING(SSfastprocess, src)

/datum/action/innate/clockcult/space_fold/Activate()
	var/datum/round_event_control/chosen_event = tgui_input_list(owner, "Choose an event", "[charges] [charges == 1 ? "charge" : "charges"] remaining", event_list)
	if(isnull(chosen_event) || isnull(event_list[chosen_event]))
		return FALSE

	if(used_event_list[chosen_event] && (event_list[chosen_event] >= 4 || used_event_list[chosen_event] >= 4))
		to_chat(owner, span_warning("You have summoned this event too many times to do so again!"))
		return FALSE

	if(tgui_alert(owner, "Are you sure you want to summon this event? It will cost [event_list[chosen_event]] cogs.", "Confirm summon", list("Yes", "No")) != "Yes")
		return FALSE

	var/actual_cost = event_list[chosen_event]
	if(GLOB.clock_ark && GLOB.clock_ark.current_state >= ARK_STATE_CHARGING)
		actual_cost *= 2
	if(charges < actual_cost)
		to_chat(owner, span_warning("You don't have enough charges to summon this event."))
		return FALSE
	if(istype(owner, /mob/living/eminence))
		var/mob/living/eminence/em_user = owner
		if(em_user.cogs < actual_cost)
			to_chat(em_user, span_warning("You don't have enough cogs to do this!"))
			return FALSE
		em_user.cogs -= actual_cost

	chosen_event.run_event(event_cause = "an Eminence folding spacetime")
	charges -= actual_cost
	if(charges + event_list[chosen_event] >= initial(charges))
		START_PROCESSING(SSfastprocess, src)
		COOLDOWN_START(src, charge_cooldown, 1 MINUTES)
	used_event_list[chosen_event] = used_event_list[chosen_event] + 1
	return TRUE

#undef EMINENCE_EVENTS
