/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "\improper Lizardperson"
	plural_form = "Lizardfolk"
	id = SPECIES_LIZARD
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_REPTILE
	/* NOVA EDIT REMOVAL START - Customization
	body_markings = list(
		/datum/bodypart_overlay/simple/body_marking/lizard = SPRITE_ACCESSORY_NONE,
	)
	*/ // NOVA EDIT REMOVAL END
	mutant_organs = list(
		/obj/item/organ/horns = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/frills = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/snout = "Round",
		/obj/item/organ/spines = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/tail/lizard = "Smooth",
	)
	mutanttongue = /obj/item/organ/tongue/lizard
	mutanteyes = /obj/item/organ/eyes/lizard
	mutantbrain = /obj/item/organ/brain/lizard
	coldmod = 1.5
	heatmod = 0.67
	payday_modifier = 1.0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_cookie = /obj/item/food/meat/slab
	meat = /obj/item/food/meat/slab/human/mutant/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/carbon/lizard
	exotic_bloodtype = BLOOD_TYPE_LIZARD
	inert_mutation = /datum/mutation/firebreath
	death_sound = 'sound/mobs/humanoids/lizard/deathsound.ogg'
	species_language_holder = /datum/language_holder/lizard
	digitigrade_customization = DIGITIGRADE_OPTIONAL

	// Lizards are coldblooded and can stand a greater temperature range than humans
	bodytemp_heat_damage_limit = BODYTEMP_HEAT_LAVALAND_SAFE
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 10)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/lizard,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/lizard,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/lizard,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/lizard,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/lizard,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/lizard,
	)

/// Lizards are cold blooded and do not stabilize body temperature naturally
/datum/species/lizard/body_temperature_core(mob/living/carbon/human/humi, seconds_per_tick)
	return

//NOVA EDIT REMOVAL BEGIN
/*
/datum/species/lizard/randomize_features()
	var/list/features = ..()
	features[FEATURE_LIZARD_MARKINGS] = pick(SSaccessories.feature_list[FEATURE_LIZARD_MARKINGS])
	return features
*/
//NOVA EDIT REMOVAL END

/datum/species/lizard/get_scream_sound(mob/living/carbon/human/lizard)
	return pick(
		'sound/mobs/humanoids/lizard/lizard_scream_1.ogg',
		'sound/mobs/humanoids/lizard/lizard_scream_2.ogg',
		'sound/mobs/humanoids/lizard/lizard_scream_3.ogg',
	)

/datum/species/lizard/get_cough_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cough/female_cough1.ogg',
			'sound/mobs/humanoids/human/cough/female_cough2.ogg',
			'sound/mobs/humanoids/human/cough/female_cough3.ogg',
			'sound/mobs/humanoids/human/cough/female_cough4.ogg',
			'sound/mobs/humanoids/human/cough/female_cough5.ogg',
			'sound/mobs/humanoids/human/cough/female_cough6.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cough/male_cough1.ogg',
		'sound/mobs/humanoids/human/cough/male_cough2.ogg',
		'sound/mobs/humanoids/human/cough/male_cough3.ogg',
		'sound/mobs/humanoids/human/cough/male_cough4.ogg',
		'sound/mobs/humanoids/human/cough/male_cough5.ogg',
		'sound/mobs/humanoids/human/cough/male_cough6.ogg',
	)


/datum/species/lizard/get_cry_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cry/female_cry1.ogg',
			'sound/mobs/humanoids/human/cry/female_cry2.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cry/male_cry1.ogg',
		'sound/mobs/humanoids/human/cry/male_cry2.ogg',
		'sound/mobs/humanoids/human/cry/male_cry3.ogg',
	)


/datum/species/lizard/get_sneeze_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg'
	return 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg'

/datum/species/lizard/get_laugh_sound(mob/living/carbon/human/lizard)
	return 'sound/mobs/humanoids/lizard/lizard_laugh1.ogg'

/datum/species/lizard/get_sigh_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return SFX_FEMALE_SIGH
	return SFX_MALE_SIGH

/datum/species/lizard/get_sniff_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sniff/female_sniff.ogg'
	return 'sound/mobs/humanoids/human/sniff/male_sniff.ogg'

