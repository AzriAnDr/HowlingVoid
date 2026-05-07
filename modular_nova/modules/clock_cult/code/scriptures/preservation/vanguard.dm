/datum/scripture/slab/vanguard
	name = "Vanguard"
	use_time = 30 SECONDS
	slab_overlay = "vanguard"
	desc = "Provides the user with 30 seconds of stun immunity, though the slab cannot invoke other scriptures while it is active."
	tip = "Gain temporary stun immunity."
	invocation_text = list("With the Engine's power coursing through me...", "I will stop them in their tracks!")
	invocation_time = 2 SECONDS
	button_icon_state = "Vanguard"
	category = SPELLTYPE_PRESERVATION
	cogs_required = 2
	power_cost = STANDARD_CELL_CHARGE * 0.15

/datum/scripture/slab/vanguard/apply_effects(atom/applied_atom)
	return FALSE

/datum/scripture/slab/vanguard/invoke()
	. = ..()
	invoker.add_traits(list(
		TRAIT_STUNIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_NOLIMBDISABLE,
	), VANGUARD_TRAIT)
	to_chat(invoker, span_notice("You feel like nothing can stop you!"))

/datum/scripture/slab/vanguard/count_down()
	. = ..()
	if(time_left == 5 SECONDS)
		to_chat(invoker, span_userdanger("You start to feel tired again."))

/datum/scripture/slab/vanguard/end_invocation(silent = FALSE)
	if(invoker)
		invoker.remove_traits(list(
			TRAIT_STUNIMMUNE,
			TRAIT_PUSHIMMUNE,
			TRAIT_NOLIMBDISABLE,
		), VANGUARD_TRAIT)
		to_chat(invoker, span_warning("You feel the last of the energy from the [invoking_slab] leave you."))

	return ..()
