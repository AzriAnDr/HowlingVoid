/// Cargo-ready flatpacks for particle accelerator parts.
/obj/item/flatpacked_machine/particle_accelerator
	name = "flatpacked particle accelerator part"
	desc = "A compactly packed particle accelerator component."
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "flatpack"
	w_class = WEIGHT_CLASS_HUGE
	type_to_deploy = /obj/structure/particle_accelerator
	deploy_time = 2 SECONDS

/obj/item/flatpacked_machine/particle_accelerator/Initialize(mapload)
	. = ..()
	var/atom/deployed_type = type_to_deploy
	name = "flatpack ([initial(deployed_type.name)])"
	desc = "A compactly packed [initial(deployed_type.name)]. [initial(deployed_type.desc)]"

/obj/item/flatpacked_machine/particle_accelerator/give_manufacturer_examine()
	return

/obj/item/flatpacked_machine/particle_accelerator/control_box
	type_to_deploy = /obj/machinery/particle_accelerator/control_box

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
