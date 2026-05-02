/obj/item/clothing/wrists
	name = "slap bracelet"
	desc = "oh no."
	gender = PLURAL
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/clothing/wrist.dmi'
	worn_icon = 'icons/mob/clothing/wrists.dmi'
	siemens_coefficient = 0.5
	body_parts_covered = HANDS
	slot_flags = NONE
	extra_slot_flags = ITEM_SLOT_WRISTS
	attack_verb_simple = list("slapped on the wrist")
	strip_delay = 20
	equip_delay_other = 40

/obj/item/clothing/wrists/armwarmer
	name = "arm warmers"
	desc = "A pair of arm warmers."
	icon_state = "armwarmer"
	body_parts_covered = ARMS

/obj/item/clothing/wrists/armwarmer/long
	name = "long arm warmers"
	desc = "A pair of long arm warmers."
	icon_state = "armwarmer_long"
	body_parts_covered = ARMS

/obj/item/clothing/wrists/armwarmer_striped
	name = "striped arm warmers"
	desc = "A pair of striped arm warmers."
	icon = 'icons/map_icons/clothing/_clothing.dmi'
	worn_icon = 'icons/mob/clothing/wrists.dmi'
	icon_state = "/obj/item/clothing/wrists/armwarmer_striped"
	post_init_icon_state = "armwarmer_striped"
	body_parts_covered = ARMS
	greyscale_colors = "#FFFFFF#FFFFFF"
	greyscale_config = /datum/greyscale_config/armwarmer_striped
	greyscale_config_worn = /datum/greyscale_config/armwarmer_striped/worn

/datum/greyscale_config/armwarmer_striped
	name = "Striped Arm Warmers"
	icon_file = 'icons/obj/clothing/wrist.dmi'
	json_config = 'code/datums/greyscale/json_configs/armwarmer_striped.json'

/datum/greyscale_config/armwarmer_striped/worn
	name = "Striped Arm Warmers (Worn)"
	icon_file = 'icons/mob/clothing/wrists.dmi'

/obj/item/clothing/wrists/armwarmer_striped/long
	name = "long striped arm warmers"
	desc = "A pair of long striped arm warmers."
	icon = 'icons/map_icons/clothing/_clothing.dmi'
	worn_icon = 'icons/mob/clothing/wrists.dmi'
	icon_state = "/obj/item/clothing/wrists/armwarmer_striped/long"
	post_init_icon_state = "armwarmer_striped_long"
	body_parts_covered = ARMS
	greyscale_config = /datum/greyscale_config/armwarmer_striped_long
	greyscale_config_worn = /datum/greyscale_config/armwarmer_striped_long/worn

/datum/greyscale_config/armwarmer_striped_long
	name = "Long Striped Arm Warmers"
	icon_file = 'icons/obj/clothing/wrist.dmi'
	json_config = 'code/datums/greyscale/json_configs/armwarmer_striped_long.json'

/datum/greyscale_config/armwarmer_striped_long/worn
	name = "Long Striped Arm Warmers (Worn)"
	icon_file = 'icons/mob/clothing/wrists.dmi'
