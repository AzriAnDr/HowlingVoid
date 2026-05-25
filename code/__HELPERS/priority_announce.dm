// please don't use these defines outside of this file in order to ensure a unified framework. unless you have a really good reason to make them global, then whatever

// these four are just text spans that furnish the TEXT itself with the appropriate CSS classes
#define MAJOR_ANNOUNCEMENT_TITLE(string) ("<span class='major_announcement_title'>" + string + "</span>")
#define SUBHEADER_ANNOUNCEMENT_TITLE(string) ("<span class='subheader_announcement_text'>" + string + "</span>")
#define MAJOR_ANNOUNCEMENT_TEXT(string) ("<span class='major_announcement_text'>" + string + "</span>")
#define MINOR_ANNOUNCEMENT_TITLE(string) ("<span class='minor_announcement_title'>" + string + "</span>")
#define MINOR_ANNOUNCEMENT_TEXT(string) ("<span class='minor_announcement_text'>" + string + "</span>")

#define ANNOUNCEMENT_HEADER(string) ("<span class='announcement_header'>" + string + "</span>")

// these two are the ones that actually give the striped background
#define CHAT_ALERT_DEFAULT_SPAN(string) ("<div class='chat_alert_default'>" + string + "</div>")
#define CHAT_ALERT_COLORED_SPAN(color, string) ("<div class='chat_alert_" + color + "'>" + string + "</div>")

#define ANNOUNCEMENT_COLORS list("default", "green", "blue", "pink", "yellow", "orange", "red", "purple")

/proc/build_priority_announcement_markup(text, title = "", type, sender_override, has_important_message = FALSE, color_override, use_russian = FALSE)
	var/list/announcement_strings = list()

	var/header = ""
	switch(type)
		if(ANNOUNCEMENT_TYPE_PRIORITY)
			var/priority_header_text = use_russian ? "Приоритетное оповещение" : "Priority Announcement"
			header = MAJOR_ANNOUNCEMENT_TITLE(priority_header_text)
			if(length(title) > 0)
				header += SUBHEADER_ANNOUNCEMENT_TITLE(title)
		if(ANNOUNCEMENT_TYPE_CAPTAIN)
			var/captain_header_text = use_russian ? "Объявление капитана" : "Captain's Announcement"
			header = MAJOR_ANNOUNCEMENT_TITLE(captain_header_text)
		if(ANNOUNCEMENT_TYPE_SYNDICATE)
			var/syndicate_header_text = use_russian ? "Объявление капитана Синдиката" : "Syndicate Captain's Announcement"
			header = MAJOR_ANNOUNCEMENT_TITLE(syndicate_header_text)
		else
			header = generate_unique_announcement_header(title, sender_override, use_russian)

	announcement_strings += ANNOUNCEMENT_HEADER(header)

	if(SSstation.announcer.custom_alert_message && !has_important_message)
		announcement_strings += MAJOR_ANNOUNCEMENT_TEXT(SSstation.announcer.custom_alert_message)
	else
		announcement_strings += MAJOR_ANNOUNCEMENT_TEXT(text)

	if(color_override)
		return CHAT_ALERT_COLORED_SPAN(color_override, jointext(announcement_strings, ""))

	return CHAT_ALERT_DEFAULT_SPAN(jointext(announcement_strings, ""))

/proc/build_minor_announcement_markup(message, title = "Attention:", color_override)
	var/list/minor_announcement_strings = list()
	if(title != null && title != "")
		minor_announcement_strings += ANNOUNCEMENT_HEADER(MINOR_ANNOUNCEMENT_TITLE(title))
	minor_announcement_strings += MINOR_ANNOUNCEMENT_TEXT(message)

	if(color_override)
		return CHAT_ALERT_COLORED_SPAN(color_override, jointext(minor_announcement_strings, ""))

	return CHAT_ALERT_DEFAULT_SPAN(jointext(minor_announcement_strings, ""))

/**
 * Make a big red text announcement to
 *
 * Formatted like:
 *
 * " Message from sender "
 *
 * " Title "
 *
 * " Text "
 *
 * Arguments
 * * text - required, the text to announce
 * * title - optional, the title of the announcement.
 * * sound - optional, the sound played accompanying the announcement
 * * type - optional, the type of the announcement, for some "preset" announcement templates. See __DEFINES/announcements.dm
 * * sender_override - optional, modifies the sender of the announcement
 * * has_important_message - is this message critical to the game (and should not be overridden by station traits), or not
 * * players - a list of all players to send the message to. defaults to all players (not including new players)
 * * encode_title - if TRUE, the title will be HTML encoded
 * * encode_text - if TRUE, the text will be HTML encoded
 */
