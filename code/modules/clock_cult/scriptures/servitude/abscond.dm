/datum/scripture/abscond
	name = "Abscond"
	desc = "After a long delay, recalls you and anything you are pulling to Reebe. Can only be invoked from a marked area."
	tip = "Return to Reebe."
	button_icon_state = "Abscond"
	invocation_time = 45 SECONDS
	invocation_text = list("Return to our home, the city of cogs.")
	category = SPELLTYPE_SERVITUDE
	power_cost = 100
	cogs_required = 2

/datum/scripture/abscond/check_special_requirements(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!GLOB.clock_marked_areas[get_area(invoker)] && !istype(get_area(invoker), /area/ruin/powered/reebe))
		to_chat(user, span_warning("We can only abscond from marked areas!"))
		return FALSE

	if(!get_clock_reebe_turf())
		to_chat(user, span_warning("Reebe is not reachable yet!"))
		return FALSE

	return TRUE

/datum/scripture/abscond/invoke_success()
	var/turf/destination = get_clock_reebe_turf()
	if(!destination)
		return FALSE

	var/atom/movable/pulled_atom = invoker.pulling
	if(pulled_atom)
		try_servant_warp(pulled_atom, destination)
	try_servant_warp(invoker, destination)
	return TRUE
