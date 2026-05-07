/datum/scripture/cogscarab
	name = "Summon Cogscarab"
	desc = "Summons a Cogscarab shell, which may be possessed by a ghost loyal to Ratvar. Takes longer the more cogscarabs exist."
	tip = "Use Cogscarabs to fortify Reebe."
	button_icon_state = "Cogscarab"
	power_cost = 500
	vitality_cost = 30
	invocation_time = 12 SECONDS
	invocation_text = list("My fallen brothers,", "now is the time we rise", "to protect our Lord", "and achieve greatness!")
	category = SPELLTYPE_PRESERVATION
	cogs_required = 5
	invokers_required = 2

/datum/scripture/cogscarab/begin_invoke(mob/living/invoking_mob, obj/item/clockwork/clockwork_slab/slab, bypass_unlock_checks)
	invocation_time = 12 SECONDS + (6 SECONDS * length(GLOB.cogscarabs))
	return ..()

/datum/scripture/cogscarab/check_special_requirements(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!istype(get_area(invoker), /area/ruin/powered/reebe))
		to_chat(invoker, span_warning("You must do this on Reebe!"))
		return FALSE

	if(length(GLOB.cogscarabs) >= MAXIMUM_COGSCARABS)
		to_chat(invoker, span_warning("You can't summon any more cogscarabs."))
		return FALSE

	if(GLOB.clock_ark?.current_state >= ARK_STATE_ACTIVE)
		to_chat(invoker, span_warning("It is too late to summon cogscarabs now. Ratvar is coming!"))
		return FALSE

	return TRUE

/datum/scripture/cogscarab/invoke_success()
	new /obj/effect/mob_spawn/ghost_role/drone/cogscarab(get_turf(invoker))
	return TRUE
