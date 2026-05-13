/datum/beaker_panel

/datum/beaker_panel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/beaker_panel/ui_close()
	qdel(src)

/datum/beaker_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BeakerPanel")
		ui.open()

/datum/beaker_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("spawn")
			var/obj/created = spawn_container_from_data(user, params["spawn_info"])
			user.log_message("spawned a [created] containing [pretty_string_from_reagent_list(created.reagents.reagent_list)]", LOG_ADMIN)
			return TRUE
		if("spawngrenade")
			var/obj/item/grenade/chem_grenade/grenade = spawn_grenade_from_data(user, params["spawn_info"], params["grenade_info"])
			var/log_string = list()
			for(var/obj/beaker as anything in grenade.beakers)
				log_string += pretty_string_from_reagent_list(beaker.reagents.reagent_list)
			user.log_message("spawned a [grenade] containing [english_list(log_string)]", LOG_ADMIN)
			return TRUE

/datum/beaker_panel/ui_static_data(mob/user)
	var/list/data = list()

	data["reagents"] = list()
	data["containers"] = list()

	for(var/datum/reagent/reagent_type as anything in subtypesof(/datum/reagent))
		if(!reagent_type::name)
			continue
		data["reagents"] += list(list("id" = reagent_type, "text" = reagent_type::name))

	for(var/obj/item/reagent_containers/container_type as anything in subtypesof(/obj/item/reagent_containers))
		if(!container_type::name)
			continue
		data["containers"] += list(list("id" = container_type, "text" = container_type::name, "volume" = container_type::volume))

	return data

/datum/beaker_panel/proc/spawn_container_from_data(mob/user, list/spawn_info)
	var/container_type = text2path(spawn_info["container"])
	var/list/container_reagents = list()
	for(var/reagent_string, reagent_amount in spawn_info["reagents"])
		container_reagents[text2path(reagent_string)] = text2num(reagent_amount)

	return spawn_container(user, container_type, container_reagents)

/datum/beaker_panel/proc/spawn_container(mob/user, container_type, list/container_reagents)
	var/obj/item/reagent_containers/container = new container_type(user.drop_location())
	container.reagents.maximum_volume = INFINITY
	container.reagents.clear_reagents()
	container.reagents.add_reagent_list(container_reagents)
	container.reagents.maximum_volume = max(container.reagents.total_volume, initial(container.volume))
	return container

/datum/beaker_panel/proc/spawn_grenade_from_data(mob/user, list/all_spawn_info, list/grenade_info)
	var/list/containers = list()
	for(var/list/container_info as anything in all_spawn_info)
		containers += spawn_container_from_data(user, container_info)

	return spawn_grenade(user, containers, grenade_info)

/datum/beaker_panel/proc/spawn_grenade(mob/user, list/beakers, list/grenade_info)
	var/obj/item/grenade/chem_grenade/grenade = new(user.drop_location())
	grenade.beakers = beakers
	grenade.stage_change(GRENADE_READY)

	for(var/obj/beaker as anything in grenade.beakers)
		beaker.forceMove(grenade)

	switch(grenade_info["detonation_type"])
		if("normal")
			var/det_time = text2num(grenade_info["detonation_timer"]) * 1 SECONDS
			if(det_time)
				grenade.det_time = det_time

	return grenade

ADMIN_VERB(beaker_panel, R_SPAWN, "Spawn Reagent Container", "Spawn a reagent container.", ADMIN_CATEGORY_EVENTS)
	var/datum/beaker_panel/panel = new
	panel.ui_interact(user.mob)

/proc/cmp_admin_reagent_entry(list/a, list/b)
	if(!islist(a) || !islist(b))
		return 0
	var/name_a = istext(a?["name"]) ? a["name"] : ""
	var/name_b = istext(b?["name"]) ? b["name"] : ""
	var/compare = cmp_text_asc(name_a, name_b)
	if(compare)
		return compare
	var/id_a = istext(a?["id"]) ? a["id"] : ""
	var/id_b = istext(b?["id"]) ? b["id"] : ""
	return cmp_text_asc(id_a, id_b)

/datum/admins/proc/create_reagent(mob/user)
	if(!check_rights(R_SPAWN))
		return
	if(!user)
		return
	var/datum/admin_reagent_panel/panel = new(src)
	panel.ui_interact(user)

/datum/admin_reagent_panel
	var/datum/admins/holder
	var/list/reagent_entries
	var/list/reagent_lookup
	var/list/container_entries
	var/list/container_lookup

