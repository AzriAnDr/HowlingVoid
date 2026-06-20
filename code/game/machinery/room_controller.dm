GLOBAL_LIST_EMPTY(room_controller_by_area)

#define ROOM_OPEN 1
#define ROOM_GUESTS_ONLY 2
#define ROOM_CLOSED 3

#define ACTION_ADD "add"
#define ACTION_REMOVE "remove"
#define ACTION_CLEAR "clear"

/obj/machinery/room_controller
	name = "Hilbert's Hotel Room Controller"
	desc = "A mysterious device."
	icon = 'icons/obj/machines/room_controller.dmi'
	icon_state = "room_controller"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	use_power = NO_POWER_USE
	rad_insulation = RAD_FULL_INSULATION
	integrity_failure = 0
	max_integrity = INFINITY

	/// Displayed room number on the screen.
	var/room_number
	/// Room visibility in external lists.
	var/room_visibility = TRUE
	/// Room access mode.
	var/room_status = ROOM_OPEN
	/// Whether guest names are visible.
	var/room_privacy = TRUE
	/// Custom description shown by the UI.
	var/room_description = ""
	/// Custom room name shown by the UI.
	var/room_name
	/// FontAwesome icon key used by the TGUI panel.
	var/room_icon = "door-open"
	/// Current owner name shown in the UI.
	var/room_owner_name
	/// Current owner bound to a player identity rather than an ID card.
	var/room_owner_ckey
	/// Trusted guest names.
	var/list/trusted_guest_names = list()
	/// Trusted guest identities keyed by displayed character name.
	var/list/trusted_guest_ckeys_by_name = list()
	/// The area currently managed by this controller.
	var/area/managed_area
	/// Dorm airlocks controlled by this panel.
	var/list/linked_doors = list()
	/// Legacy list kept for compatibility with older cleanup code.
	var/list/protected_occupants = list()
	/// Throttle for privacy enforcement scans.
	var/next_privacy_sync = 0

	/// Flavor text appended on initialization.
	var/static/list/vanity_tags = list(
		", scribbled all around it",
		". There's a small bloody fingerprint on it",
		". The corner is torn off",
		". It's covered in a thick layer of dust",
		". The writing is smudged, as if someone was in a hurry. You squint your eyes..",
		". The writing is faded",
		". The writing is barely visible",
		". The corner is burnt",
	)
	/// Fake service months for the maintenance sticker.
	var/static/list/service_months = list("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12")
	/// Fake service days for the maintenance sticker.
	var/static/list/service_days = list("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31")

/obj/machinery/room_controller/Initialize(mapload)
	. = ..()
	managed_area = get_area(src)
	if(!room_number && istype(managed_area, /area/misc/condo))
		var/area/misc/condo/condo_area = managed_area
		if(condo_area.condo_number)
			room_number = condo_area.condo_number
	if(managed_area)
		GLOB.room_controller_by_area[managed_area] = src
	link_room_doors()
	START_PROCESSING(SSobj, src)
	desc += span_info("There is an old tag on the back of the device[pick(vanity_tags)]. Last Serviced: 1025-[pick(service_months)]-[pick(service_days)].")
	if(!room_name)
		room_name = room_number ? "Room [room_number]" : "Custom Room"

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/machines/room_controller_sound.ogg', 50), 3 SECONDS)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, say), "Welcome to Hilbert's Hotel."), 3 SECONDS)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, say), "Enjoy your stay!"), 5 SECONDS)
	update_appearance()

/obj/machinery/room_controller/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	clear_room_protection()
	unlink_room_doors()
	if(managed_area && GLOB.room_controller_by_area[managed_area] == src)
		GLOB.room_controller_by_area[managed_area] = null
	return ..()

/obj/machinery/room_controller/examine(mob/user)
	. = ..()
	. += span_info("The screen displays [!room_number ? "the word \"Error\". Nothing else." : "some small text and a large number [room_number]."]")

/obj/machinery/room_controller/update_overlays()
	. = ..()
	var/list/to_display = list()

	if(!room_number)
		var/mutable_appearance/error = mutable_appearance(icon, "n_err")
		error.pixel_x = 9
		error.pixel_y = -11
		. += error
	else
		var/room_text = "[room_number]"
		if(length(room_text) > 3)
			to_display = list(room_text[1], room_text[2], "dot")
		else
			for(var/i in 1 to min(length(room_text), 3))
				to_display += room_text[i]

		var/x_offset = 9
		for(var/digit in to_display)
			var/mutable_appearance/digit_overlay = mutable_appearance(icon, "n_[digit]")
			digit_overlay.pixel_x = x_offset
			digit_overlay.pixel_y = -11
			. += digit_overlay
			x_offset += 4

	. += emissive_appearance(icon, "screen_dim", src)

