/obj/machinery/sleeper/clockwork
	name = "Clockwork Sleeper"
	desc = "An enclosed machine used to stabilize and heal servants."
	color = rgb(190, 135, 0)
	circuit = /obj/item/circuitboard/machine/sleeper/clockwork
	min_health = -75

/obj/item/circuitboard/machine/sleeper/clockwork
	name = "Clockwork Sleeper"
	build_path = /obj/machinery/sleeper/clockwork
	req_components = list(
		/datum/stock_part/matter_bin/clock = 1,
		/datum/stock_part/servo/clock = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 2,
	)
