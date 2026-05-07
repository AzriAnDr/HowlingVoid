/obj/effect/portal/permanent/one_way/reebe
	name = "whirring portal"
	desc = "A tall, glowing portal. A low emination of moving cogs can be heard. You don't feel like coming back will be the easiest."
	id = "reebe_entry"
	color = "#fcbe03"


/obj/effect/portal/permanent/one_way/reebe/clock_only // Portal that only lets clock cultists through, so they get their head start.
	name = "loudly whirring portal"
	/// If this prevents non-clockies from entering
	var/clock_only = TRUE


/obj/effect/portal/permanent/one_way/reebe/clock_only/teleport(atom/movable/movable, force)
	if(!ismob(movable))
		return FALSE

	var/mob/movable_mob = movable

	if(!IS_CLOCK(movable_mob) && clock_only && !isobserver(movable_mob))
		to_chat(movable_mob, span_warning("An invisble force pushes you back as you try to approach [src]!"))
		return FALSE

	return ..()


/obj/effect/portal/permanent/one_way/reebe/leaving
	desc = "For those who wish or require to leave the holy outpost."
	id = "reebe_exit"


/obj/effect/portal/permanent/one_way/reebe/leaving/set_linked()
	hard_target = get_safe_random_station_turf()


/obj/effect/portal/permanent/one_way/reebe/leaving/teleport(atom/movable/movable, force)
	to_chat(movable, span_notice("You prepare yourself to enter [src]..."))

	if(!do_after(movable, 4 SECONDS))
		return FALSE

	return ..()

/obj/effect/portal/clockcult
	name = "dimensional anomaly"
	desc = "A dimensional anomaly. It feels warm to the touch, and has a gentle puff of steam emanating from it."
	icon = 'icons/obj/anomaly.dmi'
	icon_state = "bhole3"
	mech_sized = TRUE
	density = TRUE
	force_teleport = TRUE
	var/static/list/possible_targets

/obj/effect/portal/clockcult/Initialize(mapload, _lifespan = 0, obj/effect/portal/_linked, automatic_link = FALSE, turf/hard_target_override)
	. = ..()
	if(!possible_targets)
		possible_targets = list()
		for(var/obj/effect/landmark/late_cog_portals/portal_mark in GLOB.landmarks_list)
			possible_targets += portal_mark

	if(length(possible_targets))
		hard_target = get_turf(pick(possible_targets))
		return

	hard_target = get_clock_reebe_turf()

/obj/effect/portal/clockcult/Bumped(atom/movable/bumper)
	. = ..()
	teleport(bumper)

/obj/effect/portal/clockcult/teleport(atom/movable/teleported_atom, force = FALSE, pull_loop = FALSE)
	if(isliving(teleported_atom))
		if(pull_loop)
			return

		to_chat(teleported_atom, span_notice("You begin climbing into the rift."))
		if(!do_after(teleported_atom, 5 SECONDS, target = src))
			return

		var/mob/living/teleported_living = teleported_atom
		if(teleported_living.pulling)
			teleport(teleported_living.pulling, TRUE)

		if(teleported_living.client)
			var/client_color = teleported_living.client.color
			teleported_living.client.color = "#BE8700"
			animate(teleported_living.client, color = client_color, time = 2.5 SECONDS)
		var/prev_alpha = teleported_atom.alpha
		teleported_atom.alpha = 0
		animate(teleported_atom, alpha = prev_alpha, time = 1 SECONDS)
	return ..()
