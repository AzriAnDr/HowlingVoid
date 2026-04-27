// Bluespace Shield Field Generator - Shield Segment
// Individual energy field tiles that make up the shield barrier.

/obj/structure/bluespace_shield
	name = "bluespace energy shield"
	desc = "An impenetrable field of bluespace energy, capable of blocking anything as long as it's active."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-old"
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	density = TRUE
	opacity = FALSE
	move_resist = INFINITY
	can_atmos_pass = ATMOS_PASS_PROC
	resistance_flags = INDESTRUCTIBLE
	/// The generator that owns this segment
	var/obj/machinery/power/bluespace_shield_generator/gen
	/// Ticks remaining before this segment regenerates
	var/disabled_for = 0
	/// Ticks remaining while diffused
	var/diffused_for = 0
	/// Current hit points of this segment
	var/shield_hp = 200
	/// Maximum hit points (scales with generator mitigation)
	var/shield_max_hp = 200
	/// Base HP before scaling
	var/base_hp = 200
	/// Whether this segment is currently blocking explosions
	var/blocking_explosions = FALSE

/obj/structure/bluespace_shield/Initialize(mapload, obj/machinery/power/bluespace_shield_generator/new_gen)
	. = ..()
	if(QDELETED(new_gen))
		return INITIALIZE_HINT_QDEL
	gen = new_gen
	update_explosion_blocking()
	update_appearance()
	air_update_turf(TRUE, TRUE)

/obj/structure/bluespace_shield/Destroy()
	if(gen)
		gen.field_segments -= src
		gen.damaged_segments -= src
		gen = null
	air_update_turf(TRUE, TRUE)
	return ..()

/obj/structure/bluespace_shield/update_overlays()
	. = ..()
	if(!gen)
		return
	if(gen.check_flag(BSHIELD_MODE_OVERCHARGE) && !disabled_for && !diffused_for)
		. += mutable_appearance(icon, "shield-red")

/obj/structure/bluespace_shield/update_icon_state()
	. = ..()
	if(!gen)
		icon_state = "shield-old"
		return
	if(disabled_for || diffused_for)
		invisibility = INVISIBILITY_MAXIMUM
		return
	invisibility = 0
	if(gen.check_flag(BSHIELD_MODE_PHOTONIC))
		set_opacity(TRUE)
	else
		set_opacity(FALSE)
	icon_state = "shield-old"

// Prevents anything from forcemoving shield segments
/obj/structure/bluespace_shield/forceMove(atom/destination, no_tp, harderforce)
	if(QDELING(src))
		return ..()
	return FALSE

// --- DAMAGE HANDLING ---

/obj/structure/bluespace_shield/proc/take_shield_damage(damage, damtype, atom/hitby)
	if(!gen)
		qdel(src)
		return
	if(!damage)
		return

	damage = round(damage)

	// Scale max HP with mitigation and field integrity
	var/mitigation = 0
	switch(damtype)
		if(BSHIELD_DAMTYPE_PHYSICAL)
			mitigation = gen.mitigation_physical
		if(BSHIELD_DAMTYPE_EM)
			mitigation = gen.mitigation_em
		if(BSHIELD_DAMTYPE_HEAT)
			mitigation = gen.mitigation_heat
	var/integrity_multiplier = 1 + (gen.field_integrity() / 100) * 9
	shield_max_hp = base_hp * (1 + mitigation / 100) * integrity_multiplier

	// Segment absorbs damage with its own HP first
	shield_hp -= damage

	// Visual impact effect
	impact_effect(round(abs(damage * 2)))

	if(shield_hp <= 0)
		// HP depleted - overflow damage goes to generator energy
		var/overflow = abs(shield_hp)
		shield_hp = 0
		var/breach = gen.take_shield_damage(overflow, damtype)
		// Only this segment fails; no cascade unless critical/failure
		switch(breach)
			if(BSHIELD_ABSORBED, BSHIELD_BREACHED_MINOR)
				fail(3)
			if(BSHIELD_BREACHED_MAJOR)
				fail(5)
			if(BSHIELD_BREACHED_CRITICAL)
				fail_adjacent(1, hitby)
			if(BSHIELD_BREACHED_FAILURE)
				fail_adjacent(2, hitby)

