/datum/vote/storyteller_mode
	name = "Storyteller Mode"
	override_question = "Round Storyteller Selection"
	default_choices = list(
		"Dynamic",
		"Extended",
	)
	count_method = VOTE_COUNT_METHOD_SINGLE
	winner_method = VOTE_WINNER_METHOD_SIMPLE
	contains_vote_in_name = TRUE
	default_message = "Choose how the storyteller should pace the next round."
	announce_start = FALSE

/datum/vote/storyteller_mode/is_config_enabled()
	return SSstoryteller.is_enabled()

/datum/vote/storyteller_mode/can_be_initiated(forced = FALSE)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .
	if(SSticker.current_state != GAME_STATE_PREGAME)
		return "The storyteller mode vote can only be started during pregame."
	return VOTE_AVAILABLE

/datum/vote/storyteller_mode/initiate_vote(initiator, duration)
	. = ..()
	return "[.] Dynamic mode adds a short storyteller preparation phase after the lobby countdown ends. During that setup window, ready, observe, and character changes are temporarily locked while the final round roster is finalized."

/datum/vote/storyteller_mode/finalize_vote(winning_option)
	if(SSstoryteller.manual_round_mode_override)
		SSstoryteller.record_decision("Ignored storyteller mode vote result because an admin manually set the storyteller mode.")
		return
	var/selected_mode = STORYTELLER_ROUND_MODE_DYNAMIC
	if(winning_option == "Extended")
		selected_mode = STORYTELLER_ROUND_MODE_EXTENDED
	selected_mode = SSstoryteller.get_alternating_round_mode(selected_mode)
	SSstoryteller.set_round_mode(selected_mode)
