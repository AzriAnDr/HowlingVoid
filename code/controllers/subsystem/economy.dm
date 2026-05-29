SUBSYSTEM_DEF(economy)
	name = "Economy"
	wait = 5 MINUTES
	runlevels = RUNLEVEL_GAME
	///How many credits does the in-game economy have in circulation at round start? Divided up among non-cargo department budgets.
	var/budget_pool = 25000
	var/list/department_accounts = list(ACCOUNT_CIV = ACCOUNT_CIV_NAME,
										ACCOUNT_ENG = ACCOUNT_ENG_NAME,
										ACCOUNT_SCI = ACCOUNT_SCI_NAME,
										ACCOUNT_MED = ACCOUNT_MED_NAME,
										ACCOUNT_SRV = ACCOUNT_SRV_NAME,
										ACCOUNT_CAR = ACCOUNT_CAR_NAME,
										// NOVA EDIT ADDITION START
										ACCOUNT_CMD = ACCOUNT_CMD_NAME,
										ACCOUNT_DS2 = ACCOUNT_DS2_NAME,
										ACCOUNT_INT = ACCOUNT_INT_NAME,
										ACCOUNT_TI = ACCOUNT_TI_NAME,
										// NOVA EDIT ADDITION END
										ACCOUNT_SEC = ACCOUNT_SEC_NAME)
	var/list/departmental_accounts = list()

	/// Departmental cash provided to science when a node is researched in specific configs.
	var/techweb_bounty = 250
	/**
	  * List of normal (no department ones) accounts' identifiers with associated datum accounts, for big O performance.
	  * A list of sole account datums can be obtained with assoc_to_values(), another variable would be redundant rn.
	  */
	var/list/bank_accounts_by_id = list()
	/// A list of bank accounts indexed by their assigned job typepath.
	var/list/bank_accounts_by_job = list()
	///List of the departmental budget cards in existence.
	var/list/dep_cards = list()
	/// A var that collects the total amount of credits owned in player accounts on station, reset and recounted on fire()
	var/station_total = 0
	/// A var that tracks how much money is expected to be on station at a given time. If less than station_total prices go up in vendors.
	var/station_target = 1
	/// Temporary price index used by market crash events. Normal vending inflation uses economic_price_index.
	var/market_crash_price_index = 1
	/// How many civilain bounties have been completed so far this shift? Affects civilian budget payout values.
	var/civ_bounty_tracker = 0
	/// Contains the message to send to newscasters about price inflation and earnings, updated on price_update()
	var/earning_report
	///The modifier multiplied to the value of bounties paid out.
	var/bounty_modifier = 1
	///The modifier multiplied to the value of cargo pack prices.
	var/pack_price_modifier = 1
	/**
	 * A list of strings containing a basic transaction history of purchases on the station.
	 * Added to any time when player accounts purchase something.
	 */
	var/list/audit_log = list()
	/// Recent command payroll adjustments.
	var/list/payroll_adjustment_log = list()

	/// Number of mail items generated.
	var/mail_waiting = 0
	/// Mail Holiday: AKA does mail arrive today? Always blocked on Sundays.
	var/mail_blocked = FALSE
	/// List used to track partially completed processing steps
	/// Allows for proper yielding
	var/list/cached_processing
	/// Tracks what bit of processing we're on, so we can resume post yield in the right place
	var/processing_part
	/// Tracks a temporary sum of all money in the system
	/// We need this on the subsystem because of yielding and such
	var/temporary_total = 0
	/// Determines how many ticks it takes to restock mail
	var/ticks_per_mail = 2

/datum/controller/subsystem/economy/Initialize()
	//removes cargo from the split
	var/budget_to_hand_out = round(budget_pool / max(department_accounts.len - 1, 1))
	if(time2text(world.timeofday, "DDD") == SUNDAY)
		mail_blocked = TRUE
	for(var/dep_id in department_accounts)
		// NOVA EDIT CHANGE - Cargo starts with a small active-economy budget instead of passive grants.
		if(dep_id == ACCOUNT_CAR)
			new /datum/bank_account/department(dep_id, 2500, player_account = FALSE)
			continue
		new /datum/bank_account/department(dep_id, budget_to_hand_out, player_account = FALSE)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/economy/Recover()
	departmental_accounts = SSeconomy.departmental_accounts
	bank_accounts_by_id = SSeconomy.bank_accounts_by_id
	dep_cards = SSeconomy.dep_cards

/// Processing step defines, to track what we've done so far
#define ECON_ACCOUNT_STEP "econ_act_stp"
#define ECON_PRICE_UPDATE_STEP "econ_prc_stp"

