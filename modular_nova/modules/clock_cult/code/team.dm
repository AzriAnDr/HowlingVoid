GLOBAL_DATUM(main_clock_cult, /datum/team/clock_cult)
GLOBAL_VAR_INIT(ratvar_risen, FALSE)

/datum/team/clock_cult
	name = "Clock Cult"
	var/max_human_servants = 8
	var/list/human_servants = list()
	var/list/non_human_servants = list()

/datum/team/clock_cult/add_member(datum/mind/new_member)
	. = ..()
	if(new_member.current && ishuman(new_member.current))
		human_servants |= new_member
	else
		non_human_servants |= new_member

/datum/team/clock_cult/remove_member(datum/mind/member)
	. = ..()
	human_servants -= member
	non_human_servants -= member

/datum/team/clock_cult/roundend_report()
	var/list/parts = list()
	var/list/checked_objectives = list()
	var/failure = FALSE

	if(length(objectives))
		var/count = 1
		for(var/datum/objective/objective as anything in objectives)
			if(objective.check_completion())
				checked_objectives += "<b>Objective #[count]</b>: [objective.explanation_text] [span_greentext("Success!")]"
			else
				checked_objectives += "<b>Objective #[count]</b>: [objective.explanation_text] [span_redtext("Fail.")]"
				failure = TRUE
			count++

	if(failure)
		parts += span_redtext("The clock cult has failed to protect the Ark and summon Ratvar.")
	else
		parts += span_greentext("The clock cult has succeeded. Ratvar's light shall shine forever more!")

	if(length(checked_objectives))
		parts += "<b>The clock cultists' objectives were:</b>"
		parts += checked_objectives

	if(length(members))
		parts += span_header("The clock cultists were:")
		parts += printplayerlist(members)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/clock_cult/proc/setup_objectives()
	if(length(objectives))
		return

	GLOB.main_clock_cult = src

	var/datum/objective/clock_anchoring_crystals/crystals_objective = new
	crystals_objective.team = src
	objectives += crystals_objective

	var/datum/objective/clock_ark/ark_objective = new
	ark_objective.team = src
	objectives += ark_objective

	var/datum/objective/clock_ratvar/ratvar_objective = new
	ratvar_objective.team = src
	objectives += ratvar_objective

/datum/objective/clock_anchoring_crystals

/datum/objective/clock_anchoring_crystals/New()
	. = ..()
	update_explanation_text()

/datum/objective/clock_anchoring_crystals/update_explanation_text()
	var/plural = ANCHORING_CRYSTALS_TO_SUMMON > 1
	explanation_text = "Summon and protect [ANCHORING_CRYSTALS_TO_SUMMON] Anchoring Crystal[plural ? "s" : ""] until [plural ? "they are" : "it is"] fully charged."

/datum/objective/clock_anchoring_crystals/check_completion()
	return GLOB.charged_anchoring_crystals >= ANCHORING_CRYSTALS_TO_SUMMON || completed

/datum/objective/clock_ark
	explanation_text = "Construct and protect the Ark of the Clockwork Justiciar after the Anchoring Crystals are charged."

/datum/objective/clock_ark/check_completion()
	return GLOB.clock_ark || GLOB.ratvar_risen || completed

/datum/objective/clock_ratvar
	explanation_text = "Open the Ark and protect it until Ratvar arrives."

/datum/objective/clock_ratvar/check_completion()
	return GLOB.ratvar_risen || completed
