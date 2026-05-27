/// Placeholder to check against the SAVE_DATA_EMPTY and SAVE_DATA_OBSOLETE values.
/// _Any_ generated save data version will be zero or a positive integer, so it's only necessary to check against this value for anything negative (error states).
#ifndef SAVE_DATA_NO_ERROR
#define SAVE_DATA_NO_ERROR 0
#endif
/// Typically signifies an empty list, where the savefile is not loaded or the character is new. Will just trigger a regeneration.
#ifndef SAVE_DATA_EMPTY
#define SAVE_DATA_EMPTY -1
#endif
/// The save data is below the accepted minimum and should be reset.
#ifndef SAVE_DATA_OBSOLETE
#define SAVE_DATA_OBSOLETE -2
#endif

/// This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN 32

/// This is the current version, anything below this will attempt to update (if it's not obsolete)
/// You do not need to raise this if you are adding new values that have sane defaults.
/// Only raise this value when changing the meaning/format/name/layout of an existing value
/// where you would want the updater procs below to run
#define SAVEFILE_VERSION_MAX 52

#define IS_DATA_OBSOLETE(version) (version == SAVE_DATA_OBSOLETE)
#define SHOULD_UPDATE_DATA(version) (version >= SAVE_DATA_NO_ERROR && version < SAVEFILE_VERSION_MAX)

/*
SAVEFILE UPDATING/VERSIONING - 'Simplified', or rather, more coder-friendly ~Carn
	This proc checks if the current directory of the savefile S needs updating
	It is to be used by the load_character and load_preferences procs.
	(S.cd == "/" is preferences, S.cd == "/character[integer]" is a character slot, etc)

	if the current directory's version is below SAVEFILE_VERSION_MIN it will simply wipe everything in that directory
	(if we're at root "/" then it'll just wipe the entire savefile, for instance.)

	if its version is below SAVEFILE_VERSION_MAX but above the minimum, it will load data but later call the
	respective update_preferences() or update_character() proc.
	Those procs allow coders to specify format changes so users do not lose their setups and have to redo them again.

	Failing all that, the standard sanity checks are performed. They simply check the data is suitable, reverting to
	initial() values if necessary.
*/
/datum/preferences/proc/check_savedata_version(list/save_data)
	if(!save_data)
		return SAVE_DATA_EMPTY
	var/save_version = save_data["version"]

	if(save_version < SAVEFILE_VERSION_MIN)
		return SAVE_DATA_OBSOLETE
	if(save_version < SAVEFILE_VERSION_MAX)
		return save_version
	return SAVE_DATA_EMPTY

//should these procs get fairly long
//just increase SAVEFILE_VERSION_MIN so it's not as far behind
//SAVEFILE_VERSION_MAX and then delete any obsolete if clauses
//from these procs.
//This only really meant to avoid annoying frequent players
//if your savefile is 3 months out of date, then 'tough shit'.

/datum/preferences/proc/update_preferences(current_version, datum/json_savefile/S)
	if(current_version < 34)
		write_preference(/datum/preference/toggle/auto_fit_viewport, TRUE)

	if(current_version < 35) //makes old keybinds compatible with #52040, sets the new default
		var/newkey = FALSE
		for(var/list/key in key_bindings)
			for(var/bind in key)
				if(bind == "quick_equipbelt")
					key -= "quick_equipbelt"
					key |= "quick_equip_belt"

				if(bind == "bag_equip")
					key -= "bag_equip"
					key |= "quick_equip_bag"

				if(bind == "quick_equip_suit_storage")
					newkey = TRUE
		if(!newkey && !key_bindings["ShiftQ"])
			key_bindings["ShiftQ"] = list("quick_equip_suit_storage")

	if(current_version < 36)
		if(key_bindings["ShiftQ"] == "quick_equip_suit_storage")
			key_bindings["ShiftQ"] = list("quick_equip_suit_storage")

	if(current_version < 37)
		if(read_preference(/datum/preference/numeric/fps) == 0)
			write_preference(GLOB.preference_entries[/datum/preference/numeric/fps], -1)

	if (current_version < 38)
		var/found_block_movement = FALSE

		for (var/list/key in key_bindings)
			for (var/bind in key)
				if (bind == "block_movement")
					found_block_movement = TRUE
					break
			if (found_block_movement)
				break

		if (!found_block_movement)
			LAZYADD(key_bindings["Ctrl"], "block_movement")

	if (current_version < 39)
		LAZYADD(key_bindings["F"], "toggle_combat_mode")
		LAZYADD(key_bindings["4"], "toggle_combat_mode")
	if (current_version < 40)
		LAZYADD(key_bindings["Space"], "hold_throw_mode")

	if (current_version < 41)
		migrate_preferences_to_tgui_prefs_menu()

	if (current_version < 44)
		update_tts_blip_prefs()

/datum/preferences/proc/update_character(current_version, list/save_data)
	if (current_version < 41)
		migrate_character_to_tgui_prefs_menu()

	if (current_version < 42)
		// migrate_body_types(save_data) // NOVA EDIT - This'll fuck up savefiles
		migrate_mentor() // NOVA EDIT - Make mentors alive again

	if (current_version < 43)
		migrate_legacy_sound_toggles(savefile)

	if (current_version < 45)
		migrate_quirk_to_loadout(
			quirk_to_migrate = "Pride Pin",
			new_typepath = /obj/item/clothing/accessory/pride,
			data_to_migrate = list(INFO_RESKIN = save_data?["pride_pin"]),
		)
	if (current_version < 46)
		migrate_boolean_sound_prefs_to_default_volume()
	if (current_version < 47)
		migrate_boolean_sound_prefs_to_default_volume_v2()
	if (current_version < 48)
		migrate_quirk_to_loadout(
			quirk_to_migrate = "Colorist",
			new_typepath = /obj/item/dyespray,
		)
	if(current_version < 49)
		migrate_quirk_to_loadout(
			quirk_to_migrate = "Cyborg Pre-screened dogtag",
			new_typepath = /obj/item/clothing/accessory/dogtag/borg_ready,
		)
	if(current_version < 50)
		migrate_quirk_to_personality(
			quirk_to_migrate = "Extrovert",
			new_typepath = /datum/personality/extrovert,
		)
		migrate_quirk_to_personality(
			quirk_to_migrate = "Introvert",
			new_typepath = /datum/personality/introvert,
		)
		migrate_quirk_to_personality(
			quirk_to_migrate = "Bad Touch",
			new_typepath = /datum/personality/aloof,
		)
		migrate_quirk_to_personality(
			quirk_to_migrate = "Apathetic",
			new_typepath = /datum/personality/apathetic,
		)
		migrate_quirk_to_personality(
			quirk_to_migrate = "Snob",
			new_typepath = /datum/personality/snob,
		)
		migrate_quirk_to_personality(
			quirk_to_migrate = "Spiritual",
			new_typepath = /datum/personality/spiritual,
		)
	if(current_version < 51)
		migrate_felinid_feature_keys(save_data)

	if(current_version < 52)
		migrate_gendered_nonbinary_physique(save_data)

