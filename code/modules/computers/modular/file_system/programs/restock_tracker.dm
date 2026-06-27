#define RESTOCK_TRACKER_MISSING_PREVIEW_LIMIT 4
#define RESTOCK_TASK_DURATION (15 MINUTES)
#define RESTOCK_TASK_BASE_REWARD 8
#define RESTOCK_TASK_PER_MISSING_ITEM_REWARD 1
#define RESTOCK_TASK_MAX_REWARD 45
#define RESTOCK_TASK_PENALTY_MULTIPLIER 2

/datum/computer_file/program/restock_tracker
	filename = "restockapp"
	filedesc = "NT Restock Tracker"
	downloader_category = PROGRAM_CATEGORY_SUPPLY
	program_open_overlay = "restock"
	extended_desc = "Nanotrasen IoT network listing all the vending machines found on station, and how well stocked they are each. Profitable!"
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	can_run_on_flags = PROGRAM_ALL
	size = 4
	program_icon = "cash-register"
	tgui_id = "NtosRestock"

/datum/supply_pack/restock_tracker
	name = "Restock Tracker Order"
	group = "Vending Restocks"
	desc = "A restock cartridge requested by NT Restock Tracker."
	cost = 0
	order_flags = ORDER_INVISIBLE
	test_ignored = TRUE
	/// The refill canister type this order should create.
	var/obj/item/vending_refill/restock_canister_path
	/// Standard-product stock snapshot loaded into the ordered canister.
	var/list/restock_products = list()
	/// Premium-product stock snapshot loaded into the ordered canister.
	var/list/restock_premium = list()

/datum/supply_pack/restock_tracker/New(obj/machinery/vending/vendor, list/products_to_load, list/premium_to_load)
	. = ..()
	if(!vendor?.refill_canister)
		return
	restock_canister_path = vendor.refill_canister
	name = "[vendor.name] Restock"
	crate_name = "[vendor.name] restock crate"
	restock_products = products_to_load?.Copy() || list()
	restock_premium = premium_to_load?.Copy() || list()
	contains = list()
	contains[restock_canister_path] = 1

/datum/supply_pack/restock_tracker/fill(obj/container)
	if(!restock_canister_path)
		return
	var/obj/item/vending_refill/canister = new restock_canister_path(container)
	canister.products = restock_products.Copy()
	canister.contraband = list()
	canister.premium = restock_premium.Copy()

/datum/computer_file/program/restock_tracker/proc/get_user_account()
	var/obj/item/card/id/user_id = computer?.stored_id?.GetID()
	return user_id?.registered_account

/datum/computer_file/program/restock_tracker/proc/can_claim_restock_tasks(datum/bank_account/account)
	if(!account?.add_to_accounts || ispath(account.account_job))
		return FALSE
	return TRUE

