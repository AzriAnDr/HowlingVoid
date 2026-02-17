/datum/species/hemophage/New()
	. = ..()

/datum/species/hemophage/on_species_gain(mob/living/carbon/human/new_hemophage, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if(istype(new_hemophage))
		new_hemophage.apply_status_effect(/datum/status_effect/blood_regen_active)

/datum/species/hemophage/on_species_loss(mob/living/carbon/human/former_hemophage, datum/species/new_species, pref_load)
	. = ..()
	if(istype(former_hemophage))
		former_hemophage.remove_status_effect(/datum/status_effect/blood_regen_active)


/obj/item/organ/heart/hemophage/proc/can_passive_dark_regen(mob/living/carbon/human/hemophage)
	if(in_closet(hemophage))
		return TRUE

	var/turf/current_turf = get_turf(hemophage)
	if(!istype(current_turf))
		return FALSE

	return current_turf.get_lumcount() <= HEMOPHAGE_DARK_REGEN_LIGHT_THRESHOLD


/obj/item/organ/heart/hemophage/proc/has_healable_dark_regen_damage(mob/living/carbon/human/hemophage)
	if(hemophage.get_tox_loss() > 0 && hemophage.can_adjust_tox_loss())
		return TRUE

	if(length(hemophage.get_damaged_bodyparts(brute = TRUE, burn = FALSE, required_bodytype = BODYTYPE_ORGANIC)))
		return TRUE

	if(length(hemophage.get_damaged_bodyparts(brute = FALSE, burn = TRUE, required_bodytype = BODYTYPE_ORGANIC)))
		return TRUE

	return FALSE


/datum/status_effect/blood_regen_active
	id = "blood_regen_active"
	status_type = STATUS_EFFECT_UNIQUE
	processing_speed = STATUS_EFFECT_FAST_PROCESS
	tick_interval = HEMOPHAGE_DARK_REGEN_START_DELAY
	alert_type = null
	var/time_in_darkness = 0

/datum/status_effect/blood_regen_active/tick(seconds_between_ticks)
	var/mob/living/carbon/human/regenerator = owner
	if(!istype(regenerator))
		return

	var/obj/item/organ/heart/hemophage/tumor_heart = regenerator.get_organ_by_type(/obj/item/organ/heart/hemophage)
	if(!istype(tumor_heart) || tumor_heart.is_dormant)
		time_in_darkness = 0
		return

	if(regenerator.get_blood_volume() <= MINIMUM_VOLUME_FOR_REGEN)
		time_in_darkness = 0
		return

	if(!tumor_heart.can_passive_dark_regen(regenerator))
		time_in_darkness = 0
		return

	if(!tumor_heart.has_healable_dark_regen_damage(regenerator))
		time_in_darkness = 0
		return

	time_in_darkness += (seconds_between_ticks SECONDS)
	if(time_in_darkness < HEMOPHAGE_DARK_REGEN_START_DELAY)
		return

	var/max_blood_for_regen = regenerator.get_blood_volume() - MINIMUM_VOLUME_FOR_REGEN
	if(max_blood_for_regen <= 0)
		time_in_darkness = 0
		return

	var/blood_used = 0

	var/brute_damage = regenerator.get_brute_loss()
	if(brute_damage && length(regenerator.get_damaged_bodyparts(brute = TRUE, burn = FALSE, required_bodytype = BODYTYPE_ORGANIC)))
		var/brutes_to_heal = min(max_blood_for_regen, min(HEMOPHAGE_DARK_REGEN_BRUTE_PER_SECOND, brute_damage) * seconds_between_ticks)
		if(brutes_to_heal > 0)
			regenerator.adjust_brute_loss(-brutes_to_heal, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
			blood_used += brutes_to_heal
			max_blood_for_regen -= brutes_to_heal

	var/burn_damage = regenerator.get_fire_loss()
	if(burn_damage && max_blood_for_regen > 0 && length(regenerator.get_damaged_bodyparts(brute = FALSE, burn = TRUE, required_bodytype = BODYTYPE_ORGANIC)))
		var/burns_to_heal = min(max_blood_for_regen, min(HEMOPHAGE_DARK_REGEN_BURN_PER_SECOND, burn_damage) * seconds_between_ticks)
		if(burns_to_heal > 0)
			regenerator.adjust_fire_loss(-burns_to_heal, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
			blood_used += burns_to_heal
			max_blood_for_regen -= burns_to_heal

	var/toxin_damage = regenerator.get_tox_loss()
	if(toxin_damage && max_blood_for_regen > 0 && regenerator.can_adjust_tox_loss())
		var/toxins_to_heal = min(max_blood_for_regen, min(HEMOPHAGE_DARK_REGEN_TOX_PER_SECOND, toxin_damage) * seconds_between_ticks)
		if(toxins_to_heal > 0)
			regenerator.adjust_tox_loss(-toxins_to_heal, updating_health = FALSE, forced = TRUE)
			blood_used += toxins_to_heal

	if(blood_used <= 0)
		time_in_darkness = 0
		return

	regenerator.adjust_blood_volume(-blood_used * HEMOPHAGE_DARK_REGEN_BLOOD_COST_PER_DAMAGE)
	regenerator.updatehealth()
	new /obj/effect/temp_visual/heal(get_turf(regenerator), COLOR_EFFECT_HEAL_RED)
