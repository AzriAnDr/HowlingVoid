/datum/quirk/unsteady
	name = "Unsteady(Неустойчивый)"
	desc = "Вас легко сбить с ног или напугать, и вы часто падаете, когда получаете травму."
	icon = FA_ICON_PERSON_FALLING_BURST
	value = 0 // much like death degradation, effects can be negated in configuration
	gain_text = span_danger("У вас такое чувство, что вы можете легко упасть.")
	lose_text = span_notice("Вы снова чувствуете себя уверенно.")
	medical_record_text = "Пациент обнаруживает, что ему чрезвычайно легко упасть из-за внешнего воздействия."

	// the minimum amount of damage required to knockdown
	var/unsteady_damagethreshold = UNSTEADY_DEFAULT_DAMAGETHRESHOLD
	// chance to knockdown when hit over threshold
	var/unsteady_hurtchance = UNSTEADY_DEFAULT_DAMAGECHANCE
	// length of the knockdown
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

	// update vars on preferences
	var/datum/preferences/client_preferences = client_source?.prefs

	if(!client_preferences)
		return

	unsteady_damagethreshold = client_preferences.read_preference(/datum/preference/numeric/unsteady/unsteady_damagethreshold)
	unsteady_hurtchance = client_preferences.read_preference(/datum/preference/numeric/unsteady/unsteady_hurtfactor)
	unsteady_stunlength = client_preferences.read_preference(/datum/preference/numeric/unsteady/unsteady_stunlength)

/datum/quirk/unsteady/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_APPLY_DAMAGE)

/// Knockdown if all our conditions are met and display a combat message for it
/datum/quirk/unsteady/proc/ouchie(mob/living/carbon/source, damage, damagetype, def_zone, blocked, wound_bonus, exposed_wound_bonus, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER

	if(damagetype != BRUTE)
		return
	if(damage < unsteady_damagethreshold)
		return
	if (!prob(unsteady_hurtchance))
		return

	//don't display the message if already downed
	if(!source.IsKnockdown())
		source.visible_message(
			span_warning("[source] падает в спешке!"),
			span_userdanger("Вы падаете в спешке!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
	)

	// get down on the floor, break it down
	source.Knockdown(unsteady_stunlength)
