/datum/quirk/cursed
	name = "Cursed(Проклятие)"
	desc = "Ты проклят невезением. Ты гораздо чаще страдаете от несчастных случаев и неудач. Когда идёт дождь, он идёт как из ведра."
	icon = FA_ICON_CLOUD_SHOWERS_HEAVY
	value = -8
	mob_trait = TRAIT_CURSED
	gain_text = span_danger("Ты чувствуешь, что у тебя будет плохой день.")
	lose_text = span_notice("Ты чувствуешь, что тебя ждет хороший день.")
	medical_record_text = "Пациент нюня, плакса и верит, что его преследует черная полоса неудач."
	hardcore_value = 8

/datum/quirk/cursed/add(client/client_source)
	quirk_holder.AddComponent(/datum/component/omen/quirk)
