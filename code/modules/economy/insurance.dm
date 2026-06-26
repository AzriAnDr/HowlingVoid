/datum/medical_insurance_claim
	/// Bank account paying for the patient's treatment.
	var/datum/bank_account/patient_account
	/// Patient tied to this claim.
	var/mob/living/patient
	/// Medic who opened the claim and must finalize it.
	var/mob/living/medic
	/// Bank account receiving the payout.
	var/datum/bank_account/medic_account
	/// Claim opening time.
	var/opened_at
	/// Claim expiry time.
	var/expires_at
	/// Payout calculated when the claim was opened.
	var/estimated_payout

/datum/medical_insurance_claim/New(datum/bank_account/new_patient_account, mob/living/new_patient, mob/living/new_medic, datum/bank_account/new_medic_account, new_estimated_payout)
	patient_account = new_patient_account
	patient = new_patient
	medic = new_medic
	medic_account = new_medic_account
	opened_at = world.time
	expires_at = world.time + MEDICAL_INSURANCE_TREATMENT_WINDOW
	estimated_payout = new_estimated_payout
	if(patient)
		RegisterSignal(patient, COMSIG_QDELETING, PROC_REF(on_participant_qdeleted))
	if(medic)
		RegisterSignal(medic, COMSIG_QDELETING, PROC_REF(on_participant_qdeleted))
	addtimer(CALLBACK(src, PROC_REF(expire)), MEDICAL_INSURANCE_TREATMENT_WINDOW)

/datum/medical_insurance_claim/Destroy()
	if(patient)
		UnregisterSignal(patient, COMSIG_QDELETING)
	if(medic)
		UnregisterSignal(medic, COMSIG_QDELETING)
	if(patient_account && patient_account.active_insurance_claim == src)
		patient_account.active_insurance_claim = null
	patient_account = null
	patient = null
	medic = null
	medic_account = null
	return ..()

