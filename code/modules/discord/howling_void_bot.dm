/// Base URL for the external Howling Void Discord bot API, for example http://127.0.0.1:5088.
/// Used for round announcements; old-style Discord verification uses MariaDB directly.
/datum/config_entry/string/howling_void_bot_api_url
	protection = CONFIG_ENTRY_LOCKED

/// Shared API key for round announcement requests from SS13 to the external Discord bot.
/datum/config_entry/string/howling_void_bot_api_key
	protection = CONFIG_ENTRY_LOCKED|CONFIG_ENTRY_HIDDEN

/// Timeout for HTTP calls to the external Discord bot, in seconds.
/datum/config_entry/number/howling_void_bot_http_timeout_seconds
	default = 5
	min_val = 1

/proc/howling_void_bot_is_configured()
	return !!CONFIG_GET(string/howling_void_bot_api_url) && !!CONFIG_GET(string/howling_void_bot_api_key)

/proc/howling_void_bot_build_url(endpoint)
	var/base_url = CONFIG_GET(string/howling_void_bot_api_url)
	if(!base_url)
		return

	if(copytext(base_url, length(base_url), length(base_url) + 1) == "/")
		base_url = copytext(base_url, 1, length(base_url))

	return "[base_url]/[endpoint]"

/proc/howling_void_bot_headers()
	return list(
		"Content-Type" = "application/json",
		"X-Api-Key" = CONFIG_GET(string/howling_void_bot_api_key),
	)

/proc/howling_void_bot_round_mode_name()
	if(SSstoryteller?.is_enabled())
		if(SSstoryteller.round_mode == STORYTELLER_ROUND_MODE_EXTENDED)
			return "Extended"
		return "Dynamic"

	return "Dynamic"

/proc/howling_void_bot_announce_round_start()
	set waitfor = FALSE

	if(!howling_void_bot_is_configured())
		return

	var/player_count = LAZYLEN(GLOB.joined_player_list)
	if(!player_count)
		player_count = SSticker.totalPlayersReady

	var/alive_count = min(living_player_count(), player_count)
	var/dead_count = max(player_count - alive_count, 0)
	var/ghost_count = length(GLOB.dead_player_list) + length(GLOB.current_observers_list)

	var/list/payload = list(
		"roundId" = "[GLOB.round_id]",
		"mode" = howling_void_bot_round_mode_name(),
		"playerCount" = player_count,
		"roundTime" = DisplayTimeText(world.time - SSticker.round_start_time),
		"alive" = alive_count,
		"dead" = dead_count,
		"adminCount" = length(GLOB.admins),
		"ghostCount" = ghost_count,
	)

	var/datum/http_request/request = new
	request.prepare(
		RUSTG_HTTP_METHOD_POST,
		howling_void_bot_build_url("api/rounds/announce"),
		json_encode(payload),
		howling_void_bot_headers(),
		timeout_seconds = CONFIG_GET(number/howling_void_bot_http_timeout_seconds),
	)
	request.execute_blocking()

	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code < 200 || response.status_code >= 300)
		log_world("Howling Void bot round announcement failed: [response.errored ? response.error : "HTTP [response.status_code]: [response.body]"]")
