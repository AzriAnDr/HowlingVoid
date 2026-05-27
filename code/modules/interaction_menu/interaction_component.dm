
/datum/component/interactable
	/// A hard reference to the parent
	var/mob/living/carbon/human/self = null
	/// A list of interactions that the user can engage in.
	var/list/datum/interaction/interactions
	var/interact_last = 0
	var/interact_next = 0
	/// Whether or not we are using subtler for lewd interactions.
	var/use_subtler = TRUE
	/// Max ERP custom subtler message length.
	var/erp_subtle_max_length = 2048
	/// Whether or not we have an erp interaction available to us right now
	var/has_erp_interaction = FALSE
	/// Active auto-repeat interactions keyed by interaction + target ref.
	var/list/auto_interaction_info = list()

/datum/component/interactable/Initialize(...)
	if(QDELETED(parent))
		qdel(src)
		return

	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	self = parent

	build_interactions_list()

/datum/component/interactable/proc/build_interactions_list()
	interactions = list()
	for(var/iterating_interaction_id in GLOB.interaction_instances)
		var/datum/interaction/interaction = GLOB.interaction_instances[iterating_interaction_id]
		if(interaction.lewd)
			if(is_erp_panel_blocked_mob(self))
				continue
			if(!self.client?.prefs?.read_preference(/datum/preference/toggle/erp))
				continue
			if(interaction.sexuality != "" && interaction.sexuality != self.client?.prefs?.read_preference(/datum/preference/choiced/erp_sexuality))
				continue
		interactions.Add(interaction)

/datum/component/interactable/proc/is_erp_panel_blocked_mob(mob/target)
	if(!target)
		return FALSE
	if(isanimal_or_basicmob(target) || issilicon(target))
		return TRUE
	var/mob/living/carbon/human/human_target = target
	if(!istype(human_target))
		return FALSE
	return human_target.dna?.species?.type == /datum/species/monkey

/datum/component/interactable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CLICK_CTRL_SHIFT, PROC_REF(open_interaction_menu))

/datum/component/interactable/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_CLICK_CTRL_SHIFT)

/datum/component/interactable/Destroy(force)
	STOP_PROCESSING(SSprocessing, src)
	self = null
	interactions = null
	auto_interaction_info = null
	return ..()

/datum/component/interactable/proc/open_interaction_menu(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!ishuman(user))
		return
	build_interactions_list()
	INVOKE_ASYNC(src, PROC_REF(ui_interact), user)
	return CLICK_ACTION_SUCCESS

/datum/component/interactable/proc/can_interact(datum/interaction/interaction, mob/living/carbon/human/target)
	var/mob/living/carbon/human/actual_target = interaction.usage == INTERACTION_SELF ? target : self
	if(interaction.lewd && (is_erp_panel_blocked_mob(target) || is_erp_panel_blocked_mob(actual_target)))
		return FALSE
	if(!interaction.allow_act(target, actual_target))
		return FALSE
	if(interaction.lewd && !actual_target.client?.prefs?.read_preference(/datum/preference/toggle/erp))
		return FALSE
	if(interaction.usage != INTERACTION_SELF && !interaction.distance_allowed && !target.Adjacent(actual_target))
		return FALSE
	if(interaction.category == INTERACTION_CAT_HIDE)
		return FALSE
	if(actual_target == target && interaction.usage == INTERACTION_OTHER)
		return FALSE
	return TRUE

/datum/component/interactable/proc/build_auto_interaction_key(datum/interaction/interaction, mob/living/carbon/human/target)
	if(!interaction || !target)
		return null
	return "[interaction.get_interaction_id()]_target_[REF(target)]"

/datum/component/interactable/proc/get_auto_interaction_stat_value(mob/living/carbon/human/target, stat_name)
	if(!target)
		return 0
	switch(stat_name)
		if("pleasure")
			return target.pleasure
		if("pain")
			return target.pain
		else
			return target.arousal

/datum/component/interactable/proc/auto_interaction_thresholds_met(mob/living/carbon/human/target, list/thresholds)
	if(!target || !islist(thresholds) || !length(thresholds))
		return FALSE
	for(var/stat_name in thresholds)
		var/threshold_value = clamp(text2num("[thresholds[stat_name]]"), 1, AROUSAL_LIMIT)
		if(get_auto_interaction_stat_value(target, stat_name) >= threshold_value)
			return TRUE
	return FALSE

