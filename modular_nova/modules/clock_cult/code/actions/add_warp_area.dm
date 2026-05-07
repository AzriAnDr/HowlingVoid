/// How many areas observation consoles are able to warp to at the start.
#define STARTING_WARP_AREAS 8
/// How much vitality each already marked area adds to the cost.
#define COST_PER_AREA 4

/datum/action/innate/clockcult/add_warp_area
	name = "Add Warp Area"
	desc = "Add an additional area observation consoles can warp to."
	button_icon_state = "Spatial Warp"
	var/static/list/cached_addable_areas
	var/static/list/blocked_areas = typecacheof(list(/area/station/service/chapel, /area/station/ai))
	var/static/list/costly_areas = typecacheof(list(/area/station/command, /area/station/security))

/datum/action/innate/clockcult/add_warp_area/New(Target)
	. = ..()
	if(isnull(cached_addable_areas))
		build_addable_areas()
		choose_starting_warp_areas()

/datum/action/innate/clockcult/add_warp_area/IsAvailable(feedback)
	if(!IS_CLOCK(owner))
		return FALSE
	return ..()

/datum/action/innate/clockcult/add_warp_area/Activate()
	if(!length(cached_addable_areas))
		return

	var/area/input_area = tgui_input_list(owner, "Select an area to add.", "Add Area", cached_addable_areas)
	if(!input_area)
		return

	var/cost = max((length(GLOB.clock_marked_areas) * COST_PER_AREA) - (STARTING_WARP_AREAS * COST_PER_AREA), 0)
	if(is_type_in_typecache(input_area.type, costly_areas))
		cost *= 2

	if(tgui_alert(owner, "Are you sure you want to add [input_area]? It will cost [cost] vitality.", "Add Area", list("Yes", "No")) != "Yes")
		return

	if(GLOB.clock_vitality < cost)
		to_chat(owner, span_brass("Not enough vitality."))
		return

	if(GLOB.clock_marked_areas[input_area])
		return

	GLOB.clock_marked_areas[input_area] = TRUE
	GLOB.clock_vitality -= cost
	cached_addable_areas -= input_area
	send_clock_message("[input_area] added to warpable areas.")

/datum/action/innate/clockcult/add_warp_area/proc/choose_starting_warp_areas()
	if(!length(cached_addable_areas))
		return

	var/sanity = 0
	var/added_areas = 0
	var/list/temp_list = cached_addable_areas.Copy()
	while(added_areas < STARTING_WARP_AREAS && sanity < 100 && length(temp_list))
		sanity++
		var/area/picked_area = pick(temp_list)
		temp_list -= picked_area
		if(is_type_in_typecache(picked_area.type, costly_areas))
			continue

		added_areas++
		GLOB.clock_marked_areas[picked_area] = TRUE
		cached_addable_areas -= picked_area

/datum/action/innate/clockcult/add_warp_area/proc/build_addable_areas()
	cached_addable_areas = list()
	for(var/area_type as anything in GLOB.the_station_areas)
		var/area/station_area = GLOB.areas_by_type[area_type]
		if(!station_area || station_area.outdoors || (station_area.area_flags & NOTELEPORT) || is_type_in_typecache(station_area.type, blocked_areas) || GLOB.clock_marked_areas[station_area])
			continue
		cached_addable_areas += station_area

/datum/action/innate/clockcult/show_warpable_areas
	name = "Warpable Areas"
	desc = "Display what areas are currently warpable to by observation consoles."
	button_icon_state = "console_info"

/datum/action/innate/clockcult/show_warpable_areas/Activate()
	to_chat(owner, boxed_message(span_brass("Current areas observation consoles can warp to: [english_list(GLOB.clock_marked_areas)] <br/>You can add additional areas with the \"Add Warp Area\" action.")))

#undef STARTING_WARP_AREAS
#undef COST_PER_AREA
