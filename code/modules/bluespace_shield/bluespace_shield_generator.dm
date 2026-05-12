// Bluespace Shield Field Generator
// Generates an energy shield around the entire map boundary (hull) of the z-level it's placed on.
// Ported from SierraBay12 shield generator with bluespace drive aesthetics.

// Looping sound datum for the idle hum
/datum/looping_sound/bluespace_shield
	mid_sounds = list('sound/machines/BSD_idle.ogg')
	mid_length = 66 SECONDS
	volume = 200
	extra_range = 20
	vary = FALSE

// =============================================================================
// MAIN GENERATOR
// =============================================================================

/obj/machinery/power/bluespace_shield_generator
	name = "bluespace shield field generator"
	desc = "A heavy-duty shield generator that uses bluespace energy fields to project a protective barrier along the hull boundary of an entire deck. Extremely power-hungry. Must be placed on a wire."
	icon = 'icons/obj/machines/bluespacedrive.dmi'
	icon_state = "bsd_core"
	pixel_x = -32
	pixel_y = -32
	density = TRUE
	anchored = TRUE
	move_resist = INFINITY
	max_integrity = 1500
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | BOMB_PROOF
	circuit = /obj/item/circuitboard/machine/bluespace_shield_generator
	/// We need to process to charge and maintain shields
	processing_flags = NONE
	use_power = NO_POWER_USE

	// --- Shield field state ---
	/// List of all active shield segments
	var/list/obj/structure/bluespace_shield/field_segments = list()
	/// List of damaged/disabled segments currently regenerating
	var/list/obj/structure/bluespace_shield/damaged_segments = list()
	/// Bitfield of enabled shield modes
	var/shield_modes = 0
	/// Current EM damage mitigation percentage
	var/mitigation_em = 0
	/// Current physical damage mitigation percentage
	var/mitigation_physical = 0
	/// Current heat damage mitigation percentage
	var/mitigation_heat = 0
	/// Maximum achievable mitigation (set by RefreshParts)
	var/mitigation_max = 0

	// --- Energy ---
	/// Maximum internal energy reserve in joules
	var/max_energy = 0
	/// Current internal energy reserve
	var/current_energy = 0
	/// Maximum power draw from grid per tick
	var/input_cap = 2000000
	/// Power used for shield upkeep last tick
	var/upkeep_power_usage = 0
	/// Total power drawn last tick
	var/power_usage = 0
	/// Energy needed for full shield strength
	var/full_shield_strength = 0
	/// Upkeep cost multiplier from enabled modes
	var/upkeep_multiplier = 1

	// --- Generator state ---
	/// Current operational state (BSHIELD_OFF, _RUNNING, etc.)
	var/running = BSHIELD_OFF
	/// Whether the shield has overloaded
	var/overloaded = FALSE
	/// Whether the generator has been hacked via wires
	var/hacked = FALSE
	/// Ticks remaining before generator can restart after emergency shutdown
	var/offline_for = 0
	/// Whether the current cooldown is from a full stop (energy depletion) vs emergency stop
	var/full_stop = FALSE
	/// Whether the input wire is cut
	var/input_cut = FALSE
	/// Whether mode changes are locked out (wire cut)
	var/mode_changes_locked = FALSE
	/// Whether AI control is disabled
	var/ai_control_disabled = FALSE

	// --- Idle/spinup ---
	/// Idle cost multiplier (trades off cost vs spinup time)
	var/idle_multiplier = 1
	/// Valid idle multiplier settings
	var/list/idle_valid_values = list(1, 2, 5, 10)
	/// Ticks to spin up from idle to running
	var/spinup_delay = 5
	/// Remaining spinup ticks
	var/spinup_counter = 0

	// --- Mode datums ---
	/// List of all available shield mode datums
	var/list/datum/bluespace_shield_mode/mode_list

	// --- Sound ---
	/// Looping idle sound
	var/datum/looping_sound/bluespace_shield/sound_loop

	// --- Broken/repair state ---
	/// Whether the generator is currently broken (destroyed core)
	var/broken = FALSE
	/// Current repair step (BSHIELD_REPAIR_CROWBAR through BSHIELD_REPAIR_WELD_FINAL)
	var/repair_state = BSHIELD_REPAIR_CROWBAR
	/// Timer ID for singularity countdown (7 minutes after break)
	var/singularity_timer = TIMER_ID_NULL
	/// Seconds remaining until singularity collapse
	var/singularity_countdown = 0
	/// Timer ID for periodic radio warnings
	var/warning_timer = TIMER_ID_NULL
	/// The turf currently protected from explosion damage while supporting the generator
	var/turf/protected_support_turf

// =============================================================================
// LIFECYCLE
// =============================================================================

/obj/machinery/power/bluespace_shield_generator/Initialize(mapload)
	. = ..()
	connect_to_network()
	RegisterSignal(src, COMSIG_ATOM_PRE_EX_ACT, PROC_REF(handle_generator_pre_ex_act))
	sound_loop = new(src)
	mode_list = list()
	for(var/mode_type in subtypesof(/datum/bluespace_shield_mode))
		mode_list += new mode_type()
	refresh_support_turf_protection()
	update_appearance()

/obj/machinery/power/bluespace_shield_generator/Destroy()
	UnregisterSignal(src, COMSIG_ATOM_PRE_EX_ACT)
	refresh_support_turf_protection(null)
	shutdown_field()
	disconnect_from_network()
	mode_list = null
	if(singularity_timer != TIMER_ID_NULL)
		deltimer(singularity_timer)
		singularity_timer = TIMER_ID_NULL
	if(warning_timer != TIMER_ID_NULL)
		deltimer(warning_timer)
		warning_timer = TIMER_ID_NULL
	QDEL_NULL(sound_loop)
	return ..()

