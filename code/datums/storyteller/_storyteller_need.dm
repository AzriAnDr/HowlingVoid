/datum/storyteller/need_report
	var/id
	var/title = "Unknown Need"
	var/department_id = ACCOUNT_CIV
	var/severity = 0
	var/priority = 0
	var/recommended_action_family
	var/summary = ""
	var/list/details = list()

/datum/storyteller/need_report/proc/to_ui_data()
	return list(
		"id" = id,
		"title" = title,
		"department" = department_id,
		"severity" = severity,
		"priority" = priority,
		"family" = recommended_action_family,
		"summary" = summary,
		"details" = details.Copy(),
	)

/datum/storyteller/need_analyzer
	var/id
	var/title = "Unknown Need"
	var/department_id = ACCOUNT_CIV
	var/recommended_action_family

/datum/storyteller/need_analyzer/proc/apply_tuning(list/storyteller_config)
	return

/datum/storyteller/need_analyzer/proc/evaluate(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot)
	return null

/datum/storyteller/need_analyzer/proc/build_report(severity, priority, summary, list/details)
	var/datum/storyteller/need_report/report = new
	report.id = id
	report.title = title
	report.department_id = department_id
	report.severity = clamp(round(severity), 0, 100)
	report.priority = max(0, round(priority))
	report.recommended_action_family = recommended_action_family
	report.summary = summary
	report.details = islist(details) ? details.Copy() : list()
	return report

/datum/storyteller/need_analyzer/food_shortage
	id = STORYTELLER_NEED_FOOD_SHORTAGE
	title = "Kitchen Food Shortage"
	department_id = ACCOUNT_SRV
	recommended_action_family = "aid_kitchen"
	var/food_per_crew = 0.75
	var/minimum_food_stock = 6

/datum/storyteller/need_analyzer/food_shortage/apply_tuning(list/storyteller_config)
	var/list/need_config = storyteller_config["needs"]
	if(!islist(need_config))
		return
	if(!isnull(need_config["food_per_crew"]))
		food_per_crew = max(0.2, text2num("[need_config["food_per_crew"]]"))
	if(!isnull(need_config["minimum_food_stock"]))
		minimum_food_stock = max(1, round(text2num("[need_config["minimum_food_stock"]]")))

/datum/storyteller/need_analyzer/food_shortage/evaluate(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot)
	if(!istype(snapshot))
		return

	var/expected_food = max(minimum_food_stock, round(snapshot.alive_crew * food_per_crew))
	var/available_food = snapshot.kitchen_food_total + snapshot.service_food_total
	if(available_food >= expected_food)
		return

	var/shortage = max(expected_food - available_food, 0)
	var/severity = min(60, round((shortage / max(expected_food, 1)) * 60))
	if(snapshot.cook_count <= 0)
		severity += 20
	if(snapshot.service_staff_count <= 1)
		severity += 10
	if(snapshot.alive_crew >= 25)
		severity += 10

	var/priority = severity + round(snapshot.alive_crew / 4)
	var/list/details = list(
		"expected_food" = expected_food,
		"available_food" = available_food,
		"cook_count" = snapshot.cook_count,
		"service_staff_count" = snapshot.service_staff_count,
		"crew_scale" = max(1, round(snapshot.alive_crew / 6)),
	)
	return build_report(
		severity,
		priority,
		"Kitchen-side food stock is below the current crew demand.",
		details,
	)

/datum/storyteller/need_analyzer/engineering_repairs
	id = STORYTELLER_NEED_ENGINEERING_REPAIRS
	title = "Engineering Repair Crisis"
	department_id = ACCOUNT_ENG
	recommended_action_family = "aid_engineering"
	var/repair_damage_threshold = 8

/datum/storyteller/need_analyzer/engineering_repairs/apply_tuning(list/storyteller_config)
	var/list/need_config = storyteller_config["needs"]
	if(!islist(need_config))
		return
	if(!isnull(need_config["repair_damage_threshold"]))
		repair_damage_threshold = max(1, round(text2num("[need_config["repair_damage_threshold"]]")))

