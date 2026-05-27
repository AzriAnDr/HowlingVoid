/datum/species/monkey/kobold
	name = "\improper Kobold"
	id = SPECIES_KOBOLD_PRIMITIVE
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_REPTILE
	mutant_organs = list()

	mutanttongue = /obj/item/organ/tongue/lizard
	mutanteyes = /obj/item/organ/eyes/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/carbon/lizard
	meat = /obj/item/food/meat/slab/human/mutant/lizard
	knife_butcher_results = list(/obj/item/food/meat/slab/human/mutant/lizard = 5, /obj/item/stack/sheet/animalhide/carbon/lizard = 1)
	inherent_traits = list(
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_UNDERWEAR,
		TRAIT_VENTCRAWLER_NUDE,
		TRAIT_WEAK_SOUL,
		TRAIT_MUTANT_COLORS,
	)
	no_equip_flags = null
	species_cookie = /obj/item/food/meat/slab
	coldmod = 1.5
	heatmod = 0.67
	death_sound = 'sound/mobs/humanoids/lizard/deathsound.ogg'
	bodytemp_heat_damage_limit = BODYTEMP_HEAT_LAVALAND_SAFE
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 10)
	species_cookie = /obj/item/food/meat/slab
	species_language_holder = /datum/language_holder/kobold
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/kobold,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/kobold,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/kobold,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/kobold,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/kobold,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/kobold,
	)
	exotic_bloodtype = BLOOD_TYPE_LIZARD
	payday_modifier = 1

/datum/species/monkey/kobold/get_default_mutant_bodyparts()
	return list(
		FEATURE_TAIL = MUTPART_BLUEPRINT("Smooth", is_randomizable = TRUE),
		FEATURE_SNOUT = MUTPART_BLUEPRINT("Round", is_randomizable = TRUE),
		FEATURE_FRILLS = MUTPART_BLUEPRINT("Short", is_randomizable = FALSE),
		FEATURE_HORNS = MUTPART_BLUEPRINT("Curled", is_randomizable = FALSE),
	)

/datum/species/monkey/kobold/randomize_features()
	var/list/features = ..()
	var/main_color = "#[random_color()]"
	features[FEATURE_MUTANT_COLOR] = main_color
	features[FEATURE_MUTANT_COLOR_TWO] = main_color
	features[FEATURE_MUTANT_COLOR_THREE] = main_color
	features -= FEATURE_TAIL
	return features

/datum/species/monkey/kobold/get_scream_sound(mob/living/carbon/human/kobold)
	return pick(
		'sound/mobs/humanoids/lizard/lizard_scream_1.ogg',
		'sound/mobs/humanoids/lizard/lizard_scream_2.ogg',
		'sound/mobs/humanoids/lizard/lizard_scream_3.ogg',
	)

/datum/species/monkey/kobold/get_hiss_sound(mob/living/carbon/human/kobold)
	return 'sound/mobs/humanoids/lizard/lizard_hiss.ogg'

/datum/species/monkey/kobold/get_physical_attributes()
	return "Kobolds are functionally identical to monkeys, but with the downsides of lizards."

/datum/species/monkey/kobold/get_species_description()
	return "Kobolds are diminutive, reptilian creatures as related to Lizardpeople as monkeys are to humans."

/datum/species/monkey/kobold/get_species_lore()
	return list(
		"A smaller subspecies of lizardperson, tends to be rather excitable in nature.",
	)

/datum/species/monkey/kobold/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "thermometer-empty",
		SPECIES_PERK_NAME = "Cold-blooded",
		SPECIES_PERK_DESC = "Kobolds have higher tolerance for hot temperatures, but lower \
			tolerance for cold temperatures. Additionally, they cannot self-regulate their body temperature - \
			they are as cold or as warm as the environment around them is. Stay warm!",
	))

	return to_add