/// Temporarily collapses this segment
/obj/structure/bluespace_shield/proc/fail(duration)
	if(duration <= 0)
		return
	if(gen)
		gen.damaged_segments |= src
	disabled_for += duration
	set_density(FALSE)
	invisibility = INVISIBILITY_MAXIMUM
	set_opacity(FALSE)
	update_explosion_blocking()
	air_update_turf(TRUE, TRUE)
	update_appearance()

/// Regenerates this segment (called each tick by the generator)
/obj/structure/bluespace_shield/proc/regenerate()
	if(!gen)
		return
	disabled_for = max(0, disabled_for - 1)
	diffused_for = max(0, diffused_for - 1)
	// Recalculate max HP based on current field integrity and mitigation
	var/integrity_multiplier = 1 + (gen.field_integrity() / 100) * 9
	var/best_mitigation = max(gen.mitigation_em, gen.mitigation_physical, gen.mitigation_heat)
	shield_max_hp = base_hp * (1 + best_mitigation / 100) * integrity_multiplier
	// Regenerate HP each tick
	if(shield_hp < shield_max_hp)
		shield_hp = min(shield_hp + round(shield_max_hp * 0.1), shield_max_hp)
	if(!disabled_for && !diffused_for)
		set_density(TRUE)
		invisibility = 0
		update_explosion_blocking()
		air_update_turf(TRUE, TRUE)
		update_appearance()
		gen.damaged_segments -= src

/// Diffuse this segment (from shield diffusers)
/obj/structure/bluespace_shield/proc/diffuse(duration)
	if(!gen)
		return
	if(gen.check_flag(BSHIELD_MODE_BYPASS) && !disabled_for)
		take_shield_damage(duration * rand(8, 12), BSHIELD_DAMTYPE_EM)
		return
	diffused_for = max(duration, 0)
	gen.damaged_segments |= src
	set_density(FALSE)
	invisibility = INVISIBILITY_MAXIMUM
	set_opacity(FALSE)
	update_explosion_blocking()
	air_update_turf(TRUE, TRUE)
	update_appearance()

/// Fails this segment and adjacent ones
/obj/structure/bluespace_shield/proc/fail_adjacent(range, atom/hitby)
	if(hitby)
		visible_message(span_danger("[src] flashes as [hitby] collides with it, fading in a rain of sparks!"))
	else
		visible_message(span_danger("[src] flashes and fades in a rain of sparks!"))
	fail(range * 2)
	for(var/obj/structure/bluespace_shield/S in range(range, src))
		if(S.gen != gen)
			continue
		S.fail(-(-range + get_dist(src, S)) * 2)

/// Overcharge shock on contact
/obj/structure/bluespace_shield/proc/overcharge_shock(mob/living/victim)
	victim.adjust_fire_loss(rand(20, 40))
	victim.Knockdown(5 SECONDS)
	to_chat(victim, span_danger("A surge of energy from [src] paralyzes you!"))
	take_shield_damage(10, BSHIELD_DAMTYPE_EM)

/// Visual ripple effect spreading across shield segments
/obj/structure/bluespace_shield/proc/impact_effect(intensity, list/affected = list())
	intensity = clamp(intensity, 1, 10)
	var/old_color = color
	color = gen?.check_flag(BSHIELD_MODE_OVERCHARGE) ? COLOR_VIVID_YELLOW : COLOR_CYAN
	animate(src, color = old_color, time = 1 SECONDS)
	affected |= src
	intensity--
	if(intensity)
		addtimer(CALLBACK(src, PROC_REF(spread_impact), intensity, affected), 0.2 SECONDS)

/obj/structure/bluespace_shield/proc/spread_impact(intensity, list/affected)
	for(var/direction in GLOB.cardinals)
		var/turf/T = get_step(src, direction)
		if(!T)
			continue
		for(var/obj/structure/bluespace_shield/neighbor in T)
			if(!(neighbor in affected))
				neighbor.impact_effect(intensity, affected)

/// Called when mode flags change on the generator
/obj/structure/bluespace_shield/proc/flags_updated()
	if(!gen)
		qdel(src)
		return
	update_explosion_blocking()
	air_update_turf(TRUE, TRUE)
	update_appearance()

/// Adds or removes explosion blocking based on mode and segment state
/obj/structure/bluespace_shield/proc/update_explosion_blocking()
	var/should_block = gen && gen.check_flag(BSHIELD_MODE_DAMPEN) && !disabled_for && !diffused_for
	if(should_block && !blocking_explosions)
		explosion_block = BSHIELD_EXPLOSION_BLOCK
		AddElement(/datum/element/blocks_explosives)
		blocking_explosions = TRUE
	else if(!should_block && blocking_explosions)
		RemoveElement(/datum/element/blocks_explosives)
		explosion_block = 0
		blocking_explosions = FALSE

