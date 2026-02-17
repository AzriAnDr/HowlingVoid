/datum/movespeed_modifier/dullahan_headless_disorientation
	multiplicative_slowdown = 0.18

/datum/movespeed_modifier/dullahan_headless_severe_disorientation
	multiplicative_slowdown = 0.30

/mob/living/carbon/human
	/// Runtime toggle to avoid repeatedly multiplying/dividing focus modifiers.
	var/tmp/dullahan_focus_active = FALSE
	/// Cooldown for head threat warnings.
	var/tmp/dullahan_next_threat_ping = 0

/datum/species/dullahan
	/// Control resistance multiplier while being a Dullahan.
	var/dullahan_stun_mod = 0.9
	/// How far the body can be from the head before penalties start.
	var/dullahan_safe_head_distance = 1
	/// Distance where disorientation becomes severe.
	var/dullahan_severe_head_distance = 5
	/// Healing effectiveness while the head is separated from the body.
	var/dullahan_separated_heal_multiplier = 0.8
	/// Extra incoming damage on head hits.
	var/dullahan_head_hit_vulnerability = 1.12
	/// Extra incoming damage on head hits while separated.
	var/dullahan_separated_head_hit_vulnerability = 1.22
	/// Threat sensing range around detached head.
	var/dullahan_threat_sense_range = 6
	/// Cooldown in deciseconds between threat warnings.
	var/dullahan_threat_ping_cooldown = 30

/datum/species/dullahan/on_species_gain(mob/living/carbon/human/human, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if(!human)
		return

	human.dullahan_focus_active = FALSE
	human.dullahan_next_threat_ping = 0
	human.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_disorientation)
	human.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_severe_disorientation)

	RegisterSignal(human, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(on_dullahan_damage_modifiers))
	RegisterSignals(human, COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES, PROC_REF(on_dullahan_adjust_healing))

/datum/species/dullahan/on_species_loss(mob/living/carbon/human/human)
	if(human)
		set_focus_state(human, FALSE)
		human.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_disorientation)
		human.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_severe_disorientation)
		UnregisterSignal(human, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)
		UnregisterSignal(human, COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES)
	. = ..()

/datum/species/dullahan/spec_life(mob/living/carbon/human/source, seconds_per_tick)
	. = ..()
	if(!source || QDELETED(source))
		return

	var/head_distance = get_head_distance(source)
	var/head_is_close = (head_distance <= dullahan_safe_head_distance)
	set_focus_state(source, head_is_close)

	if(QDELETED(my_head))
		set_focus_state(source, FALSE)
		source.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_disorientation)
		source.add_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_severe_disorientation)
		source.adjust_confusion_up_to(0.8 SECONDS * seconds_per_tick, 6 SECONDS)
		source.adjust_eye_blur_up_to(0.8 SECONDS * seconds_per_tick, 8 SECONDS)
		return

	if(head_distance > dullahan_severe_head_distance)
		source.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_disorientation)
		source.add_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_severe_disorientation)
		source.adjust_confusion_up_to(0.7 SECONDS * seconds_per_tick, 5 SECONDS)
		source.adjust_eye_blur_up_to(0.7 SECONDS * seconds_per_tick, 6 SECONDS)
		return

	if(head_distance > dullahan_safe_head_distance)
		source.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_severe_disorientation)
		source.add_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_disorientation)
		source.adjust_confusion_up_to(0.5 SECONDS * seconds_per_tick, 4 SECONDS)
		source.adjust_eye_blur_up_to(0.5 SECONDS * seconds_per_tick, 5 SECONDS)
		return

	source.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_disorientation)
	source.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_severe_disorientation)
	scan_head_for_threats(source)

/datum/species/dullahan/proc/get_head_distance(mob/living/carbon/human/source)
	if(!source || QDELETED(source) || QDELETED(my_head))
		return INFINITY

	var/turf/body_turf = get_turf(source)
	var/turf/head_turf = get_turf(my_head)
	if(!body_turf || !head_turf)
		return INFINITY

	return get_dist(body_turf, head_turf)

