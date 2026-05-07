/datum/scripture/create_structure/sigil_submission
	name = "Sigil of Submission"
	desc = "Summons a sigil that converts a living prisoner to the faith of Ratvar after they remain on top of it."
	tip = "Convert restrained prisoners."
	button_icon_state = "Sigil of Submission"
	power_cost = 300
	invocation_time = 5 SECONDS
	invocation_text = list("Relax, animal...", "for I shall show you the truth.")
	summoned_structure = /obj/structure/destructible/clockwork/sigil/submission
	cogs_required = 1
	category = SPELLTYPE_SERVITUDE
