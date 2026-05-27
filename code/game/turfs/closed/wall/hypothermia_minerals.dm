/turf/closed/mineral/random/icy_planet
	name = "rock"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "icerock_wall"
	baseturfs = /turf/open/misc/icy_planet/snow
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	mineralChance = 5
	proximity_based = FALSE

/turf/closed/mineral/random/icy_planet/mineral_chances()
	return list(
		/obj/item/stack/ore/gold = 1,
		/obj/item/stack/ore/iron = 30,
		/obj/item/stack/ore/silver = 6,
		/obj/item/stack/ore/titanium = 2,
		/obj/item/stack/ore/uranium = 1,
	)

/turf/closed/mineral/random/icy_planet/snow
	name = "snowy mountainside"
	icon = MAP_SWITCH('icons/turf/walls/mountain_wall.dmi', 'icons/turf/mining.dmi')
	icon_state = "mountainrock"
	base_icon_state = "mountain_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS

/turf/closed/mineral/random/icy_planet/cave
	name = "mountainside"
	icon = MAP_SWITCH('icons/liquids/turf/smoothrocks.dmi', 'icons/turf/mining.dmi')
	icon_state = "rock"
	smoothing_groups = SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_MINERAL_WALLS
	canSmoothWith = SMOOTH_GROUP_MINERAL_WALLS
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	baseturfs = /turf/open/misc/dirt/station
