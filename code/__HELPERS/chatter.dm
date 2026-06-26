/proc/chatter(message, phoneme, atom/speaker)
	// Transform a message into a list of word lengths and punctuation marks.
	// For example:
	// "Hi." -> [2, "."]
	// "HALP GEROGE MELLONS, that sentence, is GRIFFIN ME!"
	// -> [4, 6, 7, ",", 4, 8, ",", 2, 7, 2, "!"]
	// "thissentenceissquashed" -> [22]
	var/regex/word_and_punctuation = regex("(\[\\l\\d]*)(\[^\\l\\d\\s])?", "g")
	var/list/letter_count = list()
	while(word_and_punctuation.Find(message) != 0)
		if(word_and_punctuation.group[1])
			letter_count += length(word_and_punctuation.group[1])
		if(word_and_punctuation.group[2])
			letter_count += word_and_punctuation.group[2]
	chatter_speak(speaker, letter_count, phoneme)

/// Takes a list that dictates speech pace and plays a sentence fragment at that pace.
/proc/chatter_speak(atom/speaker, list/letter_count, phoneme, extra_delay = 0)
	var/static/list/punctuation = list(",", ":", ";", ".", "?", "!", "'", "-")
	var/delay = extra_delay
	for(var/i in 1 to length(letter_count))
		var/item = letter_count[i]
		if(item in punctuation)
			// Simulate pauses in speech. Semicolons are ignored because of their use in HTML escaping.
			if(item in list(",", ":"))
				delay += 0.3 SECONDS
			if(item in list("!", "?", "."))
				delay += 0.6 SECONDS
			continue

		if(!isnum(item))
			continue
		letter_count.Cut(1, i + 1)
		var/list/current_context = letter_count

		var/length = min(item, 10)
		if(length == 0)
			// Verbalise long spaces.
			delay += 0.1 SECONDS

		if(delay)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(chatter_speak_word), speaker, letter_count, phoneme, length), delay, flags = TIMER_CLIENT_TIME)
		else
			chatter_speak_word(speaker, current_context, phoneme, length)
		break // The loop handles punctuation; the actual looping operation happens in timers that call timers.

/proc/chatter_speak_word(atom/speaker, list/letter_count, phoneme, length)
	var/path = "sound/runtime/chatter/[phoneme]_[length].ogg"
	var/loc = speaker.loc
	playsound(loc, path, vol = 40, vary = 0, extrarange = 3)

	var/delay = (length + 1) * chatter_get_delay_multiplier(phoneme)
	chatter_speak(speaker, letter_count, phoneme, delay)

/proc/chatter_get_delay_multiplier(phoneme)
	. = 0.1 SECONDS
	switch(phoneme)
		if("papyrus")
			. = 0.05 SECONDS
		if("griffin")
			. = 0.05 SECONDS
		if("sans")
			. = 0.07 SECONDS
		if("owl")
			. = 0.07 SECONDS

