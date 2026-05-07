/obj/machinery/door/train
	name = "Train door"

/obj/machinery/door/train/lock()
	. = ..()
	locked = TRUE

/obj/machinery/door/train/unlock()
	. = ..()
	locked = FALSE

/obj/machinery/door/train/open(forced)
	if(locked)
		if(usr)
			balloon_alert(usr, "Locked!")
			to_chat(usr, "Door is locked from other side!")
		return
	return ..()

/obj/machinery/door/train/close(forced)
	if(locked)
		if(usr)
			balloon_alert(usr, "Locked!")
			to_chat(usr, "Door is locked!")
		return
	return ..()

/obj/machinery/door/train/train_door
	name = "Train door"
	desc = "A solid metal door, often used in train carriages."
	icon = 'icons/obj/doors/train/train_door.dmi'
	has_access_panel = FALSE
	opacity = FALSE

/obj/machinery/door/train/train_door/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/redirect_attack_hand_from_turf, interact_check = CALLBACK(src, PROC_REF(drag_check)))

/obj/machinery/door/train/train_door/proc/drag_check(mob/user)
	if(user.pulling)
		return FALSE
	return TRUE

/obj/machinery/door/train/train_door/animation_length(animation)
	switch(animation)
		if(DOOR_OPENING_ANIMATION)
			return 0.7 SECONDS
		if(DOOR_CLOSING_ANIMATION)
			return 0.8 SECONDS
		if(DOOR_DENY_ANIMATION)
			return 0.1 SECONDS

/obj/machinery/door/train/train_door/animation_segment_delay(animation)
	switch(animation)
		if(DOOR_OPENING_PASSABLE)
			return 0.7 SECONDS
		if(DOOR_OPENING_FINISHED)
			return 0.8 SECONDS
		if(DOOR_CLOSING_UNPASSABLE)
			return 0.2 SECONDS
		if(DOOR_CLOSING_FINISHED)
			return 0.7 SECONDS

/obj/machinery/door/airlock/train_locomotive
	name = "Train locomotive"
	desc = "A solid metal door, often used in train carriages."
	icon = 'icons/obj/doors/airlocks/train/locomotive_door.dmi'
	aiControlDisabled = AI_WIRE_DISABLED
	air_tight = TRUE

/obj/machinery/door/airlock/train_locomotive/glass
	icon = 'icons/obj/doors/airlocks/train/locomotive_door_glass.dmi'

/obj/machinery/door/train/coupe_door
	name = "Coupe door"
	desc = "A solid metal door, often used in train carriages."
	icon = 'icons/obj/doors/train/coupe_door.dmi'
	has_access_panel = FALSE
