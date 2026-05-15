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

	if(href_list["set_menu_music_volume"])
		var/datum/preferences/preferences = client.prefs
		if(!preferences)
			return

		var/menu_music_volume = clamp(text2num(href_list["set_menu_music_volume"]), 0, 100)
		preferences.update_preference(GLOB.preference_entries[/datum/preference/numeric/volume/sound_menu_music_volume], menu_music_volume)
		if(menu_music_volume > 0)
			preferences.update_preference(GLOB.preference_entries[/datum/preference/toggle/menu_music_enabled], TRUE)
		preferences.update_data_for_all_viewers()
		preferences.update_static_data(src, always_instant = TRUE)
		preferences.save_preferences()
		update_menu_music_settings()
		return

	if(href_list["set_interface_language"])
		var/datum/preferences/preferences = client.prefs
		if(!preferences)
			return

		var/interface_language = href_list["set_interface_language"]
		if(!(interface_language in list("english", "russian")))
			return

		preferences.write_preference(GLOB.preference_entries[/datum/preference/choiced/interface_language], interface_language)
		preferences.update_static_data(src, always_instant = TRUE)
		update_interface_language_setting()
		return

	if(href_list["set_menu_chapter"])
		var/datum/preferences/preferences = client.prefs
		if(!preferences)
			return

		var/datum/preference/choiced/chapter_preference = GLOB.preference_entries[/datum/preference/choiced/menu_chapter]
		var/menu_chapter = href_list["set_menu_chapter"]
		if(!(menu_chapter in chapter_preference.get_choices()))
			return

		preferences.write_preference(chapter_preference, menu_chapter)
		preferences.save_preferences()
		update_menu_chapter_setting()
		return

	if(href_list["observe"])
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
		play_lobby_button_sound()
		var/datum/preferences/preferences = client.prefs
		preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/be_antag], !preferences.read_preference(/datum/preference/toggle/be_antag))
		client << output(preferences.read_preference(/datum/preference/toggle/be_antag), "nova_title_browser:toggle_antag")
		return

	if(href_list["character_setup"])
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

		client << output((ready == PLAYER_READY_TO_PLAY) ? 1 : 0, "nova_title_browser:toggle_ready")
		return

	if(href_list["late_join"])
		play_lobby_button_sound()
		GLOB.latejoin_menu.ui_interact(usr)
		return

	if(href_list["display_polls"])
		handle_player_polling()
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
			client << output(1, "nova_title_browser:set_round_started")
		return

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

	winset(src, "nova_title_browser", "is-disabled=false;is-visible=true")
	winset(src, "status_bar", "is-visible=false")

	// Howling Void Edit start
	var/datum/asset/lobby_assets = get_asset_datum(/datum/asset/simple/lobby) // Sending base lobby assets
	lobby_assets.send(src)

	var/datum/asset/howling_menu_assets = get_asset_datum(/datum/asset/simple/lobby_howling_menu) // Sending custom html_menu assets
	howling_menu_assets.send(src)
	// Howling Void Edit end

	update_title_screen()

/**
 * Hard updates the title screen HTML, it causes visual glitches if used.
 */
/mob/dead/new_player/proc/update_title_screen()
	var/dat = get_title_html()

	src << browse(SStitle.current_title_screen, "file=loading_screen.gif;display=0")
	src << browse(dat, "window=nova_title_browser")
	update_menu_music_settings()

// Howling Void Edit start
/mob/dead/new_player/proc/notify_round_started()
	if(!client)
		return
	client << output(1, "nova_title_browser:set_round_started")
// Howling Void Edit end

/mob/dead/new_player/proc/update_menu_music_settings()
	if(!client)
		return

	var/datum/preferences/preferences = client.prefs
	if(!preferences)
		return

	var/menu_music_enabled = preferences.read_preference(/datum/preference/toggle/menu_music_enabled) ? 1 : 0
	var/menu_music_volume = clamp(preferences.read_preference(/datum/preference/numeric/volume/sound_menu_music_volume), 0, 100)
	client << output(menu_music_enabled, "nova_title_browser:set_menu_music_enabled")
	client << output(menu_music_volume, "nova_title_browser:set_menu_music_volume")

