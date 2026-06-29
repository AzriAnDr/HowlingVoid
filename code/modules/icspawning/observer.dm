// NOVA MODULE IC-SPAWNING https://github.com/Skyrat-SS13/Skyrat-tg/pull/104

/mob/dead/observer/CtrlClickOn(mob/user)
	quickicspawn(user)


#define QUICK_SPAWN_TELEPORT_FLUX "Bluespace"
#define QUICK_SPAWN_TELEPORT_POD "Pod"
#define QUICK_SPAWN_CHARACTER_SELECTED "Selected Character"
#define QUICK_SPAWN_CHARACTER_RANDOM "Randomly Created"
#define QUICK_SPAWN_QUIRKS_LOADOUT "Quirks & Loadout"
#define QUICK_SPAWN_QUIRKS_ONLY "Quirks Only"
#define QUICK_SPAWN_LOADOUT_ONLY "Loadout Only"
#define QUICK_SPAWN_NEITHER "Neither"
#define QUICK_SPAWN_DEFAULT_OUTFIT "Bluespace-tech"

/mob/dead/observer/proc/quickicspawn(mob/user)
	if(!isobserver(user) || !check_rights(R_SPAWN))
		return

	var/datum/ic_spawn_builder/builder = new(src, user)
	builder.ui_interact(src)
	builder.wait()

	if(!builder?.submitted)
		qdel(builder)
		return

	builder.apply_spawn()
	qdel(builder)

/// Internal state holder + modal for IC quick spawn.
/datum/ic_spawn_builder
	var/mob/dead/observer/owner
	var/mob/target
	var/teleport_mode = QUICK_SPAWN_TELEPORT_FLUX
	var/character_mode = QUICK_SPAWN_CHARACTER_SELECTED
	var/outfit_choice = QUICK_SPAWN_DEFAULT_OUTFIT
	var/quirk_mode = QUICK_SPAWN_QUIRKS_LOADOUT
	var/give_return = FALSE
	var/give_godmode = FALSE
	var/count_as_admin = FALSE
	var/give_nutrition_supply = FALSE
	var/submitted = FALSE
	var/closed = FALSE
	var/list/outfit_options

/datum/ic_spawn_builder/New(mob/dead/observer/owner, mob/target)
	src.owner = owner
	src.target = target
	give_return = owner == target
	outfit_options = build_outfit_options(owner?.client)
	if(!(outfit_choice in outfit_options))
		outfit_choice = QUICK_SPAWN_DEFAULT_OUTFIT
	return ..()

/datum/ic_spawn_builder/Destroy(force)
	SStgui.close_uis(src)
	return ..()

/datum/ic_spawn_builder/proc/wait()
	while(!submitted && !closed && !QDELETED(src))
		stoplag(1)

/datum/ic_spawn_builder/ui_state(mob/user)
	return ADMIN_STATE(R_SPAWN)

/datum/ic_spawn_builder/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "QuickICSpawn")
		ui.open()

/datum/ic_spawn_builder/ui_close(mob/user)
	closed = TRUE
	return ..()

/datum/ic_spawn_builder/ui_static_data(mob/user)
	var/list/data = list()
	var/list/frontend_outfits = list()
	for(var/option_id in outfit_options)
		var/list/entry = outfit_options[option_id]
		frontend_outfits += list(list(
			"id" = entry["id"],
			"name" = entry["name"],
			"category" = entry["category"],
		))
	data["outfits"] = frontend_outfits
	data["defaultOutfit"] = outfit_choice
	return data

/datum/ic_spawn_builder/ui_data(mob/user)
	return list(
		"targetName" = target?.name,
		"targetKey" = target?.key,
		"spawnForSelf" = owner == target,
		"teleportMode" = teleport_mode,
		"characterMode" = character_mode,
		"outfitChoice" = outfit_choice,
		"quirkMode" = quirk_mode,
		"giveReturn" = give_return,
		"canGiveReturn" = owner != target,
		"giveGodmode" = give_godmode,
		"countAsAdmin" = count_as_admin,
		"giveNutritionSupply" = give_nutrition_supply,
	)

