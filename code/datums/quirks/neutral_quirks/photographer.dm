/datum/quirk/item_quirk/photographer
	name = "Photographer(Фотограф)"
	desc = "Ты носишь с собой фотоаппарат и личный фотоальбом везде, куда бы ты не пошёл, а ваши альбомы стали легендой среди ваших коллег."
	icon = FA_ICON_CAMERA
	value = 0
	mob_trait = TRAIT_PHOTOGRAPHER
	gain_text = span_notice("Ты знаешь все о фотографии.")
	lose_text = span_danger("Ты забываешь, как работают фотоаппараты.")
	medical_record_text = "Пациент упоминает фотографию как хобби, помогающее снять стресс."
	mail_goodies = list(/obj/item/camera_film)

/datum/quirk/item_quirk/photographer/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/storage/photo_album/personal/photo_album = new(get_turf(human_holder))
	photo_album.persistence_id = "personal_[ckey(human_holder.last_mind?.key)]" // this is a persistent album, the ID is tied to the account's key to avoid tampering // NOVA EDIT CHANGE - ORIGINAL: photo_album.persistence_id = "personal_[human_holder.last_mind?.key]" // this is a persistent album, the ID is tied to the account's key to avoid tampering
	photo_album.persistence_load()
	photo_album.name = "Фотоальбом [human_holder.real_name]"

	give_item_to_holder(photo_album, list(LOCATION_BACKPACK, LOCATION_HANDS))
	give_item_to_holder(
		/obj/item/camera,
		list(
			LOCATION_NECK,
			LOCATION_LPOCKET,
			LOCATION_RPOCKET,
			LOCATION_BACKPACK,
			LOCATION_HANDS
		)
	)
