/datum/species/shadekin
	name = "Shadekin"
	id = SPECIES_SHADEKIN
	mutanttongue = /obj/item/organ/tongue/shadekin
	mutantbrain = /obj/item/organ/brain/shadekin
	mutanteyes = /obj/item/organ/eyes/shadekin

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	digitigrade_customization = DIGITIGRADE_OPTIONAL
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/shadekin,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/shadekin,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/shadekin,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/shadekin,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/shadekin,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/shadekin,
	)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_WATER_BREATHING,
		TRAIT_SLICK_SKIN,
		TRAIT_MUTANT_COLORS,
		TRAIT_NIGHT_VISION,
		TRAIT_NOBREATH,
	)
	species_language_holder = /datum/language_holder/shadekin


/datum/species/shadekin/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "lightbulb",
		SPECIES_PERK_NAME = "Dark Regeneration",
		SPECIES_PERK_DESC = "Shadekins regenerate their physical wounds while in the darkness."
	),
	list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "moon",
			SPECIES_PERK_NAME = "Darkness Assist",
			SPECIES_PERK_DESC = "Thanks to their kinship with darkness, Shadekins gain additional  \
								speed of movement and actions when in the dark.",
		)
	)

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "crutch",
		SPECIES_PERK_NAME = "Light Averse",
		SPECIES_PERK_DESC = "Shadekins move slightly slower while in the light."
	))

	return to_add

/datum/species/shadekin/get_default_mutant_bodyparts()
	return list(
		FEATURE_TAIL = MUTPART_BLUEPRINT("Shade", is_randomizable = FALSE),
		FEATURE_SNOUT = MUTPART_BLUEPRINT(SPRITE_ACCESSORY_NONE, is_randomizable = FALSE),
		FEATURE_EARS = MUTPART_BLUEPRINT(SPRITE_ACCESSORY_NONE, is_randomizable = FALSE),
		FEATURE_LEGS = MUTPART_BLUEPRINT(NORMAL_LEGS, is_randomizable = FALSE, is_feature = TRUE),
	)

/datum/species/shadekin/proc/sync_ear_feature(mob/living/carbon/human/target)
	var/datum/mutant_bodypart/ears = target.dna.mutant_bodyparts[FEATURE_EARS]
	if(isnull(ears))
		target.dna.mutant_bodyparts[FEATURE_EARS] = build_mutant_part(SPRITE_ACCESSORY_NONE)
		target.dna.features[FEATURE_EARS] = SPRITE_ACCESSORY_NONE
		return

	target.dna.features[FEATURE_EARS] = ears.name || SPRITE_ACCESSORY_NONE

/datum/species/shadekin/apply_supplementary_body_changes(mob/living/carbon/human/target, datum/preferences/preferences, visuals_only = FALSE)
	. = ..()
	sync_ear_feature(target)
	var/datum/mutant_bodypart/ears = target.dna.mutant_bodyparts[FEATURE_EARS]
	if(!ears || ears.name == SPRITE_ACCESSORY_NONE)
		return
	if(!findtext(ears.name, "Shade"))
		return
	ears.set_colors(list(
		target.dna.features[FEATURE_MUTANT_COLOR],
		target.dna.features[FEATURE_MUTANT_COLOR_TWO],
		target.dna.features[FEATURE_MUTANT_COLOR_THREE],
	))

/datum/species/shadekin/randomize_features()
	var/list/features = ..()
	features[FEATURE_MUTANT_COLOR] = "#222222"
	features[FEATURE_MUTANT_COLOR_TWO] = "#505050"
	features[FEATURE_MUTANT_COLOR_THREE] = "#3f3f3f"
	features[FEATURE_EARS] = SPRITE_ACCESSORY_NONE
	features[FEATURE_TAIL] = "Shade"
	features[FEATURE_SNOUT] = SPRITE_ACCESSORY_NONE
	features[FEATURE_LEGS] = NORMAL_LEGS
	return features

/datum/species/shadekin/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons = TRUE, replace_missing = TRUE)
	sync_ear_feature(human_who_gained_species)
	. = ..()
	sync_ear_feature(human_who_gained_species)

/datum/species/shadekin/prepare_human_for_preview(mob/living/carbon/human/shadekin)
	var/main_color = "#222222"
	var/secondary_color = "#383838"
	var/tertiary_color = "#383838"
	shadekin.dna.features[FEATURE_MUTANT_COLOR] = main_color
	shadekin.dna.features[FEATURE_MUTANT_COLOR_TWO] = secondary_color
	shadekin.dna.features[FEATURE_MUTANT_COLOR_THREE] = tertiary_color

	shadekin.dna.mutant_bodyparts[FEATURE_EARS] = build_mutant_part("Shade Ears", list(main_color, secondary_color, tertiary_color))
	shadekin.dna.mutant_bodyparts[FEATURE_SNOUT] = build_mutant_part(SPRITE_ACCESSORY_NONE, list(main_color, secondary_color, tertiary_color))
	shadekin.dna.mutant_bodyparts[FEATURE_TAIL] = build_mutant_part("Shade", list(main_color, secondary_color, tertiary_color))
	shadekin.set_eye_color("#5ec7e4")
	regenerate_organs(shadekin, src, visual_only = TRUE)
	for(var/obj/item/bodypart/bodypart as anything in shadekin.bodyparts)
		bodypart.skin_tone = ""
		bodypart.species_color = main_color
		bodypart.update_draw_color()
	apply_supplementary_body_changes(shadekin, null, TRUE)
	shadekin.update_body(TRUE)

/datum/species/shadekin/get_species_description()
    return list(
        "Shadekins appeared somewhere in distant space."
    )

/datum/species/shadekin/get_species_lore()
    return list(
        "It is unclear when exactly Shadekin first spawned, though it is assumedly a relatively recent development."
    )
