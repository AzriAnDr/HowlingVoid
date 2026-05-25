GLOBAL_LIST_EMPTY(preferences_datums)

/datum/preferences
	var/client/parent
	/// The path to the general savefile for this datum
	var/path
	/// Whether or not we allow saving/loading. Used for guests, if they're enabled
	var/load_and_save = TRUE
	/// Ensures that we always load the last used save, QOL
	var/default_slot = 1
	/// The maximum number of slots we're allowed to contain
	var/max_save_slots = 30 //NOVA EDIT - ORIGINAL 3

	/// Bitflags for communications that are muted
	var/muted = NONE
	/// Last IP that this client has connected from
	var/last_ip
	/// Last CID that this client has connected from
	var/last_id

	/// Cached changelog size, to detect new changelogs since last join
	var/lastchangelog = ""

	/// List of ROLE_X that the client wants to be eligible for
	var/list/be_special = list() //Special role selection

	/// Custom keybindings. Map of keybind names to keyboard inputs.
	/// For example, by default would have "swap_hands" -> list("X")
	var/list/key_bindings = list()

	/// Cached list of keybindings, mapping keys to actions.
	/// For example, by default would have "X" -> list("swap_hands")
	var/list/key_bindings_by_key = list()

	var/toggles = TOGGLES_DEFAULT
	var/db_flags = NONE
	var/chat_toggles = TOGGLES_DEFAULT_CHAT
	var/ghost_form = "ghost"

	//character preferences
	var/slot_randomized //keeps track of round-to-round randomization of the character slot, prevents overwriting

	var/list/randomise = list()

	//Quirk list
	var/list/all_quirks = list()

	//Job preferences 2.0 - indexed by job title , no key or value implies never
	var/list/job_preferences = list()

	/// Assoc list of custom emote panel entries. Key -> name string OR assoc list with "name","message","type","sound","effect","color","volume" keys.
	var/list/custom_emote_panel = list()

	/// The current window, PREFERENCE_TAB_* in [`code/__DEFINES/preferences.dm`]
	var/current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES

	var/unlock_content = 0

	var/list/ignoring = list()

	var/list/exp = list()

	var/action_buttons_screen_locs = list()

	///Someone thought we were nice! We get a little heart in OOC until we join the server past the below time (we can keep it until the end of the round otherwise)
	var/hearted
	///If we have a hearted commendations, we honor it every time the player loads preferences until this time has been passed
	var/hearted_until
	///What outfit typepaths we've favorited in the SelectEquipment menu
	var/list/favorite_outfits = list()

	/// A preview of the current character
	var/atom/movable/screen/map_view/char_preview/character_preview_view

	/// A list of instantiated middleware
	var/list/datum/preference_middleware/middleware = list()

	/// The json savefile for this datum
	var/datum/json_savefile/savefile

	/// The savefile relating to character preferences, PREFERENCE_CHARACTER
	var/list/character_data

	/// A list of keys that have been updated since the last save.
	var/list/recently_updated_keys = list()

	/// A cache of preference entries to values.
	/// Used to avoid expensive READ_FILE every time a preference is retrieved.
	var/value_cache = list()

	/// If set to TRUE, will update character_profiles on the next ui_data tick.
	var/tainted_character_profiles = FALSE

/datum/preferences/Destroy(force)
	QDEL_NULL(character_preview_view)
	QDEL_LIST(middleware)
	value_cache = null
	return ..()

/datum/preferences/New(client/parent)
	src.parent = parent

	for (var/middleware_type in subtypesof(/datum/preference_middleware))
		middleware += new middleware_type(src)

	if(IS_CLIENT_OR_MOCK(parent))
		if(is_guest_key(parent.key))
			if(parent.is_localhost())
				path = DEV_PREFS_PATH // guest + locallost = dev instance, load dev preferences if possible
			else
				load_and_save = FALSE // guest + not localhost = guest on live, don't save anything
		else
			load_path(parent.ckey) // not guest = load their actual savefile
		if(load_and_save && !fexists(path))
			try_savefile_type_migration()

		refresh_membership()
	else
		CRASH("attempted to create a preferences datum without a client or mock!")
	load_savefile()

	// give them default keybinds and update their movement keys
	key_bindings = deep_copy_list(GLOB.default_hotkeys)
	key_bindings_by_key = get_key_bindings_by_key(key_bindings)
	randomise = get_default_randomization()

	var/loaded_preferences_successfully = load_preferences()
	if(loaded_preferences_successfully)
		if(load_character())
			// NOVA EDIT ADDITION START - Sanitizing preferences
			sanitize_languages()
			sanitize_quirks()
			// NOVA EDIT ADDITION END - Sanitizing preferences
			return // Don't remove this. Just don't. Nothing is worth forced random characters. // NOVA EDIT CHANGE - Just adds comment - Original: return
	//we couldn't load character data so just randomize the character appearance + name
	randomise_appearance_prefs() //let's create a random character then - rather than a fat, bald and naked man.
	if(parent)
		apply_all_client_preferences()
		parent.set_macros()

	if(!loaded_preferences_successfully)
		save_preferences()
	save_character() //let's save this new random character so it doesn't keep generating new ones.

