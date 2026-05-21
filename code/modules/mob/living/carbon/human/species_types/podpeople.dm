/datum/species/pod
	// A mutation caused by a human being ressurected in a revival pod. These regain health in light, and begin to wither in darkness.
	name = "\improper Podperson"
	plural_form = "Podpeople"
	id = SPECIES_PODPERSON
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_PLANT_SAFE,
	)
	mutant_organs = list(
		/obj/item/organ/pod_hair = "None",
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_PLANT
	inherent_factions = list(FACTION_PLANTS, FACTION_VINES)

	heatmod = 1.5
	payday_modifier = 1.0
	meat = /obj/item/food/meat/slab/human/mutant/plant
	exotic_bloodtype = BLOOD_TYPE_H2O
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/plant

	mutantappendix = /obj/item/organ/appendix/pod
	mutantbrain = /obj/item/organ/brain/pod
	mutantears = /obj/item/organ/ears/pod
	mutanteyes = /obj/item/organ/eyes/pod
	mutantheart = /obj/item/organ/heart/pod
	mutantliver = /obj/item/organ/liver/pod
	mutantlungs = /obj/item/organ/lungs/pod
	mutantstomach = /obj/item/organ/stomach/pod
	mutanttongue = /obj/item/organ/tongue/pod

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/pod,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/pod,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/pod,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/pod,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/pod,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/pod,
	)

/datum/species/pod/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features[FEATURE_MUTANT_COLOR] = "#886600"
	human.dna.features[FEATURE_POD_HAIR] = "Rose"
	human.update_body(is_creating = TRUE)

/datum/species/pod/get_physical_attributes()
	return "Podpeople are in many ways the inverse of shadows, healing in light and starving with the dark. \
		Their bodies are like tinder and easy to char."

/datum/species/pod/get_species_description()
	return "Podpeople are largely peaceful plant based lifeforms, resembling a humanoid figure made of leaves, flowers, and vines."

/datum/species/pod/get_species_lore()
	return list(
		"Not much is known about the origins of the Podpeople. \
		Many assume them to be the result of a long forgotten botanical experiment, slowly mutating for years on years until they became the beings they are today. \
		Ever since they were uncovered long ago, their kind have been found on board stations and planets across the galaxy, \
		often working in hydroponics bays, kitchens, or science departments, working with plants and other botanical lifeforms.",
	)

/datum/species/pod/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "lightbulb",
		SPECIES_PERK_NAME = "Photosynthetic",
		SPECIES_PERK_DESC = "As long as you are conscious, and within a well-lit area, you will slowly heal brute, burn, toxin and oxygen damage and gain nutrition - and never get fat! \
		However, if you are LOW on nutrition, you will progressively take brute damage until you die or enter the light once more."
	))

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "biohazard",
		SPECIES_PERK_NAME = "Weedkiller Susceptability",
		SPECIES_PERK_DESC = "Being a floral life form, you are susceptable to anti-florals and will take extra toxin damage from it!"
	))

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "briefcase-medical",
		SPECIES_PERK_NAME = "Semi-Complex Biology",
		SPECIES_PERK_DESC = "Your biology is extremely complex, making ordinary health scanners unable to scan you. Make sure the doctor treating you either has a \
		plant analyzer or a advanced health scanner!"
	))

	return to_add

// HowlingVoid podperson mechanics integration.
/datum/species/pod
	/// Species-granted rooted intake action tracked for cleanup.
	var/tmp/list/species_rooted_intake_action = list()

/datum/species/pod/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
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

/datum/species/pod/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
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

/datum/species/pod/proc/get_status_tab_item(mob/living/source, list/items)
	SIGNAL_HANDLER

	if(!hv_is_podweak_human(source))
		return

	items += "Current water level: [round(source.get_blood_volume())]/[POD_WATER_RESERVE_MAX]"

/datum/species/pod/spec_life(mob/living/carbon/human/H, seconds_per_tick)
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
	cooldown_time = 5 SECONDS
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
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = POD_ROOTED_INTAKE_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/turf/anchored_turf
	var/list/spawned_roots = list()
	var/root_lock_expires = 0

/datum/status_effect/pod_rooted_intake_active/on_apply()
	. = ..()
	if(!ishuman(owner))
		return FALSE

	anchored_turf = get_turf(owner)
	root_lock_expires = world.time + 1.5 SECONDS
	RegisterSignal(owner, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(on_owner_try_move))
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	spawn_roots(anchored_turf)
	return TRUE

/datum/status_effect/pod_rooted_intake_active/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE)
	clear_spawned_roots()
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	return ..()

