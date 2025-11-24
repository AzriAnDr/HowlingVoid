/datum/quirk/mute
	name = "Mute(Немота)"
	desc = "По какой-то причине ты совершенно не способен говорить."
	icon = FA_ICON_VOLUME_XMARK
	value = -4
	mob_trait = TRAIT_MUTE
	gain_text = span_danger("Ты не можешь говорить!")
	lose_text = span_notice("Ты чувствуешь растущую силу своих голосовых связок.")
	medical_record_text = "Пациент не способен использовать свой голос в какой-либо форме."
	hardcore_value = 4
