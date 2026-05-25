/obj/item/target_designator/sniper
	name = "\improper Shot Caller"
	desc = "A target designator with a shorter acquisition duration and a singular turret limit, but capable of tagging targets at much further ranges."
	icon = 'icons/magfed_turret/designator.dmi'
	icon_state = "shot_caller"
	inhand_icon_state = "shot_caller"
	righthand_file = 'icons/magfed_turret/inhands/righthand.dmi'
	lefthand_file = 'icons/magfed_turret/inhands/righthand.dmi'
	worn_icon_state = "shot_caller"
	worn_icon = 'icons/magfed_turret/mob/belt.dmi'
	scan_range = 15
	turret_limit = 1
	acquisition_duration = 0.2 SECONDS //tbh i just wanted something that'd work better for getting icon showcases.
	target_all = FALSE