/datum/storyteller/need_analyzer/engineering_repairs/evaluate(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot)
	if(!istype(snapshot))
		return
	if(snapshot.engineer_count <= 0)
		return

	var/damage_score = (snapshot.station_breach_tiles * 4) + snapshot.damaged_window_count + snapshot.damaged_grille_count + snapshot.broken_floor_count
	damage_score += round((1 - snapshot.station_integrity) * 25)
	if(damage_score < repair_damage_threshold)
		return

	var/severity = min(100, damage_score * 2)
	if(snapshot.engineer_count == 1)
		severity += 10
	if(snapshot.active_alarms >= 3)
		severity += 10

	var/priority = severity + round(snapshot.alive_crew / 5)
	var/list/details = list(
		"breach_tiles" = snapshot.station_breach_tiles,
		"damaged_windows" = snapshot.damaged_window_count,
		"damaged_grilles" = snapshot.damaged_grille_count,
		"broken_floors" = snapshot.broken_floor_count,
		"engineer_count" = snapshot.engineer_count,
		"crew_scale" = max(1, round(snapshot.alive_crew / 7)),
	)
	return build_report(
		severity,
		priority,
		"Engineering damage markers indicate the station repair queue is behind.",
		details,
	)

/datum/storyteller/need_analyzer/material_shortage
	id = STORYTELLER_NEED_MATERIAL_SHORTAGE
	title = "Cargo Material Shortage"
	department_id = ACCOUNT_CAR
	recommended_action_family = "aid_materials"
	var/material_target_total = 650
	var/material_emergency_total = 280
	var/material_income_floor = 40

/datum/storyteller/need_analyzer/material_shortage/apply_tuning(list/storyteller_config)
	var/list/need_config = storyteller_config["needs"]
	if(!islist(need_config))
		return
	if(!isnull(need_config["material_target_total"]))
		material_target_total = max(50, round(text2num("[need_config["material_target_total"]]")))
	if(!isnull(need_config["material_emergency_total"]))
		material_emergency_total = max(20, round(text2num("[need_config["material_emergency_total"]]")))
	if(!isnull(need_config["material_income_floor"]))
		material_income_floor = max(0, round(text2num("[need_config["material_income_floor"]]")))

/datum/storyteller/need_analyzer/material_shortage/evaluate(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot)
	if(!istype(snapshot))
		return

	var/total_materials = snapshot.ore_silo_material_total + snapshot.loose_material_total
	var/is_low_total = total_materials < material_target_total
	var/is_poor_income = snapshot.material_gain_recent < material_income_floor
	if(!is_low_total && !is_poor_income)
		return

	var/severity = 0
	if(total_materials < material_emergency_total)
		severity += 40
	else if(total_materials < material_target_total)
		severity += round(((material_target_total - total_materials) / max(material_target_total, 1)) * 35)
	if(is_poor_income)
		severity += 20
	if(snapshot.miner_count <= 0)
		severity += 15
	else if(snapshot.miner_count == 1)
		severity += 8

	var/priority = severity + round(snapshot.alive_crew / 6)
	var/list/details = list(
		"total_materials" = total_materials,
		"material_gain_recent" = snapshot.material_gain_recent,
		"miner_count" = snapshot.miner_count,
		"cargo_staff_count" = snapshot.cargo_staff_count,
		"crew_scale" = max(1, round(snapshot.alive_crew / 8)),
	)
	return build_report(
		severity,
		priority,
		"Station stockpiles and recent material intake are below the current operational target.",
		details,
	)

/datum/storyteller/need_analyzer/medical_surge
	id = STORYTELLER_NEED_MEDICAL_SURGE
	title = "Medical Triage Surge"
	department_id = ACCOUNT_MED
	recommended_action_family = "aid_medical"
	var/injury_threshold = 4
	var/critical_threshold = 1
	var/medical_supply_floor = 10

