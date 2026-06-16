/obj/item/storage/lockbox/order
	/// Bool if this was departmentally ordered or not
	var/department_purchase
	/// Department of the person buying the crate if buying via the NIRN app.
	var/datum/bank_account/department/department_account

/obj/structure/closet/crate/large/import
	name = "heavy-duty wooden crate"
	icon = 'icons/company_imports/import_crate.dmi'
	material_drop_amount = 0

#define COMPANY_IMPORT_CARGO_CONSOLE 1
#define COMPANY_IMPORT_ORDER_APP 2

/datum/component/armament/company_imports
	/// Is this set to private order.
	var/self_paid = FALSE
	/// What kind of parent is hosting this import menu.
	var/console_state
	/// If this is a tablet, the parent budget ordering program.
	var/datum/computer_file/program/budgetorders/parent_prog
	/// Base64 icon cache keyed by supply pack type.
	var/list/cached_pack_icons = list()

/datum/component/armament/company_imports/Initialize(list/required_products, list/needed_access)
	parent_atom = parent
	if(istype(parent, /obj/machinery/computer/cargo))
		console_state = COMPANY_IMPORT_CARGO_CONSOLE
	else if(istype(parent, /obj/item/modular_computer))
		console_state = COMPANY_IMPORT_ORDER_APP
	else
		return COMPONENT_INCOMPATIBLE

/datum/component/armament/company_imports/Destroy(force)
	parent_prog = null
	cached_pack_icons = null
	return ..()

/datum/component/armament/company_imports/on_attack_hand(datum/source, mob/living/user)
	return

/datum/component/armament/company_imports/on_attackby(atom/target, obj/item, mob/user)
	return

/datum/component/armament/company_imports/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CargoImportConsole")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/component/armament/company_imports/ui_data(mob/user)
	var/list/data = list()
	var/obj/item/card/id/id_card = get_user_id(user)
	var/datum/bank_account/buyer = get_budget_account(id_card)
	var/budget_name = buyer?.account_holder || "Cargo Budget"
	if(self_paid && id_card?.registered_account)
		budget_name = id_card.registered_account.account_holder

	data["budget_name"] = budget_name
	data["budget_points"] = self_paid ? id_card?.registered_account?.account_balance : buyer?.account_balance
	data["cant_buy_restricted"] = FALSE // NOVA EDIT CHANGE - Restricted imports are orderable; suspicious orders are announced to supply.
	data["self_paid"] = !!self_paid
	data["armaments_list"] = get_company_import_data()
	return data

/datum/component/armament/company_imports/proc/get_company_import_data()
	var/list/company_data = list()
	for(var/pack_id in SSshuttle.supply_packs)
		var/datum/supply_pack/pack = SSshuttle.supply_packs[pack_id]
		if(!is_company_pack_visible(pack))
			continue

		var/company = company_name_from_pack(pack)
		var/subcategory = pack.group || "General"
		LAZYINITLIST(company_data[company])
		LAZYINITLIST(company_data[company][subcategory])
		company_data[company][subcategory] += list(list(
			"ref" = "[pack_id]",
			"icon" = get_pack_icon(pack),
			"name" = pack.name,
			"cost" = pack.get_cost(),
			"description" = pack.desc || pack.name,
			"restricted" = !!(pack.access || pack.access_view),
		))

	var/list/armaments_list = list()
	for(var/company in sort_list(company_data))
		var/list/subcategories = list()
		for(var/subcategory in sort_list(company_data[company]))
			subcategories += list(list(
				"subcategory" = subcategory,
				"items" = company_data[company][subcategory],
			))
		armaments_list += list(list(
			"category" = company,
			"subcategories" = subcategories,
		))
	return armaments_list

/datum/component/armament/company_imports/proc/is_company_pack_visible(datum/supply_pack/pack)
	if(!istype(pack))
		return FALSE
	if(!istype(pack, /datum/supply_pack/companies))
		return FALSE
	if((pack.order_flags & ORDER_INVISIBLE) || (pack.order_flags & ORDER_POD_ONLY))
		return FALSE
	if((pack.order_flags & ORDER_SPECIAL) && !(pack.order_flags & ORDER_SPECIAL_ENABLED))
		return FALSE
	if((pack.order_flags & ORDER_EMAG_ONLY) && !parent_is_emagged())
		return FALSE
	if((pack.order_flags & ORDER_CONTRABAND) && !parent_has_contraband())
		return FALSE
	if(!(pack.console_flag & get_console_flag()))
		return FALSE
	return TRUE

