ADMIN_VERB(open_storyteller_panel, R_ADMIN, "Storyteller Panel", "Open the storyteller panel.", ADMIN_CATEGORY_GAME)
	storyteller_panel(user.mob)

/proc/storyteller_panel(mob/user)
	if(!check_rights(R_ADMIN))
		return
	SSstoryteller.ui_interact(user)
	log_admin("[key_name(user)] opened the Storyteller Panel.")
	if(!isobserver(user))
		message_admins("[key_name_admin(user)] opened the Storyteller Panel.")
	BLACKBOX_LOG_ADMIN_VERB("Storyteller Panel")

SUBSYSTEM_DEF(storyteller)
	name = "Storyteller"
	wait = 1 MINUTES
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME
	ss_flags = SS_KEEP_TIMING
	dependencies = list(
		/datum/controller/subsystem/economy,
		/datum/controller/subsystem/events,
		/datum/controller/subsystem/vote,
	)

	var/datum/storyteller/profile/profile
	var/profile_type = /datum/storyteller/profile
	var/datum/storyteller/action_catalog/catalog
	var/datum/storyteller/state_snapshot/current_snapshot
	var/list/datum/storyteller/need_analyzer/need_analyzers = list()
	var/list/datum/storyteller/need_report/current_need_reports = list()
	var/list/storyteller_config = list()
	var/list/recent_death_times = list()
	var/list/recent_explosion_times = list()
	var/list/family_cooldowns = list()
	var/list/action_admin_cooldowns = list()
	var/list/admin_discarded_actions = list()
	var/list/reserved_action_budgets = list()
	var/list/queued_antag_metadata = list()
	var/list/scheduled_action_queue = list()
	var/list/decision_history = list()
	var/list/prepared_roundstart_entries = list()
	var/list/frozen_roster_data
	var/last_snapshot_refresh = 0
	var/last_heavy_scan = 0
	var/positive_fatigue_locked_until = 0
	var/negative_fatigue_locked_until = 0
	var/last_latejoin_hostile_at = 0
	var/last_material_total = 0
	var/baseline_structure_captured = FALSE
	var/baseline_station_breach_tiles = 0
	var/baseline_broken_floor_count = 0
	var/baseline_damaged_window_count = 0
	var/baseline_damaged_grille_count = 0
	var/prep_phase_active = FALSE
	var/prep_phase_started_at = 0
	var/prep_phase_ends_at = 0
	var/threat_budget = 0
	var/aid_budget = 0
	var/current_phase_max = 1
	var/phase_cap = 1
	var/automatic_phase_floor = 1
	var/manual_phase_override = FALSE
	var/manual_profile_override = FALSE
	var/paused = FALSE
	var/skip_next_pulse = FALSE
	var/snapshot_dirty = TRUE
	var/round_mode = STORYTELLER_ROUND_MODE_DYNAMIC
	var/mode_vote_started = FALSE
	var/mode_vote_finalized = FALSE
	var/manual_round_mode_override = FALSE
	var/round_mode_history_recorded = FALSE
	var/list/round_mode_history = list()
	var/round_cadence_initialized = FALSE
	var/profile_selected = FALSE
	var/round_started_at = 0
	var/positive_channel_ready_at = 0
	var/negative_channel_ready_at = 0
	var/latejoin_roundstart_locked_until = 0
	var/last_positive_action_at = 0
	var/last_negative_action_at = 0
	var/last_positive_action_cost = 0
	var/last_negative_action_cost = 0
	var/last_positive_action_impact = 0
	var/last_negative_action_impact = 0
	var/queued_positive_action_id
	var/queued_negative_action_id
	var/next_scheduled_action_queue_id = 1
	var/list/active_modifiers = list()
	var/list/pending_pod_deliveries = list()

/datum/controller/subsystem/storyteller/Initialize()
	load_config()
	load_round_mode_history()
	reset_profile_selection()
	catalog = new(storyteller_config)
	initialize_need_analyzers()
	current_snapshot = new
	phase_cap = max(1, CONFIG_GET(number/storyteller_phase_max))
	current_phase_max = 1
	round_mode = STORYTELLER_ROUND_MODE_DYNAMIC
	mode_vote_started = FALSE
	mode_vote_finalized = FALSE

	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, PROC_REF(on_mob_death))
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, PROC_REF(on_explosion))
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(on_crewmember_joined))
	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, PROC_REF(on_enter_pregame))
	for(var/datum/round_event_control/event_control as anything in SSevents.control)
		RegisterSignal(event_control, COMSIG_CREATED_ROUND_EVENT, PROC_REF(on_round_event_created))

	return SS_INIT_SUCCESS

/datum/controller/subsystem/storyteller/proc/initialize_need_analyzers()
	need_analyzers = list()
	for(var/datum/storyteller/need_analyzer/analyzer_type as anything in subtypesof(/datum/storyteller/need_analyzer))
		if(analyzer_type == /datum/storyteller/need_analyzer)
			continue
		var/datum/storyteller/need_analyzer/analyzer = new analyzer_type
		analyzer.apply_tuning(storyteller_config)
		need_analyzers += analyzer

/datum/controller/subsystem/storyteller/fire(resumed)
	if(!catalog || !profile)
		load_config()
		reset_profile_selection()
		catalog = new(storyteller_config)
		initialize_need_analyzers()

	phase_cap = max(1, CONFIG_GET(number/storyteller_phase_max))
	current_phase_max = clamp(current_phase_max, 1, phase_cap)

	if(!is_enabled())
		return

	if(SSticker.current_state == GAME_STATE_PREGAME)
		process_pregame_mode_vote()

	prune_expired_modifiers()
	prune_pending_pod_deliveries()
	prune_admin_action_cooldowns()
	prune_queued_antag_metadata()
	refresh_snapshot()
	update_scores()
	evaluate_needs()
	update_budgets()
	var/processed_scheduled_actions = process_scheduled_action_queue()
	if(processed_scheduled_actions && SSticker.IsRoundInProgress())
		refresh_snapshot(TRUE)
		update_scores()
		evaluate_needs()
		update_budgets()

	if(!SSticker.IsRoundInProgress())
		return

	ensure_round_cadence()
	update_content_stage()

	if(skip_next_pulse)
		skip_next_pulse = FALSE
		record_decision("Skipped one storyteller pulse.")
		return

	if(paused)
		return

	try_run_positive_action()
	try_run_negative_action()

/datum/controller/subsystem/storyteller/proc/is_enabled()
	return CONFIG_GET(flag/storyteller_enabled)

/datum/controller/subsystem/storyteller/proc/owns_pacing()
	return is_enabled() && CONFIG_GET(flag/storyteller_full_owner)

/datum/controller/subsystem/storyteller/proc/process_pregame_mode_vote()
	if(mode_vote_finalized || mode_vote_started)
		return
	if(SSticker.current_state != GAME_STATE_PREGAME)
		return
	if(!SSvote || SSvote.current_vote)
		return
	mode_vote_started = SSvote.initiate_vote(/datum/vote/storyteller_mode, "the storyteller", null, forced = TRUE)
	if(mode_vote_started)
		record_decision("Started storyteller mode vote for the upcoming round.")

/datum/controller/subsystem/storyteller/proc/set_round_mode(new_mode, announce = TRUE)
	if(!(new_mode in list(STORYTELLER_ROUND_MODE_DYNAMIC, STORYTELLER_ROUND_MODE_EXTENDED)))
		new_mode = STORYTELLER_ROUND_MODE_DYNAMIC
	round_mode = new_mode
	mode_vote_finalized = TRUE
	if(!round_mode_history_recorded)
		record_round_mode_history(round_mode)
		round_mode_history_recorded = TRUE
	if(announce)
		record_decision("Selected storyteller round mode: [capitalize(round_mode)].")

/datum/controller/subsystem/storyteller/proc/get_round_mode_options_ui_data()
	RETURN_TYPE(/list)
	return list(
		list(
			"id" = STORYTELLER_ROUND_MODE_DYNAMIC,
			"name" = "Dynamic",
		),
		list(
			"id" = STORYTELLER_ROUND_MODE_EXTENDED,
			"name" = "Extended",
		),
	)

/datum/controller/subsystem/storyteller/proc/cancel_active_mode_vote()
	if(!SSvote?.current_vote || !istype(SSvote.current_vote, /datum/vote/storyteller_mode))
		return FALSE
	SSvote.reset()
	mode_vote_started = FALSE
	return TRUE

/datum/controller/subsystem/storyteller/proc/clear_extended_incompatible_queues(mob/user)
	var/cleared_anything = FALSE
	if(queued_negative_action_id)
		var/datum/storyteller/action/queued_action = catalog.get_action(queued_negative_action_id)
		if(istype(queued_action) && queued_action.is_antag_action())
			cleared_anything = cancel_queued_antag(queued_negative_action_id, user) || cleared_anything

	for(var/queue_id in queued_antag_metadata.Copy())
		cleared_anything = cancel_queued_antag(queue_id, user) || cleared_anything

	for(var/list/entry as anything in scheduled_action_queue.Copy())
		if(!islist(entry))
			continue
		var/datum/storyteller/action/scheduled_action = catalog.get_action(entry["actionId"])
		if(!istype(scheduled_action) || !scheduled_action.is_antag_action())
			continue
		cleared_anything = cancel_queued_antag(entry["queueId"], user) || cleared_anything

	return cleared_anything

/datum/controller/subsystem/storyteller/proc/set_manual_round_mode(new_mode, mob/user)
	if(!(new_mode in list(STORYTELLER_ROUND_MODE_DYNAMIC, STORYTELLER_ROUND_MODE_EXTENDED)))
		return FALSE

	manual_round_mode_override = TRUE
	if(cancel_active_mode_vote())
		record_decision("[key_name(user)] canceled the active storyteller mode vote.")

	set_round_mode(new_mode, FALSE)
	if(round_mode == STORYTELLER_ROUND_MODE_EXTENDED)
		clear_extended_incompatible_queues(user)
	record_decision("[key_name(user)] set storyteller round mode to [capitalize(round_mode)].")
	return TRUE

/datum/controller/subsystem/storyteller/proc/apply_profile_type(new_profile_type)
	if(!ispath(new_profile_type, /datum/storyteller/profile))
		new_profile_type = /datum/storyteller/profile
	profile_type = new_profile_type
	profile = new profile_type
	profile.apply_tuning(storyteller_config)
	profile.apply_profile_bias()

/datum/controller/subsystem/storyteller/proc/reset_profile_selection()
	profile_selected = FALSE
	apply_profile_type(/datum/storyteller/profile)

/datum/controller/subsystem/storyteller/proc/get_profile_type_by_id(profile_id)
	if(!profile_id)
		return /datum/storyteller/profile
	var/normalized_profile_id = lowertext("[profile_id]")
	switch(normalized_profile_id)
		if("passive")
			return /datum/storyteller/profile/passive
		if("aggressive")
			return /datum/storyteller/profile/aggressive
		if("balanced")
			return /datum/storyteller/profile
		if("patient custodian", "терпеливый куратор")
			return /datum/storyteller/profile/passive
		if("aggressive escalation", "агрессивная эскалация")
			return /datum/storyteller/profile/aggressive
		if("balanced drama", "сбалансированная драма")
			return /datum/storyteller/profile
	return /datum/storyteller/profile

/datum/controller/subsystem/storyteller/proc/get_profile_options_ui_data()
	RETURN_TYPE(/list)
	return list(
		list(
			"id" = "balanced",
			"name" = "Balanced Drama",
		),
		list(
			"id" = "passive",
			"name" = "Patient Custodian",
		),
		list(
			"id" = "aggressive",
			"name" = "Aggressive Escalation",
		),
	)

/datum/controller/subsystem/storyteller/proc/set_manual_profile(profile_id, mob/user)
	var/profile_subtype = get_profile_type_by_id(profile_id)
	manual_profile_override = TRUE
	profile_selected = TRUE
	apply_profile_type(profile_subtype)
	record_decision("[key_name(user)] set storyteller profile to [profile.name].")
	return TRUE

/datum/controller/subsystem/storyteller/proc/clear_manual_profile(mob/user)
	manual_profile_override = FALSE
	if(is_roundstart_prep_active())
		profile_selected = FALSE
		select_profile_for_roster(build_pregame_roster_data())
		record_decision("[key_name(user)] returned storyteller profile selection to automatic frozen-roster picks.")
		return TRUE
	if(SSticker.IsRoundInProgress())
		profile_selected = FALSE
		select_profile_for_population(max(current_snapshot?.alive_crew || 0, current_snapshot?.active_population || 0))
		record_decision("[key_name(user)] returned storyteller profile selection to automatic population-based picks.")
		return TRUE
	reset_profile_selection()
	record_decision("[key_name(user)] cleared the storyteller profile override.")
	return TRUE

/datum/controller/subsystem/storyteller/proc/get_profile_weights_for_population(player_count)
	RETURN_TYPE(/list)
	return list(
		/datum/storyteller/profile/passive = max(10, 60 - max(player_count, 0)),
		/datum/storyteller/profile = 45,
		/datum/storyteller/profile/aggressive = max(5, min(90, 5 + max(player_count - 10, 0) * 2)),
	)

/datum/controller/subsystem/storyteller/proc/pick_profile_type(player_count)
	return pick_weight(get_profile_weights_for_population(player_count))

/datum/controller/subsystem/storyteller/proc/select_profile_for_population(player_count)
	if(profile_selected)
		return
	var/list/profile_weights = get_profile_weights_for_population(player_count)
	var/chosen_profile_type = pick_weight(profile_weights)
	apply_profile_type(chosen_profile_type)
	profile_selected = TRUE
	record_decision("Selected storyteller profile [profile.name] for population [player_count].", build_storyteller_trace_data(list(
		"population" = player_count,
		"profileWeights" = profile_weights.Copy(),
	)))

/datum/controller/subsystem/storyteller/proc/should_run_roundstart_prep_phase()
	return is_enabled() && round_mode == STORYTELLER_ROUND_MODE_DYNAMIC && SSticker.current_state == GAME_STATE_SETTING_UP && !SSticker.HasRoundStarted()

/datum/controller/subsystem/storyteller/proc/is_roundstart_prep_active()
	return prep_phase_active && should_run_roundstart_prep_phase()

/datum/controller/subsystem/storyteller/proc/get_roundstart_prep_remaining()
	if(!is_roundstart_prep_active())
		return 0
	return max(prep_phase_ends_at - world.time, 0)

/datum/controller/subsystem/storyteller/proc/build_pregame_roster_data()
	RETURN_TYPE(/list)
	var/list/department_intents = list()
	var/list/job_intents = list()
	var/list/key_job_intents = list()
	var/ready_count = 0
	var/list/relevant_departments = list(
		ACCOUNT_CMD,
		ACCOUNT_SEC,
		ACCOUNT_ENG,
		ACCOUNT_MED,
		ACCOUNT_SCI,
		ACCOUNT_CAR,
		ACCOUNT_SRV,
	)

	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(QDELETED(player) || player.ready != PLAYER_READY_TO_PLAY || !player.client?.prefs)
			continue

		ready_count++
		var/datum/job/intended_job = player.client.prefs.get_highest_priority_job()
		if(!intended_job)
			continue

		job_intents[intended_job.title] = (job_intents[intended_job.title] || 0) + 1
		if(intended_job.title in profile.key_jobs)
			key_job_intents[intended_job.title] = TRUE

		var/department_id = intended_job.paycheck_department
		if(!department_id)
			continue
		department_intents[department_id] = (department_intents[department_id] || 0) + 1

	var/department_coverage = 0
	for(var/department_id in relevant_departments)
		if((department_intents[department_id] || 0) > 0)
			department_coverage++

	return list(
		"readyCount" = ready_count,
		"departmentIntents" = department_intents,
		"jobIntents" = job_intents,
		"keyJobIntentCount" = length(key_job_intents),
		"departmentCoverage" = department_coverage,
	)

/datum/controller/subsystem/storyteller/proc/get_profile_weights_for_roster(list/roster_data)
	RETURN_TYPE(/list)
	if(!islist(roster_data))
		return get_profile_weights_for_population(0)

	var/ready_count = roster_data["readyCount"] || 0
	var/key_job_intents = roster_data["keyJobIntentCount"] || 0
	var/department_coverage = roster_data["departmentCoverage"] || 0
	var/list/department_intents = roster_data["departmentIntents"] || list()
	var/command_intents = department_intents[ACCOUNT_CMD] || 0
	var/anchor_support = 0

	for(var/department_id in list(ACCOUNT_ENG, ACCOUNT_MED, ACCOUNT_SEC, ACCOUNT_SCI, ACCOUNT_CAR))
		if((department_intents[department_id] || 0) > 0)
			anchor_support++

	return list(
		/datum/storyteller/profile/passive = max(15, 70 - (ready_count * 2)) + max(0, 5 - key_job_intents) * 12 + max(0, 4 - department_coverage) * 10,
		/datum/storyteller/profile = 45 + ready_count + (department_coverage * 5),
		/datum/storyteller/profile/aggressive = max(5, (ready_count * 2) - 10) + (key_job_intents * 9) + (department_coverage * 6) + (anchor_support * 4) + (command_intents > 0 ? 6 : 0),
	)

/datum/controller/subsystem/storyteller/proc/pick_profile_type_for_roster(list/roster_data)
	return pick_weight(get_profile_weights_for_roster(roster_data))

/datum/controller/subsystem/storyteller/proc/select_profile_for_roster(list/roster_data)
	if(profile_selected)
		return
	var/ready_count = islist(roster_data) ? (roster_data["readyCount"] || 0) : 0
	var/list/profile_weights = get_profile_weights_for_roster(roster_data)
	var/chosen_profile_type = pick_weight(profile_weights)
	apply_profile_type(chosen_profile_type)
	profile_selected = TRUE
	record_decision("Selected storyteller profile [profile.name] from a frozen lobby roster of [ready_count] ready players.", build_storyteller_trace_data(list(
		"roster" = get_storyteller_roster_trace_data(roster_data),
		"profileWeights" = profile_weights.Copy(),
	)))

/datum/controller/subsystem/storyteller/proc/calculate_initial_content_stage_for_roster(list/roster_data)
	var/stage = 1
	if(phase_cap <= 1 || !islist(roster_data))
		return stage

	var/ready_count = roster_data["readyCount"] || 0
	var/key_job_intents = roster_data["keyJobIntentCount"] || 0
	var/department_coverage = roster_data["departmentCoverage"] || 0
	var/list/department_intents = roster_data["departmentIntents"] || list()
	var/engineering_intents = department_intents[ACCOUNT_ENG] || 0
	var/medical_intents = department_intents[ACCOUNT_MED] || 0
	var/security_intents = department_intents[ACCOUNT_SEC] || 0
	var/profile_scale = 1 + (((profile?.escalation_rise_multiplier || 1) - 1) * 0.6)
	var/effective_ready_count = round(ready_count * profile_scale)
	var/effective_key_job_intents = round(key_job_intents * profile_scale)
	var/effective_department_coverage = round(department_coverage * profile_scale)

	if(phase_cap >= 2 && (effective_ready_count >= 22 || (effective_ready_count >= 16 && effective_key_job_intents >= 5 && effective_department_coverage >= 5 && engineering_intents > 0 && medical_intents > 0)))
		stage = 2
	if(phase_cap >= 3 && (effective_ready_count >= 38 || (effective_ready_count >= 30 && effective_key_job_intents >= 6 && effective_department_coverage >= 6 && engineering_intents > 0 && medical_intents > 0 && security_intents > 0)))
		stage = 3
	if(phase_cap >= 4 && (effective_ready_count >= 52 || (effective_ready_count >= 42 && effective_key_job_intents >= 7 && effective_department_coverage >= 7 && engineering_intents >= 2 && medical_intents >= 2 && security_intents > 0)))
		stage = 4

	return clamp(stage, 1, phase_cap)

/datum/controller/subsystem/storyteller/proc/select_initial_content_stage_for_roster(list/roster_data)
	if(manual_phase_override)
		return
	var/ready_count = islist(roster_data) ? (roster_data["readyCount"] || 0) : 0
	var/initial_phase = calculate_initial_content_stage_for_roster(roster_data)
	current_phase_max = initial_phase
	automatic_phase_floor = initial_phase
	record_decision("Locked storyteller starting content stage to [current_phase_max] from a frozen lobby roster of [ready_count] ready players.", build_storyteller_trace_data(list(
		"roster" = get_storyteller_roster_trace_data(roster_data),
		"initialPhase" = initial_phase,
		"profileRiseMultiplier" = profile?.escalation_rise_multiplier || 1,
	)))

/datum/controller/subsystem/storyteller/proc/get_profile_name_for_type(profile_path)
	switch(profile_path)
		if(/datum/storyteller/profile/passive)
			return "Patient Custodian"
		if(/datum/storyteller/profile/aggressive)
			return "Aggressive Escalation"
	return "Balanced Drama"

/datum/controller/subsystem/storyteller/proc/get_profile_chance_ui_data(list/roster_data)
	RETURN_TYPE(/list)
	var/list/weights = get_profile_weights_for_roster(roster_data)
	var/total_weight = 0
	for(var/profile_path in weights)
		total_weight += max(0, weights[profile_path])

	var/list/entries = list()
	for(var/profile_path in weights)
		var/weight = max(0, weights[profile_path])
		entries += list(list(
			"id" = "[profile_path]",
			"name" = get_profile_name_for_type(profile_path),
			"weight" = weight,
			"chancePercent" = total_weight > 0 ? round((weight / total_weight) * 100, 0.1) : 0,
		))
	return entries

/datum/controller/subsystem/storyteller/proc/get_stage_chance_ui_data(list/roster_data)
	RETURN_TYPE(/list)
	var/predicted_stage = calculate_initial_content_stage_for_roster(roster_data)
	var/list/entries = list()
	for(var/stage in 1 to max(1, phase_cap))
		entries += list(list(
			"id" = stage,
			"name" = "Stage [stage]",
			"chancePercent" = stage == predicted_stage ? 100 : 0,
			"predicted" = stage == predicted_stage,
		))
	return entries

/datum/controller/subsystem/storyteller/proc/get_ready_player_mode_vote_ui_data()
	RETURN_TYPE(/list)
	var/list/entries = list()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(QDELETED(player) || player.ready != PLAYER_READY_TO_PLAY || !player.client?.prefs)
			continue

		var/datum/job/intended_job = player.client.prefs.get_highest_priority_job()
		entries += list(list(
			"ckey" = player.ckey || player.client.ckey,
			"name" = player.client.prefs.read_preference(/datum/preference/name/real_name),
			"job" = intended_job?.title || "No preferred job",
		))
	return entries

/datum/controller/subsystem/storyteller/proc/get_mode_vote_ui_data(mob/user)
	RETURN_TYPE(/list)
	var/list/roster_data = build_pregame_roster_data()
	var/list/alternation_data = get_mode_alternation_ui_data()
	var/list/data = list(
		"enabled" = is_enabled(),
		"roundMode" = round_mode,
		"modeFinalized" = mode_vote_finalized,
		"selectedMode" = mode_vote_finalized ? round_mode : null,
		"interfaceLanguage" = get_panel_language_value(user, "storyteller"),
		"menuChapter" = user?.client?.prefs?.read_preference(/datum/preference/choiced/menu_chapter),
		"alternation" = alternation_data,
		"modes" = list(
			list(
				"id" = STORYTELLER_ROUND_MODE_DYNAMIC,
				"name" = "Dynamic",
				"summary" = "The storyteller actively paces roundstart, midround, and latejoin pressure with a short setup preparation phase.",
			),
			list(
				"id" = STORYTELLER_ROUND_MODE_EXTENDED,
				"name" = "Extended",
				"summary" = "A calmer station round. Storyteller aid and background pacing remain available, but natural hostile pressure is suppressed.",
			),
		),
		"storytellerSummary" = "The storyteller reads crew readiness, department coverage, station danger, and resource pressure to pick a profile, starting stage, and later round events.",
	)

	if(user?.client?.holder)
		data["profileName"] = profile?.name || "Unknown"
		data["phase"] = current_phase_max
		data["phaseCap"] = phase_cap
		data["admin"] = list(
			"playerCount" = alternation_data["playerCount"],
			"readyCount" = roster_data["readyCount"] || 0,
			"readyPlayers" = get_ready_player_mode_vote_ui_data(),
			"profileChances" = get_profile_chance_ui_data(roster_data),
			"stageChances" = get_stage_chance_ui_data(roster_data),
		)
	return data