/datum/component/interactable/process(seconds_per_tick)
	if(!length(auto_interaction_info))
		return PROCESS_KILL

	for(var/interaction_key in auto_interaction_info.Copy())
		var/list/entry = auto_interaction_info[interaction_key]
		if(!islist(entry))
			auto_interaction_info -= interaction_key
			continue

		var/interaction_id = entry["interaction_id"]
		var/datum/interaction/interaction = GLOB.interaction_instances[interaction_id]
		var/mob/living/carbon/human/target = locate(entry["target"])
		var/datum/component/interactable/target_component = target?.GetComponent(/datum/component/interactable)
		if(!interaction || QDELETED(target) || !target_component?.can_interact(interaction, self))
			auto_interaction_info -= interaction_key
			continue

		var/mob/living/carbon/human/threshold_target = interaction.usage == INTERACTION_SELF ? self : target
		var/list/thresholds = entry["thresholds"]
		var/duration_limit_seconds = clamp(text2num("[entry["duration_limit_seconds"]]"), 0, 60)
		var/started_at = text2num("[entry["started_at"]]")
		if(duration_limit_seconds > 0 && world.time >= started_at + (duration_limit_seconds SECONDS))
			auto_interaction_info -= interaction_key
			continue
		if(auto_interaction_thresholds_met(threshold_target, thresholds))
			auto_interaction_info -= interaction_key
			continue

		if(world.time < text2num("[entry["next_interaction"]]"))
			continue

		interaction.act(self, target, !!entry["use_subtler"])

		if(auto_interaction_thresholds_met(threshold_target, thresholds))
			auto_interaction_info -= interaction_key
			continue
		if(duration_limit_seconds > 0 && world.time >= started_at + (duration_limit_seconds SECONDS))
			auto_interaction_info -= interaction_key
			continue

		var/interval_seconds = clamp(text2num("[entry["speed"]]"), INTERACTION_SPEED_MIN / (1 SECONDS), INTERACTION_SPEED_MAX / (1 SECONDS))
		entry["next_interaction"] = world.time + (interval_seconds SECONDS)

	if(!length(auto_interaction_info))
		return PROCESS_KILL

	return

/// UI Control
/datum/component/interactable/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "InteractionPanel")
		ui.open()

/datum/component/interactable/ui_status(mob/user, datum/ui_state/state)
	if(!ishuman(user))
		return UI_CLOSE

	return UI_INTERACTIVE // This UI is always interactive as we handle distance flags via can_interact

/datum/component/interactable/ui_static_data(mob/user)
	var/list/data = list()
	data["arousalLimit"] = AROUSAL_LIMIT
	return data

/datum/component/interactable/ui_data(mob/user)
	var/list/data = list()
	var/list/descriptions = list()
	var/list/interaction_names = list()
	var/list/translation_keys = list()
	var/list/description_translation_keys = list()
	var/list/category_translation_keys = list()
	var/list/categories = list()
	var/list/erp_categories = list()
	var/list/colors = list()
	var/list/interaction_usages = list()
	var/erp_panel_blocked = is_erp_panel_blocked_mob(user) || is_erp_panel_blocked_mob(self)

	has_erp_interaction = FALSE

	for (var/datum/interaction/interaction in interactions)
		if (!can_interact(interaction, user))
			continue

		if (interaction.lewd)
			has_erp_interaction = TRUE

		var/category = interaction.category
		var/interaction_id = interaction.get_interaction_id()
		var/list/category_map = interaction.lewd ? erp_categories : categories
		var/list/category_list = category_map[category]

		if (isnull(category_list))
			category_list = list()
			category_map[category] = category_list
			var/category_translation_key = interaction.get_ui_category_translation_key()
			if(length(category_translation_key))
				category_translation_keys[category] = category_translation_key

		category_list += interaction_id

		interaction_names[interaction_id] = interaction.name
		descriptions[interaction_id] = interaction.description
		var/translation_key = interaction.get_ui_translation_key()
		var/description_translation_key = interaction.get_ui_description_translation_key()
		if(length(translation_key))
			translation_keys[interaction_id] = translation_key
		if(length(description_translation_key))
			description_translation_keys[interaction_id] = description_translation_key
		colors[interaction_id] = interaction.color
		interaction_usages[interaction_id] = interaction.usage

	// Sort category contents once
	for (var/category in categories)
		categories[category] = sort_list(categories[category])
	for (var/category in erp_categories)
		erp_categories[category] = sort_list(erp_categories[category])

	// Build and sort category names
	data["categories"] = sort_list(assoc_to_keys(categories))
	data["interactions"] = categories
	data["erp_categories"] = sort_list(assoc_to_keys(erp_categories))
	data["erp_interactions"] = erp_categories
	data["interaction_names"] = interaction_names
	data["descriptions"] = descriptions
	data["translation_keys"] = translation_keys
	data["description_translation_keys"] = description_translation_keys
	data["category_translation_keys"] = category_translation_keys
	data["colors"] = colors
	data["interaction_usages"] = interaction_usages
	data["auto_interaction_speed_values"] = list(
		INTERACTION_SPEED_MIN / (1 SECONDS),
		INTERACTION_SPEED_MAX / (1 SECONDS),
	)

	data["ref_user"] = REF(user)
	data["ref_self"] = REF(self)
	data["self"] = self.name
	data["user_name"] = user?.name
	data["target_name"] = self.name
	data["interface_language"] = user?.client?.prefs?.read_preference(/datum/preference/choiced/interface_language)
	data["block_interact"] = interact_next >= world.time
	data["use_subtler"] = use_subtler
	data["erp_subtle_max_length"] = erp_subtle_max_length
	data["erp_interaction"] = !erp_panel_blocked && self.client?.prefs?.read_preference(/datum/preference/toggle/erp)
	data["has_erp_interaction"] = has_erp_interaction
	var/datum/component/interactable/user_component = user?.GetComponent(/datum/component/interactable)
	data["auto_interaction_info"] = user_component?.auto_interaction_info || list()
	data["erp_preferences"] = erp_panel_blocked ? list() : build_erp_preferences_data(user)
	data["content_preferences"] = list()

	var/mob/living/carbon/human/human_user = user

	data["isTargetSelf"] = (user == self)

	// user (the one who opened the ui)
	var/user_pleasure = 0
	var/user_arousal = 0
	var/user_pain = 0

	if(user)
		user_pleasure = human_user.pleasure
		user_arousal = human_user.arousal
		user_pain = human_user.pain

		data["pleasure"] = user_pleasure
		data["arousal"] = user_arousal
		data["pain"] = user_pain
		data["user_body_exposure"] = build_body_exposure_data(human_user)


	// self - the one who the interaction component belongs to, aka who it's opened on (confusing var name yep)
	if(user != self)
		data["theirPleasure"] = self.pleasure
		data["theirArousal"] = self.arousal
		data["theirPain"] = self.pain
		data["target_body_exposure"] = build_body_exposure_data(self)

	var/list/parts = list()

	if(!erp_panel_blocked && ishuman(user) && can_lewd_strip(user, self))
		if(self.client?.prefs?.read_preference(/datum/preference/toggle/erp/sex_toy))
			if(self.has_vagina())
				parts += list(generate_strip_entry(ORGAN_SLOT_VAGINA, self, user, self.vagina))
			if(self.has_penis())
				parts += list(generate_strip_entry(ORGAN_SLOT_PENIS, self, user, self.penis))
			if(self.has_anus())
				parts += list(generate_strip_entry(ORGAN_SLOT_ANUS, self, user, self.anus))
			parts += list(generate_strip_entry(ORGAN_SLOT_NIPPLES, self, user, self.nipples))

	data["lewd_slots"] = parts

	return data

