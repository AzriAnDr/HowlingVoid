// MODULAR ARMOUR

// WARDEN
/obj/item/clothing/suit/armor/vest/warden/syndicate
	name = "master at arms' vest"
	desc = "Stunning. Menacing. Perfect for the man who gets bullied for leaving the brig."
	icon = 'icons/obj/clothing/suits/armor_additions.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor_additions.dmi'
	icon_state = "warden_syndie"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

// HEAD OF PERSONNEL
/obj/item/clothing/suit/armor/vest/hop/hop_formal
	name = "head of personnel's parade jacket"
	desc = "A luxurious deep blue jacket for the Head of Personnel, woven with a red trim. It smells of bureaucracy."
	icon = 'icons/obj/clothing/suits/armor_additions.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor_additions.dmi'
	icon_state = "hopformal"

/obj/item/clothing/suit/armor/vest/hop/hop_formal/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

// CAPTAIN
/obj/item/clothing/suit/armor/vest/capcarapace/jacket
	name = "captain's jacket"
	desc = "A lightweight armored jacket in the Captain's colors. For when you want something sleeker."
	icon = 'icons/obj/clothing/suits/armor_additions.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor_additions.dmi'
	icon_state = "capjacket_casual"
	body_parts_covered = CHEST|ARMS