/datum/controller/subsystem/storyteller/proc/begin_roundstart_prep_phase()
	if(prep_phase_active)
		return
	if(!mode_vote_finalized)
		record_decision("Storyteller mode vote did not finalize before preparation; using [capitalize(round_mode)] mode.")
		mode_vote_finalized = TRUE
		if(!round_mode_history_recorded)
			record_round_mode_history(round_mode)
			round_mode_history_recorded = TRUE

	prep_phase_active = TRUE
	prep_phase_started_at = world.time
	prep_phase_ends_at = world.time + STORYTELLER_DEFAULT_SETUP_PREP_DURATION

	var/list/roster_data = build_pregame_roster_data()
	frozen_roster_data = roster_data
	if(!manual_profile_override)
		select_profile_for_roster(roster_data)
	if(!manual_phase_override)
		select_initial_content_stage_for_roster(roster_data)

	record_decision("Started storyteller setup preparation for [DisplayTimeText(STORYTELLER_DEFAULT_SETUP_PREP_DURATION, round_seconds_to = 1)].", build_storyteller_trace_data(list(
		"roster" = get_storyteller_roster_trace_data(roster_data),
		"prepDurationDs" = STORYTELLER_DEFAULT_SETUP_PREP_DURATION,
	)))
	to_chat(world, span_notice("The storyteller is finalizing the dynamic round setup. Character editing, observation, and round-entry changes are locked for [DisplayTimeText(STORYTELLER_DEFAULT_SETUP_PREP_DURATION, round_seconds_to = 1)]."))

/datum/controller/subsystem/storyteller/proc/finish_roundstart_prep_phase()
	if(!prep_phase_active)
		return
	prep_phase_active = FALSE
	prep_phase_started_at = 0
	prep_phase_ends_at = 0
	record_decision("Storyteller setup preparation completed. Proceeding with dynamic round setup.")

/datum/controller/subsystem/storyteller/proc/hold_round_setup_for_prep_phase()
	if(!prep_phase_active && !should_run_roundstart_prep_phase())
		return FALSE

	if(prep_phase_active && !should_run_roundstart_prep_phase())
		finish_roundstart_prep_phase()
		return FALSE

	if(!prep_phase_active)
		begin_roundstart_prep_phase()
		return TRUE

	if(world.time < prep_phase_ends_at)
		return TRUE

	finish_roundstart_prep_phase()
	return FALSE

/datum/controller/subsystem/storyteller/proc/allow_roundstart_hostiles()
	return round_mode == STORYTELLER_ROUND_MODE_DYNAMIC

/datum/controller/subsystem/storyteller/proc/allow_negative_midround()
	return TRUE

/datum/controller/subsystem/storyteller/proc/load_config()
	storyteller_config = list()
	var/config_file = "[global.config.directory]/storyteller.toml"
	if(!fexists(config_file))
		return

	var/list/result = rustg_raw_read_toml_file(config_file)
	if(!result["success"])
		log_game("Storyteller: Failed to load [config_file] ([result["content"]])")
		return

	storyteller_config = json_decode(result["content"]) || list()

/datum/controller/subsystem/storyteller/proc/load_round_mode_history()
	round_mode_history = list()
	if(!fexists(STORYTELLER_MODE_HISTORY_FILE))
		return

	var/list/raw_history = json_decode(file2text(STORYTELLER_MODE_HISTORY_FILE))
	if(!islist(raw_history))
		return

	for(var/history_entry in raw_history)
		if(history_entry in list(STORYTELLER_ROUND_MODE_DYNAMIC, STORYTELLER_ROUND_MODE_EXTENDED))
			round_mode_history += history_entry

	while(length(round_mode_history) > 2)
		round_mode_history.Cut(1, 2)

/datum/controller/subsystem/storyteller/proc/save_round_mode_history()
	var/json_file = file(STORYTELLER_MODE_HISTORY_FILE)
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(round_mode_history))

/datum/controller/subsystem/storyteller/proc/record_round_mode_history(selected_mode)
	if(!(selected_mode in list(STORYTELLER_ROUND_MODE_DYNAMIC, STORYTELLER_ROUND_MODE_EXTENDED)))
		return

	round_mode_history += selected_mode
	while(length(round_mode_history) > 2)
		round_mode_history.Cut(1, 2)

	save_round_mode_history()

/datum/controller/subsystem/storyteller/proc/get_pregame_player_count()
	var/player_count = 0
	for(var/client/player_client as anything in GLOB.clients)
		if(!player_client?.mob || is_guest_key(player_client.key))
			continue
		player_count++
	return player_count

/datum/controller/subsystem/storyteller/proc/get_alternating_round_mode(voted_mode)
	if(!(voted_mode in list(STORYTELLER_ROUND_MODE_DYNAMIC, STORYTELLER_ROUND_MODE_EXTENDED)))
		return STORYTELLER_ROUND_MODE_DYNAMIC

	if(length(round_mode_history) < 2)
		return voted_mode

	var/previous_mode = round_mode_history[length(round_mode_history)]
	var/before_previous_mode = round_mode_history[length(round_mode_history) - 1]
	if(previous_mode != before_previous_mode)
		return voted_mode

	var/player_count = get_pregame_player_count()
	if(previous_mode == STORYTELLER_ROUND_MODE_EXTENDED && player_count >= STORYTELLER_MODE_ALTERNATION_LOW_POP_THRESHOLD)
		record_decision("Forced Dynamic storyteller mode because the previous two rounds were Extended.")
		return STORYTELLER_ROUND_MODE_DYNAMIC

	if(previous_mode == STORYTELLER_ROUND_MODE_DYNAMIC && player_count <= STORYTELLER_MODE_ALTERNATION_HIGH_POP_THRESHOLD)
		record_decision("Forced Extended storyteller mode because the previous two rounds were Dynamic.")
		return STORYTELLER_ROUND_MODE_EXTENDED

	return voted_mode

/datum/controller/subsystem/storyteller/proc/get_mode_alternation_ui_data()
	var/player_count = get_pregame_player_count()
	var/forced_mode
	var/reason

	if(length(round_mode_history) >= 2)
		var/previous_mode = round_mode_history[length(round_mode_history)]
		var/before_previous_mode = round_mode_history[length(round_mode_history) - 1]
		if(previous_mode == before_previous_mode)
			if(previous_mode == STORYTELLER_ROUND_MODE_EXTENDED && player_count >= STORYTELLER_MODE_ALTERNATION_LOW_POP_THRESHOLD)
				forced_mode = STORYTELLER_ROUND_MODE_DYNAMIC
				reason = "The previous two rounds were Extended."
			else if(previous_mode == STORYTELLER_ROUND_MODE_DYNAMIC && player_count <= STORYTELLER_MODE_ALTERNATION_HIGH_POP_THRESHOLD)
				forced_mode = STORYTELLER_ROUND_MODE_EXTENDED
				reason = "The previous two rounds were Dynamic."

	return list(
		"playerCount" = player_count,
		"history" = round_mode_history.Copy(),
		"forcedMode" = forced_mode,
		"reason" = reason,
		"lowPopThreshold" = STORYTELLER_MODE_ALTERNATION_LOW_POP_THRESHOLD,
		"highPopThreshold" = STORYTELLER_MODE_ALTERNATION_HIGH_POP_THRESHOLD,
	)

/datum/controller/subsystem/storyteller/proc/on_mob_death(datum/source, mob/living/dead_mob, gibbed)
	SIGNAL_HANDLER
	if(!istype(dead_mob) || !dead_mob.mind?.assigned_role || isobserver(dead_mob) || isnewplayer(dead_mob))
		return
	recent_death_times += world.time
	snapshot_dirty = TRUE

/datum/controller/subsystem/storyteller/proc/on_explosion(datum/source, turf/epicenter)
	SIGNAL_HANDLER
	if(!isturf(epicenter) || !is_station_level(epicenter.z))
		return
	recent_explosion_times += world.time
	snapshot_dirty = TRUE

/datum/controller/subsystem/storyteller/proc/on_crewmember_joined(datum/source, mob/living/new_character, assigned_job)
	SIGNAL_HANDLER
	snapshot_dirty = TRUE

/datum/controller/subsystem/storyteller/proc/on_round_event_created(datum/source, datum/round_event/round_event)
	SIGNAL_HANDLER
	snapshot_dirty = TRUE

/datum/controller/subsystem/storyteller/proc/on_enter_pregame(datum/source)
	SIGNAL_HANDLER
	round_mode = STORYTELLER_ROUND_MODE_DYNAMIC
	mode_vote_started = FALSE
	mode_vote_finalized = FALSE
	manual_round_mode_override = FALSE
	round_mode_history_recorded = FALSE
	reset_round_state_tracking()
	reset_profile_selection()
	process_pregame_mode_vote()

/datum/controller/subsystem/storyteller/proc/reset_round_state_tracking()
	round_cadence_initialized = FALSE
	profile_selected = FALSE
	round_started_at = 0
	positive_channel_ready_at = 0
	negative_channel_ready_at = 0
	latejoin_roundstart_locked_until = 0
	last_latejoin_hostile_at = 0
	last_positive_action_at = 0
	last_negative_action_at = 0
	last_positive_action_cost = 0
	last_negative_action_cost = 0
	last_positive_action_impact = 0
	last_negative_action_impact = 0
	prep_phase_active = FALSE
	prep_phase_started_at = 0
	prep_phase_ends_at = 0
	positive_fatigue_locked_until = 0
	negative_fatigue_locked_until = 0
	family_cooldowns.Cut()
	action_admin_cooldowns.Cut()
	admin_discarded_actions.Cut()
	reserved_action_budgets.Cut()
	queued_antag_metadata.Cut()
	scheduled_action_queue.Cut()
	active_modifiers.Cut()
	pending_pod_deliveries.Cut()
	queued_positive_action_id = null
	queued_negative_action_id = null
	next_scheduled_action_queue_id = 1
	manual_phase_override = FALSE
	manual_profile_override = FALSE
	current_phase_max = 1
	automatic_phase_floor = 1
	frozen_roster_data = null
	baseline_structure_captured = FALSE
	baseline_station_breach_tiles = 0
	baseline_broken_floor_count = 0
	baseline_damaged_window_count = 0
	baseline_damaged_grille_count = 0
	reset_profile_selection()

/datum/controller/subsystem/storyteller/proc/ensure_round_cadence()
	if(!SSticker.IsRoundInProgress())
		return
	if(round_cadence_initialized && round_started_at == SSticker.round_start_time)
		return

	if(!profile_selected)
		select_profile_for_population(max(current_snapshot?.alive_crew || 0, current_snapshot?.active_population || 0))

	round_cadence_initialized = TRUE
	round_started_at = SSticker.round_start_time
	negative_channel_ready_at = round_started_at + rand(profile.negative_roundstart_delay_min, profile.negative_roundstart_delay_max)
	positive_channel_ready_at = round_started_at + rand(profile.positive_roundstart_delay_min, profile.positive_roundstart_delay_max)
	latejoin_roundstart_locked_until = round_started_at + rand(profile.latejoin_roundstart_lock_min, profile.latejoin_roundstart_lock_max)
	record_decision("Initialized storyteller cadence. Negative pressure unlocks in [DisplayTimeText(max(negative_channel_ready_at - world.time, 0), round_seconds_to = 1)], positive relief unlocks in [DisplayTimeText(max(positive_channel_ready_at - world.time, 0), round_seconds_to = 1)], latejoin hostiles unlock in [DisplayTimeText(max(latejoin_roundstart_locked_until - world.time, 0), round_seconds_to = 1)].")

/datum/controller/subsystem/storyteller/proc/refresh_snapshot(force = FALSE)
	if(!current_snapshot)
		current_snapshot = new

	if(!force && !snapshot_dirty && (world.time - last_snapshot_refresh) < wait)
		return

	prune_recent_trackers()

	var/perform_heavy_scan = force || !last_heavy_scan || (world.time - last_heavy_scan) >= profile.heavy_scan_interval
	var/datum/storyteller/state_snapshot/new_snapshot = new
	populate_light_snapshot(new_snapshot)
	if(perform_heavy_scan)
		populate_heavy_snapshot(new_snapshot)
		last_heavy_scan = world.time
	else
		carry_forward_heavy_snapshot(new_snapshot)

	current_snapshot = new_snapshot
	last_snapshot_refresh = world.time
	snapshot_dirty = FALSE

/datum/controller/subsystem/storyteller/proc/carry_forward_heavy_snapshot(datum/storyteller/state_snapshot/target)
	if(!current_snapshot || !istype(target))
		return
	target.ore_silo_material_total = current_snapshot.ore_silo_material_total
	target.ore_silo_materials = current_snapshot.ore_silo_materials.Copy()
	target.loose_material_total = current_snapshot.loose_material_total
	target.loose_materials = current_snapshot.loose_materials.Copy()
	target.material_gain_recent = current_snapshot.material_gain_recent
	target.station_integrity = current_snapshot.station_integrity
	target.station_breach_tiles = current_snapshot.station_breach_tiles
	target.broken_floor_count = current_snapshot.broken_floor_count
	target.damaged_window_count = current_snapshot.damaged_window_count
	target.damaged_grille_count = current_snapshot.damaged_grille_count
	target.kitchen_food_total = current_snapshot.kitchen_food_total
	target.service_food_total = current_snapshot.service_food_total
	target.medical_supply_total = current_snapshot.medical_supply_total
	target.science_supply_total = current_snapshot.science_supply_total
	target.janitorial_supply_total = current_snapshot.janitorial_supply_total
	target.general_cleanable_count = current_snapshot.general_cleanable_count
	target.blood_cleanable_count = current_snapshot.blood_cleanable_count

/datum/controller/subsystem/storyteller/proc/populate_light_snapshot(datum/storyteller/state_snapshot/snapshot)
	if(!istype(snapshot))
		return

	snapshot.active_population = get_active_player_count(afk_check = TRUE)
	snapshot.recent_deaths = length(recent_death_times)
	snapshot.recent_explosions = length(recent_explosion_times)
	snapshot.total_key_jobs = length(profile.key_jobs)

	for(var/mob/living/player_mob as anything in GLOB.alive_player_list)
		if(QDELETED(player_mob) || !player_mob.mind)
			continue

		var/datum/job/assigned_role = player_mob.mind.assigned_role
		if(!assigned_role || is_unassigned_job(assigned_role))
			continue

		snapshot.alive_crew++
		if(assigned_role.title in profile.key_jobs)
			if(snapshot.key_jobs_occupied[assigned_role.title])
				snapshot.key_jobs_occupied[assigned_role.title] = "[snapshot.key_jobs_occupied[assigned_role.title]], [player_mob.real_name]"
			else
				snapshot.key_jobs_occupied[assigned_role.title] = player_mob.real_name

		var/department_id = assigned_role.paycheck_department
		if(department_id)
			snapshot.department_staffing[department_id] = (snapshot.department_staffing[department_id] || 0) + 1
			if(department_id == ACCOUNT_SRV)
				snapshot.service_staff_count++
			else if(department_id == ACCOUNT_MED)
				snapshot.medical_staff_count++
			else if(department_id == ACCOUNT_SEC)
				snapshot.security_staff_count++
			else if(department_id == ACCOUNT_SCI)
				snapshot.science_staff_count++
			else if(department_id == ACCOUNT_CAR)
				snapshot.cargo_staff_count++

		switch(assigned_role.title)
			if(JOB_COOK, JOB_CHEF)
				snapshot.cook_count++
			if(JOB_BARTENDER)
				snapshot.bartender_count++
			if(JOB_BOTANIST)
				snapshot.botanist_count++
			if(JOB_MEDICAL_DOCTOR, JOB_CHIEF_MEDICAL_OFFICER)
				snapshot.doctor_count++
			if(JOB_CHEMIST)
				snapshot.chemist_count++
			if(JOB_STATION_ENGINEER, JOB_CHIEF_ENGINEER)
				snapshot.engineer_count++
			if(JOB_ATMOSPHERIC_TECHNICIAN)
				snapshot.engineer_count++
				snapshot.atmos_count++
			if(JOB_QUARTERMASTER)
				snapshot.quartermaster_count++
			if(JOB_CARGO_TECHNICIAN)
				snapshot.cargo_technician_count++
			if(JOB_CARGO_GORILLA)
				snapshot.cargo_gorilla_count++
			if(JOB_SHAFT_MINER)
				snapshot.miner_count++
			if(JOB_BITRUNNER)
				snapshot.bitrunner_count++
			if(JOB_SCIENTIST, JOB_RESEARCH_DIRECTOR)
				snapshot.scientist_count++
			if(JOB_ROBOTICIST)
				snapshot.roboticist_count++
			if(JOB_GENETICIST)
				snapshot.geneticist_count++
			if(JOB_JANITOR)
				snapshot.janitor_count++
			if(JOB_CLOWN)
				snapshot.clown_count++
			if(JOB_MIME)
				snapshot.mime_count++

		if(iscarbon(player_mob))
			var/mob/living/carbon/carbon_player = player_mob
			if(carbon_player.health < (carbon_player.maxHealth - 15))
				snapshot.injured_crew_count++
			if(HAS_TRAIT(carbon_player, TRAIT_CRITICAL_CONDITION) || carbon_player.health < 0)
				snapshot.critical_crew_count++

	snapshot.key_jobs_filled_count = length(snapshot.key_jobs_occupied)

	for(var/mob/living/antag_mob as anything in GLOB.current_living_antags)
		if(QDELETED(antag_mob) || antag_mob.stat == DEAD)
			continue
		snapshot.living_antag_count++
		for(var/datum/antagonist/antag_datum as anything in antag_mob.mind?.antag_datums)
			if(antag_datum.antag_flags & ANTAG_SKIP_GLOBAL_LIST)
				continue
			var/antag_name = antag_datum.name || "[antag_datum.type]"
			snapshot.living_antag_types[antag_name] = (snapshot.living_antag_types[antag_name] || 0) + 1

	for(var/department_id in profile.department_labels)
		var/datum/bank_account/department/department_account = SSeconomy.get_dep_account(department_id)
		snapshot.department_money[department_id] = department_account?.account_balance || 0
	snapshot.cargo_budget = snapshot.department_money[ACCOUNT_CAR] || 0

	for(var/area_type in GLOB.the_station_areas)
		var/area/station_area = GLOB.areas_by_type[area_type]
		if(!station_area || !length(station_area.active_alarms))
			continue
		for(var/alarm_type in station_area.active_alarms)
			snapshot.active_alarms += station_area.active_alarms[alarm_type]

	for(var/datum/round_event/running_event as anything in SSevents.running)
		if(QDELETED(running_event))
			continue
		snapshot.active_round_event_count++
		var/event_name = running_event.control?.name || "[running_event.type]"
		snapshot.active_round_events[event_name] = (snapshot.active_round_events[event_name] || 0) + 1

/datum/controller/subsystem/storyteller/proc/populate_heavy_snapshot(datum/storyteller/state_snapshot/snapshot)
	if(!istype(snapshot))
		return

	var/recent_tracked_material_total = 0
	var/obj/machinery/ore_silo/silo = GLOB.ore_silo_default
	if(silo?.materials)
		snapshot.ore_silo_material_total = round(silo.materials.total_amount() / SHEET_MATERIAL_AMOUNT)
		for(var/datum/material/material as anything in silo.materials.materials)
			var/material_amount = round(silo.materials.get_material_amount(material) / SHEET_MATERIAL_AMOUNT)
			snapshot.ore_silo_materials[material.name] = material_amount
			if(!is_storyteller_material_gain_excluded(material))
				recent_tracked_material_total += material_amount

	for(var/obj/item/stack/found_stack in world)
		var/turf/location = get_turf(found_stack)
		if(!location || !SSmapping.level_trait(location.z, ZTRAIT_STATION))
			continue
		snapshot.loose_material_total += found_stack.amount
		snapshot.loose_materials[found_stack.name] = (snapshot.loose_materials[found_stack.name] || 0) + found_stack.amount
		if(!is_storyteller_material_stack_gain_excluded(found_stack))
			recent_tracked_material_total += found_stack.amount
		CHECK_TICK

	snapshot.material_gain_recent = last_material_total ? (recent_tracked_material_total - last_material_total) : 0
	last_material_total = recent_tracked_material_total

	for(var/obj/item/found_item in world)
		var/turf/location = get_turf(found_item)
		if(!location || !is_station_level(location.z))
			continue
		var/area/location_area = get_area(location)
		if(!istype(location_area))
			continue

		if(is_storyteller_countable_food_item(found_item) && is_storyteller_countable_food_storage(found_item.loc))
			if(istype(location_area, /area/station/service/kitchen) || istype(location_area, /area/station/service/kitchen/coldroom))
				snapshot.kitchen_food_total++
			else if(istype(location_area, /area/station/service/bar) || istype(location_area, /area/station/service/cafeteria))
				snapshot.service_food_total++

		if(istype(location_area, /area/station/medical))
			if(istype(found_item, /obj/item/storage/medkit) || istype(found_item, /obj/item/stack/medical) || istype(found_item, /obj/item/healthanalyzer) || istype(found_item, /obj/item/reagent_containers/cup/bottle/epinephrine) || istype(found_item, /obj/item/reagent_containers/hypospray/medipen))
				snapshot.medical_supply_total++

		if(istype(location_area, /area/station/science))
			if(istype(found_item, /obj/item/stock_parts) || istype(found_item, /obj/item/analyzer) || istype(found_item, /obj/item/reagent_containers/cup/beaker) || istype(found_item, /obj/item/stack/sheet/mineral/plasma) || istype(found_item, /obj/item/stack/sheet/glass))
				snapshot.science_supply_total++

		if(istype(found_item, /obj/item/reagent_containers/spray/cleaner) || istype(found_item, /obj/item/grenade/chem_grenade/cleaner) || istype(found_item, /obj/item/mop) || istype(found_item, /obj/item/soap) || istype(found_item, /obj/item/storage/bag/trash) || istype(found_item, /obj/item/lightreplacer))
			snapshot.janitorial_supply_total++
		CHECK_TICK

	populate_station_structure_snapshot(snapshot)

	snapshot.station_integrity = 1
	if(GLOB.start_state)
		var/datum/station_state/live_state = new
		live_state.count()
		snapshot.station_integrity = clamp(GLOB.start_state.score(live_state), 0, 1)
	apply_structure_baseline(snapshot)

/datum/controller/subsystem/storyteller/proc/populate_station_structure_snapshot(datum/storyteller/state_snapshot/snapshot)
	if(!istype(snapshot))
		return

	for(var/area_type in GLOB.the_station_areas)
		var/area/station_area = GLOB.areas_by_type[area_type]
		if(!station_area)
			continue

		for(var/list/zlevel_turfs as anything in station_area.get_zlevel_turf_lists())
			for(var/turf/location as anything in zlevel_turfs)
				if(!is_station_level(location.z))
					continue

				if(isspaceturf(location))
					snapshot.station_breach_tiles++
				else if(isfloorturf(location))
					var/turf/open/floor/floor = location
					if(floor.broken)
						snapshot.broken_floor_count++

				for(var/obj/found_object as anything in location.contents)
					if(istype(found_object, /obj/effect/decal/cleanable))
						snapshot.general_cleanable_count++
						if(istype(found_object, /obj/effect/decal/cleanable/blood))
							snapshot.blood_cleanable_count++
					else if(istype(found_object, /obj/structure/window))
						var/obj/structure/window/found_window = found_object
						if(found_window.get_integrity() < found_window.max_integrity)
							snapshot.damaged_window_count++
					else if(istype(found_object, /obj/structure/grille))
						var/obj/structure/grille/found_grille = found_object
						if(found_grille.get_integrity() < found_grille.max_integrity)
							snapshot.damaged_grille_count++

				CHECK_TICK