/datum/preferences/proc/get_statpanel_favorites()
	var/list/favorites = vars["statpanel_favorites"]
	if(!islist(favorites))
		favorites = list()
		vars["statpanel_favorites"] = favorites
	return favorites

/datum/preferences/proc/set_statpanel_favorites(list/new_favorites)
	if(!islist(new_favorites))
		new_favorites = list()
	vars["statpanel_favorites"] = new_favorites

/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	// There used to be code here that readded the preview view if you "rejoined"
	// I'm making the assumption that ui close will be called whenever a user logs out, or loses a window
	// If this isn't the case, kill me and restore the code, thanks

	if(is_storyteller_character_edit_locked(user))
		return

	// We need IconForge and the assets to be ready before allowing the menu to open
	if(SSearly_assets.initialized != INITIALIZATION_INNEW_REGULAR)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		character_preview_view?.display_to(user, ui.window)
		return
	if(!character_preview_view || QDELETED(character_preview_view))
		character_preview_view = create_character_preview_view(user)
	else
		character_preview_view.update_body()
	ui = new(user, src, "PreferencesMenu", null, 1080, 920)
	ui.set_autoupdate(FALSE)
	ui.open()
	character_preview_view.display_to(user, ui.window)

/datum/preferences/ui_state(mob/user)
	return GLOB.always_state

// Without this, a hacker would be able to edit other people's preferences if
// they had the ref to Topic to.
/datum/preferences/ui_status(mob/user, datum/ui_state/state)
	return user.client == parent ? UI_INTERACTIVE : UI_CLOSE

