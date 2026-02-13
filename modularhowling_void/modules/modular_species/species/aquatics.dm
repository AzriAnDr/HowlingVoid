/datum/species/aquatic
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_WATER_BREATHING,
		TRAIT_MUTANT_COLORS,
		TRAIT_SHARP_CLAWS,
	)
	/// Guard to ignore movement signal emitted by our own coast step.
	var/tmp/list/space_coast_skip = list()
	/// Last client move direction for pending coast step.
	var/tmp/list/space_coast_dir = list()

/datum/species/aquatic/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	..()
	if(!istype(H))
		return

	UnregisterSignal(H, COMSIG_MOB_REAGENT_TICK)
	RegisterSignal(H, COMSIG_MOB_REAGENT_TICK, PROC_REF(on_reagent_tick))
	RegisterSignal(H, COMSIG_MOVABLE_MOVED, PROC_REF(update_water_mobility))
	RegisterSignal(H, COMSIG_MOB_CLIENT_MOVED, PROC_REF(on_spacewalk_step))

	var/datum/action/cooldown/scent_scan/aquatic/scent = new()
	scent.Grant(H)
	var/datum/action/cooldown/scent_tracking/track = new()
	track.Grant(H)

	if(!H.has_quirk(/datum/quirk/sharpclaws))
		H.add_quirk(/datum/quirk/sharpclaws)

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
	..()
	if(!istype(H))
		return

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
		if(A.density)
			return TRUE

	return FALSE

/datum/species/aquatic/proc/on_nose_boop(mob/living/carbon/human/source, mob/living/carbon/helper)
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

/datum/species/aquatic/create_pref_unique_perks()
	var/list/perks = list()
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_TOOTH,
		SPECIES_PERK_NAME = "Sharp Claws",
		SPECIES_PERK_DESC = "Your claws are sharp enough to deal meaningful damage without weapons. In melee, you hit harder and tear through weak materials more easily.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_PERSON_WALKING,
		SPECIES_PERK_NAME = "Like a Fish in Water",
		SPECIES_PERK_DESC = "You move through space with ease, as if you were swimming.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_HAND,
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
		SPECIES_PERK_ICON = FA_ICON_SHIRT,
		SPECIES_PERK_NAME = "Salty Blood",
		SPECIES_PERK_DESC = "Your blood has elevated salinity - it purges toxins faster, but handles medicine worse.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_ARROW_DOWN,
		SPECIES_PERK_NAME = "Thermoregulation",
		SPECIES_PERK_DESC = "Your body handles cold worse, but tolerates heat better.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_ARROW_DOWN,
		SPECIES_PERK_NAME = "Sensitive Snout",
		SPECIES_PERK_DESC = "Your snout is more sensitive to hits and even occasional light touches.",
	))
	return perks
