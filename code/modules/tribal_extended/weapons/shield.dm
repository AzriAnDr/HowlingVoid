/obj/item/shield/goliath
	name = "goliath shield"
	desc = "A shield made from interwoven plates of goliath hide."
	icon = 'icons/tribal_extended/shields.dmi'
	icon_state = "goliath_shield"
	lefthand_file = 'icons/tribal_extended/shields_lefthand.dmi'
	righthand_file = 'icons/tribal_extended/shields_righthand.dmi'
	worn_icon = 'icons/tribal_extended/back.dmi'
	worn_icon_state = "goliath_shield"
	inhand_icon_state = "goliath_shield"
	max_integrity = 200
	w_class = WEIGHT_CLASS_BULKY
	shield_break_sound = 'sound/effects/bang.ogg'
	shield_break_leftover = /obj/item/stack/sheet/animalhide/goliath_hide
	resistance_flags = FIRE_PROOF | LAVA_PROOF
	custom_materials = list(/datum/material/bone = SHEET_MATERIAL_AMOUNT * 4)