/datum/preferences/proc/is_storyteller_character_edit_locked(mob/user)
	if(!isnewplayer(user) || current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return FALSE

	var/remaining = SSstoryteller.get_roundstart_prep_remaining()
	if(remaining <= 0)
		return FALSE

	to_chat(user, span_warning("Character setup is temporarily locked while the storyteller finalizes the dynamic round roster. Try again in [DisplayTimeText(remaining, round_seconds_to = 1)]."))
	return TRUE

/datum/preferences/proc/is_storyteller_locked_preferences_action(action)
	return action in list(
		"change_slot",
		"remove_current_slot",
		"import_character",
		"set_preference",
		"set_color_preference",
		"set_tricolor_preference",
		"open_food",
		"set_job_preference",
		"set_job_title",
		"update_background",
	)

/datum/preferences/ui_data(mob/user)
	var/list/data = list()

	if (tainted_character_profiles)
		data["character_profiles"] = create_character_profiles()
		tainted_character_profiles = FALSE
	//NOVA EDIT ADDITION BEGIN
	data["preview_selection"] = preview_pref
	data["erp_pref"] = read_preference(/datum/preference/toggle/master_erp_preferences)
	data["quirk_points_enabled"] = !CONFIG_GET(flag/disable_quirk_points)
	data["quirks_balance"] = GetQuirkBalance()
	data["positive_quirk_count"] = GetPositiveQuirkCount()
	data["interface_language"] = read_preference(/datum/preference/choiced/interface_language) // Howling Void edit
	data["panel_languages"] = build_panel_languages_payload(src)
	//NOVA EDIT ADDITION END
	data["character_preferences"] = compile_character_preferences(user)

	data["active_slot"] = default_slot

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		data += preference_middleware.get_ui_data(user)

	return data

/datum/preferences/ui_static_data(mob/user)
	var/list/data = list()

	// NOVA EDIT ADDITION START
	if(CONFIG_GET(flag/disable_erp_preferences))
		data["preview_options"] = list(PREVIEW_PREF_JOB, PREVIEW_PREF_LOADOUT, PREVIEW_PREF_UNDERWEAR, PREVIEW_PREF_NAKED)
	else
		data["preview_options"] = list(PREVIEW_PREF_JOB, PREVIEW_PREF_LOADOUT, PREVIEW_PREF_UNDERWEAR, PREVIEW_PREF_NAKED, PREVIEW_PREF_NAKED_AROUSED)
	// NOVA EDIT ADDITION END

	data["character_profiles"] = create_character_profiles()

	data["character_preview_view"] = character_preview_view?.assigned_map
	data["overflow_role"] = SSjob.get_job_type(SSjob.overflow_role).title
	data["window"] = current_window

	data["content_unlocked"] = unlock_content
	data["interface_language"] = read_preference(/datum/preference/choiced/interface_language) // Howling Void edit
	data["panel_languages"] = build_panel_languages_payload(src)

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		data += preference_middleware.get_ui_static_data(user)

	return data

/datum/preferences/ui_assets(mob/user)
	var/list/assets = list(
		get_asset_datum(/datum/asset/spritesheet_batched/preferences),
		get_asset_datum(/datum/asset/json/preferences),
	)

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		assets += preference_middleware.get_ui_assets()

	return assets

/datum/preferences/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	if(SSlag_switch.measures[DISABLE_CREATOR] && action != "change_slot")
		to_chat(usr, "The creator has been disabled. Please do not ahelp.")
		return

	var/mob/request_user = ui?.user || usr
	if(is_storyteller_locked_preferences_action(action) && is_storyteller_character_edit_locked(request_user))
		return TRUE

	log_creator("[key_name(usr)] ACTED [action] | PREFERENCE: [params["preference"]] | VALUE: [params["value"]]")

	switch (action)
		if ("change_slot")
			// Save existing character
			save_character()
			// SAFETY: `switch_to_slot` performs sanitization on the slot number
			switch_to_slot(params["slot"], usr)
			return TRUE
		if ("remove_current_slot")
			remove_current_slot()
			return TRUE
		if ("rotate")
			/* NOVA EDIT - Bi-directional prefs menu rotation - ORIGINAL:
			character_preview_view.setDir(turn(character_preview_view.dir, -90))
			*/ // ORIGINAL END - NOVA EDIT START:
			var/backwards = params["backwards"]
			character_preview_view.setDir(turn(character_preview_view.dir, backwards ? 90 : -90))
			// NOVA EDIT END
			return TRUE
		if ("export_preferences")
			savefile?.export_json_to_client(usr, parent?.ckey)
			return TRUE
		if ("export_character")
			export_current_slot()
			return TRUE
		if ("import_character")
			import_current_slot()
			return TRUE
		if ("set_preference")
			var/requested_preference_key = params["preference"]
			var/value = params["value"]

			for (var/datum/preference_middleware/preference_middleware as anything in middleware)
				if (preference_middleware.pre_set_preference(usr, requested_preference_key, value))
					return TRUE

			var/datum/preference/requested_preference = GLOB.preference_entries_by_key[requested_preference_key]
			if (isnull(requested_preference))
				return FALSE

			// SAFETY: `update_preference` performs validation checks
			if (!update_preference(requested_preference, value))
				return FALSE

			if (istype(requested_preference, /datum/preference/name))
				tainted_character_profiles = TRUE

			for(var/datum/preference_middleware/preference_middleware as anything in middleware)
				preference_middleware.post_set_preference(ui.user, requested_preference_key, value)
			return TRUE
		if ("set_color_preference")
			var/requested_preference_key = params["preference"]

			var/datum/preference/requested_preference = GLOB.preference_entries_by_key[requested_preference_key]
			if (isnull(requested_preference))
				return FALSE

			if (!istype(requested_preference, /datum/preference/color))
				return FALSE

			var/default_value = read_preference(requested_preference.type)

			// Yielding
			var/new_color = tgui_color_picker(
				usr,
				"Select new color",
				null,
				default_value || COLOR_WHITE,
			)

			if (!new_color)
				return FALSE

			if (!update_preference(requested_preference, new_color))
				return FALSE

			return TRUE
		// NOVA EDIT ADDITION START
		if("update_preview")
			preview_pref = params["updated_preview"]
			character_preview_view.update_body()
			return TRUE

		if ("open_food")
			GLOB.food_prefs_menu.ui_interact(usr)
			return TRUE
		if("set_ui_language")
			var/element = params["element"]
			var/language = lowertext("[params["language"]]")
			var/pref_path = get_panel_language_preference_path(element)

			if(!pref_path || !(language in list("english", "russian")))
				return FALSE

			var/datum/preference/requested_preference = GLOB.preference_entries[pref_path]
			if(isnull(requested_preference))
				return FALSE

			return update_preference(requested_preference, language)
		// NOVA EDIT ADDITION START: Background Selection
		if("update_background")
			update_preference(GLOB.preference_entries[/datum/preference/choiced/background_state], params["new_background"])
			return TRUE
		// NOVA EDIT ADDITION END

		if ("set_tricolor_preference")
			var/requested_preference_key = params["preference"]
			var/index_key = params["value"]

			var/datum/preference/requested_preference = GLOB.preference_entries_by_key[requested_preference_key]
			if (isnull(requested_preference))
				return FALSE

			if (!istype(requested_preference, /datum/preference/tri_color))
				return FALSE

			var/default_value_list = read_preference(requested_preference.type)
			if (!islist(default_value_list))
				return FALSE
			var/default_value = default_value_list[index_key]

			// Yielding
			var/new_color = tgui_color_picker(
				usr,
				"Select new color",
				null,
				default_value || COLOR_WHITE,
			)

			if (!new_color)
				return FALSE

			default_value_list[index_key] = new_color

			if (!update_preference(requested_preference, default_value_list))
				return FALSE

			return TRUE

		// For the quirks in the prefs menu.
		if ("get_quirks_balance")
			return TRUE
		//NOVA EDIT ADDITION END

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		var/delegation = preference_middleware.action_delegations[action]
		if (!isnull(delegation))
			return call(preference_middleware, delegation)(params, usr)

	return FALSE

/datum/preferences/ui_close(mob/user)
	if(length(open_uis) > 1)
		return

	save_character()
	save_preferences()
	QDEL_NULL(character_preview_view)

/datum/preferences/Topic(href, list/href_list)
	. = ..()
	if (.)
		return

	if (href_list["open_keybindings"])
		current_window = PREFERENCE_TAB_KEYBINDINGS
		update_static_data(usr)
		ui_interact(usr)
		return TRUE

/datum/preferences/proc/create_character_preview_view(mob/user)
	character_preview_view = new(null, null, src)
	character_preview_view.generate_view("character_preview_[REF(character_preview_view)]")
	character_preview_view.update_body()

	return character_preview_view

/datum/preferences/proc/compile_character_preferences(mob/user)
	var/list/preferences = list()

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (!preference.is_accessible(src))
			continue

		var/value = read_preference(preference.type)
		var/data = preference.compile_ui_data(user, value)

		LAZYINITLIST(preferences[preference.category])
		preferences[preference.category][preference.savefile_key] = data


	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		var/list/append_character_preferences = preference_middleware.get_character_preferences(user)
		if (isnull(append_character_preferences))
			continue

		for (var/category in append_character_preferences)
			if (category in preferences)
				preferences[category] += append_character_preferences[category]
			else
				preferences[category] = append_character_preferences[category]

	return preferences

/// Applies all PREFERENCE_PLAYER preferences
/datum/preferences/proc/apply_all_client_preferences()
	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.savefile_identifier != PREFERENCE_PLAYER)
			continue

		value_cache -= preference.type
		preference.apply_to_client(parent, read_preference(preference.type))

