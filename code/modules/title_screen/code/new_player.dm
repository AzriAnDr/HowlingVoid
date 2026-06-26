/mob/dead/new_player
	/// Title screen is ready to receive signals
	var/title_screen_is_ready = FALSE

/mob/dead/new_player/Topic(href, href_list[])
	if(src != usr)
		return

	if(!client)
		return

	if(client.interviewee)
		return FALSE

	if(handle_title_screen_preference_topic(href_list))
		return

	if(href_list["observe"])
		if(is_storyteller_lobby_locked(TRUE))
			return
		play_lobby_button_sound()
		make_me_an_observer()
		return

	if(href_list["server_swap"])
		play_lobby_button_sound()
		server_swap()
		return

	if(href_list["view_manifest"])
		play_lobby_button_sound()
		ViewManifest()
		return

	if(href_list["view_directory"])
		play_lobby_button_sound()
		client?.show_character_directory()
		return

	if(href_list["toggle_antag"])
		if(is_storyteller_lobby_locked(TRUE))
			return
		play_lobby_button_sound()
		var/datum/preferences/preferences = client.prefs
		preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/be_antag], !preferences.read_preference(/datum/preference/toggle/be_antag))
		client << output(preferences.read_preference(/datum/preference/toggle/be_antag), "howling_title_browser:toggle_antag")
		return

	if(href_list["character_setup"])
		if(is_storyteller_lobby_locked(TRUE))
			return
		play_lobby_button_sound()
		var/datum/preferences/preferences = client.prefs
		preferences.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
		preferences.update_static_data(src)
		preferences.ui_interact(src)
		return

	if(href_list["game_options"])
		play_lobby_button_sound()
		var/datum/preferences/preferences = client.prefs
		preferences.current_window = PREFERENCE_TAB_GAME_PREFERENCES
		preferences.update_static_data(usr)
		preferences.ui_interact(usr)
		return

	if(href_list["storyteller_vote"])
		play_lobby_button_sound()
		SSvote.open_storyteller_vote_panel(usr)
		return

	if(href_list["toggle_ready"])
		if(SSticker && SSticker.current_state > GAME_STATE_PREGAME)
			to_chat(src, span_notice("It's too late for that, the round is already starting!"))
			return
		play_lobby_button_sound()
		if(CONFIG_GET(flag/min_flavor_text))
			if(!is_admin(client) && length_char(client?.prefs?.read_preference(/datum/preference/text/flavor_text)) < CONFIG_GET(number/flavor_text_character_requirement))
				to_chat(src, span_notice("You need at least [CONFIG_GET(number/flavor_text_character_requirement)] characters of flavor text to ready up for the round. You have [length_char(client.prefs.read_preference(/datum/preference/text/flavor_text))] characters."))
				return

		if(ready == PLAYER_NOT_READY)
			auto_deadmin_on_ready_or_latejoin()
			ready = PLAYER_READY_TO_PLAY
			SSstatpanels.add_job_estimation(src)
		else
			ready = PLAYER_NOT_READY
			SSstatpanels.remove_job_estimation(src)

		client << output((ready == PLAYER_READY_TO_PLAY) ? 1 : 0, "howling_title_browser:toggle_ready")
		return

	if(href_list["late_join"])
		play_lobby_button_sound()
		GLOB.latejoin_menu.ui_interact(usr)
		return

	if(href_list["display_polls"])
		handle_player_polling()
		return

	if(href_list["open_discord"])
		if(client)
			client << link(CONFIG_GET(string/discord_link))
		return

	if(href_list["viewpoll"])
		var/datum/poll_question/poll = locate(href_list["viewpoll"]) in GLOB.polls
		poll_player(poll)
		return

	if(href_list["votepollref"])
		var/datum/poll_question/poll = locate(href_list["votepollref"]) in GLOB.polls
		vote_on_poll_handler(poll, href_list)
		return

	if(href_list["title_is_ready"])
		title_screen_is_ready = TRUE
		update_menu_music_settings()
		update_interface_language_setting()
		update_menu_chapter_setting()
		if(SSticker && SSticker.current_state > GAME_STATE_PREGAME)
			client << output(1, "howling_title_browser:set_round_started")
		return