/datum/computer_file/program/restock_tracker/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("claim_task")
			var/datum/bank_account/user_account = get_user_account()
			if(!can_claim_restock_tasks(user_account))
				to_chat(ui.user, span_warning("A valid ID bank account is required to claim restock tasks."))
				return TRUE

			var/obj/machinery/vending/vendor = locate(params["vendor"])
			if(!istype(vendor) || istype(vendor, /obj/machinery/vending/custom) || vendor.all_products_free)
				return TRUE

			var/missing_total = vendor.get_restock_missing_count()
			if(!missing_total)
				to_chat(ui.user, span_warning("[vendor] does not need a refill task right now."))
				vendor.clear_restock_task()
				return TRUE

			if(vendor.restock_task_claimant && vendor.restock_task_claimant != user_account)
				to_chat(ui.user, span_warning("[vendor] is already claimed by [vendor.restock_task_claimant_name || "another crew member"]."))
				return TRUE

			if(vendor.restock_task_claimant == user_account)
				to_chat(ui.user, span_notice("You have already claimed [vendor]."))
				return TRUE

			vendor.restock_task_claimant = user_account
			vendor.restock_task_claimant_name = user_account.account_holder
			vendor.restock_task_missing_at_claim = missing_total
			vendor.restock_task_reward = vendor.calculate_restock_task_reward(missing_total)
			vendor.restock_task_penalty = vendor.calculate_restock_task_penalty()
			vendor.restock_task_due_time = world.time + RESTOCK_TASK_DURATION
			vendor.restock_task_timer_id = addtimer(CALLBACK(vendor, TYPE_PROC_REF(/obj/machinery/vending, fail_restock_task)), RESTOCK_TASK_DURATION, TIMER_STOPPABLE)
			to_chat(ui.user, span_notice("You claim the restock task for [vendor]. Complete the refill within [DisplayTimeText(RESTOCK_TASK_DURATION, 1)] for [vendor.restock_task_reward] [MONEY_NAME]. Failure fine: [vendor.restock_task_penalty] [MONEY_NAME]."))
			user_account.bank_card_talk("Restock task accepted: [vendor] in [get_area_name(vendor)]. Reward: [vendor.restock_task_reward][MONEY_SYMBOL]. Failure fine: [vendor.restock_task_penalty][MONEY_SYMBOL].", TRUE)
			return TRUE

		if("order_restock")
			var/datum/bank_account/order_user_account = get_user_account()
			if(!order_user_account)
				to_chat(ui.user, span_warning("A valid ID bank account is required to submit restock requests."))
				return TRUE

			var/obj/machinery/vending/order_vendor = locate(params["vendor"])
			if(!istype(order_vendor) || istype(order_vendor, /obj/machinery/vending/custom) || order_vendor.all_products_free)
				return TRUE
			if(order_vendor.restock_task_claimant != order_user_account)
				to_chat(ui.user, span_warning("You must claim this restock task before ordering supplies for it."))
				return TRUE
			if(!order_vendor.get_restock_missing_count())
				to_chat(ui.user, span_warning("[order_vendor] does not need restock supplies right now."))
				return TRUE

			if(order_vendor.restock_supply_ordered)
				to_chat(ui.user, span_warning("A restock order has already been submitted for this task."))
				return TRUE

			if(order_vendor.get_pending_restock_order())
				to_chat(ui.user, span_warning("A restock request for [order_vendor] is already pending."))
				return TRUE

			var/datum/supply_pack/pack = order_vendor.create_restock_supply_pack()
			if(!pack)
				to_chat(ui.user, span_warning("No cargo restock pack is available for [order_vendor]."))
				return TRUE

			var/orderer_rank = order_user_account.account_job ? order_user_account.account_job.title : "Crew"
			var/datum/supply_order/order = new /datum/supply_order/disposable(
				pack = pack,
				orderer = order_user_account.account_holder,
				orderer_rank = orderer_rank,
				orderer_ckey = ui.user?.ckey,
				reason = "NT Restock Tracker: [order_vendor] in [get_area_name(order_vendor)]",
				paying_account = null,
				charge_on_purchase = FALSE,
			)
			order.generateRequisition(get_turf(computer))
			SSshuttle.request_list += order
			order_vendor.restock_supply_order_id = order.id
			order_vendor.restock_supply_ordered = TRUE
			to_chat(ui.user, span_notice("Restock request #[order.id] for [pack.name] has been submitted to Cargo."))
			computer.say("Restock request submitted for [order_vendor].")
			return TRUE

/datum/computer_file/program/restock_tracker/ui_data()
	var/list/data = list()
	var/datum/bank_account/user_account = get_user_account()
	data["can_claim_tasks"] = can_claim_restock_tasks(user_account)
	data["account_id"] = user_account ? "[user_account.account_id]" : null

	var/list/vending_list = list()
	var/id_increment = 1
	for(var/obj/machinery/vending/vendor as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/vending))
		if(vendor.all_products_free || istype(vendor, /obj/machinery/vending/custom))
			continue

		var/list/restock_status = vendor.get_restock_status()
		var/missing_total = restock_status["missing_total"]
		if(!missing_total && !vendor.credits_contained)
			vendor.clear_restock_task()
			continue

		var/task_reward = vendor.restock_task_reward || vendor.calculate_restock_task_reward(missing_total)
		var/task_penalty = vendor.restock_task_penalty || vendor.calculate_restock_task_penalty()
		var/claimed_by_you = vendor.restock_task_claimant && vendor.restock_task_claimant == user_account
		var/claimable = data["can_claim_tasks"] && missing_total && (!vendor.restock_task_claimant || claimed_by_you)
		var/datum/supply_order/pending_order = vendor.get_pending_restock_order()
		var/fallback_restock_pack_name = vendor.refill_canister ? "[vendor.name] Restock" : null
		vending_list += list(list(
			"name" = vendor.name,
			"location" = get_area_name(vendor),
			"credits" = vendor.credits_contained,
			"percentage" = restock_status["percentage"],
			"missing_total" = missing_total,
			"missing_products" = restock_status["missing_products"],
			"missing_extra" = restock_status["missing_extra"],
			"missing_value" = restock_status["missing_value"],
			"reward" = missing_total ? task_reward : 0,
			"penalty" = missing_total ? task_penalty : 0,
			"claimed_by" = vendor.restock_task_claimant_name,
			"claimed_by_you" = claimed_by_you,
			"claimable" = claimable,
			"time_left" = vendor.restock_task_claimant ? DisplayTimeText(max(vendor.restock_task_due_time - world.time, 0), 1) : null,
			"order_pending" = !!pending_order,
			"order_id" = pending_order?.id,
			"order_pack" = pending_order?.pack?.name || fallback_restock_pack_name,
			"order_sent" = vendor.restock_supply_ordered,
			"orderable" = !!vendor.refill_canister && claimed_by_you && !vendor.restock_supply_ordered,
			"vendor" = REF(vendor),
			"id" = id_increment,
		))
		id_increment++

	data["vending_list"] = vending_list
	return data