/// A preview of a character for use in the preferences menu
/atom/movable/screen/map_view/char_preview
	name = "character_preview"

	/// The body that is displayed
	var/mob/living/carbon/human/dummy/body
	/// The preferences this refers to
	var/datum/preferences/preferences
	/// Whether we show current job clothes or nude/loadout only
	var/show_job_clothes = TRUE
	// NOVA EDIT ADDITION START: Better character preview: Rescales between 32x32, 64x64 and 96x96.
	var/image/canvas
	var/last_canvas_size
	var/last_canvas_state
	// NOVA EDIT ADDITION END

/atom/movable/screen/map_view/char_preview/Initialize(mapload, datum/hud/hud_owner, datum/preferences/preferences)
	. = ..()
	src.preferences = preferences

/atom/movable/screen/map_view/char_preview/Destroy()
	// NOVA EDIT ADDITION START: Better character preview
	canvas?.cut_overlays()
	canvas = null
	// NOVA EDIT ADDITION END
	QDEL_NULL(body)
	preferences?.character_preview_view = null
	preferences = null
	return ..()

/atom/movable/screen/map_view/char_preview/setDir(newdir)
	return ..()

/// Updates the currently displayed body
/atom/movable/screen/map_view/char_preview/proc/update_body()
	if (isnull(body))
		create_body()
	else
		body.wipe_state()

	appearance = preferences.render_new_preview_appearance(body, show_job_clothes)

	// NOVA EDIT ADDITION BEGIN: Better character preview
	var/body_scale = get_preview_body_size_scale()
	var/height_scale = get_preview_height_scale()
	var/required_width = CEILING(ICON_SIZE_X * body_scale, 1)
	var/required_height = CEILING(ICON_SIZE_Y * body_scale * height_scale, 1)
	if(body.dna?.mutant_bodyparts["taur"])
		required_width += ICON_SIZE_X

	var/canvas_size = get_preview_canvas_size(required_width, required_height)
	var/canvas_state = preferences.read_preference(/datum/preference/choiced/background_state)
	body.pixel_x = canvas_size * 16

	if (isnull(canvas) || last_canvas_size != canvas_size || last_canvas_state != canvas_state)
		switch (canvas_size)
			if (0)
				canvas = image('icons/character_preview_background/background_32x32.dmi', icon_state = canvas_state)
			if (1)
				canvas = image('icons/character_preview_background/background_64x64.dmi', icon_state = canvas_state)
			if (2)
				canvas = image('icons/character_preview_background/background_96x96.dmi', icon_state = canvas_state)

	// Update the map view bounds when canvas size changes to properly display the scaled preview
	set_position(1, 1)
	last_canvas_size = canvas_size
	last_canvas_state = canvas_state

	canvas.cut_overlays()
	canvas.add_overlay(body.appearance)

	appearance = canvas.appearance
	// NOVA EDIT ADDITION END

