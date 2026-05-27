
GLOBAL_LIST_EMPTY_TYPED(interaction_instances, /datum/interaction)

/datum/interaction
	/// The name to be displayed in the interaction menu for this interaction
	var/name = "broken interaction"
	/// Stable identifier used by UI/backend to resolve this interaction.
	var/interaction_id = ""
	/// Optional localization key for the interaction name in the UI.
	var/translation_key = ""
	/// The description of the interacton.
	var/description = "broken"
	/// Optional localization key for the interaction description in the UI.
	var/description_translation_key = ""
	/// If it can be done at a distance.
	var/distance_allowed = FALSE
	/// A list of possible messages displayed loaded by the JSON.
	var/list/message = list()
	/// Localized variants of [message], keyed by panel language.
	var/list/localized_messages = list()
	/// A list of possible messages displayed directly to the USER.
	var/list/user_messages = list()
	/// Localized variants of [user_messages], keyed by panel language.
	var/list/localized_user_messages = list()
	/// A list of possible messages displayed directly to the TARGET.
	var/list/target_messages = list()
	/// Localized variants of [target_messages], keyed by panel language.
	var/list/localized_target_messages = list()
	/// What category this interaction will fall under in the menu.
	var/category = INTERACTION_CAT_HIDE
	/// Optional localization key for the interaction category in the UI.
	var/category_translation_key = ""
	/// Defines how we interact with ourselves or others.
	var/usage = INTERACTION_OTHER
	/// Does this interaction play a sound?
	var/sound_use = FALSE
	/// Does the interaction sound vary in pitch each time?
	var/sound_vary = TRUE
	/// If it plays a sound, how far does it travel?
	var/sound_range = 1
	/// Stores the sound for later.
	var/sound_cache = null
	/// Is this lewd?
	var/lewd = FALSE
	/// What parts do WE need(IMPORTANT TO GET IT TO THE CORRECT DEFINE, ORGAN SLOT)?
	var/list/user_required_parts = list()
	/// What parts do they need(IMPORTANT TO GET IT TO THE CORRECT DEFINE, ORGAN SLOT)?
	var/list/target_required_parts = list()
	/// What parts must exist on the user, even if covered by clothing?
	var/list/user_required_any_parts = list()
	/// What parts must exist on the target, even if covered by clothing?
	var/list/target_required_any_parts = list()
	/// The amount of pleasure the target receives from this interaction.
	/// Can be a fixed number or a list(min, max).
	var/target_pleasure = 0
	/// The amount of arousal the target receives from this interaction.
	/// Can be a fixed number or a list(min, max).
	var/target_arousal = 0
	/// The amount of pain the target receives.
	/// Can be a fixed number or a list(min, max).
	var/target_pain = 0
	/// The amount of pleasure the user receives.
	/// Can be a fixed number or a list(min, max).
	var/user_pleasure = 0
	/// The amount of arousal the user receives.
	/// Can be a fixed number or a list(min, max).
	var/user_arousal = 0
	/// The amount of pain the user receives.
	/// Can be a fixed number or a list(min, max).
	var/user_pain = 0
	/// A list of possible sounds.
	var/list/sound_possible = list()
	/// What requirements does this interaction have? See defines.
	var/list/interaction_requires = list()
	/// Optional list of item paths the user must hold in the active hand.
	var/list/user_required_item_paths = list()
	/// Optional list of held item paths that explicitly disqualify this interaction.
	var/list/user_blocked_item_paths = list()
	/// Optional list of lewd slots on the target that must contain a matching toy.
	var/list/target_required_item_slots = list()
	/// Optional list of toy paths the target must currently have inserted/attached.
	var/list/target_required_item_paths = list()
	/// Optional list of inserted/attached toy paths that explicitly disqualify this interaction.
	var/list/target_blocked_item_paths = list()
	/// What color should the interaction button be?
	var/color = "blue"
	/// What sexuality preference do we display for.
	var/sexuality = ""
	/// Whether this datum should be auto-registered into the player-visible interaction list.
	var/register_in_menu = TRUE

/datum/interaction/proc/normalize_translation_token(value)
	value = lowertext("[value]")
	var/list/replacements = list(
		" " = "_",
		"-" = "_",
		"'" = "",
		"\"" = "",
		"," = "",
		"." = "",
		":" = "",
		";" = "",
		"(" = "",
		")" = "",
		"&" = "and",
		"/" = "_",
	)
	for(var/from_text in replacements)
		value = replacetext(value, from_text, replacements[from_text])
	while(findtext(value, "__"))
		value = replacetext(value, "__", "_")
	while(length(value) && copytext(value, 1, 2) == "_")
		value = copytext(value, 2)
	while(length(value) && copytext(value, length(value), length(value) + 1) == "_")
		value = copytext(value, 1, length(value))
	return value

