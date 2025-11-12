/datum/species/lizard
	//10% к защите от урона
	damage_modifier = 10
	var/maxHealth_bonus = 10

/datum/species/lizard/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	//Прибавка к макс хп
	human_who_gained_species.maxHealth += maxHealth_bonus
	human_who_gained_species.health += maxHealth_bonus

	. = ..()

	var/datum/action/cooldown/mob_cooldown/venomous_bite/lizard/action = new()
	action.Grant(human_who_gained_species)

	var/datum/action/cooldown/regenerate_limbs/lizard/regeneration = new()
	regeneration.Grant(human_who_gained_species)

	//Удары когтями к обычному урону
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

	UnregisterSignal(human, COMSIG_MOVABLE_SET_GRAB_STATE)

/datum/species/lizard/proc/on_grab(mob/lizard, new_state)
	SIGNAL_HANDLER

	if(new_state > GRAB_PASSIVE && !lizard.has_movespeed_modifier(/datum/movespeed_modifier/lizard_grab_speedboost))
		to_chat(lizard, "aaa")
		lizard.add_movespeed_modifier(/datum/movespeed_modifier/lizard_grab_speedboost)
	else if (new_state == GRAB_PASSIVE && lizard.has_movespeed_modifier(/datum/movespeed_modifier/lizard_grab_speedboost))
		lizard.remove_movespeed_modifier(/datum/movespeed_modifier/lizard_grab_speedboost)

/datum/movespeed_modifier/lizard_grab_speedboost
	multiplicative_slowdown = -2


/datum/action/cooldown/mob_cooldown/venomous_bite/lizard
	name = "Ядовитый укус"
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
			owner.balloon_alert(owner, "рот закрыт!")
			return FALSE

	var/mob/living/target = target_atom

	if (!owner.Adjacent(target))
		owner.balloon_alert(owner, "слишком далеко!")
		return FALSE

	if (target == owner)
		owner.balloon_alert(owner, "нельзя укусить себя!")
		return FALSE

	owner.visible_message(span_warning("[owner] кусает [target]!"), span_warning("Ты кусаешь [target]!"), ignored_mobs = target)
	to_chat(target, span_userdanger("[owner] кусает тебя!"))

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














/datum/action/cooldown/regenerate_limbs/lizard
	name = "Отращивание конечностей"
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
	var/list/limbs_to_heal = H.get_missing_limbs()
	if(!length(limbs_to_heal))
		return FALSE
	if(H.nutrition >= NUTRITION_LEVEL_HUNGRY + limb_regeneration_cost)
		return TRUE

/datum/action/cooldown/regenerate_limbs/lizard/Activate()
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs() - BODY_ZONE_HEAD - BODY_ZONE_CHEST
	if(!length(limbs_to_heal))
		to_chat(H, span_notice("Тебе нечего отращивать."))
		return
	to_chat(H, span_notice("Ты фокусируешься на отращивании [length(limbs_to_heal) >= 2 ? "потерянных конечностей" : "потерянной конечности"]..."))
	if(do_after(H, 3 SECONDS, H))
		if(H.nutrition >= limb_regeneration_cost * length(limbs_to_heal) + NUTRITION_LEVEL_HUNGRY)
			H.regenerate_limbs(list(BODY_ZONE_CHEST, BODY_ZONE_HEAD))
			H.nutrition -= limb_regeneration_cost * length(limbs_to_heal)
			to_chat(H, span_notice("...и спустя мгновение ты вернул их!"))
			return
		else if(H.nutrition >= limb_regeneration_cost)
			while(H.nutrition >= NUTRITION_LEVEL_HUNGRY + limb_regeneration_cost)
				var/healed_limb = pick(limbs_to_heal)
				H.regenerate_limb(healed_limb)
				limbs_to_heal -= healed_limb
				H.nutrition -= limb_regeneration_cost
			to_chat(H, span_warning("...но тебе не хватает сил! Тебе нужно съесть больше, чтобы восстановиться полностью!"))
			return
		to_chat(H, span_warning("...но ты ужасно голоден! На пустой желудок не получится сделать этого!"))
	to_chat(H, span_notice("...но в последний момент... передумываешь."))

	. = ..()
	return TRUE
