/// -- Outfit and mob helpers to equip our loadout items. --

/// An empty outfit we fill in with our loadout items to dress our dummy.
/datum/outfit/player_loadout
	name = "Player Loadout"

/datum/outfit/player_loadout/equip(mob/living/carbon/human/user, visualsOnly)
	. = ..()
	user.equip_outfit_and_loadout(new /datum/outfit(), user.client.prefs)

/obj/item/storage/box/loadout_job_gear
	name = "spare equipment box"
	desc = "A box containing spare equipment that could not fit in its intended place."
	illustration = "writing"
	storage_type = /datum/storage/box/loadout_job_gear

/datum/storage/box/loadout_job_gear
	max_slots = 16
	max_specific_storage = WEIGHT_CLASS_BULKY
	max_total_storage = 64

/*
 * Actually equip our mob with our job outfit and our loadout items.
 * Loadout items override the pre-existing item in the corresponding slot of the job outfit.
 * Some job items are preserved after being overridden - belt items, ear items, and glasses.
 * The rest of the slots, the items are overridden completely and deleted.
 *
 * Plasmamen are snowflaked to not have any envirosuit pieces removed just in case.
 * Their loadout items for those slots will be added to their backpack on spawn.
 *
 * outfit - the job outfit we're equipping
 * visuals_only - whether we call special equipped procs, or if we just look like we equipped it
 * preference_source - the preferences of the thing we're equipping
 * equipping_job - The job that's being applied.
 */
