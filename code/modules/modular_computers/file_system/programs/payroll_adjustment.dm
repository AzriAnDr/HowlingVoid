#define MAX_PAYROLL_ADJUSTMENT 100
#define MAX_PAYROLL_REASON_LENGTH 180
#define PAYROLL_LOG_LIMIT 30
#define PAYROLL_MODE_AMOUNT "amount"
#define PAYROLL_MODE_PERCENT "percent"

/datum/computer_file/program/payroll_adjustment
	filename = "payrolladjust"
	filedesc = "Payroll Adjustment"
	downloader_category = PROGRAM_CATEGORY_EQUIPMENT
	program_open_overlay = "id"
	extended_desc = "A command payroll application for targeted salary increases and reductions funded by the station budget."
	run_access = list(ACCESS_CAPTAIN, ACCESS_HOP)
	download_access = list(ACCESS_CAPTAIN, ACCESS_HOP)
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	size = 4
	tgui_id = "NtosPayrollAdjustment"
	program_icon = "money-check-dollar"
	can_run_on_flags = PROGRAM_ALL

/datum/computer_file/program/payroll_adjustment/proc/can_adjust_payroll()
	var/obj/item/card/id/user_id = computer?.stored_id?.GetID()
	if(!user_id)
		return FALSE
	var/list/user_access = user_id.GetAccess()
	return (ACCESS_CAPTAIN in user_access) || (ACCESS_HOP in user_access)

/datum/computer_file/program/payroll_adjustment/proc/get_account_by_id(account_id)
	if(!account_id)
		return null
	var/datum/bank_account/account = SSeconomy.bank_accounts_by_id["[account_id]"]
	if(!account?.account_job || ispath(account.account_job))
		return null
	return account

/datum/computer_file/program/payroll_adjustment/proc/get_base_paycheck(datum/bank_account/account)
	if(!account?.account_job)
		return 0
	return clamp(round(account.account_job.paycheck * account.payday_modifier), 0, PAYCHECK_CREW)

/datum/computer_file/program/payroll_adjustment/proc/get_basis_options()
	return list("Performance", "Seniority", "Special Achievement", "Other")