/**
 *  Takes the organ slot name, along with a target and source, along with the item on the target that the source can potentially interact with.
 *  If the source can't interact with said slot, or there is no item in the first place, it'll set the icon to null to indicate that TGUI should put a placeholder sprite.
 *
 * Arguments:
 * * name - The name of slot to check and return inside the generated list.
 * * target - The mob that's being interacted with.
 * * source - The mob that's interacting.
 * * item - The item that's currently inside said slot. Can be null.
 */
/datum/component/interactable/proc/generate_strip_entry(name, mob/living/carbon/human/target, mob/living/carbon/human/source, obj/item/clothing/sextoy/item)
	return list(
		"name" = name,
		"img" = (item && can_lewd_strip(source, target, name)) ? icon2base64(icon(item.icon, item.icon_state, SOUTH, 1)) : null
		)

/datum/component/interactable/proc/build_body_exposure_data(mob/living/carbon/human/target)
	var/list/entries = list()
	var/list/part_keys = list(
		"chest",
		"groin",
		"hands",
		"feet",
		"mouth",
		"ears",
		"eyes",
		"cap",
		"snout",
		"horns",
		"frills",
		"fluff",
		"moth_antennae",
		"neck_accessory",
		"skrell_hair",
		"synth_antenna",
		"breasts",
		"penis",
		"vagina",
		"anus",
		"butt",
		"belly",
		"spines",
		"tail",
		"wings",
		"taur",
		"xeno_head",
		"xenodorsal",
	)

	for(var/part_key in part_keys)
		var/list/entry = build_exposure_entry(part_key, target.get_lewd_part_state(part_key))
		if(entry)
			entries += list(entry)

	return entries

/datum/component/interactable/proc/build_exposure_entry(part, state)
	if(isnull(state))
		return null

	return list(
		"part" = part,
		"state" = state,
	)

