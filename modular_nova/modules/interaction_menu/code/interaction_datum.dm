
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
	/// A list of possible messages displayed directly to the USER.
	var/list/user_messages = list()
	/// A list of possible messages displayed directly to the TARGET.
	var/list/target_messages = list()
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

	if(target_required_parts.len)
		for(var/thing in target_required_parts)
			if(target.get_lewd_part_state(thing) != "open")
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
	var/msg = pick(message)
	// We replace %USER% with nothing because manual_emote already prepends it.
	msg = trim(replacetext(replacetext(msg, "%TARGET%", "[target]"), "%USER%", ""), INTERACTION_MAX_CHAR)
	msg = replacetext(replacetext(msg, "%TARGET_PRONOUN_THEIR%", target.p_their()), "%TARGET_PRONOUN_THEIRS%", target.p_theirs())
	msg = replacetext(replacetext(msg, "%USER_PRONOUN_THEIR%", user.p_their()), "%USER_PRONOUN_THEIRS%", user.p_theirs())
	msg = replacetext(replacetext(msg, "%TARGET_PRONOUN_THEM%", target.p_them()), "%USER_PRONOUN_THEM%", user.p_them())
	msg = replacetext(replacetext(msg, "%TARGET_PRONOUN_THEY%", target.p_they()), "%USER_PRONOUN_THEY%", user.p_they())
	msg = replacetext(msg, "%ITEM%", display_item ? "[display_item.name]" : "item")

	if(lewd)
		if(use_subtler)
			user.emote("subtler", type_override = /datum/emote/living/subtler::emote_type | EMOTE_LEWD, message = msg, intentional = TRUE)
		else
			var/list/ignoring_mobs = list()
			for(var/mob/not_interested in get_hearers_in_view(DEFAULT_MESSAGE_RANGE, user))
				if(!not_interested.client?.prefs?.read_preference(/datum/preference/toggle/erp))
					ignoring_mobs += not_interested
			user.visible_message(span_purple("[user] [msg]"), ignored_mobs = ignoring_mobs)
			user.log_message(msg, LOG_EMOTE)
	else
		user.manual_emote(msg)

	if(user_messages.len)
		var/user_msg = pick(user_messages)
		user_msg = replacetext(replacetext(user_msg, "%TARGET%", "[target]"), "%USER%", "[user]")
		user_msg = replacetext(replacetext(user_msg, "%TARGET_PRONOUN_THEIR%", target.p_their()), "%TARGET_PRONOUN_THEIRS%", target.p_theirs())
		user_msg = replacetext(replacetext(user_msg, "%USER_PRONOUN_THEIR%", user.p_their()), "%USER_PRONOUN_THEIRS%", user.p_theirs())
		user_msg = replacetext(replacetext(user_msg, "%TARGET_PRONOUN_THEM%", target.p_them()), "%USER_PRONOUN_THEM%", user.p_them())
		user_msg = replacetext(replacetext(user_msg, "%TARGET_PRONOUN_THEY%", target.p_they()), "%USER_PRONOUN_THEY%", user.p_they())
		to_chat(user, user_msg)

	if(target_messages.len)
		var/target_msg = pick(target_messages)
		target_msg = replacetext(replacetext(target_msg, "%TARGET%", "[target]"), "%USER%", "[user]")
		target_msg = replacetext(replacetext(target_msg, "%TARGET_PRONOUN_THEIR%", target.p_their()), "%TARGET_PRONOUN_THEIRS%", target.p_theirs())
		target_msg = replacetext(replacetext(target_msg, "%USER_PRONOUN_THEIR%", user.p_their()), "%USER_PRONOUN_THEIRS%", user.p_theirs())
		target_msg = replacetext(replacetext(target_msg, "%TARGET_PRONOUN_THEM%", target.p_them()), "%USER_PRONOUN_THEM%", user.p_them())
		target_msg = replacetext(replacetext(target_msg, "%TARGET_PRONOUN_THEY%", target.p_they()), "%USER_PRONOUN_THEY%", user.p_they())
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
	name = sanitize_text(json["name"])
	translation_key = sanitize_text(json["translation_key"])
	description = sanitize_text(json["description"])
	description_translation_key = sanitize_text(json["description_translation_key"])
	distance_allowed = sanitize_integer(json["distance_allowed"], 0, 1, 0)
	message = sanitize_islist(json["message"], list("json error"))
	category = sanitize_text(json["category"])
	category_translation_key = sanitize_text(json["category_translation_key"])
	usage = sanitize_text(json["usage"])
	sound_use = sanitize_integer(json["sound_use"], 0, 1, 0)
	sound_range = sanitize_integer(json["sound_range"], 1, 7, 1)
	sound_vary = sanitize_integer(json["sound_vary"], 0, 1, 1)
	sound_possible = sanitize_islist(json["sound_possible"], list("json error"))
	interaction_requires = sanitize_islist(json["interaction_requires"], list())
	color = sanitize_text(json["color"])

	user_messages = sanitize_islist(json["user_messages"], list())
	user_required_parts = sanitize_islist(json["user_required_parts"], list())
	user_required_item_paths = sanitize_islist(json["user_required_item_paths"], list())
	user_blocked_item_paths = sanitize_islist(json["user_blocked_item_paths"], list())
	user_arousal = load_effect_value(json["user_arousal"])
	user_pleasure = load_effect_value(json["user_pleasure"])
	user_pain = load_effect_value(json["user_pain"])
	target_messages = sanitize_islist(json["target_messages"], list())
	target_required_parts = sanitize_islist(json["target_required_parts"], list())
	target_required_item_slots = sanitize_islist(json["target_required_item_slots"], list())
	target_required_item_paths = sanitize_islist(json["target_required_item_paths"], list())
	target_blocked_item_paths = sanitize_islist(json["target_blocked_item_paths"], list())
	target_arousal = load_effect_value(json["target_arousal"])
	target_pleasure = load_effect_value(json["target_pleasure"])
	target_pain = load_effect_value(json["target_pain"])
	lewd = sanitize_integer(json["lewd"], 0, 1, 0)
	sexuality = sanitize_text(json["sexuality"])
	return TRUE