/// checks through keybindings for outdated unbound keys and updates them
/datum/preferences/proc/check_keybindings()
	if(!parent)
		return
	var/list/binds_by_key = get_key_bindings_by_key(key_bindings)
	var/list/notadded = list()
	for (var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		if(kb.name in key_bindings)
			continue // key is unbound and or bound to something

		var/addedbind = FALSE
		key_bindings[kb.name] = list()

		if(parent.hotkeys)
			for(var/hotkeytobind in kb.hotkey_keys)
				if(hotkeytobind == UNBOUND_KEY)
					addedbind = TRUE
				else if(!length(binds_by_key[hotkeytobind])) //Only bind to the key if nothing else is bound
					key_bindings[kb.name] |= hotkeytobind
					addedbind = TRUE
		else
			for(var/classickeytobind in kb.classic_keys)
				if(classickeytobind == UNBOUND_KEY)
					addedbind = TRUE
				else if(!length(binds_by_key[classickeytobind])) //Only bind to the key if nothing else is bound
					key_bindings[kb.name] |= classickeytobind
					addedbind = TRUE

		if(!addedbind)
			notadded += kb
	save_preferences() //Save the players pref so that new keys that were set to UNBOUND_KEY as default are permanently stored
	if(length(notadded))
		addtimer(CALLBACK(src, PROC_REF(announce_conflict), notadded), 5 SECONDS)

/datum/preferences/proc/announce_conflict(list/notadded)
	to_chat(parent, "<span class='warningplain'><b><u>Keybinding Conflict</u></b></span>\n\
					<span class='warningplain'><b>There are new <a href='byond://?src=[REF(src)];open_keybindings=1'>keybindings</a> that default to keys you've already bound. The new ones will be unbound.</b></span>")
	for(var/item in notadded)
		var/datum/keybinding/conflicted = item
		to_chat(parent, span_danger("[conflicted.category]: [conflicted.full_name] needs updating"))

/datum/preferences/proc/load_path(ckey, filename="preferences.json")
	if(!ckey || !load_and_save)
		return
	path = "data/player_saves/[ckey[1]]/[ckey]/[filename]"

/datum/preferences/proc/load_savefile()
	if(load_and_save && !path)
		CRASH("Attempted to load savefile without first loading a path!")
	savefile = new /datum/json_savefile(load_and_save ? path : null)

/datum/preferences/proc/load_preferences()
	if(!savefile)
		stack_trace("Attempted to load the preferences of [parent] without a savefile; did you forget to call load_savefile?")
		load_savefile()
		if(!savefile)
			stack_trace("Failed to load the savefile for [parent] after manually calling load_savefile; something is very wrong.")
			return FALSE

	var/data_validity_integer = check_savedata_version(savefile.get_entry())
	if(load_and_save && IS_DATA_OBSOLETE(data_validity_integer)) //fatal, can't load any data
		var/bacpath = PREFS_BACKUP_PATH(path) //todo: if the savefile version is higher then the server, check the backup, and give the player a prompt to load the backup
		if (fexists(bacpath))
			fdel(bacpath) //only keep 1 version of backup
		fcopy(savefile.path, bacpath) //byond helpfully lets you use a savefile for the first arg.
		return FALSE

	apply_all_client_preferences()

	//general preferences
	lastchangelog = savefile.get_entry("lastchangelog")
	be_special = savefile.get_entry("be_special")
	default_slot = savefile.get_entry("default_slot")
	chat_toggles = savefile.get_entry("chat_toggles")
	toggles = savefile.get_entry("toggles")
	ignoring = savefile.get_entry("ignoring")

	// OOC commendations
	hearted_until = savefile.get_entry("hearted_until")
	if(hearted_until > world.realtime)
		hearted = TRUE
	//favorite outfits
	favorite_outfits = savefile.get_entry("favorite_outfits")

	var/list/parsed_favs = list()
	for(var/typetext in favorite_outfits)
		var/datum/outfit/path = text2path(typetext)
		if(ispath(path)) //whatever typepath fails this check probably doesn't exist anymore
			parsed_favs += path
	favorite_outfits = unique_list(parsed_favs)

	//statpanel favorites
	var/list/statpanel_favorites = savefile.get_entry("statpanel_favorites", get_statpanel_favorites())

	var/list/cleaned_statpanel_favorites = list()
	for(var/favorite in statpanel_favorites)
		if(!istext(favorite))
			continue
		var/cleaned = trim(favorite, STATPANEL_FAVORITE_MAX_LENGTH)
		cleaned = sanitize_text(cleaned, "")
		if(!length(cleaned))
			continue
		cleaned_statpanel_favorites += cleaned
	set_statpanel_favorites(unique_list(cleaned_statpanel_favorites))

	//statpanel tab preferences
	statpanel_tab_order = savefile.get_entry("statpanel_tab_order", statpanel_tab_order)
	statpanel_tab_hidden = savefile.get_entry("statpanel_tab_hidden", statpanel_tab_hidden)
	statpanel_tab_colors = savefile.get_entry("statpanel_tab_colors", statpanel_tab_colors)
	statpanel_tab_structured = savefile.get_entry("statpanel_tab_structured", statpanel_tab_structured)
	statpanel_tab_structured_initialized = savefile.get_entry("statpanel_tab_structured_initialized", statpanel_tab_structured_initialized)
	statpanel_tab_max_buttons_per_row = savefile.get_entry("statpanel_tab_max_buttons_per_row", statpanel_tab_max_buttons_per_row)

	if(!islist(statpanel_tab_order))
		statpanel_tab_order = list()
	if(!islist(statpanel_tab_hidden))
		statpanel_tab_hidden = list()
	if(!islist(statpanel_tab_colors))
		statpanel_tab_colors = list()
	if(!islist(statpanel_tab_structured))
		statpanel_tab_structured = list()
	if(!islist(statpanel_tab_max_buttons_per_row))
		statpanel_tab_max_buttons_per_row = list()
	statpanel_tab_structured_initialized = !!statpanel_tab_structured_initialized

	var/list/clean_statpanel_order = list()
	for(var/tab_name in statpanel_tab_order)
		if(!istext(tab_name))
			continue
		var/cleaned_tab = sanitize_text(trim(tab_name, 64), "")
		if(length(cleaned_tab))
			clean_statpanel_order += cleaned_tab
	statpanel_tab_order = unique_list(clean_statpanel_order)

	var/list/clean_statpanel_hidden = list()
	for(var/hidden_tab in statpanel_tab_hidden)
		if(!istext(hidden_tab))
			continue
		var/cleaned_hidden = sanitize_text(trim(hidden_tab, 64), "")
		if(length(cleaned_hidden))
			clean_statpanel_hidden += cleaned_hidden
	statpanel_tab_hidden = unique_list(clean_statpanel_hidden)

	var/list/clean_statpanel_colors = list()
	for(var/color_tab in statpanel_tab_colors)
		if(!istext(color_tab))
			continue
		var/color_value = statpanel_tab_colors[color_tab]
		if(!istext(color_value))
			continue
		var/cleaned_color_tab = sanitize_text(trim(color_tab, 64), "")
		var/cleaned_color_value = sanitize_text(trim(color_value, 32), "")
		if(length(cleaned_color_tab) && length(cleaned_color_value))
			clean_statpanel_colors[cleaned_color_tab] = cleaned_color_value
	statpanel_tab_colors = clean_statpanel_colors

	var/list/clean_statpanel_structured = list()
	for(var/grouped_tab in statpanel_tab_structured)
		if(!istext(grouped_tab))
			continue
		var/cleaned_grouped = sanitize_text(trim(grouped_tab, 64), "")
		if(length(cleaned_grouped))
			clean_statpanel_structured += cleaned_grouped
	statpanel_tab_structured = unique_list(clean_statpanel_structured)
	if(!statpanel_tab_structured_initialized && length(statpanel_tab_structured))
		statpanel_tab_structured_initialized = TRUE

	var/list/clean_statpanel_max_buttons = list()
	for(var/limited_tab in statpanel_tab_max_buttons_per_row)
		if(!istext(limited_tab))
			continue
		var/cleaned_limited_tab = sanitize_text(trim(limited_tab, 64), "")
		if(!length(cleaned_limited_tab))
			continue
		var/raw_button_limit = statpanel_tab_max_buttons_per_row[limited_tab]
		var/button_limit
		if(isnum(raw_button_limit))
			button_limit = raw_button_limit
		else if(istext(raw_button_limit))
			button_limit = text2num(raw_button_limit)
		if(!isnum(button_limit))
			continue
		button_limit = sanitize_integer(button_limit, 1, 20, 0)
		if(button_limit)
			clean_statpanel_max_buttons[cleaned_limited_tab] = button_limit
	statpanel_tab_max_buttons_per_row = clean_statpanel_max_buttons

	// Custom hotkeys
	key_bindings = savefile.get_entry("key_bindings")

	//try to fix any outdated data if necessary
	if(SHOULD_UPDATE_DATA(data_validity_integer))
		var/bacpath = PREFS_BACKUP_PATH(path) //todo: if the savefile version is higher then the server, check the backup, and give the player a prompt to load the backup
		if (fexists(bacpath))
			fdel(bacpath) //only keep 1 version of backup
		fcopy(savefile.path, bacpath) //byond helpfully lets you use a savefile for the first arg.
		update_preferences(data_validity_integer, savefile)

	check_keybindings() // this apparently fails every time and overwrites any unloaded prefs with the default values, so don't load anything after this line or it won't actually save

	//Sanitize
	lastchangelog = sanitize_text(lastchangelog, initial(lastchangelog))
	default_slot = sanitize_integer(default_slot, 1, max_save_slots, initial(default_slot))
	toggles = sanitize_integer(toggles, 0, SHORT_REAL_LIMIT-1, initial(toggles))
	be_special = sanitize_be_special(SANITIZE_LIST(be_special))
	key_bindings = sanitize_keybindings(key_bindings)
	favorite_outfits = SANITIZE_LIST(favorite_outfits)
	statpanel_tab_order = SANITIZE_LIST(statpanel_tab_order)
	statpanel_tab_hidden = SANITIZE_LIST(statpanel_tab_hidden)
	statpanel_tab_colors = SANITIZE_LIST(statpanel_tab_colors)
	statpanel_tab_structured = SANITIZE_LIST(statpanel_tab_structured)
	statpanel_tab_max_buttons_per_row = SANITIZE_LIST(statpanel_tab_max_buttons_per_row)

	key_bindings_by_key = get_key_bindings_by_key(key_bindings)

	if(SHOULD_UPDATE_DATA(data_validity_integer)) //save the updated version
		var/old_default_slot = default_slot
		var/old_max_save_slots = max_save_slots

		for (var/slot in savefile.get_entry()) //but first, update all current character slots.
			if (copytext(slot, 1, 10) != "character")
				continue
			var/slotnum = text2num(copytext(slot, 10))
			if (!slotnum)
				continue
			max_save_slots = max(max_save_slots, slotnum) //so we can still update byond member slots after they lose memeber status
			default_slot = slotnum
			if (load_character())
				save_character()
		default_slot = old_default_slot
		max_save_slots = old_max_save_slots
		save_preferences()

	return TRUE

/datum/preferences/proc/save_preferences()
	if(!savefile)
		CRASH("Attempted to save the preferences of [parent] without a savefile. This should have been handled by load_preferences()")
	if(path == DEV_PREFS_PATH)
		// Don't save over dev preferences
		return TRUE

	savefile.set_entry("version", SAVEFILE_VERSION_MAX) //updates (or failing that the sanity checks) will ensure data is not invalid at load. Assume up-to-date

	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		if (preference.savefile_identifier != PREFERENCE_PLAYER)
			continue

		if (!(preference.type in recently_updated_keys))
			continue

		recently_updated_keys -= preference.type

		if (preference_type in value_cache)
			write_preference(preference, preference.serialize(value_cache[preference_type]))

	savefile.set_entry("lastchangelog", lastchangelog)
	savefile.set_entry("be_special", be_special)
	savefile.set_entry("default_slot", default_slot)
	savefile.set_entry("toggles", toggles)
	savefile.set_entry("chat_toggles", chat_toggles)
	savefile.set_entry("ignoring", ignoring)
	savefile.set_entry("key_bindings", key_bindings)
	savefile.set_entry("hearted_until", (hearted_until > world.realtime ? hearted_until : null))
	savefile.set_entry("favorite_outfits", favorite_outfits)
	savefile.set_entry("statpanel_favorites", get_statpanel_favorites())
	savefile.set_entry("statpanel_tab_order", statpanel_tab_order)
	savefile.set_entry("statpanel_tab_hidden", statpanel_tab_hidden)
	savefile.set_entry("statpanel_tab_colors", statpanel_tab_colors)
	savefile.set_entry("statpanel_tab_structured", statpanel_tab_structured)
	savefile.set_entry("statpanel_tab_structured_initialized", statpanel_tab_structured_initialized)
	savefile.set_entry("statpanel_tab_max_buttons_per_row", statpanel_tab_max_buttons_per_row)
	savefile.save()
	return TRUE

/datum/preferences/proc/load_character(slot)
	SHOULD_NOT_SLEEP(TRUE)
	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		savefile.set_entry("default_slot", slot)

	var/tree_key = "character[slot]"
	var/list/save_data = savefile.get_entry(tree_key)
	var/data_validity_integer = check_savedata_version(save_data)
	if(IS_DATA_OBSOLETE(data_validity_integer)) //fatal, can't load any data
		return FALSE

	// Read everything into cache
	// Uses priority order as some values may rely on others for creating default values
	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.savefile_identifier != PREFERENCE_CHARACTER)
			continue

		value_cache -= preference.type
		read_preference(preference.type)

	//Character
	randomise = save_data?["randomise"]

	//Load prefs
	job_preferences = save_data?["job_preferences"]

	//Quirks
	all_quirks = save_data?["all_quirks"]
	//Custom emote panel
	custom_emote_panel = SANITIZE_LIST(save_data?["custom_emote_panel"])
	load_character_nova(save_data) // NOVA EDIT ADDITION

	//try to fix any outdated data if necessary
	//preference updating will handle saving the updated data for us.
	if(SHOULD_UPDATE_DATA(data_validity_integer))
		update_character(data_validity_integer, save_data)

	//Sanitize
	randomise = SANITIZE_LIST(randomise)
	job_preferences = SANITIZE_LIST(job_preferences)
	all_quirks = SANITIZE_LIST(all_quirks)
	languages = SANITIZE_LIST(languages) // NOVA EDIT ADDITION
	augments = SANITIZE_LIST(augments) // NOVA EDIT ADDITION

	//Validate job prefs
	for(var/j in job_preferences)
		if(job_preferences[j] != JP_LOW && job_preferences[j] != JP_MEDIUM && job_preferences[j] != JP_HIGH)
			job_preferences -= j

	var/datum/species/species_type = read_preference(/datum/preference/choiced/species) // Howling Void edit
	all_quirks = SSquirks.filter_invalid_quirks(SANITIZE_LIST(all_quirks), SANITIZE_LIST(augments), species_type) // NOVA EDIT CHANGE - AUGMENTS+ - ORIGINAL: all_quirks = SSquirks.filter_invalid_quirks(SANITIZE_LIST(all_quirks)) // Howling Void edit original: all_quirks = SSquirks.filter_invalid_quirks(SANITIZE_LIST(all_quirks), SANITIZE_LIST(augments))
	validate_quirks()
	sanitize_languages() // NOVA EDIT ADDITION

	return TRUE

