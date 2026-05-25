/turf/open/indestructible/reebe_void
	name = "void"
	desc = "A white, empty void, quite unlike anything you've seen before."
	icon_state = "reebemap"
	layer = SPACE_LAYER
	baseturfs = /turf/open/indestructible/reebe_void
	planetary_atmos = TRUE
	bullet_bounce_sound = null //forever falling
	tiled_turf = FALSE


/turf/open/indestructible/reebe_void/Initialize(mapload)
	. = ..()
	icon_state = "reebegame"


/turf/open/indestructible/reebe_void/Enter(atom/movable/movable, atom/old_loc)
	if(!..())
		return FALSE
	else
		if(istype(movable, /obj/structure/window))
			return FALSE
		if(istype(movable, /obj/projectile))
			return TRUE
		return FALSE


/turf/open/indestructible/reebe_void/spawning
	icon_state = "reebespawn"


/turf/open/indestructible/reebe_void/spawning/Initialize(mapload)
	. = ..()
	if(mapload)
		for(var/i in 1 to 3)
			if(prob(1))
				new /obj/structure/fluff/clockwork/alloy_shards/large(src)

			if(prob(2))
				new /obj/structure/fluff/clockwork/alloy_shards/medium(src)

			if(prob(3))
				new /obj/structure/fluff/clockwork/alloy_shards/small(src)

/turf/open/indestructible/reebe_void/spawning/lattices
	icon_state = "reebelattice"

/turf/open/indestructible/reebe_void/spawning/lattices/Initialize(mapload)
	. = ..()
	if(mapload)
		if(prob(95) && !(locate(/obj/structure/lattice) in loc)) // Don't try putting a lattice where one already exists or we can get runtimes
			new /obj/structure/lattice/clockwork(src)

/turf/open/indestructible/reebe_flooring
	name = "clockwork floor"
	desc = "You feel a faint warmth from below it."
	icon_state = "clockwork_floor"
	planetary_atmos = TRUE
	baseturfs = /turf/open/indestructible/reebe_flooring
	turf_flags = NOJAUNT

/turf/open/indestructible/reebe_flooring/proc/ratvar_act()
	return FALSE

/turf/open/indestructible/reebe_flooring/flat
	icon_state = "reebe"

/turf/open/indestructible/reebe_flooring/filled
	icon_state = "clockwork_floor_filled"

/turf/open/floor/engine/clockwork
	name = "clockwork floor"
	desc = "You feel a faint warmth from below it."
	icon_state = "clockwork_floor"

/turf/closed/wall/clockwork
	name = "clockwork wall"
	desc = "A forboding clump of gears that turn on their own. A faint glow emanates from within."
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	icon_state = "clockwork_wall-0"
	base_icon_state = "clockwork_wall"
	smoothing_flags = SMOOTH_BITMASK
	sheet_type = /obj/item/stack/sheet/bronze
	sheet_amount = 2
	girder_type = /obj/structure/girder/bronze
	turf_flags = NOJAUNT
	hardness = 3

/turf/closed/wall/clockwork/proc/ratvar_act()
	return FALSE

/turf/closed/wall/clockwork/rust_heretic_act(rust_strength)
	visible_message(span_warning("\The [src] glows for a second, but is unaffected by the magic!"))
	return

/turf/closed/wall/clockwork/reebe
	baseturfs = /turf/open/indestructible/reebe_flooring
