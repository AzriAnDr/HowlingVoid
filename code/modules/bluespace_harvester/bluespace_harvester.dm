/**
 * # Bluespace Harvester
 *
 * A station goal that consumes enormous amounts of power to generate rewards.
 * Ported from Paradise-SS220.
 *
 * A machine that takes power each tick, generates points based on it,
 * and lets you spend those points on rewards. A certain amount of points
 * has to be generated for the station goal to count as completed.
 */

#define NEAREST_MW(power) ((power) - (power) % (1 MEGA WATTS))

/// Points generated per cycle for each Watt of power consumption
#define POINTS_PER_W 4e-6
/// Amount of points generated per cycle per 50KW for the first 500KW
#define BASE_POINTS 2

/datum/data/bluespace_tap_product
	/// Name of the product
	var/product_name = "generic"
	/// The path to a list containing the common drops
	var/product_path_common = null
	/// The path to a list containing the uncommon drops
	var/product_path_uncommon = null
	/// The path to a list containing the rare drops
	var/product_path_rare = null
	/// How much the product costs to produce
	var/product_cost = 100

/datum/data/bluespace_tap_product/New(name, path_common, path_uncommon, path_rare, cost)
	product_name = name
	product_path_common = path_common
	product_path_uncommon = path_uncommon
	product_path_rare = path_rare
	product_cost = cost

/obj/item/circuitboard/machine/bluespace_tap
	name = "Bluespace Harvester"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/power/bluespace_tap
	req_components = list(
		/datum/stock_part/capacitor = 5,
		/obj/item/stack/ore/bluespace_crystal = 5,
	)

/obj/machinery/power/bluespace_tap
	name = "Bluespace harvester"
	desc = "A massive experimental device that reaches through bluespace to gather objects from other dimensions."
	icon = 'icons/obj/machines/bluespace_harvester.dmi'
	icon_state = "bluespace_tap"
	base_icon_state = "bluespace_tap"
	max_integrity = 300
	pixel_x = -32
	pixel_y = -32
	density = TRUE
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/machine/bluespace_tap

	/// list of possible products
	var/static/list/product_list

	/// The amount of power being used for mining at the moment (Watts)
	var/mining_power = 0
	/// The power you WANT the machine to use for mining (Watts)
	var/desired_mining_power = 0
	/// Points mined this cycle
	var/mined_points = 0
	/// Available mining points
	var/points = 0
	/// The total points earned by this machine so far
	var/total_points = 0
	/// The point interval where the machine will automatically spawn a clothing item
	var/clothing_interval = 7500
	/// The point interval where the machine will automatically spawn a food item
	var/food_interval = 10000
	/// The point interval where the machine will automatically spawn a cultural item
	var/cultural_interval = 15000
	/// The point interval where the machine will automatically spawn an organic item
	var/organic_interval = 20000
	/// The point interval where the machine will strike a motherlode
	var/motherlode_interval = 45000

	/// Whether or not auto shutdown will engage when portals open
	var/auto_shutdown = TRUE
	/// Whether or not stabilizers will engage
	var/stabilizers = TRUE
	/// Amount of power the stabilizers consume (Watts)
	var/stabilizer_power = 0
	/// Whether or not mining power will be prevented from exceeding stabilizer power
	var/stabilizer_priority = TRUE
	/// When portal event triggers this will hold references to all portals
	var/list/active_nether_portals = list()
	/// The amount of portals waiting to be spawned
	var/spawning = 0
	/// When a filth event triggers, this will stop the operation until it is cleaned
	var/dirty = FALSE
	/// Internal radio to handle announcements over engineering
	var/obj/item/radio/radio

