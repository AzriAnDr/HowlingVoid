/datum/scripture/create_structure/the_ark
	name = "The Ark"
	desc = "Creates the Ark of the Clockwork Justiciar. Once activated with a Clockwork Slab, it must be protected until Ratvar arrives."
	tip = "Create and awaken the Ark."
	button_icon_state = "Tinkerer's Cache"
	power_cost = 500
	invocation_time = 15 SECONDS
	invocation_text = list("The veil thins.", "The cogs align.", "May the Ark open.")
	summoned_structure = /obj/structure/destructible/clockwork/the_ark
	cogs_required = 0
	category = SPELLTYPE_STRUCTURES

/datum/scripture/create_structure/the_ark/check_special_requirements(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(GLOB.clock_ark)
		invoker.balloon_alert(invoker, "ark already exists!")
		return FALSE
	return TRUE
