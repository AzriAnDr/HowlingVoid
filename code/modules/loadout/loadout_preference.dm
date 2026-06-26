/datum/preference/loadout
	savefile_key = "loadout_list"
	savefile_identifier = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_LOADOUT
	can_randomize = FALSE
	// NOVA EDIT NOTE: This isn't accurate, this is now an assoc list of names to the stuff below.
	// Loadout preference is an assoc list [item_path] = [loadout item information list]
	//
	// it may look something like
	// - list(/obj/item/glasses = list())
	// or
	// - list(/obj/item/plush/lizard = list("name" = "Tests-The-Loadout", "color" = "#FF0000"))

// Loadouts are applied with job equip code.
/datum/preference/loadout/apply_to_human(mob/living/carbon/human/target, value)
	return

// Sanitize on load to ensure no invalid paths from older saves get in
/datum/preference/loadout/deserialize(input, datum/preferences/preferences)
	return sanitize_loadout_list(input, preferences.parent?.mob)

// Default value is null - the loadout list is a lazylist
/datum/preference/loadout/create_default_value(datum/preferences/preferences)
	return null

/datum/preference/loadout/is_valid(value)
	return isnull(value) || islist(value)

/**
 * Removes all invalid paths from loadout lists.
 * This is a general sanitization for preference loading.
 *
 * Returns a list, or null if empty
 */
/datum/preference/loadout/proc/sanitize_loadout_list(list/passed_list, mob/optional_loadout_owner) as /list
	var/list/sanitized_list
	for(var/path in passed_list)
		var/path_display = istext(path) ? path : "[path]"
		// Loading from json has each path in the list as a string that we need to convert back to typepath
		var/obj/item/real_path = istext(path) ? text2path(path) : path
		if(!ispath(real_path, /obj/item))
			if(optional_loadout_owner)
				to_chat(optional_loadout_owner, span_boldnotice("The following invalid item path was found \
					in your character loadout: [path_display]. \
					It has been removed, renamed, or is otherwise missing - \
					You may want to check your loadout settings."))
			continue

		else if(!istype(GLOB.all_loadout_datums[real_path], /datum/loadout_item))
			if(optional_loadout_owner)
				to_chat(optional_loadout_owner, span_boldnotice("The following invalid loadout item was found \
					in your character loadout: [path_display]. \
					It has been removed, renamed, or is otherwise missing - \
					You may want to check your loadout settings."))
			continue

		var/datum/loadout_item/loadout_item = GLOB.all_loadout_datums[real_path]
		if(loadout_item.is_disabled())
			continue // this just falls off silently

		// Set into sanitize list using converted path key
		var/list/data = passed_list[path]
		LAZYSET(sanitized_list, real_path, LAZYLISTDUPLICATE(data))

	return sanitized_list


// BEGIN NOVA CORE MIGRATION: code/modules/loadout/loadout_preference.dm
// Oh, I'm sorry, you were looking for GOOD code? Turn around and leave. - Rimi

/datum/preference/loadout_index
	savefile_key = "loadout_index"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/loadout_index/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return

/datum/preference/loadout_index/create_informed_default_value(datum/preferences/preferences)
	var/list/loadouts = preferences.read_preference(/datum/preference/loadout)
	if(length(loadouts))
		return loadouts[1]

/datum/preference/loadout_index/deserialize(input, datum/preferences/preferences)
	if (istext(input))
		return input

	return create_informed_default_value(preferences)

/datum/preference/loadout_index/is_valid(value)
	return istext(value)

/datum/preference/choiced/loadout_override_preference
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	priority = PREFERENCE_PRIORITY_DEFAULT
	savefile_key = "loadout_override_preference"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/loadout_override_preference/init_possible_values()
	return list(LOADOUT_OVERRIDE_JOB, LOADOUT_OVERRIDE_BACKPACK, LOADOUT_OVERRIDE_CASE)

/datum/preference/choiced/loadout_override_preference/create_default_value()
	return LOADOUT_OVERRIDE_BACKPACK

/datum/preference/choiced/loadout_override_preference/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE

/datum/preference/loadout
	savefile_key = "loadout_lists" // Change the savefile key to avoid data corruption if this goes COMPLETELY WRONG during a test merge.

// I'm going to flex my cursed modular knowledge now.
/datum/preference/loadout/deserialize(list/input, datum/preferences/preferences)
	for (var/name in input)
		input[name] = ..(input[name], preferences) // ULTIMATE MODULARITY BULLSHIT GO

	return input

/datum/preference/loadout/create_default_value(datum/preferences/preferences)
	return list("Default" = list())

/datum/preference/loadout/compile_ui_data(mob/user, value)
	var/list/data = ..()
	var/list/loadout_list = list()
	for(var/key in data)
		loadout_list += key
	data = list("loadout" = data[user?.client?.prefs.read_preference(/datum/preference/loadout_index)] || "Default") // Fail nicely and hopefully avoid runtiming, though this is client bullshit we're on about
	data["loadouts"] = loadout_list
	return data
// END NOVA CORE MIGRATION: code/modules/loadout/loadout_preference.dm
