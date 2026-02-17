/datum/species/pod/podweak
	/// Per-mob accumulated plant-pathogen exposure for realistic infection timing.
	var/tmp/list/plant_disease_exposure = list()

/datum/species/pod/podweak/proc/try_contract_plant_disease(mob/living/carbon/human/podperson, seconds_per_tick)
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

/datum/species/pod/podweak/proc/has_pod_plant_disease(mob/living/carbon/human/podperson)
	if(!istype(podperson))
		return FALSE

	for(var/datum/disease/active_disease as anything in podperson.diseases)
		if(istype(active_disease, /datum/disease/pod_plant))
			return TRUE

	return FALSE

/datum/species/pod/podweak/proc/reset_plant_disease_exposure(mob/living/carbon/human/podperson)
	if(!istype(podperson))
		return
	plant_disease_exposure[podperson] = 0

/datum/species/pod/podweak/proc/has_plantbgone_in_body(mob/living/carbon/human/podperson)
	if(!istype(podperson))
		return FALSE
	if(podperson.reagents?.has_reagent(/datum/reagent/toxin/plantbgone/weedkiller, check_subtypes = TRUE))
		return TRUE
	var/obj/item/organ/stomach/belly = podperson.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(belly?.reagents?.has_reagent(/datum/reagent/toxin/plantbgone/weedkiller, check_subtypes = TRUE))
		return TRUE
	return FALSE

/datum/species/pod/podweak/proc/has_dirty_hydro_tray_nearby(mob/living/carbon/human/podperson)
	for(var/obj/machinery/hydroponics/tray in range(1, podperson))
		if(tray.pestlevel >= 5 || tray.weedlevel >= 5 || tray.toxic >= 30)
			return TRUE
	return FALSE

/datum/species/pod/podweak/proc/has_mold_nearby(mob/living/carbon/human/podperson)
	if(locate(/obj/structure/mold) in range(2, podperson))
		return TRUE
	return FALSE

/datum/species/pod/podweak/proc/has_ants_on_turf(mob/living/carbon/human/podperson)
	var/turf/current_turf = get_turf(podperson)
	if(!istype(current_turf))
		return FALSE
	if(locate(/obj/effect/decal/cleanable/ants) in current_turf)
		return TRUE
	return FALSE

/datum/species/pod/podweak/proc/has_heavy_pests_nearby(mob/living/carbon/human/podperson)
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