/datum/admin_reagent_panel/New(datum/admins/holder)
	src.holder = holder
	reagent_entries = list()
	reagent_lookup = list()
	container_entries = list()
	container_lookup = list()

	var/list/reagent_records = list()
	for(var/datum/reagent/reagent_type as anything in subtypesof(/datum/reagent))
		var/name = initial(reagent_type.name)
		if(!istext(name) || !length(name))
			name = "[reagent_type]"
		var/list/record = list(
			"id" = "[reagent_type]",
			"name" = name,
			"path" = reagent_type,
		)
		reagent_records += list(record)

	reagent_records = sort_list(reagent_records, GLOBAL_PROC_REF(cmp_admin_reagent_entry))

	for(var/list/record in reagent_records)
		var/id = record["id"]
		reagent_entries += list(list(
			"id" = id,
			"name" = record["name"],
		))
		reagent_lookup[id] = record["path"]

	var/list/container_records = list()
	for(var/obj/item/reagent_containers/container_type as anything in subtypesof(/obj/item/reagent_containers))
		var/name = initial(container_type.name)
		if(!istext(name) || !length(name))
			name = "[container_type]"
		var/volume = initial(container_type.volume)
		var/list/record = list(
			"id" = "[container_type]",
			"name" = name,
			"path" = container_type,
		)
		if(isnum(volume))
			record["volume"] = volume
		else
			record["volume"] = null
		container_records += list(record)

	container_records = sort_list(container_records, GLOBAL_PROC_REF(cmp_admin_reagent_entry))

	for(var/list/record in container_records)
		var/id = record["id"]
		var/volume = record["volume"]
		container_entries += list(list(
			"id" = id,
			"name" = record["name"],
			"volume" = isnum(volume) ? volume : null,
		))
		container_lookup[id] = record["path"]

	return ..()

/datum/admin_reagent_panel/ui_state(mob/user)
	return ADMIN_STATE(R_SPAWN)

/datum/admin_reagent_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminReagent")
		ui.open()

/datum/admin_reagent_panel/ui_static_data(mob/user)
	var/list/static_data = list()
	static_data["reagents"] = reagent_entries
	static_data["containers"] = container_entries
	return static_data

/datum/admin_reagent_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!holder || !holder.check_for_rights(R_SPAWN))
		return
	var/mob/user
	if(ui)
		user = ui.user
	if(!user)
		return
	switch(action)
		if("spawn")
			var/container_key = params?["container"]
			if(!istext(container_key) || !length(container_key))
				return
			var/container_path = container_lookup?[container_key]
			if(!container_path || !ispath(container_path, /obj/item/reagent_containers))
				to_chat(user, span_warning("Select a valid container type."), confidential = TRUE)
				return
			var/reagents_json = params?["reagents"]
			if(!istext(reagents_json) || !length(reagents_json))
				to_chat(user, span_warning("Add reagents before spawning a container."), confidential = TRUE)
				return
			var/list/decoded = json_decode(reagents_json)
			if(!islist(decoded))
				return
			var/list/reagent_specs = list()
			for(var/list/entry in decoded)
				if(!islist(entry))
					continue
				var/reagent_key = entry?["path"]
				if(!istext(reagent_key) || !length(reagent_key))
					continue
				var/datum/reagent/reagent_type = reagent_lookup?[reagent_key]
				if(!reagent_type || !ispath(reagent_type, /datum/reagent))
					continue
				var/amount_value = entry?["amount"]
				var/amount = text2num(amount_value)
				if(amount <= 0)
					continue
				reagent_specs += list(list(
					"reagent" = reagent_type,
					"amount" = amount,
				))
			if(!length(reagent_specs))
				to_chat(user, span_warning("Add at least one reagent with a positive amount."), confidential = TRUE)
				return
			var/turf/location = get_turf(user)
			if(!location)
				to_chat(user, span_warning("Cannot determine a spawn location."), confidential = TRUE)
				return
			var/obj/item/reagent_containers/container = new container_path(location)
			container.reagents.maximum_volume = INFINITY
			container.reagents.clear_reagents()
			for(var/list/spec in reagent_specs)
				container.reagents.add_reagent(spec["reagent"], spec["amount"])
			container.reagents.maximum_volume = max(container.reagents.total_volume, initial(container.volume))
			container.flags_1 |= ADMIN_SPAWNED_1
			var/reagent_description = pretty_string_from_reagent_list(container.reagents.reagent_list)
			var/message = "spawned a [container] containing [reagent_description]"
			user.log_message(message, LOG_GAME)
			log_admin("[key_name(user)] [message]")
			to_chat(user, span_notice("You [message]."), confidential = TRUE)