/datum/preferences/proc/save_character()
	SHOULD_NOT_SLEEP(TRUE)
	if(!path)
		return FALSE
	var/tree_key = "character[default_slot]"
	if(!(tree_key in savefile.get_entry()))
		savefile.set_entry(tree_key, list())
	var/save_data = savefile.get_entry(tree_key)

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.savefile_identifier != PREFERENCE_CHARACTER)
			continue

		if (!(preference.type in recently_updated_keys))
			continue

		recently_updated_keys -= preference.type

		if (preference.type in value_cache)
			write_preference(preference, preference.serialize(value_cache[preference.type]))

	save_data["version"] = SAVEFILE_VERSION_MAX //load_character will sanitize any bad data, so assume up-to-date.

	// This is the version when the random security department was removed.
	// When the minimum is higher than that version, it's impossible for someone to have the "Random" department.
	#if SAVEFILE_VERSION_MIN > 40
	#warn The prefered_security_department check in code/modules/client/preferences/security_department.dm is no longer necessary.
	#endif

	//Character
	save_data["randomise"] = randomise

	//Write prefs
	save_data["job_preferences"] = job_preferences

	//Quirks
	save_data["all_quirks"] = all_quirks
	//Custom emote panel
	save_data["custom_emote_panel"] = custom_emote_panel
	save_character_nova(save_data) // NOVA EDIT ADDITION

	return TRUE