/datum/status_effect/pod_rooted_intake_active/proc/on_owner_try_move(mob/living/source, atom/new_loc, direct)
	SIGNAL_HANDLER

	if(!istype(source) || !anchored_turf)
		return

	if(world.time < root_lock_expires)
		source.balloon_alert(source, "roots hold you")
		return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE

	if(get_turf(source) == anchored_turf)
		source.remove_status_effect(/datum/status_effect/pod_rooted_intake_active)

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
	// Keep roots on one tile, but vary their look per cast.
	alpha = rand(185, 240)
	transform = turn(matrix(), pick(0, 90, 180, 270))

/datum/species/pod/prepare_human_for_preview(mob/living/carbon/human/podperson)
	podperson.dna.features[FEATURE_MUTANT_COLOR] = "#886600"
	podperson.dna.mutant_bodyparts[FEATURE_POD_HAIR] = build_mutant_part("Rose", list("#cc3355", "#5c8f2f", "#5c8f2f"))
	regenerate_organs(podperson, src, visual_only = TRUE)
	podperson.update_body(TRUE)

/datum/species/pod/podweak/prepare_human_for_preview(mob/living/carbon/human/podperson)
	podperson.dna.features[FEATURE_MUTANT_COLOR] = "#6f8a34"
	podperson.dna.mutant_bodyparts[FEATURE_POD_HAIR] = build_mutant_part("Ivy", list(COLOR_VIBRANT_LIME, "#7fbf3f", "#48611c"))
	regenerate_organs(podperson, src, visual_only = TRUE)
	podperson.update_body(TRUE)

/datum/species/pod/create_pref_unique_perks()
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


// HowlingVoid podperson diseases integration.
/datum/species/pod
	/// Per-mob accumulated plant-pathogen exposure for realistic infection timing.
	var/tmp/list/plant_disease_exposure = list()

/datum/species/pod/proc/try_contract_plant_disease(mob/living/carbon/human/podperson, seconds_per_tick)
	if(!istype(podperson) || podperson.stat == DEAD)
		return
	if(has_pod_plant_disease(podperson))
		return

	var/turf/current_turf = get_turf(podperson)
	var/light_level = istype(current_turf) ? current_turf.get_lumcount() : 0
	var/water_ratio = podperson.get_blood_volume() / POD_WATER_RESERVE_MAX
	var/chance = POD_PLANT_DISEASE_BASE_CHANCE
	var/exposure_gain = POD_PLANT_EXPOSURE_PER_SECOND_BASE
	var/forced_disease
	var/source_hint

	if(light_level <= POD_PLANT_DISEASE_MIN_LIGHT)
		chance += POD_PLANT_DISEASE_DARK_CHANCE
		exposure_gain += POD_PLANT_EXPOSURE_DARK_BONUS
		source_hint = "darkness"
	if(water_ratio < 0.4)
		chance += POD_PLANT_DISEASE_DRY_CHANCE
		exposure_gain += POD_PLANT_EXPOSURE_DRY_BONUS
		if(!source_hint)
			source_hint = "dehydration"

	if(has_plantbgone_in_body(podperson))
		chance += POD_PLANT_DISEASE_WEEDKILLER_CHANCE
		exposure_gain += POD_PLANT_EXPOSURE_WEEDKILLER_BONUS
		forced_disease = /datum/disease/pod_plant/leaf_rust
		source_hint = "weedkiller stress"

	if(has_dirty_hydro_tray_nearby(podperson))
		chance += POD_PLANT_DISEASE_DIRTY_TRAY_CHANCE
		exposure_gain += POD_PLANT_EXPOSURE_DIRTY_TRAY_BONUS
		if(!source_hint)
			source_hint = "contaminated hydroponics"

	if(has_mold_nearby(podperson))
		chance += POD_PLANT_DISEASE_MOLD_NEARBY_CHANCE
		exposure_gain += POD_PLANT_EXPOSURE_MOLD_BONUS
		if(!forced_disease)
			forced_disease = /datum/disease/pod_plant/powder_mold
		source_hint = "airborne mold"

	if(has_ants_on_turf(podperson))
		var/ant_exposure_mult = podperson.shoes ? POD_PLANT_ANTS_SHOES_MULT : 1
		chance += POD_PLANT_DISEASE_ANTS_CHANCE * ant_exposure_mult
		exposure_gain += POD_PLANT_EXPOSURE_ANTS_BONUS * ant_exposure_mult
		if(ant_exposure_mult >= 1)
			forced_disease = /datum/disease/pod_plant/parasitosis
			source_hint = "parasites from ants"
		else if(!source_hint)
			source_hint = "ants in soil"

	if(has_heavy_pests_nearby(podperson))
		chance += POD_PLANT_DISEASE_HEAVY_PESTS_CHANCE
		exposure_gain += POD_PLANT_EXPOSURE_HEAVY_PESTS_BONUS
		if(!forced_disease)
			forced_disease = /datum/disease/pod_plant/parasitosis
		if(!source_hint)
			source_hint = "heavy pest bloom"

	var/current_exposure = plant_disease_exposure[podperson] || 0
	if(source_hint)
		current_exposure = min(POD_PLANT_EXPOSURE_INFECT_THRESHOLD * 3, current_exposure + (exposure_gain * seconds_per_tick))
	else
		current_exposure = max(0, current_exposure - (POD_PLANT_EXPOSURE_SAFE_DECAY_PER_SECOND * seconds_per_tick))
	plant_disease_exposure[podperson] = current_exposure

	if(current_exposure < POD_PLANT_EXPOSURE_INFECT_THRESHOLD)
		return

	if(!SPT_PROB(chance, seconds_per_tick))
		return

	var/datum/disease/new_disease
	if(forced_disease)
		new_disease = new forced_disease()
	else if(water_ratio < 0.3)
		new_disease = new /datum/disease/pod_plant/root_rot()
	else if(light_level <= POD_PLANT_DISEASE_MIN_LIGHT)
		new_disease = new /datum/disease/pod_plant/powder_mold()
	else
		new_disease = new(pick(/datum/disease/pod_plant/leaf_rust, /datum/disease/pod_plant/powder_mold))

	if(podperson.ForceContractDisease(new_disease, FALSE, TRUE))
		plant_disease_exposure[podperson] = 0
		if(source_hint)
			to_chat(podperson, span_warning("Your plant body shows signs of infection due to [source_hint]."))
		else
			to_chat(podperson, span_warning("Your plant body shows signs of infection."))

