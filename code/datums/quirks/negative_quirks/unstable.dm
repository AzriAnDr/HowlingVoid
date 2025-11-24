/datum/quirk/unstable
	name = "Unstable(Нестабильный)"
	desc = "Из-за прошлых проблем ты не сможешь восстановить рассудок! Будь очень осторожен, управляя своим настроением!"
	icon = FA_ICON_ANGRY
	value = -10
	mob_trait = TRAIT_UNSTABLE
	gain_text = span_danger("Слищком много мыслей...")
	lose_text = span_notice("Твой разум успокоился.")
	medical_record_text = "Психика пациента находится в уязвимом состоянии и не может оправиться от травматических событий."
	hardcore_value = 9
	mail_goodies = list(/obj/effect/spawner/random/entertainment/plushie)