/mob/dead/new_player/proc/update_interface_language_setting()
	if(!client)
		return

	var/datum/preferences/preferences = client.prefs
	if(!preferences)
		return

	client << output(preferences.read_preference(/datum/preference/choiced/interface_language), "nova_title_browser:set_menu_language")

/mob/dead/new_player/proc/update_menu_chapter_setting()
	if(!client)
		return

	var/datum/preferences/preferences = client.prefs
	if(!preferences)
		return

	client << output(preferences.read_preference(/datum/preference/choiced/menu_chapter), "nova_title_browser:set_menu_chapter")

/datum/asset/simple/lobby
	assets = list(
		"FixedsysExcelsior3.01Regular.ttf" = 'html/browser/FixedsysExcelsior3.01Regular.ttf',
	)

// Howling Void Edit start
/datum/asset/simple/lobby_howling_menu
	assets = list(
		"menuChapters.js" = 'code/modules/title_screen/html_menu/menuChapters.js',
		"ironHeart.js" = 'code/modules/title_screen/html_menu/ironHeart.js',
		"jesusWept.js" = 'code/modules/title_screen/html_menu/jesusWept.js',
		"crossToBear.js" = 'code/modules/title_screen/html_menu/crossToBear.js',
		"sisterRay.js" = 'code/modules/title_screen/html_menu/sisterRay.js',
		"molesHamsters.js" = 'code/modules/title_screen/html_menu/molesHamsters.js',
		"ironHeart.css" = 'code/modules/title_screen/html_menu/ironHeart.css',
		"jesusWept.css" = 'code/modules/title_screen/html_menu/jesusWept.css',
		"crossToBear.css" = 'code/modules/title_screen/html_menu/crossToBear.css',
		"sisterRay.css" = 'code/modules/title_screen/html_menu/sisterRay.css',
		"molesHamsters.css" = 'code/modules/title_screen/html_menu/molesHamsters.css',
		"buttonclickrelease.ogg" = 'code/modules/title_screen/html_menu/buttonclickrelease.ogg',
		"iron_heart.ogg" = 'code/modules/title_screen/html_menu/iron_heart.ogg',
		"jesus_wept.ogg" = 'code/modules/title_screen/html_menu/jesus_wept.ogg',
		"cross_to_bear.ogg" = 'code/modules/title_screen/html_menu/cross_to_bear.ogg',
		"Sister_Ray.mp3" = 'code/modules/title_screen/html_menu/Sister_Ray.mp3',
		"molesHamsters.mp3" = 'code/modules/title_screen/html_menu/molesHamsters.mp3',
	)
// Howling Void Edit end

/**
 * Removes the titlescreen entirely from a mob.
 */
/mob/dead/new_player/proc/hide_title_screen()
	if(client?.mob)
		// Howling Void Edit start
		client << output(null, "nova_title_browser:stop_menu_audio")
		// Howling Void Edit end
		winset(client, "nova_title_browser", "is-disabled=true;is-visible=false")
		winset(client, "status_bar", "is-visible=true")

/mob/dead/new_player/proc/play_lobby_button_sound()
	var/sound/button_sound = sound('modular_nova/master_files/sound/effects/save.ogg')
	button_sound.volume = 25
	SEND_SOUND(src, button_sound)

GLOBAL_LIST_EMPTY(startup_messages)
// FOR MOR INFO ON HTML CUSTOMISATION, SEE: https://github.com/Skyrat-SS13/Skyrat-tg/pull/4783

#define MAX_STARTUP_MESSAGES 27
#define HOWLING_MENU_HTML "code/modules/title_screen/html_menu/index.html"

/mob/dead/new_player/proc/get_title_html()
	if(SSticker.current_state == GAME_STATE_STARTUP)
		return get_startup_title_html()

	return get_howling_title_html()