/datum/species/pod/proc/has_pod_plant_disease(mob/living/carbon/human/podperson)
	if(!istype(podperson))
		return FALSE

	for(var/datum/disease/active_disease as anything in podperson.diseases)
		if(istype(active_disease, /datum/disease/pod_plant))
			return TRUE

	return FALSE

/datum/species/pod/proc/reset_plant_disease_exposure(mob/living/carbon/human/podperson)
	if(!istype(podperson))
		return
	plant_disease_exposure[podperson] = 0

/datum/species/pod/proc/has_plantbgone_in_body(mob/living/carbon/human/podperson)
	if(!istype(podperson))
		return FALSE
	if(podperson.reagents?.has_reagent(/datum/reagent/toxin/plantbgone/weedkiller, check_subtypes = TRUE))
		return TRUE
	var/obj/item/organ/stomach/belly = podperson.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(belly?.reagents?.has_reagent(/datum/reagent/toxin/plantbgone/weedkiller, check_subtypes = TRUE))
		return TRUE
	return FALSE

/datum/species/pod/proc/has_dirty_hydro_tray_nearby(mob/living/carbon/human/podperson)
	for(var/obj/machinery/hydroponics/tray in range(1, podperson))
		if(tray.pestlevel >= 5 || tray.weedlevel >= 5 || tray.toxic >= 30)
			return TRUE
	return FALSE

/datum/species/pod/proc/has_mold_nearby(mob/living/carbon/human/podperson)
	if(locate(/obj/structure/mold) in range(2, podperson))
		return TRUE
	return FALSE

/datum/species/pod/proc/has_ants_on_turf(mob/living/carbon/human/podperson)
	var/turf/current_turf = get_turf(podperson)
	if(!istype(current_turf))
		return FALSE
	if(locate(/obj/effect/decal/cleanable/ants) in current_turf)
		return TRUE
	return FALSE

/datum/species/pod/proc/has_heavy_pests_nearby(mob/living/carbon/human/podperson)
	for(var/obj/machinery/hydroponics/tray in range(POD_PLANT_HEAVY_PESTS_RANGE, podperson))
		if(tray.pestlevel >= 8)
			return TRUE
	return FALSE

/datum/disease/pod_plant
	form = "Plant infection"
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	spread_text = "Non-contagious"
	agent = "aggressive phytopathogens"
	bypasses_immunity = TRUE
	severity = DISEASE_SEVERITY_MINOR
	stage = 1
	max_stages = 3
	stage_prob = 1.2
	incubation_time = 35
	cure_chance = 8
	cures = list()
	cure_text = "Botanical fertilizers"
	infectable_biotypes = MOB_PLANT
	viable_mobtypes = list(/mob/living/carbon/human)

/datum/disease/pod_plant/is_viable_mobtype(mob_type)
	if(!..())
		return FALSE
	return ispath(mob_type, /mob/living/carbon/human)

/datum/disease/pod_plant/proc/is_podperson()
	if(!ishuman(affected_mob))
		return FALSE
	var/mob/living/carbon/human/human_target = affected_mob
	return human_target.dna?.species?.id == SPECIES_PODPERSON_WEAK

/datum/disease/pod_plant/stage_act(seconds_per_tick)
	if(!is_podperson())
		cure(add_resistance = FALSE)
		return FALSE
	return ..()

