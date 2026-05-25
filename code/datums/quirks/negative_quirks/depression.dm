/datum/quirk/depression
	name = "Depression"
	desc = "You sometimes just hate life."
	icon = FA_ICON_FROWN
	value = -3
	gain_text = span_danger("You start feeling depressed.")
	lose_text = span_notice("You no longer feel depressed.") //if only it were that easy!
	medical_record_text = "Patient has a mild mood disorder causing them to experience acute episodes of depression."
	medical_symptom_text = "Experiences persistent feelings of sadness, hopelessness, and a lack of motivation."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED|QUIRK_PROCESSES|QUIRK_TRAUMALIKE
	hardcore_value = 2
	mail_goodies = list(/obj/item/storage/pill_bottle/happinesspsych)

/datum/quirk/depression/process(seconds_per_tick)
	// 0.416% is 15 successes / 3600 seconds. Calculated with 2 minute
	// mood runtime, so 50% average uptime across the hour.
	if(SPT_PROB(0.416, seconds_per_tick))
		quirk_holder.add_mood_event("depression", /datum/mood_event/depression)

/datum/quirk/depression/remove()
	quirk_holder.clear_mood_event("depression")


// BEGIN NOVA CORE MIGRATION: code/datums/quirks/negative_quirks/depression.dm
/datum/quirk/depression/add()
	. = ..()
	if(issynthetic(quirk_holder))
		mail_goodies = list(/obj/item/storage/box/flat/neuroware/happiness)
	else
		mail_goodies = initial(mail_goodies)

/datum/quirk/depression/add_unique(client/client_source)
	var/depression_medication = /obj/item/storage/pill_bottle/happinesspsych
	if(issynthetic(quirk_holder))
		depression_medication = /obj/item/storage/box/flat/neuroware/happiness
	give_item_to_holder_nova(
		depression_medication,
		list(
			LOCATION_LPOCKET,
			LOCATION_RPOCKET,
			LOCATION_BACKPACK,
			LOCATION_HANDS,
		),
		flavour_text = "These will keep your mood stable until you can secure a supply of medication.",
		notify_player = TRUE,
	)
// END NOVA CORE MIGRATION: code/datums/quirks/negative_quirks/depression.dm