/datum/interaction/proc/get_auto_translation_prefix()
	var/type_text = "[type]"
	if(findtext(type_text, "/datum/interaction/howling_extra") == 1)
		return "ui.interaction_panel.interaction.base"
	return ""

/datum/interaction/proc/get_auto_translation_suffix()
	var/type_text = "[type]"
	var/root_text = ""
	if(findtext(type_text, "/datum/interaction/howling_extra") == 1)
		root_text = "/datum/interaction/howling_extra"
	else
		return ""

	var/suffix = copytext(type_text, length(root_text) + 1)
	if(copytext(suffix, 1, 2) == "/")
		suffix = copytext(suffix, 2)
	if(!length(suffix))
		return ""

	var/list/segments = splittext(suffix, "/")
	var/list/normalized_segments = list()
	for(var/segment in segments)
		var/normalized = normalize_translation_token(segment)
		if(length(normalized))
			normalized_segments += normalized
	return jointext(normalized_segments, ".")

/datum/interaction/proc/get_ui_translation_key()
	if(length(translation_key))
		return translation_key
	var/prefix = get_auto_translation_prefix()
	var/suffix = get_auto_translation_suffix()
	if(length(prefix) && length(suffix))
		return "[prefix].[suffix].name"
	return ""

/datum/interaction/proc/get_ui_description_translation_key()
	if(length(description_translation_key))
		return description_translation_key
	var/prefix = get_auto_translation_prefix()
	var/suffix = get_auto_translation_suffix()
	if(length(prefix) && length(suffix))
		return "[prefix].[suffix].description"
	return ""

/datum/interaction/proc/get_ui_category_translation_key()
	if(length(category_translation_key))
		return category_translation_key
	if(category == INTERACTION_CAT_HIDE || !length(category))
		return ""
	var/type_text = "[type]"
	if(findtext(type_text, "/datum/interaction/howling_extra") == 1)
		var/normalized_category = normalize_translation_token(category)
		if(length(normalized_category))
			return "ui.interaction_panel.category.base.[normalized_category]"
	return ""

/datum/interaction/proc/get_interaction_id()
	if(length(interaction_id))
		return interaction_id
	if(type != /datum/interaction)
		return "[type]"
	return "name:[name]"

/datum/interaction/proc/load_localized_message_list(language, field, value)
	if(!length(language))
		return
	var/list/localized_list = sanitize_islist(value, list())
	if(!length(localized_list))
		return
	switch(field)
		if("message")
			localized_messages[language] = localized_list
		if("user_messages")
			localized_user_messages[language] = localized_list
		if("target_messages")
			localized_target_messages[language] = localized_list

/datum/interaction/proc/load_localization_data(language, list/localization)
	if(!islist(localization))
		return
	load_localized_message_list(language, "message", localization["message"])
	load_localized_message_list(language, "user_messages", localization["user_messages"])
	load_localized_message_list(language, "target_messages", localization["target_messages"])

/datum/interaction/proc/get_message_options_for_language(list/default_messages, list/localized_options, language)
	if(length(language) && islist(localized_options))
		var/list/language_options = localized_options[language]
		if(length(language_options))
			return language_options
	return default_messages

/datum/interaction/proc/get_message_option_for_language(list/default_messages, list/localized_options, language, message_index)
	var/list/language_options = get_message_options_for_language(default_messages, localized_options, language)
	if(!length(language_options))
		return null
	if(message_index && message_index <= length(language_options))
		return language_options[message_index]
	return pick(language_options)

/datum/interaction/proc/get_message_language(mob/reader)
	return get_panel_language_value(reader, "interaction")

/proc/hides_interaction_messages_from_ghosts(mob/source)
	return !!source?.client?.prefs?.read_preference(/datum/preference/toggle/erp/hide_interactions_from_ghosts)

