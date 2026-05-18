/**
 * # Loadout categories
 *
 * Loadout categories are singletons used to group loadout items together in the loadout screen.
 */
/datum/loadout_category
	/// The name of the category, shown in the tabs
	var/category_name
	/// FontAwesome icon for the category
	var/category_ui_icon
	/// String to display on the top-right of a category tab
	var/category_info
	/// Order which they appear in the tabs, ties go alphabetically
	var/tab_order = -1
	/// What type of loadout items should be generated for this category?
	var/type_to_generate
	/// List of all loadout items in this category
	VAR_FINAL/list/datum/loadout_item/associated_items

/datum/loadout_category/New()
	. = ..()
	associated_items = get_items()
	for(var/i = associated_items.len, i >= 1, i--)
		var/datum/loadout_item/item = associated_items[i]
		if(!ispath(item?.item_path, /obj/item))
			associated_items.Cut(i, i + 1)
			if(item)
				qdel(item, force = TRUE)
			continue

		if(GLOB.all_loadout_datums[item.item_path])
			var/datum/loadout_item/existing_item = GLOB.all_loadout_datums[item.item_path]
			stack_trace("Duplicate loadout item_path [item.item_path] for [item.type] in [type]. Already registered by [existing_item?.type] in [existing_item?.category?.type]. Ignoring duplicate entry.")
			associated_items.Cut(i, i + 1)
			qdel(item, force = TRUE)
			continue

		GLOB.all_loadout_datums[item.item_path] = item

/datum/loadout_category/Destroy(force, ...)
	if(!force)
		stack_trace("QDEL called on loadout category [type]. This shouldn't ever happen. (Use FORCE if necessary.)")
		return QDEL_HINT_LETMELIVE

	associated_items.Cut()
	return ..()

/// Return a list of all /datum/loadout_items in this category.
/datum/loadout_category/proc/get_items() as /list
	var/list/all_items = list()
	var/list/handled_manifest_ids = list()
	for(var/datum/loadout_item/found_type as anything in typesof(type_to_generate))
		var/manifest_id = "[found_type]"
		var/list/manifest_entry = get_loadout_manifest_entry(manifest_id)
		if(manifest_entry)
			handled_manifest_ids[manifest_id] = TRUE

		var/abstract_type = initial(found_type.abstract_type)
		if(manifest_entry && manifest_entry["abstract_type"])
			abstract_type = loadout_manifest_json_to_typepath(manifest_entry["abstract_type"], /datum/loadout_item) || abstract_type

		if(found_type == abstract_type)
			continue

		var/item_path = initial(found_type.item_path)
		if(manifest_entry && manifest_entry["item_path"])
			item_path = loadout_manifest_json_to_typepath(manifest_entry["item_path"], /obj/item)

		if(!ispath(item_path, /obj/item))
			continue

		var/datum/loadout_item/spawned_type = manifest_entry ? new found_type(src, manifest_entry, manifest_id) : new found_type(src)
		if(!ispath(spawned_type?.item_path, /obj/item))
			if(spawned_type)
				qdel(spawned_type, force = TRUE)
			continue

		// Let's sanitize in case somebody inserted the player's byond name instead of ckey in canonical form
		if(spawned_type.ckeywhitelist)
			for (var/i = 1, i <= length(spawned_type.ckeywhitelist), i++)
				spawned_type.ckeywhitelist[i] = ckey(spawned_type.ckeywhitelist[i])

		all_items += spawned_type

	for(var/list/manifest_entry as anything in ensure_loadout_manifest_entries())
		var/manifest_id = "[manifest_entry["id"]]"
		if(handled_manifest_ids[manifest_id])
			continue

		var/template_type = loadout_manifest_json_to_typepath(manifest_entry["template_type"], /datum/loadout_item)
		if(!ispath(template_type, type_to_generate))
			continue

		var/datum/loadout_item/manifest_item = new template_type(src, manifest_entry, manifest_entry["id"])
		if(!ispath(manifest_item.item_path, /obj/item))
			qdel(manifest_item, force = TRUE)
			continue

		if(manifest_item.ckeywhitelist)
			for(var/i = 1, i <= length(manifest_item.ckeywhitelist), i++)
				manifest_item.ckeywhitelist[i] = ckey(manifest_item.ckeywhitelist[i])

		all_items += manifest_item

	return all_items

/// Returns a list of all /datum/loadout_items in this category, formatted for UI use. Only ran once.
/datum/loadout_category/proc/items_to_ui_data() as /list
	if(!length(associated_items))
		return list()

	var/list/formatted_list = list()

	for(var/datum/loadout_item/item as anything in associated_items)
		if(item.is_disabled())
			continue

		var/list/item_data = item.to_ui_data()
		UNTYPED_LIST_ADD(formatted_list, item_data)

	sortTim(formatted_list, /proc/cmp_assoc_list_name) // Alphabetizing
	return formatted_list

/**
 * Handles what happens when two items of this category are selected at once
 *
 * Return TRUE if it's okay to continue with adding the incoming item,
 * or return FALSE to stop the new item from being added
 */
/datum/loadout_category/proc/handle_duplicate_entires(
	datum/preference_middleware/loadout/manager,
	datum/loadout_item/conflicting_item,
	datum/loadout_item/added_item,
	list/datum/loadout_item/all_loadout_items,
)
	manager.deselect_item(conflicting_item)
	return TRUE