/datum/preferences/proc/switch_to_slot(new_slot, mob/user = null)
	if(new_slot == default_slot) // sanity check, nothing to do here.
		return
	if(isnull(user))
		user = usr
	// SAFETY: `load_character` performs sanitization on the slot number
	if (!load_character(new_slot))
		tainted_character_profiles = TRUE
		randomise_appearance_prefs()
		save_character()

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		preference_middleware.on_new_character(user)

	character_preview_view.update_body()
	if(user)
		update_static_data(user, always_instant = TRUE)
	SSstatpanels.update_job_estimation(ckey = parent.ckey) // update the job estimations with their new char // NOVA EDIT ADDITION

/datum/preferences/proc/remove_current_slot()
	PRIVATE_PROC(TRUE)

	var/closest_slot
	for (var/other_slot in default_slot - 1 to 1 step -1)
		var/save_data = savefile.get_entry("character[other_slot]")
		if (!isnull(save_data))
			closest_slot = other_slot
			break

	if (isnull(closest_slot))
		for (var/other_slot in default_slot + 1 to max_save_slots)
			var/save_data = savefile.get_entry("character[other_slot]")
			if (!isnull(save_data))
				closest_slot = other_slot
				break

	if (isnull(closest_slot))
		stack_trace("remove_current_slot() being called when there are no slots to go to, the client should prevent this")
		return

	savefile.remove_entry("character[default_slot]")
	tainted_character_profiles = TRUE
	switch_to_slot(closest_slot, usr)

