GLOBAL_VAR_INIT(clock_power, 2500)
GLOBAL_VAR_INIT(max_clock_power, 2500) // Increases with every APC cogged
GLOBAL_VAR_INIT(clock_vitality, 0)
GLOBAL_VAR_INIT(max_clock_vitality, 200) // This one however is constant
GLOBAL_VAR_INIT(clock_installed_cogs, 0)
GLOBAL_VAR_INIT(charged_anchoring_crystals, 0)
GLOBAL_DATUM(current_eminence, /mob/living/eminence)

GLOBAL_LIST_EMPTY(clockwork_research)
GLOBAL_LIST_EMPTY(clockwork_research_unlocked_recipes)
GLOBAL_LIST_EMPTY(clockwork_research_unlocked_scriptures)
GLOBAL_LIST_EMPTY(clock_anchoring_crystals)
GLOBAL_LIST_EMPTY(clock_marked_areas)
GLOBAL_LIST_EMPTY(cogscarabs)


/// Returns a list of every initialized clockwork research datum
/proc/setup_clockwork_research()
	. = list()
	for(var/path in subtypesof(/datum/clockwork_research))
		. += new path

	return .
