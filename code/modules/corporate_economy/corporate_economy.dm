/// Station productivity captured by Nanotrasen rather than paid to employees.
/datum/controller/subsystem/economy
	var/corporate_export_take_rate = 0.70
	var/station_export_share = 0.30
	var/corporate_retail_take_rate = 0.25
	var/corporate_bounty_take_rate = 0.50
	var/employee_bounty_share = 0.50
	var/poverty_basket_multiplier = 1
	/// Soft station money-pressure price index for normal vending prices.
	var/economic_price_index = 1
	/// Published vending price version. Vending machines lazily refresh when this changes.
	var/vending_price_generation = 1
	var/last_vending_price_index = 1
	var/minimum_economic_price_index = 1
	var/maximum_economic_price_index = 2.5
	var/economic_price_smoothing = 0.25
	var/economic_price_deflation_smoothing = 0.10
	var/vending_price_update_threshold = 0.05
	var/last_price_pressure_reason = "stable"
	var/last_money_pressure = 1
	var/last_spending_pressure = 0
	var/last_consumption_snapshot = 0
	var/economic_history_limit = 30
	var/corporate_export_take_event_modifier = 0
	var/corporate_bounty_take_event_modifier = 0
	var/station_export_allocation_event_modifier = 0
	var/import_price_event_modifier = 1
	var/sensitive_order_reporting_intensity = 1
	var/economic_shock_name = "Normal operations"
	var/economic_shock_report = ""
	var/labor_unrest_wage_share_threshold = 0.08

	var/gross_station_product = 0
	var/real_station_product = 0
	var/corporate_surplus = 0
	var/employee_wage_pool = 0
	var/crew_consumption = 0
	var/list/gsp_by_source = list()
	var/list/consumption_by_sink = list()
	var/list/corporate_surplus_by_source = list()
	var/list/economic_event_totals = list()
	var/list/economic_event_by_source = list()
	var/list/economic_department_income = list()
	var/list/economic_history = list()

/datum/controller/subsystem/economy/proc/record_economic_event(category, source, amount, department_id = null)
	if(!category || !source || !isnum(amount))
		return

	amount = max(0, round(amount))
	if(!amount)
		return

	if(!economic_event_totals)
		economic_event_totals = list()
	if(!economic_event_by_source)
		economic_event_by_source = list()
	if(!economic_department_income)
		economic_department_income = list()

	economic_event_totals[category] = (economic_event_totals[category] || 0) + amount
	economic_event_by_source[source] = (economic_event_by_source[source] || 0) + amount
	if(department_id)
		economic_department_income[department_id] = (economic_department_income[department_id] || 0) + amount

/datum/controller/subsystem/economy/proc/record_department_income(department_id, source, amount)
	record_economic_event("department_income", source, amount, department_id)

/datum/controller/subsystem/economy/proc/record_tax_fine(source, amount, department_id = null)
	record_economic_event("tax_fine", source, amount, department_id)

/datum/controller/subsystem/economy/proc/record_grant(source, amount, department_id = null)
	record_economic_event("grant", source, amount, department_id)

/datum/controller/subsystem/economy/proc/record_transfer_activity(source, amount)
	record_economic_event("transfer", source, amount)

/datum/controller/subsystem/economy/proc/record_import_cost(source, amount, department_id = null)
	record_economic_event("import_cost", source, amount, department_id)

/datum/controller/subsystem/economy/proc/record_gsp(source, gross_amount, corporate_take = 0)
	if(!source || !isnum(gross_amount))
		return

	gross_amount = max(0, round(gross_amount))
	corporate_take = max(0, round(corporate_take))
	if(!gross_amount && !corporate_take)
		return

	if(!gsp_by_source)
		gsp_by_source = list()
	if(!corporate_surplus_by_source)
		corporate_surplus_by_source = list()

	gross_station_product += gross_amount
	gsp_by_source[source] = (gsp_by_source[source] || 0) + gross_amount
	record_economic_event("production", source, gross_amount)

	if(corporate_take)
		corporate_surplus += corporate_take
		corporate_surplus_by_source[source] = (corporate_surplus_by_source[source] || 0) + corporate_take

