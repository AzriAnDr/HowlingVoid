/// Essentially a rewritten version of Hilbert's Hotel that supports multiple map templates; and a reference to GMTower's beautiful condo system. You should play it's successor... :3
/obj/machinery/cafe_condo_teleporter
	name = "Matrixed Teleportation Unit"
	desc = "A sub-divided; stable teleportation system with a unseen central processing hub."
	icon = /obj/machinery/teleport/hub::icon
	icon_state = /obj/machinery/teleport/hub::icon_state
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/cafe_condo_teleporter/examine(mob/user)
	. = ..()
	. += span_notice("You can use this to retire to a private room.")
	. += span_warning("Beware: once all occupants exit a room; it resets.")

/obj/machinery/cafe_condo_teleporter/attack_robot(mob/user)
	if(user.Adjacent(src))
		ui_interact(user)
	return TRUE

/obj/machinery/cafe_condo_teleporter/attack_hand(mob/living/user, list/modifiers)
	ui_interact(user)
	return TRUE

/obj/machinery/cafe_condo_teleporter/attack_tk(mob/user)
	to_chat(user, span_notice("\The [src] actively rejects your mind as the bluespace energies surrounding it disrupt your telekinesis."))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/cafe_condo_teleporter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MatrixedTeleportationUnit")
		ui.open()

/obj/machinery/cafe_condo_teleporter/ui_data(mob/user)
	var/list/data = list()

	data["max_room_number"] = SHORT_REAL_LIMIT
	data["categories"] = get_condo_categories()
	data["templates"] = get_condo_template_data()
	data["open_rooms"] = get_public_room_list(only_open = TRUE)
	data["reserved_rooms"] = get_public_room_list(only_open = FALSE)
	return data

/obj/machinery/cafe_condo_teleporter/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("check_in")
			var/requested_condo = text2num(params["room_number"])
			if(!requested_condo)
				return TRUE
			check_in(usr, requested_condo, params["template_name"])
			return TRUE
		if("refresh")
			SStgui.update_uis(src)
			return TRUE

	return FALSE

/obj/machinery/cafe_condo_teleporter/proc/check_in(mob/user, requested_condo, template_name)
	if(!requested_condo)
		return
	if(requested_condo > SHORT_REAL_LIMIT)
		to_chat(user, span_warning("This network is only hooked up to [SHORT_REAL_LIMIT] rooms!"))
		return
	if((requested_condo < 1) || (requested_condo != round(requested_condo)))
		to_chat(user, span_warning("That is not a valid room number!"))
		return
	if(!check_target_eligibility(user))
		return

	if(SScondos.active_condos["[requested_condo]"])
		SScondos.enter_active_room(requested_condo, user)
		return

	var/datum/map_template/condo/chosen_condo = SScondos.condo_templates[template_name]
	if(!chosen_condo)
		to_chat(user, span_warning("Choose a condo archetype first."))
		return
	if(!check_target_eligibility(user))
		return
	if(SScondos.active_condos["[requested_condo]"])
		to_chat(user, span_warning("The room number you requested became occupied while you were selecting! Sending you to the occupied condo..."))
		SScondos.enter_active_room(requested_condo, user)
		return

	SScondos.create_and_enter_condo(requested_condo, chosen_condo, user, src)

/obj/machinery/cafe_condo_teleporter/proc/get_condo_categories()
	var/list/categories = list()

	for(var/template_name in SScondos.condo_templates)
		var/datum/map_template/condo/template = SScondos.condo_templates[template_name]
		categories |= (template.category || "Condo")

	return sort_list(categories)

/obj/machinery/cafe_condo_teleporter/proc/get_condo_template_data()
	var/list/templates = list()
	var/list/template_names = sort_list(assoc_to_keys(SScondos.condo_templates))

	for(var/template_name in template_names)
		var/datum/map_template/condo/template = SScondos.condo_templates[template_name]
		templates += list(list(
			"name" = template.name,
			"title" = template.get_public_name(),
			"category" = template.category || "Condo",
		))

	return templates

/obj/machinery/cafe_condo_teleporter/proc/get_public_room_list(only_open)
	var/list/room_list = list()
	var/list/sorted_room_numbers = list()

	for(var/condo_number in SScondos.active_condos)
		sorted_room_numbers += text2num(condo_number)

	sorted_room_numbers = sort_list(sorted_room_numbers, GLOBAL_PROC_REF(cmp_numeric_asc))

	for(var/room_number in sorted_room_numbers)
		var/datum/turf_reservation/condo/reservation = SScondos.active_condos["[room_number]"]
		var/list/listing = build_public_room_listing(room_number, reservation)
		if(!listing)
			continue

		var/is_open = !!listing["is_open"]
		if(only_open && !is_open)
			continue
		if(!only_open && is_open)
			continue

		room_list += list(listing)

	return room_list

/obj/machinery/cafe_condo_teleporter/proc/build_public_room_listing(room_number, datum/turf_reservation/condo/reservation)
	if(!reservation)
		return null

	var/turf/condo_bottom_left = reservation.bottom_left_turfs[1]
	if(!condo_bottom_left)
		return null

	var/area/current_area = get_area(condo_bottom_left)
	var/obj/machinery/room_controller/controller = current_area ? GLOB.room_controller_by_area[current_area] : null
	if(controller && !controller.room_visibility)
		return null

	var/template_name = reservation.condo_template?.get_public_name() || "Condo"
	var/room_name = controller?.room_name || "Room [room_number]"
	var/room_icon = controller?.room_icon || "door-open"
	// Keep this check local so the teleporter does not depend on macro order from room_controller.dm.
	var/is_open = !controller || controller.room_status == 1

	var/list/visible_names = list()
	if(controller?.room_privacy)
		visible_names = controller.get_present_player_names()
		if(!length(visible_names) && controller.room_owner_name)
			visible_names += controller.room_owner_name

	return list(
		"room_number" = room_number,
		"room_name" = room_name,
		"template_name" = template_name,
		"icon" = room_icon,
		"is_open" = is_open,
		"guest_names" = visible_names,
	)

/// Sanitycheck to prevent exploitation
/obj/machinery/cafe_condo_teleporter/proc/check_target_eligibility(mob/to_be_checked)
	if(!src.Adjacent(to_be_checked))
		to_chat(to_be_checked, span_warning("You too far away from \the [src] to enter it!"))
		return FALSE
	if(to_be_checked.incapacitated)
		to_chat(to_be_checked, span_warning("You aren't able to activate \the [src] anymore!"))
		return FALSE
	return TRUE
