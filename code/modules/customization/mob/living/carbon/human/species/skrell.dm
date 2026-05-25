/datum/species/skrell
	name = "Skrell"
	id = SPECIES_SKRELL
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_MUTANT_COLORS,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	bodytemp_normal = (BODYTEMP_NORMAL + 70)
	bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_SPREAD
	bodytemp_cold_damage_limit = (T20C - 10)
	species_language_holder = /datum/language_holder/skrell
	mutanttongue = /obj/item/organ/tongue/skrell
	payday_modifier = 1.0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	mutantbrain = /obj/item/organ/brain/skrell
	mutanteyes = /obj/item/organ/eyes/skrell
	mutantlungs = /obj/item/organ/lungs/skrell
	mutantheart = /obj/item/organ/heart/skrell
	mutantliver = /obj/item/organ/liver/skrell
	mutanttongue = /obj/item/organ/tongue/skrell
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/mutant/skrell,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/mutant/skrell,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/mutant/skrell,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/mutant/skrell,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/mutant/skrell,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/mutant/skrell,
	)

/datum/species/skrell/get_default_mutant_bodyparts()
	return list(
		FEATURE_EARS = MUTPART_BLUEPRINT(SPRITE_ACCESSORY_NONE, is_randomizable = FALSE),
		FEATURE_SKRELL_HAIR = MUTPART_BLUEPRINT("Short", is_randomizable = TRUE),
	)

/datum/species/skrell/get_species_description()
	return placeholder_description

/datum/species/skrell/get_species_lore()
	return list(placeholder_lore)

/datum/species/skrell/randomize_features()
	var/list/features = ..()
	var/main_color
	var/random = rand(1,6)
	//Choose from a range of green-blue colors
	switch(random)
		if(1)
			main_color = "#44FF77"
		if(2)
			main_color = "#22FF88"
		if(3)
			main_color = "#22FFBB"
		if(4)
			main_color = "#22FFFF"
		if(5)
			main_color = "#22BBFF"
		if(6)
			main_color = "#2266FF"
	features[FEATURE_MUTANT_COLOR] = main_color
	features[FEATURE_MUTANT_COLOR_TWO] = main_color
	features[FEATURE_MUTANT_COLOR_THREE] = main_color
	return features

/datum/species/skrell/prepare_human_for_preview(mob/living/carbon/human/skrell)
	var/skrell_color = "#22BBFF"
	skrell.dna.features[FEATURE_MUTANT_COLOR] = skrell_color
	skrell.dna.features[FEATURE_MUTANT_COLOR_TWO] = skrell_color
	skrell.dna.features[FEATURE_MUTANT_COLOR_THREE] = skrell_color
	skrell.dna.mutant_bodyparts[FEATURE_SKRELL_HAIR] = build_mutant_part("Long", list(skrell_color, skrell_color, skrell_color))
	regenerate_organs(skrell, src, visual_only = TRUE)
	skrell.update_body(TRUE)

/obj/item/organ/tongue/skrell
	name = "internal vocal sacs"
	desc = "An Strange looking sac."
	icon = 'icons/organs/skrell_organ.dmi'
	icon_state = "tongue"
	taste_sensitivity = 5
	var/static/list/languages_possible_skrell = typecacheof(list(
		/datum/language/common,
		/datum/language/uncommon,
		/datum/language/draconic,
		/datum/language/codespeak,
		/datum/language/monkey,
		/datum/language/narsie,
		/datum/language/machine,
		/datum/language/slime,
		/datum/language/beachbum,
		/datum/language/aphasia,
		/datum/language/piratespeak,
		/datum/language/moffic,
		/datum/language/sylvan,
		/datum/language/shadowtongue,
		/datum/language/terrum,
		/datum/language/vox,
		/datum/language/nekomimetic,
		/datum/language/skrell,
	))
	liked_foodtypes = TOXIC | FRUIT | VEGETABLES
	disliked_foodtypes = RAW | CLOTH
	toxic_foodtypes = DAIRY | MEAT

/obj/item/organ/tongue/skrell/get_possible_languages()
	return languages_possible_skrell

/obj/item/organ/heart/skrell
	name = "skrellian heart"
	icon = 'icons/organs/skrell_organ.dmi'
	icon_state = "heart"

/obj/item/organ/brain/skrell
	name = "spongy brain"
	icon = 'icons/organs/skrell_organ.dmi'
	icon_state = "brain2"

/obj/item/organ/brain/skrell/on_mob_insert(mob/living/carbon/brain_owner, special, movement_flags)
	. = ..()
	brain_owner.add_psionic(/datum/psionic/sensitive)

/obj/item/organ/eyes/skrell
	name = "amphibian eyes"
	desc = "Large black orbs."
	icon = 'icons/organs/skrell_organ.dmi'
	icon_state = "eyes"
	flash_protect = FLASH_PROTECTION_SENSITIVE