/datum/component/interactable/proc/build_erp_preferences_data(mob/living/carbon/human/user)
	var/datum/preference/choiced/erp_status/pref_erp_status = GLOB.preference_entries[/datum/preference/choiced/erp_status]
	var/datum/preference/choiced/erp_status_mechanics/pref_erp_status_mechanics = GLOB.preference_entries[/datum/preference/choiced/erp_status_mechanics]
	var/datum/preference/choiced/erp_status_nc/pref_erp_status_nc = GLOB.preference_entries[/datum/preference/choiced/erp_status_nc]
	var/datum/preference/choiced/erp_status_hypno/pref_erp_status_hypno = GLOB.preference_entries[/datum/preference/choiced/erp_status_hypno]
	var/datum/preference/choiced/erp_status_v/pref_erp_status_v = GLOB.preference_entries[/datum/preference/choiced/erp_status_v]
	var/list/specs = list(
		list("id" = "erp_pref", "name" = "ERP Interaction", "description" = "Allows ERP interactions and lets other players know you are open to them.", "type" = "toggle", "category" = "ERP", "path" = /datum/preference/toggle/erp),
		list("id" = "erp_hide_interactions_from_ghosts_pref", "name" = "Hide Interactions From Ghosts", "description" = "Prevents ghosts from seeing interaction panel actions you perform.", "type" = "toggle", "category" = "ERP", "path" = /datum/preference/toggle/erp/hide_interactions_from_ghosts),
		list("id" = "erp_sounds_pref", "name" = "ERP Sounds", "description" = "Hear sounds from ERP interactions and stimuli.", "type" = "toggle", "category" = "ERP", "path" = /datum/preference/toggle/erp/sounds),
		list("id" = "autoemote_pref", "name" = "Auto Emote", "description" = "Automatically emote from the arousal system.", "type" = "toggle", "category" = "ERP", "path" = /datum/preference/toggle/erp/autoemote),
		list("id" = "autocum_pref", "name" = "Autocum", "description" = "Automatically climax when the arousal system decides you should.", "type" = "toggle", "category" = "ERP", "path" = /datum/preference/toggle/erp/autocum),
		list("id" = "aphro_pref", "name" = "Aphrodisiacs", "description" = "Allow the effects of aphrodisiacs.", "type" = "toggle", "category" = "ERP", "path" = /datum/preference/toggle/erp/aphro),
		list("id" = "erp_sexuality_pref", "name" = "ERP Content Boundaries", "description" = "Controls what ERP content you see. None shows all content.", "type" = "choice", "category" = "ERP", "path" = /datum/preference/choiced/erp_sexuality, "choices" = list("Gay", "Straight", "None")),
		list("id" = "sextoy_sounds_pref", "name" = "Sex Toy Sounds", "description" = "Hear sounds from sex toys.", "type" = "toggle", "category" = "ERP", "path" = /datum/preference/toggle/erp/sex_toy_sounds),
		list("id" = "master_erp_pref", "name" = "Show ERP Preferences", "description" = "Shows or hides ERP-related preferences.", "type" = "toggle", "category" = "ERP", "path" = /datum/preference/toggle/master_erp_preferences),
		list("id" = "gender_change_pref", "name" = "Forced Gender Change", "description" = "Allow forced gender change effects.", "type" = "toggle", "category" = "ERP", "path" = /datum/preference/toggle/erp/gender_change),
		list("id" = "new_genitalia_growth_pref", "name" = "ERP New Genitalia Growth", "description" = "Allow growth of new genitalia.", "type" = "toggle", "category" = "ERP", "path" = /datum/preference/toggle/erp/new_genitalia_growth),
		list("id" = "sextoy_pref", "name" = "Sex Toy Interaction", "description" = "Allows interaction with sex toys.", "type" = "toggle", "category" = "ERP", "path" = /datum/preference/toggle/erp/sex_toy),
		list("id" = "penis_enlargement_pref", "name" = "Penis Enlargement", "description" = "Allow penis enlargement effects.", "type" = "toggle", "category" = "ERP", "path" = /datum/preference/toggle/erp/penis_enlargement),
		list("id" = "genitalia_removal_pref", "name" = "ERP Genitalia Removal", "description" = "Allow removal of existing genitalia.", "type" = "toggle", "category" = "ERP", "path" = /datum/preference/toggle/erp/genitalia_removal),
		list("id" = "penis_shrinkage_pref", "name" = "Penis Shrinkage", "description" = "Allow penis shrinkage effects.", "type" = "toggle", "category" = "ERP", "path" = /datum/preference/toggle/erp/penis_shrinkage),
		list("id" = "erp_status_pref", "name" = "ERP Status", "description" = "Your general ERP role/status preference.", "type" = "choice", "category" = "ERP", "path" = /datum/preference/choiced/erp_status, "choices" = pref_erp_status.init_possible_values()),
		list("id" = "erp_status_mechanical_pref", "name" = "ERP Mechanical Status", "description" = "Your preference for ERP with mechanical consequences.", "type" = "choice", "category" = "ERP", "path" = /datum/preference/choiced/erp_status_mechanics, "choices" = pref_erp_status_mechanics.init_possible_values()),
		list("id" = "erp_status_noncon_pref", "name" = "ERP Non-Con Status", "description" = "Your preference for non-consensual ERP themes.", "type" = "choice", "category" = "ERP", "path" = /datum/preference/choiced/erp_status_nc, "choices" = pref_erp_status_nc.init_possible_values()),
		list("id" = "erp_status_hypnosis_pref", "name" = "ERP Hypnosis Status", "description" = "Your preference for hypnosis-related ERP content.", "type" = "choice", "category" = "ERP", "path" = /datum/preference/choiced/erp_status_hypno, "choices" = pref_erp_status_hypno.init_possible_values()),
		list("id" = "erp_status_vore_pref", "name" = "ERP Vore Status", "description" = "Your preference for vore-related ERP content.", "type" = "choice", "category" = "ERP", "path" = /datum/preference/choiced/erp_status_v, "choices" = pref_erp_status_v.init_possible_values()),
	)
	return build_preferences_data_from_specs(user, specs)