/datum/species/dullahan/proc/set_focus_state(mob/living/carbon/human/source, enabled)
	if(!source)
		return
	if(enabled == source.dullahan_focus_active)
		return

	if(enabled)
		source.physiology.stun_mod *= dullahan_stun_mod
		source.physiology.knockdown_mod *= dullahan_stun_mod
	else
		source.physiology.stun_mod /= dullahan_stun_mod
		source.physiology.knockdown_mod /= dullahan_stun_mod

	source.dullahan_focus_active = enabled

/datum/species/dullahan/proc/is_head_zone_hit(def_zone)
	if(isbodypart(def_zone))
		var/obj/item/bodypart/part = def_zone
		return part.body_zone == BODY_ZONE_HEAD

	return def_zone == BODY_ZONE_HEAD

/datum/species/dullahan/proc/on_dullahan_damage_modifiers(mob/living/carbon/human/source, list/damage_mods, damage, damagetype, def_zone, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER
	if(!is_head_zone_hit(def_zone))
		return

	var/head_distance = get_head_distance(source)
	if(head_distance > dullahan_safe_head_distance)
		damage_mods += dullahan_separated_head_hit_vulnerability
		return

	damage_mods += dullahan_head_hit_vulnerability

/datum/species/dullahan/proc/on_dullahan_adjust_healing(mob/living/carbon/human/source, type, amount, forced)
	SIGNAL_HANDLER
	if(forced || amount >= 0)
		return
	if(get_head_distance(source) <= dullahan_safe_head_distance)
		return

	var/new_amount = amount * dullahan_separated_heal_multiplier
	switch(type)
		if(BRUTE)
			source.adjust_brute_loss(new_amount, forced = TRUE)
		if(BURN)
			source.adjust_fire_loss(new_amount, forced = TRUE)
		if(OXY)
			source.adjust_oxy_loss(new_amount, forced = TRUE)
		if(TOX)
			source.adjust_tox_loss(new_amount, forced = TRUE)
		else
			return

	return COMPONENT_IGNORE_CHANGE

/datum/species/dullahan/proc/scan_head_for_threats(mob/living/carbon/human/source)
	if(!source || QDELETED(source) || QDELETED(my_head))
		return
	if(!prevent_perspective_change) // Threat sensing only when looking through the detached head.
		return
	if(source.dullahan_next_threat_ping > world.time)
		return

	var/turf/head_turf = get_turf(my_head)
	if(!head_turf)
		return

	for(var/mob/living/potential in orange(dullahan_threat_sense_range, head_turf))
		if(potential == source || potential.stat >= UNCONSCIOUS)
			continue
		if(!potential.combat_mode)
			continue

		var/direction = get_dir(head_turf, get_turf(potential))
		to_chat(source, span_warning("Your detached sight catches hostile movement to the [dir2text(direction)]!"))
		source.dullahan_next_threat_ping = world.time + dullahan_threat_ping_cooldown
		break

/datum/species/dullahan/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_EYE,
			SPECIES_PERK_NAME = "Detached Threat Sense",
			SPECIES_PERK_DESC = "While seeing through the detached head, Dullahans can sense nearby hostile movement around it.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_SHIELD,
			SPECIES_PERK_NAME = "Focused Undead",
			SPECIES_PERK_DESC = "Dullahans are harder to stun or knock down while body and head stay close.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "horse-head",
			SPECIES_PERK_NAME = "Headless and Horseless",
			SPECIES_PERK_DESC = "If body and head are too far apart, Dullahans become disoriented, slower, and less precise.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_BRIEFCASE_MEDICAL,
			SPECIES_PERK_NAME = "Split Recovery",
			SPECIES_PERK_DESC = "Dullahan healing is weaker while body and head are separated.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_BULLSEYE,
			SPECIES_PERK_NAME = "Exposed Head",
			SPECIES_PERK_DESC = "Head hits deal extra damage to Dullahans, especially while separated.",
		),
	)

	return to_add
