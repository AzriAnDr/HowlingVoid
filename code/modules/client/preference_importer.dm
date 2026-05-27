/datum/preference_importer
	var/datum/preferences/target_prefs
	var/list/raw_data
	var/list/found_characters = list()
	var/selected_character = 1
	var/target_slot = 1
	var/has_keybindings = FALSE
	var/has_game_prefs = FALSE
	var/import_keybindings = TRUE
	var/import_game_prefs = TRUE
	var/export_version = 1
	var/atom/movable/screen/map_view/char_preview/preview_view
	var/list/imported_keybindings
	var/list/imported_game_prefs
	var/imported_toggles
	var/imported_chat_toggles
	var/list/imported_be_special
	var/import_character = TRUE
	var/import_emote_panel = TRUE
	var/preview_mode = PREVIEW_PREF_UNDERWEAR

/datum/preference_importer/New(datum/preferences/prefs, list/data)
	. = ..()
	target_prefs = prefs
	raw_data = data
	target_slot = prefs.default_slot
	parse_import_data()

/datum/preference_importer/Destroy(force)
	cleanup_preview()
	target_prefs = null
	raw_data = null
	found_characters = null
	imported_keybindings = null
	imported_game_prefs = null
	imported_be_special = null
	return ..()

/datum/preference_importer/proc/cleanup_preview()
	if(preview_view)
		preview_view.preferences = null
		QDEL_NULL(preview_view)

