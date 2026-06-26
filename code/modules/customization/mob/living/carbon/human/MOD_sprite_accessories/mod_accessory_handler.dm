// This DMI holds all of the overlayable textures for MODs
#define HARDLIGHT_DMI 'icons/customization/modules/mob/living/carbon/human/MOD_sprite_accessories/icons/MOD_mask.dmi'

/datum/sprite_accessory/proc/get_mod_hardlight_control(mob/living/carbon/human/wearer)
	return null

/datum/sprite_accessory/proc/resolve_mod_hardlight_control(mob/living/carbon/human/wearer, required_slot)
	var/obj/item/mod/control/modsuit_control = wearer?.back
	if(!istype(modsuit_control))
		return null
	if(required_slot && modsuit_control.get_part_from_slot(required_slot) != wearer.get_item_by_slot(required_slot))
		return null

	var/datum/mod_theme/mod_theme = modsuit_control.theme
	if(!modsuit_control.active || !mod_theme?.hardlight)
		return null

	return modsuit_control

/datum/sprite_accessory/proc/build_mod_hardlight_icon(obj/item/mod/control/modsuit_control, mutable_appearance/appearance_to_use = null)
	if(!istype(modsuit_control))
		return

	var/datum/mod_theme/mod_theme = modsuit_control.theme
	if(!modsuit_control.active || !mod_theme.hardlight)
		return

	var/icon/special_icon = appearance_to_use ? icon(appearance_to_use.icon, appearance_to_use.icon_state) : icon(icon, icon_state)
	special_icon.Blend("#fff", ICON_ADD)

	if(modsuit_control.color || modsuit_control.cached_color_filter)
		return special_icon

	var/icon/MOD_texture = icon(HARDLIGHT_DMI, "[mod_theme.hardlight_theme]")
	special_icon.Blend(MOD_texture, ICON_MULTIPLY)
	return special_icon

// Tail hardlight
/datum/sprite_accessory/tails
	use_custom_mod_icon = TRUE

/datum/sprite_accessory/tails/get_mod_hardlight_control(mob/living/carbon/human/wearer)
	if(!istype(wearer?.wear_suit, /obj/item/clothing/suit/mod))
		return null
	return resolve_mod_hardlight_control(wearer, ITEM_SLOT_OCLOTHING)

/datum/sprite_accessory/tails/get_custom_mod_icon(mob/living/carbon/human/wearer, mutable_appearance/appearance_to_use = null)
	return build_mod_hardlight_icon(get_mod_hardlight_control(wearer), appearance_to_use)

// Ears hardlight
/datum/sprite_accessory/ears
	use_custom_mod_icon = TRUE

/datum/sprite_accessory/ears/get_mod_hardlight_control(mob/living/carbon/human/wearer)
	if(!istype(wearer?.head, /obj/item/clothing/head/mod))
		return null
	return resolve_mod_hardlight_control(wearer, ITEM_SLOT_HEAD)

/datum/sprite_accessory/ears/get_custom_mod_icon(mob/living/carbon/human/wearer, mutable_appearance/appearance_to_use = null)
	return build_mod_hardlight_icon(get_mod_hardlight_control(wearer), appearance_to_use)

// Wings hardlight
/datum/sprite_accessory/wings
	use_custom_mod_icon = TRUE

/datum/sprite_accessory/wings/get_mod_hardlight_control(mob/living/carbon/human/wearer)
	if(!istype(wearer?.wear_suit, /obj/item/clothing/suit/mod))
		return null
	return resolve_mod_hardlight_control(wearer, ITEM_SLOT_OCLOTHING)

/datum/sprite_accessory/wings/get_custom_mod_icon(mob/living/carbon/human/wearer, mutable_appearance/appearance_to_use = null)
	return build_mod_hardlight_icon(get_mod_hardlight_control(wearer), appearance_to_use)

// Antennae hardlight
/datum/sprite_accessory/moth_antennae
	use_custom_mod_icon = TRUE

/datum/sprite_accessory/moth_antennae/get_mod_hardlight_control(mob/living/carbon/human/wearer)
	if(!istype(wearer?.head, /obj/item/clothing/head/mod))
		return null
	return resolve_mod_hardlight_control(wearer, ITEM_SLOT_HEAD)

