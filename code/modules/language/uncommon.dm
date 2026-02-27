/datum/language/uncommon
	name = "Neu-Deutsch"
	desc = "The second-most spoken Human language."
	key = "!"
	flags = TONGUELESS_SPEECH
	space_chance = 20
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 0
	syllables = list(
		"ach", "echt", "icht", "och", "uch",
		"sch", "schla", "schne", "schwar", "scho",
		"st", "ste", "sto", "stra", "stru",
		"br", "bra", "bre", "bro",
		"kr", "kra", "kre", "kro",
		"gr", "gra", "gre", "gro",
		"tr", "tra", "tre", "tro",
		"kl", "kla", "kle", "klo",
		"fl", "fla", "fle", "flo",
		"wald", "berg", "heim", "dorf",
		"mann", "stein", "feld", "burg",
		"hart", "reich", "blut", "nacht",
		"jä", "kön", "für", "wölf",
		"zorn", "eisen", "sturm", "licht"
	)
	icon_state = "galuncom"
	default_priority = 90

	mutual_understanding = list(
		/datum/language/common = 20,
		/datum/language/beachbum = 20,
	)
