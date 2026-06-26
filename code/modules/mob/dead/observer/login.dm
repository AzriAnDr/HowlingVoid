/mob/dead/observer/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	if(ckey && is_banned_from(ckey, BAN_DONOTREVIVE))
		to_chat(src, span_notice("As you are revival banned, you cannot reenter your body."))
		can_reenter_corpse = FALSE

	ghost_accs = client.prefs.read_preference(/datum/preference/choiced/ghost_accessories)
	ghost_others = client.prefs.read_preference(/datum/preference/choiced/ghost_others)
	var/preferred_form = null

	if(client.prefs.unlock_content)
		preferred_form = client.prefs.read_preference(/datum/preference/choiced/ghost_form)
		ghost_orbit = client.prefs.read_preference(/datum/preference/choiced/ghost_orbit)

	update_icon(ALL, preferred_form)
	updateghostimages()
	client.set_right_click_menu_mode(FALSE)
	lighting_cutoff = default_lighting_cutoff()
	update_sight()