/datum/controller/subsystem/economy/proc/record_consumption(sink, amount, corporate_take = 0)
	if(!sink || !isnum(amount))
		return

	amount = max(0, round(amount))
	corporate_take = max(0, round(corporate_take))
	if(!amount && !corporate_take)
		return

	if(!consumption_by_sink)
		consumption_by_sink = list()
	if(!corporate_surplus_by_source)
		corporate_surplus_by_source = list()

	crew_consumption += amount
	consumption_by_sink[sink] = (consumption_by_sink[sink] || 0) + amount
	record_economic_event("consumption", sink, amount)

	if(corporate_take)
		corporate_surplus += corporate_take
		corporate_surplus_by_source[sink] = (corporate_surplus_by_source[sink] || 0) + corporate_take

/datum/controller/subsystem/economy/proc/record_wages(amount)
	if(!isnum(amount))
		return

	employee_wage_pool += max(0, round(amount))
	record_economic_event("wages", "payroll", amount)

/datum/controller/subsystem/economy/proc/get_target_economic_price_index()
	if(!bank_accounts_by_id?.len)
		return minimum_economic_price_index

	var/average_crew_money = station_total / bank_accounts_by_id.len
	var/money_pressure = average_crew_money / max(station_target, 1)
	var/recent_consumption = max(0, crew_consumption - last_consumption_snapshot)
	var/spending_pressure = recent_consumption / max(station_target * bank_accounts_by_id.len, 1)
	last_money_pressure = round(money_pressure, 0.01)
	last_spending_pressure = round(spending_pressure, 0.01)
	var/target_index = max(money_pressure, 1 + clamp(spending_pressure, 0, 0.5))
	return clamp(round(target_index, 0.01), minimum_economic_price_index, maximum_economic_price_index)

/datum/controller/subsystem/economy/proc/update_economic_price_index()
	var/target_index = get_target_economic_price_index()
	var/index_delta = target_index - economic_price_index
	var/smoothing = index_delta >= 0 ? economic_price_smoothing : economic_price_deflation_smoothing
	economic_price_index = clamp(round(economic_price_index + (index_delta * smoothing), 0.01), minimum_economic_price_index, maximum_economic_price_index)
	last_price_pressure_reason = "stable"
	if(HAS_TRAIT(src, TRAIT_MARKET_CRASHING))
		last_price_pressure_reason = "market shock"
	else if(last_spending_pressure >= 0.05 && last_spending_pressure >= last_money_pressure - 1)
		last_price_pressure_reason = "retail spending"
	else if(last_money_pressure > 1.05)
		last_price_pressure_reason = "crew liquidity"
	return economic_price_index

/datum/controller/subsystem/economy/proc/get_effective_price_index()
	var/soft_index = max(economic_price_index, minimum_economic_price_index)
	if(HAS_TRAIT(src, TRAIT_MARKET_CRASHING))
		return max(soft_index, market_crash_price_index)
	return soft_index

/datum/controller/subsystem/economy/proc/capture_economic_snapshot()
	if(!economic_history)
		economic_history = list()

	var/datum/bank_account/cargo_account = get_dep_account(ACCOUNT_CAR)
	economic_history += list(list(
		"time" = station_time_timestamp("hh:mm"),
		"cargo_balance" = round(cargo_account?.account_balance || 0),
		"gross_station_product" = round(gross_station_product),
		"corporate_surplus" = round(corporate_surplus),
		"crew_consumption" = round(crew_consumption),
		"price_index" = get_effective_price_index(),
		"station_total" = round(station_total),
		"wage_share" = get_wage_share(),
		"cargo_exports" = round(gsp_by_source?["cargo_exports"] || 0),
		"cargo_import_costs" = round(economic_event_totals?["import_cost"] || 0),
		"cargo_income" = round(economic_department_income?[ACCOUNT_CAR] || 0),
	))
	while(economic_history.len > economic_history_limit)
		economic_history.Cut(1, 2)
	last_consumption_snapshot = crew_consumption

/datum/controller/subsystem/economy/proc/should_update_vending_prices()
	return abs(get_effective_price_index() - last_vending_price_index) >= vending_price_update_threshold

/datum/controller/subsystem/economy/proc/get_reference_basket_price()
	return max(1, round((initial(/obj/machinery/vending/snack::default_price) * 2) + initial(/obj/machinery/vending/cola::default_price) + initial(/obj/machinery/vending/coffee::default_price) + initial(/obj/machinery/vending/medical::default_price) + initial(/obj/machinery/vending/tool::default_price)))

