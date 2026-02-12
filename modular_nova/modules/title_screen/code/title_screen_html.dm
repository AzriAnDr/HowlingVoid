GLOBAL_LIST_EMPTY(startup_messages)
// FOR MOR INFO ON HTML CUSTOMISATION, SEE: https://github.com/Skyrat-SS13/Skyrat-tg/pull/4783

#define MAX_STARTUP_MESSAGES 27

/mob/dead/new_player/proc/get_title_html()
	var/dat = SStitle.title_html
	if(SSticker.current_state == GAME_STATE_STARTUP)
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
			var progress_container = document.getElementById(\"progress_container\");
			// milliseconds, the actual realtime tick number
			var previous_tick = new Date().getTime();
			// These times are all in 10ths of a second, like byond.
			var progress_current_time = [world.timeofday - SStitle.progress_reference_time];
			var progress_completion_time = [SStitle.average_completion_time];
			// Current progress bar position from 0-100
			var progress_current_position = 0;
			// Current start position from 0-100 of subprogress area. Zooming towards target_sub_start.
			var progress_sub_start = 0;
			// Target start position of progress area. A captured value of progress_current_position.
			var target_sub_start = 0;

			setInterval(function() {
				// Compensate for shakey execution.
				if(progress_current_time < progress_completion_time) {
					var current_tick = new Date().getTime();
					progress_current_time += (current_tick - previous_tick) / 100;
					previous_tick = current_tick;
				}

				// Bound the new position between the old pos and 100: only go forwards
				progress_current_position = Math.min(Math.max(progress_current_time / progress_completion_time * 100, progress_current_position), 100);

				if(progress_sub_start == 0) {
					// person just connected, jump to current real progress pos.
					progress_sub_start = target_sub_start = progress_current_position;
				} else {
					// Animate the sub-progress position; requires old and new progress bar pos to know speed.
					progress_sub_start = Math.min(progress_sub_start + 0.1, target_sub_start);
				}

				// Recalculate gap as a % within a % since they're nested.
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
		</script>
		"}

	else
		var/current_character_name = uppertext(client.prefs.read_preference(/datum/preference/name/real_name))
		var/current_antag_text = client.prefs.read_preference(/datum/preference/toggle/be_antag) ? "BE ANTAGONIST: ON" : "BE ANTAGONIST: OFF"
		var/current_ready_text = ready == PLAYER_READY_TO_PLAY ? "READY: ON" : "READY: OFF"
		var/menu_music_enabled = client.prefs.read_preference(/datum/preference/toggle/menu_music_enabled)
		var/menu_music_volume = clamp(client.prefs.read_preference(/datum/preference/numeric/volume/sound_menu_music_volume), 0, 100)
		var/menu_chapters_url = SSassets.transport.get_asset_url("menuChapters.js")
		var/iron_heart_css_url = SSassets.transport.get_asset_url("ironHeart.css")
		var/iron_heart_js_url = SSassets.transport.get_asset_url("ironHeart.js")
		var/jesus_wept_css_url = SSassets.transport.get_asset_url("jesusWept.css")
		var/jesus_wept_js_url = SSassets.transport.get_asset_url("jesusWept.js")
		var/iron_heart_audio_url = SSassets.transport.get_asset_url("iron_heart.ogg")
		var/jesus_wept_audio_url = SSassets.transport.get_asset_url("jesus_wept.ogg")
		var/select_audio_url = SSassets.transport.get_asset_url("buttonclickrelease.ogg")

		dat = {"
		<!doctype html>
		<html lang=\"en\">
			<head>
				<meta charset=\"UTF-8\">
				<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">
				<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
				<title>HOWLING VOID - Main Menu</title>
				<style>
					html, body { background: #000; }
					body { opacity: 0; }
					body.menu-css-ready { opacity: 1; transition: opacity 0.12s linear; }
				</style>
				<link href=\"https://fonts.googleapis.com/css2?family=Crimson+Text:wght@400;700&display=swap\" rel=\"stylesheet\">
			</head>
			<body>
				<div class=\"vignette\"></div>
				<div class=\"noise-overlay\"></div>
				<div class=\"background-layer bg-layer-1\"></div>
				<div class=\"background-layer bg-layer-2\"></div>

				<div class=\"inverted-cross-overlay\">
					<div class=\"cross-fog\"></div>
					<div class=\"inverted-cross\">
						<div class=\"cross-shape\"></div>
						<div class=\"cross-noise\"></div>
					</div>
				</div>
				<div class=\"whisper-layer\"></div>

				<div class=\"start-overlay\">
					<div class=\"start-center\">
						<div class=\"start-title\">ОТКАЗ ОТ ОТВЕТСТВЕННОСТИ</div>
						<div class=\"start-text\">
							Прежде чем продолжить, вы должны осознанно принять условия этого перехода.<br /><br />
							✦ Вы подтверждаете что вам <span class=\"accent\">+18 лет</span>.<br />
							✦ Вы входите в пространство, содержащее сцены насилия, резкие световые вспышки, искажённые образы, символику и темы, способные вызвать эмоциональный или физический дискомфорт.<br />
							✦ Вы подтверждаете, что <span class=\"accent\">не страдаете эпилепсией</span>, не реагируете болезненно на мерцание света, глитчи и агрессивные визуальные эффекты.<br />
							✦ Вы понимаете, что любая встреченная здесь символика, религиозные мотивы, оккультные элементы и образы — <span class=\"accent\">используются исключительно в художественных и атмосферных целях</span>, и не предназначены для пропаганды или утверждения какого-либо мировоззрения.<br />
							✦ Вы соглашаетесь войти, осознавая, что увиденное — это <span class=\"accent\">выдуманный художественный мир</span>, и принимаете все визуальные и эмоциональные последствия его атмосферы.<br /><br />
							Если вы не готовы — запечатайте этот проход.<br />
							Если готовы — подтвердите своё намерение.
						</div>
						<label class=\"start-skip\">
							<input type=\"checkbox\" id=\"skip-intro\" />
							<span>Пропустить вступление</span>
						</label>
						<button class=\"start-button\">Я СОГЛАШАЮСЬ</button>
					</div>
				</div>

				<div class=\"fisheye-lens\"></div>
				<div class=\"intro-overlay intro-overlay--hidden\">
					<div class=\"intro-center\">
						<div class=\"intro-line-small\">A build by</div>
						<div class=\"intro-line-main\">Syndicate: Code Red</div>
						<div class=\"intro-line-sub\">Space Station 13</div>
					</div>
				</div>

				<div class=\"blood-flash\"></div>
				<div class=\"white-flash\"></div>

				<div class=\"menu-wrapper\">
					<div class=\"menu-title\">
						<div class=\"menu-title-small-wrap\">
							<span class=\"menu-title-small\">SYNDICATE: CODE RED</span>
							<span class=\"menu-title-small-ghost\">SYNDICATE: CODE RED</span>
						</div>
						<span class=\"menu-title-main-wrap\">
							<span class=\"menu-title-main\" data-text=\"HOWLING VOID\">HOWLING VOID</span>
							<span class=\"menu-title-main-ghost\">HOWLING VOID</span>
						</span>
						<div class=\"menu-title-sub-wrap\">
							<span class=\"menu-title-sub\">JESUS WEPT</span>
							<span class=\"menu-title-sub-ghost\">JESUS WEPT</span>
						</div>
					</div>

					<div class=\"menu-divider\"></div>
					<ul class=\"menu-list\">
		"}

		if(!SSticker || SSticker.current_state <= GAME_STATE_PREGAME)
			dat += {"<li class=\"menu-item\" data-action=\"toggle-ready\"><a id=\"ready\" class=\"menu-link\" href='byond://?src=[text_ref(src)];toggle_ready=1'><span class=\"menu-label\">[current_ready_text]</span></a></li>"}
		else
			dat += {"
				<li class=\"menu-item\" data-action=\"join-game\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];late_join=1'><span class=\"menu-label\">JOIN GAME</span></a></li>
			"}

		dat += {"
						<li class=\"menu-item\" data-action=\"observe\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];observe=1'><span class=\"menu-label\">OBSERVE</span></a></li>
						<li class=\"menu-item\" data-action=\"manifest\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];view_manifest=1'><span class=\"menu-label\">CREW MANIFEST</span></a></li>
						<li class=\"menu-item\" data-action=\"character-directory\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];view_directory=1'><span class=\"menu-label\">CHARACTER DIRECTORY</span></a></li>
						<li class=\"menu-item\" data-action=\"character-setup\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];character_setup=1'><span class=\"menu-label\">SETUP CHARACTER: <span id=\"character_slot\">[current_character_name]</span></span></a></li>
						<li class=\"menu-item\" data-action=\"game-options\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];game_options=1'><span class=\"menu-label\">GAME OPTIONS</span></a></li>
						<li class=\"menu-item\" data-action=\"be-antagonist\"><a id=\"be_antag\" class=\"menu-link\" href='byond://?src=[text_ref(src)];toggle_antag=1'><span class=\"menu-label\">[current_antag_text]</span></a></li>
		"}

		if(!is_guest_key(src.key))
			dat += {"<li class=\"menu-item\" data-action=\"polls\"><a class=\"menu-link\" href='byond://?src=[text_ref(src)];display_polls=1'><span class=\"menu-label\">POLLS</span></a></li>"}

		dat += {"
					</ul>
				</div>

				<audio id=\"select-sound\" src=\"[select_audio_url]\" preload=\"auto\"></audio>
				<audio id=\"bgm\" src=\"\" preload=\"auto\"></audio>

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
						if(!ready_mark)
							return;
						ready_mark.id = "";
						ready_mark.href = "byond://?src=[text_ref(src)];late_join=1";
						ready_mark.innerHTML = "<span class='menu-label'>JOIN GAME</span>";
						var ready_item = ready_mark.closest ? ready_mark.closest(".menu-item") : null;
						if(ready_item) {
							ready_item.dataset.action = "join-game";
						}
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
						var bgm = document.getElementById("bgm");
						if(bgm) {
							try {
								bgm.pause();
								bgm.currentTime = 0;
							} catch(e) {}
						}
						var select = document.getElementById("select-sound");
						if(select) {
							try {
								select.pause();
								select.currentTime = 0;
							} catch(e) {}
						}
					}

					function set_menu_music_settings(payload) {
						var parts = String(payload || "").split(";");
						window.__HOWLING_MENU_SETTINGS = window.__HOWLING_MENU_SETTINGS || {};
						window.__HOWLING_MENU_SETTINGS.musicEnabled = parseInt(parts[0], 10) ? true : false;
						window.__HOWLING_MENU_SETTINGS.musicVolume = Math.max(0, Math.min(1, (parseFloat(parts[1]) || 0) / 100));
						apply_menu_music_settings();
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

						var bgm = document.getElementById("bgm");
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
								bgm.play();
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
						window.__HOWLING_MENU_SETTINGS.musicVolume = Math.max(0, Math.min(1, parsed / 100));
						apply_menu_music_settings();
					}

					function append_terminal_text() {}
					function update_loading_progress() {}
				</script>
				<script>
					window.__HOWLING_MENU_SETTINGS = {
						musicEnabled: [menu_music_enabled ? "true" : "false"],
						musicVolume: [menu_music_volume] / 100,
						introAccepted: false
					};
					window.__HOWLING_MENU_ASSETS = {
						"menuChapters.js": "[menu_chapters_url]",
						"ironHeart.css": "[iron_heart_css_url]",
						"ironHeart.js": "[iron_heart_js_url]",
						"jesusWept.css": "[jesus_wept_css_url]",
						"jesusWept.js": "[jesus_wept_js_url]",
						"iron_heart.ogg": "[iron_heart_audio_url]",
						"jesus_wept.ogg": "[jesus_wept_audio_url]",
						"buttonclickrelease.ogg": "[select_audio_url]"
					};
				</script>
				<script src=\"[menu_chapters_url]\"></script>
		"}

		if(SStitle.current_notice)
			dat += {"
				<div class=\"container_notice\">
					<p class=\"menu_notice\">[SStitle.current_notice]</p>
				</div>
			"}

		dat += {"
				<script>
					var ready_request = new XMLHttpRequest();
					ready_request.open(\"GET\", \"?src=[text_ref(src)];title_is_ready=1\", true);
					ready_request.send();
				</script>
			</body>
		</html>
		"}

	if(SSticker.current_state == GAME_STATE_STARTUP)
		// Tell the server this page loaded.
		dat += {"
			<script>
				var ready_request = new XMLHttpRequest();
				ready_request.open(\"GET\", \"?src=[text_ref(src)];title_is_ready=1\", true);
				ready_request.send();
			</script>
		"}

	if(SSticker.current_state == GAME_STATE_STARTUP)
		dat += "</body></html>"

	return dat
