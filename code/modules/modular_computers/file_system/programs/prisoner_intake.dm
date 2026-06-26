/datum/computer_file/program/prisoner_intake
	filename = "prisonerintake"
	filedesc = "Prisoner Intake"
	extended_desc = "A brig processing application for assigning prisoner IDs and filing incarceration records."
	downloader_category = PROGRAM_CATEGORY_SECURITY
	program_open_overlay = "id"
	program_flags = PROGRAM_ON_NTNET_STORE
	can_run_on_flags = PROGRAM_PDA | PROGRAM_LAPTOP
	run_access = list(ACCESS_BRIG)
	download_access = list(ACCESS_BRIG)
	always_update_ui = TRUE
	size = 4
	tgui_id = "NtosPrisonerIntake"
	program_icon = "file-signature"
	detomatix_resistance = DETOMATIX_RESIST_MINOR

	/// Crew record selected through the intake app.
	var/datum/record/crew/target_record
	/// Prisoner ID selected by scanning a prisoner card.
	var/obj/item/card/id/advanced/prisoner/selected_prisoner_id
	/// Sentence time assigned to the prisoner ID, in the same units used by prisoner ID timers.
	var/sentence_time
	/// Security record status assigned when the intake is processed.
	var/record_status = WANTED_PRISONER

/datum/computer_file/program/prisoner_intake/proc/format_sentence_time(sentence)
	if(sentence == -1)
		return "Permanent"
	if(sentence > 0)
		return DisplayTimeText(sentence * 10, round_seconds_to = 1)
	return null

/datum/computer_file/program/prisoner_intake/proc/format_record_remaining(datum/record/crew/record)
	if(!record)
		return null
	if(record.corrections_sentence_permanent)
		return "Permanent"
	if(record.corrections_sentence_start <= 0 || record.corrections_sentence_duration <= 0)
		return null
	var/remaining = max(record.corrections_sentence_duration * 10 - (world.time - record.corrections_sentence_start), 0)
	if(remaining <= 0)
		return "Served"
	return DisplayTimeText(remaining, round_seconds_to = 1)

/datum/computer_file/program/prisoner_intake/proc/get_record_photo_path(datum/record/crew/record, mob/user)
	if(!record)
		return null
	var/obj/item/photo/front_photo = record.get_front_photo()
	if(!istype(front_photo) || !front_photo.picture?.picture_image)
		return null
	var/photo_asset_name = "ntos_prisoner_intake_[REF(record)]_front.png"
	SSassets.transport.register_asset(photo_asset_name, front_photo.picture.picture_image)
	SSassets.transport.send_assets(user, photo_asset_name)
	return SSassets.transport.get_asset_url(photo_asset_name)

/datum/computer_file/program/prisoner_intake/proc/get_operator_id()
	return computer?.stored_id?.GetID()

/datum/computer_file/program/prisoner_intake/proc/get_operator_account()
	var/obj/item/card/id/operator_id = get_operator_id()
	var/datum/bank_account/operator_account = operator_id?.registered_account
	if(!operator_account || IS_DEPARTMENTAL_ACCOUNT(operator_account))
		return null
	return operator_account

/datum/computer_file/program/prisoner_intake/proc/can_process(mob/user, loud = FALSE)
	var/obj/item/card/id/operator_id = get_operator_id()
	if(!operator_id)
		if(loud)
			computer.balloon_alert(user, "insert operator ID")
		return FALSE
	if(!(ACCESS_BRIG in operator_id.GetAccess()))
		if(loud)
			computer.balloon_alert(user, "access denied")
		return FALSE
	if(!get_operator_account())
		if(loud)
			computer.balloon_alert(user, "no personal account")
		return FALSE
	return TRUE

/datum/computer_file/program/prisoner_intake/proc/clear_missing_refs()
	if(QDELETED(selected_prisoner_id))
		selected_prisoner_id = null
	if(QDELETED(target_record))
		target_record = null

