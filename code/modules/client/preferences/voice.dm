/// TTS voice preference
/datum/preference/choiced/voice
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tts_voice"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	should_update_preview = FALSE

/datum/preference/choiced/voice/is_accessible(datum/preferences/preferences)
	if(!SStts.tts_enabled)
		return FALSE
	return ..()

/datum/preference/choiced/voice/init_possible_values()
	if(SStts.tts_enabled)
		return SStts.available_speakers
	if(fexists("data/cached_tts_voices.json"))
		var/list/text_data = rustg_file_read("data/cached_tts_voices.json")
		var/list/cached_data = json_decode(text_data)
		if(!cached_data)
			return list("invalid")
		return cached_data
	return list("invalid")

/datum/preference/choiced/voice/apply_to_human(mob/living/carbon/human/target, value)
	if(SStts.tts_enabled && !(value in SStts.available_speakers))
		value = pick(SStts.available_speakers) // As a failsafe
	target.voice = value

/datum/preference/numeric/tts_voice_pitch
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tts_voice_pitch"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	minimum = -12
	maximum = 12
	should_update_preview = FALSE

/datum/preference/numeric/tts_voice_pitch/is_accessible(datum/preferences/preferences)
	if(!SStts.tts_enabled || !SStts.pitch_enabled)
		return FALSE
	return ..()

/datum/preference/numeric/tts_voice_pitch/create_default_value()
	return 0

/datum/preference/numeric/tts_voice_pitch/apply_to_human(mob/living/carbon/human/target, value)
	if(SStts.tts_enabled && SStts.pitch_enabled)
		target.pitch = value


// BEGIN NOVA CORE MIGRATION: code/modules/client/preferences/voice.dm

/datum/preference/choiced/voice
	category = PREFERENCE_CATEGORY_VOCALS // Originally PREFERENCE_CATEGORY_NON_CONTEXTUAL, we are relocating it to the voice menu

/datum/preference/choiced/voice/is_accessible(datum/preferences/preferences)
	var/voice_type_pref = preferences.read_preference(/datum/preference/choiced/vocals/voice_type)
	if(voice_type_pref != VOICE_TYPE_TTS)
		return FALSE

	return ..(preferences)

/datum/preference/choiced/voice/init_possible_values()
	if(SStts.tts_enabled)
		return list(TTS_VOICE_NONE) + SStts.available_speakers

	if(fexists("data/cached_tts_voices.json"))
		var/list/text_data = rustg_file_read("data/cached_tts_voices.json")
		var/list/cached_data = json_decode(text_data)
		if(!cached_data)
			return list("invalid")

		return list(TTS_VOICE_NONE) + cached_data

	return list("invalid")

/datum/preference/choiced/voice/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	if(preferences.read_preference(/datum/preference/choiced/vocals/voice_type) != VOICE_TYPE_TTS)
		target.voice = TTS_VOICE_NONE
		return
	if(SStts.tts_enabled && !(value in cached_values))
		value = pick(SStts.available_speakers) // As a failsafe

	target.voice = value == TTS_VOICE_NONE ? "" : value

//#undef TTS_VOICE_NONE - NOVA EDIT REMOVAL - Used by silicon login after preferences compile.
// END NOVA CORE MIGRATION: code/modules/client/preferences/voice.dm
