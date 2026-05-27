/atom/proc/do_jiggle_nova(targetangle = 45, timer = 20)
	var/matrix/OM = matrix(transform)
	var/matrix/M = matrix(transform)
	var/halftime = timer * 0.5
	M.Turn(pick(-targetangle, targetangle))
	animate(src, transform = M, time = halftime, easing = ELASTIC_EASING)
	animate(src, transform = OM, time = halftime, easing = ELASTIC_EASING)

/atom/proc/do_squish(squishx = 1.2, squishy = 0.6, timer = 20)
	var/matrix/OM = matrix(transform)
	var/matrix/M = matrix(transform)
	var/halftime = timer * 0.5
	M.Scale(squishx, squishy)
	animate(src, transform = M, time = halftime, easing = BOUNCE_EASING)
	animate(src, transform = OM, time = halftime, easing = BOUNCE_EASING)

/** Get all hearers in range, ignores walls and such. Code stolen from `/proc/get_hearers_in_view()`
 * Much faster and less expensive than range()
*/
/proc/get_hearers_in_looc_range(atom/source, range_radius = LOOC_RANGE)
	var/turf/center_turf = get_turf(source)
	if(!center_turf)
		return

	. = list()
	var/old_luminosity = center_turf.luminosity
	if(range_radius <= 0) //special case for if only source cares
		for(var/atom/movable/target as anything in center_turf)
			var/list/recursive_contents = target.important_recursive_contents?[RECURSIVE_CONTENTS_HEARING_SENSITIVE]
			if(recursive_contents)
				. += recursive_contents
		return .

	var/list/hearables_from_grid = SSspatial_grid.orthogonal_range_search(source, RECURSIVE_CONTENTS_HEARING_SENSITIVE, range_radius)

	if(!length(hearables_from_grid))//we know that something is returned by the grid, but we dont know if we need to actually filter down the output
		return .

	var/list/assigned_oranges_ears = SSspatial_grid.assign_oranges_ears(hearables_from_grid)

	for(var/mob/oranges_ear/ear in range(range_radius, center_turf))
		. += ear.references

	for(var/mob/oranges_ear/remaining_ear as anything in assigned_oranges_ears) //we need to clean up our mess
		remaining_ear.unassign()

	center_turf.luminosity = old_luminosity
	return .

/// Returns TRUE if the supplied area allows player-side shoo ghost privacy.
/proc/is_shoo_ghost_area(area/checked_area)
	if(isnull(checked_area))
		return FALSE
	return is_ghost_cafe_area(checked_area) || istype(checked_area, /area/misc/hilbertshotel)

/// Returns TRUE if this mob is currently shooing ghosts from a valid location.
/proc/is_shoo_ghost_active(mob/shooer)
	if(isnull(shooer) || !shooer.auto_shoo_ghosts)
		return FALSE
	return shooer.auto_shoo_admin_override || is_shoo_ghost_area(get_area(shooer))

/// Returns TRUE if this mob's shoo ghost settings block this client.
/proc/shoo_ghost_blocks_client(mob/shooer, client/ghost_client)
	if(!is_shoo_ghost_active(shooer))
		return FALSE
	return shooer.auto_shoo_include_admins || !ghost_client?.holder

/// Returns TRUE if the target is inside an active admin shoo ghost radius.
/proc/is_admin_shoo_ghost_protected(mob/target)
	if(isnull(target))
		return FALSE
	var/turf/target_turf = get_turf(target)
	if(isnull(target_turf))
		return FALSE

	for(var/mob/shooer in range(GHOST_MAX_VIEW_RANGE_MEMBER, target_turf))
		if(!shooer.auto_shoo_admin_override || !shooer.auto_shoo_include_admins)
			continue
		if(is_shoo_ghost_active(shooer))
			return TRUE

	return FALSE

/// Sends a generic shoo ghost denial notice to an observer.
/proc/notify_shoo_ghost_block(mob/shooer, mob/dead/observer/ghost)
	var/shoo_name = shooer.real_name ? shooer.real_name : shooer.name
	to_chat(ghost, span_notice("[shoo_name] has shoo ghosts enabled."))

/**
 * Checks if a LOOC message should be blocked from a sender to a hearer based on shoo ghost settings.
 * Returns TRUE if the message should be blocked, FALSE otherwise.
 */
/proc/is_looc_blocked_by_shoo_ghost(mob/sender, mob/hearer, client/sender_client, client/hearer_client)
	if(isnull(sender) || isnull(hearer))
		return FALSE

	if(isnull(sender_client))
		sender_client = sender.client
	if(isnull(hearer_client))
		hearer_client = hearer.client

	if(isobserver(sender))
		if(shoo_ghost_blocks_client(hearer, sender_client))
			return TRUE

		for(var/mob/nearby in range(LOOC_RANGE, hearer))
			if(nearby == hearer)
				continue
			if(shoo_ghost_blocks_client(nearby, sender_client))
				return TRUE

	if(isobserver(hearer))
		if(shoo_ghost_blocks_client(sender, hearer_client))
			return TRUE

		for(var/mob/nearby in range(LOOC_RANGE, sender))
			if(nearby == sender)
				continue
			if(shoo_ghost_blocks_client(nearby, hearer_client))
				return TRUE

	return FALSE

/// Checks if remote LOOC should be blocked from admins by admin shoo ghost.
/proc/is_remote_looc_blocked_by_shoo_ghost(mob/sender)
	if(isnull(sender))
		return FALSE

	if(is_shoo_ghost_active(sender) && sender.auto_shoo_include_admins)
		return TRUE

	for(var/mob/nearby in range(LOOC_RANGE, sender))
		if(nearby == sender)
			continue
		if(is_shoo_ghost_active(nearby) && nearby.auto_shoo_include_admins)
			return TRUE

	return FALSE

/**
 * Checks if speech or emotes should be blocked from a speaker to an observer by shoo ghost settings.
 * Returns TRUE if the message should be blocked, FALSE otherwise.
 */
/proc/is_say_blocked_by_shoo_ghost(mob/speaker, mob/dead/observer/ghost)
	if(isnull(speaker) || isnull(ghost) || !isobserver(ghost))
		return FALSE

	if(shoo_ghost_blocks_client(speaker, ghost.client))
		return TRUE

	for(var/mob/nearby in range(LOOC_RANGE, speaker))
		if(nearby == speaker)
			continue
		if(shoo_ghost_blocks_client(nearby, ghost.client))
			return TRUE

	return FALSE

///This will check if SSaccessories.sprite_accessories[mutant_part]?[part_name] is associated with sprite accessory with factual TRUE.
/proc/is_factual_sprite_accessory(mutant_part, part_name)
	if(!mutant_part || !part_name)
		return FALSE
	var/datum/sprite_accessory/accessory = SSaccessories.sprite_accessories[mutant_part]?[part_name]
	return accessory?.factual
