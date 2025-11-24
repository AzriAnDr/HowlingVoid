/datum/quirk/pushover
	name = "Pushover(Легко поддающийся влиянию)"
	desc = "Твой первый инстинкт — всегда позволять людям себя толкать. Уклоняться от захватов становится заметно сложнее."
	icon = FA_ICON_HANDSHAKE
	value = -8
	mob_trait = TRAIT_GRABWEAKNESS
	gain_text = span_danger("Чувствуешь себя слабаком.")
	lose_text = span_notice("Вам хочется постоять за себя.")
	medical_record_text = "Пациент демонстрирует крайне неуверенную личность и им легко манипулировать."
	hardcore_value = 4
	mail_goodies = list(/obj/item/clothing/gloves/cargo_gauntlet)