/obj/machinery/room_controller/proc/get_player_ckey(mob/user)
	if(!user)
		return null
	if(user.ckey)
		return ckey(user.ckey)
	if(user.key)
		return ckey(user.key)
	if(user.client?.ckey)
		return ckey(user.client.ckey)
	if(user.mind?.key)
		return ckey(user.mind.key)
	return null

/obj/machinery/room_controller/proc/is_owner(mob/user)
	if(!user)
		return FALSE
	var/user_ckey = get_player_ckey(user)
	if(room_owner_ckey && user_ckey == room_owner_ckey)
		return TRUE
	return !!(room_owner_name && user.real_name == room_owner_name)

/obj/machinery/room_controller/proc/is_trusted_guest(mob/user)
	if(!user || !length(trusted_guest_names))
		return FALSE
	if(user.real_name in trusted_guest_names)
		return TRUE

	var/user_ckey = get_player_ckey(user)
	if(!user_ckey)
		return FALSE

	for(var/guest_name in trusted_guest_ckeys_by_name)
		if(trusted_guest_ckeys_by_name[guest_name] == user_ckey)
			return TRUE

	return FALSE

/obj/machinery/room_controller/proc/can_bypass_room_restrictions(mob/user)
	return !!(user?.client?.holder || isAdminGhostAI(user) || HAS_SILICON_ACCESS(user))

/obj/machinery/room_controller/proc/can_enter_room(mob/user)
	if(!room_owner_name)
		return TRUE
	if(can_bypass_room_restrictions(user) || is_owner(user))
		return TRUE

	switch(room_status)
		if(ROOM_OPEN)
			return TRUE
		if(ROOM_GUESTS_ONLY)
			return is_trusted_guest(user)
		if(ROOM_CLOSED)
			return FALSE

	return FALSE

/obj/machinery/room_controller/proc/should_block_ghosts()
	return !!(room_owner_name && room_status != ROOM_OPEN)

/obj/machinery/room_controller/proc/can_manage_room(mob/user)
	return is_owner(user)

/obj/machinery/room_controller/proc/can_ghost_observe_room(mob/user)
	if(!room_owner_name)
		return TRUE
	if(can_bypass_room_restrictions(user))
		return TRUE
	if(is_owner(user) || is_trusted_guest(user))
		return TRUE
	return FALSE

/obj/machinery/room_controller/proc/assign_owner(mob/user, forced_name, forced_ckey)
	if(!user?.mind)
		return FALSE

	room_owner_name = forced_name || user.real_name || room_owner_name
	room_owner_ckey = forced_ckey || get_player_ckey(user)
	if(room_owner_name)
		trusted_guest_names -= room_owner_name
		trusted_guest_ckeys_by_name -= room_owner_name
	return TRUE

/obj/machinery/room_controller/proc/resolve_player_ckey(target_name)
	if(!target_name)
		return null

	for(var/mob/player as anything in GLOB.player_list)
		if(!player?.mind || player.real_name != target_name)
			continue
		return get_player_ckey(player)

	return null

/obj/machinery/room_controller/interact(mob/user)
	. = ..()
	ui_interact(user)

/obj/machinery/room_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HilbertsHotelRoomControl")
		ui.open()

/obj/machinery/room_controller/ui_data(mob/user)
	var/list/data = list()

	data["room_number"] = room_number
	data["user_name"] = user?.real_name
	data["can_manage"] = can_manage_room(user)
	data["room_preferences"] = list(
		"status" = room_status,
		"visibility" = room_visibility,
		"privacy" = room_privacy,
		"description" = room_description,
		"name" = room_name,
		"icon" = room_icon,
	)
	data["access_restrictions"] = list(
		"room_owner" = room_owner_name || "Unassigned",
		"trusted_guests" = trusted_guest_names.Copy(),
	)
	data["present_players"] = get_present_player_names()
	return data

