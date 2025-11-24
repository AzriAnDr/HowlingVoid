/datum/quirk/evil
	name = "Fundamentally Evil(Фундаментально злой)"
	desc = "Там, где у тебя должна быть душа, лишь чернильно-чёрная пустота. Пока ты стремишься сохранить свой социальный статус,, \
		Любой, кто слишком долго будет смотреть в твои холодные, равнодушные глаза, узнает правду. Ты — настоящее зло. Нет ничего... \
		С тобой что-то не так. Ты выбрал зло и посвятил себя ему. Твои амбиции превыше всего."
	icon = FA_ICON_HAND_MIDDLE_FINGER
	value = 0
	mob_trait = TRAIT_EVIL
	gain_text = span_notice("Ты отбрасываешь то немногое, что осталось от твоей человечности. Тебе ещё есть над чем работать.")
	lose_text = span_notice("Вы внезапно начинаете больше заботиться о других и их потребностях.")
	medical_record_text = "Пациент с блеском прошел все наши тесты на социальную пригодность, но у него возникли трудности с тестами на эмпатию."
	mail_goodies = list(/obj/item/food/grown/citrus/lemon)

/datum/quirk/evil/post_add()
	var/evil_policy = get_policy("[type]") || "Обратите внимание, что хотя вы и можете быть [LOWER_TEXT(name)], это НЕ дает вам никаких дополнительных прав нападать на людей или сеять хаос."
	// We shouldn't need this, but it prevents people using it as a dumb excuse in ahelps.
	to_chat(quirk_holder, span_big(span_info(evil_policy)))
