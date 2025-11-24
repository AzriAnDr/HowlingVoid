/datum/quirk/alcohol_tolerance
	name = "Alcohol Tolerance(Толерантность к алкоголю)"
	desc = "Ты пьянеешь медленнее и испытываешь меньше неприятных последствий от алкоголя."
	icon = FA_ICON_BEER
	value = 4
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = span_notice("Такое чувство, будто ты мог бы выпить целую кегу!")
	lose_text = span_danger("Ты больше не чувствуешь сопротивления алкоголю. Каким-то образом.")
	medical_record_text = "Пациент демонстрирует высокую толерантность к алкоголю."
	mail_goodies = list(/obj/item/skillchip/wine_taster)
