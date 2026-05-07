/**
 * Custom Emote Panel - backend for tgui_panel
 * Allows players to create and manage custom emote shortcuts accessible from the TGUI panel.
 */

/// Maximum number of custom emotes per character slot
#define TGUI_PANEL_MAX_EMOTES 69
/// Maximum length of emote key
#define CUSTOM_EMOTE_MAX_KEY_LEN 32
/// Maximum length of emote display name
#define CUSTOM_EMOTE_MAX_NAME_LEN 32

/datum/tgui_panel
	/// Static list of all available built-in emotes, keyed by emote key. Initialized lazily.
	var/static/list/all_emotes

/**
 * Initializes or reinitializes the static list of all available emotes.
 */
/datum/tgui_panel/proc/populate_all_emotes_list()
	all_emotes = list()
	for(var/path in valid_subtypesof(/datum/emote))
		var/datum/emote/E = new path()
		if(E.key)
			all_emotes[E.key] = E

/datum/tgui_panel/proc/get_custom_emote_type_options()
	return list(
		"Text Only" = EMOTE_VISIBLE,
		"Sound Only" = EMOTE_AUDIBLE,
		"Text and Sound" = EMOTE_VISIBLE | EMOTE_AUDIBLE,
		"Effect Only" = EMOTE_EFFECT,
		"Effect and Sound" = EMOTE_EFFECT | EMOTE_AUDIBLE,
		"Effect and Text" = EMOTE_EFFECT | EMOTE_VISIBLE,
		"Effect, Text, and Sound" = EMOTE_EFFECT | EMOTE_VISIBLE | EMOTE_AUDIBLE,
	)

/**
 * Creates a new custom emote entry in the player's panel.
 */
/datum/tgui_panel/proc/emotes_create(emote_key, emote_name, emote_message, emote_type, emote_sound, emote_effect, emote_color)
	if(length(client.prefs.custom_emote_panel) >= TGUI_PANEL_MAX_EMOTES)
		to_chat(client, span_warning("Maximum number of emotes reached: [TGUI_PANEL_MAX_EMOTES]"))
		return FALSE

	var/list/new_entry = list(
		"name" = emote_name,
	)
	if(!isnull(emote_message) && length(emote_message))
		new_entry["message"] = emote_message
	if(!isnull(emote_type))
		new_entry["type"] = emote_type
	if(!isnull(emote_sound))
		new_entry["sound"] = emote_sound
	if(!isnull(emote_effect))
		new_entry["effect"] = emote_effect
	if(!isnull(emote_color))
		new_entry["color"] = sanitize_hexcolor(emote_color)

	if(new_entry.len > 1)
		client.prefs.custom_emote_panel[emote_key] = new_entry
	else
		client.prefs.custom_emote_panel[emote_key] = emote_name

	client.prefs.save_custom_emotes()
	return TRUE

/**
 * Removes an existing custom emote entry after confirmation.
 */
/datum/tgui_panel/proc/emotes_remove(emote_key, old_emote_name)
	var/confirmation = tgui_alert(client.mob, "Are you sure you want to remove emote \"[old_emote_name]\" ([emote_key])?", "Confirmation", list("Remove", "Cancel"))
	if(confirmation != "Remove")
		return FALSE

	client.prefs.custom_emote_panel.Remove(emote_key)
	client.prefs.save_custom_emotes()
	return TRUE

/**
 * Renames an existing custom emote entry.
 */
/datum/tgui_panel/proc/emotes_rename(emote_key, old_emote_name)
	var/emote_name = tgui_input_text(client.mob, "Choose new name for emote [emote_key]:", "Emote Name", old_emote_name, CUSTOM_EMOTE_MAX_NAME_LEN)
	if(!emote_name)
		return FALSE

	var/entry = client.prefs.custom_emote_panel[emote_key]
	if(islist(entry))
		entry["name"] = emote_name
	else
		client.prefs.custom_emote_panel[emote_key] = emote_name
	client.prefs.save_custom_emotes()
	return TRUE