/datum/controller/subsystem/storyteller/proc/apply_structure_baseline(datum/storyteller/state_snapshot/snapshot)
	if(!istype(snapshot))
		return
	if(!SSticker.HasRoundStarted())
		return

	if(!baseline_structure_captured)
		baseline_structure_captured = TRUE
		baseline_station_breach_tiles = snapshot.station_breach_tiles
		baseline_broken_floor_count = snapshot.broken_floor_count
		baseline_damaged_window_count = snapshot.damaged_window_count
		baseline_damaged_grille_count = snapshot.damaged_grille_count

	snapshot.station_breach_tiles = max(0, snapshot.station_breach_tiles - baseline_station_breach_tiles)
	snapshot.broken_floor_count = max(0, snapshot.broken_floor_count - baseline_broken_floor_count)
	snapshot.damaged_window_count = max(0, snapshot.damaged_window_count - baseline_damaged_window_count)
	snapshot.damaged_grille_count = max(0, snapshot.damaged_grille_count - baseline_damaged_grille_count)

/datum/controller/subsystem/storyteller/proc/prune_recent_trackers()
	var/cutoff = world.time - profile.recent_window
	while(length(recent_death_times) && recent_death_times[1] < cutoff)
		recent_death_times.Cut(1, 2)
	while(length(recent_explosion_times) && recent_explosion_times[1] < cutoff)
		recent_explosion_times.Cut(1, 2)

/datum/controller/subsystem/storyteller/proc/update_scores()
	if(!current_snapshot)
		return
	current_snapshot.control_score = profile.score_control(current_snapshot)
	current_snapshot.danger_score = profile.score_danger(current_snapshot)

/datum/controller/subsystem/storyteller/proc/evaluate_needs()
	current_need_reports = list()
	if(!current_snapshot)
		return

	for(var/datum/storyteller/need_analyzer/analyzer as anything in need_analyzers)
		var/datum/storyteller/need_report/report = analyzer.evaluate(src, current_snapshot)
		if(!istype(report))
			continue
		current_need_reports += report

/datum/controller/subsystem/storyteller/proc/get_top_need_priority()
	var/highest_priority = 0
	for(var/datum/storyteller/need_report/report as anything in current_need_reports)
		highest_priority = max(highest_priority, report.priority)
	return highest_priority

/datum/controller/subsystem/storyteller/proc/update_budgets()
	if(!current_snapshot)
		return

	var/budget_delta = current_snapshot.control_score - current_snapshot.danger_score
	if(budget_delta > 0)
		var/threat_divisor = profile.threat_gain_divisor
		if(round_mode == STORYTELLER_ROUND_MODE_EXTENDED)
			threat_divisor = max(profile.threat_gain_divisor, profile.extended_threat_gain_divisor)
		threat_budget = min(profile.budget_cap, threat_budget + max(1, round(budget_delta / max(threat_divisor, 1))))
	else if(budget_delta < 0)
		aid_budget = min(profile.budget_cap, aid_budget + max(1, round(-budget_delta / profile.aid_gain_divisor)))

	var/top_need_priority = get_top_need_priority()
	if(top_need_priority > 0)
		aid_budget = min(profile.budget_cap, aid_budget + max(1, round(top_need_priority / profile.need_gain_divisor)))

/datum/controller/subsystem/storyteller/proc/get_round_elapsed()
	if(!SSticker.HasRoundStarted())
		return 0
	var/start_time = round_started_at || SSticker.round_start_time
	return max(world.time - start_time, 0)

/datum/controller/subsystem/storyteller/proc/get_security_readiness_score(datum/storyteller/state_snapshot/snapshot = current_snapshot)
	if(!istype(snapshot))
		return 0

	var/crew_count = max(snapshot.alive_crew, snapshot.active_population, 1)
	var/expected_security = max(round(crew_count / 8), 1)
	var/staff_presence = clamp(snapshot.security_staff_count / expected_security, 0, 1.25)
	var/staff_factor = clamp(snapshot.security_staff_count / expected_security, 0, 1)
	var/casualty_resilience = clamp(1 - ((snapshot.recent_deaths + (snapshot.critical_crew_count * 0.5)) / max(snapshot.security_staff_count * 2, 1)), 0, 1)
	var/alarm_control = clamp(1 - (snapshot.active_alarms / max(snapshot.security_staff_count * 6, 1)), 0, 1)
	var/threat_control = clamp(1 - (snapshot.living_antag_count / max(snapshot.security_staff_count * 2, 1)), 0, 1)
	var/readiness = (staff_presence * 50) + (casualty_resilience * 20 * staff_factor) + (alarm_control * 15 * staff_factor) + (threat_control * 15 * staff_factor)
	return clamp(round(readiness), 0, 100)

/datum/controller/subsystem/storyteller/proc/get_roundstart_security_readiness_score()
	if(!islist(frozen_roster_data))
		return 0

	var/ready_count = frozen_roster_data["readyCount"] || 0
	var/key_job_intents = frozen_roster_data["keyJobIntentCount"] || 0
	var/department_coverage = frozen_roster_data["departmentCoverage"] || 0
	var/list/department_intents = frozen_roster_data["departmentIntents"] || list()
	var/security_intents = department_intents[ACCOUNT_SEC] || 0
	var/expected_security = max(round(max(ready_count, 1) / 9), 1)
	var/staff_presence = clamp(security_intents / expected_security, 0, 1.25)
	var/staff_factor = clamp(security_intents / expected_security, 0, 1)
	var/key_job_support = clamp(key_job_intents / 6, 0, 1)
	var/coverage_support = clamp(department_coverage / 7, 0, 1)
	var/readiness = (staff_presence * 70) + (key_job_support * 15 * staff_factor) + (coverage_support * 15 * staff_factor)
	return clamp(round(readiness), 0, 100)

/datum/controller/subsystem/storyteller/proc/get_antag_readiness_score(action_context)
	if(action_context == STORYTELLER_CONTEXT_ROUNDSTART)
		return get_roundstart_security_readiness_score()
	return get_security_readiness_score()

/datum/controller/subsystem/storyteller/proc/get_distress_stage_drop(datum/storyteller/state_snapshot/snapshot = current_snapshot)
	if(!istype(snapshot) || !profile)
		return 0

	var/integrity_loss = clamp(1 - snapshot.station_integrity, 0, 1)
	var/breach_pressure = clamp(snapshot.station_breach_tiles / 120, 0, 2)
	var/floor_pressure = clamp(snapshot.broken_floor_count / 160, 0, 1.5)
	var/frame_pressure = clamp((snapshot.damaged_window_count + snapshot.damaged_grille_count) / 120, 0, 1.5)
	var/death_pressure = clamp(snapshot.recent_deaths / 3, 0, 2.5)
	var/explosion_pressure = clamp(snapshot.recent_explosions / 2, 0, 2.5)
	var/critical_pressure = clamp(snapshot.critical_crew_count / max(snapshot.alive_crew / 6, 1), 0, 2)
	var/distress_score = ((death_pressure * 1) + (explosion_pressure * 1.15) + (breach_pressure * 0.9) + (floor_pressure * 0.45) + (frame_pressure * 0.4) + (integrity_loss * 1.4) + (critical_pressure * 0.75)) * profile.escalation_decay_multiplier

	var/stage_drop = 0
	if(distress_score >= 1.25)
		stage_drop++
	if(distress_score >= 2.75)
		stage_drop++
	if(distress_score >= 4.5)
		stage_drop++
	return stage_drop

/datum/controller/subsystem/storyteller/proc/get_content_stage_analysis()
	RETURN_TYPE(/list)
	var/list/analysis = list(
		"stage" = 1,
		"phaseCap" = phase_cap,
	)
	if(phase_cap <= 1)
		return analysis

	var/elapsed = get_round_elapsed()
	var/population = max(current_snapshot?.alive_crew || 0, current_snapshot?.active_population || 0)
	var/control = current_snapshot?.control_score || 0
	var/danger = current_snapshot?.danger_score || 0
	var/active_antags = current_snapshot?.living_antag_count || 0
	var/security_readiness = get_security_readiness_score()
	var/stability_margin = max(control - danger, 0)
	var/rise_multiplier = profile?.escalation_rise_multiplier || 1
	var/effective_elapsed = elapsed * rise_multiplier
	var/effective_population = round(population * rise_multiplier)
	var/effective_stability = round(stability_margin * rise_multiplier)
	var/effective_security = round(security_readiness * rise_multiplier)
	var/stage = 1

	if(phase_cap >= 2 && (effective_elapsed >= 25 MINUTES || effective_population >= 18 || effective_stability >= 35 || (active_antags >= 2 && effective_security >= 35)))
		stage = 2
	if(phase_cap >= 3 && (effective_elapsed >= 50 MINUTES || effective_population >= 32 || effective_stability >= 55 || (active_antags >= 4 && effective_security >= 55)))
		stage = 3
	if(phase_cap >= 4 && (effective_elapsed >= 75 MINUTES || effective_population >= 45 || effective_stability >= 72 || (active_antags >= 6 && effective_security >= 70)))
		stage = 4

	var/distress_stage_drop = get_distress_stage_drop()
	stage = max(1, stage - distress_stage_drop)
	var/floor_stage = max(1, automatic_phase_floor - distress_stage_drop)
	stage = max(stage, floor_stage)

	analysis |= list(
		"stage" = clamp(stage, 1, phase_cap),
		"elapsedDs" = elapsed,
		"population" = population,
		"control" = control,
		"danger" = danger,
		"activeAntags" = active_antags,
		"securityReadiness" = security_readiness,
		"stabilityMargin" = stability_margin,
		"riseMultiplier" = rise_multiplier,
		"effectiveElapsedDs" = effective_elapsed,
		"effectivePopulation" = effective_population,
		"effectiveStability" = effective_stability,
		"effectiveSecurity" = effective_security,
		"distressStageDrop" = distress_stage_drop,
		"floorStage" = floor_stage,
		"stage2Triggers" = list(
			"time" = effective_elapsed >= 25 MINUTES,
			"population" = effective_population >= 18,
			"stability" = effective_stability >= 35,
			"securityVsAntags" = active_antags >= 2 && effective_security >= 35,
		),
		"stage3Triggers" = list(
			"time" = effective_elapsed >= 50 MINUTES,
			"population" = effective_population >= 32,
			"stability" = effective_stability >= 55,
			"securityVsAntags" = active_antags >= 4 && effective_security >= 55,
		),
		"stage4Triggers" = list(
			"time" = effective_elapsed >= 75 MINUTES,
			"population" = effective_population >= 45,
			"stability" = effective_stability >= 72,
			"securityVsAntags" = active_antags >= 6 && effective_security >= 70,
		),
	)
	return analysis

/datum/controller/subsystem/storyteller/proc/calculate_content_stage()
	return get_content_stage_analysis()["stage"]

/datum/controller/subsystem/storyteller/proc/update_content_stage()
	if(manual_phase_override)
		return
	var/list/stage_analysis = get_content_stage_analysis()
	var/new_phase = stage_analysis["stage"] || current_phase_max
	if(new_phase == current_phase_max)
		return
	var/previous_phase = current_phase_max
	current_phase_max = new_phase
	if(current_phase_max > previous_phase)
		record_decision("Storyteller content stage advanced to [current_phase_max].", build_storyteller_trace_data(list(
			"previousPhase" = previous_phase,
			"newPhase" = current_phase_max,
			"stageAnalysis" = stage_analysis,
		)))
	else
		record_decision("Storyteller content stage fell back to [current_phase_max].", build_storyteller_trace_data(list(
			"previousPhase" = previous_phase,
			"newPhase" = current_phase_max,
			"stageAnalysis" = stage_analysis,
		)))

/datum/controller/subsystem/storyteller/proc/is_channel_ready(action_polarity)
	if(has_pending_storyteller_scheduled_action(action_polarity))
		return FALSE
	switch(action_polarity)
		if(STORYTELLER_POLARITY_POSITIVE)
			return world.time >= positive_channel_ready_at
		if(STORYTELLER_POLARITY_NEGATIVE)
			return world.time >= negative_channel_ready_at
	return TRUE

/datum/controller/subsystem/storyteller/proc/get_action_impact(datum/storyteller/action/action)
	if(!istype(action))
		return 0
	var/effective_weight = max(action.get_effective_weight(src), 1)
	var/base_impact = (action.cost * 4) + effective_weight
	if(action.context == STORYTELLER_CONTEXT_LATEJOIN)
		base_impact += 10
	else if(action.context == STORYTELLER_CONTEXT_ROUNDSTART)
		base_impact += 6
	return clamp(round(base_impact), 5, 100)

/datum/controller/subsystem/storyteller/proc/calculate_negative_interval(datum/storyteller/action/action)
	var/datum/storyteller/state_snapshot/snapshot = current_snapshot
	var/crew_count = max(snapshot?.alive_crew || 0, snapshot?.active_population || 0)
	var/crew_ratio = clamp(crew_count / 60, 0, 1)
	var/base_interval = round(profile.negative_interval_max - ((profile.negative_interval_max - profile.negative_interval_min) * crew_ratio))
	var/danger_pressure = clamp((snapshot?.danger_score || 0) / 100, 0, 1)
	var/integrity_loss = clamp(1 - (snapshot?.station_integrity || 1), 0, 1)
	var/death_pressure = clamp((snapshot?.recent_deaths || 0) / 6, 0, 1)
	var/explosion_pressure = clamp((snapshot?.recent_explosions || 0) / 4, 0, 1)
	var/action_impact = get_action_impact(action) / 100
	var/impact_scale = 1 + (action_impact * 0.4)
	var/pressure_scale = 1 - min(0.55, (danger_pressure * 0.18) + (integrity_loss * 0.15) + (death_pressure * 0.12) + (explosion_pressure * 0.2))
	var/interval = round(base_interval * impact_scale * pressure_scale)
	if(round_mode == STORYTELLER_ROUND_MODE_EXTENDED)
		interval = round(interval * 1.35)
	return clamp(interval, profile.negative_interval_min, profile.negative_interval_max + (round_mode == STORYTELLER_ROUND_MODE_EXTENDED ? 10 MINUTES : 0))

/datum/controller/subsystem/storyteller/proc/calculate_positive_interval(datum/storyteller/action/action)
	var/datum/storyteller/state_snapshot/snapshot = current_snapshot
	var/crew_count = max(snapshot?.alive_crew || 0, snapshot?.active_population || 0)
	var/crew_ratio = clamp(crew_count / 45, 0, 1)
	var/base_interval = round(profile.positive_interval_min + ((profile.positive_interval_max - profile.positive_interval_min) * crew_ratio))
	var/danger_pressure = clamp(max((snapshot?.danger_score || 0) - (snapshot?.control_score || 0), 0) / 100, 0, 1)
	var/integrity_loss = clamp(1 - (snapshot?.station_integrity || 1), 0, 1)
	var/death_pressure = clamp((snapshot?.recent_deaths || 0) / 6, 0, 1)
	var/explosion_pressure = clamp((snapshot?.recent_explosions || 0) / 4, 0, 1)
	var/need_pressure = clamp(get_top_need_priority() / 100, 0, 1)
	var/negative_aftershock = clamp(last_negative_action_impact / 100, 0, 1)
	var/action_impact = get_action_impact(action) / 100
	var/impact_scale = 1 + (action_impact * 0.25)
	var/distress_scale = 1 - min(0.65, (danger_pressure * 0.2) + (integrity_loss * 0.08) + (death_pressure * 0.16) + (explosion_pressure * 0.12) + (need_pressure * 0.18) + (negative_aftershock * 0.1))
	var/interval = round(base_interval * impact_scale * distress_scale)
	return clamp(interval, 6 MINUTES, profile.positive_interval_max + 10 MINUTES)

/datum/controller/subsystem/storyteller/proc/prune_expired_modifiers()
	if(!length(active_modifiers))
		return
	for(var/modifier_id in active_modifiers.Copy())
		var/list/entry = active_modifiers[modifier_id]
		if(!islist(entry))
			active_modifiers -= modifier_id
			continue
		var/expires_at = entry["until"]
		if(!isnum(expires_at) || world.time < expires_at)
			continue
		active_modifiers -= modifier_id

/datum/controller/subsystem/storyteller/proc/get_modifier_entry(modifier_id)
	prune_expired_modifiers()
	if(!modifier_id)
		return null
	var/list/entry = active_modifiers[modifier_id]
	if(!islist(entry))
		return null
	return entry

/datum/controller/subsystem/storyteller/proc/has_active_modifier(modifier_id)
	return !isnull(get_modifier_entry(modifier_id))

/datum/controller/subsystem/storyteller/proc/get_modifier_value(modifier_id, default_value = 1)
	var/list/entry = get_modifier_entry(modifier_id)
	if(!islist(entry))
		return default_value
	var/value = entry["value"]
	if(!isnum(value))
		value = text2num("[value]")
	if(!isnum(value))
		return default_value
	return value

/datum/controller/subsystem/storyteller/proc/get_modifier_remaining(modifier_id)
	var/list/entry = get_modifier_entry(modifier_id)
	if(!islist(entry))
		return 0
	return max(entry["until"] - world.time, 0)

/datum/controller/subsystem/storyteller/proc/get_modifier_label(modifier_id)
	var/list/entry = get_modifier_entry(modifier_id)
	if(!islist(entry))
		return null
	return "[entry["label"]]"

/datum/controller/subsystem/storyteller/proc/get_modifier_title(modifier_id)
	var/list/entry = get_modifier_entry(modifier_id)
	if(!islist(entry))
		return null
	return "[entry["title"]]"

/datum/controller/subsystem/storyteller/proc/get_modifier_description(modifier_id)
	var/list/entry = get_modifier_entry(modifier_id)
	if(!islist(entry))
		return null
	return "[entry["description"]]"

/datum/controller/subsystem/storyteller/proc/apply_timed_modifier(modifier_id, value, duration, label, title, positive = TRUE, description = null)
	if(!modifier_id || !isnum(duration) || duration <= 0)
		return FALSE
	active_modifiers[modifier_id] = list(
		"value" = value,
		"until" = world.time + duration,
		"label" = label || modifier_id,
		"title" = title || modifier_id,
		"description" = description || label || title || modifier_id,
		"positive" = positive,
	)
	return TRUE

/datum/controller/subsystem/storyteller/proc/is_polarity_fatigue_locked(action_polarity)
	switch(action_polarity)
		if(STORYTELLER_POLARITY_POSITIVE)
			return world.time < positive_fatigue_locked_until
		if(STORYTELLER_POLARITY_NEGATIVE)
			return world.time < negative_fatigue_locked_until
	return FALSE

/datum/controller/subsystem/storyteller/proc/is_family_on_cooldown(family)
	if(!family)
		return FALSE
	var/cooldown_end = family_cooldowns[family]
	if(!cooldown_end)
		return FALSE
	if(world.time >= cooldown_end)
		family_cooldowns -= family
		return FALSE
	return TRUE

/datum/controller/subsystem/storyteller/proc/prune_admin_action_cooldowns()
	if(!length(action_admin_cooldowns))
		return
	for(var/action_id in action_admin_cooldowns.Copy())
		var/cooldown_end = action_admin_cooldowns[action_id]
		if(isnum(cooldown_end) && world.time < cooldown_end)
			continue
		action_admin_cooldowns -= action_id

/datum/controller/subsystem/storyteller/proc/is_action_admin_suppressed(action_id)
	if(!action_id)
		return FALSE
	prune_admin_action_cooldowns()
	var/cooldown_end = action_admin_cooldowns[action_id]
	return isnum(cooldown_end) && world.time < cooldown_end

/datum/controller/subsystem/storyteller/proc/is_action_discarded(action_id)
	if(!action_id)
		return FALSE
	return !!admin_discarded_actions[action_id]

/datum/controller/subsystem/storyteller/proc/toggle_action_discarded(action_id, mob/user)
	var/datum/storyteller/action/action = catalog.get_action(action_id)
	if(!istype(action) || !action.is_antag_action())
		return FALSE
	if(is_action_discarded(action.id))
		admin_discarded_actions -= action.id
		record_decision("[key_name(user)] restored storyteller antagonist action [action.name].")
		return TRUE
	admin_discarded_actions[action.id] = TRUE
	record_decision("[key_name(user)] discarded storyteller antagonist action [action.name] for the current round.")
	return TRUE

/datum/controller/subsystem/storyteller/proc/get_reserved_action_budget(action_id)
	if(!action_id)
		return 0
	return max(0, reserved_action_budgets[action_id] || 0)

/datum/controller/subsystem/storyteller/proc/consume_reserved_action_budget(action_id)
	if(!action_id)
		return 0
	var/reserved = get_reserved_action_budget(action_id)
	reserved_action_budgets -= action_id
	return reserved

/datum/controller/subsystem/storyteller/proc/refund_reserved_action_budget(action_id)
	if(!action_id)
		return 0
	var/refund = consume_reserved_action_budget(action_id)
	if(refund <= 0)
		return 0
	threat_budget = min(profile?.budget_cap || 100, threat_budget + refund)
	return refund

/datum/controller/subsystem/storyteller/proc/copy_storyteller_context_data(list/context_data)
	RETURN_TYPE(/list)
	if(!islist(context_data))
		return list()
	return context_data.Copy()

/datum/controller/subsystem/storyteller/proc/has_pending_storyteller_scheduled_action(action_polarity)
	if(!action_polarity)
		return FALSE
	prune_scheduled_action_queue()
	for(var/list/entry as anything in scheduled_action_queue)
		if(!islist(entry))
			continue
		if(entry["polarity"] == action_polarity)
			return TRUE
	return FALSE

/datum/controller/subsystem/storyteller/proc/get_scheduled_action_conflict_reason(datum/storyteller/action/action)
	if(!istype(action))
		return null
	prune_scheduled_action_queue()
	for(var/list/entry as anything in scheduled_action_queue)
		if(!islist(entry))
			continue
		if(entry["actionId"] == action.id)
			return "Already queued in the storyteller schedule"
		if(action.family && entry["family"] == action.family)
			return "A related storyteller action is already queued"
	return null

/datum/controller/subsystem/storyteller/proc/prune_scheduled_action_queue()
	if(!length(scheduled_action_queue))
		return
	for(var/index = length(scheduled_action_queue), index >= 1, index--)
		var/list/entry = scheduled_action_queue[index]
		if(!islist(entry))
			scheduled_action_queue.Cut(index, index + 1)
			continue
		if(!entry["queueId"] || !entry["actionId"])
			scheduled_action_queue.Cut(index, index + 1)
			continue
		if(!catalog?.get_action(entry["actionId"]))
			scheduled_action_queue.Cut(index, index + 1)

/datum/controller/subsystem/storyteller/proc/get_scheduled_action_queue_index(queue_id)
	if(!queue_id || !length(scheduled_action_queue))
		return 0
	for(var/index in 1 to length(scheduled_action_queue))
		var/list/entry = scheduled_action_queue[index]
		if(!islist(entry))
			continue
		if(entry["queueId"] == queue_id)
			return index
	return 0

/datum/controller/subsystem/storyteller/proc/get_scheduled_action_queue_entry(queue_id)
	RETURN_TYPE(/list)
	var/index = get_scheduled_action_queue_index(queue_id)
	if(index <= 0)
		return null
	var/list/entry = scheduled_action_queue[index]
	if(!islist(entry))
		return null
	return entry

/datum/controller/subsystem/storyteller/proc/build_scheduled_action_context(datum/storyteller/action/action, list/context_data, forced = FALSE, mob/user)
	RETURN_TYPE(/list)
	var/list/stored_context = copy_storyteller_context_data(context_data)
	stored_context["selection_context"] = action?.context || stored_context["selection_context"]
	stored_context["scheduled"] = TRUE
	if(forced && istype(action))
		stored_context |= build_forced_context_data(action, user)
	return stored_context

