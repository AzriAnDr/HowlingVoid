/// Tesla generator which turns explosive tesla arcs into an energy ball.
/obj/machinery/the_singularitygen/tesla
	name = "Tesla Energy Ball Generator"
	desc = "An odd device which produces a Tesla Energy Ball when powered by a strong electrical arc."
	icon = 'icons/obj/machines/engine/tesla_generator.dmi'
	icon_state = "TheSingGen"
	creation_type = /obj/energy_ball

/obj/machinery/the_singularitygen/tesla/zap_act(power, zap_flags)
	if(zap_flags & ZAP_MACHINE_EXPLOSIVE)
		energy += power / (1 MEGA JOULES)
	return ..()
