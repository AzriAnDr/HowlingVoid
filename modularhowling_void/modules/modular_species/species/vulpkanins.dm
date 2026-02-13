/datum/species/vulpkanin
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_MUTANT_COLORS,
		TRAIT_SENSITIVE_HEARING,
		TRAIT_NIGHT_VISION,
		TRAIT_CANINE,
		TRAIT_HARD_SOLES,
		TRAIT_SHARP_CLAWS,
	)
	bodytemp_cold_damage_limit = 228.15
	bodytemp_heat_damage_limit = 323.15

/datum/species/vulpkanin/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	H.physiology.heat_mod *= 1.25
	H.physiology.cold_mod *= 0.729

	if(!H.quirks)
		H.quirks = list()

	var/found_photophobia = FALSE
	var/found_nightvision = FALSE
	for(var/datum/quirk/Q in H.quirks)
		if(istype(Q, /datum/quirk/photophobia))
			found_photophobia = TRUE
		if(istype(Q, /datum/quirk/night_vision))
			found_nightvision = TRUE

	if(!found_photophobia)
		var/datum/quirk/photophobia/P = new()
		P.quirk_holder = H
		H.quirks += P
		P.add(H.client)

	if(!found_nightvision)
		var/datum/quirk/night_vision/N = new()
		N.quirk_holder = H
		H.quirks += N
		N.add(H.client)

	var/obj/item/organ/ears/ears = H.get_organ_slot(ORGAN_SLOT_EARS)
	if(ears)
		var/datum/action/cooldown/spell/teshari_hearing/hearing_action = new
		hearing_action.Grant(H)

	var/datum/action/cooldown/scent_scan/vulp/scent = new()
	scent.Grant(H)
	var/datum/action/cooldown/scent_tracking/track = new()
	track.Grant(H)

/datum/species/vulpkanin/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()

	if(!H)
		return

	H.physiology.heat_mod /= 1.25
	H.physiology.cold_mod /= 0.729

/datum/species/vulpkanin/create_pref_unique_perks()
	var/list/to_add = list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_MOON,
			SPECIES_PERK_NAME = "Night Vision",
			SPECIES_PERK_DESC = "Vulps can see better in the dark than humans, but bright light dazzles them more.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_HEADPHONES_SIMPLE,
			SPECIES_PERK_NAME = "Keen Hearing",
			SPECIES_PERK_DESC = "Vulps hear better. You can pick up even the quietest sounds, but your ears are also more sensitive.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_HEADPHONES_SIMPLE,
			SPECIES_PERK_NAME = "Keen Smell",
			SPECIES_PERK_DESC = "Vulps have an excellent sense of smell. You can sniff for fresh nearby trails, track who left prints, and even detect reagents in containers.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_ANGRY,
			SPECIES_PERK_NAME = "Fur",
			SPECIES_PERK_DESC = "You handle cold well, but heat is harder for you. Also, fur burns very well.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_LINES_LEANING,
			SPECIES_PERK_NAME = "Sharp Claws",
			SPECIES_PERK_DESC = "Vulps have very sharp claws.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_PERSON_RUNNING,
			SPECIES_PERK_NAME = "Soft Paw Pads",
			SPECIES_PERK_DESC = "You feel comfortable without shoes.",
		),
	)

	return to_add