/**
 * Changes the trigger key of an existing custom emote.
 */
/datum/tgui_panel/proc/emotes_change_key(emote_key, old_emote_name)
	if(!all_emotes)
		populate_all_emotes_list()
	var/new_key = tgui_input_text(client.mob, "Enter new key for emote [old_emote_name]:", "Emote Key", emote_key, CUSTOM_EMOTE_MAX_KEY_LEN)
	if(!new_key)
		return FALSE
	new_key = lowertext(new_key)
	if((new_key in all_emotes) || (new_key in client.prefs.custom_emote_panel))
		to_chat(client, span_warning("Emote [new_key] already exists!"))
		return FALSE
	var/entry = client.prefs.custom_emote_panel[emote_key]
	client.prefs.custom_emote_panel.Remove(emote_key)
	client.prefs.custom_emote_panel[new_key] = entry
	client.prefs.save_custom_emotes()
	return TRUE

/**
 * Edits the displayed message of a custom emote.
 */
/datum/tgui_panel/proc/emotes_edit_message(emote_key)
	var/entry = client.prefs.custom_emote_panel[emote_key]
	if(!islist(entry))
		entry = list("name" = entry)
	var/emote_message = stripped_multiline_input(client.mob, "What message should emote [emote_key] display?", "Emote Message", entry["message"], MAX_MESSAGE_LEN)
	if(isnull(emote_message))
		return FALSE
	if(istext(emote_message) && !length(emote_message))
		entry -= "message"
	else
		entry["message"] = emote_message
	client.prefs.custom_emote_panel[emote_key] = entry
	client.prefs.save_custom_emotes()
	return TRUE

/**
 * Edits the sound played by a custom emote.
 */
/datum/tgui_panel/proc/emotes_edit_sound(emote_key)
	if(!all_emotes)
		populate_all_emotes_list()
	var/entry = client.prefs.custom_emote_panel[emote_key]
	if(!islist(entry))
		entry = list("name" = entry)
	var/list/choices = list("None" = null)
	for(var/key in all_emotes)
		choices[key] = key
	var/sound_choice = tgui_input_list(client.mob, "Which sound should this emote play?", "Emote Sound", choices)
	if(isnull(sound_choice))
		return FALSE
	var/sound_key = choices[sound_choice]
	entry["sound"] = sound_key
	client.prefs.custom_emote_panel[emote_key] = entry
	client.prefs.save_custom_emotes()
	return TRUE

/**
 * Edits the visual effect triggered by a custom emote.
 */
/datum/tgui_panel/proc/emotes_edit_effect(emote_key)
	if(!all_emotes)
		populate_all_emotes_list()
	var/entry = client.prefs.custom_emote_panel[emote_key]
	if(!islist(entry))
		entry = list("name" = entry)
	var/list/choices = list("None" = null)
	for(var/key in all_emotes)
		var/datum/emote/E = all_emotes[key]
		if(E?.has_custom_emote_effect)
			choices[key] = key
	var/effect_choice = tgui_input_list(client.mob, "Which effect should this emote display?", "Emote Effect", choices)
	if(isnull(effect_choice))
		return FALSE
	var/effect_key = choices[effect_choice]
	entry["effect"] = effect_key
	if(effect_key || isnum(entry["type"]))
		var/current_type = isnum(entry["type"]) ? entry["type"] : EMOTE_VISIBLE
		if(effect_key)
			current_type |= EMOTE_EFFECT
		else
			current_type &= ~EMOTE_EFFECT
		if(current_type)
			entry["type"] = current_type
		else
			entry -= "type"
	client.prefs.custom_emote_panel[emote_key] = entry
	client.prefs.save_custom_emotes()
	return TRUE

/**
 * Edits the type flags (visible/audible/effect) of a custom emote.
 */
