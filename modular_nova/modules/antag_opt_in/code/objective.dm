/datum/objective
	/// The default opt-in level for target preference filtering.
	var/default_opt_in_level = OPT_IN_YES_KILL
	/// If TRUE, this objective prefers targets whose round-removal setting accepts this objective.
	var/check_antag_opt_in = FALSE

/// Simple getter for [default_opt_in_level]. Use for custom behavior.
/datum/objective/proc/get_opt_in_level(datum/mind/target_mind)
	return default_opt_in_level

/// Returns whether this objective should prefer opted-in targets.
/datum/objective/proc/should_check_antag_opt_in()
	if(!check_antag_opt_in || CONFIG_GET(flag/disable_antag_opt_in_preferences))
		return FALSE
	if(owner?.has_antag_datum(/datum/antagonist/heretic))
		return FALSE
	for(var/datum/mind/objective_owner as anything in get_owners())
		if(objective_owner?.has_antag_datum(/datum/antagonist/heretic))
			return FALSE
	return TRUE

/// Enables preference filtering for this objective instance.
/datum/objective/proc/enable_antag_opt_in_check()
	check_antag_opt_in = TRUE
	return src

/// Returns whether or not our opt in levels/variables are correct for the target. If true, they can be picked as a target.
/datum/objective/proc/opt_in_valid(datum/mind/target_mind)
	if(isnull(target_mind))
		return FALSE
	return (get_opt_in_level(target_mind) <= target_mind.get_target_opt_in_level())

// ROUND REMOVE
/datum/objective/maroon
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE
	check_antag_opt_in = TRUE

/datum/objective/assassinate/paradox_clone
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE
	check_antag_opt_in = TRUE

/datum/objective/capture
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE
	check_antag_opt_in = TRUE

/datum/objective/absorb
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE
	check_antag_opt_in = TRUE

/datum/objective/absorb_changeling
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE
	check_antag_opt_in = TRUE

/datum/objective/sacrifice
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE
	check_antag_opt_in = TRUE

/datum/objective/debrain
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE
	check_antag_opt_in = TRUE

/datum/objective/jailbreak/detain
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE
	check_antag_opt_in = TRUE

// KILL

/datum/objective/assassinate
	default_opt_in_level = OPT_IN_YES_KILL

/datum/objective/destroy
	default_opt_in_level = OPT_IN_YES_KILL

/datum/objective/mutiny
	default_opt_in_level = OPT_IN_YES_KILL

// TEMP

/datum/objective/protect
	default_opt_in_level = OPT_IN_YES_TEMP

/datum/objective/protect/nonhuman
	default_opt_in_level = OPT_IN_YES_TEMP

/datum/objective/steal_n_of_type
	default_opt_in_level = OPT_IN_YES_TEMP

/datum/objective/steal
	default_opt_in_level = OPT_IN_YES_TEMP

/datum/objective/escape/escape_with_identity
	default_opt_in_level = OPT_IN_YES_TEMP

/datum/objective/jailbreak
	default_opt_in_level = OPT_IN_YES_TEMP

/datum/objective/contract
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE
	check_antag_opt_in = TRUE
