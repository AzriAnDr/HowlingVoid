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
	var/department_id
	var/minimum_crew = 0
	var/required_department_id
	var/required_department_staff = 0
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

	if(!forced && istype(owner) && !context_data["scheduled"])
		var/conflict_reason = owner.get_scheduled_action_conflict_reason(src)
		if(conflict_reason)
			result["available"] = FALSE
			result["reason"] = conflict_reason
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
	var/population = max(snapshot?.alive_crew || 0, snapshot?.active_population || 0)
	if(population < minimum_crew)
		return list("available" = FALSE, "reason" = "Requires at least [minimum_crew] active crew")
	if(required_department_staff > 0)
		var/staff_count = 0
		if(islist(snapshot?.department_staffing))
			staff_count = snapshot.department_staffing[required_department_id] || 0
		if(staff_count < required_department_staff)
			return list("available" = FALSE, "reason" = "Required department is not staffed")
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

/datum/storyteller/action/proc/get_ui_category()
	return is_antag_action() ? "Antagonist" : "Storyteller Action"

/datum/storyteller/action/proc/get_ui_description()
	return null

/datum/storyteller/action/proc/force_execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return execute(owner, snapshot, context_data)

/datum/storyteller/action/proc/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return FALSE

/datum/storyteller/action/proc/get_storyteller_crew_scale(datum/storyteller/state_snapshot/snapshot)
	var/population = max(snapshot?.alive_crew || 0, snapshot?.active_population || 0)
	if(population >= 20)
		return 3
	if(population >= 10)
		return 2
	return 1

/datum/storyteller/action/proc/get_storyteller_department_target(datum/controller/subsystem/storyteller/owner, department_id)
	if(department_id)
		var/turf/department_target = owner.get_department_drop_target(department_id)
		if(department_target)
			return department_target
	return owner.get_common_area_drop_target()

/datum/storyteller/action/proc/get_storyteller_area_target(datum/controller/subsystem/storyteller/owner, department_id, list/area_roots)
	var/list/area_choices = list()
	if(islist(area_roots))
		for(var/area_root in area_roots)
			if(!ispath(area_root, /area))
				continue
			if(area_root in GLOB.the_station_areas)
				area_choices += area_root
			for(var/candidate in subtypesof(area_root))
				if(candidate in GLOB.the_station_areas)
					area_choices += candidate
	if(length(area_choices))
		var/turf/area_target = get_safe_random_station_turf(area_choices)
		if(area_target)
			return area_target
	return get_storyteller_department_target(owner, department_id)

/datum/storyteller/action/proc/get_storyteller_cargo_lobby_target(datum/controller/subsystem/storyteller/owner)
	var/list/area_choices = list()
	for(var/area_type in list(/area/station/cargo/lobby))
		if(area_type in GLOB.the_station_areas)
			area_choices += area_type
		for(var/candidate in subtypesof(area_type))
			if(candidate in GLOB.the_station_areas)
				area_choices += candidate
	if(length(area_choices))
		var/turf/lobby_target = get_safe_random_station_turf(area_choices)
		if(lobby_target)
			return lobby_target
	return get_storyteller_department_target(owner, ACCOUNT_CAR)

/datum/storyteller/action/proc/get_storyteller_scaled_items(list/items_by_count, scale)
	var/list/scaled_items = list()
	if(!islist(items_by_count))
		return scaled_items
	for(var/item_type in items_by_count)
		if(!ispath(item_type, /atom/movable))
			continue
		var/count = items_by_count[item_type]
		if(isnull(count))
			count = 1
		scaled_items[item_type] = max(1, round(text2num("[count]") * max(scale, 1)))
	return scaled_items

/datum/storyteller/action/proc/add_storyteller_event_brief(atom/storage_loc, paper_name, paper_text)
	if(!storage_loc || !paper_text)
		return
	var/obj/item/paper/brief = new /obj/item/paper(storage_loc)
	brief.name = paper_name || "operations brief"
	brief.add_raw_text(paper_text)

/datum/storyteller/action/proc/drop_storyteller_event_items(turf/target, list/items_by_count)
	if(!isturf(target) || !islist(items_by_count))
		return 0
	var/dropped = 0
	for(var/item_type in items_by_count)
		if(!ispath(item_type, /atom/movable))
			continue
		var/count = max(0, round(text2num("[items_by_count[item_type] || 1]")))
		for(var/i in 1 to count)
			new item_type(target)
			dropped++
	return dropped

/datum/storyteller/action/proc/is_storyteller_hostile_spawn_turf(turf/target)
	if(!isturf(target) || target.density || isgroundlessturf(target))
		return FALSE
	var/area/target_area = get_area(target)
	if(!target_area || !(target_area.area_flags & VALID_TERRITORY))
		return FALSE
	for(var/obj/obstacle in target)
		if(obstacle.density)
			return FALSE
	return TRUE

/datum/storyteller/action/proc/get_storyteller_clear_turf_near(atom/center, radius = 1)
	if(!center)
		return null
	var/list/candidates = list()
	for(var/turf/candidate in range(radius, center))
		if(is_storyteller_hostile_spawn_turf(candidate))
			candidates += candidate
	if(length(candidates))
		return pick(candidates)
	return null

/datum/storyteller/action/proc/get_storyteller_hostile_vent_target(turf/target)
	var/area/target_area = get_area(target)
	var/list/atmos_sources = list()
	if(target_area)
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in target_area.air_vents)
			var/turf/vent_turf = get_turf(vent)
			if(QDELETED(vent) || !vent_turf || vent_turf.z != target.z)
				continue
			atmos_sources += vent
		for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in target_area.air_scrubbers)
			var/turf/scrubber_turf = get_turf(scrubber)
			if(QDELETED(scrubber) || !scrubber_turf || scrubber_turf.z != target.z)
				continue
			atmos_sources += scrubber
	if(!length(atmos_sources))
		return get_storyteller_clear_turf_near(target, 2) || target
	var/atom/source = pick(atmos_sources)
	return get_storyteller_clear_turf_near(source, 1) || get_turf(source) || target

/datum/storyteller/action/proc/get_storyteller_hostile_spawn_method(mob_type)
	if(!ispath(mob_type, /mob/living))
		return null
	var/static/list/vent_mobs = typecacheof(list(
		/mob/living/basic/cockroach,
		/mob/living/basic/flesh_spider,
		/mob/living/basic/frog,
		/mob/living/basic/mouse,
		/mob/living/basic/slime,
		/mob/living/basic/snake,
		/mob/living/basic/spider/growing,
		/mob/living/simple_animal/hostile/ooze,
		/mob/living/simple_animal/hostile/scorpion,
		/mob/living/simple_animal/hostile/syndimouse,
	))
	var/static/list/pod_mobs = typecacheof(list(
		/mob/living/basic/hivebot,
		/mob/living/basic/killer_tomato,
		/mob/living/basic/mining_drone,
		/mob/living/basic/viscerator,
		/mob/living/simple_animal/hostile/plantmutant,
		/mob/living/simple_animal/hostile/trog,
	))
	var/static/list/smoke_mobs = typecacheof(list(
		/mob/living/basic/eyeball,
		/mob/living/basic/faithless,
		/mob/living/basic/ghost,
		/mob/living/basic/migo,
		/mob/living/basic/paper_wizard,
	))
	if(is_type_in_typecache(mob_type, smoke_mobs))
		return "smoke"
	if(is_type_in_typecache(mob_type, vent_mobs))
		return "vent"
	if(is_type_in_typecache(mob_type, pod_mobs))
		return "pod"
	return "pod"

/datum/storyteller/action/proc/force_storyteller_basic_hostile_ai(mob/living/basic/hostile)
	if(!istype(hostile))
		return
	QDEL_NULL(hostile.ai_controller)
	hostile.ai_controller = new /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles(hostile)
	var/datum/ai_controller/controller = hostile.ai_controller
	controller.set_blackboard_key(BB_BASIC_MOB_IDLE_WALK_CHANCE, 20)
	controller.set_blackboard_key(BB_TARGETING_STRATEGY, /datum/targeting_strategy/basic)
	controller.set_blackboard_key(BB_TARGET_MINIMUM_STAT, SOFT_CRIT)
	controller.reset_ai_status()