/datum/interaction/proc/format_interaction_message(message_text, mob/living/carbon/human/user, mob/living/carbon/human/target, obj/item/display_item)
	message_text = replacetext(replacetext(message_text, "%TARGET%", "[target]"), "%USER%", "[user]")
	message_text = replacetext(replacetext(message_text, "%TARGET_PRONOUN_THEIR%", target.p_their()), "%TARGET_PRONOUN_THEIRS%", target.p_theirs())
	message_text = replacetext(replacetext(message_text, "%USER_PRONOUN_THEIR%", user.p_their()), "%USER_PRONOUN_THEIRS%", user.p_theirs())
	message_text = replacetext(replacetext(message_text, "%TARGET_PRONOUN_THEM%", target.p_them()), "%USER_PRONOUN_THEM%", user.p_them())
	message_text = replacetext(replacetext(message_text, "%TARGET_PRONOUN_THEY%", target.p_they()), "%USER_PRONOUN_THEY%", user.p_they())
	return replacetext(message_text, "%ITEM%", display_item ? "[display_item.name]" : "item")

/datum/interaction/proc/format_visible_interaction_message(language, message_index, mob/living/carbon/human/user, mob/living/carbon/human/target, obj/item/display_item)
	var/msg = get_message_option_for_language(message, localized_messages, language, message_index)
	if(!msg)
		return null
	// manual_emote and the lewd visible message both prepend the acting mob separately.
	msg = trim(replacetext(replacetext(msg, "%TARGET%", "[target]"), "%USER%", ""), INTERACTION_MAX_CHAR)
	return format_interaction_message(msg, user, target, display_item)

/datum/interaction/proc/get_visible_interaction_language_groups(mob/living/carbon/human/user, list/ignored_mobs)
	var/list/language_groups = list()
	var/list/hearers = mob_only_listeners(get_hearers_in_view(DEFAULT_MESSAGE_RANGE, user))
	if(hides_interaction_messages_from_ghosts(user))
		for(var/mob/hearing_mob as anything in hearers)
			if(isobserver(hearing_mob))
				ignored_mobs += hearing_mob
	hearers -= ignored_mobs
	for(var/mob/hearing_mob as anything in hearers)
		if(!hearing_mob?.client)
			continue
		var/language = get_message_language(hearing_mob)
		if(!language_groups[language])
			language_groups[language] = list()
		language_groups[language] += hearing_mob
	return list("groups" = language_groups, "hearers" = hearers)

/datum/interaction/proc/build_ignored_mobs_except_language_group(list/base_ignored_mobs, list/hearers, list/language_group)
	var/list/group_ignored_mobs = base_ignored_mobs.Copy()
	for(var/mob/hearing_mob as anything in hearers)
		if(!(hearing_mob in language_group))
			group_ignored_mobs += hearing_mob
	return group_ignored_mobs

/datum/interaction/proc/show_localized_manual_emote_ghosts(message_index, mob/living/carbon/human/user, mob/living/carbon/human/target, obj/item/display_item)
	if(hides_interaction_messages_from_ghosts(user))
		return
	var/origin_turf = get_turf(user)
	for(var/mob/ghost as anything in GLOB.dead_mob_list)
		if(!ghost.client || isnewplayer(ghost))
			continue
		if(!(get_chat_toggles(ghost.client) & CHAT_GHOSTSIGHT) || (ghost in viewers(origin_turf, null)))
			continue
		var/ghost_msg = format_visible_interaction_message(get_message_language(ghost), message_index, user, target, display_item)
		if(!ghost_msg)
			continue
		ghost.show_message("[FOLLOW_LINK(ghost, user)] <b>[user]</b> [ghost_msg]")

/datum/interaction/proc/show_localized_visible_interaction_message(message_index, mob/living/carbon/human/user, mob/living/carbon/human/target, obj/item/display_item, list/ignored_mobs)
	var/list/base_ignored_mobs = islist(ignored_mobs) ? ignored_mobs.Copy() : list()
	var/list/language_payload = get_visible_interaction_language_groups(user, base_ignored_mobs)
	var/list/language_groups = language_payload["groups"]
	var/list/hearers = language_payload["hearers"]

	if(!lewd)
		var/log_msg = format_visible_interaction_message(get_message_language(user), message_index, user, target, display_item)
		if(log_msg && user.client)
			user.log_message(log_msg, LOG_EMOTE)

	for(var/language in language_groups)
		var/list/language_group = language_groups[language]
		var/msg = format_visible_interaction_message(language, message_index, user, target, display_item)
		if(!msg)
			continue
		var/list/group_ignored_mobs = build_ignored_mobs_except_language_group(base_ignored_mobs, hearers, language_group)
		if(lewd)
			user.visible_message(span_purple("[user] [msg]"), ignored_mobs = group_ignored_mobs)
		else
			user.visible_message(msg, ignored_mobs = group_ignored_mobs, visible_message_flags = EMOTE_MESSAGE)

	if(!lewd)
		show_localized_manual_emote_ghosts(message_index, user, target, display_item)

