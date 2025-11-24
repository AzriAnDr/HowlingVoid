/datum/quirk/robot_limb_detach
	name = "Cybernetic Limb Mount(Кибернетическое крепление конечностей)"
	desc = "Вы можете отсоединять и снова прикреплять любые установленные роботизированные конечности с минимальными усилиями, если они находятся в хорошем состоянии."
	gain_text = span_notice("Внутренние датчики сообщают, что протоколы отсоединения конечностей готовы и ждут.")
	lose_text = span_notice("ОШИБКА: ПРОТОКОЛЫ ОТКЛЮЧЕНИЯ КОНЕЧНОСТЕЙ ОТКЛЮЧЕНЫ.")
	medical_record_text = "Кибернетика суставов конечностей пациента с быстросъемными и съемными протезами."
	value = 0
	mob_trait = TRAIT_ROBOTIC_LIMBATTACHMENT
	icon = FA_ICON_HANDSHAKE_SIMPLE_SLASH
	quirk_flags = QUIRK_HUMAN_ONLY
	/// The action we add with this quirk in add(), used for easy deletion later
	var/datum/action/cooldown/spell/added_action

/datum/quirk/robot_limb_detach/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/datum/action/cooldown/spell/robot_self_amputation/limb_action = new /datum/action/cooldown/spell/robot_self_amputation()
	limb_action.Grant(human_holder)
	added_action = limb_action

/datum/quirk/robot_limb_detach/remove()
	QDEL_NULL(added_action)

/datum/action/cooldown/spell/robot_self_amputation
	name = "Отделить роботизированную конечность"
	desc = "Отсоедините одну из ваших роботизированных конечностей от кибернетических устройств. Не допускайте, чтобы вас удерживали или принуждали к чему-либо. Не действует на раненых конечностях — сначала обработайте их."
	button_icon_state = "autotomy"

	cooldown_time = 30 SECONDS
	spell_requirements = NONE
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_INCAPACITATED

/datum/action/cooldown/spell/robot_self_amputation/is_valid_target(atom/cast_on)
	return ishuman(cast_on)

/datum/action/cooldown/spell/robot_self_amputation/cast(mob/living/carbon/human/cast_on)
	. = ..()

	if(HAS_TRAIT(cast_on, TRAIT_NODISMEMBER))
		to_chat(cast_on, span_warning("ОШИБКА: ПРОТОКОЛЫ ОТКЛЮЧЕНИЯ КОНЕЧНОСТЕЙ ОТКЛЮЧЕНЫ. Обратитесь к специалисту по обслуживанию."))
		return

	var/list/exclusions = list()
	exclusions += BODY_ZONE_CHEST
	if (!issynthetic(cast_on))
		exclusions += BODY_ZONE_HEAD // no decapitating yourself unless you're a synthetic, who keep their brains in their chest

	var/list/robot_parts = list()
	for (var/obj/item/bodypart/possible_part as anything in cast_on.bodyparts)
		if ((possible_part.bodytype & BODYTYPE_ROBOTIC) && !(possible_part.body_zone in exclusions)) //only robot limbs and only if they're not crucial to our like, ongoing life, you know?
			robot_parts += possible_part

	if (!length(robot_parts))
		to_chat(cast_on, "ОШИБКА: Протоколы отсоединения конечностей сообщают об отсутствии совместимого кибернетического оборудования. Обратитесь к специалисту по обслуживанию.")
		return

	var/obj/item/bodypart/limb_to_detach = tgui_input_list(cast_on, "Конечность для отсоединения", "Кибернетическое отделение конечностей", sort_names(robot_parts))
	if (QDELETED(src) || QDELETED(cast_on) || QDELETED(limb_to_detach))
		return

	if (length(limb_to_detach.wounds) >= 1)
		cast_on.balloon_alert(cast_on, "нельзя отделять раненые конечности!")
		playsound(cast_on, 'sound/machines/buzz/buzz-sigh.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return

	cast_on.balloon_alert(cast_on, "detaching limb...")
	playsound(cast_on, 'sound/items/tools/rped.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	cast_on.visible_message(span_notice("[cast_on] перемещает [cast_on.p_their()] [limb_to_detach.name] вперед, приводы шипят и жужжат, когда [cast_on.p_they()] отцепляет[cast_on.p_s()] конечность от крепления..."))

	if(do_after(cast_on, 5 SECONDS))
		cast_on.visible_message(span_notice("Осторожно повернув, [cast_on] наконец освобождает [cast_on.p_their()] [limb_to_detach.name] из гнезда."))
		limb_to_detach.drop_limb()
		cast_on.put_in_hands(limb_to_detach)
		cast_on.balloon_alert(cast_on, "конечность оторвана!")
		if(prob(5))
			playsound(cast_on, 'sound/items/champagne_pop.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		else
			playsound(cast_on, 'sound/items/deconstruct.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	else
		cast_on.balloon_alert(cast_on, "прервано!")
		playsound(cast_on, 'sound/machines/buzz/buzz-sigh.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