/datum/medical_insurance_claim/proc/on_participant_qdeleted(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/medical_insurance_claim/proc/expire()
	if(QDELETED(src) || world.time < expires_at)
		return
	qdel(src)

/datum/bank_account/proc/initialize_medical_insurance()
	if(!add_to_accounts || !istype(account_job, /datum/job))
		return
	insurance_balance = max(insurance_balance, get_starting_medical_insurance_balance())

/datum/bank_account/proc/get_starting_medical_insurance_balance()
	if(!istype(account_job, /datum/job))
		return 0

	var/start_amount = MEDICAL_INSURANCE_START_DEFAULT
	if((account_job.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY) || account_job.paycheck_department == ACCOUNT_SEC || istype(account_job, /datum/job/shaft_miner))
		start_amount = max(start_amount, MEDICAL_INSURANCE_START_RISK)
	if((account_job.departments_bitflags & DEPARTMENT_BITFLAG_MEDICAL) || account_job.paycheck_department == ACCOUNT_MED || (account_job.job_flags & JOB_HEAD_OF_STAFF))
		start_amount = max(start_amount, MEDICAL_INSURANCE_START_PRIORITY)
	return start_amount

/datum/bank_account/proc/get_payday_insurance_contribution(payday_amount)
	if(payday_amount <= 0)
		return 0
	var/exact_contribution = (payday_amount * MEDICAL_INSURANCE_PAYDAY_RATE) + insurance_payday_remainder
	var/contribution = FLOOR(exact_contribution, 1)
	insurance_payday_remainder = exact_contribution - contribution
	return contribution

/datum/bank_account/proc/adjust_insurance_money(amount, reason)
	if(!isnum(amount) || !amount)
		return TRUE
	if(amount < 0 && insurance_balance < -amount)
		return FALSE
	insurance_balance += amount
	if(reason)
		add_log_to_history(amount, reason)
	return TRUE

/datum/bank_account/proc/fund_insurance_from_account(datum/bank_account/funding_account, amount, reason)
	if(amount <= 0)
		return TRUE
	if(isnull(funding_account) || !funding_account.adjust_money(-amount, reason))
		return FALSE
	adjust_insurance_money(amount, reason)
	SSblackbox.record_feedback("amount", "insurance_credits_added", amount)
	log_econ("[amount] [MONEY_NAME] were transferred from [funding_account.account_holder]'s account to [account_holder]'s medical insurance account.")
	return TRUE

/datum/bank_account/proc/transfer_money_to_insurance(amount, reason = "Insurance: Personal Contribution")
	if(amount <= 0 || !adjust_money(-amount, reason))
		return FALSE
	adjust_insurance_money(amount, reason)
	SSblackbox.record_feedback("amount", "insurance_credits_added", amount)
	log_econ("[amount] [MONEY_NAME] were transferred from [account_holder]'s bank account to their medical insurance account.")
	return TRUE

/datum/bank_account/proc/can_use_medical_insurance(mob/living/user)
	if(!user)
		return FALSE
	var/datum/bank_account/user_account = user.get_bank_account()
	if(!user_account || !istype(user_account.account_job, /datum/job))
		return FALSE
	return user_account.account_job.paycheck_department == ACCOUNT_MED

/datum/bank_account/proc/grant_medical_insurance_scan_access(mob/living/medic, mob/living/patient)
	if(!medic || !patient)
		return
	if(isnull(LAZYACCESS(insurance_scan_access, medic)))
		RegisterSignal(medic, COMSIG_QDELETING, PROC_REF(on_medical_insurance_scan_user_qdeleted))
	LAZYSET(insurance_scan_access, medic, world.time + MEDICAL_INSURANCE_SCAN_LINK_TIME)
	LAZYSET(insurance_scan_patients, medic, patient)

/datum/bank_account/proc/remove_medical_insurance_scan_access(mob/living/medic)
	if(!LAZYACCESS(insurance_scan_access, medic))
		return
	insurance_scan_access -= medic
	insurance_scan_patients -= medic
	UnregisterSignal(medic, COMSIG_QDELETING)

/datum/bank_account/proc/on_medical_insurance_scan_user_qdeleted(datum/source)
	SIGNAL_HANDLER

	var/mob/living/medic = source
	remove_medical_insurance_scan_access(medic)

/datum/bank_account/proc/clear_medical_insurance_scan_access()
	if(!insurance_scan_access)
		return
	for(var/mob/living/medic as anything in insurance_scan_access)
		UnregisterSignal(medic, COMSIG_QDELETING)
	insurance_scan_access = null
	insurance_scan_patients = null

/datum/bank_account/proc/get_medical_insurance_scan_patient(mob/living/medic)
	var/expires_at = LAZYACCESS(insurance_scan_access, medic)
	if(!expires_at)
		return null
	if(world.time > expires_at)
		remove_medical_insurance_scan_access(medic)
		return null
	var/mob/living/patient = LAZYACCESS(insurance_scan_patients, medic)
	if(QDELETED(patient))
		remove_medical_insurance_scan_access(medic)
		return null
	return patient

/datum/bank_account/Topic(href, list/href_list)
	. = ..()
	if(!href_list["medical_insurance_action"])
		return
	var/mob/living/medic = usr
	if(!istype(medic))
		return
	var/mob/living/patient = get_medical_insurance_scan_patient(medic)
	if(!patient)
		to_chat(medic, span_warning("Your insurance scan has expired. Scan the patient again."))
		return
	switch(href_list["medical_insurance_action"])
		if("open")
			open_medical_insurance_claim(patient, medic)
		if("finalize")
			finalize_medical_insurance_claim(patient, medic)

/datum/bank_account/proc/get_medical_insurance_claim_blocker(mob/living/patient, mob/living/medic)
	if(!patient || !medic)
		return "Invalid claim target."
	if(patient == medic)
		return "You cannot open an insurance claim on yourself."
	if(!can_use_medical_insurance(medic))
		return "Only medical department employees can process insurance claims."
	if(insurance_balance < MEDICAL_INSURANCE_MIN_PAYOUT)
		return "The patient's insurance account has insufficient funds."
	if(active_insurance_claim)
		return "This patient already has an active insurance claim."
	if(world.time < next_insurance_claim_time)
		return "This patient's claim cooldown is still active."
	if(medical_insurance_billable_value(patient, include_base_fee = FALSE) <= 0)
		return "No billable injuries were detected."
	return null

/datum/bank_account/proc/open_medical_insurance_claim(mob/living/patient, mob/living/medic)
	var/blocker = get_medical_insurance_claim_blocker(patient, medic)
	if(blocker)
		to_chat(medic, span_warning(blocker))
		return FALSE

	var/estimated_value = medical_insurance_billable_value(patient)
	var/estimated_payout = clamp(max(round(estimated_value), MEDICAL_INSURANCE_MIN_PAYOUT), MEDICAL_INSURANCE_MIN_PAYOUT, MEDICAL_INSURANCE_MAX_PAYOUT)
	estimated_payout = min(estimated_payout, insurance_balance)
	if(estimated_payout < MEDICAL_INSURANCE_MIN_PAYOUT)
		to_chat(medic, span_warning("The patient's insurance account cannot cover the minimum claim payout."))
		return FALSE

	var/datum/bank_account/medic_account = medic.get_bank_account()
	if(!medic_account)
		to_chat(medic, span_warning("You need a linked bank account to process insurance claims."))
		return FALSE

	active_insurance_claim = new /datum/medical_insurance_claim(src, patient, medic, medic_account, estimated_payout)
	next_insurance_claim_time = world.time + MEDICAL_INSURANCE_CLAIM_COOLDOWN
	to_chat(medic, span_notice("Insurance claim opened. Heal and scan [patient] again within [DisplayTimeText(MEDICAL_INSURANCE_TREATMENT_WINDOW)] to receive up to [estimated_payout] [MONEY_NAME]."))
	bank_card_talk("Medical insurance claim opened for [estimated_payout] [MONEY_SYMBOL].")
	log_econ("[medic] opened a [estimated_payout] [MONEY_NAME] medical insurance claim for [patient] on [account_holder]'s account.")
	return TRUE

/datum/bank_account/proc/finalize_medical_insurance_claim(mob/living/patient, mob/living/medic)
	if(!active_insurance_claim)
		to_chat(medic, span_warning("This patient has no active insurance claim."))
		return FALSE
	if(active_insurance_claim.patient != patient)
		to_chat(medic, span_warning("This insurance claim is tied to another patient."))
		return FALSE
	if(active_insurance_claim.medic != medic || active_insurance_claim.medic_account != medic.get_bank_account())
		to_chat(medic, span_warning("Only the medic who opened this claim can finalize it."))
		return FALSE
	if(world.time > active_insurance_claim.expires_at)
		to_chat(medic, span_warning("This insurance claim has expired."))
		qdel(active_insurance_claim)
		return FALSE
	if(medical_insurance_remaining_treatment_value(patient) > 0)
		to_chat(medic, span_warning("The patient still has treatable billable injuries. Treat them before finalizing the claim."))
		return FALSE

	var/payout = min(active_insurance_claim.estimated_payout, insurance_balance, MEDICAL_INSURANCE_MAX_PAYOUT)
	if(payout < MEDICAL_INSURANCE_MIN_PAYOUT)
		to_chat(medic, span_warning("The patient's insurance account no longer has enough funds to pay this claim."))
		qdel(active_insurance_claim)
		return FALSE

	var/datum/bank_account/medic_account = active_insurance_claim.medic_account
	if(!adjust_insurance_money(-payout, "Medical Insurance: Claim Payment"))
		to_chat(medic, span_warning("The patient's insurance account could not be charged."))
		return FALSE
	if(!medic_account.adjust_money(payout, "Medical Insurance: [account_holder]"))
		adjust_insurance_money(payout, "Medical Insurance: Failed Claim Refund")
		to_chat(medic, span_warning("Your bank account could not receive the insurance payout."))
		return FALSE

	to_chat(medic, span_notice("Insurance claim finalized. You receive [payout] [MONEY_NAME]."))
	bank_card_talk("Medical insurance paid [payout] [MONEY_SYMBOL] to [medic].")
	SSblackbox.record_feedback("amount", "insurance_claim_payout", payout)
	log_econ("[payout] [MONEY_NAME] were paid from [account_holder]'s medical insurance account to [medic_account.account_holder]'s account.")
	qdel(active_insurance_claim)
	return TRUE

/proc/get_medical_insurance_healthscan_line(mob/user, mob/living/target)
	if(!isliving(user) || !target)
		return null
	var/mob/living/living_user = user
	var/datum/bank_account/patient_account = target.get_bank_account()
	if(!patient_account || !patient_account.can_use_medical_insurance(living_user))
		return null

	patient_account.grant_medical_insurance_scan_access(living_user, target)
	var/base_line = "<hr><span class='info ml-1'>Insurance balance: [patient_account.insurance_balance] [MONEY_SYMBOL]. "
	if(patient_account.active_insurance_claim)
		if(patient_account.active_insurance_claim.medic == living_user)
			var/time_left = max(patient_account.active_insurance_claim.expires_at - world.time, 0)
			return "[base_line]<a href='byond://?src=[REF(patient_account)];medical_insurance_action=finalize'>Finalize insurance claim</a> ([DisplayTimeText(time_left)] left).</span><br>"
		return "[base_line]Active claim opened by [patient_account.active_insurance_claim.medic].</span><br>"

	var/blocker = patient_account.get_medical_insurance_claim_blocker(target, living_user)
	if(blocker)
		if(world.time < patient_account.next_insurance_claim_time)
			var/cooldown_left = patient_account.next_insurance_claim_time - world.time
			return "[base_line]Claim unavailable: cooldown [DisplayTimeText(cooldown_left)].</span><br>"
		return "[base_line]Claim unavailable: [blocker]</span><br>"

	var/estimated_value = medical_insurance_billable_value(target)
	var/estimated_payout = clamp(max(round(estimated_value), MEDICAL_INSURANCE_MIN_PAYOUT), MEDICAL_INSURANCE_MIN_PAYOUT, MEDICAL_INSURANCE_MAX_PAYOUT)
	estimated_payout = min(estimated_payout, patient_account.insurance_balance)
	return "[base_line]<a href='byond://?src=[REF(patient_account)];medical_insurance_action=open'>Calculate insurance</a> (estimated payout: [estimated_payout] [MONEY_SYMBOL]).</span><br>"

/proc/medical_insurance_billable_value(mob/living/patient, include_base_fee = TRUE)
	if(!patient)
		return 0

	var/value = 0
	value += medical_insurance_damage_price(patient)
	value += medical_insurance_blood_price(patient)
	value += medical_insurance_temperature_price(patient)
	value += medical_insurance_disease_price(patient)
	if(!patient.appears_alive())
		value += MEDICAL_INSURANCE_DEATH_PRICE
	if(iscarbon(patient))
		var/mob/living/carbon/carbon_patient = patient
		value += medical_insurance_wound_price(carbon_patient)
		value += medical_insurance_embedded_price(carbon_patient)
		value += length(carbon_patient.get_missing_limbs()) * MEDICAL_INSURANCE_MISSING_LIMB_PRICE
	if(ishuman(patient))
		var/mob/living/carbon/human/human_patient = patient
		value += medical_insurance_nonfunctional_organ_price(human_patient)

	if(value > 0 && include_base_fee)
		value += MEDICAL_INSURANCE_BASE_FEE
	return value

/proc/medical_insurance_remaining_treatment_value(mob/living/patient)
	var/value = medical_insurance_billable_value(patient, include_base_fee = FALSE)
	if(ishuman(patient))
		var/mob/living/carbon/human/human_patient = patient
		value -= medical_insurance_nonfunctional_organ_price(human_patient)
	return max(value, 0)

/proc/medical_insurance_damage_price(mob/living/patient)
	var/total_damage = max(patient.get_brute_loss(), 0) + max(patient.get_fire_loss(), 0) + max(patient.get_tox_loss(), 0) + max(patient.get_oxy_loss(), 0)
	if(total_damage <= MEDICAL_INSURANCE_DAMAGE_TOLERANCE)
		return 0
	return ceil(total_damage / MEDICAL_INSURANCE_DAMAGE_DIVISOR)

/proc/medical_insurance_wound_price(mob/living/carbon/patient)
	var/value = 0
	for(var/datum/wound/wound as anything in patient.all_wounds)
		switch(wound.severity)
			if(WOUND_SEVERITY_TRIVIAL)
				value += 5
			if(WOUND_SEVERITY_MODERATE)
				value += 12
			if(WOUND_SEVERITY_SEVERE)
				value += 25
			if(WOUND_SEVERITY_CRITICAL to INFINITY)
				value += 40
	return value

/proc/medical_insurance_embedded_price(mob/living/carbon/patient)
	var/embedded_count = 0
	for(var/zone in patient.get_all_limbs())
		var/obj/item/bodypart/limb = patient.get_bodypart(zone)
		if(limb)
			embedded_count += LAZYLEN(limb.embedded_objects)
	return min(embedded_count * MEDICAL_INSURANCE_EMBED_PRICE, MEDICAL_INSURANCE_EMBED_CAP)

/proc/medical_insurance_blood_price(mob/living/patient)
	if(!patient.get_bloodtype())
		return 0
	var/cached_blood_volume = patient.get_blood_volume(apply_modifiers = TRUE)
	var/blood_percent = round((cached_blood_volume / BLOOD_VOLUME_NORMAL) * 100)
	if(blood_percent >= MEDICAL_INSURANCE_BLOOD_SAFE_PERCENT)
		return 0
	if(cached_blood_volume <= BLOOD_VOLUME_OKAY)
		return MEDICAL_INSURANCE_BLOOD_CRITICAL_PRICE
	return MEDICAL_INSURANCE_BLOOD_LOW_PRICE

/proc/medical_insurance_nonfunctional_organ_price(mob/living/carbon/human/patient)
	var/nonfunctional_organs = 0
	for(var/obj/item/organ/organ as anything in patient.organs)
		if(medical_insurance_is_brain_organ(organ))
			continue
		if(!(organ.organ_flags & ORGAN_FAILING))
			continue
		nonfunctional_organs++
	return nonfunctional_organs * MEDICAL_INSURANCE_NONFUNCTIONAL_ORGAN_PRICE

/proc/medical_insurance_is_brain_organ(obj/item/organ/organ)
	if(!organ)
		return FALSE
	if(organ.slot == ORGAN_SLOT_BRAIN)
		return TRUE
	return findtext("[organ.slot]", "brain")

/proc/medical_insurance_temperature_price(mob/living/patient)
	var/heat_limit = patient.get_body_temp_heat_damage_limit()
	var/cold_limit = patient.get_body_temp_cold_damage_limit()
	if(patient.bodytemperature >= heat_limit)
		return patient.bodytemperature >= heat_limit + 20 ? MEDICAL_INSURANCE_TEMP_SEVERE_PRICE : MEDICAL_INSURANCE_TEMP_MILD_PRICE
	if(patient.bodytemperature <= cold_limit)
		return patient.bodytemperature <= cold_limit - 20 ? MEDICAL_INSURANCE_TEMP_SEVERE_PRICE : MEDICAL_INSURANCE_TEMP_MILD_PRICE
	return 0

/proc/medical_insurance_disease_price(mob/living/patient)
	var/visible_negative_diseases = 0
	for(var/datum/disease/disease as anything in patient.diseases)
		if(disease.visibility_flags & HIDDEN_SCANNER)
			continue
		if(disease.severity == DISEASE_SEVERITY_POSITIVE || disease.severity == DISEASE_SEVERITY_NONTHREAT || disease.severity == DISEASE_SEVERITY_UNCURABLE)
			continue
		visible_negative_diseases++
	return min(visible_negative_diseases * MEDICAL_INSURANCE_DISEASE_PRICE, MEDICAL_INSURANCE_DISEASE_CAP)

/obj/item/card/id/proc/transfer_to_insurance(mob/living/user)
	if(!registered_account)
		to_chat(user, span_warning("This ID has no linked bank account."))
		return FALSE
	if(loc != user)
		to_chat(user, span_warning("You must be holding the ID to continue!"))
		return FALSE
	var/amount_to_transfer = tgui_input_number(user, "How much do you want to move into medical insurance? (Max: [registered_account.account_balance] [MONEY_SYMBOL])", "Fund Insurance", max_value = registered_account.account_balance)
	if(!amount_to_transfer || QDELETED(user) || QDELETED(src) || issilicon(user) || loc != user)
		return FALSE
	if(!alt_click_can_use_id(user))
		return FALSE
	if(!registered_account.transfer_money_to_insurance(amount_to_transfer))
		var/difference = amount_to_transfer - registered_account.account_balance
		registered_account.bank_card_talk(span_warning("ERROR: The linked account requires [difference] more [MONEY_NAME_AUTOPURAL(difference)] to fund insurance."), TRUE)
		return FALSE
	to_chat(user, span_notice("You move [amount_to_transfer] [MONEY_NAME] into medical insurance. Insurance balance: [registered_account.insurance_balance] [MONEY_SYMBOL]."))
	return TRUE
