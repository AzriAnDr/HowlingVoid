/datum/preference/choiced/interface_language
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_identifier = PREFERENCE_PLAYER
	savefile_key = "interface_language"

/datum/preference/choiced/interface_language/init_possible_values()
	return list("english", "russian")

/datum/preference/choiced/interface_language/create_default_value()
	return "english"

/datum/preference/choiced/interface_language/apply_to_client(client/client, value)
	return
