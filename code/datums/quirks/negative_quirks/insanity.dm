/datum/quirk/insanity
	name = "Reality Dissociation Syndrome(Синдром диссоциации реальности)"
	desc = "Ты страдаешь тяжелым расстройством, которое вызывает очень яркие галлюцинации и трудности с выражением мыслей. \
		Токсин «Разрушителя разума» может подавить его действие, и вы станете невосприимчивы к галлюциногенным свойствам «Разрушителя разума». \
		ЭТО НЕ ДАЁТ ТЕБЕ ПРАВО САМОАНТАЖИТЬ!"
	icon = FA_ICON_GRIN_TONGUE_WINK
	value = -8
	gain_text = span_userdanger("...")
	lose_text = span_notice("Ты снова чувствуешь себя в гармонии с миром.")
	medical_record_text = "Пациент страдает острым синдромом нарушения реальности, испытывает яркие галлюцинации и может испытывать трудности с речью."
	hardcore_value = 6
	mail_goodies = list(/obj/item/storage/pill_bottle/lsdpsych)
	/// Weakref to the trauma we give out
	var/datum/weakref/added_trama_ref

/datum/quirk/insanity/add(client/client_source)
	if(!iscarbon(quirk_holder))
		return
	var/mob/living/carbon/carbon_quirk_holder = quirk_holder

	// Setup our special RDS mild hallucination.
	// Not a unique subtype so not to plague subtypesof,
	// also as we inherit the names and values from our quirk.
	var/datum/brain_trauma/mild/hallucinations/added_trauma = new()
	added_trauma.resilience = TRAUMA_RESILIENCE_ABSOLUTE
	added_trauma.name = name
	added_trauma.desc = medical_record_text
	added_trauma.scan_desc = LOWER_TEXT(name)
	added_trauma.gain_text = null
	added_trauma.lose_text = null
	added_trauma.uncapped = client_source?.prefs?.read_preference(/datum/preference/toggle/rds_limit)

	carbon_quirk_holder.gain_trauma(added_trauma)
	added_trama_ref = WEAKREF(added_trauma)

/datum/quirk/insanity/post_add()
	var/rds_policy = get_policy("[type]") || "Обратите внимания, что ваш [LOWER_TEXT(name)] НЕ даёт вам никаких прав на нападение на людей или вредить станции."
	// I don't /think/ we'll need this, but for newbies who think "roleplay as insane" = "license to kill", it's probably a good thing to have.
	to_chat(quirk_holder, span_big(span_info(rds_policy)))

/datum/quirk/insanity/remove()
	QDEL_NULL(added_trama_ref)

/datum/quirk_constant_data/rds_limit
	associated_typepath = /datum/quirk/insanity
	customization_options = list(/datum/preference/toggle/rds_limit)
