/datum/species/skrell/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	if(!istype(H))
		return

	RegisterSignal(H, COMSIG_MOVABLE_MOVED, PROC_REF(update_skrell_hydration))
	RegisterSignal(H, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(on_skrell_damage_modifiers))
	update_skrell_hydration(H, null)

/datum/species/skrell/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	if(!istype(H))
		return

	UnregisterSignal(H, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(H, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)
	H.remove_movespeed_modifier(/datum/movespeed_modifier/skrell_hydrated_stride)

/datum/species/skrell/proc/is_skrell_hydrated_tile(atom/location)
	if(!isturf(location))
		return FALSE

	var/turf/check_turf = location
	if(istype(check_turf, /turf/open/water))
		return TRUE
	if(check_turf.liquids && check_turf.liquids.liquid_state >= LIQUID_STATE_WAIST)
		return TRUE

	return FALSE

/datum/species/skrell/proc/update_skrell_hydration(mob/living/carbon/human/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(!istype(source))
		return

	if(is_skrell_hydrated_tile(source.loc))
		source.add_movespeed_modifier(/datum/movespeed_modifier/skrell_hydrated_stride)
	else
		source.remove_movespeed_modifier(/datum/movespeed_modifier/skrell_hydrated_stride)

/datum/species/skrell/proc/on_skrell_damage_modifiers(mob/living/carbon/human/source, list/damage_mods, damage, damagetype, def_zone, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER

	if(!istype(source))
		return
	if(damagetype != BURN)
		return
	if(!is_skrell_hydrated_tile(source.loc))
		return

	// Moist skin handles heating and charring better while hydrated.
	damage_mods += 0.85

/datum/movespeed_modifier/skrell_hydrated_stride
	multiplicative_slowdown = -0.15

/datum/species/skrell/get_species_description()
	return "Skrell are amphibious humanoids with heat-tolerant biology and delicate sensory systems. They perform best when hydrated and struggle in the cold."

/datum/species/skrell/get_species_lore()
	return list(
		"Skrell physiology developed around warm, wet environments, leading to exceptional heat tolerance and specialized internal organs.",
		"Their skin and breathing systems handle humidity and moisture well, letting them keep control and tempo on wet terrain.",
		"Bright flashes and severe cold remain major stress factors for skrell bodies despite their adaptability in many other areas.",
	)

/datum/species/skrell/create_pref_unique_perks()
	var/list/perks = list()
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_DROPLET,
		SPECIES_PERK_NAME = "Hydrated Stride",
		SPECIES_PERK_DESC = "Skrell move faster while standing in sufficiently deep water or liquids.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_FIRE_FLAME_CURVED,
		SPECIES_PERK_NAME = "Moist Barrier",
		SPECIES_PERK_DESC = "While hydrated, skrell take reduced burn damage.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_FLASK,
		SPECIES_PERK_NAME = "Exotic Biochemistry",
		SPECIES_PERK_DESC = "Skrell organs handle toxins and unusual gases differently from baseline humans.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_SNOWFLAKE,
		SPECIES_PERK_NAME = "Cold-Blooded",
		SPECIES_PERK_DESC = "Skrell are notably vulnerable to cold environments and cold gases.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_EYE,
		SPECIES_PERK_NAME = "Light Sensitive",
		SPECIES_PERK_DESC = "Skrell eyes are more sensitive to intense flashes.",
	))
	return perks
