/datum/quirk/light_step
	name = "Light Step(Лёгкая походка)"
	desc = "Ты ходишь плавно; шаги и наступания на острые предметы становятся тише и менее болезненными. Кроме того, руки и одежда не испачкаются, если наступить на кровь."
	icon = FA_ICON_SHOE_PRINTS
	value = 4
	mob_trait = TRAIT_LIGHT_STEP
	gain_text = span_notice("Ты чувствуешь себя лёгким на ногах.")
	lose_text = span_danger("Ты как варвар! Такой же громоздкий и неуклюжий!")
	medical_record_text = "Ловкость пациента скрывает его сильную способность к скрытности."
	mail_goodies = list(/obj/item/clothing/shoes/sandal)
