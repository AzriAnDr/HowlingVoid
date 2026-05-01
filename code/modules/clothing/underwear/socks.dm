/obj/item/clothing/underwear/socks
	name = "socks"
	desc = "A pair of socks."
	icon_state = "white_norm"
	body_parts_covered = FEET
	extra_slot_flags = ITEM_SLOT_SOCKS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/underwear/socks/equipped(mob/living/user, slot)
	. = ..()
	var/slot_noextra = slot & ~ITEM_SLOT_EXTRA
	if(!istype(user, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/human = user
	if(human.syncing_extra_inventory)
		return
	if(slot & ITEM_SLOT_EXTRA && slot_noextra & ITEM_SLOT_SOCKS)
		human.socks = name
	else
		human.socks = "Nude"
	human.update_underwear(FALSE)

/obj/item/clothing/underwear/socks/dropped(mob/living/user)
	. = ..()
	if(!istype(user, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/human = user
	if(human.syncing_extra_inventory)
		return
	human.socks = "Nude"
	human.update_underwear(FALSE)