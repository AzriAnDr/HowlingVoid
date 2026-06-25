/// Turns :emoji_name: sequences into chat emoji tags.
/proc/emoji_parse(text)
	if(!text)
		return text
	. = text
	if(!CONFIG_GET(flag/emojis))
		return
	var/static/list/emojis = icon_states(icon(EMOJI_SET))
	var/parsed = ""
	var/pos = 1
	var/search = 0
	var/emoji = ""
	while(1)
		search = findtext(text, ":", pos)
		parsed += copytext(text, pos, search)
		if(search)
			pos = search
			search = findtext(text, ":", pos + length(text[pos]))
			if(search)
				emoji = LOWER_TEXT(copytext(text, pos + length(text[pos]), search))
				var/datum/asset/spritesheet_batched/sheet = get_asset_datum(/datum/asset/spritesheet_batched/chat)
				var/tag = sheet.icon_tag("emoji-[emoji]")
				if(tag)
					parsed += tag
					pos = search + length(text[pos])
				else
					parsed += copytext(text, pos, search)
					pos = search
				emoji = ""
				continue
			else
				parsed += copytext(text, pos, search)
		break
	return parsed

/// Cuts any text that would not be parsed as an emoji.
/proc/emoji_sanitize(text)
	. = text
	if(!CONFIG_GET(flag/emojis))
		return
	var/static/list/emojis = icon_states(icon(EMOJI_SET))
	var/final = ""
	var/pos = 1
	var/search = 0
	while(1)
		search = findtext(text, ":", pos)
		if(search)
			pos = search
			search = findtext(text, ":", pos + length(text[pos]))
			if(search)
				var/word = LOWER_TEXT(copytext(text, pos + length(text[pos]), search))
				if(word in emojis)
					final += LOWER_TEXT(copytext(text, pos, search + length(text[search])))
				pos = search + length(text[search])
				continue
		break
	return final

