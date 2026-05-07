/datum/scripture/create_structure/stargazer
	name = "Stargazer"
	desc = "Creates a stargazer that can enchant weapons and protective garments."
	tip = "Empower armaments."
	button_icon_state = "Stargazer"
	power_cost = 400
	invocation_time = 1 MINUTES
	invocation_text = list("The light of Engine shall empower my armaments!")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/stargazer
	cogs_required = 2
	category = SPELLTYPE_STRUCTURES
