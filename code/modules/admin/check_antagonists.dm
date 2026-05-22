// Antagonist admin panel helpers and listing utilities

/// Fallback nuclear code cache so admins always see a code for the current round.
var/global/admin_panel_fallback_nuke_code
var/global/admin_panel_fallback_nuke_code_round_id

/proc/admin_panel_get_fallback_nuke_code()
	if(admin_panel_fallback_nuke_code_round_id != GLOB.round_id || !admin_panel_fallback_nuke_code)
		admin_panel_fallback_nuke_code_round_id = GLOB.round_id
		admin_panel_fallback_nuke_code = random_nukecode()
	return admin_panel_fallback_nuke_code

// Name shown on antag list.
/datum/antagonist/proc/antag_listing_name()
	if(!owner)
		return "Unassigned"
	if(owner.current)
		return "<a href='byond://?_src_=holder;[HrefToken()];adminplayeropts=[REF(owner.current)]'>[owner.current.real_name]</a> "
	return "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(owner)]'>[owner.name]</a> "

// Whatever interesting things happened to the antag admins should know about.
// Include additional information about antag in this part.
/datum/antagonist/proc/antag_listing_status()
	if(!owner)
		return "(Unassigned)"
	if(!owner.current)
		return "<font color=red>(Body destroyed)</font>"
	if(owner.current.stat == DEAD)
		return "<font color=red>(DEAD)</font>"
	if(!owner.current.client)
		return "(No client)"

/// Status text without HTML for TGUI.
/datum/antagonist/proc/antag_listing_status_text()
	if(!owner)
		return "Unassigned"
	if(!owner.current)
		return "Body destroyed"
	if(owner.current.stat == DEAD)
		return "Dead"
	if(!owner.current.client)
		return "No client"
	return "Alive"

// Builds the common FLW PM TP commands part.
// Probably not going to be overwritten by anything but you never know.
/datum/antagonist/proc/antag_listing_commands()
	if(!owner)
		return
	var/list/parts = list()
	parts += "<a href='byond://?priv_msg=[ckey(owner.key)]'>PM</a>"
	if(owner.current)
		parts += "<a href='byond://?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(owner.current)]'>FLW</a>"
	else
		parts += ""
	parts += "<a href='byond://?_src_=holder;[HrefToken()];traitor=[REF(owner)]'>Show Objective</a>"
	return parts

// Builds table row for the antag.
// Jim (Status) FLW PM TP
/datum/antagonist/proc/antag_listing_entry()
	var/list/parts = list()
	if(show_name_in_check_antagonists)
		parts += "[antag_listing_name()]([name])"
	else
		parts += antag_listing_name()
	parts += antag_listing_status()
	parts += antag_listing_commands()
	return "<tr><td>[parts.Join("</td><td>")]</td></tr>"

/// Builds a data entry for the TGUI antagonist list.
/datum/antagonist/proc/antag_listing_entry_data()
	var/list/entry = list()
	var/antag_display = owner?.current ? owner.current.real_name : owner?.name
	if(show_name_in_check_antagonists)
		antag_display = "[antag_display] ([name])"
	entry["display"] = antag_display || "Unknown"
	entry["role"] = name
	entry["status"] = antag_listing_status_text()
	entry["rawStatus"] = antag_listing_status()
	entry["ckey"] = owner?.key
	entry["mobRef"] = owner?.current ? REF(owner.current) : null
	entry["mindRef"] = owner ? REF(owner) : null
	entry["canFollow"] = !!owner?.current
	entry["hasClient"] = !!owner?.current?.client
	entry["category"] = roundend_category
	entry["isDead"] = owner?.current?.stat == DEAD
	return entry

