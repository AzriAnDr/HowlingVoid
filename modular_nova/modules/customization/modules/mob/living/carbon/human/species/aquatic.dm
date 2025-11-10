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
	// Храним ссылку на наш скрытый «двигатель», чтобы потом убрать.
	//var/datum/component/akula_swim/swim_component
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutant_bodyparts = list()
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
		"tail" = list("Shark", TRUE),
		"snout" = list("Shark", TRUE),
		"horns" = list("None", FALSE),
		"ears" = list("Hammerhead", TRUE),
		"legs" = list("Normal Legs", FALSE),
		"wings" = list("None", FALSE),
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
	features["mcolor"] = main_color
	features["mcolor2"] = second_color
	features["mcolor3"] = second_color
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
/*
	// --- Добавляем компонент плавания ---
	if(!swim_component)
		swim_component = H.AddComponent(/datum/component/akula_swim)
	to_chat(H, span_notice("Ты чувствуешь себя в невесомости как дома — словно в воде."))
*/
/datum/species/aquatic/on_species_loss(mob/living/carbon/human/H)
	..()
	if(!istype(H))
		return
	if(HAS_TRAIT(H, TRAIT_NO_SLIP_WATER))
		REMOVE_TRAIT(H, TRAIT_NO_SLIP_WATER, REF(src))
	if(HAS_TRAIT(H, TRAIT_NO_SLIP_ICE))
		REMOVE_TRAIT(H, TRAIT_NO_SLIP_ICE, REF(src))
/*
	// --- Убираем компонент плавания ---
	if(swim_component)
		qdel(swim_component)
		swim_component = null
	to_chat(H, span_warning("Твоя подвижность в невесомости исчезает."))


// =====================================================================
// Component: Akula Swim (аналог джетпака без топлива)
// =====================================================================

/datum/component/akula_swim
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/mob/living/carbon/human/owner
	var/active = FALSE
	var/datum/component/jetpack/jetpack_emulation

/datum/component/akula_swim/Initialize(_owner)
	if(!istype(_owner, /mob/living/carbon/human))
		return COMPONENT_INCOMPATIBLE
	owner = _owner
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_move))
	check_gravity()
	return ..()

/datum/component/akula_swim/Destroy()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_Z_CHANGED))
	disable_swim()
	owner = null
	return ..()

/datum/component/akula_swim/proc/get_gravity_for(atom/movable/A)
	var/turf/T = get_turf(A)
	if(!T)
		return STANDARD_GRAVITY
	var/datum/controller/subsystem/gravity/G = SSGRAVITY
	if(!G)
		return STANDARD_GRAVITY
	return G.get_gravity(T)

/datum/component/akula_swim/proc/check_gravity()
	if(!owner)
		return
	var/grav = get_gravity_for(owner)
	if(grav <= ZERO_GRAVITY && !active)
		enable_swim()
	else if(grav > ZERO_GRAVITY && active)
		disable_swim()

/datum/component/akula_swim/proc/on_move(atom/source)
	check_gravity()

// включаем свободное движение (эмуляция джетпака)
/datum/component/akula_swim/proc/enable_swim()
	if(active)
		return
	active = TRUE

	if(!jetpack_emulation)
		jetpack_emulation = owner.AddComponent(
			/datum/component/jetpack,
			TRUE, // стабилизированный
			1.8,  // сила тяги
			1.3,  // сила стабилизации
			null, null, null,
			CALLBACK(src, PROC_REF(always_true)),
			CALLBACK(src, PROC_REF(always_true)),
			/datum/effect_system/trail_follow/ion/grav_allowed
		)

	to_chat(owner, span_notice("Ты начинаешь двигаться в невесомости словно в воде."))

/datum/component/akula_swim/proc/disable_swim()
	if(!active)
		return
	active = FALSE
	if(jetpack_emulation)
		qdel(jetpack_emulation)
		jetpack_emulation = null
	to_chat(owner, span_warning("Ты больше не можешь двигаться в невесомости."))

/datum/component/akula_swim/proc/always_true()
	return TRUE
*/

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
		SPECIES_PERK_ICON = FA_ICON_LUNGS,
		SPECIES_PERK_NAME = "Хищное спокойствие",
		SPECIES_PERK_DESC = "Вы не показываете эмоций и способны дольше сохранять концентрацию. Однако люди чувствуют себя рядом с вами неуютно.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_ARROW_DOWN,
		SPECIES_PERK_NAME = "Терморегуляция",
		SPECIES_PERK_DESC = "Ваше тело хуже переносит холод, но переносят жару лучше.",
	))
	return perks