/atom/movable/screen/map_view/char_preview/proc/get_preview_body_size_scale()
	if(isnull(body?.dna))
		return BODY_SIZE_NORMAL

	var/body_scale = body.dna.features["body_size"]
	if(!isnum(body_scale) || body_scale <= 0)
		return BODY_SIZE_NORMAL

	return body_scale

/atom/movable/screen/map_view/char_preview/proc/get_preview_height_scale()
	if(isnull(body) || body.mob_height == HUMAN_HEIGHT_MEDIUM)
		return 1

	var/list/height_offsets = GLOB.human_heights_to_offsets["[body.mob_height]"]
	if(!islist(height_offsets) || length(height_offsets) < 2)
		return 1

	var/height_scale = 1 + ((height_offsets[1] + height_offsets[2]) / ICON_SIZE_Y)
	return max(height_scale, 0.75)

/atom/movable/screen/map_view/char_preview/proc/get_preview_canvas_size(required_width = ICON_SIZE_X, required_height = ICON_SIZE_Y)
	if(required_width > 64 || required_height > 64)
		return 2
	if(required_width > 32 || required_height > 32)
		return 1
	return 0

/atom/movable/screen/map_view/char_preview/proc/create_body()
	QDEL_NULL(body)

	body = new

/datum/preferences/proc/create_character_profiles()
	var/list/profiles = list()

	for (var/index in 1 to max_save_slots)
		// It won't be updated in the savefile yet, so just read the name directly
		if (index == default_slot)
			profiles += read_preference(/datum/preference/name/real_name)
			continue

		var/tree_key = "character[index]"
		var/save_data = savefile.get_entry(tree_key)
		var/name = save_data?["real_name"]

		if (isnull(name))
			profiles += null
			continue

		profiles += name

	return profiles

/datum/preferences/proc/set_job_preference_level(datum/job/job, level)
	if (!job)
		return FALSE

	if (level == JP_HIGH)
		var/datum/job/overflow_role = SSjob.overflow_role
		var/overflow_role_title = initial(overflow_role.title)

		for(var/other_job in job_preferences)
			if(job_preferences[other_job] == JP_HIGH)
				// Overflow role needs to go to NEVER, not medium!
				if(other_job == overflow_role_title)
					job_preferences[other_job] = null
				else
					job_preferences[other_job] = JP_MEDIUM

	if(level == null)
		job_preferences -= job.title
	else
		job_preferences[job.title] = level

	return TRUE

