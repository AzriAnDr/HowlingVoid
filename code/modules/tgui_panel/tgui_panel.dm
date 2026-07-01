/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui_panel datum
 * Hosts tgchat and other nice features.
 */
/datum/tgui_panel
	var/client/client
	var/datum/tgui_window/window
	var/broken = FALSE
	var/initialized_at
	/// Each client notifies on protected playback, so this prevents spamming admins.
	var/static/admins_warned = FALSE

/datum/tgui_panel/New(client/client, id)
	src.client = client
	window = new(client, id)
	window.subscribe(src, PROC_REF(on_message))

/datum/tgui_panel/Del()
	window.unsubscribe(src)
	window.close()
	return ..()

/**
 * public
 *
 * TRUE if panel is initialized and ready to receive messages.
 */
/datum/tgui_panel/proc/is_ready()
	return !broken && window.is_ready()

/**
 * public
 *
 * Initializes tgui panel.
 */
/datum/tgui_panel/proc/initialize(force = FALSE)
	set waitfor = FALSE
	// Minimal sleep to defer initialization to after client constructor
	sleep(1 TICKS)
	initialized_at = world.time
	// Perform a clean initialization
	window.initialize(
		strict_mode = TRUE,
		assets = list(
			get_asset_datum(/datum/asset/simple/tgui_panel),
		))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/fontawesome))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/tgfont))
	window.send_asset(get_asset_datum(/datum/asset/spritesheet_batched/chat))
	// Other setup
	request_telemetry()
	addtimer(CALLBACK(src, PROC_REF(on_initialize_timed_out)), 5 SECONDS)
	window.send_message("testTelemetryCommand")

/**
 * private
 *
 * Called when initialization has timed out.
 */
