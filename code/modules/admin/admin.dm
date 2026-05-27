////////////////////////////////
/proc/message_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span></span>"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINLOG,
		html = msg,
		confidential = TRUE)

/proc/relay_msg_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">RELAY:</span> <span class=\"message\">[msg]</span></span>"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINLOG,
		html = msg,
		confidential = TRUE)

///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/Game()
	if(!check_rights(0))
		return

	var/datum/admin_game_panel/interface = new(src)
	interface.ui_interact(usr)
	return

/datum/admin_game_panel
	var/datum/admins/holder

/datum/admin_game_panel/New(datum/admins/holder)
	src.holder = holder
	return ..()

/datum/admin_game_panel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/admin_game_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GamePanel")
		ui.open()

/datum/admin_game_panel/ui_data(mob/user)
	var/list/data = list()
	var/can_spawn = FALSE
	var/has_marked_atom = FALSE
	if(holder)
		if(holder.check_for_rights(R_SPAWN))
			can_spawn = TRUE
		var/datum/marked = holder.marked_datum
		if(istype(marked, /atom))
			has_marked_atom = TRUE
	data["canSpawn"] = can_spawn
	data["hasMarkedAtom"] = has_marked_atom
	return data

/datum/admin_game_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!holder)
		return

	switch(action)
		if("spawn_panel")
			if(!check_rights(R_SPAWN))
				return
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/spawn_panel)
		if("create_reagent")
			if(!check_rights(R_SPAWN))
				return
			holder.create_reagent(usr)
		if("duplicate_marked")
			if(!check_rights(R_SPAWN))
				return
			var/atom/marked_atom = holder.marked_datum
			if(!istype(marked_atom))
				return
			var/turf/location = get_turf(usr)
			if(!location)
				return
			duplicate_object(marked_atom, location)

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

ADMIN_VERB(spawn_atom, R_SPAWN, "Spawn", "Spawn an atom.", ADMIN_CATEGORY_DEBUG, object as text|null)
	var/static/list/atom_types
	if (isnull(atom_types))
		atom_types = subtypesof(/atom)

	var/chosen_path = null
	var/list/preparsed = null
	if (object)
		preparsed = splittext(object, ":")
		var/list/matches = filter_fancy_list(atom_types, preparsed[1])
		if (length(matches) == 1)
			chosen_path = matches[1]

	if(!chosen_path)
		var/datum/spawn_menu/menu = user.holder.spawn_menu
		if (!menu)
			menu = new()
			user.holder.spawn_menu = menu
		menu.init_value = object
		menu.ui_interact(user.mob)
		BLACKBOX_LOG_ADMIN_VERB("Spawn Atom")
		return TRUE

	var/amount = 1
	if (length(preparsed) > 1)
		amount = clamp(text2num(preparsed[2]), 1, ADMIN_SPAWN_CAP)

	var/turf/target_turf = get_turf(user.mob)
	if (ispath(chosen_path, /turf))
		target_turf.ChangeTurf(chosen_path)
	else
		for (var/i in 1 to amount)
			var/atom/spawned = new chosen_path(target_turf)
			spawned.flags_1 |= ADMIN_SPAWNED_1

	log_admin("[key_name(user.mob)] spawned [amount] x [chosen_path] at [AREACOORD(user.mob)]")
	BLACKBOX_LOG_ADMIN_VERB("Spawn Atom")
	return TRUE

ADMIN_VERB(spawn_atom_pod, R_SPAWN, "PodSpawn", "Spawn an atom via supply drop.", ADMIN_CATEGORY_DEBUG, object as text)
	var/chosen = pick_closest_path(object)
	if(!chosen)
		return
	var/turf/target_turf = get_turf(user.mob)

	if(ispath(chosen, /turf))
		target_turf.ChangeTurf(chosen)
	else
		var/obj/structure/closet/supplypod/pod = podspawn(list(
			"target" = target_turf,
			"path" = /obj/structure/closet/supplypod/centcompod,
		))
		//we need to set the admin spawn flag for the spawned items so we do it outside of the podspawn proc
		var/atom/A = new chosen(pod)
		A.flags_1 |= ADMIN_SPAWNED_1

	log_admin("[key_name(user)] pod-spawned [chosen] at [AREACOORD(user.mob)]")
	BLACKBOX_LOG_ADMIN_VERB("Podspawn Atom")

ADMIN_VERB(spawn_cargo, R_SPAWN, "Spawn Cargo", "Spawn a cargo crate.", ADMIN_CATEGORY_DEBUG, object as text)
	var/chosen = pick_closest_path(object, make_types_fancy(subtypesof(/datum/supply_pack)))
	if(!chosen)
		return
	var/datum/supply_pack/S = new chosen
	S.order_flags |= ORDER_ADMIN_SPAWNED
	S.generate(get_turf(user.mob))

	log_admin("[key_name(user)] spawned cargo pack [chosen] at [AREACOORD(user.mob)]")
	BLACKBOX_LOG_ADMIN_VERB("Spawn Cargo")

ADMIN_VERB(create_or_modify_area, R_DEBUG, "Create Or Modify Area", "Create of modify an area. wow.", ADMIN_CATEGORY_DEBUG)
	create_area(user.mob)

//Kicks all the clients currently in the lobby. The second parameter (kick_only_afk) determins if an is_afk() check is ran, or if all clients are kicked
//defaults to kicking everyone (afk + non afk clients in the lobby)
//returns a list of ckeys of the kicked clients
/proc/kick_clients_in_lobby(message, kick_only_afk = 0)
	var/list/kicked_client_names = list()
	for(var/client/C in GLOB.clients)
		if(isnewplayer(C.mob))
			if(kick_only_afk && !C.is_afk()) //Ignore clients who are not afk
				continue
			if(message)
				to_chat(C, message, confidential = TRUE)
			kicked_client_names.Add("[C.key]")
			qdel(C)
	return kicked_client_names

