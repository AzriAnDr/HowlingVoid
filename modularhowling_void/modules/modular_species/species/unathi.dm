/datum/species/unathi
	// Mirror of custom lizard passives/abilities for unathi.
	damage_modifier = 10
	var/maxHealth_bonus = 10
	/// Species-granted actions tracked for cleanup.
	var/tmp/list/species_venom_action = list()
	var/tmp/list/species_regen_action = list()
	var/tmp/list/species_tail_regen_action = list()

/datum/species/unathi/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	if(!istype(human_who_gained_species))
		return

	// Max HP bonus
	human_who_gained_species.maxHealth += maxHealth_bonus
	human_who_gained_species.health += maxHealth_bonus

	. = ..()

	var/datum/action/cooldown/mob_cooldown/venomous_bite/lizard/old_venom = species_venom_action[human_who_gained_species]
	if(old_venom)
		old_venom.Remove(human_who_gained_species)
		qdel(old_venom)
	species_venom_action[human_who_gained_species] = null

	var/datum/action/cooldown/regenerate_limbs/lizard/old_regen = species_regen_action[human_who_gained_species]
	if(old_regen)
		old_regen.Remove(human_who_gained_species)
		qdel(old_regen)
	species_regen_action[human_who_gained_species] = null

	var/datum/action/cooldown/regenerate_tail/lizard/old_tail_regen = species_tail_regen_action[human_who_gained_species]
	if(old_tail_regen)
		old_tail_regen.Remove(human_who_gained_species)
		qdel(old_tail_regen)
	species_tail_regen_action[human_who_gained_species] = null

	var/datum/action/cooldown/mob_cooldown/venomous_bite/lizard/action = new()
	action.Grant(human_who_gained_species)
	species_venom_action[human_who_gained_species] = action

	var/datum/action/cooldown/regenerate_limbs/lizard/regeneration = new()
	regeneration.Grant(human_who_gained_species)
	species_regen_action[human_who_gained_species] = regeneration

	var/datum/action/cooldown/regenerate_tail/lizard/tail_regeneration = new()
	tail_regeneration.Grant(human_who_gained_species)
	species_tail_regen_action[human_who_gained_species] = tail_regeneration

	var/obj/item/bodypart/arm/left/left_arm = human_who_gained_species.get_bodypart(BODY_ZONE_L_ARM)
	if(left_arm)
		left_arm.unarmed_attack_verbs = list("slash")
		left_arm.unarmed_attack_effect = ATTACK_EFFECT_CLAW
		left_arm.unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
		left_arm.unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
		left_arm.unarmed_sharpness = SHARP_EDGED

	var/obj/item/bodypart/arm/right/right_arm = human_who_gained_species.get_bodypart(BODY_ZONE_R_ARM)
	if(right_arm)
		right_arm.unarmed_attack_verbs = list("slash")
		right_arm.unarmed_attack_effect = ATTACK_EFFECT_CLAW
		right_arm.unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
		right_arm.unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
		right_arm.unarmed_sharpness = SHARP_EDGED

	RegisterSignal(human_who_gained_species, COMSIG_MOVABLE_SET_GRAB_STATE, PROC_REF(on_grab))

/datum/species/unathi/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	if(!istype(human))
		return

	. = ..()

	human.maxHealth -= maxHealth_bonus
	human.health -= maxHealth_bonus

	var/obj/item/bodypart/arm/left/left_arm = human.get_bodypart(BODY_ZONE_L_ARM)
	if(left_arm)
		left_arm.unarmed_attack_verbs = initial(left_arm.unarmed_attack_verbs)
		left_arm.unarmed_attack_effect = initial(left_arm.unarmed_attack_effect)
		left_arm.unarmed_attack_sound = initial(left_arm.unarmed_attack_sound)
		left_arm.unarmed_miss_sound = initial(left_arm.unarmed_miss_sound)
		left_arm.unarmed_sharpness = initial(left_arm.unarmed_sharpness)

	var/obj/item/bodypart/arm/right/right_arm = human.get_bodypart(BODY_ZONE_R_ARM)
	if(right_arm)
		right_arm.unarmed_attack_verbs = initial(right_arm.unarmed_attack_verbs)
		right_arm.unarmed_attack_effect = initial(right_arm.unarmed_attack_effect)
		right_arm.unarmed_attack_sound = initial(right_arm.unarmed_attack_sound)
		right_arm.unarmed_miss_sound = initial(right_arm.unarmed_miss_sound)
		right_arm.unarmed_sharpness = initial(right_arm.unarmed_sharpness)

	var/datum/action/cooldown/mob_cooldown/venomous_bite/lizard/action = species_venom_action[human]
	if(action)
		action.Remove(human)
		qdel(action)
	species_venom_action[human] = null

	var/datum/action/cooldown/regenerate_limbs/lizard/regeneration = species_regen_action[human]
	if(regeneration)
		regeneration.Remove(human)
		qdel(regeneration)
	species_regen_action[human] = null

	var/datum/action/cooldown/regenerate_tail/lizard/tail_regeneration = species_tail_regen_action[human]
	if(tail_regeneration)
		tail_regeneration.Remove(human)
		qdel(tail_regeneration)
	species_tail_regen_action[human] = null

	UnregisterSignal(human, COMSIG_MOVABLE_SET_GRAB_STATE)

/datum/species/unathi/proc/on_grab(mob/unathi, new_state)
	SIGNAL_HANDLER

	if((new_state > GRAB_PASSIVE || unathi.has_movespeed_modifier(/datum/movespeed_modifier/grab_slowdown)) && !unathi.has_movespeed_modifier(/datum/movespeed_modifier/lizard_grab_speedboost))
		unathi.add_movespeed_modifier(/datum/movespeed_modifier/lizard_grab_speedboost)
	else if (new_state == GRAB_PASSIVE && unathi.has_movespeed_modifier(/datum/movespeed_modifier/lizard_grab_speedboost))
		unathi.remove_movespeed_modifier(/datum/movespeed_modifier/lizard_grab_speedboost)

/datum/species/unathi/create_pref_unique_perks()
	. = ..()
	. += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_SHIELD,
			SPECIES_PERK_NAME = "Scaled Hide",
			SPECIES_PERK_DESC = "Unathi have slightly better all-around damage resistance.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_TOOTH,
			SPECIES_PERK_NAME = "Venomous Bite",
			SPECIES_PERK_DESC = "You can inject venom with a close bite attack.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_HAND_SPARKLES,
			SPECIES_PERK_NAME = "Regrow Limbs",
			SPECIES_PERK_DESC = "You can regenerate missing limbs by spending nutrition.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_SCISSORS,
			SPECIES_PERK_NAME = "Tail Autotomy",
			SPECIES_PERK_DESC = "Tail pulls can tear your tail off. You can regrow it with the Regrow Tail ability.",
		),
	)
