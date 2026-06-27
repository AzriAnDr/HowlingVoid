#define EXPRESS_EMAG_DISCOUNT 0.72
#define EXPRESS_PERSONAL_MARKUP 1.3
#define BEACON_PRINT_COOLDOWN 10 SECONDS

/obj/machinery/computer/cargo/express
	name = "express supply console"
	desc = "This console allows the user to purchase a package \
		with 1/40th of the delivery time: made possible by Nanotrasen's new \"1500mm Orbital Railgun\".\
		All sales are near instantaneous - please choose carefully"
	icon_screen = "supply_express"
	circuit = /obj/item/circuitboard/computer/cargo/express
	blockade_warning = "Bluespace instability detected. Delivery impossible."
	req_access = list(ACCESS_CARGO)
	is_express = TRUE
	interface_type = "CargoExpress"

	var/message
	var/list/meme_pack_data
	/// The linked supplypod beacon
	var/obj/item/supplypod_beacon/beacon
	/// The budget account manually linked by swiping the matching budget card.
	var/datum/bank_account/department/bound_budget_account
	/// If TRUE, department purchases require a manually linked budget card.
	var/require_budget_card = TRUE
	/// Where we droppin boys
	var/area/landingzone = /area/station/cargo/storage
	var/pod_type = /obj/structure/closet/supplypod
	/// If this console is locked and needs to be unlocked with an ID
	var/locked = TRUE
	/// Is the console in beacon mode? Exists to let beacon know when a pod may come in
	var/using_beacon = FALSE
	/// Number of beacons printed. Used to determine beacon names.
	var/static/printed_beacons = 0
	/// Cooldown to prevent beacon spam
	COOLDOWN_DECLARE(beacon_print_cooldown)

/obj/machinery/computer/cargo/express/Initialize(mapload)
	. = ..()
	packin_up()
	landingzone = GLOB.areas_by_type[landingzone]
	if (isnull(landingzone))
		WARNING("[src] couldnt find a Quartermaster/Storage (aka cargobay) area on the station, and as such it has set the supplypod landingzone to the area it resides in.")
		landingzone = get_area(src)

/obj/machinery/computer/cargo/express/on_construction(mob/user)
	. = ..()
	packin_up()

/obj/machinery/computer/cargo/express/Destroy()
	if(beacon)
		beacon.unlink_console()
	bound_budget_account = null
	return ..()

/obj/machinery/computer/cargo/express/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(require_budget_card && istype(tool, /obj/item/card/id/departmental_budget/car))
		var/obj/item/card/id/departmental_budget/budget_card = tool
		var/datum/bank_account/department/cargo_budget = SSeconomy.get_dep_account(cargo_account)
		if(isnull(cargo_budget) || budget_card.registered_account != cargo_budget)
			balloon_alert(user, "wrong budget card!")
			return ITEM_INTERACT_BLOCKING

		if(bound_budget_account == cargo_budget)
			bound_budget_account = null
			balloon_alert(user, "budget unlinked")
		else
			bound_budget_account = cargo_budget
			balloon_alert(user, "budget linked")
		SStgui.update_uis(src)
		return ITEM_INTERACT_SUCCESS

	if (tool.GetID() && allowed(user))
		locked = !locked
		to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the interface."))
		return ITEM_INTERACT_SUCCESS

	if (istype(tool, /obj/item/disk/cargo/bluespace_pod))
		if (pod_type == /obj/structure/closet/supplypod/bluespacepod)
			balloon_alert(user, "already upgraded!")
			return ITEM_INTERACT_FAILURE
		if(!user.temporarilyRemoveItemFromInventory(tool))
			return ITEM_INTERACT_FAILURE
		pod_type = /obj/structure/closet/supplypod/bluespacepod // doesnt affect our circuit board, making reversal possible
		to_chat(user, span_notice("You insert the disk into [src], allowing for advanced supply delivery vehicles."))
		tool.forceMove(src)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/supplypod_beacon))
		var/obj/item/supplypod_beacon/beacon = tool
		if (beacon.express_console != src)
			beacon.link_console(src, user)
			return ITEM_INTERACT_SUCCESS

		to_chat(user, span_alert("[src] is already linked to [beacon]."))
		return ITEM_INTERACT_FAILURE

	return NONE

