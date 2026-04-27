/**
 * # Opening Blast
 *
 * Lock side knowledge, grants the spell Wave of Desperation.
 * Wave of Desperation can only be cast while restrained, removing restraints and repelling nearby people.
 */
/datum/heretic_knowledge/spell/opening_blast
	name = "Wave Of Desperation"
	desc = "Grants you Wave Of Desperation, a spell which can only be cast while restrained. \
		It removes your restraints, repels and knocks down adjacent people, and applies the Mansus Grasp to everything nearby."
	gain_text = "My shackles undone in dark fury, their feeble bindings crumble before my power."

	action_to_add = /datum/action/cooldown/spell/aoe/wave_of_desperation
	cost = 2
	drafting_tier = 2