/datum/controller/subsystem/economy/proc/get_current_basket_price()
	var/effective_inflation = get_effective_price_index()
	return max(1, round(get_reference_basket_price() * effective_inflation))

/datum/controller/subsystem/economy/proc/get_price_index()
	return round(get_current_basket_price() / max(get_reference_basket_price(), 1), 0.01)

/datum/controller/subsystem/economy/proc/get_real_gsp()
	real_station_product = round(gross_station_product / max(get_price_index(), 0.1))
	return real_station_product

/datum/controller/subsystem/economy/proc/get_average_paycheck()
	var/crew_accounts = 0
	var/paycheck_total = 0
	for(var/id in bank_accounts_by_id)
		var/datum/bank_account/current_account = bank_accounts_by_id[id]
		if(!is_corporate_economy_crew_account(current_account))
			continue

		var/paycheck_value = current_account.account_job.paycheck * current_account.payday_modifier
		paycheck_value += current_account.paycheck_adjustment
		paycheck_total += max(0, round(paycheck_value))
		crew_accounts++

	return crew_accounts ? round(paycheck_total / crew_accounts, 0.01) : 0

/datum/controller/subsystem/economy/proc/get_paycheck_pps()
	return round(get_average_paycheck() / max(get_current_basket_price(), 1), 0.01)

/datum/controller/subsystem/economy/proc/get_wage_share()
	return round(employee_wage_pool / max(gross_station_product, 1), 0.001)

/datum/controller/subsystem/economy/proc/get_corporate_export_take_rate(is_bounty = FALSE)
	var/base_rate = is_bounty ? corporate_bounty_take_rate : corporate_export_take_rate
	var/event_modifier = is_bounty ? corporate_bounty_take_event_modifier : corporate_export_take_event_modifier
	return clamp(base_rate + event_modifier, 0, 0.95)

/datum/controller/subsystem/economy/proc/get_station_export_allocation_bonus(gross_amount)
	if(!isnum(gross_amount) || !station_export_allocation_event_modifier)
		return 0
	return max(0, round(gross_amount * station_export_allocation_event_modifier))

/datum/controller/subsystem/economy/proc/get_supply_pack_event_price_modifier(datum/supply_pack/pack)
	if(!pack || import_price_event_modifier == 1)
		return 1
	if(istype(pack, /datum/supply_pack/imports) || istype(pack, /datum/supply_pack/companies))
		return max(0.1, import_price_event_modifier)
	return 1

/datum/controller/subsystem/economy/proc/get_export_split_summary(gross_amount, corporate_take, station_share)
	return "Gross export value: [round(gross_amount)] [MONEY_NAME]. Corporate remittance: [round(corporate_take)] [MONEY_NAME]. Station allocation: [round(station_share)] [MONEY_NAME]. Cargo receives [round(station_share)] [MONEY_NAME] after mandatory corporate remittance."

/datum/controller/subsystem/economy/proc/get_hardship_report_data()
	var/paycheck_pps = get_paycheck_pps()
	var/current_wage_share = get_wage_share()
	var/poverty_count = get_poverty_count()
	var/crew_count = get_crew_account_count()
	var/status = "Contained"
	var/commentary = "Employee purchasing power remains within acceptable austerity parameters."

	if(gross_station_product > 0 && current_wage_share < labor_unrest_wage_share_threshold)
		status = "Labor unrest watch"
		commentary = "Wage share is below comfort guidance; productivity messaging should be intensified."
	else if(paycheck_pps < 1)
		status = "Efficient hardship"
		commentary = "Average pay cannot purchase one basic basket. Labor cost containment is outperforming."
	else if(crew_count && poverty_count >= round(crew_count * 0.5))
		status = "Broad austerity"
		commentary = "Crew liquidity stress is widespread and currently budget-neutral."

	return list(
		"status" = status,
		"commentary" = commentary,
	)

/datum/controller/subsystem/economy/proc/get_economic_shock_report()
	if(!economic_shock_report)
		return ""
	return economic_shock_report