/obj/machinery/computer/cargo/express/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	if(user)
		if (emag_card)
			user.visible_message(span_warning("[user] swipes [emag_card] through [src]!"))
		to_chat(user, span_notice("You change the routing protocols, allowing the Supply Pod to land anywhere on the station."))
	obj_flags |= EMAGGED
	contraband = TRUE
	// This also sets this on the circuit board
	var/obj/item/circuitboard/computer/cargo/board = circuit
	board.obj_flags |= EMAGGED
	board.contraband = TRUE
	packin_up()
	return TRUE

/obj/machinery/computer/cargo/express/proc/packin_up(forced = FALSE) // oh shit, I'm sorry
	meme_pack_data = list() // sorry for what?
	if(!forced && !SSshuttle.initialized) // our quartermaster taught us not to be ashamed of our supply packs
		SSshuttle.express_consoles += src // specially since they're such a good price and all
		return // yeah, I see that, your quartermaster gave you good advice
	// it gets cheaper when I return it
	for(var/pack_id in SSshuttle.supply_packs) // mmhm
		var/datum/supply_pack/pack = SSshuttle.supply_packs[pack_id] // sometimes, I return it so much, I rip the manifest
		if(!meme_pack_data[pack.group]) // see, my quartermaster taught me a few things too
			meme_pack_data[pack.group] = list( // like, how not to rip the manifest
				"name" = pack.group, // by using someone else's crate
				"packs" = get_packs_data(pack.group, express = TRUE), // will you show me?
			) // i'd be right happy to

/obj/machinery/computer/cargo/express/proc/get_budget_account()
	if(!require_budget_card)
		return SSeconomy.get_dep_account(cargo_account)
	if(QDELETED(bound_budget_account))
		bound_budget_account = null
	return bound_budget_account

/obj/machinery/computer/cargo/express/proc/get_user_id(mob/user)
	if(!isliving(user))
		return null
	var/mob/living/living_user = user
	return living_user.get_idcard(TRUE)

/obj/machinery/computer/cargo/express/proc/get_express_pack_cost(datum/supply_pack/pack, personal_purchase = FALSE)
	. = pack.get_cost() * get_discount()
	if(personal_purchase)
		. *= EXPRESS_PERSONAL_MARKUP
	return round(.)

