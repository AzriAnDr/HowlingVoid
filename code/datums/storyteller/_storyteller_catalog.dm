/datum/storyteller/action_catalog
	var/list/actions = list()
	var/list/actions_by_id = list()

/datum/storyteller/action_catalog/New(list/storyteller_config)
	. = ..()
	for(var/datum/storyteller/action/action_type as anything in subtypesof(/datum/storyteller/action))
		if(action_type == /datum/storyteller/action)
			continue
		if(!initial(action_type.id))
			continue

		var/datum/storyteller/action/action = new action_type
		action.apply_tuning(storyteller_config)
		actions += action
		actions_by_id[action.id] = action

/datum/storyteller/action_catalog/proc/get_action(action_id)
	return actions_by_id[action_id]

/datum/storyteller/action_catalog/proc/get_actions_for_context(action_context, action_polarity)
	RETURN_TYPE(/list)
	var/list/result = list()
	for(var/datum/storyteller/action/action as anything in actions)
		if(action.context != action_context)
			continue
		if(action_polarity && action.polarity != action_polarity)
			continue
		result += action
	return result
