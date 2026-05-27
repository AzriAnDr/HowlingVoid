// Atmos types used for planetary airs
/datum/atmosphere/lavaland
	id = LAVALAND_DEFAULT_ATMOS

	base_gases = list(
		/datum/gas/oxygen=5,
		/datum/gas/nitrogen=10,
	)
	normal_gases = list(
		/datum/gas/oxygen=10,
		/datum/gas/nitrogen=10,
		/datum/gas/carbon_dioxide=10,
	)
	restricted_gases = list(
		/datum/gas/plasma=0.1,
		/datum/gas/bz=1.2,
		/datum/gas/miasma=1.2,
		/datum/gas/water_vapor=0.1,
	)
	restricted_chance = 0	// NOVA EDIT: Disables restricted gases from rolling - Original value (30)

	minimum_pressure = HAZARD_LOW_PRESSURE + 10
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1

	minimum_temp = BODYTEMP_COLD_DAMAGE_LIMIT + 1
	maximum_temp = LAVALAND_MAX_TEMPERATURE

/datum/atmosphere/icemoon
	id = ICEMOON_DEFAULT_ATMOS

	base_gases = list(
		/datum/gas/oxygen=5,
		/datum/gas/nitrogen=10,
	)
	normal_gases = list(
		/datum/gas/oxygen=10,
		/datum/gas/nitrogen=10,
		/datum/gas/carbon_dioxide=10,
	)
	restricted_gases = list(
		/datum/gas/plasma=0.1,
		/datum/gas/water_vapor=0.1,
		/datum/gas/miasma=1.2,
	)
	restricted_chance = 0	// NOVA EDIT: Disables restricted gases from rolling - Original value (20)

	minimum_pressure = HAZARD_LOW_PRESSURE + 10
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1

	minimum_temp = ICEBOX_MIN_TEMPERATURE
	maximum_temp = ICEBOX_MIN_TEMPERATURE



// BEGIN NOVA CORE MIGRATION: code/datums/atmosphere/planetary.dm
/// Safe planet atmos is here incase people want to make planetside stations with safe atmospherics. PLEASE MAKE A CUSTOM ONE IF YOU ARE HAVING UNIQUE PLANET ATMOS

#define SAFE_PLANET_PRESSURE 101 // In case you want your planet to be base atmospheric pressure. This is safe pressure
#define SAFE_PLANET_TEMPERATURE 297 // In Degrees its 72*F and 23*C
#define SAFE_PLANET_ATMOS "SAFE_PLANET_ATMOS" // Just the ID of the atmos planet, its highly suggested you use defines for this.

/datum/atmosphere/safe_planet
	id = SAFE_PLANET_ATMOS

	base_gases = list(
		/datum/gas/oxygen=5,
		/datum/gas/nitrogen=10,
	)
	normal_gases = list(
		/datum/gas/oxygen=10,
		/datum/gas/carbon_dioxide=0.4,
	)
	restricted_gases = list(
	)
	restricted_chance = 0

	minimum_pressure = SAFE_PLANET_PRESSURE
	maximum_pressure = SAFE_PLANET_PRESSURE

	minimum_temp = SAFE_PLANET_TEMPERATURE - 5
	maximum_temp = SAFE_PLANET_TEMPERATURE + 5
// END NOVA CORE MIGRATION: code/datums/atmosphere/planetary.dm