/datum/disease/pod_plant/root_rot
	name = "Root Rot"
	desc = "A dehydration-sensitive plant infection that weakens root structure."
	cures = list(/datum/reagent/plantnutriment/eznutriment)
	cure_text = "E-Z Nutrient"

/datum/disease/pod_plant/root_rot/stage_act(seconds_per_tick)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/podperson = affected_mob
	var/mult = stage
	podperson.adjust_blood_volume(-(0.35 * mult * seconds_per_tick), minimum = 0)
	podperson.adjust_stamina_loss(0.65 * mult * seconds_per_tick, updating_stamina = FALSE)
	podperson.adjust_oxy_loss(0.12 * mult * seconds_per_tick, updating_health = FALSE)
	if(SPT_PROB(POD_ROOT_ROT_WHEEZE_CHANCE_PER_STAGE * mult, seconds_per_tick))
		podperson.emote("wheeze")
	if(SPT_PROB(POD_ROOT_ROT_DIZZY_CHANCE_PER_STAGE * mult, seconds_per_tick))
		podperson.adjust_dizzy_up_to(1.5 SECONDS, 6 SECONDS)
		if(prob(35))
			to_chat(podperson, span_warning("Your roots feel brittle and your stance wobbles."))
	podperson.updatehealth()

/datum/disease/pod_plant/leaf_rust
	name = "Leaf Rust"
	desc = "A fungal lesion pattern that dries and chars exposed plant tissue."
	cures = list(/datum/reagent/plantnutriment/robustharvestnutriment)
	cure_text = "Robust Harvest"

