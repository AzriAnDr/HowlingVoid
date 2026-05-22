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
	/// Whether animated item sprites should play in character previews.
	var/preview_item_animations_enabled = FALSE

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
		return
	if(!character_preview_view || QDELETED(character_preview_view))
		character_preview_view = create_character_preview_view(user)
	else
		character_preview_view.update_body()
	ui = new(user, src, "PreferencesMenu", null, 1080, 920)
	ui.set_autoupdate(FALSE)
	ui.open()

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
	data["character_preview_direction"] = dir2text(character_preview_view?.dir || SOUTH)
	data["character_preview_url"] = character_preview_view?.get_preview_url(user)
	data["character_preview_urls"] = character_preview_view?.get_preview_urls(user)
	data["character_preview_animations"] = character_preview_view?.get_preview_animations(user)
	data["preview_item_animations_enabled"] = preview_item_animations_enabled
	data["preview_animations"] = data["character_preview_animations"]
	data["preview_direction"] = data["character_preview_direction"]
	data["preview_url"] = data["character_preview_url"]
	data["preview_urls"] = data["character_preview_urls"]

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

		if("toggle_preview_item_animations")
			preview_item_animations_enabled = !preview_item_animations_enabled
			character_preview_view?.clear_preview_assets()
			if(character_preview_view)
				character_preview_view.preview_asset_dirty = TRUE
			SStgui.update_uis(src)
			return TRUE

		if("prime_preview_direction")
			var/requested_direction = text2dir(params["direction"])
			if(!requested_direction)
				requested_direction = SOUTH
			character_preview_view?.setDir(requested_direction)
			character_preview_view?.get_preview_url(usr, requested_direction)
			SStgui.update_uis(src)
			return TRUE

		if("open_preview_window")
			open_preview_window(usr)
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
	character_preview_view = new(null, src)
	character_preview_view.update_body()

	return character_preview_view

/datum/preferences/proc/open_preview_window(mob/user)
	if(!user || user.client != parent)
		return FALSE

	for(var/datum/tgui/open_ui as anything in open_uis)
		if(open_ui.user == user && open_ui.interface == "CharacterPreviewWindow")
			return TRUE

	var/datum/tgui/ui = new(user, src, "CharacterPreviewWindow", "Character Preview", 700, 760)
	ui.open()
	ui.set_autoupdate(TRUE)
	return TRUE

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
	var/list/preview_asset_names
	var/list/preview_asset_urls
	var/list/preview_animation_data
	var/preview_asset_dirty = TRUE
	// NOVA EDIT ADDITION END

/atom/movable/screen/map_view/char_preview/Initialize(mapload, datum/preferences/preferences)
	. = ..()
	src.preferences = preferences

/atom/movable/screen/map_view/char_preview/Destroy()
	// NOVA EDIT ADDITION START: Better character preview
	canvas?.cut_overlays()
	canvas = null
	// NOVA EDIT ADDITION END
	preview_asset_names = null
	preview_asset_urls = null
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
				canvas = image('modular_nova/modules/character_preview_background/icons/background_32x32.dmi', icon_state = canvas_state)
			if (1)
				canvas = image('modular_nova/modules/character_preview_background/icons/background_64x64.dmi', icon_state = canvas_state)
			if (2)
				canvas = image('modular_nova/modules/character_preview_background/icons/background_96x96.dmi', icon_state = canvas_state)

	// Update the map view bounds when canvas size changes to properly display the scaled preview
	set_position(1, 1)
	last_canvas_size = canvas_size
	last_canvas_state = canvas_state

	canvas.cut_overlays()
	canvas.add_overlay(body.appearance)

	appearance = canvas.appearance
	clear_preview_assets()
	preview_asset_dirty = TRUE
	// NOVA EDIT ADDITION END

/atom/movable/screen/map_view/char_preview/proc/clear_preview_assets()
	preview_asset_names = null
	preview_asset_urls = null
	preview_animation_data = null

/atom/movable/screen/map_view/char_preview/proc/preview_item_animations_enabled()
	return !!preferences?.preview_item_animations_enabled

/atom/movable/screen/map_view/char_preview/proc/refresh_preview_appearance(preview_dir = dir)
	if(isnull(body) || isnull(canvas))
		update_body()
	if(isnull(body) || isnull(canvas))
		return FALSE

	body.setDir(preview_dir)
	canvas.cut_overlays()
	canvas.add_overlay(body.appearance)
	appearance = canvas.appearance
	return TRUE

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

/atom/movable/screen/map_view/char_preview/proc/build_preview_background_icon(required_width = ICON_SIZE_X, required_height = ICON_SIZE_Y)
	var/canvas_state = preferences.read_preference(/datum/preference/choiced/background_state)
	switch(get_preview_canvas_size(required_width, required_height))
		if(0)
			return icon('modular_nova/modules/character_preview_background/icons/background_32x32.dmi', canvas_state)
		if(1)
			return icon('modular_nova/modules/character_preview_background/icons/background_64x64.dmi', canvas_state)
		if(2)
			return icon('modular_nova/modules/character_preview_background/icons/background_96x96.dmi', canvas_state)

	return icon('icons/blanks/32x32.dmi', "nothing")