/datum/tgui_panel/proc/emotes_edit_type(emote_key)
	var/entry = client.prefs.custom_emote_panel[emote_key]
	if(!islist(entry))
		entry = list("name" = entry)
	var/list/type_options = get_custom_emote_type_options()
	var/type_choice = tgui_input_list(client.mob, "What should this emote use?", "Emote Type", type_options)
	if(isnull(type_choice))
		return FALSE
	var/emote_type_flag = type_options[type_choice]
	entry["type"] = emote_type_flag
	client.prefs.custom_emote_panel[emote_key] = entry
	client.prefs.save_custom_emotes()
	return TRUE

/**
 * Edits the button color of a custom emote.
 */
/datum/tgui_panel/proc/emotes_edit_color(emote_key)
	var/entry = client.prefs.custom_emote_panel[emote_key]
	if(!islist(entry))
		entry = list("name" = entry)
	var/default_color = entry["color"]
	if(!istext(default_color))
		default_color = "#ffffff"
	var/new_color = tgui_color_picker(client.mob, "Choose a button color for [emote_key]", "Emote Color", default_color)
	if(isnull(new_color))
		return FALSE
	entry["color"] = sanitize_hexcolor(new_color)
	client.prefs.custom_emote_panel[emote_key] = entry
	client.prefs.save_custom_emotes()
	return TRUE

/**
 * Reorders the custom emotes panel according to a new ordered list of keys.
 */
/datum/tgui_panel/proc/emotes_reorder(list/new_order)
	if(!client?.prefs)
		return FALSE

	var/list/panel = client.prefs.custom_emote_panel
	if(!panel || !length(panel))
		return FALSE

	if(length(new_order) != length(panel))
		return FALSE

	for(var/key in new_order)
		if(!(key in panel))
			return FALSE

	var/list/new_panel = list()
	for(var/key in new_order)
		new_panel[key] = panel[key]

	client.prefs.custom_emote_panel = new_panel
	client.prefs.save_custom_emotes()
	return TRUE

/**
 * Opens the CustomEmoteEditor TGUI for creating or editing a custom emote.
 */
/datum/tgui_panel/proc/open_custom_emote_editor(mob/user, emote_key)
	if(!client?.prefs)
		return
	if(!client.prefs.custom_emote_panel)
		client.prefs.custom_emote_panel = list()
	if(emote_key)
		emote_key = LOWER_TEXT(emote_key)
		var/entry = client.prefs.custom_emote_panel[emote_key]
		if(!islist(entry))
			to_chat(client, span_warning("Emote [emote_key] is not a custom emote."))
			return
	var/datum/custom_emote_editor/editor = new(src, user, emote_key)
	editor.ui_interact(user)

/**
 * Validates and saves a custom emote from the editor form submission.
 */
