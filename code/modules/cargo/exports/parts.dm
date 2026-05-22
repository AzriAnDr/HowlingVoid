// Circuit boards, spare parts, etc.

/datum/export/solar_assembly
	cost = CARGO_CRATE_VALUE * 0.25
	unit_name = "solar panel assembly"
	export_types = list(/obj/item/solar_assembly)

/datum/export/tracker_board
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "solar tracker board"
	export_types = list(/obj/item/electronics/tracker)

/datum/export/control_board
	cost = CARGO_CRATE_VALUE * 0.75
	unit_name = "solar panel control board"
	export_types = list(/obj/item/circuitboard/computer/solar_control)

//Data Disks
/datum/export/advanced_disk
	cost = CARGO_CRATE_VALUE * 0.4
	unit_name = "advanced data disk"
	export_types = list(/obj/item/disk/computer/advanced)
	include_subtypes = FALSE

/datum/export/super_disk
	cost = CARGO_CRATE_VALUE * 0.6
	unit_name = "super data disk"
	export_types = list(/obj/item/disk/computer/super)
	include_subtypes = FALSE

/datum/export/standard_disk
	cost = CARGO_CRATE_VALUE * 0.2
	unit_name = "data disk"
	export_types = list(/obj/item/disk/computer)
	include_subtypes = TRUE

/datum/export/reformatted_technology_disk
	cost = CARGO_CRATE_VALUE * 5
	unit_name = "reformatted technology disk"
	export_types = list(/obj/item/disk/design_disk/bepis/remove_tech)
	include_subtypes = FALSE
	allow_negative_cost = TRUE

/datum/export/reformatted_technology_disk/get_base_cost(obj/item/disk/design_disk/bepis/remove_tech/sold_disk)
	return sold_disk.rnd_console_inserted ? 0 : ..()

/datum/export/reformatted_technology_disk/applies_to(obj/item/disk/design_disk/bepis/remove_tech/exported_item, apply_elastic = TRUE, export_markets)
	for(var/found_market in export_markets)
		if(!is_type_in_typecache(exported_item, export_types))
			continue
		if(found_market != sales_market)
			continue
		if(exported_item.flags_1 & HOLOGRAM_1)
			continue
		return TRUE

/datum/export/reformatted_technology_disk/total_printout(datum/export_report/ex, notes = TRUE)
	if(!ex.total_amount[src])
		return ""
	if(ex.total_value[src])
		return ..()

	var/total_amount = ex.total_amount[src]
	return "0 [MONEY_NAME]: Received [total_amount] [unit_name][total_amount > 1 ? plural_s(unit_name) : ""]."

/datum/export/refill_canister
	cost = CARGO_CRATE_VALUE * 0.5 //If someone want to make this worth more as it empties, go ahead
	unit_name = "vending refill canister"
	export_types = list(/obj/item/vending_refill)

/datum/export/refill_canister/total_printout(datum/export_report/ex, notes = TRUE)
	. = ..()
	if(. && notes)
		. += " Thank you for restocking the station!"
