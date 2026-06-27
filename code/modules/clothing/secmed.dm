/datum/armor/security_medic_light
	melee = 35
	bullet = 30
	laser = 30
	energy = 40
	bomb = 25
	fire = 50
	acid = 50
	wound = 10

/obj/item/clothing/suit/toggle/labcoat/security_medic
	name = "security medic labcoat"
	desc = "A lightweight armored labcoat worn by security medics."
	icon = 'icons/obj/clothing/suits/labcoat_additions.dmi'
	worn_icon = 'icons/mob/clothing/suits/labcoat_additions.dmi'
	icon_state = "secmed_labcoat"
	blood_overlay_type = "armor"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	armor_type = /datum/armor/security_medic_light

/obj/item/clothing/suit/toggle/labcoat/security_medic/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/flashlight,
		/obj/item/gun,
		/obj/item/melee/baton/telescopic,
		/obj/item/storage/medkit,
	)

/obj/item/clothing/suit/toggle/labcoat/security_medic/blue
	icon_state = "secmed_labcoat_blue"

/obj/item/clothing/suit/hazardvest/security_medic
	name = "security medic vest"
	desc = "A lightweight vest worn by security medics."
	icon = 'icons/obj/clothing/suits/armor_additions.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor_additions.dmi'
	icon_state = "secmed_vest"
	worn_icon_state = "secmed_vest"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	allowed = list(/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer, /obj/item/flashlight, /obj/item/reagent_containers/cup/bottle, /obj/item/reagent_containers/cup/beaker, /obj/item/reagent_containers/applicator/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/baton/telescopic, /obj/item/soap, /obj/item/tank/internals/emergency_oxygen, /obj/item/gun, /obj/item/storage/medkit)
	armor_type = /datum/armor/security_medic_light

/obj/item/clothing/suit/hazardvest/security_medic/blue
	icon_state = "secmed_vest_blue"
	worn_icon_state = "secmed_vest_blue"

/obj/item/clothing/suit/armor/vest/security_medic
	name = "security medic armor vest"
	desc = "A security medic's armor vest with extra pockets for medical supplies."
	icon = 'icons/obj/clothing/suits/armor_additions.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor_additions.dmi'
	icon_state = "secmed_armor"
	worn_icon_state = "secmed_armor"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	allowed = list(/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer, /obj/item/flashlight, /obj/item/reagent_containers/cup/bottle, /obj/item/reagent_containers/cup/beaker, /obj/item/reagent_containers/applicator/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/baton/telescopic, /obj/item/soap, /obj/item/tank/internals/emergency_oxygen, /obj/item/gun, /obj/item/storage/medkit)

/obj/item/clothing/under/rank/security/security_medic
	name = "security medic turtleneck"
	desc = "A comfortable turtleneck with a white armband denoting the wearer as a security medic."
	icon = 'icons/obj/clothing/under/security_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/security_additions.dmi'
	worn_icon_digi = 'icons/mob/clothing/under/security_digi.dmi'
	icon_state = "security_medic_turtleneck"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/security/security_medic/skirt
	name = "security medic skirtleneck"
	desc = "A comfortable turtleneck with a white armband and brown skirt denoting the wearer as a security medic."
	icon_state = "security_medic_turtleneck_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/security_medic/alternate
	name = "security medic uniform"
	desc = "A lightly armored uniform worn by Nanotrasen's asset protection medical corps."
	icon_state = "security_medic_jumpsuit"
	worn_icon_state = "security_medic_jumpsuit"

/obj/item/clothing/head/beret/sec/security_medic
	name = "security medic beret"
	desc = "A robust beret with security medic colors. Reinforced fabric offers sufficient protection."
	greyscale_colors = "#3F3C40#870E12"
	post_init_icon_state = "beret_badge"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/helmet/sec/security_medic
	name = "security medic helmet"
	desc = "A standard issue combat helmet for security medics. Keep your head down."
	icon = 'icons/obj/clothing/head/helmet_additions.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet_additions.dmi'
	icon_state = "secmed_helmet"
	base_icon_state = "secmed_helmet"
	actions_types = null
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/storage/belt/security/medic
	name = "security medic belt"
	desc = "A security belt marked for security medic use."
	icon = 'icons/obj/clothing/belts_additions.dmi'
	worn_icon = 'icons/mob/clothing/belt_additions.dmi'
	icon_state = "belt_medic"
	worn_icon_state = "belt_medic"

/obj/item/storage/belt/security/medic/full/PopulateContents()
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/melee/baton/security/loaded(src)
	update_appearance()

/obj/item/encryptionkey/headset_medsec
	name = "medical-security radio encryption key"
	channels = list(RADIO_CHANNEL_MEDICAL = 1, RADIO_CHANNEL_SECURITY = 1)
	greyscale_colors = "#820a16#69abd1"

/obj/item/radio/headset/headset_medsec
	name = "security medic's bowman headset"
	desc = "Used to hear how many security officers need to be stitched back together."
	icon_state = "sec_headset_alt"
	worn_icon_state = "sec_headset_alt"
	keyslot = /obj/item/encryptionkey/headset_medsec
	radio_talk_sound = 'sound/radiosound/radio/security.ogg'

/obj/item/radio/headset/headset_medsec/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection)

/obj/item/clothing/glasses/hud/medsechud/sunglasses
	name = "health scanner security HUD sunglasses"
	desc = "Sunglasses with medical and security HUD displays."
	icon_state = "sunhudmed"
	inhand_icon_state = "sunhudmed"
	flash_protect = FLASH_PROTECTION_FLASH
	flags_cover = GLASSESCOVERSEYES
	tint = 1
	glass_colour_type = /datum/client_colour/glass_colour/blue

/obj/item/storage/bag/garment/secmed
	name = "security medic's garment bag"
	desc = "A bag containing extra clothing for the security medic."

/obj/item/storage/bag/garment/secmed/PopulateContents()
	. = ..()
	new /obj/item/clothing/suit/toggle/labcoat/security_medic(src)
	new /obj/item/clothing/suit/toggle/labcoat/security_medic/blue(src)
	new /obj/item/clothing/suit/toggle/labcoat/nova/security_medic/doctor_tailcoat(src)
	new /obj/item/clothing/suit/hazardvest/security_medic(src)
	new /obj/item/clothing/suit/hazardvest/security_medic/blue(src)
	new /obj/item/clothing/head/helmet/sec/security_medic(src)
	new /obj/item/clothing/under/rank/security/security_medic/alternate(src)
	new /obj/item/clothing/under/rank/security/security_medic(src)
	new /obj/item/clothing/under/rank/security/security_medic/skirt(src)

/obj/structure/closet/secure_closet/security_medic
	name = "security medic's locker"
	req_access = list(ACCESS_BRIG)
	icon_state = "sec"

/obj/structure/closet/secure_closet/security_medic/PopulateContents()
	..()
	new /obj/item/radio/headset/headset_medsec(src)
	new /obj/item/clothing/glasses/hud/medsechud/sunglasses(src)
	new /obj/item/storage/medkit/emergency(src)
	new /obj/item/clothing/suit/jacket/straight_jacket(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/storage/belt/security/medic/full(src)
	new /obj/item/storage/bag/garment/secmed(src)
