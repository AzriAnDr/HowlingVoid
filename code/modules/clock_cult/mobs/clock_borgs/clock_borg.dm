/mob/living/silicon/robot
	var/clockwork = FALSE
	var/obj/item/clockwork/clockwork_slab/internal_clock_slab

/mob/living/silicon/robot/proc/set_clockwork(clockwork_state, rebuild = TRUE)
	clockwork = clockwork_state
	if(rebuild)
		model?.rebuild_modules()
	update_icons()
	if(clockwork)
		set_light_color(LIGHT_COLOR_CLOCKWORK)
		scrambledcodes = TRUE
		set_connected_ai(null)
		lawupdate = FALSE
		if(!istype(laws, /datum/ai_laws/ratvar))
			QDEL_NULL(laws)
			laws = new /datum/ai_laws/ratvar()
		laws.associate(src)
		if(!internal_clock_slab)
			internal_clock_slab = new /obj/item/clockwork/clockwork_slab(src)
	else
		scrambledcodes = FALSE
		QDEL_NULL(internal_clock_slab)

/mob/living/silicon/robot/Destroy()
	QDEL_NULL(internal_clock_slab)
	return ..()

/obj/item/robot_suit
	var/be_clockwork = FALSE

/obj/item/robot_suit/prebuilt/clockwork
	name = "Clockwork Cyborg Endoskeleton"
	desc = "Is that a steam exhaust port?"
	color = rgb(190, 135, 0)
	be_clockwork = TRUE
