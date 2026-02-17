/datum/species/ghoul
	// Keep core ghoul identity, but pivot into carrion-adapted survivors.
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_EASYDISMEMBER,
		TRAIT_EASILY_WOUNDED,
		TRAIT_LITERATE,
		TRAIT_MUTANT_COLORS,
		TRAIT_FIXED_MUTANT_COLORS,
		TRAIT_STRONG_STOMACH,
		TRAIT_VIRUS_RESISTANCE,
	)

/datum/species/ghoul/handle_radiation(mob/living/carbon/human/source, time_since_irradiated, seconds_per_tick)
	// Ghouls convert irradiation stress into regeneration instead of suffering mutation collapse.
	var/need_mob_update = FALSE
	need_mob_update += source.adjust_tox_loss(-0.8 * seconds_per_tick, updating_health = FALSE, forced = TRUE)
	need_mob_update += source.adjust_brute_loss(-0.45 * seconds_per_tick, updating_health = FALSE)
	need_mob_update += source.adjust_fire_loss(-0.45 * seconds_per_tick, updating_health = FALSE)
	need_mob_update += source.adjust_oxy_loss(-0.35 * seconds_per_tick, updating_health = FALSE, forced = TRUE)
	if(need_mob_update)
		source.updatehealth()

/datum/species/ghoul/create_pref_unique_perks()
	var/list/perks = list()
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "biohazard",
		SPECIES_PERK_NAME = "Carrion Eater",
		SPECIES_PERK_DESC = "Ghouls can stomach rotten and contaminated food with far fewer consequences.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "shield-virus",
		SPECIES_PERK_NAME = "Disease-Hardened",
		SPECIES_PERK_DESC = "Ghoul biology is unusually resistant to most diseases.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "radiation",
		SPECIES_PERK_NAME = "Radiotrophic Flesh",
		SPECIES_PERK_DESC = "While irradiated, ghouls regenerate instead of suffering normal radiation effects.",
	))

	return perks