/obj/machinery/power/bluespace_shield_generator/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	refresh_support_turf_protection(get_turf(old_loc))

/obj/machinery/power/bluespace_shield_generator/proc/refresh_support_turf_protection(turf/old_turf = protected_support_turf)
	if(old_turf)
		UnregisterSignal(old_turf, COMSIG_ATOM_PRE_EX_ACT)
	var/turf/new_turf = get_turf(src)
	protected_support_turf = new_turf
	if(new_turf)
		RegisterSignal(new_turf, COMSIG_ATOM_PRE_EX_ACT, PROC_REF(protect_support_turf_from_explosion))

/obj/machinery/power/bluespace_shield_generator/proc/protect_support_turf_from_explosion(turf/source, severity, target)
	SIGNAL_HANDLER
	if(QDELETED(src) || source != get_turf(src))
		return NONE
	return COMPONENT_CANCEL_EX_ACT

/obj/machinery/power/bluespace_shield_generator/proc/should_break_from_explosion(severity, target)
	if(broken)
		return FALSE
	if(target == src)
		return TRUE
	return severity >= EXPLODE_HEAVY

/obj/machinery/power/bluespace_shield_generator/proc/handle_generator_pre_ex_act(atom/source, severity, target)
	SIGNAL_HANDLER
	if(should_break_from_explosion(severity, target))
		generator_break()
	return COMPONENT_CANCEL_EX_ACT

/obj/machinery/power/bluespace_shield_generator/RefreshParts()
	. = ..()
	// Sum all component tiers for combined rating
	var/capacitor_rating = 0
	for(var/datum/stock_part/capacitor/cap in component_parts)
		capacitor_rating += cap.tier

	var/bin_rating = 0
	for(var/datum/stock_part/matter_bin/bin in component_parts)
		bin_rating += bin.tier

	var/servo_rating = 0
	for(var/datum/stock_part/servo/servo in component_parts)
		servo_rating += servo.tier

	var/laser_rating = 0
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		laser_rating += laser.tier

	var/scanner_rating = 0
	for(var/datum/stock_part/scanning_module/scanner in component_parts)
		scanner_rating += scanner.tier

	// Capacitors + matter bins -> energy capacity (10T4 each = 80 combined)
	full_shield_strength = (capacitor_rating + bin_rating) * 100000000
	max_energy = full_shield_strength * 25
	current_energy = clamp(current_energy, 0, max_energy)

	// Lasers improve power input cap
	input_cap = 2000000 + laser_rating * 500000

	// Servos + scanners improve mitigation cap
	mitigation_max = BSHIELD_MITIGATION_MAX_BASE + BSHIELD_MITIGATION_MAX_RESEARCH * (servo_rating + scanner_rating)
	mitigation_em = clamp(mitigation_em, 0, mitigation_max)
	mitigation_physical = clamp(mitigation_physical, 0, mitigation_max)
	mitigation_heat = clamp(mitigation_heat, 0, mitigation_max)

/obj/machinery/power/bluespace_shield_generator/update_icon_state()
	. = ..()
	var/new_state = broken ? "bsd_core_broken" : "bsd_core"
	if(icon_state != new_state)
		icon_state = new_state

/obj/machinery/power/bluespace_shield_generator/update_overlays()
	. = ..()
	var/overlay_state = broken ? "bsd_c_u" : "bsd_c_s"
	var/mutable_appearance/overlay = mutable_appearance(icon, overlay_state)
	. += overlay

/// Cannot be thrown
/obj/machinery/power/bluespace_shield_generator/safe_throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, gentle)
	return FALSE

// =============================================================================
// POWER & PROCESS
// =============================================================================

/obj/machinery/power/bluespace_shield_generator/process(seconds_per_tick)
	if(offline_for)
		offline_for = max(0, offline_for - 1)
		if(offline_for == 0)
			full_stop = FALSE
			end_processing()
		return

	if(running == BSHIELD_OFF)
		return

	// Spinning up from idle
	if(running == BSHIELD_SPINNING_UP)
		spinup_counter--
		if(spinup_counter <= 0)
			running = BSHIELD_RUNNING
			regenerate_field()
			sound_loop.start()
			update_appearance()

	// Discharging (shutting down)
	if(running == BSHIELD_DISCHARGING)
		current_energy -= BSHIELD_SHUTDOWN_DISPERSION_RATE
		if(current_energy <= 0)
			current_energy = 0
			full_stop = TRUE
			shutdown_field()
			offline_for = 60
			begin_processing()
			return

	// Passive mitigation decay
	mitigation_em = clamp(mitigation_em - BSHIELD_MITIGATION_LOSS_PASSIVE, 0, mitigation_max)
	mitigation_heat = clamp(mitigation_heat - BSHIELD_MITIGATION_LOSS_PASSIVE, 0, mitigation_max)
	mitigation_physical = clamp(mitigation_physical - BSHIELD_MITIGATION_LOSS_PASSIVE, 0, mitigation_max)

	// Calculate upkeep
	if(running == BSHIELD_RUNNING)
		upkeep_power_usage = round((length(field_segments) - length(damaged_segments)) * BSHIELD_UPKEEP_PER_TILE * upkeep_multiplier)
	else if(running >= BSHIELD_IDLE)
		upkeep_power_usage = round(BSHIELD_UPKEEP_IDLE * idle_multiplier * max(length(field_segments), 1) * upkeep_multiplier)
	else
		upkeep_power_usage = 0

	// Draw power from powernet wire and charge internal reserve
	power_usage = 0
	if(!powernet)
		connect_to_network()
	if(!input_cut && powernet)
		var/grid_avail = surplus()
		var/total_demand = upkeep_power_usage
		// Also try to charge internal reserve
		var/charge_want = input_cap ? clamp(max_energy - current_energy, 0, input_cap) : max(0, max_energy - current_energy)
		total_demand += charge_want
		// Cap by input_cap and available surplus
		var/grid_draw = min(total_demand, input_cap, grid_avail)
		if(grid_draw > 0)
			add_load(grid_draw)
			power_usage = grid_draw

		// Pay upkeep - first from grid, remainder from reserve
		if(grid_draw >= upkeep_power_usage)
			// All upkeep covered by grid, rest goes to charging
			current_energy += round(grid_draw - upkeep_power_usage)
		else if(running >= BSHIELD_RUNNING)
			// Grid couldn't cover upkeep, drain reserve for the difference
			current_energy -= round(upkeep_power_usage - grid_draw)
	else if(running >= BSHIELD_RUNNING)
		// No powernet connection - drain from internal reserve
		current_energy -= round(upkeep_power_usage)

	current_energy = clamp(current_energy, 0, max_energy)

	// Energy failure check (skip during spinup/idle - no field needs energy yet)
	if(current_energy <= 0 && running == BSHIELD_RUNNING)
		energy_failure()
		return

	// Regenerate damaged segments
	if(!overloaded)
		for(var/obj/structure/bluespace_shield/S in damaged_segments)
			S.regenerate()
	else if(field_integrity() > 25)
		overloaded = FALSE