/datum/interaction/proc/show_localized_subtler_interaction_message(message_index, mob/living/carbon/human/user, mob/living/carbon/human/target, obj/item/display_item)
	if(user.stat != CONSCIOUS)
		to_chat(user, span_warning("You can't emote at this time."))
		return FALSE
	if(SSdbcore.IsConnected() && is_banned_from(user, "emote"))
		to_chat(user, span_warning("You cannot send subtle emotes (banned)."))
		return FALSE
	if(user.client?.prefs.muted & MUTE_IC)
		to_chat(user, span_warning("You cannot send IC messages (muted)."))
		return FALSE

	var/log_msg = format_visible_interaction_message(get_message_language(user), message_index, user, target, display_item)
	if(!log_msg)
		return FALSE
	user.log_message(log_msg, LOG_SUBTLER)

	var/list/receivers = get_hearers_in_view(1, user) - GLOB.dead_mob_list

	var/obj/effect/overlay/holo_pad_hologram/hologram = GLOB.hologram_impersonators[user]
	if(hologram)
		receivers |= get_hearers_in_view(1, hologram)

	for(var/obj/effect/overlay/holo_pad_hologram/iterating_hologram in receivers)
		if(iterating_hologram?.Impersonation?.client)
			receivers |= iterating_hologram.Impersonation
	for(var/obj/item/dullahan_relay/dullahan in receivers)
		receivers -= dullahan
		receivers += dullahan.owner

	for(var/mob/receiver in receivers)
		if(!receiver?.client)
			continue
		if(!receiver.client?.prefs?.read_preference(/datum/preference/toggle/erp))
			continue
		var/receiver_msg = format_visible_interaction_message(get_message_language(receiver), message_index, user, target, display_item)
		if(!receiver_msg)
			continue
		var/space = should_have_space_before_emote(html_decode(receiver_msg)[1]) ? " " : ""
		var/subtler_message = span_subtler("<b>[user]</b>[space]<i>[user.apply_message_emphasis(receiver_msg)]</i>")
		receiver.show_message(subtler_message, alt_msg = subtler_message)
		if(!isobserver(receiver))
			var/datum/preferences/prefs = receiver.client?.prefs
			if(prefs && prefs.read_preference(/datum/preference/toggle/subtler_sound))
				receiver.playsound_local(get_turf(receiver), 'sound/effects/achievement/glockenspiel_ping.ogg', 50)
	return TRUE

/proc/interaction_json_to_typepath(value, expected_parent)
	if(ispath(value))
		if(ispath(value, expected_parent))
			return value
		return null
	if(!istext(value))
		return null
	var/typepath = text2path(value)
	if(!ispath(typepath, expected_parent))
		return null
	return typepath

/proc/interaction_json_to_typepath_list(value, expected_parent)
	var/list/raw_values = sanitize_islist(value, list())
	var/list/typepaths = list()
	for(var/raw_value in raw_values)
		var/typepath = interaction_json_to_typepath(raw_value, expected_parent)
		if(ispath(typepath, expected_parent))
			typepaths += typepath
	return typepaths

/datum/interaction/proc/get_matching_held_item(mob/living/carbon/human/user)
	if(!length(user_required_item_paths))
		return null
	var/obj/item/held_item = user?.get_active_held_item()
	if(!held_item)
		return null
	for(var/item_path in user_blocked_item_paths)
		if(ispath(item_path) && istype(held_item, item_path))
			return null
	for(var/item_path in user_required_item_paths)
		if(ispath(item_path) && istype(held_item, item_path))
			return held_item
	return null

/datum/interaction/proc/get_matching_target_item(mob/living/carbon/human/target)
	if(!length(target_required_item_slots) && !length(target_required_item_paths))
		return null
	if(!target)
		return null

	var/list/search_slots = length(target_required_item_slots) ? target_required_item_slots : list(
		ORGAN_SLOT_VAGINA,
		ORGAN_SLOT_PENIS,
		ORGAN_SLOT_ANUS,
		ORGAN_SLOT_NIPPLES,
	)

	for(var/slot_name in search_slots)
		var/obj/item/slot_item = target.vars[slot_name]
		if(!slot_item)
			continue
		var/blocked = FALSE
		for(var/blocked_path in target_blocked_item_paths)
			if(ispath(blocked_path) && istype(slot_item, blocked_path))
				blocked = TRUE
				break
		if(blocked)
			continue
		if(!length(target_required_item_paths))
			return slot_item
		for(var/item_path in target_required_item_paths)
			if(ispath(item_path) && istype(slot_item, item_path))
				return slot_item

	return null

