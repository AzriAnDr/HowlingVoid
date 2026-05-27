/obj/item/hand_item/scent_focus
	name = "scent focus"
	icon = 'icons/organs/cyber_tongue.dmi'
	icon_state = "cybertongue"
	inhand_icon_state = "nothing"
	flags_1 = NONE

/obj/item/hand_item/scent_focus/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/datum/action/cooldown/scent_scan/ability = locate(/datum/action/cooldown/scent_scan) in user.actions
	if(ability)
		if(get_dist(get_turf(interacting_with), get_turf(user)) > 1)
			to_chat(user, span_warning("That is too far away to catch a scent."))
			ability.StartCooldown(3 SECONDS)
		else
			user.visible_message(
				span_notice("[user] sniffs [interacting_with], taking in the scent."),
				span_notice("You sniff [interacting_with]...")
			)

			if(!do_after(user, 2.5 SECONDS, user, max_interact_count = 1))
				to_chat(user, span_warning("You lose the trail."))
				ability.StartCooldown(2 SECONDS)
			else
				ability.perform_scan(user, interacting_with)

	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/hand_item/scent_focus/Destroy(force)
	if(ishuman(loc))
		var/mob/living/carbon/human/user = loc
		var/datum/action/cooldown/scent_scan/ability = locate(/datum/action/cooldown/scent_scan) in user.actions
		if(ability)
			ability.StartCooldown(2 SECONDS)
	return ..()

/datum/action/cooldown/scent_scan
	name = "Keen Scent"
	desc = "Your sense of smell lets you pick up traces and scents in the surrounding area."
	button_icon = 'icons/organs/cyber_tongue.dmi'
	button_icon_state = "cybertongue"
	cooldown_time = 6 SECONDS
	check_flags = AB_CHECK_CONSCIOUS
	var/list/sniffable_categories = list()

/datum/action/cooldown/scent_scan/Destroy()
	sniffable_categories = null
	return ..()

/datum/action/cooldown/scent_scan/Activate(atom/target)
	var/mob/living/carbon/human/human_owner = owner
	if(!human_owner)
		return FALSE
	if(!isnull(human_owner.get_active_held_item()))
		return FALSE

	human_owner.put_in_active_hand(new /obj/item/hand_item/scent_focus)
	return TRUE

/datum/action/cooldown/scent_scan/proc/perform_scan(mob/living/carbon/human/sniffer, atom/target)
	var/list/messages = list()
	var/list/clues_found = list()
	var/datum/action/cooldown/scent_tracking/tracking_action = locate(/datum/action/cooldown/scent_tracking) in sniffer.actions

	for(var/atom/scanned_atom as anything in get_turf(target))
		var/list/log_entry = gather_forensic_data(scanned_atom)
		if(!LAZYLEN(log_entry))
			continue

		var/list/formatted = format_forensic_message(scanned_atom, log_entry)
		if(LAZYLEN(formatted))
			messages += formatted

		if(!tracking_action)
			continue

		var/list/prints = log_entry[DETSCAN_CATEGORY_FINGERS]
		if(LAZYLEN(prints))
			for(var/print in prints)
				if(istext(print) && !(print in clues_found))
					clues_found += print

		var/list/bloods = log_entry[DETSCAN_CATEGORY_BLOOD]
		if(LAZYLEN(bloods))
			for(var/blood in bloods)
				if(!(blood in clues_found))
					clues_found += blood

	if(LAZYLEN(clues_found) && tracking_action)
		LAZYADD(tracking_action.scent_targets, clues_found)
		addtimer(CALLBACK(tracking_action, TYPE_PROC_REF(/datum/action/cooldown/scent_tracking, clear_scent_targets), LAZYLEN(clues_found) + 1), 30 SECONDS)

	if(!LAZYLEN(messages))
		to_chat(sniffer, span_notice("You do not smell anything unusual."))
	else
		sniffer.balloon_alert(sniffer, "scent caught")
		to_chat(sniffer, span_notice("<b>You catch the scents nearby:</b>"))
		for(var/line in messages)
			to_chat(sniffer, span_info(line))

	StartCooldown()
	return TRUE

