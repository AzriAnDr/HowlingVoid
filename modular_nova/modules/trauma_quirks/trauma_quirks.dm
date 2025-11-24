/datum/quirk/possessive
	name = "Possessive(Обладательный)"
	desc = "Вы чувствуете сильную привязанность к любой вещи, которой владеете; часто вам кажется, что вы не можете ее бросить."
	value = 0
	gain_text = span_danger("Вам кажется, что все, что у вас есть, слишком ценно, чтобы его выбросить.")
	lose_text = span_notice("Внезапно вы чувствуете, что ваши вещи больше не так уж и важны.")
	medical_record_text = "Субъект проявляет собственническую тенденцию по отношению к объектам."
	icon = FA_ICON_HANDS_HOLDING

/datum/quirk/possessive/post_add()
	. = ..()
	var/mob/living/carbon/human/affected_human = quirk_holder
	affected_human.gain_trauma(/datum/brain_trauma/mild/possessive, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/possessive/remove()
	. = ..()
	var/mob/living/carbon/human/affected_human = quirk_holder
	affected_human?.cure_trauma_type(/datum/brain_trauma/mild/possessive, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/kleptomaniac
	name = "Kleptomaniac(Клептоманьяк)"
	desc = "Вы чувствуете сильное желание поднять что-нибудь, часто не осознавая этого."
	value = 0
	gain_text = span_danger("Вы чувствуете внезапное желание что-то взять. Никто, конечно, не заметит.")
	lose_text = span_notice("Вы больше не чувствуете желания брать вещи.")
	medical_record_text = "У субъекта наблюдается клептомания."
	icon = FA_ICON_HAND_HOLDING

/datum/quirk/kleptomaniac/post_add()
	. = ..()
	var/mob/living/carbon/human/affected_human = quirk_holder
	affected_human.gain_trauma(/datum/brain_trauma/severe/kleptomaniac, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/kleptomaniac/remove()
	. = ..()
	var/mob/living/carbon/human/affected_human = quirk_holder
	affected_human?.cure_trauma_type(/datum/brain_trauma/severe/kleptomaniac, TRAUMA_RESILIENCE_ABSOLUTE)
