/datum/quirk/throwingarm
	name = "Throwing Arm(Бросающая рука)"
	desc = "У тебя такие тяжёлые руки! Кажется, что брошенные тобой предметы всегда летят дальше, чем у всех остальных, и ты никогда не промахиваешься."
	icon = FA_ICON_BASEBALL
	value = 7
	mob_trait = TRAIT_THROWINGARM
	gain_text = span_notice("Твои руки полны энергии!")
	lose_text = span_danger("У тебя немного болят руки.")
	medical_record_text = "Пациент демонстрирует мастерство в бросании мячей."
	mail_goodies = list(/obj/item/toy/beach_ball/baseball, /obj/item/toy/basketball, /obj/item/toy/dodgeball)