/mob/dead/new_player/proc/handle_title_screen_preference_topic(list/href_list)
	if(href_list["set_menu_music_volume"])
		set_menu_music_volume(text2num(href_list["set_menu_music_volume"]))
		return TRUE

	if(href_list["set_interface_language"])
		set_menu_interface_language(href_list["set_interface_language"])
		return TRUE

	if(href_list["set_menu_chapter"])
		set_menu_chapter(href_list["set_menu_chapter"])
		return TRUE

	return FALSE

/mob/dead/new_player/proc/set_menu_music_volume(volume)
	var/datum/preferences/preferences = client?.prefs
	if(!preferences)
		return

	var/menu_music_volume = clamp(volume, 0, 100)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/numeric/volume/sound_menu_music_volume], menu_music_volume)
	if(menu_music_volume > 0)
		preferences.update_preference(GLOB.preference_entries[/datum/preference/toggle/menu_music_enabled], TRUE)
	preferences.update_data_for_all_viewers()
	preferences.update_static_data(src, always_instant = TRUE)
	preferences.save_preferences()
	update_menu_music_settings()

/mob/dead/new_player/proc/set_menu_interface_language(interface_language)
	var/datum/preferences/preferences = client?.prefs
	if(!preferences)
		return

	if(!(interface_language in list("english", "russian")))
		return

	preferences.write_preference(GLOB.preference_entries[/datum/preference/choiced/interface_language], interface_language)
	preferences.update_static_data(src, always_instant = TRUE)
	update_interface_language_setting()

/mob/dead/new_player/proc/set_menu_chapter(menu_chapter)
	var/datum/preferences/preferences = client?.prefs
	if(!preferences)
		return

	var/datum/preference/choiced/chapter_preference = GLOB.preference_entries[/datum/preference/choiced/menu_chapter]
	if(!(menu_chapter in chapter_preference.get_choices()))
		return

	preferences.write_preference(chapter_preference, menu_chapter)
	preferences.save_preferences()
	update_menu_chapter_setting()

/mob/dead/new_player/Login()
	. = ..()
	if(client)
		stop_sound_channel(CHANNEL_LOBBYMUSIC)
	show_title_screen()

/**
 * Shows the titlescreen to a new player.
 */
/mob/dead/new_player/proc/show_title_screen()
	if(isnull(client))
		return
	if(client.interviewee)
		return

	stop_sound_channel(CHANNEL_LOBBYMUSIC)

	winset(src, "howling_title_browser", "is-disabled=false;is-visible=true")
	winset(src, "status_bar", "is-visible=false")

	var/datum/asset/lobby_assets = get_asset_datum(/datum/asset/simple/lobby) // Sending base lobby assets
	lobby_assets.send(src)

	var/datum/asset/howling_menu_assets = get_asset_datum(/datum/asset/simple/lobby_howling_menu) // Sending custom html_menu assets
	howling_menu_assets.send(src)

	update_title_screen()

/**
 * Hard updates the title screen HTML, it causes visual glitches if used.
 */
/mob/dead/new_player/proc/update_title_screen()
	var/dat = get_title_html()

	src << browse(SStitle.current_title_screen, "file=loading_screen.gif;display=0")
	src << browse(dat, "window=howling_title_browser")
	update_menu_music_settings()
	update_menu_chapter_setting()

/mob/dead/new_player/proc/notify_round_started()
	if(!client)
		return
	client << output(1, "howling_title_browser:set_round_started")

/mob/dead/new_player/proc/update_menu_chapter_setting()
	if(!client || !client.prefs || !title_screen_is_ready)
		return

	var/menu_chapter = client.prefs.read_preference(/datum/preference/choiced/menu_chapter)
	client << output(menu_chapter, "howling_title_browser:set_menu_chapter")

/mob/dead/new_player/proc/update_menu_music_settings()
	if(!client)
		return

	var/datum/preferences/preferences = client.prefs
	if(!preferences)
		return

	var/menu_music_enabled = preferences.read_preference(/datum/preference/toggle/menu_music_enabled) ? 1 : 0
	var/menu_music_volume = clamp(preferences.read_preference(/datum/preference/numeric/volume/sound_menu_music_volume), 0, 100)
	client << output(menu_music_enabled, "howling_title_browser:set_menu_music_enabled")
	client << output(menu_music_volume, "howling_title_browser:set_menu_music_volume")

/mob/dead/new_player/proc/update_interface_language_setting()
	if(!client)
		return

	var/datum/preferences/preferences = client.prefs
	if(!preferences)
		return

	client << output(preferences.read_preference(/datum/preference/choiced/interface_language), "howling_title_browser:set_menu_language")

