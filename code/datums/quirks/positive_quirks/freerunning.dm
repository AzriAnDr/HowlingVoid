/datum/quirk/freerunning
	name = "Freerunning(Паркурист)"
	desc = "Ты быстрее забираешься на столы и не получаешь урон от падений с небольшой высоты."
	icon = FA_ICON_RUNNING
	value = 8
	mob_trait = TRAIT_FREERUNNING
	gain_text = span_notice("Ты чувствуешь себя лёгким на подъём.")
	lose_text = span_danger("Вы снова чувствуете себя неуклюжим.")
	medical_record_text = "Пациент показал высокие результаты по кардиотестам."
	mail_goodies = list(/obj/item/melee/skateboard, /obj/item/clothing/shoes/wheelys/rollerskates)