/datum/controller/subsystem/storyteller/proc/schedule_action_entry(datum/storyteller/action/action, list/context_data, delay, source = STORYTELLER_QUEUE_SOURCE_ADMIN, storyteller_generated = FALSE, mob/user)
	if(!istype(action))
		return FALSE
	prune_scheduled_action_queue()
	var/normalized_delay = max(0, round(delay))
	var/source_name = source == STORYTELLER_QUEUE_SOURCE_ADMIN ? key_name(user) : "Storyteller"
	scheduled_action_queue += list(list(
		"queueId" = "storyteller_queue_[next_scheduled_action_queue_id++]",
		"actionId" = action.id,
		"name" = action.name,
		"context" = action.context,
		"polarity" = action.polarity,
		"family" = action.family,
		"source" = source,
		"sourceName" = source_name,
		"storytellerGenerated" = storyteller_generated,
		"scheduledAt" = world.time,
		"executeAt" = world.time + normalized_delay,
		"delay" = normalized_delay,
		"contextData" = build_scheduled_action_context(action, context_data, source == STORYTELLER_QUEUE_SOURCE_ADMIN, user),
	))
	return TRUE

/datum/controller/subsystem/storyteller/proc/schedule_storyteller_action(datum/storyteller/action/action, list/context_data)
	if(!istype(action))
		return FALSE
	var/delay = STORYTELLER_DEFAULT_ACTION_QUEUE_DELAY
	if(!schedule_action_entry(action, context_data, delay, STORYTELLER_QUEUE_SOURCE_STORYTELLER, TRUE, null))
		return FALSE
	record_decision("Queued storyteller action [action.name] to trigger in [DisplayTimeText(delay, round_seconds_to = 1)].", build_storyteller_trace_data(list(
		"queuedAction" = get_storyteller_action_trace_data(action),
		"queueDelayDs" = delay,
		"queueSource" = STORYTELLER_QUEUE_SOURCE_STORYTELLER,
	), current_snapshot, context_data))
	return TRUE

/datum/controller/subsystem/storyteller/proc/queue_action_with_delay(action_id, delay, mob/user)
	var/datum/storyteller/action/action = catalog.get_action(action_id)
	if(!istype(action))
		return FALSE
	var/normalized_delay = max(0, round(delay))
	var/list/context_data = build_forced_context_data(action, user)
	if(!schedule_action_entry(action, context_data, normalized_delay, STORYTELLER_QUEUE_SOURCE_ADMIN, FALSE, user))
		return FALSE
	record_decision("[key_name(user)] queued storyteller action [action.name] to trigger in [DisplayTimeText(normalized_delay, round_seconds_to = 1)].", build_storyteller_trace_data(list(
		"queuedAction" = get_storyteller_action_trace_data(action),
		"queueDelayDs" = normalized_delay,
		"queueSource" = STORYTELLER_QUEUE_SOURCE_ADMIN,
	), current_snapshot, context_data))
	return TRUE

/datum/controller/subsystem/storyteller/proc/remove_scheduled_action(queue_id, mob/user)
	prune_scheduled_action_queue()
	var/index = get_scheduled_action_queue_index(queue_id)
	if(index <= 0)
		return FALSE
	var/list/entry = scheduled_action_queue[index]
	scheduled_action_queue.Cut(index, index + 1)
	record_decision("[key_name(user)] removed queued storyteller action [entry["name"]].")
	return TRUE

/datum/controller/subsystem/storyteller/proc/set_scheduled_action_delay(queue_id, delay, mob/user)
	prune_scheduled_action_queue()
	var/index = get_scheduled_action_queue_index(queue_id)
	if(index <= 0)
		return FALSE
	var/list/entry = scheduled_action_queue[index]
	if(!islist(entry))
		return FALSE
	var/normalized_delay = max(0, round(delay))
	entry["scheduledAt"] = world.time
	entry["executeAt"] = world.time + normalized_delay
	entry["delay"] = normalized_delay
	record_decision("[key_name(user)] changed queued storyteller action [entry["name"]] timer to [DisplayTimeText(normalized_delay, round_seconds_to = 1)].")
	return TRUE

/datum/controller/subsystem/storyteller/proc/move_scheduled_action(queue_id, direction, mob/user)
	prune_scheduled_action_queue()
	var/index = get_scheduled_action_queue_index(queue_id)
	if(index <= 0)
		return FALSE
	var/list/entry = scheduled_action_queue[index]
	if(!islist(entry))
		return FALSE
	var/target_index = index
	switch(direction)
		if("up")
			target_index = max(1, index - 1)
		if("down")
			target_index = min(length(scheduled_action_queue), index + 1)
		if("top")
			target_index = 1
		if("bottom")
			target_index = length(scheduled_action_queue)
		else
			return FALSE
	if(target_index == index)
		return FALSE
	scheduled_action_queue.Cut(index, index + 1)
	var/list/new_queue = list()
	var/inserted = FALSE
	for(var/i in 1 to (length(scheduled_action_queue) + 1))
		if(i == target_index && !inserted)
			new_queue += list(entry)
			inserted = TRUE
		if(i <= length(scheduled_action_queue))
			new_queue += list(scheduled_action_queue[i])
	if(!inserted)
		new_queue += list(entry)
	scheduled_action_queue = new_queue
	record_decision("[key_name(user)] moved queued storyteller action [entry["name"]] to position [target_index].")
	return TRUE

/datum/controller/subsystem/storyteller/proc/force_scheduled_action(queue_id, mob/user)
	prune_scheduled_action_queue()
	var/index = get_scheduled_action_queue_index(queue_id)
	if(index <= 0)
		return FALSE
	var/list/entry = scheduled_action_queue[index]
	if(!islist(entry))
		return FALSE
	var/datum/storyteller/action/action = catalog.get_action(entry["actionId"])
	if(!istype(action))
		record_decision("[key_name(user)] failed to force queued storyteller action [entry["name"]].")
		return FALSE

	refresh_snapshot(TRUE)
	update_scores()
	evaluate_needs()

	var/list/context_data = copy_storyteller_context_data(entry["contextData"])
	if(!length(context_data))
		context_data = list("selection_context" = action.context)
	context_data |= build_forced_context_data(action, user)

	if(!action.force_execute(src, current_snapshot, context_data))
		record_decision("[key_name(user)] failed to force queued storyteller action [action.name].")
		return FALSE

	scheduled_action_queue.Cut(index, index + 1)
	if(action.context == STORYTELLER_CONTEXT_ROUNDSTART || action.context == STORYTELLER_CONTEXT_LATEJOIN)
		record_decision("[key_name(user)] armed queued storyteller action [action.name] immediately.")
	else
		record_decision("[key_name(user)] forced queued storyteller action [action.name] immediately.")
	return TRUE

/datum/controller/subsystem/storyteller/proc/execute_scheduled_action_entry(list/entry)
	if(!islist(entry))
		return FALSE
	var/datum/storyteller/action/action = catalog.get_action(entry["actionId"])
	if(!istype(action))
		return FALSE
	var/list/context_data = copy_storyteller_context_data(entry["contextData"])
	if(!length(context_data))
		context_data = list("selection_context" = action.context)
	var/success = FALSE
	if(entry["source"] == STORYTELLER_QUEUE_SOURCE_ADMIN)
		success = action.force_execute(src, current_snapshot, context_data)
	else
		success = action.execute(src, current_snapshot, context_data)
	if(!success)
		record_decision("Queued storyteller action [action.name] failed to trigger.", build_storyteller_trace_data(list(
			"queuedAction" = get_storyteller_action_trace_data(action),
			"queueEntry" = list(
				"id" = entry["queueId"],
				"context" = entry["context"],
				"polarity" = entry["polarity"],
				"family" = entry["family"],
				"source" = entry["source"],
				"sourceName" = entry["sourceName"],
				"scheduledAt" = entry["scheduledAt"],
				"executeAt" = entry["executeAt"],
				"delay" = entry["delay"],
			),
		), current_snapshot, context_data))
	return success

/datum/controller/subsystem/storyteller/proc/process_scheduled_action_queue()
	prune_scheduled_action_queue()
	if(!length(scheduled_action_queue))
		return FALSE
	var/processed_anything = FALSE
	for(var/index = 1, index <= length(scheduled_action_queue), )
		var/list/entry = scheduled_action_queue[index]
		if(!islist(entry))
			scheduled_action_queue.Cut(index, index + 1)
			continue
		var/action_context = entry["context"]
		if(action_context == STORYTELLER_CONTEXT_ROUNDSTART)
			if(SSticker.current_state > GAME_STATE_SETTING_UP)
				record_decision("Queued storyteller action [entry["name"]] expired because the roundstart setup window has already passed.")
				scheduled_action_queue.Cut(index, index + 1)
				continue
		else if(!SSticker.IsRoundInProgress())
			index++
			continue
		if(world.time < (entry["executeAt"] || 0))
			index++
			continue
		scheduled_action_queue.Cut(index, index + 1)
		processed_anything = execute_scheduled_action_entry(entry) || processed_anything
	return processed_anything

/datum/controller/subsystem/storyteller/proc/get_scheduled_action_queue_ui_data()
	RETURN_TYPE(/list)
	prune_scheduled_action_queue()
	var/list/data = list()
	var/position = 1
	for(var/list/entry as anything in scheduled_action_queue)
		if(!islist(entry))
			continue
		data += list(list(
			"id" = entry["queueId"],
			"name" = entry["name"],
			"context" = entry["context"],
			"polarity" = entry["polarity"],
			"source" = entry["source"],
			"sourceName" = entry["sourceName"],
			"storytellerGenerated" = !!entry["storytellerGenerated"],
			"remaining" = max((entry["executeAt"] || 0) - world.time, 0),
			"scheduledFor" = station_time_timestamp("hh:mm:ss", entry["executeAt"]),
			"position" = position,
		))
		position++
	return data

/datum/controller/subsystem/storyteller/proc/prune_queued_antag_metadata()
	if(!length(queued_antag_metadata))
		return
	var/list/active_refs = list()
	for(var/datum/dynamic_ruleset/ruleset as anything in SSdynamic.queued_rulesets)
		active_refs[REF(ruleset)] = TRUE
	for(var/metadata_ref in queued_antag_metadata.Copy())
		if(active_refs[metadata_ref])
			continue
		queued_antag_metadata -= metadata_ref

/datum/controller/subsystem/storyteller/proc/is_latejoin_hostile_locked()
	if(world.time < latejoin_roundstart_locked_until)
		return TRUE
	return world.time < (last_latejoin_hostile_at + profile.latejoin_hostile_lock)

/datum/controller/subsystem/storyteller/proc/note_latejoin_hostile_trigger()
	last_latejoin_hostile_at = world.time

/datum/controller/subsystem/storyteller/proc/get_event_control(event_control_type)
	for(var/datum/round_event_control/event_control as anything in SSevents.control)
		if(event_control.type == event_control_type)
			return event_control

/datum/controller/subsystem/storyteller/proc/get_storyteller_snapshot_trace_data(datum/storyteller/state_snapshot/snapshot = current_snapshot)
	RETURN_TYPE(/list)
	if(!istype(snapshot))
		return list()

	return list(
		"activePopulation" = snapshot.active_population,
		"aliveCrew" = snapshot.alive_crew,
		"recentDeaths" = snapshot.recent_deaths,
		"recentExplosions" = snapshot.recent_explosions,
		"activeAlarms" = snapshot.active_alarms,
		"controlScore" = snapshot.control_score,
		"dangerScore" = snapshot.danger_score,
		"livingAntagCount" = snapshot.living_antag_count,
		"stationIntegrity" = round(snapshot.station_integrity * 100, 0.1),
		"breachTiles" = snapshot.station_breach_tiles,
		"brokenFloors" = snapshot.broken_floor_count,
		"damagedWindows" = snapshot.damaged_window_count,
		"damagedGrilles" = snapshot.damaged_grille_count,
		"cargoBudget" = snapshot.cargo_budget,
		"materialGainRecent" = snapshot.material_gain_recent,
		"oreSiloMaterials" = snapshot.ore_silo_material_total,
		"looseMaterials" = snapshot.loose_material_total,
		"criticalCrewCount" = snapshot.critical_crew_count,
		"securityStaffCount" = snapshot.security_staff_count,
		"engineeringStaffCount" = snapshot.engineer_count + snapshot.atmos_count,
		"medicalStaffCount" = snapshot.medical_staff_count,
	)

/datum/controller/subsystem/storyteller/proc/get_storyteller_roster_trace_data(list/roster_data)
	RETURN_TYPE(/list)
	if(!islist(roster_data))
		return list()

	var/list/department_intents = roster_data["departmentIntents"]
	var/list/job_intents = roster_data["jobIntents"]

	return list(
		"readyCount" = roster_data["readyCount"] || 0,
		"keyJobIntentCount" = roster_data["keyJobIntentCount"] || 0,
		"departmentCoverage" = roster_data["departmentCoverage"] || 0,
		"departmentIntents" = department_intents ? department_intents.Copy() : list(),
		"jobIntents" = job_intents ? job_intents.Copy() : list(),
	)

/datum/controller/subsystem/storyteller/proc/get_storyteller_context_trace_data(list/context_data)
	RETURN_TYPE(/list)
	if(!islist(context_data))
		return list()

	var/list/data = list(
		"selectionContext" = context_data["selection_context"],
		"forced" = !!context_data["force"],
		"scheduled" = !!context_data["scheduled"],
	)

	var/datum/storyteller/need_report/report = context_data["need_report"]
	if(istype(report))
		data["needReport"] = list(
			"id" = report.id,
			"title" = report.title,
			"departmentId" = report.department_id,
			"severity" = report.severity,
			"priority" = report.priority,
			"summary" = report.summary,
		)

	var/mob/living/carbon/human/latejoiner = context_data["latejoiner"]
	if(istype(latejoiner))
		data["latejoinTarget"] = key_name(latejoiner)

	var/mob/admin_user = context_data["admin_user"]
	if(admin_user)
		data["adminUser"] = key_name(admin_user)

	return data

/datum/controller/subsystem/storyteller/proc/get_storyteller_action_trace_data(datum/storyteller/action/action, effective_weight = null)
	RETURN_TYPE(/list)
	if(!istype(action))
		return list()

	var/list/data = list(
		"id" = action.id,
		"name" = action.name,
		"context" = action.context,
		"polarity" = action.polarity,
		"family" = action.family,
		"stage" = action.stage,
		"cost" = action.cost,
		"baseWeight" = action.weight,
		"effectiveWeight" = isnull(effective_weight) ? action.get_effective_weight(src) : effective_weight,
		"allowInExtended" = action.allow_in_extended,
		"isAntagAction" = action.is_antag_action(),
	)
	if(istype(action, /datum/storyteller/action/dynamic_base))
		var/datum/storyteller/action/dynamic_base/dynamic_action = action
		data["dynamicRulesetType"] = "[dynamic_action.dynamic_ruleset_type]"
	return data

/datum/controller/subsystem/storyteller/proc/get_storyteller_weight_map_trace_data(list/weighted_actions)
	RETURN_TYPE(/list)
	var/list/data = list()
	if(!islist(weighted_actions))
		return data

	for(var/datum/storyteller/action/action as anything in weighted_actions)
		if(!istype(action))
			continue
		data += list(list(
			"id" = action.id,
			"name" = action.name,
			"context" = action.context,
			"polarity" = action.polarity,
			"family" = action.family,
			"stage" = action.stage,
			"cost" = action.cost,
			"weight" = weighted_actions[action],
		))
	return data

/datum/controller/subsystem/storyteller/proc/get_storyteller_blocked_reason_trace_data(action_context, action_polarity, list/context_data)
	RETURN_TYPE(/list)
	var/list/blocked_reason_counts = list()
	if(!catalog || !current_snapshot)
		return blocked_reason_counts

	for(var/datum/storyteller/action/action as anything in catalog.get_actions_for_context(action_context, action_polarity))
		if(is_action_admin_suppressed(action.id))
			blocked_reason_counts["Admin suppressed"] = (blocked_reason_counts["Admin suppressed"] || 0) + 1
			continue

		var/list/availability = action.get_availability(src, current_snapshot, context_data)
		var/effective_weight = action.get_effective_weight(src)
		if(availability["available"] && effective_weight > 0)
			continue

		var/reason = availability["reason"]
		if(!reason && effective_weight <= 0)
			reason = "Zero effective weight"
		if(!reason)
			reason = "Unavailable"
		blocked_reason_counts[reason] = (blocked_reason_counts[reason] || 0) + 1

	return blocked_reason_counts

/datum/controller/subsystem/storyteller/proc/build_storyteller_trace_data(list/extra_data, datum/storyteller/state_snapshot/snapshot = current_snapshot, list/context_data = null)
	RETURN_TYPE(/list)
	var/list/data = list(
		"roundMode" = round_mode,
		"profile" = profile?.name,
		"profileType" = "[profile_type]",
		"phase" = current_phase_max,
		"phaseCap" = phase_cap,
		"automaticPhaseFloor" = automatic_phase_floor,
		"manualPhaseOverride" = manual_phase_override,
		"manualProfileOverride" = manual_profile_override,
		"threatBudget" = threat_budget,
		"aidBudget" = aid_budget,
		"roundElapsedDs" = get_round_elapsed(),
		"positiveLockRemainingDs" = max(positive_fatigue_locked_until - world.time, 0),
		"negativeLockRemainingDs" = max(negative_fatigue_locked_until - world.time, 0),
		"positiveWindowRemainingDs" = max(positive_channel_ready_at - world.time, 0),
		"negativeWindowRemainingDs" = max(negative_channel_ready_at - world.time, 0),
		"latejoinLockRemainingDs" = max(latejoin_roundstart_locked_until - world.time, 0),
		"securityReadiness" = get_security_readiness_score(snapshot),
		"distressStageDrop" = get_distress_stage_drop(snapshot),
		"snapshot" = get_storyteller_snapshot_trace_data(snapshot),
	)

	var/list/context_trace = get_storyteller_context_trace_data(context_data)
	if(length(context_trace))
		data["context"] = context_trace

	if(islist(extra_data))
		data |= extra_data

	return data

/datum/controller/subsystem/storyteller/proc/build_dynamic_ruleset_trace_data(datum/dynamic_ruleset/ruleset, population_size, candidate_count, list/context_data, list/selected_minds = null)
	RETURN_TYPE(/list)
	var/list/data = build_storyteller_trace_data(list(), current_snapshot, context_data)
	if(!istype(ruleset))
		return data

	data["ruleset"] = list(
		"name" = ruleset.name,
		"configTag" = ruleset.config_tag,
		"prefFlag" = ruleset.pref_flag,
		"jobbanFlag" = ruleset.jobban_flag,
		"minimumPopulation" = islist(ruleset.min_pop) ? resolve_dynamic_tier_value(ruleset.min_pop, SSdynamic.current_tier?.tier) : ruleset.min_pop,
		"candidateCount" = candidate_count,
		"populationSize" = population_size,
		"selectedMinds" = format_selected_minds(selected_minds),
		"logData" = ruleset.log_data,
	)
	return data

/datum/controller/subsystem/storyteller/proc/log_storyteller_trace(message, list/data)
	if(!message)
		return
	log_storyteller(message, data)

/datum/controller/subsystem/storyteller/proc/record_decision(message, list/data = null)
	if(!message)
		return
	decision_history += list(list(
		"time" = station_time_timestamp("hh:mm:ss"),
		"message" = message,
	))
	while(length(decision_history) > STORYTELLER_DECISION_HISTORY_MAX)
		decision_history.Cut(1, 2)
	log_storyteller_trace(message, data)
	log_game("Storyteller: [message]")
	if(CONFIG_GET(flag/storyteller_debug_logging))
		message_admins("Storyteller: [message]")

/datum/controller/subsystem/storyteller/proc/record_action_execution(datum/storyteller/action/action, details, spend_budget = TRUE, list/extra_data = null)
	if(!istype(action))
		return

	var/reserved_cost = consume_reserved_action_budget(action.id)

	if(spend_budget && action.context != STORYTELLER_CONTEXT_ROUNDSTART)
		if(action.polarity == STORYTELLER_POLARITY_NEGATIVE)
			threat_budget = max(0, threat_budget - max(action.cost - reserved_cost, 0))
		else if(action.polarity == STORYTELLER_POLARITY_POSITIVE)
			aid_budget = max(0, aid_budget - action.cost)

	if(action.polarity == STORYTELLER_POLARITY_NEGATIVE)
		negative_fatigue_locked_until = world.time + profile.fatigue_lock
		if(action.context != STORYTELLER_CONTEXT_ROUNDSTART)
			last_negative_action_at = world.time
			last_negative_action_cost = action.cost
			last_negative_action_impact = get_action_impact(action)
			negative_channel_ready_at = world.time + calculate_negative_interval(action)
	else if(action.polarity == STORYTELLER_POLARITY_POSITIVE)
		positive_fatigue_locked_until = world.time + profile.fatigue_lock
		if(action.context != STORYTELLER_CONTEXT_ROUNDSTART)
			last_positive_action_at = world.time
			last_positive_action_cost = action.cost
			last_positive_action_impact = get_action_impact(action)
			positive_channel_ready_at = world.time + calculate_positive_interval(action)
	if(action.family)
		family_cooldowns[action.family] = world.time + profile.family_cooldown

	var/message = "Executed [action.name]"
	if(details)
		message += " ([details])"
	if(action.context != STORYTELLER_CONTEXT_ROUNDSTART)
		switch(action.polarity)
			if(STORYTELLER_POLARITY_NEGATIVE)
				message += "; next negative window in [DisplayTimeText(max(negative_channel_ready_at - world.time, 0), round_seconds_to = 1)]"
			if(STORYTELLER_POLARITY_POSITIVE)
				message += "; next positive window in [DisplayTimeText(max(positive_channel_ready_at - world.time, 0), round_seconds_to = 1)]"

	var/list/log_data = build_storyteller_trace_data(list(
		"action" = get_storyteller_action_trace_data(action),
		"reservedCost" = reserved_cost,
		"spendBudget" = spend_budget,
		"details" = details,
	), current_snapshot)
	if(islist(extra_data))
		log_data |= extra_data
	record_decision(message, log_data)

/datum/controller/subsystem/storyteller/proc/format_selected_minds(list/selected_minds)
	if(!length(selected_minds))
		return "none"

	var/list/names = list()
	for(var/datum/mind/selected_mind as anything in selected_minds)
		names += key_name(selected_mind.current || selected_mind)
	return english_list(names)

/datum/controller/subsystem/storyteller/proc/track_dynamic_ruleset(datum/dynamic_ruleset/ruleset)
	if(!istype(ruleset))
		return
	queued_antag_metadata -= REF(ruleset)
	if(ruleset in SSdynamic.queued_rulesets)
		SSdynamic.unqueue_ruleset(ruleset)
	if(!(ruleset in SSdynamic.executed_rulesets))
		SSdynamic.executed_rulesets += ruleset

/datum/controller/subsystem/storyteller/proc/resolve_dynamic_tier_value(list/values, requested_tier)
	if(!islist(values))
		return values

	if(!isnum(requested_tier))
		requested_tier = STORYTELLER_DYNAMIC_TIER_MAX

	if(isnum(values[requested_tier]))
		return values[requested_tier]

	var/max_tier = STORYTELLER_DYNAMIC_TIER_MAX
	for(var/i in requested_tier to max_tier)
		if(isnum(values[i]))
			return values[i]

	var/min_tier = STORYTELLER_DYNAMIC_TIER_MIN
	for(var/i in requested_tier to min_tier step -1)
		if(isnum(values[i]))
			return values[i]

	return 0