/datum/component/interactable/proc/build_preferences_data_from_specs(mob/living/carbon/human/user, list/specs)
	var/list/entries = list()
	var/datum/preferences/preferences = user?.client?.prefs
	if(!preferences)
		return entries

	for(var/list/spec as anything in specs)
		var/pref_path = spec["path"]
		if(!pref_path)
			continue

		entries += list(list(
			"id" = spec["id"],
			"name" = spec["name"],
			"description" = spec["description"],
			"type" = spec["type"],
			"category" = spec["category"],
			"value" = preferences.read_preference(pref_path),
			"choices" = spec["choices"],
		))

	return entries

/datum/component/interactable/proc/get_interaction_preference_path(pref_id)
	switch(pref_id)
		if("master_erp_pref")
			return /datum/preference/toggle/master_erp_preferences
		if("erp_pref")
			return /datum/preference/toggle/erp
		if("erp_hide_interactions_from_ghosts_pref")
			return /datum/preference/toggle/erp/hide_interactions_from_ghosts
		if("erp_sounds_pref")
			return /datum/preference/toggle/erp/sounds
		if("subtler_sound")
			return /datum/preference/toggle/subtler_sound
		if("sextoy_pref")
			return /datum/preference/toggle/erp/sex_toy
		if("sextoy_sounds_pref")
			return /datum/preference/toggle/erp/sex_toy_sounds
		if("autocum_pref")
			return /datum/preference/toggle/erp/autocum
		if("autoemote_pref")
			return /datum/preference/toggle/erp/autoemote
		if("bimbofication_pref")
			return /datum/preference/toggle/erp/bimbofication
		if("aphro_pref")
			return /datum/preference/toggle/erp/aphro
		if("breast_enlargement_pref")
			return /datum/preference/toggle/erp/breast_enlargement
		if("breast_shrinkage_pref")
			return /datum/preference/toggle/erp/breast_shrinkage
		if("penis_enlargement_pref")
			return /datum/preference/toggle/erp/penis_enlargement
		if("penis_shrinkage_pref")
			return /datum/preference/toggle/erp/penis_shrinkage
		if("erp_status_pref")
			return /datum/preference/choiced/erp_status
		if("erp_status_mechanical_pref")
			return /datum/preference/choiced/erp_status_mechanics
		if("erp_status_noncon_pref")
			return /datum/preference/choiced/erp_status_nc
		if("erp_status_hypnosis_pref")
			return /datum/preference/choiced/erp_status_hypno
		if("erp_status_vore_pref")
			return /datum/preference/choiced/erp_status_v
		if("gender_change_pref")
			return /datum/preference/toggle/erp/gender_change
		if("genitalia_removal_pref")
			return /datum/preference/toggle/erp/genitalia_removal
		if("new_genitalia_growth_pref")
			return /datum/preference/toggle/erp/new_genitalia_growth
		if("erp_sexuality_pref")
			return /datum/preference/choiced/erp_sexuality
	return null

/datum/component/interactable/proc/use_russian_interaction_text(mob/reader)
	return uses_panel_language(reader, "interaction")

/datum/component/interactable/proc/russian_lewd_slot(slot_index, form = "accusative")
	switch(slot_index)
		if(ORGAN_SLOT_VAGINA)
			switch(form)
				if("genitive")
					return "киски"
				if("placement")
					return "киску"
				if("possessive")
					return "твоей киски"
				if("possessive_placement")
					return "твою киску"
				else
					return "киску"
		if(ORGAN_SLOT_ANUS)
			switch(form)
				if("genitive")
					return "ануса"
				if("placement")
					return "анус"
				if("possessive")
					return "твоего ануса"
				if("possessive_placement")
					return "твой анус"
				else
					return "анус"
		if(ORGAN_SLOT_PENIS)
			switch(form)
				if("genitive")
					return "члена"
				if("placement")
					return "член"
				if("possessive")
					return "твоего члена"
				if("possessive_placement")
					return "твой член"
				else
					return "член"
		if(ORGAN_SLOT_NIPPLES)
			switch(form)
				if("genitive")
					return "сосков"
				if("placement")
					return "соскам"
				if("possessive")
					return "твоих сосков"
				if("possessive_placement")
					return "твоим соскам"
				else
					return "соски"
	return "[slot_index]"

/datum/component/interactable/proc/russian_lewd_slot_preposition(slot_index, removing = FALSE)
	if(removing)
		return slot_index in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS) ? "из" : "с"
	if(slot_index == ORGAN_SLOT_NIPPLES)
		return "к"
	if(slot_index == ORGAN_SLOT_PENIS)
		return "на"
	return "в"