/datum/action/cooldown/scent_scan/proc/gather_forensic_data(atom/scanned_atom)
	if(!scanned_atom)
		return list()

	var/list/log_entry = list()

	if(DETSCAN_CATEGORY_FIBER in sniffable_categories)
		var/list/fibers = GET_ATOM_FIBRES(scanned_atom)
		if(LAZYLEN(fibers))
			LAZYSET(log_entry, DETSCAN_CATEGORY_FIBER, fibers.Copy())

	if(DETSCAN_CATEGORY_BLOOD in sniffable_categories)
		var/list/blood = GET_ATOM_BLOOD_DNA(scanned_atom)
		if(LAZYLEN(blood))
			LAZYSET(log_entry, DETSCAN_CATEGORY_BLOOD, blood.Copy())

	if(DETSCAN_CATEGORY_FINGERS in sniffable_categories)
		if(ishuman(scanned_atom))
			var/mob/living/carbon/human/scanned_human = scanned_atom
			if(!scanned_human.gloves && scanned_human.dna?.unique_identity)
				var/fingerprint = md5(scanned_human.dna.unique_identity)
				if(fingerprint)
					LAZYSET(log_entry, DETSCAN_CATEGORY_FINGERS, list(fingerprint))
		else if(!ismob(scanned_atom))
			var/list/prints = GET_ATOM_FINGERPRINTS(scanned_atom)
			if(LAZYLEN(prints))
				LAZYSET(log_entry, DETSCAN_CATEGORY_FINGERS, prints.Copy())

	if(DETSCAN_CATEGORY_REAGENTS in sniffable_categories && scanned_atom.reagents)
		for(var/datum/reagent/reagent as anything in scanned_atom.reagents.reagent_list)
			if(!log_entry[DETSCAN_CATEGORY_REAGENTS])
				log_entry[DETSCAN_CATEGORY_REAGENTS] = list()
			log_entry[DETSCAN_CATEGORY_REAGENTS][reagent.name] = reagent.volume

	return log_entry

/datum/action/cooldown/scent_scan/proc/format_forensic_message(atom/scanned_atom, list/log_entry)
	if(!LAZYLEN(log_entry))
		return null

	var/list/lines = list("<b>[scanned_atom]</b>")

	var/list/fibers = log_entry[DETSCAN_CATEGORY_FIBER]
	if(LAZYLEN(fibers))
		lines += "&bull; Fibers: [english_list(fibers)]"

	var/list/blood_data = log_entry[DETSCAN_CATEGORY_BLOOD]
	if(LAZYLEN(blood_data))
		var/list/blood_lines = list()
		for(var/id in blood_data)
			blood_lines += "[blood_data[id] || "unknown"]"
		lines += "&bull; Blood traces: [blood_lines.Join(", ")]"

	var/list/reagents = log_entry[DETSCAN_CATEGORY_REAGENTS]
	if(LAZYLEN(reagents))
		var/list/reagent_lines = list()
		for(var/reagent_name in reagents)
			var/amount = reagents[reagent_name]
			reagent_lines += "[reagent_name] ([round(amount, 0.1)]u)"
		lines += "&bull; Particles: [reagent_lines.Join(", ")]"

	return lines

/datum/action/cooldown/scent_scan/aquatic
	sniffable_categories = list(
		DETSCAN_CATEGORY_BLOOD,
	)

/datum/action/cooldown/scent_scan/tajaran
	sniffable_categories = list(
		DETSCAN_CATEGORY_FINGERS,
		DETSCAN_CATEGORY_FIBER,
	)

/datum/action/cooldown/scent_scan/vulp
	sniffable_categories = list(
		DETSCAN_CATEGORY_FINGERS,
		DETSCAN_CATEGORY_FIBER,
		DETSCAN_CATEGORY_BLOOD,
	)

/datum/action/cooldown/scent_scan/vulp/perform_scan(mob/living/carbon/human/sniffer, atom/target)
	if(ishuman(target))
		var/mob/living/carbon/human/sniffed_human = target
		var/damage_amount = sniffed_human.get_brute_loss() + sniffed_human.get_fire_loss()
		var/health_message = "[sniffed_human.get_visible_name()] "

		switch(damage_amount)
			if(0 to 15)
				health_message += "has no noticeable wounds"
			if(16 to 35)
				health_message += "has a few small scratches"
			if(36 to 55)
				health_message += "has fresh wounds"
			if(56 to 85)
				health_message += "is badly wounded"
			if(86 to 120)
				health_message += "is covered in severe wounds"
			if(130 to INFINITY)
				health_message += "smells like death is close"

		to_chat(sniffer, span_info("[health_message][LAZYLEN(sniffed_human.diseases) ? ", and may be ill." : "."]"))
		StartCooldown()
		return TRUE

	return ..()

/datum/action/cooldown/scent_tracking
	name = "Track Scent"
	desc = "Try to determine the direction of a remembered scent."
	background_icon_state = "bg_default"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "nose"
	cooldown_time = 2 SECONDS
	check_flags = AB_CHECK_CONSCIOUS
	var/list/scent_targets = list()
	var/mob/living/carbon/human/scent_target

/datum/action/cooldown/scent_tracking/Destroy()
	scent_targets = null
	scent_target = null
	return ..()