/datum/computer_file/program/prisoner_intake/tap(atom/tapped_atom, mob/living/user, list/modifiers)
	if(!istype(tapped_atom, /obj/item/card/id))
		return FALSE
	if(!can_process(user, TRUE))
		return TRUE

	if(istype(tapped_atom, /obj/item/card/id/advanced/prisoner))
		selected_prisoner_id = tapped_atom
		computer.balloon_alert(user, "prisoner ID scanned")
		SStgui.update_uis(computer)
		return TRUE

	var/obj/item/card/id/scanned_id = tapped_atom
	if(!scanned_id.registered_name)
		computer.balloon_alert(user, "unregistered ID")
		return TRUE

	var/datum/record/crew/found_record = find_record(scanned_id.registered_name)
	if(!found_record)
		computer.balloon_alert(user, "record not found")
		return TRUE

	target_record = found_record
	computer.balloon_alert(user, "crew ID scanned")
	SStgui.update_uis(computer)
	return TRUE

/datum/computer_file/program/prisoner_intake/ui_data(mob/user)
	clear_missing_refs()

	var/list/data = list()
	var/obj/item/card/id/operator_id = get_operator_id()
	var/datum/bank_account/operator_account = get_operator_account()

	data["operator_name"] = operator_id ? (operator_id.registered_name || operator_id.name) : null
	data["operator_has_access"] = !!(operator_id && (ACCESS_BRIG in operator_id.GetAccess()))
	data["operator_has_account"] = !!operator_account
	data["reward"] = CORRECTIONS_INTAKE_REWARD
	data["sentence_time"] = sentence_time
	data["sentence_display"] = format_sentence_time(sentence_time)
	data["record_status"] = record_status

	data["target"] = null
	if(target_record)
		data["target"] = list(
			"name" = target_record.name,
			"gender" = target_record.gender,
			"rank" = target_record.rank,
			"species" = target_record.species,
			"wanted_status" = target_record.wanted_status,
			"rewarded" = target_record.corrections_intake_rewarded,
			"sentence_remaining_display" = format_record_remaining(target_record),
			"sentence_duration_display" = format_sentence_time(target_record.corrections_sentence_permanent ? -1 : target_record.corrections_sentence_duration),
			"photo_path" = get_record_photo_path(target_record, user),
		)

	data["prisoner_id"] = null
	if(selected_prisoner_id)
		data["prisoner_id"] = list(
			"name" = selected_prisoner_id.name,
			"registered_name" = selected_prisoner_id.registered_name,
			"timed" = selected_prisoner_id.timed,
			"time_to_assign" = selected_prisoner_id.time_to_assign,
			"time_display" = selected_prisoner_id.time_to_assign ? DisplayTimeText(selected_prisoner_id.time_to_assign * 10, round_seconds_to = 1) : null,
		)

	data["can_process"] = !!(operator_account && target_record && sentence_time)
	return data