/obj/machinery/computer/cargo/express/ui_data(mob/user)
	var/canBeacon = beacon && (isturf(beacon.loc) || ismob(beacon.loc))//is the beacon in a valid location?
	var/list/data = list()
	var/datum/bank_account/budget_account = get_budget_account()
	var/obj/item/card/id/id_card = get_user_id(user)
	var/datum/bank_account/display_account = self_paid ? id_card?.registered_account : budget_account
	data["points"] = display_account?.account_balance || 0
	data["budgetName"] = display_account?.account_holder || (self_paid ? "No ID detected" : "No budget linked")
	data["budgetLinked"] = !isnull(budget_account)
	data["locked"] = locked//swipe an ID to unlock
	data["siliconUser"] = HAS_SILICON_ACCESS(user)
	data["beaconzone"] = beacon ? get_area(beacon) : ""//where is the beacon located? outputs in the tgui
	data["using_beacon"] = using_beacon //is the mode set to deliver to the beacon or the cargobay?
	data["canBeacon"] = !using_beacon || canBeacon //is the mode set to beacon delivery, and is the beacon in a valid location?
	data["canBuyBeacon"] = !self_paid && COOLDOWN_FINISHED(src, beacon_print_cooldown) && !isnull(budget_account) && budget_account.account_balance >= BEACON_COST
	data["beaconError"] = using_beacon && !canBeacon ? "(BEACON ERROR)" : ""//changes button text to include an error alert if necessary
	data["hasBeacon"] = beacon != null//is there a linked beacon?
	data["beaconName"] = beacon ? beacon.name : "No Beacon Found"
	data["printMsg"] = COOLDOWN_FINISHED(src, beacon_print_cooldown) ? "Print Beacon for [BEACON_COST] [MONEY_NAME]" : "Print Beacon for [BEACON_COST] [MONEY_NAME] ([COOLDOWN_TIMELEFT(src, beacon_print_cooldown)])" //buttontext for printing beacons
	data["self_paid"] = self_paid
	data["private_price_multiplier"] = EXPRESS_PERSONAL_MARKUP
	data["displayed_currency_name"] = " [MONEY_SYMBOL]"
	data["displayed_currency_full_name"] = " [MONEY_NAME]"
	data["max_order"] = CARGO_MAX_ORDER
	data["cart"] = list()
	data["supplies"] = list()
	message = "Sales are near-instantaneous - please choose carefully."
	if(SSshuttle.supply_blocked)
		message = blockade_warning
	if(!self_paid && require_budget_card && isnull(budget_account))
		message = "Cargo budget not linked. Swipe a Cargo Budget card to enable department purchases."
	if(using_beacon && !beacon)
		message = "BEACON ERROR: BEACON MISSING"//beacon was destroyed
	else if (using_beacon && !canBeacon)
		message = "BEACON ERROR: MUST BE EXPOSED"//beacon's loc/user's loc must be a turf
	if(obj_flags & EMAGGED)
		message = "(&!#@ERROR: R0UTING_#PRO7O&OL MALF(*CT#ON. $UG%ESTE@ ACT#0N: !^/PULS3-%E)ET CIR*)ITB%ARD."
	data["message"] = message
	if(!meme_pack_data)
		packin_up()
		stack_trace("There was no pack data for [src]")
	data["supplies"] = meme_pack_data
	return data

/obj/machinery/computer/cargo/express/get_discount()
	return (obj_flags & EMAGGED) ? EXPRESS_EMAG_DISCOUNT : 1

