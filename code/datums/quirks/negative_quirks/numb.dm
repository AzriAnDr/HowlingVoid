/datum/quirk/numb
	name = "Numb(Онемение)"
	desc = "Боли вы вообще не почувствуете."
	icon = FA_ICON_STAR_OF_LIFE
	value = -4
	gain_text = "Вы чувствуете, как ваше тело немеет."
	lose_text = "Онемение отступает."
	medical_record_text = "У пациента наблюдается врожденная гипестезия, делающая его нечувствительным к болевым раздражителям."
	hardcore_value = 4

/datum/quirk/numb/add(client/client_source)
	quirk_holder.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
	quirk_holder.add_traits(list(TRAIT_ANALGESIA, TRAIT_NO_DAMAGE_OVERLAY), QUIRK_TRAIT)

/datum/quirk/numb/remove(client/client_source)
	quirk_holder.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
	quirk_holder.remove_traits(list(TRAIT_ANALGESIA, TRAIT_NO_DAMAGE_OVERLAY), QUIRK_TRAIT)
