#define MOOD_CATEGORY_PHOTOPHOBIA "photophobia"

/datum/quirk/photophobia
	name = "Photophobia"
	desc = "Bright lights seem to bother you more than others. Maybe it's a medical condition."
	icon = FA_ICON_ARROWS_TO_EYE
	value = -4
	gain_text = span_danger("The safety of light feels off...")
	lose_text = span_notice("Enlightening.")
	medical_record_text = "Patient has acute phobia of light, and insists it is physically harmful."
	medical_symptom_text = "Exhibits heightened sensitivity to bright lights, leading to discomfort and avoidance behaviors."
	hardcore_value = 4
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_TRAUMALIKE
	mail_goodies = list(
		/obj/item/flashlight/flashdark,
		/obj/item/food/grown/mushroom/glowshroom/shadowshroom,
		/obj/item/skillchip/light_remover,
	)

/datum/quirk/photophobia/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(check_eyes))
	RegisterSignal(quirk_holder, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(restore_eyes))
	RegisterSignal(quirk_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_holder_moved))
	update_eyes(quirk_holder.get_organ_slot(ORGAN_SLOT_EYES))

/datum/quirk/photophobia/remove()
	UnregisterSignal(quirk_holder, list(
		COMSIG_CARBON_GAIN_ORGAN,
		COMSIG_CARBON_LOSE_ORGAN,
		COMSIG_MOVABLE_MOVED,))
	quirk_holder.clear_mood_event(MOOD_CATEGORY_PHOTOPHOBIA)
	var/obj/item/organ/eyes/normal_eyes = quirk_holder.get_organ_slot(ORGAN_SLOT_EYES)
	if(istype(normal_eyes))
		normal_eyes.flash_protect = initial(normal_eyes.flash_protect)

/datum/quirk/photophobia/proc/check_eyes(datum/source, obj/item/organ/eyes/sensitive_eyes)
	SIGNAL_HANDLER
	if(!istype(sensitive_eyes))
		return
	update_eyes(sensitive_eyes)

/datum/quirk/photophobia/proc/update_eyes(obj/item/organ/eyes/target_eyes)
	if(!istype(target_eyes))
		return
	target_eyes.flash_protect = max(target_eyes.flash_protect - severity, FLASH_PROTECTION_HYPER_SENSITIVE) // NOVA EDIT CHANGE - ORIGINAL: target_eyes.flash_protect = max(target_eyes.flash_protect - 1, FLASH_PROTECTION_HYPER_SENSITIVE)
	target_eyes.refresh() // NOVA EDIT ADDITION

/datum/quirk/photophobia/proc/restore_eyes(datum/source, obj/item/organ/eyes/normal_eyes)
	SIGNAL_HANDLER
	if(!istype(normal_eyes))
		return
	normal_eyes.flash_protect = initial(normal_eyes.flash_protect)
	normal_eyes.refresh() // NOVA EDIT ADDITION

/datum/quirk/photophobia/proc/on_holder_moved(mob/living/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(quirk_holder.stat != CONSCIOUS || quirk_holder.IsSleeping() || quirk_holder.IsUnconscious())
		return

	if(HAS_TRAIT(quirk_holder, TRAIT_FEARLESS))
		return

	var/mob/living/carbon/human/human_holder = quirk_holder

	if(human_holder.sight & SEE_TURFS)
		return

	var/turf/holder_turf = get_turf(quirk_holder)

	var/lums = holder_turf.get_lumcount()

	var/eye_protection = quirk_holder.get_eye_protection()
	if(lums < LIGHTING_TILE_IS_DARK || eye_protection >= FLASH_PROTECTION_NONE)
		quirk_holder.clear_mood_event(MOOD_CATEGORY_PHOTOPHOBIA)
		return
	quirk_holder.add_mood_event(MOOD_CATEGORY_PHOTOPHOBIA, /datum/mood_event/photophobia)

	#undef MOOD_CATEGORY_PHOTOPHOBIA


// BEGIN NOVA CORE MIGRATION: code/datums/quirks/negative_quirks/photophobia.dm
/datum/quirk/photophobia
	desc = "Bright lights are uncomfortable and upsetting to you for whatever reason. Your eyes are also more sensitive to light in general. This shares a unique interaction with Night Vision."
	/// how much of a flash_protect deficit the quirk inflicts
	var/severity = 1

/datum/quirk/photophobia/add_unique(client/client_source)
	var/sensitivity = client_source?.prefs.read_preference(/datum/preference/choiced/photophobia_severity)
	switch (sensitivity)
		if ("Hypersensitive")
			severity = 2
		if ("Sensitive")
			severity = 1
	var/obj/item/organ/eyes/holder_eyes = quirk_holder.get_organ_slot(ORGAN_SLOT_EYES)
	restore_eyes(holder_eyes) // add_unique() happens after add() so we need to jank reset this to ensure sensitivity is properly applied at roundstart
	check_eyes(holder_eyes)

/datum/quirk_constant_data/photophobia
	associated_typepath = /datum/quirk/photophobia
	customization_options = list(/datum/preference/choiced/photophobia_severity)

/datum/preference/choiced/photophobia_severity
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "photophobia_severity"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/photophobia_severity/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Photophobia" in preferences.all_quirks

/datum/preference/choiced/photophobia_severity/init_possible_values()
	var/list/values = list("Sensitive", "Hypersensitive")
	return values

/datum/preference/choiced/photophobia_severity/apply_to_human(mob/living/carbon/human/target, value)
	return
// END NOVA CORE MIGRATION: code/datums/quirks/negative_quirks/photophobia.dm