/obj/machinery/computer/cargo/express/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("LZCargo")
			using_beacon = FALSE
			if (beacon)
				beacon.update_status(SP_UNREADY) //ready light on beacon will turn off
		if("LZBeacon")
			using_beacon = TRUE
			if (beacon)
				beacon.update_status(SP_READY) //turns on the beacon's ready light
		if("printBeacon")
			var/datum/bank_account/account = get_budget_account()
			if(isnull(account) || !account.adjust_money(-BEACON_COST))
				return

			// a ~ten second cooldown for printing beacons to prevent spam
			COOLDOWN_START(src, beacon_print_cooldown, BEACON_PRINT_COOLDOWN)
			var/obj/item/supplypod_beacon/new_beacon = new /obj/item/supplypod_beacon(drop_location())
			new_beacon.link_console(src, user) //rather than in beacon's Initialize(), we can assign the computer to the beacon by reusing this proc)
			printed_beacons++ //printed_beacons starts at 0, so the first one out will be called beacon # 1
			beacon.name = "Supply Pod Beacon #[printed_beacons]"
		if("toggleprivate")
			self_paid = !self_paid
			return TRUE

		if("add")//Generate Supply Order first
			if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_EXPRESSPOD_CONSOLE))
				say("Railgun recalibrating. Stand by.")
				return
			var/id = params["id"]
			id = text2path(id) || id
			var/datum/supply_pack/pack = SSshuttle.supply_packs[id]

			if(!istype(pack))
				CRASH("Unknown supply pack id given by express order console ui. ID: [params["id"]]")

			/* NOVA EDIT REMOVAL BEGIN - We use the goody system for imports, so we remove this block in order to let cargo and ghost roles to get imports
			if((pack.order_flags & ORDER_GOODY) && !self_paid && !(obj_flags & EMAGGED))
				playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 50, FALSE)
				say("ERROR: Small crates may only be purchased by private accounts.")
				return
			*/ // NOVA EDIT REMOVAL END

			var/name = "*None Provided*"
			var/rank = "*None Provided*"
			var/ckey = user.ckey
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				name = H.get_authentification_name()
				rank = H.get_assignment(hand_first = TRUE)
			else if(HAS_SILICON_ACCESS(user))
				name = user.real_name
				rank = "Silicon"
			var/reason = ""
			var/datum/supply_order/order = new(pack, name, rank, ckey, reason)
			var/datum/bank_account/account
			if(self_paid)
				var/obj/item/card/id/id_card = get_user_id(user)
				if(!istype(id_card))
					say("No ID card detected.")
					return
				if(IS_DEPARTMENTAL_CARD(id_card))
					say("The [src] rejects [id_card].")
					return
				account = id_card.registered_account
				if(!istype(account))
					say("Invalid bank account.")
					return

				var/bypass = istype(id_card, /obj/item/card/id/advanced/chameleon)
				if(corporate_economy_lacks_supply_pack_access(pack, id_card.GetAccess(), bypass))
					say("[id_card] lacks the requisite access for this purchase.")
					return
				order.paying_account = account
				order.private_purchase = TRUE
			else
				account = get_budget_account()
				if (isnull(account))
					say("No cargo budget card linked.")
					return

			if (obj_flags & EMAGGED)
				landingzone = GLOB.areas_by_type[pick(GLOB.the_station_areas)]


			var/list/empty_turfs
			if (!istype(beacon) || !using_beacon || (obj_flags & EMAGGED))
				empty_turfs = list()
				for(var/turf/open/floor/open_turf in landingzone.get_turfs_from_all_zlevels())
					if(!open_turf.is_blocked_turf())
						empty_turfs += open_turf

				if (!length(empty_turfs))
					return

			if (obj_flags & EMAGGED)
				var/emag_order_cost = get_express_pack_cost(order.pack, self_paid)
				if (account.account_balance < emag_order_cost)
					return

				TIMER_COOLDOWN_START(src, COOLDOWN_EXPRESSPOD_CONSOLE, 10 SECONDS)
				order.generateRequisition(get_turf(src))
				for(var/i in 1 to MAX_EMAG_ROCKETS)
					if (!account.adjust_money(-emag_order_cost, "Cargo Express: [order.pack.name]"))
						break

					var/turf/landing_turf = pick(empty_turfs)
					empty_turfs -= landing_turf
					if(pack.special_pod)
						new /obj/effect/pod_landingzone(landing_turf, pack.special_pod, order)
					else
						new /obj/effect/pod_landingzone(landing_turf, pod_type, order)

				update_appearance()
				return TRUE

			var/turf/landing_turf
			if (istype(beacon) && using_beacon)
				landing_turf = get_turf(beacon)
				beacon.update_status(SP_LAUNCH)
			else
				landing_turf = pick(empty_turfs)

			var/order_cost = get_express_pack_cost(order.pack, self_paid)
			if (!account.adjust_money(-order_cost, "Cargo Express: [order.pack.name]"))
				return
			if(self_paid)
				account.bank_card_talk("Cargo express order #[order.id] ([order.pack.name]) processed. [order_cost] [MONEY_NAME] have been charged to your bank account.")

			TIMER_COOLDOWN_START(src, COOLDOWN_EXPRESSPOD_CONSOLE, 5 SECONDS)
			if(pack.special_pod)
				new /obj/effect/pod_landingzone(landing_turf, pack.special_pod, order)
			else
				new /obj/effect/pod_landingzone(landing_turf, pod_type, order)

			update_appearance()
			return TRUE

#undef EXPRESS_EMAG_DISCOUNT
#undef EXPRESS_PERSONAL_MARKUP
#undef BEACON_PRINT_COOLDOWN


// BEGIN NOVA CORE MIGRATION: code/modules/cargo/expressconsole.dm
/obj/item/circuitboard/computer/cargo/express/ghost
	name = "Soar Industries Express Delivery Console"
	build_path = /obj/machinery/computer/cargo/express/ghost
	contraband = TRUE