/obj/item/organ/lungs/skrell
	name = "skrell lungs"
	icon = 'icons/organs/skrell_organ.dmi'
	icon_state = "lungs"
	safe_plasma_max = 40
	safe_co2_max = 40

	cold_message = "You can't stand the freezing cold with every breath you take!"
	cold_level_1_threshold = 248
	cold_level_2_threshold = 220
	cold_level_3_threshold = 170
	cold_level_1_damage = COLD_GAS_DAMAGE_LEVEL_2 //Keep in mind with gas damage levels, you can set these to be negative, if you want someone to heal, instead.
	cold_level_2_damage = COLD_GAS_DAMAGE_LEVEL_2
	cold_level_3_damage = COLD_GAS_DAMAGE_LEVEL_3
	cold_damage_type = BRUTE

	hot_message = "You can't stand the searing heat with every breath you take!"
	heat_level_1_threshold = 318
	heat_level_2_threshold = 348
	heat_level_3_threshold = 1000
	heat_level_1_damage = HEAT_GAS_DAMAGE_LEVEL_2
	heat_level_2_damage = HEAT_GAS_DAMAGE_LEVEL_2
	heat_level_3_damage = HEAT_GAS_DAMAGE_LEVEL_3
	heat_damage_type = BURN

/obj/item/organ/liver/skrell
	name = "skrell liver"
	icon_state = "liver"
	icon = 'icons/organs/skrell_organ.dmi'
	alcohol_tolerance = 5
	toxTolerance = 10 //can shrug off up to 10u of toxins.
	liver_resistance = 1.2 * LIVER_DEFAULT_TOX_RESISTANCE // +20%

// HowlingVoid skrell mechanics integration.
/datum/species/skrell/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	if(!istype(H))
		return

	RegisterSignal(H, COMSIG_MOVABLE_MOVED, PROC_REF(update_skrell_hydration))
	RegisterSignal(H, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(on_skrell_damage_modifiers))
	update_skrell_hydration(H, null)

/datum/species/skrell/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	if(!istype(H))
		return

	UnregisterSignal(H, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(H, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)
	H.remove_movespeed_modifier(/datum/movespeed_modifier/skrell_hydrated_stride)

/datum/species/skrell/proc/is_skrell_hydrated_tile(atom/location)
	if(!isturf(location))
		return FALSE

	var/turf/check_turf = location
	if(istype(check_turf, /turf/open/water))
		return TRUE
	if(check_turf.liquids && check_turf.liquids.liquid_state >= LIQUID_STATE_WAIST)
		return TRUE

	return FALSE

/datum/species/skrell/proc/update_skrell_hydration(mob/living/carbon/human/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(!istype(source))
		return

	if(is_skrell_hydrated_tile(source.loc))
		source.add_movespeed_modifier(/datum/movespeed_modifier/skrell_hydrated_stride)
	else
		source.remove_movespeed_modifier(/datum/movespeed_modifier/skrell_hydrated_stride)

/datum/species/skrell/proc/on_skrell_damage_modifiers(mob/living/carbon/human/source, list/damage_mods, damage, damagetype, def_zone, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER

	if(!istype(source))
		return
	if(damagetype != BURN)
		return
	if(!is_skrell_hydrated_tile(source.loc))
		return

	// Moist skin handles heating and charring better while hydrated.
	damage_mods += 0.85

/datum/movespeed_modifier/skrell_hydrated_stride
	multiplicative_slowdown = -0.15

/datum/species/skrell/get_species_description()
	return "Skrell are amphibious humanoids with heat-tolerant biology and delicate sensory systems. They perform best when hydrated and struggle in the cold."

/datum/species/skrell/get_species_lore()
	return list(
		"Skrell physiology developed around warm, wet environments, leading to exceptional heat tolerance and specialized internal organs.",
		"Their skin and breathing systems handle humidity and moisture well, letting them keep control and tempo on wet terrain.",
		"Bright flashes and severe cold remain major stress factors for skrell bodies despite their adaptability in many other areas.",
	)

/datum/species/skrell/create_pref_unique_perks()
	var/list/perks = list()
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_DROPLET,
		SPECIES_PERK_NAME = "Hydrated Stride",
		SPECIES_PERK_DESC = "Skrell move faster while standing in sufficiently deep water or liquids.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_FIRE_FLAME_CURVED,
		SPECIES_PERK_NAME = "Moist Barrier",
		SPECIES_PERK_DESC = "While hydrated, skrell take reduced burn damage.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_FLASK,
		SPECIES_PERK_NAME = "Exotic Biochemistry",
		SPECIES_PERK_DESC = "Skrell organs handle toxins and unusual gases differently from baseline humans.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_SNOWFLAKE,
		SPECIES_PERK_NAME = "Cold-Blooded",
		SPECIES_PERK_DESC = "Skrell are notably vulnerable to cold environments and cold gases.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_EYE,
		SPECIES_PERK_NAME = "Light Sensitive",
		SPECIES_PERK_DESC = "Skrell eyes are more sensitive to intense flashes.",
	))
	return perks