/datum/action/cooldown/scent_tracking/PreActivate(atom/target)
	var/mob/living/carbon/human/human_owner = owner
	if(!human_owner || !LAZYLEN(scent_targets))
		return FALSE

	if(!(scent_target in scent_targets))
		scent_target = null

	var/list/radial_options = list()
	for(var/clue in scent_targets)
		var/mob/living/carbon/human/human_target = find_best_target(human_owner, clue)
		if(!human_target)
			continue

		var/datum/radial_menu_choice/option = new
		option.name = human_target.get_visible_name()
		option.image = image(icon = 'icons/mob/actions/actions_items.dmi', icon_state = "bci_question")
		option.info = get_scent_balloon(human_owner, human_target)
		radial_options[human_target] = option

	if(!LAZYLEN(radial_options))
		human_owner.balloon_alert(human_owner, "trail lost")
		return FALSE

	scent_target = show_radial_menu(human_owner, human_owner, radial_options, radius = 42)
	if(!scent_target)
		return FALSE

	return ..()

/datum/action/cooldown/scent_tracking/Activate(atom/target)
	var/mob/living/carbon/human/human_owner = owner
	if(!human_owner)
		return FALSE

	var/mob/living/carbon/human/tracked_human = scent_target
	if(QDELETED(tracked_human))
		scent_target = null
		human_owner.balloon_alert(human_owner, "trail lost")
		return TRUE

	human_owner.balloon_alert(human_owner, get_scent_balloon(human_owner, tracked_human))
	show_scent_arrow(human_owner, tracked_human)
	StartCooldown()
	return TRUE

/datum/action/cooldown/scent_tracking/proc/find_best_target(mob/living/carbon/human/sniffer, clue)
	if(!sniffer || !clue)
		return null

	var/turf/sniffer_turf = get_turf(sniffer)
	for(var/mob/living/carbon/human/candidate as anything in GLOB.human_list)
		if(candidate == sniffer || QDELETED(candidate) || candidate.stat == DEAD || !candidate.dna?.unique_identity)
			continue

		var/turf/candidate_turf = get_turf(candidate)
		if(!candidate_turf || !sniffer_turf || candidate_turf.z != sniffer_turf.z)
			continue

		if(md5(candidate.dna.unique_identity) == clue)
			return candidate
		if(clue in candidate.get_blood_dna_list())
			return candidate

	return null

/datum/action/cooldown/scent_tracking/proc/clear_scent_targets(cut_up_to)
	if(!cut_up_to)
		return FALSE

	var/mob/living/carbon/human/human_owner = owner
	scent_targets.Cut(1, cut_up_to)
	if(!(scent_target in scent_targets))
		scent_target = null
	if(human_owner)
		human_owner.balloon_alert(human_owner, "scents faded")
	return TRUE

/datum/action/cooldown/scent_tracking/proc/get_scent_balloon(mob/living/sniffer, mob/living/target)
	var/turf/sniffer_turf = get_turf(sniffer)
	var/turf/target_turf = get_turf(target)
	if(!sniffer_turf || !target_turf)
		return "unknown location"
	if(sniffer_turf.z != target_turf.z)
		return "another level"

	var/distance = get_dist(sniffer_turf, target_turf)
	var/direction = get_dir(sniffer_turf, target_turf)
	switch(distance)
		if(0 to 8)
			return "very close, [dir2text(direction)]"
		if(9 to 16)
			return "close, [dir2text(direction)]"
		if(17 to 64)
			return "far, [dir2text(direction)]"
		else
			return "very far"

/datum/action/cooldown/scent_tracking/proc/show_scent_arrow(mob/living/carbon/human/sniffer, mob/living/carbon/human/target)
	if(!sniffer || !target)
		return

	var/turf/sniffer_turf = get_turf(sniffer)
	var/turf/target_turf = get_turf(target)
	if(!sniffer_turf || !target_turf || sniffer_turf.z != target_turf.z)
		return

	var/distance = get_dist(sniffer_turf, target_turf)
	var/arrow_color = COLOR_YELLOW
	switch(distance)
		if(0 to 8)
			arrow_color = COLOR_GREEN
		if(9 to 16)
			arrow_color = COLOR_YELLOW
		if(17 to 64)
			arrow_color = COLOR_ORANGE
		else
			arrow_color = COLOR_RED

	if(sniffer.hud_used)
		new /atom/movable/screen/navigate_arrow/scent(null, sniffer.hud_used, target_turf, arrow_color)

/atom/movable/screen/navigate_arrow/scent
	icon = 'icons/effects/96x96.dmi'
	name = "scent arrow"
	icon_state = "navigate_arrow_appear"
	pixel_x = -32
	pixel_y = -32
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