/obj/machinery/room_controller/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("modify_trusted_guests")
			if(params["action"] == ACTION_ADD)
				modify_trusted_guests(usr, params["action"], params["user"])
				SStgui.update_uis(src)
				return TRUE

	if(!can_manage_room(usr))
		playsound(src, 'sound/machines/terminal/terminal_error.ogg', 50, TRUE)
		say("Access denied.")
		return FALSE

	switch(action)
		if("toggle_visibility")
			room_visibility = !room_visibility
			. = TRUE
		if("toggle_status")
			switch(room_status)
				if(ROOM_OPEN)
					room_status = ROOM_GUESTS_ONLY
				if(ROOM_GUESTS_ONLY)
					room_status = ROOM_CLOSED
				if(ROOM_CLOSED)
					room_status = ROOM_OPEN
			. = TRUE
		if("toggle_privacy")
			room_privacy = !room_privacy
			. = TRUE
		if("update_description")
			room_description = copytext_char(trim(params["description"] || ""), 1, 221)
			. = TRUE
		if("update_name")
			var/new_name = trim(params["name"] || "")
			room_name = copytext_char(new_name || "Room [room_number || "?"]", 1, 21)
			. = TRUE
		if("set_icon")
			room_icon = params["icon"] || room_icon
			. = TRUE
		if("modify_trusted_guests")
			modify_trusted_guests(usr, params["action"], params["user"])
			. = TRUE
		if("transfer_ownership")
			transfer_ownership(usr, params["target_name"])
			. = TRUE

	if(.)
		refresh_condo_directory()
		SStgui.update_uis(src)

/obj/machinery/room_controller/proc/refresh_condo_directory()
	if(!istype(managed_area, /area/misc/condo))
		return
	var/area/misc/condo/condo_area = managed_area
	if(condo_area.parent_object)
		SStgui.update_uis(condo_area.parent_object)

/obj/machinery/room_controller/process(seconds_per_tick)
	if(world.time < next_privacy_sync)
		return
	next_privacy_sync = world.time + 2 SECONDS
	sync_room_privacy()

/obj/machinery/room_controller/proc/apply_dynamic_room_number(new_room_number)
	if(room_number == new_room_number || isnull(new_room_number) || new_room_number == 0)
		return
	room_number = new_room_number
	if(!room_name || room_name == "Custom Room" || findtext(room_name, "Room "))
		room_name = "Room [room_number]"
	update_appearance()
	SStgui.update_uis(src)

/obj/machinery/room_controller/proc/sync_room_privacy()
	if(!managed_area)
		return
	if(!should_block_ghosts())
		return

	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
		eject_ghost(ghost)

/obj/machinery/room_controller/proc/clear_room_protection()
	protected_occupants.Cut()

/obj/machinery/room_controller/proc/get_present_player_names()
	var/list/present_players = list()
	if(!managed_area)
		return present_players

	for(var/turf/room_turf as anything in get_area_turfs(managed_area, z))
		for(var/mob/living/player in room_turf)
			if(!player?.mind || !player.client || !player.real_name)
				continue
			present_players |= player.real_name

	return sort_list(present_players)

/obj/machinery/room_controller/proc/get_ghost_redirect_turf()
	var/list/observer_starts = list()
	for(var/obj/effect/landmark/observer_start/start as anything in GLOB.landmarks_list)
		var/turf/start_turf = get_turf(start)
		if(start_turf)
			observer_starts += start_turf

	if(length(observer_starts))
		return pick(observer_starts)

	if(!managed_area)
		return get_turf(src)

	for(var/turf/room_turf as anything in get_area_turfs(managed_area, z))
		for(var/direction in GLOB.cardinals)
			var/turf/neighbor = get_step(room_turf, direction)
			if(!neighbor || neighbor.density || get_area(neighbor) == managed_area)
				continue
			return neighbor

	return get_turf(src)

/obj/machinery/room_controller/proc/notify_room_kick(mob/dead/observer/ghost)
	if(!ghost)
		return

	var/message = span_warning("Кикнут куколд: [ghost.name]")
	for(var/mob/player as anything in GLOB.player_list)
		if(!player?.client)
			continue
		if(!(is_owner(player) || is_trusted_guest(player)))
			continue
		to_chat(player, message)

/obj/machinery/room_controller/proc/get_ghost_kick_message()
	if(prob(5))
		return "Лежит куколд с женой на пляже. К ним подходит качок и говорит\n- Эй, куколд, я твою жену сейчас уведу и выебу.\nКуколд ему отвечает\n- Это мы ещё посмотрим..."
	return "Не сегодня, куколд!"

/proc/get_room_controller_for_atom(atom/target)
	if(!target)
		return null
	var/area/target_area = get_area(target)
	if(!target_area)
		return null
	return GLOB.room_controller_by_area[target_area]

/mob/dead/observer/proc/can_view_room_atom(atom/target, silent = FALSE)
	var/obj/machinery/room_controller/controller = get_room_controller_for_atom(target)
	if(!controller || !controller.should_block_ghosts() || controller.can_ghost_observe_room(src))
		return TRUE

	if(!silent)
		to_chat(src, span_notice("That room is private."))
	return FALSE

