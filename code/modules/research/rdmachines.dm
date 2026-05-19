//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.

/obj/machinery/rnd
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = TRUE
	use_power = IDLE_POWER_USE

	///Are we currently printing a machine
	var/busy = FALSE
	///Is this machne hacked via wires
	var/hacked = FALSE
	///Is this machine disabled via wires
	var/disabled = FALSE
	///Ref to global science techweb.
	var/datum/techweb/stored_research
	///The item loaded inside the machine, used by experimentors and destructive analyzers only.
	var/obj/item/loaded_item
	/// Whether this machine should automatically connect to a nearby R&D server on init.
	var/auto_connect_to_techweb = TRUE
	/// Whether this machine requires alt-click with a linked multitool to connect to a techweb.
	var/manual_techweb_link_requires_alt = FALSE

/obj/machinery/rnd/Initialize(mapload)
	. = ..()
	set_wires(new /datum/wires/rnd(src))
	register_context()

/obj/machinery/rnd/post_machine_initialize()
	. = ..()
	if(auto_connect_to_techweb && !CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		CONNECT_TO_RND_SERVER_ROUNDSTART(stored_research, src)
	if(stored_research)
		on_connected_techweb()

/obj/machinery/rnd/on_construction(mob/user)
	. = ..()
	apply_machine_circuit_configuration()
	if(!auto_connect_to_techweb)
		connect_techweb(null)

/obj/machinery/rnd/Destroy()
	if(stored_research)
		log_research("[src] disconnected from techweb [stored_research] (destroyed).")
		stored_research = null
	return ..()

/obj/machinery/rnd/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return

	. += span_notice("A [EXAMINE_HINT("multitool")] with techweb designs can be uploaded here.")
	if(manual_techweb_link_requires_alt)
		. += span_notice("Use [EXAMINE_HINT("Alt-click")] with a linked multitool to connect this machine to a techweb.")
	if(!stored_research)
		. += span_warning(get_techweb_link_notice())
	. += span_notice("Its maintenance panel can be [EXAMINE_HINT("screwed")] [panel_open ? "closed" : "open"].")
	if(panel_open)
		. += span_notice("Use a [EXAMINE_HINT("multitool")] or [EXAMINE_HINT("wirecutters")] to interact with wires.")
		. += span_notice("The machine can be [EXAMINE_HINT("pried")] apart.")

/obj/machinery/rnd/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		return

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] Panel"
		context[SCREENTIP_CONTEXT_RMB] = "[panel_open ? "Close" : "Open"] Panel"
		return CONTEXTUAL_SCREENTIP_SET

	if(panel_open)
		var/msg
		if(held_item.tool_behaviour == TOOL_CROWBAR)
			msg = "Deconstruct"
		else if(is_wire_tool(held_item))
			msg = "Open Wires"

		if(msg)
			context[SCREENTIP_CONTEXT_LMB] = msg
			context[SCREENTIP_CONTEXT_RMB] = msg
			return CONTEXTUAL_SCREENTIP_SET
	else
		if(held_item.tool_behaviour == TOOL_MULTITOOL)
			var/obj/item/multitool/tool = held_item.get_proxy_attacker_for(src, user)
			if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
				if(manual_techweb_link_requires_alt)
					context[SCREENTIP_CONTEXT_ALT_LMB] = "Link Techweb"
				else
					context[SCREENTIP_CONTEXT_LMB] = "Upload Techweb"
					context[SCREENTIP_CONTEXT_RMB] = "Upload Techweb"
				return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/rnd/proc/apply_machine_circuit_configuration()
	var/obj/item/circuitboard/machine/board = circuit
	if(!istype(board))
		return

	auto_connect_to_techweb = board.techweb_link_on_init
	manual_techweb_link_requires_alt = board.techweb_link_via_alt_click

	if(board.machine_name_override)
		name = board.machine_name_override
	if(board.machine_desc_override)
		desc = board.machine_desc_override
	if(!isnull(board.machine_req_access_override))
		req_access = board.machine_req_access_override.Copy()

	if(istype(src, /obj/machinery/rnd/production))
		var/obj/machinery/rnd/production/production_machine = src
		if(board.override_allowed_department_flags)
			production_machine.allowed_department_flags = board.allowed_department_flags_override

