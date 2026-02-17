/datum/species/pod/podweak
	/// Species-granted rooted intake action tracked for cleanup.
	var/tmp/list/species_rooted_intake_action = list()

/datum/species/pod/podweak/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	if(!istype(H))
		return
	RegisterSignal(H, COMSIG_ATOM_BEING_OPERATED_ON, PROC_REF(adjust_operations_for_podweak_target))
	RegisterSignal(H, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))
	H.default_blood_volume = POD_WATER_RESERVE_MAX
	H.set_blood_volume(POD_WATER_START_VOLUME)
	ADD_TRAIT(H, TRAIT_VIRUSIMMUNE, SPECIES_TRAIT)
	reset_plant_disease_exposure(H)

	var/list/current_diseases = H.diseases ? H.diseases.Copy() : list()
	for(var/datum/disease/old_disease as anything in current_diseases)
		if(old_disease?.bypasses_immunity)
			continue
		old_disease.remove_disease()

	H.apply_status_effect(/datum/status_effect/pod_light_regen_active)

	var/datum/action/cooldown/pod_rooted_intake/old_intake = species_rooted_intake_action[H]
	if(old_intake)
		old_intake.Remove(H)
		qdel(old_intake)
	species_rooted_intake_action[H] = null

	var/datum/action/cooldown/pod_rooted_intake/new_intake = new()
	new_intake.Grant(H)
	species_rooted_intake_action[H] = new_intake

/datum/species/pod/podweak/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	if(!istype(H))
		return
	UnregisterSignal(H, COMSIG_ATOM_BEING_OPERATED_ON)
	UnregisterSignal(H, COMSIG_MOB_GET_STATUS_TAB_ITEMS)
	H.remove_status_effect(/datum/status_effect/pod_light_regen_active)
	H.remove_status_effect(/datum/status_effect/pod_rooted_intake_active)
	REMOVE_TRAIT(H, TRAIT_VIRUSIMMUNE, SPECIES_TRAIT)
	reset_plant_disease_exposure(H)

	var/datum/action/cooldown/pod_rooted_intake/intake = species_rooted_intake_action[H]
	if(intake)
		intake.Remove(H)
		qdel(intake)
	species_rooted_intake_action[H] = null

	H.default_blood_volume = BLOOD_VOLUME_NORMAL
	H.set_blood_volume(min(H.get_blood_volume(), BLOOD_VOLUME_NORMAL))

/datum/species/pod/podweak/proc/get_status_tab_item(mob/living/source, list/items)
	SIGNAL_HANDLER

	if(!hv_is_podweak_human(source))
		return

	items += "Current water level: [round(source.get_blood_volume())]/[POD_WATER_RESERVE_MAX]"

/datum/species/pod/podweak/spec_life(mob/living/carbon/human/H, seconds_per_tick)
	. = ..()
	if(H.stat != CONSCIOUS)
		return

	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = min(1, T.get_lumcount()) - 0.5
		H.adjust_nutrition(5 * light_amount * seconds_per_tick)
		if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
			H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(1 * seconds_per_tick, 0)
		new /obj/effect/temp_visual/annoyed/plant(get_turf(H))

	var/missing_water = POD_WATER_RESERVE_MAX - H.get_blood_volume()
	if(missing_water > 0)
		var/max_absorb = min(POD_WATER_ABSORB_PER_SECOND * seconds_per_tick, missing_water)
		var/absorbed = 0
		var/remaining = max_absorb

		var/obj/item/organ/stomach/belly = H.get_organ_slot(ORGAN_SLOT_STOMACH)
		if(remaining > 0 && belly?.reagents)
			absorbed += belly.reagents.remove_reagent(/datum/reagent/water, remaining, include_subtypes = TRUE)
			remaining = max(0, max_absorb - absorbed)

		if(remaining > 0 && H.reagents)
			absorbed += H.reagents.remove_reagent(/datum/reagent/water, remaining, include_subtypes = TRUE)

		if(absorbed > 0)
			H.adjust_blood_volume(absorbed, maximum = POD_WATER_RESERVE_MAX)

	H.adjust_blood_volume(-POD_WATER_DRAIN_PER_SECOND * seconds_per_tick, minimum = 0)

	var/current_water = H.get_blood_volume()
	if(current_water < BLOOD_VOLUME_SAFE)
		var/deficit_ratio = clamp((BLOOD_VOLUME_SAFE - current_water) / BLOOD_VOLUME_SAFE, 0, 1)
		var/wither_damage = POD_WITHER_DAMAGE_MAX_PER_SECOND * deficit_ratio * seconds_per_tick
		if(wither_damage > 0)
			H.take_overall_damage(wither_damage, 0)
			if(prob(25 * seconds_per_tick))
				new /obj/effect/temp_visual/annoyed/plant(get_turf(H))

	try_contract_plant_disease(H, seconds_per_tick)