/datum/disease/pod_plant/leaf_rust/stage_act(seconds_per_tick)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/podperson = affected_mob
	var/mult = stage
	podperson.adjust_fire_loss(0.16 * mult * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
	podperson.adjust_tox_loss(0.1 * mult * seconds_per_tick, updating_health = FALSE)
	podperson.adjust_nutrition(-(1.0 * mult * seconds_per_tick))
	if(SPT_PROB(POD_LEAF_RUST_COUGH_CHANCE_PER_STAGE * mult, seconds_per_tick))
		podperson.emote("cough")
	if(SPT_PROB(POD_LEAF_RUST_BLUR_CHANCE_PER_STAGE * mult, seconds_per_tick))
		podperson.set_eye_blur_if_lower(4 SECONDS)
		if(prob(35))
			to_chat(podperson, span_warning("Dry, rusty flakes irritate your eyes and throat."))
	podperson.updatehealth()

/datum/disease/pod_plant/powder_mold
	name = "Powder Mold"
	desc = "A powdery mold that clogs plant respiration and slows metabolism."
	cures = list(/datum/reagent/plantnutriment/left4zednutriment)
	cure_text = "Left 4 Zed"

/datum/disease/pod_plant/powder_mold/stage_act(seconds_per_tick)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/podperson = affected_mob
	var/mult = stage
	podperson.adjust_tox_loss(0.16 * mult * seconds_per_tick, updating_health = FALSE)
	podperson.adjust_stamina_loss(0.5 * mult * seconds_per_tick, updating_stamina = FALSE)
	podperson.adjust_nutrition(-(1.5 * mult * seconds_per_tick))
	if(SPT_PROB(POD_POWDER_MOLD_COUGH_CHANCE_PER_STAGE * mult, seconds_per_tick))
		podperson.emote("cough")
	if(SPT_PROB(POD_POWDER_MOLD_SNEEZE_CHANCE_PER_STAGE * mult, seconds_per_tick))
		podperson.emote("sneeze")
	if(SPT_PROB(POD_POWDER_MOLD_CONFUSION_CHANCE_PER_STAGE * mult, seconds_per_tick))
		podperson.adjust_confusion_up_to(1 SECONDS, 5 SECONDS)
		podperson.set_eye_blur_if_lower(4 SECONDS)
		if(prob(40))
			to_chat(podperson, span_warning("Spore dust clouds your vision."))
	podperson.updatehealth()

/datum/disease/pod_plant/parasitosis
	name = "Plant Parasitosis"
	desc = "A swarm-like parasitic infestation irritating plant tissue and draining vitality."
	cures = list(
		/datum/reagent/toxin/pestkiller,
		/datum/reagent/toxin/pestkiller/organic,
	)
	cure_text = "Pesticides (Pestkiller / Organic Pestkiller)"

/datum/disease/pod_plant/parasitosis/stage_act(seconds_per_tick)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/podperson = affected_mob
	var/mult = stage
	podperson.adjust_tox_loss(POD_PARASITOSIS_TOX_PER_STAGE_SECOND * mult * seconds_per_tick, updating_health = FALSE)
	podperson.adjust_brute_loss(POD_PARASITOSIS_BRUTE_PER_STAGE_SECOND * mult * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
	podperson.adjust_stamina_loss(POD_PARASITOSIS_STAMINA_PER_STAGE_SECOND * mult * seconds_per_tick, updating_stamina = FALSE)
	podperson.adjust_nutrition(-(POD_PARASITOSIS_NUTRITION_PER_STAGE_SECOND * mult * seconds_per_tick))
	if(SPT_PROB(POD_PARASITOSIS_SCRATCH_CHANCE_PER_STAGE * mult, seconds_per_tick))
		podperson.emote("scratch")
	if(SPT_PROB(POD_PARASITOSIS_JITTER_CHANCE_PER_STAGE * mult, seconds_per_tick))
		podperson.set_jitter_if_lower(3 SECONDS)
	if(SPT_PROB(POD_PARASITOSIS_CONFUSION_CHANCE_PER_STAGE * mult, seconds_per_tick))
		podperson.adjust_confusion_up_to(0.8 SECONDS, 4 SECONDS)
		if(prob(45))
			to_chat(podperson, span_warning("You feel tiny parasites crawling through your stem tissue."))
	podperson.updatehealth()


// HowlingVoid podperson surgery integration.
/proc/hv_is_podweak_human(mob/living/target)
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/human_target = target
	var/datum/species/species = human_target.dna?.species
	if(!species)
		return FALSE
	return istype(species, /datum/species/pod) || (species.id in list(SPECIES_PODPERSON_WEAK, SPECIES_PODPERSON))

/proc/hv_get_podweak_from_operation_target(atom/movable/operating_on)
	if(isliving(operating_on) && hv_is_podweak_human(operating_on))
		return operating_on
	if(isbodypart(operating_on))
		var/obj/item/bodypart/limb = operating_on
		if(hv_is_podweak_human(limb.owner))
			return limb.owner
	return null

/proc/hv_get_podweak_operation_typepaths()
	return list(
		/datum/surgery_operation/limb/incise_skin/podweak,
		/datum/surgery_operation/limb/retract_skin/podweak,
		/datum/surgery_operation/limb/drill_bones/podweak,
		/datum/surgery_operation/limb/incise_organs/podweak,
		/datum/surgery_operation/limb/close_skin/podweak,
		/datum/surgery_operation/limb/clamp_bleeders/podweak,
		/datum/surgery_operation/limb/unclamp_bleeders/podweak,
		/datum/surgery_operation/basic/tend_wounds/podweak,
		/datum/surgery_operation/limb/saw_bones/podweak,
		/datum/surgery_operation/limb/repair_dislocation/podweak,
		/datum/surgery_operation/limb/repair_hairline/podweak,
		/datum/surgery_operation/limb/reset_compound/podweak,
		/datum/surgery_operation/limb/repair_compound/podweak,
		/datum/surgery_operation/limb/prepare_cranium_repair/podweak,
		/datum/surgery_operation/limb/repair_cranium/podweak,
		/datum/surgery_operation/limb/repair_puncture/podweak,
		/datum/surgery_operation/limb/seal_veins/podweak,
		/datum/surgery_operation/limb/amputate/podweak,
		/datum/surgery_operation/limb/replace_limb/podweak,
		/datum/surgery_operation/limb/organ_manipulation/internal/podweak,
		/datum/surgery_operation/limb/organ_manipulation/external/podweak,
		/datum/surgery_operation/organ/repair/lobectomy/podweak,
		/datum/surgery_operation/organ/repair/hepatectomy/podweak,
		/datum/surgery_operation/organ/repair/coronary_bypass/podweak,
		/datum/surgery_operation/organ/repair/gastrectomy/podweak,
		/datum/surgery_operation/organ/repair/ears/podweak,
		/datum/surgery_operation/organ/repair/eyes/podweak,
		/datum/surgery_operation/organ/repair/brain/podweak,
	)

/proc/hv_is_podweak_operation(datum/surgery_operation/operation)
	if(!istype(operation))
		return FALSE
	return operation.type in hv_get_podweak_operation_typepaths()

/proc/hv_is_pod_surgery_tool(obj/item/tool)
	if(!tool)
		return FALSE
	return istype(tool, /obj/item/secateurs) \
		|| istype(tool, /obj/item/geneshears) \
		|| istype(tool, /obj/item/cultivator) \
		|| istype(tool, /obj/item/reagent_containers/spray/weedspray) \
		|| istype(tool, /obj/item/reagent_containers/spray/pestspray) \
		|| istype(tool, /obj/item/hatchet) \
		|| istype(tool, /obj/item/stack/medical/bone_gel) \
		|| istype(tool, /obj/item/stack/medical/wrap/sticky_tape) \
		|| istype(tool, /obj/item/organ) \
		|| istype(tool, /obj/item/bodypart) \
		|| (tool.tool_behaviour in list(TOOL_DRILL, TOOL_BONESET, TOOL_HEMOSTAT, TOOL_WIRECUTTER, TOOL_SCREWDRIVER, TOOL_CROWBAR))

/datum/species/pod/proc/adjust_operations_for_podweak_target(atom/movable/operating_on, mob/living/surgeon, list/possible_operations)
	SIGNAL_HANDLER

	if(!hv_get_podweak_from_operation_target(operating_on))
		return

	possible_operations.Cut()
	possible_operations += hv_get_podweak_operation_typepaths()

/datum/surgery_operation/limb/incise_skin/podweak
	name = "split bark"
	rnd_name = "Bark Separation"
	desc = "Open the podperson's bark layers to expose inner plant tissue."
	rnd_desc = "Open the podperson's bark layers to expose inner plant tissue."
	implements = list(
		/obj/item/secateurs = 0.9,
		/obj/item/geneshears = 1,
		/obj/item/hatchet = 1.35,
	)

/datum/surgery_operation/limb/incise_skin/podweak/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/incise_skin/podweak/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/secateurs))
		return TRUE
	if(istype(tool, /obj/item/geneshears))
		return TRUE
	return ..()