/datum/storyteller/need_analyzer/medical_surge/apply_tuning(list/storyteller_config)
	var/list/need_config = storyteller_config["needs"]
	if(!islist(need_config))
		return
	if(!isnull(need_config["medical_injury_threshold"]))
		injury_threshold = max(1, round(text2num("[need_config["medical_injury_threshold"]]")))
	if(!isnull(need_config["medical_critical_threshold"]))
		critical_threshold = max(0, round(text2num("[need_config["medical_critical_threshold"]]")))
	if(!isnull(need_config["medical_supply_floor"]))
		medical_supply_floor = max(1, round(text2num("[need_config["medical_supply_floor"]]")))

/datum/storyteller/need_analyzer/medical_surge/evaluate(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot)
	if(!istype(snapshot))
		return

	var/pressure = (snapshot.injured_crew_count * 4) + (snapshot.critical_crew_count * 18) + (snapshot.recent_deaths * 5)
	var/supply_gap = max(medical_supply_floor - snapshot.medical_supply_total, 0)
	if(pressure < (injury_threshold * 4) && snapshot.critical_crew_count < critical_threshold && supply_gap <= 0)
		return

	var/severity = min(100, pressure + (supply_gap * 3))
	if(snapshot.medical_staff_count <= 0)
		severity += 15
	else if(snapshot.doctor_count <= 0)
		severity += 8
	if(snapshot.critical_crew_count > 0)
		severity += 10

	var/priority = severity + round(snapshot.alive_crew / 5)
	var/list/details = list(
		"injured_crew" = snapshot.injured_crew_count,
		"critical_crew" = snapshot.critical_crew_count,
		"medical_staff_count" = snapshot.medical_staff_count,
		"doctor_count" = snapshot.doctor_count,
		"medical_supply_total" = snapshot.medical_supply_total,
		"crew_scale" = max(1, round(snapshot.alive_crew / 7)),
	)
	return build_report(
		severity,
		priority,
		"Medical telemetry indicates rising treatment demand and thinning triage reserves.",
		details,
	)

/datum/storyteller/need_analyzer/security_strain
	id = STORYTELLER_NEED_SECURITY_STRAIN
	title = "Security Strain"
	department_id = ACCOUNT_SEC
	recommended_action_family = "aid_security"
	var/security_pressure_threshold = 18

/datum/storyteller/need_analyzer/security_strain/apply_tuning(list/storyteller_config)
	var/list/need_config = storyteller_config["needs"]
	if(!islist(need_config))
		return
	if(!isnull(need_config["security_pressure_threshold"]))
		security_pressure_threshold = max(1, round(text2num("[need_config["security_pressure_threshold"]]")))

/datum/storyteller/need_analyzer/security_strain/evaluate(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot)
	if(!istype(snapshot))
		return

	var/pressure = (snapshot.living_antag_count * 16) + (snapshot.active_alarms * 3) + (snapshot.recent_deaths * 4)
	pressure += min(snapshot.active_round_event_count * 2, 10)
	if(pressure < security_pressure_threshold)
		return

	var/severity = min(100, pressure)
	if(snapshot.security_staff_count <= 0)
		severity += 20
	else if(snapshot.security_staff_count == 1)
		severity += 12
	if(snapshot.alive_crew >= 25)
		severity += 8

	var/priority = severity + (snapshot.living_antag_count * 5)
	var/list/details = list(
		"living_antag_count" = snapshot.living_antag_count,
		"active_alarms" = snapshot.active_alarms,
		"recent_deaths" = snapshot.recent_deaths,
		"security_staff_count" = snapshot.security_staff_count,
		"crew_scale" = max(1, round(snapshot.alive_crew / 8)),
	)
	return build_report(
		severity,
		priority,
		"Security coverage is being stretched by threats, alarms, and casualty pressure.",
		details,
	)

/datum/storyteller/need_analyzer/science_shortage
	id = STORYTELLER_NEED_SCIENCE_SHORTAGE
	title = "Science Supply Shortage"
	department_id = ACCOUNT_SCI
	recommended_action_family = "aid_science"
	var/science_supply_floor = 8
	var/science_budget_floor = 3500
	var/science_pressure_threshold = 16

