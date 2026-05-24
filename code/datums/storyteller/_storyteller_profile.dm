/datum/storyteller/profile
	var/id = "balanced"
	var/name = "Balanced Drama"

	var/recent_window = STORYTELLER_DEFAULT_RECENT_WINDOW
	var/heavy_scan_interval = STORYTELLER_DEFAULT_HEAVY_SCAN_INTERVAL
	var/fatigue_lock = STORYTELLER_DEFAULT_FATIGUE_LOCK
	var/family_cooldown = STORYTELLER_DEFAULT_FAMILY_COOLDOWN
	var/latejoin_hostile_lock = STORYTELLER_DEFAULT_LATEJOIN_HOSTILE_LOCK
	var/negative_roundstart_delay_min = STORYTELLER_DEFAULT_NEGATIVE_ROUNDSTART_DELAY_MIN
	var/negative_roundstart_delay_max = STORYTELLER_DEFAULT_NEGATIVE_ROUNDSTART_DELAY_MAX
	var/positive_roundstart_delay_min = STORYTELLER_DEFAULT_POSITIVE_ROUNDSTART_DELAY_MIN
	var/positive_roundstart_delay_max = STORYTELLER_DEFAULT_POSITIVE_ROUNDSTART_DELAY_MAX
	var/latejoin_roundstart_lock_min = STORYTELLER_DEFAULT_LATEJOIN_ROUNDSTART_LOCK_MIN
	var/latejoin_roundstart_lock_max = STORYTELLER_DEFAULT_LATEJOIN_ROUNDSTART_LOCK_MAX
	var/negative_interval_min = STORYTELLER_DEFAULT_NEGATIVE_INTERVAL_MIN
	var/negative_interval_max = STORYTELLER_DEFAULT_NEGATIVE_INTERVAL_MAX
	var/positive_interval_min = STORYTELLER_DEFAULT_POSITIVE_INTERVAL_MIN
	var/positive_interval_max = STORYTELLER_DEFAULT_POSITIVE_INTERVAL_MAX

	var/threat_gain_divisor = 6
	var/aid_gain_divisor = 6
	var/need_gain_divisor = 10
	var/extended_threat_gain_divisor = 18
	var/budget_cap = 100
	var/escalation_rise_multiplier = 1
	var/escalation_decay_multiplier = 1

	var/list/key_jobs = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_QUARTERMASTER,
		JOB_AI,
	)

	var/list/department_labels = list(
		ACCOUNT_CMD = ACCOUNT_CMD_NAME,
		ACCOUNT_SEC = ACCOUNT_SEC_NAME,
		ACCOUNT_ENG = ACCOUNT_ENG_NAME,
		ACCOUNT_MED = ACCOUNT_MED_NAME,
		ACCOUNT_SCI = ACCOUNT_SCI_NAME,
		ACCOUNT_CAR = ACCOUNT_CAR_NAME,
		ACCOUNT_SRV = ACCOUNT_SRV_NAME,
		ACCOUNT_CIV = ACCOUNT_CIV_NAME,
	)

