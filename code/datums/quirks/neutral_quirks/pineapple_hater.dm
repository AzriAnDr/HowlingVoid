/datum/quirk/pineapple_hater
	name = "Ananas Aversion(Неприязнь к ананасам)"
	desc = "Вы испытываете отвращение к плодам рода ананас. Серьёзно, как кто-то может называть их полезными? И какой безумец вообще осмелится положить их в пиццу!?"
	icon = FA_ICON_THUMBS_DOWN
	value = 0
	gain_text = span_notice("Ты ловишь себя на мысли, что этот идиот на самом деле любит ананасы... что-то не так...")
	lose_text = span_notice("Кажется, твои чувства к ананасам возвращаются к прежним прохладным отношениям.")
	medical_record_text = "Пациент прав, считая ананас отвратительным."
	mail_goodies = list( // basic pizza slices
		/obj/item/food/pizzaslice/margherita,
		/obj/item/food/pizzaslice/meat,
		/obj/item/food/pizzaslice/mushroom,
		/obj/item/food/pizzaslice/vegetable,
		/obj/item/food/pizzaslice/sassysage,
	)

/datum/quirk/pineapple_hater/add(client/client_source)
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		return
	tongue.disliked_foodtypes |= PINEAPPLE

/datum/quirk/pineapple_hater/remove()
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		return
	tongue.disliked_foodtypes = initial(tongue.disliked_foodtypes)