/datum/tgui_panel/proc/emotes_submit_custom(datum/custom_emote_editor/editor, list/payload)
	if(!client?.prefs)
		return list("success" = FALSE, "error" = "Preferences unavailable.")
	if(!client.prefs.custom_emote_panel)
		client.prefs.custom_emote_panel = list()

	if(!all_emotes)
		populate_all_emotes_list()

	var/list/panel = client.prefs.custom_emote_panel

	var/raw_key = payload["key"]
	if(!istext(raw_key))
		return list("success" = FALSE, "error" = "Emote key is required.")
	var/emote_key = LOWER_TEXT(trim(raw_key))
	if(!length(emote_key))
		return list("success" = FALSE, "error" = "Emote key is required.")
	if(length(emote_key) > CUSTOM_EMOTE_MAX_KEY_LEN)
		return list("success" = FALSE, "error" = "Emote key is too long.")

	var/raw_name = payload["name"]
	if(!istext(raw_name))
		return list("success" = FALSE, "error" = "Emote name is required.")
	var/emote_name = trim(raw_name)
	if(!length(emote_name))
		return list("success" = FALSE, "error" = "Emote name is required.")
	if(length(emote_name) > CUSTOM_EMOTE_MAX_NAME_LEN)
		return list("success" = FALSE, "error" = "Emote name is too long.")

	var/raw_message = payload["message"]
	var/emote_message = null
	if(istext(raw_message))
		if(length(raw_message) > MAX_MESSAGE_LEN)
			return list("success" = FALSE, "error" = "Emote message is too long.")
		if(length(trim(raw_message)))
			emote_message = raw_message

	var/text_enabled = payload["text_enabled"] ? TRUE : FALSE
	var/sound_enabled = payload["sound_enabled"] ? TRUE : FALSE
	var/effect_enabled = payload["effect_enabled"] ? TRUE : FALSE

	var/type_flags = 0
	if(text_enabled)
		type_flags |= EMOTE_VISIBLE
	if(sound_enabled)
		type_flags |= EMOTE_AUDIBLE
	if(effect_enabled)
		type_flags |= EMOTE_EFFECT
	if(!type_flags)
		return list("success" = FALSE, "error" = "Select at least one option (Text, Sound, or Effect).")

	var/sound_key = null
	var/effect_key = null
	if(sound_enabled)
		var/raw_sound = payload["sound_key"]
		if(!istext(raw_sound) || !length(raw_sound))
			return list("success" = FALSE, "error" = "Select a sound or disable the Sound option.")
		sound_key = LOWER_TEXT(trim(raw_sound))
		// Support variant format: "base_key:variant"
		var/base_sound_key = sound_key
		var/colon_pos = findtext(sound_key, ":")
		if(colon_pos)
			base_sound_key = copytext(sound_key, 1, colon_pos)
		var/datum/emote/sound_emote = all_emotes[base_sound_key]
		if(!sound_emote)
			return list("success" = FALSE, "error" = "Selected sound emote is invalid.")
		if(!sound_emote.sound && !sound_emote.get_sound(client.mob))
			return list("success" = FALSE, "error" = "Selected sound emote has no sound.")
	if(effect_enabled)
		var/raw_effect = payload["effect_key"]
		if(!istext(raw_effect) || !length(raw_effect))
			return list("success" = FALSE, "error" = "Select an effect or disable the Effect option.")
		effect_key = LOWER_TEXT(trim(raw_effect))
		var/datum/emote/effect_emote = all_emotes[effect_key]
		if(!effect_emote || !effect_emote.has_custom_emote_effect)
			return list("success" = FALSE, "error" = "Selected effect emote is invalid.")

	var/raw_color = payload["color"]
	var/emote_color = null
	if(istext(raw_color) && length(raw_color))
		emote_color = sanitize_hexcolor(raw_color)
		if(!emote_color)
			return list("success" = FALSE, "error" = "Selected color is invalid.")

	var/raw_volume = payload["volume"]
	var/emote_volume = 100
	if(isnum(raw_volume))
		emote_volume = clamp(round(raw_volume), 0, 125)

	var/old_key = editor?.emote_key
	if(!old_key)
		if((emote_key in all_emotes) || (emote_key in panel))
			return list("success" = FALSE, "error" = "Emote [emote_key] already exists.")
	else if(emote_key != old_key && ((emote_key in all_emotes) || (emote_key in panel)))
		return list("success" = FALSE, "error" = "Emote [emote_key] already exists.")

	var/list/new_entry = list(
		"name" = emote_name,
		"type" = type_flags,
	)
	if(emote_message)
		new_entry["message"] = emote_message
	if(sound_key)
		new_entry["sound"] = sound_key
	if(effect_key)
		new_entry["effect"] = effect_key
	if(emote_color)
		new_entry["color"] = emote_color
	if(emote_volume != 100)
		new_entry["volume"] = emote_volume

	if(old_key && old_key != emote_key)
		panel.Remove(old_key)

	panel[emote_key] = new_entry
	client.prefs.save_custom_emotes()
	editor?.set_saved_key(emote_key)
	to_chat(client, span_notice("Custom emote [emote_name] saved."))
	return list("success" = TRUE, "key" = emote_key)

/**
 * Plays a sound preview for the custom emote editor.
 */
