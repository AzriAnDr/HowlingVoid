/datum/species/vulpkanin
	name = "Vulpkanin"
	id = SPECIES_VULP
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_MUTANT_COLORS,
		TRAIT_SENSITIVE_HEARING,
		TRAIT_NIGHT_VISION,
		TRAIT_CANINE,
		TRAIT_HARD_SOLES,
		TRAIT_SHARP_CLAWS,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	bodytemp_cold_damage_limit = 228.15   // начинают мёрзнуть при -45°C
	bodytemp_heat_damage_limit = 323.15   // перегреваются при +50°C
	//physiology.cold_mod -= 0.30         // гораздо устойчивее к холоду
	//hysiology.heat_mod += 0.30         // хуже переносят жару
	mutant_bodyparts = list()
	mutanttongue = /obj/item/organ/tongue/vulpkanin
	species_language_holder = /datum/language_holder/vulpkanin
	payday_modifier = 1.0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	examine_limb_id = SPECIES_MAMMAL
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/mutant,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/mutant,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/mutant,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/mutant,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/mutant,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/mutant,
	)

/datum/species/vulpkanin/get_default_mutant_bodyparts()
	return list(
		"tail" = list("Fox", TRUE),
		"snout" = list("Mammal, Long", TRUE),
		"ears" = list("Fox", TRUE),
		"legs" = list("Normal Legs", FALSE),
	)

/obj/item/organ/tongue/vulpkanin
	liked_foodtypes = RAW | MEAT
	disliked_foodtypes = CLOTH
	toxic_foodtypes = TOXIC


/datum/species/vulpkanin/randomize_features()
	var/list/features = ..()
	var/main_color
	var/second_color
	var/random = rand(1,5)
	//Choose from a variety of mostly brightish, animal, matching colors
	switch(random)
		if(1)
			main_color = "#FFAA00"
			second_color = "#FFDD44"
		if(2)
			main_color = "#FF8833"
			second_color = "#FFAA33"
		if(3)
			main_color = "#FFCC22"
			second_color = "#FFDD88"
		if(4)
			main_color = "#FF8800"
			second_color = "#FFFFFF"
		if(5)
			main_color = "#999999"
			second_color = "#EEEEEE"
	features["mcolor"] = main_color
	features["mcolor2"] = second_color
	features["mcolor3"] = second_color
	return features

/datum/species/vulpkanin/get_random_body_markings(list/passed_features)
	var/name = pick("Fox", "Floof", "Floofer")
	var/datum/body_marking_set/BMS = GLOB.body_marking_sets[name]
	var/list/markings = list()
	if(BMS)
		markings = assemble_body_markings_from_set(BMS, passed_features, src)
	return markings

/datum/species/vulpkanin/get_species_description()
	return placeholder_description

/datum/species/vulpkanin/get_species_lore()
	return list(placeholder_lore)

/datum/species/vulpkanin/prepare_human_for_preview(mob/living/carbon/human/vulp)
	var/main_color = "#FF8800"
	var/second_color = "#FFFFFF"

	vulp.dna.features["mcolor"] = main_color
	vulp.dna.features["mcolor2"] = second_color
	vulp.dna.features["mcolor3"] = second_color
	vulp.dna.mutant_bodyparts["snout"] = list(MUTANT_INDEX_NAME = "Mammal, Long", MUTANT_INDEX_COLOR_LIST = list(main_color, main_color, main_color))
	vulp.dna.mutant_bodyparts["tail"] = list(MUTANT_INDEX_NAME = "Husky", MUTANT_INDEX_COLOR_LIST = list(second_color, main_color, main_color))
	vulp.dna.mutant_bodyparts["ears"] = list(MUTANT_INDEX_NAME = "Wolf", MUTANT_INDEX_COLOR_LIST = list(main_color, second_color, second_color))
	regenerate_organs(vulp, src, visual_only = TRUE)
	vulp.update_body(TRUE)



/datum/species/vulpkanin/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	H.physiology.heat_mod *= 1.25
	H.physiology.cold_mod *= 0.729
	// === Квирки (ночное зрение и фотофобия) ===
	if(!H.quirks)
		H.quirks = list()

	var/found_photophobia = FALSE
	var/found_nightvision = FALSE
	for(var/datum/quirk/Q in H.quirks)
		if(istype(Q, /datum/quirk/photophobia))
			found_photophobia = TRUE
		if(istype(Q, /datum/quirk/night_vision))
			found_nightvision = TRUE

	if(!found_photophobia)
		var/datum/quirk/photophobia/P = new()
		P.quirk_holder = H
		H.quirks += P
		P.add(H.client)

	if(!found_nightvision)
		var/datum/quirk/night_vision/N = new()
		N.quirk_holder = H
		H.quirks += N
		N.add(H.client)
	// === Способность слуха ===
	var/obj/item/organ/ears/ears = H.get_organ_slot(ORGAN_SLOT_EARS)
	if(ears)
		var/datum/action/cooldown/spell/teshari_hearing/hearing_action = new
		hearing_action.Grant(H)


/datum/species/vulpkanin/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()

	if(!H)
		return

	H.physiology.heat_mod /= 1.25
	H.physiology.cold_mod /= 0.729


/datum/species/vulpkanin/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_EYE_DROPPER,
			SPECIES_PERK_NAME = "Вульпийские глаза",
			SPECIES_PERK_DESC = "Вульпы видят в темноте лучше, чем люди, но яркий свет их слепит лучше.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_HEADPHONES_SIMPLE,
			SPECIES_PERK_NAME = "Чуткий слух",
			SPECIES_PERK_DESC = "Вульпы лучше слышат. Вы можете слышать даже самые тихие звуки, но из-за этого уши стали более чувствительные!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_HEADPHONES_SIMPLE,
			SPECIES_PERK_NAME = "Чуткий нюх",
			SPECIES_PERK_DESC = "У вульп - отменный нюх. Вы можете принюхаться, чтобы найти свежие следы поблизости, отследить носителя отпечатков и даже учуять реагенты в ёмкости!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_ANGRY,
			SPECIES_PERK_NAME = "Шерсть",
			SPECIES_PERK_DESC = "Вы хорошо переносите холод, но вам тяжело в жару. Интересный факт, а вы знали что шерсть хорошо горит? :)",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_ANGRY,
			SPECIES_PERK_NAME = "Острые когти",
			SPECIES_PERK_DESC = "У вульп очень острые когти.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_ANGRY,
			SPECIES_PERK_NAME = "Шерсть",
			SPECIES_PERK_DESC = "Вы хорошо переносите холод, но вам тяжело в жару. Интересный факт, а вы знали что шерсть хорошо горит? :)",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_PERSON_RUNNING,
			SPECIES_PERK_NAME = "Подушечки на лапах",
			SPECIES_PERK_DESC = "Вы комфортно себя чувствуете без обуви.",
		),
	)


	return to_add
