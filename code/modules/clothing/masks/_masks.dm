/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/masks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/masks_righthand.dmi'
	abstract_type = /obj/item/clothing/mask
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_MASK
	strip_delay = 4 SECONDS
	equip_delay_other = 4 SECONDS
	visor_vars_to_toggle = NONE

	var/adjusted_flags = null
	///Did we install a filtering cloth?
	var/has_filter = FALSE
	/// If defined, what voice should we override with if TTS is active?
	var/voice_override
	/// If set to true, activates the radio effect on TTS. Used for sec hailers, but other masks can utilize it for their own vocal effect.
	var/use_radio_beeps_tts = FALSE
	/// The unique sound effect of dying while wearing this
	var/unique_death

/obj/item/clothing/mask/attack_self(mob/user)
	if((clothing_flags & VOICEBOX_TOGGLABLE))
		clothing_flags ^= (VOICEBOX_DISABLED)
		var/status = !(clothing_flags & VOICEBOX_DISABLED)
		to_chat(user, span_notice("You turn the voice box in [src] [status ? "on" : "off"]."))

/obj/item/clothing/mask/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands || !(body_parts_covered & HEAD))
		return
	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damagedmask")

/obj/item/clothing/mask/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file, mutant_styles) // NOVA EDIT CHANGE - ORIGINAL: /obj/item/clothing/gloves/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file)
	. = ..()
	if (isinhands || !(body_parts_covered & HEAD))
		return
	var/blood_overlay = get_blood_overlay("mask")
	if (blood_overlay)
		. += blood_overlay

/obj/item/clothing/mask/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_worn_mask()

//Proc that moves gas/breath masks out of the way, disabling them and allowing pill/food consumption
/obj/item/clothing/mask/visor_toggling(mob/living/user)
	. = ..()
	if(up)
		if(adjusted_flags)
			slot_flags = adjusted_flags
	else
		slot_flags = initial(slot_flags)

/obj/item/clothing/mask/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state || initial(post_init_icon_state) || initial(icon_state)][up ? "_up" : ""]"

/**
 * Proc called in lungs.dm to act if wearing a mask with filters, used to reduce the filters durability, return a changed gas mixture depending on the filter status
 * Arguments:
 * * breath - the gas mixture of the breather
 */
/obj/item/clothing/mask/proc/consume_filter(datum/gas_mixture/breath)
	return breath


// BEGIN NOVA CORE MIGRATION: code/modules/clothing/masks/_masks.dm
// Make sure that these get drawn over the snout layer if the mob has a snout
/obj/item/clothing/mask/visual_equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot & ITEM_SLOT_MASK)
		if(!(user.bodyshape & BODYSHAPE_ALT_FACEWEAR_LAYER))
			return
		if(!isnull(alternate_worn_layer) && alternate_worn_layer < BODY_FRONT_LAYER) // if the alternate worn layer was already lower than snouts then leave it be
			return

		alternate_worn_layer = ABOVE_BODY_FRONT_HEAD_LAYER
		user.update_worn_mask()

		if(user.head) // so we don't draw over hats, which use the same layer
			user.update_worn_head()

/obj/item/clothing/mask/dropped(mob/living/carbon/human/user)
	. = ..()
	alternate_worn_layer = initial(alternate_worn_layer)

/obj/item/clothing/mask
	var/item_face_toggled

/obj/item/clothing/mask/Initialize(mapload)
	if (src.flags_inv && (src.flags_inv & HIDEFACE))
		if (!islist(actions_types))
			actions_types = list(/datum/action/item_action/toggle_hide_face)

	return ..()

/datum/action/item_action/toggle_hide_face/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/mask/target_mask = target
	target_mask.toggle_hide_face(usr)

/**
 * Toggles the HIDEFACE flag on the user's mask.
 *
 * @param user The user to toggle the mask for.
 * @param force Whether to force the mask to be toggled.
 * @return TRUE if the mask was toggled, FALSE otherwise.
 */
/obj/item/clothing/mask/proc/toggle_hide_face(mob/living/carbon/user, force = FALSE)
	if(!user.wear_mask && !force)
		return FALSE

	if(src.flags_inv & HIDEFACE)
		src.flags_inv &= ~HIDEFACE
		to_chat(user, "You've revealed your face!")
		item_face_toggled = TRUE
	else
		src.flags_inv |= HIDEFACE
		if (!force)
			to_chat(user, "You've hidden your face!")
		item_face_toggled = FALSE

	return TRUE

/obj/item/clothing/mask/dropped(mob/living/user)
	. = ..()
	if(item_face_toggled)
		toggle_hide_face(user, force = TRUE)
// END NOVA CORE MIGRATION: code/modules/clothing/masks/_masks.dm
