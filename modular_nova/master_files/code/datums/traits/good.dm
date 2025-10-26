// NOVA GOOD TRAITS

/datum/quirk/hard_soles
	name = "Закаленные ступни"
	desc = "Вы привыкли ходить босиком, и у вас не возникнет никаких негативных последствий от этого."
	value = 2
	mob_trait = TRAIT_HARD_SOLES
	gain_text = span_notice("Земля больше не кажется такой грубой для ваших ног.")
	lose_text = span_danger("Вы начинаете ощущать что вам неудобно ходить босиком.")
	medical_record_text = "Стопы пациента более устойчивы к натяжению."
	icon = FA_ICON_PERSON_RUNNING

/datum/quirk/linguist
	name = "Лингвист"
	desc = "Вы изучаете несколько языков и получаете дополнительный языковой балл."
	value = 0
	mob_trait = TRAIT_LINGUIST
	gain_text = span_notice("Кажется, ваш мозг более приспособлен к разговору сразу на нескольких языках.")
	lose_text = span_danger("Ваше понимание тонкостей драконьих идиом со временем исчезает.")
	medical_record_text = "Пациент демонстрирует повышенные способности к изучению языков."
	icon = FA_ICON_BOOK_ATLAS

/datum/quirk/sharpclaws
	name = "Острые Коготи"
	desc = "Будь то врожденная биология охотника или ваше упрямое нежелание стричь ногти перед занятиями по джиу-джитсу, ваши атаки без оружия более резкие и заставят людей истекать кровью."
	value = 2
	mob_trait = TRAIT_SHARP_CLAWS
	gain_text = span_notice("Ладони немного болят из-за острых ногтей.")
	lose_text = span_danger("Вы чувствуете отчетливую пустоту, когда ваши ногти становятся тусклыми; удачи вам в попытках унять зуд.")
	medical_record_text = "Пациент разодрал подушки смотрового стола; порекомендовал ему подстричь когти."
	icon = FA_ICON_LINES_LEANING

/datum/quirk/sharpclaws/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(!istype(human_holder))
		return FALSE

	var/obj/item/bodypart/arm/left/left_arm = human_holder.get_bodypart(BODY_ZONE_L_ARM)
	if(left_arm)
		left_arm.unarmed_attack_verbs = list("slash")
		left_arm.unarmed_attack_effect = ATTACK_EFFECT_CLAW
		left_arm.unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
		left_arm.unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
		left_arm.unarmed_sharpness = SHARP_EDGED

	var/obj/item/bodypart/arm/right/right_arm = human_holder.get_bodypart(BODY_ZONE_R_ARM)
	if(right_arm)
		right_arm.unarmed_attack_verbs = list("slash")
		right_arm.unarmed_attack_effect = ATTACK_EFFECT_CLAW
		right_arm.unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
		right_arm.unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
		right_arm.unarmed_sharpness = SHARP_EDGED