/datum/preferences/proc/GetQuirkBalance()
	var/datum/species/species_type = read_preference(/datum/preference/choiced/species)
	var/bal = CONFIG_GET(number/default_quirk_points) + get_species_quirk_points_bonus(species_type)
	for(var/V in all_quirks)
		bal -= get_quirk_value(V)
	//NOVA EDIT ADDITION
	for(var/key in augments)
		var/datum/augment_item/aug = GLOB.augment_items[augments[key]]
		if(isnull(aug))
			continue
		bal -= aug.cost
	//NOVA EDIT END
	return bal

/datum/preferences/proc/GetPositiveQuirkCount()
	. = 0
	for(var/q in all_quirks)
		if(get_quirk_value(q) > 0)
			.++

/datum/preferences/proc/get_quirk_value(quirk_name)
	if(isnull(quirk_name))
		return 0

	var/value = SSquirks.quirk_points[quirk_name]
	if(isnum(value))
		return value

	var/datum/quirk/quirk_type = SSquirks.quirks[quirk_name]
	if(ispath(quirk_type, /datum/quirk))
		return initial(quirk_type.value)

	// Compatibility fallback for old/altered save entries.
	var/safe_name = sanitize_css_class_name("[quirk_name]")
	for(var/raw_name in SSquirks.quirk_points)
		if(sanitize_css_class_name(raw_name) != safe_name)
			continue
		value = SSquirks.quirk_points[raw_name]
		if(isnum(value))
			return value

	return 0

/datum/preferences/proc/validate_quirks()
	sanitize_quirks()
	var/datum/species/species_type = read_preference(/datum/preference/choiced/species)
	var/list/quirks_removed
	for(var/quirk_name in all_quirks)
		var/quirk_path = SSquirks.quirks[quirk_name]
		var/datum/quirk/quirk_prototype = SSquirks.quirk_prototypes[quirk_path]
		if(isnull(quirk_prototype) || !quirk_prototype.is_species_appropriate(species_type))
			all_quirks -= quirk_name
			LAZYADD(quirks_removed, quirk_name)
	var/list/feedback
	if(LAZYLEN(quirks_removed))
		LAZYADD(feedback, "The following quirks are incompatible with your species:")
		LAZYADD(feedback, quirks_removed)
	if(!CONFIG_GET(flag/disable_quirk_points) && GetQuirkBalance() < 0)
		LAZYADD(feedback, "Your quirks have been reset.")
		all_quirks = list()
	if(LAZYLEN(feedback))
		to_chat(parent, boxed_message(span_greentext(feedback.Join("\n"))))


/**
 * Safely read a given preference datum from a given client.
 *
 * Reads the given preference datum from the given client, and guards against null client and null prefs.
 * The client object is fickle and can go null at times, so use this instead of read_preference() if you
 * want to ensure no runtimes.
 *
 * returns client.prefs.read_preference(prefs_to_read) or FALSE if something went wrong.
 *
 * Arguments:
 * * client/prefs_holder - the client to read the pref from
 * * datum/preference/pref_to_read - the type of preference datum to read.
 */
/proc/safe_read_pref(client/prefs_holder, datum/preference/pref_to_read)
	if(!prefs_holder)
		return FALSE
	if(prefs_holder && !prefs_holder?.prefs)
		stack_trace("[prefs_holder?.mob] ([prefs_holder?.ckey]) had null prefs, which shouldn't be possible!")
		return FALSE

	return prefs_holder?.prefs.read_preference(pref_to_read)

/**
 * Get the given client's chat toggle prefs.
 *
 * Getter function for prefs.chat_toggles which guards against null client and null prefs.
 * The client object is fickle and can go null at times, so use this instead of directly accessing the var
 * if you want to ensure no runtimes.
 *
 * returns client.prefs.chat_toggles or FALSE if something went wrong.
 *
 * Arguments:
 * * client/prefs_holder - the client to get the chat_toggles pref from.
 */
/proc/get_chat_toggles(client/target)
	if(ismob(target))
		var/mob/target_mob = target
		target = target_mob.client

	if(isnull(target))
		return NONE

	var/datum/preferences/preferences = target.prefs
	if(isnull(preferences))
		stack_trace("[key_name(target)] preference datum was null")
		return NONE

	return preferences.chat_toggles

/// Sanitizes the preferences, applies the randomization prefs, and then applies the preference to the human mob.
/datum/preferences/proc/safe_transfer_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE, is_antag = FALSE)
	apply_character_randomization_prefs(is_antag)
	apply_prefs_to(character, icon_updates)