/datum/component/interactable/proc/show_localized_interaction_visible_message(
	mob/living/carbon/human/source,
	english_message,
	russian_message,
	english_self_message,
	russian_self_message,
	english_blind_message,
	russian_blind_message,
	vision_distance = SAMETILE_MESSAGE_RANGE,
	list/ignored_mobs
)
	var/list/base_ignored_mobs = islist(ignored_mobs) ? ignored_mobs.Copy() : list()
	base_ignored_mobs += source

	var/list/hearers = mob_only_listeners(get_hearers_in_view(vision_distance, source))
	if(hides_interaction_messages_from_ghosts(source))
		for(var/mob/hearing_mob as anything in hearers)
			if(isobserver(hearing_mob))
				base_ignored_mobs += hearing_mob
	hearers -= base_ignored_mobs

	var/list/language_groups = list()
	for(var/mob/hearing_mob as anything in hearers)
		if(!hearing_mob?.client)
			continue
		var/language = get_panel_language_value(hearing_mob, "interaction")
		if(!language_groups[language])
			language_groups[language] = list()
		language_groups[language] += hearing_mob

	for(var/language in language_groups)
		var/list/language_group = language_groups[language]
		var/list/group_ignored_mobs = base_ignored_mobs.Copy()
		for(var/mob/hearing_mob as anything in hearers)
			if(!(hearing_mob in language_group))
				group_ignored_mobs += hearing_mob
		source.visible_message(
			language == "russian" ? russian_message : english_message,
			blind_message = language == "russian" ? russian_blind_message : english_blind_message,
			vision_distance = vision_distance,
			ignored_mobs = group_ignored_mobs,
		)

	if(use_russian_interaction_text(source))
		source.show_message(russian_self_message, MSG_VISUAL, russian_blind_message, MSG_AUDIBLE)
	else
		source.show_message(english_self_message, MSG_VISUAL, english_blind_message, MSG_AUDIBLE)

