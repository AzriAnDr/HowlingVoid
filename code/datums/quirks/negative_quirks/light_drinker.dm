/datum/quirk/light_drinker
	name = "Light Drinker(Легко напивающийся)"
	desc = "Ты просто не можешь контролировать употребление спиртного и очень быстро пьянеешь."
	icon = FA_ICON_COCKTAIL
	value = -2
	mob_trait = TRAIT_LIGHT_DRINKER
	gain_text = span_notice("Одна только мысль об употреблении алкоголя может вызвать головокружение.")
	lose_text = span_danger("Вы больше не подвержены сильному воздействию алкоголя.")
	medical_record_text = "У пациента низкая толерантность к алкоголю. (Слабак)"
	hardcore_value = 3
	mail_goodies = list(/obj/item/reagent_containers/cup/glass/waterbottle)