/datum/quirk/sharpclaws/remove(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/bodypart/arm/left/left_arm = human_holder.get_bodypart(BODY_ZONE_L_ARM)
	if(left_arm)
		left_arm.unarmed_attack_verbs = initial(left_arm.unarmed_attack_verbs)
		left_arm.unarmed_attack_effect = initial(left_arm.unarmed_attack_effect)
		left_arm.unarmed_attack_sound = initial(left_arm.unarmed_attack_sound)
		left_arm.unarmed_miss_sound = initial(left_arm.unarmed_miss_sound)
		left_arm.unarmed_sharpness = initial(left_arm.unarmed_sharpness)

	var/obj/item/bodypart/arm/right/right_arm = human_holder.get_bodypart(BODY_ZONE_R_ARM)
	if(right_arm)
		right_arm.unarmed_attack_verbs = initial(right_arm.unarmed_attack_verbs)
		right_arm.unarmed_attack_effect = initial(right_arm.unarmed_attack_effect)
		right_arm.unarmed_attack_sound = initial(right_arm.unarmed_attack_sound)
		right_arm.unarmed_miss_sound = initial(right_arm.unarmed_miss_sound)
		right_arm.unarmed_sharpness = initial(right_arm.unarmed_sharpness)

// AdditionalEmotes *turf quirks
/datum/quirk/water_aspect
	name = "Аквоид (Эмоуты)"
	desc = "Ваш дом - глубина. Космос оказался очень похожим. (*turf, чтобы кастануть)"
	value = 0
	mob_trait = TRAIT_WATER_ASPECT
	gain_text = span_notice("Вы чувствуете, что вы как рыба в воде!")
	lose_text = span_danger("Вы теперь как человек в воде...")
	medical_record_text = "Пациент - водное создание."
	icon = FA_ICON_WATER

/datum/quirk/webbing_aspect
	name = "Ткаческий талант (Эмоуты)"
	desc = "(Врождённая способность насекомых) У вас есть возможности ткать благодаря паутине (*turf, чтобы кастануть)"
	value = 0
	mob_trait = TRAIT_WEBBING_ASPECT
	gain_text = span_notice("Вы легко могли бы сплести паутину.")
	lose_text = span_danger("Каким-то образом ты утратила способность ткать.")
	medical_record_text = "Пациент обладает способностью плести паутину из синтезированного естественным образом шелка."
	icon = FA_ICON_STICKY_NOTE

/datum/quirk/floral_aspect
	name = "Черты растения (Эмоуты)"
	desc = "(Врождённый Подперсон) Исследования Кудзу не бесполезны, технология быстрого фотосинтеза уже здесь! (*turf,)"
	value = 0
	mob_trait = TRAIT_FLORAL_ASPECT
	gain_text = span_notice("Вы ощущаете как из вас проростают лозы.")
	lose_text = span_danger("Somehow, you've lost your ability to rapidly photosynthesize.")
	medical_record_text = "Patient can rapidly photosynthesize to grow vines."
	icon = FA_ICON_PLANT_WILT

/datum/quirk/ash_aspect
	name = "Житель пустошей (Эмоуты)"
	desc = "(Врожденная способность ящеров) Вам подвластна сила с которой вы можете дышать огнём, оставляя за собой лишь пепел. Жаль что такая способность годится только в театральных постановках... (*turf чтобы кастануть)"
	value = 0
	mob_trait = TRAIT_ASH_ASPECT
	gain_text = span_notice("Внутри тебя тлеет кузница.")
	lose_text = span_danger("Каким-то образом ты утратил способность дышать огнем.")
	medical_record_text = "У пациентов имеется огнедышащая железа, обычно встречающаяся у ящерообразных."
	icon = FA_ICON_FIRE

/datum/quirk/sparkle_aspect
	name = "ЛА-А-АМПОЧКА (Эмоуты)"
	desc = "(Врожденный дар мотылька) Сверкают, как пыльные крылышки мотылька, или как дешевая зажигалка. (*turf чтобы  кастануть)"
	value = 0
	mob_trait = TRAIT_SPARKLE_ASPECT
	gain_text = span_notice("Ты весь в блестящей пыли!")
	lose_text = span_danger("Каким-то образом ты полностью очистилась от блесток..")
	medical_record_text = "Пациент, кажется, выглядит потрясающе."
	icon = FA_ICON_HAND_SPARKLES

/datum/quirk/no_appendix
	name = "Переживший аппендицит"
	desc = "В прошлом у вас был аппендицит, и теперь у вас его нет."
	icon = FA_ICON_NOTES_MEDICAL
	value = 2
	gain_text = span_notice("У вас больше нет аппендикса.")
	lose_text = span_danger("Ваш аппендикс чудесным образом... вырос заново?")
	medical_record_text = "У пациента в прошлом был аппендицит, и ему удалили аппендикс хирургическим путем."
	/// The mob's original appendix
	var/obj/item/organ/appendix/old_appendix

/datum/quirk/no_appendix/post_add()
	var/mob/living/carbon/carbon_quirk_holder = quirk_holder
	old_appendix = carbon_quirk_holder.get_organ_slot(ORGAN_SLOT_APPENDIX)

	if(isnull(old_appendix))
		return

	old_appendix.Remove(carbon_quirk_holder, special = TRUE)
	old_appendix.moveToNullspace()

	STOP_PROCESSING(SSobj, old_appendix)

/datum/quirk/no_appendix/remove()
	var/mob/living/carbon/carbon_quirk_holder = quirk_holder

	if(isnull(old_appendix))
		return

	var/obj/item/organ/appendix/current_appendix = carbon_quirk_holder.get_organ_slot(ORGAN_SLOT_APPENDIX)

	// if we have not gained an appendix already, put the old one back
	if(isnull(current_appendix))
		old_appendix.Insert(carbon_quirk_holder, special = TRUE)
	else
		qdel(old_appendix)

	old_appendix = null

/datum/quirk/sensitive_hearing // Teshari hearing but as a quirk
	name = "Чувствительный слух"
	desc = "Вы можете слышать даже самые тихие звуки, но из-за этого повышается риск повреждения слуха."
	icon = FA_ICON_HEADPHONES_SIMPLE
	value = 6
	hidden_quirk = FALSE // disabled until reworked.
	mob_trait = TRAIT_SENSITIVE_HEARING
	gain_text = span_notice("Падение булавки можно услышать на расстоянии 10 метров.")
	lose_text = span_danger("Ваш слух становится менее чувствительным.")
	medical_record_text = "Пациент показал очень высокие результаты при проверке слуха."
	/// Teshari hearing is an action, so here is its holder
	var/datum/action/cooldown/spell/teshari_hearing/hearing_action

/datum/quirk/sensitive_hearing/add_unique()
	var/obj/item/organ/ears/ears = quirk_holder.get_organ_slot(ORGAN_SLOT_EARS)

	hearing_action = new
	LAZYADD(ears.actions_types, hearing_action.type)
	ears.add_item_action(hearing_action)
	hearing_action.Grant(quirk_holder)

/datum/quirk/sensitive_hearing/remove()
	if(QDELING(quirk_holder))
		return
	var/obj/item/organ/ears/ears = quirk_holder.get_organ_slot(ORGAN_SLOT_EARS)
	if(isnull(ears))
		return

	LAZYREMOVE(ears.actions_types, hearing_action.type)
	ears.remove_item_action(hearing_action)
	hearing_action.Remove(quirk_holder)
	//restore dmg multiplier of our current ears
	//we could have any subtype at this point so just take that one's initial value
	//as opposed to making a copy at the start of the player's round (what if they transplant it, etc)
	ears.damage_multiplier = initial(ears.damage_multiplier)
