/obj/item/fireproof_spray
	name = "fireproof spray"
	desc = "A miraculous (lead free!) spray mix that will fireproof any article of clothing. A warning label denotes it won't work for prolonged extreme temperatures."
	icon = 'icons/fireproof_spray/fireproof_spray.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	icon_state = "fireproof_spray"
	resistance_flags = FIRE_PROOF
	/// The number of uses left in the spray.
	var/uses = 2

/obj/item/fireproof_spray/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	if(uses <= 0)
		to_chat(user, span_warning("The spraycan is empty!"))
		return ITEM_INTERACT_BLOCKING

	var/obj/item/clothing/clothing = interacting_with
	if(!istype(clothing))
		to_chat(user, span_warning("The spray only works on clothing!"))
		return ITEM_INTERACT_BLOCKING
	if(clothing.resistance_flags & FIRE_PROOF)
		to_chat(user, span_warning("[clothing] is already fireproof, you don't want to waste the spray!"))
		return ITEM_INTERACT_BLOCKING
	if(clothing.get_armor_rating(BULLET) > 1 || clothing.get_armor_rating(ENERGY) > 1)
		to_chat(user, span_warning("[clothing] is lined with armored plates so the spray won't work on this, said armor prevents the solution from adhering correctly! You smartly don't waste the spray."))
		return ITEM_INTERACT_BLOCKING

	to_chat(user, span_notice("You spray all over [clothing], ensuring it won't burn too much."))
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 5)
	clothing.AddComponent(/datum/component/spray_fireproofed, immunity_time = HAS_TRAIT_FROM(clothing, TRAIT_ITEM_OBJECTIVE_BLOCKED, "Loadout") ? -1 : 60 SECONDS)
	uses--
	return ITEM_INTERACT_SUCCESS

/obj/item/fireproof_spray/examine(mob/user)
	. = ..()
	if(uses > 0)
		. += span_notice("It has [uses] use\s left.")
	else
		. += span_warning("It is empty.")