/datum/admins/proc/build_antag_listing()
	var/list/sections = list()
	var/list/priority_sections = list()

	var/list/all_teams = list()
	var/list/all_antagonists = list()

	for(var/datum/antagonist/antag in GLOB.antagonists)
		if(!antag.owner)
			continue
		all_teams |= antag.get_team()
		all_antagonists += antag

	for(var/datum/team/team in all_teams)
		for(var/datum/antagonist/team_antag in all_antagonists)
			if(team_antag.get_team() == team)
				all_antagonists -= team_antag
		sections += team.antag_listing_entry()

	sortTim(all_antagonists, GLOBAL_PROC_REF(cmp_antag_category))

	var/current_category
	var/list/current_section = list()
	for(var/i in 1 to all_antagonists.len)
		var/datum/antagonist/current_antag = all_antagonists[i]
		var/datum/antagonist/next_antag
		if(i < all_antagonists.len)
			next_antag = all_antagonists[i + 1]
		if(!current_category)
			current_category = current_antag.roundend_category
			current_section += "<b>[capitalize(current_category)]</b><br>"
			current_section += "<table cellspacing=5>"
		current_section += current_antag.antag_listing_entry()

		if(!next_antag || next_antag.roundend_category != current_antag.roundend_category)
			current_section += "</table>"
			sections += current_section.Join()
			current_section.Cut()
			current_category = null
	var/list/all_sections = priority_sections + sections
	return all_sections.Join("<br>")

/datum/admins/proc/build_antag_listing_data()
	var/list/sections = list()

	var/list/all_teams = list()
	var/list/all_antagonists = list()

	for(var/datum/antagonist/antag in GLOB.antagonists)
		if(!antag.owner)
			continue
		all_teams |= antag.get_team()
		all_antagonists += antag

	for(var/datum/team/team in all_teams)
		var/list/members = list()
		for(var/datum/antagonist/team_antag in all_antagonists)
			if(team_antag.get_team() == team)
				all_antagonists -= team_antag
				members += list(team_antag.antag_listing_entry_data())
		var/list/section = list(
			"title" = team.antag_listing_name(),
			"entries" = members,
			"type" = "team",
		)
		sections += list(section)

	sortTim(all_antagonists, GLOBAL_PROC_REF(cmp_antag_category))

	var/current_category
	var/list/current_entries = list()
	for(var/i in 1 to all_antagonists.len)
		var/datum/antagonist/current_antag = all_antagonists[i]
		var/datum/antagonist/next_antag
		if(i < all_antagonists.len)
			next_antag = all_antagonists[i + 1]
		if(!current_category)
			current_category = current_antag.roundend_category
		current_entries += list(current_antag.antag_listing_entry_data())

		if(!next_antag || next_antag.roundend_category != current_antag.roundend_category)
			var/list/section = list(
				"title" = capitalize(current_category),
				"entries" = current_entries.Copy(),
				"type" = "category",
			)
			sections += list(section)
			current_entries.Cut()
			current_category = null
	return sections

/datum/admins/proc/check_antagonists()
	if(!SSticker.HasRoundStarted())
		tgui_alert(usr, "The game hasn't started yet!")
		return

	var/datum/admin_antagonist_panel/interface = new(src)
	interface.ui_interact(usr)

/datum/admin_antagonist_panel
	var/datum/admins/holder

/datum/admin_antagonist_panel/New(datum/admins/holder)
	src.holder = holder
	return ..()

/datum/admin_antagonist_panel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/admin_antagonist_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AntagonistPanel")
		ui.open()

/datum/admin_antagonist_panel/ui_data(mob/user)
	var/list/data = list()
	var/has_rights = holder?.check_for_rights(R_ADMIN)
	data["hasRights"] = has_rights
	data["roundStarted"] = SSticker.HasRoundStarted()
	if(!has_rights || !SSticker.HasRoundStarted())
		return data

	data["round"] = build_round_data()
	data["counts"] = build_population_data()
	data["antagonists"] = holder.build_antag_listing_data()
	data["opforHtml"] = SSopposing_force?.get_check_antag_listing()
	data["nuke"] = build_nuke_data()
	data["permissions"] = list(
		"canAdmin" = holder.check_for_rights(R_ADMIN),
		"canServer" = holder.check_for_rights(R_SERVER),
	)
	return data

/datum/admin_antagonist_panel/proc/build_round_data()
	var/list/round = list()
	round["duration"] = DisplayTimeText(world.time - SSticker.round_start_time)
	round["shuttle"] = build_shuttle_data()
	round["delayEnd"] = SSticker.delay_end
	round["readyForReboot"] = SSticker.ready_for_reboot
	round["ctfEnabled"] = is_ctf_enabled()
	return round