/datum/interaction/proc/json_save(path)
	var/fpath = path
	if(fexists(fpath))
		fdel(fpath)
	var/list/json = list(
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
		"user_required_item_paths" = user_required_item_paths,
		"user_blocked_item_paths" = user_blocked_item_paths,
		"user_arousal" = user_arousal,
		"user_pleasure" = user_pleasure,
		"user_pain" = user_pain,
		"target_messages" = target_messages,
		"target_required_parts" = target_required_parts,
		"target_required_item_slots" = target_required_item_slots,
		"target_required_item_paths" = target_required_item_paths,
		"target_blocked_item_paths" = target_blocked_item_paths,
		"target_arousal" = target_arousal,
		"target_pleasure" = target_pleasure,
		"target_pain" = target_pain,
		"lewd" = lewd,
		"sexuality" = sexuality,
	)
	var/file = file(fpath)
	WRITE_FILE(file, json_encode(json))
	return TRUE

/// Global loading procs
/proc/should_register_interaction_instance(datum/interaction/interaction, spath)
	if(interaction.name != initial(/datum/interaction::name))
		return TRUE
	if(interaction.description != initial(/datum/interaction::description))
		return TRUE
	if(interaction.category == INTERACTION_CAT_HIDE)
		return FALSE
	if(length(subtypesof(spath)))
		return FALSE
	return TRUE

/proc/populate_interaction_instances()
	for(var/spath in subtypesof(/datum/interaction))
		var/datum/interaction/interaction = new spath()
		if(!should_register_interaction_instance(interaction, spath))
			qdel(interaction)
			continue
		interaction.interaction_id = "[spath]"
		GLOB.interaction_instances[interaction.get_interaction_id()] = interaction
	populate_interaction_jsons(INTERACTION_JSON_FOLDER)

