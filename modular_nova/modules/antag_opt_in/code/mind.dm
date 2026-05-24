/datum/mind
	/// The optin level set by preferences.
	var/ideal_opt_in_level = OPT_IN_DEFAULT_LEVEL
	/// Set to TRUE on a successful transfer_mind() call. If TRUE, transfer_mind() will not refresh opt in.
	var/opt_in_initialized

/mob/living/Login()
	. = ..()
	if(CONFIG_GET(flag/disable_antag_opt_in_preferences)) //lets not annoy our fellow players with useless info if we don't use this system at all
		return
	if (isnull(mind))
		return
	if (isnull(client?.prefs))
		return
	if (!mind.opt_in_initialized)
		mind.update_opt_in(client.prefs)
		mind.opt_in_initialized = TRUE

/// Refreshes our ideal antag target opt-in level by accessing preferences.
/datum/mind/proc/update_opt_in(datum/preferences/preference_instance = GLOB.preferences_datums[ckey(key)])
	if (isnull(preference_instance))
		return

	ideal_opt_in_level = preference_instance.read_preference(/datum/preference/choiced/antag_opt_in_status)

/// Gets the effective opt-in level used for antagonist target preference checks.
/datum/mind/proc/get_target_opt_in_level()
	var/target_opt_in_level = ideal_opt_in_level
	var/datum/preferences/preference_instance = GLOB.preferences_datums[ckey(key)]
	if(!isnull(preference_instance))
		target_opt_in_level = preference_instance.read_preference(/datum/preference/choiced/antag_opt_in_status)
	if(target_opt_in_level == OPT_IN_NOT_TARGET)
		return get_job_opt_in_level()
	return target_opt_in_level

/// Gets the opt-in level displayed in examine panels.
/datum/mind/proc/get_effective_opt_in_level()
	return get_target_opt_in_level()

/// Security jobs are always valid for kill targets, but not automatic round removal.
/datum/mind/proc/get_job_opt_in_level()
	if(assigned_role?.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
		return SECURITY_OPT_IN_LEVEL
	return OPT_IN_NOT_TARGET

/// Antagonist preferences no longer force this preference.
/datum/mind/proc/get_antag_opt_in_level()
	return OPT_IN_NOT_TARGET