/datum/component/interactable/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!ishuman(ui.user))
		return

	if(action == "toggle_subtler")
		use_subtler = !use_subtler
		return TRUE

	if(action == "set_preference")
		var/mob/living/carbon/human/user = ui.user
		if(is_erp_panel_blocked_mob(user) || is_erp_panel_blocked_mob(self))
			return FALSE
		var/datum/preferences/preferences = user?.client?.prefs
		var/pref_id = params["preference_id"]
		var/pref_path = get_interaction_preference_path(pref_id)
		if(!preferences || !pref_path)
			return FALSE

		var/datum/preference/preference = GLOB.preference_entries[pref_path]
		if(!preference)
			return FALSE

		var/value
		if(ispath(pref_path, /datum/preference/choiced))
			value = params["value"]
		else
			value = text2num("[params["value"]]") ? TRUE : FALSE

		return preferences.update_preference(preference, value)

	if(action == "send_subtle_message")
		var/mob/living/carbon/human/user = ui.user
		if(is_erp_panel_blocked_mob(user) || is_erp_panel_blocked_mob(self))
			return FALSE
		var/message = trim(html_encode(params["message"] || ""), erp_subtle_max_length)
		if(!length(message))
			return FALSE

		user.emote(
			use_subtler ? "subtler" : "subtle",
			type_override = /datum/emote/living/subtler::emote_type | EMOTE_LEWD,
			message = message,
			intentional = TRUE,
		)
		return TRUE

	if(action == "auto_interaction")
		var/mob/living/carbon/human/user = ui.user
		if(is_erp_panel_blocked_mob(user) || is_erp_panel_blocked_mob(self))
			return FALSE
		var/datum/component/interactable/user_component = user?.GetComponent(/datum/component/interactable)
		if(!user_component)
			return FALSE

		if(params["stop_all"])
			user_component.auto_interaction_info.Cut()
			STOP_PROCESSING(SSprocessing, user_component)
			return TRUE

		var/datum/interaction/interaction = GLOB.interaction_instances[params["interaction"]]
		if(!interaction)
			return FALSE

		var/mob/living/carbon/human/panel_target = locate(params["selfref"])
		if(!panel_target)
			return FALSE

		var/mob/living/carbon/human/actual_target = interaction.usage == INTERACTION_SELF ? user : panel_target
		var/interaction_key = user_component.build_auto_interaction_key(interaction, actual_target)
		if(!interaction_key)
			return FALSE

		if(params["action"] == "stop")
			user_component.auto_interaction_info -= interaction_key
			if(!length(user_component.auto_interaction_info))
				STOP_PROCESSING(SSprocessing, user_component)
			return TRUE

		var/datum/component/interactable/target_component = actual_target.GetComponent(/datum/component/interactable)
		if(!target_component?.can_interact(interaction, user))
			return FALSE

		var/interval_seconds = clamp(text2num("[params["speed"]]"), INTERACTION_SPEED_MIN / (1 SECONDS), INTERACTION_SPEED_MAX / (1 SECONDS))
		var/list/thresholds = list()
		if(text2num("[params["threshold_pleasure_enabled"]]"))
			thresholds["pleasure"] = clamp(text2num("[params["threshold_pleasure_value"]]"), 1, AROUSAL_LIMIT)
		if(text2num("[params["threshold_arousal_enabled"]]"))
			thresholds["arousal"] = clamp(text2num("[params["threshold_arousal_value"]]"), 1, AROUSAL_LIMIT)
		if(text2num("[params["threshold_pain_enabled"]]"))
			thresholds["pain"] = clamp(text2num("[params["threshold_pain_value"]]"), 1, AROUSAL_LIMIT)
		var/duration_limit_seconds = 0
		if(text2num("[params["duration_enabled"]]"))
			duration_limit_seconds = clamp(text2num("[params["duration_value"]]"), 1, 60)

		user_component.auto_interaction_info[interaction_key] = list(
			"interaction_id" = interaction.get_interaction_id(),
			"speed" = interval_seconds,
			"target" = REF(actual_target),
			"target_name" = actual_target.name,
			"started_at" = world.time,
			"next_interaction" = world.time + (interval_seconds SECONDS),
			"thresholds" = thresholds,
			"duration_limit_seconds" = duration_limit_seconds,
			"use_subtler" = !!use_subtler,
		)
		START_PROCESSING(SSprocessing, user_component)
		return TRUE

	if(params["interaction"])
		var/interaction_id = params["interaction"]
		var/datum/interaction/interaction = GLOB.interaction_instances[interaction_id]
		if(interaction)
			var/mob/living/carbon/human/user = locate(params["userref"])
			var/mob/living/carbon/human/interaction_target = interaction.usage == INTERACTION_SELF ? user : locate(params["selfref"])
			if(interaction.lewd && (is_erp_panel_blocked_mob(user) || is_erp_panel_blocked_mob(interaction_target)))
				return FALSE
			if(!can_interact(interaction, user))
				return FALSE
			interaction.act(user, interaction_target, use_subtler)
			var/datum/component/interactable/interaction_component = user.GetComponent(/datum/component/interactable)
			interaction_component.interact_last = world.time
			interact_next = interaction_component.interact_last + INTERACTION_COOLDOWN
			interaction_component.interact_next = interact_next
			return TRUE

	if(params["item_slot"])
		// This code should be easy enough to follow... I hope.
		var/item_index = params["item_slot"]
		var/mob/living/carbon/human/source = locate(params["userref"])
		var/mob/living/carbon/human/target = locate(params["selfref"])
		if(is_erp_panel_blocked_mob(source) || is_erp_panel_blocked_mob(target))
			return FALSE
		var/obj/item/clothing/sextoy/new_item = source.get_active_held_item()
		var/obj/item/clothing/sextoy/existing_item = target.vars[item_index]
		var/source_uses_russian = use_russian_interaction_text(source)

		if(!existing_item && !new_item)
			source.show_message(span_warning(source_uses_russian ? "Нет предмета, который можно вставить или снять!" : "No item to insert or remove!"))
			return

		if(!existing_item && !istype(new_item))
			source.show_message(span_warning(source_uses_russian ? "Предмет в вашей руке не является игрушкой!" : "The item you're holding is not a toy!"))
			return

		if(can_lewd_strip(source, target, item_index) && is_toy_compatible(new_item, item_index))
			var/internal = (item_index in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS))
			var/insert_or_attach = internal ? "insert" : "attach"
			var/into_or_onto = internal ? "into" : "onto"
			var/remove_preposition_ru = russian_lewd_slot_preposition(item_index, TRUE)
			var/place_preposition_ru = russian_lewd_slot_preposition(item_index)
			var/slot_placement_ru = russian_lewd_slot(item_index, "placement")
			var/slot_genitive_ru = russian_lewd_slot(item_index, "genitive")
			var/slot_possessive_ru = russian_lewd_slot(item_index, "possessive")
			var/slot_possessive_placement_ru = russian_lewd_slot(item_index, "possessive_placement")
			var/insert_or_attach_ru = internal ? "вставить" : "закрепить"
			var/inserts_or_attaches_ru = internal ? "вставляет" : "закрепляет"

			// Do not show visible_messages to people without erp prefs
			var/list/ignoring_mobs = list()
			for(var/mob/not_interested in get_hearers_in_view(SAMETILE_MESSAGE_RANGE, source))
				if(!not_interested.client?.prefs?.read_preference(/datum/preference/toggle/erp))
					ignoring_mobs += not_interested
			if(existing_item)
				show_localized_interaction_visible_message(
					source,
					span_purple("[source.name] starts trying to remove something from [target.name]'s [item_index]."),
					span_purple("[source.name] пытается снять что-то [remove_preposition_ru] [slot_genitive_ru] [target.name]."),
					span_purple("You start to remove [existing_item.name] from [target.name]'s [item_index]."),
					span_purple("Вы начинаете снимать [existing_item.name] [remove_preposition_ru] [slot_genitive_ru] [target.name]."),
					span_purple("You hear someone trying to remove something from someone nearby."),
					span_purple("Вы слышите, как кто-то рядом пытается снять с кого-то игрушку."),
					ignored_mobs = ignoring_mobs + list(target),
				)
			else if (new_item)
				show_localized_interaction_visible_message(
					source,
					span_purple("[source.name] starts trying to [insert_or_attach] the [new_item.name] [into_or_onto] [target.name]'s [item_index]."),
					span_purple("[source.name] пытается [insert_or_attach_ru] [new_item.name] [place_preposition_ru] [slot_placement_ru] [target.name]."),
					span_purple("You start to [insert_or_attach] the [new_item.name] [into_or_onto] [target.name]'s [item_index]."),
					span_purple("Вы начинаете [insert_or_attach_ru] [new_item.name] [place_preposition_ru] [slot_placement_ru] [target.name]."),
					span_purple("You hear someone trying to [insert_or_attach] something [into_or_onto] someone nearby."),
					span_purple("Вы слышите, как кто-то рядом пытается [insert_or_attach_ru] игрушку."),
					ignored_mobs = ignoring_mobs + list(target),
				)
			if (source != target)
				if(use_russian_interaction_text(target))
					target.show_message(span_warning(existing_item ? "[source.name] пытается снять [existing_item.name] [remove_preposition_ru] [slot_possessive_ru]!" : "[source.name] пытается [insert_or_attach_ru] [new_item.name] [place_preposition_ru] [slot_possessive_placement_ru]!"))
				else
					target.show_message(span_warning("[source.name] is trying to [existing_item ? "remove the [existing_item.name] [internal ? "in" : "on"]" : "insert or attach the [new_item.name] [into_or_onto]"] your [item_index]!"))
			if(do_after(
				source,
				5 SECONDS,
				target,
				interaction_key = "interaction_[item_index]"
				) && can_lewd_strip(source, target, item_index))

				if(existing_item)
					show_localized_interaction_visible_message(
						source,
						span_purple("[source.name] removes [existing_item.name] from [target.name]'s [item_index]."),
						span_purple("[source.name] снимает [existing_item.name] [remove_preposition_ru] [slot_genitive_ru] [target.name]."),
						span_purple("You remove [existing_item.name] from [target.name]'s [item_index]."),
						span_purple("Вы снимаете [existing_item.name] [remove_preposition_ru] [slot_genitive_ru] [target.name]."),
						span_purple("You hear someone remove something from someone nearby."),
						span_purple("Вы слышите, как кто-то рядом снимает с кого-то игрушку."),
						ignored_mobs = ignoring_mobs,
					)
					target.dropItemToGround(existing_item, force = TRUE) // Force is true, cause nodrop shouldn't affect lewd items.
					target.vars[item_index] = null
				else if (new_item)
					show_localized_interaction_visible_message(
						source,
						span_purple("[source.name] [internal ? "inserts" : "attaches"] the [new_item.name] [into_or_onto] [target.name]'s [item_index]."),
						span_purple("[source.name] [inserts_or_attaches_ru] [new_item.name] [place_preposition_ru] [slot_placement_ru] [target.name]."),
						span_purple("You [insert_or_attach] the [new_item.name] [into_or_onto] [target.name]'s [item_index]."),
						span_purple("Вы [inserts_or_attaches_ru] [new_item.name] [place_preposition_ru] [slot_placement_ru] [target.name]."),
						span_purple("You hear someone [insert_or_attach] something [into_or_onto] someone nearby."),
						span_purple("Вы слышите, как кто-то рядом [inserts_or_attaches_ru] игрушку."),
						ignored_mobs = ignoring_mobs,
					)
					target.vars[item_index] = new_item
					new_item.forceMove(target)
					new_item.lewd_equipped(target, item_index)
				target.update_inv_lewd()

		else
			source.show_message(span_warning(source_uses_russian ? "Не удалось изменить игрушки [target.name]!" : "Failed to adjust [target.name]'s toys!"))

		return TRUE

	message_admins("Unhandled interaction '[params["interaction"]]'. Inform coders.")