/datum/storyteller/action/proc/prepare_storyteller_event_hostile(mob/living/hostile, faction_id)
	if(!istype(hostile))
		return
	hostile.set_combat_mode(TRUE)
	hostile.set_faction(list(faction_id, FACTION_HOSTILE))
	hostile.set_allies(list(REF(hostile)))
	if(istype(hostile, /mob/living/basic))
		force_storyteller_basic_hostile_ai(hostile)
	if(istype(hostile, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/simple_hostile = hostile
		simple_hostile.attack_same = FALSE

/datum/storyteller/action/proc/spawn_storyteller_vent_hostile(turf/target, mob_type, faction_id)
	var/turf/spawn_turf = get_storyteller_hostile_vent_target(target)
	if(!spawn_turf)
		return null
	var/mob/living/hostile = new mob_type(spawn_turf)
	prepare_storyteller_event_hostile(hostile, faction_id)
	return hostile

/datum/storyteller/action/proc/spawn_storyteller_smoke_hostile(turf/target, mob_type, faction_id)
	var/turf/spawn_turf = get_storyteller_clear_turf_near(target, 3) || target
	if(!spawn_turf)
		return null
	var/mob/living/hostile = new mob_type(spawn_turf)
	prepare_storyteller_event_hostile(hostile, faction_id)
	return hostile

/datum/storyteller/action/proc/spawn_storyteller_pod_hostiles(turf/target, mob_type, amount, faction_id)
	var/list/spawned = list()
	if(!isturf(target) || !ispath(mob_type, /mob/living) || amount <= 0)
		return spawned
	var/turf/drop_turf = get_storyteller_clear_turf_near(target, 2) || target
	var/obj/structure/closet/supplypod/podspawn/pod = new(null, /datum/pod_style/cultist)
	pod.name = "bloody drop pod"
	pod.desc = "A blood-stained drop pod carrying unidentified hostile life signs."
	pod.specialised = TRUE
	pod.bluespace = TRUE
	pod.effectQuiet = FALSE
	pod.explosionSize = list(0, 0, 0, 0)
	pod.delays = list(POD_TRANSIT = 15 SECONDS, POD_FALLING = 4, POD_OPENING = 10, POD_LEAVING = 20)
	for(var/i in 1 to amount)
		var/mob/living/hostile = new mob_type(pod)
		prepare_storyteller_event_hostile(hostile, faction_id)
		spawned += hostile
	new /obj/effect/pod_landingzone(drop_turf, pod)
	return spawned

/datum/storyteller/action/proc/spawn_storyteller_event_hostiles(turf/target, list/mob_types, amount)
	if(!isturf(target) || !length(mob_types) || amount <= 0)
		return list("mobs" = list(), "spawn_methods" = list())
	var/list/spawned = list()
	var/list/spawn_queue = list()
	for(var/mob_type in mob_types)
		if(!ispath(mob_type, /mob/living))
			continue
		spawn_queue += mob_type
	while(length(spawn_queue) < amount)
		var/mob_type = pick(mob_types)
		if(ispath(mob_type, /mob/living))
			spawn_queue += mob_type
	if(!length(spawn_queue))
		return list("mobs" = spawned, "spawn_methods" = list())
	spawn_queue = shuffle(spawn_queue)
	var/spawned_count = 0
	var/limit = max(amount, length(mob_types))
	var/faction_id = "storyteller_hostile_site_[world.time]_[rand(1000, 9999)]"
	var/list/spawn_methods = list()
	var/list/pod_groups = list()
	var/spawned_smoke = FALSE
	for(var/mob_type as anything in spawn_queue)
		if(spawned_count >= limit)
			break
		if(!ispath(mob_type, /mob/living))
			continue
		var/spawn_method = get_storyteller_hostile_spawn_method(mob_type)
		spawn_methods[spawn_method] = TRUE
		var/mob/living/hostile
		switch(spawn_method)
			if("pod")
				pod_groups[mob_type] = (pod_groups[mob_type] || 0) + 1
			if("smoke")
				if(!spawned_smoke)
					do_smoke(3, target, target)
					spawned_smoke = TRUE
				hostile = spawn_storyteller_smoke_hostile(target, mob_type, faction_id)
				if(hostile)
					spawned += hostile
			if("vent")
				hostile = spawn_storyteller_vent_hostile(target, mob_type, faction_id)
				if(hostile)
					spawned += hostile
		spawned_count++
	for(var/mob_type in pod_groups)
		spawned += spawn_storyteller_pod_hostiles(target, mob_type, pod_groups[mob_type], faction_id)
	return list("mobs" = spawned, "spawn_methods" = spawn_methods)

/datum/storyteller/action/proc/get_storyteller_department_bitflag(department_id)
	switch(department_id)
		if(ACCOUNT_ENG)
			return DEPARTMENT_BITFLAG_ENGINEERING
		if(ACCOUNT_MED)
			return DEPARTMENT_BITFLAG_MEDICAL
		if(ACCOUNT_SCI)
			return DEPARTMENT_BITFLAG_SCIENCE
		if(ACCOUNT_SEC)
			return DEPARTMENT_BITFLAG_SECURITY
		if(ACCOUNT_SRV)
			return DEPARTMENT_BITFLAG_SERVICE
		if(ACCOUNT_CAR)
			return DEPARTMENT_BITFLAG_CARGO
		if(ACCOUNT_CMD)
			return DEPARTMENT_BITFLAG_COMMAND
	return NONE

/datum/storyteller/action/proc/get_storyteller_department_access(department_id)
	switch(department_id)
		if(ACCOUNT_ENG)
			return ACCESS_ENGINEERING
		if(ACCOUNT_MED)
			return ACCESS_MEDICAL
		if(ACCOUNT_SCI)
			return ACCESS_RESEARCH
		if(ACCOUNT_SEC)
			return ACCESS_SECURITY
		if(ACCOUNT_SRV)
			return ACCESS_SERVICE
		if(ACCOUNT_CAR)
			return ACCESS_CARGO
		if(ACCOUNT_CMD)
			return ACCESS_COMMAND
	return ACCESS_CARGO

/datum/storyteller/action/proc/get_storyteller_department_area_type(department_id)
	switch(department_id)
		if(ACCOUNT_ENG)
			return /area/station/engineering
		if(ACCOUNT_MED)
			return /area/station/medical
		if(ACCOUNT_SCI)
			return /area/station/science
		if(ACCOUNT_SEC)
			return /area/station/security
		if(ACCOUNT_SRV)
			return /area/station/service
		if(ACCOUNT_CAR)
			return /area/station/cargo
		if(ACCOUNT_CMD)
			return /area/station/command
	return /area/station/cargo

/datum/storyteller/action/proc/get_storyteller_department_secure_crate_type(department_id)
	switch(department_id)
		if(ACCOUNT_ENG)
			return /obj/structure/closet/crate/secure/engineering
		if(ACCOUNT_SCI)
			return /obj/structure/closet/crate/secure/science
		if(ACCOUNT_SEC)
			return /obj/structure/closet/crate/secure/gear
		if(ACCOUNT_CAR)
			return /obj/structure/closet/crate/secure/cargo
	return /obj/structure/closet/crate/secure

/datum/storyteller/action/proc/get_storyteller_science_techweb()
	RETURN_TYPE(/datum/techweb)
	for(var/datum/techweb/techweb as anything in SSresearch.techwebs)
		if(istype(techweb, /datum/techweb/science))
			return techweb

/datum/storyteller/action/proc/get_storyteller_tech_node_tier(datum/techweb_node/node, list/tier_cache)
	if(!istype(node))
		return 1
	if(tier_cache[node.id])
		return tier_cache[node.id]
	var/tier = 1
	for(var/prereq_id in node.prereq_ids)
		var/datum/techweb_node/prereq = SSresearch.techweb_node_by_id(prereq_id)
		if(!istype(prereq) || prereq == SSresearch.error_node)
			continue
		tier = max(tier, get_storyteller_tech_node_tier(prereq, tier_cache) + 1)
	tier_cache[node.id] = tier
	return tier

/datum/storyteller/action/proc/get_storyteller_research_cost_tier(research_cost)
	var/cost = round(text2num("[research_cost || 0]"))
	if(cost >= TECHWEB_TIER_5_POINTS)
		return 5
	if(cost >= TECHWEB_TIER_4_POINTS)
		return 4
	if(cost >= TECHWEB_TIER_3_POINTS)
		return 3
	if(cost >= TECHWEB_TIER_2_POINTS)
		return 2
	if(cost >= TECHWEB_TIER_1_POINTS)
		return 1
	return 0

/datum/storyteller/action/proc/get_storyteller_item_contract_tier(item_type)
	var/datum/stock_part/stock_part = GLOB.stock_part_datums_per_object[item_type]
	if(istype(stock_part))
		return max(1, round(stock_part.tier))
	return 1

/datum/storyteller/action/proc/get_storyteller_design_research_tier(datum/design/design, datum/techweb/techweb, list/tier_cache)
	if(!istype(design) || !istype(techweb))
		return 1
	var/tier = get_storyteller_item_contract_tier(design.build_path)
	for(var/node_id in techweb.researched_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_node_by_id(node_id)
		if(!istype(node) || node == SSresearch.error_node)
			continue
		if(!(design.id in node.design_ids))
			continue
		var/cost_tier = get_storyteller_research_cost_tier(node.research_costs[TECHWEB_POINT_TYPE_GENERIC])
		if(cost_tier)
			tier = max(tier, cost_tier)
	for(var/datum/techweb_node/node as anything in design.unlocked_by)
		if(!istype(node) || !techweb.researched_nodes[node.id])
			continue
		var/cost_tier = get_storyteller_research_cost_tier(node.research_costs[TECHWEB_POINT_TYPE_GENERIC])
		tier = max(tier, cost_tier || get_storyteller_tech_node_tier(node, tier_cache))
	return max(1, tier)

/datum/storyteller/action/proc/get_storyteller_design_contract_value(datum/design/design, research_tier)
	if(!istype(design))
		return get_storyteller_contract_unit_value(null, research_tier)
	var/material_value = 0
	for(var/material in design.materials)
		material_value += round((design.materials[material] || 0) / SHEET_MATERIAL_AMOUNT * 120)
	return max(150 + (max(research_tier, 1) * 175), material_value)

/datum/storyteller/action/proc/get_storyteller_researched_contract_pool(department_id)
	var/list/pool = list()
	var/department_flag = get_storyteller_department_bitflag(department_id)
	if(!department_flag)
		return pool
	var/datum/techweb/science_web = get_storyteller_science_techweb()
	if(!istype(science_web))
		return pool
	var/list/tier_cache = list()
	for(var/design_id in science_web.researched_designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
		if(!istype(design) || design == SSresearch.error_design)
			continue
		if(!(design.departmental_flags & department_flag))
			continue
		if(!(design.build_type & PROTOLATHE))
			continue
		if(!ispath(design.build_path, /obj/item))
			continue
		var/research_tier = get_storyteller_design_research_tier(design, science_web, tier_cache)
		var/list/requirement = make_storyteller_contract_requirement(
			design.build_path,
			1,
			research_tier,
			get_storyteller_design_contract_value(design, research_tier),
			design.name,
		)
		if(islist(requirement))
			pool += list(requirement)
	return pool

/datum/storyteller/action/proc/build_storyteller_hostile_reward_items(department_id, mob_count, list/fallback_items)
	var/list/reward_items = list()
	var/department_flag = get_storyteller_department_bitflag(department_id)
	var/datum/techweb/science_web = get_storyteller_science_techweb()
	var/list/tier_cache = list()
	var/list/researched_candidates = list()
	var/max_tier = 1
	if(istype(science_web))
		for(var/design_id in science_web.researched_designs)
			var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
			if(!istype(design) || design == SSresearch.error_design)
				continue
			if(!ispath(design.build_path, /obj/item))
				continue
			if(department_flag && !(design.departmental_flags & department_flag))
				continue
			if(!(design.build_type & (PROTOLATHE|IMPRINTER|MECHFAB|AUTOLATHE)))
				continue
			var/design_tier = get_storyteller_design_research_tier(design, science_web, tier_cache)
			max_tier = max(max_tier, design_tier)
			researched_candidates += list(list(
				"type" = design.build_path,
				"tier" = design_tier,
			))
	var/reward_rolls = clamp(round(mob_count * 1.25), 1, 10)
	if(length(researched_candidates))
		for(var/i in 1 to reward_rolls)
			var/list/chosen = pick(researched_candidates)
			var/item_type = chosen["type"]
			var/design_tier = max(1, chosen["tier"] || 1)
			reward_items[item_type] = (reward_items[item_type] || 0) + max(1, round(design_tier / 2))
	if(length(fallback_items))
		var/fallback_scale = max(1, round(mob_count / 2))
		for(var/item_type in fallback_items)
			if(!ispath(item_type, /obj/item))
				continue
			reward_items[item_type] = (reward_items[item_type] || 0) + max(1, round((fallback_items[item_type] || 1) * fallback_scale))
	return list(
		"items" = reward_items,
		"maxTier" = max_tier,
	)

/datum/storyteller/action/proc/get_storyteller_hostile_credit_reward(mob_count, research_tier, list/reward_items)
	var/item_bonus = length(reward_items) * 120
	return round((500 + (max(mob_count, 1) * 350) + (max(research_tier, 1) * 250) + item_bonus) / 10)

/datum/supply_pack/storyteller_hostile_reward
	var/reward_department_id = ACCOUNT_CAR
	var/reward_department_label = ACCOUNT_CAR_NAME

/datum/supply_pack/storyteller_hostile_reward/generate(atom/A, datum/bank_account/paying_account, crate_override)
	var/obj/structure/closet/crate/reward_crate = ..()
	if(istype(reward_crate))
		apply_reward_crate_style(reward_crate)
	return reward_crate

/datum/supply_pack/storyteller_hostile_reward/proc/apply_reward_crate_style(obj/structure/closet/crate/reward_crate)
	var/reward_icon_state
	switch(reward_department_id)
		if(ACCOUNT_ENG)
			reward_icon_state = "engi_secure_crate"
		if(ACCOUNT_MED)
			reward_icon_state = "medicalcrate"
		if(ACCOUNT_SCI)
			reward_icon_state = "scisecurecrate"
		if(ACCOUNT_SEC)
			reward_icon_state = "secgearcrate"
		if(ACCOUNT_SRV)
			reward_icon_state = "hydrosecurecrate"
		if(ACCOUNT_CAR)
			reward_icon_state = "cargo_secure"
		if(ACCOUNT_CMD, ACCOUNT_CIV)
			reward_icon_state = "centcom_secure"
	if(!reward_icon_state)
		return
	reward_crate.icon_state = reward_icon_state
	reward_crate.base_icon_state = reward_icon_state
	reward_crate.desc = "A secured [reward_department_label] reward crate."
	reward_crate.update_appearance()

/datum/storyteller/hostile_site_tracker
	var/datum/weakref/storyteller_ref
	var/action_id
	var/action_name
	var/department_id = ACCOUNT_CAR
	var/department_label = ACCOUNT_CAR_NAME
	var/area_name = "Unknown Area"
	var/list/tracked_mobs = list()
	var/list/reward_items = list()
	var/reward_credits = 0
	var/research_tier = 1
	var/reward_access = ACCESS_CARGO
	var/reward_department_area = /area/station/cargo
	var/reward_crate_type = /obj/structure/closet/crate/secure/cargo
	var/rewarded = FALSE

/datum/storyteller/hostile_site_tracker/New(
	datum/controller/subsystem/storyteller/owner,
	datum/storyteller/action/source_action,
	list/spawned_mobs,
	department_id,
	department_label,
	area_name,
	list/reward_items,
	reward_credits,
	research_tier,
	reward_access,
	reward_department_area,
	reward_crate_type,
)
	. = ..()
	storyteller_ref = WEAKREF(owner)
	action_id = source_action?.id || "storyteller_hostile_site"
	action_name = source_action?.name || "Hostile Site"
	src.department_id = department_id || ACCOUNT_CAR
	src.department_label = department_label || ACCOUNT_CAR_NAME
	src.area_name = area_name || initial(src.area_name)
	src.reward_items = islist(reward_items) ? reward_items.Copy() : list()
	src.reward_credits = max(0, round(text2num("[reward_credits || 0]")))
	src.research_tier = max(1, round(text2num("[research_tier || 1]")))
	src.reward_access = reward_access || ACCESS_CARGO
	src.reward_department_area = reward_department_area || /area/station/cargo
	src.reward_crate_type = ispath(reward_crate_type, /obj/structure/closet/crate) ? reward_crate_type : /obj/structure/closet/crate/secure
	for(var/mob/living/tracked_mob as anything in spawned_mobs)
		if(QDELETED(tracked_mob))
			continue
		tracked_mobs[REF(tracked_mob)] = WEAKREF(tracked_mob)
		RegisterSignals(tracked_mob, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(on_tracked_mob_finished))
	if(!length(tracked_mobs))
		complete_site()

/datum/storyteller/hostile_site_tracker/Destroy(force)
	for(var/mob_ref in tracked_mobs)
		var/datum/weakref/tracked_ref = tracked_mobs[mob_ref]
		var/mob/living/tracked_mob = tracked_ref?.resolve()
		if(istype(tracked_mob))
			UnregisterSignal(tracked_mob, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING))
	tracked_mobs = null
	reward_items = null
	return ..()

/datum/storyteller/hostile_site_tracker/proc/on_tracked_mob_finished(datum/source)
	SIGNAL_HANDLER
	var/mob/living/tracked_mob = source
	var/mob_ref = REF(tracked_mob)
	if(!(mob_ref in tracked_mobs))
		return
	tracked_mobs -= mob_ref
	if(istype(tracked_mob))
		UnregisterSignal(tracked_mob, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING))
	if(!length(tracked_mobs))
		complete_site()

/datum/storyteller/hostile_site_tracker/proc/complete_site()
	if(rewarded)
		return
	rewarded = TRUE
	if(reward_credits > 0)
		var/datum/bank_account/department/cargo_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(cargo_account?.adjust_money(reward_credits, "Storyteller hostile site bounty: [action_name]"))
			SSeconomy.record_grant("[action_id]_hostile_site_bounty", reward_credits, ACCOUNT_CAR)
	if(!length(reward_items))
		reward_items[/obj/item/stack/sheet/iron] = max(5, research_tier * 5)
	queue_reward_shipment()
	update_cargo_bounty_message()
	var/datum/controller/subsystem/storyteller/owner = storyteller_ref?.resolve()
	if(istype(owner))
		owner.announce_storyteller_notice(
			"[action_name] has been cleared in [area_name]. Cargo has received [reward_credits] credits and a [department_label] reward crate has been queued for the supply shuttle.",
			"Hostile Site Cleared",
			ANNOUNCER_DEPARTMENTAL,
			"green",
		)
	qdel(src)

/datum/storyteller/hostile_site_tracker/proc/queue_reward_shipment()
	var/datum/supply_pack/storyteller_hostile_reward/reward_pack = new
	reward_pack.name = "[action_name] Reward Shipment"
	reward_pack.group = "Storyteller"
	reward_pack.desc = "A secured [department_label] reward shipment for clearing [action_name]."
	reward_pack.cost = max(1, round(reward_credits / 2))
	reward_pack.contains = reward_items.Copy()
	reward_pack.crate_name = "[department_label] hostile site reward crate"
	reward_pack.crate_type = reward_crate_type
	reward_pack.access = reward_access
	reward_pack.test_ignored = TRUE
	reward_pack.reward_department_id = department_id
	reward_pack.reward_department_label = department_label
	var/datum/supply_order/disposable/reward_order = new(
		pack = reward_pack,
		orderer = "Storyteller",
		orderer_rank = "Central Command",
		orderer_ckey = null,
		reason = "Automated reward shipment for clearing [action_name].",
		paying_account = null,
		department_destination = reward_department_area,
		charge_on_purchase = FALSE,
		manifest_can_fail = FALSE,
		can_be_cancelled = FALSE,
	)
	SSshuttle.shopping_list += reward_order

/datum/storyteller/hostile_site_tracker/proc/update_cargo_bounty_message()
	var/credit_text = reward_credits > 0 ? "Cargo has received [reward_credits] credits." : "No credit bounty was issued."
	SSshuttle.centcom_message = "Hostile site cleared: [action_name] in [area_name]. [credit_text] A [department_label] reward crate has been queued for the supply shuttle."
	for(var/obj/machinery/computer/cargo/cargo_console as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/cargo))
		SStgui.update_uis(cargo_console)

/datum/storyteller/action/proc/get_storyteller_contract_requirement_type(item_type)
	if(ispath(item_type, /obj/item/stack/cable_coil))
		return /obj/item/stack/cable_coil
	if(ispath(item_type, /obj/item/stack/sheet/iron))
		return /obj/item/stack/sheet/iron
	if(ispath(item_type, /obj/item/stack/sheet/glass))
		return /obj/item/stack/sheet/glass
	if(ispath(item_type, /obj/item/stack/sheet/plasteel))
		return /obj/item/stack/sheet/plasteel
	if(ispath(item_type, /obj/item/stack/sheet/mineral/plasma))
		return /obj/item/stack/sheet/mineral/plasma
	return item_type

/datum/storyteller/action/proc/get_storyteller_contract_unit_value(item_type, tier = 1)
	if(ispath(item_type, /obj/item/stack/cable_coil))
		return 20
	if(ispath(item_type, /obj/item/stack/sheet/iron) || ispath(item_type, /obj/item/stack/sheet/glass))
		return 45
	if(ispath(item_type, /obj/item/stack/sheet/plasteel) || ispath(item_type, /obj/item/stack/sheet/mineral/plasma))
		return 120
	if(ispath(item_type, /obj/item/stock_parts))
		return 180 + (max(tier, 1) * 160)
	if(ispath(item_type, /obj/item/storage))
		return 300
	if(ispath(item_type, /obj/item/reagent_containers))
		return 180
	return 150 + (max(tier, 1) * 75)

/datum/storyteller/action/proc/make_storyteller_contract_requirement(item_type, amount = 1, tier = 1, unit_value = null, item_name = null)
	if(!ispath(item_type, /obj/item))
		return null
	var/requirement_type = get_storyteller_contract_requirement_type(item_type)
	var/final_amount = max(1, round(text2num("[amount || 1]")))
	if(ispath(item_type, /obj/item/stack))
		var/obj/item/stack/stack_path = item_type
		final_amount *= max(1, round(initial(stack_path.amount)))
	var/final_tier = max(max(1, round(text2num("[tier || 1]"))), get_storyteller_item_contract_tier(requirement_type))
	var/final_unit_value = isnull(unit_value) ? get_storyteller_contract_unit_value(requirement_type, final_tier) : max(1, round(text2num("[unit_value]")))
	var/obj/item/requirement_path = requirement_type
	return list(
		"type" = requirement_type,
		"name" = item_name || initial(requirement_path.name),
		"amount" = final_amount,
		"tier" = final_tier,
		"unit_value" = final_unit_value,
	)

/datum/storyteller/action/proc/make_storyteller_researched_contract_requirement(item_type, amount = 1)
	if(!ispath(item_type, /obj/item))
		return null
	var/datum/techweb/science_web = get_storyteller_science_techweb()
	if(!istype(science_web))
		return null
	var/list/tier_cache = list()
	for(var/design_id in science_web.researched_designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
		if(!istype(design) || design == SSresearch.error_design)
			continue
		if(design.build_path != item_type)
			continue
		var/research_tier = get_storyteller_design_research_tier(design, science_web, tier_cache)
		return make_storyteller_contract_requirement(
			item_type,
			amount,
			research_tier,
			get_storyteller_design_contract_value(design, research_tier),
			design.name
		)
	return null

/datum/storyteller/action/proc/make_storyteller_event_contract_requirement(item_type, amount = 1)
	var/list/researched_requirement = make_storyteller_researched_contract_requirement(item_type, amount)
	if(islist(researched_requirement))
		return researched_requirement
	return make_storyteller_contract_requirement(item_type, amount, 1)

/datum/storyteller/action/proc/get_storyteller_contract_pool(department_id)
	switch(department_id)
		if(ACCOUNT_ENG)
			return list(
				make_storyteller_contract_requirement(/obj/item/stack/cable_coil, 15, 1, 20),
				make_storyteller_contract_requirement(/obj/item/stack/sheet/glass, 6, 1, 45),
				make_storyteller_contract_requirement(/obj/item/stack/sheet/iron, 8, 1, 45),
				make_storyteller_contract_requirement(/obj/item/analyzer, 1, 1, 220),
				make_storyteller_contract_requirement(/obj/item/stock_parts/capacitor/adv, 1, 2, 520),
				make_storyteller_contract_requirement(/obj/item/stock_parts/power_store/cell/high, 1, 2, 550),
			)
		if(ACCOUNT_MED)
			return list(
				make_storyteller_contract_requirement(/obj/item/healthanalyzer, 1, 1, 240),
				make_storyteller_contract_requirement(/obj/item/storage/box/syringes, 1, 1, 260),
				make_storyteller_contract_requirement(/obj/item/reagent_containers/syringe, 3, 1, 100),
				make_storyteller_contract_requirement(/obj/item/reagent_containers/blood/random, 1, 2, 450),
				make_storyteller_contract_requirement(/obj/item/storage/box/medigels, 1, 2, 500),
				make_storyteller_contract_requirement(/obj/item/storage/medkit/emergency, 1, 1, 350),
			)
		if(ACCOUNT_SCI)
			return list(
				make_storyteller_contract_requirement(/obj/item/stock_parts/scanning_module, 1, 1, 320),
				make_storyteller_contract_requirement(/obj/item/stock_parts/micro_laser, 1, 1, 320),
				make_storyteller_contract_requirement(/obj/item/stock_parts/matter_bin/adv, 1, 2, 520),
				make_storyteller_contract_requirement(/obj/item/stock_parts/capacitor/super, 1, 3, 780),
				make_storyteller_contract_requirement(/obj/item/geiger_counter, 1, 2, 420),
				make_storyteller_contract_requirement(/obj/item/multitool, 1, 1, 260),
			)
		if(ACCOUNT_SEC)
			return list(
				make_storyteller_contract_requirement(/obj/item/storage/box/evidence, 1, 1, 300),
				make_storyteller_contract_requirement(/obj/item/flashlight/seclite, 1, 1, 260),
				make_storyteller_contract_requirement(/obj/item/radio, 1, 1, 180),
				make_storyteller_contract_requirement(/obj/item/clipboard, 1, 1, 160),
				make_storyteller_contract_requirement(/obj/item/stamp/denied, 1, 1, 160),
			)
		if(ACCOUNT_SRV)
			return list(
				make_storyteller_contract_requirement(/obj/item/seeds/random, 2, 1, 150),
				make_storyteller_contract_requirement(/obj/item/plant_analyzer, 1, 1, 240),
				make_storyteller_contract_requirement(/obj/item/reagent_containers/cup/bottle/nutrient/ez, 1, 1, 260),
				make_storyteller_contract_requirement(/obj/item/storage/box/donkpockets, 1, 1, 300),
				make_storyteller_contract_requirement(/obj/item/soap/nanotrasen, 1, 1, 180),
				make_storyteller_contract_requirement(/obj/item/storage/bag/trash, 1, 1, 220),
			)
		if(ACCOUNT_CAR)
			return list(
				make_storyteller_contract_requirement(/obj/item/stack/sheet/iron, 10, 1, 45),
				make_storyteller_contract_requirement(/obj/item/stack/sheet/glass, 8, 1, 45),
				make_storyteller_contract_requirement(/obj/item/stack/cable_coil, 20, 1, 20),
				make_storyteller_contract_requirement(/obj/item/multitool, 1, 1, 260),
				make_storyteller_contract_requirement(/obj/item/stock_parts/capacitor, 1, 1, 320),
				make_storyteller_contract_requirement(/obj/item/paper/requisition, 2, 1, 100),
			)
		if(ACCOUNT_CMD, ACCOUNT_CIV)
			return list(
				make_storyteller_contract_requirement(/obj/item/paper/requisition, 2, 1, 100),
				make_storyteller_contract_requirement(/obj/item/clipboard, 1, 1, 160),
				make_storyteller_contract_requirement(/obj/item/stamp/granted, 1, 1, 160),
				make_storyteller_contract_requirement(/obj/item/camera, 1, 1, 240),
				make_storyteller_contract_requirement(/obj/item/camera_film, 1, 1, 180),
				make_storyteller_contract_requirement(/obj/item/radio, 1, 1, 180),
			)
	return get_storyteller_contract_pool(ACCOUNT_CAR)

/datum/storyteller/action/proc/add_storyteller_contract_requirement(list/requirements, list/seen_types, list/requirement)
	if(!islist(requirements) || !islist(seen_types) || !islist(requirement))
		return FALSE
	var/item_type = requirement["type"]
	if(!item_type || seen_types[item_type])
		return FALSE
	seen_types[item_type] = TRUE
	requirements += list(requirement)
	return TRUE

/datum/storyteller/action/proc/get_storyteller_researched_event_contract_pool(list/items_by_count)
	var/list/requirements = list()
	var/list/seen_types = list()
	if(!length(items_by_count))
		return requirements
	for(var/item_type in items_by_count)
		var/base_amount = max(1, round(text2num("[items_by_count[item_type] || 1]")))
		add_storyteller_contract_requirement(
			requirements,
			seen_types,
			make_storyteller_researched_contract_requirement(item_type, base_amount)
		)
	return requirements

/datum/storyteller/action/proc/build_storyteller_contract_requirements(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, department_id, list/items_by_count, list/research_items_by_count)
	var/scale = get_storyteller_crew_scale(snapshot)
	var/target_department = department_id || owner.select_relief_department(snapshot) || ACCOUNT_CAR

	var/list/event_requirements = list()
	var/list/event_seen_types = list()
	if(length(items_by_count))
		for(var/item_type in items_by_count)
			var/base_amount = max(1, round(text2num("[items_by_count[item_type] || 1]")))
			add_storyteller_contract_requirement(
				event_requirements,
				event_seen_types,
				make_storyteller_event_contract_requirement(item_type, base_amount)
			)

	var/list/pool = list()
	var/list/pool_seen_types = list()
	for(var/list/requirement as anything in event_requirements)
		add_storyteller_contract_requirement(pool, pool_seen_types, requirement)
	if(length(event_requirements))
		for(var/list/requirement as anything in get_storyteller_researched_event_contract_pool(research_items_by_count))
			add_storyteller_contract_requirement(pool, pool_seen_types, requirement)
	else
		for(var/list/requirement as anything in get_storyteller_researched_contract_pool(target_department))
			add_storyteller_contract_requirement(pool, pool_seen_types, requirement)
		for(var/list/requirement as anything in get_storyteller_contract_pool(target_department))
			add_storyteller_contract_requirement(pool, pool_seen_types, requirement)
	if(!length(pool))
		return list()

	var/staff_count = 0
	if(islist(snapshot?.department_staffing))
		staff_count = snapshot.department_staffing[target_department] || 0
	var/event_type_count = length(event_requirements)
	var/requested_types = clamp(event_type_count + round(staff_count / 2) + (scale - 1), event_type_count, min(6, length(pool)))
	if(!event_type_count)
		requested_types = clamp(2 + round(staff_count / 2) + (scale - 1), 2, min(6, length(pool)))
	var/quantity_multiplier = max(1, scale + round(staff_count / 3))

	var/list/requirements = list()
	var/list/selected_seen_types = list()
	for(var/list/requirement as anything in event_requirements)
		if(!islist(requirement))
			continue
		requirement = requirement.Copy()
		add_storyteller_contract_requirement(requirements, selected_seen_types, requirement)

	var/list/randomized_pool = shuffle(pool.Copy())
	for(var/list/requirement as anything in randomized_pool)
		if(length(requirements) >= requested_types)
			break
		if(!islist(requirement))
			continue
		requirement = requirement.Copy()
		if(!add_storyteller_contract_requirement(requirements, selected_seen_types, requirement))
			continue

	for(var/list/requirement as anything in requirements)
		var/research_tier = max(1, requirement["tier"] || 1)
		var/tier_quantity_scale = max(1, round(quantity_multiplier / max(research_tier, 1)))
		requirement["amount"] = max(1, round((requirement["amount"] || 1) * tier_quantity_scale))
	return requirements

/datum/storyteller/action/proc/get_storyteller_contract_manifest_text(list/requirements)
	var/list/manifest_entries = list()
	for(var/list/requirement as anything in requirements)
		if(!islist(requirement))
			continue
		var/amount = max(1, round(text2num("[requirement["amount"] || 1]")))
		manifest_entries += "[amount]x [requirement["name"] || "unknown item"]"
	return jointext(manifest_entries, ", ")

/datum/storyteller/action/proc/get_storyteller_contract_summary(base_message, list/requirements)
	var/manifest_text = get_storyteller_contract_manifest_text(requirements)
	if(!manifest_text)
		return base_message
	return "Requested manifest: [manifest_text]. Deliver the listed items to the Cargo lobby pickup pod for Cargo payment."

/datum/storyteller/action/proc/get_storyteller_contract_reward(list/requirements)
	var/total = 0
	for(var/list/requirement as anything in requirements)
		var/amount = max(1, round(text2num("[requirement["amount"] || 1]")))
		var/tier = max(1, round(text2num("[requirement["tier"] || 1]")))
		var/unit_value = max(1, round(text2num("[requirement["unit_value"] || 100]")))
		total += round(amount * unit_value * (1 + ((tier - 1) * 0.5)))
	return round(max(total, 750), 50)

/datum/storyteller/action/proc/to_ui_data(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/list/availability = get_availability(owner, snapshot, context_data)
	return list(
		"id" = id,
		"name" = name,
		"type" = "[type]",
		"category" = get_ui_category(),
		"description" = get_ui_description(),
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

/datum/storyteller/action/dynamic_base/get_effective_weight(datum/controller/subsystem/storyteller/owner)
	var/base_weight = ..()
	if(base_weight <= 0 || !istype(owner))
		return base_weight

	var/readiness_score = owner.get_antag_readiness_score(context)
	var/readiness_ratio = clamp(readiness_score / 100, 0, 1)
	var/harshness = clamp(((stage - 1) * 0.4) + (max(cost - 12, 0) / 24), 0.1, 1.5)
	var/base_scale = 0.55 + (readiness_ratio * 0.75)
	var/quality_scale = 1 + ((readiness_ratio - 0.5) * (0.25 + (harshness * 0.55)))
	return max(1, round(base_weight * clamp(base_scale * quality_scale, 0.25, 2)))

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
		owner.record_decision("Roundstart [name] preparation failed: [ruleset.log_data || "unknown reason"]", owner.build_dynamic_ruleset_trace_data(ruleset, population_size, length(antag_candidates), list("selection_context" = STORYTELLER_CONTEXT_ROUNDSTART), ruleset.selected_minds))
		qdel(ruleset)
		return null
	return ruleset

/datum/storyteller/action/dynamic_roundstart/proc/execute_prepared_action(datum/controller/subsystem/storyteller/owner, datum/dynamic_ruleset/roundstart/ruleset)
	if(!istype(ruleset))
		return FALSE
	ruleset.execute()
	owner.track_dynamic_ruleset(ruleset)
	owner.record_action_execution(src, "Roundstart minds: [owner.format_selected_minds(ruleset.selected_minds)]", spend_budget = FALSE, extra_data = owner.build_dynamic_ruleset_trace_data(ruleset, length(ruleset.selected_minds), length(ruleset.selected_minds), list("selection_context" = STORYTELLER_CONTEXT_ROUNDSTART), ruleset.selected_minds))
	return TRUE

/datum/storyteller/action/dynamic_roundstart/force_execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(SSticker.current_state > GAME_STATE_SETTING_UP)
		return FALSE
	if(!owner.queue_dynamic_ruleset_action(src, context_data["admin_user"], !!context_data["force"]))
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
		owner.record_decision("Latejoin [name] failed: [running.log_data || "unknown reason"]", owner.build_dynamic_ruleset_trace_data(running, player_count, 1, context_data, running.selected_minds))
		qdel(running)
		return FALSE

	running.execute()
	owner.track_dynamic_ruleset(running)
	owner.note_latejoin_hostile_trigger()
	owner.record_action_execution(src, "Latejoin target: [key_name(latejoiner)]", extra_data = owner.build_dynamic_ruleset_trace_data(running, player_count, 1, context_data, running.selected_minds))
	return TRUE

/datum/storyteller/action/dynamic_latejoin/force_execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(!owner.queue_dynamic_ruleset_action(src, context_data["admin_user"], !!context_data["force"]))
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
		owner.record_decision("Midround [name] failed: [running.log_data || "unknown reason"]", owner.build_dynamic_ruleset_trace_data(running, player_count, length(candidates), context_data, running.selected_minds))
		qdel(running)
		return FALSE

	running.execute()
	owner.track_dynamic_ruleset(running)
	owner.record_action_execution(src, "Midround minds: [owner.format_selected_minds(running.selected_minds)]", extra_data = owner.build_dynamic_ruleset_trace_data(running, player_count, length(candidates), context_data, running.selected_minds))
	return TRUE

/datum/storyteller/action/dynamic_midround/force_execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/mob/admin = context_data["admin_user"]
	if(!SSdynamic.force_run_midround(dynamic_ruleset_type, alert_admins_on_fail = TRUE, admin = admin, bypass_preference_checks = !!context_data["force"]))
		return FALSE
	owner.record_action_execution(src, "Forced midround execution", spend_budget = FALSE, extra_data = owner.build_storyteller_trace_data(list(
		"action" = owner.get_storyteller_action_trace_data(src),
		"dynamicRulesetType" = "[dynamic_ruleset_type]",
		"forced" = TRUE,
	), snapshot, context_data))
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

/datum/storyteller/action/random_event/get_ui_category()
	return "Round Event"

/datum/storyteller/action/random_event/get_ui_description()
	return "Runs the linked station round event through the storyteller schedule."

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
	owner.record_action_execution(src, extra_data = owner.build_storyteller_trace_data(list(
		"eventControlType" = "[event_control_type]",
	), snapshot, context_data))
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
	var/dispatch_message
	var/modifier_multiplier = 1
	var/modifier_is_positive = TRUE

/datum/storyteller/action/timed_modifier/get_ui_category()
	return "Timed Modifier"

/datum/storyteller/action/timed_modifier/get_ui_description()
	return dispatch_message || "Applies a temporary storyteller modifier to the station."

/datum/storyteller/action/timed_modifier/check_additional_availability(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(modifier_id && owner.has_active_modifier(modifier_id))
		return list("available" = FALSE, "reason" = "Conflicting storyteller modifier already active")
	return ..()

/datum/storyteller/action/timed_modifier/proc/get_modifier_duration(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return rand(min_duration, max(max_duration, min_duration))

/datum/storyteller/action/timed_modifier/proc/get_modifier_multiplier(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	return modifier_multiplier

/datum/storyteller/action/timed_modifier/proc/get_modifier_label(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return "[modifier_title || name]"

/datum/storyteller/action/timed_modifier/proc/get_modifier_description(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	return get_dispatch_message(owner, snapshot, context_data, modifier_multiplier, duration)

/datum/storyteller/action/timed_modifier/proc/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	if(dispatch_message)
		return dispatch_message
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
	var/waste_percent = round((clamp(1 + ((1 - modifier_multiplier) * 0.7), 1, 1.35) - 1) * 100)
	return "The crystal has drifted into an unstable harmonic band. Grid output is [loss_percent]% below baseline, waste output is elevated by [waste_percent]%, and internal wear is accumulating faster than normal."

/datum/storyteller/action/negative/timed_modifier/engineering_power_instability/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data, modifier_multiplier, duration)
	var/waste_multiplier = round(clamp(1 + ((1 - modifier_multiplier) * 0.7), 1, 1.35), 0.01)
	return "Engine telemetry has entered an unstable band. Supermatter efficiency is reduced to [round(modifier_multiplier, 0.01)]x, waste output is elevated to [waste_multiplier]x, and crystal wear is rising for [DisplayTimeText(duration, round_seconds_to = 1)]."

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

/datum/storyteller/action/positive/adaptive_pod/get_ui_category()
	return "Relief Pod"

/datum/storyteller/action/positive/adaptive_pod/get_ui_description()
	return "Launches a supply pod for a matching storyteller need. The contents are chosen from the detected department problem."

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
	owner.announce_storyteller_notice(owner.append_storyteller_landing_zone(get_dispatch_message(owner, report), target), dispatch_title, dispatch_sound, dispatch_color)
	owner.record_action_execution(src, "Scheduled adaptive relief pod for [report.title]")
	return TRUE

/datum/storyteller/action/positive/department_supply_pod
	parent_type = /datum/storyteller/action/positive/adaptive_pod
	id = "aid_department_supply_pod"
	name = "Engineering Relief Pod"
	family = "aid_department"
	cost = 12
	weight = 9
	supported_need_ids = list(STORYTELLER_NEED_ENGINEERING_REPAIRS)

/datum/storyteller/action/positive/food_relief_pod
	parent_type = /datum/storyteller/action/positive/adaptive_pod
	id = "aid_food_relief_pod"
	name = "Food Relief Pod"
	family = "aid_kitchen"
	cost = 12
	weight = 9
	supported_need_ids = list(STORYTELLER_NEED_FOOD_SHORTAGE)
	dispatch_title = "Service Relief Dispatch"
	dispatch_sound = 'sound/announcer/notice/notice2.ogg'

/datum/storyteller/action/positive/food_relief_pod/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/need_report/report)
	return "Emergency ration reserves have been rerouted to the service wing."

/datum/storyteller/action/positive/department_supply_pod/get_dispatch_message(datum/controller/subsystem/storyteller/owner, datum/storyteller/need_report/report)
	if(!istype(report))
		return ..()
	if(report.id == STORYTELLER_NEED_ENGINEERING_REPAIRS)
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
		owner.append_storyteller_landing_zone("A morale package has been cleared for common-area delivery. Productivity enhancement is encouraged.", target),
		"Morale Dispatch",
		'sound/announcer/notice/notice2.ogg',
		"green",
	)
	owner.record_action_execution(src, "Scheduled morale pod for a common area")
	return TRUE

// Station event backlog. These actions intentionally use existing HV content only.
/datum/storyteller/action/positive/event_contract_pod
	cost = 7
	weight = 4
	allow_in_extended = TRUE
	var/list/items_by_count = list()
	var/list/research_items_by_count = list()
	var/dispatch_title = "Station Operations Notice"
	var/dispatch_message = "A station objective is available."
	var/dispatch_sound = 'sound/announcer/notice/notice2.ogg'
	var/dispatch_color = "green"
	var/crate_name = "operations package"
	var/crate_desc = "A small package routed by the storyteller operations desk."
	var/paper_name = "operations brief"
	var/paper_text
	var/contract_duration_min = 10 MINUTES
	var/contract_duration_max = 15 MINUTES

/datum/storyteller/action/positive/event_contract_pod/get_ui_category()
	return "Contract Pod"

/datum/storyteller/action/positive/event_contract_pod/get_ui_description()
	return dispatch_message

/datum/storyteller/action/positive/event_contract_pod/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/contract_department = department_id || owner.select_relief_department(snapshot) || ACCOUNT_CAR
	var/list/requirements = build_storyteller_contract_requirements(owner, snapshot, contract_department, items_by_count, research_items_by_count)
	if(!length(requirements))
		return FALSE
	var/turf/target = get_storyteller_cargo_lobby_target(owner)
	if(!target)
		return FALSE
	var/obj/structure/closet/supplypod/storyteller_contract/pod = new(null, /datum/pod_style/box)
	var/list/pod_delays = list()
	if(islist(pod.delays))
		var/list/existing_delays = pod.delays
		pod_delays = existing_delays.Copy()
	pod_delays[POD_TRANSIT] = owner.get_storyteller_contract_pod_transit_delay()
	pod.delays = pod_delays
	var/reward_amount = get_storyteller_contract_reward(requirements)
	var/contract_summary = get_storyteller_contract_summary(dispatch_message, requirements)
	pod.setup_contract(name, contract_summary, contract_department, requirements, reward_amount, rand(contract_duration_min, contract_duration_max))
	var/obj/effect/pod_landingzone/landingzone = new(target, pod)
	if(!istype(landingzone))
		qdel(pod)
		return FALSE
	var/eta = max((pod.delays[POD_TRANSIT] || 0) + (pod.delays[POD_FALLING] || 0), 0)
	owner.track_pending_pod_delivery(
		landingzone,
		target,
		ACCOUNT_CAR,
		name,
		"Pickup contract: [owner.get_department_label(contract_department)] items for [reward_amount] credits.",
		eta,
	)
	owner.announce_storyteller_notice(
		owner.append_storyteller_landing_zone("[contract_summary] The pickup window will close automatically if the pod is not dispatched in time.", target),
		dispatch_title,
		dispatch_sound,
		dispatch_color,
	)
	owner.record_action_execution(src, "Scheduled contract pickup pod at [owner.get_storyteller_drop_area_name(target)] for [reward_amount] credits")
	return TRUE

/datum/storyteller/action/negative/event_contract_pod
	parent_type = /datum/storyteller/action/positive/event_contract_pod
	polarity = STORYTELLER_POLARITY_NEGATIVE
	dispatch_color = "orange"
	dispatch_sound = 'sound/announcer/notice/notice1.ogg'
	extended_weight = 1

/datum/storyteller/action/negative/event_contract_pod/get_ui_category()
	return "Contract Pod"

/datum/storyteller/action/negative/event_contract_pod/get_ui_description()
	return dispatch_message

/datum/storyteller/action/positive/department_budget_notice
	cost = 7
	weight = 4
	allow_in_extended = TRUE
	var/budget_amount = 0
	var/dispatch_title = "Station Operations Notice"
	var/dispatch_message = "A station objective is available."
	var/dispatch_sound = 'sound/announcer/notice/notice2.ogg'
	var/dispatch_color = "green"

/datum/storyteller/action/positive/department_budget_notice/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	if(department_id && budget_amount)
		var/final_budget = budget_amount * get_storyteller_crew_scale(snapshot)
		if(!owner.grant_department_budget(department_id, final_budget, name))
			return FALSE
		if(final_budget > 0)
			SSeconomy.record_grant(id, final_budget, department_id)
	owner.announce_storyteller_notice(dispatch_message, dispatch_title, dispatch_sound, dispatch_color)
	owner.record_action_execution(src, "Applied department budget notice")
	return TRUE

/datum/storyteller/action/positive/department_budget_notice/get_ui_description()
	return dispatch_message

/datum/storyteller/action/negative/department_budget_notice
	parent_type = /datum/storyteller/action/positive/department_budget_notice
	polarity = STORYTELLER_POLARITY_NEGATIVE
	dispatch_color = "orange"
	dispatch_sound = 'sound/announcer/notice/notice1.ogg'
	extended_weight = 1

/datum/storyteller/action/negative/hostile_site
	cost = 7
	weight = 4
	allow_in_extended = TRUE
	extended_weight = 1
	var/list/area_roots = list(/area/station/maintenance)
	var/list/mob_types = list(/mob/living/simple_animal/hostile/syndimouse)
	var/list/reward_items = list()
	var/base_mobs = 1
	var/max_mobs = 3
	var/dispatch_title = "Station Alert"
	var/dispatch_message = "A localized hostile site has been reported."
	var/dispatch_sound = 'sound/announcer/notice/notice1.ogg'
	var/dispatch_color = "orange"

/datum/storyteller/action/negative/hostile_site/get_ui_category()
	return "Hostile Site"

/datum/storyteller/action/negative/hostile_site/get_ui_description()
	return dispatch_message

/datum/storyteller/action/negative/hostile_site/proc/get_hostile_site_dispatch(datum/controller/subsystem/storyteller/owner, turf/target, list/spawn_methods)
	var/area_name = owner.get_storyteller_drop_area_name(target)
	if(!length(spawn_methods))
		return "[dispatch_message] Activity zone: [area_name]."
	var/list/source_names = list()
	if(spawn_methods["vent"])
		source_names += "vent and scrubber traces"
	if(spawn_methods["pod"])
		source_names += "bloody drop pods"
	if(spawn_methods["smoke"])
		source_names += "localized smoke manifestation"
	if(length(source_names) > 1)
		return "[dispatch_message] Activity zone: [area_name]. Sources include [jointext(source_names, ", ")]."
	if(spawn_methods["vent"])
		return "[dispatch_message] Vent and scrubber traces point to [area_name]."
	if(spawn_methods["pod"])
		return "[dispatch_message] Drop zone: [area_name]. Bloody pods are inbound."
	if(spawn_methods["smoke"])
		return "[dispatch_message] Manifestation site: [area_name]. A smoke anomaly is forming."
	return "[dispatch_message] Activity zone: [area_name]."

/datum/storyteller/action/negative/hostile_site/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/turf/target = get_storyteller_area_target(owner, department_id, area_roots)
	if(!target)
		return FALSE
	var/security_staff = max(snapshot?.security_staff_count || 0, 0)
	var/minimum_mobs = 1
	if(length(mob_types))
		minimum_mobs = length(mob_types)
	var/spawn_count = max(minimum_mobs, clamp(base_mobs + max(security_staff - 1, 0), 1, max_mobs))
	var/list/spawn_result = spawn_storyteller_event_hostiles(target, mob_types, spawn_count)
	var/list/spawned_mobs = spawn_result["mobs"]
	var/list/spawn_methods = spawn_result["spawn_methods"]
	var/spawned = length(spawned_mobs)
	if(spawned <= 0)
		return FALSE
	var/reward_department = department_id || ACCOUNT_CAR
	var/list/reward_data = build_storyteller_hostile_reward_items(reward_department, spawned, reward_items)
	var/list/queued_reward_items = reward_data["items"]
	var/research_tier = reward_data["maxTier"] || 1
	var/credit_reward = get_storyteller_hostile_credit_reward(spawned, research_tier, queued_reward_items)
	var/area/target_area = get_area(target)
	var/department_label = owner.get_department_label(reward_department)
	new /datum/storyteller/hostile_site_tracker(
		owner,
		src,
		spawned_mobs,
		reward_department,
		department_label,
		target_area?.name || "Unknown Area",
		queued_reward_items,
		credit_reward,
		research_tier,
		get_storyteller_department_access(reward_department),
		get_storyteller_department_area_type(reward_department),
		get_storyteller_department_secure_crate_type(reward_department),
	)
	owner.announce_storyteller_alert(get_hostile_site_dispatch(owner, target, spawn_methods), dispatch_title, dispatch_sound, dispatch_color)
	var/list/spawn_method_names = list()
	for(var/spawn_method in spawn_methods)
		spawn_method_names += spawn_method
	owner.record_action_execution(src, "Spawned [spawned] hostiles by [jointext(spawn_method_names, ", ")] at [owner.get_storyteller_drop_area_name(target)]; reward snapshot tier [research_tier], [credit_reward] cargo credits")
	return TRUE

/datum/storyteller/action/positive/event_contract_pod/emergency_maintenance_contract
	id = "station_emergency_maintenance_contract"
	name = "Emergency Maintenance Contract"
	family = "station_global_repair"
	minimum_crew = 3
	department_id = ACCOUNT_ENG
	items_by_count = list(/obj/item/stack/cable_coil/thirty = 1, /obj/item/stack/sheet/iron/ten = 1, /obj/item/stack/sheet/glass = 1, /obj/item/lightreplacer = 1, /obj/item/multitool = 1)
	research_items_by_count = list(/obj/item/weldingtool/experimental = 1, /obj/item/analyzer/ranged = 1, /obj/item/storage/part_replacer = 1, /obj/item/storage/part_replacer/bluespace = 1, /obj/item/lightreplacer/blue = 1)
	dispatch_title = "Maintenance Contract"
	dispatch_message = "Central Command has opened a maintenance pickup contract. Deliver repair tools and materials to the Cargo lobby pickup pod for Cargo payment."
	crate_name = "maintenance contract crate"
	crate_desc = "A small repair crate for a station maintenance contract."
	paper_text = "Emergency Maintenance Contract: repair visible station damage and log completion through Engineering or Command."

/datum/storyteller/action/negative/hostile_site/void_echo_front
	id = "station_void_echo_front"
	name = "Void Echo Front"
	family = "station_void_pve"
	cost = 8
	weight = 4
	stage = 2
	mob_types = list(/mob/living/basic/migo, /mob/living/basic/ghost, /mob/living/basic/eyeball, /mob/living/basic/flesh_spider)
	reward_items = list(/obj/item/paper = 1, /obj/item/geiger_counter = 1)
	base_mobs = 1
	max_mobs = 3
	dispatch_title = "Void Echo Front"
	dispatch_message = "Weak void signatures have surfaced in maintenance. Security should clear the site while Science recovers any residue."

/datum/storyteller/action/positive/event_contract_pod/atmospheric_recall_drill
	id = "station_atmospheric_recall_drill"
	name = "Atmospheric Recall Drill"
	family = "station_atmos_drill"
	department_id = ACCOUNT_ENG
	items_by_count = list(/obj/item/analyzer = 1, /obj/item/tank/internals/emergency_oxygen/engi = 1, /obj/item/extinguisher = 1)
	research_items_by_count = list(/obj/item/analyzer/ranged = 1, /obj/item/gas_filter = 1, /obj/item/gas_filter/plasmaman = 1, /obj/item/construction/plumbing/engineering = 1)
	dispatch_title = "Atmospheric Recall Drill"
	dispatch_message = "An atmosphere verification contract is open. Deliver inspection and emergency response gear to the Cargo lobby pickup pod for Cargo payment."
	crate_name = "atmospheric recall crate"
	crate_desc = "A compact kit for a station atmosphere verification drill."
	paper_text = "Atmospheric Recall Drill: verify suspicious air alarms, close false positives, and report real leaks."

/datum/storyteller/action/positive/department_budget_notice/nanotrasen_efficiency_audit
	id = "station_nanotrasen_efficiency_audit"
	name = "Nanotrasen Efficiency Audit"
	family = "station_social_global"
	minimum_crew = 3
	department_id = ACCOUNT_CMD
	budget_amount = 1200
	dispatch_title = "Efficiency Audit"
	dispatch_message = "Nanotrasen has opened a low-intensity efficiency audit. Departments are encouraged to trade quick deliverables; Command receives a coordination grant."

/datum/storyteller/action/negative/event_contract_pod/bluespace_static_season
	id = "station_bluespace_static_season"
	name = "Bluespace Static Season"
	family = "station_bluespace_static"
	cost = 6
	weight = 3
	dispatch_title = "Bluespace Static"
	dispatch_message = "Minor bluespace static is swapping loose station items between nearby public areas. Secure sensitive equipment until the season passes."

/datum/storyteller/action/negative/event_contract_pod/bluespace_static_season/get_ui_category()
	return "Ambient Event"

/datum/storyteller/action/negative/event_contract_pod/bluespace_static_season/execute(datum/controller/subsystem/storyteller/owner, datum/storyteller/state_snapshot/snapshot, list/context_data)
	var/scale = get_storyteller_crew_scale(snapshot)
	var/list/candidates = list()
	for(var/obj/item/item as anything in world)
		if(QDELETED(item) || item.anchored || !isturf(item.loc) || !is_station_level(item.z))
			continue
		candidates += item
	if(!length(candidates))
		return FALSE
	var/moved = 0
	var/target_count = min(length(candidates), 3 + (scale * 2))
	for(var/i in 1 to target_count)
		var/obj/item/chosen = pick_n_take(candidates)
		var/turf/target = owner.get_common_area_drop_target()
		if(!target)
			continue
		chosen.forceMove(target)
		moved++
	if(moved <= 0)
		return FALSE
	owner.announce_storyteller_notice(dispatch_message, dispatch_title, dispatch_sound, dispatch_color)
	owner.record_action_execution(src, "Displaced [moved] loose items")
	return TRUE

/datum/storyteller/action/negative/department_budget_notice/stationwide_supply_recall
	id = "station_stationwide_supply_recall"
	name = "Stationwide Supply Recall"
	family = "station_supply_recall"
	department_id = ACCOUNT_CAR
	budget_amount = -600
	dispatch_title = "Supply Recall"
	dispatch_message = "Several routine consumable lots have been marked for recall. Cargo may replace the affected stock or absorb a small logistics penalty."

/datum/storyteller/action/negative/timed_modifier/auxiliary_power_rationing
	id = "station_auxiliary_power_rationing"
	name = "Auxiliary Power Rationing"
	family = "station_power_rationing"
	department_id = ACCOUNT_ENG
	required_department_id = ACCOUNT_ENG
	required_department_staff = 1
	modifier_id = STORYTELLER_MOD_ENGINEERING_POWER
	modifier_multiplier = 0.85
	min_duration = 7 MINUTES
	max_duration = 7 MINUTES
	modifier_title = "Auxiliary Power Rationing"
	dispatch_title = "Power Rationing"
	dispatch_message = "Auxiliary power has entered a rationing window. Engineering can stabilize the grid while machines run at reduced efficiency."

/datum/storyteller/action/positive/department_budget_notice/civil_defense_broadcast
	id = "station_civil_defense_broadcast"
	name = "Civil Defense Broadcast"
	family = "station_social_global"
	minimum_crew = 3
	department_id = ACCOUNT_CMD
	budget_amount = 700
	dispatch_title = "Civil Defense Broadcast"
	dispatch_message = "A civil defense drill is active. Crew should check in at public safe zones; Command receives a morale coordination grant."

/datum/storyteller/action/negative/hostile_site/maintenance_pressure_sweep
	id = "station_maintenance_pressure_sweep"
	name = "Maintenance Pressure Sweep"
	family = "station_maintenance_pve"
	cost = 8
	weight = 5
	mob_types = list(/mob/living/basic/mouse/rat, /mob/living/simple_animal/hostile/syndimouse, /mob/living/simple_animal/hostile/scorpion, /mob/living/basic/cockroach/sewer, /mob/living/basic/snake/banded, /mob/living/basic/spider/growing/spiderling/hunter)
	reward_items = list(/obj/item/stack/cable_coil = 1, /obj/item/stack/sheet/iron/ten = 1)
	base_mobs = 1
	max_mobs = 4
	dispatch_title = "Maintenance Pressure Sweep"
	dispatch_message = "Hostile maintenance lifeforms and pressure leak indicators have been reported. Security and Engineering should sweep the marked sector."

/datum/storyteller/action/positive/timed_modifier/rare_materials_window
	id = "station_rare_materials_window"
	name = "Rare Materials Window"
	family = "station_mining_window"
	department_id = ACCOUNT_CAR
	required_department_id = ACCOUNT_CAR
	required_department_staff = 1
	modifier_id = STORYTELLER_MOD_CARGO_PROCESSING
	modifier_multiplier = 1.25
	min_duration = 8 MINUTES
	max_duration = 8 MINUTES
	modifier_title = "Rare Materials Window"
	dispatch_title = "Mining Window"
	dispatch_message = "Mining scanners report a short rare-materials window. Mining and Cargo gain improved processing returns for a limited time."

/datum/storyteller/action/positive/event_contract_pod/station_insurance_inspection
	id = "station_station_insurance_inspection"
	name = "Station Insurance Inspection"
	family = "station_social_global"
	minimum_crew = 2
	department_id = ACCOUNT_CMD
	items_by_count = list(/obj/item/camera = 1, /obj/item/camera_film = 2, /obj/item/clipboard = 1, /obj/item/stamp/granted = 1)
	research_items_by_count = list(/obj/item/hand_labeler = 1, /obj/item/hand_labeler_refill = 1)
	dispatch_title = "Insurance Inspection"
	dispatch_message = "Station insurance is buying inspection documentation. Deliver cameras, film, and stamped paperwork to the Cargo lobby pickup pod."
	crate_name = "insurance inspection crate"
	paper_text = "Station Insurance Inspection: photograph intact departments, collect signatures, and forward the packet through Command."

/datum/storyteller/action/negative/event_contract_pod/comms_relay_misroute
	parent_type = /datum/storyteller/action/negative/event_contract_pod
	id = "station_comms_relay_misroute"
	name = "Comms Relay Misroute"
	polarity = STORYTELLER_POLARITY_NEGATIVE
	family = "station_comms_fault"
	department_id = ACCOUNT_ENG
	items_by_count = list(/obj/item/radio = 1, /obj/item/multitool = 1)
	research_items_by_count = list(/obj/item/multitool/circuit = 1, /obj/item/stock_parts/subspace/analyzer = 1, /obj/item/stock_parts/subspace/transmitter = 1)
	dispatch_color = "orange"
	dispatch_sound = 'sound/announcer/notice/notice1.ogg'
	dispatch_title = "Comms Misroute"
	dispatch_message = "A telecomms relay audit contract is open. Deliver radio reset equipment to the Cargo lobby pickup pod for Cargo payment."
	crate_name = "relay reset crate"
	paper_text = "Comms Relay Misroute: inspect telecomms relays, reset suspicious routing points, and report clean channels."

/datum/storyteller/action/negative/hostile_site/cargo_crate_stowaways
	id = "station_cargo_crate_stowaways"
	name = "Cargo Crate Stowaways"
	family = "station_cargo_pve"
	department_id = ACCOUNT_CAR
	area_roots = list(/area/station/cargo)
	mob_types = list(/mob/living/basic/mouse/rat, /mob/living/simple_animal/hostile/syndimouse, /mob/living/basic/cockroach/hauberoach, /mob/living/basic/frog/crazy)
	reward_items = list(/obj/item/paper/requisition = 1)
	base_mobs = 1
	max_mobs = 3
	dispatch_title = "Cargo Stowaways"
	dispatch_message = "A suspicious Cargo delivery contains hostile stowaways. Cargo should open crates carefully and request Security support."

/datum/storyteller/action/negative/hostile_site/warehouse_spoilage_bloom
	id = "station_warehouse_spoilage_bloom"
	name = "Warehouse Spoilage Bloom"
	family = "station_cargo_pve"
	department_id = ACCOUNT_CAR
	area_roots = list(/area/station/cargo)
	mob_types = list(/mob/living/simple_animal/hostile/ooze, /mob/living/simple_animal/hostile/plantmutant, /mob/living/basic/cockroach/bloodroach, /mob/living/basic/killer_tomato)
	reward_items = list(/obj/item/plant_analyzer = 1, /obj/item/seeds/random = 1)
	base_mobs = 1
	max_mobs = 3
	dispatch_title = "Warehouse Spoilage"
	dispatch_message = "Organic spoilage has bloomed in storage. Cargo and Science can clear it and recover samples."

/datum/storyteller/action/negative/hostile_site/medbay_containment_patient
	id = "station_medbay_containment_patient"
	name = "Medbay Containment Patient"
	family = "station_medical_pve"
	department_id = ACCOUNT_MED
	area_roots = list(/area/station/medical)
	mob_types = list(/mob/living/simple_animal/hostile/ooze, /mob/living/basic/flesh_spider, /mob/living/basic/slime/random)
	reward_items = list(/obj/item/healthanalyzer = 1, /obj/item/storage/box/syringes = 1)
	base_mobs = 1
	max_mobs = 2
	dispatch_title = "Containment Patient"
	dispatch_message = "An unstable patient has broken containment in Medbay. Medical should control the patient while Security stands by."

/datum/storyteller/action/positive/event_contract_pod/paramedic_distress_beacon
	id = "station_paramedic_distress_beacon"
	name = "Paramedic Distress Beacon"
	family = "station_medical_rescue"
	department_id = ACCOUNT_MED
	items_by_count = list(/obj/item/storage/medkit/emergency = 1, /obj/item/healthanalyzer = 1, /obj/item/bodybag = 1)
	research_items_by_count = list(/obj/item/healthanalyzer/advanced = 1, /obj/item/reagent_containers/hypospray/medipen/empty = 1, /obj/item/reagent_containers/spray/medical = 1)
	dispatch_title = "Paramedic Beacon"
	dispatch_message = "A rescue response pickup contract is open. Deliver medical rescue supplies to the Cargo lobby pickup pod for Cargo payment."
	crate_name = "paramedic response crate"
	paper_text = "Paramedic Distress Beacon: locate the wounded transit worker or simulated patient marker, stabilize them, and return medical paperwork."

/datum/storyteller/action/negative/hostile_site/xenobiology_specimen_escape
	id = "station_xenobiology_specimen_escape"
	name = "Xenobiology Specimen Escape"
	family = "station_science_pve"
	department_id = ACCOUNT_SCI
	area_roots = list(/area/station/science)
	mob_types = list(/mob/living/basic/slime, /mob/living/basic/slime/random, /mob/living/simple_animal/hostile/ooze, /mob/living/basic/spider/growing/spiderling/scout)
	reward_items = list(/obj/item/plant_analyzer = 1)
	base_mobs = 1
	max_mobs = 2
	dispatch_title = "Specimen Escape"
	dispatch_message = "A low-grade xenobiology specimen is loose in Science. Recover or destroy it before it reaches public halls."

/datum/storyteller/action/negative/hostile_site/research_containment_drift
	id = "station_research_containment_drift"
	name = "Research Containment Drift"
	family = "station_science_fault"
	department_id = ACCOUNT_SCI
	area_roots = list(/area/station/science)
	mob_types = list(/mob/living/basic/migo, /mob/living/basic/eyeball, /mob/living/basic/viscerator, /mob/living/basic/hivebot)
	reward_items = list(/obj/item/multitool = 1, /obj/item/geiger_counter = 1)
	base_mobs = 1
	max_mobs = 1
	dispatch_title = "Containment Drift"
	dispatch_message = "A drifting research signature is causing weak hallucination pulses. Science should stabilize the site with scanners or tools."

/datum/storyteller/action/negative/hostile_site/hydroponics_pollination_surge
	id = "station_hydroponics_pollination_surge"
	name = "Hydroponics Pollination Surge"
	family = "station_service_pve"
	department_id = ACCOUNT_SRV
	area_roots = list(/area/station/service)
	mob_types = list(/mob/living/simple_animal/hostile/plantmutant, /mob/living/simple_animal/hostile/ooze, /mob/living/basic/killer_tomato, /mob/living/basic/cockroach/bloodroach)
	reward_items = list(/obj/item/seeds/random = 2, /obj/item/plant_analyzer = 1)
	base_mobs = 1
	max_mobs = 3
	dispatch_title = "Pollination Surge"
	dispatch_message = "Hydroponics is experiencing accelerated growth with hostile weeds. Botany can clear the weeds and recover useful seed stock."

/datum/storyteller/action/negative/hostile_site/kitchen_pest_nest
	id = "station_kitchen_pest_nest"
	name = "Kitchen Pest Nest"
	family = "station_service_pve"
	department_id = ACCOUNT_SRV
	area_roots = list(/area/station/service)
	mob_types = list(/mob/living/basic/mouse/rat, /mob/living/simple_animal/hostile/syndimouse, /mob/living/basic/cockroach, /mob/living/basic/frog/crazy)
	reward_items = list(/obj/item/storage/box/donkpockets = 1, /obj/item/soap/nanotrasen = 1)
	base_mobs = 1
	max_mobs = 4
	dispatch_title = "Kitchen Pest Nest"
	dispatch_message = "A pest nest has been found in the service wing. Kitchen and Janitorial can clear it before food service suffers."

/datum/storyteller/action/negative/hostile_site/chapel_restless_shrine
	id = "station_chapel_restless_shrine"
	name = "Chapel Restless Shrine"
	family = "station_chapel_pve"
	department_id = ACCOUNT_SRV
	area_roots = list(/area/station/service)
	mob_types = list(/mob/living/basic/ghost, /mob/living/basic/faithless, /mob/living/basic/eyeball, /mob/living/basic/migo)
	reward_items = list(/obj/item/storage/box/holy = 1, /obj/item/paper = 1)
	base_mobs = 1
	max_mobs = 2
	dispatch_title = "Restless Shrine"
	dispatch_message = "A restless shrine has begun disturbing the chapel wing. The Chaplain may pacify it, or Security may clear it."

/datum/storyteller/action/negative/hostile_site/library_forbidden_manuscript
	id = "station_library_forbidden_manuscript"
	name = "Library Forbidden Manuscript"
	family = "station_library_social"
	department_id = ACCOUNT_SRV
	area_roots = list(/area/station/service)
	mob_types = list(/mob/living/basic/paper_wizard/copy, /mob/living/basic/eyeball, /mob/living/basic/ghost)
	reward_items = list(/obj/item/paper = 2, /obj/item/clipboard = 1)
	base_mobs = 1
	max_mobs = 1
	dispatch_title = "Forbidden Manuscript"
	dispatch_message = "A forbidden manuscript has surfaced in the library. Service and Science can catalogue it before its side effects spread."

/datum/storyteller/action/negative/hostile_site/brig_evidence_leak
	id = "station_brig_evidence_leak"
	name = "Brig Evidence Leak"
	family = "station_security_pve"
	department_id = ACCOUNT_SEC
	area_roots = list(/area/station/security)
	mob_types = list(/mob/living/basic/viscerator, /mob/living/basic/hivebot, /mob/living/simple_animal/hostile/syndimouse)
	reward_items = list(/obj/item/storage/box/evidence = 1, /obj/item/stamp/denied = 1)
	base_mobs = 1
	max_mobs = 2
	dispatch_title = "Evidence Leak"
	dispatch_message = "Evidence storage has released contraband hazards. Security should inventory the site and Cargo may dispose of cleared items."

/datum/storyteller/action/negative/event_contract_pod/armory_lockdown_fault
	parent_type = /datum/storyteller/action/negative/event_contract_pod
	id = "station_armory_lockdown_fault"
	name = "Armory Lockdown Fault"
	polarity = STORYTELLER_POLARITY_NEGATIVE
	family = "station_security_fault"
	department_id = ACCOUNT_SEC
	items_by_count = list(/obj/item/multitool = 1, /obj/item/stack/cable_coil = 1)
	research_items_by_count = list(/obj/item/flashlight/seclite = 1, /obj/item/evidencebag = 1, /obj/item/inspector = 1, /obj/item/restraints/handcuffs/cable/zipties = 1, /obj/item/dragnet_beacon = 1)
	dispatch_color = "orange"
	dispatch_sound = 'sound/announcer/notice/notice1.ogg'
	dispatch_title = "Armory Lockdown Fault"
	dispatch_message = "An armory diagnostic pickup contract is open. Deliver reset tools and repair supplies to the Cargo lobby pickup pod."
	crate_name = "armory diagnostic crate"
	paper_text = "Armory Lockdown Fault: verify armory access, reset safety locks, and record any manual repair."

/datum/storyteller/action/negative/event_contract_pod/engineering_coolant_leak
	parent_type = /datum/storyteller/action/negative/event_contract_pod
	id = "station_engineering_coolant_leak"
	name = "Engineering Coolant Leak"
	polarity = STORYTELLER_POLARITY_NEGATIVE
	family = "station_engineering_fault"
	department_id = ACCOUNT_ENG
	items_by_count = list(/obj/item/extinguisher = 1, /obj/item/analyzer = 1, /obj/item/stack/cable_coil = 1)
	research_items_by_count = list(/obj/item/analyzer/ranged = 1, /obj/item/gas_filter = 1, /obj/item/gas_filter/plasmaman = 1, /obj/item/construction/plumbing/engineering = 1)
	dispatch_color = "orange"
	dispatch_sound = 'sound/announcer/notice/notice1.ogg'
	dispatch_title = "Coolant Leak"
	dispatch_message = "A coolant response pickup contract is open. Deliver inspection and cleanup supplies to the Cargo lobby pickup pod."
	crate_name = "coolant response crate"
	paper_text = "Engineering Coolant Leak: inspect pipes, mark slippery tiles, and call Medical if hypothermia symptoms appear."

/datum/storyteller/action/positive/timed_modifier/supermatter_calibration_bonus
	id = "station_supermatter_calibration_bonus"
	name = "Supermatter Calibration Bonus"
	family = "station_engineering_power"
	department_id = ACCOUNT_ENG
	required_department_id = ACCOUNT_ENG
	required_department_staff = 1
	modifier_id = STORYTELLER_MOD_ENGINEERING_POWER
	modifier_multiplier = 1.2
	min_duration = 6 MINUTES
	max_duration = 6 MINUTES
	modifier_title = "Supermatter Calibration Bonus"
	dispatch_title = "Engine Calibration"
	dispatch_message = "Engineering has an opportunity to tune engine efficiency. Station machinery receives a short power-efficiency bonus."

/datum/storyteller/action/negative/hostile_site/disposals_backflow
	id = "station_disposals_backflow"
	name = "Disposals Backflow"
	family = "station_janitor_pve"
	department_id = ACCOUNT_SRV
	area_roots = list(/area/station/service, /area/station/hallway)
	mob_types = list(/mob/living/basic/mouse/rat, /mob/living/simple_animal/hostile/syndimouse, /mob/living/basic/cockroach/sewer, /mob/living/basic/frog/crazy)
	reward_items = list(/obj/item/storage/bag/trash = 1, /obj/item/mop = 1, /obj/item/soap/nanotrasen = 1)
	base_mobs = 1
	max_mobs = 3
	dispatch_title = "Disposals Backflow"
	dispatch_message = "Several disposal bins have backflowed refuse and hostile pests. Janitorial and Cargo can recycle the mess."

/datum/storyteller/action/negative/event_contract_pod/morgue_misfile
	parent_type = /datum/storyteller/action/negative/event_contract_pod
	id = "station_morgue_misfile"
	name = "Morgue Misfile"
	polarity = STORYTELLER_POLARITY_NEGATIVE
	family = "station_medical_security"
	department_id = ACCOUNT_MED
	items_by_count = list(/obj/item/storage/box/bodybags = 1, /obj/item/clipboard = 1, /obj/item/stamp/denied = 1)
	research_items_by_count = list(/obj/item/reagent_containers/cup/beaker/organ_jar = 1, /obj/item/healthanalyzer/advanced = 1)
	dispatch_color = "orange"
	dispatch_sound = 'sound/announcer/notice/notice1.ogg'
	dispatch_title = "Morgue Misfile"
	dispatch_message = "A morgue review pickup contract is open. Deliver body bags, records, and evidence paperwork to the Cargo lobby pickup pod."
	crate_name = "morgue review packet"
	paper_text = "Morgue Misfile: identify the body, record cause of death, and forward evidence to Security."

/datum/storyteller/action/negative/hostile_site/telecomms_signal_parasite
	id = "station_telecomms_signal_parasite"
	name = "Telecomms Signal Parasite"
	family = "station_comms_pve"
	department_id = ACCOUNT_ENG
	area_roots = list(/area/station/engineering)
	mob_types = list(/mob/living/basic/viscerator, /mob/living/basic/mining_drone, /mob/living/basic/hivebot/range)
	reward_items = list(/obj/item/radio = 1, /obj/item/multitool = 1)
	base_mobs = 1
	max_mobs = 2
	dispatch_title = "Signal Parasite"
	dispatch_message = "A signal parasite is causing radio static near telecomms infrastructure. Engineering should clear or dismantle the source."

/datum/storyteller/action/negative/hostile_site/mining_claim_jumper
	id = "station_mining_claim_jumper"
	name = "Mining Claim Jumper"
	family = "station_mining_pve"
	department_id = ACCOUNT_CAR
	area_roots = list(/area/station/cargo)
	mob_types = list(/mob/living/basic/mining_drone, /mob/living/basic/hivebot, /mob/living/simple_animal/hostile/trog)
	reward_items = list(/obj/item/stack/sheet/iron/ten = 1, /obj/item/geiger_counter = 1)
	base_mobs = 1
	max_mobs = 3
	dispatch_title = "Claim Jumper"
	dispatch_message = "A small claim-jumper beacon is interfering with mining logistics. Miners can clear it for a Cargo bounty."

/datum/storyteller/action/positive/event_contract_pod/botanical_spore_courier
	id = "station_botanical_spore_courier"
	name = "Botanical Spore Courier"
	family = "station_botany_science"
	department_id = ACCOUNT_SRV
	items_by_count = list(/obj/item/seeds/random = 3, /obj/item/plant_analyzer = 1, /obj/item/reagent_containers/cup/bottle/nutrient/ez = 1)
	research_items_by_count = list(/obj/item/storage/bag/plants/portaseeder = 1, /obj/item/reagent_containers/cup/watering_can/advanced = 1)
	dispatch_title = "Spore Courier"
	dispatch_message = "A botanical sample pickup contract is open. Deliver seeds, plant analysis gear, and nutrients to the Cargo lobby pickup pod."
	crate_name = "spore courier crate"
	paper_text = "Botanical Spore Courier: grow the samples, scan them, and send one useful product to Kitchen or Science."

/datum/storyteller/action/negative/hostile_site/robotics_calibration_swarm
	id = "station_robotics_calibration_swarm"
	name = "Robotics Calibration Swarm"
	family = "station_robotics_pve"
	department_id = ACCOUNT_SCI
	area_roots = list(/area/station/science)
	mob_types = list(/mob/living/basic/mining_drone, /mob/living/basic/viscerator, /mob/living/basic/hivebot, /mob/living/basic/hivebot/mechanic)
	reward_items = list(/obj/item/stock_parts/capacitor = 1, /obj/item/stock_parts/servo = 1)
	base_mobs = 1
	max_mobs = 3
	dispatch_title = "Calibration Swarm"
	dispatch_message = "Robotics calibration units have gone mobile. Robotics can disable them with tools or recover parts after destruction."

/datum/storyteller/action/positive/event_contract_pod/department_trade_mandate
	id = "station_department_trade_mandate"
	name = "Department Trade Mandate"
	family = "station_social_trade"
	minimum_crew = 3
	department_id = ACCOUNT_CMD
	items_by_count = list(/obj/item/clipboard = 1, /obj/item/paper/requisition = 2, /obj/item/stamp/granted = 1)
	dispatch_title = "Trade Mandate"
	dispatch_message = "A department trade paperwork contract is open. Deliver stamped requisition records to the Cargo lobby pickup pod."
	crate_name = "trade mandate packet"
	paper_text = "Department Trade Mandate: pair two departments, exchange one useful item or service, and stamp the completed requisition."

/datum/storyteller/action/positive/event_contract_pod/cross_training_voucher
	id = "station_cross_training_voucher"
	name = "Cross-Training Voucher"
	family = "station_social_training"
	minimum_crew = 2
	department_id = ACCOUNT_CMD
	items_by_count = list(/obj/item/clipboard = 1, /obj/item/stamp/granted = 1, /obj/item/paper = 2)
	research_items_by_count = list(/obj/item/hand_labeler = 1)
	dispatch_title = "Cross-Training Voucher"
	dispatch_message = "A cross-training documentation contract is open. Deliver voucher paperwork to the Cargo lobby pickup pod."
	crate_name = "cross-training packet"
	paper_text = "Cross-Training Voucher: appoint one volunteer, record the assisted department, and return access when the task ends."

/datum/storyteller/action/positive/event_contract_pod/peer_review_request
	id = "station_peer_review_request"
	name = "Peer Review Request"
	family = "station_social_science"
	minimum_crew = 2
	department_id = ACCOUNT_SCI
	items_by_count = list(/obj/item/clipboard = 1, /obj/item/plant_analyzer = 1, /obj/item/healthanalyzer = 1)
	research_items_by_count = list(/obj/item/healthanalyzer/advanced = 1, /obj/item/fish_analyzer = 1, /obj/item/anomaly_neutralizer = 1)
	dispatch_title = "Peer Review"
	dispatch_message = "A peer review sample contract is open. Deliver review tools and paperwork to the Cargo lobby pickup pod."
	crate_name = "peer review kit"
	paper_text = "Peer Review Request: receive one sample from another department, scan it, and return a short finding."

/datum/storyteller/action/positive/event_contract_pod/safety_buddy_system
	id = "station_safety_buddy_system"
	name = "Safety Buddy System"
	family = "station_social_buddy"
	minimum_crew = 2
	department_id = ACCOUNT_CMD
	items_by_count = list(/obj/item/radio = 2, /obj/item/flashlight = 2, /obj/item/clipboard = 1)
	research_items_by_count = list(/obj/item/gps = 1, /obj/item/beacon = 1)
	dispatch_title = "Safety Buddy System"
	dispatch_message = "A safety buddy documentation contract is open. Deliver pair-assignment supplies to the Cargo lobby pickup pod."
	crate_name = "safety buddy kit"
	paper_text = "Safety Buddy System: pair two crewmembers, choose a modest objective, and verify both returned safely."

/datum/storyteller/action/positive/event_contract_pod/station_charity_drive
	id = "station_station_charity_drive"
	name = "Station Charity Drive"
	family = "station_social_charity"
	minimum_crew = 3
	department_id = ACCOUNT_SRV
	items_by_count = list(/obj/item/storage/box/donkpockets = 1, /obj/item/clipboard = 1, /obj/item/stamp/granted = 1)
	dispatch_title = "Charity Drive"
	dispatch_message = "A charity drive pickup contract is open. Deliver starter donations and stamped records to the Cargo lobby pickup pod."
	crate_name = "charity drive starter crate"
	paper_text = "Station Charity Drive: collect varied donations from multiple departments and distribute the reward through Service."

/datum/storyteller/action/positive/event_contract_pod/emergency_blood_drive
	id = "station_emergency_blood_drive"
	name = "Emergency Blood Drive"
	family = "station_social_medical"
	department_id = ACCOUNT_MED
	items_by_count = list(/obj/item/reagent_containers/blood/random = 2, /obj/item/reagent_containers/syringe = 2, /obj/item/healthanalyzer = 1)
	research_items_by_count = list(/obj/item/reagent_containers/blood = 1, /obj/item/reagent_containers/syringe/bluespace = 1, /obj/item/healthanalyzer/advanced = 1)
	dispatch_title = "Blood Drive"
	dispatch_message = "An emergency blood reserve contract is open. Deliver blood collection supplies to the Cargo lobby pickup pod."
	crate_name = "blood drive crate"
	paper_text = "Emergency Blood Drive: collect donor blood safely, label it, and restock Medbay reserves."

/datum/storyteller/action/positive/event_contract_pod/cargo_priority_manifest
	id = "station_cargo_priority_manifest"
	name = "Cargo Priority Manifest"
	family = "station_social_cargo"
	department_id = ACCOUNT_CAR
	items_by_count = list(/obj/item/paper/requisition = 3, /obj/item/clipboard = 1, /obj/item/stamp/granted = 1, /obj/item/hand_labeler = 1)
	research_items_by_count = list(/obj/item/hand_labeler_refill = 1)
	dispatch_title = "Priority Manifest"
	dispatch_message = "A priority manifest pickup contract is open. Deliver stamped requisitions and labeling supplies to the Cargo lobby pickup pod."
	crate_name = "priority manifest packet"
	paper_text = "Cargo Priority Manifest: collect stamped requests, label the priority order, deliver it, and file the manifest."

/datum/storyteller/action/positive/department_budget_notice/command_confidence_check
	id = "station_command_confidence_check"
	name = "Command Confidence Check"
	family = "station_social_command"
	minimum_crew = 2
	department_id = ACCOUNT_CMD
	budget_amount = 650
	dispatch_title = "Confidence Check"
	dispatch_message = "Command should announce one station priority: repairs, medical, security, research, or morale. A small coordination grant has been approved."

/datum/storyteller/action/positive/event_contract_pod/departmental_debate_broadcast
	id = "station_departmental_debate_broadcast"
	name = "Departmental Debate Broadcast"
	family = "station_social_vote"
	minimum_crew = 3
	department_id = ACCOUNT_CMD
	items_by_count = list(/obj/item/clipboard = 1, /obj/item/paper = 3, /obj/item/stamp/granted = 1, /obj/item/stamp/denied = 1)
	dispatch_title = "Debate Broadcast"
	dispatch_message = "A departmental debate record contract is open. Deliver vote paperwork and stamps to the Cargo lobby pickup pod."
	crate_name = "debate packet"
	paper_text = "Departmental Debate Broadcast: state two requests, collect crew votes, and distribute aid according to the result."

/datum/storyteller/action/positive/event_contract_pod/lost_intern_assignment
	id = "station_lost_intern_assignment"
	name = "Lost Intern Assignment"
	family = "station_social_escort"
	minimum_crew = 1
	department_id = ACCOUNT_CIV
	items_by_count = list(/obj/item/radio = 1, /obj/item/clipboard = 1, /obj/item/food/ready_donk = 1)
	research_items_by_count = list(/obj/item/gps = 1, /obj/item/beacon = 1)
	dispatch_title = "Lost Intern"
	dispatch_message = "An intern assistance pickup contract is open. Deliver escort supplies and paperwork to the Cargo lobby pickup pod."
	crate_name = "intern assistance packet"
	paper_text = "Lost Intern Assignment: choose a safe department destination and escort the intern or roleplayed trainee there."

/datum/storyteller/action/positive/event_contract_pod/salvage_cache_ping
	id = "station_salvage_cache_ping"
	name = "Salvage Cache Ping"
	family = "station_salvage_cache"
	department_id = ACCOUNT_CAR
	items_by_count = list(/obj/item/stack/sheet/iron/twenty = 1, /obj/item/stack/cable_coil/thirty = 1, /obj/item/stock_parts/capacitor = 1, /obj/item/multitool = 1)
	research_items_by_count = list(/obj/item/storage/part_replacer = 1, /obj/item/stock_parts/capacitor/adv = 1, /obj/item/stock_parts/matter_bin/adv = 1, /obj/item/gps = 1)
	dispatch_title = "Salvage Cache"
	dispatch_message = "A salvage recovery contract is open. Deliver recovered materials and tools to the Cargo lobby pickup pod."
	crate_name = "salvage cache"
	crate_desc = "A compact cache of recoverable station materials."
	paper_text = "Salvage Cache Ping: recover the cache, check for minor hazards, and route useful materials through Cargo."

/datum/storyteller/action/positive/event_contract_pod/centcom_snack_drop
	id = "station_centcom_snack_drop"
	name = "CentCom Snack Drop"
	family = "station_service_food"
	department_id = ACCOUNT_SRV
	items_by_count = list(/obj/item/storage/box/donkpockets = 1, /obj/item/food/ready_donk = 4, /obj/item/pizzabox/margherita = 1, /obj/item/food/cake/plain = 1)
	research_items_by_count = list(/obj/item/reagent_containers/cup/coffeepot = 1, /obj/item/reagent_containers/cup/coffeepot/bluespace = 1, /obj/item/reagent_containers/cup/bottle/syrup_bottle = 1)
	dispatch_title = "Snack Drop"
	dispatch_message = "A snack distribution pickup contract is open. Deliver prepared food to the Cargo lobby pickup pod for Cargo payment."
	crate_name = "snack distribution crate"
	crate_desc = "A food crate intended for organized service counter distribution."
	paper_text = "CentCom Snack Drop: distribute food through Service. Rough opening and hoarding should be treated as reduced morale value."

/datum/storyteller/action/positive/event_contract_pod/experimental_medigel_trial
	id = "station_experimental_medigel_trial"
	name = "Experimental Medigel Trial"
	family = "station_medical_trial"
	department_id = ACCOUNT_MED
	items_by_count = list(/obj/item/storage/box/medigels = 1, /obj/item/healthanalyzer = 1, /obj/item/clipboard = 1)
	research_items_by_count = list(/obj/item/reagent_containers/medigel = 2, /obj/item/reagent_containers/chem_pack = 1, /obj/item/healthanalyzer/advanced = 1)
	dispatch_title = "Medigel Trial"
	dispatch_message = "An experimental medigel return contract is open. Deliver trial supplies and medical records to the Cargo lobby pickup pod."
	crate_name = "medigel trial crate"
	paper_text = "Experimental Medigel Trial: use samples on appropriate patients, record outcomes, and avoid casual distribution."

/datum/storyteller/action/positive/event_contract_pod/prototype_part_shipment
	id = "station_prototype_part_shipment"
	name = "Prototype Part Shipment"
	family = "station_science_engineering"
	department_id = ACCOUNT_SCI
	items_by_count = list(/obj/item/stock_parts/capacitor/adv = 1, /obj/item/stock_parts/scanning_module/adv = 1, /obj/item/stock_parts/servo/nano = 1, /obj/item/stock_parts/micro_laser/high = 1)
	research_items_by_count = list(/obj/item/stock_parts/capacitor/super = 1, /obj/item/stock_parts/scanning_module/phasic = 1, /obj/item/stock_parts/servo/pico = 1, /obj/item/stock_parts/micro_laser/ultra = 1, /obj/item/stock_parts/matter_bin/bluespace = 1)
	dispatch_title = "Prototype Shipment"
	dispatch_message = "A prototype component pickup contract is open. Deliver scanned advanced parts to the Cargo lobby pickup pod."
	crate_name = "prototype part crate"
	paper_text = "Prototype Part Shipment: scan the advanced parts, install them where useful, and log the upgraded machine."

/datum/storyteller/action/positive/timed_modifier/mining_scanner_alignment
	id = "station_mining_scanner_alignment"
	name = "Mining Scanner Alignment"
	family = "station_mining_window"
	department_id = ACCOUNT_CAR
	required_department_id = ACCOUNT_CAR
	required_department_staff = 1
	modifier_id = STORYTELLER_MOD_CARGO_PROCESSING
	modifier_multiplier = 1.18
	min_duration = 8 MINUTES
	max_duration = 8 MINUTES
	modifier_title = "Mining Scanner Alignment"
	dispatch_title = "Scanner Alignment"
	dispatch_message = "Mining scanner alignment is active. Mining and Cargo gain a short processing advantage while rich deposits are easier to route."

/datum/storyteller/action/positive/event_contract_pod/public_works_grant
	id = "station_public_works_grant"
	name = "Public Works Grant"
	family = "station_public_works"
	minimum_crew = 2
	department_id = ACCOUNT_ENG
	items_by_count = list(/obj/item/lightreplacer = 1, /obj/item/stack/cable_coil/thirty = 1, /obj/item/soap/nanotrasen = 1, /obj/item/seeds/random = 1)
	research_items_by_count = list(/obj/item/lightreplacer/blue = 1, /obj/item/mop/advanced = 1, /obj/item/storage/bag/trash/bluespace = 1, /obj/item/holosign_creator/janibarrier = 1, /obj/item/door_seal = 1)
	dispatch_title = "Public Works Grant"
	dispatch_message = "A public works pickup contract is open. Deliver maintenance and beautification supplies to the Cargo lobby pickup pod."
	crate_name = "public works crate"
	paper_text = "Public Works Grant: repair lights, clean public areas, add modest plants or furniture, and report completed improvements."