/obj/machinery/power/bluespace_tap/Initialize(mapload)
	. = ..()
	if(!product_list)
		product_list = list(
			new /datum/data/bluespace_tap_product("Unknown Exotic Clothing",
				/obj/effect/spawner/random/bluespace_tap/clothes_common,
				/obj/effect/spawner/random/bluespace_tap/clothes_uncommon,
				/obj/effect/spawner/random/bluespace_tap/clothes_rare,
				5000),
			new /datum/data/bluespace_tap_product("Unknown Food",
				/obj/effect/spawner/random/bluespace_tap/food_common,
				/obj/effect/spawner/random/bluespace_tap/food_uncommon,
				/obj/effect/spawner/random/bluespace_tap/food_rare,
				6000),
			new /datum/data/bluespace_tap_product("Unknown Cultural Artifact",
				/obj/effect/spawner/random/bluespace_tap/cultural_common,
				/obj/effect/spawner/random/bluespace_tap/cultural_uncommon,
				/obj/effect/spawner/random/bluespace_tap/cultural_rare,
				15000),
			new /datum/data/bluespace_tap_product("Unknown Biological Artifact",
				/obj/effect/spawner/random/bluespace_tap/organic_common,
				/obj/effect/spawner/random/bluespace_tap/organic_uncommon,
				/obj/effect/spawner/random/bluespace_tap/organic_rare,
				20000),
		)

	if(!powernet)
		connect_to_network()

	radio = new(src)
	radio.set_listening(FALSE)
	radio.set_frequency(FREQ_ENGINEERING)

/obj/machinery/power/bluespace_tap/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/power/bluespace_tap/examine(mob/user)
	. = ..()
	. += span_notice("An alien looking device that gathers all manner of objects from different dimensions.")
	if(dirty)
		. += span_warning("It's gummed up with filth!")

/obj/machinery/power/bluespace_tap/update_icon_state()
	. = ..()
	if(length(active_nether_portals))
		icon_state = "cascade_tap"
		return
	if(surplus() <= 0)
		icon_state = base_icon_state
	else
		icon_state = "[base_icon_state][get_icon_state_number()]"

/obj/machinery/power/bluespace_tap/update_overlays()
	. = ..()
	underlays.Cut()

	if(length(active_nether_portals) || spawning)
		. += "cascade"
		set_light(15, 5, "#ff0000")
		return

	if(machine_stat & (BROKEN|NOPOWER))
		set_light(0)
	else
		set_light(1, 1, "#353535")

	if(surplus())
		if(dirty)
			. += "screen_dirty"
		else
			. += "screen"
		if(light)
			underlays += emissive_appearance(icon, "light_mask", src)

/obj/machinery/power/bluespace_tap/proc/get_icon_state_number()
	switch(mining_power)
		if(50 KILO WATTS to 3 MEGA WATTS)
			return 1
		if(3 MEGA WATTS to 8 MEGA WATTS)
			return 2
		if(8 MEGA WATTS to 11 MEGA WATTS)
			return 3
		if(11 MEGA WATTS to 15 MEGA WATTS)
			return 4
		if(15 MEGA WATTS to INFINITY)
			return 5
		else
			return 0

/obj/machinery/power/bluespace_tap/power_change()
	. = ..()
	if(machine_stat & (BROKEN|NOPOWER))
		set_light(0)
	else
		set_light(1, 1, "#353535")
	if(.)
		update_icon()

/obj/machinery/power/bluespace_tap/connect_to_network()
	. = ..()
	if(.)
		update_icon()

/obj/machinery/power/bluespace_tap/disconnect_from_network()
	. = ..()
	if(.)
		update_icon()

/obj/machinery/power/bluespace_tap/proc/set_power(t_power)
	desired_mining_power = max(t_power, 0)
	if(desired_mining_power > 1 MEGA WATTS)
		desired_mining_power = desired_mining_power - (desired_mining_power % (1 MEGA WATTS))