/obj/machinery/room_controller/proc/eject_ghost(mob/dead/observer/ghost)
	if(!ghost || ghost.client?.holder || !should_block_ghosts() || get_area(ghost) != managed_area || can_ghost_observe_room(ghost))
		return FALSE

	var/turf/redirect_turf = get_ghost_redirect_turf()
	if(!redirect_turf)
		return FALSE

	if(ghost.observetarget && get_area(ghost.observetarget) == managed_area)
		ghost.reset_perspective(null)
	if(ghost.orbit_target && get_area(ghost.orbit_target) == managed_area)
		ghost.orbiting?.end_orbit(ghost)
	ghost.abstract_move(redirect_turf)
	to_chat(ghost, span_notice("[get_ghost_kick_message()]"))
	notify_room_kick(ghost)
	return TRUE

/obj/machinery/room_controller/proc/link_room_doors()
	unlink_room_doors()
	if(!managed_area)
		return

	for(var/turf/room_turf as anything in get_area_turfs(managed_area, z))
		for(var/obj/machinery/door/airlock/door in room_turf)
			if(door.linked_room_controller && door.linked_room_controller != src)
				continue
			door.linked_room_controller = src
			linked_doors |= door

	if(length(linked_doors))
		return

	for(var/turf/room_turf as anything in get_area_turfs(managed_area, z))
		for(var/direction in GLOB.cardinals)
			var/turf/neighbor = get_step(room_turf, direction)
			if(!neighbor)
				continue
			for(var/obj/machinery/door/airlock/door in neighbor)
				if(door.linked_room_controller && door.linked_room_controller != src)
					continue
				door.linked_room_controller = src
				linked_doors |= door

/obj/machinery/room_controller/proc/unlink_room_doors()
	for(var/obj/machinery/door/airlock/door as anything in linked_doors)
		if(door?.linked_room_controller == src)
			door.linked_room_controller = null
	linked_doors.Cut()

/obj/machinery/room_controller/emp_act(severity)
	. = ..()

/obj/machinery/room_controller/proc/transfer_ownership(mob/user, target_name)
	if(!target_name)
		playsound(src, 'sound/machines/terminal/terminal_error.ogg', 50, TRUE)
		say("Select a resident from the room first.")
		return FALSE

	var/list/present_players = get_present_player_names()
	if(!(target_name in present_players))
		playsound(src, 'sound/machines/terminal/terminal_error.ogg', 50, TRUE)
		say("That resident is no longer in the room.")
		return FALSE

	assign_owner(user, target_name, resolve_player_ckey(target_name))
	playsound(src, 'sound/machines/terminal/terminal_processing.ogg', 50, TRUE)
	say("Room ownership transferred.")
	return TRUE

/obj/machinery/room_controller/proc/modify_trusted_guests(mob/user, action, target_name)
	switch(action)
		if(ACTION_ADD)
			if(!user?.mind)
				return FALSE
			if(!user.real_name || user.real_name == room_owner_name || (user.real_name in trusted_guest_names))
				return FALSE
			trusted_guest_names += user.real_name
			var/user_ckey = get_player_ckey(user)
			if(user_ckey)
				trusted_guest_ckeys_by_name[user.real_name] = user_ckey
		if(ACTION_REMOVE)
			if(target_name in trusted_guest_names)
				trusted_guest_names -= target_name
				trusted_guest_ckeys_by_name -= target_name
		if(ACTION_CLEAR)
			trusted_guest_names.Cut()
			trusted_guest_ckeys_by_name.Cut()
		else
			return FALSE

	playsound(src, 'sound/machines/terminal/terminal_processing.ogg', 50, TRUE)
	return TRUE

/obj/machinery/door/airlock
	var/obj/machinery/room_controller/linked_room_controller

/mob/dead/observer/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(client?.holder)
		return
	var/obj/machinery/room_controller/controller = GLOB.room_controller_by_area[get_area(src)]
	controller?.eject_ghost(src)

/obj/machinery/room_controller/directional/north
	pixel_x = 0
	pixel_y = 28
	dir = NORTH

/obj/machinery/room_controller/directional/south
	pixel_x = 0
	pixel_y = -28
	dir = SOUTH

/obj/machinery/room_controller/directional/east
	pixel_x = 28
	pixel_y = 0
	dir = EAST

/obj/machinery/room_controller/directional/west
	pixel_x = -28
	pixel_y = 0
	dir = WEST

#undef ROOM_OPEN
#undef ROOM_GUESTS_ONLY
#undef ROOM_CLOSED

#undef ACTION_ADD
#undef ACTION_REMOVE
#undef ACTION_CLEAR