/**
 * Applies the given preferences to a human mob.
 *
 * Arguments:
 * * character - The human mob to apply the preferences to
 * * icon_updates - Whether to update the mob's icons after applying preferences.
 * Is often skipped to save processing when an update will happen later anyway.
 * * do_not_apply - A list of preference types to skip when applying preferences.
 */
/datum/preferences/proc/apply_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE, list/do_not_apply, visuals_only = FALSE) // NOVA EDIT CHANGE - ORIGINAL: /datum/preferences/proc/apply_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE, list/do_not_apply)
	character.dna.features = MANDATORY_FEATURE_LIST // NOVA EDIT CHANGE - We need to instansiate the list with the basic features. - ORIGINAL: character.dna.features = list()

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.savefile_identifier != PREFERENCE_CHARACTER)
			continue
		if (preference.type in do_not_apply)
			continue

		preference.apply_to_human(character, read_preference(preference.type), src) // NOVA EDIT CHANGE - ORIGINAL: preference.apply_to_human(character, read_preference(preference.type))

	// NOVA EDIT ADDITION START - middleware apply human prefs
	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		preference_middleware.apply_to_human(character, src, visuals_only = visuals_only)
	// NOVA EDIT ADDITION END

	character.dna.real_name = character.real_name

	if(icon_updates)
		character.icon_render_keys = list()
		character.update_body(is_creating = TRUE)

	SEND_SIGNAL(character, COMSIG_HUMAN_PREFS_APPLIED)

/// Returns whether the parent mob should have the random hardcore settings enabled. Assumes it has a mind.
/datum/preferences/proc/should_be_random_hardcore(datum/job/job, datum/mind/mind)
	if(!read_preference(/datum/preference/toggle/random_hardcore))
		return FALSE
	if(job.job_flags & JOB_HEAD_OF_STAFF) //No heads of staff
		return FALSE
	for(var/datum/antagonist/antag as anything in mind.antag_datums)
		if(antag.get_team()) //No team antags
			return FALSE
	return TRUE

/// Inverts the key_bindings list such that it can be used for key_bindings_by_key
/datum/preferences/proc/get_key_bindings_by_key(list/key_bindings)
	var/list/output = list()

	for (var/action in key_bindings)
		for (var/key in key_bindings[action])
			LAZYADD(output[key], action)

	return output

/// Returns the default `randomise` variable ouptut
/datum/preferences/proc/get_default_randomization()
	var/list/default_randomization = list()

	for (var/preference_key in GLOB.preference_entries_by_key)
		var/datum/preference/preference = GLOB.preference_entries_by_key[preference_key]
		if (preference.is_randomizable() && preference.randomize_by_default)
			default_randomization[preference_key] = RANDOM_ENABLED

	return default_randomization

/datum/preferences/proc/refresh_membership()
	var/byond_member = parent.IsByondMember()
	if(isnull(byond_member)) // Connection failure, retry once
		byond_member = parent.IsByondMember()
		var/static/admins_warned = FALSE
		if(!admins_warned)
			admins_warned = TRUE
			message_admins("BYOND membership lookup had a connection failure for a user. This is most likely an issue on the BYOND side but if this consistently happens you should bother your server operator to look into it.")
		if(isnull(byond_member)) // Retrying didn't work, warn the user
			log_game("BYOND membership lookup for [parent.ckey] failed due to a connection error.")
		else
			log_game("BYOND membership lookup for [parent.ckey] failed due to a connection error but succeeded after retry.")

	if(isnull(byond_member))
		to_chat(parent, span_warning("There's been a connection failure while trying to check the status of your BYOND membership. Reconnecting may fix the issue, or BYOND could be experiencing downtime."))

	unlock_content = !!byond_member
	donator_status = !!GLOB.donator_list[parent.ckey] // NOVA EDIT ADDITION - DONATOR CHECK
	if(unlock_content || donator_status) // NOVA EDIT CHANGE - ORIGINAL: if(unlock_content)
		max_save_slots = 50 //NOVA EDIT - ORIGINAL: max_save_slots = 8


// BEGIN NOVA CORE MIGRATION: code/modules/client/preferences.dm
#define MAX_MUTANT_ROWS 4