/obj/machinery/power/bluespace_tap/process(seconds_per_tick)
	mining_power = surplus()

	if(mining_power > 1 MEGA WATTS)
		mining_power = NEAREST_MW(mining_power)

	if(obj_flags & EMAGGED)
		desired_mining_power = mining_power
		stabilizer_power = 0
	else if(stabilizers)
		if(stabilizer_priority)
			stabilizer_power = \
				min(max(mining_power - max(NEAREST_MW(mining_power / 2), NEAREST_MW((mining_power + 30 MEGA WATTS) / 3)), 0), \
				clamp(desired_mining_power - clamp((30 MEGA WATTS) - desired_mining_power, 0, 15 MEGA WATTS), 0, desired_mining_power))
			mining_power = mining_power - stabilizer_power
		else
			stabilizer_power = \
				clamp(mining_power - desired_mining_power, \
				0, \
				desired_mining_power - clamp(30 MEGA WATTS - desired_mining_power, 0, 15 MEGA WATTS))
	else
		stabilizer_power = 0

	mining_power = min(mining_power, desired_mining_power)
	add_load(mining_power + stabilizer_power)

	if(!dirty)
		mined_points = min(BASE_POINTS * (mining_power / (50 KILO WATTS)), 20) + mining_power * (POINTS_PER_W + ((obj_flags & EMAGGED) ? 1 : 0) / (1 MEGA WATTS))
		points += mined_points
		total_points += mined_points
		update_icon()

	if(total_points > clothing_interval)
		produce(product_list[1], FALSE, !stabilizers)
		radio.talk_into(src, "Bluespace harvester progress detected: [src] has produced unknown clothes!", FREQ_ENGINEERING)
		clothing_interval += 7500

	if(total_points > food_interval)
		produce(product_list[2], FALSE, !stabilizers)
		radio.talk_into(src, "Bluespace harvester progress detected: [src] has produced unknown food!", FREQ_ENGINEERING)
		food_interval += 10000

	if(total_points > cultural_interval)
		produce(product_list[3], FALSE, !stabilizers)
		radio.talk_into(src, "Bluespace harvester progress detected: [src] has produced something unknown with cultural value!", FREQ_ENGINEERING)
		cultural_interval += 15000

	if(total_points > organic_interval)
		produce(product_list[4], FALSE, !stabilizers)
		radio.talk_into(src, "Bluespace harvester progress detected: [src] has produced something organic!", FREQ_ENGINEERING)
		organic_interval += 20000

	if(total_points > motherlode_interval)
		produce_motherlode()
		motherlode_interval += 45000

	var/emagged = (obj_flags & EMAGGED) ? 1 : 0
	if(prob((mining_power - clamp(30 MEGA WATTS - mining_power, 0, 15 MEGA WATTS) - stabilizer_power) / (10 MEGA WATTS) + (emagged * 5)))
		var/area/our_area = get_area(src)
		if(!spawning || !length(active_nether_portals))
			priority_announce(
				"An unexpected power surge has occurred during bluespace harvester operation. Extradimensional incursion detected. Expected location: [our_area.name]. [emagged ? "DANGER: Emergency shutdown failed. Manual shutdown is required immediately." : auto_shutdown ? "Emergency shutdown has been initiated." : "Automatic shutdown is disabled."]",
				"WARNING: Bluespace harvester malfunction detected!",
				'sound/machines/bluespace_harvester.ogg'
			)
		if(!emagged && auto_shutdown)
			desired_mining_power = 0
		start_nether_portaling(rand(1, 3) + round(max((mining_power - 15 MEGA WATTS) / (30 MEGA WATTS), 0)), TRUE)

	try_events()

/obj/machinery/power/bluespace_tap/proc/start_nether_portaling(amount, new_incursion = FALSE)
	if(new_incursion)
		spawning += amount
	var/turf/location = locate(x + rand(-5, 5), y + rand(-5, 5), z)
	var/obj/structure/spawner/nether/bluespace_tap/portal = new(location)
	amount--
	spawning--
	active_nether_portals += portal
	portal.linked_source_object = src
	portal.max_mobs = 5 + max((mining_power - 15 MEGA WATTS) / (20 MEGA WATTS), 0)
	update_icon()
	if(amount)
		addtimer(CALLBACK(src, PROC_REF(start_nether_portaling), amount), rand(3, 5) SECONDS)