/datum/surgery_operation/limb/retract_skin/podweak
	name = "separate bark layers"
	rnd_name = "Bark Retraction"
	desc = "Separate plant tissue layers to access inner structures."
	rnd_desc = "Separate plant tissue layers to access inner structures."
	implements = list(
		/obj/item/secateurs = 0.9,
		/obj/item/geneshears = 1,
		/obj/item/hatchet = 1.35,
	)

/datum/surgery_operation/limb/retract_skin/podweak/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/retract_skin/podweak/get_default_radial_image()
	return image(/obj/item/secateurs)

/datum/surgery_operation/limb/close_skin/podweak
	name = "bind bark seam"
	rnd_name = "Bark Binding"
	desc = "Seal and bind damaged bark after plant-tissue work."
	rnd_desc = "Seal and bind damaged bark after plant-tissue work."
	implements = list(
		/obj/item/reagent_containers/spray/weedspray = 0.9,
		/obj/item/reagent_containers/spray/pestspray = 1,
	)

/datum/surgery_operation/limb/close_skin/podweak/get_any_tool()
	return "Botanical spray"

/datum/surgery_operation/limb/close_skin/podweak/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/reagent_containers/spray/weedspray))
		return TRUE
	if(istype(tool, /obj/item/reagent_containers/spray/pestspray))
		return TRUE
	return FALSE

/datum/surgery_operation/limb/close_skin/podweak/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/close_skin/podweak/get_default_radial_image()
	return image(/obj/item/reagent_containers/spray/weedspray)

/datum/surgery_operation/limb/clamp_bleeders/podweak
	name = "stabilize sap channels"
	rnd_name = "Sap Channel Stabilization"
	desc = "Stabilize leaking sap channels in exposed pod tissue."
	rnd_desc = "Stabilize leaking sap channels in exposed pod tissue."
	implements = list(
		/obj/item/secateurs = 0.9,
		/obj/item/geneshears = 1,
	)

/datum/surgery_operation/limb/clamp_bleeders/podweak/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/unclamp_bleeders/podweak
	name = "restore sap flow"
	rnd_name = "Sap Flow Recovery"
	desc = "Restore circulation through stabilized sap channels."
	rnd_desc = "Restore circulation through stabilized sap channels."
	implements = list(
		/obj/item/secateurs = 0.9,
		/obj/item/geneshears = 1,
	)

/datum/surgery_operation/limb/unclamp_bleeders/podweak/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/basic/tend_wounds/podweak
	name = "tend plant tissue"
	rnd_name = "Plant Tissue Tending"
	desc = "Treat bruised and burned plant tissue using botanical instruments."
	rnd_desc = "Treat bruised and burned plant tissue using botanical instruments."
	implements = list(
		/obj/item/reagent_containers/spray/weedspray = 0.9,
		/obj/item/reagent_containers/spray/pestspray = 1,
	)

/datum/surgery_operation/basic/tend_wounds/podweak/snowflake_check_availability(mob/living/patient, mob/living/surgeon, tool, operated_zone)
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(patient)

/datum/surgery_operation/limb/saw_bones/podweak
	name = "prune hardened stem"
	rnd_name = "Stem Pruning"
	desc = "Cut through hardened pod tissue to access deeper structures."
	rnd_desc = "Cut through hardened pod tissue to access deeper structures."
	implements = list(
		/obj/item/hatchet = 1,
		/obj/item/secateurs = 2.85,
	)