/proc/populate_interaction_jsons(directory)
	for(var/file in flist(directory))
		if(flist(directory + file) && !findlasttext(directory + file, ".json"))
			populate_interaction_instances(directory + file)
			continue
		if(findlasttext(directory + file, ".master.json")) // This is a master json which has special handling
			populate_interaction_jsons_master(directory + file)
			continue
		var/datum/interaction/interaction = new()
		if(interaction.load_from_json(directory + file))
			interaction.interaction_id = "json:[interaction.name]"
			GLOB.interaction_instances[interaction.get_interaction_id()] = interaction
		else message_admins("Error loading interaction from file: '[html_encode(directory + file)]'. Inform coders.")

/proc/populate_interaction_jsons_master(path)
	if(!fexists(path))
		message_admins("We are attempting to load an interaction master without the file existing! '[path]'")
		return
	var/file = file(path)
	var/list/json = json_load(file)

	for(var/iname in json)
		if(GLOB.interaction_instances["json:[iname]"])
			message_admins("Interaction Master '[html_encode(path)]' contained a duplicate interaction! '[html_encode(iname)]'")
			continue

		var/list/ijson = json[iname]
		if(ijson["name"] != iname)
			message_admins("Interaction Master '[html_encode(path)]' contained an invalid interaction! '[html_encode(iname)]'")
			continue

		var/datum/interaction/interaction = new()

		interaction.name = sanitize_text(ijson["name"] || iname)
		interaction.translation_key = sanitize_text(ijson["translation_key"])
		interaction.description = sanitize_text(ijson["description"])
		interaction.description_translation_key = sanitize_text(ijson["description_translation_key"])
		interaction.distance_allowed = sanitize_integer(ijson["distance_allowed"], 0, 1, 0)
		interaction.message = sanitize_islist(ijson["message"], list("json error"))
		interaction.category = sanitize_text(ijson["category"])
		interaction.category_translation_key = sanitize_text(ijson["category_translation_key"])
		interaction.usage = sanitize_text(ijson["usage"])
		interaction.sound_use = sanitize_integer(ijson["sound_use"], 0, 1, 0)
		interaction.sound_range = sanitize_integer(ijson["sound_range"], 1, 7, 1)
		interaction.sound_vary = sanitize_integer(ijson["sound_vary"], 0, 1, 1)
		interaction.sound_possible = sanitize_islist(ijson["sound_possible"], list("json error"))
		interaction.interaction_requires = sanitize_islist(ijson["interaction_requires"], list())
		interaction.color = sanitize_text(ijson["color"])

		interaction.user_messages = sanitize_islist(ijson["user_messages"], list())
		interaction.user_required_parts = sanitize_islist(ijson["user_required_parts"], list())
		interaction.user_arousal = sanitize_integer(ijson["user_arousal"], 0, 100, 0)
		interaction.user_pleasure = sanitize_integer(ijson["user_pleasure"], 0, 100, 0)
		interaction.user_pain = sanitize_integer(ijson["user_pain"], 0, 100, 0)
		interaction.target_messages = sanitize_islist(ijson["target_messages"], list())
		interaction.target_required_parts = sanitize_islist(ijson["target_required_parts"], list())
		interaction.target_arousal = sanitize_integer(ijson["target_arousal"], 0, 100, 0)
		interaction.target_pleasure = sanitize_integer(ijson["target_pleasure"], 0, 100, 0)
		interaction.target_pain = sanitize_integer(ijson["target_pain"], 0, 100, 0)
		interaction.lewd = sanitize_integer(ijson["lewd"], 0, 1, 0)
		interaction.sexuality = sanitize_text(ijson["sexuality"])

		interaction.interaction_id = "json:[iname]"
		GLOB.interaction_instances[interaction.get_interaction_id()] = interaction

ADMIN_VERB(reload_interactions, R_DEBUG, "Reload Interactions", "Force reload interactions.", ADMIN_CATEGORY_DEBUG)
	populate_interaction_instances()
