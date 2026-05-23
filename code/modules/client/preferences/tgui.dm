GLOBAL_LIST_INIT(tgui_window_themes, list(
	"nanotrasen" = "Nanotrasen",
	"midnight" = "Midnight",
	"neutral" = "Neutral",
	"syndicate" = "Syndicate",
	"wizard" = "Wizard",
	"retro" = "Retro",
	"paper" = "Paper",
	"hackerman" = "Hackerman",
	"howlingvoid" = "Howling Void",
	"admin" = "Admin",
	"clockwork" = "Clockwork",
))

GLOBAL_LIST_INIT(tgui_window_backdrops, list(
	"nanotrasen" = "Nanotrasen",
	"neutral" = "Neutral",
	"syndicate" = "Syndicate",
	"wizard" = "Wizard",
	"admin" = "Admin",
	"spooky" = "Spooky",
	"none" = "None",
))

/proc/refresh_client_tgui_appearance(client/client)
	for(var/datum/tgui/tgui as anything in SStgui.all_uis)
		if(tgui.user?.client != client)
			continue
		tgui.send_full_update(force = TRUE, always_instant = TRUE)

// Determines if input boxes are in tgui or old fashioned
/datum/preference/toggle/tgui_input
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tgui_input"
	savefile_identifier = PREFERENCE_PLAYER

/// Large button preference. Error text is in tooltip.
/datum/preference/toggle/tgui_input_large
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tgui_input_large"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/tgui_input_large/apply_to_client(client/client, value)
	for (var/datum/tgui/tgui as anything in client.mob?.tgui_open_uis)
		// Force it to reload either way
		tgui.send_full_update(client.mob)

/// Swapped button state - sets buttons to SS13 traditional SUBMIT/CANCEL
/datum/preference/toggle/tgui_input_swapped
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tgui_input_swapped"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/tgui_input_swapped/apply_to_client(client/client, value)
	for (var/datum/tgui/tgui as anything in client.mob?.tgui_open_uis)
		// Force it to reload either way
		tgui.send_full_update(client.mob)

/// Changes layout in some UI's, like Vending, Smartfridge etc. Making it list or grid
/datum/preference/choiced/tgui_layout
	savefile_key = "tgui_layout"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/tgui_layout/init_possible_values()
	return list(
		TGUI_LAYOUT_GRID,
		TGUI_LAYOUT_LIST,
	)

/datum/preference/choiced/tgui_layout/create_default_value()
	return TGUI_LAYOUT_LIST

/datum/preference/choiced/tgui_layout/apply_to_client(client/client, value)
	for (var/datum/tgui/tgui as anything in client.mob?.tgui_open_uis)
		// Force it to reload either way
		tgui.update_static_data(client.mob)

/datum/preference/choiced/tgui_layout/smartfridge
	savefile_key = "tgui_layout_smartfridge"

/datum/preference/choiced/tgui_layout/create_default_value()
	return TGUI_LAYOUT_GRID

/datum/preference/toggle/tgui_lock
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tgui_lock"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/tgui_lock/apply_to_client(client/client, value)
	for (var/datum/tgui/tgui as anything in client.mob?.tgui_open_uis)
		// Force it to reload either way
		tgui.update_static_data(client.mob)

/// Light mode for tgui say
/datum/preference/toggle/tgui_say_light_mode
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tgui_say_light_mode"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/tgui_say_light_mode/apply_to_client(client/client)
	client.tgui_say?.load()

/datum/preference/choiced/tgui_window_appearance
	abstract_type = /datum/preference/choiced/tgui_window_appearance
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/tgui_window_appearance/compile_constant_data()
	var/list/data = ..()
	data["display_names"] = get_display_names().Copy()
	return data

/datum/preference/choiced/tgui_window_appearance/apply_to_client(client/client, value)
	refresh_client_tgui_appearance(client)

/datum/preference/choiced/tgui_window_appearance/proc/get_display_names()
	RETURN_TYPE(/list)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("get_display_names() was not implemented for [type]!")

/datum/preference/choiced/tgui_window_theme
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tgui_window_theme"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/tgui_window_theme/init_possible_values()
	return assoc_to_keys(GLOB.tgui_window_themes)

/datum/preference/choiced/tgui_window_theme/create_default_value()
	return "howlingvoid"

/datum/preference/choiced/tgui_window_theme/proc/get_display_names()
	RETURN_TYPE(/list)
	return GLOB.tgui_window_themes

/datum/preference/choiced/tgui_window_backdrop
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tgui_window_backdrop"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/tgui_window_backdrop/init_possible_values()
	return assoc_to_keys(GLOB.tgui_window_backdrops)

/datum/preference/choiced/tgui_window_backdrop/create_default_value()
	return "nanotrasen"

/datum/preference/choiced/tgui_window_backdrop/proc/get_display_names()
	RETURN_TYPE(/list)
	return GLOB.tgui_window_backdrops

/datum/preference/toggle/ui_scale
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "ui_scale"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = TRUE

/datum/preference/toggle/ui_scale/apply_to_client(client/client, value)
	if(!istype(client))
		return

	INVOKE_ASYNC(client, TYPE_VERB_REF(/client, refresh_tgui))
	client.tgui_say?.load()
