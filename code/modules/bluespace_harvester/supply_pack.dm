/**
 * Bluespace Harvester Supply Pack
 *
 * Cargo crate containing the bluespace harvester parts.
 */

/datum/supply_pack/engineering/bluespace_harvester
	name = "Bluespace Harvester Parts"
	desc = "An experimental device that reaches through bluespace into other dimensions to gather objects. Contains the circuit board and instruction manual. Requires a significant amount of power to operate."
	cost = CARGO_CRATE_VALUE * 20
	order_flags = ORDER_SPECIAL
	access_view = ACCESS_COMMAND
	contains = list(
		/obj/item/circuitboard/machine/bluespace_tap,
		/obj/item/paper/guides/jobs/engineering/bluespace_tap,
	)
	crate_name = "bluespace harvester parts crate"