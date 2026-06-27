/datum/computer_file/program/budgetorders
	filename = "orderapp"
	filedesc = "NT Shopping Network"
	downloader_category = PROGRAM_CATEGORY_SUPPLY
	program_open_overlay = "request"
	extended_desc = "Nanotrasen Shopping Network interface for purchasing supplies from the cargo catalogue using a department budget account."
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	can_run_on_flags = PROGRAM_LAPTOP | PROGRAM_PDA
	size = 10
	tgui_id = "NtosCargo"
	program_icon = FA_ICON_CART_FLATBED
	///Are you actually placing orders with it?
	var/requestonly = TRUE
	///Can the tablet see or buy illegal stuff?
	var/contraband = FALSE
	///Is it being bought from a personal account, or is it being done via a budget/cargo?
	var/self_paid = FALSE
	///Can this console approve purchase requests?
	var/can_approve_requests = FALSE
	///What do we say when the shuttle moves with living beings on it.
	var/safety_warning = "For safety and ethical reasons, the automated supply shuttle cannot transport live organisms, \
		human remains, classified nuclear weaponry, mail, undelivered departmental order crates, syndicate bombs, \
		homing beacons, unstable eigenstates, or machinery housing any form of artificial intelligence."
	///If you're being raided by pirates, what do you tell the crew?
	var/blockade_warning = "Bluespace instability detected. Shuttle movement impossible."
	///The name of the shuttle template being used as the cargo shuttle. 'cargo' is default and contains critical code. Don't change this unless you know what you're doing.
	var/cargo_shuttle = "cargo"
	///The docking port called when returning to the station.
	var/docking_home = "cargo_home"
	///The docking port called when leaving the station.
	var/docking_away = "cargo_away"
	///If this console can loan the cargo shuttle. Set to false to disable.
	var/stationcargo = TRUE
	///The account this console processes and displays. Independent from the account the shuttle processes.
	var/cargo_account = ACCOUNT_CAR

/datum/computer_file/program/budgetorders/proc/is_visible_pack(mob/user, paccess_to_check, list/access, contraband)
	if(HAS_SILICON_ACCESS(user)) //Borgs can't buy things.
		return FALSE
	if(computer.obj_flags & EMAGGED)
		return TRUE
	else if(contraband) //Hide contrband when non-emagged.
		return FALSE
	if(!paccess_to_check) // No required_access, allow it.
		return TRUE
	if(isAdminGhostAI(user))
		return TRUE

	//Aquire access from the inserted ID card.
	if(!length(access))
		access = computer?.GetAccess()
		if(!length(access))
			return FALSE

	if(paccess_to_check in access)
		return TRUE

	return FALSE

