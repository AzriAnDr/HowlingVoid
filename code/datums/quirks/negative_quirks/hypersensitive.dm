/datum/quirk/hypersensitive
	name = "Hypersensitive(Гиперчувствительный)"
	desc = "Хорошо это или плохо, но, похоже, все вокруг влияет на настроение больше, чем следовало бы."
	icon = FA_ICON_FLUSHED
	value = -2
	gain_text = span_danger("Кажется что ты всё делаешь из мухи слона...")
	lose_text = span_notice("Ты снова чувствуешь себя нормально.")
	medical_record_text = "У пациента наблюдается высокая степень эмоциональной неустойчивости."
	hardcore_value = 3
	mail_goodies = list(/obj/effect/spawner/random/entertainment/plushie_delux)

/datum/quirk/hypersensitive/add(client/client_source)
	if (quirk_holder.mob_mood)
		quirk_holder.mob_mood.mood_modifier += 0.5

/datum/quirk/hypersensitive/remove()
	if (quirk_holder.mob_mood)
		quirk_holder.mob_mood.mood_modifier -= 0.5
