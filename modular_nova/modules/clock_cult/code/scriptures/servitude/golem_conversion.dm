/datum/scripture/transform_to_golem
	name = "Ascend Form"
	desc = "Ascend your form into that of a clockwork golem, gaining innate armor, environmental immunity, and faster invocation for most scriptures."
	tip = "Become a clockwork golem."
	button_icon_state = "Spatial Warp"
	power_cost = STANDARD_CELL_CHARGE * 0.5
	invocation_time = 15 SECONDS
	invocation_text = list("My form is weak...", "It must ascend...", "To that of clockwork.")
	cogs_required = 3
	category = SPELLTYPE_SERVITUDE

/datum/scripture/transform_to_golem/check_special_requirements(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(GLOB.charged_anchoring_crystals < ANCHORING_CRYSTALS_TO_SUMMON)
		to_chat(invoker, span_warning("The Ark still needs [ANCHORING_CRYSTALS_TO_SUMMON] charged anchoring crystals before servants can ascend."))
		return FALSE

	if(!ishuman(invoker))
		to_chat(invoker, span_warning("This scripture can only be used by humanoid servants."))
		return FALSE

	if(is_species(invoker, /datum/species/golem/clockwork))
		to_chat(invoker, span_notice("You are already a clockwork golem!"))
		return FALSE

	return TRUE

/datum/scripture/transform_to_golem/invoke_success()
	var/mob/living/carbon/human/human_servant = invoker
	human_servant.set_species(/datum/species/golem/clockwork)
	human_servant.update_body(TRUE)
	human_servant.update_mutations_overlay()
	human_servant.visible_message(
		span_brass("[human_servant]'s body locks and reforges into living brass!"),
		span_brass("<b>Your frail form is remade into living brass.</b>"),
		visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
	)