/atom/movable/screen/map_view/char_preview/proc/get_preview_flat_appearance_bounds(appearance_to_measure)
	if(isnull(appearance_to_measure))
		return null

	var/mutable_appearance/render_appearance = new /mutable_appearance(appearance_to_measure)
	if(render_appearance.alpha <= 0)
		return null

	var/base_width = ICON_SIZE_X
	var/base_height = ICON_SIZE_Y
	if(render_appearance.icon)
		var/list/base_dimensions = get_icon_dimensions(render_appearance.icon)
		if(isnum(base_dimensions["width"]) && base_dimensions["width"] > 0)
			base_width = base_dimensions["width"]
		if(isnum(base_dimensions["height"]) && base_dimensions["height"] > 0)
			base_height = base_dimensions["height"]

	var/flat_x1 = 1
	var/flat_x2 = base_width
	var/flat_y1 = 1
	var/flat_y2 = base_height

	for(var/layer_appearance as anything in render_appearance.underlays)
		var/mutable_appearance/underlay = new /mutable_appearance(layer_appearance)
		if(underlay.alpha <= 0)
			continue
		if(underlay.plane != FLOAT_PLANE && underlay.plane != render_appearance.plane)
			continue
		var/list/underlay_bounds = get_preview_flat_appearance_bounds(underlay)
		if(!islist(underlay_bounds))
			continue
		flat_x1 = min(flat_x1, underlay.pixel_x + underlay.pixel_w + 1)
		flat_x2 = max(flat_x2, underlay.pixel_x + underlay.pixel_w + underlay_bounds["width"])
		flat_y1 = min(flat_y1, underlay.pixel_y + underlay.pixel_z + 1)
		flat_y2 = max(flat_y2, underlay.pixel_y + underlay.pixel_z + underlay_bounds["height"])

	for(var/layer_appearance as anything in render_appearance.overlays)
		var/mutable_appearance/overlay = new /mutable_appearance(layer_appearance)
		if(overlay.alpha <= 0)
			continue
		if(overlay.plane != FLOAT_PLANE && overlay.plane != render_appearance.plane)
			continue
		var/list/overlay_bounds = get_preview_flat_appearance_bounds(overlay)
		if(!islist(overlay_bounds))
			continue
		flat_x1 = min(flat_x1, overlay.pixel_x + overlay.pixel_w + 1)
		flat_x2 = max(flat_x2, overlay.pixel_x + overlay.pixel_w + overlay_bounds["width"])
		flat_y1 = min(flat_y1, overlay.pixel_y + overlay.pixel_z + 1)
		flat_y2 = max(flat_y2, overlay.pixel_y + overlay.pixel_z + overlay_bounds["height"])

	return list(
		"x1" = flat_x1,
		"x2" = flat_x2,
		"y1" = flat_y1,
		"y2" = flat_y2,
		"width" = flat_x2 - flat_x1 + 1,
		"height" = flat_y2 - flat_y1 + 1,
		"base_width" = base_width,
		"base_height" = base_height,
	)

/atom/movable/screen/map_view/char_preview/proc/pixel_scale_preview_icon(icon/source_icon, target_width, target_height)
	if(!isicon(source_icon))
		return null

	target_width = max(round(target_width), 1)
	target_height = max(round(target_height), 1)

	var/source_width = source_icon.Width()
	var/source_height = source_icon.Height()
	if(source_width <= 0 || source_height <= 0)
		return null
	if(source_width == target_width && source_height == target_height)
		return icon(source_icon)

	var/icon/scaled_icon = icon('icons/blanks/32x32.dmi', "nothing")
	scaled_icon.Scale(target_width, target_height)

	for(var/x in 1 to target_width)
		var/source_x = clamp(round(((x - 0.5) * source_width / target_width) + 0.5), 1, source_width)
		for(var/y in 1 to target_height)
			var/source_y = clamp(round(((y - 0.5) * source_height / target_height) + 0.5), 1, source_height)
			var/pixel = source_icon.GetPixel(source_x, source_y)
			if(!pixel)
				continue
			if(length(pixel) == 7)
				pixel += "ff"
			if(length(pixel) >= 9 && copytext(pixel, 8, 10) == "00")
				continue
			scaled_icon.DrawBox(pixel, x, y)

	return scaled_icon

/atom/movable/screen/map_view/char_preview/proc/scale_preview_body_icon(icon/body_icon)
	if(!isicon(body_icon))
		return null

	var/body_scale = get_preview_body_size_scale()
	var/height_scale = get_preview_height_scale()
	if(body_scale == BODY_SIZE_NORMAL && height_scale == 1)
		return body_icon

	var/list/body_dimensions = get_icon_dimensions(body_icon)
	var/scaled_width = max(CEILING(body_dimensions["width"] * body_scale, 1), 1)
	var/scaled_height = max(CEILING(body_dimensions["height"] * body_scale * height_scale, 1), 1)
	if(scaled_width < body_dimensions["width"] || scaled_height < body_dimensions["height"])
		return pixel_scale_preview_icon(body_icon, scaled_width, scaled_height)
	var/icon/scaled_icon = icon(body_icon)
	scaled_icon.Scale(scaled_width, scaled_height)
	return scaled_icon