/datum/tgui_panel/proc/on_initialize_timed_out()
	// Currently does nothing but sending a message to old chat.
	SEND_TEXT(client, span_userdanger("Failed to load fancy chat, click <a href='byond://?src=[REF(src)];reload_tguipanel=1'>HERE</a> to attempt to reload it."))

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 */
/datum/tgui_panel/proc/on_message(type, payload)
	if(type == "ready")
		broken = FALSE
		window.send_message("update", list(
			"config" = list(
				"client" = list(
					"ckey" = client.ckey,
					"address" = client.address,
					"computer_id" = client.computer_id,
					"interface_language" = client.prefs.read_preference(/datum/preference/choiced/interface_language),
				),
				"window" = list(
					"locked" = FALSE,
				),
			),
		))
		// Send custom emote list once the panel is ready
		emotes_send_list()
		return TRUE

	if(type == "chat/fix")
		log_tgui(client, "Started fixing.", context = "message/chat/fix")
		client.nuke_chat()
		return TRUE

	if(!client?.prefs)
		return

	if(type == "emotes/execute")
		if(!islist(payload))
			return
		var/emote_key = payload["key"]
		if(!emote_key || !istext(emote_key) || !length(emote_key))
			return
		var/entry = client.prefs.custom_emote_panel[emote_key]
		if(isnull(entry))
			to_chat(client, span_warning("Emote [emote_key] not found in your panel!"))
			return FALSE
		if(!isliving(client?.mob))
			return TRUE
		var/mob/living/L = client.mob
		if(islist(entry))
			var/type_flags = EMOTE_VISIBLE
			if(isnum(entry["type"]))
				type_flags = entry["type"]
			var/message_text = entry["message"]
			var/has_message = (type_flags & EMOTE_VISIBLE) && istext(message_text) && length(message_text)
			if(has_message)
				var/message_flags = type_flags & (EMOTE_VISIBLE | EMOTE_AUDIBLE | EMOTE_IMPORTANT | EMOTE_RUNECHAT)
				if(!message_flags)
					message_flags = EMOTE_VISIBLE
				L.emote("me", message_flags, message_text, TRUE)
			var/sound_key = entry["sound"]
			if(sound_key && (type_flags & EMOTE_AUDIBLE))
				if(!all_emotes)
					populate_all_emotes_list()
				// Support variant format: "base_key:variant" (e.g. "cough:male 1")
				var/base_sound_key = sound_key
				var/variant_key = null
				var/colon_pos = findtext(sound_key, ":")
				if(colon_pos)
					base_sound_key = copytext(sound_key, 1, colon_pos)
					variant_key = copytext(sound_key, colon_pos + 1)
				if(base_sound_key in all_emotes)
					var/datum/emote/E = all_emotes[base_sound_key]
					if(E.check_cooldown(L, TRUE))
						var/snd
						// Try variant sound first if requested
						if(variant_key && variant_key != "default")
							var/variant_snd = E.get_variant_sound(variant_key, L)
							if(variant_snd)
								snd = istype(variant_snd, /sound) ? variant_snd : sound(variant_snd)
						// Fall back to standard sound
						if(!snd)
							snd = E.get_sound(L)
						if(!snd)
							snd = E.sound
						if(snd && E.should_play_sound(L, TRUE) && TIMER_COOLDOWN_FINISHED(L, "general_emote_audio_cooldown") && TIMER_COOLDOWN_FINISHED(L, base_sound_key))
							TIMER_COOLDOWN_START(L, base_sound_key, E.specific_emote_audio_cooldown)
							TIMER_COOLDOWN_START(L, "general_emote_audio_cooldown", E.general_emote_audio_cooldown)
							var/frequency = null
							if(E.affected_by_pitch && SStts.tts_enabled && SStts.pitch_enabled)
								frequency = rand(MIN_EMOTE_PITCH, MAX_EMOTE_PITCH) * (1 + sqrt(abs(L.pitch)) * SIGN(L.pitch) * EMOTE_TTS_PITCH_MULTIPLIER)
							else if(E.vary)
								frequency = rand(MIN_EMOTE_PITCH, MAX_EMOTE_PITCH)
							var/emote_volume = entry["volume"]
							if(!isnum(emote_volume))
								emote_volume = 100
							var/final_volume = clamp(round(50 * emote_volume / 100), 0, 63)
							playsound(source = L, soundin = snd, vol = final_volume, vary = FALSE, ignore_walls = E.sound_wall_ignore, frequency = frequency)
			var/effect_key = entry["effect"]
			if(effect_key && (type_flags & EMOTE_EFFECT))
				if(!all_emotes)
					populate_all_emotes_list()
				if(effect_key in all_emotes)
					L.play_emote_effect(effect_key, null, TRUE, TRUE)
		else
			L.emote(emote_key)
		return TRUE

	if(type == "emotes/create")
		if(!all_emotes)
			populate_all_emotes_list()
		if(length(client.prefs.custom_emote_panel) >= TGUI_PANEL_MAX_EMOTES)
			to_chat(client, span_warning("Maximum number of emotes reached: [TGUI_PANEL_MAX_EMOTES]"))
			return FALSE
		var/list/choices = list("Create Custom Emote" = "custom")
		for(var/key in all_emotes)
			if(isnull(client.prefs.custom_emote_panel[key]))
				choices[key] = key
		var/emote_choice = tgui_input_list(client.mob, "Which emote to add to panel?", "Choose Emote", choices)
		if(!emote_choice)
			return
		var/choice_value = choices[emote_choice]
		if(choice_value == "custom")
			open_custom_emote_editor(client.mob)
			return TRUE
		var/emote_key = choice_value
		if(!(emote_key in all_emotes))
			to_chat(client, span_warning("Emote [emote_key] doesn't exist!"))
			return
		var/emote_name = tgui_input_text(client.mob, "What name should emote [emote_key] have in panel?", "Emote Name", emote_key, CUSTOM_EMOTE_MAX_NAME_LEN)
		if(!emote_name)
			to_chat(client, span_warning("Invalid emote name!"))
			return
		if(emotes_create(emote_key, emote_name))
			emotes_send_list()
		return TRUE

	if(type == "emotes/contextAction")
		if(!islist(payload))
			return
		var/emote_key = payload["key"]
		if(!emote_key || !istext(emote_key) || !length(emote_key))
			return
		var/old_emote_entry = client.prefs.custom_emote_panel[emote_key]
		if(isnull(old_emote_entry))
			to_chat(client, span_warning("Emote [emote_key] not found in your panel!"))
			return FALSE
		var/is_custom = islist(old_emote_entry)
		var/old_emote_name = is_custom ? old_emote_entry["name"] : old_emote_entry
		var/list/options
		if(is_custom)
			options = list("Edit All", "Change Key", "Change Name", "Change Text", "Change Sound", "Change Effect", "Change Type", "Change Color", "Remove", "Cancel")
		else
			options = list("Remove", "Cancel")
		var/action = tgui_input_list(client.mob, "What would you like to do with emote \"[old_emote_name]\" ([emote_key])?", "Choose Action", options)
		switch(action)
			if("Remove")
				if(emotes_remove(emote_key, old_emote_name))
					emotes_send_list()
			if("Edit All")
				open_custom_emote_editor(client.mob, emote_key)
				return TRUE
			if("Change Name")
				if(is_custom && emotes_rename(emote_key, old_emote_name))
					emotes_send_list()
			if("Change Text")
				if(is_custom && emotes_edit_message(emote_key))
					emotes_send_list()
			if("Change Sound")
				if(is_custom && emotes_edit_sound(emote_key))
					emotes_send_list()
			if("Change Effect")
				if(is_custom && emotes_edit_effect(emote_key))
					emotes_send_list()
			if("Change Type")
				if(is_custom && emotes_edit_type(emote_key))
					emotes_send_list()
			if("Change Color")
				if(is_custom && emotes_edit_color(emote_key))
					emotes_send_list()
			if("Change Key")
				if(is_custom && emotes_change_key(emote_key, old_emote_name))
					emotes_send_list()
		return TRUE

	if(type == "emotes/reorder")
		if(!islist(payload))
			return
		var/list/new_order = payload["order"]
		if(!islist(new_order) || !length(new_order))
			return
		if(emotes_reorder(new_order))
			emotes_send_list()
		return TRUE

/**
 * public
 *
 * Sends a round restart notification.
 */
/datum/tgui_panel/proc/send_roundrestart()
	window.send_message("roundrestart")