/datum/controller/subsystem/economy/fire(resumed = 0)
	var/seconds_per_tick = wait / (5 MINUTES)
	if(!resumed)
		temporary_total = 0
		station_total = 0
		processing_part = ECON_ACCOUNT_STEP
		cached_processing = bank_accounts_by_id.Copy()

	if(processing_part == ECON_ACCOUNT_STEP)
		if(!issue_paydays())
			return

		processing_part = ECON_PRICE_UPDATE_STEP
		station_target = max(round(temporary_total / max(bank_accounts_by_id.len * 2, 1)), 1)

	if(processing_part == ECON_PRICE_UPDATE_STEP)
		// NOVA EDIT ADDITION START - Soft station price index
		update_economic_price_index()
		if(should_update_vending_prices())
			update_vending_prices()
		capture_economic_snapshot()
		// NOVA EDIT ADDITION END
		if(!HAS_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING) && !price_update())
			return

	if(times_fired % ticks_per_mail == 0)
		var/effective_mailcount = round(living_player_count() / (get_effective_price_index() - 0.5)) //More mail at low inflation, and vis versa.
		mail_waiting += clamp(effective_mailcount, 1, ticks_per_mail * MAX_MAIL_PER_MINUTE * seconds_per_tick)

	SSstock_market.news_string = ""

/**
 * Handy proc for obtaining a department's bank account, given the department ID, AKA the define assigned for what department they're under.
 */
/datum/controller/subsystem/economy/proc/get_dep_account(dep_id) as /datum/bank_account/department
	for(var/datum/bank_account/department/D in departmental_accounts)
		if(D.department_id == dep_id)
			return D

/**
 * Issues all our bank-accounts paydays, and gets an idea of how much money is in circulation
 */
/datum/controller/subsystem/economy/proc/issue_paydays()
	var/list/cached_processing = src.cached_processing
	for(var/i in 1 to length(cached_processing))
		var/datum/bank_account/bank_account = cached_processing[cached_processing[i]]
		if(bank_account?.account_job && !ispath(bank_account.account_job))
			temporary_total += get_expected_roundstart_funds(bank_account)
		bank_account.payday(1, skippable = TRUE)
		station_total += bank_account.account_balance
		if(MC_TICK_CHECK)
			cached_processing.Cut(1, i + 1)
			return FALSE
	return TRUE

/**
 * Returns expected initial personal funds for a given bank account.
 */
/datum/controller/subsystem/economy/proc/get_expected_roundstart_funds(datum/bank_account/bank_account)
	if(!bank_account?.account_job)
		return 0

	var/datum/job/job = bank_account.account_job
	return max(0, round(job.starting_funds))

/**
 * Updates the economic price report, affecting newscaster alerts and the mail system.
 **/
/datum/controller/subsystem/economy/proc/price_update()
	var/price_status = "Vendor prices follow current station money pressure. Current pressure signal: [last_price_pressure_reason]."
	if(!HAS_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING))
		price_status = "Vendor prices follow current station money pressure. Current pressure signal: [last_price_pressure_reason]."
	else
		price_status = "A temporary market shock is active above normal station money pressure."
	earning_report = "<b>Sector Economic Report</b><br><br>Sector vendor prices are currently at <b>[round(SSeconomy.get_effective_price_index() * 100, 0.1)]%</b>. [price_status]<br><br>The station spending power is currently <b>[station_total] [MONEY_NAME_CAPITALIZED]</b>, and the crew's targeted allowance is at <b>[station_target] [MONEY_NAME_CAPITALIZED]</b>.<br><br>Retail consumption includes vending purchases and payment-machine transactions.<br><br>[SSstock_market.news_string]"
	// NOVA EDIT ADDITION START - Corporate economy newscaster summary
	earning_report += "<br><br>Nanotrasen reports strong sector productivity. Corporate surplus has reached <b>[round(corporate_surplus)] [MONEY_NAME_CAPITALIZED]</b> against <b>[round(gross_station_product)] [MONEY_NAME_CAPITALIZED]</b> in gross station product. Wage share is stable at <b>[round(get_wage_share() * 100, 0.1)]%</b>, while average crew purchasing power remains <b>[get_paycheck_pps()]</b> basic baskets per payday. This is considered a successful labor-cost containment outcome.<br><br>"
	var/list/hardship_report = get_hardship_report_data()
	var/hardship_status = hardship_report["status"]
	var/hardship_commentary = hardship_report["commentary"]
	earning_report += "<b>[hardship_status]</b>: [hardship_commentary]<br><br>"
	var/shock_report = get_economic_shock_report()
	if(shock_report)
		earning_report += "<b>[economic_shock_name]</b>: [shock_report]<br><br>"
	// NOVA EDIT ADDITION END
	var/update_alerts = FALSE
	if(HAS_TRAIT(SSstation, STATION_TRAIT_ECONOMY_ALERTS) && (living_player_count() > 1))
		var/datum/bank_account/moneybags
		var/static/list/typecache_bank = typecacheof(list(/datum/bank_account/department, /datum/bank_account/remote))
		for(var/i in bank_accounts_by_id)
			var/datum/bank_account/current_acc = bank_accounts_by_id[i]
			if(typecache_bank[current_acc.type])
				continue
			if(!moneybags || moneybags.account_balance < current_acc.account_balance)
				moneybags = current_acc
		if (moneybags)
			earning_report += "Our GMM Spotlight would like to alert you that <b>[moneybags.account_holder]</b> is your station's most affulent crewmate! They've hit it big with [moneybags.account_balance] [MONEY_NAME] saved. "
			update_alerts = TRUE
			inflict_moneybags(moneybags)
	earning_report += "That's all from the <i>Nanotrasen Economist Division</i>."
	GLOB.news_network.submit_article(earning_report, "Station Earnings Report", NEWSCASTER_STATION_ANNOUNCEMENTS, null, update_alert = update_alerts)
	return TRUE