/atom/movable/screen/map_view/char_preview/proc/build_body_preview_icon(preview_dir = dir, no_anim = TRUE)
	if(!refresh_preview_appearance(preview_dir))
		return null

	var/icon/body_icon = getFlatIcon(body, defdir = preview_dir, no_anim = no_anim)
	return scale_preview_body_icon(body_icon)

/atom/movable/screen/map_view/char_preview/proc/composite_preview_icon(icon/body_icon, list/body_bounds = null)
	if(!isicon(body_icon))
		return null

	var/list/body_dimensions = get_icon_dimensions(body_icon)
	var/icon/output_icon
	if(canvas?.icon)
		output_icon = icon(canvas.icon, canvas.icon_state)
	else
		output_icon = build_preview_background_icon(body_dimensions["width"], body_dimensions["height"])
	var/list/output_dimensions = get_icon_dimensions(output_icon)
	var/output_width = output_dimensions["width"]

	var/offset_x = round((output_width - body_dimensions["width"]) * 0.5) + 1
	if(islist(body_bounds))
		var/body_scale = get_preview_body_size_scale()
		var/base_width = max(CEILING(body_bounds["base_width"] * body_scale, 1), 1)
		var/left_extension = max(CEILING((1 - body_bounds["x1"]) * body_scale, 1), 0)
		var/desired_root_left = round((output_width - base_width) * 0.5) + 1
		offset_x = desired_root_left - left_extension
		var/min_offset_x = min(1, output_width - body_dimensions["width"] + 1)
		var/max_offset_x = max(1, output_width - body_dimensions["width"] + 1)
		offset_x = clamp(offset_x, min_offset_x, max_offset_x)
	output_icon.Blend(body_icon, ICON_OVERLAY, offset_x, 1)
	return output_icon

/atom/movable/screen/map_view/char_preview/proc/build_preview_icon(preview_dir = dir, no_anim = TRUE)
	var/icon/body_icon
	var/list/body_bounds
	if(no_anim)
		var/list/body_frame_data = build_body_preview_frame_data(preview_dir, 0)
		body_icon = body_frame_data?["icon"]
		body_bounds = body_frame_data?["bounds"]
	else
		body_icon = build_body_preview_icon(preview_dir, no_anim)
	return composite_preview_icon(body_icon, body_bounds)

/atom/movable/screen/map_view/char_preview/proc/get_preview_icon_metadata(icon/preview_icon)
	if(!isicon(preview_icon))
		return null

	var/tmp_file = "tmp/character-preview-[rand(1, 999999)].dmi"
	fcopy(preview_icon, tmp_file)
	var/list/metadata = icon_metadata(file(tmp_file))
	fdel(tmp_file)
	return metadata


/atom/movable/screen/map_view/char_preview/proc/get_preview_icon_state_data(icon/preview_icon)
	var/list/metadata = get_preview_icon_metadata(preview_icon)
	if(!islist(metadata) || !islist(metadata["states"]) || !length(metadata["states"]))
		return null

	return metadata["states"][1]

/atom/movable/screen/map_view/char_preview/proc/collapse_preview_icon_frame(icon/source_icon, forced_width = null, forced_height = null)
	if(!isicon(source_icon))
		return null

	var/source_width = forced_width
	var/source_height = forced_height
	if(!isnum(source_width) || !isnum(source_height) || source_width <= 0 || source_height <= 0)
		var/list/source_metadata = get_preview_icon_metadata(source_icon)
		source_width = source_metadata?["width"]
		source_height = source_metadata?["height"]
	if(!isnum(source_width) || !isnum(source_height) || source_width <= 0 || source_height <= 0)
		var/list/source_dimensions = get_icon_dimensions(source_icon)
		source_width = source_dimensions["width"]
		source_height = source_dimensions["height"]
	if(!isnum(source_width) || !isnum(source_height) || source_width <= 0 || source_height <= 0)
		return null

	var/icon/collapsed_icon = icon(source_icon)
	collapsed_icon.Crop(1, 1, source_width, source_height)
	return collapsed_icon

/atom/movable/screen/map_view/char_preview/proc/get_preview_file_state_data(icon_file, icon_state)
	if(!icon_file)
		return null

	var/list/metadata = icon_metadata(icon_file)
	if(!islist(metadata) || !islist(metadata["states"]) || !length(metadata["states"]))
		return null

	if(length(icon_state))
		for(var/list/state_data as anything in metadata["states"])
			if(state_data["name"] == icon_state)
				return state_data
		return null

	for(var/list/state_data as anything in metadata["states"])
		if(!length(state_data["name"]))
			return state_data

	return length(metadata["states"]) == 1 ? metadata["states"][1] : null

