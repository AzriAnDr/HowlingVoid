GLOBAL_DATUM(cult_ratvar, /obj/ratvar)

/obj/ratvar
	name = "Ratvar, the Clockwork Justiciar"
	desc = "Ratvar has risen."
	icon = 'icons/clock_cult/ratvar_512.dmi'
	icon_state = "ratvar"
	anchored = TRUE
	density = FALSE
	pixel_x = -236
	pixel_y = -256
	light_color = COLOR_THEME_CLOCKWORK
	light_power = 1
	move_resist = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	var/ending_started = FALSE

/obj/ratvar/Initialize(mapload)
	. = ..()
	GLOB.cult_ratvar = src
	set_light(20, 1, COLOR_THEME_CLOCKWORK)
	SSpoints_of_interest.make_point_of_interest(src)
	log_game("!!! RATVAR HAS RISEN. !!!")
	sound_to_playing_players('sound/clock_cult/effects/ratvar_reveal.ogg', 100)
	send_to_playing_players(span_reallybig(span_brass("The bluespace veil gives way to Ratvar. His light shall shine upon all mortals!")))
	SSshuttle.registerHostileEnvironment(src)
	addtimer(CALLBACK(src, PROC_REF(clockcult_ending_start)), 5 SECONDS)

/obj/ratvar/Destroy(force)
	if(GLOB.cult_ratvar == src)
		GLOB.cult_ratvar = null
	return ..()

/obj/ratvar/proc/clockcult_ending_start()
	if(ending_started)
		return
	ending_started = TRUE
	SSsecurity_level.set_level(SEC_LEVEL_DELTA)
	priority_announce("Huge gravitational-energy spike detected near [station_name()]. Event survival chance is estimated at 0%.", "Central Command Anomalous Materials Division")
	addtimer(CALLBACK(src, PROC_REF(clockcult_final_ending)), 60 SECONDS)

/obj/ratvar/proc/clockcult_final_ending()
	sound_to_playing_players('sound/clock_cult/effects/ratvar_rises.ogg', 100)
	for(var/mob/living/lit_mob as anything in GLOB.mob_living_list)
		if(IS_CLOCK(lit_mob))
			continue
		lit_mob.fire_stacks = 100
		lit_mob.ignite_mob()
		lit_mob.emote("scream")

	SSticker.force_ending = TRUE