/datum/controller/subsystem/storyteller/proc/select_dynamic_tier_for_roundstart(roundstart_population)
	var/list/dynamic_config = SSdynamic.get_config()
	var/list/tier_weighted = list()
	var/picked_tier = /datum/dynamic_tier/greenshift

	for(var/datum/dynamic_tier/tier_type as anything in subtypesof(/datum/dynamic_tier))
		var/datum/dynamic_tier/tier_datum = new tier_type(dynamic_config)
		if(roundstart_population < tier_datum.min_pop)
			qdel(tier_datum)
			continue

		if(tier_datum.weight > 0)
			tier_weighted[tier_type] = tier_datum.weight
		qdel(tier_datum)

	if(length(tier_weighted))
		picked_tier = pick_weight(tier_weighted)

	SSdynamic.set_tier(picked_tier, roundstart_population)

	if(!SSdynamic.current_tier)
		return

	var/roundstart_spawn = SSdynamic.rulesets_to_spawn["roundstart"]
	var/light_midround_spawn = SSdynamic.rulesets_to_spawn["light_midround"]
	var/heavy_midround_spawn = SSdynamic.rulesets_to_spawn["heavy_midround"]
	var/latejoin_spawn = SSdynamic.rulesets_to_spawn["latejoin"]

	record_decision("Selected storyteller dynamic tier [SSdynamic.current_tier.tier] for [roundstart_population] roundstart candidates.", build_storyteller_trace_data(list(
		"roundstartPopulation" = roundstart_population,
		"selectedTier" = SSdynamic.current_tier.tier,
		"tierWeights" = tier_weighted.Copy(),
		"roundstartRulesetCount" = roundstart_spawn,
		"lightMidroundRulesetCount" = light_midround_spawn,
		"heavyMidroundRulesetCount" = heavy_midround_spawn,
		"latejoinRulesetCount" = latejoin_spawn,
	)))

	log_dynamic("Selected tier: [SSdynamic.current_tier.tier]")
	log_dynamic("- Roundstart population: [roundstart_population]")
	log_dynamic("- Roundstart ruleset count: [roundstart_spawn]")
	log_dynamic("- Light midround ruleset count: [light_midround_spawn]")
	log_dynamic("- Heavy midround ruleset count: [heavy_midround_spawn]")
	log_dynamic("- Latejoin ruleset count: [latejoin_spawn]")
	SSblackbox.record_feedback(
		"associative",
		"dynamic_tier",
		1,
		list(
			"server_name" = CONFIG_GET(string/serversqlname),
			"tier" = SSdynamic.current_tier.tier,
			"player_count" = roundstart_population,
			"roundstart_ruleset_count" = roundstart_spawn,
			"light_midround_ruleset_count" = light_midround_spawn,
			"heavy_midround_ruleset_count" = heavy_midround_spawn,
			"latejoin_ruleset_count" = latejoin_spawn,
		),
	)

/datum/controller/subsystem/storyteller/proc/get_roundstart_action_count(player_count)
	if(player_count < 25)
		return 1
	if(player_count <= 50)
		return 2
	return 3

/datum/controller/subsystem/storyteller/proc/collect_roundstart_antag_candidates()
	RETURN_TYPE(/list)
	var/list/antag_candidates = list()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list - SSjob.unassigned)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind)
			antag_candidates += player

	for(var/mob/dead/new_player/player as anything in SSjob.unassigned)
		var/list/job_data = list()
		var/job_prefs = player.client?.prefs.job_preferences
		for(var/job in job_prefs)
			var/priority = job_prefs[job]
			job_data += "[job]: [SSjob.job_priority_level_to_string(priority)]"
		to_chat(player, span_danger("You were unable to qualify for any roundstart antagonist role this round because your job preferences presented a high chance of all of your selected jobs being unavailable, along with 'return to lobby if job is unavailable' enabled. Increase the number of roles set to medium or low priority to reduce the chances of this happening."))
		log_admin("[player.ckey] failed to qualify for any roundstart antagonist role because their job preferences presented a high chance of all of their selected jobs being unavailable, along with 'return to lobby if job is unavailable' enabled and has [player.client?.prefs?.be_special.len || 0] antag preferences enabled. They will be unable to qualify for any roundstart antagonist role. These are their job preferences - [job_data.Join(" | ")]")
	return antag_candidates

/datum/controller/subsystem/storyteller/proc/select_action(action_context, action_polarity, list/context_data)
	if(!catalog || !current_snapshot)
		return

	var/list/weighted_actions = list()
	var/list/blocked_reason_counts = list()
	for(var/datum/storyteller/action/action as anything in catalog.get_actions_for_context(action_context, action_polarity))
		if(is_action_admin_suppressed(action.id))
			blocked_reason_counts["Admin suppressed"] = (blocked_reason_counts["Admin suppressed"] || 0) + 1
			continue
		var/list/availability = action.get_availability(src, current_snapshot, context_data)
		var/effective_weight = action.get_effective_weight(src)
		if(!availability["available"] || effective_weight <= 0)
			var/reason = availability["reason"]
			if(!reason && effective_weight <= 0)
				reason = "Zero effective weight"
			if(!reason)
				reason = "Unavailable"
			blocked_reason_counts[reason] = (blocked_reason_counts[reason] || 0) + 1
			continue
		weighted_actions[action] = effective_weight

	if(!length(weighted_actions))
		log_storyteller_trace("No eligible storyteller actions were available for [action_polarity] [action_context] selection.", build_storyteller_trace_data(list(
			"actionContext" = action_context,
			"actionPolarity" = action_polarity,
			"eligibleActions" = list(),
			"blockedReasonCounts" = blocked_reason_counts,
		), current_snapshot, context_data))
		return

	var/datum/storyteller/action/picked_action = pick_weight(weighted_actions)
	log_storyteller_trace("Selected storyteller action [picked_action?.name || "unknown"] for [action_polarity] [action_context].", build_storyteller_trace_data(list(
		"actionContext" = action_context,
		"actionPolarity" = action_polarity,
		"eligibleActions" = get_storyteller_weight_map_trace_data(weighted_actions),
		"blockedReasonCounts" = blocked_reason_counts,
		"selectedAction" = get_storyteller_action_trace_data(picked_action, weighted_actions[picked_action]),
	), current_snapshot, context_data))
	return picked_action

/datum/controller/subsystem/storyteller/proc/get_negative_candidate_pool()
	RETURN_TYPE(/list)
	var/list/weighted_actions = list()
	var/list/context_data = list("selection_context" = STORYTELLER_CONTEXT_MIDROUND)
	for(var/datum/storyteller/action/action as anything in catalog.get_actions_for_context(STORYTELLER_CONTEXT_MIDROUND, STORYTELLER_POLARITY_NEGATIVE))
		if(is_action_admin_suppressed(action.id))
			continue
		var/list/availability = action.get_availability(src, current_snapshot, context_data)
		var/effective_weight = action.get_effective_weight(src)
		if(!availability["available"] || effective_weight <= 0)
			continue
		weighted_actions[action] = effective_weight
	return list(
		"context_data" = context_data,
		"weighted_actions" = weighted_actions,
	)

/datum/controller/subsystem/storyteller/proc/get_midround_candidate_pool(action_polarity)
	RETURN_TYPE(/list)
	switch(action_polarity)
		if(STORYTELLER_POLARITY_POSITIVE)
			return get_positive_candidate_pool()
		if(STORYTELLER_POLARITY_NEGATIVE)
			return get_negative_candidate_pool()
	return null

/datum/controller/subsystem/storyteller/proc/get_positive_candidate_pool()
	RETURN_TYPE(/list)
	var/list/attempted_ids = list()
	while(TRUE)
		var/datum/storyteller/need_report/report = get_highest_priority_need_report(attempted_ids)
		if(!istype(report))
			break

		var/list/context_data = list(
			"selection_context" = STORYTELLER_CONTEXT_MIDROUND,
			"need_report" = report,
		)
		var/list/weighted_actions = list()
		for(var/datum/storyteller/action/action as anything in catalog.get_actions_for_context(STORYTELLER_CONTEXT_MIDROUND, STORYTELLER_POLARITY_POSITIVE))
			if(is_action_admin_suppressed(action.id))
				continue
			if(length(action.supported_need_ids) && !action.supports_need(report.id))
				continue
			var/list/availability = action.get_availability(src, current_snapshot, context_data)
			var/effective_weight = action.get_effective_weight(src)
			if(!availability["available"] || effective_weight <= 0)
				continue
			weighted_actions[action] = effective_weight + (length(action.supported_need_ids) ? max(1, round(report.priority / 10)) : 0)

		if(length(weighted_actions))
			return list(
				"context_data" = context_data,
				"weighted_actions" = weighted_actions,
				"need_report" = report,
			)

		attempted_ids += report.id

	var/list/fallback_context_data = list("selection_context" = STORYTELLER_CONTEXT_MIDROUND)
	var/list/fallback_weighted_actions = list()
	for(var/datum/storyteller/action/action as anything in catalog.get_actions_for_context(STORYTELLER_CONTEXT_MIDROUND, STORYTELLER_POLARITY_POSITIVE))
		if(is_action_admin_suppressed(action.id))
			continue
		var/list/availability = action.get_availability(src, current_snapshot, fallback_context_data)
		var/effective_weight = action.get_effective_weight(src)
		if(!availability["available"] || effective_weight <= 0)
			continue
		fallback_weighted_actions[action] = effective_weight

	if(!length(fallback_weighted_actions))
		return null
	return list(
		"context_data" = fallback_context_data,
		"weighted_actions" = fallback_weighted_actions,
	)

/datum/controller/subsystem/storyteller/proc/prepare_roundstart_actions()
	prepared_roundstart_entries.Cut()

	if(!is_enabled())
		return TRUE

	if(!mode_vote_finalized)
		record_decision("Storyteller mode vote did not finalize before setup; using [capitalize(round_mode)] mode.")
		mode_vote_finalized = TRUE
		if(!round_mode_history_recorded)
			record_round_mode_history(round_mode)
			round_mode_history_recorded = TRUE

	refresh_snapshot(TRUE)
	update_scores()
	evaluate_needs()

	var/list/dynamic_config = SSdynamic.get_config()
	SEND_SIGNAL(SSdynamic, COMSIG_DYNAMIC_PRE_ROUNDSTART, dynamic_config)
	SSjob.divide_occupations(pure = TRUE, allow_all = TRUE)

	var/list/antag_candidates = collect_roundstart_antag_candidates()
	var/num_real_players = length(antag_candidates)
	if(!profile_selected)
		select_profile_for_population(num_real_players)
		update_scores()
		evaluate_needs()

	if(!SSdynamic.current_tier)
		select_dynamic_tier_for_roundstart(num_real_players)

	var/list/context_data = list(
		"selection_context" = STORYTELLER_CONTEXT_ROUNDSTART,
		"ignore_budget" = TRUE,
		"ignore_cooldowns" = TRUE,
	)

	for(var/datum/dynamic_ruleset/roundstart/forced_ruleset in SSdynamic.queued_rulesets)
		if(!forced_ruleset.prepare_execution(num_real_players, antag_candidates))
			record_decision("Queued roundstart [forced_ruleset.config_tag] preparation failed: [forced_ruleset.log_data || "unknown reason"]", build_dynamic_ruleset_trace_data(forced_ruleset, num_real_players, length(antag_candidates), context_data, forced_ruleset.selected_minds))
			SSdynamic.unqueue_ruleset(forced_ruleset)
			qdel(forced_ruleset)
			continue
		prepared_roundstart_entries += list(list(
			"action" = null,
			"ruleset" = forced_ruleset,
		))

	if(!allow_roundstart_hostiles())
		SSjob.reset_occupations()
		SSdynamic.base_rulesets_to_spawn["roundstart"] = length(prepared_roundstart_entries)
		SSdynamic.rulesets_to_spawn["roundstart"] = 0
		record_decision("Skipping natural storyteller roundstart hostiles in [capitalize(round_mode)] mode.")
		return TRUE

	var/to_prepare = get_roundstart_action_count(num_real_players)
	var/list/roundstart_pool = catalog.get_actions_for_context(STORYTELLER_CONTEXT_ROUNDSTART, STORYTELLER_POLARITY_NEGATIVE)
	roundstart_pool = roundstart_pool.Copy()
	while(to_prepare > 0 && length(roundstart_pool))
		var/list/weighted_actions = list()
		for(var/datum/storyteller/action/dynamic_roundstart/action as anything in roundstart_pool)
			var/list/availability = action.get_availability(src, current_snapshot, context_data)
			var/effective_weight = action.get_effective_weight(src)
			if(!availability["available"] || effective_weight <= 0)
				continue
			weighted_actions[action] = effective_weight

		if(!length(weighted_actions))
			break

		var/datum/storyteller/action/dynamic_roundstart/picked_action = pick_weight(weighted_actions)
		roundstart_pool -= picked_action
		if(!istype(picked_action))
			continue

		var/datum/dynamic_ruleset/roundstart/prepared_ruleset = picked_action.prepare_roundstart_action(src, num_real_players, antag_candidates)
		if(!istype(prepared_ruleset))
			continue

		prepared_roundstart_entries += list(list(
			"action" = picked_action,
			"ruleset" = prepared_ruleset,
		))
		to_prepare--
		record_decision("Prepared roundstart storyteller action [picked_action.name].", build_storyteller_trace_data(list(
			"roundstartCandidateCount" = num_real_players,
			"eligibleActions" = get_storyteller_weight_map_trace_data(weighted_actions),
			"selectedAction" = get_storyteller_action_trace_data(picked_action, weighted_actions[picked_action]),
		), current_snapshot, context_data))

	SSjob.reset_occupations()

	if(SSdynamic.current_tier)
		COOLDOWN_START(SSdynamic, light_ruleset_start, SSdynamic.current_tier.ruleset_type_settings["light_midround"]["time_threshold"])
		COOLDOWN_START(SSdynamic, heavy_ruleset_start, SSdynamic.current_tier.ruleset_type_settings["heavy_midround"]["time_threshold"])
		COOLDOWN_START(SSdynamic, latejoin_ruleset_start, SSdynamic.current_tier.ruleset_type_settings["latejoin"]["time_threshold"])

	SSdynamic.base_rulesets_to_spawn["roundstart"] = length(prepared_roundstart_entries)
	SSdynamic.rulesets_to_spawn["roundstart"] = 0
	return TRUE

/datum/controller/subsystem/storyteller/proc/execute_roundstart_actions()
	if(!length(prepared_roundstart_entries))
		return

	for(var/list/entry as anything in prepared_roundstart_entries)
		var/datum/storyteller/action/dynamic_roundstart/action = entry["action"]
		var/datum/dynamic_ruleset/roundstart/ruleset = entry["ruleset"]
		if(!istype(ruleset))
			continue
		if(istype(action))
			action.execute_prepared_action(src, ruleset)
			continue
		ruleset.execute()
		track_dynamic_ruleset(ruleset)
		record_decision("Executed queued roundstart ruleset [ruleset.config_tag].")

	prepared_roundstart_entries.Cut()
	snapshot_dirty = TRUE

/datum/controller/subsystem/storyteller/proc/handle_latejoin(mob/living/carbon/human/latejoiner)
	if(!is_enabled() || !istype(latejoiner) || paused)
		return FALSE
	if(round_mode != STORYTELLER_ROUND_MODE_DYNAMIC)
		return FALSE

	ensure_round_cadence()
	refresh_snapshot()
	update_scores()
	evaluate_needs()

	var/list/context_data = list(
		"selection_context" = STORYTELLER_CONTEXT_LATEJOIN,
		"latejoiner" = latejoiner,
	)
	var/datum/storyteller/action/action = select_action(STORYTELLER_CONTEXT_LATEJOIN, STORYTELLER_POLARITY_NEGATIVE, context_data)
	if(!istype(action))
		return FALSE
	return action.execute(src, current_snapshot, context_data)

/datum/controller/subsystem/storyteller/proc/try_run_positive_action()
	if(try_run_interim_channel_action(STORYTELLER_POLARITY_POSITIVE))
		return TRUE
	if(!is_channel_ready(STORYTELLER_POLARITY_POSITIVE))
		return FALSE
	if(queued_positive_action_id)
		var/datum/storyteller/action/queued_action = catalog.get_action(queued_positive_action_id)
		queued_positive_action_id = null
		if(istype(queued_action))
			var/list/forced_context = build_forced_context_data(queued_action, null)
			if(queued_action.force_execute(src, current_snapshot, forced_context))
				record_decision("Executed queued storyteller action [queued_action.name] in the positive channel.")
				return TRUE
			record_decision("Queued storyteller action [queued_action.name] failed to execute in the positive channel.")
	var/list/selected = select_positive_action()
	if(!islist(selected))
		return FALSE

	var/datum/storyteller/action/action = selected["action"]
	var/list/context_data = selected["context_data"]
	if(!istype(action) || !islist(context_data))
		return FALSE
	return schedule_storyteller_action(action, context_data)

/datum/controller/subsystem/storyteller/proc/try_run_negative_action()
	if(try_run_interim_channel_action(STORYTELLER_POLARITY_NEGATIVE))
		return TRUE
	if(!allow_negative_midround())
		return FALSE
	if(!is_channel_ready(STORYTELLER_POLARITY_NEGATIVE))
		return FALSE
	if(queued_negative_action_id)
		var/datum/storyteller/action/queued_action = catalog.get_action(queued_negative_action_id)
		queued_negative_action_id = null
		if(istype(queued_action))
			var/list/forced_context = build_forced_context_data(queued_action, null)
			if(queued_action.force_execute(src, current_snapshot, forced_context))
				record_decision("Executed queued storyteller action [queued_action.name] in the negative channel.")
				return TRUE
			record_decision("Queued storyteller action [queued_action.name] failed to execute in the negative channel.")

	var/list/context_data = list("selection_context" = STORYTELLER_CONTEXT_MIDROUND)
	var/datum/storyteller/action/action = select_action(STORYTELLER_CONTEXT_MIDROUND, STORYTELLER_POLARITY_NEGATIVE, context_data)
	if(!istype(action))
		return FALSE
	return schedule_storyteller_action(action, context_data)

/datum/controller/subsystem/storyteller/proc/get_channel_ready_at(action_polarity)
	switch(action_polarity)
		if(STORYTELLER_POLARITY_POSITIVE)
			return positive_channel_ready_at
		if(STORYTELLER_POLARITY_NEGATIVE)
			return negative_channel_ready_at
	return 0

/datum/controller/subsystem/storyteller/proc/get_channel_fatigue_unlock_at(action_polarity)
	switch(action_polarity)
		if(STORYTELLER_POLARITY_POSITIVE)
			return positive_fatigue_locked_until
		if(STORYTELLER_POLARITY_NEGATIVE)
			return negative_fatigue_locked_until
	return 0

/datum/controller/subsystem/storyteller/proc/get_channel_last_action_at(action_polarity)
	switch(action_polarity)
		if(STORYTELLER_POLARITY_POSITIVE)
			return last_positive_action_at
		if(STORYTELLER_POLARITY_NEGATIVE)
			return last_negative_action_at
	return 0

/datum/controller/subsystem/storyteller/proc/get_channel_interim_tick_count(action_polarity)
	var/fatigue_unlock_at = get_channel_fatigue_unlock_at(action_polarity)
	var/channel_ready_at = get_channel_ready_at(action_polarity)
	var/window_duration = max(channel_ready_at - fatigue_unlock_at, 0)
	if(window_duration <= 0)
		return 0
	return max(1, CEILING(window_duration / max(wait, 1), 1))

/datum/controller/subsystem/storyteller/proc/can_attempt_interim_channel_roll(action_polarity)
	if(!SSticker.IsRoundInProgress())
		return FALSE
	if(action_polarity == STORYTELLER_POLARITY_NEGATIVE && !allow_negative_midround())
		return FALSE
	if(has_pending_storyteller_scheduled_action(action_polarity))
		return FALSE
	if(is_channel_ready(action_polarity))
		return FALSE
	if(is_polarity_fatigue_locked(action_polarity))
		return FALSE
	if(!get_channel_last_action_at(action_polarity))
		return FALSE
	var/channel_ready_at = get_channel_ready_at(action_polarity)
	var/fatigue_unlock_at = get_channel_fatigue_unlock_at(action_polarity)
	if(channel_ready_at <= 0 || channel_ready_at <= fatigue_unlock_at)
		return FALSE
	if(world.time <= fatigue_unlock_at || world.time >= channel_ready_at)
		return FALSE
	if(action_polarity == STORYTELLER_POLARITY_POSITIVE && queued_positive_action_id)
		return FALSE
	if(action_polarity == STORYTELLER_POLARITY_NEGATIVE && queued_negative_action_id)
		return FALSE
	return TRUE

/datum/controller/subsystem/storyteller/proc/try_run_interim_channel_action(action_polarity)
	if(!can_attempt_interim_channel_roll(action_polarity))
		return FALSE

	var/list/candidate_pool = get_midround_candidate_pool(action_polarity)
	if(!islist(candidate_pool))
		return FALSE

	var/list/weighted_actions = candidate_pool["weighted_actions"]
	var/list/context_data = candidate_pool["context_data"]
	if(!islist(weighted_actions) || !length(weighted_actions) || !islist(context_data))
		return FALSE

	var/list/chance_map = get_action_chance_map(weighted_actions)
	var/action_count = length(chance_map)
	var/interim_tick_count = get_channel_interim_tick_count(action_polarity)
	if(action_count <= 0 || interim_tick_count <= 0)
		return FALSE

	var/list/interim_weighted_actions = list()
	for(var/datum/storyteller/action/action as anything in weighted_actions)
		var/current_chance = chance_map[action] || 0
		if(current_chance <= 0)
			continue
		var/tick_chance = clamp(current_chance / (action_count * interim_tick_count), 0, 100)
		if(prob(tick_chance))
			interim_weighted_actions[action] = weighted_actions[action]

	if(!length(interim_weighted_actions))
		return FALSE

	var/datum/storyteller/action/picked_action = pick_weight(interim_weighted_actions)
	if(!istype(picked_action))
		return FALSE
	return schedule_storyteller_action(picked_action, context_data)

/datum/controller/subsystem/storyteller/proc/select_positive_action()
	RETURN_TYPE(/list)
	var/list/candidate_pool = get_midround_candidate_pool(STORYTELLER_POLARITY_POSITIVE)
	if(!islist(candidate_pool))
		log_storyteller_trace("No eligible storyteller actions were available for positive midround selection.", build_storyteller_trace_data(list(
			"actionContext" = STORYTELLER_CONTEXT_MIDROUND,
			"actionPolarity" = STORYTELLER_POLARITY_POSITIVE,
		)))
		return null
	var/list/weighted_actions = candidate_pool["weighted_actions"]
	var/list/context_data = candidate_pool["context_data"]
	var/datum/storyteller/action/fallback_action = pick_weight(weighted_actions)
	if(!istype(fallback_action))
		log_storyteller_trace("Positive storyteller midround selection failed to pick a weighted action.", build_storyteller_trace_data(list(
			"actionContext" = STORYTELLER_CONTEXT_MIDROUND,
			"actionPolarity" = STORYTELLER_POLARITY_POSITIVE,
			"eligibleActions" = get_storyteller_weight_map_trace_data(weighted_actions),
		), current_snapshot, context_data))
		return null
	log_storyteller_trace("Selected storyteller action [fallback_action.name] for positive midround.", build_storyteller_trace_data(list(
		"actionContext" = STORYTELLER_CONTEXT_MIDROUND,
		"actionPolarity" = STORYTELLER_POLARITY_POSITIVE,
		"eligibleActions" = get_storyteller_weight_map_trace_data(weighted_actions),
		"selectedAction" = get_storyteller_action_trace_data(fallback_action, weighted_actions[fallback_action]),
	), current_snapshot, context_data))
	return list(
		"action" = fallback_action,
		"context_data" = context_data,
	)

/datum/controller/subsystem/storyteller/proc/get_highest_priority_need_report(list/excluded_need_ids)
	var/datum/storyteller/need_report/best_report
	var/best_priority = -1
	for(var/datum/storyteller/need_report/report as anything in current_need_reports)
		if(report.id in excluded_need_ids)
			continue
		if(report.priority <= best_priority)
			continue
		best_priority = report.priority
		best_report = report
	return best_report

/datum/controller/subsystem/storyteller/proc/get_best_matching_need_report(datum/storyteller/action/action)
	if(!istype(action) || !length(action.supported_need_ids))
		return null
	var/datum/storyteller/need_report/best_report
	var/best_priority = -1
	for(var/datum/storyteller/need_report/report as anything in current_need_reports)
		if(!(report.id in action.supported_need_ids))
			continue
		if(report.priority <= best_priority)
			continue
		best_priority = report.priority
		best_report = report
	return best_report

