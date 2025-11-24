/datum/quirk/illiterate
	name = "Illiterate(Неграмотный)"
	desc = "Ты бросил школу и не умеешь читать и писать. Это влияет на чтение, письмо, использование компьютеров и других электронных устройств."
	icon = FA_ICON_GRADUATION_CAP
	value = -8
	mob_trait = TRAIT_ILLITERATE
	medical_record_text = "Пациент неграмотный."
	hardcore_value = 8
	mail_goodies = list(/obj/item/pai_card) // can read things for you
