/datum/species/lizard
	// 10% damage resistance
	damage_modifier = 10
	var/maxHealth_bonus = 10
	/// Species-granted actions tracked for cleanup.
	var/tmp/list/species_venom_action = list()
	var/tmp/list/species_regen_action = list()
	var/tmp/list/species_tail_regen_action = list()

/datum/species/lizard/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
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

/datum/species/lizard/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
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

/datum/species/lizard/proc/on_grab(mob/lizard, new_state)
	SIGNAL_HANDLER

	if((new_state > GRAB_PASSIVE || lizard.has_movespeed_modifier(/datum/movespeed_modifier/grab_slowdown)) && !lizard.has_movespeed_modifier(/datum/movespeed_modifier/lizard_grab_speedboost))
		lizard.add_movespeed_modifier(/datum/movespeed_modifier/lizard_grab_speedboost)
	else if (new_state == GRAB_PASSIVE && lizard.has_movespeed_modifier(/datum/movespeed_modifier/lizard_grab_speedboost))
		lizard.remove_movespeed_modifier(/datum/movespeed_modifier/lizard_grab_speedboost)

/datum/movespeed_modifier/lizard_grab_speedboost
	multiplicative_slowdown = -2


// Venomous bite
/datum/action/cooldown/mob_cooldown/venomous_bite/lizard
	name = "Venomous Bite"
	cooldown_time = 1.5 SECONDS
	click_to_activate = TRUE

/datum/action/cooldown/mob_cooldown/venomous_bite/lizard/New(Target, original, datum/reagent/our_reagent, quantity_override)
	. = ..(our_reagent = /datum/reagent/toxin/venom)

/datum/action/cooldown/mob_cooldown/venomous_bite/lizard/set_reagent(datum/reagent/new_reagent, quantity_override, cooldown_override)
	reagent_typepath = new_reagent

/datum/action/cooldown/mob_cooldown/venomous_bite/lizard/Activate(atom/target_atom)
	if (!isliving(target_atom))
		return FALSE
	if (iscarbon(owner))
		var/mob/living/carbon/carbon_holder = owner
		if (carbon_holder.is_mouth_covered())
			owner.balloon_alert(owner, "mouth covered!")
			return FALSE

	var/mob/living/target = target_atom

	if (!owner.Adjacent(target))
		owner.balloon_alert(owner, "too far away!")
		return FALSE

	if (target == owner)
		owner.balloon_alert(owner, "you can't bite yourself!")
		return FALSE

	owner.visible_message(span_warning("[owner] bites [target]!"), span_warning("You bite [target]!"), ignored_mobs = target)
	to_chat(target, span_userdanger("[owner] bites you!"))

	StartCooldown()

	var/penetrated = try_bite(target)
	if (penetrated)
		inject(target)
	return TRUE

/datum/action/cooldown/mob_cooldown/venomous_bite/lizard/add_reagents(datum/reagents/target, harvesting = FALSE)
	var/temp
	if (ishuman(owner))
		var/mob/living/carbon/human/human_holder = owner
		temp = human_holder.coretemperature

	target.add_reagent(reagent_typepath, 5, reagtemp = temp)
	return TRUE



/// Limb regeneration
/datum/action/cooldown/regenerate_limbs/lizard
	name = "Regrow Limbs"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeheal"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	cooldown_time = 5 SECONDS

	var/limb_regeneration_cost = 50

/datum/action/cooldown/regenerate_limbs/lizard/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs() - BODY_ZONE_HEAD - BODY_ZONE_CHEST
	if(!length(limbs_to_heal))
		return FALSE
	if(H.nutrition >= NUTRITION_LEVEL_HUNGRY + limb_regeneration_cost)
		return TRUE

/datum/action/cooldown/regenerate_limbs/lizard/Activate()
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs() - BODY_ZONE_HEAD - BODY_ZONE_CHEST
	if(!length(limbs_to_heal))
		to_chat(H, span_notice("You have nothing to regrow."))
		return
	to_chat(H, span_notice("You focus on regrowing [length(limbs_to_heal) >= 2 ? "lost limbs" : "a lost limb"]..."))
	if(do_after(H, 3 SECONDS, H))
		if(H.nutrition >= limb_regeneration_cost * length(limbs_to_heal) + NUTRITION_LEVEL_HUNGRY)
			for(var/limb_zone in limbs_to_heal)
				H.regenerate_limb(limb_zone)
			H.nutrition -= limb_regeneration_cost * length(limbs_to_heal)
			to_chat(H, span_notice("...and moments later, you have them back!"))
			return
		else if(H.nutrition >= limb_regeneration_cost)
			while(H.nutrition >= NUTRITION_LEVEL_HUNGRY + limb_regeneration_cost)
				var/healed_limb = pick(limbs_to_heal)
				H.regenerate_limb(healed_limb)
				limbs_to_heal -= healed_limb
				H.nutrition -= limb_regeneration_cost
			to_chat(H, span_warning("...but you don't have enough energy! Eat more to fully recover!"))
			return
		to_chat(H, span_warning("...but you're starving! You can't do this on an empty stomach!"))
	to_chat(H, span_notice("...but at the last moment, you change your mind."))

	. = ..()
	return TRUE

/// Tail regeneration
/datum/action/cooldown/regenerate_tail/lizard
	name = "Regrow Tail"
	desc = "Regrow your lost tail by spending nutrition."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeheal"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	cooldown_time = 10 SECONDS

	var/tail_regeneration_cost = 10
	var/tail_regen_time = 3 SECONDS

/datum/action/cooldown/regenerate_tail/lizard/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	if(H.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL))
		return FALSE
	return TRUE

/datum/action/cooldown/regenerate_tail/lizard/Activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	if(H.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL))
		to_chat(H, span_notice("You already have a tail."))
		return FALSE

	if(H.nutrition < (NUTRITION_LEVEL_HUNGRY + tail_regeneration_cost))
		to_chat(H, span_warning("You need more nutrition to regrow your tail."))
		return FALSE

	to_chat(H, span_notice("You focus on regrowing your tail..."))
	if(!do_after(H, tail_regen_time, H))
		to_chat(H, span_notice("You lose concentration."))
		return FALSE

	if(H.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL))
		return FALSE

	var/obj/item/organ/tail/lizard/new_tail = new()
	if(!new_tail.Insert(H))
		qdel(new_tail)
		to_chat(H, span_warning("Your tail fails to regrow."))
		return FALSE

	H.nutrition -= tail_regeneration_cost
	to_chat(H, span_notice("Your tail regrows."))
	StartCooldown()
	return TRUE

/datum/species/lizard/create_pref_unique_perks()
	. = ..()
	. += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_SHIELD,
			SPECIES_PERK_NAME = "Scaled Hide",
			SPECIES_PERK_DESC = "Lizards have slightly better all-around damage resistance.",
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