/datum/preferences/proc/export_current_slot()
	var/list/save_data = savefile.get_entry("character[default_slot]")
	if(!save_data)
		tgui_alert(usr, "No character to export!", "Export Character")
		return

	var/list/export_data = list()
	export_data["character_data"] = save_data
	export_data["export_version"] = 2

	export_data["key_bindings"] = key_bindings

	var/list/game_prefs = list()
	for(var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		if(preference.savefile_identifier != PREFERENCE_PLAYER)
			continue
		if(is_admin_only_preference(preference))
			continue
		var/pref_value = read_preference(preference.type)
		if(!isnull(pref_value))
			game_prefs[preference.savefile_key] = preference.serialize(pref_value)
	export_data["game_preferences"] = game_prefs

	export_data["toggles"] = toggles
	export_data["chat_toggles"] = chat_toggles
	export_data["be_special"] = be_special

	var/time_string = time2text(world.timeofday, "MMM_DD_YYYY_hh-mm-ss", TIMEZONE_UTC)
	var/file_name = "[parent.ckey]_character_[default_slot]_[time_string].json"
	var/temp_path = "data/preferences_export_working_directory/[file_name]"

	if(!text2file(json_encode(export_data, JSON_PRETTY_PRINT), temp_path))
		tgui_alert(usr, "Failed to export character!", "Export Character")
		return

	to_chat(usr, span_notice("Sending you [file_name], this may take a moment..."))
	DIRECT_OUTPUT(usr, ftp(file(temp_path), file_name))
	fdel(temp_path)

/datum/preferences/proc/is_admin_only_preference(datum/preference/preference)
	if(istype(preference, /datum/preference/color/asay_color))
		return TRUE
	if(istype(preference, /datum/preference/choiced/brief_outfit))
		return TRUE
	if(istype(preference, /datum/preference/toggle/bypass_deadmin_in_centcom))
		return TRUE
	if(istype(preference, /datum/preference/toggle/ghost_roles_as_admin))
		return TRUE
	if(istype(preference, /datum/preference/toggle/comms_notification))
		return TRUE
	if(istype(preference, /datum/preference/toggle/auto_deadmin_on_ready_or_latejoin))
		return TRUE
	return FALSE

/datum/preferences/proc/import_current_slot()
	var/import_file = input(usr, "Select a character export file (.json)", "Import Character") as null|file
	if(!import_file)
		return

	var/list/data
	try
		data = json_decode(file2text(import_file))
	catch(var/exception/e)
		tgui_alert(usr, "The supplied file contains errors: [e]", "Import Character")
		return

	if(!islist(data))
		tgui_alert(usr, "No valid data found in file!", "Import Character")
		return

	var/datum/preference_importer/importer = new(src, data)
	if(!importer.has_valid_data())
		tgui_alert(usr, "No character data found in file!", "Import Character")
		qdel(importer)
		return

	importer.ui_interact(usr)

/proc/get_linked_antag_preference_groups()
	var/static/list/groups = list(
		list(
			ROLE_VAMPIRE,
			ROLE_VAMPIRIC_ACCIDENT,
		),
	)
	return groups

/datum/preferences/proc/sanitize_be_special(list/input_be_special)
	var/list/output = list()

	for (var/role in input_be_special)
		if (role in get_all_antag_flags())
			output += role

	for(var/list/group as anything in get_linked_antag_preference_groups())
		if(!islist(group) || !length(group))
			continue
		if(!length(output & group))
			continue
		output |= group

	return output.len == input_be_special.len ? input_be_special : output

/proc/sanitize_keybindings(value)
	var/list/base_bindings = sanitize_islist(value,list())
	for(var/keybind_name in base_bindings)
		if (!(keybind_name in GLOB.keybindings_by_name))
			base_bindings -= keybind_name
	return base_bindings

#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN
#undef SAVE_DATA_NO_ERROR
#undef SAVE_DATA_EMPTY
//#undef SAVE_DATA_OBSOLETE - NOVA EDIT REMOVAL - Used in [code\modules\admin\preferences_loadverb.dm]
#undef IS_DATA_OBSOLETE
#undef SHOULD_UPDATE_DATA


// BEGIN NOVA CORE MIGRATION: code/modules/client/preferences_savefile.dm
/**
 * This is a cheap replica of the standard savefile version, only used for characters for now.
 * You can't really use the non-modular version, least you eventually want asinine merge
 * conflicts and/or potentially disastrous issues to arise, so here's your own.
 */
#define MODULAR_SAVEFILE_VERSION_MAX 17

#define MODULAR_SAVEFILE_UP_TO_DATE -1

#define VERSION_GENITAL_TOGGLES 1
#define VERSION_BREAST_SIZE_CHANGE 2
#define VERSION_SYNTH_REFACTOR 3
#define VERSION_UNDERSHIRT_BRA_SPLIT 4
#define VERSION_CHRONOLOGICAL_AGE 5
#define VERSION_TG_LOADOUT 6
#define VERSION_INTERNAL_EXTERNAL_ORGANS 7
#define VERSION_SKRELL_HAIR_NAME_UPDATE 8
#define VERSION_TG_EMOTE_SOUNDS 9
#define VERSION_CAT_EARS_DUPES 10
#define VERSION_LOADOUT_PRESETS 12
#define VERSION_EMO_LONG_REMOVAL 13
#define VERSION_TOOLKIT_IMPLANTS 14
#define VERSION_VOCAL_BARKS 15
#define VERSION_FEATHERY_WINGS_FIX 16
#define VERSION_DONK_MIGRATION 17

#define INDEX_UNDERWEAR 1
#define INDEX_BRA 2

/**
 * Checks if the modular side of the savefile is up to date.
 * If the return value is higher than 0, update_character_nova() will be called later.
 */
/datum/preferences/proc/savefile_needs_update_nova(list/save_data)
	var/savefile_version = save_data["modular_version"]

	if(save_data.len && savefile_version < MODULAR_SAVEFILE_VERSION_MAX)
		return savefile_version

	return MODULAR_SAVEFILE_UP_TO_DATE


/// Loads the modular customizations of a character from the savefile
/datum/preferences/proc/load_character_nova(list/save_data)
	if(!save_data)
		save_data = list()

	load_augments(SANITIZE_LIST(save_data["augments"]))

	augment_limb_styles = SANITIZE_LIST(save_data["augment_limb_styles"])
	for(var/key in augment_limb_styles)
		if(!GLOB.robotic_styles_list[augment_limb_styles[key]])
			augment_limb_styles -= key

	body_markings = update_markings(SANITIZE_LIST(save_data["body_markings"]))
	mismatched_customization = save_data["mismatched_customization"]
	allow_advanced_colors = save_data["allow_advanced_colors"]

	alt_job_titles = save_data["alt_job_titles"]

	general_record = sanitize_text(general_record)
	security_record = sanitize_text(security_record)
	medical_record = sanitize_text(medical_record)
	background_info = sanitize_text(background_info)
	exploitable_info = sanitize_text(exploitable_info)

	var/list/save_languages = SANITIZE_LIST(save_data["languages"])
	for(var/language in save_languages)
		var/value = save_languages[language]
		save_languages -= language

		if(istext(language))
			language = _text2path(language)
		save_languages[language] = value
	languages = save_languages

	tgui_prefs_migration = save_data["tgui_prefs_migration"]
	if(!tgui_prefs_migration && save_data.len) // If save_data is empty, this is definitely a new character
		to_chat(parent, boxed_message(span_redtext("PREFERENCE MIGRATION BEGINNING.\
		\nDO NOT INTERACT WITH YOUR PREFERENCES UNTIL THIS PROCESS HAS BEEN COMPLETED.\
		\nDO NOT DISCONNECT UNTIL THIS PROCESS HAS BEEN COMPLETED.\
		")))
		migrate_nova(save_data)
		addtimer(CALLBACK(src, PROC_REF(check_migration)), 10 SECONDS)


	food_preferences = SANITIZE_LIST(save_data["food_preferences"])

	var/needs_nova_update = savefile_needs_update_nova(save_data)
	if(needs_nova_update >= 0)
		update_character_nova(needs_nova_update, save_data) // needs_nova_update == savefile_version if we need an update (positive integer)


/// Brings a savefile up to date with modular preferences. Called if savefile_needs_update_nova() returned a value higher than 0
/datum/preferences/proc/update_character_nova(current_version, list/save_data)
	if(current_version < VERSION_GENITAL_TOGGLES)
		// removed genital toggles, with the new choiced prefs paths as assoc
		var/static/list/old_toggles
		if(!old_toggles)
			old_toggles = list(
				"penis_toggle" = /datum/preference/choiced/genital/penis,
				"testicles_toggle" = /datum/preference/choiced/genital/testicles,
				"vagina_toggle" = /datum/preference/choiced/genital/vagina,
				"womb_toggle" = /datum/preference/choiced/genital/womb,
				"breasts_toggle" = /datum/preference/choiced/genital/breasts,
				"anus_toggle" = /datum/preference/choiced/genital/anus,
			)

		for(var/toggle in old_toggles)
			var/has_genital = save_data[toggle]
			if(!has_genital) // The toggle was off, so we make sure they have it set to the default "None" in the dropdown pref.
				var/datum/preference/genital = GLOB.preference_entries[old_toggles[toggle]]
				write_preference(genital, genital.create_default_value())

		if(save_data["skin_tone_toggle"])
			for(var/pref_type in subtypesof(/datum/preference/toggle/genital_skin_tone))
				write_preference(GLOB.preference_entries[pref_type], TRUE)

	if(current_version < VERSION_BREAST_SIZE_CHANGE)
		var/list/old_breast_prefs
		old_breast_prefs = save_data["breasts_size"]
		if(isnum(old_breast_prefs)) // Can't be too careful
			// You weren't meant to be able to pick sizes over this anyways.
			write_preference(GLOB.preference_entries[/datum/preference/choiced/breasts_size], GLOB.breast_size_translation["[min(old_breast_prefs, 10)]"])

	if(current_version < VERSION_SYNTH_REFACTOR)
		var/old_species = save_data["species"]
		if(istext(old_species) && (old_species in list("synthhuman", "synthliz", "synthmammal", "ipc")))

			var/list/new_color

			if(old_species == "synthhuman")
				write_preference(GLOB.preference_entries[/datum/preference/choiced/mutant_choice/synth_chassis], "Human Chassis")
				write_preference(GLOB.preference_entries[/datum/preference/choiced/mutant_choice/synth_head], "Human Head")
				// Get human skintone instead of mutant color
				new_color = save_data["skin_tone"]
				new_color = skintone2hex(new_color)
			else if(old_species == "synthliz")
				write_preference(GLOB.preference_entries[/datum/preference/choiced/mutant_choice/synth_chassis], "Lizard Chassis")
				write_preference(GLOB.preference_entries[/datum/preference/choiced/mutant_choice/synth_head], "Lizard Head")
			if(old_species == "synthmammal")
				write_preference(GLOB.preference_entries[/datum/preference/choiced/mutant_choice/synth_chassis], "Mammal Chassis")
				write_preference(GLOB.preference_entries[/datum/preference/choiced/mutant_choice/synth_head], "Mammal Head")

			// Sorry, but honestly, you folk might like to browse the IPC screens now they've got previews.
			write_preference(GLOB.preference_entries[/datum/preference/choiced/mutant_choice/ipc_screen], "None")
			// Unfortunately, you will get a human last name applied due to load behaviours. Nothing I can do about it.
			write_preference(GLOB.preference_entries[/datum/preference/choiced/species], "synth")

			// If human code hasn't kicked in, grab mutant colour.
			if(!new_color)
				new_color = save_data["mutant_colors_color"]
				if(islist(new_color) && new_color.len > 0)
					new_color = sanitize_hexcolor(new_color[1])
				// Just let validation pick its own value.

			if(new_color)
				write_preference(GLOB.preference_entries[/datum/preference/color/mutant/synth_chassis], new_color)
				write_preference(GLOB.preference_entries[/datum/preference/color/mutant/synth_head], new_color)

	if(current_version < VERSION_UNDERSHIRT_BRA_SPLIT)
		var/static/list/underwear_to_underwear_bra = list(
			"Bikini" = list("Panties - Slim", "Bra"),
			"Lace Bikini" = list("Panties - Thin", "Bra - Thin"),
			"Bralette w/ Boyshorts" = list("Boyshorts (Alt)", "Bra, Sports"),
			"Sports Bra w/ Boyshorts" = list("Boyshorts", "Bra, Sports - Alt"),
			"Strapless Bikini" = list("Panties - Slim", "Strapless Swimsuit Top (Alt)"),
			"Babydoll" = list("Thong - Alt", null), // Got moved to an undershirt, actual underwear part is now a thong.
			"Two-Piece Swimsuit" = list("Panties - Swimsuit", "Swimsuit Top"),
			"Strapless Two-Piece Swimsuit" = list("Panties - Swimsuit", "Strapless Swimsuit Top"),
			"Halter Swimsuit" = list("Panties - Basic", "Bra - Halterneck - (Alt)"),
			"Neko Bikini (White)" = list("Panties - Neko", "Bra - Neko"),
			"Neko Bikini (Black)" = list("Panties - Neko", "Bra - Neko"),
			"UK Biniki" = list("Panties - UK", "Bra - UK"),
		)

		var/current_underwear = save_data["underwear"]
		var/migrated_underwear_bra = underwear_to_underwear_bra[current_underwear]

		if(migrated_underwear_bra)
			var/migrated_color = save_data["underwear_color"]
			var/migrated_underwear = migrated_underwear_bra[INDEX_UNDERWEAR]
			var/migrated_bra = migrated_underwear_bra[INDEX_BRA]

			if(migrated_underwear)
				write_preference(GLOB.preference_entries[/datum/preference/choiced/underwear], migrated_underwear)

			if(migrated_bra)
				write_preference(GLOB.preference_entries[/datum/preference/choiced/bra], migrated_bra)
				write_preference(GLOB.preference_entries[/datum/preference/color/bra_color], migrated_color)

		var/current_undershirt = save_data["undershirt"]

		// This one has a different treatment because it's an underwear that has been moved mainly to an undershirt,
		// ending up as a thong for the underwear part itself. We only want to override the undershirt if there's none,
		// though.
		if(current_underwear == "Babydoll" && current_undershirt == "Nude")
			var/migrated_color = save_data["underwear_color"]

			write_preference(GLOB.preference_entries[/datum/preference/choiced/undershirt], "Babydoll")
			write_preference(GLOB.preference_entries[/datum/preference/color/undershirt_color], migrated_color)

		var/static/list/undershirt_to_bra = list(
			"Bra, Sports" = "Bra, Sports",
			"Sports Bra (Alt)" = "Sports Bra (Alt)",
			"Bra" = "Bra",
			"Bra - Alt" = "Bra - Alt",
			"Bra - Thin" = "Bra - Thin",
			"Bra - Kinky Black" = "Bra - Kinky Black",
			"Bra - Freedom" = "Bra - Freedom",
			"Bra - Commie" = "Bra - Commie",
			"Bra - Bee-kini" = "Bra - Bee-kini",
			"Bra - UK" = "Bra - UK",
			"Bra - Neko" = "Bra - Neko",
			"Bra - Halterneck" = "Bra - Halterneck",
			"Bra - Sports - Alt" = "Bra - Sports - Alt",
			"Bra - Strapless" = "Bra - Strapless",
			"Bra - Latex" = "Bra - Latex",
			"Bra - Striped" = "Bra - Striped",
			"Bra - Sarashi" = "Bra - Sarashi",
			"Fishnet - Sleeved" = "Fishnet - Sleeved",
			"Fishnet - Sleeved (Greyscaled)" = "Fishnet - Sleeved (Greyscaled)",
			"Fishnet - Sleeveless" = "Fishnet - Sleeveless",
			"Fishnet - Sleeveless (Greyscaled)" = "Fishnet - Sleeveless (Greyscaled)",
			"Swimsuit Top" = "Bra - Halterneck - (Alt)",
			"Chastity Bra" = "Chastity Bra",
			"Pasties" = "Pasties",
			"Pasties - Alt" = "Pasties - Alt",
			"Shibari" = "Shibari",
			"Shibari Sleeves" = "Shibari Sleeves",
			"Binder" = "Binder",
			"Binder - Strapless" = "Binder - Strapless",
			"Safekini" = "Safekini",
		)

		var/migrated_bra_from_undershirt = undershirt_to_bra[current_undershirt]

		if(migrated_bra_from_undershirt)
			var/migrated_color = save_data["undershirt_color"]

			write_preference(GLOB.preference_entries[/datum/preference/choiced/bra], migrated_bra_from_undershirt)
			write_preference(GLOB.preference_entries[/datum/preference/color/bra_color], migrated_color)
			write_preference(GLOB.preference_entries[/datum/preference/choiced/undershirt], "Nude")

	// Resets Chronological Age field to default.
	if(current_version < VERSION_CHRONOLOGICAL_AGE)
		write_preference(GLOB.preference_entries[/datum/preference/numeric/chronological_age], read_preference(/datum/preference/numeric/age))

	if(current_version < VERSION_TG_LOADOUT)
		var/list/save_loadout = SANITIZE_LIST(save_data["loadout_list"])
		for(var/loadout in save_loadout)
			var/entry = save_loadout[loadout]
			save_loadout -= loadout

			if(istext(loadout))
				loadout = _text2path(loadout)
			save_loadout[loadout] = entry
		var/loadout_list = sanitize_loadout_list(save_loadout)

		if (length(loadout_list)) // We only want to write these changes down if we're certain that there was anything in that.
			write_preference(GLOB.preference_entries[/datum/preference/loadout], loadout_list)

	if(current_version < VERSION_INTERNAL_EXTERNAL_ORGANS)
		var/list/save_augments = SANITIZE_LIST(save_data["augments"])
		var/prefix_length = length("/obj/item/organ/internal") // Shouldn't be any external augments, but if there are, it's the same length
		for(var/augment_name in save_augments)
			var/augment_path_string = save_augments[augment_name]
			if(!(findtext(augment_path_string, "/obj/item/organ/internal") || findtext(augment_path_string, "/obj/item/organ/external")))
				continue // Make sure we don't strip something that isn't there
			var/augment_path_string_stripped = copytext(save_augments[augment_name], prefix_length + 1)
			save_augments[augment_name] = "/obj/item/organ[augment_path_string_stripped]"
		load_augments(save_augments)

	if(current_version < VERSION_SKRELL_HAIR_NAME_UPDATE)
		var/list/mutant_bodyparts = SANITIZE_LIST(save_data["mutant_bodyparts"])

		var/datum/mutant_bodypart/mutant_part = mutant_bodyparts[FEATURE_SKRELL_HAIR]
		if(mutant_part)
			var/current_skrell_hair = mutant_part.name

			if(current_skrell_hair == "Male")
				write_preference(GLOB.preference_entries[/datum/preference/choiced/mutant_choice/skrell_hair], "Short")
			else if(current_skrell_hair == "Female")
				write_preference(GLOB.preference_entries[/datum/preference/choiced/mutant_choice/skrell_hair], "Long")

		// Sets old insect laugh to the merged moth/insect in case character uses it.
	if (current_version < VERSION_TG_EMOTE_SOUNDS)
		var/current_laugh = save_data["character_laugh"]
		var/current_scream = save_data["character_scream"]
		if(current_laugh == "Moth Laugh" || current_laugh == "Insect Laugh")
			write_preference(GLOB.preference_entries[/datum/preference/choiced/laugh], "Insect Laugh (Moth)")
		if(current_scream == "Moth Scream 2")
			write_preference(GLOB.preference_entries[/datum/preference/choiced/scream], "Lizard Scream")

	if (current_version < VERSION_CAT_EARS_DUPES)
		var/current_ears = save_data["feature_ears"]
		if(current_ears == "Cat, Big")
			write_preference(GLOB.preference_entries[/datum/preference/choiced/mutant_choice/ears], "Cat (Colorable Inner, Behind Hair)")
		else if(current_ears == "Cat, normal")
			write_preference(GLOB.preference_entries[/datum/preference/choiced/mutant_choice/ears], "Cat, Alert")
		else if(current_ears == "Cat, Big (Alt)")
			write_preference(GLOB.preference_entries[/datum/preference/choiced/mutant_choice/ears], "Cat (Colorable Inner)")

	if(current_version < VERSION_LOADOUT_PRESETS)
		write_preference(GLOB.preference_entries[/datum/preference/loadout], list("Default" = save_data["loadout_list"]))

	if(current_version < VERSION_EMO_LONG_REMOVAL)
		var/current_hair = save_data["hairstyle_name"]
		if(current_hair == "Emo Long")
			write_preference(GLOB.preference_entries[/datum/preference/choiced/hairstyle], "Long Emo")
	if(current_version < VERSION_TOOLKIT_IMPLANTS)
		migrate_toolset_implants(save_data)

	if(current_version < VERSION_VOCAL_BARKS)
		var/current_tts_voice = save_data["tts_voice"]
		if(current_tts_voice != TTS_VOICE_NONE && current_tts_voice != "invalid") // make sure we don't turn off TTS for people who have it on
			write_preference(GLOB.preference_entries[/datum/preference/choiced/vocals/voice_type], "Text-to-speech")

	if(current_version < VERSION_FEATHERY_WINGS_FIX)
		var/current_wings = save_data["feature_wings"]
		if(current_wings == "Moth (Featherful)")
			write_preference(GLOB.preference_entries[/datum/preference/choiced/mutant_choice/wings], "Moth (Feathery)")

	if(current_version < VERSION_DONK_MIGRATION)
		var/current_donk = save_data["feature_penis"]
		if(current_donk != "None")
			write_preference(GLOB.preference_entries[/datum/preference/choiced/genital/penis], current_donk + " (Alt)")
		var/current_pocket = save_data["feature_testicles"]
		if(current_pocket == "Pair")
			write_preference(GLOB.preference_entries[/datum/preference/choiced/genital/testicles], "Pair (Alt)")

/datum/preferences/proc/check_migration()
	if(!tgui_prefs_migration)
		to_chat(parent, boxed_message(span_redtext("CRITICAL FAILURE IN PREFERENCE MIGRATION, REPORT THIS IMMEDIATELY.")))
		message_admins("PREFERENCE MIGRATION: [ADMIN_LOOKUPFLW(parent)] has failed the process for migrating PREFERENCES. Check runtimes.")


/// Saves the modular customizations of a character on the savefile
/datum/preferences/proc/save_character_nova(list/save_data)
	save_data["augments"] = augments
	save_data["augment_limb_styles"] = augment_limb_styles
	save_data["body_markings"] = body_markings
	save_data["mismatched_customization"] = mismatched_customization
	save_data["allow_advanced_colors"] = allow_advanced_colors
	save_data["alt_job_titles"] = alt_job_titles
	save_data["languages"] = languages
	save_data["modular_version"] = MODULAR_SAVEFILE_VERSION_MAX
	save_data["food_preferences"] = food_preferences

/datum/preferences/proc/update_markings(list/markings)
	return sanitize_marking_map(markings, null, null)

/datum/preferences/proc/load_augments(list/augments_prefs)
	var/list/augments_sanitized = list()
	for(var/aug_slot in augments_prefs)
		var/aug_entry = augments_prefs[aug_slot]

		if(istext(aug_entry))
			aug_entry = _text2path(aug_entry)

		var/datum/augment_item/aug = GLOB.augment_items[aug_entry]
		if(!aug)
			for(var/augment_path in GLOB.augment_items)
				var/datum/augment_item/possible_aug = GLOB.augment_items[augment_path]
				if(possible_aug.path != aug_entry)
					continue
				aug_entry = augment_path
				aug = possible_aug
				break
		if(aug)
			augments_sanitized[aug_slot] = aug_entry
	augments = augments_sanitized

/// Migration for loadout augments, replaces augments with /toolkit versions if the original doesn't exist
/datum/preferences/proc/migrate_toolset_implants(list/save_data)
	var/list/save_augments = SANITIZE_LIST(save_data["augments"])
	if(!length(save_augments))
		return
	for(var/augment_name in save_augments)
		var/augment_path_string = save_augments[augment_name]
		var/augment_path = _text2path(augment_path_string)
		var/datum/augment_item/augment_item = GLOB.augment_items[augment_path]
		if(!augment_item)
			for(var/possible_augment_path in GLOB.augment_items)
				var/datum/augment_item/possible_aug = GLOB.augment_items[possible_augment_path]
				if(possible_aug.path != augment_path)
					continue
				augment_item = possible_aug
				break
		if(augment_item) // The augment already exists, neat!
			continue
		// Saved augment doesn't exist, try the toolkit version
		augment_path_string = replacetext(augment_path_string, "/cyberimp/arm/", "/cyberimp/arm/toolkit/")
		augment_path = _text2path(augment_path_string)
		var/found_toolkit_augment = FALSE
		for(var/possible_augment_path in GLOB.augment_items)
			var/datum/augment_item/possible_aug = GLOB.augment_items[possible_augment_path]
			if(possible_aug.path != augment_path)
				continue
			save_augments[augment_name] = possible_augment_path
			found_toolkit_augment = TRUE
			break
		if(found_toolkit_augment)
			continue
		stack_trace("Attempt to migrate augment item [save_augments[augment_name]] failed!")
		save_augments -= augment_name

	load_augments(save_augments)

#undef MODULAR_SAVEFILE_VERSION_MAX
#undef MODULAR_SAVEFILE_UP_TO_DATE

#undef VERSION_GENITAL_TOGGLES
#undef VERSION_BREAST_SIZE_CHANGE
#undef VERSION_SYNTH_REFACTOR
#undef VERSION_UNDERSHIRT_BRA_SPLIT
#undef VERSION_CHRONOLOGICAL_AGE
#undef VERSION_TG_LOADOUT
#undef VERSION_INTERNAL_EXTERNAL_ORGANS
#undef VERSION_SKRELL_HAIR_NAME_UPDATE
#undef VERSION_TG_EMOTE_SOUNDS
#undef VERSION_CAT_EARS_DUPES
#undef VERSION_LOADOUT_PRESETS
#undef VERSION_EMO_LONG_REMOVAL
#undef VERSION_TOOLKIT_IMPLANTS
#undef VERSION_VOCAL_BARKS
#undef VERSION_FEATHERY_WINGS_FIX
#undef VERSION_DONK_MIGRATION
// END NOVA CORE MIGRATION: code/modules/client/preferences_savefile.dm