/datum/species/monkey/kobold/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "spider",
			SPECIES_PERK_NAME = "Vent Crawling",
			SPECIES_PERK_DESC = "Kobolds can crawl through the vent and scrubber networks while wearing no clothing. \
				Stay out of the kitchen!",
		),
	)

/datum/species/monkey/kobold/create_pref_language_perk()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "comment",
		SPECIES_PERK_NAME = "Primitive Tongue",
		SPECIES_PERK_DESC = "You are able to understand [/datum/language/kobold::name].",
	))

	return to_add

/datum/species/monkey/kobold/prepare_human_for_preview(mob/living/carbon/human/kobold)
	var/main_color = "#926838"
	var/second_color = "#926838"
	var/third_color = "#926838"

	kobold.dna.features[FEATURE_MUTANT_COLOR] = main_color
	kobold.dna.features[FEATURE_MUTANT_COLOR_TWO] = second_color
	kobold.dna.features[FEATURE_MUTANT_COLOR_THREE] = third_color
	kobold.dna.mutant_bodyparts[FEATURE_SNOUT] = build_mutant_part("Round", list(main_color, main_color, main_color))
	kobold.dna.mutant_bodyparts[FEATURE_TAIL] = build_mutant_part("Smooth", list(second_color, main_color, main_color))
	kobold.dna.mutant_bodyparts[FEATURE_HORNS] = build_mutant_part("Curled", list(main_color, main_color, main_color))
	kobold.dna.mutant_bodyparts[FEATURE_FRILLS] = build_mutant_part("Short", list(main_color, main_color, main_color))
	regenerate_organs(kobold, src, visual_only = TRUE)
	kobold.update_body(TRUE)

// Same as regular kobolds except they cannot be butchered, and are smart enough to use devices (debatable)
/datum/species/monkey/kobold/roundstart
	id = SPECIES_KOBOLD
	examine_limb_id = SPECIES_KOBOLD
	mutantbrain = /obj/item/organ/brain/lizard
	knife_butcher_results = null
	inherent_traits = list(
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_VENTCRAWLER_NUDE,
		TRAIT_MUTANT_COLORS,
	)

// HowlingVoid kobold mechanics integration.
/datum/actionspeed_modifier/kobold_quickwork
	id = ACTIONSPEED_ID_HOWLING_KOBOLD_QUICKWORK
	variable = TRUE

/datum/species/monkey/kobold
	/// Cached maxHealth before Kobold override (key = mob)
	var/tmp/list/kobold_prev_max_health = list()
	/// Cached unarmed arm damage before Kobold override (key = mob, value = list("l_low","l_high","r_low","r_high"))
	var/tmp/list/kobold_prev_arm_damage = list()
	/// Trap ping anti-spam timer per mob (world.time deciseconds)
	var/tmp/list/kobold_trap_scan_cd = list()
	/// Recently pinged trap refs per mob (key = mob, value = assoc list REF -> expire time)
	var/tmp/list/kobold_known_traps = list()