/datum/computer_file/program/prisoner_intake/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	clear_missing_refs()
	if(!isliving(ui.user))
		return TRUE
	var/mob/living/user = ui.user

	switch(action)
		if("clear_selection")
			target_record = null
			selected_prisoner_id = null
			sentence_time = null
			record_status = WANTED_PRISONER
			return TRUE

		if("select_crew")
			if(!can_process(user, TRUE))
				return TRUE
			var/list/crew_records_by_name = list()
			var/list/crew_names = list()
			for(var/datum/record/crew/crew_record as anything in GLOB.manifest.general)
				crew_records_by_name[crew_record.name] = crew_record
				crew_names += crew_record.name
			if(!length(crew_names))
				computer.balloon_alert(user, "no crew records")
				return TRUE
			var/chosen_name = tgui_input_list(user, "Select a crew member to process.", "Prisoner Intake", sort_list(crew_names))
			if(isnull(chosen_name) || QDELETED(src) || QDELETED(user) || !user.can_perform_action(computer, FORBID_TELEKINESIS_REACH | ALLOW_RESTING))
				return TRUE
			var/datum/record/crew/chosen_record = crew_records_by_name[chosen_name]
			if(!chosen_record)
				return TRUE
			target_record = chosen_record
			computer.balloon_alert(user, "crew selected")
			return TRUE

		if("open_security_records")
			if(!target_record)
				computer.balloon_alert(user, "select crew")
				return TRUE
			var/datum/computer_file/program/records/security/security_records = computer.find_file_by_name("secrecords")
			if(!istype(security_records))
				computer.balloon_alert(user, "records app missing")
				return TRUE
			computer.open_program(user, security_records)
			return TRUE

		if("set_sentence")
			if(!can_process(user, TRUE))
				return TRUE
			var/new_time
			if(params["seconds"])
				new_time = text2num(params["seconds"])
			else
				var/default_time = sentence_time > 0 ? sentence_time : 900
				new_time = tgui_input_number(user, "Sentence time in seconds", "Prisoner Intake", default_time, 86400, 1)
				if(isnull(new_time))
					return TRUE
			if(!isnum(new_time) || (new_time != -1 && (new_time < 1 || new_time > 86400)) || QDELETED(src) || QDELETED(user) || !user.can_perform_action(computer, FORBID_TELEKINESIS_REACH | ALLOW_RESTING))
				return TRUE
			sentence_time = round(new_time)
			return TRUE

		if("set_record_status")
			if(!can_process(user, TRUE))
				return TRUE
			var/new_status = params["status"]
			if(!(new_status in list(WANTED_PRISONER, WANTED_PAROLE, WANTED_DISCHARGED)))
				return TRUE
			record_status = new_status
			return TRUE

		if("process_intake")
			if(!can_process(user, TRUE))
				return TRUE
			if(!target_record)
				computer.balloon_alert(user, "select crew")
				return TRUE
			if(!sentence_time)
				computer.balloon_alert(user, "set sentence")
				return TRUE
			if(selected_prisoner_id && get_dist(user, selected_prisoner_id) > 1)
				computer.balloon_alert(user, "prisoner ID too far")
				return TRUE

			if(selected_prisoner_id && record_status == WANTED_PRISONER)
				selected_prisoner_id.registered_name = target_record.name
				selected_prisoner_id.time_to_assign = sentence_time == -1 ? 86400 : sentence_time
				selected_prisoner_id.time_left = 0
				selected_prisoner_id.timed = TRUE
				selected_prisoner_id.update_label()
				STOP_PROCESSING(SSobj, selected_prisoner_id)

			var/old_status = target_record.wanted_status
			target_record.wanted_status = record_status
			if(record_status == WANTED_PRISONER)
				target_record.set_corrections_sentence(sentence_time, sentence_time == -1)
			else
				target_record.clear_corrections_sentence()
			update_matching_security_huds(target_record.name)
			user.investigate_log("[target_record.name] has been set from [old_status] to [record_status] by [key_name(user)] through Prisoner Intake.", INVESTIGATE_RECORDS)

			var/datum/bank_account/operator_account = get_operator_account()
			var/paid = FALSE
			if(!target_record.corrections_intake_rewarded && operator_account.adjust_money(CORRECTIONS_INTAKE_REWARD, CORRECTIONS_INTAKE_TRANSACTION_REASON))
				target_record.corrections_intake_rewarded = TRUE
				paid = TRUE
				operator_account.bank_card_talk("You have received [CORRECTIONS_INTAKE_REWARD] [MONEY_SYMBOL] for processing prisoner intake for [target_record.name].")
				log_econ("[CORRECTIONS_INTAKE_REWARD] [MONEY_NAME] were awarded to [operator_account.account_holder]'s account for processing prisoner intake for [target_record.name].")

			computer.balloon_alert(user, paid ? "intake processed" : "intake updated")
			return TRUE

/datum/aas_config_entry/corrections_sentence_served
	name = "Security Alert: Corrections Sentence Served"
	announcement_lines_map = list(
		"Message" = "%PERSON has served their corrections sentence. Security record updated to discharged.",
	)
	vars_and_tooltips_map = list(
		"PERSON" = "will be replaced with the prisoner's name.",
	)