/obj/machinery/power/bluespace_tap/ui_data(mob/user)
	var/list/data = list()
	data["desiredMiningPower"] = desired_mining_power
	data["miningPower"] = mining_power
	data["points"] = points
	data["totalPoints"] = total_points
	data["powerUse"] = mining_power + stabilizer_power
	data["availablePower"] = surplus()
	data["emagged"] = !!(obj_flags & EMAGGED)
	data["dirty"] = dirty
	data["autoShutown"] = auto_shutdown
	data["stabilizers"] = stabilizers
	data["stabilizerPower"] = stabilizer_power
	data["stabilizerPriority"] = stabilizer_priority
	data["portaling"] = (length(active_nether_portals) || spawning)

	var/list/listed_items = list()
	for(var/key = 1 to length(product_list))
		var/datum/data/bluespace_tap_product/product = product_list[key]
		listed_items += list(list(
			"key" = key,
			"name" = product.product_name,
			"price" = product.product_cost,
		))
	data["product"] = listed_items
	return data

/obj/machinery/power/bluespace_tap/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BluespaceTap", name)
		ui.open()

/obj/machinery/power/bluespace_tap/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("set")
			set_power(text2num(params["set_power"]))
			return TRUE
		if("vend")
			var/key = text2num(params["target"])
			if(key <= 0 || key > length(product_list))
				return FALSE
			produce(product_list[key], TRUE, TRUE)
			return TRUE
		if("auto_shutdown")
			auto_shutdown = !auto_shutdown
			return TRUE
		if("stabilizers")
			stabilizers = !stabilizers
			return TRUE
		if("stabilizer_priority")
			stabilizer_priority = !stabilizer_priority
			return TRUE

/obj/machinery/power/bluespace_tap/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	do_sparks(5, FALSE, src)
	if(user)
		balloon_alert(user, "safeties disabled")
	return TRUE

/obj/machinery/power/bluespace_tap/proc/produce(datum/data/bluespace_tap_product/product, purchased = FALSE, double_chance = FALSE)
	if(!product)
		return
	if(purchased)
		if(product.product_cost > points)
			return
		points -= product.product_cost
		product.product_cost = round(1.2 * product.product_cost, 1)

	playsound(src, 'sound/effects/magic/blink.ogg', 50)
	do_sparks(2, FALSE, src)

	var/turf/spawn_location = find_spawn_location()
	if(!spawn_location)
		spawn_location = get_turf(src)

	spawn_item(product, spawn_location)

	if(prob(25) && double_chance)
		spawn_location = find_spawn_location(TRUE)
		if(spawn_location)
			spawn_item(product, spawn_location)

/obj/machinery/power/bluespace_tap/proc/produce_motherlode()
	radio.talk_into(src, "Power spike detected during Bluespace Harvester operation. Large bluespace payload inbound.", FREQ_ENGINEERING)

	var/list/possible_spawns = list()
	for(var/turf/current_target_turf in view(3, src))
		possible_spawns += current_target_turf

	for(var/datum/data/bluespace_tap_product/product in product_list)
		for(var/i in 1 to 5)
			var/turf/spawn_location = pick_n_take(possible_spawns)
			if(!spawn_location)
				spawn_location = get_turf(src)
			if(spawn_location.density)
				var/list/open_turfs = spawn_location.get_atmos_adjacent_turfs()
				if(length(open_turfs))
					spawn_location = pick(open_turfs)
			spawn_item(product, spawn_location)

/obj/machinery/power/bluespace_tap/proc/find_spawn_location(random = FALSE)
	var/list/possible_spawns = list()
	for(var/turf/current_target_turf in view(3, src))
		possible_spawns += current_target_turf

	while(length(possible_spawns))
		var/turf/current_spawn = pick_n_take(possible_spawns)
		if(!current_spawn.density)
			return current_spawn
		var/list/open_turfs = current_spawn.get_atmos_adjacent_turfs()
		if(length(open_turfs))
			return pick(open_turfs)
	return null