/datum/tgui_panel/proc/preview_custom_emote_sound(mob/user, sound_key, volume = 100)
	if(!istext(sound_key) || !length(sound_key))
		return FALSE
	if(!user)
		return FALSE
	if(!all_emotes)
		populate_all_emotes_list()
	sound_key = LOWER_TEXT(sound_key)

	if(!isnum(volume))
		volume = 100
	volume = clamp(volume, 0, 125)

	// Support variant format: "base_key:variant" (e.g. "cough:male 1" or "cough:random:female")
	var/base_sound_key = sound_key
	var/variant_key = null
	var/colon_pos = findtext(sound_key, ":")
	if(colon_pos)
		base_sound_key = copytext(sound_key, 1, colon_pos)
		variant_key = copytext(sound_key, colon_pos + 1)

	var/datum/emote/E = all_emotes[base_sound_key]
	if(!E)
		to_chat(client, span_warning("Selected sound emote is invalid."))
		return FALSE

	var/mob/living/living_preview = istype(user, /mob/living) ? user : null
	var/sound/snd
	// If a specific variant is requested (not "default"), try to use it
	if(variant_key && variant_key != "default")
		var/variant_snd = E.get_variant_sound(variant_key, living_preview)
		if(variant_snd)
			snd = istype(variant_snd, /sound) ? variant_snd : sound(variant_snd)
	// Fall back to standard sound resolution
	if(!snd)
		if(living_preview)
			snd = E.get_sound(living_preview)
	if(!snd)
		snd = E.sound
	if(!snd)
		to_chat(client, span_warning("Selected sound emote is invalid."))
		return FALSE
	if(!istype(snd, /sound))
		snd = sound(snd)
	if(!snd)
		return FALSE

	var/frequency = null
	if(living_preview)
		if(E.affected_by_pitch && SStts.tts_enabled && SStts.pitch_enabled)
			frequency = rand(MIN_EMOTE_PITCH, MAX_EMOTE_PITCH) * (1 + sqrt(abs(living_preview.pitch)) * SIGN(living_preview.pitch) * EMOTE_TTS_PITCH_MULTIPLIER)
		else if(E.vary)
			frequency = rand(MIN_EMOTE_PITCH, MAX_EMOTE_PITCH)
	else if(E.vary)
		frequency = rand(MIN_EMOTE_PITCH, MAX_EMOTE_PITCH)

	var/final_volume = clamp(round(50 * volume / 100), 0, 63)
	user.playsound_local(null, null, final_volume, FALSE, frequency, pressure_affected = FALSE, sound_to_use = snd)
	return TRUE

/**
 * Plays an effect preview for the custom emote editor.
 */
/datum/tgui_panel/proc/preview_custom_emote_effect(mob/user, effect_key)
	if(!istext(effect_key) || !length(effect_key))
		return FALSE
	if(!all_emotes)
		populate_all_emotes_list()
	effect_key = LOWER_TEXT(effect_key)
	var/datum/emote/E = all_emotes[effect_key]
	if(!E?.has_custom_emote_effect)
		to_chat(client, span_warning("Selected effect emote is invalid."))
		return FALSE
	if(!isliving(user))
		if(user)
			to_chat(user, span_warning("You need to be alive to preview emote effects."))
		else
			to_chat(client, span_warning("You need to be alive to preview emote effects."))
		return FALSE
	var/mob/living/L = user
	L.play_emote_effect(effect_key, null, TRUE)
	return TRUE

/**
 * Sends the current custom emote list to the TGUI panel frontend.
 */
/datum/tgui_panel/proc/emotes_send_list()
	if(!client?.prefs)
		return
	if(!all_emotes)
		populate_all_emotes_list()
	var/list/panel = client.prefs.custom_emote_panel
	if(!panel)
		panel = list()
		client.prefs.custom_emote_panel = panel
	var/list/payload = list()
	for(var/emote_key in panel)
		var/entry = panel[emote_key]
		var/name
		var/message
		var/color
		var/effect
		if(islist(entry))
			name = entry["name"]
			message = entry["message"]
			color = entry["color"]
			effect = entry["effect"]
		else
			name = entry
		if(!message && (emote_key in all_emotes))
			var/datum/emote/E = all_emotes[emote_key]
			if(E)
				message = E.message
		payload[emote_key] = list(
			"name" = name,
			"message" = message,
			"effect" = effect,
			"color" = color,
		)
	window.send_message("emotes/setList", payload)

