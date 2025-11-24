/datum/quirk/deviant_tastes
	name = "Deviant Tastes(Извращённые вкусы)"
	desc = "Тебе не нравится еда, которая нравится большинству людей, и вы находите вкусной то, что им не нравится."
	icon = FA_ICON_GRIN_TONGUE_SQUINT
	value = 0
	gain_text = span_notice("Тебе хочется чего-то странного на вкус.")
	lose_text = span_notice("Ты больше не говноед")
	medical_record_text = "Пациент демонстрирует нерегулярные предпочтения в питании."
	mail_goodies = list(/obj/item/food/urinalcake, /obj/item/food/badrecipe) // Mhhhmmm yummy

/datum/quirk/deviant_tastes/add(client/client_source)
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		return
	var/liked_foodtypes = tongue.liked_foodtypes
	tongue.liked_foodtypes = tongue.disliked_foodtypes
	tongue.disliked_foodtypes = liked_foodtypes

/datum/quirk/deviant_tastes/remove()
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		return
	tongue.liked_foodtypes = initial(tongue.liked_foodtypes)
	tongue.disliked_foodtypes = initial(tongue.disliked_foodtypes)
