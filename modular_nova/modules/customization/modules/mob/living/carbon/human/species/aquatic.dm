/datum/species/aquatic
	name = "Akula (Generic)"
	id = SPECIES_AQUATIC
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_WATER_BREATHING,
		TRAIT_MUTANT_COLORS,
		TRAIT_SHARP_CLAWS,
	)

	/// Храним исходные значения метаболизма для персонажей, чтобы корректно восстанавливать их при смене вида.
	var/list/original_metabolism_efficiency = list()
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutanttongue = /obj/item/organ/tongue/aquatic
	payday_modifier = 1.0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	examine_limb_id = SPECIES_AKULA
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/mutant/aquatic,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/mutant/aquatic,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/mutant/aquatic,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/mutant/aquatic,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/mutant/aquatic,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/mutant/aquatic,
	)

/datum/species/aquatic/get_default_mutant_bodyparts()
	return list(
		FEATURE_TAIL = MUTPART_BLUEPRINT("Shark", is_randomizable = TRUE),
		FEATURE_SNOUT = MUTPART_BLUEPRINT("Shark", is_randomizable = TRUE),
		FEATURE_HORNS = MUTPART_BLUEPRINT(SPRITE_ACCESSORY_NONE, is_randomizable = FALSE),
		FEATURE_EARS = MUTPART_BLUEPRINT("Hammerhead", is_randomizable = TRUE),
		FEATURE_LEGS = MUTPART_BLUEPRINT(NORMAL_LEGS, is_randomizable = FALSE, is_feature = TRUE),
		FEATURE_WINGS = MUTPART_BLUEPRINT(SPRITE_ACCESSORY_NONE, is_randomizable = FALSE),
	)

/obj/item/organ/tongue/aquatic
	liked_foodtypes = SEAFOOD | MEAT | FRUIT | GORE
	disliked_foodtypes = CLOTH | GROSS
	toxic_foodtypes = TOXIC

/obj/item/organ/tongue/aquatic/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/bubble_icon_override, "fish", BUBBLE_ICON_PRIORITY_ORGAN)

/datum/species/aquatic/randomize_features(mob/living/carbon/human/human_mob)
	var/list/features = ..()
	var/main_color
	var/second_color
	var/random = rand(1,5)
	//Choose from a variety of sharkish colors, with a whiter secondary and tertiary
	switch(random)
		if(1)
			main_color = "#668899"
			second_color = "#BBCCDD"
		if(2)
			main_color = "#334455"
			second_color = "#DDDDEE"
		if(3)
			main_color = "#445566"
			second_color = "#DDDDEE"
		if(4)
			main_color = "#666655"
			second_color = "#DDDDEE"
		if(5)
			main_color = "#444444"
			second_color = "#DDDDEE"
	features[FEATURE_MUTANT_COLOR] = main_color
	features[FEATURE_MUTANT_COLOR_TWO] = second_color
	features[FEATURE_MUTANT_COLOR_THREE] = second_color
	return features

/datum/species/aquatic/get_random_body_markings(list/passed_features)
	var/name = "Shark"
	var/datum/body_marking_set/BMS = GLOB.body_marking_sets[name]
	var/list/markings = list()
	if(BMS)
		markings = assemble_body_markings_from_set(BMS, passed_features, src)
	return markings

/datum/species/aquatic/get_species_description()
	return placeholder_description

/datum/species/aquatic/get_species_lore()
	return list(placeholder_lore)



/datum/species/aquatic/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	..()
	if(!istype(H))
		return

	original_metabolism_efficiency[H] = H.metabolism_efficiency
	if(H.reagents)
		RegisterSignal(H.reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_reagents_updated))
	update_metabolism_efficiency(H)

	// === Инстинкт охотника ===
	var/datum/action/cooldown/scent_scan/aquatic/scent = new()
	scent.Grant(H)
	var/datum/action/cooldown/scent_tracking/track = new()
	track.Grant(H)

// ============================================================================
// Акуловые когти
// ============================================================================
	// Если у игрока ещё нет этого перка — выдаём
	if(!H.has_quirk(/datum/quirk/sharpclaws))
		H.add_quirk(/datum/quirk/sharpclaws)

	// --- Не скользим по воде и льду ---
	if(!HAS_TRAIT(H, TRAIT_NO_SLIP_WATER))
		ADD_TRAIT(H, TRAIT_NO_SLIP_WATER, REF(src))
	if(!HAS_TRAIT(H, TRAIT_NO_SLIP_ICE))
		ADD_TRAIT(H, TRAIT_NO_SLIP_ICE, REF(src))

	// --- Шагаем по космосу, как будто это вода ---
	if(!HAS_TRAIT(H, TRAIT_SPACEWALK))
		ADD_TRAIT(H, TRAIT_SPACEWALK, REF(src))

	RegisterSignal(H, COMSIG_CARBON_NOSE_BOOPED, PROC_REF(on_nose_boop))
	RegisterSignal(H, COMSIG_CARBON_NOSE_STRUCK, PROC_REF(on_nose_struck))
	RegisterSignal(H, COMSIG_MOB_MOVESPEED_UPDATED, PROC_REF(check_water_slowdown))

