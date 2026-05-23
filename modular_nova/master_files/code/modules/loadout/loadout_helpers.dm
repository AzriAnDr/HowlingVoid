///Fetches the current loadout list from prefs and formats it via loadout_list_to_datums().
/client/proc/get_loadout_datums()
	RETURN_TYPE(/list)

	if(isnull(prefs))
		return list()
	return loadout_list_to_datums(get_active_loadout_list(prefs))

///Fetches the active loadout preset from prefs, with a fallback for missing or stale preset indexes.
/proc/get_active_loadout_list(datum/preferences/preference_source) as /list
	RETURN_TYPE(/list)

	if(isnull(preference_source))
		return list()

	var/list/all_loadouts = preference_source.read_preference(/datum/preference/loadout)
	if(!islist(all_loadouts))
		return list()

	var/current_loadout_key = preference_source.read_preference(/datum/preference/loadout_index)
	if(current_loadout_key && islist(all_loadouts[current_loadout_key]))
		return all_loadouts[current_loadout_key]

	for(var/preset_name in all_loadouts)
		var/list/preset_entries = all_loadouts[preset_name]
		if(islist(preset_entries))
			return preset_entries

	return list()
