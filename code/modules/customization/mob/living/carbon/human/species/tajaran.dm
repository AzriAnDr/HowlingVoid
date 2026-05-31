/datum/species/tajaran
	name = "Tajaran"
	id = SPECIES_TAJARAN
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_HATED_BY_DOGS,
		TRAIT_MUTANT_COLORS,
		TRAIT_CATLIKE_GRACE,
		TRAIT_WATER_HATER,
	)
	mutanttongue = /obj/item/organ/tongue/cat/tajaran
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID

	payday_modifier = 1.0
	species_language_holder = /datum/language_holder/tajaran
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

/datum/species/tajaran/get_default_mutant_bodyparts()
	return list(
		FEATURE_TAIL = MUTPART_BLUEPRINT("Cat (Big)", is_randomizable = TRUE),
		FEATURE_SNOUT = MUTPART_BLUEPRINT("Mammal, Short", is_randomizable = TRUE),
		FEATURE_EARS = MUTPART_BLUEPRINT("Cat, Alert", is_randomizable = TRUE),
		FEATURE_LEGS = MUTPART_BLUEPRINT(NORMAL_LEGS, is_randomizable = FALSE, is_feature = TRUE),
	)

/obj/item/organ/tongue/cat/tajaran
	liked_foodtypes = GRAIN | MEAT
	disliked_foodtypes = CLOTH


/datum/species/tajaran/randomize_features()
	var/list/features = ..()
	var/main_color
	var/second_color
	var/random = rand(1,5)
	//Choose from a variety of mostly coldish, animal, matching colors
	switch(random)
		if(1)
			main_color = "#BBAA88"
			second_color = "#AAAA99"
		if(2)
			main_color = "#777766"
			second_color = "#888877"
		if(3)
			main_color = "#AA9988"
			second_color = "#AAAA99"
		if(4)
			main_color = "#EEEEDD"
			second_color = "#FFEEEE"
		if(5)
			main_color = "#DDCC99"
			second_color = "#DDCCAA"
	features[FEATURE_MUTANT_COLOR] = main_color
	features[FEATURE_MUTANT_COLOR_TWO] = second_color
	features[FEATURE_MUTANT_COLOR_THREE] = second_color
	return features

/datum/species/tajaran/get_random_body_markings(list/passed_features)
	var/name = pick("Tajaran", "Floof", "Floofer")
	var/datum/body_marking_set/BMS = GLOB.body_marking_sets[name]
	var/list/markings = list()
	if(BMS)
		markings = assemble_body_markings_from_set(BMS, passed_features, src)
	return markings

/datum/species/tajaran/get_species_description()
	return placeholder_description

/datum/species/tajaran/get_species_lore()
	return list(placeholder_lore)

/datum/species/tajaran/prepare_human_for_preview(mob/living/carbon/human/cat)
	var/main_color = "#AA9988"
	var/second_color = "#AAAA99"

	cat.dna.features[FEATURE_MUTANT_COLOR] = main_color
	cat.dna.features[FEATURE_MUTANT_COLOR_TWO] = second_color
	cat.dna.features[FEATURE_MUTANT_COLOR_THREE] = second_color
	cat.dna.mutant_bodyparts[FEATURE_SNOUT] = build_mutant_part("Mammal, Short", list(main_color, main_color, main_color))
	cat.dna.mutant_bodyparts[FEATURE_TAIL] = build_mutant_part("Cat", list(second_color, main_color, main_color))
	cat.dna.mutant_bodyparts[FEATURE_EARS] = build_mutant_part("Cat, Alert", list(main_color, second_color, second_color))
	regenerate_organs(cat, src, visual_only = TRUE)
	cat.update_body(TRUE)
/* HOWLING VOID EDIT
/datum/species/tajaran/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_PERSON_FALLING,
		SPECIES_PERK_NAME = "Soft Landing",
		SPECIES_PERK_DESC = "Tajarans are unhurt by high falls, and land on their feet.",
	))
	return to_add
HOWLING VOID EDIT ENDS*/