/**
 * Saves custom emotes to the character's savefile slot.
 */
/datum/preferences/proc/save_custom_emotes()
	if(!path)
		return FALSE

	var/tree_key = "character[default_slot]"
	if(!(tree_key in savefile.get_entry()))
		return FALSE

	var/save_data = savefile.get_entry(tree_key)
	save_data["custom_emote_panel"] = custom_emote_panel
	savefile.save()
	return TRUE

// ==================== Custom Emote Editor ====================

/datum/custom_emote_editor
	var/datum/tgui_panel/panel
	var/emote_key
	var/is_edit = FALSE
	var/current_color = "#ffffff"
	var/color_timestamp
	var/status_message
	var/status_is_error = FALSE
	var/revision

/datum/custom_emote_editor/New(datum/tgui_panel/panel, mob/user, emote_key)
	src.panel = panel
	revision = world.time
	color_timestamp = revision
	if(emote_key)
		emote_key = LOWER_TEXT(emote_key)
		src.emote_key = emote_key
		is_edit = TRUE
		var/entry = panel.client?.prefs?.custom_emote_panel?[emote_key]
		if(islist(entry))
			var/entry_color = entry["color"]
			if(istext(entry_color))
				current_color = entry_color
	return ..()

/datum/custom_emote_editor/ui_state(mob/user)
	return GLOB.always_state

/datum/custom_emote_editor/ui_close()
	qdel(src)

/datum/custom_emote_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		var/title = is_edit ? "Edit Custom Emote" : "Create Custom Emote"
		ui = new(user, src, "CustomEmoteEditor", title)
		ui.open()

/datum/custom_emote_editor/ui_static_data(mob/user)
	var/list/data = list()
	panel.populate_all_emotes_list()
	var/list/sound_options = list()
	var/list/effect_options = list()

	for(var/key in panel.all_emotes)
		var/datum/emote/E = panel.all_emotes[key]
		if(!E)
			continue
		var/display_name = E.name ? E.name : key
		var/has_sound = E.sound
		if(!has_sound)
			try
				has_sound = E.get_sound(user)
			catch()
				has_sound = FALSE

		// Check for sound variants — if present, always show in panel regardless of has_sound
		var/list/variants = E.get_sound_variants(user)
		if(islist(variants) && length(variants))
			var/list/variant_list = list()
			// Meta-variants
			variant_list += list(list("key" = "[key]:default", "name" = "Default (auto)", "isMeta" = TRUE))
			variant_list += list(list("key" = "[key]:random", "name" = "Random (any)", "isMeta" = TRUE))
			// Detect categories for random:<category>
			var/list/categories = list()
			for(var/vkey in variants)
				var/space_pos = findtext(vkey, " ")
				var/category = space_pos ? copytext(vkey, 1, space_pos) : vkey
				categories[category] = TRUE
			for(var/category in categories)
				variant_list += list(list("key" = "[key]:random:[category]", "name" = "Random ([category])", "isMeta" = TRUE))
			// Specific variants
			for(var/vkey in variants)
				variant_list += list(list("key" = "[key]:[vkey]", "name" = vkey, "isMeta" = FALSE))
			sound_options += list(list(
				"key" = key,
				"name" = display_name,
				"message" = E.message,
				"hasVariants" = TRUE,
				"variants" = variant_list,
			))
		else if(has_sound)
			sound_options += list(list(
				"key" = key,
				"name" = display_name,
				"message" = E.message,
			))
		if(E.has_custom_emote_effect)
			effect_options += list(list(
				"key" = key,
				"name" = display_name,
				"message" = E.message,
			))

	data["sounds"] = sound_options
	data["effects"] = effect_options
	data["limits"] = list(
		"key" = CUSTOM_EMOTE_MAX_KEY_LEN,
		"name" = CUSTOM_EMOTE_MAX_NAME_LEN,
		"message" = MAX_MESSAGE_LEN,
	)
	return data

