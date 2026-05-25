/*
Unused icons for new areas are "awaycontent1" ~ "awaycontent30"
*/


// Away Missions
/area/awaymission
	name = "Strange Location"
	icon = 'icons/area/areas_away_missions.dmi'
	icon_state = "away"
	default_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_AWAY
	sound_environment = SOUND_ENVIRONMENT_ROOM

/// Gulag

/area/awaymission/outdoors
	name = "Outdoors"

/area/awaymission/survivors
	name = "Survivors Territory"

/area/awaymission/survivors/house
	name = "Survivors House"

/area/awaymission/survivors/shuttle
	name = "Survivors Shuttle"
	requires_power = FALSE

/area/awaymission/survivors/base
	name = "Survivors Base"
	requires_power = FALSE

/area/awaymission/village
	name = "Village"
	requires_power = FALSE

/area/awaymission/huge_church
	name = "Large Church"
	requires_power = FALSE

/area/awaymission/gulag
	name = "Gulag"
	requires_power = FALSE

/area/awaymission/gulag/laboratory
	name = "Gulag Laboratory"

/area/awaymission/gen_laboratory
	name = "Genetic Laboratory"

/area/awaymission/mining_base
	name = "Mining Base"

/area/awaymission/mining_base/security_post
	name = "Mining Base Guard Post"
	requires_power = FALSE

/area/awaymission/mining_base/hangar
	name = "Mining Base Hangar"
	requires_power = FALSE

/area/awaymission/museum
	name = "Nanotrasen Museum"
	icon_state = "awaycontent28"
	sound_environment = SOUND_ENVIRONMENT_CONCERT_HALL

/area/awaymission/museum/mothroachvoid
	static_lighting = FALSE
	base_lighting_alpha = 200
	base_lighting_color = "#FFF4AA"
	sound_environment = SOUND_ENVIRONMENT_PLAIN
	ambientsounds = list('sound/ambience/beach/shore.ogg', 'sound/ambience/misc/ambiodd.ogg','sound/ambience/medical/ambinice.ogg')

/area/awaymission/museum/cafeteria
	name = "Nanotrasen Museum Cafeteria"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/awaymission/errorroom
	name = "Super Secret Room"
	static_lighting = FALSE
	base_lighting_alpha = 255
	area_flags = NOTELEPORT
	default_gravity = STANDARD_GRAVITY

/area/awaymission/secret
	area_flags = NOTELEPORT|HIDDEN_AREA

/area/awaymission/secret/unpowered
	always_unpowered = TRUE

/area/awaymission/secret/unpowered/outdoors
	outdoors = TRUE

/area/awaymission/secret/unpowered/no_grav
	default_gravity = ZERO_GRAVITY

/area/awaymission/secret/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/awaymission/secret/powered
	requires_power = FALSE

/area/awaymission/secret/powered/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255


/// Backrooms

/area/awaymission/backrooms
	icon_state = "unknown"
	requires_power = FALSE

/area/awaymission/backrooms/level_one
	name = "Level 1"
	icon_state = "away1"

/area/awaymission/backrooms/level_two
	name = "Level 2"
	icon_state = "away2"

/area/awaymission/backrooms/level_three
	name = "Level 3"
	icon_state = "away3"


// BEGIN NOVA CORE MIGRATION: code/game/area/areas/away_content.dm
/area/awaymission
	area_flags = NOTELEPORT
// END NOVA CORE MIGRATION: code/game/area/areas/away_content.dm
