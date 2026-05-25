/datum/dynamic_ruleset/roundstart/clock_cult
	name = "Clock Cult"
	config_tag = "Roundstart Clock Cult"
	preview_antag_datum = /datum/antagonist/clock_cultist
	pref_flag = ROLE_CLOCK_CULTIST
	ruleset_flags = RULESET_HIGH_IMPACT
	weight = alist(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	min_antag_cap = list("denominator" = 20, "offset" = 1)
	blacklisted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/clock_cult/get_always_blacklisted_roles()
	return ..() | JOB_CHAPLAIN

/datum/dynamic_ruleset/roundstart/clock_cult/create_execute_args()
	return list(new /datum/team/clock_cult())

/datum/dynamic_ruleset/roundstart/clock_cult/execute()
	GLOB.clock_installed_cogs = max(GLOB.clock_installed_cogs, CLOCK_CULT_STARTING_COGS)
	. = ..()
	var/datum/team/clock_cult/main_cult = locate() in GLOB.antagonist_teams
	main_cult?.setup_objectives()
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_reebe), selected_minds[1]?.current)

/datum/dynamic_ruleset/roundstart/clock_cult/assign_role(datum/mind/candidate, datum/team/clock_cult/clock_team)
	var/datum/antagonist/clock_cultist/servant = new
	servant.give_slab = TRUE
	candidate.add_antag_datum(servant, clock_team)

/datum/dynamic_ruleset/roundstart/clock_cult/round_result()
	if(GLOB.ratvar_risen)
		SSticker.mode_result = "win - ratvar risen"
		return TRUE

	SSticker.mode_result = "loss - ratvar trapped"
	return TRUE

/datum/dynamic_ruleset/midround/from_living/clock_cultist
	name = "Clock Cultist"
	config_tag = "Midround Clock Cultist"
	preview_antag_datum = /datum/antagonist/clock_cultist
	midround_type = HEAVY_MIDROUND
	pref_flag = ROLE_CLOCK_CULTIST_MIDROUND
	jobban_flag = ROLE_CLOCK_CULTIST
	ruleset_flags = RULESET_HIGH_IMPACT
	weight = alist(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 0,
		DYNAMIC_TIER_MEDIUMHIGH = 1,
		DYNAMIC_TIER_HIGH = 2,
	)
	min_pop = 30
	blacklisted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	repeatable = FALSE

/datum/dynamic_ruleset/midround/from_living/clock_cultist/get_always_blacklisted_roles()
	return ..() | JOB_CHAPLAIN

/datum/dynamic_ruleset/midround/from_living/clock_cultist/assign_role(datum/mind/candidate)
	GLOB.clock_installed_cogs = max(GLOB.clock_installed_cogs, CLOCK_CULT_STARTING_COGS)
	var/datum/antagonist/clock_cultist/solo/servant = new
	servant.give_slab = TRUE
	candidate.add_antag_datum(servant)
