/datum/quirk/telepathic
	name = "Telepathic(Телепатия)"
	desc = "Вы способны передавать свои мысли другим живым существам."
	gain_text = span_purple("Ваш разум бурлит псионической энергией.")
	lose_text = span_notice("Обыденность вновь окутывает ваши мысли.")
	medical_record_text = "У пациента наблюдается необычно увеличенная область Брока, заметная при исследовании мозговой биологии; вероятно, способен к экстрасенсорной коммуникации."
	value = 2
	icon = FA_ICON_HEAD_SIDE_COUGH
	/// Ref used to easily retrieve the action used when removing the quirk from silicons
	var/datum/weakref/tele_action_ref

/datum/quirk/telepathic/add(client/client_source)
		var/datum/action/cooldown/spell/pointed/telepathy/tele_action = new

		tele_action.Grant(quirk_holder)
		tele_action_ref = WEAKREF(tele_action)

/datum/quirk/telepathic/remove()
	var/datum/action/cooldown/spell/pointed/telepathy/tele_action = tele_action_ref?.resolve()
	if (!isnull(tele_action))
		QDEL_NULL(tele_action)
	tele_action_ref = null