/datum/computer_file/program/budgetorders/ui_data(mob/user)
	var/list/data = list()
	data["location"] = SSshuttle.supply.getStatusText()
	data["department"] = "Cargo"

	var/datum/bank_account/buyer = SSeconomy.get_dep_account(cargo_account)
	var/obj/item/card/id/id_card = computer.stored_id?.GetID()
	if(id_card?.registered_account)
		buyer = SSeconomy.get_dep_account(id_card?.registered_account.account_job.paycheck_department)
		if((ACCESS_BUDGET in id_card.access))
			requestonly = FALSE
			can_approve_requests = TRUE
			// If buyer is a departmental budget, replaces "Cargo" with that budget - we're not using the cargo budget here
			data["department"] = "[buyer.account_holder] Requisitions"
		else
			requestonly = TRUE
			can_approve_requests = FALSE
	else
		requestonly = TRUE
	if(buyer)
		data["points"] = buyer.account_balance
	// To recap above because it's kind of a mess, here's all the options:
		//Head of staff ID card: Can approve, buy, and make purchases using their own departmental budgets.
		//ID card, not a head of staff: can request items from cargo using departmental budget.
		//No ID card, can request items from cargo using the cargo budget.

	//Otherwise static data, that is being applied in ui_data as the crates visible and buyable are not static, and are determined by inserted ID.
	data["requestonly"] = requestonly
	data["supplies"] = list()
	for(var/pack in SSshuttle.supply_packs)
		var/datum/supply_pack/P = SSshuttle.supply_packs[pack]
		if(P.order_flags & ORDER_INVISIBLE)
			continue
		if((P.order_flags & ORDER_CONTRABAND) && !contraband)
			continue
		// NOVA EDIT CHANGE START - Sensitive supply packs are visible to non-security buyers; orders are announced instead of hard-blocked.
		if((!corporate_economy_is_sensitive_supply_pack(P) && !is_visible_pack(user, P.access_view , null, (P.order_flags & ORDER_CONTRABAND))) || (P.order_flags & ORDER_EMAG_ONLY))
			continue
		// NOVA EDIT CHANGE END
		if(!data["supplies"][P.group])
			data["supplies"][P.group] = list(
				"name" = P.group,
				"packs" = list()
			)
		if(((P.order_flags & ORDER_EMAG_ONLY) && ((P.order_flags & ORDER_CONTRABAND) && !contraband) || ((P.order_flags & ORDER_SPECIAL) && !(P.order_flags & ORDER_SPECIAL_ENABLED)) || (P.order_flags & ORDER_POD_ONLY)))
			continue

		// NOVA EDIT ADDITION START
		if(!(P.console_flag & console_flag))
			continue
		// NOVA EDIT ADDITION END
		var/obj/item/first_item = length(P.contains) > 0 ? P.contains[1] : null
		data["supplies"][P.group]["packs"] += list(list(
			"name" = P.name,
			"cost" = P.get_cost(),
			"id" = pack,
			"desc" = P.desc || P.name, // If there is a description, use it. Otherwise use the pack's name.
			"first_item_icon" = first_item?.icon,
			"first_item_icon_state" = first_item?.icon_state,
			"goody" = P.order_flags & ORDER_GOODY,
			"is_company" = istype(P, /datum/supply_pack/companies),
			"access" = P.access,
			"contains" = P.get_contents_ui_data(),
		))

	//Data regarding the User's capability to buy things.
	data["away"] = SSshuttle.supply.getDockedId() == docking_away
	data["self_paid"] = self_paid
	data["docked"] = SSshuttle.supply.mode == SHUTTLE_IDLE
	data["loan"] = !!SSshuttle.shuttle_loan
	data["loan_dispatched"] = SSshuttle.shuttle_loan && SSshuttle.shuttle_loan.dispatched
	data["can_send"] = FALSE //There is no situation where I want the app to be able to send the shuttle AWAY from the station, but conversely is fine.
	data["can_approve_requests"] = can_approve_requests
	data["app_cost"] = TRUE
	var/message = "Remember to stamp and send back the supply manifests."
	if(SSshuttle.centcom_message)
		message = SSshuttle.centcom_message
	if(SSshuttle.supply_blocked)
		message = blockade_warning
	data["message"] = message
	data["cart"] = build_cargo_cart_ui_data(SSshuttle.shopping_list)

	data["requests"] = list()
	for(var/datum/supply_order/order in SSshuttle.request_list)
		var/datum/supply_pack/pack = order.pack
		data["requests"] += list(list(
			"object" = pack.name,
			"cost" = pack.get_cost(),
			"orderer" = order.orderer,
			"reason" = order.reason,
			"id" = order.id,
			"account" = order.paying_account ? order.paying_account.account_holder : "Cargo Department"
		))

	return data

/datum/computer_file/program/budgetorders/ui_static_data(mob/user)
	var/list/data = list()
	data["max_order"] = CARGO_MAX_ORDER
	data["displayed_currency_full_name"] = " [MONEY_NAME]"
	data["displayed_currency_name"] = " [MONEY_SYMBOL]"
	return data