/atom/movable/screen/map_view/char_preview/proc/get_preview_state_delays(list/state_data)
	if(!islist(state_data))
		return null

	var/list/raw_delay_list = state_data["delays"]
	if(islist(raw_delay_list))
		var/list/delay_copy = list()
		for(var/delay_value as anything in raw_delay_list)
			delay_copy += delay_value
		return delay_copy

	var/raw_delay_value = state_data["delay"]
	raw_delay_list = raw_delay_value
	if(islist(raw_delay_list))
		var/list/legacy_delay_copy = list()
		for(var/delay_value as anything in raw_delay_list)
			legacy_delay_copy += delay_value
		return legacy_delay_copy

	if(isnum(raw_delay_value))
		return list(raw_delay_value)

	if(istext(raw_delay_value) && length(raw_delay_value))
		var/list/parsed_delays = list()
		for(var/delay_value in splittext(raw_delay_value, ","))
			parsed_delays += text2num("[delay_value]")
		return length(parsed_delays) ? parsed_delays : null

	return null

/atom/movable/screen/map_view/char_preview/proc/copy_preview_delay_list(list/source_delays)
	if(!islist(source_delays))
		return null

	var/list/delay_copy = list()
	for(var/delay_value as anything in source_delays)
		delay_copy += delay_value
	return delay_copy

/atom/movable/screen/map_view/char_preview/proc/get_preview_state_frame_count(list/state_data)
	if(!islist(state_data))
		return 1

	var/frame_count = 1
	var/raw_frame_count = state_data["frames"]
	if(isnum(raw_frame_count))
		frame_count = max(raw_frame_count, 1)
	else if(!isnull(raw_frame_count))
		frame_count = max(text2num("[raw_frame_count]"), 1)
	var/list/delays = get_preview_state_delays(state_data)
	if(islist(delays))
		frame_count = max(frame_count, length(delays))

	return frame_count

/atom/movable/screen/map_view/char_preview/proc/get_preview_state_delay_value(list/state_data, frame_index)
	var/list/delays = get_preview_state_delays(state_data)
	if(!islist(delays) || !length(delays))
		return 1

	var/delay_index = min(max(round(frame_index), 1), length(delays))
	var/delay_value = delays[delay_index]
	if(!isnum(delay_value))
		delay_value = text2num("[delay_value]")
	if(!isnum(delay_value) || delay_value <= 0)
		return 1

	return delay_value

/atom/movable/screen/map_view/char_preview/proc/get_preview_state_sequence_frames(list/state_data)
	if(!islist(state_data))
		return null

	var/frame_count = get_preview_state_frame_count(state_data)
	if(frame_count <= 0)
		return null

	var/list/sequence_frames = list()
	for(var/frame_index in 1 to frame_count)
		sequence_frames += frame_index

	if(state_data?["rewind"] && frame_count > 1)
		for(var/frame_index = frame_count - 1, frame_index >= 2, frame_index--)
			sequence_frames += frame_index

	return sequence_frames

/atom/movable/screen/map_view/char_preview/proc/get_preview_state_sequence_delays(list/state_data)
	var/list/sequence_frames = get_preview_state_sequence_frames(state_data)
	if(!islist(sequence_frames) || !length(sequence_frames))
		return null

	var/list/sequence_delays = list()
	for(var/frame_index as anything in sequence_frames)
		sequence_delays += get_preview_state_delay_value(state_data, frame_index)

	return sequence_delays

/atom/movable/screen/map_view/char_preview/proc/get_preview_state_cycle_duration(list/state_data)
	var/list/sequence_delays = get_preview_state_sequence_delays(state_data)
	if(!islist(sequence_delays) || !length(sequence_delays))
		return 0

	var/total_duration = 0
	for(var/delay_value as anything in sequence_delays)
		total_duration += delay_value

	return total_duration

/atom/movable/screen/map_view/char_preview/proc/get_preview_state_frame_at_elapsed(list/state_data, elapsed_time)
	if(isnull(elapsed_time))
		return null

	var/frame_count = get_preview_state_frame_count(state_data)
	if(frame_count <= 1)
		return 1

	var/total_duration = get_preview_state_cycle_duration(state_data)
	if(total_duration <= 0)
		return 1

	var/list/sequence_frames = get_preview_state_sequence_frames(state_data)
	var/list/sequence_delays = get_preview_state_sequence_delays(state_data)
	if(!islist(sequence_frames) || !islist(sequence_delays) || !length(sequence_frames) || !length(sequence_delays))
		return 1

	var/time_in_cycle = elapsed_time % total_duration
	if(time_in_cycle < 0)
		time_in_cycle += total_duration

	for(var/sequence_index in 1 to length(sequence_frames))
		var/delay_value = sequence_delays[sequence_index]
		if(time_in_cycle < delay_value)
			return sequence_frames[sequence_index]
		time_in_cycle -= delay_value

	return sequence_frames[length(sequence_frames)]