/datum/component/armament/company_imports/proc/get_pack_icon(datum/supply_pack/pack)
	if(cached_pack_icons[pack.type])
		return cached_pack_icons[pack.type]
	var/preview_type = length(pack.contains) > 0 ? pack.contains[1] : null
	if(!ispath(preview_type, /atom/movable))
		cached_pack_icons[pack.type] = ""
		return cached_pack_icons[pack.type]
	var/atom/movable/preview = new preview_type()
	cached_pack_icons[pack.type] = icon2base64(getFlatIcon(preview, no_anim = TRUE))
	qdel(preview)
	return cached_pack_icons[pack.type]

/datum/component/armament/company_imports/proc/company_name_from_pack(datum/supply_pack/pack)
	var/list/path_segments = splittext("[pack.type]", "/")
	var/company_index = path_segments.Find("companies")
	var/company_key = (company_index && length(path_segments) >= company_index + 2) ? path_segments[company_index + 2] : null
	switch(company_key)
		if("akh_frontier")
			return FRONTIER_EQUIPMENT_NAME
		if("blacksteel")
			return BLACKSTEEL_FOUNDATION_NAME
		if("deforest")
			return DEFOREST_MEDICAL_NAME
		if("donk")
			return DONK_CO_NAME
		if("hc_surplus")
			return NRI_SURPLUS_COMPANY_NAME
		if("kahraman")
			return KAHRAMAN_INDUSTRIES_NAME
		if("microstar")
			return MICROSTAR_ENERGY_NAME
		if("nakamura")
			return NAKAMURA_ENGINEERING_MODSUITS_NAME
		if("sol_fed")
			return SOL_DEFENSE_DEFENSE_NAME
		if("vitezstvi")
			return VITEZSTVI_AMMO_NAME
	return "Miscellaneous Imports"

/datum/component/armament/company_imports/proc/get_console_flag()
	if(console_state == COMPANY_IMPORT_CARGO_CONSOLE)
		var/obj/machinery/computer/cargo/cargo_console = parent
		return cargo_console.console_flag
	if(console_state == COMPANY_IMPORT_ORDER_APP)
		return parent_prog?.console_flag || CARGO_CONSOLE_PDA
	return CARGO_CONSOLE_NT

/datum/component/armament/company_imports/proc/parent_is_emagged()
	if(console_state != COMPANY_IMPORT_CARGO_CONSOLE)
		return FALSE
	var/obj/machinery/computer/cargo/cargo_console = parent
	return !!(cargo_console.obj_flags & EMAGGED)

/datum/component/armament/company_imports/proc/parent_has_contraband()
	if(console_state != COMPANY_IMPORT_CARGO_CONSOLE)
		return FALSE
	var/obj/machinery/computer/cargo/cargo_console = parent
	return cargo_console.contraband

/datum/component/armament/company_imports/proc/cannot_buy_restricted(obj/item/card/id/id_card)
	if(console_state == COMPANY_IMPORT_CARGO_CONSOLE)
		var/obj/machinery/computer/cargo/cargo_console = parent
		return cargo_console.requestonly
	if(!id_card?.registered_account)
		return TRUE
	return !(ACCESS_BUDGET in id_card.access) && !(ACCESS_COMMAND in id_card.access) && !(ACCESS_QM in id_card.access)

/datum/component/armament/company_imports/proc/get_user_id(mob/user)
	if(console_state == COMPANY_IMPORT_ORDER_APP)
		return parent_prog?.computer?.stored_id?.GetID()
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		return human_user.get_idcard(TRUE)
	return null

/datum/component/armament/company_imports/proc/get_budget_account(obj/item/card/id/id_card)
	if(console_state == COMPANY_IMPORT_ORDER_APP && id_card?.registered_account?.account_job)
		if((ACCESS_BUDGET in id_card.access) || (ACCESS_COMMAND in id_card.access) || (ACCESS_QM in id_card.access))
			parent_prog.requestonly = FALSE
			parent_prog.can_approve_requests = TRUE
			return SSeconomy.get_dep_account(id_card.registered_account.account_job.paycheck_department)
		parent_prog.requestonly = TRUE
		parent_prog.can_approve_requests = FALSE
	return SSeconomy.get_dep_account(ACCOUNT_CAR)

