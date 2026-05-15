/datum/quirk/touched_by_cosmos
	name = "Touched by cosmos"
	desc = "You have become one with the cosmos, making voidwalker attacks less effective against you at the cost of slightly more physical and burn damage."
	value = 8
	gain_text = ""
	lose_text = ""
	medical_record_text = "They have a stable cosmic neural pattern and glass-like tissue fragility."
	icon = FA_ICON_SHUTTLE_SPACE

/datum/quirk/touched_by_cosmos/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.gain_trauma(/datum/brain_trauma/voided_quirk, TRAUMA_RESILIENCE_ABSOLUTE)

	var/datum/brain_trauma/voided_quirk/cosmos_quirk = human_holder.has_trauma_type(/datum/brain_trauma/voided_quirk, TRAUMA_RESILIENCE_ABSOLUTE)
	if(!cosmos_quirk)
		return

	cosmos_quirk.space_color = client_source?.prefs?.read_preference(/datum/preference/color/space_color) || COLOR_WHITE
	cosmos_quirk.apply_effects()

/datum/quirk/touched_by_cosmos/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.cure_trauma_type(/datum/brain_trauma/voided_quirk, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk_constant_data/touched_by_cosmos
	associated_typepath = /datum/quirk/touched_by_cosmos
	customization_options = list(/datum/preference/color/space_color)

/datum/preference/color/space_color
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "voidwalker_space_color"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	should_update_preview = TRUE

/datum/preference/color/space_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/space_color/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE

	return /datum/quirk/touched_by_cosmos::name in preferences.all_quirks

/datum/preference/color/space_color/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	var/datum/brain_trauma/voided_quirk/cosmos_quirk = target.has_trauma_type(/datum/brain_trauma/voided_quirk, TRAUMA_RESILIENCE_ABSOLUTE)
	if(!cosmos_quirk)
		return

	cosmos_quirk.set_space_color(value)
