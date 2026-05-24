/// Kept for compatibility with downstream calls. Jobs no longer modify round-removal targeting.
/datum/job/proc/update_opt_in_vars()
	return FALSE

/// Deprecated no-op.
/datum/job/proc/update_opt_in_desc_suffix()
	return

/// Setter for [new_suffix]. Resets desc then appends the new suffix.
/datum/job/proc/set_opt_in_desc_suffix(new_suffix)
	description = initial(description)

	if (new_suffix)
		description += new_suffix

/datum/controller/subsystem/job/setup_occupations()
	. = ..()

	if(CONFIG_GET(flag/disable_antag_opt_in_preferences))
		return

	for(var/datum/job/job as anything in all_occupations)
		job.update_opt_in_vars()
