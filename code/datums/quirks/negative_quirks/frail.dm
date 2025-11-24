/datum/quirk/frail
	name = "Frail(Хрупкий)"
	desc = "Твоя кожа как бумага, а кости как стекло. Ты склонен к травмам и легко получаешь повреждения."
	icon = FA_ICON_SKULL
	value = -6
	mob_trait = TRAIT_EASILY_WOUNDED
	gain_text = span_danger("Ты хрупок.")
	lose_text = span_notice("Ты крепчаешь.")
	medical_record_text = "Пациенту невероятно легко нанести травму. Пожалуйста, проявите всю необходимую осмотрительность, чтобы избежать возможных исков о врачебной халатности."
	hardcore_value = 4
	mail_goodies = list(/obj/effect/spawner/random/medical/minor_healing)
