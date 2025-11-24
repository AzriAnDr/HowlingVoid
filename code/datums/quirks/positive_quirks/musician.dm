/datum/quirk/item_quirk/musician
	name = "Musician(Музыкант)"
	desc = "Вы знаете всё о музыкальных инструментах. Ваша музыка способна поднять настроение окружающим."
	icon = FA_ICON_GUITAR
	value = 2
	mob_trait = TRAIT_MUSICIAN
	gain_text = span_notice("Вы знаете все о музыкальных инструментах.")
	lose_text = span_danger("Вы забываете, как работают музыкальные инструменты.")
	medical_record_text = "Сканирование мозга пациента показывает высокоразвитый слух."
	mail_goodies = list(/obj/effect/spawner/random/entertainment/musical_instrument, /obj/item/instrument/piano_synth/headphones)

/datum/quirk/item_quirk/musician/add_unique(client/client_source)
	give_item_to_holder(/obj/item/choice_beacon/music, list(LOCATION_BACKPACK, LOCATION_HANDS))
