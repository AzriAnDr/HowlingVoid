//Lavaland Ruins
//NOTICE: /unpowered means you never get power. Thanks Fikou

/area/ruin/powered/beach

/area/ruin/powered/lavaland_phone_booth
	name = "\improper Phone Booth"

/area/ruin/powered/clownplanet
	name = "\improper Clown Biodome"
	ambientsounds = list('sound/music/lobby_music/clown.ogg')

/area/ruin/unpowered/gaia
	name = "\improper Patch of Eden"

/area/ruin/powered/snow_biodome

/area/ruin/powered/gluttony

/area/ruin/powered/golem_ship
	name = "\improper Free Golem Ship"

/area/ruin/powered/greed

/area/ruin/unpowered/hierophant
	name = "\improper Hierophant's Arena"

/area/ruin/powered/pride

/area/ruin/powered/seedvault

/area/ruin/unpowered/elephant_graveyard
	name = "\improper Elephant Graveyard"

/area/ruin/powered/graveyard_shuttle
	name = "\improper Elephant Graveyard"

/area/ruin/syndicate_lava_base
	name = "\improper Secret Base"
	ambience_index = AMBIENCE_DANGER
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'
	always_unpowered = FALSE

/area/ruin/unpowered/cultaltar
	name = "\improper Cult Altar"
	area_flags = CULT_PERMITTED
	area_flags_mapping = NONE
	ambience_index = AMBIENCE_SPOOKY

/area/ruin/thelizardsgas_lavaland
	name = "\improper The Lizard's Gas"
	icon_state = "lizardgas"
	sound_environment = SOUND_ENVIRONMENT_ROOM
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'

//Syndicate lavaland base

/area/ruin/syndicate_lava_base/engineering
	name = "Interdyne Engineering"

/area/ruin/syndicate_lava_base/medbay
	name = "Interdyne Medbay"

/area/ruin/syndicate_lava_base/arrivals
	name = "Interdyne Arrivals"

/area/ruin/syndicate_lava_base/bar
	name = "\improper Interdyne Bar"

/area/ruin/syndicate_lava_base/lounge
	name = "\improper Interdyne Lounge"

/area/ruin/syndicate_lava_base/main
	name = "\improper Interdyne Primary Hallway"

/area/ruin/syndicate_lava_base/cargo
	name = "\improper Interdyne Cargo Bay"

/area/ruin/syndicate_lava_base/chemistry
	name = "Interdyne Chemistry"

/area/ruin/syndicate_lava_base/virology
	name = "Interdyne Virology"

/area/ruin/syndicate_lava_base/testlab
	name = "\improper Interdyne Experimentation Lab"
	area_flags = XENOBIOLOGY_COMPATIBLE
	area_flags_mapping = NONE

/area/ruin/syndicate_lava_base/dormitories
	name = "\improper Interdyne Dormitories"

/area/ruin/syndicate_lava_base/telecomms
	name = "\improper Interdyne Telecommunications"

/area/ruin/syndicate_lava_base/hydroponics
	name = "\improper Syndicate Lavaland Hydroponics"

//Xeno Nest

/area/ruin/unpowered/xenonest
	name = "The Hive"
	always_unpowered = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'

//ash walker nest
/area/ruin/unpowered/ash_walkers
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'
/area/ruin/unpowered/ratvar
	outdoors = TRUE
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'


// BEGIN NOVA CORE MIGRATION: code/game/area/areas/ruins/lavaland.dm
// Lavaland Ruins
// NOTICE: /unpowered means you never get power. Thanks Fikou!

// ASH WALKER MACHINES FIX
/area/ruin/unpowered/ash_walkers
	always_unpowered = FALSE
	power_equip = TRUE

// Interdyne planetary base

/area/ruin/interdyne_planetary_base // used as parent type and for turret control
	name = "Interdyne Pharmaceuticals Spinward Sector Base"
	icon = 'icons/area/areas_centcom.dmi'
	icon_state = "syndie-control"
	ambience_index = AMBIENCE_DANGER
	ambient_buzz = 'sound/ambience/lavaland/magma.ogg'
	area_flags = BLOBS_ALLOWED

/area/ruin/interdyne_planetary_base/cargo
	name = "Interdyne Cargo Bay"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "mining"

/area/ruin/interdyne_planetary_base/cargo/deck
	name = "Interdyne Deck Officer's Office"
	icon_state = "qm_office"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/ruin/interdyne_planetary_base/cargo/ware
	name = "Interdyne Warehouse"
	icon_state = "cargo_warehouse"

