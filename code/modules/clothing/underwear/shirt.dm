/obj/item/clothing/underwear/shirt
	name = "shirt"
	desc = "A shirt."
	icon_state = "shirt_white"
	body_parts_covered = CHEST | ARMS
	extra_slot_flags = ITEM_SLOT_SHIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/underwear/shirt/equipped(mob/living/user, slot)
	. = ..()
	var/slot_noextra = slot & ~ITEM_SLOT_EXTRA
	if(!istype(user, /mob/living/carbon/human) || istype(src, /obj/item/clothing/underwear/shirt/bra))
		return
	var/mob/living/carbon/human/human = user
	if(human.syncing_extra_inventory)
		return
	if(slot & ITEM_SLOT_EXTRA && slot_noextra & ITEM_SLOT_SHIRT)
		human.undershirt = name
	else
		human.undershirt = "Nude"
	human.update_underwear(FALSE)
	human.update_body_parts()

/obj/item/clothing/underwear/shirt/dropped(mob/living/user)
	. = ..()
	if(!istype(user, /mob/living/carbon/human) || istype(src, /obj/item/clothing/underwear/shirt/bra))
		return
	var/mob/living/carbon/human/human = user
	if(human.syncing_extra_inventory)
		return
	human.undershirt = "Nude"
	human.update_underwear(FALSE)
	human.update_body_parts()

/obj/item/clothing/underwear/shirt/bra
	name = "bra"
	desc = "A bra."
	icon_state = "bra"
	body_parts_covered = CHEST
	extra_slot_flags = ITEM_SLOT_BRA
	female_sprite_flags = NO_FEMALE_UNIFORM

/obj/item/clothing/underwear/shirt/bra/equipped(mob/living/user, slot)
	. = ..()
	var/slot_noextra = slot & ~ITEM_SLOT_EXTRA
	if(!istype(user, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/human = user
	if(human.syncing_extra_inventory)
		return
	if(slot & ITEM_SLOT_EXTRA && slot_noextra & ITEM_SLOT_BRA)
		human.bra = name
	else
		human.bra = "Nude"
	human.update_underwear(FALSE)
	human.update_body_parts()

/obj/item/clothing/underwear/shirt/bra/dropped(mob/living/user)
	. = ..()
	if(!istype(user, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/human = user
	if(human.syncing_extra_inventory)
		return
	human.bra = "Nude"
	human.update_underwear(FALSE)
	human.update_body_parts()