/obj/machinery/rnd/proc/get_multitool_techweb(obj/item/multitool/tool)
	if(isnull(tool) || QDELETED(tool.buffer) || !istype(tool.buffer, /datum/techweb))
		return null
	return tool.buffer

/obj/machinery/rnd/proc/try_alt_multitool_link(mob/living/user)
	if(!manual_techweb_link_requires_alt)
		return FALSE

	var/obj/item/multitool/tool = user.get_active_held_item()
	var/datum/techweb/new_techweb = get_multitool_techweb(tool)
	if(!new_techweb)
		return FALSE

	connect_techweb(new_techweb)
	balloon_alert(user, "techweb linked")
	return TRUE

///Called when attempting to connect the machine to a techweb, forgetting the old.
/obj/machinery/rnd/proc/connect_techweb(datum/techweb/new_techweb)
	if(stored_research == new_techweb)
		return
	if(stored_research)
		log_research("[src] disconnected from techweb [stored_research] when connected to [new_techweb].")
	stored_research = new_techweb
	if(!isnull(stored_research))
		on_connected_techweb()

/obj/machinery/rnd/proc/get_techweb_link_notice()
	if(manual_techweb_link_requires_alt)
		return "This machine is not linked to an R&D server. Alt-click it with a multitool linked to an R&D server first."
	return "This machine is not linked to an R&D server and cannot print designs."

/obj/machinery/rnd/proc/notify_missing_techweb_link(mob/user)
	var/message = get_techweb_link_notice()
	if(user)
		balloon_alert(user, "link R&D server first")
		to_chat(user, span_warning(message))
	else
		say(message)
	return FALSE

///Called post-connection to a new techweb.
/obj/machinery/rnd/proc/on_connected_techweb()
	SHOULD_CALL_PARENT(FALSE)

///Reset the state of this machine
/obj/machinery/rnd/proc/reset_busy()
	busy = FALSE

/obj/machinery/rnd/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/rnd/crowbar_act_secondary(mob/living/user, obj/item/tool)
	return crowbar_act(user, tool)

/obj/machinery/rnd/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "[initial(icon_state)]_t", initial(icon_state), tool)

/obj/machinery/rnd/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	return screwdriver_act(user, tool)

/obj/machinery/rnd/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(panel_open)
		wires.interact(user)
		return ITEM_INTERACT_SUCCESS
	var/datum/techweb/new_techweb = get_multitool_techweb(tool)
	if(new_techweb)
		if(manual_techweb_link_requires_alt)
			balloon_alert(user, "alt-click to link")
			return ITEM_INTERACT_BLOCKING
		connect_techweb(new_techweb)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/rnd/multitool_act_secondary(mob/living/user, obj/item/tool)
	return multitool_act(user, tool)

/obj/machinery/rnd/click_alt(mob/user)
	if(isliving(user) && try_alt_multitool_link(user))
		return CLICK_ACTION_SUCCESS
	return ..()

/obj/machinery/rnd/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(panel_open)
		wires.interact(user)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/rnd/wirecutter_act_secondary(mob/living/user, obj/item/tool)
	return wirecutter_act(user, tool)

//whether the machine can have an item inserted in its current state.
/obj/machinery/rnd/proc/is_insertion_ready(mob/user)
	if(panel_open)
		balloon_alert(user, "panel open!")
		return FALSE
	if(disabled)
		balloon_alert(user, "belts disabled!")
		return FALSE
	if(busy)
		balloon_alert(user, "still busy!")
		return FALSE
	if(machine_stat & BROKEN)
		balloon_alert(user, "machine broken!")
		return FALSE
	if(machine_stat & NOPOWER)
		balloon_alert(user, "no power!")
		return FALSE
	if(loaded_item)
		balloon_alert(user, "item already loaded!")
		return FALSE
	return TRUE

//we eject the loaded item when deconstructing the machine
/obj/machinery/rnd/on_deconstruction(disassembled)
	if(loaded_item)
		loaded_item.forceMove(drop_location())
	..()