/proc/priority_announce(text, title = "", sound, type, sender_override, has_important_message = FALSE, list/mob/players = GLOB.player_list, encode_title = TRUE, encode_text = TRUE, color_override, text_ru = null, title_ru = null, sender_override_ru = null)
	if(!text)
		return

	if(isnull(players))
		players = GLOB.player_list

	if(encode_title && title && length(title) > 0)
		title = html_encode(title)
	if(encode_title && title_ru && length(title_ru) > 0)
		title_ru = html_encode(title_ru)
	if(encode_text)
		text = html_encode(text)
		if(!length(text))
			return
		if(text_ru)
			text_ru = html_encode(text_ru)

	if(!sound)
		sound = SSstation.announcer.get_rand_alert_sound()
	else if(SSstation.announcer.event_sounds[sound])
		sound = SSstation.announcer.event_sounds[sound]

	if(type == ANNOUNCEMENT_TYPE_CAPTAIN)
		GLOB.news_network.submit_article(text, "Captain's Announcement", NEWSCASTER_STATION_ANNOUNCEMENTS, null)

	var/list/finalized_announcements = list()
	for(var/mob/target in players)
		var/use_russian = uses_panel_language(target, "announce")
		finalized_announcements[target] = build_priority_announcement_markup(
			text = use_russian && !isnull(text_ru) ? text_ru : text,
			title = use_russian && !isnull(title_ru) ? title_ru : title,
			type = type,
			sender_override = use_russian && !isnull(sender_override_ru) ? sender_override_ru : sender_override,
			has_important_message = has_important_message,
			color_override = color_override,
			use_russian = use_russian,
		)

	dispatch_announcement_to_players(finalized_announcements, players, sound)

	if(isnull(sender_override) && players == GLOB.player_list)
		if(length(title) > 0)
			GLOB.news_network.submit_article(title + "<br><br>" + text, "[command_name()]", NEWSCASTER_STATION_ANNOUNCEMENTS, null)
		else
			GLOB.news_network.submit_article(text, "[command_name()] Update", NEWSCASTER_STATION_ANNOUNCEMENTS, null)

/**
 * Print a report to all the communications consoles, and optionally send an announcement to players about it. This is used for the roundstart report, but can also be used for other reports in the future.
 *
 * * text - the text of the report to print
 * * title - the title of the report, which is also the name of the printed paper.
 * If null, defaults to "Classified [command_name()] Update"
 * * announce - whether or not to send an announcement to players about the report being printed.
 * Defaults to TRUE.
 * * contains_advanced_html - whether or not the text contains advanced HTML that should be rendered on the paper.
 * Advanced HTML (currently) only includes <img> tags, but may include other tags in the future.
 * Do not allow player inputted reports to contain advanced HTML.
 * Defaults to FALSE, which means only basic HTML will be rendered.
 */
/proc/print_command_report(text = "", title = null, announce = TRUE, contains_advanced_html = FALSE)
	if(!title)
		title = "Classified [command_name()] Update"

	if(announce)
		priority_announce(
			text = "A report has been downloaded and printed out at all communications consoles.",
			title = "Incoming Classified Message",
			sound = SSstation.announcer.get_rand_report_sound(),
			has_important_message = TRUE,
			text_ru = "На всех консолях связи загружен и распечатан новый отчёт.",
			title_ru = "Получено засекреченное сообщение",
		)

	var/datum/comm_message/message = new
	message.title = title
	message.content = text

	GLOB.communications_controller.send_message(message, contains_advanced_html = contains_advanced_html)

/**
 * Sends a minor annoucement to players.
 * Minor announcements are large text, with the title in red and message in white.
 * Only mobs that can hear can see the announcements.
 *
 * message - the message contents of the announcement.
 * title - the title of the announcement, which is often "who sent it".
 * alert - whether this announcement is an alert, or just a notice. Only changes the sound that is played by default.
 * html_encode - if TRUE, we will html encode our title and message before sending it, to prevent player input abuse.
 * players - optional, a list mobs to send the announcement to. If unset, sends to all palyers.
 * sound_override - optional, use the passed sound file instead of the default notice sounds.
 * should_play_sound - Whether the notice sound should be played or not. This can also be a callback, if you only want mobs to hear the sound based off of specific criteria.
 * color_override - optional, use the passed color instead of the default notice color.
 */
