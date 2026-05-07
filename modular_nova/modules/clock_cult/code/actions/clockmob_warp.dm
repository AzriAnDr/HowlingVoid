/datum/action/cooldown/clock_cult/clockmob_warp
	name = "Clockwork Warp"
	desc = "Warp to and from marked areas on the station and Reebe."
	cooldown_time = 30 SECONDS
	button_icon_state = "warp_down"

/datum/action/cooldown/clock_cult/clockmob_warp/Grant(mob/granted_to)
	. = ..()
	if(!on_reebe(granted_to))
		button_icon_state = "Abscond"

/datum/action/cooldown/clock_cult/clockmob_warp/Activate(atom/target)
	var/turf/selected_turf
	var/new_icon_state
	if(on_reebe(owner))
		if(!length(GLOB.clock_marked_areas))
			return FALSE
		var/area/selection = tgui_input_list(owner, "Where do you want to warp?", "Warping", GLOB.clock_marked_areas)
		if(!isarea(selection))
			return FALSE
		selected_turf = pick(selection.get_turfs_from_all_zlevels())
		new_icon_state = "Abscond"
	else
		selected_turf = get_clock_reebe_turf()
		new_icon_state = "warp_down"

	if(!selected_turf || !do_after(owner, cooldown_time, target = owner))
		return FALSE

	try_servant_warp(owner, selected_turf)
	if(new_icon_state)
		button_icon_state = new_icon_state
		build_all_button_icons(UPDATE_BUTTON_ICON)
	return ..()
