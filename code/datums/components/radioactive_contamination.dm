/**
 * Surface radioactive contamination.
 *
 * This represents radioactive dust or residue stuck to an atom. It is separate
 * from /datum/component/irradiated: contamination can sit on objects, turfs, or
 * mobs, can be washed off, and only primary contamination can rub off further.
 */
/datum/component/radioactive_contamination
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	/// Current surface contamination activity.
	var/activity = 0
	/// Human-readable source for scans and investigation logs.
	var/source_name = "unknown source"
	/// 0 means primary contamination. Secondary contamination does not spread further.
	var/spread_generation = 0

	COOLDOWN_DECLARE(spread_cooldown)
	COOLDOWN_DECLARE(emit_cooldown)

/datum/component/radioactive_contamination/Initialize(
	new_activity = RAD_CONTAMINATION_DIRECT_EXPOSURE,
	atom/source = null,
	new_spread_generation = 0,
)
	if(!istype(parent, /atom))
		return COMPONENT_INCOMPATIBLE

	var/atom/atom_parent = parent
	if(!atom_parent.can_receive_radioactive_contamination())
		return COMPONENT_INCOMPATIBLE

	activity = clamp(new_activity, 0, RAD_CONTAMINATION_MAX_ACTIVITY)
	if(activity < RAD_CONTAMINATION_MIN_ACTIVITY)
		return COMPONENT_INCOMPATIBLE

	source_name = source ? "[source]" : source_name
	spread_generation = max(new_spread_generation, 0)

	START_PROCESSING(SSobj, src)

/datum/component/radioactive_contamination/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/radioactive_contamination/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	RegisterSignal(parent, COMSIG_GEIGER_COUNTER_SCAN, PROC_REF(on_geiger_counter_scan))

/datum/component/radioactive_contamination/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_GEIGER_COUNTER_SCAN,
	))

/datum/component/radioactive_contamination/InheritComponent(
	datum/component/new_component,
	i_am_original,
	new_activity = RAD_CONTAMINATION_DIRECT_EXPOSURE,
	atom/source = null,
	new_spread_generation = 0,
)
	if(!i_am_original)
		return

	add_activity(new_activity, source, new_spread_generation)

/datum/component/radioactive_contamination/proc/add_activity(new_activity, atom/source = null, new_spread_generation = 0)
	activity = clamp(activity + new_activity, 0, RAD_CONTAMINATION_MAX_ACTIVITY)
	if(source)
		source_name = "[source]"
	spread_generation = min(spread_generation, max(new_spread_generation, 0))

/datum/component/radioactive_contamination/process(seconds_per_tick)
	activity = max(activity - (RAD_CONTAMINATION_DECAY_PER_SECOND * seconds_per_tick), 0)
	if(activity < RAD_CONTAMINATION_MIN_ACTIVITY)
		qdel(src)
		return PROCESS_KILL

	try_emit_radiation()
	try_spread_contamination()

/datum/component/radioactive_contamination/proc/try_emit_radiation()
	if(spread_generation > RAD_CONTAMINATION_MAX_SPREAD_GENERATION)
		return

	if(activity < RAD_CONTAMINATION_EMIT_THRESHOLD)
		return

	if(!COOLDOWN_FINISHED(src, emit_cooldown))
		return

	var/atom/atom_parent = parent
	if(!get_turf(atom_parent))
		return

	COOLDOWN_START(src, emit_cooldown, RAD_CONTAMINATION_EMIT_COOLDOWN)
	radiation_pulse(
		source = atom_parent,
		max_range = RAD_CONTAMINATION_EMIT_RANGE,
		threshold = RAD_HEAVY_INSULATION,
		chance = clamp(round(activity * 0.25), DEFAULT_RADIATION_CHANCE, 35),
		apply_surface_contamination = FALSE,
	)

