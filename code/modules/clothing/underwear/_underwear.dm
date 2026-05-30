/obj/item/clothing/underwear
	name = "underwear"
	desc = "If you're reading this, something went wrong."
	icon = 'icons/mob/clothing/underwear.dmi'
	worn_icon = 'icons/mob/clothing/underwear.dmi'
	worn_icon_digi = 'icons/mob/clothing/underwear.dmi'
	body_parts_covered = GROIN
	slot_flags = NONE
	extra_slot_flags = NONE
	w_class = WEIGHT_CLASS_SMALL

	/// Underwear defaults to neutral female shaping unless overridden by generated types.
	var/female_sprite_flags = NO_FEMALE_UNIFORM

/obj/item/clothing/underwear/mob_can_equip(mob/living/user, slot, disable_warning, bypass_equip_delay_self, ignore_equipped, indirect_action)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_NO_UNDERWEAR))
		return FALSE

/obj/item/clothing/underwear/Move()
	. = ..()
	setDir(SOUTH)

/mob/living/carbon/human/proc/underwear_render_hidden(underwear_hide_flag)
	if(underwear_visibility & underwear_hide_flag)
		return TRUE
	for(var/obj/item/item in list(w_uniform, wear_suit))
		if(istype(item) && (item.flags_inv & HIDEUNDERWEAR))
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/undershirt_hidden()
	if(underwear_visibility & UNDERWEAR_HIDE_SHIRT)
		return TRUE
	for(var/obj/item/item in list(w_uniform, wear_suit))
		if(istype(item) && ((item.body_parts_covered & CHEST) || (item.flags_inv & HIDEUNDERWEAR)))
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/bra_hidden()
	if(underwear_visibility & UNDERWEAR_HIDE_BRA)
		return TRUE
	for(var/obj/item/item in list(w_uniform, wear_suit))
		if(istype(item) && ((item.body_parts_covered & CHEST) || (item.flags_inv & HIDEUNDERWEAR)))
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/underwear_hidden()
	if(underwear_visibility & UNDERWEAR_HIDE_UNDIES)
		return TRUE
	for(var/obj/item/item in list(w_uniform, wear_suit))
		if(istype(item) && ((item.body_parts_covered & GROIN) || (item.flags_inv & HIDEUNDERWEAR)))
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/socks_hidden()
	if(underwear_visibility & UNDERWEAR_HIDE_SOCKS)
		return TRUE
	for(var/obj/item/item in list(wear_suit))
		if(istype(item) && ((item.body_parts_covered & FEET) || (item.flags_inv & HIDEUNDERWEAR)))
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/wrists_hidden()
	for(var/obj/item/item in list(w_uniform, wear_suit, w_shirt, w_underwear))
		if(istype(item) && (item.body_parts_covered & ARMS) && (item.flags_inv & HIDEWRISTS))
			return TRUE
	return FALSE