/area/ruin/interdyne_planetary_base/cargo/obs
	name = "Interdyne Observation Center"
	icon = 'icons/area/areas_centcom.dmi'
	icon_state = "observatory"
	ambience_index = AMBIENCE_DANGER

/area/ruin/interdyne_planetary_base/cargo/obs/Initialize(mapload)
	if(!ambientsounds)
		var/list/temp_ambientsounds = GLOB.ambience_assoc[ambience_index]
		ambientsounds = temp_ambientsounds.Copy()
		ambientsounds += list(
			'sound/random_ship_event/random_ships/heliostatic_inspectors/sounds/morse.ogg',
			'sound/ambience/engineering/ambitech.ogg',
			'sound/ambience/misc/signal.ogg',
			'sound/random_ship_event/random_ships/heliostatic_inspectors/sounds/morse.ogg',
		)
	return ..()

/area/ruin/interdyne_planetary_base/main
	name = "Interdyne Main Hall"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "hall"

/area/ruin/interdyne_planetary_base/main/vault
	name = "Interdyne Vault"
	icon = 'icons/area/areas_centcom.dmi'
	icon_state = "syndie-control"

/area/ruin/interdyne_planetary_base/main/dorms
	name = "Interdyne Dormitories"
	icon_state = "crew_quarters"

/area/ruin/interdyne_planetary_base/main/dorms/lib
	name = "Interdyne Library"
	icon_state = "library"
	mood_bonus = 5
	mood_message = "I love being in the base's library!"
	mood_trait = TRAIT_INTROVERT
	sound_environment = SOUND_AREA_WOODFLOOR

/area/ruin/interdyne_planetary_base/med
	name = "Interdyne Medical Wing"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "medbay"
	ambience_index = AMBIENCE_MEDICAL

/area/ruin/interdyne_planetary_base/med/pharm
	name = "Interdyne Pharmacy"
	icon_state = "pharmacy"

/area/ruin/interdyne_planetary_base/med/viro
	name = "Interdyne Virological Lab"
	icon_state = "virology"
	ambience_index = AMBIENCE_VIROLOGY

/area/ruin/interdyne_planetary_base/med/morgue
	name = "Interdyne Morgue"
	icon_state = "morgue"
	ambience_index = AMBIENCE_SPOOKY
	ambientsounds = list('sound/ambience/icemoon/ambiicemelody4.ogg') // creepy, but a bit wistful
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/ruin/interdyne_planetary_base/science
	name = "Interdyne Science Wing"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "science"

/area/ruin/interdyne_planetary_base/science/xeno
	name = "Interdyne Xenobiological Lab"
	icon_state = "xenobio"

/area/ruin/interdyne_planetary_base/serv
	name = "Interdyne Service Wing"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "hall_service"

/area/ruin/interdyne_planetary_base/serv/rstrm
	name = "Interdyne Unisex Restrooms"
	icon_state = "toilet"

/area/ruin/interdyne_planetary_base/serv/bar
	name = "Interdyne Bar"
	icon_state = "bar"
	mood_bonus = 5
	mood_message = "I love being in the base's bar!"
	mood_trait = TRAIT_EXTROVERT

/area/ruin/interdyne_planetary_base/serv/kitchen
	name = "Interdyne Kitchen"
	icon_state = "kitchen"

/area/ruin/interdyne_planetary_base/serv/hydr
	name = "Interdyne Hydroponics"
	icon_state = "hydro"

/area/ruin/interdyne_planetary_base/eng
	name = "Interdyne Engineering"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "maint_electrical" // given interdyne's powerplant is rtg's, thought this looked good on the frontend for mappers
	ambient_buzz = 'sound/random_ship_event/random_ships/heliostatic_inspectors/sounds/gear_loop.ogg'

/area/ruin/interdyne_planetary_base/eng/Initialize(mapload)
	if(!ambientsounds)
		var/list/temp_ambientsounds = GLOB.ambience_assoc[ambience_index]
		ambientsounds = temp_ambientsounds.Copy()
		ambientsounds += list(
			'sound/items/geiger/low1.ogg',
			'sound/items/geiger/low2.ogg',
		)
	return ..()

/area/ruin/interdyne_planetary_base/eng/disp
	name = "Interdyne Disposals"
	icon_state = "disposal"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

//The prefab colonist homestead. Dependent on the colony_fabricator module.
/area/ruin/colonist_homestead
	name = "Colonist Homestead"
// END NOVA CORE MIGRATION: code/game/area/areas/ruins/lavaland.dm
