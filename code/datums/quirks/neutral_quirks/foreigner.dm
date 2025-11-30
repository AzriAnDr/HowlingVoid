/datum/quirk/foreigner
	name = "Foreigner(Иностранец)"
	desc = "Ты не местный. Ты не знаешь Сол!"
	icon = FA_ICON_LANGUAGE
	value = 0
	gain_text = span_notice("Слова, которые произносятся вокруг вас, не имеют никакого смысла.")
	lose_text = span_notice("Вы освоили Сол.")
	medical_record_text = "Пациент не говорит на Соле и может нуждаться в переводчике. Почему это диагноз?"
	mail_goodies = list(/obj/item/taperecorder) // for translation

/datum/quirk/foreigner/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.add_blocked_language(/datum/language/common)
	if(ishumanbasic(human_holder))
		human_holder.grant_language(/datum/language/uncommon, source = LANGUAGE_QUIRK)

/datum/quirk/foreigner/remove()
	if(QDELETED(quirk_holder))
		return
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.remove_blocked_language(/datum/language/common)
	if(ishumanbasic(human_holder))
		human_holder.remove_language(/datum/language/uncommon)