/obj/machinery/vending/proc/get_restock_missing_count()
	SHOULD_BE_PURE(TRUE)

	. = 0
	var/list/legal_records = product_records + coin_records
	for(var/datum/data/vending_product/record as anything in legal_records)
		. += max(0, record.max_amount - record.amount)

/obj/machinery/vending/proc/get_restock_missing_value()
	SHOULD_BE_PURE(TRUE)

	. = 0
	var/list/legal_records = product_records + coin_records
	for(var/datum/data/vending_product/record as anything in legal_records)
		var/missing_amount = max(0, record.max_amount - record.amount)
		if(!missing_amount)
			continue
		. += missing_amount * max(record.price || 0, 0)

/obj/machinery/vending/proc/get_restock_status(missing_preview_limit = RESTOCK_TRACKER_MISSING_PREVIEW_LIMIT)
	SHOULD_BE_PURE(TRUE)
	RETURN_TYPE(/list)

	var/list/total_legal_stock = total_stock(contrabrand = FALSE)
	var/loaded_stock = total_legal_stock[1]
	var/max_stock = total_legal_stock[2]
	var/list/missing_products = list()
	var/missing_entries = 0
	var/missing_total = 0
	var/missing_value = 0

	var/list/legal_records = product_records + coin_records
	for(var/datum/data/vending_product/record as anything in legal_records)
		var/missing_amount = max(0, record.max_amount - record.amount)
		if(!missing_amount)
			continue

		missing_total += missing_amount
		missing_value += missing_amount * max(record.price || 0, 0)
		missing_entries++
		if(length(missing_products) >= missing_preview_limit)
			continue

		missing_products += list(list(
			"name" = record.name,
			"missing" = missing_amount,
			"amount" = record.amount,
			"max" = record.max_amount,
		))

	return list(
		"loaded" = loaded_stock,
		"max" = max_stock,
		"percentage" = max_stock ? (loaded_stock / max_stock) * 100 : 100,
		"missing_total" = missing_total,
		"missing_value" = missing_value,
		"missing_products" = missing_products,
		"missing_extra" = max(0, missing_entries - length(missing_products)),
	)

/obj/machinery/vending/proc/calculate_restock_task_reward(missing_total)
	SHOULD_BE_PURE(TRUE)

	if(!missing_total)
		return 0
	return clamp(round(RESTOCK_TASK_BASE_REWARD + (missing_total * RESTOCK_TASK_PER_MISSING_ITEM_REWARD)), RESTOCK_TASK_BASE_REWARD, RESTOCK_TASK_MAX_REWARD)

/obj/machinery/vending/proc/calculate_restock_task_penalty()
	SHOULD_BE_PURE(TRUE)

	return round(get_restock_missing_value() * RESTOCK_TASK_PENALTY_MULTIPLIER)

/obj/machinery/vending/proc/get_restock_supply_pack()
	RETURN_TYPE(/datum/supply_pack)

	if(!refill_canister)
		return null

	for(var/pack_id in SSshuttle.supply_packs)
		var/datum/supply_pack/pack = SSshuttle.supply_packs[pack_id]
		if(!pack?.contains)
			continue
		if(pack.order_flags & (ORDER_INVISIBLE | ORDER_EMAG_ONLY | ORDER_POD_ONLY | ORDER_CONTRABAND))
			continue
		if((pack.order_flags & ORDER_SPECIAL) && !(pack.order_flags & ORDER_SPECIAL_ENABLED))
			continue
		if(refill_canister in pack.contains)
			return pack

