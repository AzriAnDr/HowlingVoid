/datum/atom_skin/security_armor_vest_white
	abstract_type = /datum/atom_skin/security_armor_vest_white

/datum/atom_skin/security_armor_vest_white/black
	preview_name = "Black Variant"
	new_icon_state = "vest_black"

/datum/atom_skin/security_armor_vest_white/blue
	preview_name = "Blue Variant"
	new_icon_state = "vest_blue"

/datum/atom_skin/security_armor_vest_white/white
	preview_name = "White Variant"
	new_icon_state = "vest_white"

/obj/item/clothing/suit/armor/vest/alt/sec/white
	icon = 'icons/obj/clothing/suits/armor_additions.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor_additions.dmi'
	icon_state = "vest_white"

/obj/item/clothing/suit/armor/vest/alt/sec/white/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/security_armor_vest_white)

/obj/item/clothing/suit/armor/vest/brit
	name = "high vis armored vest"
	desc = "Oi bruv, you got a loicence for that?"
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "hazardbg"
	worn_icon_state = "hazardbg"

/obj/item/clothing/suit/armor/vest/brit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, "zipper")

/datum/atom_skin/vested_jacket
	abstract_type = /datum/atom_skin/vested_jacket

/datum/atom_skin/vested_jacket/red
	preview_name = "Red Variant"
	new_icon_state = "vested_jacket"

/datum/atom_skin/vested_jacket/blue
	preview_name = "Blue Variant"
	new_icon_state = "vested_jacket_blue"

/datum/atom_skin/vested_jacket/white
	preview_name = "White Variant"
	new_icon_state = "vested_jacket_white"

/datum/atom_skin/vested_jacket/black
	preview_name = "Black Variant"
	new_icon_state = "vested_jacket_black"

/obj/item/clothing/suit/armor/vest/vested_jacket
	name = "vested security jacket"
	desc = "The company standard armor now with a stylish zipper jacket stitched in for when you don't think you'll get shot!"
	icon = 'icons/obj/clothing/suits/armor_additions.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor_additions.dmi'
	icon_state = "vested_jacket"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	heat_protection = CHEST|GROIN|ARMS

/obj/item/clothing/suit/armor/vest/vested_jacket/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/vested_jacket)
	AddComponent(/datum/component/toggle_icon, "zipper")

/obj/item/clothing/head/hooded/winterhood/security/blue
	desc = "A blue, armour-padded winter hood. Definitely not bulletproof, especially not the part where your face goes."
	icon = 'icons/obj/clothing/head/winterhood_additions.dmi'
	worn_icon = 'icons/mob/clothing/head/winterhood_additions.dmi'
	icon_state = "winterhood_security"

/obj/item/clothing/suit/hooded/wintercoat/security/blue
	name = "security winter coat"
	desc = "A blue, armour-padded winter coat. It glitters with a mild ablative coating and a robust air of authority."
	icon = 'icons/obj/clothing/suits/wintercoat_additions.dmi'
	worn_icon = 'icons/mob/clothing/suits/wintercoat_additions.dmi'
	icon_state = "coatsecurity_winter"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security/blue

/*
*	WARDEN
*/

/obj/item/clothing/suit/armor/vest/warden/blue
	icon = 'icons/obj/clothing/suits/armor_additions.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor_additions.dmi'
	icon_state = "vest_warden"

/*
*	Head of Security
*/

/obj/item/clothing/suit/armor/hos/hos_formal/black
	icon = 'icons/obj/clothing/suits/armor_additions.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor_additions.dmi'
	icon_state = "hosformal_black"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