/datum/admin_antagonist_panel/proc/build_shuttle_data()
	var/list/shuttle = list()
	var/timeleft = SSshuttle.emergency.timeLeft()
	shuttle["etaSeconds"] = timeleft
	shuttle["state"] = SSshuttle.emergency.mode
	shuttle["isIdleOrRecalled"] = EMERGENCY_IDLE_OR_RECALLED
	shuttle["canSendBack"] = SSshuttle.emergency.mode == SHUTTLE_CALL && !EMERGENCY_AT_LEAST_DOCKED
	shuttle["canCall"] = !EMERGENCY_AT_LEAST_DOCKED
	shuttle["callDisabledReason"] = EMERGENCY_AT_LEAST_DOCKED ? "Shuttle already docked or recalling." : null
	return shuttle

/datum/admin_antagonist_panel/proc/build_population_data()
	var/list/stats = list()
	var/connected_players = GLOB.clients.len
	var/lobby_players = 0
	var/observers = 0
	var/observers_connected = 0
	var/living_players = 0
	var/living_players_connected = 0
	var/antagonists = 0
	var/antagonists_dead = 0
	var/brains = 0
	var/other_players = 0
	var/living_skipped = 0
	var/drones = 0
	var/security = 0
	var/security_dead = 0

	for(var/mob/checked_mob in GLOB.mob_list)
		if(!checked_mob.ckey)
			continue
		if(isnewplayer(checked_mob))
			lobby_players++
			continue
		else if(checked_mob.mind && !isbrain(checked_mob) && !isobserver(checked_mob))
			if(checked_mob.stat != DEAD)
				if(isdrone(checked_mob))
					drones++
					continue
				if(is_centcom_level(checked_mob.z))
					living_skipped++
					continue
				living_players++
				if(checked_mob.client)
					living_players_connected++
			else if(checked_mob.ckey)
				observers++
				if(checked_mob.client)
					observers_connected++

			if(checked_mob.is_antag())
				antagonists++
				if(checked_mob.stat == DEAD)
					antagonists_dead++
			if(checked_mob.mind.assigned_role?.departments_list?.Find(/datum/job_department/security))
				security++
				if(checked_mob.stat == DEAD)
					security_dead++
		else if(checked_mob.stat == DEAD || isobserver(checked_mob))
			observers++
			if(checked_mob.client)
				observers_connected++
		else if(isbrain(checked_mob))
			brains++
		else
			other_players++

	stats["connected"] = connected_players
	stats["lobby"] = lobby_players
	stats["living"] = living_players
	stats["livingConnected"] = living_players_connected
	stats["antagonists"] = antagonists
	stats["antagonistsAlive"] = antagonists - antagonists_dead
	stats["antagonistsDead"] = antagonists_dead
	stats["security"] = security
	stats["securityDead"] = security_dead
	stats["skipped"] = living_skipped
	stats["drones"] = drones
	stats["observers"] = observers
	stats["observersConnected"] = observers_connected
	stats["brains"] = brains
	stats["other"] = other_players
	return stats

/datum/admin_antagonist_panel/proc/get_loneop_info()
	var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
	if(!loneop)
		return null
	return list(
		"weight" = loneop.weight,
		"occurrences" = loneop.occurrences,
		"maxOccurrences" = loneop.max_occurrences,
		"chance" = clamp(loneop.weight, 0, 100),
	)

/datum/admin_antagonist_panel/proc/build_nuke_data()
	var/list/nuke = list()
	var/list/disks = list()
	for(var/obj/item/disk/nuclear/disk as anything in (SSpoints_of_interest?.real_nuclear_disks || list()))
		var/datum/component/keep_me_secure/secure_component = disk.GetComponent(/datum/component/keep_me_secure)
		var/turf/disk_turf = get_turf(disk)
		var/list/info = list(
			"ref" = REF(disk),
			"name" = disk.name,
			"fake" = disk.fake,
			"secured" = secure_component?.is_secured(),
			"lastMove" = secure_component ? max(world.time - secure_component.last_move, 0) : null,
			"holder" = disk.loc ? disk.loc.name : null,
			"holderType" = disk.loc ? "[disk.loc.type]" : null,
			"location" = disk_turf ? get_area_name(disk_turf, TRUE) : null,
			"coords" = disk_turf ? list("x" = disk_turf.x, "y" = disk_turf.y, "z" = disk_turf.z) : null,
		)
		disks += list(info)

	nuke["disks"] = disks
	nuke["code"] = find_nuke_code()
	nuke["loneOp"] = get_loneop_info()
	nuke["hasDisks"] = disks.len > 0
	return nuke

