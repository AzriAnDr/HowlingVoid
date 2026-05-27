/obj/item/shield/riot/pointman/nri
	name = "heavy corpsman shield"
	desc = "A shield designed for people that have to sprint to the rescue. Cumbersome as hell. Repair with plasteel."
	icon_state = "riot"
	icon = 'icons/novaya_ert/riot.dmi'
	lefthand_file = 'icons/novaya_ert/riot_left.dmi'
	righthand_file = 'icons/novaya_ert/riot_right.dmi'
	transparent = FALSE
	shield_break_leftover = /obj/item/corpsman_broken

/obj/item/corpsman_broken
	name = "broken corpsman shield"
	desc = "Might be able to be repaired with a welder."
	icon_state = "riot_broken"
	icon = 'icons/novaya_ert/riot.dmi'
	w_class = WEIGHT_CLASS_BULKY

/obj/item/corpsman_broken/welder_act(mob/living/user, obj/item/I)
	..()
	new /obj/item/shield/riot/pointman/nri((get_turf(src)))
	qdel(src)
