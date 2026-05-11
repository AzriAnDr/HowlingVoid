/obj/machinery/byteforge
	name = "byteforge"

	circuit = /obj/item/circuitboard/machine/byteforge
	desc = "A machine used by the quantum server. Quantum code converges here, materializing decrypted assets from the virtual abyss."
	icon = 'icons/obj/machines/bitrunning.dmi'
	icon_state = "byteforge"
	base_icon_state = "byteforge"
	obj_flags = BLOCKS_CONSTRUCTION | CAN_BE_HIT
	/// Idle particles
	var/mutable_appearance/byteforge_particles
	/// Highest installed laser tier influencing ore output
	var/laser_tier = 0
	/// Highest installed scanning module tier influencing duplication chance
	var/scanner_tier = 0
	/// Multiplier applied to ore yield after byteforge processing
	var/ore_yield_multiplier = 1
	/// Percentage chance to double the produced ore stacks
	var/ore_duplication_chance = 0

/obj/machinery/byteforge/Initialize(mapload)
	. = ..()

	register_context()

/obj/machinery/byteforge/post_machine_initialize()
	. = ..()

	RefreshParts()
	setup_particles()

/obj/machinery/byteforge/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		return

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] Panel"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/byteforge/examine(mob/user)
	. = ..()

	. += span_notice("Must be within 4 tiles of the quantum server.")

	. += span_notice("Its maintenance panel can be [EXAMINE_HINT("screwed")] [panel_open ? "close" : "open"].")
	if(panel_open)
		. += span_notice("It can be [EXAMINE_HINT("pried")] apart.")

	var/laser_bonus = max(ore_yield_multiplier - 1, 0) * 100
	var/scanner_bonus = ore_duplication_chance

	. += span_notice("- Laser array yield bonus: [round(laser_bonus)]% (Tier [laser_tier]).")
	. += span_notice("- Scanning module duplication chance: [round(scanner_bonus)]% (Tier [scanner_tier]).")

/obj/machinery/byteforge/update_appearance(updates)
	. = ..()

	setup_particles()

/obj/machinery/byteforge/screwdriver_act(mob/living/user, obj/item/screwdriver)
	. = ITEM_INTERACT_FAILURE
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_panel", base_icon_state, screwdriver))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/byteforge/crowbar_act(mob/living/user, obj/item/crowbar)
	. = ITEM_INTERACT_FAILURE
	if(default_deconstruction_crowbar(crowbar))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/byteforge/RefreshParts()
	. = ..()

	var/new_laser_tier = 0
	var/new_scanner_tier = 0

	for(var/datum/stock_part/micro_laser/laser in component_parts)
		new_laser_tier = max(new_laser_tier, laser.tier)
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		new_laser_tier = max(new_laser_tier, laser.rating)

	for(var/datum/stock_part/scanning_module/scanner in component_parts)
		new_scanner_tier = max(new_scanner_tier, scanner.tier)
	for(var/obj/item/stock_parts/scanning_module/scanner in component_parts)
		new_scanner_tier = max(new_scanner_tier, scanner.rating)

	laser_tier = new_laser_tier
	scanner_tier = new_scanner_tier

	ore_yield_multiplier = get_laser_multiplier_for_tier(laser_tier)
	ore_duplication_chance = get_scanner_chance_for_tier(scanner_tier)

	return .

/obj/machinery/byteforge/proc/get_laser_multiplier_for_tier(tier)
	switch(tier)
		if(4 to INFINITY)
			return 2
		if(3)
			return 1.2
		if(2)
			return 0.8
		if(1)
			return 0.4
		else
			return 0

/obj/machinery/byteforge/proc/get_scanner_chance_for_tier(tier)
	switch(tier)
		if(4 to INFINITY)
			return 30
		if(3)
			return 15
		if(2)
			return 10
		if(1)
			return 5
		else
			return 0

/obj/machinery/byteforge/proc/get_ore_yield_multiplier()
	return ore_yield_multiplier

/obj/machinery/byteforge/proc/get_ore_duplication_chance()
	return ore_duplication_chance

/// Does some sparks after it's done
/obj/machinery/byteforge/proc/flash(atom/movable/thing)
	playsound(src, 'sound/effects/magic/blink.ogg', 50, TRUE)

	do_sparks(5, TRUE, loc, spark_type = /datum/effect_system/basic/spark_spread/quantum)
	set_light(l_on = FALSE)

/// Forge begins to process
/obj/machinery/byteforge/proc/flicker(angry = FALSE)
	var/mutable_appearance/lighting = mutable_appearance(initial(icon), "on_overlay[angry ? "_angry" : ""]")
	flick_overlay_view(lighting, 1 SECONDS)

	set_light(l_range = 2, l_power = 1.5, l_color = angry ? LIGHT_COLOR_BUBBLEGUM : LIGHT_COLOR_BABY_BLUE, l_on = TRUE)

/// Adds the particle overlays to the byteforge
/obj/machinery/byteforge/proc/setup_particles(angry = FALSE)
	cut_overlay(byteforge_particles)

	byteforge_particles = mutable_appearance(initial(icon), "on_particles[angry ? "_angry" : ""]", ABOVE_MOB_LAYER)

	if(is_operational)
		add_overlay(byteforge_particles)

/// Forge is done processing
/obj/machinery/byteforge/proc/spawn_cache(obj/cache)
	if(QDELETED(cache))
		return

	flash()

	cache.forceMove(loc)

/// Timed flash
/obj/machinery/byteforge/proc/start_to_spawn(obj/cache)
	flicker()

	addtimer(CALLBACK(src, PROC_REF(spawn_cache), cache), 1 SECONDS)