/datum/custom_emote_editor/ui_data(mob/user)
	var/list/data = list()

	var/list/emote_data = list()
	var/name = ""
	var/message = ""
	var/text_enabled = TRUE
	var/sound_enabled = FALSE
	var/effect_enabled = FALSE
	var/sound_key
	var/effect_key
	var/volume = 100

	if(is_edit)
		var/entry = panel.client?.prefs?.custom_emote_panel?[emote_key]
		if(islist(entry))
			name = entry["name"] || emote_key
			message = entry["message"] || ""
			sound_key = entry["sound"]
			effect_key = entry["effect"]
			volume = entry["volume"] || 100
			if(color_timestamp == revision)
				var/entry_color = entry["color"]
				if(istext(entry_color))
					current_color = entry_color
				else
					current_color = "#ffffff"
			var/type_flags = entry["type"]
			if(!isnum(type_flags))
				type_flags = EMOTE_VISIBLE
			text_enabled = (type_flags & EMOTE_VISIBLE) ? TRUE : FALSE
			sound_enabled = (type_flags & EMOTE_AUDIBLE) ? TRUE : FALSE
			effect_enabled = (type_flags & EMOTE_EFFECT) ? TRUE : FALSE
		else if(istext(entry))
			name = entry
	emote_data["revision"] = revision
	emote_data["key"] = is_edit ? emote_key : ""
	emote_data["name"] = name
	emote_data["message"] = message
	emote_data["text_enabled"] = text_enabled
	emote_data["sound_enabled"] = sound_enabled
	emote_data["effect_enabled"] = effect_enabled
	emote_data["sound_key"] = sound_key
	emote_data["effect_key"] = effect_key
	emote_data["volume"] = volume
	emote_data["color"] = list(
		"value" = current_color,
		"timestamp" = color_timestamp,
	)

	data["emote"] = emote_data
	data["is_edit"] = is_edit
	if(status_message)
		data["status"] = list(
			"message" = status_message,
			"is_error" = status_is_error,
		)
	return data

/datum/custom_emote_editor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("save")
			var/list/result = panel.emotes_submit_custom(src, params)
			if(result["success"])
				status_message = null
				status_is_error = FALSE
				panel.emotes_send_list()
				ui.close()
			else if(result["error"])
				set_status(result["error"], TRUE)
			return TRUE
		if("discard")
			ui.close()
			return TRUE
		if("pick_color")
			var/current = params["current_color"]
			if(!istext(current) || !length(current))
				current = current_color
			if(!istext(current) || !length(current))
				current = "#ffffff"
			var/new_color = tgui_color_picker(ui.user, "Choose a button color", "Emote Color", current)
			if(new_color)
				var/sanitized = sanitize_hexcolor(new_color)
				if(sanitized)
					current_color = sanitized
					color_timestamp = world.time
					set_status("Updated preview color.")
					return TRUE
				set_status("Selected color is invalid.", TRUE)
				return TRUE
			return FALSE
		if("preview_sound")
			var/preview_volume = params["volume"]
			if(!isnum(preview_volume))
				preview_volume = 100
			if(panel.preview_custom_emote_sound(ui.user, params["sound_key"], preview_volume))
				set_status("Playing sound preview.")
			return TRUE
		if("preview_effect")
			if(panel.preview_custom_emote_effect(ui.user, params["effect_key"]))
				set_status("Playing effect preview.")
			return TRUE
	return

/datum/custom_emote_editor/proc/set_status(message, is_error = FALSE)
	status_message = message
	status_is_error = is_error

/datum/custom_emote_editor/proc/set_saved_key(new_key)
	if(!new_key)
		return
	emote_key = new_key
	is_edit = TRUE
