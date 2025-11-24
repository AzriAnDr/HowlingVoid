/datum/quirk/strong_stomach
	name = "Strong Stomach(Крепкий желудок)"
	desc = "Ты можешь есть пищу, выброшенную на землю, не боясь заболеть."
	icon = FA_ICON_FACE_GRIN_BEAM_SWEAT
	value = 4
	mob_trait = TRAIT_STRONG_STOMACH
	gain_text = span_notice("Возникает ощущение, что вы могли бы съесть все, что угодно!")
	lose_text = span_danger("Глядя на еду, лежащую на земле, становится немного не по себе.")
	medical_record_text = "У пациента более сильная, чем обычно, иммунная система... к пищевым отравлениям, по крайней мере..."
	mail_goodies = list(
		/obj/item/reagent_containers/applicator/pill/ondansetron,
	)