/datum/ic_spawn_builder/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("setTeleport")
			if(params["teleport"] in list(QUICK_SPAWN_TELEPORT_FLUX, QUICK_SPAWN_TELEPORT_POD))
				teleport_mode = params["teleport"]
			return TRUE

		if("setCharacterMode")
			if(params["characterMode"] in list(QUICK_SPAWN_CHARACTER_SELECTED, QUICK_SPAWN_CHARACTER_RANDOM))
				character_mode = params["characterMode"]
			return TRUE

		if("setOutfit")
			if(params["outfit"] && (params["outfit"] in outfit_options))
				outfit_choice = params["outfit"]
			return TRUE

		if("setQuirkMode")
			if(params["quirkMode"] in list(QUICK_SPAWN_QUIRKS_LOADOUT, QUICK_SPAWN_QUIRKS_ONLY, QUICK_SPAWN_LOADOUT_ONLY, QUICK_SPAWN_NEITHER))
				quirk_mode = params["quirkMode"]
			return TRUE

		if("setReturn")
			give_return = !!params["giveReturn"]
			return TRUE

		if("setGodmode")
			give_godmode = !!params["giveGodmode"]
			return TRUE

		if("setCountAsAdmin")
			count_as_admin = !!params["countAsAdmin"]
			return TRUE

		if("setNutritionSupply")
			give_nutrition_supply = !!params["giveNutritionSupply"]
			return TRUE

		if("submit")
			if(!(outfit_choice in outfit_options))
				outfit_choice = QUICK_SPAWN_DEFAULT_OUTFIT
			submitted = TRUE
			SStgui.close_uis(src)
			return TRUE

		if("cancel")
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

	return FALSE

/datum/ic_spawn_builder/proc/add_option(list/options, id, name, category, value)
	options[id] = list(
		"id" = id,
		"name" = name,
		"category" = category,
		"value" = value,
	)

/datum/ic_spawn_builder/proc/build_outfit_options(client/owner_client)
	var/list/options = list()
	add_option(options, QUICK_SPAWN_DEFAULT_OUTFIT, "Bluespace Tech", "Quick", /datum/outfit/admin/bst)
	add_option(options, "Bluespace-tech-modsuit", "Bluespace Tech (MODsuit)", "Quick", /datum/outfit/debug/bst)
	add_option(options, "naked", "Naked", "Quick", null)

	// Core outfits
	var/list/job_outfits = typesof(/datum/outfit/job)
	var/list/plasmaman_outfits = typesof(/datum/outfit/plasmaman)
	for(var/path in sort_list(subtypesof(/datum/outfit)))
		if((path in job_outfits) || (path in plasmaman_outfits))
			continue
		var/datum/outfit/O = path
		add_option(options, "[path]", initial(O.name), "General", path)

	// Job presets
	for(var/path in sort_list(subtypesof(/datum/outfit/job)))
		var/datum/outfit/job/O = path
		add_option(options, "[path]", "Job: [initial(O.name)]", "Job", path)

	// Plasmaman sets
	for(var/path in sort_list(typesof(/datum/outfit/plasmaman)))
		var/datum/outfit/plasmaman/O = path
		add_option(options, "[path]", "Plasmaman: [initial(O.name)]", "Plasmaman", path)

	// Custom saved outfits
	if(owner_client)
		var/custom_index = 1
		for(var/datum/outfit/custom_outfit in GLOB.custom_outfits)
			add_option(options, "custom-[custom_index]", custom_outfit.name, "Custom", custom_outfit)
			custom_index++

	return options

/datum/ic_spawn_builder/proc/get_outfit_value()
	var/list/entry = outfit_options[outfit_choice]
	return entry?["value"]