/datum/component/armament/company_imports/proc/order_pack(mob/user, datum/supply_pack/pack)
	var/obj/item/card/id/id_card = get_user_id(user)
	var/datum/bank_account/buyer = get_budget_account(id_card)
	if(self_paid)
		if(!istype(id_card))
			to_chat(user, span_warning("No ID card detected."))
			return FALSE
		if(IS_DEPARTMENTAL_CARD(id_card))
			to_chat(user, span_warning("[id_card] cannot be used to make purchases."))
			return FALSE
		buyer = id_card.registered_account
		if(!istype(buyer))
			to_chat(user, span_warning("Invalid bank account."))
			return FALSE

	if(!buyer)
		to_chat(user, span_warning("No budget found."))
		return FALSE

	var/actual_cost = pack.get_cost()
	if(!buyer.has_money(actual_cost))
		to_chat(user, span_warning("Not enough money."))
		return FALSE

	var/name = "*None Provided*"
	var/rank = "*None Provided*"
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		name = human_user.get_authentification_name()
		rank = human_user.get_assignment(hand_first = TRUE)
	else if(HAS_SILICON_ACCESS(user))
		name = user.real_name
		rank = "Silicon"
	else
		return FALSE

	var/reason = ""
	var/request_order = should_route_order_to_requests(buyer)
	if(request_order && !self_paid)
		reason = tgui_input_text(user, "Reason", name, max_length = MAX_MESSAGE_LEN)
		if(isnull(reason))
			return FALSE

	var/datum/supply_order/created_order = new(
		pack = pack,
		orderer = name,
		orderer_rank = rank,
		orderer_ckey = user.ckey,
		reason = reason,
		paying_account = buyer,
		can_be_cancelled = TRUE,
		recipient_account = id_card?.registered_account,
		private_purchase = self_paid,
	)
	created_order.generateRequisition(get_turf(parent))
	if(request_order && !self_paid)
		SSshuttle.request_list += created_order
	else
		SSshuttle.shopping_list += created_order
	// NOVA EDIT ADDITION START - Sensitive company import orders are allowed, but reported to supply.
	var/payment_source = self_paid ? (buyer?.account_holder || "private account") : (buyer?.account_holder || "Cargo Budget")
	if(corporate_economy_lacks_supply_pack_access(pack, id_card?.GetAccess()))
		corporate_economy_announce_sensitive_cargo_order(parent_atom, pack, name, rank, payment_source)
	// NOVA EDIT ADDITION END
	return TRUE

/datum/component/armament/company_imports/proc/should_request_order()
	if(console_state == COMPANY_IMPORT_CARGO_CONSOLE)
		var/obj/machinery/computer/cargo/cargo_console = parent
		return cargo_console.requestonly
	if(console_state == COMPANY_IMPORT_ORDER_APP)
		return parent_prog?.requestonly || !parent_prog?.computer?.stored_id
	return FALSE

/datum/component/armament/company_imports/proc/should_route_order_to_requests(datum/bank_account/buyer)
	if(self_paid)
		return FALSE
	if(buyer == SSeconomy.get_dep_account(ACCOUNT_CAR))
		return TRUE
	return should_request_order()

/datum/component/armament/company_imports/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggleprivate")
			var/obj/item/card/id/id_card = get_user_id(ui.user)
			if(!id_card)
				return
			self_paid = !self_paid
			SStgui.update_uis(src)
			return TRUE
		if("equip_item")
			var/pack_id = text2path(params["armament_ref"])
			var/datum/supply_pack/pack = SSshuttle.supply_packs[pack_id]
			if(!is_company_pack_visible(pack))
				return
			// NOVA EDIT REMOVAL - Restricted imports are orderable; suspicious orders are announced to supply.
			. = order_pack(ui.user, pack)
			if(.)
				SStgui.update_uis(src)

/obj/machinery/computer/cargo/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "company_import_window")
		var/datum/component/armament/company_imports/import_component = GetComponent(/datum/component/armament/company_imports)
		if(!import_component)
			AddComponent(/datum/component/armament/company_imports)
			import_component = GetComponent(/datum/component/armament/company_imports)
		import_component.ui_interact(ui.user)
		return TRUE

#undef COMPANY_IMPORT_CARGO_CONSOLE
#undef COMPANY_IMPORT_ORDER_APP