/datum/storyteller/profile/proc/apply_tuning(list/storyteller_config)
	if(!islist(storyteller_config))
		return

	var/list/profile_config = storyteller_config["profile"]
	if(!islist(profile_config))
		return

	if(type == /datum/storyteller/profile && !isnull(profile_config["name"]))
		name = "[profile_config["name"]]"

	var/value = text2num("[profile_config["recent_window_seconds"]]")
	if(!isnull(profile_config["recent_window_seconds"]))
		recent_window = max(30 SECONDS, round(value * 10))

	value = text2num("[profile_config["heavy_scan_interval_seconds"]]")
	if(!isnull(profile_config["heavy_scan_interval_seconds"]))
		heavy_scan_interval = max(30 SECONDS, round(value * 10))

	value = text2num("[profile_config["fatigue_lock_seconds"]]")
	if(!isnull(profile_config["fatigue_lock_seconds"]))
		fatigue_lock = max(10 SECONDS, round(value * 10))

	value = text2num("[profile_config["family_cooldown_seconds"]]")
	if(!isnull(profile_config["family_cooldown_seconds"]))
		family_cooldown = max(30 SECONDS, round(value * 10))

	value = text2num("[profile_config["latejoin_hostile_lock_seconds"]]")
	if(!isnull(profile_config["latejoin_hostile_lock_seconds"]))
		latejoin_hostile_lock = max(30 SECONDS, round(value * 10))

	value = text2num("[profile_config["negative_roundstart_delay_min_seconds"]]")
	if(!isnull(profile_config["negative_roundstart_delay_min_seconds"]))
		negative_roundstart_delay_min = max(1 MINUTES, round(value * 10))

	value = text2num("[profile_config["negative_roundstart_delay_max_seconds"]]")
	if(!isnull(profile_config["negative_roundstart_delay_max_seconds"]))
		negative_roundstart_delay_max = max(negative_roundstart_delay_min, round(value * 10))

	value = text2num("[profile_config["positive_roundstart_delay_min_seconds"]]")
	if(!isnull(profile_config["positive_roundstart_delay_min_seconds"]))
		positive_roundstart_delay_min = max(1 MINUTES, round(value * 10))

	value = text2num("[profile_config["positive_roundstart_delay_max_seconds"]]")
	if(!isnull(profile_config["positive_roundstart_delay_max_seconds"]))
		positive_roundstart_delay_max = max(positive_roundstart_delay_min, round(value * 10))

	value = text2num("[profile_config["latejoin_roundstart_lock_min_seconds"]]")
	if(!isnull(profile_config["latejoin_roundstart_lock_min_seconds"]))
		latejoin_roundstart_lock_min = max(5 MINUTES, round(value * 10))

	value = text2num("[profile_config["latejoin_roundstart_lock_max_seconds"]]")
	if(!isnull(profile_config["latejoin_roundstart_lock_max_seconds"]))
		latejoin_roundstart_lock_max = max(latejoin_roundstart_lock_min, round(value * 10))

	value = text2num("[profile_config["negative_interval_min_seconds"]]")
	if(!isnull(profile_config["negative_interval_min_seconds"]))
		negative_interval_min = max(1 MINUTES, round(value * 10))

	value = text2num("[profile_config["negative_interval_max_seconds"]]")
	if(!isnull(profile_config["negative_interval_max_seconds"]))
		negative_interval_max = max(negative_interval_min, round(value * 10))

	value = text2num("[profile_config["positive_interval_min_seconds"]]")
	if(!isnull(profile_config["positive_interval_min_seconds"]))
		positive_interval_min = max(1 MINUTES, round(value * 10))

	value = text2num("[profile_config["positive_interval_max_seconds"]]")
	if(!isnull(profile_config["positive_interval_max_seconds"]))
		positive_interval_max = max(positive_interval_min, round(value * 10))

	value = text2num("[profile_config["threat_gain_divisor"]]")
	if(!isnull(profile_config["threat_gain_divisor"]))
		threat_gain_divisor = max(1, value)

	value = text2num("[profile_config["aid_gain_divisor"]]")
	if(!isnull(profile_config["aid_gain_divisor"]))
		aid_gain_divisor = max(1, value)

	value = text2num("[profile_config["need_gain_divisor"]]")
	if(!isnull(profile_config["need_gain_divisor"]))
		need_gain_divisor = max(1, value)

	value = text2num("[profile_config["extended_threat_gain_divisor"]]")
	if(!isnull(profile_config["extended_threat_gain_divisor"]))
		extended_threat_gain_divisor = max(1, value)

	value = text2num("[profile_config["budget_cap"]]")
	if(!isnull(profile_config["budget_cap"]))
		budget_cap = max(1, value)

	value = text2num("[profile_config["escalation_rise_multiplier"]]")
	if(!isnull(profile_config["escalation_rise_multiplier"]))
		escalation_rise_multiplier = max(0.1, value)

	value = text2num("[profile_config["escalation_decay_multiplier"]]")
	if(!isnull(profile_config["escalation_decay_multiplier"]))
		escalation_decay_multiplier = max(0.1, value)

/datum/storyteller/profile/proc/apply_profile_bias()
	return

/datum/storyteller/profile/proc/score_control(datum/storyteller/state_snapshot/snapshot)
	if(!istype(snapshot))
		return 0

	var/crew_ratio = clamp(snapshot.alive_crew / max(snapshot.active_population, 1), 0, 1)
	var/job_ratio = clamp(snapshot.key_jobs_filled_count / max(snapshot.total_key_jobs, 1), 0, 1)
	var/integrity_ratio = clamp(snapshot.station_integrity, 0, 1)
	var/total_money = 0
	var/total_materials = snapshot.ore_silo_material_total + snapshot.loose_material_total

	for(var/department_id in snapshot.department_money)
		total_money += snapshot.department_money[department_id]

	var/funds_ratio = clamp(total_money / 80000, 0, 1)
	var/material_ratio = clamp(total_materials / 700, 0, 1)

	return clamp(
		round((crew_ratio * 25) + (job_ratio * 25) + (integrity_ratio * 25) + (funds_ratio * 15) + (material_ratio * 10)),
		0,
		100,
	)

