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
	/// Quirks injected by this species per mob (key = mob, value = list of quirk typepaths).
	var/tmp/list/species_added_quirks = list()
	/// Species-granted actions, tracked for safe cleanup on species loss.
	var/tmp/list/species_hearing_action = list()
	var/tmp/list/species_scent_scan_action = list()
	var/tmp/list/species_scent_track_action = list()

/datum/species/vulpkanin/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	if(!istype(H))
		return

	. = ..()
	H.physiology.heat_mod *= 1.25
	H.physiology.cold_mod *= 0.729

	var/list/added_quirks = list()
	species_added_quirks[H] = added_quirks

	if(!H.has_quirk(/datum/quirk/photophobia))
		if(H.add_quirk(/datum/quirk/photophobia, override_client = H.client, announce = FALSE))
			added_quirks += /datum/quirk/photophobia

	if(!H.has_quirk(/datum/quirk/night_vision))
		if(H.add_quirk(/datum/quirk/night_vision, override_client = H.client, announce = FALSE))
			added_quirks += /datum/quirk/night_vision

	var/datum/action/cooldown/spell/teshari_hearing/old_hearing_action = species_hearing_action[H]
	if(old_hearing_action)
		old_hearing_action.Remove(H)
		qdel(old_hearing_action)
	species_hearing_action[H] = null

	var/datum/action/cooldown/scent_scan/vulp/old_scent = species_scent_scan_action[H]
	if(old_scent)
		old_scent.Remove(H)
		qdel(old_scent)
	species_scent_scan_action[H] = null

	var/datum/action/cooldown/scent_tracking/old_track = species_scent_track_action[H]
	if(old_track)
		old_track.Remove(H)
		qdel(old_track)
	species_scent_track_action[H] = null

	var/obj/item/organ/ears/ears = H.get_organ_slot(ORGAN_SLOT_EARS)
	if(ears)
		var/datum/action/cooldown/spell/teshari_hearing/hearing_action = new
		hearing_action.Grant(H)
		species_hearing_action[H] = hearing_action

	var/datum/action/cooldown/scent_scan/vulp/scent = new()
	scent.Grant(H)
	species_scent_scan_action[H] = scent
	var/datum/action/cooldown/scent_tracking/track = new()
	track.Grant(H)
	species_scent_track_action[H] = track

/datum/species/vulpkanin/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()

	if(!H)
		return

	H.physiology.heat_mod /= 1.25
	H.physiology.cold_mod /= 0.729

	var/list/added_quirks = species_added_quirks[H]
	if(length(added_quirks))
		for(var/quirk_type as anything in added_quirks)
			if(H.has_quirk(quirk_type))
				H.remove_quirk(quirk_type)
	species_added_quirks[H] = null

	var/datum/action/cooldown/spell/teshari_hearing/hearing_action = species_hearing_action[H]
	if(hearing_action)
		hearing_action.Remove(H)
		qdel(hearing_action)
	species_hearing_action[H] = null

	var/datum/action/cooldown/scent_scan/vulp/scent = species_scent_scan_action[H]
	if(scent)
		scent.Remove(H)
		qdel(scent)
	species_scent_scan_action[H] = null

	var/datum/action/cooldown/scent_tracking/track = species_scent_track_action[H]
	if(track)
		track.Remove(H)
		qdel(track)
	species_scent_track_action[H] = null

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