/datum/ic_spawn_builder/proc/apply_spawn()
	if(!owner || !target)
		return

	var/turf/current_turf = get_turf(target)
	if(!current_turf)
		return

	var/selected_outfit = get_outfit_value()
	var/mob/living/carbon/human/spawned_player = new(target)

	if(character_mode == QUICK_SPAWN_CHARACTER_SELECTED)
		spawned_player.name = target.name
		spawned_player.real_name = target.real_name

		var/mob/living/carbon/human/player_as_human = spawned_player
		target.client?.prefs.safe_transfer_prefs_to(player_as_human)
		if(quirk_mode == QUICK_SPAWN_QUIRKS_LOADOUT || quirk_mode == QUICK_SPAWN_LOADOUT_ONLY)
			if(isnull(selected_outfit))
				player_as_human.equip_outfit_and_loadout(new /datum/outfit(), target.client?.prefs)
			else
				player_as_human.equip_outfit_and_loadout(selected_outfit, target.client?.prefs)
		else if(selected_outfit)
			spawned_player.equipOutfit(selected_outfit)
		if(quirk_mode == QUICK_SPAWN_QUIRKS_LOADOUT || quirk_mode == QUICK_SPAWN_QUIRKS_ONLY)
			SSquirks.AssignQuirks(player_as_human, target.client)
		player_as_human.dna.update_dna_identity()
	else if(selected_outfit)
		spawned_player.equipOutfit(selected_outfit)

	QDEL_IN(target, 1)

	if(teleport_mode == QUICK_SPAWN_TELEPORT_FLUX)
		playsound(spawned_player, 'sound/effects/magic/Disable_Tech.ogg', 100, 1)

	if(target.mind && isliving(spawned_player))
		target.mind.transfer_to(spawned_player, TRUE)
	else
		spawned_player.ckey = target.key

	if(give_godmode)
		ADD_TRAIT(spawned_player, TRAIT_GODMODE, ADMIN_TRAIT)

	if(count_as_admin && spawned_player.client)
		spawned_player.client.admin_ghost_poll_eligible = TRUE

	if(give_return)
		var/datum/action/cooldown/spell/return_back/return_spell = new(spawned_player)
		return_spell.Grant(spawned_player)

	if(give_nutrition_supply)
		// HowlingVoid has no thirst system. Kept commented in case hydration supply is restored later.
		// var/datum/action/innate/ghostcafe_supply/hydration/hydration_toggle = new(spawned_player)
		// hydration_toggle.Grant(spawned_player)
		var/datum/action/innate/ghostcafe_supply/nutrition/nutrition_toggle = new(spawned_player)
		nutrition_toggle.Grant(spawned_player)

	switch(teleport_mode)
		if(QUICK_SPAWN_TELEPORT_FLUX)
			spawned_player.forceMove(current_turf)
			do_sparks(10, TRUE, spawned_player, spark_type = /datum/effect_system/basic/spark_spread/quantum)
		if(QUICK_SPAWN_TELEPORT_POD)
			var/obj/structure/closet/supplypod/empty_pod = new()

			empty_pod.style = /datum/pod_style/advanced
			empty_pod.bluespace = TRUE
			empty_pod.explosionSize = list(0,0,0,0)
			empty_pod.desc = "A sleek, and slightly worn Bluespace pod - its probably seen many deliveries..."

			spawned_player.forceMove(empty_pod)

			new /obj/effect/pod_landingzone(current_turf, empty_pod)

/client/proc/robust_dress_shop_skyrat()
	var/list/baseoutfits = list("Naked","Custom","As Job...", "As Plasmaman...")
	var/list/outfits = list()
	var/list/paths = subtypesof(/datum/outfit) - typesof(/datum/outfit/job) - typesof(/datum/outfit/plasmaman)

	for(var/path in paths)
		// Get the datum from the path so we can grab its name.
		var/datum/outfit/path_as_outfit = path
		outfits[initial(path_as_outfit.name)] = path

	var/dresscode = tgui_input_list(src, "Select outfit", "Robust quick dress shop", baseoutfits + sort_list(outfits))

	if (isnull(dresscode))
		return

	if (outfits[dresscode])
		dresscode = outfits[dresscode]

	if (dresscode == "As Job...")
		var/list/job_paths = subtypesof(/datum/outfit/job)
		var/list/job_outfits = list()
		for(var/path in job_paths)
			var/datum/outfit/O = path
			job_outfits[initial(O.name)] = path

		dresscode = input("Select job equipment", "Robust quick dress shop") as null|anything in sort_list(job_outfits)
		dresscode = job_outfits[dresscode]
		if(isnull(dresscode))
			return

	if (dresscode == "As Plasmaman...")
		var/list/plasmaman_paths = typesof(/datum/outfit/plasmaman)
		var/list/plasmaman_outfits = list()
		for(var/path in plasmaman_paths)
			var/datum/outfit/O = path
			plasmaman_outfits[initial(O.name)] = path

		dresscode = input("Select plasmeme equipment", "Robust quick dress shop") as null|anything in sort_list(plasmaman_outfits)
		dresscode = plasmaman_outfits[dresscode]
		if(isnull(dresscode))
			return

	if (dresscode == "Custom")
		var/list/custom_names = list()
		for(var/datum/outfit/req_outfit in GLOB.custom_outfits)
			custom_names[req_outfit.name] = req_outfit
		var/selected_name = input("Select outfit", "Robust quick dress shop") as null|anything in sort_list(custom_names)
		dresscode = custom_names[selected_name]
		if(isnull(dresscode))
			return

	return dresscode

	#undef QUICK_SPAWN_TELEPORT_FLUX
	#undef QUICK_SPAWN_TELEPORT_POD
	#undef QUICK_SPAWN_CHARACTER_SELECTED
	#undef QUICK_SPAWN_CHARACTER_RANDOM
	#undef QUICK_SPAWN_QUIRKS_LOADOUT
	#undef QUICK_SPAWN_QUIRKS_ONLY
	#undef QUICK_SPAWN_LOADOUT_ONLY
	#undef QUICK_SPAWN_NEITHER
	#undef QUICK_SPAWN_DEFAULT_OUTFIT