/datum/species/lizard/get_snore_sound(mob/living/carbon/human/lizard)
	if(lizard.physique == FEMALE)
		return SFX_SNORE_FEMALE
	return SFX_SNORE_MALE

/datum/species/lizard/get_hiss_sound(mob/living/carbon/human/lizard)
	return 'sound/mobs/humanoids/lizard/lizard_hiss.ogg'

/datum/species/lizard/get_physical_attributes()
	return "Lizardpeople can withstand slightly higher temperatures than most species, but they are very vulnerable to the cold \
		and can't regulate their body-temperature internally, making the vacuum of space extremely deadly to them."

/datum/species/lizard/get_species_description()
	return "The militaristic Lizardpeople hail originally from Tizira, but have grown \
		throughout their centuries in the stars to possess a large spacefaring \
		empire: though now they must contend with their younger, more \
		technologically advanced Human neighbours."

/datum/species/lizard/get_species_lore()
	return list(
		"The face of conspiracy theory was changed forever the day mankind met the lizards.",

		"Hailing from the arid world of Tizira, lizards were travelling the stars back when mankind was first discovering how neat trains could be. \
		However, much like the space-fable of the space-tortoise and space-hare, lizards have rejected their kin's motto of \"slow and steady\" \
		in favor of resting on their laurels and getting completely surpassed by 'bald apes', due in no small part to their lack of access to plasma.",

		"The history between lizards and humans has resulted in many conflicts that lizards ended on the losing side of, \
		with the finale being an explosive remodeling of their moon. Today's lizard-human relations are seeing the continuance of a record period of peace.",

		"Lizard culture is inherently militaristic, though the influence the military has on lizard culture \
		begins to lessen the further colonies lie from their homeworld - \
		with some distanced colonies finding themselves subsumed by the cultural practices of other species nearby.",

		"On their homeworld, lizards celebrate their 16th birthday by enrolling in a mandatory 5 year military tour of duty. \
		Roles range from combat to civil service and everything in between. As the old slogan goes: \"Your place will be found!\"",
	)

// Override for the default temperature perks, so we can give our specific "cold blooded" perk.
/datum/species/lizard/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "thermometer-empty",
		SPECIES_PERK_NAME = "Cold-blooded",
		SPECIES_PERK_DESC = "Lizardpeople have higher tolerance for hot temperatures, but lower \
			tolerance for cold temperatures. Additionally, they cannot self-regulate their body temperature - \
			they are as cold or as warm as the environment around them is. Stay warm!",
	))

	return to_add

/*
Lizard subspecies: ASHWALKERS
*/
/datum/species/lizard/ashwalker
	name = "Ash Walker"
	id = SPECIES_LIZARD_ASH
	examine_limb_id = SPECIES_LIZARD
	mutantlungs = /obj/item/organ/lungs/lavaland
	mutantbrain = /obj/item/organ/brain/primitive
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_VIRUSIMMUNE,
	)
	// inherent_factions = list(FACTION_ASHWALKER) // NOVA EDIT REMOVAL: Moving to Ritual
	species_language_holder = /datum/language_holder/lizard/ash
	digitigrade_customization = DIGITIGRADE_FORCED
	examine_limb_id = SPECIES_LIZARD
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/lizard,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/lizard,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/lizard/ashwalker,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/lizard/ashwalker,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/lizard,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/lizard,
	)

/datum/species/lizard/ashwalker/get_physical_attributes()
	return "Ash Walkers are identical to lizardpeople in almost all aspects. \
		Unlike them, they're always digitigrade, they can breathe Lavaland's often noxious atmosphere and resist viruses. They are usually illiterate."

/*
Lizard subspecies: SILVER SCALED
*/
/datum/species/lizard/silverscale
	name = "Silver Scale"
	id = SPECIES_LIZARD_SILVER
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_REPTILE
	inherent_traits = list(
		TRAIT_HOLY,
		TRAIT_NOBREATH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_WINE_TASTER,
	)
	mutantlungs = null
	damage_modifier = 10 //very light silvery scales soften blows
	species_language_holder = /datum/language_holder/lizard/silver
	mutanttongue = /obj/item/organ/tongue/lizard/silver
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	examine_limb_id = SPECIES_LIZARD
	///stored mutcolor for when we turn back off of a silverscale.
	var/old_mutcolor