// --- ATMOS PASS ---

/obj/structure/bluespace_shield/can_atmos_pass(turf/T, vertical)
	if(!gen || disabled_for || diffused_for)
		return TRUE
	return !gen.check_flag(BSHIELD_MODE_ATMOSPHERIC)

// --- MOVEMENT PASS ---

/obj/structure/bluespace_shield/CanPass(atom/movable/mover, border_dir)
	. = ..()
	if(!gen || disabled_for || diffused_for)
		return TRUE
	if(!mover)
		return TRUE
	return mover.can_pass_bluespace_shield(gen)

// --- INCOMING DAMAGE ---

/obj/structure/bluespace_shield/bullet_act(obj/projectile/proj, def_zone)
	. = ..()
	if(disabled_for)
		return
	if(proj.damage_type == BURN)
		take_shield_damage(proj.damage, BSHIELD_DAMTYPE_HEAT, proj)
	else if(proj.damage_type == BRUTE)
		take_shield_damage(proj.damage, BSHIELD_DAMTYPE_PHYSICAL, proj)
	else
		take_shield_damage(proj.damage, BSHIELD_DAMTYPE_EM, proj)

/obj/structure/bluespace_shield/ex_act(severity)
	if(disabled_for)
		return
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_shield_damage(rand(60, 80), BSHIELD_DAMTYPE_PHYSICAL)
		if(EXPLODE_HEAVY)
			take_shield_damage(rand(30, 50), BSHIELD_DAMTYPE_PHYSICAL)
		if(EXPLODE_LIGHT)
			take_shield_damage(rand(10, 20), BSHIELD_DAMTYPE_PHYSICAL)

/obj/structure/bluespace_shield/emp_act(severity)
	. = ..()
	if(!disabled_for)
		take_shield_damage(rand(30, 60) / severity, BSHIELD_DAMTYPE_EM)

/obj/structure/bluespace_shield/attackby(obj/item/weapon, mob/living/user, params)
	user.changeNext_move(weapon.attack_speed)
	user.do_attack_animation(src)
	playsound(src, weapon.hitsound, 50, TRUE)
	visible_message(span_danger("[user] hits [src] with [weapon]!"))
	switch(weapon.damtype)
		if(BURN)
			take_shield_damage(weapon.force, BSHIELD_DAMTYPE_HEAT, weapon)
		if(BRUTE)
			take_shield_damage(weapon.force, BSHIELD_DAMTYPE_PHYSICAL, weapon)
		else
			take_shield_damage(weapon.force, BSHIELD_DAMTYPE_EM, weapon)

/obj/structure/bluespace_shield/Bumped(atom/movable/bumper)
	. = ..()
	if(!gen)
		qdel(src)
		return
	impact_effect(2)
	if(gen.check_flag(BSHIELD_MODE_OVERCHARGE) && isliving(bumper))
		overcharge_shock(bumper)

// --- CAN_PASS OVERRIDES FOR ATOM TYPES ---

/atom/movable/proc/can_pass_bluespace_shield(obj/machinery/power/bluespace_shield_generator/gen)
	return TRUE

/mob/living/can_pass_bluespace_shield(obj/machinery/power/bluespace_shield_generator/gen)
	return !gen.check_flag(BSHIELD_MODE_NONHUMANS)

/mob/living/carbon/human/can_pass_bluespace_shield(obj/machinery/power/bluespace_shield_generator/gen)
	if(issynthetic(src))
		return !gen.check_flag(BSHIELD_MODE_SILICON)
	return !gen.check_flag(BSHIELD_MODE_HUMANOIDS)

/mob/living/silicon/can_pass_bluespace_shield(obj/machinery/power/bluespace_shield_generator/gen)
	return !gen.check_flag(BSHIELD_MODE_SILICON)

/obj/can_pass_bluespace_shield(obj/machinery/power/bluespace_shield_generator/gen)
	return !gen.check_flag(BSHIELD_MODE_HYPERKINETIC)

/obj/projectile/beam/can_pass_bluespace_shield(obj/machinery/power/bluespace_shield_generator/gen)
	return !gen.check_flag(BSHIELD_MODE_PHOTONIC)