/datum/interaction/proc/allow_act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target == user && usage == INTERACTION_OTHER)
		return FALSE

	if(target != user && usage == INTERACTION_SELF)
		return FALSE

	if(user_required_parts.len)
		for(var/thing in user_required_parts)
			if(user.get_lewd_part_state(thing) != "open")
				return FALSE

	if(user_required_any_parts.len)
		for(var/thing in user_required_any_parts)
			if(isnull(user.get_lewd_part_state(thing)))
				return FALSE

	if(target_required_parts.len)
		for(var/thing in target_required_parts)
			if(target.get_lewd_part_state(thing) != "open")
				return FALSE

	if(target_required_any_parts.len)
		for(var/thing in target_required_any_parts)
			if(isnull(target.get_lewd_part_state(thing)))
				return FALSE

	if(length(user_required_item_paths) && !get_matching_held_item(user))
		return FALSE

	if((length(target_required_item_slots) || length(target_required_item_paths)) && !get_matching_target_item(target))
		return FALSE

	for(var/requirement in interaction_requires)
		switch(requirement)
			if(INTERACTION_REQUIRE_SELF_HAND)
				if(!user.get_active_hand())
					return FALSE
			if(INTERACTION_REQUIRE_TARGET_HAND)
				if(!target.get_active_hand())
					return FALSE
			if(INTERACTION_REQUIRE_SELF_MOUTH)
				if(user.get_lewd_part_state("mouth") != "open")
					return FALSE
			if(INTERACTION_REQUIRE_TARGET_MOUTH)
				if(target.get_lewd_part_state("mouth") != "open")
					return FALSE
			if(INTERACTION_REQUIRE_SELF_TK)
				if(!user.dna?.check_mutation(/datum/mutation/telekinesis))
					return FALSE

			else
				CRASH("Unimplemented interaction requirement '[requirement]'")
	return TRUE

/datum/interaction/proc/act(mob/living/carbon/human/user, mob/living/carbon/human/target, use_subtler)
	if(!allow_act(user, target))
		return
	var/obj/item/held_item = get_matching_held_item(user)
	var/obj/item/target_item = get_matching_target_item(target)
	var/obj/item/display_item = held_item || target_item
	if(!message)
		message_admins("Interaction had a null message list. '[html_encode(name)]'")
		return
	if(!islist(message) && istext(message))
		message_admins("Deprecated message handling for '[html_encode(name)]'. Correct format is a list with one entry. This message will only show once.")
		message = list(message)
	if(!length(message))
		message_admins("Interaction had an empty message list. '[html_encode(name)]'")
		return
	var/message_index = rand(1, length(message))

	if(lewd)
		var/msg = format_visible_interaction_message(get_message_language(user), message_index, user, target, display_item)
		if(!msg)
			return
		if(use_subtler)
			show_localized_subtler_interaction_message(message_index, user, target, display_item)
		else
			var/list/ignoring_mobs = list()
			for(var/mob/not_interested in get_hearers_in_view(DEFAULT_MESSAGE_RANGE, user))
				if(!not_interested.client?.prefs?.read_preference(/datum/preference/toggle/erp))
					ignoring_mobs += not_interested
			show_localized_visible_interaction_message(message_index, user, target, display_item, ignoring_mobs)
			user.log_message(msg, LOG_EMOTE)
	else
		if(user.stat == CONSCIOUS)
			show_localized_visible_interaction_message(message_index, user, target, display_item)

	if(user_messages.len)
		var/list/user_message_options = get_message_options_for_language(user_messages, localized_user_messages, get_message_language(user))
		var/user_msg = format_interaction_message(pick(user_message_options), user, target, display_item)
		to_chat(user, user_msg)

	if(target_messages.len)
		var/list/target_message_options = get_message_options_for_language(target_messages, localized_target_messages, get_message_language(target))
		var/target_msg = format_interaction_message(pick(target_message_options), user, target, display_item)
		to_chat(target, target_msg)

	if(sound_use)
		if(!sound_possible)
			message_admins("Interaction has sound_use set to TRUE but does not set sound! '[html_encode(name)]'")
			return
		if(!islist(sound_possible) && istext(sound_possible))
			message_admins("Deprecated sound handling for '[html_encode(name)]'. Correct format is a list with one entry. This message will only show once.")
			sound_possible = list(sound_possible)
		sound_cache = pick(sound_possible)
		if (lewd)
			playsound_if_pref(target.loc, sound_cache, 50, sound_vary, max(0, -SOUND_RANGE + sound_range), pref_to_check = /datum/preference/toggle/erp/sounds)
		else
			playsound(target.loc, sound_cache, 50, sound_vary, max(0, -SOUND_RANGE + sound_range))

	INVOKE_ASYNC(src, PROC_REF(apply_effects), user, target)


