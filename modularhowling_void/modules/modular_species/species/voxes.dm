/datum/actionspeed_modifier/vox_quickhands
	id = ACTIONSPEED_ID_HOWLING_VOX_QUICKHANDS
	variable = TRUE

/datum/species/vox/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	if(!istype(H))
		return

	// Vox perform interaction-based actions faster across the board.
	H.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/vox_quickhands, multiplicative_slowdown = -0.2)
	// Better resistance against stun batons and taser-style control weapons.
	ADD_TRAIT(H, TRAIT_BATON_RESISTANCE, REF(src))

/datum/species/vox/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	if(!istype(H))
		return

	H.remove_actionspeed_modifier(ACTIONSPEED_ID_HOWLING_VOX_QUICKHANDS)
	REMOVE_TRAIT(H, TRAIT_BATON_RESISTANCE, REF(src))

/datum/species/vox/create_pref_unique_perks()
	. = ..()
	. += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Quick Hands",
			SPECIES_PERK_DESC = "Vox complete most interaction-based actions around 20% faster.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-halved",
			SPECIES_PERK_NAME = "Shock-Hardened",
			SPECIES_PERK_DESC = "Vox are more resistant to baton and taser-style disabling effects.",
		),
	)