/obj/machinery/power/bluespace_tap/proc/spawn_item(datum/data/bluespace_tap_product/product, turf/spawn_turf)
	if(!product)
		return
	var/list/loot_rarities = list(
		product.product_path_common = 60,
		product.product_path_uncommon = 30,
		product.product_path_rare = 10,
	)
	var/product_path = pick_weight(loot_rarities)
	new /obj/effect/portal(spawn_turf, null, src, 1 SECONDS)
	playsound(src, 'sound/effects/magic/blink.ogg', 50)
	new product_path(spawn_turf)
	log_game("Bluespace harvester product spawned at [AREACOORD(spawn_turf)]")

#define PROB_CAP 5
#define PROB_CURVE 250

/obj/machinery/power/bluespace_tap/proc/try_events()
	if(!mining_power)
		return
	var/megawatts = mining_power / 1000000
	var/emagged = (obj_flags & EMAGGED) ? 1 : 0
	var/event_prob = (PROB_CAP * megawatts / (megawatts + PROB_CURVE)) + (emagged * 5)
	if(!prob(event_prob))
		return
	var/static/list/event_list = list(
		/datum/bluespace_tap_event/dirty,
		/datum/bluespace_tap_event/electric_arc,
		/datum/bluespace_tap_event/radiation,
		/datum/bluespace_tap_event/gas,
	)
	var/datum/bluespace_tap_event/event = pick(event_list)
	run_event(event)

/obj/machinery/power/bluespace_tap/proc/run_event(datum/bluespace_tap_event/event)
	if(ispath(event))
		event = new event(src)
	if(!istype(event))
		return
	event.start_event()

/obj/machinery/power/bluespace_tap/wash(clean_types)
	. = ..()
	dirty = FALSE
	update_appearance()

#undef PROB_CAP
#undef PROB_CURVE

/obj/structure/spawner/nether/bluespace_tap
	spawn_time = 30 SECONDS
	max_mobs = 5
	max_integrity = 250
	var/obj/machinery/power/bluespace_tap/linked_source_object

/obj/structure/spawner/nether/bluespace_tap/handle_deconstruct(disassembled)
	new /obj/item/stack/ore/bluespace_crystal(loc)
	return ..()

/obj/structure/spawner/nether/bluespace_tap/Destroy()
	. = ..()
	if(linked_source_object)
		linked_source_object.active_nether_portals -= src
		linked_source_object.update_icon()

/obj/item/paper/guides/jobs/engineering/bluespace_tap
	name = "paper- 'The Experimental NT Bluespace Harvester - Mining other universes for science and profit!'"
	default_raw_text = {"<h1>Important Instructions!</h1>Please follow all setup instructions to ensure proper operation. <br>
	1. Create a wire node with ample access to spare power. The device operates independently of APCs. <br>
	2. Create a machine frame as normal on the wire node, taking into account the device's dimensions (3 by 3 meters). <br>
	3. Insert wiring, circuit board and required components and finish construction according to NT engineering standards. <br>
	4. Ensure the device is connected to the proper power network and the network contains sufficient power. <br>
	5. Set machine to desired level. Check periodically on machine progress. <br>
	6. Optionally, spend earned points on fun and exciting rewards. <br><hr>
	<h2>Operational Principles</h2>
	<p>The Bluespace Harvester is capable of accepting a nearly limitless amount of power to search other universes for valuables to recover.
	The speed of this search is controlled via the 'level' control of the device.
	While it can be run on a low level by almost any power generation system, higher levels require work by a dedicated engineering team to power.
	As we are interested in testing how the device performs under stress, we wish to encourage you to stress-test it and see how much power you can provide it.
	For this reason, total shift point production will be calculated and announced at shift end. High totals may result in bonus payments to members of the Engineering department.</p>
	<p>NT Science Directorate, Extradimensional Exploitation Research Group</p>
	<p><small>Device highly experimental. Not for sale. Do not operate near small children or vital NT assets. Do not tamper with machine. In case of existential dread, stop machine immediately.
	Please document any and all extradimensional incursions. In case of imminent death, please leave said documentation in plain sight for clean-up teams to recover.</small></p>"}

#undef POINTS_PER_W
#undef BASE_POINTS
#undef NEAREST_MW