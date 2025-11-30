/datum/quirk/item_quirk/mime_fan
	name = "Mime Fan(Фанат мимов)"
	desc = "Ты поклонник выходок пантомимы и получаете заряд настроения, надевая значок пантомимы."
	icon = FA_ICON_THUMBTACK
	value = 2
	mob_trait = TRAIT_MIME_FAN
	gain_text = span_notice("Ты большой поклонник мимов.")
	lose_text = span_danger("Ты больше не чувствуешь себя таким уж большим фанатом мимов.")
	medical_record_text = "Пациент имеет сильное увлечение пантомимой и мимами."
	mail_goodies = list(
		/obj/item/toy/crayon/mime,
		/obj/item/clothing/mask/gas/mime,
		/obj/item/storage/backpack/mime,
		/obj/item/clothing/under/rank/civilian/mime,
		/obj/item/reagent_containers/cup/glass/bottle/bottleofnothing,
		/obj/item/stamp/mime,
		/obj/item/storage/box/survival/hug/black,
		/obj/item/bedsheet/mime,
		/obj/item/clothing/shoes/sneakers/mime,
		/obj/item/toy/figure/mime,
		/obj/item/toy/crayon/spraycan/mimecan,
	)

/datum/quirk/item_quirk/mime_fan/add_unique(client/client_source)
	give_item_to_holder(/obj/item/clothing/accessory/mime_fan_pin, list(LOCATION_BACKPACK, LOCATION_HANDS))
