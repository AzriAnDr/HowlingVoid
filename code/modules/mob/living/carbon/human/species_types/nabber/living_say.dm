/proc/apply_species_hear_language_overrides(mob/living/listener, atom/movable/speaker, datum/language/message_language, raw_message, list/spans, list/message_mods)
	if(ispath(message_language, /datum/language/nabber) && speaker != listener)
		var/gbs_translation_check = listener.translate_language(speaker, message_language, raw_message, spans, message_mods)
		if(raw_message != gbs_translation_check)
			message_mods[MODE_CUSTOM_SAY_EMOTE] = gbs_translation_check
			message_mods[MODE_CUSTOM_SAY_ERASE_INPUT] = TRUE

	if(ispath(message_language, /datum/language/nabber) && isnabber(listener))
		message_mods[MODE_CUSTOM_SAY_EMOTE] = null
		message_mods[MODE_CUSTOM_SAY_ERASE_INPUT] = FALSE