/datum/storyteller/profile/proc/score_danger(datum/storyteller/state_snapshot/snapshot)
	if(!istype(snapshot))
		return 0

	var/integrity_loss = clamp(1 - snapshot.station_integrity, 0, 1)
	var/job_gap = clamp(1 - (snapshot.key_jobs_filled_count / max(snapshot.total_key_jobs, 1)), 0, 1)
	var/danger_total = 0

	danger_total += min(snapshot.recent_deaths * 6, 25)
	danger_total += min(snapshot.recent_explosions * 10, 20)
	danger_total += min(snapshot.active_alarms * 3, 15)
	danger_total += min(snapshot.injured_crew_count * 2, 12)
	danger_total += min(snapshot.critical_crew_count * 8, 18)
	danger_total += (integrity_loss * 20)
	danger_total += min(snapshot.living_antag_count * 6, 20)
	danger_total += (job_gap * 10)
	danger_total += min(snapshot.active_round_event_count * 2, 10)

	return clamp(round(danger_total), 0, 100)

/datum/storyteller/profile/passive
	id = "passive"
	name = "Patient Custodian"

/datum/storyteller/profile/passive/apply_profile_bias()
	fatigue_lock = round(fatigue_lock * 1.15)
	family_cooldown = round(family_cooldown * 1.2)
	latejoin_hostile_lock = round(latejoin_hostile_lock * 1.15)
	negative_roundstart_delay_min = round(negative_roundstart_delay_min * 1.2)
	negative_roundstart_delay_max = round(negative_roundstart_delay_max * 1.2)
	positive_roundstart_delay_min = round(positive_roundstart_delay_min * 0.9)
	positive_roundstart_delay_max = round(positive_roundstart_delay_max * 0.9)
	negative_interval_min = round(negative_interval_min * 1.25)
	negative_interval_max = round(negative_interval_max * 1.25)
	positive_interval_min = round(positive_interval_min * 0.9)
	positive_interval_max = round(positive_interval_max * 0.9)
	threat_gain_divisor = max(1, round(threat_gain_divisor * 1.2))
	aid_gain_divisor = max(1, round(aid_gain_divisor * 0.85))
	need_gain_divisor = max(1, round(need_gain_divisor * 0.85))
	extended_threat_gain_divisor = max(threat_gain_divisor, round(extended_threat_gain_divisor * 1.2))
	escalation_rise_multiplier *= 0.85
	escalation_decay_multiplier *= 1.3

/datum/storyteller/profile/aggressive
	id = "aggressive"
	name = "Aggressive Escalation"

/datum/storyteller/profile/aggressive/apply_profile_bias()
	fatigue_lock = round(fatigue_lock * 0.9)
	family_cooldown = round(family_cooldown * 0.85)
	latejoin_hostile_lock = round(latejoin_hostile_lock * 0.9)
	negative_roundstart_delay_min = round(negative_roundstart_delay_min * 0.75)
	negative_roundstart_delay_max = round(negative_roundstart_delay_max * 0.8)
	positive_roundstart_delay_min = round(positive_roundstart_delay_min * 1.05)
	positive_roundstart_delay_max = round(positive_roundstart_delay_max * 1.05)
	negative_interval_min = round(negative_interval_min * 0.8)
	negative_interval_max = round(negative_interval_max * 0.85)
	positive_interval_min = round(positive_interval_min * 0.95)
	positive_interval_max = round(positive_interval_max * 0.95)
	threat_gain_divisor = max(1, round(threat_gain_divisor * 0.8))
	aid_gain_divisor = max(1, round(aid_gain_divisor * 1.05))
	need_gain_divisor = max(1, round(need_gain_divisor * 1.1))
	extended_threat_gain_divisor = max(threat_gain_divisor, round(extended_threat_gain_divisor * 0.85))
	escalation_rise_multiplier *= 1.2
	escalation_decay_multiplier *= 0.8