/datum/species/monkey/kobold/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	if(!istype(H))
		return

	. = ..()

	kobold_prev_max_health[H] = H.maxHealth
	H.maxHealth = 75
	H.health = min(H.health, H.maxHealth)

	var/list/arm_damage_cache = list()
	var/obj/item/bodypart/arm/left/left_arm = H.get_bodypart(BODY_ZONE_L_ARM)
	if(left_arm)
		arm_damage_cache["l_low"] = left_arm.unarmed_damage_low
		arm_damage_cache["l_high"] = left_arm.unarmed_damage_high
		left_arm.unarmed_damage_low = max(0, round(left_arm.unarmed_damage_low * 0.85))
		left_arm.unarmed_damage_high = max(left_arm.unarmed_damage_low, round(left_arm.unarmed_damage_high * 0.85))

	var/obj/item/bodypart/arm/right/right_arm = H.get_bodypart(BODY_ZONE_R_ARM)
	if(right_arm)
		arm_damage_cache["r_low"] = right_arm.unarmed_damage_low
		arm_damage_cache["r_high"] = right_arm.unarmed_damage_high
		right_arm.unarmed_damage_low = max(0, round(right_arm.unarmed_damage_low * 0.85))
		right_arm.unarmed_damage_high = max(right_arm.unarmed_damage_low, round(right_arm.unarmed_damage_high * 0.85))
	if(length(arm_damage_cache))
		kobold_prev_arm_damage[H] = arm_damage_cache

	RegisterSignal(H, COMSIG_MOVABLE_MOVED, PROC_REF(on_kobold_moved))
	RegisterSignal(H, COMSIG_LIVING_TRY_PULL, PROC_REF(on_kobold_try_pull))
	RegisterSignal(H, COMSIG_MOB_FLASHED, PROC_REF(on_kobold_flashed))

	ADD_TRAIT(H, TRAIT_VENTCRAWLER_ALWAYS, REF(src))
	ADD_TRAIT(H, TRAIT_QUICK_BUILD, REF(src))
	H.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/kobold_quickwork, multiplicative_slowdown = -0.3)

/datum/species/monkey/kobold/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	if(!istype(H))
		return

	. = ..()

	UnregisterSignal(H, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_TRY_PULL, COMSIG_MOB_FLASHED))

	if(HAS_TRAIT(H, TRAIT_VENTCRAWLER_ALWAYS))
		REMOVE_TRAIT(H, TRAIT_VENTCRAWLER_ALWAYS, REF(src))
	if(HAS_TRAIT(H, TRAIT_QUICK_BUILD))
		REMOVE_TRAIT(H, TRAIT_QUICK_BUILD, REF(src))
	H.remove_actionspeed_modifier(ACTIONSPEED_ID_HOWLING_KOBOLD_QUICKWORK)

	if(isnum(kobold_prev_max_health[H]))
		H.maxHealth = kobold_prev_max_health[H]
		H.health = min(H.health, H.maxHealth)

	var/list/arm_damage_cache = kobold_prev_arm_damage[H]
	if(islist(arm_damage_cache))
		var/obj/item/bodypart/arm/left/left_arm = H.get_bodypart(BODY_ZONE_L_ARM)
		if(left_arm)
			if(isnum(arm_damage_cache["l_low"]))
				left_arm.unarmed_damage_low = arm_damage_cache["l_low"]
			if(isnum(arm_damage_cache["l_high"]))
				left_arm.unarmed_damage_high = arm_damage_cache["l_high"]
		var/obj/item/bodypart/arm/right/right_arm = H.get_bodypart(BODY_ZONE_R_ARM)
		if(right_arm)
			if(isnum(arm_damage_cache["r_low"]))
				right_arm.unarmed_damage_low = arm_damage_cache["r_low"]
			if(isnum(arm_damage_cache["r_high"]))
				right_arm.unarmed_damage_high = arm_damage_cache["r_high"]

	kobold_prev_max_health -= H
	kobold_prev_arm_damage -= H
	kobold_trap_scan_cd -= H
	kobold_known_traps -= H

/datum/species/monkey/kobold/proc/on_kobold_try_pull(mob/living/carbon/human/source, atom/movable/target, force)
	SIGNAL_HANDLER

	if(!istype(source) || !target)
		return
	if(istype(target, /obj/structure/closet) || istype(target, /obj/machinery/portable_atmospherics/canister))
		to_chat(source, span_warning("It's too bulky for you to drag."))
		return COMSIG_LIVING_CANCEL_PULL
	if(isliving(target))
		if(ishuman(target))
			var/mob/living/carbon/human/human_target = target
			if(human_target.mob_height >= HUMAN_HEIGHT_MEDIUM && (human_target.stat == DEAD || human_target.body_position == LYING_DOWN || human_target.stat >= SOFT_CRIT))
				to_chat(source, span_warning("This body is too heavy for you to drag."))
				return COMSIG_LIVING_CANCEL_PULL
		return

