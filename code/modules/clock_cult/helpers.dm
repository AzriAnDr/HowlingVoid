/proc/get_clock_reebe_turf()
	var/list/reebe_turfs = get_area_turfs(/area/ruin/powered/reebe)
	if(!length(reebe_turfs))
		return null

	for(var/i in 1 to 20)
		var/turf/picked_turf = pick(reebe_turfs)
		if(!picked_turf.is_blocked_turf(exclude_mobs = TRUE))
			return picked_turf

	return pick(reebe_turfs)

/proc/on_reebe(atom/checking_atom)
	return istype(get_area(checking_atom), /area/ruin/powered/reebe)

/proc/try_servant_warp(atom/movable/warped, turf/destination)
	if(!warped || !destination)
		return FALSE

	new /obj/effect/temp_visual/ratvar/warp(get_turf(warped))
	warped.forceMove(destination)
	new /obj/effect/temp_visual/ratvar/warp(destination)
	return TRUE