/atom/movable/screen/map_view/char_preview/proc/get_preview_appearance_state_data(appearance_to_render)
	if(isnull(appearance_to_render))
		return null

	var/mutable_appearance/render_appearance = new /mutable_appearance(appearance_to_render)
	var/render_icon = render_appearance.icon
	if(!render_icon)
		return null

	var/render_state = render_appearance.icon_state
	var/list/file_state_data = get_preview_file_state_data(render_icon, render_state)
	if(islist(file_state_data))
		return file_state_data

	var/icon/appearance_icon = get_preview_metadata_icon(appearance_to_render)
	if(!isicon(appearance_icon))
		return null

	return get_preview_icon_state_data(appearance_icon)

/atom/movable/screen/map_view/char_preview/proc/get_preview_metadata_icon(appearance_to_render)
	if(isnull(appearance_to_render))
		return null

	var/mutable_appearance/render_appearance = new /mutable_appearance(appearance_to_render)
	var/render_icon = render_appearance.icon
	if(!render_icon)
		return null

	var/render_state = render_appearance.icon_state

	if(isicon(render_icon) && !length(render_state))
		return icon(render_icon)

	if(!icon_exists(render_icon, render_state))
		if(icon_exists(render_icon, ""))
			render_state = ""
		else
			return null

	return icon(render_icon, render_state)

/atom/movable/screen/map_view/char_preview/proc/find_first_animated_preview_layer(appearance_to_check)
	if(isnull(appearance_to_check))
		return null

	var/list/state_data = get_preview_appearance_state_data(appearance_to_check)
	var/list/delays = get_preview_state_delays(state_data)
	var/frame_count = get_preview_state_frame_count(state_data)
	if(frame_count > 1)
		var/icon_text = "[appearance_to_check:icon]"
		if(length(icon_text) > 48)
			icon_text = copytext(icon_text, length(icon_text) - 47)
		var/state_text = "[appearance_to_check:icon_state]"
		if(!length(state_text))
			state_text = "<blank>"
		return "[icon_text] [state_text] f=[frame_count] d=[length(delays)]"

	var/list/underlays = appearance_to_check:underlays
	for(var/underlay_appearance as anything in underlays)
		var/underlay_result = find_first_animated_preview_layer(underlay_appearance)
		if(underlay_result)
			return underlay_result

	var/list/overlays = appearance_to_check:overlays
	for(var/overlay_appearance as anything in overlays)
		var/overlay_result = find_first_animated_preview_layer(overlay_appearance)
		if(overlay_result)
			return overlay_result

	return null

/atom/movable/screen/map_view/char_preview/proc/find_first_animated_preview_layer_in_value(value)
	if(isnull(value))
		return null

	if(islist(value))
		for(var/entry as anything in value)
			var/list_result = find_first_animated_preview_layer(entry)
			if(list_result)
				return list_result
		return null

	return find_first_animated_preview_layer(value)

/atom/movable/screen/map_view/char_preview/proc/get_preview_appearance_icon(appearance_to_render, preview_dir = dir, frame_index)
	if(isnull(appearance_to_render))
		return null

	var/mutable_appearance/render_appearance = new /mutable_appearance(appearance_to_render)
	var/render_icon = render_appearance.icon
	if(!render_icon)
		return null

	var/render_state = render_appearance.icon_state
	var/render_dir = (!render_appearance.dir || render_appearance.dir == SOUTH) ? preview_dir : render_appearance.dir

	if(isicon(render_icon) && !length(render_state))
		var/list/render_icon_metadata = get_preview_icon_metadata(render_icon)
		var/render_icon_width = render_icon_metadata?["width"]
		var/render_icon_height = render_icon_metadata?["height"]
		var/list/icon_state_data = get_preview_icon_state_data(render_icon)
		var/resolved_icon_frame = get_preview_state_frame_at_elapsed(icon_state_data, frame_index)
		if(isnull(frame_index))
			return collapse_preview_icon_frame(icon(render_icon, dir = render_dir, frame = 1), render_icon_width, render_icon_height)
		if(isnull(resolved_icon_frame))
			resolved_icon_frame = 1
		return collapse_preview_icon_frame(icon(render_icon, dir = render_dir, frame = resolved_icon_frame), render_icon_width, render_icon_height)

	if(!icon_exists(render_icon, render_state))
		if(icon_exists(render_icon, ""))
			render_state = ""
		else
			return null

	var/list/render_icon_dimensions = get_icon_dimensions(render_icon)
	var/render_icon_width = render_icon_dimensions["width"]
	var/render_icon_height = render_icon_dimensions["height"]
	var/list/state_data = get_preview_file_state_data(render_icon, render_state)
	var/resolved_frame_index = get_preview_state_frame_at_elapsed(state_data, frame_index)
	if(isnull(frame_index))
		return collapse_preview_icon_frame(icon(render_icon, render_state, render_dir, frame = 1), render_icon_width, render_icon_height)

	if(isnull(resolved_frame_index))
		return collapse_preview_icon_frame(icon(render_icon, render_state, render_dir, frame = 1), render_icon_width, render_icon_height)

	return collapse_preview_icon_frame(icon(render_icon, render_state, render_dir, frame = resolved_frame_index), render_icon_width, render_icon_height)


