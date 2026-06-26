GLOBAL_LIST_EMPTY(startup_messages)
// FOR MOR INFO ON HTML CUSTOMISATION, SEE: https://github.com/Skyrat-SS13/Skyrat-tg/pull/4783

#define MAX_STARTUP_MESSAGES 27
#define HOWLING_MENU_HTML "code/html_menu/index.html"

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
	items += {"<li class=\"menu-item\" data-action=\"storyteller-vote\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];storyteller_vote=1'><span class=\"menu-label\">STORYTELLER VOTE</span></a></li>"}

	items += {"<li class=\"menu-item\" data-action=\"discord\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];open_discord=1'><span class=\"menu-label\">DISCORD</span></a></li>"}

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
				if(window.setMenuChapterFromServer) {
					window.setMenuChapterFromServer(chapter);
					return;
				}
				if(window.setMenuChapter) {
					window.setMenuChapter(chapter);
					return;
				}
				window.__HOWLING_MENU_SETTINGS = window.__HOWLING_MENU_SETTINGS || {};
				window.__HOWLING_MENU_SETTINGS.menuChapter = String(chapter || \"\");
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
				byondSrc: \"[text_ref(src)]\",
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
	get_asset_datum(/datum/asset/simple/lobby_howling_menu)
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