/datum/interaction/proc/resolve_effect_value(value)
	if(isnull(value))
		return 0
	if(islist(value))
		var/list/range = value
		if(!range.len)
			return 0
		var/min_value = sanitize_integer(range[1], 0, 100, 0)
		var/max_value = min_value
		if(range.len >= 2)
			max_value = sanitize_integer(range[2], 0, 100, min_value)
		if(max_value < min_value)
			var/temp = min_value
			min_value = max_value
			max_value = temp
		return rand(min_value, max_value)
	if(!isnum(value))
		return 0
	var/fixed_value = sanitize_integer(value, 0, 100, 0)
	if(fixed_value <= 0)
		return 0
	if(fixed_value == 1)
		return rand(0, 1)
	return rand(max(0, fixed_value - 1), min(100, fixed_value + 1))


/datum/interaction/proc/load_effect_value(value)
	if(islist(value))
		var/list/raw_range = value
		if(!raw_range.len)
			return 0
		var/min_value = sanitize_integer(raw_range[1], 0, 100, 0)
		var/max_value = min_value
		if(raw_range.len >= 2)
			max_value = sanitize_integer(raw_range[2], 0, 100, min_value)
		if(max_value < min_value)
			var/temp = min_value
			min_value = max_value
			max_value = temp
		return list(min_value, max_value)
	return sanitize_integer(value, 0, 100, 0)