/atom/movable/screen/map_view/char_preview/proc/collect_body_preview_animation_state_data(appearance_to_check = body, list/current_states = null)
	if(!islist(current_states))
		current_states = list()

	if(isnull(appearance_to_check))
		return current_states

	var/list/state_data = get_preview_appearance_state_data(appearance_to_check)
	if(get_preview_state_frame_count(state_data) > 1)
		current_states += null
		current_states[length(current_states)] = state_data

	var/list/current_underlays = appearance_to_check:underlays
	for(var/underlay_appearance as anything in current_underlays)
		collect_body_preview_animation_state_data(underlay_appearance, current_states)

	var/list/current_overlays = appearance_to_check:overlays
	for(var/overlay_appearance as anything in current_overlays)
		collect_body_preview_animation_state_data(overlay_appearance, current_states)

	return current_states

/atom/movable/screen/map_view/char_preview/proc/get_preview_animation_runtime_signature(list/runtime_entries)
	if(!islist(runtime_entries) || !length(runtime_entries))
		return ""

	var/list/signature_parts = list()
	for(var/list/runtime_entry as anything in runtime_entries)
		var/sequence_index = runtime_entry["sequence_index"]
		var/remaining_delay = runtime_entry["remaining_delay"]
		signature_parts += "[sequence_index]:[remaining_delay]"

	return jointext(signature_parts, "|")

/atom/movable/screen/map_view/char_preview/proc/build_preview_animation_timeline(preview_dir = dir)
	if(!refresh_preview_appearance(preview_dir))
		return list(
			"frames" = 1,
			"delays" = null,
			"rewind" = FALSE,
			"times" = list(0),
		)

	var/list/animated_states = collect_body_preview_animation_state_data(body)
	if(!length(animated_states))
		return list(
			"frames" = 1,
			"delays" = null,
			"rewind" = FALSE,
			"times" = list(0),
		)

	var/list/runtime_entries = list()
	for(var/list/state_data as anything in animated_states)
		var/list/sequence_frames = get_preview_state_sequence_frames(state_data)
		var/list/sequence_delays = get_preview_state_sequence_delays(state_data)
		if(!islist(sequence_frames) || !islist(sequence_delays) || !length(sequence_frames) || !length(sequence_delays))
			continue
		runtime_entries += null
		runtime_entries[length(runtime_entries)] = list(
			"frames" = sequence_frames,
			"delays" = sequence_delays,
			"sequence_index" = 1,
			"remaining_delay" = sequence_delays[1],
		)

	if(!length(runtime_entries))
		return list(
			"frames" = 1,
			"delays" = null,
			"rewind" = FALSE,
			"times" = list(0),
		)

	var/list/frame_times = list(0)
	var/list/composite_delays = list()
	var/initial_signature = get_preview_animation_runtime_signature(runtime_entries)
	var/list/seen_signatures = list()
	seen_signatures[initial_signature] = TRUE

	while(length(composite_delays) < 256)
		var/next_delay = null
		for(var/list/runtime_entry as anything in runtime_entries)
			var/remaining_delay = runtime_entry["remaining_delay"]
			if(!isnum(remaining_delay))
				remaining_delay = text2num("[remaining_delay]")
			if(!isnum(remaining_delay) || remaining_delay <= 0)
				remaining_delay = 1
			runtime_entry["remaining_delay"] = remaining_delay
			if(isnull(next_delay) || remaining_delay < next_delay)
				next_delay = remaining_delay

		if(isnull(next_delay))
			break

		composite_delays += next_delay
		var/current_time = frame_times[length(frame_times)]
		var/next_time = current_time + next_delay

		for(var/list/runtime_entry as anything in runtime_entries)
			var/remaining_delay = runtime_entry["remaining_delay"] - next_delay
			var/list/sequence_delays = runtime_entry["delays"]
			var/sequence_length = length(sequence_delays)
			while(remaining_delay <= 0 && sequence_length)
				var/sequence_index = runtime_entry["sequence_index"] + 1
				if(sequence_index > sequence_length)
					sequence_index = 1
				runtime_entry["sequence_index"] = sequence_index
				remaining_delay += sequence_delays[sequence_index]
			runtime_entry["remaining_delay"] = remaining_delay

		var/signature = get_preview_animation_runtime_signature(runtime_entries)
		if(signature == initial_signature)
			break
		if(seen_signatures[signature])
			break

		seen_signatures[signature] = TRUE
		frame_times += next_time

	if(!length(composite_delays))
		return list(
			"frames" = 1,
			"delays" = null,
			"rewind" = FALSE,
			"times" = list(0),
		)

	return list(
		"frames" = length(composite_delays),
		"delays" = copy_preview_delay_list(composite_delays),
		"rewind" = FALSE,
		"times" = frame_times,
	)

