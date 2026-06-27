/obj/item/geiger_counter //DISCLAIMER: I know nothing about how real-life Geiger counters work. This will not be realistic. ~Xhuis
	name = "\improper Geiger counter"
	desc = "A handheld device used for detecting and measuring radiation pulses."
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "geiger_off"
	inhand_icon_state = "multitool"
	worn_icon_state = "geiger_counter"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 1.5, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 1.5)

	var/last_perceived_radiation_danger = null
	var/turf/last_perceived_radiation_turf = null

	var/scanning = FALSE

/obj/item/geiger_counter/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_IN_RANGE_OF_IRRADIATION, PROC_REF(on_pre_potential_irradiation))

/obj/item/geiger_counter/examine(mob/user)
	. = ..()
	if(!scanning)
		return
	. += span_info("Alt-click it to clear stored radiation levels.")
	switch(last_perceived_radiation_danger)
		if(null)
			. += span_notice("Ambient radiation level count reports that all is well.")
		if(PERCEIVED_RADIATION_DANGER_LOW)
			. += span_alert("Ambient radiation levels slightly above average.")
		if(PERCEIVED_RADIATION_DANGER_MEDIUM)
			. += span_warning("Ambient radiation levels above average.")
		if(PERCEIVED_RADIATION_DANGER_HIGH)
			. += span_danger("Ambient radiation levels highly above average.")
		if(PERCEIVED_RADIATION_DANGER_EXTREME)
			. += span_suicide("Ambient radiation levels reaching critical level!")

/obj/item/geiger_counter/update_icon_state()
	if(!scanning)
		icon_state = "geiger_off"
		return ..()

	switch(last_perceived_radiation_danger)
		if(null)
			icon_state = "geiger_on_1"
		if(PERCEIVED_RADIATION_DANGER_LOW)
			icon_state = "geiger_on_2"
		if(PERCEIVED_RADIATION_DANGER_MEDIUM)
			icon_state = "geiger_on_3"
		if(PERCEIVED_RADIATION_DANGER_HIGH)
			icon_state = "geiger_on_4"
		if(PERCEIVED_RADIATION_DANGER_EXTREME)
			icon_state = "geiger_on_5"
	return ..()

/obj/item/geiger_counter/attack_self(mob/user)
	scanning = !scanning

	if (scanning)
		AddComponent(/datum/component/geiger_sound)
	else
		qdel(GetComponent(/datum/component/geiger_sound))

	update_appearance(UPDATE_ICON)
	balloon_alert(user, "switch [scanning ? "on" : "off"]")

/obj/item/geiger_counter/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(SHOULD_SKIP_INTERACTION(interacting_with, src, user))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/geiger_counter/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!CAN_IRRADIATE(interacting_with) && !interacting_with.can_receive_radioactive_contamination() && !interacting_with.GetComponent(/datum/component/radioactive_contamination))
		return NONE

	user.visible_message(span_notice("[user] scans [interacting_with] with [src]."), span_notice("You scan [interacting_with]'s radiation levels with [src]..."))
	addtimer(CALLBACK(src, PROC_REF(scan), interacting_with, user), 20, TIMER_UNIQUE) // Let's not have spamming GetAllContents
	return ITEM_INTERACT_SUCCESS

/obj/item/geiger_counter/equipped(mob/user, slot, initial)
	. = ..()

	RegisterSignal(user, COMSIG_IN_RANGE_OF_IRRADIATION, PROC_REF(on_pre_potential_irradiation))

/obj/item/geiger_counter/dropped(mob/user, silent = FALSE)
	. = ..()

	UnregisterSignal(user, COMSIG_IN_RANGE_OF_IRRADIATION)

/obj/item/geiger_counter/proc/on_pre_potential_irradiation(datum/source, datum/radiation_pulse_information/pulse_information, insulation_to_target)
	SIGNAL_HANDLER

	last_perceived_radiation_danger = get_perceived_radiation_danger(pulse_information, insulation_to_target)
	last_perceived_radiation_turf = get_turf(source)
	addtimer(CALLBACK(src, PROC_REF(reset_perceived_danger)), TIME_WITHOUT_RADIATION_BEFORE_RESET, TIMER_UNIQUE | TIMER_OVERRIDE)

	if (scanning)
		update_appearance(UPDATE_ICON)

/obj/item/geiger_counter/proc/reset_perceived_danger()
	last_perceived_radiation_danger = null
	last_perceived_radiation_turf = null
	if (scanning)
		update_appearance(UPDATE_ICON)

/obj/item/geiger_counter/proc/scan(atom/target, mob/user)
	var/datum/component/radioactive_contamination/contamination = target.GetComponent(/datum/component/radioactive_contamination)
	if(contamination)
		contamination.send_geiger_reading(user, src)
		send_ambient_radiation_reading(target, user)
		return

	if (SEND_SIGNAL(target, COMSIG_GEIGER_COUNTER_SCAN, user, src) & COMSIG_GEIGER_COUNTER_SCAN_SUCCESSFUL)
		send_ambient_radiation_reading(target, user)
		return

	to_chat(user, span_notice("[icon2html(src, user)] [isliving(target) ? "Subject" : "Target"] is free of radioactive surface contamination."))
	send_ambient_radiation_reading(target, user)

/obj/item/geiger_counter/proc/send_ambient_radiation_reading(atom/target, mob/user)
	if(isnull(last_perceived_radiation_danger))
		return

	if(get_turf(target) != last_perceived_radiation_turf)
		return

	switch(last_perceived_radiation_danger)
		if(PERCEIVED_RADIATION_DANGER_LOW)
			to_chat(user, span_alert("[icon2html(src, user)] Ambient radiation at this location is slightly above average."))
		if(PERCEIVED_RADIATION_DANGER_MEDIUM)
			to_chat(user, span_warning("[icon2html(src, user)] Ambient radiation at this location is above average."))
		if(PERCEIVED_RADIATION_DANGER_HIGH)
			to_chat(user, span_danger("[icon2html(src, user)] Ambient radiation at this location is highly above average."))
		if(PERCEIVED_RADIATION_DANGER_EXTREME)
			to_chat(user, span_suicide("[icon2html(src, user)] Ambient radiation at this location is reaching critical level!"))

/obj/item/geiger_counter/click_alt(mob/living/user)
	if(!scanning)
		to_chat(user, span_warning("[src] must be on to reset its radiation level!"))
		return CLICK_ACTION_BLOCKING
	to_chat(user, span_notice("You flush [src]'s radiation counts, resetting it to normal."))
	last_perceived_radiation_danger = null
	last_perceived_radiation_turf = null
	update_appearance(UPDATE_ICON)
	return CLICK_ACTION_SUCCESS