/datum/species/lizard/silverscale/get_physical_attributes()
	return "Silver Scales are to lizardpeople what angels are to humans. \
		Mostly identical, they are holy, don't breathe, don't get viruses, their hide cannot be pierced, love the taste of wine, \
		and their tongue allows them to turn into a statue, for some reason."

/datum/species/lizard/silverscale/on_species_gain(mob/living/carbon/human/new_silverscale, datum/species/old_species, pref_load, regenerate_icons)
	old_mutcolor = new_silverscale.dna.features[FEATURE_MUTANT_COLOR]
	new_silverscale.dna.features[FEATURE_MUTANT_COLOR] = "#eeeeee"
	new_silverscale.add_eye_color("#0000a0", EYE_COLOR_SPECIES_PRIORITY)
	. = ..()
	new_silverscale.add_filter("silver_glint", 2, list("type" = "outline", "color" = "#ffffff63", "size" = 2))

/datum/species/lizard/silverscale/on_species_loss(mob/living/carbon/human/was_silverscale, datum/species/new_species, pref_load)
	was_silverscale.dna.features[FEATURE_MUTANT_COLOR] = old_mutcolor
	was_silverscale.remove_eye_color(EYE_COLOR_SPECIES_PRIORITY)
	was_silverscale.remove_filter("silver_glint")
	return ..()

// HowlingVoid lizard mechanics integration.
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

/proc/hv_can_species_autotomy_tail(mob/living/carbon/human/human)
	return istype(human?.dna?.species, /datum/species/lizard) || istype(human?.dna?.species, /datum/species/unathi)

/proc/hv_get_species_tail_regen_type(mob/living/carbon/human/human)
	var/default_tail_type = /obj/item/organ/tail/lizard
	var/datum/mutant_bodypart/tail_part = human?.dna?.mutant_bodyparts[FEATURE_TAIL]
	if(!tail_part || tail_part.name == SPRITE_ACCESSORY_NONE)
		return default_tail_type

	var/list/tail_accessories = SSaccessories.sprite_accessories[FEATURE_TAIL]
	var/datum/sprite_accessory/tails/tail_sprite = tail_accessories?[tail_part.name]
	return tail_sprite?.organ_type || default_tail_type

/proc/hv_regenerate_species_limb(mob/living/carbon/human/human, limb_zone)
	if(!human.regenerate_limb(limb_zone))
		return FALSE

	var/obj/item/bodypart/new_limb = human.get_bodypart(limb_zone)
	new_limb?.update_limb(is_creating = TRUE)
	return TRUE

/proc/hv_apply_species_tail_appearance(mob/living/carbon/human/human, obj/item/organ/tail/tail)
	if(!human?.dna || !tail?.bodypart_overlay)
		return

	tail.bodypart_overlay.set_appearance_from_dna(human.dna)
	tail.bodypart_owner?.update_limb(is_creating = TRUE)


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
				hv_regenerate_species_limb(H, limb_zone)
			H.nutrition -= limb_regeneration_cost * length(limbs_to_heal)
			to_chat(H, span_notice("...and moments later, you have them back!"))
			return
		else if(H.nutrition >= limb_regeneration_cost)
			while(H.nutrition >= NUTRITION_LEVEL_HUNGRY + limb_regeneration_cost)
				var/healed_limb = pick(limbs_to_heal)
				hv_regenerate_species_limb(H, healed_limb)
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

	var/tail_type = hv_get_species_tail_regen_type(H)
	var/obj/item/organ/tail/new_tail = new tail_type()
	if(!new_tail.Insert(H))
		qdel(new_tail)
		to_chat(H, span_warning("Your tail fails to regrow."))
		return FALSE

	hv_apply_species_tail_appearance(H, new_tail)
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
			SPECIES_PERK_ICON = FA_ICON_RECYCLE,
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