//returns TRUE to let the dragdrop code know we are trapping this event
//returns FALSE if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(mob/dead/observer/frommob, mob/tomob)

	//this is the exact two check rights checks required to edit a ckey with vv.
	if (!check_rights(R_VAREDIT,0) || !check_rights(R_SPAWN|R_DEBUG,0))
		return FALSE

	if (!frommob.ckey)
		return FALSE

	var/question = ""
	if (tomob.ckey)
		question = "This mob already has a user ([tomob.key]) in control of it! "
	question += "Are you sure you want to place [frommob.name]([frommob.key]) in control of [tomob.name]?"

	var/ask = tgui_alert(usr, question, "Place ghost in control of mob?", list("Yes", "No"))
	if (ask != "Yes")
		return TRUE

	if (!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
		return TRUE

	// Disassociates observer mind from the body mind
	if(tomob.client)
		tomob.ghostize(FALSE)
	else
		for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
			if(tomob.mind == ghost.mind)
				ghost.mind = null

	message_admins(span_adminnotice("[key_name_admin(usr)] has put [frommob.key] in control of [tomob.name]."))
	log_admin("[key_name(usr)] stuffed [frommob.key] into [tomob.name].")
	BLACKBOX_LOG_ADMIN_VERB("Ghost Drag Control")

	tomob.PossessByPlayer(frommob.key)
	tomob.client?.init_verbs()
	qdel(frommob)

	return TRUE

/// Sends a message to adminchat when anyone with a holder logs in or logs out.
/// Is dependent on admin preferences and configuration settings, which means that this proc can fire without sending a message.
/client/proc/adminGreet(logout = FALSE)
	if(!SSticker.HasRoundStarted())
		return

	if(logout && CONFIG_GET(flag/announce_admin_logout))
		message_admins("Admin logout: [key_name(src)]")
		return

	if(!logout && CONFIG_GET(flag/announce_admin_login) && (prefs.toggles & ANNOUNCE_LOGIN))
		message_admins("Admin login: [key_name(src)]")
		return


// BEGIN NOVA CORE MIGRATION: code/modules/admin/admin.dm
GLOBAL_VAR_INIT(dchat_allowed, TRUE)

ADMIN_VERB(toggledchat, R_ADMIN, "Toggle Dead Chat", "Toggle dis bitch.", ADMIN_CATEGORY_SERVER)
	toggle_dchat()
	log_admin("[key_name(usr)] toggled dead chat.")
	message_admins("[key_name_admin(usr)] toggled dead chat.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle DCHAT", "[GLOB.dchat_allowed ? "Enabled" : "Disabled"]")) // If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/toggle_dchat(toggle = null)
	if(toggle != null) // if we're specifically en/disabling dead chat
		if(toggle != GLOB.dchat_allowed)
			GLOB.dchat_allowed = toggle
		else
			return
	else // otherwise just toggle it
		GLOB.dchat_allowed = !GLOB.dchat_allowed
	to_chat(world, span_oocplain("<B>The dead chat channel has been globally [GLOB.dchat_allowed ? "enabled" : "disabled"].</B>"))

/datum/admin_help
	/// Have we requested this ticket to stop being part of the Ticket Ping subsystem?
	var/ticket_ping_stop = FALSE
	/// Are we added to the ticket ping subsystem in the first place
	var/ticket_ping = FALSE
	/// Who is handling this admin help?
	var/handler
	/// All sanitized text
	var/full_text

//Let the initiator know their ahelp is being handled
/datum/admin_help/proc/handle_issue(key_name = key_name_admin(usr))
	if(state != AHELP_ACTIVE)
		return FALSE

	if(handler && handler == usr.ckey) // No need to handle it twice as the same person ;)
		return TRUE

	if(handler && handler != usr.ckey)
		var/response = tgui_alert(usr, "This ticket is already being handled by [handler]. Do you want to continue?", "Ticket already assigned", list("Yes", "No"))
		if(!response || response == "No")
			return FALSE

	var/msg = span_adminhelp("Your ticket is now being handled by [usr?.client?.holder?.fakekey ? usr?.client?.holder?.fakekey : "an administrator"]! Please wait while they type their response and/or gather relevant information.")

	if(initiator)
		to_chat(initiator, msg)

	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "handling")
	msg = "Ticket [TicketHref("#[id]")] is being handled by [key_name]"
	message_admins(msg)
	log_admin_private(msg)
	AddInteraction("Being handled by [key_name]", "Being handled by [key_name_admin(usr, FALSE)]")

	handler = "[usr.ckey]"
	return TRUE

///Proc which converts an admin_help ticket to a mentorhelp
/datum/admin_help/proc/convert_to_mentorhelp(key_name = key_name_admin(usr))
	if(state != AHELP_ACTIVE)
		return FALSE

	if(handler && handler != usr.ckey)
		var/response = tgui_alert(usr, "This ticket is already being handled by [handler]. Do you want to continue?", "Ticket already assigned", list("Yes", "No"))
		if(!response || response == "No")
			return FALSE

	add_verb(initiator, /client/verb/mentorhelp) // Way to override mentorhelp cooldown.

	to_chat(initiator, span_adminhelp("Your ticket was converted to Mentorhelp"))
	initiator.mentorhelp(full_text)
	initiator.giveadminhelpverb()

	message_admins("[key_name] converted Ticket #[id] from [initiator_key_name] into Mentorhelp")
	log_admin("[usr.client] converted Ticket #[id] from [initiator_ckey] into Mentorhelp")

	Close(key_name, TRUE)
// END NOVA CORE MIGRATION: code/modules/admin/admin.dm