// HowlingVoid tajaran mechanics integration.
/datum/species/tajaran
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_HATED_BY_DOGS,
		TRAIT_MUTANT_COLORS,
		TRAIT_CATLIKE_GRACE,
		TRAIT_WATER_HATER,
		TRAIT_FELINE,
		TRAIT_SENSITIVE_HEARING,
		TRAIT_NIGHT_VISION,
		TRAIT_FREERUNNING,
		TRAIT_HARD_SOLES,
		TRAIT_SHARP_CLAWS,
	)
	bodytemp_normal = 308
	bodytemp_cold_damage_limit = 238.15
	bodytemp_heat_damage_limit = 325.15
	/// Trait source key used for DNR that comes specifically from Tajaran Nine Lives.
	var/static/nine_lives_trait_source = "tajaran_nine_lives"
	/// How many deaths a Tajaran can have before permanent death is enforced.
	var/nine_lives_max_deaths = 9

/mob/living/carbon/human
	/// Personal death counter for Tajaran Nine Lives.
	var/tajaran_nine_lives_death_count = 0

/datum/species/tajaran/proc/on_tajaran_projectile_hit(mob/living/carbon/human/tajaran, obj/projectile/hit_projectile)
	SIGNAL_HANDLER

	if(prob(25) && tajaran.stat == CONSCIOUS)
		tajaran.visible_message(span_danger("[tajaran.get_visible_name()] dodges [hit_projectile]!"))
		play_tajaran_dodge_fx(tajaran)
		playsound(tajaran.loc, "sound/items/weapons/effects/ric[rand(1, 5)]", 25, TRUE, -1)
		return COMPONENT_BULLET_PIERCED

/datum/species/tajaran/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	if(!H)
		return

	if(H.tajaran_nine_lives_death_count < nine_lives_max_deaths)
		REMOVE_TRAIT(H, TRAIT_DNR, nine_lives_trait_source)

	H.physiology.heat_mod *= 1.25
	H.physiology.cold_mod *= 0.81

	RegisterSignal(H, COMSIG_LIVING_DEATH, PROC_REF(on_tajaran_death))
	RegisterSignal(H, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(on_tajaran_projectile_hit))
	RegisterSignal(H, COMSIG_LIVING_DODGE_MELEE, PROC_REF(tajaran_dodge_melee))

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

	var/obj/item/organ/ears/ears = H.get_organ_slot(ORGAN_SLOT_EARS)
	if(ears)
		var/datum/action/cooldown/spell/teshari_hearing/hearing_action = new
		hearing_action.Grant(H)

	var/datum/action/cooldown/tajaran_grooming/G = new()
	G.Grant(H)

	var/datum/action/cooldown/scent_scan/tajaran/scent = new()
	scent.Grant(H)
	var/datum/action/cooldown/scent_tracking/track = new()
	track.Grant(H)

/datum/species/tajaran/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	if(!H)
		return

	REMOVE_TRAIT(H, TRAIT_DNR, nine_lives_trait_source)

	H.physiology.cold_mod /= 0.81
	H.physiology.heat_mod /= 1.25
	UnregisterSignal(H, list(COMSIG_LIVING_DEATH, COMSIG_ATOM_PRE_BULLET_ACT, COMSIG_LIVING_DODGE_MELEE))

	var/obj/item/organ/ears/ears = H.get_organ_slot(ORGAN_SLOT_EARS)
	if(ears)
		ears.damage_multiplier = initial(ears.damage_multiplier)

/datum/species/tajaran/proc/on_tajaran_death(mob/living/carbon/human/tajaran, gibbed)
	SIGNAL_HANDLER

	if(!istype(tajaran))
		return

	tajaran.tajaran_nine_lives_death_count++

	if(tajaran.tajaran_nine_lives_death_count == (nine_lives_max_deaths - 1))
		to_chat(tajaran, span_danger("You feel this life is your last one..."))

	if(tajaran.tajaran_nine_lives_death_count < nine_lives_max_deaths)
		return

	if(!HAS_TRAIT(tajaran, TRAIT_DNR))
		tajaran.visible_message(span_warning("[tajaran.get_visible_name()] has exhausted all lives and won't rise again."))
		ADD_TRAIT(tajaran, TRAIT_DNR, nine_lives_trait_source)

/datum/species/tajaran/proc/tajaran_dodge_melee(mob/living/carbon/human/tajaran)
	SIGNAL_HANDLER

	if(prob(25))
		src.play_tajaran_dodge_fx(tajaran)
		return COMPONENT_DODGE_SUCCEEDED
	return COMPONENT_DODGE_FAILED

