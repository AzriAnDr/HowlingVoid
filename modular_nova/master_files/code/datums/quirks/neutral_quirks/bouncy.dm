/datum/quirk/bouncy
	name = "Bouncy!(Прыгающий)"
	desc = "Ты ходишь как в южном парке."
	gain_text = span_notice("Ты прыгаешь!")
	lose_text = span_notice("Вы потеряли бодрость в своих шагах...")
	medical_record_text = "Пациент ходит нетипично."
	value = 0
	icon = FA_ICON_TURN_UP

/datum/quirk/bouncy/add(client/client_source)
	quirk_holder.AddElementTrait(TRAIT_WADDLING, QUIRK_TRAIT, /datum/element/waddling)

/datum/quirk/bouncy/remove()
	REMOVE_TRAIT(quirk_holder, TRAIT_WADDLING, QUIRK_TRAIT)
