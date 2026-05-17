/client/verb/mute_menu_music()
	set name = "Mute Menu Music"
	set category = "OOC"
	set desc = "Set title screen menu music volume to 0."

	if(!prefs)
		return

	prefs.write_preference(GLOB.preference_entries[/datum/preference/numeric/volume/sound_menu_music_volume], 0)
	prefs.update_static_data(mob, always_instant = TRUE)
	to_chat(src, span_notice("Menu music muted (volume set to 0)."))

	if(isnewplayer(mob))
		var/mob/dead/new_player/new_player = mob
		new_player.update_menu_music_settings()
