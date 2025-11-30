/datum/quirk/pineapple_liker
	name = "Ananas Affinity(Любитель ананасов)"
	desc = "Ты обнаруживаешь, что тебе очень нравятся плоды ананаса. Кажется, ты никогда не можете насытиться их сладким вкусом!"
	icon = FA_ICON_THUMBS_UP
	value = 0
	gain_text = span_notice("Ты чувствуешь сильное желание съесть ананас.")
	lose_text = span_notice("Твои чувства к ананасам, похоже, возвращаются к умеренному теплу..")
	medical_record_text = "Пациент демонстрирует патологическую любовь к ананасам."
	mail_goodies = list(/obj/item/food/pizzaslice/pineapple)

/datum/quirk/pineapple_liker/add(client/client_source)
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		return
	tongue.liked_foodtypes |= PINEAPPLE

/datum/quirk/pineapple_liker/remove()
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		return
	tongue.liked_foodtypes = initial(tongue.liked_foodtypes)