/datum/asset/simple/lobby
	assets = list(
		"FixedsysExcelsior3.01Regular.ttf" = 'html/browser/FixedsysExcelsior3.01Regular.ttf',
	)

/datum/asset/simple/lobby_howling_menu
	assets = list(
		"menuChapters.js" = 'code/html_menu/menuChapters.js',
		"ironHeart.js" = 'code/html_menu/ironHeart.js',
		"jesusWept.js" = 'code/html_menu/jesusWept.js',
		"crossToBear.js" = 'code/html_menu/crossToBear.js',
		"sisterRay.js" = 'code/html_menu/sisterRay.js',
		"molesHamsters.js" = 'code/html_menu/molesHamsters.js',
		"ironHeart.css" = 'code/html_menu/ironHeart.css',
		"jesusWept.css" = 'code/html_menu/jesusWept.css',
		"crossToBear.css" = 'code/html_menu/crossToBear.css',
		"sisterRay.css" = 'code/html_menu/sisterRay.css',
		"molesHamsters.css" = 'code/html_menu/molesHamsters.css',
		"buttonclickrelease.ogg" = 'code/html_menu/buttonclickrelease.ogg',
		"iron_heart.ogg" = 'code/html_menu/iron_heart.ogg',
		"jesus_wept.ogg" = 'code/html_menu/jesus_wept.ogg',
		"cross_to_bear.ogg" = 'code/html_menu/cross_to_bear.ogg',
		"Sister_Ray.mp3" = 'code/html_menu/Sister_Ray.mp3',
		"molesHamsters.mp3" = 'code/html_menu/molesHamsters.mp3',
	)

/**
 * Removes the titlescreen entirely from a mob.
 */
/mob/dead/new_player/proc/hide_title_screen()
	if(client?.mob)
		client << output(null, "howling_title_browser:stop_menu_audio")
		winset(client, "howling_title_browser", "is-disabled=true;is-visible=false")
		winset(client, "status_bar", "is-visible=true")

/mob/dead/new_player/proc/play_lobby_button_sound()
	var/sound/button_sound = sound('sound/effects/save.ogg')
	button_sound.volume = 25
	SEND_SOUND(src, button_sound)

/**
 * Allows the player to select a server to join from any loaded servers.
 */
/mob/dead/new_player/proc/server_swap()
	var/list/servers = CONFIG_GET(keyed_list/cross_server)
	if(LAZYLEN(servers) == 1)
		var/server_name = servers[1]
		var/server_ip = servers[server_name]
		var/confirm = tgui_alert(src, "Are you sure you want to swap to [server_name] ([server_ip])?", "Swapping server!", list("Send me there", "Stay here"))
		if(confirm == "Connect me!")
			to_chat_immediate(src, "So long, spaceman.")
			client << link(server_ip)
		return
	var/server_name = tgui_input_list(src, "Please select the server you wish to swap to:", "Swap servers!", servers)
	if(!server_name)
		return
	var/server_ip = servers[server_name]
	var/confirm = tgui_alert(src, "Are you sure you want to swap to [server_name] ([server_ip])?", "Swapping server!", list("Connect me!", "Stay here!"))
	if(confirm == "Connect me!")
		to_chat_immediate(src, "So long, spaceman.")
		src.client << link(server_ip)

/**
 * Shows the player a list of current polls, if any.
 */
/mob/dead/new_player/proc/playerpolls()
	if(!usr || !client)
		return

	var/output
	if (!SSdbcore.Connect())
		return
	var/isadmin = FALSE
	if(client?.holder)
		isadmin = TRUE
	var/datum/db_query/query_get_new_polls = SSdbcore.NewQuery({"
		SELECT id FROM [format_table_name("poll_question")]
		WHERE (adminonly = 0 OR :isadmin = 1)
		AND Now() BETWEEN starttime AND endtime
		AND deleted = 0
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_vote")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_textreply")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
	"}, list("isadmin" = isadmin, "ckey" = ckey))

	if(!query_get_new_polls.Execute())
		qdel(query_get_new_polls)
		return
	if(query_get_new_polls.NextRow())
		output +={"<a class="menu_button menu_newpoll" href='byond://?src=[text_ref(src)];display_polls=1'>POLLS (NEW)</a>"}
	else
		output +={"<a class="menu_button" href='byond://?src=[text_ref(src)];display_polls=1'>POLLS</a>"}
	qdel(query_get_new_polls)
	if(QDELETED(src))
		return
	return output
