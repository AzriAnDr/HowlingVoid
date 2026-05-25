//PEACEKEEPER GLASSES
/obj/item/clothing/glasses/hud/security/sunglasses/peacekeeper
	name = "peacekeeper hud glasses"
	icon_state = "peacekeeperglasses"
	worn_icon = 'icons/mob/clothing/eyes_additions.dmi'
	icon = 'icons/obj/clothing/glasses_additions.dmi'

//PEACEKEEPER ARMOR
/obj/item/clothing/suit/armor/vest/peacekeeper
	name = "peacekeeper armor vest"
	desc = "A standard issue peacekeeper armor vest, versatile, lightweight, and most importantly, cheap."
	icon = 'icons/obj/clothing/suits/armor_additions.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor_additions.dmi'
	icon_state = "peacekeeper_white"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/armor/vest/peacekeeper/black
	icon_state = "peacekeeper_black"

/obj/item/clothing/suit/armor/vest/peacekeeper/spacecoat
	name = "peacekeeper sleek coat"
	desc = "An incredibly stylish and heavy black coat made of synthetic kangaroo leather, padded with durathread and lined with kevlar."
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "peacekeeper_spacecoat"
	worn_icon_state = "peacekeeper_spacecoat"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

//PEACEKEEPER GLOVES
/obj/item/clothing/gloves/combat/peacekeeper
	name = "peacekeeper gloves"
	desc = "These tactical gloves are fireproof."
	icon = 'icons/obj/clothing/gloves_additions.dmi'
	worn_icon = 'icons/mob/clothing/hands_additions.dmi'
	icon_state = "black_blue_gloves"
	worn_icon_state = "black_blue"
	siemens_coefficient = 0.5
	strip_delay = 20
	cold_protection = 0
	min_cold_protection_temperature = null
	heat_protection = 0
	max_heat_protection_temperature = null
	resistance_flags = FLAMMABLE
	armor_type = /datum/armor/none
	cut_type = null

/obj/item/clothing/gloves/tackler/peacekeeper
	name = "peacekeeper gripper gloves"
	desc = "Special gloves that manipulate the blood vessels in the wearer's hands, granting them the ability to launch headfirst into walls."
	icon = 'icons/obj/clothing/gloves_additions.dmi'
	worn_icon = 'icons/mob/clothing/hands_additions.dmi'
	icon_state = "black_blue_gripper_gloves"

/obj/item/clothing/gloves/kaza_ruk/sec/peacekeeper
	name = "peacekeeper krav maga gloves"
	desc = "These gloves can teach you to perform Krav Maga using nanochips."
	icon = 'icons/obj/clothing/gloves_additions.dmi'
	worn_icon = 'icons/mob/clothing/hands_additions.dmi'
	icon_state = "fightgloves_blue"
	greyscale_colors = "#3F6E9E"

//PEACEKEEPER WEBBING
/obj/item/storage/belt/security/webbing/peacekeeper
	icon = 'icons/obj/clothing/belts_additions.dmi'
	worn_icon = 'icons/mob/clothing/belt_additions.dmi'
	icon_state = "blue_webbing"
	worn_icon_state = "blue_webbing"

/obj/item/storage/belt/security/webbing/peacekeeper/setup_reskins()
	return

//BOOTS
/obj/item/clothing/shoes/jackboots/peacekeeper
	name = "peacekeeper boots"
	desc = "High speed, low drag combat boots."
	icon = 'icons/obj/clothing/shoes_additions.dmi'
	worn_icon = 'icons/mob/clothing/feet_additions.dmi'
	icon_state = "peacekeeper"