/datum/preferences
	/// Associative list, keyed by language typepath, pointing to LANGUAGE_UNDERSTOOD, or LANGUAGE_SPOKEN, for whether we understand or speak the language
	var/list/languages = list()
	/// List of chosen augmentations. It's an associative list with key name of the slot, pointing to a typepath of an augment define
	var/list/augments = list()
	/// List of chosen preferred styles for limb replacements
	var/list/augment_limb_styles = list()
	/// Which augment slot we currently have chosen, this is for UI display
	var/chosen_augment_slot
	/// A list of all bodymarkings
	var/list/list/body_markings = list()

	/// Will the person see accessories not meant for their species to choose from
	var/mismatched_customization = FALSE

	/// Allows the user to freely color his body markings and mutant parts.
	var/allow_advanced_colors = FALSE

	/// Preference of how the preview should show the character.
	var/preview_pref = PREVIEW_PREF_JOB

	var/needs_update = TRUE

	var/arousal_preview = AROUSAL_NONE

	// BACKGROUND STUFF
	var/general_record = ""
	var/security_record = ""
	var/medical_record = ""

	var/background_info = ""
	var/exploitable_info = ""

	/// Whether the user wants to see body size being shown in the preview
	var/show_body_size = FALSE

	/// Alternative job titles stored in preferences. Assoc list, ie. alt_job_titles["Scientist"] = "Cytologist"
	var/list/alt_job_titles = list()

	// Determines if the player has undergone TGUI preferences migration, if so, this will prevent constant loading.
	var/tgui_prefs_migration = TRUE

	/// An assoc list of food types to liked or dislike values. If null or empty, default species tastes are used instead on application.
	/// If a food doesn't exist in this list, it uses the default value.
	var/list/food_preferences = list()

/datum/preferences/proc/species_updated(species_type)
	all_quirks = list()
	// Reset cultural stuff
	reset_languages_to_species_defaults()
	save_character()

/datum/preferences/proc/reset_languages_to_species_defaults()
	languages = get_default_species_languages()

/datum/preferences/proc/get_default_species_languages()
	var/list/default_languages = list()
	var/datum/species/species_type = read_preference(/datum/preference/choiced/species)
	if(!ispath(species_type))
		return default_languages

	var/datum/language_holder/language_holder = GLOB.prototype_language_holders[species_type::species_language_holder]
	if(isnull(language_holder))
		return default_languages

	for(var/language in language_holder.spoken_languages)
		default_languages[language] = LANGUAGE_SPOKEN

	return default_languages

/// Tries to get the topmost language of the language holder. Should be the species' native language, and if it isn't, you should pester a coder.
/datum/preferences/proc/try_get_common_language()
	var/datum/species/species_type = read_preference(/datum/preference/choiced/species)
	var/datum/language_holder/language_holder = GLOB.prototype_language_holders[species_type::species_language_holder]
	var/language = language_holder.spoken_languages[1]
	return language

/datum/preferences/proc/CanBuyAugment(datum/augment_item/target_aug, datum/augment_item/current_aug)
	// Check biotypes
	var/species_type = read_preference(/datum/preference/choiced/species)
	var/datum/species/current_species = GLOB.species_prototypes[species_type]
	if(!(current_species.inherent_biotypes & target_aug.allowed_biotypes))
		return
	var/quirk_points = GetQuirkBalance()
	var/leverage = 0
	if(current_aug)
		leverage += current_aug.cost
	if((quirk_points + leverage)>= target_aug.cost)
		return TRUE
	else
		return FALSE

/// This proc saves the damage currently on `character` (human) and reapplies it after `safe_transfer_prefs()` is applied to the `character`.
/datum/preferences/proc/safe_transfer_prefs_to_with_damage(mob/living/carbon/human/character, icon_updates = TRUE, is_antag = FALSE)
	if(!istype(character))
		return FALSE

	var/datum/component/damage_tracker/human/added_tracker = character.AddComponent(/datum/component/damage_tracker/human)
	if(!added_tracker)
		return FALSE

	safe_transfer_prefs_to(character, icon_updates, is_antag)
	qdel(added_tracker)

// Updates the mob's chat color in the global cache
/datum/preferences/safe_transfer_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE, is_antag = FALSE)
	. = ..()
	GLOB.chat_colors_by_mob_name[character.name] = list(character.chat_color, character.chat_color_darkened) // by now the mob has had its prefs applied to it
// END NOVA CORE MIGRATION: code/modules/client/preferences.dm