/datum/status_effect/pod_light_regen_active
	id = "pod_light_regen_active"
	status_type = STATUS_EFFECT_UNIQUE
	processing_speed = STATUS_EFFECT_FAST_PROCESS
	tick_interval = POD_LIGHT_REGEN_START_DELAY
	alert_type = null
	var/time_in_light = 0

/datum/status_effect/pod_light_regen_active/tick(seconds_between_ticks)
	var/mob/living/carbon/human/regenerator = owner
	if(!istype(regenerator))
		return

	if(regenerator.get_blood_volume() <= POD_LIGHT_REGEN_MIN_WATER)
		time_in_light = 0
		return

	var/turf/current_turf = get_turf(regenerator)
	if(!istype(current_turf))
		time_in_light = 0
		return

	if(current_turf.get_lumcount() <= POD_LIGHT_REGEN_LIGHT_THRESHOLD)
		time_in_light = 0
		return

	var/has_healable_damage = FALSE
	if(regenerator.get_tox_loss() > 0 && regenerator.can_adjust_tox_loss())
		has_healable_damage = TRUE
	else if(length(regenerator.get_damaged_bodyparts(brute = TRUE, burn = FALSE, required_bodytype = BODYTYPE_ORGANIC)))
		has_healable_damage = TRUE
	else if(length(regenerator.get_damaged_bodyparts(brute = FALSE, burn = TRUE, required_bodytype = BODYTYPE_ORGANIC)))
		has_healable_damage = TRUE

	if(!has_healable_damage)
		time_in_light = 0
		return

	time_in_light += (seconds_between_ticks SECONDS)
	if(time_in_light < POD_LIGHT_REGEN_START_DELAY)
		return

	var/max_water_for_regen = regenerator.get_blood_volume() - POD_LIGHT_REGEN_MIN_WATER
	if(max_water_for_regen <= 0)
		time_in_light = 0
		return

	var/water_used = 0

	var/brute_damage = regenerator.get_brute_loss()
	if(brute_damage && length(regenerator.get_damaged_bodyparts(brute = TRUE, burn = FALSE, required_bodytype = BODYTYPE_ORGANIC)))
		var/brutes_to_heal = min(max_water_for_regen, min(POD_LIGHT_REGEN_BRUTE_PER_SECOND, brute_damage) * seconds_between_ticks)
		if(brutes_to_heal > 0)
			regenerator.adjust_brute_loss(-brutes_to_heal, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
			water_used += brutes_to_heal
			max_water_for_regen -= brutes_to_heal

	var/burn_damage = regenerator.get_fire_loss()
	if(burn_damage && max_water_for_regen > 0 && length(regenerator.get_damaged_bodyparts(brute = FALSE, burn = TRUE, required_bodytype = BODYTYPE_ORGANIC)))
		var/burns_to_heal = min(max_water_for_regen, min(POD_LIGHT_REGEN_BURN_PER_SECOND, burn_damage) * seconds_between_ticks)
		if(burns_to_heal > 0)
			regenerator.adjust_fire_loss(-burns_to_heal, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
			water_used += burns_to_heal
			max_water_for_regen -= burns_to_heal

	var/toxin_damage = regenerator.get_tox_loss()
	if(toxin_damage && max_water_for_regen > 0 && regenerator.can_adjust_tox_loss())
		var/toxins_to_heal = min(max_water_for_regen, min(POD_LIGHT_REGEN_TOX_PER_SECOND, toxin_damage) * seconds_between_ticks)
		if(toxins_to_heal > 0)
			regenerator.adjust_tox_loss(-toxins_to_heal, updating_health = FALSE, forced = TRUE)
			water_used += toxins_to_heal

	if(water_used <= 0)
		time_in_light = 0
		return

	regenerator.adjust_blood_volume(-water_used * POD_LIGHT_REGEN_WATER_COST_PER_DAMAGE)
	regenerator.updatehealth()
	new /obj/effect/temp_visual/heal(get_turf(regenerator), COLOR_EFFECT_HEAL_RED)

/datum/action/cooldown/pod_rooted_intake
	name = "Rooted Intake"
	desc = "Root yourself in place and draw water from the floor under you."
	button_icon = 'icons/mob/spacevines.dmi'
	button_icon_state = "Light1"
	cooldown_time = 20 SECONDS
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/cooldown/pod_rooted_intake/Activate(atom/target)
	var/mob/living/carbon/human/podperson = owner
	if(!istype(podperson))
		return FALSE
	if(podperson.has_status_effect(/datum/status_effect/pod_rooted_intake_active))
		to_chat(podperson, span_notice("You are already rooted in place."))
		return FALSE

	podperson.apply_status_effect(/datum/status_effect/pod_rooted_intake_active)
	podperson.balloon_alert(podperson, "roots spread")
	podperson.visible_message(
		span_notice("[podperson] sinks roots into the floor."),
		span_notice("You sink roots into the floor and start drinking water."),
	)
	StartCooldown()
	return TRUE

/datum/action/cooldown/pod_rooted_intake/proc/pod_has_floor_water(turf/current_turf)
	if(!istype(current_turf))
		return FALSE
	if(iswaterturf(current_turf))
		return TRUE

	var/obj/effect/abstract/liquid_turf/liquids = current_turf.liquids
	if(!liquids || !length(liquids.reagent_list))
		return FALSE

	for(var/datum/reagent/reagent_type as anything in liquids.reagent_list)
		if(ispath(reagent_type, /datum/reagent/water) && liquids.reagent_list[reagent_type] > 0)
			return TRUE
	return FALSE

/datum/status_effect/pod_rooted_intake_active
	id = "pod_rooted_intake_active"
	duration = POD_ROOTED_INTAKE_DURATION
	tick_interval = POD_ROOTED_INTAKE_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/turf/anchored_turf
	var/list/spawned_roots = list()

/datum/status_effect/pod_rooted_intake_active/on_apply()
	. = ..()
	if(!ishuman(owner))
		return FALSE

	anchored_turf = get_turf(owner)
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	spawn_roots(anchored_turf)
	return TRUE

/datum/status_effect/pod_rooted_intake_active/on_remove()
	clear_spawned_roots()
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	return ..()

/datum/status_effect/pod_rooted_intake_active/tick(seconds_between_ticks)
	var/mob/living/carbon/human/podperson = owner
	if(!istype(podperson))
		return

	var/turf/current_turf = get_turf(podperson)
	if(!istype(current_turf))
		return

	if(anchored_turf && current_turf != anchored_turf)
		podperson.remove_status_effect(/datum/status_effect/pod_rooted_intake_active)
		return

	var/missing_water = POD_WATER_RESERVE_MAX - podperson.get_blood_volume()
	if(missing_water <= 0)
		return

	var/want_absorb = min(POD_ROOTED_INTAKE_ABSORB_PER_SECOND * seconds_between_ticks, missing_water)
	var/absorbed = 0

	if(iswaterturf(current_turf))
		absorbed = want_absorb
	else if(current_turf.liquids && length(current_turf.liquids.reagent_list))
		absorbed = drain_water_from_liquids(current_turf.liquids, want_absorb)

	if(absorbed <= 0)
		return

	podperson.adjust_blood_volume(absorbed, maximum = POD_WATER_RESERVE_MAX)
	new /obj/effect/temp_visual/heal(current_turf, COLOR_EFFECT_HEAL_RED)

/datum/status_effect/pod_rooted_intake_active/proc/spawn_roots(turf/current_turf)
	if(!istype(current_turf))
		return

	clear_spawned_roots()

	var/obj/effect/pod_roots/center_roots = new(current_turf)
	center_roots.alpha = 230
	spawned_roots += center_roots

/datum/status_effect/pod_rooted_intake_active/proc/drain_water_from_liquids(obj/effect/abstract/liquid_turf/liquids, wanted)
	if(!liquids || wanted <= 0)
		return 0

	var/absorbed = 0
	for(var/datum/reagent/reagent_type as anything in liquids.reagent_list)
		if(!ispath(reagent_type, /datum/reagent/water))
			continue

		var/available = liquids.reagent_list[reagent_type]
		if(available <= 0)
			continue

		var/to_take = min(wanted - absorbed, available)
		liquids.reagent_list[reagent_type] -= to_take
		liquids.total_reagents -= to_take
		absorbed += to_take

		if(liquids.reagent_list[reagent_type] <= 0)
			liquids.reagent_list -= reagent_type

		if(absorbed >= wanted)
			break

	if(absorbed <= 0)
		return 0

	if(liquids.total_reagents <= 0 || !length(liquids.reagent_list))
		qdel(liquids, TRUE)
	else
		liquids.has_cached_share = FALSE
		if(!liquids.my_turf?.lgroup)
			liquids.calculate_height()
			liquids.set_reagent_color_for_liquid()

	return absorbed

/datum/status_effect/pod_rooted_intake_active/proc/clear_spawned_roots()
	if(!length(spawned_roots))
		return
	for(var/obj/effect/pod_roots/root_fx as anything in spawned_roots)
		if(QDELETED(root_fx))
			continue
		qdel(root_fx)
	spawned_roots.Cut()

/obj/effect/pod_roots
	name = "roots"
	icon = 'icons/mob/spacevines.dmi'
	icon_state = "Light1"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 210

/obj/effect/pod_roots/Initialize(mapload)
	. = ..()
	icon_state = pick("Light1", "Med1", "Med2", "Med3", "Hvy1", "Hvy2", "Hvy3")

/datum/species/pod/podweak/create_pref_unique_perks()
	. = ..()
	. += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "droplet",
			SPECIES_PERK_NAME = "Water Reservoir",
			SPECIES_PERK_DESC = "Podpeople store water as blood (up to 2000 units). Drinking water replenishes this reserve.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Photosynthetic Regeneration",
			SPECIES_PERK_DESC = "In bright light, podpeople gradually regenerate brute, burn and toxin damage by consuming stored water.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "seedling",
			SPECIES_PERK_NAME = "Rooted Intake",
			SPECIES_PERK_DESC = "Active ability: root in place and absorb water directly from wet turf and liquid puddles.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "leaf",
			SPECIES_PERK_NAME = "Plant Medicine",
			SPECIES_PERK_DESC = "Podpeople use specialized botanical surgeries and are best treated with botany-compatible methods.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "hourglass-half",
			SPECIES_PERK_NAME = "Withering",
			SPECIES_PERK_DESC = "Water reserve is drained over time. At low water levels, podpeople wither and take increasing brute damage.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "bug",
			SPECIES_PERK_NAME = "Plant Pathologies",
			SPECIES_PERK_DESC = "Immune to most standard diseases, but vulnerable to plant-specific infections and infestations.",
		),
	)