/atom/movable/screen/map_view/char_preview/proc/build_preview_frame_appearance(appearance_to_snapshot, preview_dir = dir, elapsed_time = 0)
	if(isnull(appearance_to_snapshot))
		return null

	var/mutable_appearance/source_appearance = new /mutable_appearance(appearance_to_snapshot)
	var/mutable_appearance/frame_appearance = new /mutable_appearance(source_appearance)
	var/icon/frame_icon = get_preview_appearance_icon(source_appearance, preview_dir, elapsed_time)
	if(isicon(frame_icon))
		frame_appearance.icon = frame_icon
		frame_appearance.icon_state = ""
		frame_appearance.dir = SOUTH

	var/list/frame_underlays = list()
	var/list/source_underlays = appearance_to_snapshot:underlays
	for(var/underlay_appearance as anything in source_underlays)
		var/mutable_appearance/frame_underlay = build_preview_frame_appearance(underlay_appearance, preview_dir, elapsed_time)
		if(!isnull(frame_underlay))
			frame_underlays += frame_underlay
	frame_appearance.vars["underlays"] = frame_underlays

	var/list/frame_overlays = list()
	var/list/source_overlays = appearance_to_snapshot:overlays
	for(var/overlay_appearance as anything in source_overlays)
		var/mutable_appearance/frame_overlay = build_preview_frame_appearance(overlay_appearance, preview_dir, elapsed_time)
		if(!isnull(frame_overlay))
			frame_overlays += frame_overlay
	frame_appearance.vars["overlays"] = frame_overlays

	return frame_appearance

/atom/movable/screen/map_view/char_preview/proc/build_body_preview_frame_icon(preview_dir = dir, elapsed_time = 0, skip_refresh = FALSE)
	var/list/frame_data = build_body_preview_frame_data(preview_dir, elapsed_time, skip_refresh)
	return frame_data?["icon"]

/atom/movable/screen/map_view/char_preview/proc/build_body_preview_frame_data(preview_dir = dir, elapsed_time = 0, skip_refresh = FALSE)
	if(!skip_refresh && !refresh_preview_appearance(preview_dir))
		return null

	var/mutable_appearance/frame_appearance = build_preview_frame_appearance(body, preview_dir, elapsed_time)
	if(isnull(frame_appearance))
		return null

	var/icon/frame_icon = getFlatIcon(frame_appearance, defdir = preview_dir, no_anim = TRUE)
	return list(
		"icon" = scale_preview_body_icon(frame_icon),
		"bounds" = get_preview_flat_appearance_bounds(frame_appearance),
	)

/atom/movable/screen/map_view/char_preview/proc/build_preview_strip(preview_dir = dir, list/frame_times)
	if(!islist(frame_times) || !length(frame_times))
		return null

	var/static/max_preview_strip_dimension = 2048

	if(!refresh_preview_appearance(preview_dir))
		return null

	var/list/first_frame_data = build_body_preview_frame_data(preview_dir, frame_times[1], TRUE)
	var/icon/first_frame_body_icon = first_frame_data?["icon"]
	if(!isicon(first_frame_body_icon))
		return null
	var/icon/first_frame_icon = composite_preview_icon(first_frame_body_icon, first_frame_data?["bounds"])
	if(!isicon(first_frame_icon))
		return null

	var/frame_count = length(frame_times)
	var/list/frame_dimensions = get_icon_dimensions(first_frame_icon)
	var/frame_width = frame_dimensions["width"]
	var/frame_height = frame_dimensions["height"]
	var/strip_width = frame_width * frame_count

	if(frame_width <= 0 || frame_height <= 0)
		return null
	if(strip_width > max_preview_strip_dimension)
		var/max_frame_count = max(round(max_preview_strip_dimension / frame_width), 1)
		frame_times = frame_times.Copy(1, max_frame_count + 1)
		frame_count = length(frame_times)
		strip_width = frame_width * frame_count
	if(strip_width > max_preview_strip_dimension || frame_height > max_preview_strip_dimension)
		return null

	var/icon/strip_icon = icon('icons/blanks/32x32.dmi', "nothing")
	strip_icon.Scale(strip_width, frame_height)

	for(var/frame_index in 1 to frame_count)
		var/elapsed_time = frame_times[frame_index]
		var/list/frame_data = frame_index == 1 ? first_frame_data : build_body_preview_frame_data(preview_dir, elapsed_time, TRUE)
		var/icon/frame_body_icon = frame_data?["icon"]
		if(!isicon(frame_body_icon))
			return null
		var/icon/frame_icon = frame_index == 1 ? first_frame_icon : composite_preview_icon(frame_body_icon, frame_data?["bounds"])
		if(!isicon(frame_icon))
			return null
		strip_icon.Blend(frame_icon, ICON_OVERLAY, ((frame_index - 1) * frame_width) + 1, 1)

	return list(
		"icon" = strip_icon,
		"frames" = frame_count,
		"width" = frame_width,
		"height" = frame_height,
	)

