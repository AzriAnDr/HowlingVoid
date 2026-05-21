/datum/preference/choiced/panel_language
	abstract_type = /datum/preference/choiced/panel_language
	savefile_identifier = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	can_randomize = FALSE

/datum/preference/choiced/panel_language/init_possible_values()
	return list("english", "russian")

/datum/preference/choiced/panel_language/create_default_value()
	return "english"

/proc/get_panel_language_preference_path(element)
	switch(lowertext("[element]"))
		if("preferences")
			return /datum/preference/choiced/panel_language/preferences
		if("game_preferences")
			return /datum/preference/choiced/panel_language/game_preferences
		if("interaction")
			return /datum/preference/choiced/panel_language/interaction
		if("antag_info")
			return /datum/preference/choiced/panel_language/antag_info
		if("rnd")
			return /datum/preference/choiced/panel_language/rnd
		if("announce")
			return /datum/preference/choiced/panel_language/announce
		if("storyteller")
			return /datum/preference/choiced/panel_language/storyteller

	return null

/proc/get_panel_language_value(mob/target, element, default_language = "english")
	var/pref_path = get_panel_language_preference_path(element)
	if(isnull(pref_path))
		return default_language

	var/client/target_client = target?.client
	if(!target_client?.prefs)
		return default_language

	var/detected_language = lowertext("[target_client.prefs.read_preference(pref_path)]")
	if(!(detected_language in list("english", "russian")))
		return default_language

	return detected_language

/proc/uses_panel_language(mob/target, element, expected_language = "russian")
	return get_panel_language_value(target, element) == lowertext("[expected_language]")

/proc/build_panel_languages_payload(datum/preferences/preferences)
	if(!preferences)
		return null

	return list(
		"preferences" = preferences.read_preference(/datum/preference/choiced/panel_language/preferences),
		"game_preferences" = preferences.read_preference(/datum/preference/choiced/panel_language/game_preferences),
		"interaction" = preferences.read_preference(/datum/preference/choiced/panel_language/interaction),
		"antag_info" = preferences.read_preference(/datum/preference/choiced/panel_language/antag_info),
		"rnd" = preferences.read_preference(/datum/preference/choiced/panel_language/rnd),
		"announce" = preferences.read_preference(/datum/preference/choiced/panel_language/announce),
		"storyteller" = preferences.read_preference(/datum/preference/choiced/panel_language/storyteller),
	)

/datum/preference/choiced/panel_language/preferences
	savefile_key = "panel_language_preferences"

/datum/preference/choiced/panel_language/preferences/apply_to_client(client/client, value)
	return

/datum/preference/choiced/panel_language/game_preferences
	savefile_key = "panel_language_game_preferences"

/datum/preference/choiced/panel_language/game_preferences/apply_to_client(client/client, value)
	return

/datum/preference/choiced/panel_language/interaction
	savefile_key = "panel_language_interaction"

/datum/preference/choiced/panel_language/interaction/apply_to_client(client/client, value)
	return

/datum/preference/choiced/panel_language/antag_info
	savefile_key = "panel_language_antag_info"

/datum/preference/choiced/panel_language/antag_info/apply_to_client(client/client, value)
	return

/datum/preference/choiced/panel_language/rnd
	savefile_key = "panel_language_rnd"

/datum/preference/choiced/panel_language/rnd/apply_to_client(client/client, value)
	return

/datum/preference/choiced/panel_language/announce
	savefile_key = "panel_language_announce"

/datum/preference/choiced/panel_language/announce/apply_to_client(client/client, value)
	return

/datum/preference/choiced/panel_language/storyteller
	savefile_key = "panel_language_storyteller"

/datum/preference/choiced/panel_language/storyteller/apply_to_client(client/client, value)
	return