// =============================================================================
// FIELD GENERATION - HULL MODE (covers entire z-level boundary)
// =============================================================================

/// Shuts down the shield completely, removing all segments
/obj/machinery/power/bluespace_shield_generator/proc/clear_field_segments()
	for(var/obj/structure/bluespace_shield/S in field_segments)
		qdel(S)
	field_segments.Cut()
	damaged_segments.Cut()

/// Shuts down the shield completely, removing all segments
/obj/machinery/power/bluespace_shield_generator/proc/shutdown_field()
	clear_field_segments()
	running = BSHIELD_OFF
	current_energy = 0
	mitigation_em = 0
	mitigation_physical = 0
	mitigation_heat = 0
	sound_loop.stop()
	update_appearance()

/// Generates the hull shield field - covers z-level boundary with space
/obj/machinery/power/bluespace_shield_generator/proc/regenerate_field()
	set background = TRUE
	clear_field_segments()

	if(!running)
		return

	var/z_level = z
	var/list/shield_turfs = list()

	// Scan the entire z-level for turfs adjacent to space (cardinal + diagonal)
	for(var/turf/T as anything in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		if(!isfloorturf(T) && !isclosedturf(T))
			continue
		for(var/direction in GLOB.alldirs)
			var/turf/neighbor = get_step(T, direction)
			if(neighbor && isspaceturf(neighbor))
				shield_turfs |= neighbor

	// Create shield segments on the space turfs
	for(var/turf/shield_turf as anything in shield_turfs)
		if(locate(/obj/structure/bluespace_shield) in shield_turf)
			continue
		var/obj/structure/bluespace_shield/S = new(shield_turf, src)
		field_segments += S

	update_appearance()

/// Recalculates upkeep multiplier from enabled modes
/obj/machinery/power/bluespace_shield_generator/proc/update_upkeep_multiplier()
	var/new_upkeep = 1.0
	for(var/datum/bluespace_shield_mode/SM in mode_list)
		if(check_flag(SM.mode_flag))
			new_upkeep *= SM.multiplier
	upkeep_multiplier = new_upkeep

// =============================================================================
// DAMAGE
// =============================================================================

/// Process damage to the shield's energy reserve, return breach level
/obj/machinery/power/bluespace_shield_generator/proc/take_shield_damage(damage, damtype)
	var/energy_cost = damage * BSHIELD_ENERGY_PER_HP

	// Adaptive mitigation
	if(check_flag(BSHIELD_MODE_MODULATE))
		mitigation_em -= BSHIELD_MITIGATION_HIT_LOSS
		mitigation_heat -= BSHIELD_MITIGATION_HIT_LOSS
		mitigation_physical -= BSHIELD_MITIGATION_HIT_LOSS

		switch(damtype)
			if(BSHIELD_DAMTYPE_PHYSICAL)
				mitigation_physical += BSHIELD_MITIGATION_HIT_LOSS + BSHIELD_MITIGATION_HIT_GAIN
				energy_cost *= 1 - (mitigation_physical / 100)
			if(BSHIELD_DAMTYPE_EM)
				mitigation_em += BSHIELD_MITIGATION_HIT_LOSS + BSHIELD_MITIGATION_HIT_GAIN
				energy_cost *= 1 - (mitigation_em / 100)
			if(BSHIELD_DAMTYPE_HEAT)
				mitigation_heat += BSHIELD_MITIGATION_HIT_LOSS + BSHIELD_MITIGATION_HIT_GAIN
				energy_cost *= 1 - (mitigation_heat / 100)

		mitigation_em = clamp(mitigation_em, 0, mitigation_max)
		mitigation_heat = clamp(mitigation_heat, 0, mitigation_max)
		mitigation_physical = clamp(mitigation_physical, 0, mitigation_max)

	current_energy -= energy_cost

	// Play damage sound on generator itself
	playsound(src, 'sound/machines/BSD_damaging.ogg', 100, TRUE, extrarange = 10)

	if(current_energy < 0)
		energy_failure()
		return BSHIELD_BREACHED_FAILURE

	var/breach_roll = rand(field_integrity(), field_integrity() + 100)
	if(breach_roll <= BSHIELD_CRITICAL_BREACH_THRESHOLD)
		return BSHIELD_BREACHED_CRITICAL
	else if(breach_roll <= BSHIELD_MAJOR_BREACH_THRESHOLD)
		return BSHIELD_BREACHED_MAJOR
	else if(breach_roll <= BSHIELD_MINOR_BREACH_THRESHOLD)
		return BSHIELD_BREACHED_MINOR
	return BSHIELD_ABSORBED

/// Returns current field integrity as a 0-100 percentage
/obj/machinery/power/bluespace_shield_generator/proc/field_integrity()
	if(full_shield_strength)
		return round(clamp(current_energy / full_shield_strength, 0, 1) * 100)
	return 0

/// Called when internal energy is depleted
/obj/machinery/power/bluespace_shield_generator/proc/energy_failure()
	if(running == BSHIELD_DISCHARGING)
		shutdown_field()
	else
		current_energy = 0
		overloaded = TRUE
		for(var/obj/structure/bluespace_shield/S in field_segments)
			S.fail(1)

// =============================================================================
// DAMAGE RESISTANCE - CUSTOM BREAK INSTEAD OF DESTRUCTION
// =============================================================================

/// Intercept damage: play BSD sound, and break the generator instead of letting it reach atom_destruction
/obj/machinery/power/bluespace_shield_generator/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	if(broken)
		return
	if(damage_flag == BOMB)
		return
	var/effective_damage = damage_amount
	if(effective_damage >= atom_integrity && !broken)
		atom_integrity = max_integrity
		generator_break()
		playsound(src, 'sound/machines/BSD_damaging.ogg', 100, TRUE, extrarange = 10)
		return
	. = ..()
	if(damage_amount > 0)
		playsound(src, 'sound/machines/BSD_damaging.ogg', 100, TRUE, extrarange = 10)

/// Any destruction path that bypasses normal damage should still collapse the core instead of deleting the machine outright.
/obj/machinery/power/bluespace_shield_generator/atom_destruction(damage_flag)
	if(!broken)
		update_integrity(max_integrity)
		generator_break()
		return
	return ..()

/// Also play damage sound for projectile hits
/obj/machinery/power/bluespace_shield_generator/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit)
	if(!broken)
		playsound(src, 'sound/machines/BSD_damaging.ogg', 100, TRUE, extrarange = 10)
	return ..()

