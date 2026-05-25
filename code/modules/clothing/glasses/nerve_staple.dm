/obj/item/clothing/glasses/nerve_staple
	name = "\proper a nerve staple"
	desc = "A horrific looking device that is stapled into your face"
	icon = 'icons/obj/clothing/glasses_additions.dmi'
	icon_state = "nerve_staple"
	worn_icon = 'icons/mob/clothing/eyes_additions.dmi'
	worn_icon_state = "nerve_staple"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_traits = list(TRAIT_PACIFISM)

/obj/item/clothing/glasses/nerve_staple/Initialize(mapload)
	. = ..()
	if (prob(20))
		worn_icon_state = "[initial(worn_icon_state)]_r"

/obj/item/clothing/glasses/nerve_staple/equipped(mob/user, slot)
	. = ..()
	if (slot & ITEM_SLOT_EYES)
		ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)

/obj/item/clothing/glasses/nerve_staple/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
