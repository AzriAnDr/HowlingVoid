#define BASE_REGEN_PER_SECOND 5
#define EMPOWERED_REGEN_PER_SECOND 10
#define BASE_REGEN_DELAY 30 SECONDS
#define EMPOWERED_REGEN_DELAY 10 SECONDS

/obj/structure/destructible/clockwork/wall_lattice
	name = "clockwork stabilization lattice"
	desc = "A field of energy around a clockwork wall. If destroyed, the wall it supports will collapse."
	icon = 'icons/clock_cult/clockwork_effects.dmi'
	icon_state = "wall_energy_lattice"
	alpha = 130
	layer = ABOVE_NORMAL_TURF_LAYER
	density = FALSE
	max_integrity = 400
	resistance_flags = ACID_PROOF | FIRE_PROOF | LAVA_PROOF
	anchored = TRUE
	break_sound = null
	armor_type = /datum/armor/clockwork_wall_lattice
	break_message = span_warning("The stabilization lattice rapidly collapses, bringing the wall it supported with it!")
	debris = null
	immune_to_servant_attacks = TRUE
	clockwork_desc = "Protects and stabilizes a clockwork wall."
	var/turf/closed/wall/mineral/bronze/linked_wall
	var/is_empowered = FALSE
	var/regenerate_at = 0
	var/regen_per_second = BASE_REGEN_PER_SECOND
	var/regen_delay = BASE_REGEN_DELAY

/obj/structure/destructible/clockwork/wall_lattice/Initialize(mapload, atom/link_to)
	. = ..()
	if(istype(link_to, /turf/closed/wall/mineral/bronze))
		linked_wall = link_to
	else if(istype(get_turf(src), /turf/closed/wall/mineral/bronze))
		linked_wall = get_turf(src)

	if(!linked_wall)
		return INITIALIZE_HINT_QDEL

/obj/structure/destructible/clockwork/wall_lattice/Destroy()
	STOP_PROCESSING(SSobj, src)
	var/turf/closed/wall/mineral/bronze/old_wall = linked_wall
	linked_wall = null
	if(!QDELETED(old_wall))
		old_wall.dismantle_wall()
	return ..()

/obj/structure/destructible/clockwork/wall_lattice/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	if(!regenerate_at)
		START_PROCESSING(SSobj, src)
		regenerate_at = world.time + regen_delay
	return ..()

/obj/structure/destructible/clockwork/wall_lattice/process(seconds_per_tick)
	if(world.time > regenerate_at)
		repair_damage(regen_per_second * seconds_per_tick)

	if(atom_integrity >= max_integrity)
		regenerate_at = 0
		return PROCESS_KILL

/obj/structure/destructible/clockwork/wall_lattice/play_attack_sound(damage_amount, damage_type, damage_flag)
	playsound(get_turf(src), 'sound/effects/empulse.ogg', 75, TRUE)

/obj/structure/destructible/clockwork/wall_lattice/proc/empower()
	if(is_empowered)
		return FALSE

	is_empowered = TRUE
	regen_per_second = EMPOWERED_REGEN_PER_SECOND
	regen_delay = EMPOWERED_REGEN_DELAY
	set_armor(/datum/armor/empowered_clockwork_wall_lattice)
	if(regenerate_at)
		regenerate_at -= (BASE_REGEN_DELAY - EMPOWERED_REGEN_DELAY)
	return TRUE

/datum/armor/clockwork_wall_lattice
	melee = 10
	bullet = 40
	laser = 30
	energy = 30
	bomb = 100
	bio = 100

/datum/armor/empowered_clockwork_wall_lattice
	melee = 30
	bullet = 60
	laser = 50
	energy = 50
	bomb = 100
	bio = 100

#undef BASE_REGEN_PER_SECOND
#undef EMPOWERED_REGEN_PER_SECOND
#undef BASE_REGEN_DELAY
#undef EMPOWERED_REGEN_DELAY