/// Checks if the target has ERP toys enabled, and can be logially reached by the user.
/datum/component/interactable/proc/can_lewd_strip(mob/living/carbon/human/source, mob/living/carbon/human/target, slot_index)
	if(!target.client?.prefs?.read_preference(/datum/preference/toggle/erp/sex_toy))
		return FALSE
	if(!(source.loc == target.loc || source.Adjacent(target)))
		return FALSE
	if(!source.has_arms())
		return FALSE
	if(!slot_index) // This condition is for the UI to decide if the button is shown at all. Slot index should never be null otherwise.
		return TRUE

	switch(slot_index)
		if(ORGAN_SLOT_NIPPLES)
			return target.has_breasts(REQUIRE_GENITAL_EXPOSED)

		if(ORGAN_SLOT_PENIS)
			return target.has_penis(REQUIRE_GENITAL_EXPOSED)
		if(ORGAN_SLOT_VAGINA)
			return target.has_vagina(REQUIRE_GENITAL_EXPOSED)
		if(ORGAN_SLOT_ANUS)
			return target.has_anus(REQUIRE_GENITAL_EXPOSED)

/// Decides if a player should be able to insert or remove an item from a provided lewd slot_index.
/datum/component/interactable/proc/is_toy_compatible(obj/item/clothing/sextoy/item, slot_index)
	if(!item) // Used for UI code, should never be actually null during actual logic code.
		return TRUE

	switch(slot_index)
		if(ORGAN_SLOT_VAGINA)
			return item.lewd_slot_flags & LEWD_SLOT_VAGINA
		if(ORGAN_SLOT_PENIS)
			return item.lewd_slot_flags & LEWD_SLOT_PENIS
		if(ORGAN_SLOT_ANUS)
			return item.lewd_slot_flags & LEWD_SLOT_ANUS
		if(ORGAN_SLOT_NIPPLES)
			return item.lewd_slot_flags & LEWD_SLOT_NIPPLES
		else
			return FALSE