/// Light blasts are ignored, while heavy/devastating hits force the generator into its custom broken state.
/obj/machinery/power/bluespace_shield_generator/ex_act(severity, target)
	if(should_break_from_explosion(severity, target))
		generator_break()
		return TRUE
	return FALSE

/obj/machinery/power/bluespace_shield_generator/hypotheticalShuttleMove(rotation, move_mode, obj/docking_port/mobile/moving_dock)
	. = ..()
	if(. & MOVE_AREA)
		. |= MOVE_CONTENTS

/obj/machinery/power/bluespace_shield_generator/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	. = ..()
	if(. & MOVE_AREA)
		. |= MOVE_CONTENTS
	if(running == BSHIELD_RUNNING)
		clear_field_segments()
		sound_loop.stop()
		update_appearance()

/obj/machinery/power/bluespace_shield_generator/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	connect_to_network()
	if(!broken && running == BSHIELD_RUNNING)
		regenerate_field()
		sound_loop.start()
		update_appearance()

/obj/machinery/power/bluespace_shield_generator/blob_act(obj/structure/blob/B)
	if(!broken && prob(20))
		generator_break()

/// Breaks the generator: shuts down shields, triggers explosion, sets broken state
/obj/machinery/power/bluespace_shield_generator/proc/generator_break()
	if(broken)
		return
	broken = TRUE
	repair_state = BSHIELD_REPAIR_CROWBAR
	shutdown_field()
	end_processing()
	sound_loop.stop()
	priority_announce(
		"A catastrophic failure has been detected in the bluespace shield generator compartment. Containment is destroyed and the core is exposed. Engineering response required immediately.",
		"BLUESPACE GENERATOR FAILURE",
		'sound/machines/matteralarm.ogg',
		sender_override = "Bluespace Containment Monitoring",
		color_override = "red",
		text_ru = "В отсеке блюспейс-щитогенератора зафиксирована катастрофическая авария. Контейнмент разрушен, ядро оголено. Инженерной службе требуется немедленно отреагировать.",
		title_ru = "АВАРИЯ БЛЮСПЕЙС-ГЕНЕРАТОРА",
		sender_override_ru = "Мониторинг блюспейс-контейнмента",
	)
	playsound(src, 'sound/machines/BSD_explosion.ogg', 100, FALSE, extrarange = 30)
	addtimer(CALLBACK(src, PROC_REF(do_break_explosion)), 4 SECONDS)
	update_appearance()
	// Start 7-minute singularity countdown
	singularity_countdown = 420
	singularity_timer = addtimer(CALLBACK(src, PROC_REF(spawn_singularity)), 7 MINUTES, TIMER_STOPPABLE)
	warning_timer = addtimer(CALLBACK(src, PROC_REF(broadcast_singularity_warning)), 30 SECONDS, TIMER_STOPPABLE | TIMER_LOOP)

/// Creates the explosion after containment failure
/obj/machinery/power/bluespace_shield_generator/proc/do_break_explosion()
	var/turf/epicenter = get_turf(src)
	if(!epicenter)
		return
	explosion(epicenter, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 10, flame_range = 15, flash_range = 60, explosion_cause = src)

