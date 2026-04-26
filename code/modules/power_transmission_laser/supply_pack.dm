/**
 * # Power Transmission Laser Supply Packs
 *
 * Cargo crates for ordering PTL and Laser Terminal parts.
 */

/datum/supply_pack/engineering/transmission_laser
	name = "Power Transmission Laser Crate"
	desc = "Contains the circuit board and components needed to construct a Power Transmission Laser. Requires station goal."
	cost = CARGO_CRATE_VALUE * 20
	order_flags = ORDER_SPECIAL
	access_view = ACCESS_COMMAND
	contains = list(
		/obj/item/circuitboard/machine/transmission_laser,
		/obj/item/stock_parts/capacitor/quadratic = 3,
		/obj/item/stock_parts/micro_laser/quadultra = 3,
	)
	crate_name = "power transmission laser crate"

/datum/supply_pack/engineering/laser_terminal
	name = "Laser Terminal Crate"
	desc = "Contains the circuit board and components to construct a Laser Terminal for receiving PTL power remotely. Requires station goal."
	cost = CARGO_CRATE_VALUE * 8
	order_flags = ORDER_SPECIAL
	access_view = ACCESS_COMMAND
	contains = list(
		/obj/item/circuitboard/machine/laser_terminal = 2,
		/obj/item/stock_parts/capacitor/quadratic = 4,
		/obj/item/stack/cable_coil = 2,
	)
	crate_name = "laser terminal crate"