/datum/species/vulpkanin
	name = "Vulpkanin"
	id = SPECIES_VULP
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_MUTANT_COLORS,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID

	mutanttongue = /obj/item/organ/tongue/dog
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
		FEATURE_TAIL = MUTPART_BLUEPRINT("Fox", is_randomizable = TRUE),
		FEATURE_SNOUT = MUTPART_BLUEPRINT("Mammal, Long", is_randomizable = TRUE),
		FEATURE_EARS = MUTPART_BLUEPRINT("Fox", is_randomizable = TRUE),
		FEATURE_LEGS = MUTPART_BLUEPRINT(NORMAL_LEGS, is_randomizable = FALSE, is_feature = TRUE),
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
	features[FEATURE_MUTANT_COLOR] = main_color
	features[FEATURE_MUTANT_COLOR_TWO] = second_color
	features[FEATURE_MUTANT_COLOR_THREE] = second_color
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

	vulp.dna.features[FEATURE_MUTANT_COLOR] = main_color
	vulp.dna.features[FEATURE_MUTANT_COLOR_TWO] = second_color
	vulp.dna.features[FEATURE_MUTANT_COLOR_THREE] = second_color
	vulp.dna.mutant_bodyparts[FEATURE_SNOUT] = build_mutant_part("Mammal, Long", list(main_color, main_color, main_color))
	vulp.dna.mutant_bodyparts[FEATURE_TAIL] = build_mutant_part("Husky", list(second_color, main_color, main_color))
	vulp.dna.mutant_bodyparts[FEATURE_EARS] = build_mutant_part("Wolf", list(main_color, second_color, second_color))
	regenerate_organs(vulp, src, visual_only = TRUE)
	vulp.update_body(TRUE)

// HowlingVoid vulpkanin mechanics integration.
/datum/species/vulpkanin
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_MUTANT_COLORS,
		TRAIT_SENSITIVE_HEARING,
		TRAIT_NIGHT_VISION,
		TRAIT_CANINE,
		TRAIT_FREERUNNING,
		TRAIT_HARD_SOLES,
		TRAIT_SHARP_CLAWS,
		TRAIT_WATER_HATER,
	)
	bodytemp_cold_damage_limit = 228.15
	bodytemp_heat_damage_limit = 323.15
	/// Quirks injected by this species per mob (key = mob, value = list of quirk typepaths).
	var/tmp/list/species_added_quirks = list()
	/// Species-granted actions, tracked for safe cleanup on species loss.
	var/tmp/list/species_hearing_action = list()
	var/tmp/list/species_scent_scan_action = list()
	var/tmp/list/species_scent_track_action = list()
/datum/movespeed_modifier/vulpkanin_speedboost
	multiplicative_slowdown = -0.08

/datum/species/vulpkanin/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	if(!istype(H))
		return

	. = ..()
	H.physiology.heat_mod *= 1.3
	H.physiology.cold_mod *= 0.7
	H.add_movespeed_modifier(/datum/movespeed_modifier/vulpkanin_speedboost)

	var/list/added_quirks = list()
	species_added_quirks[H] = added_quirks

	if(!H.has_quirk(/datum/quirk/photophobia))
		if(H.add_quirk(/datum/quirk/photophobia, override_client = H.client, announce = FALSE))
			added_quirks += /datum/quirk/photophobia

	if(!H.has_quirk(/datum/quirk/night_vision))
		if(H.add_quirk(/datum/quirk/night_vision, override_client = H.client, announce = FALSE))
			added_quirks += /datum/quirk/night_vision

	var/datum/action/cooldown/spell/teshari_hearing/old_hearing_action = species_hearing_action[H]
	if(old_hearing_action)
		old_hearing_action.Remove(H)
		qdel(old_hearing_action)
	species_hearing_action[H] = null

	var/datum/action/cooldown/scent_scan/vulp/old_scent = species_scent_scan_action[H]
	if(old_scent)
		old_scent.Remove(H)
		qdel(old_scent)
	species_scent_scan_action[H] = null

	var/datum/action/cooldown/scent_tracking/old_track = species_scent_track_action[H]
	if(old_track)
		old_track.Remove(H)
		qdel(old_track)
	species_scent_track_action[H] = null

	var/obj/item/organ/ears/ears = H.get_organ_slot(ORGAN_SLOT_EARS)
	if(ears)
		var/datum/action/cooldown/spell/teshari_hearing/hearing_action = new
		hearing_action.Grant(H)
		species_hearing_action[H] = hearing_action

	var/datum/action/cooldown/scent_scan/vulp/scent = new()
	scent.Grant(H)
	species_scent_scan_action[H] = scent
	var/datum/action/cooldown/scent_tracking/track = new()
	track.Grant(H)
	species_scent_track_action[H] = track

/datum/species/vulpkanin/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()

	if(!H)
		return

	H.physiology.heat_mod /= 1.3
	H.physiology.cold_mod /= 0.7
	H.remove_movespeed_modifier(/datum/movespeed_modifier/vulpkanin_speedboost)

	var/list/added_quirks = species_added_quirks[H]
	if(length(added_quirks))
		for(var/quirk_type as anything in added_quirks)
			if(H.has_quirk(quirk_type))
				H.remove_quirk(quirk_type)
	species_added_quirks[H] = null

	var/datum/action/cooldown/spell/teshari_hearing/hearing_action = species_hearing_action[H]
	if(hearing_action)
		hearing_action.Remove(H)
		qdel(hearing_action)
	species_hearing_action[H] = null

	var/datum/action/cooldown/scent_scan/vulp/scent = species_scent_scan_action[H]
	if(scent)
		scent.Remove(H)
		qdel(scent)
	species_scent_scan_action[H] = null

	var/datum/action/cooldown/scent_tracking/track = species_scent_track_action[H]
	if(track)
		track.Remove(H)
		qdel(track)
	species_scent_track_action[H] = null

/datum/species/vulpkanin/create_pref_unique_perks()
	var/list/to_add = list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_MOON,
			SPECIES_PERK_NAME = "Night Vision",
			SPECIES_PERK_DESC = "Vulps can see better in the dark than humans, but bright light dazzles them more.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_HEADPHONES_SIMPLE,
			SPECIES_PERK_NAME = "Keen Hearing",
			SPECIES_PERK_DESC = "Vulps hear better. You can pick up even the quietest sounds, but your ears are also more sensitive.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_PERSON_RUNNING,
			SPECIES_PERK_NAME = "Predator Mobility",
			SPECIES_PERK_DESC = "Vulps move through obstacles and uneven terrain more comfortably than humans.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_WIND,
			SPECIES_PERK_NAME = "Keen Smell",
			SPECIES_PERK_DESC = "Vulps have an excellent sense of smell. You can sniff for fresh nearby trails, track who left prints, and even detect reagents in containers.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_DOG,
			SPECIES_PERK_NAME = "Fur",
			SPECIES_PERK_DESC = "You handle cold well, but heat is harder for you. Also, fur burns very well.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shower",
			SPECIES_PERK_NAME = "Hydrophobia",
			SPECIES_PERK_DESC = "Vulps dislike being soaked and feel worse in wet conditions.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_LINES_LEANING,
			SPECIES_PERK_NAME = "Sharp Claws",
			SPECIES_PERK_DESC = "Vulps have very sharp claws.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_PERSON_RUNNING,
			SPECIES_PERK_NAME = "Soft Paw Pads",
			SPECIES_PERK_DESC = "You feel comfortable without shoes.",
		),
	)

	return to_add