/// Broadcasts periodic warnings about impending singularity collapse
/obj/machinery/power/bluespace_shield_generator/proc/broadcast_singularity_warning()
	singularity_countdown = max(0, singularity_countdown - 30)
	if(!broken || singularity_countdown <= 0)
		if(warning_timer != TIMER_ID_NULL)
			deltimer(warning_timer)
			warning_timer = TIMER_ID_NULL
		return
	var/minutes = round(singularity_countdown / 60)
	var/seconds = singularity_countdown % 60
	var/time_text
	var/time_text_ru
	if(minutes > 0)
		time_text = "[minutes] min [seconds] sec"
		time_text_ru = "[minutes] мин [seconds] сек"
	else
		time_text = "[seconds] sec"
		time_text_ru = "[seconds] сек"
	priority_announce(
		"Critical bluespace destabilization detected. Core containment remains breached. Gravitational singularity formation expected in [time_text]. Repair immediately.",
		"BLUESPACE ALERT",
		'sound/misc/null.ogg',
		sender_override = "Bluespace Containment Monitoring",
		color_override = "red",
		text_ru = "Зафиксирована критическая дестабилизация блюспейса. Контейнмент ядра всё ещё нарушен. Формирование гравитационной сингулярности ожидается через [time_text_ru]. Немедленно приступите к ремонту.",
		title_ru = "ТРЕВОГА БЛЮСПЕЙСА",
		sender_override_ru = "Мониторинг блюспейс-контейнмента",
	)

/// Spawns a stage 6 gravitational singularity at the generator's location
/obj/machinery/power/bluespace_shield_generator/proc/spawn_singularity()
	singularity_timer = TIMER_ID_NULL
	if(warning_timer != TIMER_ID_NULL)
		deltimer(warning_timer)
		warning_timer = TIMER_ID_NULL
	singularity_countdown = 0
	if(!broken)
		return
	var/turf/T = get_turf(src)
	if(!T)
		return
	priority_announce(
		"Containment failure is now total. A gravitational singularity has formed at the generator site.",
		"BLUESPACE CATASTROPHE",
		sender_override = "Bluespace Containment Monitoring",
		color_override = "red",
		text_ru = "Контейнмент полностью утрачен. В зоне генератора сформировалась гравитационная сингулярность.",
		title_ru = "БЛЮСПЕЙС-КАТАСТРОФА",
		sender_override_ru = "Мониторинг блюспейс-контейнмента",
	)
	playsound(T, 'sound/machines/matteralarm.ogg', 200, FALSE, extrarange = 50)
	var/obj/singularity/S = new(T)
	S.consumed_supermatter = TRUE
	S.energy = STAGE_SIX_ENERGY
	qdel(src)

// =============================================================================
// REPAIR SYSTEM - step by step
// =============================================================================

/obj/machinery/power/bluespace_shield_generator/examine(mob/user)
	. = ..()
	if(broken)
		. += span_danger("Structural integrity: catastrophic failure.")
		. += span_danger("The bluespace containment field has collapsed. The core is exposed and sparking.")
		if(singularity_countdown > 0)
			var/cd_minutes = round(singularity_countdown / 60)
			var/cd_seconds = singularity_countdown % 60
			var/cd_text = cd_minutes > 0 ? "[cd_minutes] MIN [cd_seconds] SEC" : "[cd_seconds] SEC"
			. += span_bolddanger("SINGULARITY COLLAPSE IN [cd_text]! REPAIR IMMEDIATELY!")
		switch(repair_state)
			if(BSHIELD_REPAIR_CROWBAR)
				. += span_notice("The wrecked casing panels are jammed shut over the internals. They need to be <b>pried open</b> with a crowbar.")
			if(BSHIELD_REPAIR_WELD_DEBRIS)
				. += span_notice("Molten metal shrapnel is fused to the internal frame. It must be <b>cut away with a welder</b>.")
			if(BSHIELD_REPAIR_PLASTEEL)
				. += span_notice("The containment vessel is breached. <b>50 sheets of plasteel</b> are needed to rebuild the outer shell.")
			if(BSHIELD_REPAIR_WELD_CASING)
				. += span_notice("The new plasteel plating is loosely placed. The seams must be <b>welded</b> shut.")
			if(BSHIELD_REPAIR_WRENCH_FRAME)
				. += span_notice("The welded plating needs to be <b>bolted</b> into the structural frame with a wrench.")
			if(BSHIELD_REPAIR_CABLES)
				. += span_notice("The internal power conduits are completely fried. <b>30 cable pieces</b> are needed to replace the wiring.")
			if(BSHIELD_REPAIR_WIRECUTTER)
				. += span_notice("The new cabling has excess length and exposed leads. It must be <b>trimmed with wirecutters</b>.")
			if(BSHIELD_REPAIR_SCREWDRIVER)
				. += span_notice("The access panels are still open. They need to be <b>screwed</b> back into place.")
			if(BSHIELD_REPAIR_URANIUM)
				. += span_warning("The radiation dampening rods have been vaporized. <b>10 sheets of uranium</b> are required to replace them.")
				. += span_boldwarning("Warning: inserting uranium into the exposed core will cause a radiation pulse!")
			if(BSHIELD_REPAIR_CRYSTAL)
				. += span_notice("The bluespace resonance matrix is shattered. A <b>bluespace crystal</b> must be inserted into the focusing chamber.")
			if(BSHIELD_REPAIR_MULTITOOL)
				. += span_notice("All hardware is in place, but the control firmware is corrupted. A <b>multitool</b> is needed to flash the backup firmware and recalibrate the containment field harmonics.")
			if(BSHIELD_REPAIR_WELD_FINAL)
				. += span_notice("Final step - the containment seals must be <b>welded</b> shut to restore full integrity.")
		. += span_notice("Repair progress: step [repair_state + 1] of 12.")
	else
		var/integrity_percent = round(get_integrity_percentage() * 100)
		if(integrity_percent >= 75)
			. += span_notice("Structural integrity: [integrity_percent]%.")
		else if(integrity_percent >= 40)
			. += span_warning("Structural integrity: [integrity_percent]%.")
		else
			. += span_danger("Structural integrity: [integrity_percent]%.")
		if(atom_integrity < max_integrity)
			if(running != BSHIELD_OFF || offline_for)
				. += span_notice("The outer casing can be repaired with a welder once the generator is fully offline.")
			else
				. += span_notice("The outer casing can be repaired with a welder.")
		if(running)
			. += span_notice("It is currently [running == BSHIELD_RUNNING ? "active with shields deployed" : "in standby mode"].")
			. += span_notice("Field integrity: [field_integrity()]%.")
			. += span_notice("Segments: [length(field_segments) - length(damaged_segments)]/[length(field_segments)] active.")
		else if(offline_for)
			. += span_warning("It is cooling down from an emergency shutdown. [offline_for * 2] seconds remaining.")
		else
			. += span_notice("It is offline.")
	if(overloaded)
		. += span_danger("The generator is overloaded!")

