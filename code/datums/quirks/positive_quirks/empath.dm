/datum/quirk/empath
	name = "Empath(Эмпат)"
	desc = "Будь то шестое чувство или тщательное изучение языка тела, тебе достаточно одного быстрого взгляда на человека, чтобы понять, что он чувствует."
	icon = FA_ICON_SMILE_BEAM
	value = 8
	gain_text = span_notice("Вы чувствуете гармонию с окружающими.")
	lose_text = span_danger("Вы чувствуете себя изолированным от других.")
	medical_record_text = "Пациент крайне восприимчив и чувствителен к социальным сигналам, возможно, страдает экстрасенсорным восприятием. Необходимы дальнейшие исследования."
	mail_goodies = list(/obj/item/toy/foamfinger)

/datum/quirk/empath/add(client/client_source)
	quirk_holder.AddComponentFrom(REF(src), /datum/component/empathy)

/datum/quirk/empath/remove(client/client_source)
	quirk_holder.RemoveComponentSource(REF(src), /datum/component/empathy)