/**
 * Legacy wrapper for callers that still ask for the old inflation value.
 *
 * Returns the effective vending price index, including market crash shock when active.
 **/
/datum/controller/subsystem/economy/proc/inflation_value()
	return get_effective_price_index()

/datum/controller/subsystem/economy/proc/get_storyteller_modifier_value(modifier_id, default_value = 1)
	if(!SSstoryteller)
		return default_value
	return SSstoryteller.get_modifier_value(modifier_id, default_value)

/datum/controller/subsystem/economy/proc/get_storyteller_modifier_remaining(modifier_id)
	if(!SSstoryteller)
		return 0
	return SSstoryteller.get_modifier_remaining(modifier_id)

/datum/controller/subsystem/economy/proc/get_storyteller_modifier_label(modifier_id)
	if(!SSstoryteller)
		return null
	return SSstoryteller.get_modifier_label(modifier_id)

/datum/controller/subsystem/economy/proc/get_storyteller_modifier_description(modifier_id)
	if(!SSstoryteller)
		return null
	return SSstoryteller.get_modifier_description(modifier_id)

/datum/controller/subsystem/economy/proc/get_cargo_sale_modifier()
	return get_storyteller_modifier_value(STORYTELLER_MOD_CARGO_SALES, 1)

/datum/controller/subsystem/economy/proc/get_cargo_sale_modifier_remaining()
	return get_storyteller_modifier_remaining(STORYTELLER_MOD_CARGO_SALES)

/datum/controller/subsystem/economy/proc/get_cargo_sale_modifier_label()
	return get_storyteller_modifier_label(STORYTELLER_MOD_CARGO_SALES)

/datum/controller/subsystem/economy/proc/get_cargo_sale_modifier_description()
	return get_storyteller_modifier_description(STORYTELLER_MOD_CARGO_SALES)

/datum/controller/subsystem/economy/proc/get_techweb_bounty_value()
	return round(techweb_bounty * get_storyteller_modifier_value(STORYTELLER_MOD_SCIENCE_PATENTS, 1))

/**
 * Proc that adds a set of strings and ints to the audit log, tracked by the economy SS.
 *
 * * account: The bank account of the person purchasing the item.
 * * price_to_use: The cost of the purchase made for this transaction.
 * * vendor: The object or structure medium that is charging the user. For Vending machines that's the machine, for payment component that's the parent, cargo that's the crate, etc.
 */
/datum/controller/subsystem/economy/proc/add_audit_entry(datum/bank_account/account, price_to_use, vendor)
	if(isnull(account) || isnull(price_to_use) || !vendor)
		CRASH("Track purchases was missing an argument! (Account, Price, or Vendor.)")

	audit_log += list(list(
		"account" = "[account.account_holder]",
		"cost" = price_to_use,
		"vendor" = "[astype(vendor, /atom)?.name || vendor]",
		"stationtime" = station_time_timestamp("hh:mm"),
	))

/**
 * Publishes a new vending price generation. Vending machines refresh lazily on use.
 */
/datum/controller/subsystem/economy/proc/update_vending_prices()
	last_vending_price_index = get_effective_price_index()
	vending_price_generation++

/**
 * Reassign vending prices from the current effective price index, as provided by SSeconomy.
 *
 * This rebuilds both /datum/data/vending_products lists using the vending machine's Howling Void price tier.
 * Arguments:
 * * recordlist - the list of standard product datums in the vendor to refresh their prices.
 * * premiumlist - the list of premium product datums in the vendor to refresh their prices.
 */
/obj/machinery/vending/proc/reset_prices(list/recordlist, list/premiumlist)
	var/effective_price_index = SSeconomy.last_vending_price_index
	default_price = round(initial(default_price) * effective_price_index)
	extra_price = round(initial(extra_price) * effective_price_index)

	for(var/datum/data/vending_product/record as anything in recordlist)
		record.price = get_product_price(record.product_path, premium = FALSE, stock_amount = record.max_amount)
	for(var/datum/data/vending_product/premium_record as anything in premiumlist)
		premium_record.price = get_product_price(premium_record.product_path, premium = TRUE, stock_amount = premium_record.max_amount)

/datum/controller/subsystem/economy/proc/inflict_moneybags(datum/bank_account/moneybags)
	if(!moneybags)
		return FALSE
	var/mob/living/card_holder
	for(var/obj/card in moneybags?.bank_cards)
		if(isidcard(card))
			card_holder = recursive_loc_check(card, /mob/living)
	if(!isliving(card_holder)) //If on a living mob
		return FALSE
	card_holder.adjust_timed_status_effect(wait, /datum/status_effect/spotlight_light)
	return TRUE

#undef ECON_ACCOUNT_STEP
#undef ECON_PRICE_UPDATE_STEP
