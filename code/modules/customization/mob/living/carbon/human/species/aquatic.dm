/datum/species/aquatic
	name = "Akula (Generic)"
	id = SPECIES_AQUATIC
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_WATER_BREATHING,
		TRAIT_NODROWN,
		TRAIT_MUTANT_COLORS,
	)
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

// HowlingVoid aquatic organs integration.
/obj/item/organ/brain/aquatic
	name = "Azulean Brain"
	icon = 'icons/organs/aquatic_organs.dmi'
	icon_state = "brain_aquatic"

/obj/item/organ/heart/aquatic
	name = "Azulean Heart"
	icon = 'icons/organs/aquatic_organs.dmi'
	icon_state = "heart_aquatic"

/obj/item/organ/lungs/aquatic
	name = "Azulean Lungs"
	icon = 'icons/organs/aquatic_organs.dmi'
	icon_state = "lungs_aquatic"

/obj/item/organ/stomach/aquatic
	name = "Azulean Stomach"
	icon = 'icons/organs/aquatic_organs.dmi'
	icon_state = "stomach_aquatic"

/obj/item/organ/liver/aquatic
	name = "Azulean Liver"
	icon = 'icons/organs/aquatic_organs.dmi'
	icon_state = "liver_aquatic"


/obj/item/organ/heart/aquatic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_blocker)


// HowlingVoid aquatic mechanics integration.
/datum/species/aquatic
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_SWIMMER,
		TRAIT_WATER_BREATHING,
		TRAIT_MUTANT_COLORS,
		TRAIT_SHARP_CLAWS,
	)
	/// Guard to ignore movement signal emitted by our own coast step.
	var/tmp/list/space_coast_skip = list()
	/// Last client move direction for pending coast step.
	var/tmp/list/space_coast_dir = list()
	/// Whether sharp claws quirk was injected by this species (key = mob, value = TRUE/FALSE).
	var/tmp/list/species_added_sharpclaws = list()
	/// Species-granted actions tracked for cleanup.
	var/tmp/list/species_scent_scan_action = list()
	var/tmp/list/species_scent_track_action = list()

/datum/species/aquatic/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	if(!istype(H))
		return
	. = ..()

	UnregisterSignal(H, COMSIG_MOB_REAGENT_TICK)
	RegisterSignal(H, COMSIG_MOB_REAGENT_TICK, PROC_REF(on_reagent_tick))
	RegisterSignal(H, COMSIG_MOVABLE_MOVED, PROC_REF(update_water_mobility))
	RegisterSignal(H, COMSIG_MOB_CLIENT_MOVED, PROC_REF(on_spacewalk_step))

	var/datum/action/cooldown/scent_scan/aquatic/old_scent = species_scent_scan_action[H]
	if(old_scent)
		old_scent.Remove(H)
		qdel(old_scent)
	species_scent_scan_action[H] = null

	var/datum/action/cooldown/scent_tracking/old_track = species_scent_track_action[H]
	if(old_track)
		old_track.Remove(H)
		qdel(old_track)
	species_scent_track_action[H] = null

	var/datum/action/cooldown/scent_scan/aquatic/scent = new()
	scent.Grant(H)
	species_scent_scan_action[H] = scent
	var/datum/action/cooldown/scent_tracking/track = new()
	track.Grant(H)
	species_scent_track_action[H] = track

	species_added_sharpclaws[H] = FALSE
	if(!H.has_quirk(/datum/quirk/sharpclaws))
		if(H.add_quirk(/datum/quirk/sharpclaws, override_client = H.client, announce = FALSE))
			species_added_sharpclaws[H] = TRUE

	if(!HAS_TRAIT(H, TRAIT_NO_SLIP_WATER))
		ADD_TRAIT(H, TRAIT_NO_SLIP_WATER, REF(src))
	if(!HAS_TRAIT(H, TRAIT_NO_SLIP_ICE))
		ADD_TRAIT(H, TRAIT_NO_SLIP_ICE, REF(src))
	if(!HAS_TRAIT(H, TRAIT_SPACEWALK))
		ADD_TRAIT(H, TRAIT_SPACEWALK, REF(src))

	RegisterSignal(H, COMSIG_CARBON_NOSE_BOOPED, PROC_REF(on_nose_boop))
	RegisterSignal(H, COMSIG_CARBON_NOSE_STRUCK, PROC_REF(on_nose_struck))
	update_water_mobility(H, null)