/datum/controller/subsystem/economy/proc/get_cargo_analytics_data()
	var/datum/bank_account/cargo_account = get_dep_account(ACCOUNT_CAR)
	return list(
		"cargo_budget" = round(cargo_account?.account_balance || 0),
		"gross_station_product" = round(gross_station_product),
		"corporate_surplus" = round(corporate_surplus),
		"crew_consumption" = round(crew_consumption),
		"price_index" = get_effective_price_index(),
		"soft_price_index" = economic_price_index,
		"price_reason" = last_price_pressure_reason,
		"money_pressure" = last_money_pressure,
		"spending_pressure" = last_spending_pressure,
		"wage_share" = get_wage_share(),
		"employee_wage_pool" = round(employee_wage_pool),
		"station_total" = round(station_total),
		"cargo_exports" = round(gsp_by_source?["cargo_exports"] || 0),
		"bounty_exports" = round(gsp_by_source?["bounties"] || 0),
		"cargo_import_costs" = round(economic_event_totals?["import_cost"] || 0),
		"cargo_income" = round(economic_department_income?[ACCOUNT_CAR] || 0),
		"economic_shock_name" = economic_shock_name,
		"economic_shock_report" = economic_shock_report,
		"history" = economic_history || list(),
		"event_breakdown" = corporate_economy_source_breakdown(economic_event_totals),
		"source_breakdown" = corporate_economy_source_breakdown(economic_event_by_source),
		"department_income" = corporate_economy_source_breakdown(economic_department_income),
	)

/datum/controller/subsystem/economy/proc/clear_economic_shock()
	corporate_export_take_event_modifier = 0
	corporate_bounty_take_event_modifier = 0
	station_export_allocation_event_modifier = 0
	import_price_event_modifier = 1
	sensitive_order_reporting_intensity = 1
	economic_shock_name = "Normal operations"
	economic_shock_report = ""

/datum/controller/subsystem/economy/proc/apply_corporate_audit()
	clear_economic_shock()
	corporate_export_take_event_modifier = 0.15
	corporate_bounty_take_event_modifier = 0.10
	economic_shock_name = "Corporate audit"
	economic_shock_report = "Nanotrasen audit controls are active. Export remittance has been increased pending productivity validation."

/datum/controller/subsystem/economy/proc/apply_supply_subsidy()
	clear_economic_shock()
	station_export_allocation_event_modifier = 0.15
	economic_shock_name = "Supply subsidy"
	economic_shock_report = "Temporary logistics subsidy is active. Station export allocation has been improved for essential continuity."

/datum/controller/subsystem/economy/proc/apply_labor_unrest_report()
	clear_economic_shock()
	economic_shock_name = "Labor unrest report"
	economic_shock_report = "Labor sentiment reporting is active. No payroll corrections are authorized at this time."

/datum/controller/subsystem/economy/proc/apply_black_market_glut()
	clear_economic_shock()
	import_price_event_modifier = 0.75
	sensitive_order_reporting_intensity = 2
	economic_shock_name = "Black market glut"
	economic_shock_report = "Import markets are temporarily oversupplied. Restricted procurement remains subject to enhanced logging."

/datum/controller/subsystem/economy/proc/log_sensitive_cargo_order(datum/supply_pack/pack, orderer_name, orderer_rank, payment_source, access_mismatch = FALSE, atom/source)
	if(!pack || !corporate_economy_is_sensitive_supply_pack(pack))
		return

	var/access_text = access_mismatch ? "access mismatch" : "authorized access"
	var/log_text = "Sensitive cargo order: [orderer_name || "Unknown"] ([orderer_rank || "Unknown"]) ordered [pack.name] using [payment_source || "unknown funds"]; [access_text]."
	if(sensitive_order_reporting_intensity > 1)
		log_text += " Enhanced reporting active."
	log_econ(log_text)
	if(source)
		source.investigate_log(log_text, INVESTIGATE_CARGO)

/datum/controller/subsystem/economy/proc/get_poverty_count()
	var/poverty_line = get_current_basket_price() * poverty_basket_multiplier
	var/poverty_count = 0
	for(var/id in bank_accounts_by_id)
		var/datum/bank_account/current_account = bank_accounts_by_id[id]
		if(!is_corporate_economy_crew_account(current_account))
			continue
		if(current_account.account_balance < poverty_line)
			poverty_count++

	return poverty_count

