/datum/quirk/masquerade_food
	name = "Masquerade(Маскарад)"
	desc = "Гемофаг, приспособившийся к употреблению обычной пищи и напитков. Этот процесс доставляет лишь удовольствие — никакой питательной ценности для них он не имеет."
	gain_text = span_notice("Вы чувствуете, что ваше тело приспособилось к употреблению обычной еды и питья без добавления крови.")
	lose_text = span_danger("Вы чувствуете, что ваше тело больше не способно потреблять обычную пищу или напитки без примеси крови.")
	medical_record_text = "Пациент способен употреблять обычную пищу и напитки без необходимости добавлять кровь, хотя не получает от этого питательной ценности."
	value = 2
	mob_trait = TRAIT_MASQUERADE_FOOD
	icon = FA_ICON_MASK
	quirk_flags = QUIRK_HUMAN_ONLY


/datum/quirk/masquerade_food/is_species_appropriate(datum/species/mob_species)
	var/datum/species_traits = GLOB.species_prototypes[mob_species].inherent_traits
	if(TRAIT_DRINKS_BLOOD in species_traits)
		return TRUE
	else
		return FALSE