/datum/surgery_operation/limb/saw_bones/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/drill_bones/podweak
	name = "auger stem core"
	rnd_name = "Stem Core Augering"
	desc = "Create a controlled opening through dense stem core tissue."
	rnd_desc = "Create a controlled opening through dense stem core tissue."
	implements = list(
		TOOL_DRILL = 1,
		TOOL_SCREWDRIVER = 4,
	)

/datum/surgery_operation/limb/drill_bones/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/incise_organs/podweak
	name = "split inner cambium"
	rnd_name = "Cambium Separation"
	desc = "Open inner cambium layers to access internal pod organs."
	rnd_desc = "Open inner cambium layers to access internal pod organs."
	implements = list(
		/obj/item/secateurs = 0.9,
		/obj/item/geneshears = 1,
	)

/datum/surgery_operation/limb/incise_organs/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/repair_dislocation/podweak
	name = "reset twisted stem"
	rnd_name = "Stem Realignment"
	desc = "Realign a twisted pod stem structure."
	rnd_desc = "Realign a twisted pod stem structure."
	implements = list(
		TOOL_BONESET = 1,
		TOOL_CROWBAR = 2,
	)

/datum/surgery_operation/limb/repair_dislocation/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/repair_hairline/podweak
	name = "mend fine stem crack"
	rnd_name = "Fine Fiber Repair"
	desc = "Repair a minor crack in structural plant fibers."
	rnd_desc = "Repair a minor crack in structural plant fibers."
	implements = list(
		TOOL_BONESET = 1,
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/medical/wrap/sticky_tape/surgical = 1,
		/obj/item/stack/medical/wrap/sticky_tape/super = 2,
		/obj/item/stack/medical/wrap/sticky_tape = 3.33,
	)

/datum/surgery_operation/limb/repair_hairline/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/reset_compound/podweak
	name = "set shattered branch"
	rnd_name = "Branch Reset"
	desc = "Reset a severe branch fracture before final repair."
	rnd_desc = "Reset a severe branch fracture before final repair."
	implements = list(
		TOOL_BONESET = 1,
		/obj/item/stack/medical/wrap/sticky_tape/surgical = 1.66,
		/obj/item/stack/medical/wrap/sticky_tape/super = 2.5,
		/obj/item/stack/medical/wrap/sticky_tape = 5,
	)

/datum/surgery_operation/limb/reset_compound/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/repair_compound/podweak
	name = "repair shattered branch"
	rnd_name = "Branch Reconstruction"
	desc = "Reconstruct a reset branch fracture using graft-safe methods."
	rnd_desc = "Reconstruct a reset branch fracture using graft-safe methods."
	implements = list(
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/medical/wrap/sticky_tape/surgical = 1,
		/obj/item/stack/medical/wrap/sticky_tape/super = 2,
		/obj/item/stack/medical/wrap/sticky_tape = 3.33,
	)

/datum/surgery_operation/limb/repair_compound/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/prepare_cranium_repair/podweak
	name = "clear crown debris"
	rnd_name = "Crown Debridement"
	desc = "Remove debris from cranial plant tissue before repair."
	rnd_desc = "Remove debris from cranial plant tissue before repair."
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_WIRECUTTER = 2.5,
		TOOL_SCREWDRIVER = 2.5,
	)

/datum/surgery_operation/limb/prepare_cranium_repair/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/repair_cranium/podweak
	name = "repair crown structure"
	rnd_name = "Crown Reconstruction"
	desc = "Repair severe structural damage in the pod crown."
	rnd_desc = "Repair severe structural damage in the pod crown."
	implements = list(
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/medical/wrap/sticky_tape/surgical = 1,
		/obj/item/stack/medical/wrap/sticky_tape/super = 2,
		/obj/item/stack/medical/wrap/sticky_tape = 3.33,
	)

/datum/surgery_operation/limb/repair_cranium/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/repair_puncture/podweak
	name = "realign sap channels"
	rnd_name = "Sap Channel Realignment"
	desc = "Realign ruptured sap channels prior to sealing."
	rnd_desc = "Realign ruptured sap channels prior to sealing."
	implements = list(
		/obj/item/secateurs = 0.9,
		/obj/item/geneshears = 1,
	)

/datum/surgery_operation/limb/repair_puncture/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/seal_veins/podweak
	name = "seal sap channels"
	rnd_name = "Sap Channel Sealing"
	desc = "Seal stabilized sap channels to stop fluid loss."
	rnd_desc = "Seal stabilized sap channels to stop fluid loss."

/datum/surgery_operation/limb/seal_veins/podweak/get_any_tool()
	return "Botanical spray"

/datum/surgery_operation/limb/seal_veins/podweak/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/reagent_containers/spray/weedspray))
		return TRUE
	if(istype(tool, /obj/item/reagent_containers/spray/pestspray))
		return TRUE
	return FALSE