/datum/computer_file/program/payroll_adjustment/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(!can_adjust_payroll())
		return TRUE

	switch(action)
		if("set_adjustment")
			var/datum/bank_account/target_account = get_account_by_id(params["account_id"])
			if(!target_account)
				return TRUE

			var/base_paycheck = get_base_paycheck(target_account)
			var/adjustment = 0
			switch(params["mode"])
				if(PAYROLL_MODE_PERCENT)
					adjustment = round(base_paycheck * text2num("[params["percent"]]") / 100)
				else
					adjustment = round(text2num("[params["amount"]]"))
			adjustment = clamp(adjustment, -MAX_PAYROLL_ADJUSTMENT, MAX_PAYROLL_ADJUSTMENT)
			adjustment = max(adjustment, -base_paycheck)

			var/list/basis_options = get_basis_options()
			var/basis = params["basis"]
			if(!(basis in basis_options))
				to_chat(usr, span_warning("A valid payroll adjustment basis is required."))
				return TRUE

			var/reason = trim(html_encode(params["reason"] || ""), MAX_PAYROLL_REASON_LENGTH)
			if(!reason)
				to_chat(usr, span_warning("A payroll adjustment reason is required."))
				return TRUE

			var/obj/item/card/id/user_id = computer.stored_id?.GetID()
			var/authorized_by = user_id?.registered_name || usr?.real_name || "Unknown"
			target_account.paycheck_adjustment = adjustment
			target_account.paycheck_adjustment_reason = reason
			target_account.paycheck_adjustment_basis = basis
			target_account.paycheck_adjustment_authorized_by = authorized_by

			var/list/log_entry = list(
				"time" = station_time_timestamp(),
				"employee" = target_account.account_holder,
				"job" = target_account.account_job.title,
				"adjustment" = adjustment,
				"new_paycheck" = base_paycheck + adjustment,
				"basis" = basis,
				"reason" = reason,
				"authorized_by" = authorized_by,
			)
			SSeconomy.payroll_adjustment_log = list(log_entry) + SSeconomy.payroll_adjustment_log
			if(length(SSeconomy.payroll_adjustment_log) > PAYROLL_LOG_LIMIT)
				SSeconomy.payroll_adjustment_log.Cut(PAYROLL_LOG_LIMIT + 1)

			target_account.add_log_to_history(adjustment, "Payroll Adjustment: [basis] - [reason]")
			log_econ("[authorized_by] set [target_account.account_holder]'s payroll adjustment to [adjustment] [MONEY_NAME] per payday. Basis: [basis]. Reason: [reason]")
			playsound(computer, 'sound/machines/terminal/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE

/datum/computer_file/program/payroll_adjustment/ui_data(mob/user)
	var/list/data = list()
	data["authed"] = can_adjust_payroll()
	data["max_adjustment"] = MAX_PAYROLL_ADJUSTMENT
	data["basis_options"] = get_basis_options()

	var/datum/bank_account/station_account = SSeconomy.get_dep_account(ACCOUNT_CIV)
	data["station_budget"] = station_account?.account_balance || 0
	// NOVA EDIT ADDITION START - Department budget visibility
	var/list/department_budgets = list()
	var/total_department_budget = 0
	for(var/datum/bank_account/department/department_account in SSeconomy.departmental_accounts)
		var/balance = round(department_account.account_balance)
		total_department_budget += balance
		var/role = "Department"
		if(department_account.department_id == ACCOUNT_CIV)
			role = "Station payroll fund"
		else if(department_account.department_id == ACCOUNT_CAR)
			role = "Cargo operations"

		department_budgets += list(list(
			"id" = department_account.department_id,
			"name" = department_account.account_holder,
			"balance" = balance,
			"role" = role,
			"is_station" = department_account.department_id == ACCOUNT_CIV,
			"is_cargo" = department_account.department_id == ACCOUNT_CAR,
		))
	data["department_budgets"] = department_budgets
	data["total_department_budget"] = total_department_budget
	data["visible_station_budget"] = total_department_budget
	// NOVA EDIT ADDITION END

	var/list/accounts = list()
	var/total_positive_adjustments = 0
	for(var/account_id in SSeconomy.bank_accounts_by_id)
		var/datum/bank_account/account = SSeconomy.bank_accounts_by_id[account_id]
		if(!account?.account_job || ispath(account.account_job))
			continue
		if(!(account.account_job.job_flags & JOB_CREW_MEMBER))
			continue

		var/base_paycheck = get_base_paycheck(account)
		var/current_adjustment = clamp(account.paycheck_adjustment, -base_paycheck, MAX_PAYROLL_ADJUSTMENT)
		if(current_adjustment > 0)
			total_positive_adjustments += current_adjustment

		accounts += list(list(
			"id" = "[account.account_id]",
			"name" = account.account_holder,
			"job" = account.account_job.title,
			"department" = account.account_job.paycheck_department,
			"balance" = account.account_balance,
			"base_paycheck" = base_paycheck,
			"adjustment" = current_adjustment,
			"current_paycheck" = base_paycheck + current_adjustment,
			"basis" = account.paycheck_adjustment_basis,
			"reason" = account.paycheck_adjustment_reason,
			"authorized_by" = account.paycheck_adjustment_authorized_by,
		))

	data["accounts"] = accounts
	data["positive_adjustments"] = total_positive_adjustments
	data["payroll_log"] = SSeconomy.payroll_adjustment_log
	return data

#undef MAX_PAYROLL_ADJUSTMENT
#undef MAX_PAYROLL_REASON_LENGTH
#undef PAYROLL_LOG_LIMIT
#undef PAYROLL_MODE_AMOUNT
#undef PAYROLL_MODE_PERCENT
