#define PA_PARTICLE_RADIATION_RANGE 1
#define PA_PARTICLE_RADIATION_THRESHOLD RAD_EXTREME_INSULATION
#define PA_PARTICLE_RADIATION_CHANCE_PER_ENERGY 2
#define PA_PARTICLE_RADIATION_MAX_CHANCE 100
#define PA_PARTICLE_RADIATION_CONTAMINATION_MULTIPLIER 0.375

/obj/effect/accelerated_particle
	name = "Accelerated Particles"
	desc = "Small things moving very fast."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "particle"
	anchored = TRUE
	density = FALSE
	var/movement_range = 10
	var/energy = 10
	var/speed = 1

/obj/effect/accelerated_particle/weak
	movement_range = 8
	energy = 5

/obj/effect/accelerated_particle/strong
	movement_range = 15
	energy = 15

/obj/effect/accelerated_particle/powerful
	movement_range = 20
	energy = 50

/obj/effect/accelerated_particle/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_CROSS, PROC_REF(on_crossed_atom))
	RegisterSignal(src, COMSIG_MOVABLE_CROSS_OVER, PROC_REF(on_crossed_atom))
	radiate_wave()
	addtimer(CALLBACK(src, PROC_REF(move)), 1)

/obj/effect/accelerated_particle/Destroy()
	UnregisterSignal(src, list(COMSIG_MOVABLE_CROSS, COMSIG_MOVABLE_CROSS_OVER))
	return ..()

/obj/effect/accelerated_particle/Bump(atom/hit_atom)
	if(!hit_atom)
		return
	if(isliving(hit_atom))
		irradiate_mob(hit_atom)
	else if(istype(hit_atom, /obj/machinery/the_singularitygen))
		var/obj/machinery/the_singularitygen/generator = hit_atom
		generator.energy += energy
	else if(istype(hit_atom, /obj/singularity))
		var/obj/singularity/singularity = hit_atom
		singularity.energy += energy
	else if(istype(hit_atom, /obj/structure/blob))
		var/obj/structure/blob/blob = hit_atom
		blob.take_damage(energy * 0.6)
		movement_range = 0

/obj/effect/accelerated_particle/proc/on_crossed_atom(datum/source, atom/movable/crossed_atom)
	SIGNAL_HANDLER

	if(isliving(crossed_atom))
		irradiate_mob(crossed_atom)

/obj/effect/accelerated_particle/ex_act(severity, target)
	qdel(src)

/obj/effect/accelerated_particle/singularity_pull()
	return

/obj/effect/accelerated_particle/proc/irradiate_mob(mob/living/living_mob)
	SSradiation.irradiate(living_mob, min(energy * 2, RAD_CONTAMINATION_MAX_ACTIVITY), src)

/obj/effect/accelerated_particle/proc/radiate_wave()
	var/turf/source_turf = get_turf(src)
	if(isnull(source_turf))
		return

	radiation_pulse(
		source_turf,
		max_range = PA_PARTICLE_RADIATION_RANGE,
		threshold = PA_PARTICLE_RADIATION_THRESHOLD,
		chance = clamp(energy * PA_PARTICLE_RADIATION_CHANCE_PER_ENERGY, DEFAULT_RADIATION_CHANCE, PA_PARTICLE_RADIATION_MAX_CHANCE),
		surface_contamination_multiplier = PA_PARTICLE_RADIATION_CONTAMINATION_MULTIPLIER,
	)

/obj/effect/accelerated_particle/proc/move()
	if(!step(src, dir))
		var/turf/next_turf = get_step(src, dir)
		if(next_turf)
			forceMove(next_turf)
		else
			qdel(src)
			return
	movement_range--
	if(movement_range <= 0)
		qdel(src)
		return
	radiate_wave()
	addtimer(CALLBACK(src, PROC_REF(move)), speed)

#undef PA_PARTICLE_RADIATION_RANGE
#undef PA_PARTICLE_RADIATION_THRESHOLD
#undef PA_PARTICLE_RADIATION_CHANCE_PER_ENERGY
#undef PA_PARTICLE_RADIATION_MAX_CHANCE
#undef PA_PARTICLE_RADIATION_CONTAMINATION_MULTIPLIER