/proc/minor_announce(message, title = "Attention:", alert = FALSE, html_encode = TRUE, list/players, sound_override, should_play_sound = TRUE, color_override, message_ru = null, title_ru = null)
	if(!message)
		return

	if(isnull(players))
		players = GLOB.player_list

	if(isnull(title_ru) && title == "Attention:")
		title_ru = "Внимание:"

	if(html_encode)
		title = html_encode(title)
		message = html_encode(message)
		if(title_ru)
			title_ru = html_encode(title_ru)
		if(message_ru)
			message_ru = html_encode(message_ru)

	var/list/finalized_announcements = list()
	for(var/mob/target in players)
		var/use_russian = uses_panel_language(target, "announce")
		finalized_announcements[target] = build_minor_announcement_markup(
			message = use_russian && !isnull(message_ru) ? message_ru : message,
			title = use_russian && !isnull(title_ru) ? title_ru : title,
			color_override = color_override,
		)

	var/custom_sound = sound_override || (alert ? 'sound/alerts/alerts/alert1.ogg' : 'sound/announcer/notice/notice2.ogg') // NOVA EDIT CHANGE - CUSTOM ANNOUNCEMENTS - Original: var/custom_sound = sound_override || (alert ? 'sound/announcer/notice/notice1.ogg' : 'sound/announcer/notice/notice2.ogg')
	dispatch_announcement_to_players(finalized_announcements, players, custom_sound, should_play_sound)

/// Sends an announcement about the level changing to players. Uses the passed in datum and the subsystem's previous security level to generate the message.
/proc/level_announce(datum/security_level/selected_level, previous_level_number)
	var/current_level_number = selected_level.number_level
	var/current_level_name = selected_level.name
	var/current_level_color = selected_level.announcement_color
	var/current_level_sound = selected_level.sound

	var/title
	var/title_ru
	var/message

	if(current_level_number > previous_level_number)
		title = "Attention! Security level elevated to [current_level_name]:"
		title_ru = "Внимание! Уровень угрозы повышен до [current_level_name]:"
		message = selected_level.elevating_to_announcement
	else
		title = "Attention! Security level lowered to [current_level_name]:"
		title_ru = "Внимание! Уровень угрозы понижен до [current_level_name]:"
		message = selected_level.lowering_to_announcement

	var/list/finalized_announcements = list()
	for(var/mob/target in GLOB.player_list)
		finalized_announcements[target] = build_minor_announcement_markup(
			message = message,
			title = uses_panel_language(target, "announce") ? title_ru : title,
			color_override = current_level_color,
		)

	dispatch_announcement_to_players(finalized_announcements, GLOB.player_list, current_level_sound)

/// Proc that just generates a custom header based on variables fed into `priority_announce()`
/// Will return a string.
/proc/generate_unique_announcement_header(title, sender_override, use_russian = FALSE)
	var/list/returnable_strings = list()
	if(isnull(sender_override))
		var/default_sender_text = use_russian ? "[command_name()] Обновление" : "[command_name()] Update"
		returnable_strings += MAJOR_ANNOUNCEMENT_TITLE(default_sender_text)
	else
		returnable_strings += MAJOR_ANNOUNCEMENT_TITLE(sender_override)

	if(length(title) > 0)
		returnable_strings += SUBHEADER_ANNOUNCEMENT_TITLE(title)

	return jointext(returnable_strings, "")

/// Proc that just dispatches the announcement to our applicable audience. Only the announcement is a mandatory arg.
/// `should_play_sound` can also be a callback, if you want to only play the sound to specific players.
/proc/dispatch_announcement_to_players(announcement, list/players = GLOB.player_list, sound_override = null, should_play_sound = TRUE)
	if(!sound_override)
		sound_override = SSstation.announcer.get_rand_alert_sound()
	else if(SSstation.announcer.event_sounds[sound_override])
		var/list/announcer_key = SSstation.announcer.event_sounds[sound_override]
		sound_override = pick(announcer_key)

	if(!isnull(sound_override))
		sound_override = sound(sound_override)

	var/sound_to_play = !isnull(sound_override) ? sound_override : 'sound/announcer/notice/notice2.ogg'
	var/datum/callback/should_play_sound_callback = astype(should_play_sound)
	var/list/audible_players = list()

	for(var/mob/target in players)
		if(isnewplayer(target) || HAS_TRAIT(target, TRAIT_DEAF))
			continue

		var/announcement_for_target = announcement
		if(islist(announcement))
			announcement_for_target = announcement[target]
			if(isnull(announcement_for_target))
				announcement_for_target = announcement["default"]
		if(isnull(announcement_for_target))
			continue

		to_chat(target, announcement_for_target)

		if(!should_play_sound)
			continue
		if(should_play_sound_callback && !should_play_sound_callback.Invoke(target))
			continue

		audible_players += target

	if(length(audible_players))
		alert_sound_to_playing(sound_to_play, players = audible_players)

#undef MAJOR_ANNOUNCEMENT_TITLE
#undef MAJOR_ANNOUNCEMENT_TEXT
#undef MINOR_ANNOUNCEMENT_TITLE
#undef MINOR_ANNOUNCEMENT_TEXT
#undef CHAT_ALERT_DEFAULT_SPAN
#undef CHAT_ALERT_COLORED_SPAN