/datum/admin_antagonist_panel/proc/find_nuke_code()
	for(var/datum/team/team in GLOB.antagonist_teams)
		if(!istype(team, /datum/team/nuclear))
			continue
		var/datum/team/nuclear/nuke_team = team
		if(nuke_team.memorized_code)
			admin_panel_fallback_nuke_code = nuke_team.memorized_code
			admin_panel_fallback_nuke_code_round_id = GLOB.round_id
			return nuke_team.memorized_code

	for(var/obj/machinery/nuclearbomb/nuke as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb))
		if(nuke.r_code && nuke.r_code != NUKE_CODE_UNSET)
			admin_panel_fallback_nuke_code = nuke.r_code
			admin_panel_fallback_nuke_code_round_id = GLOB.round_id
			return nuke.r_code
		if(!nuke.r_code || nuke.r_code == NUKE_CODE_UNSET)
			var/fallback_code = admin_panel_get_fallback_nuke_code()
			nuke.r_code = fallback_code
			return fallback_code

	var/final_code = admin_panel_get_fallback_nuke_code()
	for(var/obj/machinery/nuclearbomb/nuke as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb))
		if(!nuke.r_code || nuke.r_code == NUKE_CODE_UNSET)
			nuke.r_code = final_code
	return final_code

/datum/admin_antagonist_panel/proc/sanitize_nuke_code_input(raw_code)
	if(isnull(raw_code))
		return null
	var/text_code = "[raw_code]"
	var/list/digits = list()
	for(var/i in 1 to length(text_code))
		var/char = copytext_char(text_code, i, i + 1)
		if(char >= "0" && char <= "9")
			digits += char
	if(!digits.len)
		return null
	var/clean_code = digits.Join()
	if(length(clean_code) > 5)
		clean_code = copytext_char(clean_code, 1, 6)
	while(length(clean_code) < 5)
		clean_code = "0" + clean_code
	return clean_code

/datum/admin_antagonist_panel/proc/apply_nuke_code(new_code)
	if(!new_code)
		return

	admin_panel_fallback_nuke_code = new_code
	admin_panel_fallback_nuke_code_round_id = GLOB.round_id

	for(var/datum/team/nuclear/nuke_team in GLOB.antagonist_teams)
		nuke_team.memorized_code = new_code
		if(nuke_team.tracked_nuke)
			nuke_team.tracked_nuke.r_code = new_code

	for(var/obj/machinery/nuclearbomb/nuke as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb))
		nuke.r_code = new_code

	return new_code

/datum/admin_antagonist_panel/proc/is_ctf_enabled()
	var/datum/ctf_controller/ctf_state = GLOB.ctf_games?[CTF_GHOST_CTF_GAME_ID]
	return ctf_state?.ctf_enabled

