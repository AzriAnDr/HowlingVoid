/datum/quirk/no_taste
	name = "Ageusia(Агеузия)"
	desc = "Ты ничего не почувствуешь! Токсичная еда всё равно отравит тебя."
	icon = FA_ICON_MEH_BLANK
	value = 0
	mob_trait = TRAIT_AGEUSIA
	gain_text = span_notice("Вы ничего не почувствуете!")
	lose_text = span_notice("Вы снова можете чувствовать вкус!")
	medical_record_text = "Пациент страдает агевзией и не способен ощущать вкус пищи или реагентов."
	mail_goodies = list(/obj/effect/spawner/random/food_or_drink/condiment) // but can you taste the salt? CAN YOU?!
