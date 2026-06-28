/// Cargo-ready flatpacks for particle accelerator parts.
/obj/item/flatpacked_machine/particle_accelerator
	name = "flatpacked particle accelerator part"
	desc = "A compactly packed particle accelerator component. Use a multitool to deploy."
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "flatpack"
	density = TRUE
	w_class = WEIGHT_CLASS_HUGE
	throw_range = 2
	item_flags = SLOWS_WHILE_IN_HAND | IMMUTABLE_SLOW
	slowdown = 2.5
	drag_slowdown = 3.5
	type_to_deploy = /obj/structure/particle_accelerator
	deploy_time = 2 SECONDS

/obj/item/flatpacked_machine/particle_accelerator/Initialize(mapload)
	. = ..()
	var/atom/deployed_type = type_to_deploy
	name = "flatpack ([initial(deployed_type.name)])"
	desc = "A compactly packed [initial(deployed_type.name)]. [initial(deployed_type.desc)]"
	var/static/list/tool_behaviors = list(
		TOOL_MULTITOOL = list(
			SCREENTIP_CONTEXT_LMB = "Deploy",
		),
	)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)

/obj/item/flatpacked_machine/particle_accelerator/give_deployable_component()
	return

/obj/item/flatpacked_machine/particle_accelerator/give_manufacturer_examine()
	return

/obj/item/flatpacked_machine/particle_accelerator/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return
	if(loc == user)
		. += span_warning("You can't deploy while holding it in your hand.")
	else if(isturf(loc))
		var/turf/location = loc
		if(!isopenturf(location))
			. += span_warning("Can't deploy in this location.")
		else if(location.is_blocked_turf(source_atom = src))
			. += span_warning("No space for deployment.")

/obj/item/flatpacked_machine/particle_accelerator/multitool_act(mob/living/user, obj/item/tool)
	if(!isturf(loc))
		balloon_alert(user, "must deploy on the floor")
		return ITEM_INTERACT_BLOCKING

	var/turf/location = loc
	if(!isopenturf(location))
		balloon_alert(user, "can't deploy here")
		return ITEM_INTERACT_BLOCKING
	if(location.is_blocked_turf(source_atom = src))
		balloon_alert(user, "no space for deployment")
		return ITEM_INTERACT_BLOCKING

	balloon_alert_to_viewers("deploying!")
	if(!do_after(user, deploy_time, target = src))
		return ITEM_INTERACT_BLOCKING

	new /obj/effect/temp_visual/mook_dust(location)
	var/atom/movable/deployed_part = new type_to_deploy(location)
	deployed_part.setDir(dir)
	if(istype(deployed_part, /obj/structure/particle_accelerator))
		var/obj/structure/particle_accelerator/accelerator_part = deployed_part
		accelerator_part.construction_state = PA_CONSTRUCTION_UNSECURED
		accelerator_part.update_appearance()
	else if(istype(deployed_part, /obj/machinery/power/particle_accelerator/control_box))
		var/obj/machinery/power/particle_accelerator/control_box/control_box = deployed_part
		control_box.construction_state = PA_CONSTRUCTION_UNSECURED
		control_box.update_appearance()
	location.visible_message(span_warning("[src] deploys!"))
	playsound(src, 'sound/machines/terminal/terminal_eject.ogg', 70, TRUE)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/flatpacked_machine/particle_accelerator/control_box
	type_to_deploy = /obj/machinery/power/particle_accelerator/control_box

/obj/item/flatpacked_machine/particle_accelerator/end_cap
	type_to_deploy = /obj/structure/particle_accelerator/end_cap

/obj/item/flatpacked_machine/particle_accelerator/fuel_chamber
	type_to_deploy = /obj/structure/particle_accelerator/fuel_chamber

/obj/item/flatpacked_machine/particle_accelerator/power_box
	type_to_deploy = /obj/structure/particle_accelerator/power_box

/obj/item/flatpacked_machine/particle_accelerator/emitter_center
	type_to_deploy = /obj/structure/particle_accelerator/particle_emitter/center

/obj/item/flatpacked_machine/particle_accelerator/emitter_left
	type_to_deploy = /obj/structure/particle_accelerator/particle_emitter/left

/obj/item/flatpacked_machine/particle_accelerator/emitter_right
	type_to_deploy = /obj/structure/particle_accelerator/particle_emitter/right