/datum/controller/subsystem/storyteller/proc/build_force_need_report(need_id)
	RETURN_TYPE(/datum/storyteller/need_report)
	if(!need_id)
		return null
	var/datum/storyteller/need_report/report = new
	report.id = need_id
	report.severity = 50
	report.priority = 50
	report.summary = "Synthesized by an administrator for forced storyteller execution."
	report.details = list(
		"crew_scale" = clamp(round(max(current_snapshot?.alive_crew || 0, 1) / 8), 1, 8),
		"cook_count" = current_snapshot?.cook_count || 0,
		"available_food" = (current_snapshot?.kitchen_food_total || 0) + (current_snapshot?.service_food_total || 0),
		"expected_food" = max(6, round(max(current_snapshot?.alive_crew || 0, 1) * 0.8)),
		"critical_crew" = current_snapshot?.critical_crew_count || 0,
		"total_materials" = (current_snapshot?.ore_silo_material_total || 0) + (current_snapshot?.loose_material_total || 0),
	)
	switch(need_id)
		if(STORYTELLER_NEED_FOOD_SHORTAGE)
			report.title = "Forced Kitchen Relief"
			report.department_id = ACCOUNT_SRV
		if(STORYTELLER_NEED_ENGINEERING_REPAIRS)
			report.title = "Forced Engineering Relief"
			report.department_id = ACCOUNT_ENG
		if(STORYTELLER_NEED_MATERIAL_SHORTAGE)
			report.title = "Forced Cargo Relief"
			report.department_id = ACCOUNT_CAR
		if(STORYTELLER_NEED_MEDICAL_SURGE)
			report.title = "Forced Medical Relief"
			report.department_id = ACCOUNT_MED
		if(STORYTELLER_NEED_SECURITY_STRAIN)
			report.title = "Forced Security Relief"
			report.department_id = ACCOUNT_SEC
		if(STORYTELLER_NEED_SCIENCE_SHORTAGE)
			report.title = "Forced Science Relief"
			report.department_id = ACCOUNT_SCI
		if(STORYTELLER_NEED_JANITORIAL_OVERLOAD)
			report.title = "Forced Custodial Relief"
			report.department_id = ACCOUNT_SRV
		else
			report.title = "Forced Storyteller Need"
			report.department_id = ACCOUNT_CIV
	return report

/datum/controller/subsystem/storyteller/proc/build_forced_context_data(datum/storyteller/action/action, mob/user)
	RETURN_TYPE(/list)
	var/list/context_data = list(
		"selection_context" = action.context,
		"ignore_budget" = TRUE,
		"ignore_cooldowns" = TRUE,
		"force" = TRUE,
		"admin_user" = user,
	)
	if(length(action.supported_need_ids))
		var/datum/storyteller/need_report/report = get_best_matching_need_report(action)
		if(!istype(report))
			for(var/need_id in action.supported_need_ids)
				report = build_force_need_report(need_id)
				if(istype(report))
					break
		if(istype(report))
			context_data["need_report"] = report
	return context_data

/datum/controller/subsystem/storyteller/proc/get_action_discard_duration(datum/storyteller/action/action)
	if(!istype(action))
		return 5 MINUTES
	switch(action.context)
		if(STORYTELLER_CONTEXT_ROUNDSTART)
			return 15 MINUTES
		if(STORYTELLER_CONTEXT_LATEJOIN)
			return 10 MINUTES
		if(STORYTELLER_CONTEXT_MIDROUND)
			if(action.polarity == STORYTELLER_POLARITY_POSITIVE)
				return max(5 MINUTES, positive_channel_ready_at - world.time)
			return max(5 MINUTES, negative_channel_ready_at - world.time)
	return 5 MINUTES

/datum/controller/subsystem/storyteller/proc/discard_action(action_id, mob/user)
	var/datum/storyteller/action/action = catalog.get_action(action_id)
	if(!istype(action))
		return FALSE
	if(action.is_antag_action())
		return toggle_action_discarded(action_id, user)
	if(is_action_admin_suppressed(action.id))
		action_admin_cooldowns -= action.id
		record_decision("[key_name(user)] restored storyteller action [action.name] to the current rotation.")
		return TRUE
	action_admin_cooldowns[action.id] = world.time + get_action_discard_duration(action)
	record_decision("[key_name(user)] discarded storyteller action [action.name] for the current rotation.")
	return TRUE

/datum/controller/subsystem/storyteller/proc/queue_dynamic_ruleset_action(datum/storyteller/action/dynamic_base/action, mob/user, bypass_preference_checks = FALSE)
	if(!istype(action) || !action.dynamic_ruleset_type)
		return FALSE
	var/previous_length = length(SSdynamic.queued_rulesets)
	SSdynamic.queue_ruleset(action.dynamic_ruleset_type)
	if(length(SSdynamic.queued_rulesets) <= previous_length)
		return FALSE
	var/datum/dynamic_ruleset/ruleset = SSdynamic.queued_rulesets[length(SSdynamic.queued_rulesets)]
	if(!istype(ruleset))
		return TRUE
	if(user || bypass_preference_checks)
		ruleset.bypass_preference_checks = TRUE
	var/reserved_cost = 0
	if(action.polarity == STORYTELLER_POLARITY_NEGATIVE && action.context != STORYTELLER_CONTEXT_ROUNDSTART)
		reserved_cost = min(threat_budget, action.cost)
		threat_budget = max(0, threat_budget - reserved_cost)
	queued_antag_metadata[REF(ruleset)] = list(
		"actionId" = action.id,
		"name" = action.name,
		"context" = action.context,
		"prefFlag" = ruleset.pref_flag || "",
		"reservedCost" = reserved_cost,
		"sourceName" = user ? key_name(user) : null,
		"storytellerGenerated" = !user,
	)
	return TRUE

/datum/controller/subsystem/storyteller/proc/queue_action_for_next(action_id, mob/user)
	var/datum/storyteller/action/action = catalog.get_action(action_id)
	if(!istype(action))
		return FALSE
	if(action.context == STORYTELLER_CONTEXT_MIDROUND)
		if(action.polarity == STORYTELLER_POLARITY_NEGATIVE && queued_negative_action_id && queued_negative_action_id != action.id)
			var/datum/storyteller/action/previous_negative = catalog.get_action(queued_negative_action_id)
			if(istype(previous_negative) && previous_negative.is_antag_action())
				refund_reserved_action_budget(previous_negative.id)
		if(action.polarity == STORYTELLER_POLARITY_POSITIVE)
			queued_positive_action_id = action.id
		else
			queued_negative_action_id = action.id
			if(action.is_antag_action() && !get_reserved_action_budget(action.id))
				reserved_action_budgets[action.id] = min(threat_budget, action.cost)
				threat_budget = max(0, threat_budget - reserved_action_budgets[action.id])
		record_decision("[key_name(user)] queued storyteller action [action.name] for the next [action.polarity] window.")
		return TRUE
	if(istype(action, /datum/storyteller/action/dynamic_roundstart) || istype(action, /datum/storyteller/action/dynamic_latejoin))
		if(!action.force_execute(src, current_snapshot, build_forced_context_data(action, user)))
			record_decision("[key_name(user)] failed to queue storyteller action [action.name].")
			return FALSE
		return TRUE
	record_decision("[key_name(user)] cannot queue storyteller action [action.name] for the next pulse.")
	return FALSE

/datum/controller/subsystem/storyteller/proc/cancel_queued_antag(queue_id, mob/user)
	if(!queue_id)
		return FALSE
	if(queued_negative_action_id == queue_id)
		var/datum/storyteller/action/queued_action = catalog.get_action(queue_id)
		if(!istype(queued_action) || !queued_action.is_antag_action())
			return FALSE
		queued_negative_action_id = null
		var/refund = refund_reserved_action_budget(queued_action.id)
		record_decision("[key_name(user)] canceled queued storyteller antagonist [queued_action.name][refund > 0 ? " and refunded [refund] threat" : ""].")
		return TRUE

	var/scheduled_index = get_scheduled_action_queue_index(queue_id)
	if(scheduled_index > 0)
		var/list/entry = scheduled_action_queue[scheduled_index]
		var/datum/storyteller/action/scheduled_action = catalog.get_action(entry["actionId"])
		if(!istype(scheduled_action) || !scheduled_action.is_antag_action())
			return FALSE
		scheduled_action_queue.Cut(scheduled_index, scheduled_index + 1)
		record_decision("[key_name(user)] canceled queued storyteller antagonist [scheduled_action.name].")
		return TRUE

	for(var/datum/dynamic_ruleset/ruleset as anything in SSdynamic.queued_rulesets)
		if(REF(ruleset) != queue_id)
			continue
		var/list/metadata = queued_antag_metadata[queue_id]
		var/ruleset_name = islist(metadata) ? metadata["name"] : null
		ruleset_name ||= ruleset.config_tag || ruleset.name || "[ruleset.type]"
		var/refund_amount = max(0, islist(metadata) ? metadata["reservedCost"] : 0)
		if(refund_amount > 0)
			threat_budget = min(profile?.budget_cap || 100, threat_budget + refund_amount)
		queued_antag_metadata -= queue_id
		SSdynamic.unqueue_ruleset(ruleset)
		qdel(ruleset)
		record_decision("[key_name(user)] canceled queued storyteller antagonist [ruleset_name][refund_amount > 0 ? " and refunded [refund_amount] threat" : ""].")
		return TRUE
	return FALSE

/datum/controller/subsystem/storyteller/proc/grant_department_budget(department_id, amount, reason)
	var/datum/bank_account/department/department_account = SSeconomy.get_dep_account(department_id)
	if(!department_account)
		return FALSE
	return department_account.adjust_money(amount, reason)

/datum/controller/subsystem/storyteller/proc/select_relief_department(datum/storyteller/state_snapshot/snapshot)
	if(!istype(snapshot))
		return

	var/list/weights = list()
	var/list/relief_departments = list(ACCOUNT_MED, ACCOUNT_ENG, ACCOUNT_SCI, ACCOUNT_SEC, ACCOUNT_SRV, ACCOUNT_CAR, ACCOUNT_CMD)
	for(var/department_id in relief_departments)
		var/staffing = snapshot.department_staffing[department_id] || 0
		var/money = snapshot.department_money[department_id] || 0
		var/weight = max(1, 10 - (staffing * 2))
		weight += max(0, round((7000 - money) / 1000))
		weights[department_id] = max(weight, 1)

	if(!length(weights))
		return
	return pick_weight(weights)

/datum/controller/subsystem/storyteller/proc/get_department_drop_target(department_id)
	var/static/list/department_areas = list(
		ACCOUNT_CMD = list(/area/station/command, /area/station/ai),
		ACCOUNT_SEC = list(/area/station/security),
		ACCOUNT_ENG = list(/area/station/engineering),
		ACCOUNT_MED = list(/area/station/medical),
		ACCOUNT_SCI = list(/area/station/science),
		ACCOUNT_CAR = list(/area/station/cargo),
		ACCOUNT_SRV = list(/area/station/service),
		ACCOUNT_CIV = list(/area/station/hallway),
	)

	var/list/area_choices = list()
	for(var/area_type in department_areas[department_id])
		if(area_type in GLOB.the_station_areas)
			area_choices += area_type
		for(var/candidate in subtypesof(area_type))
			if(candidate in GLOB.the_station_areas)
				area_choices += candidate

	if(!length(area_choices))
		return get_common_area_drop_target()
	return get_safe_random_station_turf(area_choices)

/datum/controller/subsystem/storyteller/proc/get_common_area_drop_target()
	var/list/area_choices = list()
	for(var/area_type in list(/area/station/hallway, /area/station/service))
		for(var/candidate in subtypesof(area_type))
			if(candidate in GLOB.the_station_areas)
				area_choices += candidate

	if(!length(area_choices))
		return get_safe_random_station_turf_equal_weight()
	return get_safe_random_station_turf(area_choices)

/datum/controller/subsystem/storyteller/proc/get_need_drop_target(datum/storyteller/need_report/report)
	if(!istype(report))
		return get_common_area_drop_target()
	return get_department_drop_target(report.department_id)

/datum/controller/subsystem/storyteller/proc/get_station_hydroponics_trays()
	RETURN_TYPE(/list)
	var/list/planted_trays = list()
	var/list/empty_trays = list()
	for(var/obj/machinery/hydroponics/tray as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/hydroponics))
		if(QDELETED(tray) || !is_station_level(tray.z))
			continue
		if(tray.myseed && tray.plant_status != HYDROTRAY_PLANT_DEAD)
			planted_trays += tray
			continue
		empty_trays += tray
	if(length(planted_trays))
		planted_trays += empty_trays
		return planted_trays
	return empty_trays

/datum/controller/subsystem/storyteller/proc/get_botany_anomaly_target_count(datum/storyteller/state_snapshot/snapshot, positive = TRUE)
	var/alive_crew = snapshot?.alive_crew || 0
	var/botanist_count = snapshot?.botanist_count || 0
	var/minimum = positive ? 2 : 1
	var/crew_scale = clamp(round(alive_crew / 16), 0, 4)
	var/staff_scale = clamp(botanist_count, 0, 3)
	var/maximum = minimum + crew_scale + staff_scale
	if(positive)
		maximum += 1
	return rand(minimum, max(minimum, maximum))

/datum/controller/subsystem/storyteller/proc/apply_botany_growth_anomaly(modifier, duration, title, description, positive = TRUE, datum/storyteller/state_snapshot/snapshot = null)
	var/list/available_trays = get_station_hydroponics_trays()
	if(!length(available_trays))
		return 0
	var/list/shuffled_trays = shuffle(available_trays)
	var/target_count = min(length(shuffled_trays), get_botany_anomaly_target_count(snapshot || current_snapshot, positive))
	var/applied_count = 0
	for(var/i in 1 to target_count)
		var/obj/machinery/hydroponics/tray = shuffled_trays[i]
		if(!istype(tray))
			continue
		if(!tray.apply_storyteller_growth_anomaly(modifier, duration, title, description, positive))
			continue
		applied_count++
	return applied_count

/datum/controller/subsystem/storyteller/proc/announce_storyteller_notice(message, title = "Storyteller Notice", sound_override = 'sound/announcer/notice/notice2.ogg', color_override = "blue")
	if(!message)
		return
	minor_announce(message, title, sound_override = sound_override, color_override = color_override)

/datum/controller/subsystem/storyteller/proc/get_storyteller_drop_area_name(turf/target)
	if(!isturf(target))
		return "an unknown area"
	var/area/target_area = get_area(target)
	return target_area?.name || "an unknown area"

/datum/controller/subsystem/storyteller/proc/append_storyteller_landing_zone(message, turf/target)
	if(!message)
		return "Landing zone: [get_storyteller_drop_area_name(target)]."
	return "[message] Landing zone: [get_storyteller_drop_area_name(target)]."

/datum/controller/subsystem/storyteller/proc/is_storyteller_material_gain_excluded(datum/material/material)
	if(!istype(material))
		return FALSE
	return istype(material, /datum/material/iron) || istype(material, /datum/material/glass)

/datum/controller/subsystem/storyteller/proc/is_storyteller_material_stack_gain_excluded(obj/item/stack/found_stack)
	if(!istype(found_stack))
		return FALSE
	var/material_type = found_stack.material_type
	return ispath(material_type, /datum/material/iron) || ispath(material_type, /datum/material/glass)

/datum/controller/subsystem/storyteller/proc/is_storyteller_countable_food_item(obj/item/found_item)
	if(!istype(found_item))
		return FALSE
	if(istype(found_item, /obj/item/reagent_containers/cup/bowl))
		return found_item.reagents?.total_volume > 0
	return !!IS_EDIBLE(found_item)

/datum/controller/subsystem/storyteller/proc/is_storyteller_countable_food_storage(atom/storage_loc)
	if(isturf(storage_loc))
		return TRUE
	return istype(storage_loc, /obj/machinery/smartfridge/food)

/datum/controller/subsystem/storyteller/proc/announce_storyteller_alert(message, title = "Storyteller Alert", sound_override = ANNOUNCER_METEORS, color_override = "yellow")
	if(!message)
		return
	priority_announce(message, title, sound_override, color_override = color_override)

/datum/controller/subsystem/storyteller/proc/get_report_detail_number(datum/storyteller/need_report/report, detail_key, fallback = 0)
	if(!istype(report) || !islist(report.details))
		return fallback
	var/value = report.details[detail_key]
	if(isnull(value))
		return fallback
	value = text2num("[value]")
	if(isnull(value))
		return fallback
	return value

/datum/controller/subsystem/storyteller/proc/create_need_relief_contents(datum/storyteller/need_report/report)
	RETURN_TYPE(/list)
	if(!istype(report))
		return list()

	var/atom/movable/delivery
	switch(report.id)
		if(STORYTELLER_NEED_FOOD_SHORTAGE)
			delivery = create_food_relief_contents(report)
		if(STORYTELLER_NEED_ENGINEERING_REPAIRS)
			delivery = create_engineering_relief_contents(report)
		if(STORYTELLER_NEED_MATERIAL_SHORTAGE)
			delivery = create_material_relief_contents(report)
		if(STORYTELLER_NEED_MEDICAL_SURGE)
			delivery = create_medical_relief_contents(report)
		if(STORYTELLER_NEED_SECURITY_STRAIN)
			delivery = create_security_relief_contents(report)
		if(STORYTELLER_NEED_SCIENCE_SHORTAGE)
			delivery = create_science_relief_contents(report)
		if(STORYTELLER_NEED_JANITORIAL_OVERLOAD)
			delivery = create_janitorial_relief_contents(report)

	if(!delivery)
		return list()
	return list(delivery)

/datum/controller/subsystem/storyteller/proc/create_storyteller_crate(crate_type, crate_name, crate_desc)
	RETURN_TYPE(/obj/structure/closet/crate)
	if(!ispath(crate_type, /obj/structure/closet/crate))
		crate_type = /obj/structure/closet/crate
	var/obj/structure/closet/crate/crate = new crate_type(null)
	if(crate_name)
		crate.name = crate_name
	if(crate_desc)
		crate.desc = crate_desc
	return crate

/datum/controller/subsystem/storyteller/proc/create_storyteller_box(atom/storage_loc, box_name, box_desc, icon_state = "box", illustration = "writing", max_slots = 21, max_specific_storage = WEIGHT_CLASS_HUGE)
	RETURN_TYPE(/obj/item/storage/box)
	var/obj/item/storage/box/box = new /obj/item/storage/box(storage_loc)
	box.name = box_name
	box.desc = box_desc
	box.icon_state = icon_state
	box.illustration = illustration
	if(box.atom_storage)
		box.atom_storage.max_slots = max_slots
		box.atom_storage.max_total_storage = WEIGHT_CLASS_GIGANTIC * max_slots
		box.atom_storage.max_specific_storage = max_specific_storage
	box.update_appearance()
	return box

/datum/controller/subsystem/storyteller/proc/add_storyteller_items(atom/storage_loc, list/items_by_count)
	if(!storage_loc || !islist(items_by_count))
		return
	for(var/item_type in items_by_count)
		if(!ispath(item_type, /atom/movable))
			continue
		var/count = items_by_count[item_type]
		if(isnull(count))
			count = 1
		count = max(0, round(text2num("[count]")))
		for(var/i in 1 to count)
			new item_type(storage_loc)

/datum/controller/subsystem/storyteller/proc/add_storyteller_stack(atom/storage_loc, stack_type, amount)
	if(!storage_loc || !ispath(stack_type, /obj/item/stack))
		return
	amount = max(0, round(text2num("[amount]")))
	if(amount <= 0)
		return
	new stack_type(storage_loc, amount)

/datum/controller/subsystem/storyteller/proc/add_storyteller_basic_resource_packs(atom/storage_loc, stack_type, large_packs = 0, small_packs = 0, large_pack_amount = 25, small_pack_amount = 10)
	if(!storage_loc || !ispath(stack_type, /obj/item/stack))
		return
	large_packs = max(0, round(text2num("[large_packs]")))
	small_packs = max(0, round(text2num("[small_packs]")))
	for(var/i in 1 to large_packs)
		add_storyteller_stack(storage_loc, stack_type, large_pack_amount)
	for(var/i in 1 to small_packs)
		add_storyteller_stack(storage_loc, stack_type, small_pack_amount)

/datum/controller/subsystem/storyteller/proc/get_storyteller_pod_transit_delay()
	return rand(1 MINUTES, 3 MINUTES)

/datum/controller/subsystem/storyteller/proc/get_storyteller_contract_pod_transit_delay()
	return rand(20 SECONDS, 40 SECONDS)

/datum/controller/subsystem/storyteller/proc/load_storyteller_pod_contents(obj/structure/closet/supplypod/pod, list/contents)
	if(!istype(pod) || !islist(contents))
		return
	for(var/entry as anything in contents)
		if(ispath(entry, /atom/movable))
			var/amount_to_spawn = contents[entry] || 1
			if(!isnum(amount_to_spawn))
				stack_trace("Storyteller pod content amount for [entry] is not numeric, defaulting to 1")
				amount_to_spawn = 1
			amount_to_spawn = round(amount_to_spawn)
			if(amount_to_spawn <= 0)
				continue
			for(var/item_number in 1 to amount_to_spawn)
				new entry(pod)
			continue
		var/atom/movable/movable_entry = entry
		if(!istype(movable_entry))
			continue
		movable_entry.forceMove(pod)

/datum/controller/subsystem/storyteller/proc/prune_pending_pod_deliveries()
	if(!length(pending_pod_deliveries))
		return
	for(var/index = length(pending_pod_deliveries), index >= 1, index--)
		var/list/entry = pending_pod_deliveries[index]
		if(!islist(entry))
			pending_pod_deliveries.Cut(index, index + 1)
			continue
		var/datum/weakref/landingzone_ref = entry["landingZone"]
		var/obj/effect/pod_landingzone/landingzone = landingzone_ref?.resolve()
		if(istype(landingzone))
			continue
		pending_pod_deliveries.Cut(index, index + 1)

/datum/controller/subsystem/storyteller/proc/track_pending_pod_delivery(obj/effect/pod_landingzone/landingzone, turf/target, department_id = null, delivery_name = null, delivery_summary = null, eta = 0)
	if(!istype(landingzone) || !isturf(target))
		return
	prune_pending_pod_deliveries()
	var/area/target_area = get_area(target)
	var/area_name = target_area?.name || "Unknown Area"
	pending_pod_deliveries += list(list(
		"id" = REF(landingzone),
		"landingZone" = WEAKREF(landingzone),
		"targetTurf" = WEAKREF(target),
		"departmentId" = department_id,
		"deliveryName" = delivery_name || "Storyteller Relief Pod",
		"deliverySummary" = delivery_summary,
		"arrivalAt" = world.time + max(0, eta),
		"areaName" = area_name,
	))
	var/static/mutable_appearance/storyteller_pod_target = mutable_appearance('icons/obj/supplypods_32x32.dmi', "LZ")
	var/pod_name = delivery_name || "Storyteller Relief Pod"
	notify_ghosts("[pod_name] is inbound to [area_name].", source = get_turf(landingzone), header = "Relief Inbound", alert_overlay = storyteller_pod_target)

/datum/controller/subsystem/storyteller/proc/find_pending_pod_delivery(delivery_id)
	RETURN_TYPE(/list)
	if(!delivery_id)
		return null
	prune_pending_pod_deliveries()
	for(var/list/entry as anything in pending_pod_deliveries)
		if(entry["id"] == delivery_id)
			return entry
	return null

/datum/controller/subsystem/storyteller/proc/get_pending_pod_delivery_ui_data(department_id = null)
	RETURN_TYPE(/list)
	prune_pending_pod_deliveries()
	var/list/data = list()
	for(var/list/entry as anything in pending_pod_deliveries)
		if(!isnull(department_id) && entry["departmentId"] != department_id)
			continue
		var/datum/weakref/target_ref = entry["targetTurf"]
		var/turf/target = target_ref?.resolve()
		var/area_name = entry["areaName"] || "Unknown Area"
		if(isturf(target))
			var/area/target_area = get_area(target)
			area_name = target_area?.name || area_name
		data += list(list(
			"id" = entry["id"],
			"name" = entry["deliveryName"],
			"summary" = entry["deliverySummary"],
			"areaName" = area_name,
			"remaining" = max((entry["arrivalAt"] || 0) - world.time, 0),
		))
	return data

