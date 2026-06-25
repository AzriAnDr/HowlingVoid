/// Allows living mobs to visually tilt in place while preserving unrelated transform changes.
/datum/component/pixel_tilt
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Current tilt angle being requested by the player.
	var/tilt_angle = 0
	/// Last tilt angle applied to the mob's transform, used to undo only our own rotation.
	var/last_applied_tilt_angle = 0
	/// Maximum allowed tilt angle in either direction.
	var/maximum_tilt = 45
	/// Amount of tilt added or removed per key press.
	var/tilt_increment = 5

/datum/component/pixel_tilt/Initialize(...)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/owner = parent
	owner.balloon_alert(owner, "started tilting!")

/datum/component/pixel_tilt/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(pre_move_check))
	RegisterSignals(parent, list(
		COMSIG_LIVING_RESET_PULL_OFFSETS,
		COMSIG_MOVABLE_MOVED,
		COMSIG_LIVING_SET_BODY_POSITION,
	), PROC_REF(reset_tilt_and_remove))

/datum/component/pixel_tilt/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOB_CLIENT_PRE_LIVING_MOVE,
		COMSIG_LIVING_RESET_PULL_OFFSETS,
		COMSIG_MOVABLE_MOVED,
		COMSIG_LIVING_SET_BODY_POSITION,
	))

/// Removes the currently applied tilt rotation from the mob's transform, then deletes the component.
/datum/component/pixel_tilt/proc/reset_tilt_and_remove()
	SIGNAL_HANDLER

	var/mob/living/owner = parent

	var/matrix/transform_to_reset = matrix(owner.transform)
	snap_tilt_angle()
	transform_to_reset.Turn(-last_applied_tilt_angle)

	animate(owner, transform = transform_to_reset, time = 0.2 SECONDS)

	if(!QDELETED(owner))
		owner.balloon_alert(owner, "stopped tilting!")

	qdel(src)

/datum/component/pixel_tilt/proc/pre_move_check(mob/source, new_loc, direct)
	SIGNAL_HANDLER

	switch(direct)
		if(EAST, WEST)
			apply_tilt(source, direct)
			return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE
		if(NORTH, SOUTH)
			reset_tilt_and_remove()
			return
	return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE

/// Snaps internal tilt angle values to fixed precision to avoid floating point drift.
/datum/component/pixel_tilt/proc/snap_tilt_angle(rounding_factor = 0.01)
	tilt_angle = round(tilt_angle, rounding_factor)
	last_applied_tilt_angle = round(last_applied_tilt_angle, rounding_factor)

/// Applies or updates the visual tilt rotation based on player input.
/datum/component/pixel_tilt/proc/apply_tilt(mob/source, direct)
	var/mob/living/owner = parent
	switch(direct)
		if(EAST)
			tilt_angle = clamp(tilt_angle + tilt_increment, -maximum_tilt, maximum_tilt)
		if(WEST)
			tilt_angle = clamp(tilt_angle - tilt_increment, -maximum_tilt, maximum_tilt)

	var/matrix/tilt_matrix = matrix(owner.transform)

	snap_tilt_angle()
	tilt_matrix.Turn(-last_applied_tilt_angle)

	tilt_matrix.Turn(tilt_angle)
	last_applied_tilt_angle = tilt_angle
	animate(owner, transform = tilt_matrix, time = 0.1 SECONDS, flags = ANIMATION_PARALLEL)
