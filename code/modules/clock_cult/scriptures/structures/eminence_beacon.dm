/datum/scripture/create_structure/eminence_beacon
	name = "Eminence Spire"
	desc = "Creates an Eminence Spire, allowing the servants to awaken the Eminence."
	tip = "Call a clockwork overseer."
	button_icon_state = "Tinkerer's Cache"
	power_cost = 750
	invocation_time = 12 SECONDS
	invocation_text = list("Hear our cogs.", "Wake, overseer.", "Guide the engine.")
	summoned_structure = /obj/structure/destructible/clockwork/eminence_beacon
	cogs_required = 4
	category = SPELLTYPE_STRUCTURES

/datum/scripture/create_structure/eminence_beacon/check_special_requirements(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(GLOB.current_eminence)
		invoker.balloon_alert(invoker, "eminence exists!")
		return FALSE
	return TRUE
