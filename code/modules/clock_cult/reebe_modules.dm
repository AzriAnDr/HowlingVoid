GLOBAL_LIST_EMPTY(abscond_markers)

/proc/send_station_support_package(list/additional_items, sent_message = "We are sending a support package to the bridge to help deal with the threats to the station.")
	var/area/bridge_area = GLOB.areas_by_type[/area/station/command/bridge]
	if(!bridge_area)
		return
	var/turf/bridge_turf = pick(bridge_area.get_turfs_from_all_zlevels())
	if(!bridge_turf)
		return

	var/list/spawned_list = list(
		/obj/item/storage/medkit/advanced = 1,
		/obj/item/storage/medkit/brute = 1,
		/obj/item/storage/medkit/fire = 1,
		/obj/item/storage/medkit/regular = 1,
		/obj/item/gun/medbeam = 1,
		/obj/item/storage/part_replacer/cargo = 1,
		/obj/item/storage/box/recharger_parts = 1,
		/obj/item/storage/toolbox/mechanical = 3,
	)

	if(additional_items)
		spawned_list += additional_items
	fill_with_ones(spawned_list)
	var/obj/structure/closet/crate/spawned_crate = new
	for(var/atom/movable/spawned_object in spawned_list)
		if(!ispath(spawned_object))
			spawned_object.forceMove(spawned_crate)
			continue

		var/value = spawned_list[spawned_object]
		while(value > 0)
			value--
			new spawned_object(spawned_crate)
		spawned_list -= spawned_object

	priority_announce(sent_message, has_important_message = TRUE)
	podspawn(list("target" = bridge_turf, "style" = /datum/pod_style/centcom, "spawn" = spawned_crate, "bluespace" = FALSE, "stay_after_drop" = TRUE))

/obj/item/storage/box/recharger_parts
	name = "Recharger Parts"

/obj/item/storage/box/recharger_parts/PopulateContents()
	. = ..()
	var/list/spawned_list = list(/obj/item/circuitboard/machine/recharger = 5, /obj/item/stack/cable_coil = 1, /obj/item/stack/sheet/iron/fifty = 1)
	for(var/type in spawned_list)
		for(var/i in 1 to spawned_list[type])
			new type(src)

/obj/effect/landmark/abscond_marker
	name = "abscond marker"
	icon = 'icons/clock_cult/clockwork_effects.dmi'
	icon_state = "ratvarbeamglow"

/obj/effect/landmark/abscond_marker/Initialize(mapload)
	. = ..()
	GLOB.abscond_markers += src

/obj/effect/landmark/abscond_marker/Destroy()
	GLOB.abscond_markers -= src
	return ..()

/obj/effect/servant_blocker
	name = "servant blocker"
	icon = 'icons/clock_cult/clockwork_effects.dmi'
	icon_state = "servant_blocker"
	anchored = TRUE

/obj/effect/servant_blocker/CanPass(atom/movable/mover, border_dir)
	for(var/mob/held_mob in mover.get_all_contents())
		if(IS_CLOCK(held_mob))
			return FALSE
	return ..()

/obj/effect/spawner/structure/window/clockwork
	name = "brass window spawner"
	icon_state = "bronzewindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/clockwork/fulltile)
