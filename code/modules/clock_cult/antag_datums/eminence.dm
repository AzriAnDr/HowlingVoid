/datum/antagonist/clock_cultist/eminence
	name = "Eminence"
	give_slab = FALSE
	can_convert = FALSE
	antag_moodlet = null
	var/list/action_list = list(
		/datum/action/cooldown/clock_cult/eminence/purge_reagents,
		/datum/action/cooldown/clock_cult/eminence/linked_abscond,
		/datum/action/innate/clockcult/space_fold,
		/datum/action/innate/clockcult/teleport_to_servant,
		/datum/action/innate/clockcult/teleport_to_station,
		/datum/action/innate/clockcult/eminence_abscond,
	)

/datum/antagonist/clock_cultist/eminence/Destroy()
	QDEL_LIST(action_list)
	return ..()

/datum/antagonist/clock_cultist/eminence/greet()
	to_chat(owner.current, boxed_message("[span_bigbrass("You are the Eminence, a being bound to Ratvar.")]<br>[span_brass("You may speak through the clockwork link, pass through the station as a spirit, click servants to mark them, and influence simple machinery nearby.")]"))

/datum/antagonist/clock_cultist/eminence/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current = owner.current
	current.add_faction(FACTION_CLOCK)
	current.grant_language(/datum/language/ratvar, source = LANGUAGE_CULTIST)
	add_team_hud(current, /datum/antagonist/clock_cultist)
	for(var/datum/action/our_action as anything in action_list)
		if(ispath(our_action))
			our_action = new our_action()
		our_action.Grant(current)

/datum/antagonist/clock_cultist/eminence/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current = owner.current
	current.remove_faction(FACTION_CLOCK)
	current.remove_language(/datum/language/ratvar, source = LANGUAGE_CULTIST)
	for(var/datum/action/removed_action as anything in action_list)
		removed_action.Remove(current)
