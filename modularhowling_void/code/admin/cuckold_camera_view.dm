/client
	var/atom/movable/screen/map_view/cam_screen

ADMIN_VERB(view_player_camera, R_ADMIN, "Cuckold View", "Lets you see around another player in a separate window, useful for tracking players.", ADMIN_CATEGORY_MAIN)
	if (!check_rights_for(user, R_ADMIN))
		return

	var/mob/choice = tgui_input_list(user, "Choose a client to see", "Client Selection", GLOB.player_list)
	if (!choice || !choice.client)
		return
	var/client/choice_client = choice.client

	if (!choice_client.cam_screen)
		choice_client.cam_screen = new
		choice_client.cam_screen.generate_view("adminview[choice_client.ckey]_map")
		choice_client.RegisterSignal(choice_client, COMSIG_QDELETING, TYPE_PROC_REF(/client, cleanup_player_camera_view))
		if(choice_client.mob)
			choice_client.RegisterSignal(choice_client.mob, COMSIG_MOB_CLIENT_MOVED, TYPE_PROC_REF(/client, update_view))
			choice_client.RegisterSignal(choice_client.mob, COMSIG_MOB_SAY, TYPE_PROC_REF(/client, relay_camera_speech))

	if (user.screen_maps["adminview[choice_client.ckey]"])
		return
	user.setup_popup("adminview[choice_client.ckey]", 7, 7, 2, choice_client.ckey)
	choice_client.cam_screen.display_to(user.mob)
	choice_client.RegisterSignal(user, COMSIG_POPUP_CLEARED, TYPE_PROC_REF(/client, on_screen_clear))
	choice_client.update_view()

/client/proc/on_screen_clear(client/source, window)
	SIGNAL_HANDLER
	if (cam_screen)
		cam_screen.hide_from(source.mob)
	UnregisterSignal(source, COMSIG_POPUP_CLEARED)
	if(src.mob && (!cam_screen || !length(cam_screen.viewers_to_huds)))
		UnregisterSignal(src.mob, COMSIG_MOB_CLIENT_MOVED)
		UnregisterSignal(src.mob, COMSIG_MOB_SAY)

/client/proc/cleanup_player_camera_view()
	SIGNAL_HANDLER
	if (cam_screen)
		qdel(cam_screen)
		cam_screen = null
	if(src.mob)
		UnregisterSignal(src.mob, COMSIG_MOB_CLIENT_MOVED)
		UnregisterSignal(src.mob, COMSIG_MOB_SAY)
	UnregisterSignal(src, COMSIG_QDELETING)

/client/proc/update_view() // updates vis_contents for camera screen object
	SIGNAL_HANDLER
	if (!cam_screen)
		return

	cam_screen.vis_contents.Cut()
	for (var/turf/visible_turf in view(3, get_turf(src.mob)))
		cam_screen.vis_contents += visible_turf

/client/proc/relay_camera_speech(mob/living/source, list/speech_args)
	SIGNAL_HANDLER
	if(!cam_screen || !length(cam_screen.viewers_to_huds))
		return
	if(!source || !speech_args)
		return

	var/raw_message = speech_args[SPEECH_MESSAGE]
	if(!raw_message)
		return

	var/datum/language/message_language = speech_args[SPEECH_LANGUAGE]
	var/list/spans = speech_args[SPEECH_SPANS]
	var/list/copied_spans = islist(spans) ? spans.Copy() : null

	for(var/datum/weakref/client_ref as anything in cam_screen.viewers_to_huds)
		var/client/viewer_client = client_ref.resolve()
		var/mob/viewer_mob = viewer_client?.mob
		if(!viewer_mob)
			continue
		// If already in local hearers, standard speech path will render runechat anyway.
		if(viewer_mob in get_hearers_in_view(speech_args[SPEECH_RANGE], source))
			continue
		if(!viewer_client.prefs?.read_preference(/datum/preference/toggle/enable_runechat))
			continue
		viewer_mob.create_chat_message(source, message_language, raw_message, copied_spans)
