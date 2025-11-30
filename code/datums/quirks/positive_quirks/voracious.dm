/datum/quirk/voracious
	name = "Voracious(Ненасытный)"
	desc = "Ничто не встанет на пути между тобой и едой. Вы едите быстрее. Полнота вам к лицу."
	icon = FA_ICON_DRUMSTICK_BITE
	value = 4
	mob_trait = TRAIT_VORACIOUS
	gain_text = span_notice("Вы чувствуете ГОЛОД.")
	lose_text = span_danger("Вы больше не чувствуете ГОЛОД.")
	medical_record_text = "Пациент испытывает выше среднего удовольствие от еды и питья."
	mail_goodies = list(/obj/effect/spawner/random/food_or_drink/dinner)