/datum/controller/subsystem/economy/proc/get_crew_account_count()
	var/crew_accounts = 0
	for(var/id in bank_accounts_by_id)
		var/datum/bank_account/current_account = bank_accounts_by_id[id]
		if(is_corporate_economy_crew_account(current_account))
			crew_accounts++

	return crew_accounts

/datum/controller/subsystem/economy/proc/is_corporate_economy_crew_account(datum/bank_account/current_account)
	if(!current_account?.account_job || ispath(current_account.account_job))
		return FALSE
	if(!(current_account.account_job.job_flags & JOB_CREW_MANIFEST))
		return FALSE
	if(istype(current_account, /datum/bank_account/department) || istype(current_account, /datum/bank_account/remote))
		return FALSE
	return TRUE

/proc/corporate_economy_source_breakdown(list/source_values)
	var/list/breakdown = list()
	if(!source_values)
		return breakdown

	for(var/source in source_values)
		breakdown += list(list(
			"source" = "[source]",
			"amount" = round(source_values[source]),
		))
	return breakdown

/proc/corporate_economy_is_sensitive_supply_pack(datum/supply_pack/pack)
	if(!pack)
		return FALSE
	if(istype(pack, /datum/supply_pack/security) || istype(pack, /datum/supply_pack/imports) || istype(pack, /datum/supply_pack/companies))
		if(pack.access || pack.access_view || pack.access_any || pack.order_flags & (ORDER_CONTRABAND|ORDER_EMAG_ONLY|ORDER_DANGEROUS))
			return TRUE

	var/name_text = lowertext("[pack.name] [pack.type] [pack.group]")
	for(var/keyword in list("ammo", "armory", "ballistic", "battle rifle", "carbine", "combat", "disabler", "gun", "laser", "pistol", "rifle", "shell", "shotgun", "smg", "thermal", "weapon"))
		if(findtext(name_text, keyword))
			return TRUE
	return FALSE

/proc/corporate_economy_is_external_budget_id(department_id)
	return department_id in list(ACCOUNT_DS2, ACCOUNT_INT, ACCOUNT_TI)

/proc/corporate_economy_lacks_supply_pack_access(datum/supply_pack/pack, list/access, bypass = FALSE)
	if(!pack || bypass)
		return FALSE
	if(!pack.access && !pack.access_view && !pack.access_any)
		return FALSE
	if(!access)
		access = list()
	if(pack.access && !(pack.access in access))
		return TRUE
	if(pack.access_view && !(pack.access_view in access))
		return TRUE
	if(pack.access_any)
		for(var/required_access in pack.access_any)
			if(required_access in access)
				return FALSE
		return TRUE
	return FALSE

/proc/corporate_economy_announce_sensitive_cargo_order(atom/speaker, datum/supply_pack/pack, orderer_name, orderer_rank, payment_source, access_mismatch = TRUE)
	if(!speaker || !pack || !corporate_economy_is_sensitive_supply_pack(pack))
		return
	SSeconomy.log_sensitive_cargo_order(pack, orderer_name, orderer_rank, payment_source, access_mismatch, speaker)
	aas_config_announce(/datum/aas_config_entry/corporate_economy_sensitive_cargo_order, list(
		"ORDER" = pack.name,
		"PERSON" = orderer_name || "Unknown",
		"RANK" = orderer_rank || "Unknown",
		"PAYMENT" = payment_source || "unknown funds",
		"ACCESS" = access_mismatch ? "access mismatch noted" : "access confirmed",
	), speaker, list(RADIO_CHANNEL_SUPPLY), "Message")

/datum/aas_config_entry/corporate_economy_sensitive_cargo_order
	name = "Cargo Alert: Sensitive Order"
	announcement_lines_map = list(
		"Message" = "Sensitive cargo order placed by %PERSON, %RANK: %ORDER. Payment source: %PAYMENT. Review status: %ACCESS.",
	)
	vars_and_tooltips_map = list(
		"ORDER" = "will be replaced with order name.",
		"PERSON" = "will be replaced with orderer name.",
		"RANK" = "will be replaced with orderer rank.",
		"PAYMENT" = "will be replaced with payment source.",
		"ACCESS" = "will be replaced with access review status.",
	)