/datum/species/monkey/kobold/proc/on_kobold_flashed(mob/living/carbon/human/source, intensity, override_blindness_check, affect_silicon, visual, type, length)
	SIGNAL_HANDLER

	if(!istype(source) || source.stat != CONSCIOUS || visual)
		return

	source.add_mood_event("kobold_flashed", /datum/mood_event/kobold_flashed)
	source.Stun(max(0.3 SECONDS, intensity * 0.4 SECONDS))
	source.Knockdown(max(0.6 SECONDS, intensity * 0.6 SECONDS))

/datum/species/monkey/kobold/proc/on_kobold_moved(mob/living/carbon/human/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	if(!istype(source) || source.stat == DEAD)
		return
	if(kobold_trap_scan_cd[source] > world.time)
		return

	kobold_trap_scan_cd[source] = world.time + 2
	detect_kobold_traps(source)

/datum/species/monkey/kobold/proc/detect_kobold_traps(mob/living/carbon/human/source)
	if(!istype(source))
		return

	var/static/list/detectable_traps = typecacheof(list(
		/obj/effect/mine,
		/obj/item/restraints/legcuffs/beartrap,
		/obj/item/grenade/chem_grenade,
		/obj/structure/trap/cult,
		/obj/structure/trap/eldritch,
		/obj/structure/destructible/clockwork/trap,
	))

	var/list/known = kobold_known_traps[source]
	if(!islist(known))
		known = list()
		kobold_known_traps[source] = known

	for(var/ref_id in known)
		if(known[ref_id] <= world.time)
			known -= ref_id

	for(var/obj/trap in range(3, source))
		if(!is_type_in_typecache(trap, detectable_traps))
			continue
		if(!can_see(source, trap, 3))
			continue
		if(istype(trap, /obj/item/grenade/chem_grenade))
			var/obj/item/grenade/chem_grenade/grenade_trap = trap
			if(!grenade_trap.landminemode)
				continue

		var/ref_id = REF(trap)
		if(known[ref_id] > world.time)
			continue

		known[ref_id] = world.time + 30
		source.balloon_alert(source, "trap: [dir2text(get_dir(source, trap))]")
		show_kobold_trap_arrow(source, trap)
		break

/datum/species/monkey/kobold/proc/show_kobold_trap_arrow(mob/living/carbon/human/source, obj/trap)
	if(!istype(source) || !trap || !source.hud_used)
		return

	var/turf/source_turf = get_turf(source)
	var/turf/trap_turf = get_turf(trap)
	if(!source_turf || !trap_turf || source_turf.z != trap_turf.z)
		return

	var/distance = get_dist(source_turf, trap_turf)
	var/arrow_color = COLOR_YELLOW
	switch(distance)
		if(0 to 1)
			arrow_color = COLOR_GREEN
		if(2)
			arrow_color = COLOR_YELLOW
		else
			arrow_color = COLOR_ORANGE

	new /atom/movable/screen/navigate_arrow/scent(null, source.hud_used, trap_turf, arrow_color)

/datum/species/monkey/kobold/create_pref_unique_perks()
	. = ..()
	. += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Tinker's Tempo",
			SPECIES_PERK_DESC = "Kobolds perform actions, crafting and setup work about 30% faster.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "triangle-exclamation",
			SPECIES_PERK_NAME = "Trap Sense",
			SPECIES_PERK_DESC = "Nearby traps are easier to notice within 2 tiles if line of sight is clear.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "dumbbell",
			SPECIES_PERK_NAME = "Small Frame",
			SPECIES_PERK_DESC = "Max health is reduced to 75, unarmed melee damage is weaker, and bulky anchored cargo is hard to drag.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Light Sensitive",
			SPECIES_PERK_DESC = "Bright flashes hit kobolds harder, causing extra stun and stress.",
		),
	)