/datum/computer_file/program/budgetorders/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	switch(action)
		if("send")
			if(!SSshuttle.supply.canMove())
				computer.say(safety_warning)
				return
			if(SSshuttle.supply_blocked)
				computer.say(blockade_warning)
				return
			if(SSshuttle.supply.getDockedId() == docking_home)
				SSshuttle.moveShuttle(cargo_shuttle, docking_away, TRUE)
				computer.say("The supply shuttle is departing.")
				user.investigate_log("sent the supply shuttle away.", INVESTIGATE_CARGO)
			else
				user.investigate_log("called the supply shuttle.", INVESTIGATE_CARGO)
				computer.say("The supply shuttle has been called and will arrive in [SSshuttle.supply.timeLeft(600)] minute\s.")
				SSshuttle.moveShuttle(cargo_shuttle, docking_home, TRUE)
			. = TRUE
		if("loan")
			if(!SSshuttle.shuttle_loan)
				return
			if(SSshuttle.supply_blocked)
				computer.say(blockade_warning)
				return
			else if(SSshuttle.supply.mode != SHUTTLE_IDLE)
				return
			else if(SSshuttle.supply.getDockedId() != docking_away)
				return
			else if(stationcargo != TRUE)
				return
			else
				SSshuttle.shuttle_loan.loan_shuttle()
				computer.say("The supply shuttle has been loaned to CentCom.")
				user.investigate_log("accepted a shuttle loan event.", INVESTIGATE_CARGO)
				user.log_message("accepted a shuttle loan event.", LOG_GAME)
				. = TRUE
		if("add")
			var/id = text2path(params["id"]) || params["id"]
			var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
			if(!istype(pack))
				return
			if((pack.order_flags & (ORDER_EMAG_ONLY | ORDER_POD_ONLY | ORDER_CONTRABAND)) || ((pack.order_flags & ORDER_SPECIAL) && !(pack.order_flags & ORDER_SPECIAL_ENABLED)))
				return

			var/name = "*None Provided*"
			var/rank = "*None Provided*"
			var/ckey = user.ckey
			var/mob/living/carbon/human/hwoman
			if(ishuman(user))
				hwoman = user
				rank = hwoman.get_assignment(hand_first = TRUE)
			else if(issilicon(user))
				name = user.real_name
				rank = "Silicon"

			// Our account that we want to end up paying with.
			var/datum/bank_account/account
			// Our ID card that we want to pull from for identification. Modifies either name, account, or neither depending on function.
			var/obj/item/card/id/id_card_customer = computer.stored_id?.GetID()
			if(!id_card_customer)
				id_card_customer = hwoman?.get_idcard(TRUE) //Grab from hands/mob if there's no id_card slot to prioritize.
			name = id_card_customer?.registered_account.account_holder

			if(self_paid)
				if(!istype(id_card_customer))
					computer.say("No ID card detected.")
					return
				if(IS_DEPARTMENTAL_CARD(id_card_customer))
					computer.say("[id_card_customer] cannot be used to make purchases.")
					return
				account = id_card_customer.registered_account
				name = id_card_customer.registered_account.account_holder
				if(!istype(account))
					computer.say("Invalid bank account.")
					return

			var/reason = ""
			var/datum/bank_account/personal_department
			if((requestonly && !self_paid) || !(computer.stored_id?.GetID()))
				reason = tgui_input_text(user, "Reason", name, max_length = MAX_MESSAGE_LEN)
				if(isnull(reason) || ..())
					return

			if(id_card_customer?.registered_account?.account_job && !self_paid) //Find a budget to pull from
				personal_department = SSeconomy.get_dep_account(id_card_customer.registered_account.account_job.paycheck_department)
				if(!(personal_department.account_holder == "Cargo Budget"))
					var/dept_choice = tgui_alert(user, "Which department are you requesting this for?", "Choose request department", list("Cargo Budget", "[personal_department.account_holder]"))
					if(!dept_choice)
						return
					if(dept_choice == "Cargo Budget")
						personal_department = null

			if(SSshuttle.supply.get_order_count(pack) == OVER_ORDER_LIMIT)
				playsound(computer, 'sound/machines/buzz/buzz-sigh.ogg', 50, FALSE)
				computer.say("ERROR: No more then [CARGO_MAX_ORDER] of any pack may be ordered at once")
				return

			if(!self_paid)
				account = personal_department

			var/turf/T = get_turf(computer)
			var/datum/supply_order/SO = new(
				pack = pack,
				orderer = name,
				orderer_rank = rank,
				orderer_ckey = ckey,
				reason = reason,
				paying_account = account,
				private_purchase = self_paid,
			)
			SO.generateRequisition(T)
			if((requestonly && !self_paid) || !(computer.stored_id?.GetID()))
				SSshuttle.request_list += SO
			else
				SSshuttle.shopping_list += SO
				if(self_paid)
					computer.say("Order processed. The price will be charged to [account.account_holder]'s bank account on delivery.")
			// NOVA EDIT ADDITION START - Sensitive cargo orders are allowed, but reported to supply.
			var/payment_source = self_paid ? (account?.account_holder || "private account") : (account?.account_holder || "Cargo Budget")
			if(corporate_economy_lacks_supply_pack_access(pack, id_card_customer?.GetAccess()))
				corporate_economy_announce_sensitive_cargo_order(computer.physical, pack, name, rank, payment_source)
			// NOVA EDIT ADDITION END
			playsound(computer, 'sound/effects/coin2.ogg', 40, TRUE)
			. = TRUE
		if("remove")
			var/id = text2num(params["id"])
			var/cart_key = params["cart_key"]
			var/order_name = params["order_name"]
			for(var/datum/supply_order/SO in SSshuttle.shopping_list)
				if(cart_key && (SO.get_checkout_group_key() != cart_key || SO.pack.name != order_name))
					continue
				if(!cart_key && SO.id != id)
					continue
				SSshuttle.shopping_list -= SO
				. = TRUE
				break
		if("clear")
			for(var/datum/supply_order/cancelled_order in SSshuttle.shopping_list)
				if(cancelled_order.department_destination || cancelled_order.can_be_cancelled)
					continue //don't cancel other department's orders or orders that can't be cancelled
				SSshuttle.shopping_list -= cancelled_order
			. = TRUE
		if("approve")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.request_list)
				if(SO.id == id)
					var/obj/item/card/id/id_card = computer.stored_id?.GetID()
					if(id_card && id_card?.registered_account)
						SO.paying_account = SSeconomy.get_dep_account(id_card?.registered_account?.account_job.paycheck_department)
					SSshuttle.request_list -= SO
					SSshuttle.shopping_list += SO
					. = TRUE
					break
		if("deny")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.request_list)
				if(SO.id == id)
					SSshuttle.request_list -= SO
					. = TRUE
					break
		if("denyall")
			SSshuttle.request_list.Cut()
			. = TRUE
		if("toggleprivate")
			self_paid = !self_paid
			. = TRUE
		if("company_import_window")
			var/datum/component/armament/company_imports/import_component = computer.GetComponent(/datum/component/armament/company_imports)
			if(!import_component)
				computer.AddComponent(/datum/component/armament/company_imports)
				import_component = computer.GetComponent(/datum/component/armament/company_imports)
			import_component.parent_prog ||= src
			import_component.ui_interact(user)
			. = TRUE
	if(.)
		post_signal(cargo_shuttle)

/datum/computer_file/program/budgetorders/proc/post_signal(command)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = command))
	frequency.post_signal(src, status_signal)


// BEGIN NOVA CORE MIGRATION: code/modules/computers/modular/file_system/programs/budgetordering.dm
/datum/computer_file/program/budgetorders
	///Flag that controls which supplies packs this program is allowed to order from, as it emulates a particular cargo console.
	var/console_flag = CARGO_CONSOLE_PDA
// END NOVA CORE MIGRATION: code/modules/computers/modular/file_system/programs/budgetordering.dm