/datum/preference_importer/proc/parse_import_data()
	if(!islist(raw_data))
		return

	if("export_version" in raw_data)
		export_version = raw_data["export_version"]

		if(export_version >= 2)
			if("character_data" in raw_data)
				var/list/char_data = raw_data["character_data"]
				if(islist(char_data))
					var/char_name = char_data["real_name"] || "Unknown Character"
					found_characters += list(list("key" = "character_data", "name" = char_name, "data" = char_data))

			if("key_bindings" in raw_data)
				imported_keybindings = raw_data["key_bindings"]
				has_keybindings = islist(imported_keybindings) && length(imported_keybindings)

			if("game_preferences" in raw_data)
				imported_game_prefs = raw_data["game_preferences"]
				has_game_prefs = islist(imported_game_prefs) && length(imported_game_prefs)

			if("toggles" in raw_data)
				imported_toggles = raw_data["toggles"]

			if("chat_toggles" in raw_data)
				imported_chat_toggles = raw_data["chat_toggles"]

			if("be_special" in raw_data)
				imported_be_special = raw_data["be_special"]

	if("real_name" in raw_data)
		var/char_name = raw_data["real_name"] || "Unknown Character"
		found_characters += list(list("key" = "direct", "name" = char_name, "data" = raw_data))
		return

	var/regex/char_regex = regex("^character\\d+$")
	for(var/key in raw_data)
		if(char_regex.Find(key) && islist(raw_data[key]))
			var/list/char_data = raw_data[key]
			var/char_name = char_data["real_name"] || key
			found_characters += list(list("key" = key, "name" = char_name, "data" = char_data))

	if("key_bindings" in raw_data)
		imported_keybindings = raw_data["key_bindings"]
		has_keybindings = islist(imported_keybindings) && length(imported_keybindings)

	if("toggles" in raw_data)
		imported_toggles = raw_data["toggles"]

	if("chat_toggles" in raw_data)
		imported_chat_toggles = raw_data["chat_toggles"]

	if("be_special" in raw_data)
		imported_be_special = raw_data["be_special"]

	var/list/extracted_game_prefs = list()
	for(var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		if(preference.savefile_identifier != PREFERENCE_PLAYER)
			continue
		if(preference.savefile_key in raw_data)
			extracted_game_prefs[preference.savefile_key] = raw_data[preference.savefile_key]
	if(length(extracted_game_prefs))
		imported_game_prefs = extracted_game_prefs
		has_game_prefs = TRUE

/datum/preference_importer/proc/has_valid_data()
	return length(found_characters) > 0

/datum/preference_importer/proc/get_selected_character_data()
	if(selected_character < 1 || selected_character > length(found_characters))
		return null
	return found_characters[selected_character]["data"]

/datum/preference_importer/proc/get_selected_emote_panel_data()
	var/list/char_data = get_selected_character_data()
	if(!islist(char_data) || !("custom_emote_panel" in char_data))
		return null

	var/list/emote_panel_data = char_data["custom_emote_panel"]
	if(!islist(emote_panel_data))
		return null

	return deep_copy_list(emote_panel_data)

/datum/preference_importer/proc/get_character_species(list/char_data)
	if(!islist(char_data))
		return null

	var/datum/preference/species_preference = GLOB.preference_entries[/datum/preference/choiced/species]
	if(!species_preference)
		return null

	var/species_raw = char_data[species_preference.savefile_key]
	if(isnull(species_raw))
		return null

	return species_preference.deserialize(species_raw, target_prefs)

/datum/preference_importer/proc/extract_legacy_import_label(raw_value)
	if(!istext(raw_value))
		return null

	var/text_value = trim(raw_value)
	var/list/segments = splittext(text_value, "||")
	if(length(segments))
		text_value = trim(segments[1])

	segments = splittext(text_value, "::")
	if(length(segments))
		text_value = trim(segments[1])

	return text_value

/datum/preference_importer/proc/normalize_import_match_text(raw_value)
	var/text_value = extract_legacy_import_label(raw_value)
	if(!istext(text_value))
		return null

	text_value = lowertext(text_value)
	text_value = replacetext(text_value, "(alt)", "")
	text_value = replacetext(text_value, "(alternate)", "")
	text_value = replacetext(text_value, " ", "")
	text_value = replacetext(text_value, "-", "")
	text_value = replacetext(text_value, "_", "")
	text_value = replacetext(text_value, "'", "")
	text_value = replacetext(text_value, "\"", "")
	text_value = replacetext(text_value, ",", "")
	text_value = replacetext(text_value, ".", "")
	text_value = replacetext(text_value, "(", "")
	text_value = replacetext(text_value, ")", "")

	return text_value

/datum/preference_importer/proc/find_closest_text_match(list/candidates, raw_value)
	var/text_value = extract_legacy_import_label(raw_value)
	if(!istext(text_value) || !length(text_value))
		return null

	var/lowercase_value = lowertext(text_value)
	for(var/candidate in candidates)
		if(istext(candidate) && lowertext(candidate) == lowercase_value)
			return candidate

	var/normalized_value = normalize_import_match_text(text_value)
	if(!length(normalized_value))
		return null

	var/best_candidate = null
	var/best_score = null
	for(var/candidate in candidates)
		if(!istext(candidate))
			continue

		var/normalized_candidate = normalize_import_match_text(candidate)
		if(!length(normalized_candidate))
			continue

		if(normalized_candidate == normalized_value)
			return candidate

		if(findtext(normalized_candidate, normalized_value) || findtext(normalized_value, normalized_candidate))
			var/score = abs(length(normalized_candidate) - length(normalized_value))
			if(isnull(best_score) || score < best_score)
				best_candidate = candidate
				best_score = score

	return best_candidate

/datum/preference_importer/proc/find_closest_choice_value(datum/preference/choiced/preference, raw_value)
	if(!istype(preference) || !istext(raw_value))
		return null

	return find_closest_text_match(preference.get_choices(), raw_value)

/datum/preference_importer/proc/resolve_choice_import_value(datum/preference/choiced/preference, raw_value)
	if(!istype(preference))
		return null

	if(istext(raw_value))
		var/matched_choice = find_closest_text_match(preference.get_choices(), raw_value)
		if(!isnull(matched_choice) && preference.is_valid(matched_choice, target_prefs))
			return matched_choice

		var/list/serialized_choices = preference.get_choices_serialized()
		var/matched_serialized_choice = find_closest_text_match(serialized_choices, raw_value)
		if(!isnull(matched_serialized_choice))
			var/matched_deserialized_choice = preference.deserialize(matched_serialized_choice, target_prefs)
			if(!isnull(matched_deserialized_choice) && preference.is_valid(matched_deserialized_choice, target_prefs))
				return matched_deserialized_choice

	var/deserialized = preference.deserialize(raw_value, target_prefs)
	if(!isnull(deserialized) && preference.is_valid(deserialized, target_prefs))
		return deserialized

	return null

/datum/preference_importer/proc/get_import_body_marking_features(list/char_data)
	var/list/features = list()

	var/datum/preference/tri_color/mutant_colors/mutant_colors_pref = GLOB.preference_entries[/datum/preference/tri_color/mutant_colors]
	if(mutant_colors_pref)
		var/list/mutant_colors = mutant_colors_pref.deserialize(char_data[mutant_colors_pref.savefile_key], target_prefs)
		if(islist(mutant_colors))
			features[FEATURE_MUTANT_COLOR] = mutant_colors[1]
			features[FEATURE_MUTANT_COLOR_TWO] = mutant_colors[2]
			features[FEATURE_MUTANT_COLOR_THREE] = mutant_colors[3]

	var/datum/preference/choiced/skin_tone/skin_tone_pref = GLOB.preference_entries[/datum/preference/choiced/skin_tone]
	if(skin_tone_pref)
		var/skin_tone = skin_tone_pref.deserialize(char_data[skin_tone_pref.savefile_key], target_prefs)
		if(!isnull(skin_tone))
			features[FEATURE_SKIN_COLOR] = skintone2hex(skin_tone)

	return features

/datum/preference_importer/proc/build_body_markings_from_legacy_preset(raw_value, list/char_data)
	if(!istext(raw_value))
		return null

	var/preset_name = find_closest_text_match(GLOB.body_marking_sets, raw_value)
	if(!preset_name)
		return null

	var/datum/body_marking_set/marking_set = GLOB.body_marking_sets[preset_name]
	var/datum/species/species_type = get_character_species(char_data)
	if(!marking_set || !species_type)
		return null

	return assemble_body_markings_from_set(marking_set, get_import_body_marking_features(char_data), species_type)

/datum/preference_importer/proc/sanitize_imported_body_markings(markings_value, list/char_data)
	if(islist(markings_value))
		var/list/sanitized_markings = list()
		for(var/zone in markings_value)
			if(!istext(zone) || !islist(GLOB.body_markings_per_limb[zone]))
				continue

			var/list/zone_markings = SANITIZE_LIST(markings_value[zone])
			var/list/allowed_markings = GLOB.body_markings_per_limb[zone]
			var/list/sanitized_zone_markings = list()
			for(var/marking_name in zone_markings)
				var/matched_marking = get_marking_base_name(marking_name)
				if(!(matched_marking in allowed_markings))
					matched_marking = find_closest_text_match(allowed_markings, marking_name)
				if(!matched_marking)
					continue

				var/marking_data = zone_markings[marking_name]
				var/list/sanitized_entry = sanitize_body_marking_entry(marking_name, marking_data, length(sanitized_zone_markings) + MARKING_LAYER_MIN)
				var/key = compose_marking_key(matched_marking, sanitized_entry[MARKING_INDEX_LAYER], get_marking_sequence(marking_name), sanitized_zone_markings)
				sanitized_zone_markings[key] = sanitized_entry

			if(length(sanitized_zone_markings))
				sanitized_markings[zone] = sanitized_zone_markings

		return target_prefs.update_markings(sanitized_markings)

	var/list/legacy_markings = build_body_markings_from_legacy_preset(markings_value, char_data)
	if(!length(legacy_markings) && islist(char_data))
		legacy_markings = build_body_markings_from_legacy_preset(char_data["feature_body_markings"], char_data)

	if(length(legacy_markings))
		return target_prefs.update_markings(legacy_markings)

	return list()

/datum/preference_importer/proc/infer_missing_mutant_toggles(list/sanitized)
	if(!islist(sanitized))
		return

	for(var/preference_type in GLOB.preference_entries)
		var/datum/preference/choiced/mutant_choice/mutant_choice_pref = GLOB.preference_entries[preference_type]
		if(!istype(mutant_choice_pref))
			continue

		if(isnull(sanitized[mutant_choice_pref.savefile_key]))
			continue

		var/datum/preference/toggle/mutant_toggle/toggle_pref = GLOB.preference_entries[mutant_choice_pref.type_to_check]
		if(!toggle_pref || !isnull(sanitized[toggle_pref.savefile_key]))
			continue

		var/choice_value = mutant_choice_pref.deserialize(sanitized[mutant_choice_pref.savefile_key], target_prefs)
		if(isnull(choice_value))
			continue

		if(choice_value == mutant_choice_pref.create_default_value())
			continue

		if(choice_value == SPRITE_ACCESSORY_NONE)
			continue

		if(mutant_choice_pref.relevant_mutant_bodypart && !is_factual_sprite_accessory(mutant_choice_pref.relevant_mutant_bodypart, choice_value))
			continue

		sanitized[toggle_pref.savefile_key] = TRUE

/datum/preference_importer/proc/sanitize_character_import_data(list/char_data)
	if(!islist(char_data))
		return list()

	var/list/sanitized = char_data.Copy()

	for(var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if(preference.savefile_identifier != PREFERENCE_CHARACTER)
			continue
		var/raw_value = char_data[preference.savefile_key]
		if(isnull(raw_value))
			continue

		if(istype(preference, /datum/preference/choiced))
			var/datum/preference/choiced/choiced_preference = preference
			var/resolved_choice = resolve_choice_import_value(choiced_preference, raw_value)
			if(!isnull(resolved_choice))
				sanitized[choiced_preference.savefile_key] = choiced_preference.serialize(resolved_choice)
			else
				sanitized -= choiced_preference.savefile_key
			continue

		var/deserialized = preference.deserialize(raw_value, target_prefs)
		if(!isnull(deserialized) && preference.is_valid(deserialized, target_prefs))
			sanitized[preference.savefile_key] = preference.serialize(deserialized)
		else
			sanitized -= preference.savefile_key

	// Compatibility for legacy bark exports without a dedicated voice_type selector.
	var/datum/preference/choiced/vocals/voice_type/voice_type_pref = GLOB.preference_entries[/datum/preference/choiced/vocals/voice_type]
	if(voice_type_pref)
		var/voice_type_key = voice_type_pref.savefile_key
		var/has_blooper_data = !isnull(sanitized["blooper_speech"]) || !isnull(sanitized["blooper_speech_speed"]) || !isnull(sanitized["blooper_speech_pitch"]) || !isnull(sanitized["blooper_pitch_range"])
		if(has_blooper_data && isnull(sanitized[voice_type_key]) && voice_type_pref.is_valid(VOICE_TYPE_BARK, target_prefs))
			sanitized[voice_type_key] = voice_type_pref.serialize(VOICE_TYPE_BARK)

	if("all_quirks" in sanitized)
		var/list/quirks = sanitized["all_quirks"]
		var/list/augments = SANITIZE_LIST(sanitized["augments"])
		var/datum/species/species_type = get_character_species(sanitized)
		if(islist(quirks) && length(quirks))
			sanitized["all_quirks"] = SSquirks.filter_invalid_quirks(SANITIZE_LIST(quirks), augments, species_type)
		else
			sanitized["all_quirks"] = list()

	sanitized["body_markings"] = sanitize_imported_body_markings(char_data["body_markings"], char_data)
	sanitized -= "body_markings_toggle"
	sanitized -= "feature_body_markings"
	sanitized -= "body_markings_color"
	sanitized -= "body_markings_emissive"
	if("mutant_bodyparts" in sanitized)
		sanitized["mutant_bodyparts"] = SANITIZE_LIST(sanitized["mutant_bodyparts"])
	if("features" in sanitized)
		sanitized["features"] = SANITIZE_LIST(sanitized["features"])
	if("augments" in sanitized)
		sanitized["augments"] = SANITIZE_LIST(sanitized["augments"])
	if("augment_limb_styles" in sanitized)
		sanitized["augment_limb_styles"] = SANITIZE_LIST(sanitized["augment_limb_styles"])
	if("languages" in sanitized)
		sanitized["languages"] = SANITIZE_LIST(sanitized["languages"])
	if("alt_job_titles" in sanitized)
		sanitized["alt_job_titles"] = SANITIZE_LIST(sanitized["alt_job_titles"])
	if("be_special" in sanitized)
		sanitized["be_special"] = target_prefs.sanitize_be_special(SANITIZE_LIST(sanitized["be_special"]))

	infer_missing_mutant_toggles(sanitized)

	return sanitized

/datum/preference_importer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		preview_view?.display_to(user, ui.window)
		return

	update_preview(user)
	ui = new(user, src, "PreferenceImporter")
	ui.set_autoupdate(FALSE)
	ui.open()
	preview_view?.display_to(user, ui.window)

/datum/preference_importer/ui_state(mob/user)
	return GLOB.always_state

/datum/preference_importer/ui_status(mob/user, datum/ui_state/state)
	if(!target_prefs || target_prefs.parent != user.client)
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/preference_importer/ui_data(mob/user)
	var/list/data = list()

	var/list/characters = list()
	for(var/i in 1 to length(found_characters))
		characters += list(list(
			"index" = i,
			"name" = found_characters[i]["name"],
		))
	data["characters"] = characters
	data["selected_character"] = selected_character

	var/list/slots = list()
	for(var/i in 1 to target_prefs.max_save_slots)
		var/tree_key = "character[i]"
		var/save_data = target_prefs.savefile.get_entry(tree_key)
		var/slot_name = save_data?["real_name"]
		slots += list(list(
			"index" = i,
			"name" = slot_name,
			"occupied" = !isnull(slot_name),
		))
	data["slots"] = slots
	data["target_slot"] = target_slot
	data["active_slot"] = target_prefs.default_slot

	data["has_keybindings"] = has_keybindings
	data["has_game_prefs"] = has_game_prefs
	data["import_keybindings"] = import_keybindings
	data["import_game_prefs"] = import_game_prefs
	data["export_version"] = export_version
	data["import_character"] = import_character
	data["has_emote_panel"] = !isnull(get_selected_emote_panel_data())
	data["import_emote_panel"] = import_emote_panel
	data["preview_map"] = preview_view?.assigned_map
	data["preview_mode"] = preview_mode
	data["preview_options"] = list(PREVIEW_PREF_LOADOUT, PREVIEW_PREF_UNDERWEAR, PREVIEW_PREF_NAKED, PREVIEW_PREF_NAKED_AROUSED)

	return data

/datum/preference_importer/ui_static_data(mob/user)
	return list()

/datum/preference_importer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("select_character")
			var/new_index = params["index"]
			if(isnum(new_index) && new_index >= 1 && new_index <= length(found_characters))
				selected_character = new_index
				update_preview(ui.user)
			return TRUE

		if("select_slot")
			var/new_slot = params["slot"]
			if(isnum(new_slot) && new_slot >= 1 && new_slot <= target_prefs.max_save_slots)
				target_slot = new_slot
			return TRUE

		if("toggle_keybindings")
			import_keybindings = !import_keybindings
			return TRUE

		if("toggle_game_prefs")
			import_game_prefs = !import_game_prefs
			return TRUE

		if("toggle_character")
			import_character = !import_character
			return TRUE

		if("toggle_emote_panel")
			import_emote_panel = !import_emote_panel
			return TRUE

		if("set_preview_mode")
			var/new_mode = params["mode"]
			if(new_mode in list(PREVIEW_PREF_LOADOUT, PREVIEW_PREF_UNDERWEAR, PREVIEW_PREF_NAKED, PREVIEW_PREF_NAKED_AROUSED))
				preview_mode = new_mode
				update_preview(ui.user)
			return TRUE

		if("confirm_import")
			perform_import(ui.user)
			ui.close()
			return TRUE

		if("cancel")
			ui.close()
			return TRUE

/datum/preference_importer/ui_close(mob/user)
	if(length(open_uis) > 1)
		return

	cleanup_preview()
	QDEL_IN(src, 1)

/datum/preference_importer/proc/update_preview(mob/user)
	var/list/char_data = get_selected_character_data()
	if(!char_data || !target_prefs || !target_prefs.parent)
		return
	var/list/preview_data = sanitize_character_import_data(char_data)

	var/list/original_cache = target_prefs.value_cache
	var/list/original_body_markings = target_prefs.body_markings
	var/list/original_augments = target_prefs.augments
	var/list/original_augment_limb_styles = target_prefs.augment_limb_styles
	var/list/original_all_quirks = target_prefs.all_quirks
	var/original_preview_pref = target_prefs.preview_pref

	target_prefs.value_cache = list()
	target_prefs.body_markings = sanitize_imported_body_markings(preview_data["body_markings"], preview_data)
	target_prefs.augments = SANITIZE_LIST(preview_data["augments"])
	target_prefs.augment_limb_styles = SANITIZE_LIST(preview_data["augment_limb_styles"])
	target_prefs.all_quirks = SSquirks.filter_invalid_quirks(SANITIZE_LIST(preview_data["all_quirks"]), target_prefs.augments, get_character_species(preview_data))
	target_prefs.preview_pref = preview_mode

	for(var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if(preference.savefile_identifier != PREFERENCE_CHARACTER)
			continue
		var/value = preference.read(preview_data, target_prefs)
		if(istype(preference, /datum/preference/choiced))
			var/raw_value = preview_data[preference.savefile_key]
			if(istext(raw_value))
				var/datum/preference/choiced/choiced_preference = preference
				var/matched_choice = find_closest_choice_value(choiced_preference, raw_value)
				if(!isnull(matched_choice) && choiced_preference.is_valid(matched_choice, target_prefs))
					value = matched_choice
		if(isnull(value))
			value = preference.create_informed_default_value(target_prefs)
		if(!isnull(value))
			target_prefs.value_cache[preference.type] = value

	if(!preview_view || QDELETED(preview_view))
		preview_view = new(null, null, target_prefs)
		preview_view.generate_view("import_preview_[REF(src)]")
		preview_view.show_job_clothes = FALSE

	preview_view.update_body()

	target_prefs.value_cache = original_cache
	target_prefs.body_markings = original_body_markings
	target_prefs.augments = original_augments
	target_prefs.augment_limb_styles = original_augment_limb_styles
	target_prefs.all_quirks = original_all_quirks
	target_prefs.preview_pref = original_preview_pref

/datum/preference_importer/proc/reload_target_slot(mob/user)
	if(target_slot != target_prefs.default_slot)
		target_prefs.switch_to_slot(target_slot, user)
		return

	if(!target_prefs.load_character(target_slot))
		return

	for(var/datum/preference_middleware/preference_middleware as anything in target_prefs.middleware)
		preference_middleware.on_new_character(user)

	target_prefs.character_preview_view?.update_body()
	if(user)
		target_prefs.update_static_data(user, always_instant = TRUE)
	SSstatpanels.update_job_estimation(ckey = target_prefs.parent.ckey)

/datum/preference_importer/proc/perform_import(mob/user)
	if(!target_prefs || !has_valid_data())
		return

	var/list/char_data = get_selected_character_data()
	if(!islist(char_data))
		tgui_alert(user, "No valid character data to import!", "Import Error")
		return

	var/tree_key = "character[target_slot]"
	var/reload_character = FALSE
	var/emote_panel_imported = FALSE
	var/list/imported_emote_panel = get_selected_emote_panel_data()
	var/has_imported_emote_panel = !isnull(imported_emote_panel)
	var/list/current_slot_data = target_prefs.savefile.get_entry(tree_key)

	if(import_character)
		var/list/sanitized_data = sanitize_character_import_data(char_data)
		if(import_emote_panel && has_imported_emote_panel)
			sanitized_data["custom_emote_panel"] = imported_emote_panel
			emote_panel_imported = TRUE
		else if(islist(current_slot_data?["custom_emote_panel"]))
			sanitized_data["custom_emote_panel"] = deep_copy_list(current_slot_data["custom_emote_panel"])
		else
			sanitized_data -= "custom_emote_panel"
		target_prefs.savefile.set_entry(tree_key, sanitized_data)
		reload_character = TRUE

	else if(import_emote_panel && has_imported_emote_panel && islist(current_slot_data))
		current_slot_data["custom_emote_panel"] = imported_emote_panel
		emote_panel_imported = TRUE
		if(target_slot == target_prefs.default_slot)
			target_prefs.custom_emote_panel = deep_copy_list(imported_emote_panel)

	if(import_keybindings && has_keybindings && islist(imported_keybindings))
		target_prefs.key_bindings = sanitize_keybindings(imported_keybindings)
		target_prefs.key_bindings_by_key = target_prefs.get_key_bindings_by_key(target_prefs.key_bindings)
		target_prefs.savefile.set_entry("key_bindings", target_prefs.key_bindings)
		if(target_prefs.parent)
			target_prefs.parent.set_macros()

	if(import_game_prefs && has_game_prefs && islist(imported_game_prefs))
		for(var/pref_key in imported_game_prefs)
			var/datum/preference/pref = GLOB.preference_entries_by_key[pref_key]
			if(!pref)
				continue
			if(pref.savefile_identifier != PREFERENCE_PLAYER)
				continue
			if(target_prefs.is_admin_only_preference(pref))
				continue
			var/value = pref.deserialize(imported_game_prefs[pref_key], target_prefs)
			if(!isnull(value) && pref.is_valid(value, target_prefs))
				target_prefs.write_preference(pref, pref.serialize(value))

		if(!isnull(imported_toggles))
			target_prefs.toggles = sanitize_integer(imported_toggles, 0, SHORT_REAL_LIMIT - 1, target_prefs.toggles)
			target_prefs.savefile.set_entry("toggles", target_prefs.toggles)

		if(!isnull(imported_chat_toggles))
			target_prefs.chat_toggles = sanitize_integer(imported_chat_toggles, 0, SHORT_REAL_LIMIT - 1, target_prefs.chat_toggles)
			target_prefs.savefile.set_entry("chat_toggles", target_prefs.chat_toggles)

		if(islist(imported_be_special))
			var/list/updated_char_data = target_prefs.savefile.get_entry(tree_key)
			if(islist(updated_char_data))
				updated_char_data["be_special"] = target_prefs.sanitize_be_special(imported_be_special)
				if(target_slot == target_prefs.default_slot)
					target_prefs.be_special = updated_char_data["be_special"]

	target_prefs.savefile.save()
	target_prefs.tainted_character_profiles = TRUE

	if(reload_character)
		reload_target_slot(user)
		target_prefs.save_character()
	else if(user)
		target_prefs.update_static_data(user, always_instant = TRUE)

	if(emote_panel_imported || reload_character)
		target_prefs.parent?.tgui_panel?.emotes_send_list()

	target_prefs.save_preferences()

	if(target_prefs.parent)
		target_prefs.apply_all_client_preferences()

	var/list/imported_items = list()
	if(import_character)
		imported_items += "character"
	if(emote_panel_imported)
		imported_items += "emote panel"
	if(import_keybindings && has_keybindings)
		imported_items += "keybindings"
	if(import_game_prefs && has_game_prefs)
		imported_items += "game preferences"
	var/summary = length(imported_items) ? jointext(imported_items, ", ") : "nothing"
	tgui_alert(user, "Imported [summary] into slot [target_slot]!", "Import Complete")
