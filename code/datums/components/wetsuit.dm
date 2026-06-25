/// How many wet stacks the clothing's status effect applies to its wearer.
#define STATUS_EFFECT_STACKS 5

/datum/component/wetsuit
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/wetsuit/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(apply_wetsuit_status_effect))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(remove_wetsuit_status_effect))

/datum/component/wetsuit/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
	))

/// Applies the slippery status effect used by wetsuit-style clothing.
/datum/component/wetsuit/proc/apply_wetsuit_status_effect(obj/item/source, mob/living/user, slot)
	if(slot == ITEM_SLOT_HANDS)
		return FALSE

	user.apply_status_effect(/datum/status_effect/grouped/wetsuit, REF(source))

/// Removes the wetsuit status effect.
/datum/component/wetsuit/proc/remove_wetsuit_status_effect(obj/item/source, mob/living/user, slot)
	user.remove_status_effect(/datum/status_effect/grouped/wetsuit, REF(source))

/// The status effect granted by /datum/component/wetsuit.
/datum/status_effect/grouped/wetsuit
	id = "wetsuit"
	alert_type = null
	tick_interval = 5 SECONDS

/datum/status_effect/grouped/wetsuit/tick(seconds_between_ticks)
	owner.set_wet_stacks(stacks = STATUS_EFFECT_STACKS, remove_fire_stacks = FALSE)

#undef STATUS_EFFECT_STACKS

