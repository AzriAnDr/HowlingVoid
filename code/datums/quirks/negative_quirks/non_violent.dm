/datum/quirk/nonviolent
	name = "Pacifist(Пацифист)"
	desc = "Мысль о насилии вызывает тошноту. Настолько, что ты не можешь причинить вреда никому."
	icon = FA_ICON_PEACE
	value = -8
	mob_trait = TRAIT_PACIFISM
	gain_text = span_danger("Мысль о насилии вызывает у тебя отвращение!")
	lose_text = span_notice("Ты больше не хочешь быть активистом против насилия.")
	medical_record_text = "Пациент необычайно пацифичен и не может заставить себя причинить физический вред."
	hardcore_value = 6
	mail_goodies = list(/obj/effect/spawner/random/decoration/flower, /obj/effect/spawner/random/contraband/cannabis) // flower power
