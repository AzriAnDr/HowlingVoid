// Realignment. It's like Fleshmend but solely for stamina damage and stuns. Sec meta
/datum/action/cooldown/spell/realignment
	name = "Realignment"
	desc = "Realign yourself, rapidly regenerating stamina and becoming immune to stuns, knockdowns, sleep and slowdowns. \
		All leg restraints (bolas, traps, dragnet) are removed on cast and cannot be reapplied while active. \
		You cannot attack while realigning. Can be casted multiple times in short succession, but each cast lengthens the cooldown."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/hud/implants.dmi'
	button_icon_state = "adrenal"
	// sound = 'sound/effects/magic/whistlereset.ogg' I have no idea why this was commented out

	school = SCHOOL_FORBIDDEN
	cooldown_time = 78 SECONDS
	cooldown_reduction_per_rank = -6 SECONDS // we're not a wizard spell but we use the levelling mechanic
	spell_max_level = 10 // we can get up to / over a minute duration cd time

	invocation = "R'S'T."
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

/datum/action/cooldown/spell/realignment/can_cast_spell(feedback = TRUE)
	if(!..(feedback))
		return FALSE
	if(isliving(owner))
		var/mob/living/living_owner = owner
		if(HAS_TRAIT_FROM(living_owner, TRAIT_INCAPACITATED, STAMINA))
			if(feedback)
				to_chat(living_owner, span_warning("You are too exhausted to realign."))
			return FALSE
	return TRUE

/datum/action/cooldown/spell/realignment/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/realignment/cast(mob/living/cast_on)
	. = ..()
	cast_on.apply_status_effect(/datum/status_effect/realignment)
	to_chat(cast_on, span_notice("We begin to realign ourselves."))

/datum/action/cooldown/spell/realignment/after_cast(atom/cast_on)
	. = ..()
	// With every cast, our spell level increases for a short time, which goes back down after a period
	// and with every spell level, the cooldown duration of the spell goes up
	if(level_spell())
		var/reduction_timer = max(cooldown_time * spell_max_level * 0.5, 1.5 MINUTES)
		addtimer(CALLBACK(src, PROC_REF(delevel_spell)), reduction_timer)

/datum/action/cooldown/spell/realignment/get_spell_title()
	switch(spell_level)
		if(1, 2)
			return "Hasty " // Hasty Realignment
		if(3, 4)
			return "" // Realignment
		if(5, 6, 7)
			return "Slowed " // Slowed Realignment
		if(8, 9, 10)
			return "Laborious " // Laborious Realignment (don't reach here)

	return ""

/datum/status_effect/realignment
	id = "realigment"
	status_type = STATUS_EFFECT_REFRESH
	duration = 15 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/realignment
	tick_interval = 0.2 SECONDS
	show_duration = TRUE
	///Traits to add/remove
	var/list/realignment_traits = list(TRAIT_BATON_RESISTANCE, TRAIT_PACIFISM, TRAIT_STUNIMMUNE, TRAIT_SLEEPIMMUNE, TRAIT_IGNORESLOWDOWN)

/datum/status_effect/realignment/get_examine_text()
	return span_notice("[owner.p_Theyre()] glowing a soft white.")

/datum/status_effect/realignment/on_apply()
	owner.add_traits(realignment_traits, TRAIT_STATUS_EFFECT(id))
	owner.add_movespeed_mod_immunities(id, /datum/movespeed_modifier/dragnet_trap)
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		var/obj/item/leg_item = carbon_owner.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
		if(leg_item)
			carbon_owner.dropItemToGround(leg_item, TRUE)
	RegisterSignal(owner, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_legcuff_equipped))
	owner.add_filter(id, 2, list("type" = "outline", "color" = "#d6e3e7", "size" = 2))
	var/filter = owner.get_filter(id)
	animate(filter, alpha = 127, time = 1 SECONDS, loop = -1)
	animate(alpha = 63, time = 2 SECONDS)
	return TRUE

/datum/status_effect/realignment/on_remove()
	owner.remove_traits(realignment_traits, TRAIT_STATUS_EFFECT(id))
	UnregisterSignal(owner, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_legcuff_equipped))
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		var/obj/item/leg_item = carbon_owner.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
		if(leg_item)
			carbon_owner.dropItemToGround(leg_item, TRUE)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/dragnet_trap)
	owner.remove_movespeed_mod_immunities(id, /datum/movespeed_modifier/dragnet_trap)
	owner.remove_filter(id)

/// Prevents new leg restraints from being applied during realignment.
/datum/status_effect/realignment/proc/on_legcuff_equipped(mob/living/source, obj/item/item, slot)
	SIGNAL_HANDLER
	if(slot != ITEM_SLOT_LEGCUFFED)
		return
	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob, dropItemToGround), item, TRUE)

/datum/status_effect/realignment/tick(seconds_between_ticks)
	owner.adjust_stamina_loss(-10)
	owner.AdjustAllImmobility(-1 SECONDS)

/atom/movable/screen/alert/status_effect/realignment
	name = "Realignment"
	desc = "You're realigning yourself. You cannot attack, but are rapidly regenerating stamina and are immune to stuns, knockdowns, sleep, and slowdowns. Leg restraints are removed and cannot be applied."
	icon_state = "realignment"