/datum/storyteller/need_analyzer/science_shortage/apply_tuning(list/storyteller_config)
	var/list/need_config = storyteller_config["needs"]
	if(!islist(need_config))
		return
	if(!isnull(need_config["science_supply_floor"]))
		science_supply_floor = max(1, round(text2num("[need_config["science_supply_floor"]]")))
	if(!isnull(need_config["science_budget_floor"]))
		science_budget_floor = max(0, round(text2num("[need_config["science_budget_floor"]]")))
	if(!isnull(need_config["science_pressure_threshold"]))
		science_pressure_threshold = max(1, round(text2num("[need_config["science_pressure_threshold"]]")))

/datum/storyteller/need_analyzer/science_shortage/evaluate(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot)
	if(!istype(snapshot) || snapshot.science_staff_count <= 0)
		return

	var/science_budget = snapshot.department_money[ACCOUNT_SCI] || 0
	var/supply_gap = max(science_supply_floor - snapshot.science_supply_total, 0)
	var/budget_gap = max(science_budget_floor - science_budget, 0)
	var/pressure = (supply_gap * 5) + round(budget_gap / 400) + min(snapshot.active_round_event_count * 2, 10)
	if(pressure < science_pressure_threshold)
		return

	var/severity = min(100, pressure)
	if(snapshot.scientist_count == 1)
		severity += 8

	var/priority = severity + round(snapshot.alive_crew / 7)
	var/list/details = list(
		"science_staff_count" = snapshot.science_staff_count,
		"science_supply_total" = snapshot.science_supply_total,
		"science_budget" = science_budget,
		"crew_scale" = max(1, round(snapshot.alive_crew / 8)),
	)
	return build_report(
		severity,
		priority,
		"Research operations are running lean on components and discretionary reserves.",
		details,
	)

/datum/storyteller/need_analyzer/janitorial_overload
	id = STORYTELLER_NEED_JANITORIAL_OVERLOAD
	title = "Janitorial Overload"
	department_id = ACCOUNT_SRV
	recommended_action_family = "aid_janitorial"
	var/janitorial_cleanup_threshold = 10
	var/janitorial_supply_floor = 4

/datum/storyteller/need_analyzer/janitorial_overload/apply_tuning(list/storyteller_config)
	var/list/need_config = storyteller_config["needs"]
	if(!islist(need_config))
		return
	if(!isnull(need_config["janitorial_cleanup_threshold"]))
		janitorial_cleanup_threshold = max(1, round(text2num("[need_config["janitorial_cleanup_threshold"]]")))
	if(!isnull(need_config["janitorial_supply_floor"]))
		janitorial_supply_floor = max(1, round(text2num("[need_config["janitorial_supply_floor"]]")))

/datum/storyteller/need_analyzer/janitorial_overload/evaluate(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot)
	if(!istype(snapshot))
		return

	var/mess_score = snapshot.general_cleanable_count + (snapshot.blood_cleanable_count * 3)
	var/supply_gap = max(janitorial_supply_floor - snapshot.janitorial_supply_total, 0)
	if(mess_score < janitorial_cleanup_threshold && supply_gap <= 1)
		return

	var/severity = min(100, round((mess_score * 2) + (supply_gap * 4)))
	if(snapshot.janitor_count <= 0)
		severity += 12
	else if(snapshot.janitor_count == 1)
		severity += 6

	var/priority = severity + round(snapshot.alive_crew / 8)
	var/list/details = list(
		"general_cleanable_count" = snapshot.general_cleanable_count,
		"blood_cleanable_count" = snapshot.blood_cleanable_count,
		"janitor_count" = snapshot.janitor_count,
		"janitorial_supply_total" = snapshot.janitorial_supply_total,
		"crew_scale" = max(1, round(snapshot.alive_crew / 9)),
	)
	return build_report(
		severity,
		priority,
		"Custodial backlog is mounting across the station faster than service can clear it.",
		details,
	)