/mob/living/carbon/human/equip_outfit_and_loadout(
	datum/outfit/outfit = /datum/outfit,
	datum/preferences/preference_source = GLOB.preference_entries_by_key[ckey],
	visuals_only = FALSE,
	datum/job/equipping_job,
	allow_mechanical_loadout_items = TRUE,
)
	if (!preference_source)
		equipOutfit(outfit, visuals_only) // no prefs for loadout items, but we should still equip the outfit.
		return FALSE

	var/datum/outfit/equipped_outfit

	if(ispath(outfit))
		equipped_outfit = new outfit()
	else if(istype(outfit))
		equipped_outfit = outfit
	else
		CRASH("Outfit passed to equip_outfit_and_loadout was neither a path nor an instantiated type!")

	var/override_preference = preference_source.read_preference(/datum/preference/choiced/loadout_override_preference)
	var/list/job_gear_snapshot
	var/list/replaced_job_gear
	if(override_preference == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		job_gear_snapshot = get_loadout_job_gear_snapshot(equipped_outfit)

	var/list/loadout_list = get_active_loadout_list(preference_source)
	var/list/loadout_datums = loadout_list_to_datums(loadout_list)
	var/list/granted_loadout_datums = list()
	var/obj/item/storage/briefcase/empty/briefcase
	var/obj/item/storage/box/loadout_job_gear/spare_equipment_box
	var/obj/item/storage/box/erp/erpbox
	var/erp_enabled = !CONFIG_GET(flag/disable_erp_preferences)
	if(override_preference == LOADOUT_OVERRIDE_CASE && !visuals_only)
		briefcase = new(loc)
		for(var/datum/loadout_item/item as anything in loadout_datums)
			var/list/item_details = loadout_list?[item.item_path] || list()
			if(!item.is_equippable(src, item_details))
				continue
			if (erp_enabled && item.erp_box)
				if (isnull(erpbox))
					erpbox = new(loc)
				new item.item_path(erpbox)
				granted_loadout_datums += item
			else
				if (!item.can_be_applied_to(src, preference_source, equipping_job, allow_mechanical_loadout_items, visuals_only))
					continue
				new item.item_path(briefcase)
				granted_loadout_datums += item

		briefcase.name = "[preference_source.read_preference(/datum/preference/name/real_name)]'s travel suitcase"
		equipOutfit(equipped_outfit, visuals_only)
		put_in_hands_no_sleep(briefcase)
	else
		for(var/datum/loadout_item/item as anything in loadout_datums)
			var/list/item_details = loadout_list?[item.item_path] || list()
			if(!item.is_equippable(src, item_details))
				continue
			if (erp_enabled && item.erp_box)
				if (isnull(erpbox))
					erpbox = new(loc)
				new item.item_path(erpbox)
				granted_loadout_datums += item
			else
				if (!item.can_be_applied_to(src, preference_source, equipping_job, allow_mechanical_loadout_items, visuals_only))
					continue
				granted_loadout_datums += item

				// Make sure the item is not overriding an important for life outfit item
				var/datum/outfit/outfit_important_for_life = dna.species.outfit_important_for_life
				if(!outfit_important_for_life || !item.pre_equip_item(equipped_outfit, outfit_important_for_life, src, visuals_only))
					item.insert_path_into_outfit(equipped_outfit, src, visuals_only, override_preference)
		if(job_gear_snapshot)
			replaced_job_gear = get_replaced_loadout_job_gear(equipped_outfit, job_gear_snapshot)
			remove_loadout_job_gear_from_backpack_contents(equipped_outfit, replaced_job_gear)
		equipOutfit(equipped_outfit, visuals_only)

	var/list/new_contents = isnull(briefcase) ? get_all_gear() : briefcase.get_all_contents()

	var/update = NONE
	for(var/datum/loadout_item/item as anything in granted_loadout_datums)
		var/list/item_details = loadout_list?[item.item_path] || list()

		var/obj/item/equipped
		if(erpbox && item.erp_box)
			equipped = locate(item.item_path) in erpbox
		else
			equipped = locate(item.item_path) in new_contents

		if(isnull(equipped))
			if(istype(item, /datum/loadout_item/pocket_items/wallet))
				update |= item.on_equip_item(
					equipped_item = null,
					item_details = item_details,
					equipper = src,
					outfit = equipped_outfit,
					visuals_only = visuals_only,
				)
				continue
			if(visuals_only)
				continue
			if(isnull(spare_equipment_box))
				spare_equipment_box = new(drop_location())
			equipped = new item.item_path(spare_equipment_box)

		update |= item.on_equip_item(
			equipped_item = equipped,
			item_details = item_details,
			equipper = src,
			outfit = equipped_outfit,
			visuals_only = visuals_only,
		)

	spare_equipment_box = equip_spare_equipment_box(spare_equipment_box, replaced_job_gear)

	if(preference_source?.read_preference(/datum/preference/toggle/green_pin))
		var/obj/item/clothing/under/uniform = w_uniform
		uniform?.attach_accessory(new /obj/item/clothing/accessory/green_pin(), src, FALSE)

	if (!isnull(erpbox))
		if (!isnull(briefcase))
			erpbox.forceMove(briefcase)
		else if(!isnull(spare_equipment_box) && !QDELETED(spare_equipment_box))
			erpbox.forceMove(spare_equipment_box)
		else
			erpbox.equip_to_best_slot(src)

	if(update)
		update_clothing(update)

	return TRUE

/proc/get_loadout_job_gear_snapshot(datum/outfit/outfit)
	RETURN_TYPE(/list)

	var/static/list/loadout_replacement_slots = list(
		"accessory",
		"belt",
		"ears",
		"glasses",
		"gloves",
		"head",
		"l_hand",
		"mask",
		"neck",
		"r_hand",
		"shoes",
		"suit",
		"uniform",
	)

	var/list/snapshot = list()
	for(var/slot_name in loadout_replacement_slots)
		var/item_path = outfit.vars[slot_name]
		if(ispath(item_path, /obj/item))
			snapshot[slot_name] = item_path

	return snapshot

/proc/get_replaced_loadout_job_gear(datum/outfit/outfit, list/job_gear_snapshot)
	RETURN_TYPE(/list)

	var/list/replaced_job_gear = list()
	for(var/slot_name in job_gear_snapshot)
		var/item_path = job_gear_snapshot[slot_name]
		if(outfit.vars[slot_name] == item_path)
			continue
		replaced_job_gear[item_path] = (replaced_job_gear[item_path] || 0) + 1

	return replaced_job_gear

/proc/remove_loadout_job_gear_from_backpack_contents(datum/outfit/outfit, list/replaced_job_gear)
	if(!length(replaced_job_gear) || !length(outfit.backpack_contents))
		return

	for(var/item_path in replaced_job_gear)
		var/amount_to_remove = replaced_job_gear[item_path]
		if(!isnum(amount_to_remove))
			amount_to_remove = 1
		for(var/i in 1 to amount_to_remove)
			remove_loadout_backpack_content(outfit, item_path)

/proc/remove_loadout_backpack_content(datum/outfit/outfit, item_path)
	if(!length(outfit.backpack_contents))
		return

	var/current_amount = outfit.backpack_contents[item_path]
	if(isnum(current_amount))
		if(current_amount > 1)
			outfit.backpack_contents[item_path] = current_amount - 1
		else
			outfit.backpack_contents -= item_path
	else
		outfit.backpack_contents -= item_path

	if(!length(outfit.backpack_contents))
		outfit.backpack_contents = null

/mob/living/carbon/human/proc/equip_spare_equipment_box(obj/item/storage/box/loadout_job_gear/spare_equipment_box, list/replaced_job_gear)
	if(length(replaced_job_gear) && (isnull(spare_equipment_box) || QDELETED(spare_equipment_box)))
		spare_equipment_box = new(drop_location())

	for(var/item_path in replaced_job_gear)
		if(!ispath(item_path, /obj/item))
			continue
		var/amount_to_create = replaced_job_gear[item_path]
		if(!isnum(amount_to_create))
			amount_to_create = 1
		for(var/i in 1 to amount_to_create)
			SSwardrobe.provide_type(item_path, spare_equipment_box)

	if(isnull(spare_equipment_box) || QDELETED(spare_equipment_box))
		return null

	if(!length(spare_equipment_box.contents))
		qdel(spare_equipment_box)
		return null

	if(equip_to_storage(spare_equipment_box, ITEM_SLOT_BACK, indirect_action = TRUE))
		return spare_equipment_box

	if(put_in_hands_no_sleep(spare_equipment_box))
		return spare_equipment_box

	if(back)
		spare_equipment_box.forceMove(back)
		return spare_equipment_box

	spare_equipment_box.forceMove(drop_location())
	return spare_equipment_box

// cyborgs can wear hats from loadout
/*
 * Actually equip our mob with our job outfit and our loadout items.
 * Loadout items override the pre-existing item in the corresponding slot of the job outfit.
 * Some job items are preserved after being overridden - belt items, ear items, and glasses.
 * The rest of the slots, the items are overridden completely and deleted.
 *
 * Plasmamen are snowflaked to not have any envirosuit pieces removed just in case.
 * Their loadout items for those slots will be added to their backpack on spawn.
 *
 * outfit - the job outfit we're equipping
 * visuals_only - whether we call special equipped procs, or if we just look like we equipped it
 * preference_source - the preferences of the thing we're equipping
 * equipping_job - The job that's being applied.
 */
/mob/living/silicon/robot/proc/equip_outfit_and_loadout(datum/outfit/outfit, datum/preferences/preference_source = GLOB.preference_entries_by_key[ckey], visuals_only = FALSE, datum/job/equipping_job)
	if(!preference_source)
		return

	var/list/loadout_datums = loadout_list_to_datums(get_active_loadout_list(preference_source))
	for (var/datum/loadout_item/head/item in loadout_datums)
		if (!item.can_be_applied_to(src, preference_source, equipping_job, visuals_only))
			continue
		place_on_head(new item.item_path)
		break


/*
 * Removes all invalid paths from loadout lists.
 *
 * passed_list - the loadout list we're sanitizing.
 *
 * returns a list
 */
/proc/update_loadout_list(list/passed_list)
	RETURN_TYPE(/list)

	var/list/list_to_update = LAZYLISTDUPLICATE(passed_list)
	for(var/thing in list_to_update) //thing, 'cause it could be a lot of things
		if(ispath(thing))
			break
		var/our_path = text2path(list_to_update[thing])

		LAZYREMOVE(list_to_update, thing)
		if(ispath(our_path))
			LAZYSET(list_to_update, our_path, list())

	return list_to_update

/*
 * Removes all invalid paths from loadout lists.
 *
 * passed_list - the loadout list we're sanitizing.
 *
 * returns a list
 */
/proc/sanitize_loadout_list(list/passed_list)
	RETURN_TYPE(/list)

	var/list/list_to_clean = LAZYLISTDUPLICATE(passed_list)
	for(var/path in list_to_clean)
		if(!ispath(path))
			stack_trace("invalid path found in loadout list! (Path: [path])")
			LAZYREMOVE(list_to_clean, path)

		else if(!(path in GLOB.all_loadout_datums))
			stack_trace("invalid loadout slot found in loadout list! Path: [path]")
			LAZYREMOVE(list_to_clean, path)

	return list_to_clean

/obj/item/storage/briefcase/empty/PopulateContents()
	return

// Cyborg loadouts (currently used for hats)
/mob/living/silicon/robot/on_job_equipping(datum/job/equipping, client/player_client)
	. = ..()
	dress_up_as_job(
		equipping = equipping,
		visual_only = FALSE,
		player_client = player_client,
		consistent = FALSE,
	)

// Cyborg loadouts (currently used for hats)
/mob/living/silicon/robot/dress_up_as_job(datum/job/equipping, visual_only = FALSE, client/player_client, consistent = FALSE)
	. = ..()
	equip_outfit_and_loadout(equipping.get_outfit(consistent), player_client?.prefs, visual_only, equipping)

// originally made as a workaround the fact borgs lose their hats on module change, this
// is how borgs can pick up and drop hats

// if a borg clicks a hat, they try to put it on
/obj/item/clothing/head/attack_robot_secondary(mob/living/silicon/robot/user, list/modifiers)
	. = ..()
	if (. != SECONDARY_ATTACK_CALL_NORMAL)
		return

	if (!Adjacent(user))
		return

	balloon_alert(user, "picking up hat...")
	if (!do_after(user, 3 SECONDS, src))
		return
	if (QDELETED(src) || !Adjacent(user) || user.incapacitated)
		return
	user.place_on_head(src)
	balloon_alert(user, "picked up hat")

// if a borg right clicks themself, they try to drop their hat
/mob/living/silicon/robot/attack_robot_secondary(mob/user, list/modifiers)
	. = ..()
	if (. != SECONDARY_ATTACK_CALL_NORMAL)
		return

	if (user != src || isnull(hat))
		return

	balloon_alert(user, "dropping hat...")
	if (!do_after(user, 3 SECONDS, src))
		return
	if (QDELETED(src) || !Adjacent(user) || user.incapacitated || isnull(hat))
		return
	hat.forceMove(get_turf(src))
	hat = null
	update_icons()
	balloon_alert(user, "dropped hat")