/datum/species/tajaran/proc/play_tajaran_dodge_fx(mob/living/carbon/human/tajaran)
	if(!tajaran)
		return

	// Run emotes async to avoid sleeping-proc violations from signal handlers.
	INVOKE_ASYNC(tajaran, TYPE_PROC_REF(/mob/living/carbon/human, emote), "jump")
	INVOKE_ASYNC(tajaran, TYPE_PROC_REF(/mob/living/carbon/human, emote), "hiss")

	playsound(tajaran, 'sound/items/weapons/thudswoosh.ogg', 35, TRUE)
	playsound(tajaran, get_hiss_sound(tajaran), 45, TRUE)

/datum/species/tajaran/get_hiss_sound(mob/living/carbon/human/tajaran = null)
	return 'sound/mobs/humanoids/felinid/felinid_hiss.ogg'

/datum/action/cooldown/tajaran_grooming
	name = "Grooming"
	desc = "Clean fur, wash blood and dirt, maybe stop bleeding and heal a little."
	button_icon = 'icons/organs/cyber_tongue.dmi'
	button_icon_state = "cybertongue"
	cooldown_time = 1 SECONDS

/datum/action/cooldown/tajaran_grooming/Activate(mob/living/carbon/human/H)
	if(!H)
		return

	H.visible_message(
		span_notice("[H] starts grooming."),
		span_notice("You start grooming.")
	)

	if(!do_after(H, 15 SECONDS, H))
		to_chat(H, span_warning("You got distracted and stop grooming."))
		return

	H.wash(CLEAN_TYPE_BLOOD)
	var/heal_brute = 1
	var/heal_burn = 0
	var/obj/item/bodypart/target_BP = H.get_bodypart(H.zone_selected)
	if(target_BP)
		if(target_BP.heal_damage(heal_brute, heal_burn))
			H.update_damage_overlays()
		if(target_BP.wounds)
			for(var/datum/wound/W in target_BP.wounds)
				if(W.blood_flow > 0 && prob(45))
					W.blood_flow = 0

	H.visible_message(span_notice("[H] finishes grooming."), span_notice("You finish grooming."))

/datum/species/tajaran/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "grin-tongue",
			SPECIES_PERK_NAME = "Grooming",
			SPECIES_PERK_DESC = "Tajarans can groom wounds, clean blood and sometimes stop bleeding.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_EYE_LOW_VISION,
			SPECIES_PERK_NAME = "Tajaran Eyes",
			SPECIES_PERK_DESC = "Better low-light vision, but higher sensitivity to bright light.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_PAW,
			SPECIES_PERK_NAME = "Hunter Instinct",
			SPECIES_PERK_DESC = "Tajarans have strong reflexes and can dodge attacks.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_HEADPHONES_SIMPLE,
			SPECIES_PERK_NAME = "Sensitive Hearing",
			SPECIES_PERK_DESC = "Can hear quieter sounds, but hearing is easier to damage.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_WIND,
			SPECIES_PERK_NAME = "Hunter Smell",
			SPECIES_PERK_DESC = "Can sniff fresh traces and track prints.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_LINES_LEANING,
			SPECIES_PERK_NAME = "Sharp Claws",
			SPECIES_PERK_DESC = "Melee attacks are more likely to cause bleeding.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_RUNNING,
			SPECIES_PERK_NAME = "Natural Agility",
			SPECIES_PERK_DESC = "Moves better through obstacles and is comfortable barefoot.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_CAT,
			SPECIES_PERK_NAME = "Fur",
			SPECIES_PERK_DESC = "Handles cold better, handles heat worse.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_PERSON_FALLING,
			SPECIES_PERK_NAME = "Soft Landing",
			SPECIES_PERK_DESC = "Tajarans are unhurt by high falls, and land on their feet.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_TOOTH,
			SPECIES_PERK_NAME = "Biter :3",
			SPECIES_PERK_DESC = "Tajarans can bite.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shower",
			SPECIES_PERK_NAME = "Hydrophobia",
			SPECIES_PERK_DESC = "Tajarans dislike water and feel discomfort when wet.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_REPEAT,
			SPECIES_PERK_NAME = "Nine Lives",
			SPECIES_PERK_DESC = "After enough deaths, death becomes permanent.",
		),
	)

	return to_add
