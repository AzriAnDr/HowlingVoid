/datum/actionspeed_modifier/teshari_technical_aptitude
	id = ACTIONSPEED_ID_HOWLING_TESHARI_TECH_APTITUDE
	variable = TRUE

/datum/species/teshari/on_species_gain(mob/living/carbon/human/new_teshari, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if(!istype(new_teshari))
		return

	// Teshari are naturally fast and precise with interaction-heavy work.
	new_teshari.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/teshari_technical_aptitude, multiplicative_slowdown = -0.12)

/datum/species/teshari/on_species_loss(mob/living/carbon/C, datum/species/new_species, pref_load)
	. = ..()
	if(!istype(C, /mob/living/carbon/human))
		return

	var/mob/living/carbon/human/former_teshari = C
	former_teshari.remove_actionspeed_modifier(ACTIONSPEED_ID_HOWLING_TESHARI_TECH_APTITUDE)

/datum/species/teshari/get_species_description()
	return "Teshari are lightweight avian sophonts with fast reflexes, compact bodies, and strong adaptation to colder climates."

/datum/species/teshari/get_species_lore()
	return list(
		"Teshari communities are often organized around close-knit flocks, practical cooperation, and technical skill.",
		"Their physiology favors lower temperatures and agility, while heat and prolonged high-temperature exposure are more dangerous for them.",
		"Their small frame helps them navigate tight spaces, and many teshari are known for quick hands and precise tool use.",
	)

/datum/species/teshari/create_pref_unique_perks()
	. = ..()
	. += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Small Frame",
			SPECIES_PERK_DESC = "Teshari can slip through spaces that larger species cannot, making repositioning and escape easier.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "snowflake",
			SPECIES_PERK_NAME = "Cold-Adapted",
			SPECIES_PERK_DESC = "Teshari tolerate cold environments better than baseline humans.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "screwdriver-wrench",
			SPECIES_PERK_NAME = "Technical Aptitude",
			SPECIES_PERK_DESC = "Teshari perform most interaction-based actions about 12% faster.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "ear-listen",
			SPECIES_PERK_NAME = "Sensitive Hearing",
			SPECIES_PERK_DESC = "Teshari can pick up quieter sounds better than many other species.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Heat Fragility",
			SPECIES_PERK_DESC = "Teshari are more vulnerable to heat and overheat faster in hot environments.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "drumstick-bite",
			SPECIES_PERK_NAME = "Sensitive Diet",
			SPECIES_PERK_DESC = "Teshari strongly prefer meat/raw foods and tend to dislike grain-heavy or gross meals.",
		),
	)
