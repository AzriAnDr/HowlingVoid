/client
	var/atom/movable/screen/map_view/cuckold_view_screen
	var/mob/cuckold_view_target

ADMIN_VERB(view_cuckold, R_ADMIN, "Cuckold View", "Lets you see around another player in a separate window, useful for tracking players.", ADMIN_CATEGORY_MAIN)
	if(!check_rights_for(user, R_ADMIN))
		return

	var/mob/choice = tgui_input_list(user, "Choose a client to see", "Client Selection", GLOB.player_list)
	if(!choice?.client)
		return
	if(is_admin_shoo_ghost_protected(choice))
		to_chat(user, span_warning("[choice] is protected by Admin Shoo Ghost."))
		return

	var/client/choice_client = choice.client
	var/popup_name = "adminview[choice_client.ckey]"
	var/map_name = "[popup_name]_map"

	if(!choice_client.cuckold_view_screen)
		choice_client.cuckold_view_screen = new
		choice_client.cuckold_view_screen.generate_view(map_name)
		choice_client.RegisterSignal(choice_client, COMSIG_QDELETING, TYPE_PROC_REF(/client, cleanup_cuckold_view))
		choice_client.RegisterSignal(choice_client, COMSIG_CLIENT_MOB_LOGIN, TYPE_PROC_REF(/client, on_cuckold_view_target_mob_login))
	choice_client.set_cuckold_view_follow_target(choice_client.mob)

	if(user.screen_maps[map_name])
		return
	user.setup_popup(popup_name, 7, 7, 2, choice_client.ckey)
	choice_client.cuckold_view_screen.display_to(user.mob)
	choice_client.RegisterSignal(user, COMSIG_POPUP_CLEARED, TYPE_PROC_REF(/client, on_cuckold_view_popup_clear))
	choice_client.update_cuckold_view()
	BLACKBOX_LOG_ADMIN_VERB("Cuckold View")

/client/proc/on_cuckold_view_popup_clear(client/source, window)
	SIGNAL_HANDLER

	if(window != "adminview[ckey]")
		return

	if(cuckold_view_screen)
		cuckold_view_screen.hide_from_client(source)
	UnregisterSignal(source, COMSIG_POPUP_CLEARED)
	if(!cuckold_view_screen || !length(cuckold_view_screen.viewers_to_huds))
		set_cuckold_view_follow_target(null)

/client/proc/cleanup_cuckold_view()
	SIGNAL_HANDLER

	set_cuckold_view_follow_target(null)
	QDEL_NULL(cuckold_view_screen)
	UnregisterSignal(src, list(COMSIG_QDELETING, COMSIG_CLIENT_MOB_LOGIN))

/client/proc/on_cuckold_view_target_mob_login(client/source, mob/new_mob)
	SIGNAL_HANDLER

	set_cuckold_view_follow_target(new_mob)
	update_cuckold_view()

/client/proc/set_cuckold_view_follow_target(mob/new_target)
	if(cuckold_view_target == new_target)
		return
	if(cuckold_view_target)
		UnregisterSignal(cuckold_view_target, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_SAY))
	cuckold_view_target = new_target
	if(cuckold_view_target)
		RegisterSignal(cuckold_view_target, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/client, update_cuckold_view))
		RegisterSignal(cuckold_view_target, COMSIG_MOB_SAY, TYPE_PROC_REF(/client, relay_cuckold_view_speech))

/client/proc/update_cuckold_view()
	SIGNAL_HANDLER

	if(!cuckold_view_screen)
		return

	var/atom/focus = cuckold_view_target || mob
	if(ismob(focus))
		var/mob/focus_mob = focus
		if(is_admin_shoo_ghost_protected(focus_mob))
			cuckold_view_screen.vis_contents = null
			return

	var/turf/focus_turf = get_turf(focus)
	if(!focus_turf)
		return

	var/range = 3
	var/turf/lowerleft = locate(
		max(1, focus_turf.x - range),
		max(1, focus_turf.y - range),
		focus_turf.z,
	)
	var/turf/upperright = locate(
		min(world.maxx, focus_turf.x + range),
		min(world.maxy, focus_turf.y + range),
		focus_turf.z,
	)
	cuckold_view_screen.vis_contents = block(lowerleft, upperright)

/client/proc/relay_cuckold_view_speech(mob/source, list/speech_args)
	SIGNAL_HANDLER

	if(!cuckold_view_screen || !length(cuckold_view_screen.viewers_to_huds))
		return
	if(!source || !speech_args)
		return
	if(is_admin_shoo_ghost_protected(source))
		return

	var/raw_message = speech_args[SPEECH_MESSAGE]
	if(!raw_message)
		return

	var/datum/language/message_language = speech_args[SPEECH_LANGUAGE]
	var/list/spans = speech_args[SPEECH_SPANS]
	var/list/copied_spans = islist(spans) ? spans.Copy() : null

	for(var/datum/weakref/client_ref as anything in cuckold_view_screen.viewers_to_huds)
		var/client/viewer_client = client_ref.resolve()
		var/mob/viewer_mob = viewer_client?.mob
		if(!viewer_mob)
			continue
		if(viewer_mob in get_hearers_in_view(speech_args[SPEECH_RANGE], source))
			continue
		if(!viewer_client.prefs?.read_preference(/datum/preference/toggle/enable_runechat))
			continue
		viewer_mob.create_chat_message(source, message_language, raw_message, copied_spans)
