#define DEFAULT_HOWLING_MENU_CHAPTER "sisterRay"
#define HOWLING_MENU_CHAPTER_SAVEFILE_KEY(chapter) "menu_chapter_" + chapter

/datum/preference/choiced/menu_chapter
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_identifier = PREFERENCE_PLAYER
	savefile_key = HOWLING_MENU_CHAPTER_SAVEFILE_KEY(DEFAULT_HOWLING_MENU_CHAPTER)

/datum/preference/choiced/menu_chapter/init_possible_values()
	return list("ironHeart", "sisterRay", "jesusWept", "crossToBear", "molesHamsters")

/datum/preference/choiced/menu_chapter/create_default_value()
	return DEFAULT_HOWLING_MENU_CHAPTER

/datum/preference/choiced/menu_chapter/apply_to_client(client/client, value)
	return

/datum/preference/choiced/menu_chapter/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	return FALSE

#undef HOWLING_MENU_CHAPTER_SAVEFILE_KEY
#undef DEFAULT_HOWLING_MENU_CHAPTER