/datum/interaction/proc/apply_effects(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/resolved_user_pain = resolve_effect_value(user_pain)
	var/resolved_target_pain = resolve_effect_value(target_pain)
	var/resolved_user_pleasure = resolve_effect_value(user_pleasure)
	var/resolved_user_arousal = resolve_effect_value(user_arousal)
	var/resolved_target_pleasure = resolve_effect_value(target_pleasure)
	var/resolved_target_arousal = resolve_effect_value(target_arousal)
	if(resolved_user_pain)
		user.adjust_pain(resolved_user_pain)
	if(resolved_target_pain)
		target.adjust_pain(resolved_target_pain)
	if(!lewd)
		return
	if(resolved_user_pleasure)
		user.adjust_pleasure(resolved_user_pleasure)
	if(resolved_user_arousal)
		user.adjust_arousal(resolved_user_arousal)
	if(resolved_target_pleasure)
		target.adjust_pleasure(resolved_target_pleasure)
	if(resolved_target_arousal)
		target.adjust_arousal(resolved_target_arousal)

/datum/interaction/proc/load_from_json(path)
	var/fpath = path
	if(!fexists(fpath))
		message_admins("Attempted to load an interaction from json and the file does not exist")
		qdel(src)
		return FALSE
	var/file = file(fpath)
	var/list/json = json_load(file)
	return load_from_json_data(json)

/datum/interaction/proc/load_from_json_data(list/json, fallback_name)
	if(!islist(json))
		return FALSE
	if("interaction_id" in json)
		interaction_id = sanitize_text(json["interaction_id"])
	if("name" in json)
		name = sanitize_text(json["name"])
	else if(length(fallback_name) && !length(name))
		name = sanitize_text(fallback_name)
	if("translation_key" in json)
		translation_key = sanitize_text(json["translation_key"])
	if("description" in json)
		description = sanitize_text(json["description"])
	if("description_translation_key" in json)
		description_translation_key = sanitize_text(json["description_translation_key"])
	if("distance_allowed" in json)
		distance_allowed = sanitize_integer(json["distance_allowed"], 0, 1, 0)
	if("message" in json)
		message = sanitize_islist(json["message"], list("json error"))
	if("message_ru" in json)
		load_localized_message_list("russian", "message", json["message_ru"])
	if("category" in json)
		category = sanitize_text(json["category"])
	if("category_translation_key" in json)
		category_translation_key = sanitize_text(json["category_translation_key"])
	if("usage" in json)
		usage = sanitize_text(json["usage"])
	if("sound_use" in json)
		sound_use = sanitize_integer(json["sound_use"], 0, 1, 0)
	if("sound_range" in json)
		sound_range = sanitize_integer(json["sound_range"], 1, 7, 1)
	if("sound_vary" in json)
		sound_vary = sanitize_integer(json["sound_vary"], 0, 1, 1)
	if("sound_possible" in json)
		sound_possible = sanitize_islist(json["sound_possible"], list("json error"))
	if("interaction_requires" in json)
		interaction_requires = sanitize_islist(json["interaction_requires"], list())
	if("color" in json)
		color = sanitize_text(json["color"])

	if("user_messages" in json)
		user_messages = sanitize_islist(json["user_messages"], list())
	if("user_messages_ru" in json)
		load_localized_message_list("russian", "user_messages", json["user_messages_ru"])
	if("user_required_parts" in json)
		user_required_parts = sanitize_islist(json["user_required_parts"], list())
	if("user_required_any_parts" in json)
		user_required_any_parts = sanitize_islist(json["user_required_any_parts"], list())
	if("user_required_item_paths" in json)
		user_required_item_paths = interaction_json_to_typepath_list(json["user_required_item_paths"], /obj/item)
	if("user_blocked_item_paths" in json)
		user_blocked_item_paths = interaction_json_to_typepath_list(json["user_blocked_item_paths"], /obj/item)
	if("user_arousal" in json)
		user_arousal = load_effect_value(json["user_arousal"])
	if("user_pleasure" in json)
		user_pleasure = load_effect_value(json["user_pleasure"])
	if("user_pain" in json)
		user_pain = load_effect_value(json["user_pain"])
	if("target_messages" in json)
		target_messages = sanitize_islist(json["target_messages"], list())
	if("target_messages_ru" in json)
		load_localized_message_list("russian", "target_messages", json["target_messages_ru"])
	if("target_required_parts" in json)
		target_required_parts = sanitize_islist(json["target_required_parts"], list())
	if("target_required_any_parts" in json)
		target_required_any_parts = sanitize_islist(json["target_required_any_parts"], list())
	if("target_required_item_slots" in json)
		target_required_item_slots = sanitize_islist(json["target_required_item_slots"], list())
	if("target_required_item_paths" in json)
		target_required_item_paths = interaction_json_to_typepath_list(json["target_required_item_paths"], /obj/item)
	if("target_blocked_item_paths" in json)
		target_blocked_item_paths = interaction_json_to_typepath_list(json["target_blocked_item_paths"], /obj/item)
	if("target_arousal" in json)
		target_arousal = load_effect_value(json["target_arousal"])
	if("target_pleasure" in json)
		target_pleasure = load_effect_value(json["target_pleasure"])
	if("target_pain" in json)
		target_pain = load_effect_value(json["target_pain"])
	if("lewd" in json)
		lewd = sanitize_integer(json["lewd"], 0, 1, 0)
	if("sexuality" in json)
		sexuality = sanitize_text(json["sexuality"])
	if("register_in_menu" in json)
		register_in_menu = sanitize_integer(json["register_in_menu"], 0, 1, 1)
	return TRUE

/datum/interaction/proc/json_save(path)
	var/fpath = path
	if(fexists(fpath))
		fdel(fpath)
	var/list/json = list(
		"interaction_id" = interaction_id,
		"name" = name,
		"translation_key" = translation_key,
		"description" = description,
		"description_translation_key" = description_translation_key,
		"distance_allowed" = distance_allowed,
		"message" = message,
		"category" = category,
		"category_translation_key" = category_translation_key,
		"usage" = usage,
		"sound_use" = sound_use,
		"sound_range" = sound_range,
		"sound_vary" = sound_vary,
		"sound_possible" = sound_possible,
		"interaction_requires" = interaction_requires,
		"color" = color,
		"user_messages" = user_messages,
		"user_required_parts" = user_required_parts,
		"user_required_any_parts" = user_required_any_parts,
		"user_required_item_paths" = user_required_item_paths,
		"user_blocked_item_paths" = user_blocked_item_paths,
		"user_arousal" = user_arousal,
		"user_pleasure" = user_pleasure,
		"user_pain" = user_pain,
		"target_messages" = target_messages,
		"target_required_parts" = target_required_parts,
		"target_required_any_parts" = target_required_any_parts,
		"target_required_item_slots" = target_required_item_slots,
		"target_required_item_paths" = target_required_item_paths,
		"target_blocked_item_paths" = target_blocked_item_paths,
		"target_arousal" = target_arousal,
		"target_pleasure" = target_pleasure,
		"target_pain" = target_pain,
		"lewd" = lewd,
		"sexuality" = sexuality,
		"register_in_menu" = register_in_menu,
	)
	var/file = file(fpath)
	WRITE_FILE(file, json_encode(json))
	return TRUE

/// Global loading procs
/proc/should_register_interaction_instance(datum/interaction/interaction, spath)
	if(!interaction.register_in_menu)
		return FALSE
	if(interaction.name != initial(/datum/interaction::name))
		return TRUE
	if(interaction.description != initial(/datum/interaction::description))
		return TRUE
	if(interaction.category == INTERACTION_CAT_HIDE)
		return FALSE
	if(length(subtypesof(spath)))
		return FALSE
	return TRUE

/proc/build_interaction_instance_from_json(list/json, source_name)
	if(!islist(json))
		return null
	var/template_type = null
	if("template_type" in json)
		template_type = interaction_json_to_typepath(json["template_type"], /datum/interaction)
		if(!ispath(template_type, /datum/interaction))
			message_admins("Interaction json '[html_encode(source_name)]' specified an invalid template type.")
			return null

	var/datum/interaction/interaction = ispath(template_type, /datum/interaction) ? new template_type() : new()
	if(!interaction.load_from_json_data(json, source_name))
		qdel(interaction)
		return null
	return interaction

/proc/populate_interaction_instances()
	QDEL_LIST_ASSOC_VAL(GLOB.interaction_instances)
	for(var/spath in subtypesof(/datum/interaction))
		var/datum/interaction/interaction = new spath()
		if(!should_register_interaction_instance(interaction, spath))
			qdel(interaction)
			continue
		interaction.interaction_id = "[spath]"
		GLOB.interaction_instances[interaction.get_interaction_id()] = interaction
	for(var/directory in get_interaction_json_directories())
		populate_interaction_jsons(directory)
	apply_interaction_localization_file("russian", "config/interaction_localization/russian.json")

/proc/apply_interaction_localization_file(language, path)
	if(!length(language) || !fexists(path))
		return
	var/file = file(path)
	var/list/localizations = json_load(file)
	if(!islist(localizations))
		return
	for(var/interaction_id in localizations)
		var/datum/interaction/interaction = GLOB.interaction_instances[interaction_id]
		if(!interaction)
			continue
		interaction.load_localization_data(language, localizations[interaction_id])

/proc/get_interaction_json_directories()
	var/list/directories = list(INTERACTION_JSON_FOLDER)
	if(length(INTERACTION_LEGACY_JSON_FOLDER) && !(INTERACTION_LEGACY_JSON_FOLDER in directories))
		directories += INTERACTION_LEGACY_JSON_FOLDER
	return directories

/proc/populate_interaction_jsons(directory)
	for(var/file in flist(directory))
		var/entry_path = "[directory][file]"
		if(flist(entry_path) && !findlasttext(entry_path, ".json"))
			populate_interaction_jsons(entry_path)
			continue
		if(findlasttext(entry_path, ".master.json")) // This is a master json which has special handling
			populate_interaction_jsons_master(entry_path)
			continue
		var/file_handle = file(entry_path)
		var/list/json = json_load(file_handle)
		var/datum/interaction/interaction = build_interaction_instance_from_json(json, entry_path)
		if(!interaction)
			message_admins("Error loading interaction from file: '[html_encode(entry_path)]'. Inform coders.")
			continue
		if(!length(interaction.interaction_id))
			interaction.interaction_id = "json:[interaction.name]"
		if(GLOB.interaction_instances[interaction.get_interaction_id()])
			message_admins("Interaction file '[html_encode(entry_path)]' tried to register a duplicate interaction id '[html_encode(interaction.get_interaction_id())]'.")
			qdel(interaction)
			continue
		GLOB.interaction_instances[interaction.get_interaction_id()] = interaction

/proc/populate_interaction_jsons_master(path)
	if(!fexists(path))
		message_admins("We are attempting to load an interaction master without the file existing! '[path]'")
		return
	var/file = file(path)
	var/list/json = json_load(file)

	for(var/entry_key in json)
		var/list/entry_json = json[entry_key]
		var/datum/interaction/interaction = build_interaction_instance_from_json(entry_json, "[path]::[entry_key]")
		if(!interaction)
			message_admins("Interaction Master '[html_encode(path)]' contained an invalid interaction! '[html_encode(entry_key)]'")
			continue
		if(!length(interaction.interaction_id))
			interaction.interaction_id = "json:[entry_key]"
		if(GLOB.interaction_instances[interaction.get_interaction_id()])
			message_admins("Interaction Master '[html_encode(path)]' contained a duplicate interaction id! '[html_encode(interaction.get_interaction_id())]'")
			qdel(interaction)
			continue
		GLOB.interaction_instances[interaction.get_interaction_id()] = interaction

ADMIN_VERB(reload_interactions, R_DEBUG, "Reload Interactions", "Force reload interactions.", ADMIN_CATEGORY_DEBUG)
	populate_interaction_instances()