/obj/machinery/power/bluespace_shield_generator/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(broken)
		var/result = attempt_repair(user, tool)
		if(result)
			return result
	return ..()

/obj/machinery/power/bluespace_shield_generator/welder_act(mob/living/user, obj/item/tool)
	if(broken)
		return NONE
	if(atom_integrity >= max_integrity)
		return NONE
	if(running != BSHIELD_OFF || offline_for)
		to_chat(user, span_warning("[src] must be fully offline before you can repair the outer casing."))
		return ITEM_INTERACT_SUCCESS
	if(!tool.tool_start_check(user, amount = 1))
		return ITEM_INTERACT_SUCCESS
	to_chat(user, span_notice("You begin welding shut the cracks in [src]'s outer casing..."))
	if(tool.use_tool(src, user, 4 SECONDS, volume = 50))
		var/repaired = repair_damage(150)
		if(repaired > 0)
			to_chat(user, span_notice("You restore [repaired] integrity to [src]'s outer casing."))
			if(atom_integrity >= max_integrity)
				to_chat(user, span_notice("[src] is fully repaired."))
	return ITEM_INTERACT_SUCCESS

/// Handles all repair interactions when broken - runs before tool_act() chain
/obj/machinery/power/bluespace_shield_generator/proc/attempt_repair(mob/living/user, obj/item/weapon)
	// Periodic electrical discharge during repair - hurts the repairer
	if(prob(15) && repair_state >= BSHIELD_REPAIR_CABLES)
		do_sparks(5, TRUE, src)
		to_chat(user, span_userdanger("A violent arc of energy leaps from the exposed core and shocks you!"))
		user.electrocute_act(rand(10, 25), src)
		return ITEM_INTERACT_SUCCESS

	switch(repair_state)
		if(BSHIELD_REPAIR_CROWBAR)
			if(weapon.tool_behaviour == TOOL_CROWBAR)
				to_chat(user, span_notice("You begin prying the warped casing panels open..."))
				if(weapon.use_tool(src, user, 8 SECONDS, volume = 80))
					to_chat(user, span_notice("You wrench the jammed panels open, exposing the devastated internals."))
					repair_state++
				return ITEM_INTERACT_SUCCESS

		if(BSHIELD_REPAIR_WELD_DEBRIS)
			if(weapon.tool_behaviour == TOOL_WELDER)
				to_chat(user, span_notice("You begin cutting away the fused shrapnel from the frame..."))
				if(weapon.use_tool(src, user, 10 SECONDS, volume = 50))
					if(prob(20))
						to_chat(user, span_danger("A chunk of superheated metal flies off and burns you!"))
						user.adjust_fire_loss(rand(5, 15))
					to_chat(user, span_notice("You cut away the last of the molten debris."))
					repair_state++
				return ITEM_INTERACT_SUCCESS

		if(BSHIELD_REPAIR_PLASTEEL)
			if(istype(weapon, /obj/item/stack/sheet/plasteel))
				var/obj/item/stack/sheet/plasteel/PS = weapon
				if(PS.get_amount() >= 50)
					to_chat(user, span_notice("You begin fitting the new plasteel plating..."))
					if(do_after(user, 6 SECONDS, src))
						PS.use(50)
						to_chat(user, span_notice("You replace the shattered containment vessel with fresh plasteel plating."))
						playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
						repair_state++
				else
					to_chat(user, span_warning("You need at least 50 sheets of plasteel!"))
				return ITEM_INTERACT_SUCCESS

		if(BSHIELD_REPAIR_WELD_CASING)
			if(weapon.tool_behaviour == TOOL_WELDER)
				to_chat(user, span_notice("You begin welding the plasteel seams shut..."))
				if(weapon.use_tool(src, user, 12 SECONDS, volume = 50))
					to_chat(user, span_notice("You seal every seam on the new outer casing."))
					repair_state++
				return ITEM_INTERACT_SUCCESS

		if(BSHIELD_REPAIR_WRENCH_FRAME)
			if(weapon.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("You begin tightening the structural bolts..."))
				if(weapon.use_tool(src, user, 8 SECONDS, volume = 50))
					to_chat(user, span_notice("You bolt the outer plating firmly into the structural frame."))
					repair_state++
				return ITEM_INTERACT_SUCCESS

		if(BSHIELD_REPAIR_CABLES)
			if(istype(weapon, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/CC = weapon
				if(CC.get_amount() >= 30)
					to_chat(user, span_notice("You begin replacing the fried power conduits..."))
					if(do_after(user, 10 SECONDS, src))
						CC.use(30)
						to_chat(user, span_notice("You thread new cabling through the power distribution grid."))
						playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
						repair_state++
				else
					to_chat(user, span_warning("You need at least 30 cable pieces!"))
				return ITEM_INTERACT_SUCCESS

		if(BSHIELD_REPAIR_WIRECUTTER)
			if(weapon.tool_behaviour == TOOL_WIRECUTTER)
				to_chat(user, span_notice("You begin trimming the excess cable and sealing the leads..."))
				if(weapon.use_tool(src, user, 6 SECONDS, volume = 50))
					to_chat(user, span_notice("You trim the wiring and insulate all exposed leads."))
					repair_state++
				return ITEM_INTERACT_SUCCESS

		if(BSHIELD_REPAIR_SCREWDRIVER)
			if(weapon.tool_behaviour == TOOL_SCREWDRIVER)
				to_chat(user, span_notice("You begin fastening the access panels..."))
				if(weapon.use_tool(src, user, 6 SECONDS, volume = 50))
					to_chat(user, span_notice("You screw all access panels back into place."))
					repair_state++
				return ITEM_INTERACT_SUCCESS

		if(BSHIELD_REPAIR_URANIUM)
			if(istype(weapon, /obj/item/stack/sheet/mineral/uranium))
				var/obj/item/stack/sheet/mineral/uranium/UR = weapon
				if(UR.get_amount() >= 10)
					to_chat(user, span_boldwarning("You brace yourself and begin inserting the uranium dampening rods into the exposed core..."))
					if(do_after(user, 8 SECONDS, src))
						UR.use(10)
						to_chat(user, span_notice("You slot the uranium rods into the radiation dampening matrix."))
						to_chat(user, span_userdanger("A wave of radiation washes over you as the rods make contact with the destabilized core!"))
						playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
						radiation_pulse(src, max_range = 5, threshold = 0.3, chance = 100)
						repair_state++
				else
					to_chat(user, span_warning("You need at least 10 sheets of uranium!"))
				return ITEM_INTERACT_SUCCESS

		if(BSHIELD_REPAIR_CRYSTAL)
			if(istype(weapon, /obj/item/stack/ore/bluespace_crystal))
				to_chat(user, span_notice("You carefully align the bluespace crystal with the focusing chamber..."))
				if(do_after(user, 10 SECONDS, src))
					if(!user.temporarilyRemoveItemFromInventory(weapon))
						return ITEM_INTERACT_SUCCESS
					qdel(weapon)
					to_chat(user, span_notice("The crystal locks into the resonance matrix. The chamber hums with bluespace energy."))
					playsound(src.loc, 'sound/machines/BSD_interact.ogg', 75, TRUE)
					repair_state++
				return ITEM_INTERACT_SUCCESS

		if(BSHIELD_REPAIR_MULTITOOL)
			if(istype(weapon, /obj/item/multitool))
				to_chat(user, span_notice("You connect the multitool and begin flashing the backup firmware..."))
				if(weapon.use_tool(src, user, 15 SECONDS, volume = 30))
					if(prob(30))
						to_chat(user, span_danger("Firmware checksum mismatch! The upload failed - you need to try again."))
						return ITEM_INTERACT_SUCCESS
					to_chat(user, span_notice("Firmware restored. Containment field harmonics recalibrated successfully."))
					weapon.play_tool_sound(src)
					repair_state++
				return ITEM_INTERACT_SUCCESS

		if(BSHIELD_REPAIR_WELD_FINAL)
			if(weapon.tool_behaviour == TOOL_WELDER)
				to_chat(user, span_notice("You begin sealing the final containment welds..."))
				if(weapon.use_tool(src, user, 15 SECONDS, volume = 50))
					to_chat(user, span_notice("You finish the last weld. The containment seals glow with a reassuring blue light."))
					to_chat(user, span_boldnotice("The generator hums back to life! Bluespace containment restored!"))
					generator_fix()
				return ITEM_INTERACT_SUCCESS

	return NONE

/// Restores the generator from broken state
/obj/machinery/power/bluespace_shield_generator/proc/generator_fix()
	broken = FALSE
	running = BSHIELD_OFF
	repair_state = BSHIELD_REPAIR_CROWBAR
	atom_integrity = max_integrity
	// Cancel singularity countdown
	if(singularity_timer != TIMER_ID_NULL)
		deltimer(singularity_timer)
		singularity_timer = TIMER_ID_NULL
	if(warning_timer != TIMER_ID_NULL)
		deltimer(warning_timer)
		warning_timer = TIMER_ID_NULL
	singularity_countdown = 0
	end_processing()
	priority_announce(
		"Bluespace generator containment restored. Singularity threat eliminated.",
		"BLUESPACE STABLE",
		sender_override = "Bluespace Containment Monitoring",
		color_override = "green",
		text_ru = "Контейнмент блюспейс-генератора восстановлен. Угроза сингулярности устранена.",
		title_ru = "БЛЮСПЕЙС СТАБИЛЕН",
		sender_override_ru = "Мониторинг блюспейс-контейнмента",
	)
	update_appearance()

// =============================================================================
// STATE CONTROL
// =============================================================================

/// Checks whether a specific mode flag is enabled
/obj/machinery/power/bluespace_shield_generator/proc/check_flag(flag)
	return (shield_modes & flag)

/// Toggles a specific mode flag
/obj/machinery/power/bluespace_shield_generator/proc/toggle_flag(flag)
	shield_modes ^= flag
	update_upkeep_multiplier()
	for(var/obj/structure/bluespace_shield/S in field_segments)
		S.flags_updated()

	// Modulate reset
	if(flag & BSHIELD_MODE_MODULATE)
		mitigation_em = 0
		mitigation_physical = 0
		mitigation_heat = 0

/// Switches between idle and running states
/obj/machinery/power/bluespace_shield_generator/proc/set_idle(new_state)
	if(new_state)
		if(running == BSHIELD_IDLE)
			return
		running = BSHIELD_IDLE
		clear_field_segments()
		sound_loop.stop()
	else
		if(running != BSHIELD_IDLE)
			return
		running = BSHIELD_SPINNING_UP
		spinup_counter = round(spinup_delay / idle_multiplier)

/// Returns descriptions of all modes for the UI
/obj/machinery/power/bluespace_shield_generator/proc/get_flag_descriptions()
	var/list/all_flags = list()
	for(var/datum/bluespace_shield_mode/SM in mode_list)
		if(SM.hacked_only && !hacked)
			continue
		all_flags += list(list(
			"name" = SM.mode_name,
			"desc" = SM.mode_desc,
			"flag" = SM.mode_flag,
			"status" = !!check_flag(SM.mode_flag),
			"hacked" = SM.hacked_only,
			"multiplier" = SM.multiplier,
		))
	return all_flags

// =============================================================================
// TGUI
// =============================================================================

/obj/machinery/power/bluespace_shield_generator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BluespaceShieldGen")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/power/bluespace_shield_generator/ui_data(mob/user)
	var/list/data = list()
	data["running"] = running
	data["modes"] = get_flag_descriptions()
	data["overloaded"] = overloaded
	data["mitigation_max"] = mitigation_max
	data["mitigation_physical"] = round(mitigation_physical, 0.1)
	data["mitigation_em"] = round(mitigation_em, 0.1)
	data["mitigation_heat"] = round(mitigation_heat, 0.1)
	data["field_integrity"] = field_integrity()
	data["max_energy"] = round(max_energy / 1000000, 0.1)
	data["current_energy"] = round(current_energy / 1000000, 0.1)
	data["percentage_energy"] = max_energy ? round(current_energy / max_energy * 100) : 0
	data["total_segments"] = length(field_segments)
	data["functional_segments"] = length(field_segments) - length(damaged_segments)
	data["input_cap_kw"] = round(input_cap / 1000)
	data["upkeep_power_usage"] = round(upkeep_power_usage / 1000, 0.1)
	data["power_usage"] = round(power_usage / 1000)
	data["grid_connected"] = !!powernet
	data["hacked"] = hacked
	data["offline_for"] = offline_for * 2
	data["full_stop"] = full_stop
	data["idle_multiplier"] = idle_multiplier
	data["idle_valid_values"] = idle_valid_values
	data["broken"] = broken
	return data

/obj/machinery/power/bluespace_shield_generator/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(broken)
		return TRUE

	// Play interact sound for every UI action
	playsound(src, 'sound/machines/BSD_interact.ogg', 70, TRUE, extrarange = 5)

	switch(action)
		if("start_generator")
			if(offline_for)
				return TRUE
			if(running != BSHIELD_OFF)
				return TRUE
			connect_to_network()
			running = BSHIELD_IDLE
			begin_processing()
			set_idle(FALSE)
			update_appearance()
			return TRUE

		if("begin_shutdown")
			if(running == BSHIELD_OFF || running == BSHIELD_DISCHARGING)
				return TRUE
			// From IDLE or SPINNING_UP - no field active, just turn off directly
			if(running == BSHIELD_IDLE || running == BSHIELD_SPINNING_UP)
				shutdown_field()
				end_processing()
				return TRUE
			// From RUNNING - discharge energy first
			set_idle(TRUE)
			running = BSHIELD_DISCHARGING
			return TRUE

		if("toggle_idle")
			if(running < BSHIELD_RUNNING && running != BSHIELD_IDLE)
				return TRUE
			set_idle(running != BSHIELD_IDLE)
			return TRUE

		if("emergency_shutdown")
			if(!running)
				return TRUE
			full_stop = FALSE
			offline_for = 250
			var/old_energy = current_energy
			shutdown_field()
			// Keep processing alive so offline_for ticks down
			begin_processing()
			// EMP from stored energy release
			if(old_energy > 0)
				empulse(src, old_energy / 60000000, old_energy / 32000000, TRUE)
			return TRUE

		if("toggle_mode")
			if(mode_changes_locked)
				return TRUE
			var/flag = text2num(params["flag"])
			if(!flag)
				return TRUE
			if((flag & (BSHIELD_MODE_BYPASS | BSHIELD_MODE_OVERCHARGE)) && !hacked)
				return TRUE
			toggle_flag(flag)
			return TRUE

		if("set_input_cap")
			if(mode_changes_locked)
				return TRUE
			var/new_cap = text2num(params["cap"])
			if(isnull(new_cap))
				return TRUE
			input_cap = max(0, new_cap) * 1000
			return TRUE

		if("switch_idle")
			var/new_idle = text2num(params["value"])
			if(!(new_idle in idle_valid_values))
				return TRUE
			idle_multiplier = new_idle
			return TRUE

// =============================================================================
// INTERACTION
// =============================================================================

/obj/machinery/power/bluespace_shield_generator/screwdriver_act(mob/living/user, obj/item/tool)
	if(broken)
		return ITEM_INTERACT_BLOCKING
	if(running)
		balloon_alert(user, "turn off first!")
		return ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, "bsd_core", "bsd_core", tool))
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/power/bluespace_shield_generator/crowbar_act(mob/living/user, obj/item/tool)
	if(broken)
		return ITEM_INTERACT_BLOCKING
	if(running)
		balloon_alert(user, "turn off first!")
		return ITEM_INTERACT_BLOCKING
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return ..()
