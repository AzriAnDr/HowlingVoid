// This'll take a bit of explaining.
// Clock cult, the (shitty) gamemode is not coming back, this antagonist datum is for the soon-to-come OPFOR bundle
// However, the bundle gives `/datum/antagonist/clock_cultist/solo`, which is the same as `/datum/antagonist/clock_cultist`, but lacks conversion.

/datum/antagonist/clock_cultist
	name = "\improper Clock Cultist"
	antagpanel_category = "Clock Cultist"
	preview_outfit = /datum/outfit/clock/preview
	pref_flag = ROLE_CLOCK_CULTIST
	antag_moodlet = /datum/mood_event/cult
	show_to_ghosts = TRUE
	suicide_cry = ",r For Ratvar!!!"
	ui_name = "AntagInfoClock"
	/// If this one has access to conversion scriptures
	var/can_convert = TRUE
	/// Ref to the cultist's communication ability
	var/datum/action/innate/clockcult/comm/communicate = new
	/// Ref to the cultist's slab recall ability
	var/datum/action/innate/clockcult/recall_slab/recall = new
	/// The clock cult team this servant belongs to.
	var/datum/team/clock_cult/clock_team
	/// If this datum should create and hand out a slab on gain.
	var/give_slab = FALSE


/datum/antagonist/clock_cultist/Destroy()
	QDEL_NULL(communicate)
	QDEL_NULL(recall)
	return ..()


/datum/antagonist/clock_cultist/on_gain()
	if(clock_team)
		objectives |= clock_team.objectives
	if(give_slab && ishuman(owner.current))
		give_clockwork_slab(owner.current)
	. = ..()
	owner.current.playsound_local(get_turf(owner.current), 'sound/clock_cult/magic/scripture_tier_up.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/datum/antagonist/clock_cultist/admin_add(datum/mind/new_owner, mob/admin)
	give_slab = ishuman(new_owner.current)
	return ..()


/datum/antagonist/clock_cultist/greet()
	. = ..()
	to_chat(owner.current, span_brass("Serve Ratvar. Use your Clockwork Slab to construct the Ark, gather power, and defend it until the Justiciar arrives."))


/datum/antagonist/clock_cultist/create_team(datum/team/clock_cult/given_clock_team)
	if(given_clock_team)
		if(!istype(given_clock_team))
			stack_trace("Wrong team type passed to [type] initialization.")
			return
		clock_team = given_clock_team
	else if(GLOB.main_clock_cult)
		clock_team = GLOB.main_clock_cult
	else
		clock_team = new /datum/team/clock_cult

	clock_team.setup_objectives()


/datum/antagonist/clock_cultist/get_team()
	return clock_team


/datum/antagonist/clock_cultist/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	current.add_faction(FACTION_CLOCK)
	current.grant_language(/datum/language/ratvar, source = LANGUAGE_CULTIST)
	if(QDELETED(communicate))
		communicate = new
	if(QDELETED(recall))
		recall = new
	communicate.Grant(current)
	recall.Grant(current)
	RegisterSignal(current, COMSIG_CLOCKWORK_SLAB_USED, PROC_REF(switch_recall_slab))


/datum/antagonist/clock_cultist/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	current.remove_faction(FACTION_CLOCK)
	current.remove_language(/datum/language/ratvar, source = LANGUAGE_CULTIST)
	communicate.Remove(current)
	recall.Remove(current)
	UnregisterSignal(current, COMSIG_CLOCKWORK_SLAB_USED)


/// Change the slab in the recall ability, if it's different from the last one.
/datum/antagonist/clock_cultist/proc/switch_recall_slab(datum/source, obj/item/clockwork/clockwork_slab/slab)
	if(slab == recall.marked_slab)
		return

	recall.unmark_item()
	recall.mark_item(slab)
	to_chat(owner.current, span_brass("You re-attune yourself to a new Clockwork Slab."))


/datum/antagonist/clock_cultist/proc/give_clockwork_slab(mob/living/carbon/human/give_to)
	var/obj/item/clockwork/clockwork_slab/created_slab = new(give_to)
	created_slab.cogs = max(created_slab.cogs, CLOCK_CULT_STARTING_COGS)
	switch_recall_slab(give_to, created_slab)

	var/list/slots = list(
		LOCATION_BACKPACK,
		LOCATION_LPOCKET,
		LOCATION_RPOCKET,
	)

	if(!give_to.equip_in_one_of_slots(created_slab, slots))
		to_chat(give_to, span_userdanger("The Clockwork Slab could not fit in your belongings. It has been placed at your feet."))
		created_slab.forceMove(get_turf(give_to))
		return FALSE

	to_chat(give_to, span_brass("You have been given a Clockwork Slab."))
	return TRUE


/datum/outfit/clock/preview
	name = "Clock Cultist (Preview only)"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/clockwork
	head = /obj/item/clothing/head/helmet/clockwork
	l_hand = /obj/item/clockwork/weapon/brass_sword


/datum/antagonist/clock_cultist/solo
	name = "Clock Cultist (Solo)"
	show_to_ghosts = FALSE
	can_convert = FALSE