/datum/surgery_operation/limb/seal_veins/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/amputate/podweak
	name = "prune limb"
	rnd_name = "Limb Pruning"
	desc = "Remove an irreparably damaged pod limb."
	rnd_desc = "Remove an irreparably damaged pod limb."
	implements = list(
		/obj/item/hatchet = 0.9,
		/obj/item/secateurs = 1.2,
	)

/datum/surgery_operation/limb/amputate/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/replace_limb/podweak
	name = "graft prosthetic limb"
	rnd_name = "Limb Grafting"
	desc = "Attach a replacement limb as a grafted prosthetic."
	rnd_desc = "Attach a replacement limb as a grafted prosthetic."

/datum/surgery_operation/limb/replace_limb/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/organ_manipulation/internal/podweak
	name = "internal tissue manipulation"
	rnd_name = "Internal Tissue Manipulation"
	desc = "Manipulate internal pod organs and tissue modules."
	rnd_desc = "Manipulate internal pod organs and tissue modules."
	remove_implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/limb/organ_manipulation/internal/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/limb/organ_manipulation/external/podweak
	name = "external tissue manipulation"
	rnd_name = "External Tissue Manipulation"
	desc = "Manipulate external pod features such as tails and frills."
	rnd_desc = "Manipulate external pod features such as tails and frills."
	remove_implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/limb/organ_manipulation/external/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isbodypart(operating_on))
		return FALSE
	var/obj/item/bodypart/limb = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(limb.owner)

/datum/surgery_operation/organ/repair/lobectomy/podweak
	name = "trim damaged respiratory frond"
	rnd_name = "Respiratory Frond Trimming"
	desc = "Repair damaged respiratory tissue by trimming a bad frond."
	rnd_desc = "Repair damaged respiratory tissue by trimming a bad frond."
	implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/organ/repair/lobectomy/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isorgan(operating_on))
		return FALSE
	var/obj/item/organ/organ = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(organ.owner)

/datum/surgery_operation/organ/repair/hepatectomy/podweak
	name = "remove damaged filtration tissue"
	rnd_name = "Filtration Tissue Excision"
	desc = "Excise badly damaged filtration tissue from the organ."
	rnd_desc = "Excise badly damaged filtration tissue from the organ."
	implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/organ/repair/hepatectomy/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isorgan(operating_on))
		return FALSE
	var/obj/item/organ/organ = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(organ.owner)

/datum/surgery_operation/organ/repair/coronary_bypass/podweak
	name = "graft sap bypass"
	rnd_name = "Sap Bypass Graft"
	desc = "Create a bypass to restore flow around damaged heart tissue."
	rnd_desc = "Create a bypass to restore flow around damaged heart tissue."
	implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/organ/repair/coronary_bypass/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isorgan(operating_on))
		return FALSE
	var/obj/item/organ/organ = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(organ.owner)

/datum/surgery_operation/organ/repair/gastrectomy/podweak
	name = "prune damaged digestion tissue"
	rnd_name = "Digestive Tissue Pruning"
	desc = "Remove damaged digestive tissue to restore function."
	rnd_desc = "Remove damaged digestive tissue to restore function."
	implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/organ/repair/gastrectomy/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isorgan(operating_on))
		return FALSE
	var/obj/item/organ/organ = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(organ.owner)

/datum/surgery_operation/organ/repair/ears/podweak
	name = "sensory frond surgery"
	rnd_name = "Sensory Frond Repair"
	desc = "Repair pod auditory/sensory frond structures."
	rnd_desc = "Repair pod auditory/sensory frond structures."
	implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/organ/repair/ears/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isorgan(operating_on))
		return FALSE
	var/obj/item/organ/organ = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(organ.owner)

/datum/surgery_operation/organ/repair/eyes/podweak
	name = "oculus bloom surgery"
	rnd_name = "Oculus Bloom Repair"
	desc = "Repair visual bloom tissue to restore sight."
	rnd_desc = "Repair visual bloom tissue to restore sight."
	implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/organ/repair/eyes/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isorgan(operating_on))
		return FALSE
	var/obj/item/organ/organ = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(organ.owner)

/datum/surgery_operation/organ/repair/brain/podweak
	name = "crown core surgery"
	rnd_name = "Crown Core Repair"
	desc = "Repair high-level cognition tissue in the crown core."
	rnd_desc = "Repair high-level cognition tissue in the crown core."
	implements = list(
		/obj/item/geneshears = 0.9,
		/obj/item/secateurs = 1,
	)

/datum/surgery_operation/organ/repair/brain/podweak/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	if(!isorgan(operating_on))
		return FALSE
	var/obj/item/organ/organ = operating_on
	return ..() && hv_is_pod_surgery_tool(tool) && hv_is_podweak_human(organ.owner)