/datum/controller/subsystem/storyteller/proc/show_pending_pod_delivery(delivery_id, mob/user)
	if(!delivery_id || !istype(user))
		return FALSE
	var/list/entry = find_pending_pod_delivery(delivery_id)
	if(!islist(entry))
		to_chat(user, span_warning("That storyteller delivery is no longer pending."))
		return FALSE
	var/datum/weakref/target_ref = entry["targetTurf"]
	var/turf/target = target_ref?.resolve()
	if(!isturf(target))
		var/datum/weakref/landingzone_ref = entry["landingZone"]
		var/obj/effect/pod_landingzone/landingzone = landingzone_ref?.resolve()
		target = get_turf(landingzone)
	if(!isturf(target))
		to_chat(user, span_warning("Unable to resolve the storyteller landing zone."))
		return FALSE
	var/obj/effect/client_image_holder/dropoff_location/indicator = new(target, user)
	indicator.alpha = 180
	indicator.regenerate_image()
	QDEL_IN(indicator, 12 SECONDS)
	playsound(user, 'sound/machines/ping.ogg', 25, FALSE)
	var/area/target_area = get_area(target)
	var/time_remaining = max((entry["arrivalAt"] || 0) - world.time, 0)
	var/delivery_name = entry["deliveryName"] || "Storyteller Relief Pod"
	var/area_name = target_area?.name || "Unknown Area"
	to_chat(user, span_notice("[delivery_name] marked at [area_name] ([COORD(target)]). Estimated touchdown in [DisplayTimeText(time_remaining, round_seconds_to = 1)]."))
	return TRUE

/datum/controller/subsystem/storyteller/proc/create_storyteller_component_box(atom/storage_loc, tier)
	RETURN_TYPE(/obj/item/storage/box)
	var/list/component_types
	var/box_name
	var/box_desc
	switch(tier)
		if(1)
			box_name = "tier 1 component box"
			box_desc = "A boxed reserve of baseline machine components."
			component_types = list(
				/obj/item/stock_parts/capacitor,
				/obj/item/stock_parts/scanning_module,
				/obj/item/stock_parts/servo,
				/obj/item/stock_parts/micro_laser,
				/obj/item/stock_parts/matter_bin,
			)
		if(2)
			box_name = "tier 2 component box"
			box_desc = "A boxed reserve of advanced machine components."
			component_types = list(
				/obj/item/stock_parts/capacitor/adv,
				/obj/item/stock_parts/scanning_module/adv,
				/obj/item/stock_parts/servo/nano,
				/obj/item/stock_parts/micro_laser/high,
				/obj/item/stock_parts/matter_bin/adv,
			)
		if(3)
			box_name = "tier 3 component box"
			box_desc = "A boxed reserve of super-capacity machine components."
			component_types = list(
				/obj/item/stock_parts/capacitor/super,
				/obj/item/stock_parts/scanning_module/phasic,
				/obj/item/stock_parts/servo/pico,
				/obj/item/stock_parts/micro_laser/ultra,
				/obj/item/stock_parts/matter_bin/super,
			)
		if(4)
			box_name = "tier 4 component box"
			box_desc = "A boxed reserve of bluespace-grade machine components."
			component_types = list(
				/obj/item/stock_parts/capacitor/quadratic,
				/obj/item/stock_parts/scanning_module/triphasic,
				/obj/item/stock_parts/servo/femto,
				/obj/item/stock_parts/micro_laser/quadultra,
				/obj/item/stock_parts/matter_bin/bluespace,
			)
	if(!length(component_types))
		return
	var/obj/item/storage/box/component_box = create_storyteller_box(storage_loc, box_name, box_desc, "plasticbox", "writing", 28, WEIGHT_CLASS_NORMAL)
	for(var/component_type in component_types)
		for(var/i in 1 to 5)
			new component_type(component_box)
	return component_box

/datum/controller/subsystem/storyteller/proc/create_food_relief_contents(datum/storyteller/need_report/report)
	RETURN_TYPE(/obj/structure/closet/crate)
	var/crew_scale = clamp(round(get_report_detail_number(report, "crew_scale", 1)), 1, 8)
	var/cook_count = round(get_report_detail_number(report, "cook_count", 0))
	var/shortage = max(get_report_detail_number(report, "expected_food", 0) - get_report_detail_number(report, "available_food", 0), 1)
	var/datum/storyteller/state_snapshot/snapshot = current_snapshot
	var/obj/structure/closet/crate/freezer/food/crate = create_storyteller_crate(
		/obj/structure/closet/crate/freezer/food,
		"service relief crate",
		"A refrigerated crate packed with station-side meal and hospitality reserves.",
	)
	var/obj/item/storage/box/meal_box = create_storyteller_box(
		crate,
		cook_count <= 0 ? "ready meal box" : "kitchen resupply box",
		cook_count <= 0 ? "A box of immediately-servable meals for an overworked service wing." : "A box of staples and ingredients for kitchen recovery.",
		"box",
		"writing",
		24,
		WEIGHT_CLASS_NORMAL,
	)
	if(cook_count <= 0)
		add_storyteller_items(meal_box, list(
			/obj/item/storage/box/donkpockets = 1,
			/obj/item/storage/box/donkpockets/donkpocketpizza = max(1, round(shortage / 8)),
			/obj/item/storage/box/foodpack/nt = max(1, round(shortage / 10)),
			/obj/item/storage/box/foodpack/yangyu/sushi = max(1, round(crew_scale / 3)),
			/obj/item/storage/box/foodpack/tizira/roll = max(1, round(crew_scale / 3)),
			/obj/item/pizzabox/margherita = max(1, round(crew_scale / 2)),
			/obj/item/food/bread/plain = max(1, round(crew_scale / 2)),
			/obj/item/food/ready_donk = max(2, crew_scale),
			/obj/item/food/ready_donk/mac_n_cheese = max(1, round(crew_scale / 2)),
			/obj/item/food/ready_donk/donkhiladas = max(1, round(crew_scale / 2)),
			/obj/item/food/ready_donk/nachos_grandes = max(1, round(crew_scale / 3)),
		))
	else
		add_storyteller_items(meal_box, list(
			/obj/item/storage/box/ingredients/italian = 1,
			/obj/item/storage/box/ingredients/american = 1,
			/obj/item/storage/box/ingredients/grains = 1,
			/obj/item/storage/box/ingredients/sweets = max(1, round(crew_scale / 4)),
			/obj/item/storage/fancy/egg_box = max(1, round(crew_scale / 3)),
			/obj/item/food/grown/wheat = max(2, crew_scale),
			/obj/item/food/meat/slab/chicken = max(1, round(crew_scale / 2)),
			/obj/item/food/bread/plain = max(1, round(crew_scale / 2)),
			/obj/item/pizzabox/margherita = max(1, round(crew_scale / 3)),
		))

	if(snapshot?.botanist_count > 0)
		var/obj/item/storage/box/hydro_box = create_storyteller_box(
			crate,
			"hydroponics produce box",
			"A mixed produce box intended to keep both the kitchen and hydroponics supplied.",
			"box",
			"writing",
			16,
			WEIGHT_CLASS_NORMAL,
		)
		add_storyteller_items(hydro_box, list(
			/obj/item/storage/box/ingredients/salads = 1,
			/obj/item/storage/box/ingredients/fruity = 1,
			/obj/item/storage/box/ingredients/vegetarian = 1,
			/obj/item/food/grown/banana = max(2, crew_scale),
			/obj/item/food/grown/wheat = max(2, crew_scale),
		))

	if(snapshot?.bartender_count > 0)
		var/obj/item/storage/box/bar_box = create_storyteller_box(
			crate,
			"bartending refreshment box",
			"A service box with extra drinkware and bar staples.",
			"box",
			"writing",
			14,
			WEIGHT_CLASS_NORMAL,
		)
		add_storyteller_items(bar_box, list(
			/obj/item/storage/box/drinkingglasses = 1,
			/obj/item/reagent_containers/cup/glass/bottle/beer = max(2, round(crew_scale / 2)),
			/obj/item/reagent_containers/cup/glass/bottle/beer/light = max(2, round(crew_scale / 2)),
			/obj/item/reagent_containers/cup/glass/shaker = 1,
		))

	if(snapshot?.clown_count > 0)
		var/obj/item/storage/box/clown_box = create_storyteller_box(
			crate,
			"clown morale box",
			"A bright service box approved for authorized clown support only.",
			"box",
			"writing",
			12,
			WEIGHT_CLASS_NORMAL,
		)
		add_storyteller_items(clown_box, list(
			/obj/item/storage/box/clown = 1,
			/obj/item/storage/box/donkpockets/donkpockethonk = 1,
			/obj/item/food/pie/cream = 1,
			/obj/item/food/grown/banana = max(2, round(crew_scale / 2)),
		))

	if(snapshot?.mime_count > 0)
		var/obj/item/storage/box/mime_box = create_storyteller_box(
			crate,
			"mime pantry box",
			"A monochrome service box with supplies reserved for mime performers.",
			"box",
			"writing",
			10,
			WEIGHT_CLASS_NORMAL,
		)
		add_storyteller_items(mime_box, list(
			/obj/item/storage/box/mime = 1,
			/obj/item/food/grown/banana/mime = max(2, round(crew_scale / 2)),
			/obj/item/food/cake/plain = 1,
		))

	return crate

/datum/controller/subsystem/storyteller/proc/create_engineering_relief_contents(datum/storyteller/need_report/report)
	RETURN_TYPE(/obj/structure/closet/crate)
	var/crew_scale = clamp(round(get_report_detail_number(report, "crew_scale", 1)), 1, 8)
	var/severity = report.severity
	var/datum/storyteller/state_snapshot/snapshot = current_snapshot
	var/large_packs = max(1, round(crew_scale / 3)) + (severity >= 70 ? 1 : 0)
	var/small_packs = max(1, round(crew_scale / 2)) + (severity >= 45 ? 1 : 0)
	var/obj/structure/closet/crate/engineering/crate = create_storyteller_crate(
		/obj/structure/closet/crate/engineering,
		"engineering relief crate",
		"A field repair crate packed with structural materials and emergency engineering tools.",
	)
	var/obj/item/storage/box/material_box = create_storyteller_box(
		crate,
		"structural materials box",
		"A box of pre-counted construction materials for rapid repairs.",
		"engibox",
		"writing",
		20,
		WEIGHT_CLASS_HUGE,
	)
	add_storyteller_basic_resource_packs(material_box, /obj/item/stack/sheet/iron, large_packs, small_packs)
	add_storyteller_basic_resource_packs(material_box, /obj/item/stack/sheet/glass, max(0, large_packs - 1), small_packs)
	add_storyteller_basic_resource_packs(material_box, /obj/item/stack/rods, max(0, large_packs - 1), max(1, small_packs - 1))
	add_storyteller_basic_resource_packs(material_box, /obj/item/stack/sheet/plasteel, max(0, round(large_packs / 2)), max(1, round(small_packs / 2)))

	var/obj/item/storage/box/utility_box = create_storyteller_box(
		crate,
		"engineering utility box",
		"A mixed engineering box containing anti-breach and utility reserves.",
		"engibox",
		"writing",
		18,
		WEIGHT_CLASS_HUGE,
	)
	add_storyteller_items(utility_box, list(
		/obj/item/storage/box/metalfoam = severity >= 50 ? 2 : 1,
		/obj/item/extinguisher/advanced = 1,
		/obj/item/storage/box/engitank = snapshot?.atmos_count > 0 ? 1 : 0,
	))
	add_storyteller_stack(utility_box, /obj/item/stack/cable_coil, max(20, crew_scale * 10))
	if(severity >= 70)
		add_storyteller_items(utility_box, list(
			/obj/item/storage/box/smart_metal_foam = 1,
			/obj/item/storage/box/rcd_ammo = 1,
		))
		add_storyteller_items(crate, list(/obj/item/construction/rcd/loaded = 1))
	if(snapshot?.atmos_count > 0)
		add_storyteller_items(crate, list(
			/obj/item/analyzer = 1,
			/obj/item/tank/internals/emergency_oxygen/engi = max(1, round(crew_scale / 3)),
		))
	return crate

/datum/controller/subsystem/storyteller/proc/create_material_relief_contents(datum/storyteller/need_report/report)
	RETURN_TYPE(/obj/structure/closet/crate)
	var/crew_scale = clamp(round(get_report_detail_number(report, "crew_scale", 1)), 1, 8)
	var/severity = report.severity
	var/datum/storyteller/state_snapshot/snapshot = current_snapshot
	var/total_materials = get_report_detail_number(report, "total_materials", 0)
	var/emptiness_scale = clamp(round((650 - total_materials) / 130), 1, 5)
	var/large_packs = max(1, round((crew_scale + emptiness_scale) / 3))
	var/small_packs = max(1, round((crew_scale + emptiness_scale) / 2))
	var/material_crate_type = snapshot?.miner_count > 0 ? /obj/structure/closet/crate/cargo/mining : /obj/structure/closet/crate/cargo
	var/obj/structure/closet/crate/crate = create_storyteller_crate(
		material_crate_type,
		"cargo reserve crate",
		"A reserve cargo crate carrying refined materials and logistics backup stock.",
	)
	add_storyteller_items(crate, list(
		/obj/item/storage/bag/ore = 1,
		/obj/item/storage/bag/sheetsnatcher = 1,
	))
	if(snapshot?.cargo_staff_count > 0)
		add_storyteller_items(crate, list(/obj/item/storage/part_replacer/cargo = 1))

	var/obj/item/storage/box/base_material_box = create_storyteller_box(
		crate,
		"base resource bundle",
		"A box of basic station materials packed in 10-sheet and 25-sheet batches.",
		"engibox",
		"writing",
		18,
		WEIGHT_CLASS_HUGE,
	)
	add_storyteller_basic_resource_packs(base_material_box, /obj/item/stack/sheet/iron, large_packs, small_packs)
	add_storyteller_basic_resource_packs(base_material_box, /obj/item/stack/sheet/glass, max(1, large_packs - 1), small_packs)
	add_storyteller_basic_resource_packs(base_material_box, /obj/item/stack/rods, max(0, large_packs - 1), max(1, small_packs - 1))
	add_storyteller_basic_resource_packs(base_material_box, /obj/item/stack/sheet/plasteel, max(0, round(large_packs / 2)), max(1, round((small_packs + 1) / 2)))

	var/obj/item/storage/box/refined_box = create_storyteller_box(
		crate,
		"refined ore bundle",
		"A box of refined ores intended to shore up manufacturing bottlenecks.",
		"engibox",
		"writing",
		16,
		WEIGHT_CLASS_HUGE,
	)
	add_storyteller_stack(refined_box, /obj/item/stack/sheet/mineral/plasma, 10 * max(1, round((emptiness_scale + 1) / 2)))
	if(severity >= 45 || snapshot?.cargo_gorilla_count > 0)
		add_storyteller_stack(refined_box, /obj/item/stack/sheet/mineral/silver, 10)
		add_storyteller_stack(refined_box, /obj/item/stack/sheet/mineral/coal, 10)
	if(severity >= 60)
		add_storyteller_stack(refined_box, /obj/item/stack/sheet/mineral/gold, 10)
		add_storyteller_stack(refined_box, /obj/item/stack/sheet/mineral/uranium, 5)
	if(severity >= 75)
		add_storyteller_stack(refined_box, /obj/item/stack/sheet/mineral/titanium, 10)

	if(snapshot?.bitrunner_count > 0)
		var/obj/item/storage/box/bitrunner_box = create_storyteller_box(
			crate,
			"bitrunner cache box",
			"A box of compiled support tools for bitrunning specialists.",
			"plasticbox",
			"writing",
			12,
			WEIGHT_CLASS_NORMAL,
		)
		add_storyteller_items(bitrunner_box, list(
			/obj/item/disk/bitrunning/item/tier1 = 1,
			/obj/item/disk/bitrunning/item/tier2 = severity >= 55 ? 1 : 0,
			/obj/item/disk/bitrunning/item/tier3 = severity >= 80 ? 1 : 0,
		))
	return crate

/datum/controller/subsystem/storyteller/proc/create_medical_relief_contents(datum/storyteller/need_report/report)
	RETURN_TYPE(/obj/structure/closet/crate)
	var/crew_scale = clamp(round(get_report_detail_number(report, "crew_scale", 1)), 1, 8)
	var/severity = report.severity
	var/datum/storyteller/state_snapshot/snapshot = current_snapshot
	var/obj/structure/closet/crate/medical/crate = create_storyteller_crate(
		/obj/structure/closet/crate/medical,
		"medical relief crate",
		"A triage crate loaded with emergency treatment stock for Medbay.",
	)
	add_storyteller_items(crate, list(
		/obj/item/storage/medkit/emergency = max(1, round(crew_scale / 3)),
		/obj/item/storage/medkit/regular = max(1, round(crew_scale / 3)),
		/obj/item/healthanalyzer = 1,
	))

	var/obj/item/storage/box/triage_box = create_storyteller_box(
		crate,
		"triage support box",
		"A mixed box of frontline medical treatment supplies.",
		"medbox",
		"writing",
		18,
		WEIGHT_CLASS_NORMAL,
	)
	add_storyteller_items(triage_box, list(
		/obj/item/storage/box/bandages = 1,
		/obj/item/storage/box/medigels = 1,
		/obj/item/storage/box/medipens = 1,
		/obj/item/storage/box/medipens/utility = severity >= 50 ? 1 : 0,
		/obj/item/reagent_containers/cup/bottle/epinephrine = max(1, round(crew_scale / 3)),
	))
	add_storyteller_stack(triage_box, /obj/item/stack/medical/wrap/gauze, max(4, crew_scale * 2))
	add_storyteller_stack(triage_box, /obj/item/stack/medical/suture, max(2, crew_scale))
	add_storyteller_stack(triage_box, /obj/item/stack/medical/ointment, max(2, crew_scale))

	if(snapshot?.chemist_count > 0)
		var/obj/item/storage/box/chemist_box = create_storyteller_box(
			crate,
			"chemistry reserve box",
			"A mixed chemistry box for rapid restocking of med reagent work.",
			"medbox",
			"writing",
			20,
			WEIGHT_CLASS_NORMAL,
		)
		add_storyteller_items(chemist_box, list(
			/obj/item/storage/box/beakers/variety = 1,
			/obj/item/storage/box/beakers/big = 1,
			/obj/item/storage/box/syringes/variety = 1,
			/obj/item/storage/box/pillbottles = 1,
			/obj/item/reagent_containers/dropper = 2,
			/obj/item/reagent_containers/cup/bottle/epinephrine = max(1, round(crew_scale / 3)),
		))

	if(severity >= 45)
		add_storyteller_items(crate, list(
			/obj/item/storage/medkit/brute = 1,
			/obj/item/storage/medkit/fire = 1,
			/obj/item/storage/box/triage_cards = 1,
		))
	if(severity >= 65)
		add_storyteller_items(crate, list(
			/obj/item/storage/medkit/advanced = 1,
			/obj/item/healthanalyzer/advanced = 1,
			/obj/item/emergency_bed = max(1, round(crew_scale / 4)),
			/obj/item/reagent_containers/hypospray/medipen = max(1, round(crew_scale / 3)),
		))
	if(severity >= 75 || get_report_detail_number(report, "critical_crew", 0) > 0)
		add_storyteller_items(crate, list(
			/obj/item/defibrillator/loaded = 1,
			/obj/item/pinpointer/crew = 1,
		))
	if(snapshot?.recent_deaths > 0)
		add_storyteller_items(crate, list(/obj/item/storage/box/bodybags = 1))
	return crate

/datum/controller/subsystem/storyteller/proc/create_security_relief_contents(datum/storyteller/need_report/report)
	RETURN_TYPE(/obj/structure/closet/crate)
	var/crew_scale = clamp(round(get_report_detail_number(report, "crew_scale", 1)), 1, 8)
	var/severity = report.severity
	var/obj/structure/closet/crate/crate = create_storyteller_crate(
		/obj/structure/closet/crate,
		"security response crate",
		"A rapid-response crate of less-lethal crowd control and scene management supplies.",
	)
	var/obj/item/storage/box/arrest_box = create_storyteller_box(
		crate,
		"arrest support box",
		"A box of restraints and evidence handling gear for Security.",
		"secbox",
		"writing",
		14,
		WEIGHT_CLASS_NORMAL,
	)
	add_storyteller_items(arrest_box, list(
		/obj/item/storage/box/zipties = max(1, round(crew_scale / 3)),
		/obj/item/storage/box/handcuffs = severity >= 55 ? 1 : 0,
		/obj/item/storage/box/evidence = 1,
	))

	var/obj/item/storage/box/control_box = create_storyteller_box(
		crate,
		"crowd-control box",
		"A box of less-lethal response gear for brig-side incidents.",
		"secbox",
		"writing",
		14,
		WEIGHT_CLASS_NORMAL,
	)
	add_storyteller_items(control_box, list(
		/obj/item/storage/box/flashes = max(1, round(crew_scale / 4)),
		/obj/item/storage/box/beanbag = max(1, round(crew_scale / 4)),
		/obj/item/storage/medkit/emergency = 1,
	))
	if(severity >= 60)
		add_storyteller_items(control_box, list(/obj/item/storage/box/flashbangs = 1))
	add_storyteller_items(crate, list(/obj/item/tank/internals/emergency_oxygen = max(1, round(crew_scale / 4))))
	return crate

/datum/controller/subsystem/storyteller/proc/create_science_relief_contents(datum/storyteller/need_report/report)
	RETURN_TYPE(/obj/structure/closet/crate)
	var/crew_scale = clamp(round(get_report_detail_number(report, "crew_scale", 1)), 1, 8)
	var/severity = report.severity
	var/datum/storyteller/state_snapshot/snapshot = current_snapshot
	var/science_crate_type = snapshot?.roboticist_count > 0 ? /obj/structure/closet/crate/science/robo : /obj/structure/closet/crate/science
	var/obj/structure/closet/crate/crate = create_storyteller_crate(
		science_crate_type,
		"research relief crate",
		"A departmental science crate containing machine parts and experiment support stock.",
	)
	add_storyteller_items(crate, list(
		/obj/item/storage/part_replacer = 1,
		/obj/item/analyzer = 1,
		/obj/item/storage/box/beakers/big = 1,
	))
	create_storyteller_component_box(crate, 1)
	if(severity >= 35 || crew_scale >= 2)
		create_storyteller_component_box(crate, 2)
	if(severity >= 55)
		create_storyteller_component_box(crate, 3)
	if(severity >= 80)
		add_storyteller_items(crate, list(/obj/item/storage/part_replacer/bluespace = 1))
		create_storyteller_component_box(crate, 4)

	if(snapshot?.scientist_count > 0 || snapshot?.geneticist_count > 0)
		var/obj/item/storage/box/research_box = create_storyteller_box(
			crate,
			"research reagent box",
			"A mixed set of analysis and experiment supplies for the research floor.",
			"plasticbox",
			"writing",
			16,
			WEIGHT_CLASS_NORMAL,
		)
		add_storyteller_items(research_box, list(
			/obj/item/storage/box/beakers/variety = 1,
			/obj/item/storage/box/petridish = snapshot?.geneticist_count > 0 ? 1 : 0,
			/obj/item/storage/box/swab = snapshot?.geneticist_count > 0 ? 1 : 0,
			/obj/item/storage/box/monkeycubes = snapshot?.geneticist_count > 0 ? 1 : 0,
		))
		add_storyteller_stack(research_box, /obj/item/stack/sheet/mineral/plasma, severity >= 60 ? 20 : 10)
		add_storyteller_stack(research_box, /obj/item/stack/sheet/glass, 10)

	if(snapshot?.roboticist_count > 0)
		var/obj/item/storage/box/robotics_box = create_storyteller_box(
			crate,
			"robotics service box",
			"A robotics support box with replacement cells and assembly-side tools.",
			"plasticbox",
			"writing",
			14,
			WEIGHT_CLASS_NORMAL,
		)
		add_storyteller_items(robotics_box, list(
			/obj/item/storage/box/flashes = 1,
			/obj/item/stock_parts/power_store/cell/high = 2,
			/obj/item/stock_parts/power_store/cell/super = severity >= 55 ? 1 : 0,
		))
		add_storyteller_stack(robotics_box, /obj/item/stack/cable_coil, 20)
	return crate

