/datum/atom_skin/security_jackboots
	abstract_type = /datum/atom_skin/security_jackboots

/datum/atom_skin/security_jackboots/blue_trim
	preview_name = "Blue-Trimmed Variant"
	new_icon_state = "security_boots"

/datum/atom_skin/security_jackboots/white_trim
	preview_name = "White-Trimmed Variant"
	new_icon_state = "security_boots_white"

/datum/atom_skin/security_jackboots/fullwhite
	preview_name = "Full White Variant"
	new_icon_state = "security_boots_fullwhite"

/obj/item/clothing/shoes/jackboots/sec/blue
	icon_state = "security_boots"
	icon = 'icons/obj/clothing/shoes_additions.dmi'
	worn_icon = 'icons/mob/clothing/feet_additions.dmi'

/obj/item/clothing/shoes/jackboots/sec/blue/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/security_jackboots)
