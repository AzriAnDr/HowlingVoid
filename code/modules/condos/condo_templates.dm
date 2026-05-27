/*
HEY!!! LISTEN!!!
Due to some fuckery with how these templates work; the bottom left turf of your map HAS to touch the rest AND has to be on the same /area/.
*/

/datum/map_template/condo
	/// Public category shown in the condo teleporter UI.
	var/category = "Condo"
	/// Offset from the bottom-left turf of your condo. Said turf MUST touch the rest of your condo due to how these templates are loaded; including in /area/.
	var/landing_zone_x_offset
	var/landing_zone_y_offset

/datum/map_template/condo/proc/get_public_name()
	return replacetext(name, "Condo - ", "")

/// Keep these alphabetical.

/datum/map_template/condo/alleyway
	name = "Condo - Alleyway"
	mappath = "_maps/condos/alleyway.dmm"
	landing_zone_x_offset = 2
	landing_zone_y_offset = 5

/datum/map_template/condo/apartment
	name = "Condo - Apartment"
	mappath = "_maps/condos/apartment.dmm"
	landing_zone_x_offset = 2
	landing_zone_y_offset = 8

/datum/map_template/condo/blueshift_dorms_four
	name = "Condo - \"Blueshift\" Style Dormitory"
	mappath = "_maps/condos/blueshift_dormsfour.dmm"
	landing_zone_x_offset = 2
	landing_zone_y_offset = 2

/// Wowee! It's like I'm a real terrorist!
/// This particular one was cooler with wallening window frames and short stairs.. alas. twas not to be
/datum/map_template/condo/dstwo_condo
	name = "Condo - Authentic DS-2 Theming"
	mappath = "_maps/condos/dstwo_condo.dmm"
	landing_zone_x_offset = 7
	landing_zone_y_offset = 2

/datum/map_template/condo/beach_condo
	name = "Condo - Beachside"
	mappath = "_maps/condos/beach_condo.dmm"
	landing_zone_x_offset = 7
	landing_zone_y_offset = 2

/datum/map_template/condo/gm_condo
	name = "Condo - Suite"
	mappath = "_maps/condos/gm_condo.dmm"
	landing_zone_x_offset = 4
	landing_zone_y_offset = 2

/// This version's actually slightly different to justify itself; being based off the wallening version.
/datum/map_template/condo/hilberts_hotel
	name = "Condo - Hilbert's Hotel Room"
	mappath = "_maps/condos/hilbertshotel.dmm"
	landing_zone_x_offset = 2
	landing_zone_y_offset = 12

/datum/map_template/condo/lodge_pool
	name = "Condo - Lodge's Pool"
	mappath = "_maps/condos/lodge_pool.dmm"
	landing_zone_x_offset = 10
	landing_zone_y_offset = 1

/datum/map_template/condo/manor_hall
	name = "Condo - Manor Hall"
	mappath = "_maps/condos/manor_hall.dmm"
	landing_zone_x_offset = 1
	landing_zone_y_offset = 3

/datum/map_template/condo/medieval_bog
	name = "Condo - Medieval Bog"
	mappath = "_maps/condos/medieval_bog.dmm"
	landing_zone_x_offset = 1
	landing_zone_y_offset = 3

/datum/map_template/condo/necropolis
	name = "Condo - Necropolis"
	mappath = "_maps/condos/necropolis.dmm"
	landing_zone_x_offset = 2
	landing_zone_y_offset = 11

/datum/map_template/condo/ocean_view
	name = "Condo - Ocean View"
	mappath = "_maps/condos/ocean_view.dmm"
	landing_zone_x_offset = 7
	landing_zone_y_offset = 1

/datum/map_template/condo/ouroboros_dorms_four
	name = "Condo - \"Ouroboros\" Style Dormitory"
	mappath = "_maps/condos/ouroboros_dormssix.dmm"
	landing_zone_x_offset = 2
	landing_zone_y_offset = 4

/// The joke was originally that it was just flatgrass. Now it's a little more.
/datum/map_template/condo/planar_soil
	name = "Condo - Planar Soil"
	mappath = "_maps/condos/planar_soil.dmm"
	landing_zone_x_offset = 7
	landing_zone_y_offset = 1

/datum/map_template/condo/serenity_cabin_four
	name = "Condo - \"Serenity\" Style Cabin"
	mappath = "_maps/condos/serenity_cabinfour.dmm"
	landing_zone_x_offset = 3
	landing_zone_y_offset = 1

/datum/map_template/condo/snowglobe_dorms_four
	name = "Condo - \"Snowglobe\" Style Dormitory"
	mappath = "_maps/condos/snowglobe_dormsfour.dmm"
	landing_zone_x_offset = 6
	landing_zone_y_offset = 3

/datum/map_template/condo/station_arrivals
	name = "Condo - Arrivals Checkpoint"
	mappath = "_maps/condos/station_arrivals.dmm"
	landing_zone_x_offset = 2
	landing_zone_y_offset = 2

/datum/map_template/condo/xeno_resin
	name = "Condo - XenoResin"
	mappath = "_maps/condos/xeno_resin.dmm"
	landing_zone_x_offset = 2
	landing_zone_y_offset = 1

/datum/map_template/condo/cabin_woods
	name = "Condo - Cabin In The Woods"
	mappath = "_maps/condos/cabin_woods.dmm"
	landing_zone_x_offset = 2
	landing_zone_y_offset = 1

/datum/map_template/condo/ship_bridge
	name = "Condo - Spaceship Bridge"
	mappath = "_maps/condos/ship_bridge.dmm"
	landing_zone_x_offset = 2
	landing_zone_y_offset = 8

/datum/map_template/condo/public_library
	name = "Condo - Public Library"
	mappath = "_maps/condos/public_library.dmm"
	landing_zone_x_offset = 7
	landing_zone_y_offset = 1

/datum/map_template/condo/mountainside_apartment
	name = "Condo - Mountainside Apartment"
	mappath = "_maps/condos/apartment_mountainside.dmm"
	landing_zone_x_offset = 14
	landing_zone_y_offset = 4

/datum/map_template/condo/mountainside_fortuneteller
	name = "Condo - Fortune Teller Apartment"
	mappath = "_maps/condos/apartment_fortuneteller.dmm"
	landing_zone_x_offset = 5
	landing_zone_y_offset = 8

/datum/map_template/condo/mountainside_skyscraper
	name = "Condo - Skyscraper"
	mappath = "_maps/condos/apartment_skyscraper.dmm"
	landing_zone_x_offset = 17
	landing_zone_y_offset = 3

/datum/map_template/condo/mountainside_dragonlair
	name = "Condo - Dragon's Lair"
	mappath = "_maps/condos/apartment_dragonslair.dmm"
	landing_zone_x_offset = 5
	landing_zone_y_offset = 11

/datum/map_template/condo/deepspace_ship
	name = "Condo - Deepspace Ship"
	mappath = "_maps/condos/ship_apartment.dmm"
	landing_zone_x_offset = 9
	landing_zone_y_offset = 2

/datum/map_template/condo/deepspace_pod
	name = "Condo - Deepspace Pod"
	mappath = "_maps/condos/deepspace_pod.dmm"
	landing_zone_x_offset = 1
	landing_zone_y_offset = 2