/datum/admin_antagonist_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!holder)
		return
	if(!holder.check_for_rights(R_ADMIN))
		return

	switch(action)
		if("set_nuke_code")
			var/default_code = find_nuke_code()
			var/input_code = input(usr, "Enter new nuclear authentication code (digits only, max 5).", "Set Nuke Code", default_code) as text|null
			var/new_code = sanitize_nuke_code_input(input_code)
			if(!new_code)
				return
			apply_nuke_code(new_code)
			log_admin("[key_name(usr)] set the nuclear authentication code to [new_code] via antagonist panel.")
			message_admins(span_adminnotice("[key_name_admin(usr)] set the nuclear authentication code to [new_code]."))
		if("randomize_nuke_code")
			var/new_code = random_nukecode()
			apply_nuke_code(new_code)
			log_admin("[key_name(usr)] randomized the nuclear authentication code to [new_code] via antagonist panel.")
			message_admins(span_adminnotice("[key_name_admin(usr)] randomized the nuclear authentication code to [new_code]."))
		if("call_shuttle")
			if(EMERGENCY_AT_LEAST_DOCKED)
				return
			SSshuttle.emergency.request()
			log_admin("[key_name(usr)] called the Emergency Shuttle.")
			message_admins(span_adminnotice("[key_name_admin(usr)] called the Emergency Shuttle to the station."))
		if("send_shuttle_back")
			if(EMERGENCY_AT_LEAST_DOCKED || SSshuttle.emergency.mode != SHUTTLE_CALL)
				return
			SSshuttle.emergency.cancel()
			log_admin("[key_name(usr)] sent the Emergency Shuttle back.")
			message_admins(span_adminnotice("[key_name_admin(usr)] sent the Emergency Shuttle back."))
		if("edit_shuttle_time")
			if(!holder.check_for_rights(R_SERVER))
				return
			var/timer = input(usr, "Enter new shuttle duration (seconds):", "Edit Shuttle Timeleft", SSshuttle.emergency.timeLeft()) as num|null
			if(!timer)
				return
			SSshuttle.emergency.setTimer(timer SECONDS)
			log_admin("[key_name(usr)] edited the Emergency Shuttle's timeleft to [timer] seconds.")
			minor_announce("The emergency shuttle will reach its destination in [DisplayTimeText(timer SECONDS)].")
			message_admins(span_adminnotice("[key_name_admin(usr)] edited the Emergency Shuttle's timeleft to [timer] seconds."))
		if("delay_round_end")
			if(!holder.check_for_rights(R_SERVER))
				return
			SSticker.delay_end = TRUE
			SSticker.admin_delay_notice = "Toggled via antagonist panel"
			message_admins(span_adminnotice("[key_name_admin(usr)] delayed the round end."))
		if("undelay_round_end")
			if(!holder.check_for_rights(R_SERVER))
				return
			if(tgui_alert(usr, "Really cancel current round end delay? The reason for the current delay is: \"[SSticker.admin_delay_notice]\"", "Undelay round end", list("Yes", "No")) == "No")
				return
			SSticker.admin_delay_notice = null
			SSticker.delay_end = FALSE
			log_admin("[key_name(usr)] undelayed the round end.")
			if(SSticker.ready_for_reboot)
				message_admins("[key_name_admin(usr)] undelayed the round end. You must now manually Reboot World to start the next shift.")
			else
				message_admins("[key_name_admin(usr)] undelayed the round end.")
		if("end_round")
			message_admins(span_adminnotice("[key_name_admin(usr)] is considering ending the round."))
			if(tgui_alert(usr, "This will end the round, are you sure you want to do this?", "Confirmation", list("Yes", "No")) != "Yes")
				message_admins(span_adminnotice("[key_name_admin(usr)] decided against ending the round."))
				return
			if(tgui_alert(usr, "Final confirmation: end the round now?", "Confirmation", list("Yes", "No")) != "Yes")
				message_admins(span_adminnotice("[key_name_admin(usr)] decided against ending the round."))
				return
			message_admins(span_adminnotice("[key_name_admin(usr)] has ended the round."))
			SSticker.force_ending = ADMIN_FORCE_END_ROUND
		if("toggle_ctf")
			toggle_id_ctf(usr, CTF_GHOST_CTF_GAME_ID)
		if("reboot_world")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/restart)
		if("check_teams")
			holder.check_teams()
		if("follow")
			var/atom/movable/target = locate(params["target"])
			if(target)
				usr.client?.admin_follow(target)
		if("traitor_panel")
			var/target = locate(params["target"])
			if(!target)
				return
			if(ismob(target))
				SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/show_traitor_panel, target)
			else if(istype(target, /datum/mind))
				var/datum/mind/mind_target = target
				mind_target.traitor_panel()
		if("pm")
			var/ckey = params["ckey"]
			if(ckey)
				usr.client?.cmd_admin_pm(ckey)
		if("teleport_disk")
			var/obj/item/disk/nuclear/disk = locate(params["target"])
			if(disk)
				disk.forceMove(get_turf(usr))
				log_admin("[key_name(usr)] teleported [disk] to themselves via antagonist panel.")
				message_admins(span_adminnotice("[key_name_admin(usr)] teleported [disk] to themselves."))
		if("respawn_disk")
			var/turf/admin_turf = get_turf(usr)
			if(!admin_turf)
				return
			var/obj/item/disk/nuclear/new_disk = new(admin_turf)
			log_admin("[key_name(usr)] spawned [new_disk] at [ADMIN_VERBOSEJMP(admin_turf)].")
			message_admins(span_adminnotice("[key_name_admin(usr)] spawned [new_disk] at their location."))
