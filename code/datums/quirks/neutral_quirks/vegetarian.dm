/datum/quirk/vegetarian
	name = "Vegetarian(Вегетарианец)"
	desc = "Ты считаешь идею употребления мяса в пищу отвратительной с моральной и физической точки зрения."
	icon = FA_ICON_CARROT
	value = 0
	gain_text = span_notice("Ты чувствуешь отвращение к идее употребления мяса.")
	lose_text = span_notice("Ты чувствуешь, что есть мясо не так уж и плохо.")
	medical_record_text = "Пациент сообщает о вегетарианской диете."
	mail_goodies = list(/obj/effect/spawner/random/food_or_drink/salad)
	mob_trait = TRAIT_VEGETARIAN
