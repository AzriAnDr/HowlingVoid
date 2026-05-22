/datum/storyteller/action
	var/id
	var/name = "Unnamed Storyteller Action"
	var/context = STORYTELLER_CONTEXT_MIDROUND
	var/polarity = STORYTELLER_POLARITY_NEGATIVE
	var/family = "generic"
	var/stage = 1
	var/cost = 10
	var/weight = 10
	var/extended_weight = -1
	var/enabled = TRUE
	var/latejoin_hostile = FALSE
	var/allow_in_extended = TRUE
	var/list/supported_need_ids

/datum/storyteller/action/proc/apply_tuning(list/storyteller_config)
	if(!islist(storyteller_config) || !id)
		return

	var/list/action_enabled = storyteller_config["action_enabled"]
	var/list/action_costs = storyteller_config["action_costs"]
	var/list/action_weights = storyteller_config["action_weights"]
	var/list/action_stages = storyteller_config["action_stages"]

	if(islist(action_enabled) && !isnull(action_enabled[id]))
		enabled = !!action_enabled[id]
	if(islist(action_costs) && !isnull(action_costs[id]))
		cost = max(0, round(text2num("[action_costs[id]]")))
	if(islist(action_weights) && !isnull(action_weights[id]))
		weight = max(0, round(text2num("[action_weights[id]]")))
	if(islist(action_stages) && !isnull(action_stages[id]))
		stage = max(1, round(text2num("[action_stages[id]]")))

/datum/storyteller/action/proc/get_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	RETURN_TYPE(/list)
	var/list/result = list(
		"available" = TRUE,
		"reason" = "Ready",
	)
	var/forced = !!context_data["force"]

	if(!enabled && !forced)
		result["available"] = FALSE
		result["reason"] = "Disabled in storyteller config"
		return result

	if(!forced && istype(owner) && owner.is_action_discarded(id))
		result["available"] = FALSE
		result["reason"] = "Discarded by an administrator for this round"
		return result

	if(!forced && istype(owner) && owner.is_action_admin_suppressed(id))
		result["available"] = FALSE
		result["reason"] = "Discarded for the current storyteller rotation"
		return result

	if(!forced && !is_allowed_in_round_mode(owner))
		result["available"] = FALSE
		result["reason"] = "Blocked by current storyteller mode"
		return result

	if(!forced && stage > owner.current_phase_max)
		result["available"] = FALSE
		result["reason"] = "Blocked by storyteller phase"
		return result

	var/selection_context = context_data["selection_context"]
	if(!forced && selection_context && selection_context != context)
		result["available"] = FALSE
		result["reason"] = "Waiting for [context] scheduling window"
		return result

	if(!forced && length(supported_need_ids))
		var/datum/storyteller/need_report/need_report = context_data["need_report"]
		if(!istype(need_report))
			result["available"] = FALSE
			result["reason"] = "Requires a matching storyteller need"
			return result
		if(!(need_report.id in supported_need_ids))
			result["available"] = FALSE
			result["reason"] = "Need does not match this action"
			return result

	if(!forced && !context_data["ignore_cooldowns"])
		if(owner.is_polarity_fatigue_locked(polarity))
			result["available"] = FALSE
			result["reason"] = "[capitalize(polarity)] channel fatigue lock active"
			return result
		if(owner.is_family_on_cooldown(family))
			result["available"] = FALSE
			result["reason"] = "Family cooldown active"
			return result
		if(latejoin_hostile && owner.is_latejoin_hostile_locked())
			result["available"] = FALSE
			result["reason"] = "Latejoin hostile lock active"
			return result

	if(!forced && !context_data["ignore_budget"] && context != STORYTELLER_CONTEXT_ROUNDSTART)
		if(polarity == STORYTELLER_POLARITY_NEGATIVE && owner.threat_budget < cost)
			result["available"] = FALSE
			result["reason"] = "Threat budget below cost"
			return result
		if(polarity == STORYTELLER_POLARITY_POSITIVE && owner.aid_budget < cost)
			result["available"] = FALSE
			result["reason"] = "Aid budget below cost"
			return result

	var/list/custom_result = check_additional_availability(owner, snapshot, context_data)
	if(forced)
		return list(
			"available" = TRUE,
			"reason" = islist(custom_result) ? "Admin force bypassed: [custom_result["reason"]]" : "Admin force bypassed availability checks",
		)
	if(islist(custom_result))
		return custom_result
	return result

/datum/storyteller/action/proc/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return list(
		"available" = TRUE,
		"reason" = "Ready",
	)

/datum/storyteller/action/proc/is_allowed_in_round_mode(datum/controller/subsystem/storyteller/owner)
	if(!istype(owner))
		return TRUE
	if(owner.round_mode == STORYTELLER_ROUND_MODE_EXTENDED && !allow_in_extended)
		return FALSE
	return TRUE

/datum/storyteller/action/proc/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	if(istype(owner) && owner.round_mode == STORYTELLER_ROUND_MODE_EXTENDED && extended_weight >= 0)
		return extended_weight
	return weight

/datum/storyteller/action/proc/get_staff_scaled_weight(base_weight, staff_count, zero_scale = 0.2, one_scale = 0.5, two_scale = 0.8, extra_scale = 0.12, max_scale = 1.6)
	if(base_weight <= 0)
		return base_weight

	var/scale = zero_scale
	if(staff_count == 1)
		scale = one_scale
	else if(staff_count == 2)
		scale = two_scale
	else if(staff_count >= 3)
		scale = min(max_scale, 1 + ((staff_count - 2) * extra_scale))
	return max(1, round(base_weight * scale))

/datum/storyteller/action/proc/get_population_scaled_weight(base_weight, population, divisor = 30, minimum_scale = 0.7, maximum_scale = 1.4)
	if(base_weight <= 0)
		return base_weight
	var/scale = clamp(population / max(divisor, 1), minimum_scale, maximum_scale)
	return max(1, round(base_weight * scale))

/datum/storyteller/action/proc/supports_need(need_id)
	if(!length(supported_need_ids))
		return FALSE
	return need_id in supported_need_ids

/datum/storyteller/action/proc/is_antag_action()
	return FALSE

/datum/storyteller/action/proc/force_execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return execute(owner, snapshot, context_data)

/datum/storyteller/action/proc/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return FALSE

