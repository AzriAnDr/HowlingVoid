/datum/preference/choiced/menu_chapter
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_identifier = PREFERENCE_PLAYER
	savefile_key = "menu_chapter"

/datum/preference/choiced/menu_chapter/init_possible_values()
	return list("ironHeart", "sisterRay", "jesusWept", "crossToBear", "molesHamsters")

/datum/preference/choiced/menu_chapter/create_default_value()
	return "sisterRay"

/datum/preference/choiced/menu_chapter/apply_to_client(client/client, value)
	return