/datum/controller/subsystem/storyteller/proc/create_janitorial_relief_contents(datum/storyteller/need_report/report)
	RETURN_TYPE(/obj/structure/closet/crate)
	var/crew_scale = clamp(round(get_report_detail_number(report, "crew_scale", 1)), 1, 8)
	var/severity = report.severity
	var/obj/structure/closet/crate/trashcart/crate = create_storyteller_crate(
		/obj/structure/closet/crate/trashcart,
		"custodial relief cart",
		"A wheeled custodial cart full of cleanup and sanitation supplies.",
	)
	var/obj/item/storage/box/cleanup_box = create_storyteller_box(
		crate,
		"cleanup supply box",
		"A service box of cleaner, gloves, masks, and replacement custodial supplies.",
		"box",
		"writing",
		16,
		WEIGHT_CLASS_NORMAL,
	)
	add_storyteller_items(cleanup_box, list(
		/obj/item/storage/box/gloves = 1,
		/obj/item/storage/box/masks = 1,
		/obj/item/reagent_containers/spray/cleaner = max(1, round(crew_scale / 3)),
		/obj/item/grenade/chem_grenade/cleaner = max(1, round(crew_scale / 3)),
		/obj/item/soap/nanotrasen = 2,
	))
	add_storyteller_items(crate, list(
		/obj/item/mop = 1,
		/obj/item/storage/bag/trash = 1,
		/obj/item/lightreplacer = 1,
	))
	if(severity >= 50)
		add_storyteller_items(crate, list(/obj/item/mop/advanced = 1))
	if(severity >= 65)
		add_storyteller_items(cleanup_box, list(/obj/item/grenade/chem_grenade/cleaner = max(1, round(crew_scale / 3))))
	return crate

/datum/controller/subsystem/storyteller/proc/create_department_relief_contents(department_id)
	RETURN_TYPE(/list)
	switch(department_id)
		if(ACCOUNT_MED)
			return list(
				/obj/item/storage/medkit/emergency = 2,
				/obj/item/storage/medkit/regular = 1,
				/obj/item/storage/medkit/brute = 1,
				/obj/item/storage/medkit/fire = 1,
				/obj/item/extinguisher = 1,
				/obj/item/tank/internals/emergency_oxygen = 2,
			)
		if(ACCOUNT_ENG)
			return list(
				/obj/item/stack/cable_coil = 2,
				/obj/item/extinguisher/advanced = 1,
				/obj/item/tank/internals/emergency_oxygen/engi = 2,
				/obj/item/stock_parts/capacitor = 2,
				/obj/item/stock_parts/servo = 2,
			)
		if(ACCOUNT_SCI)
			return list(
				/obj/item/stock_parts/scanning_module = 2,
				/obj/item/stock_parts/capacitor = 2,
				/obj/item/stock_parts/servo = 2,
				/obj/item/stock_parts/micro_laser = 2,
				/obj/item/stock_parts/matter_bin = 2,
			)
		if(ACCOUNT_SEC)
			return list(
				/obj/item/storage/medkit/emergency = 1,
				/obj/item/extinguisher = 1,
				/obj/item/tank/internals/emergency_oxygen = 2,
			)
		if(ACCOUNT_CAR)
			return list(
				/obj/item/storage/bag/ore = 1,
				/obj/item/stack/sheet/iron/fifty = 1,
				/obj/item/stack/sheet/glass/fifty = 1,
			)
		if(ACCOUNT_CMD)
			return list(
				/obj/item/storage/medkit/emergency = 1,
				/obj/item/extinguisher = 1,
				/obj/item/tank/internals/emergency_oxygen = 1,
				/obj/item/stock_parts/power_store/cell/high = 1,
			)
	return list(
		/obj/item/storage/medkit/emergency = 1,
		/obj/item/tank/internals/emergency_oxygen = 1,
		/obj/item/extinguisher = 1,
	)

/datum/controller/subsystem/storyteller/proc/spawn_storyteller_pod(turf/target, list/contents, department_id = null, delivery_name = null, delivery_summary = null)
	RETURN_TYPE(/list)
	if(!isturf(target) || !length(contents))
		return null
	var/obj/structure/closet/supplypod/centcompod/pod = new(null, /datum/pod_style/centcom)
	load_storyteller_pod_contents(pod, contents)
	var/list/pod_delays = list()
	if(islist(pod.delays))
		var/list/existing_delays = pod.delays
		pod_delays = existing_delays.Copy()
	pod_delays[POD_TRANSIT] = get_storyteller_pod_transit_delay()
	pod.delays = pod_delays
	var/obj/effect/pod_landingzone/landingzone = new(target, pod)
	if(!istype(landingzone))
		qdel(pod)
		return null
	var/eta = max((pod.delays[POD_TRANSIT] || 0) + (pod.delays[POD_FALLING] || 0), 0)
	track_pending_pod_delivery(landingzone, target, department_id, delivery_name, delivery_summary, eta)
	return list(
		"id" = REF(landingzone),
		"eta" = eta,
	)

/datum/controller/subsystem/storyteller/proc/get_department_label(department_id)
	return profile.department_labels[department_id] || department_id

/datum/controller/subsystem/storyteller/proc/get_weighted_action_ui_entries(list/weighted_actions, list/context_data)
	RETURN_TYPE(/list)
	var/list/entries = list()
	var/total_weight = 0
	for(var/datum/storyteller/action/action as anything in weighted_actions)
		total_weight += max(0, weighted_actions[action])
	for(var/datum/storyteller/action/action as anything in weighted_actions)
		var/list/action_data = action.to_ui_data(src, current_snapshot, context_data)
		var/entry_weight = max(0, weighted_actions[action])
		action_data["weight"] = entry_weight
		action_data["chancePercent"] = total_weight > 0 ? round((entry_weight / total_weight) * 100, 0.1) : 0
		var/datum/storyteller/need_report/report = context_data["need_report"]
		if(istype(report))
			action_data["needId"] = report.id
			action_data["needTitle"] = report.title
		entries += list(action_data)
	return entries

/datum/controller/subsystem/storyteller/proc/get_action_chance_map(list/weighted_actions)
	RETURN_TYPE(/list)
	var/list/chances = list()
	if(!islist(weighted_actions) || !length(weighted_actions))
		return chances
	var/total_weight = 0
	for(var/datum/storyteller/action/action as anything in weighted_actions)
		total_weight += max(0, weighted_actions[action])
	if(total_weight <= 0)
		return chances
	for(var/datum/storyteller/action/action as anything in weighted_actions)
		var/entry_weight = max(0, weighted_actions[action])
		chances[action] = round((entry_weight / total_weight) * 100, 0.1)
	return chances

/datum/controller/subsystem/storyteller/proc/get_action_ui_context_data(datum/storyteller/action/action)
	RETURN_TYPE(/list)
	var/list/context_data = list("selection_context" = action.context)
	if(action.polarity == STORYTELLER_POLARITY_POSITIVE && length(action.supported_need_ids))
		var/datum/storyteller/need_report/report = get_best_matching_need_report(action)
		if(istype(report))
			context_data["need_report"] = report
	return context_data

/datum/controller/subsystem/storyteller/proc/get_action_ui_entries_for_polarity(action_polarity, antag_only = FALSE)
	RETURN_TYPE(/list)
	var/list/entries = list()
	var/list/chance_map = list()
	if(action_polarity == STORYTELLER_POLARITY_POSITIVE)
		var/list/positive_pool = get_positive_candidate_pool()
		chance_map = get_action_chance_map(islist(positive_pool) ? positive_pool["weighted_actions"] : null)
	else if(action_polarity == STORYTELLER_POLARITY_NEGATIVE && !antag_only)
		var/list/negative_pool = get_negative_candidate_pool()
		chance_map = get_action_chance_map(islist(negative_pool) ? negative_pool["weighted_actions"] : null)

	var/current_context = SSticker.IsRoundInProgress() ? STORYTELLER_CONTEXT_MIDROUND : STORYTELLER_CONTEXT_ROUNDSTART
	for(var/datum/storyteller/action/action as anything in catalog.actions)
		if(action.polarity != action_polarity)
			continue
		if(!!action.is_antag_action() != !!antag_only)
			continue
		var/list/context_data = get_action_ui_context_data(action)
		var/datum/storyteller/need_report/report = context_data["need_report"]
		var/list/action_data = action.to_ui_data(src, current_snapshot, context_data)
		action_data["chancePercent"] = chance_map[action] || 0
		action_data["activeWindow"] = action.context == current_context
		if(istype(report))
			action_data["needId"] = report.id
			action_data["needTitle"] = report.title
		entries += list(action_data)
	return entries

/datum/controller/subsystem/storyteller/proc/get_antag_action_ui_entries()
	RETURN_TYPE(/list)
	var/list/entries = list()
	var/list/context_totals = list()
	var/list/context_weights = list()
	for(var/action_context in list(STORYTELLER_CONTEXT_ROUNDSTART, STORYTELLER_CONTEXT_MIDROUND, STORYTELLER_CONTEXT_LATEJOIN))
		context_weights[action_context] = list()

	for(var/datum/storyteller/action/action as anything in catalog.actions)
		if(!action.is_antag_action())
			continue
		var/list/context_data = list("selection_context" = action.context)
		var/list/action_data = action.to_ui_data(src, current_snapshot, context_data)
		var/effective_weight = action_data["eligible"] ? max(0, action.get_effective_weight(src)) : 0
		context_weights[action.context][action] = effective_weight
		context_totals[action.context] = (context_totals[action.context] || 0) + effective_weight
		action_data["activeWindow"] = action.context == (SSticker.IsRoundInProgress() ? STORYTELLER_CONTEXT_MIDROUND : STORYTELLER_CONTEXT_ROUNDSTART)
		action_data["chancePercent"] = 0
		entries += list(action_data)

	for(var/list/action_data as anything in entries)
		var/datum/storyteller/action/action = catalog.get_action(action_data["id"])
		if(!istype(action))
			continue
		var/total_weight = context_totals[action.context] || 0
		var/action_weight = context_weights[action.context][action] || 0
		action_data["chancePercent"] = total_weight > 0 ? round((action_weight / total_weight) * 100, 0.1) : 0
	return entries

/datum/controller/subsystem/storyteller/proc/get_queued_antag_ui_entries()
	RETURN_TYPE(/list)
	var/list/entries = list()
	prune_queued_antag_metadata()
	prune_scheduled_action_queue()
	for(var/list/entry as anything in scheduled_action_queue)
		if(!islist(entry))
			continue
		var/datum/storyteller/action/scheduled_action = catalog.get_action(entry["actionId"])
		if(!istype(scheduled_action) || !scheduled_action.is_antag_action())
			continue
		var/scheduled_pref_flag = ""
		var/datum/storyteller/action/dynamic_base/dynamic_action = scheduled_action
		if(istype(dynamic_action))
			var/datum/dynamic_ruleset/scheduled_ruleset = dynamic_action.build_ruleset()
			if(istype(scheduled_ruleset))
				scheduled_pref_flag = scheduled_ruleset.pref_flag || ""
				qdel(scheduled_ruleset)
		entries += list(list(
			"id" = entry["queueId"],
			"name" = entry["name"],
			"context" = entry["context"],
			"prefFlag" = scheduled_pref_flag,
			"reservedCost" = 0,
			"remaining" = max((entry["executeAt"] || 0) - world.time, 0),
			"scheduledFor" = station_time_timestamp("hh:mm:ss", entry["executeAt"]),
			"sourceName" = entry["sourceName"],
			"storytellerGenerated" = !!entry["storytellerGenerated"],
		))
	for(var/datum/dynamic_ruleset/ruleset as anything in SSdynamic.queued_rulesets)
		var/context = "unknown"
		if(istype(ruleset, /datum/dynamic_ruleset/roundstart))
			context = STORYTELLER_CONTEXT_ROUNDSTART
		else if(istype(ruleset, /datum/dynamic_ruleset/latejoin))
			context = STORYTELLER_CONTEXT_LATEJOIN
		else
			continue
		var/list/metadata = queued_antag_metadata[REF(ruleset)]
		var/ruleset_name = islist(metadata) ? metadata["name"] : null
		ruleset_name ||= ruleset.config_tag || ruleset.name || "[ruleset.type]"
		var/queued_pref_flag = islist(metadata) ? metadata["prefFlag"] : null
		queued_pref_flag ||= ruleset.pref_flag || ""
		var/reserved_cost = max(0, islist(metadata) ? metadata["reservedCost"] : 0)
		var/source_name = islist(metadata) ? metadata["sourceName"] : null
		entries += list(list(
			"id" = REF(ruleset),
			"name" = ruleset_name,
			"context" = context,
			"prefFlag" = queued_pref_flag,
			"reservedCost" = reserved_cost,
			"remaining" = 0,
			"scheduledFor" = null,
			"sourceName" = source_name,
			"storytellerGenerated" = islist(metadata) ? !!metadata["storytellerGenerated"] : FALSE,
		))
	if(queued_negative_action_id)
		var/datum/storyteller/action/action = catalog.get_action(queued_negative_action_id)
		if(istype(action) && action.is_antag_action())
			entries += list(list(
				"id" = action.id,
				"name" = "[action.name] (Storyteller Queue)",
				"context" = action.context,
				"prefFlag" = "",
				"reservedCost" = get_reserved_action_budget(action.id),
				"remaining" = 0,
				"scheduledFor" = null,
				"sourceName" = null,
				"storytellerGenerated" = TRUE,
			))
	return entries

/datum/controller/subsystem/storyteller/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/controller/subsystem/storyteller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StorytellerPanel")
		ui.open()

/datum/controller/subsystem/storyteller/ui_data(mob/user)
	prune_queued_antag_metadata()
	refresh_snapshot()
	if(SSticker.IsRoundInProgress() && !profile_selected)
		select_profile_for_population(max(current_snapshot?.alive_crew || 0, current_snapshot?.active_population || 0))
	update_scores()
	evaluate_needs()
	if(SSticker.IsRoundInProgress())
		ensure_round_cadence()
		update_content_stage()

	var/list/data = list()
	data["enabled"] = is_enabled()
	data["ownsPacing"] = owns_pacing()
	data["paused"] = paused
	data["interfaceLanguage"] = user?.client?.prefs?.read_preference(/datum/preference/choiced/interface_language)
	data["panelLanguages"] = user?.client?.prefs ? build_panel_languages_payload(user.client.prefs) : null
	data["profileName"] = profile?.name || "Unknown"
	data["profileId"] = profile?.id || "unknown"
	data["profileOptions"] = get_profile_options_ui_data()
	data["manualProfileOverride"] = manual_profile_override
	data["roundMode"] = round_mode
	data["roundModeOptions"] = get_round_mode_options_ui_data()
	data["phase"] = current_phase_max
	data["phaseCap"] = phase_cap
	data["manualPhaseOverride"] = manual_phase_override
	data["budgetCap"] = profile?.budget_cap || 100
	data["threatBudget"] = threat_budget
	data["aidBudget"] = aid_budget
	data["positiveFatigueRemaining"] = max(positive_fatigue_locked_until - world.time, 0)
	data["negativeFatigueRemaining"] = max(negative_fatigue_locked_until - world.time, 0)
	data["latejoinHostileRemaining"] = max((last_latejoin_hostile_at + profile.latejoin_hostile_lock) - world.time, 0)
	data["positiveChannelRemaining"] = max(positive_channel_ready_at - world.time, 0)
	data["negativeChannelRemaining"] = max(negative_channel_ready_at - world.time, 0)
	data["latejoinRoundstartRemaining"] = max(latejoin_roundstart_locked_until - world.time, 0)
	data["skipNextPulse"] = skip_next_pulse
	data["roundStarted"] = SSticker.HasRoundStarted()
	data["defaultQueueDelay"] = STORYTELLER_DEFAULT_ACTION_QUEUE_DELAY
	data["snapshot"] = current_snapshot?.to_ui_data() || list()
	data["decisionHistory"] = decision_history.Copy()
	data["activeModifiers"] = list()
	for(var/modifier_id in active_modifiers)
		var/list/entry = get_modifier_entry(modifier_id)
		if(!islist(entry))
			continue
		data["activeModifiers"] += list(list(
			"id" = modifier_id,
			"title" = "[entry["title"]]",
			"label" = "[entry["label"]]",
			"description" = "[entry["description"]]",
			"value" = entry["value"],
			"remaining" = max(entry["until"] - world.time, 0),
			"positive" = !!entry["positive"],
		))
	data["detectedNeeds"] = list()
	for(var/datum/storyteller/need_report/report as anything in current_need_reports)
		var/list/report_data = report.to_ui_data()
		report_data["department"] = get_department_label(report.department_id)
		data["detectedNeeds"] += list(report_data)

	data["familyCooldowns"] = list()
	for(var/family in family_cooldowns)
		var/remaining = family_cooldowns[family] - world.time
		if(remaining <= 0)
			continue
		data["familyCooldowns"] += list(list(
			"family" = family,
			"remaining" = remaining,
		))

	var/current_context = SSticker.IsRoundInProgress() ? STORYTELLER_CONTEXT_MIDROUND : STORYTELLER_CONTEXT_ROUNDSTART
	data["currentContext"] = current_context
	data["queuedPositiveActionId"] = queued_positive_action_id
	data["queuedNegativeActionId"] = queued_negative_action_id
	data["eligibleActions"] = list()
	for(var/datum/storyteller/action/action as anything in catalog.actions)
		if(is_action_admin_suppressed(action.id))
			continue
		var/list/current_context_data = list("selection_context" = current_context)
		var/datum/storyteller/need_report/report = get_best_matching_need_report(action)
		if(istype(report))
			current_context_data["need_report"] = report
		var/list/action_data = action.to_ui_data(src, current_snapshot, current_context_data)
		if(action_data["eligible"])
			if(istype(report))
				action_data["needTitle"] = report.title
			data["eligibleActions"] += list(action_data)

	data["eligiblePositiveActions"] = get_action_ui_entries_for_polarity(STORYTELLER_POLARITY_POSITIVE, FALSE)
	data["eligibleNegativeActions"] = get_action_ui_entries_for_polarity(STORYTELLER_POLARITY_NEGATIVE, FALSE)
	data["eligibleAntagActions"] = get_antag_action_ui_entries()
	data["scheduledActions"] = get_scheduled_action_queue_ui_data()
	data["queuedAntagActions"] = get_queued_antag_ui_entries()

	data["allActions"] = list()
	for(var/datum/storyteller/action/action as anything in catalog.actions)
		data["allActions"] += list(list(
			"id" = action.id,
			"name" = action.name,
			"type" = "[action.type]",
			"category" = action.get_ui_category(),
			"description" = action.get_ui_description(),
			"context" = action.context,
			"polarity" = action.polarity,
			"isAntag" = action.is_antag_action(),
		))

	return data

/datum/controller/subsystem/storyteller/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!check_rights(R_ADMIN))
		return

	switch(action)
		if("pause")
			paused = TRUE
			record_decision("[key_name(ui.user)] paused the storyteller.")
			return TRUE
		if("resume")
			paused = FALSE
			record_decision("[key_name(ui.user)] resumed the storyteller.")
			return TRUE
		if("skip_next_pulse")
			skip_next_pulse = TRUE
			record_decision("[key_name(ui.user)] requested the next storyteller pulse be skipped.")
			return TRUE
		if("set_phase")
			var/new_phase = text2num(params["phase"])
			if(!isnum(new_phase))
				return
			current_phase_max = clamp(round(new_phase), 1, phase_cap)
			manual_phase_override = TRUE
			record_decision("[key_name(ui.user)] set storyteller phase to [current_phase_max].")
			return TRUE
		if("auto_phase")
			manual_phase_override = FALSE
			if(is_roundstart_prep_active())
				select_initial_content_stage_for_roster(build_pregame_roster_data())
				record_decision("[key_name(ui.user)] returned storyteller content stage control to automatic frozen-roster escalation.")
				return TRUE
			update_content_stage()
			record_decision("[key_name(ui.user)] returned storyteller content stage control to automatic escalation.")
			return TRUE
		if("set_profile")
			var/profile_id = params["profile_id"]
			if(!profile_id)
				return
			return set_manual_profile(profile_id, ui.user)
		if("auto_profile")
			return clear_manual_profile(ui.user)
		if("set_round_mode")
			var/new_mode = params["round_mode"]
			if(!new_mode)
				return
			return set_manual_round_mode(new_mode, ui.user)
		if("force_action")
			var/action_id = params["action_id"]
			if(!action_id)
				return
			return force_action(action_id, ui.user)
		if("force_action_next")
			var/action_id = params["action_id"]
			if(!action_id)
				return
			return queue_action_for_next(action_id, ui.user)
		if("queue_action_delayed")
			var/action_id = params["action_id"]
			var/delay = text2num(params["delay"])
			if(!action_id || !isnum(delay))
				return
			return queue_action_with_delay(action_id, delay, ui.user)
		if("set_cadence_timer")
			var/timer_id = params["timer_id"]
			var/delay = text2num(params["delay"])
			if(!timer_id || !isnum(delay))
				return
			return set_cadence_timer(timer_id, delay, ui.user)
		if("discard_action")
			var/action_id = params["action_id"]
			if(!action_id)
				return
			return discard_action(action_id, ui.user)
		if("remove_scheduled_action")
			var/queue_id = params["queue_id"]
			if(!queue_id)
				return
			return remove_scheduled_action(queue_id, ui.user)
		if("set_scheduled_action_delay")
			var/queue_id = params["queue_id"]
			var/delay = text2num(params["delay"])
			if(!queue_id || !isnum(delay))
				return
			return set_scheduled_action_delay(queue_id, delay, ui.user)
		if("move_scheduled_action")
			var/queue_id = params["queue_id"]
			var/direction = params["direction"]
			if(!queue_id || !direction)
				return
			return move_scheduled_action(queue_id, direction, ui.user)
		if("force_scheduled_action")
			var/queue_id = params["queue_id"]
			if(!queue_id)
				return
			return force_scheduled_action(queue_id, ui.user)
		if("cancel_queued_antag")
			var/queue_id = params["queue_id"]
			if(!queue_id)
				return
			return cancel_queued_antag(queue_id, ui.user)

/datum/controller/subsystem/storyteller/proc/force_action(action_id, mob/user)
	var/datum/storyteller/action/action = catalog.get_action(action_id)
	if(!istype(action))
		return FALSE

	refresh_snapshot(TRUE)
	update_scores()
	evaluate_needs()
	var/list/context_data = build_forced_context_data(action, user)
	if(!action.force_execute(src, current_snapshot, context_data))
		record_decision("[key_name(user)] failed to execute forced action [action.name].")
		return FALSE
	if(action.context == STORYTELLER_CONTEXT_ROUNDSTART || action.context == STORYTELLER_CONTEXT_LATEJOIN)
		record_decision("[key_name(user)] armed storyteller action [action.name].")
	else
		record_decision("[key_name(user)] forced storyteller action [action.name].")
	return TRUE

/datum/controller/subsystem/storyteller/proc/set_cadence_timer(timer_id, delay, mob/user)
	var/normalized_delay = max(0, round(delay))
	switch(timer_id)
		if("positive_lock")
			positive_fatigue_locked_until = world.time + normalized_delay
			record_decision("[key_name(user)] set the positive fatigue lock to [DisplayTimeText(normalized_delay, round_seconds_to = 1)].")
			return TRUE
		if("positive_window")
			positive_channel_ready_at = world.time + normalized_delay
			record_decision("[key_name(user)] set the next positive window to [DisplayTimeText(normalized_delay, round_seconds_to = 1)].")
			return TRUE
		if("negative_lock")
			negative_fatigue_locked_until = world.time + normalized_delay
			record_decision("[key_name(user)] set the negative fatigue lock to [DisplayTimeText(normalized_delay, round_seconds_to = 1)].")
			return TRUE
		if("negative_window")
			negative_channel_ready_at = world.time + normalized_delay
			record_decision("[key_name(user)] set the next negative window to [DisplayTimeText(normalized_delay, round_seconds_to = 1)].")
			return TRUE
	return FALSE