/datum/species/aquatic/on_species_loss(mob/living/carbon/human/H)
	if(!istype(H))
		return
	. = ..()

	UnregisterSignal(H, COMSIG_MOB_REAGENT_TICK)
	UnregisterSignal(H, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(H, COMSIG_MOB_CLIENT_MOVED)

	if(HAS_TRAIT(H, TRAIT_NO_SLIP_WATER))
		REMOVE_TRAIT(H, TRAIT_NO_SLIP_WATER, REF(src))
	if(HAS_TRAIT(H, TRAIT_NO_SLIP_ICE))
		REMOVE_TRAIT(H, TRAIT_NO_SLIP_ICE, REF(src))
	if(HAS_TRAIT(H, TRAIT_SPACEWALK))
		REMOVE_TRAIT(H, TRAIT_SPACEWALK, REF(src))

	H.remove_movespeed_modifier(/datum/movespeed_modifier/aquatic_water_speedboost)
	H.remove_movespeed_modifier(/datum/movespeed_modifier/aquatic_deep_water_speedboost)
	UnregisterSignal(H, list(COMSIG_CARBON_NOSE_BOOPED, COMSIG_CARBON_NOSE_STRUCK))

	var/datum/action/cooldown/scent_scan/aquatic/scent = species_scent_scan_action[H]
	if(scent)
		scent.Remove(H)
		qdel(scent)
	species_scent_scan_action[H] = null

	var/datum/action/cooldown/scent_tracking/track = species_scent_track_action[H]
	if(track)
		track.Remove(H)
		qdel(track)
	species_scent_track_action[H] = null

	if(species_added_sharpclaws[H] && H.has_quirk(/datum/quirk/sharpclaws))
		H.remove_quirk(/datum/quirk/sharpclaws)
	species_added_sharpclaws[H] = null

	space_coast_skip -= H
	space_coast_dir -= H

/datum/species/aquatic/proc/on_spacewalk_step(mob/living/carbon/human/source, move_dir, old_dir)
	SIGNAL_HANDLER
	if(!istype(source) || !source.client || !move_dir)
		return
	if(source.has_gravity() || !isturf(source.loc))
		return
	if(source.buckled || source.pulledby || source.throwing || source.incapacitated)
		return

	if(space_coast_skip[source])
		space_coast_skip -= source
		return

	space_coast_dir[source] = move_dir
	addtimer(CALLBACK(src, PROC_REF(apply_spacewalk_coast), source), 1, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/species/aquatic/proc/apply_spacewalk_coast(mob/living/carbon/human/source)
	var/move_dir = space_coast_dir[source]
	space_coast_dir -= source
	if(!istype(source) || !source.client || !move_dir)
		return
	if(!istype(source.dna?.species, /datum/species/aquatic))
		return
	if(source.has_gravity() || !isturf(source.loc))
		return
	if(source.buckled || source.pulledby || source.throwing || source.incapacitated)
		return
	// Coast only when player has released movement input.
	if(source.client.intended_direction)
		return
	// No coast when passing close to any non-space tile or nearby blocking structure.
	if(is_near_obstruction_for_coast(source))
		return
	if(is_coast_step_blocked(source, move_dir))
		return

	var/turf/next_turf = get_step(source, move_dir)
	if(!istype(next_turf))
		return

	space_coast_skip[source] = TRUE
	source.Move(next_turf, move_dir)

/datum/species/aquatic/proc/is_coast_step_blocked(mob/living/carbon/human/source, move_dir)
	if(!istype(source) || !move_dir)
		return TRUE

	var/turf/next_turf = get_step(source, move_dir)
	if(!istype(next_turf) || next_turf.density)
		return TRUE

	for(var/atom/thing in next_turf)
		if(thing == source)
			continue
		if(isliving(thing))
			continue
		if(thing.density)
			return TRUE

	return FALSE

/datum/species/aquatic/proc/is_near_obstruction_for_coast(mob/living/carbon/human/source)
	if(!istype(source))
		return TRUE

	for(var/turf/T in range(1, source))
		if(T == source.loc)
			continue
		if(!isspaceturf(T))
			return TRUE

	for(var/atom/A in range(1, source))
		if(A == source || A == source.loc)
			continue
		if(isliving(A))
			continue
		if(istype(A, /obj/structure/lattice))
			return TRUE
		if(istype(A, /obj/structure/grille))
			return TRUE
		if(istype(A, /obj/structure/window))
			return TRUE
		if(A.density)
			return TRUE

	return FALSE

/datum/species/aquatic/proc/on_nose_boop(mob/living/carbon/human/source, mob/living/carbon/helper)
	SIGNAL_HANDLER
	if(!source?.is_location_accessible(BODY_ZONE_PRECISE_MOUTH))
		return

	source.add_mood_event("aquatic_snout_boop", /datum/mood_event/aquatic_snout_boop)

/datum/species/aquatic/proc/on_nose_struck(mob/living/carbon/human/source, mob/living/carbon/human/attacker, obj/item/bodypart/affecting)
	if(!affecting)
		return

	source.apply_damage(25, STAMINA, affecting)

/datum/species/aquatic/proc/on_reagent_tick(mob/living/carbon/human/source, datum/reagent/reagent, seconds_per_tick)
	SIGNAL_HANDLER
	if(!istype(source) || !istype(reagent) || !source?.reagents)
		return

	// Apply only to blood chemistry, not stomach digestion or organ digestion.
	if(reagent.holder != source.reagents)
		return

	if(!is_blood_metabolism_target(reagent))
		return

	var/bonus_metabolized = reagent.compute_metabolization(source, seconds_per_tick) * 0.3
	if(bonus_metabolized <= 0)
		return

	source.reagents.remove_reagent(reagent.type, bonus_metabolized)

/datum/species/aquatic/proc/is_blood_metabolism_target(datum/reagent/reagent)
	if(!istype(reagent))
		return FALSE

	if(
		istype(reagent, /datum/reagent/medicine) \
		|| istype(reagent, /datum/reagent/toxin) \
		|| istype(reagent, /datum/reagent/drug) \
		|| istype(reagent, /datum/reagent/consumable/ethanol)
	)
		return TRUE

	return FALSE
// Water Swimming
/datum/species/aquatic/proc/is_aquatic_speed_tile(atom/location)
	if(!isturf(location))
		return FALSE

	var/turf/check_turf = location
	if(HAS_TRAIT(check_turf, TRAIT_TURF_IGNORE_SLOWDOWN))
		return FALSE

	if(istype(check_turf, /turf/open/water))
		return TRUE

	// Only grant speed on sufficiently deep liquids tiles (prevents boost from fresh spills/puddles).
	if(check_turf.liquids && check_turf.liquids.liquid_state >= LIQUID_STATE_WAIST)
		return TRUE

	return FALSE

/datum/species/aquatic/proc/is_aquatic_deep_tile(atom/location)
	if(!isturf(location))
		return FALSE

	var/turf/check_turf = location
	if(HAS_TRAIT(check_turf, TRAIT_TURF_IGNORE_SLOWDOWN))
		return FALSE

	if(istype(check_turf, /turf/open/water))
		var/turf/open/water/water_turf = check_turf
		if(water_turf.is_swimming_tile)
			return TRUE

	if(check_turf.liquids && check_turf.liquids.liquid_state >= LIQUID_STATE_SHOULDERS)
		return TRUE

	return FALSE

/datum/species/aquatic/proc/update_water_mobility(mob/living/carbon/human/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(!istype(source))
		return

	var/was_water = is_aquatic_speed_tile(old_loc)
	var/is_water = is_aquatic_speed_tile(source.loc)
	var/is_deep = is_aquatic_deep_tile(source.loc)

	// Apply shark speed bonuses in water without removing engine slowdowns.
	source.remove_movespeed_modifier(/datum/movespeed_modifier/aquatic_water_speedboost)
	source.remove_movespeed_modifier(/datum/movespeed_modifier/aquatic_deep_water_speedboost)

	if(!is_water)
		if(was_water)
			// Prevent short lingering post-water slowdown from the swimming status effect.
			source.remove_status_effect(/datum/status_effect/swimming)
			// Keep shark momentum briefly after leaving water.
			source.add_movespeed_modifier(/datum/movespeed_modifier/aquatic_water_speedboost)
			addtimer(CALLBACK(src, PROC_REF(clear_water_exit_boost), source), 1.5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
		return

	source.add_movespeed_modifier(/datum/movespeed_modifier/aquatic_water_speedboost)
	if(is_deep)
		source.add_movespeed_modifier(/datum/movespeed_modifier/aquatic_deep_water_speedboost)

/datum/species/aquatic/proc/clear_water_exit_boost(mob/living/carbon/human/source)
	if(!istype(source))
		return
	if(!istype(source.dna?.species, /datum/species/aquatic))
		return
	if(is_aquatic_speed_tile(source.loc))
		return
	source.remove_movespeed_modifier(/datum/movespeed_modifier/aquatic_water_speedboost)

/datum/movespeed_modifier/aquatic_water_speedboost
	multiplicative_slowdown = -0.2

/datum/movespeed_modifier/aquatic_deep_water_speedboost
	multiplicative_slowdown = -1.65

/datum/species/aquatic/prepare_human_for_preview(mob/living/carbon/human/aquatic)
	var/main_color = "#4A6D7A"
	var/secondary_color = "#cccccc"
	var/tertiary_color = "#c2c2c2"

	aquatic.dna.features[FEATURE_MUTANT_COLOR] = main_color
	aquatic.dna.features[FEATURE_MUTANT_COLOR_TWO] = secondary_color
	aquatic.dna.features[FEATURE_MUTANT_COLOR_THREE] = tertiary_color
	aquatic.dna.mutant_bodyparts[FEATURE_TAIL] = build_mutant_part("Shark", list(main_color, secondary_color, tertiary_color))
	aquatic.dna.mutant_bodyparts[FEATURE_SNOUT] = build_mutant_part("hShark", list(main_color, secondary_color, tertiary_color))
	aquatic.dna.mutant_bodyparts[FEATURE_EARS] = build_mutant_part("Sergal", list(main_color, secondary_color, tertiary_color))
	aquatic.dna.features[FEATURE_LEGS] = NORMAL_LEGS
	regenerate_organs(aquatic, src, visual_only = TRUE)
	aquatic.update_body(TRUE)

/datum/species/aquatic/create_pref_unique_perks()
	var/list/perks = list()
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_HAND_BACK_FIST,
		SPECIES_PERK_NAME = "Sharp Claws",
		SPECIES_PERK_DESC = "Your claws are sharp enough to deal meaningful damage without weapons. In melee, you hit harder and tear through weak materials more easily.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_FISH,
		SPECIES_PERK_NAME = "Like a Fish in Water",
		SPECIES_PERK_DESC = "You move through space with ease, as if you were swimming.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_WATER,
		SPECIES_PERK_NAME = "Aquatic Nature",
		SPECIES_PERK_DESC = "Wet surfaces are your home turf. You do not slip on them.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_EYE_DROPPER,
		SPECIES_PERK_NAME = "Predator Instinct",
		SPECIES_PERK_DESC = "By the scent of blood, you can determine where your prey is.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_TEMPERATURE_HALF,
		SPECIES_PERK_NAME = "Thermoregulation",
		SPECIES_PERK_DESC = "Your body handles cold worse, but tolerates heat better.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_DROPLET,
		SPECIES_PERK_NAME = "Salty Blood",
		SPECIES_PERK_DESC = "Your blood has elevated salinity - it purges toxins faster, but handles medicine worse.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_WIND,
		SPECIES_PERK_NAME = "Sensitive Snout",
		SPECIES_PERK_DESC = "Your snout is more sensitive to hits and even occasional light touches.",
	))
	return perks