/datum/storyteller/action/proc/to_ui_data(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/list/availability = get_availability(owner, snapshot, context_data)
	return list(
		"id" = id,
		"name" = name,
		"context" = context,
		"polarity" = polarity,
		"family" = family,
		"stage" = stage,
		"cost" = cost,
		"weight" = get_effective_weight(owner),
		"isAntag" = is_antag_action(),
		"discarded" = istype(owner) ? (owner.is_action_discarded(id) || owner.is_action_admin_suppressed(id)) : FALSE,
		"enabled" = enabled,
		"eligible" = !!availability["available"],
		"reason" = availability["reason"],
	)

/datum/storyteller/action/dynamic_base
	var/dynamic_ruleset_type

/datum/storyteller/action/dynamic_base/proc/is_ruleset_disabled()
	return dynamic_ruleset_type in SSdynamic.admin_disabled_rulesets

/datum/storyteller/action/dynamic_base/is_antag_action()
	return TRUE

/datum/storyteller/action/dynamic_base/proc/build_ruleset()
	if(!dynamic_ruleset_type)
		return null
	return new dynamic_ruleset_type(SSdynamic.get_config())

/datum/storyteller/action/dynamic_base/proc/meets_population_requirement(datum/dynamic_ruleset/ruleset, player_count)
	if(!istype(ruleset))
		return FALSE
	var/min_pop = ruleset.min_pop
	if(islist(min_pop))
		min_pop = SSstoryteller.resolve_dynamic_tier_value(min_pop, SSdynamic.current_tier?.tier)
	return player_count >= min_pop

/datum/storyteller/action/dynamic_roundstart
	parent_type = /datum/storyteller/action/dynamic_base
	context = STORYTELLER_CONTEXT_ROUNDSTART
	polarity = STORYTELLER_POLARITY_NEGATIVE
	family = "roundstart_antag"
	allow_in_extended = FALSE

/datum/storyteller/action/dynamic_roundstart/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(is_ruleset_disabled())
		return list("available" = FALSE, "reason" = "Disabled in Dynamic admin panel")
	return ..()

/datum/storyteller/action/dynamic_roundstart/proc/prepare_roundstart_action(datum/controller/subsystem/storyteller/owner, population_size, list/antag_candidates)
	var/datum/dynamic_ruleset/roundstart/ruleset = build_ruleset()
	if(!istype(ruleset))
		return null
	if(!ruleset.prepare_execution(population_size, antag_candidates))
		owner.record_decision("Roundstart [name] preparation failed: [ruleset.log_data || "unknown reason"]")
		qdel(ruleset)
		return null
	return ruleset

/datum/storyteller/action/dynamic_roundstart/proc/execute_prepared_action(datum/controller/subsystem/storyteller/owner, datum/dynamic_ruleset/roundstart/ruleset)
	if(!istype(ruleset))
		return FALSE
	ruleset.execute()
	owner.track_dynamic_ruleset(ruleset)
	owner.record_action_execution(src, "Roundstart minds: [owner.format_selected_minds(ruleset.selected_minds)]", spend_budget = FALSE)
	return TRUE

/datum/storyteller/action/dynamic_roundstart/force_execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(SSticker.current_state > GAME_STATE_SETTING_UP)
		return FALSE
	if(!owner.queue_dynamic_ruleset_action(src, context_data["admin_user"]))
		return FALSE
	owner.record_decision("Queued roundstart storyteller ruleset [name] for the upcoming spawn cycle.")
	return TRUE

/datum/storyteller/action/dynamic_roundstart/traitor
	id = "roundstart_traitor"
	name = "Roundstart Traitor"
	dynamic_ruleset_type = /datum/dynamic_ruleset/roundstart/traitor
	family = "roundstart_traitor"
	cost = 18
	weight = 12

/datum/storyteller/action/dynamic_roundstart/changeling
	id = "roundstart_changeling"
	name = "Roundstart Changeling"
	dynamic_ruleset_type = /datum/dynamic_ruleset/roundstart/changeling
	family = "roundstart_changeling"
	cost = 20
	weight = 7

/datum/storyteller/action/dynamic_roundstart/blood_brothers
	id = "roundstart_blood_brothers"
	name = "Roundstart Blood Brothers"
	dynamic_ruleset_type = /datum/dynamic_ruleset/roundstart/blood_brother
	family = "roundstart_blood_brothers"
	cost = 22
	weight = 6

/datum/storyteller/action/dynamic_roundstart/heretics
	id = "roundstart_heretics"
	name = "Roundstart Heretics"
	dynamic_ruleset_type = /datum/dynamic_ruleset/roundstart/heretic
	family = "roundstart_heretics"
	cost = 24
	weight = 6
	stage = 2

/datum/storyteller/action/dynamic_roundstart/malf_ai
	id = "roundstart_malf_ai"
	name = "Roundstart Malfunctioning AI"
	dynamic_ruleset_type = /datum/dynamic_ruleset/roundstart/malf_ai
	family = "roundstart_malf_ai"
	cost = 24
	weight = 4
	stage = 2

/datum/storyteller/action/dynamic_roundstart/blood_worm
	id = "roundstart_blood_worm"
	name = "Roundstart Blood Worm"
	dynamic_ruleset_type = /datum/dynamic_ruleset/roundstart/blood_worm
	family = "roundstart_blood_worm"
	cost = 25
	weight = 4
	stage = 2

/datum/storyteller/action/dynamic_roundstart/vampire
	id = "roundstart_vampire"
	name = "Roundstart Vampire"
	dynamic_ruleset_type = /datum/dynamic_ruleset/roundstart/vampire
	family = "roundstart_vampire"
	cost = 22
	weight = 5
	stage = 2

/datum/storyteller/action/dynamic_roundstart/wizard
	id = "roundstart_wizard"
	name = "Roundstart Wizard"
	dynamic_ruleset_type = /datum/dynamic_ruleset/roundstart/wizard
	family = "roundstart_wizard"
	cost = 32
	weight = 3
	stage = 3

/datum/storyteller/action/dynamic_roundstart/blood_cult
	id = "roundstart_blood_cult"
	name = "Roundstart Blood Cult"
	dynamic_ruleset_type = /datum/dynamic_ruleset/roundstart/blood_cult
	family = "roundstart_blood_cult"
	cost = 34
	weight = 3
	stage = 3

/datum/storyteller/action/dynamic_roundstart/nukies
	id = "roundstart_nukies"
	name = "Roundstart Nuclear Operatives"
	dynamic_ruleset_type = /datum/dynamic_ruleset/roundstart/nukies
	family = "roundstart_nukies"
	cost = 40
	weight = 2
	stage = 3

/datum/storyteller/action/dynamic_roundstart/clown_nukies
	id = "roundstart_clown_nukies"
	name = "Roundstart Clown Operatives"
	dynamic_ruleset_type = /datum/dynamic_ruleset/roundstart/nukies/clown
	family = "roundstart_nukies"
	cost = 38
	weight = 2
	stage = 3

/datum/storyteller/action/dynamic_roundstart/revolution
	id = "roundstart_revolution"
	name = "Roundstart Revolution"
	dynamic_ruleset_type = /datum/dynamic_ruleset/roundstart/revolution
	family = "roundstart_revolution"
	cost = 32
	weight = 3
	stage = 3

/datum/storyteller/action/dynamic_roundstart/spies
	id = "roundstart_spies"
	name = "Roundstart Spies"
	dynamic_ruleset_type = /datum/dynamic_ruleset/roundstart/spies
	family = "roundstart_spies"
	cost = 24
	weight = 4
	stage = 2

/datum/storyteller/action/dynamic_latejoin
	parent_type = /datum/storyteller/action/dynamic_base
	context = STORYTELLER_CONTEXT_LATEJOIN
	polarity = STORYTELLER_POLARITY_NEGATIVE
	family = "latejoin_hostile"
	latejoin_hostile = TRUE
	allow_in_extended = FALSE

/datum/storyteller/action/dynamic_latejoin/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(is_ruleset_disabled())
		return list("available" = FALSE, "reason" = "Disabled in Dynamic admin panel")

	var/datum/dynamic_ruleset/latejoin/checker = build_ruleset()
	if(!istype(checker))
		return list("available" = FALSE, "reason" = "Failed to create ruleset")
	var/player_count = get_active_player_count(afk_check = TRUE)
	var/available = checker.can_be_selected() && meets_population_requirement(checker, player_count)
	qdel(checker)

	if(!available)
		return list("available" = FALSE, "reason" = "Ruleset cannot currently be selected")
	return ..()

/datum/storyteller/action/dynamic_latejoin/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/mob/living/carbon/human/latejoiner = context_data["latejoiner"]
	if(!istype(latejoiner))
		return FALSE

	var/datum/dynamic_ruleset/latejoin/running = build_ruleset()
	if(!istype(running))
		return FALSE

	var/player_count = get_active_player_count(afk_check = TRUE)
	if(!running.prepare_execution(player_count, list(latejoiner)))
		owner.record_decision("Latejoin [name] failed: [running.log_data || "unknown reason"]")
		qdel(running)
		return FALSE

	running.execute()
	owner.track_dynamic_ruleset(running)
	owner.note_latejoin_hostile_trigger()
	owner.record_action_execution(src, "Latejoin target: [key_name(latejoiner)]")
	return TRUE

/datum/storyteller/action/dynamic_latejoin/force_execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(!owner.queue_dynamic_ruleset_action(src, context_data["admin_user"]))
		return FALSE
	owner.record_decision("Queued latejoin storyteller ruleset [name] for the next eligible joining player.")
	return TRUE

/datum/storyteller/action/dynamic_latejoin/traitor
	id = "latejoin_traitor"
	name = "Latejoin Traitor"
	dynamic_ruleset_type = /datum/dynamic_ruleset/latejoin/traitor
	cost = 14
	weight = 10

/datum/storyteller/action/dynamic_latejoin/changeling
	id = "latejoin_changeling"
	name = "Latejoin Changeling"
	dynamic_ruleset_type = /datum/dynamic_ruleset/latejoin/changeling
	cost = 16
	weight = 6
	stage = 2

/datum/storyteller/action/dynamic_latejoin/revolution
	id = "latejoin_revolution"
	name = "Latejoin Revolution"
	dynamic_ruleset_type = /datum/dynamic_ruleset/latejoin/revolution
	cost = 22
	weight = 3
	stage = 3

/datum/storyteller/action/dynamic_latejoin/vampire
	id = "latejoin_vampire"
	name = "Latejoin Vampire"
	dynamic_ruleset_type = /datum/dynamic_ruleset/latejoin/vampire
	cost = 18
	weight = 5
	stage = 2

/datum/storyteller/action/dynamic_midround
	parent_type = /datum/storyteller/action/dynamic_base
	context = STORYTELLER_CONTEXT_MIDROUND
	polarity = STORYTELLER_POLARITY_NEGATIVE
	family = "midround_dynamic"
	allow_in_extended = FALSE

/datum/storyteller/action/dynamic_midround/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(is_ruleset_disabled())
		return list("available" = FALSE, "reason" = "Disabled in Dynamic admin panel")

	var/datum/dynamic_ruleset/midround/checker = build_ruleset()
	if(!istype(checker))
		return list("available" = FALSE, "reason" = "Failed to create ruleset")
	var/player_count = get_active_player_count(afk_check = TRUE)
	var/available = checker.can_be_selected() && meets_population_requirement(checker, player_count)
	qdel(checker)

	if(!available)
		return list("available" = FALSE, "reason" = "Ruleset cannot currently be selected")
	return ..()

/datum/storyteller/action/dynamic_midround/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/datum/dynamic_ruleset/midround/running = build_ruleset()
	if(!istype(running))
		return FALSE

	var/player_count = get_active_player_count(afk_check = TRUE)
	var/list/candidates = running.collect_candidates()
	if(!running.prepare_execution(player_count, candidates))
		owner.record_decision("Midround [name] failed: [running.log_data || "unknown reason"]")
		qdel(running)
		return FALSE

	running.execute()
	owner.track_dynamic_ruleset(running)
	owner.record_action_execution(src, "Midround minds: [owner.format_selected_minds(running.selected_minds)]")
	return TRUE

/datum/storyteller/action/dynamic_midround/force_execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/mob/admin = context_data["admin_user"]
	if(!SSdynamic.force_run_midround(dynamic_ruleset_type, alert_admins_on_fail = TRUE, admin = admin))
		return FALSE
	owner.record_action_execution(src, "Forced midround execution", spend_budget = FALSE)
	return TRUE

/datum/storyteller/action/dynamic_midround/from_living_traitor
	id = "midround_from_living_traitor"
	name = "Sleeper Agent"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_living/traitor
	family = "midround_sleeper"
	cost = 16
	weight = 9

/datum/storyteller/action/dynamic_midround/heretic
	id = "midround_heretic"
	name = "Heretic"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_living/heretic
	family = "midround_heretic"
	cost = 22
	weight = 4
	stage = 2

/datum/storyteller/action/dynamic_midround/clock_cultist
	id = "midround_clock_cultist"
	name = "Clock Cultist"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_living/clock_cultist
	family = "midround_clock_cultist"
	cost = 30
	weight = 2
	stage = 3

/datum/storyteller/action/dynamic_midround/spiders
	id = "midround_spiders"
	name = "Spiders"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/spiders
	family = "midround_spiders"
	cost = 20
	weight = 6

/datum/storyteller/action/dynamic_midround/pirates
	id = "midround_pirates"
	name = "Pirates"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/pirates
	family = "midround_pirates"
	cost = 15
	weight = 8

/datum/storyteller/action/dynamic_midround/pirates_heavy
	id = "midround_pirates_heavy"
	name = "Heavy Pirates"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/pirates/heavy
	family = "midround_pirates"
	cost = 22
	weight = 5

/datum/storyteller/action/dynamic_midround/fugitives
	id = "midround_fugitives"
	name = "Fugitives"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/fugitives
	family = "midround_fugitives"
	cost = 18
	weight = 6

/datum/storyteller/action/dynamic_midround/from_living_traitor_mass
	id = "midround_mass_sleeper_agent"
	name = "Mass Sleeper Agents"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_living/traitor/mass
	family = "midround_sleeper"
	cost = 26
	weight = 3
	stage = 3

/datum/storyteller/action/dynamic_midround/malf_ai
	id = "midround_malf_ai"
	name = "Malfunctioning AI"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_living/malf_ai
	family = "midround_malf_ai"
	cost = 24
	weight = 4
	stage = 2

/datum/storyteller/action/dynamic_midround/blob_infection
	id = "midround_blob_infection"
	name = "Blob Infection"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_living/blob
	family = "midround_blob"
	cost = 28
	weight = 3
	stage = 3

/datum/storyteller/action/dynamic_midround/obsessed
	id = "midround_obsessed"
	name = "Obsessed"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_living/obsesed
	family = "midround_obsessed"
	cost = 16
	weight = 5
	stage = 2

/datum/storyteller/action/dynamic_midround/vampire
	id = "midround_vampire"
	name = "Vampiric Accident"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_living/vampire
	family = "midround_vampire"
	cost = 19
	weight = 5
	stage = 2

/datum/storyteller/action/dynamic_midround/ghost_wizard
	id = "midround_ghost_wizard"
	name = "Ghost Wizard"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/wizard
	family = "midround_wizard"
	cost = 28
	weight = 3
	stage = 3

/datum/storyteller/action/dynamic_midround/ghost_nukies
	id = "midround_ghost_nukies"
	name = "Ghost Nuclear Operatives"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/nukies
	family = "midround_nukies"
	cost = 36
	weight = 2
	stage = 3

/datum/storyteller/action/dynamic_midround/ghost_clown_nukies
	id = "midround_ghost_clown_nukies"
	name = "Ghost Clown Operatives"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/nukies/clown
	family = "midround_nukies"
	cost = 34
	weight = 2
	stage = 3

/datum/storyteller/action/dynamic_midround/ghost_blob
	id = "midround_ghost_blob"
	name = "Ghost Blob"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/blob
	family = "midround_blob"
	cost = 30
	weight = 3
	stage = 3

/datum/storyteller/action/dynamic_midround/xenomorph
	id = "midround_xenomorph"
	name = "Xenomorph"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/xenomorph
	family = "midround_xenomorph"
	cost = 24
	weight = 4
	stage = 3

/datum/storyteller/action/dynamic_midround/blood_worms
	id = "midround_blood_worms"
	name = "Blood Worm Infestation"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/blood_worms
	family = "midround_blood_worm"
	cost = 24
	weight = 3
	stage = 3

/datum/storyteller/action/dynamic_midround/nightmare
	id = "midround_nightmare"
	name = "Nightmare"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/nightmare
	family = "midround_nightmare"
	cost = 18
	weight = 4
	stage = 2

/datum/storyteller/action/dynamic_midround/space_dragon
	id = "midround_space_dragon"
	name = "Space Dragon"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/space_dragon
	family = "midround_space_dragon"
	cost = 34
	weight = 2
	stage = 3

/datum/storyteller/action/dynamic_midround/abductors
	id = "midround_abductors"
	name = "Abductors"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/abductors
	family = "midround_abductors"
	cost = 24
	weight = 3
	stage = 3

/datum/storyteller/action/dynamic_midround/space_ninja
	id = "midround_space_ninja"
	name = "Space Ninja"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/space_ninja
	family = "midround_space_ninja"
	cost = 24
	weight = 3
	stage = 3

/datum/storyteller/action/dynamic_midround/revenant
	id = "midround_revenant"
	name = "Revenant"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/revenant
	family = "midround_revenant"
	cost = 20
	weight = 4
	stage = 2

/datum/storyteller/action/dynamic_midround/space_changeling
	id = "midround_space_changeling"
	name = "Space Changeling"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/space_changeling
	family = "midround_space_changeling"
	cost = 20
	weight = 4
	stage = 2

/datum/storyteller/action/dynamic_midround/paradox_clone
	id = "midround_paradox_clone"
	name = "Paradox Clone"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/paradox_clone
	family = "midround_paradox"
	cost = 18
	weight = 4
	stage = 2

/datum/storyteller/action/dynamic_midround/voidwalker
	id = "midround_voidwalker"
	name = "Voidwalker"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/voidwalker
	family = "midround_voidwalker"
	cost = 19
	weight = 4
	stage = 2

/datum/storyteller/action/dynamic_midround/morph
	id = "midround_morph"
	name = "Morph"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/morph
	family = "midround_morph"
	cost = 17
	weight = 4
	stage = 2

/datum/storyteller/action/dynamic_midround/slaughter_demon
	id = "midround_slaughter_demon"
	name = "Slaughter Demon"
	dynamic_ruleset_type = /datum/dynamic_ruleset/midround/from_ghosts/slaughter_demon
	family = "midround_slaughter_demon"
	cost = 20
	weight = 3
	stage = 3

/datum/storyteller/action/random_event
	context = STORYTELLER_CONTEXT_MIDROUND
	polarity = STORYTELLER_POLARITY_NEGATIVE
	family = "midround_event"
	allow_in_extended = FALSE
	var/event_control_type

/datum/storyteller/action/random_event/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/datum/round_event_control/control = owner.get_event_control(event_control_type)
	if(!istype(control))
		return list("available" = FALSE, "reason" = "Round event control unavailable")
	var/player_count = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	if(!control.can_spawn_event(player_count))
		return list("available" = FALSE, "reason" = "Event preconditions failed")
	return ..()

/datum/storyteller/action/random_event/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(!owner.get_event_control(event_control_type))
		return FALSE
	force_event_async(event_control_type, "the storyteller")
	owner.record_action_execution(src)
	return TRUE

/datum/storyteller/action/random_event/stray_cargo
	id = "event_stray_cargo"
	name = "Stray Cargo"
	event_control_type = /datum/round_event_control/stray_cargo
	polarity = STORYTELLER_POLARITY_POSITIVE
	family = "aid_support_drop"
	cost = 8
	weight = 7
	allow_in_extended = TRUE
	extended_weight = 2

/datum/storyteller/action/random_event/communications_blackout
	id = "event_communications_blackout"
	name = "Communications Blackout"
	event_control_type = /datum/round_event_control/communications_blackout
	family = "event_infrastructure"
	cost = 12
	weight = 8

/datum/storyteller/action/random_event/communications_blackout/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/engineering_staff = owner?.current_snapshot ? (owner.current_snapshot.engineer_count + owner.current_snapshot.atmos_count) : 0
	return get_staff_scaled_weight(base_weight, engineering_staff, 0.25, 0.55, 0.9, 0.12, 1.45)

/datum/storyteller/action/random_event/electrical_storm
	id = "event_electrical_storm"
	name = "Electrical Storm"
	event_control_type = /datum/round_event_control/electrical_storm
	family = "event_infrastructure"
	cost = 12
	weight = 8

/datum/storyteller/action/random_event/electrical_storm/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/engineering_staff = owner?.current_snapshot ? (owner.current_snapshot.engineer_count + owner.current_snapshot.atmos_count) : 0
	return get_staff_scaled_weight(base_weight, engineering_staff, 0.25, 0.55, 0.9, 0.12, 1.45)

/datum/storyteller/action/random_event/grid_check
	id = "event_grid_check"
	name = "Grid Check"
	event_control_type = /datum/round_event_control/grid_check
	family = "event_infrastructure"
	cost = 14
	weight = 7

/datum/storyteller/action/random_event/grid_check/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/engineering_staff = owner?.current_snapshot ? (owner.current_snapshot.engineer_count + owner.current_snapshot.atmos_count) : 0
	return get_staff_scaled_weight(base_weight, engineering_staff, 0.2, 0.5, 0.85, 0.12, 1.45)

/datum/storyteller/action/random_event/carp_migration
	id = "event_carp_migration"
	name = "Carp Migration"
	event_control_type = /datum/round_event_control/carp_migration
	family = "event_lifesigns"
	cost = 14
	weight = 6

/datum/storyteller/action/random_event/mice_migration
	id = "event_mice_migration"
	name = "Mice Migration"
	event_control_type = /datum/round_event_control/mice_migration
	family = "event_lifesigns"
	cost = 8
	weight = 6
	allow_in_extended = TRUE
	extended_weight = 2

/datum/storyteller/action/random_event/radiation_leak
	id = "event_radiation_leak"
	name = "Radiation Leak"
	event_control_type = /datum/round_event_control/radiation_leak
	family = "event_hazard"
	cost = 14
	weight = 6

/datum/storyteller/action/random_event/radiation_leak/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/support_staff = owner?.current_snapshot ? (owner.current_snapshot.engineer_count + owner.current_snapshot.atmos_count + owner.current_snapshot.medical_staff_count) : 0
	base_weight = get_staff_scaled_weight(base_weight, support_staff, 0.3, 0.6, 0.9, 0.1, 1.4)
	return get_population_scaled_weight(base_weight, owner?.current_snapshot?.alive_crew || 0, 28, 0.8, 1.35)

/datum/storyteller/action/random_event/vent_clog
	id = "event_vent_clog"
	name = "Vent Clog"
	event_control_type = /datum/round_event_control/vent_clog
	family = "event_hazard"
	cost = 10
	weight = 7
	allow_in_extended = TRUE
	extended_weight = 2

/datum/storyteller/action/random_event/anomaly_bluespace
	id = "event_anomaly_bluespace"
	name = "Bluespace Anomaly"
	event_control_type = /datum/round_event_control/anomaly/anomaly_bluespace
	family = "event_anomaly"
	cost = 16
	weight = 5

/datum/storyteller/action/random_event/anomaly_bluespace/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/science_staff = owner?.current_snapshot ? owner.current_snapshot.science_staff_count : 0
	return get_staff_scaled_weight(base_weight, science_staff, 0.25, 0.55, 0.85, 0.12, 1.45)

/datum/storyteller/action/random_event/anomaly_hallucination
	id = "event_anomaly_hallucination"
	name = "Hallucination Anomaly"
	event_control_type = /datum/round_event_control/anomaly/anomaly_hallucination
	family = "event_anomaly"
	cost = 14
	weight = 5

/datum/storyteller/action/random_event/anomaly_hallucination/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/science_staff = owner?.current_snapshot ? owner.current_snapshot.science_staff_count : 0
	return get_staff_scaled_weight(base_weight, science_staff, 0.25, 0.55, 0.85, 0.12, 1.45)

/datum/storyteller/action/random_event/anomaly_flux
	id = "event_anomaly_flux"
	name = "Flux Anomaly"
	event_control_type = /datum/round_event_control/anomaly/anomaly_flux
	family = "event_anomaly"
	cost = 17
	weight = 4
	stage = 2

/datum/storyteller/action/random_event/anomaly_flux/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/science_staff = owner?.current_snapshot ? owner.current_snapshot.science_staff_count : 0
	var/engineering_staff = owner?.current_snapshot ? (owner.current_snapshot.engineer_count + owner.current_snapshot.atmos_count) : 0
	base_weight = get_staff_scaled_weight(base_weight, science_staff, 0.2, 0.55, 0.9, 0.12, 1.45)
	return get_staff_scaled_weight(base_weight, engineering_staff, 0.25, 0.6, 0.95, 0.1, 1.45)

/datum/storyteller/action/random_event/anomaly_pyro
	id = "event_anomaly_pyro"
	name = "Pyroclastic Anomaly"
	event_control_type = /datum/round_event_control/anomaly/anomaly_pyro
	family = "event_anomaly"
	cost = 17
	weight = 4
	stage = 2

/datum/storyteller/action/random_event/anomaly_pyro/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/support_staff = owner?.current_snapshot ? (owner.current_snapshot.science_staff_count + owner.current_snapshot.engineer_count + owner.current_snapshot.atmos_count) : 0
	return get_staff_scaled_weight(base_weight, support_staff, 0.2, 0.55, 0.9, 0.12, 1.45)

/datum/storyteller/action/random_event/anomaly_grav
	id = "event_anomaly_grav"
	name = "Gravitational Anomaly"
	event_control_type = /datum/round_event_control/anomaly/anomaly_grav
	family = "event_anomaly"
	cost = 18
	weight = 4
	stage = 2

/datum/storyteller/action/random_event/anomaly_grav/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/science_staff = owner?.current_snapshot ? owner.current_snapshot.science_staff_count : 0
	return get_staff_scaled_weight(base_weight, science_staff, 0.2, 0.55, 0.9, 0.12, 1.45)

/datum/storyteller/action/random_event/anomaly_vortex
	id = "event_anomaly_vortex"
	name = "Vortex Anomaly"
	event_control_type = /datum/round_event_control/anomaly/anomaly_vortex
	family = "event_anomaly"
	cost = 20
	weight = 3
	stage = 3

/datum/storyteller/action/random_event/anomaly_vortex/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/science_staff = owner?.current_snapshot ? owner.current_snapshot.science_staff_count : 0
	var/engineering_staff = owner?.current_snapshot ? (owner.current_snapshot.engineer_count + owner.current_snapshot.atmos_count) : 0
	base_weight = get_staff_scaled_weight(base_weight, science_staff, 0.2, 0.5, 0.85, 0.12, 1.4)
	return get_staff_scaled_weight(base_weight, engineering_staff, 0.2, 0.45, 0.8, 0.12, 1.4)

/datum/storyteller/action/random_event/anomaly_ectoplasm
	id = "event_anomaly_ectoplasm"
	name = "Ectoplasmic Anomaly"
	event_control_type = /datum/round_event_control/anomaly/anomaly_ectoplasm
	family = "event_anomaly"
	cost = 15
	weight = 4
	stage = 2

/datum/storyteller/action/random_event/anomaly_ectoplasm/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/science_staff = owner?.current_snapshot ? owner.current_snapshot.science_staff_count : 0
	return get_staff_scaled_weight(base_weight, science_staff, 0.25, 0.55, 0.85, 0.12, 1.4)

/datum/storyteller/action/random_event/anomaly_dimensional
	id = "event_anomaly_dimensional"
	name = "Dimensional Anomaly"
	event_control_type = /datum/round_event_control/anomaly/anomaly_dimensional
	family = "event_anomaly"
	cost = 18
	weight = 3
	stage = 3

/datum/storyteller/action/random_event/anomaly_dimensional/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/science_staff = owner?.current_snapshot ? owner.current_snapshot.science_staff_count : 0
	return get_staff_scaled_weight(base_weight, science_staff, 0.2, 0.5, 0.85, 0.12, 1.4)

/datum/storyteller/action/random_event/anomaly_bioscrambler
	id = "event_anomaly_bioscrambler"
	name = "Bioscrambler Anomaly"
	event_control_type = /datum/round_event_control/anomaly/anomaly_bioscrambler
	family = "event_anomaly"
	cost = 17
	weight = 3
	stage = 3

/datum/storyteller/action/random_event/anomaly_bioscrambler/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/science_staff = owner?.current_snapshot ? owner.current_snapshot.science_staff_count : 0
	var/medical_staff = owner?.current_snapshot ? owner.current_snapshot.medical_staff_count : 0
	base_weight = get_staff_scaled_weight(base_weight, science_staff, 0.2, 0.5, 0.85, 0.12, 1.4)
	return get_staff_scaled_weight(base_weight, medical_staff, 0.25, 0.55, 0.9, 0.1, 1.4)

/datum/storyteller/action/random_event/anomaly_weather
	id = "event_anomaly_weather"
	name = "Barometric Anomaly"
	event_control_type = /datum/round_event_control/anomaly/anomaly_weather
	family = "event_anomaly"
	cost = 16
	weight = 3
	stage = 2

/datum/storyteller/action/random_event/anomaly_weather/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/science_staff = owner?.current_snapshot ? owner.current_snapshot.science_staff_count : 0
	return get_staff_scaled_weight(base_weight, science_staff, 0.2, 0.5, 0.85, 0.12, 1.4)

/datum/storyteller/action/random_event/anomaly_weather_thundering
	id = "event_anomaly_weather_thundering"
	name = "Severe Barometric Anomaly"
	event_control_type = /datum/round_event_control/anomaly/anomaly_weather/thundering
	family = "event_anomaly"
	cost = 20
	weight = 2
	stage = 3

/datum/storyteller/action/random_event/anomaly_weather_thundering/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/science_staff = owner?.current_snapshot ? owner.current_snapshot.science_staff_count : 0
	return get_staff_scaled_weight(base_weight, science_staff, 0.15, 0.45, 0.8, 0.12, 1.35)

/datum/storyteller/action/random_event/camera_failure
	id = "event_camera_failure"
	name = "Camera Failure"
	event_control_type = /datum/round_event_control/camera_failure
	family = "event_infrastructure"
	cost = 9
	weight = 7
	allow_in_extended = TRUE
	extended_weight = 2

/datum/storyteller/action/random_event/camera_failure/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/security_staff = owner?.current_snapshot ? owner.current_snapshot.security_staff_count : 0
	return get_staff_scaled_weight(base_weight, security_staff, 0.35, 0.65, 0.95, 0.1, 1.35)

/datum/storyteller/action/random_event/aurora_caelus
	id = "event_aurora_caelus"
	name = "Aurora Caelus"
	event_control_type = /datum/round_event_control/aurora_caelus
	polarity = STORYTELLER_POLARITY_POSITIVE
	family = "aid_aurora"
	cost = 7
	weight = 5
	allow_in_extended = TRUE
	extended_weight = 3

/datum/storyteller/action/random_event/fake_virus
	id = "event_fake_virus"
	name = "Fake Virus"
	event_control_type = /datum/round_event_control/fake_virus
	family = "event_hoax"
	cost = 9
	weight = 6
	allow_in_extended = TRUE
	extended_weight = 2

/datum/storyteller/action/random_event/fake_virus/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/medical_staff = owner?.current_snapshot ? owner.current_snapshot.medical_staff_count : 0
	base_weight = get_staff_scaled_weight(base_weight, medical_staff, 0.3, 0.6, 0.9, 0.1, 1.4)
	return get_population_scaled_weight(base_weight, owner?.current_snapshot?.alive_crew || 0, 24, 0.8, 1.35)

/datum/storyteller/action/random_event/space_dust
	id = "event_space_dust"
	name = "Minor Space Dust"
	event_control_type = /datum/round_event_control/space_dust
	family = "event_space"
	cost = 7
	weight = 8
	allow_in_extended = TRUE
	extended_weight = 2

/datum/storyteller/action/random_event/space_dust/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/engineering_staff = owner?.current_snapshot ? (owner.current_snapshot.engineer_count + owner.current_snapshot.atmos_count) : 0
	base_weight = get_staff_scaled_weight(base_weight, engineering_staff, 0.25, 0.55, 0.85, 0.12, 1.5)
	return get_population_scaled_weight(base_weight, owner?.current_snapshot?.alive_crew || 0, 24, 0.8, 1.35)

/datum/storyteller/action/random_event/space_dust/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(!owner.get_event_control(event_control_type))
		return FALSE
	owner.announce_storyteller_alert(pick(
		"Long-range collision screens show a thin debris front crossing the station's orbital track. Expect light damage to exposed hull sections.",
		"Residual ore fragments from a nearby mining route are drifting across the station's approach vector. EVA personnel should clear open space immediately.",
		"A belt of micrometeoroid dust is brushing past the station. Minor scarring to external fittings is expected.",
	), "Collision Advisory", ANNOUNCER_METEORS)
	force_event_async(event_control_type, "the storyteller")
	owner.record_action_execution(src)
	return TRUE

/datum/storyteller/action/random_event/major_space_dust
	id = "event_major_space_dust"
	name = "Major Space Dust"
	event_control_type = /datum/round_event_control/meteor_wave/dust_storm
	family = "event_space"
	cost = 12
	weight = 4
	allow_in_extended = TRUE
	extended_weight = 1

/datum/storyteller/action/random_event/major_space_dust/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/engineering_staff = owner?.current_snapshot ? (owner.current_snapshot.engineer_count + owner.current_snapshot.atmos_count) : 0
	base_weight = get_staff_scaled_weight(base_weight, engineering_staff, 0.2, 0.45, 0.8, 0.12, 1.45)
	return get_population_scaled_weight(base_weight, owner?.current_snapshot?.alive_crew || 0, 26, 0.8, 1.35)

/datum/storyteller/action/random_event/meteor_wave
	id = "event_meteor_wave"
	name = "Meteor Wave"
	event_control_type = /datum/round_event_control/meteor_wave
	family = "event_space"
	cost = 20
	weight = 4

/datum/storyteller/action/random_event/meteor_wave/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/engineering_staff = owner?.current_snapshot ? (owner.current_snapshot.engineer_count + owner.current_snapshot.atmos_count) : 0
	base_weight = get_staff_scaled_weight(base_weight, engineering_staff, 0.12, 0.35, 0.7, 0.15, 1.55)
	return get_population_scaled_weight(base_weight, owner?.current_snapshot?.alive_crew || 0, 22, 0.85, 1.45)

/datum/storyteller/action/random_event/disease_outbreak
	id = "event_disease_outbreak"
	name = "Disease Outbreak: Classic"
	event_control_type = /datum/round_event_control/disease_outbreak
	family = "event_health"
	cost = 13
	weight = 5
	allow_in_extended = TRUE
	extended_weight = 1

/datum/storyteller/action/random_event/disease_outbreak/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/medical_staff = owner?.current_snapshot ? owner.current_snapshot.medical_staff_count : 0
	base_weight = get_staff_scaled_weight(base_weight, medical_staff, 0.2, 0.5, 0.85, 0.12, 1.45)
	return get_population_scaled_weight(base_weight, owner?.current_snapshot?.alive_crew || 0, 20, 0.85, 1.45)

/datum/storyteller/action/random_event/heart_attack
	id = "event_heart_attack"
	name = "Random Heart Attack"
	event_control_type = /datum/round_event_control/heart_attack
	family = "event_health"
	cost = 11
	weight = 4
	allow_in_extended = TRUE
	extended_weight = 1

/datum/storyteller/action/random_event/heart_attack/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/medical_staff = owner?.current_snapshot ? owner.current_snapshot.medical_staff_count : 0
	base_weight = get_staff_scaled_weight(base_weight, medical_staff, 0.25, 0.55, 0.9, 0.12, 1.45)
	return get_population_scaled_weight(base_weight, owner?.current_snapshot?.alive_crew || 0, 40, 0.75, 1.3)

/datum/storyteller/action/random_event/heart_attack/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(!owner.get_event_control(event_control_type))
		return FALSE
	owner.announce_storyteller_notice(
		"Medical telemetry has flagged elevated cardiac risk aboard the station. Medbay should remain prepared for sudden cardiac emergencies.",
		"Medical Advisory",
		'sound/announcer/medbot/attention.ogg',
		"red",
	)
	force_event_async(event_control_type, "the storyteller")
	owner.record_action_execution(src)
	return TRUE

/datum/storyteller/action/random_event/brand_intelligence
	id = "event_brand_intelligence"
	name = "Brand Intelligence"
	event_control_type = /datum/round_event_control/brand_intelligence
	family = "event_machine"
	cost = 15
	weight = 5

/datum/storyteller/action/random_event/brand_intelligence/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/support_staff = owner?.current_snapshot ? (owner.current_snapshot.science_staff_count + owner.current_snapshot.security_staff_count) : 0
	base_weight = get_staff_scaled_weight(base_weight, support_staff, 0.35, 0.65, 0.95, 0.1, 1.4)
	return get_population_scaled_weight(base_weight, owner?.current_snapshot?.alive_crew || 0, 22, 0.8, 1.35)

/datum/storyteller/action/timed_modifier
	context = STORYTELLER_CONTEXT_MIDROUND
	var/modifier_id
	var/modifier_title
	var/min_duration = 4 MINUTES
	var/max_duration = 7 MINUTES
	var/dispatch_title = "Operational Notice"
	var/dispatch_sound = 'sound/announcer/notice/notice2.ogg'
	var/dispatch_color = "blue"
	var/modifier_is_positive = TRUE

/datum/storyteller/action/timed_modifier/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(modifier_id && owner.has_active_modifier(modifier_id))
		return list("available" = FALSE, "reason" = "Conflicting storyteller modifier already active")
	return ..()

/datum/storyteller/action/timed_modifier/proc/get_modifier_duration(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return rand(min_duration, max(max_duration, min_duration))

/datum/storyteller/action/timed_modifier/proc/get_modifier_multiplier(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return 1

/datum/storyteller/action/timed_modifier/proc/get_modifier_label(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return "[modifier_title || name]"

/datum/storyteller/action/timed_modifier/proc/get_modifier_description(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return get_dispatch_message(owner, snapshot, context_data, modifier_multiplier, duration)

/datum/storyteller/action/timed_modifier/proc/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return "[modifier_title || name] is now active."

/datum/storyteller/action/timed_modifier/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(!modifier_id)
		return FALSE
	var/duration = get_modifier_duration(owner, snapshot, context_data)
	var/modifier_multiplier = get_modifier_multiplier(owner, snapshot, context_data)
	if(duration <= 0 || modifier_multiplier <= 0)
		return FALSE
	var/modifier_label = get_modifier_label(owner, snapshot, context_data, modifier_multiplier, duration)
	var/modifier_description = get_modifier_description(owner, snapshot, context_data, modifier_multiplier, duration)
	if(!owner.apply_timed_modifier(modifier_id, modifier_multiplier, duration, modifier_label, modifier_title || name, modifier_is_positive, modifier_description))
		return FALSE
	owner.announce_storyteller_notice(get_dispatch_message(owner, snapshot, context_data, modifier_multiplier, duration), dispatch_title, dispatch_sound, dispatch_color)
	owner.record_action_execution(src, "[round(modifier_multiplier, 0.01)]x for [DisplayTimeText(duration, round_seconds_to = 1)]")
	return TRUE

/datum/storyteller/action/negative
	context = STORYTELLER_CONTEXT_MIDROUND
	polarity = STORYTELLER_POLARITY_NEGATIVE

/datum/storyteller/action/positive
	polarity = STORYTELLER_POLARITY_POSITIVE
	context = STORYTELLER_CONTEXT_MIDROUND
	allow_in_extended = TRUE

/datum/storyteller/action/positive/timed_modifier
	parent_type = /datum/storyteller/action/timed_modifier
	polarity = STORYTELLER_POLARITY_POSITIVE
	modifier_is_positive = TRUE
	dispatch_color = "green"

/datum/storyteller/action/negative/timed_modifier
	parent_type = /datum/storyteller/action/timed_modifier
	polarity = STORYTELLER_POLARITY_NEGATIVE
	modifier_is_positive = FALSE
	dispatch_sound = 'sound/announcer/notice/notice1.ogg'
	dispatch_color = "orange"
	allow_in_extended = TRUE
	extended_weight = 1

/datum/storyteller/action/positive/timed_modifier/cargo_sales_surge
	id = "aid_cargo_sales_surge"
	name = "Cargo Contract Surge"
	family = "aid_cargo_sales"
	cost = 11
	weight = 7
	supported_need_ids = list(STORYTELLER_NEED_MATERIAL_SHORTAGE)
	modifier_id = STORYTELLER_MOD_CARGO_SALES
	modifier_title = "Cargo Contract Surge"
	dispatch_title = "Cargo Incentive Dispatch"
	dispatch_sound = 'sound/announcer/notice/notice3.ogg'

/datum/storyteller/action/positive/timed_modifier/cargo_sales_surge/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(snapshot?.cargo_staff_count <= 0)
		return list("available" = FALSE, "reason" = "No cargo staff are available to capitalize on a logistics contract")
	return ..()

/datum/storyteller/action/positive/timed_modifier/cargo_sales_surge/get_modifier_duration(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return rand(4 MINUTES, 7 MINUTES)

/datum/storyteller/action/positive/timed_modifier/cargo_sales_surge/get_modifier_multiplier(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/datum/storyteller/need_report/report = context_data["need_report"]
	var/crew_ratio = clamp((snapshot?.alive_crew || 0) / 55, 0, 1)
	var/severity_ratio = clamp((report?.severity || 0) / 100, 0, 1)
	return round(max(1.2, 1.85 - (crew_ratio * 0.5) + (severity_ratio * 0.15)), 0.01)

/datum/storyteller/action/positive/timed_modifier/cargo_sales_surge/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return "Central Command has routed a temporary high-priority contract package to Cargo. Shuttle exports and civilian bounty payouts will return [round(modifier_multiplier, 0.01)]x value for [DisplayTimeText(duration, round_seconds_to = 1)]."

/datum/storyteller/action/positive/timed_modifier/cargo_sales_surge/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/cargo_budget = owner?.current_snapshot?.cargo_budget || 0
	if(cargo_budget < 8000)
		base_weight += 4
	else if(cargo_budget < 12000)
		base_weight += 2
	return base_weight

/datum/storyteller/action/positive/timed_modifier/cargo_processing_surge
	id = "aid_cargo_processing_surge"
	name = "Smelter Efficiency Surge"
	family = "aid_cargo_processing"
	cost = 12
	weight = 6
	supported_need_ids = list(STORYTELLER_NEED_MATERIAL_SHORTAGE)
	modifier_id = STORYTELLER_MOD_CARGO_PROCESSING
	modifier_title = "Smelter Efficiency Surge"
	dispatch_title = "Refinery Efficiency Notice"

/datum/storyteller/action/positive/timed_modifier/cargo_processing_surge/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if((snapshot?.miner_count || 0) <= 0 && (snapshot?.cargo_staff_count || 0) <= 0)
		return list("available" = FALSE, "reason" = "No mining or cargo staff are available to use refinery assistance")
	return ..()

/datum/storyteller/action/positive/timed_modifier/cargo_processing_surge/get_modifier_duration(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return rand(5 MINUTES, 8 MINUTES)

/datum/storyteller/action/positive/timed_modifier/cargo_processing_surge/get_modifier_multiplier(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/datum/storyteller/need_report/report = context_data["need_report"]
	var/crew_ratio = clamp((snapshot?.alive_crew || 0) / 55, 0, 1)
	var/severity_ratio = clamp((report?.severity || 0) / 100, 0, 1)
	return round(max(1.15, 1.7 - (crew_ratio * 0.35) + (severity_ratio * 0.2)), 0.01)

/datum/storyteller/action/positive/timed_modifier/cargo_processing_surge/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return "A temporary smelter calibration package has been uplinked to Cargo. Furnaces and ore redemption units will process at [round(modifier_multiplier, 0.01)]x efficiency for [DisplayTimeText(duration, round_seconds_to = 1)]."

/datum/storyteller/action/positive/timed_modifier/science_patent_surge
	id = "aid_science_patent_surge"
	name = "Patent Fast-Track"
	family = "aid_science_patent"
	cost = 10
	weight = 5
	supported_need_ids = list(STORYTELLER_NEED_SCIENCE_SHORTAGE)
	modifier_id = STORYTELLER_MOD_SCIENCE_PATENTS
	modifier_title = "Patent Fast-Track"
	dispatch_title = "Research Incentive Dispatch"

/datum/storyteller/action/positive/timed_modifier/science_patent_surge/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(snapshot?.science_staff_count <= 0)
		return list("available" = FALSE, "reason" = "No science staff are available to benefit from accelerated patent handling")
	return ..()

/datum/storyteller/action/positive/timed_modifier/science_patent_surge/get_modifier_duration(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return rand(6 MINUTES, 9 MINUTES)

/datum/storyteller/action/positive/timed_modifier/science_patent_surge/get_modifier_multiplier(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/crew_ratio = clamp((snapshot?.alive_crew || 0) / 60, 0, 1)
	var/staff_ratio = clamp((snapshot?.science_staff_count || 0) / 6, 0, 1)
	return round(max(1.15, 1.6 - (crew_ratio * 0.2) + (staff_ratio * 0.15)), 0.01)

/datum/storyteller/action/positive/timed_modifier/science_patent_surge/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return "Nanotrasen patent offices have opened a temporary fast-track lane for station research. Techweb breakthroughs will pay [round(modifier_multiplier, 0.01)]x budget for [DisplayTimeText(duration, round_seconds_to = 1)]."

/datum/storyteller/action/positive/timed_modifier/medical_fast_track
	id = "aid_medical_fast_track"
	name = "Medical Fast-Track"
	family = "aid_medical_fast_track"
	cost = 10
	weight = 5
	supported_need_ids = list(STORYTELLER_NEED_MEDICAL_SURGE)
	modifier_id = STORYTELLER_MOD_MEDICAL_REPLICATION
	modifier_title = "Medical Fast-Track"
	dispatch_title = "Medical Systems Notice"
	dispatch_sound = 'sound/announcer/medbot/attention.ogg'

/datum/storyteller/action/positive/timed_modifier/medical_fast_track/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(snapshot?.medical_staff_count <= 0)
		return list("available" = FALSE, "reason" = "No medical staff are available to benefit from a replication fast-track")
	return ..()

/datum/storyteller/action/positive/timed_modifier/medical_fast_track/get_modifier_duration(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return rand(5 MINUTES, 8 MINUTES)

/datum/storyteller/action/positive/timed_modifier/medical_fast_track/get_modifier_multiplier(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/staff_ratio = clamp((snapshot?.medical_staff_count || 0) / 6, 0, 1)
	var/chemist_bonus = (snapshot?.chemist_count || 0) > 0 ? 0.15 : 0
	return round(max(1.15, 1.45 + (staff_ratio * 0.2) + chemist_bonus), 0.01)

/datum/storyteller/action/positive/timed_modifier/medical_fast_track/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return "Medical systems have been placed on emergency fast-track. PanD.E.M.I.C replication cooldowns will run at [round(modifier_multiplier, 0.01)]x speed for [DisplayTimeText(duration, round_seconds_to = 1)]."

/datum/storyteller/action/positive/timed_modifier/botany_growth_surge
	id = "aid_botany_growth_surge"
	name = "Botany Growth Surge"
	family = "aid_botany_growth"
	cost = 10
	weight = 5
	supported_need_ids = list(STORYTELLER_NEED_FOOD_SHORTAGE)
	modifier_id = STORYTELLER_MOD_BOTANY_GROWTH
	modifier_title = "Localized Hypergrowth Field"
	dispatch_title = "Hydroponics Growth Notice"
	dispatch_sound = 'sound/machines/chime.ogg'

/datum/storyteller/action/positive/timed_modifier/botany_growth_surge/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if((snapshot?.botanist_count || 0) <= 0)
		return list("available" = FALSE, "reason" = "No botanists are available to benefit from accelerated growth")
	if(!length(owner?.get_station_hydroponics_trays()))
		return list("available" = FALSE, "reason" = "No station hydroponics trays are available for a localized growth anomaly")
	return ..()

/datum/storyteller/action/positive/timed_modifier/botany_growth_surge/get_modifier_duration(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return rand(6 MINUTES, 10 MINUTES)

/datum/storyteller/action/positive/timed_modifier/botany_growth_surge/get_modifier_multiplier(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/crew_ratio = clamp((snapshot?.alive_crew || 0) / 60, 0, 1)
	var/botanist_bonus = clamp((snapshot?.botanist_count || 0) / 4, 0, 1) * 0.15
	return round(clamp(1.2 + botanist_bonus - (crew_ratio * 0.08), 1.15, 1.45), 0.01)

/datum/storyteller/action/positive/timed_modifier/botany_growth_surge/get_modifier_description(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	var/boost_percent = round((modifier_multiplier - 1) * 100)
	return "Plant analyzer sweep indicates a pollen-dense resonance pocket. Affected trays are maturing faster and carrying heavier harvest mass, with measured growth bias at +[boost_percent]%."

/datum/storyteller/action/positive/timed_modifier/botany_growth_surge/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return "Hydroponics climate control has been temporarily optimized. Plant growth and harvest output will run at [round(modifier_multiplier, 0.01)]x for [DisplayTimeText(duration, round_seconds_to = 1)]."

/datum/storyteller/action/positive/timed_modifier/botany_growth_surge/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/botanist_count = owner?.current_snapshot?.botanist_count || 0
	return get_staff_scaled_weight(base_weight, botanist_count, 0.15, 0.55, 0.85, 0.12, 1.4)

/datum/storyteller/action/positive/timed_modifier/botany_growth_surge/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(!modifier_id)
		return FALSE
	var/duration = get_modifier_duration(owner, snapshot, context_data)
	var/modifier_multiplier = get_modifier_multiplier(owner, snapshot, context_data)
	if(duration <= 0 || modifier_multiplier <= 0)
		return FALSE
	var/modifier_label = get_modifier_label(owner, snapshot, context_data, modifier_multiplier, duration)
	var/modifier_description = get_modifier_description(owner, snapshot, context_data, modifier_multiplier, duration)
	var/affected_trays = owner.apply_botany_growth_anomaly(modifier_multiplier, duration, modifier_label, modifier_description, TRUE, snapshot)
	if(affected_trays <= 0)
		return FALSE
	var/global_description = "[modifier_description] [affected_trays] tray[affected_trays == 1 ? "" : "s"] currently register the anomaly."
	if(!owner.apply_timed_modifier(modifier_id, modifier_multiplier, duration, modifier_label, modifier_title || name, modifier_is_positive, global_description))
		return FALSE
	owner.announce_storyteller_notice("Hydroponics telemetry has identified a localized hypergrowth field affecting [affected_trays] tray[affected_trays == 1 ? "" : "s"]. Botanical scanners can track the anomalous plots for [DisplayTimeText(duration, round_seconds_to = 1)].", dispatch_title, dispatch_sound, dispatch_color)
	owner.record_action_execution(src, "[affected_trays] trays at [round(modifier_multiplier, 0.01)]x for [DisplayTimeText(duration, round_seconds_to = 1)]")
	return TRUE

/datum/storyteller/action/positive/timed_modifier/engineering_power_surge
	id = "aid_engineering_power_surge"
	name = "Engineering Power Surge"
	family = "aid_engineering_power"
	cost = 11
	weight = 5
	supported_need_ids = list(STORYTELLER_NEED_ENGINEERING_REPAIRS)
	modifier_id = STORYTELLER_MOD_ENGINEERING_POWER
	modifier_title = "Resonant Output Window"
	dispatch_title = "Engine Performance Notice"
	dispatch_sound = 'sound/machines/engine_alert/engine_alert1.ogg'

/datum/storyteller/action/positive/timed_modifier/engineering_power_surge/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if((snapshot?.engineer_count || 0) <= 0)
		return list("available" = FALSE, "reason" = "No engineering staff are available to benefit from an engine performance surge")
	var/obj/machinery/power/supermatter_crystal/supermatter = GLOB.main_supermatter_engine
	if(!istype(supermatter) || QDELETED(supermatter))
		return list("available" = FALSE, "reason" = "No supermatter engine is available for a power surge")
	return ..()

/datum/storyteller/action/positive/timed_modifier/engineering_power_surge/get_modifier_duration(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return rand(5 MINUTES, 8 MINUTES)

/datum/storyteller/action/positive/timed_modifier/engineering_power_surge/get_modifier_multiplier(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/crew_ratio = clamp((snapshot?.alive_crew || 0) / 55, 0, 1)
	var/engineer_bonus = clamp(((snapshot?.engineer_count || 0) + (snapshot?.atmos_count || 0)) / 8, 0, 1) * 0.12
	return round(clamp(1.18 + engineer_bonus - (crew_ratio * 0.06), 1.12, 1.38), 0.01)

/datum/storyteller/action/positive/timed_modifier/engineering_power_surge/get_modifier_description(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	var/output_percent = round((modifier_multiplier - 1) * 100)
	return "Engine telemetry shows a favorable resonance band around the crystal. Power generation is running [output_percent]% above baseline while the window remains stable."

/datum/storyteller/action/positive/timed_modifier/engineering_power_surge/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return "Engine telemetry has stabilized around a favorable resonance. Supermatter output is boosted to [round(modifier_multiplier, 0.01)]x efficiency for [DisplayTimeText(duration, round_seconds_to = 1)]."

/datum/storyteller/action/positive/timed_modifier/engineering_power_surge/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/engineering_staff = owner?.current_snapshot ? (owner.current_snapshot.engineer_count + owner.current_snapshot.atmos_count) : 0
	return get_staff_scaled_weight(base_weight, engineering_staff, 0.15, 0.5, 0.85, 0.12, 1.4)

/datum/storyteller/action/negative/timed_modifier/cargo_customs_audit
	id = "event_cargo_customs_audit"
	name = "Cargo Customs Audit"
	family = "event_cargo_sales"
	cost = 9
	weight = 5
	modifier_id = STORYTELLER_MOD_CARGO_SALES
	modifier_title = "Cargo Customs Audit"
	dispatch_title = "Logistics Audit Notice"
	extended_weight = 1

/datum/storyteller/action/negative/timed_modifier/cargo_customs_audit/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(snapshot?.cargo_staff_count <= 0)
		return list("available" = FALSE, "reason" = "No cargo staff are present for a customs slowdown to matter")
	return ..()

/datum/storyteller/action/negative/timed_modifier/cargo_customs_audit/get_modifier_duration(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return rand(4 MINUTES, 6 MINUTES)

/datum/storyteller/action/negative/timed_modifier/cargo_customs_audit/get_modifier_multiplier(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/crew_ratio = clamp((snapshot?.alive_crew || 0) / 50, 0, 1)
	return round(clamp(0.82 - (crew_ratio * 0.12), 0.55, 0.82), 0.01)

/datum/storyteller/action/negative/timed_modifier/cargo_customs_audit/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return "A temporary customs audit has been imposed on station logistics. Shuttle exports and civilian bounty payouts are reduced to [round(modifier_multiplier, 0.01)]x value for [DisplayTimeText(duration, round_seconds_to = 1)]."

/datum/storyteller/action/negative/timed_modifier/cargo_customs_audit/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/cargo_staff = owner?.current_snapshot?.cargo_staff_count || 0
	return get_staff_scaled_weight(base_weight, cargo_staff, 0.2, 0.55, 0.85, 0.12, 1.4)

/datum/storyteller/action/negative/timed_modifier/furnace_slagging
	id = "event_furnace_slagging"
	name = "Furnace Slagging"
	family = "event_cargo_processing"
	cost = 10
	weight = 4
	modifier_id = STORYTELLER_MOD_CARGO_PROCESSING
	modifier_title = "Furnace Slagging"
	dispatch_title = "Refinery Degradation Notice"
	extended_weight = 1

/datum/storyteller/action/negative/timed_modifier/furnace_slagging/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if((snapshot?.miner_count || 0) <= 0 && (snapshot?.cargo_staff_count || 0) <= 0)
		return list("available" = FALSE, "reason" = "No cargo or mining staff are present for refinery slagging to matter")
	return ..()

/datum/storyteller/action/negative/timed_modifier/furnace_slagging/get_modifier_duration(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return rand(4 MINUTES, 7 MINUTES)

/datum/storyteller/action/negative/timed_modifier/furnace_slagging/get_modifier_multiplier(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return round(clamp(0.8 - (((snapshot?.alive_crew || 0) / 60) * 0.12), 0.55, 0.8), 0.01)

/datum/storyteller/action/negative/timed_modifier/furnace_slagging/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return "Refinery telemetry reports contamination in the smelting line. Furnaces and ore redemption units are reduced to [round(modifier_multiplier, 0.01)]x efficiency for [DisplayTimeText(duration, round_seconds_to = 1)]."

/datum/storyteller/action/negative/timed_modifier/furnace_slagging/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/miner_staff = owner?.current_snapshot ? (owner.current_snapshot.miner_count + owner.current_snapshot.cargo_staff_count) : 0
	return get_staff_scaled_weight(base_weight, miner_staff, 0.2, 0.55, 0.85, 0.12, 1.4)

/datum/storyteller/action/negative/timed_modifier/science_review_hold
	id = "event_science_review_hold"
	name = "Research Review Hold"
	family = "event_science_patent"
	cost = 9
	weight = 4
	modifier_id = STORYTELLER_MOD_SCIENCE_PATENTS
	modifier_title = "Research Review Hold"
	dispatch_title = "Research Compliance Notice"
	extended_weight = 1

/datum/storyteller/action/negative/timed_modifier/science_review_hold/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(snapshot?.science_staff_count <= 0)
		return list("available" = FALSE, "reason" = "No science staff are present for a patent review delay to matter")
	return ..()

/datum/storyteller/action/negative/timed_modifier/science_review_hold/get_modifier_duration(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return rand(5 MINUTES, 8 MINUTES)

/datum/storyteller/action/negative/timed_modifier/science_review_hold/get_modifier_multiplier(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return round(clamp(0.78 - (((snapshot?.science_staff_count || 0) / 8) * 0.08), 0.6, 0.78), 0.01)

/datum/storyteller/action/negative/timed_modifier/science_review_hold/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return "A surprise compliance review has stalled Nanotrasen patent processing. Techweb breakthrough payouts are reduced to [round(modifier_multiplier, 0.01)]x value for [DisplayTimeText(duration, round_seconds_to = 1)]."

/datum/storyteller/action/negative/timed_modifier/science_review_hold/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/science_staff = owner?.current_snapshot?.science_staff_count || 0
	return get_staff_scaled_weight(base_weight, science_staff, 0.2, 0.55, 0.85, 0.12, 1.4)

/datum/storyteller/action/negative/timed_modifier/medical_replication_backlog
	id = "event_medical_replication_backlog"
	name = "Medical Replication Backlog"
	family = "event_medical_replication"
	cost = 8
	weight = 4
	modifier_id = STORYTELLER_MOD_MEDICAL_REPLICATION
	modifier_title = "Medical Replication Backlog"
	dispatch_title = "Medical Systems Delay Notice"
	dispatch_sound = 'sound/announcer/medbot/attention.ogg'
	extended_weight = 1

/datum/storyteller/action/negative/timed_modifier/medical_replication_backlog/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(snapshot?.medical_staff_count <= 0)
		return list("available" = FALSE, "reason" = "No medical staff are present for a replication slowdown to matter")
	return ..()

/datum/storyteller/action/negative/timed_modifier/medical_replication_backlog/get_modifier_duration(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return rand(5 MINUTES, 8 MINUTES)

/datum/storyteller/action/negative/timed_modifier/medical_replication_backlog/get_modifier_multiplier(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return round(clamp(0.8 - (((snapshot?.medical_staff_count || 0) / 8) * 0.08), 0.6, 0.8), 0.01)

/datum/storyteller/action/negative/timed_modifier/medical_replication_backlog/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return "Medical replication queues are bogged down by emergency oversight. PanD.E.M.I.C cooldowns are reduced to [round(modifier_multiplier, 0.01)]x speed for [DisplayTimeText(duration, round_seconds_to = 1)]."

/datum/storyteller/action/negative/timed_modifier/medical_replication_backlog/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/medical_staff = owner?.current_snapshot?.medical_staff_count || 0
	return get_staff_scaled_weight(base_weight, medical_staff, 0.2, 0.55, 0.85, 0.12, 1.4)

/datum/storyteller/action/negative/timed_modifier/botany_growth_slump
	id = "event_botany_growth_slump"
	name = "Botany Growth Slump"
	family = "event_botany_growth"
	cost = 8
	weight = 4
	modifier_id = STORYTELLER_MOD_BOTANY_GROWTH
	modifier_title = "Mutagenic Wilt Pocket"
	dispatch_title = "Hydroponics Climate Warning"
	dispatch_sound = 'sound/machines/warning-buzzer.ogg'
	allow_in_extended = TRUE
	extended_weight = 1

/datum/storyteller/action/negative/timed_modifier/botany_growth_slump/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if((snapshot?.botanist_count || 0) <= 0)
		return list("available" = FALSE, "reason" = "No botanists are present for a hydroponics setback to matter")
	if(!length(owner?.get_station_hydroponics_trays()))
		return list("available" = FALSE, "reason" = "No station hydroponics trays are available for a localized growth anomaly")
	return ..()

/datum/storyteller/action/negative/timed_modifier/botany_growth_slump/get_modifier_duration(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return rand(5 MINUTES, 8 MINUTES)

/datum/storyteller/action/negative/timed_modifier/botany_growth_slump/get_modifier_multiplier(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return round(clamp(0.78 - (((snapshot?.botanist_count || 0) / 6) * 0.05), 0.62, 0.78), 0.01)

/datum/storyteller/action/negative/timed_modifier/botany_growth_slump/get_modifier_description(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	var/loss_percent = round((1 - modifier_multiplier) * 100)
	return "Plant analyzer sweep indicates a destabilizing wilt pocket. Affected trays are lagging behind expected growth by [loss_percent]% and are showing a higher chance of hostile genetic drift."

/datum/storyteller/action/negative/timed_modifier/botany_growth_slump/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return "Hydroponics climate control is drifting off target. Plant growth and harvests are reduced to [round(modifier_multiplier, 0.01)]x, and mutation pressure is elevated for [DisplayTimeText(duration, round_seconds_to = 1)]."

/datum/storyteller/action/negative/timed_modifier/botany_growth_slump/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/botanist_count = owner?.current_snapshot?.botanist_count || 0
	return get_staff_scaled_weight(base_weight, botanist_count, 0.15, 0.5, 0.85, 0.12, 1.35)

/datum/storyteller/action/negative/timed_modifier/botany_growth_slump/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(!modifier_id)
		return FALSE
	var/duration = get_modifier_duration(owner, snapshot, context_data)
	var/modifier_multiplier = get_modifier_multiplier(owner, snapshot, context_data)
	if(duration <= 0 || modifier_multiplier <= 0)
		return FALSE
	var/modifier_label = get_modifier_label(owner, snapshot, context_data, modifier_multiplier, duration)
	var/modifier_description = get_modifier_description(owner, snapshot, context_data, modifier_multiplier, duration)
	var/affected_trays = owner.apply_botany_growth_anomaly(modifier_multiplier, duration, modifier_label, modifier_description, FALSE, snapshot)
	if(affected_trays <= 0)
		return FALSE
	var/global_description = "[modifier_description] [affected_trays] tray[affected_trays == 1 ? "" : "s"] currently register the anomaly."
	if(!owner.apply_timed_modifier(modifier_id, modifier_multiplier, duration, modifier_label, modifier_title || name, modifier_is_positive, global_description))
		return FALSE
	owner.announce_storyteller_notice("Botanical scanners are reporting a mutagenic wilt pocket across [affected_trays] tray[affected_trays == 1 ? "" : "s"]. Growth quality is degraded until the anomaly dissipates in roughly [DisplayTimeText(duration, round_seconds_to = 1)].", dispatch_title, dispatch_sound, dispatch_color)
	owner.record_action_execution(src, "[affected_trays] trays at [round(modifier_multiplier, 0.01)]x for [DisplayTimeText(duration, round_seconds_to = 1)]")
	return TRUE

/datum/storyteller/action/negative/timed_modifier/engineering_power_instability
	id = "event_engineering_power_instability"
	name = "Supermatter Grid Instability"
	family = "event_engineering_power"
	cost = 11
	weight = 4
	modifier_id = STORYTELLER_MOD_ENGINEERING_POWER
	modifier_title = "Crystal Harmonic Drift"
	dispatch_title = "Engine Instability Alert"
	dispatch_sound = 'sound/machines/engine_alert/engine_alert2.ogg'
	allow_in_extended = TRUE
	extended_weight = 1

/datum/storyteller/action/negative/timed_modifier/engineering_power_instability/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/obj/machinery/power/supermatter_crystal/supermatter = GLOB.main_supermatter_engine
	if(!istype(supermatter) || QDELETED(supermatter))
		return list("available" = FALSE, "reason" = "No supermatter engine is available for an instability event")
	return ..()

/datum/storyteller/action/negative/timed_modifier/engineering_power_instability/get_modifier_duration(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return rand(5 MINUTES, 8 MINUTES)

/datum/storyteller/action/negative/timed_modifier/engineering_power_instability/get_modifier_multiplier(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/crew_ratio = clamp((snapshot?.alive_crew || 0) / 60, 0, 1)
	return round(clamp(0.8 - (crew_ratio * 0.08), 0.62, 0.8), 0.01)

/datum/storyteller/action/negative/timed_modifier/engineering_power_instability/get_modifier_description(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	var/loss_percent = round((1 - modifier_multiplier) * 100)
	return "The crystal has drifted into an unstable harmonic band. Grid output is [loss_percent]% below baseline and internal wear is accumulating faster than normal."

/datum/storyteller/action/negative/timed_modifier/engineering_power_instability/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return "Engine telemetry has entered an unstable band. Supermatter efficiency is reduced to [round(modifier_multiplier, 0.01)]x and crystal wear is rising for [DisplayTimeText(duration, round_seconds_to = 1)]."

/datum/storyteller/action/negative/timed_modifier/engineering_power_instability/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/engineering_staff = owner?.current_snapshot ? (owner.current_snapshot.engineer_count + owner.current_snapshot.atmos_count) : 0
	return get_staff_scaled_weight(base_weight, engineering_staff, 0.25, 0.55, 0.85, 0.12, 1.4)

/datum/storyteller/action/negative/power_cable_fault
	id = "event_power_cable_fault"
	name = "Power Cable Fault"
	family = "event_engineering_grid"
	cost = 9
	weight = 5
	allow_in_extended = TRUE
	extended_weight = 1

/datum/storyteller/action/negative/power_cable_fault/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	for(var/obj/structure/cable/candidate as anything in GLOB.cable_list)
		if(is_station_level(candidate.z))
			return ..()
	return list("available" = FALSE, "reason" = "No station cables are available for a fault event")

/datum/storyteller/action/negative/power_cable_fault/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/engineering_staff = owner?.current_snapshot ? (owner.current_snapshot.engineer_count + owner.current_snapshot.atmos_count) : 0
	return get_staff_scaled_weight(base_weight, engineering_staff, 0.25, 0.55, 0.9, 0.12, 1.45)

/datum/storyteller/action/negative/power_cable_fault/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/list/candidates = list()
	for(var/obj/structure/cable/candidate as anything in GLOB.cable_list)
		if(!is_station_level(candidate.z) || QDELETED(candidate))
			continue
		candidates += candidate
	if(!length(candidates))
		return FALSE

	shuffle_inplace(candidates)
	var/crew_count = max(snapshot?.alive_crew || 0, snapshot?.active_population || 0)
	var/target_faults = clamp(round(crew_count / 12), 2, 6)
	var/fault_count = 0
	for(var/obj/structure/cable/failed_cable as anything in candidates)
		if(fault_count >= target_faults)
			break
		if(QDELETED(failed_cable))
			continue
		failed_cable.deconstruct()
		fault_count++

	if(!fault_count)
		return FALSE

	owner.announce_storyteller_alert(
		"Grid diagnostics report a localized cable fault cascade. Engineering response is advised.",
		"Power Cable Fault",
		'sound/machines/engine_alert/engine_alert2.ogg',
		"yellow",
	)
	owner.record_action_execution(src, "Severed [fault_count] station power cables")
	return TRUE

/datum/storyteller/action/negative/apc_reboot_wave
	id = "event_apc_reboot_wave"
	name = "APC Reboot Wave"
	family = "event_engineering_grid"
	cost = 10
	weight = 4
	allow_in_extended = TRUE
	extended_weight = 1

/datum/storyteller/action/negative/apc_reboot_wave/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	for(var/obj/machinery/power/apc/apc as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc))
		if(is_station_level(apc.z) && apc.area)
			return ..()
	return list("available" = FALSE, "reason" = "No station APCs are available for a reboot wave")

/datum/storyteller/action/negative/apc_reboot_wave/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	var/engineering_staff = owner?.current_snapshot ? (owner.current_snapshot.engineer_count + owner.current_snapshot.atmos_count) : 0
	return get_staff_scaled_weight(base_weight, engineering_staff, 0.25, 0.55, 0.9, 0.12, 1.45)

/datum/storyteller/action/negative/apc_reboot_wave/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/list/candidates = list()
	for(var/obj/machinery/power/apc/apc as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc))
		if(!is_station_level(apc.z) || !apc.area)
			continue
		candidates += apc
	if(!length(candidates))
		return FALSE

	shuffle_inplace(candidates)
	var/crew_count = max(snapshot?.alive_crew || 0, snapshot?.active_population || 0)
	var/target_count = clamp(round(crew_count / 15), 2, 5)
	var/list/affected_areas = list()
	var/affected = 0
	for(var/obj/machinery/power/apc/apc as anything in candidates)
		if(affected >= target_count)
			break
		if(QDELETED(apc) || !apc.is_operational)
			continue
		apc.energy_fail(rand(45 SECONDS, 90 SECONDS))
		affected++
		affected_areas["[apc.area]"] = TRUE

	if(!affected)
		return FALSE

	owner.announce_storyteller_alert(
		"Several APC control boards have entered a protective reboot cycle. Manual resets may be required.",
		"APC Reboot Wave",
		'sound/announcer/default/poweroff.ogg',
		"yellow",
	)
	owner.record_action_execution(src, "Forced [affected] APCs into reboot across [length(affected_areas)] areas")
	return TRUE

/datum/storyteller/action/positive/cargo_budget_grant
	id = "aid_cargo_budget_grant"
	name = "Cargo Budget Grant"
	family = "aid_budget"
	cost = 8
	weight = 10

/datum/storyteller/action/positive/cargo_budget_grant/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(snapshot.cargo_budget >= 18000)
		return list("available" = FALSE, "reason" = "Cargo budget already healthy")
	return ..()

/datum/storyteller/action/positive/cargo_budget_grant/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/amount = round(clamp((snapshot.danger_score - snapshot.control_score) * 75, 1500, 5000), 100)
	if(!owner.grant_department_budget(ACCOUNT_CAR, amount, "Storyteller relief grant"))
		return FALSE
	SSeconomy.record_grant("storyteller_cargo_budget_grant", amount, ACCOUNT_CAR)
	owner.announce_storyteller_notice(
		"Central Command has approved an emergency logistics subsidy for Cargo operations.",
		"Cargo Budget Grant",
		ANNOUNCER_DEPARTMENTAL,
		"green",
	)
	owner.record_action_execution(src, "Granted [amount] credits to cargo")
	return TRUE

/datum/storyteller/action/positive/adaptive_pod
	var/dispatch_title = "Relief Dispatch"
	var/dispatch_sound = 'sound/announcer/notice/notice2.ogg'
	var/dispatch_color = "green"

/datum/storyteller/action/positive/adaptive_pod/proc/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/need_report/report)
	if(!istype(report))
		return "A storyteller relief pod is inbound."
	return "A storyteller relief pod is inbound to [owner.get_department_label(report.department_id)]."

/datum/storyteller/action/positive/adaptive_pod/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/datum/storyteller/need_report/report = context_data["need_report"]
	if(!istype(report))
		return FALSE
	var/turf/target = owner.get_need_drop_target(report)
	if(!target)
		return FALSE
	var/list/contents = owner.create_need_relief_contents(report)
	if(!length(contents))
		return FALSE
	var/list/pod_delivery = owner.spawn_storyteller_pod(
		target,
		contents,
		report.department_id,
		"[name] ([report.title])",
		get_dispatch_message(owner, report),
	)
	if(!islist(pod_delivery))
		return FALSE
	owner.announce_storyteller_notice(get_dispatch_message(owner, report), dispatch_title, dispatch_sound, dispatch_color)
	owner.record_action_execution(src, "Scheduled adaptive relief pod for [report.title]")
	return TRUE

/datum/storyteller/action/positive/department_supply_pod
	parent_type = /datum/storyteller/action/positive/adaptive_pod
	id = "aid_department_supply_pod"
	name = "Adaptive Department Relief Pod"
	family = "aid_department"
	cost = 12
	weight = 9
	supported_need_ids = list(STORYTELLER_NEED_FOOD_SHORTAGE, STORYTELLER_NEED_ENGINEERING_REPAIRS)

/datum/storyteller/action/positive/department_supply_pod/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/need_report/report)
	if(!istype(report))
		return ..()
	switch(report.id)
		if(STORYTELLER_NEED_FOOD_SHORTAGE)
			return "Emergency ration reserves have been rerouted to the service wing."
		if(STORYTELLER_NEED_ENGINEERING_REPAIRS)
			return "A rapid-repair pod has been cleared for Engineering."
	return ..()

/datum/storyteller/action/positive/mining_relief_pod
	parent_type = /datum/storyteller/action/positive/adaptive_pod
	id = "aid_mining_relief_pod"
	name = "Adaptive Material Relief Pod"
	family = "aid_materials"
	cost = 15
	weight = 7
	supported_need_ids = list(STORYTELLER_NEED_MATERIAL_SHORTAGE)
	dispatch_title = "Cargo Relief Dispatch"
	dispatch_sound = 'sound/announcer/notice/notice3.ogg'

/datum/storyteller/action/positive/mining_relief_pod/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/need_report/report)
	return "Logistics reserve stock has been rerouted to Cargo to stabilize station materials."

/datum/storyteller/action/positive/medical_response_pod
	parent_type = /datum/storyteller/action/positive/adaptive_pod
	id = "aid_medical_response_pod"
	name = "Medical Response Pod"
	family = "aid_medical"
	cost = 13
	weight = 8
	supported_need_ids = list(STORYTELLER_NEED_MEDICAL_SURGE)
	dispatch_title = "Medical Relief Dispatch"
	dispatch_sound = 'sound/announcer/medbot/attention.ogg'

/datum/storyteller/action/positive/medical_response_pod/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/need_report/report)
	return "A triage reserve pod has been cleared for Medbay."

/datum/storyteller/action/positive/security_response_pod
	parent_type = /datum/storyteller/action/positive/adaptive_pod
	id = "aid_security_response_pod"
	name = "Security Response Pod"
	family = "aid_security"
	cost = 13
	weight = 7
	supported_need_ids = list(STORYTELLER_NEED_SECURITY_STRAIN)
	dispatch_title = "Security Relief Dispatch"
	dispatch_sound = 'sound/announcer/notice/notice1.ogg'

/datum/storyteller/action/positive/security_response_pod/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/need_report/report)
	return "A security response package has been approved for the brig wing."

/datum/storyteller/action/positive/science_supply_pod
	parent_type = /datum/storyteller/action/positive/adaptive_pod
	id = "aid_science_supply_pod"
	name = "Science Supply Pod"
	family = "aid_science"
	cost = 12
	weight = 6
	supported_need_ids = list(STORYTELLER_NEED_SCIENCE_SHORTAGE)
	dispatch_title = "Research Relief Dispatch"
	dispatch_sound = 'sound/announcer/notice/notice3.ogg'

/datum/storyteller/action/positive/science_supply_pod/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/need_report/report)
	return "Research surplus components have been rerouted to Science for scheduled use."

/datum/storyteller/action/positive/janitorial_cleanup_pod
	parent_type = /datum/storyteller/action/positive/adaptive_pod
	id = "aid_janitorial_cleanup_pod"
	name = "Janitorial Cleanup Pod"
	family = "aid_janitorial"
	cost = 11
	weight = 6
	supported_need_ids = list(STORYTELLER_NEED_JANITORIAL_OVERLOAD)
	dispatch_title = "Custodial Relief Dispatch"
	dispatch_sound = 'sound/announcer/notice/notice2.ogg'

/datum/storyteller/action/positive/janitorial_cleanup_pod/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/need_report/report)
	return "A custodial intervention pod has been cleared for delivery to the service wing."

/datum/storyteller/action/positive/morale_pod
	id = "aid_morale_pod"
	name = "Morale Pod"
	family = "aid_morale"
	cost = 10
	weight = 6

/datum/storyteller/action/positive/morale_pod/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/turf/target = owner.get_common_area_drop_target()
	if(!target)
		return FALSE
	var/obj/structure/closet/crate/freezer/food/crate = owner.create_storyteller_crate(
		/obj/structure/closet/crate/freezer/food,
		"morale support crate",
		"A small morale crate packed with comfort food and drinks for the common areas.",
	)
	var/obj/item/storage/box/snack_box = owner.create_storyteller_box(
		crate,
		"breakroom snack box",
		"A service box of ready meals and quick morale boosters.",
		"box",
		"writing",
		18,
		WEIGHT_CLASS_NORMAL,
	)
	owner.add_storyteller_items(snack_box, list(
		/obj/item/pizzabox/margherita = 2,
		/obj/item/storage/box/donkpockets = 1,
		/obj/item/food/ready_donk = 4,
		/obj/item/food/cake/plain = 1,
	))
	owner.add_storyteller_items(crate, list(
		/obj/item/reagent_containers/cup/glass/bottle/beer = 4,
		/obj/item/reagent_containers/cup/glass/bottle/beer/light = 2,
	))
	var/list/contents = list(crate)
	var/list/pod_delivery = owner.spawn_storyteller_pod(
		target,
		contents,
		null,
		name,
		"Common-area morale support package",
	)
	if(!islist(pod_delivery))
		return FALSE
	owner.announce_storyteller_notice(
		"A morale package has been cleared for common-area delivery. Productivity enhancement is encouraged.",
		"Morale Dispatch",
		'sound/announcer/notice/notice2.ogg',
		"green",
	)
	owner.record_action_execution(src, "Scheduled morale pod for a common area")
	return TRUE
