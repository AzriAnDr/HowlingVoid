/datum/action/cooldown/clock_cult
	button_icon = 'icons/clock_cult/actions_clock.dmi'
	background_icon = 'icons/clock_cult/background_clock.dmi'
	background_icon_state = "bg_clock"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/cooldown/clock_cult/eminence/Activate(atom/target)
	if(!istype(owner, /mob/living/eminence))
		to_chat(owner, span_boldwarning("You are not the Eminence and should not have this ability."))
		return FALSE
	StartCooldown()
	return TRUE

/datum/action/cooldown/clock_cult/eminence/purge_reagents
	name = "Purge Reagents"
	desc = "Purges all reagents from a marked servant."
	button_icon_state = "Mending Mantra"
	cooldown_time = 30 SECONDS

/datum/action/cooldown/clock_cult/eminence/purge_reagents/Activate(atom/target)
	if(!..())
		return FALSE

	var/mob/living/eminence/em_user = owner
	var/mob/living/purged = em_user.marked_servant?.resolve()
	if(!purged)
		to_chat(em_user, span_notice("You do not currently have a marked servant."))
		return FALSE

	if(!purged.reagents?.total_volume)
		to_chat(em_user, span_notice("[purged] does not have any reagents to purge."))
		return FALSE

	purged.reagents.clear_reagents()
	em_user.marked_servant = null
	to_chat(em_user, span_brass("You purge the reagents of [purged]."))
	to_chat(purged, span_brass("A clockwork presence purges your blood."))
	return TRUE

/datum/action/cooldown/clock_cult/eminence/linked_abscond
	name = "Linked Abscond"
	desc = "Recalls a marked servant and anything they are pulling back to Reebe after a short delay."
	button_icon_state = "Linked Abscond"
	cooldown_time = 4 MINUTES

/datum/action/cooldown/clock_cult/eminence/linked_abscond/Activate(atom/target)
	var/mob/living/eminence/em_user = owner
	var/mob/living/teleported = em_user.marked_servant?.resolve()
	if(!teleported)
		to_chat(em_user, span_notice("You do not currently have a marked servant."))
		return FALSE

	if(!get_clock_reebe_turf())
		to_chat(em_user, span_warning("Reebe is not reachable yet."))
		return FALSE

	if(!..())
		return FALSE

	to_chat(em_user, span_brass("You begin to recall [teleported]."))
	to_chat(teleported, span_bigbrass("You are being recalled by the Eminence."))
	teleported.visible_message(span_warning("[teleported] flares briefly."))
	if(!do_after(em_user, 7 SECONDS, teleported))
		to_chat(em_user, span_warning("You fail to recall [teleported]."))
		return FALSE

	var/turf/destination = get_clock_reebe_turf()
	var/atom/movable/pulled_atom = teleported.pulling
	if(pulled_atom)
		try_servant_warp(pulled_atom, destination)
	try_servant_warp(teleported, destination)
	em_user.marked_servant = null
	to_chat(em_user, span_brass("You recall [teleported]."))
	return TRUE

/datum/action/innate/clockcult/teleport_to_station
	name = "Teleport to Station"
	desc = "Teleport to a random location on the station."
	button_icon_state = "warp_down"

/datum/action/innate/clockcult/teleport_to_station/Activate()
	var/turf/destination = get_safe_random_station_turf()
	if(!destination)
		return
	try_servant_warp(owner, destination)
	owner.playsound_local(get_turf(owner), 'sound/effects/magic/magic_missile.ogg', 50, TRUE, pressure_affected = FALSE)

/datum/action/innate/clockcult/eminence_abscond
	name = "Return to Reebe"
	desc = "Teleport back to Reebe."
	button_icon_state = "Abscond"

/datum/action/innate/clockcult/eminence_abscond/Activate()
	var/turf/destination = get_clock_reebe_turf()
	if(!destination)
		to_chat(owner, span_warning("Reebe is not reachable yet."))
		return
	try_servant_warp(owner, destination)
	owner.playsound_local(get_turf(owner), 'sound/effects/magic/magic_missile.ogg', 50, TRUE, pressure_affected = FALSE)

/datum/action/innate/clockcult/teleport_to_servant
	name = "Teleport to Servant"
	desc = "Teleport yourself to a fellow servant."
	button_icon_state = "clockwork_armor"

/datum/action/innate/clockcult/teleport_to_servant/Activate(mob/living/user = owner)
	var/datum/antagonist/clock_cultist/servant = user.mind?.has_antag_datum(/datum/antagonist/clock_cultist)
	if(!servant?.clock_team)
		return

	var/list/servants = list()
	for(var/datum/mind/servant_mind as anything in servant.clock_team.members)
		if(servant_mind.current && servant_mind.current != user)
			servants += servant_mind.current
	if(!length(servants))
		to_chat(user, span_warning("There are no other servants to warp to."))
		return

	var/mob/living/chosen_servant = tgui_input_list(user, "Choose a servant", "Servants", servants)
	if(!chosen_servant)
		return

	try_servant_warp(user, get_turf(chosen_servant))
	user.playsound_local(get_turf(user), 'sound/effects/magic/magic_missile.ogg', 50, TRUE, pressure_affected = FALSE)
	to_chat(user, span_brass("You warp to [chosen_servant]."))