/atom/movable/screen/map_view/char_preview/proc/get_preview_animation_entry(mob/target, preview_dir = dir)
	var/direction_key = dir2text(preview_dir)
	if(isnull(direction_key))
		direction_key = "south"

	if(preview_asset_dirty)
		clear_preview_assets()

	LAZYINITLIST(preview_asset_names)
	LAZYINITLIST(preview_asset_urls)
	LAZYINITLIST(preview_animation_data)

	if(isnull(preview_asset_names[direction_key]) || !SSassets.cache[preview_asset_names[direction_key]])
		var/icon/output_icon
		var/list/output_animation_data

		if(!preview_item_animations_enabled())
			output_icon = build_preview_icon(preview_dir, TRUE)
			if(isnull(output_icon))
				return null

			var/list/static_dimensions = get_icon_dimensions(output_icon)
			output_animation_data = list(
				"frames" = 1,
				"delays" = null,
				"rewind" = FALSE,
				"width" = static_dimensions["width"],
				"height" = static_dimensions["height"],
			)
		else
			var/list/timeline_data = build_preview_animation_timeline(preview_dir)
			var/list/delays = timeline_data?["delays"]
			var/list/frame_times = timeline_data?["times"]
			var/frame_count = islist(timeline_data) && !isnull(timeline_data["frames"]) ? max(timeline_data["frames"], 1) : 1

			if(frame_count <= 1)
				output_icon = build_preview_icon(preview_dir, TRUE)
				if(isnull(output_icon))
					return null

				var/list/static_dimensions = get_icon_dimensions(output_icon)
				output_animation_data = list(
					"frames" = 1,
					"delays" = null,
					"rewind" = FALSE,
					"width" = static_dimensions["width"],
					"height" = static_dimensions["height"],
				)
			else
				var/list/strip_data = build_preview_strip(preview_dir, frame_times)
				if(!islist(strip_data) || isnull(strip_data["icon"]))
					output_icon = build_preview_icon(preview_dir, TRUE)
					if(isnull(output_icon))
						return null

					var/list/static_dimensions = get_icon_dimensions(output_icon)
					output_animation_data = list(
						"frames" = 1,
						"delays" = null,
						"rewind" = FALSE,
						"width" = static_dimensions["width"],
						"height" = static_dimensions["height"],
					)
				else
					var/actual_frame_count = max(strip_data["frames"], 1)
					var/list/output_delays = null
					if(islist(delays) && length(delays))
						output_delays = copy_preview_delay_list(delays.Copy(1, actual_frame_count + 1))
					output_icon = strip_data["icon"]
					output_animation_data = list(
						"frames" = actual_frame_count,
						"delays" = output_delays,
						"rewind" = FALSE,
						"width" = strip_data["width"],
						"height" = strip_data["height"],
					)

		var/list/name_and_ref = generate_and_hash_rsc_file(output_icon)
		var/rsc_ref = name_and_ref[1]
		var/file_hash = name_and_ref[2]
		preview_asset_names[direction_key] = "[name_and_ref[3]].png"

		if(!SSassets.cache[preview_asset_names[direction_key]])
			SSassets.transport.register_asset(preview_asset_names[direction_key], rsc_ref, file_hash)

		preview_asset_urls[direction_key] = SSassets.transport.get_asset_url(preview_asset_names[direction_key])
		preview_animation_data[direction_key] = output_animation_data
		preview_asset_dirty = FALSE

	if(target && preview_asset_names[direction_key])
		SSassets.transport.send_assets(target, preview_asset_names[direction_key])

	return preview_animation_data[direction_key]

/atom/movable/screen/map_view/char_preview/proc/preload_preview_assets(mob/target)
	var/preloaded_assets = FALSE
	for(var/preview_dir in GLOB.cardinals)
		if(isnull(get_preview_animation_entry(target, preview_dir)))
			return FALSE
		preloaded_assets = TRUE
	return preloaded_assets

/atom/movable/screen/map_view/char_preview/proc/get_preview_url(mob/target, preview_dir = dir)
	if(isnull(get_preview_animation_entry(target, preview_dir)))
		return null

	var/direction_key = dir2text(preview_dir)
	if(isnull(direction_key))
		direction_key = "south"

	return preview_asset_urls[direction_key]

/atom/movable/screen/map_view/char_preview/proc/get_preview_urls(mob/target)
	if(isnull(preview_asset_urls))
		return null

	return preview_asset_urls.Copy()

/atom/movable/screen/map_view/char_preview/proc/get_preview_animations(mob/target)
	if(isnull(preview_animation_data))
		return null

	return preview_animation_data.Copy()
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
	var/datum/species/species_type = read_preference(/datum/preference/choiced/species)
	var/list/quirks_removed
	for(var/quirk_name in all_quirks)
		var/quirk_path = SSquirks.quirks[quirk_name]
		var/datum/quirk/quirk_prototype = SSquirks.quirk_prototypes[quirk_path]
		if(!quirk_prototype.is_species_appropriate(species_type))
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
