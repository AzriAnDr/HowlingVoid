/obj/item/clothing/underwear/briefs
	name = "briefs"
	desc = "Not going commando."
	icon_state = "male_briefs"
	body_parts_covered = GROIN
	extra_slot_flags = ITEM_SLOT_UNDERWEAR

/obj/item/clothing/underwear/briefs/equipped(mob/living/user, slot)
	. = ..()
	var/slot_noextra = slot & ~ITEM_SLOT_EXTRA
	if(!istype(user, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/human = user
	if(human.syncing_extra_inventory)
		return
	if(slot & ITEM_SLOT_EXTRA && slot_noextra & ITEM_SLOT_UNDERWEAR)
		human.underwear = name
	else
		human.underwear = "Nude"
	human.update_underwear(FALSE)
	human.update_body_parts()

/obj/item/clothing/underwear/briefs/dropped(mob/living/user)
	. = ..()
	if(!istype(user, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/human = user
	if(human.syncing_extra_inventory)
		return
	human.underwear = "Nude"
	human.update_underwear(FALSE)
	human.update_body_parts()
