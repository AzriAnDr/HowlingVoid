/datum/species/aquatic
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_WATER_BREATHING,
		TRAIT_MUTANT_COLORS,
		TRAIT_SHARP_CLAWS,
	)

	/// Store base metabolism value per mob and restore it safely on species loss.
	var/list/original_metabolism_efficiency = list()

/datum/species/aquatic/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	..()
	if(!istype(H))
		return

	original_metabolism_efficiency[H] = H.metabolism_efficiency
	if(H.reagents)
		RegisterSignal(H.reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_reagents_updated))
	update_metabolism_efficiency(H)

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

	if(has_medicine || has_toxin || has_drug || has_alcohol)
		H.metabolism_efficiency = original * 6.0
		return

	H.metabolism_efficiency = original

/datum/species/aquatic/proc/check_water_slowdown(mob/living/aquatic)
	SIGNAL_HANDLER

	var/turf/open/turfy = aquatic.loc

	if(!istype(turfy, /turf/open/water))
		return

	aquatic.remove_movespeed_modifier(/datum/movespeed_modifier/turf_slowdown)
