/datum/action/cooldown/spell/pointed/mind_gate
	name = "Mind Gate"
	desc = "Deals you 20 brain damage and the target suffers a hallucination, \
			is left confused for 10 seconds, and suffers oxygen loss and brain damage."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mind_gate"

	sound = 'sound/effects/magic/curse.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS

	invocation = "Op'n y'r m'd."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	cast_range = 6

	active_msg = "You prepare to open your mind..."

/datum/action/cooldown/spell/pointed/mind_gate/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)

/datum/action/cooldown/spell/pointed/mind_gate/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/mind_gate/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("Your mind feels closed."))
		to_chat(owner, span_warning("Their mind doesn't swing open, but neither does yours."))
		return FALSE

	var/base_duration = 5 SECONDS
	var/sanity_factor = 1
	if(cast_on.mob_mood)
		sanity_factor = 1 + ((SANITY_MAXIMUM - cast_on.mob_mood.sanity) / (SANITY_MAXIMUM - SANITY_INSANE))
		sanity_factor = clamp(sanity_factor, 0.5, 2)

	var/effect_duration = base_duration * sanity_factor

	to_chat(cast_on, span_userdanger("THE MOON SMILES UPON YOU!"))
	cast_on.balloon_alert(cast_on, "the moon smiles...")

	cast_on.adjust_temp_blindness(effect_duration)
	cast_on.adjust_silence(effect_duration)
	cast_on.AdjustKnockdown(min(effect_duration, 4 SECONDS))

	cast_on.adjust_confusion(10 SECONDS)
	cast_on.adjust_oxy_loss(30)
	cast_on.cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/body), "Mind gate, cast by [owner]")
	cast_on.cause_hallucination(/datum/hallucination/delusion/preset/heretic/gate, "Caused by mindgate")
	cast_on.adjust_organ_loss(ORGAN_SLOT_BRAIN, 30)

	if(cast_on.mob_mood)
		cast_on.mob_mood.adjust_sanity(-15)

	cast_on.add_mood_event("moon_smile", /datum/mood_event/moon_smile)
	new /obj/effect/temp_visual/moon_ringleader(get_turf(cast_on))

	var/mob/living/living_owner = owner
	living_owner.adjust_organ_loss(ORGAN_SLOT_BRAIN, 20, 140)

	var/datum/status_effect/heretic_passive/moon/moon_passive = living_owner.has_status_effect(/datum/status_effect/heretic_passive/moon)
	if(moon_passive?.passive_level >= 3)
		var/obj/item/organ/brain/owner_brain = living_owner.get_organ_slot(ORGAN_SLOT_BRAIN)
		if(owner_brain)
			owner_brain.apply_organ_damage(-15)

	return TRUE
