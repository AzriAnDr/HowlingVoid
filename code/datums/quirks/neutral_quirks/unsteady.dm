/datum/quirk/unsteady
	name = "Unsteady"
	desc = "You are easy to knock down or very easy to startle, and fall often when being hurt."
	icon = FA_ICON_PERSON_FALLING_BURST
	value = 0
	gain_text = span_danger("You feel like you could fall over easily.")
	lose_text = span_notice("You feel steady again.")
	medical_record_text = "The patient finds it remarkably easy to fall over due to external influence."

	var/unsteady_damagethreshold = UNSTEADY_DEFAULT_DAMAGETHRESHOLD
	var/unsteady_hurtchance = UNSTEADY_DEFAULT_DAMAGECHANCE
	var/unsteady_stunlength = UNSTEADY_DEFAULT_STUNLENGTH

/datum/quirk_constant_data/unsteady
	associated_typepath = /datum/quirk/unsteady
	customization_options = list(
		/datum/preference/numeric/unsteady/unsteady_damagethreshold,
		/datum/preference/numeric/unsteady/unsteady_hurtfactor,
		/datum/preference/numeric/unsteady/unsteady_stunlength,
	)

/datum/quirk/unsteady/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(ouchie))

	var/datum/preferences/client_preferences = client_source?.prefs
	if(!client_preferences)
		return

	unsteady_damagethreshold = client_preferences.read_preference(/datum/preference/numeric/unsteady/unsteady_damagethreshold)
	unsteady_hurtchance = client_preferences.read_preference(/datum/preference/numeric/unsteady/unsteady_hurtfactor)
	unsteady_stunlength = client_preferences.read_preference(/datum/preference/numeric/unsteady/unsteady_stunlength)

/datum/quirk/unsteady/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_APPLY_DAMAGE)

/// Knockdown if all our conditions are met and display a combat message for it.
/datum/quirk/unsteady/proc/ouchie(mob/living/carbon/source, damage, damagetype, def_zone, blocked, wound_bonus, exposed_wound_bonus, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER

	if(damagetype != BRUTE)
		return
	if(damage < unsteady_damagethreshold)
		return
	if(!prob(unsteady_hurtchance))
		return

	if(!source.IsKnockdown())
		source.visible_message(
			span_warning("[source] falls over in a scramble!"),
			span_userdanger("You fall over in a scramble!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
		)

	source.Knockdown(unsteady_stunlength)
