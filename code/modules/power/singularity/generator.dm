/// Singularity generator which turns particle accelerator energy into an engine core.
/obj/machinery/the_singularitygen
	name = "Gravitational Singularity Generator"
	desc = "An odd device which produces a Gravitational Singularity when set up."
	icon = 'icons/obj/machines/engine/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = TRUE
	density = TRUE
	use_power = NO_POWER_USE
	max_integrity = 500
	var/energy = 0
	var/creation_energy = 50
	var/creation_threshold = 200
	var/creation_type = /obj/singularity

/obj/machinery/the_singularitygen/process(seconds_per_tick)
	if(energy >= creation_threshold)
		var/turf/our_turf = get_turf(src)
		message_admins("A singularity has been created at [ADMIN_VERBOSEJMP(our_turf)].")
		investigate_log("created a singularity at [AREACOORD(our_turf)].", INVESTIGATE_ENGINE)
		new creation_type(our_turf, creation_energy)
		qdel(src)
		return

	if(energy > 0)
		energy--

/obj/machinery/the_singularitygen/examine(mob/user)
	. = ..()
	. += span_notice("The charge meter reads [energy]/[creation_threshold].")