/datum/species/aquatic/on_species_loss(mob/living/carbon/human/H)
	..()
	if(!istype(H))
		return

	if(H.reagents)
		UnregisterSignal(H.reagents, COMSIG_REAGENTS_HOLDER_UPDATED)

	var/original = original_metabolism_efficiency[H]
	if(!isnull(original))
		H.metabolism_efficiency = original
		original_metabolism_efficiency -= H

	if(HAS_TRAIT(H, TRAIT_NO_SLIP_WATER))
		REMOVE_TRAIT(H, TRAIT_NO_SLIP_WATER, REF(src))
	if(HAS_TRAIT(H, TRAIT_NO_SLIP_ICE))
		REMOVE_TRAIT(H, TRAIT_NO_SLIP_ICE, REF(src))

	if(HAS_TRAIT(H, TRAIT_SPACEWALK))
		REMOVE_TRAIT(H, TRAIT_SPACEWALK, REF(src))

	UnregisterSignal(H, list(COMSIG_CARBON_NOSE_BOOPED, COMSIG_CARBON_NOSE_STRUCK, COMSIG_MOB_MOVESPEED_UPDATED))

/datum/species/aquatic/proc/on_nose_boop(mob/living/carbon/human/source, mob/living/carbon/helper)
	if(!source?.is_location_accessible(BODY_ZONE_PRECISE_MOUTH))
		return

	source.add_mood_event("aquatic_snout_boop", /datum/mood_event/aquatic_snout_boop)

/datum/species/aquatic/proc/on_nose_struck(mob/living/carbon/human/source, mob/living/carbon/human/attacker, obj/item/bodypart/affecting)
	if(!affecting)
		return

	source.apply_damage(25, STAMINA, affecting)


/datum/species/aquatic/create_pref_unique_perks()
	var/list/perks = list()
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_TOOTH,
		SPECIES_PERK_NAME = "Острые когти",
		SPECIES_PERK_DESC = "Ваши когти достаточно остры, чтобы нанести ощутимый урон без оружия. В ближнем бою вы наносите больше повреждений и легче пробиваете слабые материалы.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_PERSON_WALKING,
		SPECIES_PERK_NAME = "Как рыба в воде",
		SPECIES_PERK_DESC = "По космосу вы передвигаетесь с легкостью, как будто вы в воде.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_HAND,
		SPECIES_PERK_NAME = "Водная сущность",
		SPECIES_PERK_DESC = "Влажные поверхности - ваша среда. Вы не подскальзываетесь."
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_EYE_DROPPER,
		SPECIES_PERK_NAME = "Инстинкт охотника",
		SPECIES_PERK_DESC = "По запаху крови вы можете определить, где находится ваша цель"
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_SHIRT,
		SPECIES_PERK_NAME = "Солёная кровь",
		SPECIES_PERK_DESC = "В вашей крови повышенное содержание соли — она быстрее очищается от токсинов, но хуже переносит лекарства."
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_ARROW_DOWN,
		SPECIES_PERK_NAME = "Терморегуляция",
		SPECIES_PERK_DESC = "Ваше тело хуже переносит холод, но переносят жару лучше.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_ARROW_DOWN,
		SPECIES_PERK_NAME = "Чувстельная морда",
		SPECIES_PERK_DESC = "Ваша морда более чувствствительная к ударам и порой обычным касаниям.",
	))
	return perks


/datum/species/aquatic/proc/on_reagents_updated(datum/source)
	SIGNAL_HANDLER
	var/datum/reagents/reagents = source
	var/mob/living/carbon/human/H = reagents?.my_atom
	if(!istype(H))
		return

	update_metabolism_efficiency(H)

/datum/species/aquatic/proc/update_metabolism_efficiency(mob/living/carbon/human/H)
	if(!istype(H))
		return

	var/original = original_metabolism_efficiency[H]
	if(isnull(original))
		original = H.metabolism_efficiency
		original_metabolism_efficiency[H] = original

	var/has_medicine = H.reagents?.has_reagent(/datum/reagent/medicine, TRUE)
	var/has_toxin = H.reagents?.has_reagent(/datum/reagent/toxin, TRUE)
	var/has_drug = H.reagents?.has_reagent(/datum/reagent/drug, TRUE)
	var/has_alcohol = H.reagents?.has_reagent(/datum/reagent/consumable/ethanol, TRUE)

    // если в крови есть что-то из вышеуказанного -> ускоренный метаболизм
	if(has_medicine || has_toxin || has_drug || has_alcohol)
		H.metabolism_efficiency = original * 6.0
		return

	H.metabolism_efficiency = original

///Анти-замедление в воде
/datum/species/aquatic/proc/check_water_slowdown(mob/living/aquatic)
	SIGNAL_HANDLER

	var/turf/open/turfy = aquatic.loc

	if(!istype(turfy, /turf/open/water))
		return

	aquatic.remove_movespeed_modifier(/datum/movespeed_modifier/turf_slowdown)
