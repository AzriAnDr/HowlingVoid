/// Cleans up any invalid languages. Typically happens on language renames and codedels.
/datum/preferences/proc/sanitize_languages()
	if(!islist(languages))
		languages = list()

	var/species_type = read_preference(/datum/preference/choiced/species)
	var/datum/species/species = GLOB.species_prototypes[species_type]
	var/list/whitelist = species.language_prefs_whitelist

	var/languages_edited = FALSE
	var/list/to_remove = list()

	for (var/lang_path in languages)
		if (!lang_path)
			to_remove += lang_path
			continue

		var/datum/language/language_prototype = GLOB.language_datum_instances[lang_path]
		// Path no longer exists
		if (isnull(language_prototype))
			to_remove += lang_path
			continue

		// If it's a secret language, ensure it's allowed
		if (language_prototype.secret && (isnull(whitelist) || isnull(whitelist[lang_path])))
			to_remove += lang_path

	// Only modify list once
	if (length(to_remove))
		languages -= to_remove
		languages_edited = TRUE

	if(!length(languages))
		reset_languages_to_species_defaults()
		languages_edited = TRUE

	return languages_edited

/// Cleans any quirks that should be hidden, or just simply don't exist from quirk code.
/datum/preferences/proc/sanitize_quirks()
	var/quirks_edited = FALSE
	if(!islist(all_quirks))
		all_quirks = list()
		return TRUE

	var/list/normalized_quirks = SSquirks.normalize_quirk_list(all_quirks)
	if(normalized_quirks != all_quirks)
		all_quirks = normalized_quirks
		quirks_edited = TRUE

	var/list/sanitized_quirks = list()
	var/list/available_quirks = SSquirks.get_quirks()
	for(var/quirk_name in all_quirks)
		var/quirk_type = available_quirks[quirk_name]
		if(!quirk_name || !ispath(quirk_type, /datum/quirk))
			quirks_edited = TRUE
			continue

		var/datum/quirk/typed_quirk = quirk_type
		if(initial(typed_quirk.hidden_quirk))
			quirks_edited = TRUE
			continue

		if(quirk_name in sanitized_quirks)
			quirks_edited = TRUE
			continue

		sanitized_quirks += quirk_name

	if(quirks_edited)
		all_quirks = sanitized_quirks

	return quirks_edited