/obj/machinery/computer/cargo/express/ghost
	name = "\improper Soar Industries Express Delivery Console"
	desc = "A Standard express delivery console, preloaded with a specialized protocol by SOAR Industries. Allowing it to access specialized companies."
	abstract_type = /obj/machinery/computer/cargo/express/ghost
	circuit = /obj/item/circuitboard/computer/cargo/express/ghost
	req_access = list(ACCESS_SYNDICATE)
	cargo_account = ACCOUNT_CIV /// Change this later to something else, as this is meant to prevent runtiming
	contraband = TRUE
	bypass_express_lock = TRUE
	require_budget_card = FALSE
	console_flag = CARGO_CONSOLE_PDA

	pod_type = /obj/structure/closet/supplypod/bluespacepod

/obj/machinery/computer/cargo/express/ghost/Initialize(mapload)
	. = ..()
	if(type == abstract_type) // These are not meant to be spawned
		return INITIALIZE_HINT_QDEL

/obj/machinery/computer/cargo/express/ghost/on_construction(mob/user)
	. = ..()
	/// Should report the player that built the console to the admins, in case anything fucky happens.
	message_admins("[ADMIN_LOOKUPFLW(usr)] Has built a ghost role express console ([src.name]) at [AREACOORD(src)].")

/obj/machinery/computer/cargo/express/ghost/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(user)
		to_chat(user, span_notice("You try to change the routing protocols, but the [src.name] displays a runtime error and reboots!"))
	return FALSE //never let this console be emagged

/obj/machinery/computer/cargo/express/ghost/ui_act(action, params, datum/tgui/ui)
	if(action == "add") // if we're generating a supply order
		if (!beacon || !using_beacon ) // checks if using a beacon or not.
			say("Error! Destination is not whitelisted, aborting.")
			return
	return ..()

//Interdyne Pharmaceuticals Console's console
/obj/item/circuitboard/computer/cargo/express/ghost/interdyne
	name = "Interdyne Express Supply Console"
	greyscale_colors = COLOR_RAINBOW_GREEN
	build_path = /obj/machinery/computer/cargo/express/ghost/interdyne

/obj/machinery/computer/cargo/express/ghost/interdyne
	name = "\improper Interdyne Express Supply Console"
	desc = "A specialized Interdyne Pharmaceuticals console, allowing for deepspace communication with a specialized drop pod railgun for precise and accurate \
		deliveries, no matter how remote they are located"
	circuit = /obj/item/circuitboard/computer/cargo/express/ghost/interdyne
	req_access = list(ACCESS_SYNDICATE)
	cargo_account = ACCOUNT_INT
	console_flag = CARGO_CONSOLE_INTERDYNE

//Deep Space 2's console
/obj/item/circuitboard/computer/cargo/express/ghost/syndicate
	name = "Syndicate Express Supply Console"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/computer/cargo/express/ghost/syndicate

/obj/machinery/computer/cargo/express/ghost/syndicate
	name = "\improper Syndicate Express Supply Console"
	desc = "A specialized Syndicate Express Supply Console, synced with a deepspace syndicate storage satellite, armed with a drop pod railgun for precise and accurate \
		deliveries over long distances, no matter how remote they are located."
	circuit = /obj/item/circuitboard/computer/cargo/express/ghost/syndicate
	req_access = list(ACCESS_SYNDICATE)
	cargo_account = ACCOUNT_DS2
	console_flag = CARGO_CONSOLE_DS2

// Tarkon Industries console
/obj/item/circuitboard/computer/cargo/express/ghost/tarkon
	name = "Tarkon Express Supply Console"
	build_path = /obj/machinery/computer/cargo/express/ghost/tarkon
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING

/obj/machinery/computer/cargo/express/ghost/tarkon
	name = "\improper Tarkon Express Supply Console"
	desc = "A specialized Tarkon Industries Express Supply Console, synced a deepspace storage satellite, armed with a drop pod railgun for precise and accurate \
		deliveries over long distances, no matter how remote they are located."
	circuit = /obj/item/circuitboard/computer/cargo/express/ghost/tarkon
	req_access = list(ACCESS_TARKON)
	cargo_account = ACCOUNT_TI
	console_flag = CARGO_CONSOLE_TARKON
// END NOVA CORE MIGRATION: code/modules/cargo/expressconsole.dm
