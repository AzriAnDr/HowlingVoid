/turf/open/openspace/icy_planet
	planetary_atmos = TRUE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	can_build_on = FALSE
	baseturfs = /turf/open/openspace/icy_planet

/turf/open/misc/dirt/icy_planet
	planetary_atmos = TRUE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	baseturfs = /turf/open/misc/dirt/icy_planet

/turf/open/misc/icy_planet
	planetary_atmos = TRUE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	flags_1 = NO_SCREENTIPS_1 | CAN_BE_DIRTY_1
	turf_flags = IS_SOLID | NO_RUST | NO_RUINS
	underfloor_accessibility = UNDERFLOOR_VISIBLE

/turf/open/chasm/icy_planet
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/chasm/icy_planet

/turf/open/misc/icy_planet/snow
	gender = PLURAL
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/event/hypothermia_snow.dmi'
	baseturfs = /turf/open/misc/icy_planet/snow
	icon_state = "snow_2_1"
	base_icon_state = "snow"
	slowdown = 2
	bullet_sizzle = TRUE
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/misc/icy_planet/snow/Initialize(mapload)
	. = ..()
	icon_state = "snow_" + pick_weight(list(
		pick_weight(list(
			"2_1" = 5,
			"2_2" = 5,
			"2_3" = 5,
			"2_4" = 5,
			"2_5" = 5,
			"2_6" = 5
		)) = 90,
		pick_weight(list(
			"1_1" = 5,
			"1_2" = 5,
			"1_3" = 5,
			"1_4" = 5,
			"1_5" = 5,
			"1_6" = 5
		)) = 15
	))
	AddElement(/datum/element/diggable, /obj/item/stack/sheet/mineral/snow, 2)

/turf/open/misc/icy_planet/ice
	gender = NEUTER
	name = "ice"
	desc = "Thin, slippery ice. Watch your step."
	icon = 'icons/turf/event/hypothermia_snow.dmi'
	damaged_dmi = 'icons/turf/event/hypothermia_snow.dmi'
	baseturfs = /turf/open/misc/icy_planet/snow
	icon_state = "ice"
	base_icon_state = "ice"
	slowdown = 1.5
	bullet_sizzle = TRUE
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/misc/icy_planet/ice/Initialize(mapload)
	. = ..()
	icon_state = "ice" + pick_weight(list(
		"1" = 70,
		"cracked" = 30
	))
	AddComponent(/datum/component/slippery, 4 SECONDS, lube_flags = NONE, floor_type = src, silent = FALSE)

/turf/open/misc/icy_planet/ice_cave_floor
	name = "frozen cave floor"
	desc = "A thin layer of ice over rocky ground. Echoey and cold."
	icon = 'icons/turf/event/hypothermia_snow.dmi'
	icon_state = "ice_cave"
	base_icon_state = "ice_cave"
	baseturfs = /turf/open/misc/icy_planet/ice_cave_floor
	slowdown = 1

/turf/open/misc/icy_planet/ice_cave_floor/Initialize(mapload)
	. = ..()
	air.temperature = T0C - 90
