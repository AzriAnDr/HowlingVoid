// re-adds heavy sleeper
/datum/quirk/heavy_sleeper
	name = "Heavy Sleeper(Крепко спящий)"
	desc = "Вы спите как убитый! Когда вас усыпляют или вы теряете сознание, пробуждение занимает немного больше времени."
	icon = FA_ICON_CLOUD_MOON_RAIN
	value = -2
	mob_trait = TRAIT_HEAVY_SLEEPER
	gain_text = span_danger("Вы чувствуете сонливость.")
	lose_text = span_notice("Вы снова чувствуете бодрость.")
	medical_record_text = "Пациент демонстрирует отклонения в исследованиях сна и с трудом просыпается."
	hardcore_value = 2
	mail_goodies = list(
		/obj/item/clothing/glasses/blindfold,
		/obj/effect/spawner/random/bedsheet/any,
		/obj/item/clothing/under/misc/pj/red,
		/obj/item/clothing/head/costume/nightcap/red,
		/obj/item/clothing/under/misc/pj/blue,
		/obj/item/clothing/head/costume/nightcap/blue,
		/obj/item/pillow/random,
	)
