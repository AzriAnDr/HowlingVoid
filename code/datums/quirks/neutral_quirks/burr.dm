/datum/quirk/burr
	name = "Rhotacism"
	desc = "You have trouble pronouncing the letter R."
	icon = FA_ICON_SPELL_CHECK
	value = 0
	gain_text = span_danger("Pronouncing R suddenly feels difficult.")
	lose_text = span_notice("You can pronounce R clearly again.")
	medical_record_text = "Patient has trouble pronouncing the letter R."
	hardcore_value = 0

/datum/quirk/burr/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/quirk/burr/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_SAY)

/datum/quirk/burr/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(HAS_TRAIT(source, TRAIT_SIGN_LANG))
		return

	var/message = speech_args[SPEECH_MESSAGE]
	if(!message || message[1] == "*")
		return

	var/static/regex/latin_r_regex = new(@"[rR]+", "g")
	var/static/regex/cyrillic_r_regex = new(@"[рР]+", "g")
	var/static/list/latin_r_replacements = list("h'", "gh'", "g'h", "g'", "h", "gh", "g", "r'", "h")
	var/static/list/cyrillic_r_replacements = list("х'", "гх'", "г'х", "г'", "х", "гх", "г", "р'", "х")

	var/list/message_split = splittext_char(message, " ")
	var/list/new_message = list()
	for(var/word in message_split)
		word = replacetext_char(word, latin_r_regex, pick(latin_r_replacements))
		word = replacetext_char(word, cyrillic_r_regex, pick(cyrillic_r_replacements))
		new_message += word

	speech_args[SPEECH_MESSAGE] = jointext(new_message, " ")