/mob/dead/new_player/proc/get_startup_title_html()
	var/dat = SStitle.title_html
	dat += {"<img src=\"loading_screen.gif\" class=\"bg\" alt=\"\">"}
	dat += {"<div class=\"container_terminal\" id=\"terminal\"></div>"}
	dat += {"<div class=\"container_progress\" id=\"progress_container\"><div class=\"progress_bar\" id=\"progress\"><div class=\"sub_progress_bar\" id=\"sub_progress\"></div></div></div>"}

	dat += {"
	<script language=\"JavaScript\">
		var terminal = document.getElementById(\"terminal\");
		var terminal_lines = \[
	"}

	for(var/message in GLOB.startup_messages)
		dat += {""[replacetext(message, "\"", "\\\"")]","}

	dat += {"
		\];

		function append_terminal_text(text) {
			if(text) {
				terminal_lines.push(text);
			}
			while(terminal_lines.length > [MAX_STARTUP_MESSAGES]) {
				terminal_lines.shift();
			}

			terminal.innerHTML = terminal_lines.join(\"\");
		}

		append_terminal_text();

		var progress_bar = document.getElementById(\"progress\");
		var sub_progress_bar = document.getElementById(\"sub_progress\");
		var previous_tick = new Date().getTime();
		var progress_current_time = [world.timeofday - SStitle.progress_reference_time];
		var progress_completion_time = [SStitle.average_completion_time];
		var progress_current_position = 0;
		var progress_sub_start = 0;
		var target_sub_start = 0;

		setInterval(function() {
			if(progress_current_time < progress_completion_time) {
				var current_tick = new Date().getTime();
				progress_current_time += (current_tick - previous_tick) / 100;
				previous_tick = current_tick;
			}

			progress_current_position = Math.min(Math.max(progress_current_time / progress_completion_time * 100, progress_current_position), 100);

			if(progress_sub_start == 0) {
				progress_sub_start = target_sub_start = progress_current_position;
			} else {
				progress_sub_start = Math.min(progress_sub_start + 0.1, target_sub_start);
			}

			var progress_sub_current_position = (progress_current_position - progress_sub_start) / progress_current_position * 100;

			progress_bar.style.width = \"\" + progress_current_position + \"%\";
			sub_progress_bar.style.width = \"\" + progress_sub_current_position + \"%\";
		}, 16.666666667);

		function update_loading_progress(current_time, total_time) {
			progress_current_time = parseFloat(current_time);
			progress_completion_time = parseFloat(total_time);
			target_sub_start = progress_current_position;
		}

		function set_round_started() {}
		function stop_menu_audio() {}
		function update_current_character() {}

		var ready_request = new XMLHttpRequest();
		ready_request.open(\"GET\", \"?src=[text_ref(src)];title_is_ready=1\", true);
		ready_request.send();
	</script>
	</body></html>
	"}

	return dat

/mob/dead/new_player/proc/get_howling_title_html()
	var/dat = file2text(HOWLING_MENU_HTML)
	if(!dat)
		CRASH("Unable to read Howling title menu HTML.")

	var/menu_chapters_url = SSassets.transport.get_asset_url("menuChapters.js")
	var/static_menu_html = get_howling_static_menu_html(dat)
	if(!static_menu_html)
		CRASH("Unable to find Howling title menu list in index.html.")
	if(!findtext(dat, "<script src=\"menuChapters.js\"></script>"))
		CRASH("Unable to find Howling title menu bootstrap script tag in index.html.")

	dat = replacetext(dat, "<script src=\"menuChapters.js\"></script>", "[get_howling_title_bootstrap()]<script src=\"[menu_chapters_url]\"></script>")
	dat = replacetext(dat, "<ul class=\"menu-list\">[static_menu_html]</ul>", "<ul class=\"menu-list\">[get_howling_menu_items()]</ul>")

	if(SStitle.current_notice)
		dat = replacetext(dat, "</body>", "<div class=\"container_notice\"><p class=\"menu_notice\">[SStitle.current_notice]</p></div></body>")

	return dat

/mob/dead/new_player/proc/get_howling_static_menu_html(html)
	var/list/menu_split = splittext(html, "<ul class=\"menu-list\">")
	if(length(menu_split) < 2)
		return ""

	var/list/menu_close_split = splittext(menu_split[2], "</ul>")
	if(!length(menu_close_split))
		return ""

	return menu_close_split[1]

/mob/dead/new_player/proc/get_howling_menu_items()
	var/current_antag_text = client.prefs.read_preference(/datum/preference/toggle/be_antag) ? "BE ANTAGONIST: ON" : "BE ANTAGONIST: OFF"
	var/current_ready_text = ready == PLAYER_READY_TO_PLAY ? "READY: ON" : "READY: OFF"
	var/list/items = list()

	if(!SSticker || SSticker.current_state <= GAME_STATE_PREGAME)
		items += {"<li class=\"menu-item\" data-action=\"toggle-ready\"><a id=\"ready\" class=\"menu-link\" href='byond://?src=[text_ref(src)];toggle_ready=1'><span class=\"menu-label\">[current_ready_text]</span></a></li>"}
	else
		items += {"<li class=\"menu-item\" data-action=\"join-game\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];late_join=1'><span class=\"menu-label\">JOIN GAME</span></a></li>"}

	items += {"<li class=\"menu-item\" data-action=\"observe\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];observe=1'><span class=\"menu-label\">OBSERVE</span></a></li>"}
	items += {"<li class=\"menu-item\" data-action=\"manifest\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];view_manifest=1'><span class=\"menu-label\">CREW MANIFEST</span></a></li>"}
	items += {"<li class=\"menu-item\" data-action=\"character-directory\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];view_directory=1'><span class=\"menu-label\">CHARACTER DIRECTORY</span></a></li>"}
	items += {"<li class=\"menu-item\" data-action=\"character-setup\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];character_setup=1'><span class=\"menu-label\">SETUP CHARACTER</span></a></li>"}
	items += {"<li class=\"menu-item\" data-action=\"game-options\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];game_options=1'><span class=\"menu-label\">GAME OPTIONS</span></a></li>"}
	items += {"<li class=\"menu-item\" data-action=\"be-antagonist\"><a id=\"be_antag\" class=\"menu-link\" href='byond://?src=[text_ref(src)];toggle_antag=1'><span class=\"menu-label\">[current_antag_text]</span></a></li>"}

	if(!is_guest_key(src.key))
		items += {"<li class=\"menu-item\" data-action=\"polls\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];display_polls=1'><span class=\"menu-label\">POLLS</span></a></li>"}

	return items.Join("")

/mob/dead/new_player/proc/get_howling_title_bootstrap()
	var/current_character_name = uppertext(client.prefs.read_preference(/datum/preference/name/real_name))
	var/menu_music_enabled = client.prefs.read_preference(/datum/preference/toggle/menu_music_enabled)
	var/menu_music_volume = clamp(client.prefs.read_preference(/datum/preference/numeric/volume/sound_menu_music_volume), 0, 100)
	var/current_interface_language = client.prefs.read_preference(/datum/preference/choiced/interface_language)
	var/current_menu_chapter = client.prefs.read_preference(/datum/preference/choiced/menu_chapter)

	return {"
		<span id=\"character_slot\" style=\"display:none\">[current_character_name]</span>
		<script language=\"JavaScript\">
			var ready_int = [ready == PLAYER_READY_TO_PLAY ? 1 : 0];
			var ready_mark = document.getElementById(\"ready\");
			function toggle_ready(setReady) {
				ready_int = (setReady !== undefined && setReady !== null) ? parseInt(setReady) : (ready_int ? 0 : 1);
				if(ready_mark) {
					ready_mark.innerHTML = \"<span class='menu-label'>\" + (ready_int ? \"READY: ON\" : \"READY: OFF\") + \"</span>\";
				}
			}

			function set_round_started() {
				window.__HOWLING_ROUND_STARTED = true;
				var join_href = \"byond://?src=[text_ref(src)];late_join=1\";
				var join_anchor = null;
				var menu_items = document.querySelectorAll(\".menu-item\");
				for(var i = 0; i < menu_items.length; i++) {
					var item = menu_items.item(i);
					if(item && item.dataset && item.dataset.action === \"join-game\") {
						join_anchor = item.querySelector(\"a.menu-link\");
						break;
					}
				}
				if(ready_mark) {
					ready_mark.id = \"\";
					ready_mark.href = join_href;
					ready_mark.innerHTML = \"<span class='menu-label'>JOIN GAME</span>\";
					var ready_item = ready_mark.closest ? ready_mark.closest(\".menu-item\") : null;
					if(ready_item) {
						ready_item.dataset.action = \"join-game\";
					}
					return;
				}

				if(join_anchor) {
					join_anchor.href = join_href;
					return;
				}

				var menu_list = document.querySelector(\".menu-list\");
				if(!menu_list) {
					return;
				}

				var join_item = document.createElement(\"li\");
				join_item.className = \"menu-item\";
				join_item.dataset.action = \"join-game\";
				join_item.innerHTML = \"<a class='menu-link' href='\" + join_href + \"'><span class='menu-label'>JOIN GAME</span></a>\";
				menu_list.insertBefore(join_item, menu_list.firstChild);
			}

			var antag_int = [client.prefs.read_preference(/datum/preference/toggle/be_antag) ? 1 : 0];
			var antag_mark = document.getElementById(\"be_antag\");
			function toggle_antag(setAntag) {
				antag_int = (setAntag !== undefined && setAntag !== null) ? parseInt(setAntag) : (antag_int ? 0 : 1);
				if(antag_mark) {
					antag_mark.innerHTML = \"<span class='menu-label'>\" + (antag_int ? \"BE ANTAGONIST: ON\" : \"BE ANTAGONIST: OFF\") + \"</span>\";
				}
			}

			var character_name_slot = document.getElementById(\"character_slot\");
			function update_current_character(name) {
				if(character_name_slot && name) {
					character_name_slot.textContent = String(name).toUpperCase();
				}
			}

			function stop_menu_audio() {
				var bgm = document.getElementById(\"bgm\");
				if(bgm) {
					try {
						bgm.pause();
						bgm.currentTime = 0;
					} catch(e) {}
				}
				var select = document.getElementById(\"select-sound\");
				if(select) {
					try {
						select.pause();
						select.currentTime = 0;
					} catch(e) {}
				}
			}

			function apply_menu_music_settings() {
				window.__HOWLING_MENU_SETTINGS = window.__HOWLING_MENU_SETTINGS || {};
				var enabled = window.__HOWLING_MENU_SETTINGS.musicEnabled !== false;
				var volume = parseFloat(window.__HOWLING_MENU_SETTINGS.musicVolume);
				var introAccepted = window.__HOWLING_MENU_SETTINGS.introAccepted === true;
				if(isNaN(volume)) {
					volume = 0;
				}
				volume = Math.max(0, Math.min(1, volume));

				var bgm = document.getElementById(\"bgm\");
				if(!bgm) {
					return;
				}

				if(!enabled || volume <= 0.0001) {
					try {
						bgm.pause();
					} catch(e) {}
					return;
				}

				try {
					bgm.volume = volume;
				} catch(e) {}

				if(introAccepted && bgm.paused && bgm.src) {
					try {
						var play_promise = bgm.play();
						if(play_promise && play_promise.catch) {
							play_promise.catch(function() {});
						}
					} catch(e) {}
				}
			}

			function set_menu_music_enabled(enabled) {
				window.__HOWLING_MENU_SETTINGS = window.__HOWLING_MENU_SETTINGS || {};
				window.__HOWLING_MENU_SETTINGS.musicEnabled = parseInt(enabled, 10) ? true : false;
				apply_menu_music_settings();
			}

			function set_menu_music_volume(volume) {
				window.__HOWLING_MENU_SETTINGS = window.__HOWLING_MENU_SETTINGS || {};
				var parsed = parseFloat(volume);
				if(isNaN(parsed)) {
					parsed = 0;
				}
				if(parsed > 0) {
					window.__HOWLING_MENU_SETTINGS.musicEnabled = true;
				}
				window.__HOWLING_MENU_SETTINGS.musicVolume = Math.max(0, Math.min(1, parsed / 100));
				apply_menu_music_settings();
			}

			function set_menu_language(language) {
				window.__HOWLING_MENU_SETTINGS = window.__HOWLING_MENU_SETTINGS || {};
				var normalized = String(language || \"\") === \"russian\" ? \"russian\" : \"english\";
				window.__HOWLING_MENU_SETTINGS.interfaceLanguage = normalized;
				window.__HOWLING_INTERFACE_LANGUAGE = normalized;
			}

			function set_menu_chapter(chapter) {
				window.__HOWLING_MENU_SETTINGS = window.__HOWLING_MENU_SETTINGS || {};
				window.__HOWLING_MENU_SETTINGS.menuChapter = String(chapter || \"\");
				if(typeof window.setMenuChapterFromServer === \"function\") {
					window.setMenuChapterFromServer(window.__HOWLING_MENU_SETTINGS.menuChapter);
				}
			}

			function append_terminal_text() {}
			function update_loading_progress() {}
		</script>
		<script>
			window.__HOWLING_MENU_SRC = \"[text_ref(src)]\";
			window.__HOWLING_ROUND_STARTED = [SSticker && SSticker.current_state > GAME_STATE_PREGAME ? "true" : "false"];
			window.__HOWLING_MENU_SETTINGS = {
				musicEnabled: [menu_music_enabled ? "true" : "false"],
				musicVolume: [menu_music_volume] / 100,
				interfaceLanguage: \"[current_interface_language]\",
				menuChapter: \"[current_menu_chapter]\",
				introAccepted: false
			};
			window.__HOWLING_INTERFACE_LANGUAGE = \"[current_interface_language]\";
			window.__HOWLING_MENU_ASSETS = [json_encode(get_howling_menu_assets())];
		</script>
		<script>
			var ready_request = new XMLHttpRequest();
			ready_request.open(\"GET\", \"?src=[text_ref(src)];title_is_ready=1\", true);
			ready_request.send();
		</script>
	"}

/mob/dead/new_player/proc/get_howling_menu_assets()
	return list(
		"menuChapters.js" = SSassets.transport.get_asset_url("menuChapters.js"),
		"ironHeart.css" = SSassets.transport.get_asset_url("ironHeart.css"),
		"ironHeart.js" = SSassets.transport.get_asset_url("ironHeart.js"),
		"jesusWept.css" = SSassets.transport.get_asset_url("jesusWept.css"),
		"jesusWept.js" = SSassets.transport.get_asset_url("jesusWept.js"),
		"crossToBear.css" = SSassets.transport.get_asset_url("crossToBear.css"),
		"crossToBear.js" = SSassets.transport.get_asset_url("crossToBear.js"),
		"sisterRay.css" = SSassets.transport.get_asset_url("sisterRay.css"),
		"sisterRay.js" = SSassets.transport.get_asset_url("sisterRay.js"),
		"molesHamsters.css" = SSassets.transport.get_asset_url("molesHamsters.css"),
		"molesHamsters.js" = SSassets.transport.get_asset_url("molesHamsters.js"),
		"iron_heart.ogg" = SSassets.transport.get_asset_url("iron_heart.ogg"),
		"jesus_wept.ogg" = SSassets.transport.get_asset_url("jesus_wept.ogg"),
		"cross_to_bear.ogg" = SSassets.transport.get_asset_url("cross_to_bear.ogg"),
		"Sister_Ray.mp3" = SSassets.transport.get_asset_url("Sister_Ray.mp3"),
		"molesHamsters.mp3" = SSassets.transport.get_asset_url("molesHamsters.mp3"),
		"buttonclickrelease.ogg" = SSassets.transport.get_asset_url("buttonclickrelease.ogg"),
	)

#undef HOWLING_MENU_HTML

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
