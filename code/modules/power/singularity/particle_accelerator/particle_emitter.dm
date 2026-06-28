/obj/structure/particle_accelerator/particle_emitter
	name = "EM Containment Grid"
	desc = "This launches alpha particles. Standing near the output end is not recommended."
	icon_state = "none"
	var/fire_delay = 50
	var/last_shot = 0

/obj/structure/particle_accelerator/particle_emitter/center
	icon_state = "emitter_center"
	reference = "emitter_center"

/obj/structure/particle_accelerator/particle_emitter/left
	icon_state = "emitter_left"
	reference = "emitter_left"

/obj/structure/particle_accelerator/particle_emitter/right
	icon_state = "emitter_right"
	reference = "emitter_right"

/obj/structure/particle_accelerator/particle_emitter/proc/set_delay(delay)
	if(delay < 0)
		return FALSE
	fire_delay = delay
	return TRUE

/obj/structure/particle_accelerator/particle_emitter/proc/can_emit_particle()
	return (last_shot + fire_delay) <= world.time

/obj/structure/particle_accelerator/particle_emitter/proc/emit_particle(strength = 0)
	if(!can_emit_particle())
		return FALSE
	last_shot = world.time
	var/turf/our_turf = get_turf(src)
	var/obj/effect/accelerated_particle/particle
	switch(strength)
		if(0)
			particle = new /obj/effect/accelerated_particle/weak(our_turf)
		if(1)
			particle = new /obj/effect/accelerated_particle(our_turf)
		if(2)
			particle = new /obj/effect/accelerated_particle/strong(our_turf)
		if(3)
			particle = new /obj/effect/accelerated_particle/powerful(our_turf)
	particle.setDir(dir)
	return TRUE