/obj/machinery/vending/proc/create_restock_supply_pack()
	RETURN_TYPE(/datum/supply_pack)

	if(!refill_canister)
		return null

	var/list/products_to_load = list()
	for(var/datum/data/vending_product/record as anything in product_records)
		var/missing_amount = max(0, record.max_amount - record.amount)
		if(missing_amount)
			products_to_load[record.product_path] = missing_amount

	var/list/premium_to_load = list()
	for(var/datum/data/vending_product/record as anything in coin_records)
		var/missing_amount = max(0, record.max_amount - record.amount)
		if(missing_amount)
			premium_to_load[record.product_path] = missing_amount

	if(!length(products_to_load) && !length(premium_to_load))
		return null

	return new /datum/supply_pack/restock_tracker(src, products_to_load, premium_to_load)

/obj/machinery/vending/proc/get_pending_restock_order()
	RETURN_TYPE(/datum/supply_order)

	if(!restock_supply_order_id)
		return null

	for(var/datum/supply_order/order as anything in SSshuttle.request_list + SSshuttle.shopping_list)
		if(order.id == restock_supply_order_id)
			return order

	restock_supply_order_id = 0
	return null

/obj/machinery/vending/proc/clear_restock_task()
	if(restock_task_timer_id)
		deltimer(restock_task_timer_id)
		restock_task_timer_id = null
	restock_task_claimant = null
	restock_task_claimant_name = null
	restock_task_reward = 0
	restock_task_missing_at_claim = 0
	restock_task_penalty = 0
	restock_task_due_time = 0
	restock_supply_order_id = 0
	restock_supply_ordered = FALSE

/obj/machinery/vending/proc/complete_restock_task(mob/living/user)
	if(!restock_task_claimant)
		return FALSE

	if(get_restock_missing_count())
		return FALSE

	var/obj/item/card/id/user_id = user.get_idcard(TRUE)
	var/datum/bank_account/user_account = user_id?.registered_account
	if(user_account != restock_task_claimant)
		to_chat(user, span_notice("The restock task for [src] was claimed by [restock_task_claimant_name || "another crew member"], so no task bonus is paid."))
		clear_restock_task()
		return FALSE

	var/reward = restock_task_reward || calculate_restock_task_reward(restock_task_missing_at_claim)
	if(reward > 0 && user_account.adjust_money(reward, "NT Restock Tracker: [src]"))
		user_account.bank_card_talk("Restock task complete: [src]. [reward][MONEY_SYMBOL] deposited.", TRUE)
		log_econ("[reward] [MONEY_NAME] were rewarded to [user_account.account_holder]'s account for restocking [src] through NT Restock Tracker.")
		to_chat(user, span_notice("NT Restock Tracker deposits [reward] [MONEY_NAME] into your account."))

	clear_restock_task()
	return TRUE

/obj/machinery/vending/proc/fail_restock_task()
	restock_task_timer_id = null
	if(!restock_task_claimant)
		return FALSE

	if(!get_restock_missing_count())
		clear_restock_task()
		return FALSE

	var/datum/bank_account/fined_account = restock_task_claimant
	var/penalty = max(restock_task_penalty, 0)
	if(penalty > 0)
		var/paid_penalty = min(fined_account.account_balance, penalty)
		if(paid_penalty > 0)
			fined_account.adjust_money(-paid_penalty, "NT Restock Tracker: Missed [src] task")
		var/debt_penalty = penalty - paid_penalty
		if(debt_penalty > 0)
			fined_account.account_debt += debt_penalty
			fined_account.add_log_to_history(-debt_penalty, "NT Restock Tracker: Missed [src] task debt")

		fined_account.bank_card_talk("Restock task failed: [src]. Fine applied: [penalty][MONEY_SYMBOL].", TRUE)
		log_econ("[penalty] [MONEY_NAME] were fined from [fined_account.account_holder]'s account for failing to restock [src] through NT Restock Tracker.")

	clear_restock_task()
	return TRUE

#undef RESTOCK_TRACKER_MISSING_PREVIEW_LIMIT
#undef RESTOCK_TASK_DURATION
#undef RESTOCK_TASK_BASE_REWARD
#undef RESTOCK_TASK_PER_MISSING_ITEM_REWARD
#undef RESTOCK_TASK_MAX_REWARD
#undef RESTOCK_TASK_PENALTY_MULTIPLIER
