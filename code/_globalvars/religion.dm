// All religion stuff
GLOBAL_VAR(religion)
GLOBAL_VAR(deity)
GLOBAL_DATUM(religious_sect, /datum/religion_sect)

//bible
GLOBAL_VAR(bible_name)
GLOBAL_VAR(bible_icon_state)
GLOBAL_VAR(bible_inhand_icon_state)

//altar
GLOBAL_LIST_EMPTY(chaplain_altars)

//gear
GLOBAL_VAR(holy_weapon_type)
GLOBAL_VAR(holy_armor_type)

/// Sets a new religious sect used by all chaplains int he round
/proc/set_new_religious_sect(path, reset_existing = FALSE)
	if(!ispath(path, /datum/religion_sect))
		message_admins("[ADMIN_LOOKUPFLW(usr)] has tried to spawn an item when selecting a sect.")
		return

	if(!isnull(GLOB.religious_sect))
		if (!reset_existing)
			return
		reset_religious_sect()

	GLOB.religious_sect = new path()
	for(var/i in GLOB.player_list)
		if(!isliving(i))
			continue
		var/mob/living/am_i_holy_living = i
		if(!am_i_holy_living.mind?.holy_role)
			continue
		GLOB.religious_sect.on_conversion(am_i_holy_living)
	SEND_GLOBAL_SIGNAL(COMSIG_RELIGIOUS_SECT_CHANGED)

/// Removes any existing religious sect from chaplains, allowing another to be selected
/proc/reset_religious_sect()
	for(var/i in GLOB.player_list)
		if(!isliving(i))
			continue
		var/mob/living/am_i_holy_living = i
		if(!am_i_holy_living.mind?.holy_role)
			continue
		GLOB.religious_sect.on_deconversion(am_i_holy_living)

	GLOB.religious_sect = null
	SEND_GLOBAL_SIGNAL(COMSIG_RELIGIOUS_SECT_RESET)


// BEGIN NOVA CORE MIGRATION: code/_globalvars/religion.dm
/// list of weakrefs to highpriest successor candidates. Every chaplain who joins after the initial chaplain is added to this list. The next high priest is chosen from them by seniority.
GLOBAL_LIST(holy_successors)
/// A weakref to the current high priest mob
GLOBAL_VAR(current_highpriest)
/// The previous sect's favor value
GLOBAL_VAR(prev_favor)
/// The previous sect's typepath
GLOBAL_VAR(prev_sect_type)
// END NOVA CORE MIGRATION: code/_globalvars/religion.dm
