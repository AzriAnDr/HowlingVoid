/datum/quirk/heavyset
	name = "Heavyset(Тяжеловес)"
	desc = "Вы весите значительно больше, чем большинство людей. Вам сложнее передвигаться, а другим людям сложнее вас переносить."
	icon = FA_ICON_WEIGHT_HANGING
	value = 0
	gain_text = span_notice("Тебе тяжело.")
	lose_text = span_notice("Тебе легко.")
	medical_record_text = "Пациент имеет вес значительно выше среднего."

	mob_trait = TRAIT_HEAVYSET

/datum/movespeed_modifier/heavyset
	multiplicative_slowdown = 0.3
	blacklisted_movetypes = FLOATING|FLYING

/datum/quirk/heavyset/add(client/client_source)
	ADD_TRAIT(quirk_holder, TRAIT_NO_SLIP_SLIDE, QUIRK_TRAIT)
	quirk_holder.add_movespeed_modifier(/datum/movespeed_modifier/heavyset)

/datum/quirk/heavyset/remove()
	REMOVE_TRAIT(quirk_holder, TRAIT_NO_SLIP_SLIDE, QUIRK_TRAIT)
	quirk_holder.remove_movespeed_modifier(/datum/movespeed_modifier/heavyset)