/datum/component/radioactive_contamination/proc/try_spread_contamination()
	if(spread_generation > RAD_CONTAMINATION_MAX_SPREAD_GENERATION)
		return

	if(activity < RAD_CONTAMINATION_SPREAD_THRESHOLD)
		return

	if(!COOLDOWN_FINISHED(src, spread_cooldown))
		return

	var/atom/atom_parent = parent
	var/turf/current_turf = get_turf(atom_parent)
	if(!current_turf)
		return

	var/list/atom/contact_targets = list()
	if(atom_parent != current_turf)
		contact_targets[current_turf] = TRUE

	var/atom/container = atom_parent.loc
	if(istype(container) && container != current_turf)
		contact_targets[container] = TRUE

	for(var/atom/movable/content as anything in atom_parent.contents)
		contact_targets[content] = TRUE
		if(contact_targets.len >= RAD_CONTAMINATION_SPREAD_TARGETS)
			break

	if(contact_targets.len < RAD_CONTAMINATION_SPREAD_TARGETS)
		for(var/atom/movable/nearby as anything in current_turf)
			if(nearby == atom_parent)
				continue
			contact_targets[nearby] = TRUE
			if(contact_targets.len >= RAD_CONTAMINATION_SPREAD_TARGETS)
				break

	if(!contact_targets.len)
		return

	COOLDOWN_START(src, spread_cooldown, RAD_CONTAMINATION_SPREAD_COOLDOWN)

	var/transferred_total = 0
	for(var/atom/target as anything in contact_targets)
		if(target == atom_parent || !target.can_receive_radioactive_contamination())
			continue

		var/transfer_amount = min(activity * RAD_CONTAMINATION_TRANSFER_FRACTION, activity - RAD_CONTAMINATION_MIN_ACTIVITY)
		if(transfer_amount < RAD_CONTAMINATION_MIN_ACTIVITY)
			break

		if(target.add_radioactive_contamination(transfer_amount, atom_parent, spread_generation + 1))
			transferred_total += transfer_amount

	activity = max(activity - transferred_total * 0.5, 0)

/datum/component/radioactive_contamination/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(activity < RAD_CONTAMINATION_SPREAD_THRESHOLD)
		return

	examine_list += span_warning("A faint greenish residue clings to [parent].")

/datum/component/radioactive_contamination/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER

	if(!(clean_types & (CLEAN_TYPE_RADIATION | CLEAN_TYPE_RADIATION_PARTIAL)))
		return NONE

	if(clean_types & CLEAN_TYPE_RADIATION)
		qdel(src)
		return COMPONENT_CLEANED | COMPONENT_CLEANED_GAIN_XP

	activity = max(activity - RAD_CONTAMINATION_PARTIAL_CLEAN_ACTIVITY, 0)
	if(activity < RAD_CONTAMINATION_MIN_ACTIVITY)
		qdel(src)

	return COMPONENT_CLEANED | COMPONENT_CLEANED_GAIN_XP

/datum/component/radioactive_contamination/proc/on_geiger_counter_scan(datum/source, mob/user, obj/item/geiger_counter/geiger_counter)
	SIGNAL_HANDLER
	send_geiger_reading(user, geiger_counter)
	return COMSIG_GEIGER_COUNTER_SCAN_SUCCESSFUL

/datum/component/radioactive_contamination/proc/send_geiger_reading(mob/user, obj/item/geiger_counter/geiger_counter)
	var/reading = "minor"
	switch(activity)
		if(RAD_CONTAMINATION_SPREAD_THRESHOLD to RAD_CONTAMINATION_EMIT_THRESHOLD)
			reading = "significant"
		if(RAD_CONTAMINATION_EMIT_THRESHOLD to INFINITY)
			reading = "severe"

	to_chat(user, span_bolddanger("[icon2html(geiger_counter, user)] [isliving(parent) ? "Subject" : "Target"] has [reading] radioactive surface contamination ([round(activity, 0.1)]/[RAD_CONTAMINATION_MAX_ACTIVITY] activity)."))

/atom/proc/can_receive_radioactive_contamination()
	if(isarea(src))
		return FALSE

	if(istype(src, /atom/movable/screen))
		return FALSE

	if(istype(src, /obj/effect))
		return FALSE

	return TRUE

/atom/proc/add_radioactive_contamination(activity, atom/source = null, spread_generation = 0)
	if(activity < RAD_CONTAMINATION_MIN_ACTIVITY || !can_receive_radioactive_contamination())
		return FALSE

	AddComponent(/datum/component/radioactive_contamination, activity, source, spread_generation)
	return TRUE

/atom/proc/ensure_radioactive_contamination(activity, atom/source = null, spread_generation = 0)
	if(activity < RAD_CONTAMINATION_MIN_ACTIVITY || !can_receive_radioactive_contamination())
		return FALSE

	var/datum/component/radioactive_contamination/contamination = GetComponent(/datum/component/radioactive_contamination)
	if(contamination)
		if(contamination.activity < activity)
			contamination.add_activity(activity - contamination.activity, source, spread_generation)
		return TRUE

	return add_radioactive_contamination(activity, source, spread_generation)
