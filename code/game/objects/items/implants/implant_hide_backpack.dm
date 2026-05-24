/obj/item/implant/hide_backpack
	name = "storage concealment implant"
	desc = "Projects a low-power chameleon field over equipment worn on the user's back."
	icon_state = "generic"
	actions_types = list(/datum/action/item_action/hands_free/hide_backpack)

	implant_info = "Activated manually. Conceals the visual profile of equipment worn in the user's back slot."
	implant_lore = "The chameleon storage concealment implant was designed for clients who prefer their back-mounted equipment to stay out of sight. The implant does not hide the item from inventory checks, physical interaction, or direct searches."

/obj/item/implant/hide_backpack/can_be_implanted_in(mob/living/target)
	if(!ishuman(target))
		return FALSE
	return ..()

/obj/item/implanter/hide_backpack
	name = "implanter (storage concealment)"
	imp_type = /obj/item/implant/hide_backpack

/obj/item/implantcase/hide_backpack
	name = "implant case - 'Storage Concealment'"
	desc = "A glass case containing a storage concealment implant."
	imp_type = /obj/item/implant/hide_backpack

/datum/action/item_action/hands_free/hide_backpack
	name = "Conceal Backwear"
	desc = "Toggles the storage concealment implant."
	button_icon = 'icons/obj/storage/backpack.dmi'
	button_icon_state = "backpack_faded"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	var/active = TRUE

/datum/action/item_action/hands_free/hide_backpack/Grant(mob/grant_to)
	. = ..()
	set_concealment(TRUE)

/datum/action/item_action/hands_free/hide_backpack/Remove(mob/remove_from)
	set_concealment(FALSE)
	return ..()

/datum/action/item_action/hands_free/hide_backpack/do_effect(trigger_flags)
	active = !active
	set_concealment(active)
	button_icon_state = active ? "backpack_faded" : "backpack"
	build_all_button_icons()

	var/state_text = active ? "imperceptible" : "discernible"
	var/action_text = active ? "engage" : "disengage"
	owner.visible_message(
		span_notice("The equipment worn on [owner]'s back flickers momentarily, becoming [state_text]."),
		span_notice("You [action_text] the storage concealment implant, making your backwear [state_text]."),
	)
	return TRUE

/datum/action/item_action/hands_free/hide_backpack/proc/set_concealment(enabled)
	var/mob/living/action_owner = owner
	if(!istype(action_owner) || QDELETED(action_owner))
		return

	if(enabled)
		ADD_TRAIT(action_owner, TRAIT_HIDE_BACK_SLOT, REF(src))
	else
		REMOVE_TRAIT(action_owner, TRAIT_HIDE_BACK_SLOT, REF(src))

	action_owner.update_worn_back()