/datum/sprite_accessory/moth_antennae/get_custom_mod_icon(mob/living/carbon/human/wearer, mutable_appearance/appearance_to_use = null)
	return build_mod_hardlight_icon(get_mod_hardlight_control(wearer), appearance_to_use)

// IPC Antennae hardlight
/datum/sprite_accessory/antenna
	use_custom_mod_icon = TRUE

/datum/sprite_accessory/antenna/get_mod_hardlight_control(mob/living/carbon/human/wearer)
	if(!istype(wearer?.head, /obj/item/clothing/head/mod))
		return null
	return resolve_mod_hardlight_control(wearer, ITEM_SLOT_HEAD)

/datum/sprite_accessory/antenna/get_custom_mod_icon(mob/living/carbon/human/wearer, mutable_appearance/appearance_to_use = null)
	return build_mod_hardlight_icon(get_mod_hardlight_control(wearer), appearance_to_use)

// Horns hardlight
/datum/sprite_accessory/horns
	use_custom_mod_icon = TRUE

/datum/sprite_accessory/horns/get_mod_hardlight_control(mob/living/carbon/human/wearer)
	if(!istype(wearer?.head, /obj/item/clothing/head/mod))
		return null
	return resolve_mod_hardlight_control(wearer, ITEM_SLOT_HEAD)

/datum/sprite_accessory/horns/get_custom_mod_icon(mob/living/carbon/human/wearer, mutable_appearance/appearance_to_use = null)
	return build_mod_hardlight_icon(get_mod_hardlight_control(wearer), appearance_to_use)

// Taur hardlight
/datum/sprite_accessory/taur
	use_custom_mod_icon = TRUE

/datum/sprite_accessory/taur/get_mod_hardlight_control(mob/living/carbon/human/wearer)
	if(!istype(wearer?.wear_suit, /obj/item/clothing/suit/mod))
		return null
	return resolve_mod_hardlight_control(wearer, ITEM_SLOT_OCLOTHING)

/datum/sprite_accessory/taur/get_custom_mod_icon(mob/living/carbon/human/wearer, mutable_appearance/appearance_to_use = null)
	return build_mod_hardlight_icon(get_mod_hardlight_control(wearer), appearance_to_use)

// Lizard spines hardlight
/datum/sprite_accessory/spines
	use_custom_mod_icon = TRUE

/datum/sprite_accessory/spines/get_mod_hardlight_control(mob/living/carbon/human/wearer)
	if(!istype(wearer?.wear_suit, /obj/item/clothing/suit/mod))
		return null
	return resolve_mod_hardlight_control(wearer, ITEM_SLOT_OCLOTHING)

/datum/sprite_accessory/spines/get_custom_mod_icon(mob/living/carbon/human/wearer, mutable_appearance/appearance_to_use = null)
	return build_mod_hardlight_icon(get_mod_hardlight_control(wearer), appearance_to_use)

// Xenodorsal hardlight
/datum/sprite_accessory/xenodorsal
	use_custom_mod_icon = TRUE

/datum/sprite_accessory/xenodorsal/get_mod_hardlight_control(mob/living/carbon/human/wearer)
	if(!istype(wearer?.wear_suit, /obj/item/clothing/suit/mod))
		return null
	return resolve_mod_hardlight_control(wearer, ITEM_SLOT_OCLOTHING)

/datum/sprite_accessory/xenodorsal/get_custom_mod_icon(mob/living/carbon/human/wearer, mutable_appearance/appearance_to_use = null)
	return build_mod_hardlight_icon(get_mod_hardlight_control(wearer), appearance_to_use)

// Skrell hair hardlight
/datum/sprite_accessory/skrell_hair
	use_custom_mod_icon = TRUE

/datum/sprite_accessory/skrell_hair/get_mod_hardlight_control(mob/living/carbon/human/wearer)
	if(!istype(wearer?.head, /obj/item/clothing/head/mod))
		return null
	return resolve_mod_hardlight_control(wearer, ITEM_SLOT_HEAD)

/datum/sprite_accessory/skrell_hair/get_custom_mod_icon(mob/living/carbon/human/wearer, mutable_appearance/appearance_to_use = null)
	return build_mod_hardlight_icon(get_mod_hardlight_control(wearer), appearance_to_use)

#undef HARDLIGHT_DMI
