GLOBAL_LIST_EMPTY(heretic_arenas)

/// Movement slowdown applied to non-heretic arena participants. IGNORE_NOSLOW is required to bypass TRAIT_IGNORESLOWDOWN given by the arena.
/datum/movespeed_modifier/heretic_arena_slowdown
	id = MOVESPEED_ID_HERETIC_ARENA
	multiplicative_slowdown = 0.5
	flags = IGNORE_NOSLOW

/// The minimum allowed cached_multiplicative_slowdown for non-heretic arena participants (prevents speed boosts).
#define HERETIC_ARENA_SPEED_CAP 1.75

// Invisible effect that doesnt exist outside of containing the prox monitor
/obj/effect/abstract/heretic_arena
	icon = null
	icon_state = null
	alpha = 0
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	/// Proximity monitor that handles the effects we are looking for
	var/datum/proximity_monitor/advanced/heretic_arena/arena
	/// Stoppable timer used instead of QDEL_IN so we can extend it on death
	var/qdel_timer
	/// Absolute world.time when the arena is scheduled to be deleted
	var/end_time
	/// Reference to the casting spell so we can extend its revert timer on participant death
	var/datum/action/cooldown/spell/wolves_among_sheep/linked_spell

/obj/effect/abstract/heretic_arena/Initialize(mapload, range, duration, caster)
	. = ..()
	arena = new(src, range)
	end_time = world.time + duration
	qdel_timer = addtimer(CALLBACK(GLOBAL_PROC, /proc/qdel, src), duration, TIMER_STOPPABLE)
	arena.set_caster(caster)
	GLOB.heretic_arenas += src

/obj/effect/abstract/heretic_arena/Destroy(force)
	deltimer(qdel_timer)
	QDEL_NULL(arena)
	GLOB.heretic_arenas -= src
	. = ..()

/// Extends the arena duration by [add_time] from its scheduled end, also notifies the linked spell.
/obj/effect/abstract/heretic_arena/proc/extend_duration(add_time)
	if(QDELETED(src))
		return
	deltimer(qdel_timer)
	end_time = max(world.time, end_time) + add_time
	qdel_timer = addtimer(CALLBACK(GLOBAL_PROC, /proc/qdel, src), end_time - world.time, TIMER_STOPPABLE)
	if(!isnull(linked_spell) && !QDELETED(linked_spell))
		linked_spell.extend_revert_timer(end_time - world.time)

/datum/proximity_monitor/advanced/heretic_arena
	/// Reference to the caster, the spell collapses if they leave the arena
	var/arena_caster
	/// List of mobs inside our arena
	var/list/contained_mobs = list()
	/// List of border walls we have placed on the edges of the monitor
	var/list/border_walls = list()
	/// List of blades we've so generously handed out to the participants
	var/list/welfare_blades = list()
	/// List of immunities given to our combatants
	var/static/list/given_immunities = list(
		TRAIT_BOMBIMMUNE,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_NO_SLIP_ALL,
		TRAIT_NOBREATH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_SHOCKIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_STUNIMMUNE,
		TRAIT_FORCED_GRAVITY,
	)

/datum/proximity_monitor/advanced/heretic_arena/New(atom/_host, range, _ignore_if_not_on_turf)
	. = ..()
	recalculate_field(full_recalc = TRUE)
	var/list/things_in_range = range(range)
	for(var/mob/living/carbon/human/human_in_range in things_in_range)
		enlist_participant(human_in_range)

/// Registers a mob as an arena participant. Safe to call on already-enlisted mobs (no-op).
/datum/proximity_monitor/advanced/heretic_arena/proc/enlist_participant(mob/living/carbon/human/new_participant)
	if(new_participant in contained_mobs)
		return // Already a participant
	new_participant.add_traits(given_immunities, HERETIC_ARENA_TRAIT)
	contained_mobs += new_participant
	if(!IS_HERETIC(new_participant))
		var/obj/item/melee/sickly_blade/training/new_blade = new(get_turf(new_participant))
		welfare_blades += new_blade
		INVOKE_ASYNC(new_participant, TYPE_PROC_REF(/mob, put_in_hands), new_blade)
		new_participant.mind?.add_antag_datum(/datum/antagonist/heretic_arena_participant)
	new_participant.apply_status_effect(/datum/status_effect/arena_tracker)
	RegisterSignal(new_participant, COMSIG_CAN_Z_MOVE, PROC_REF(on_try_z_move))
	RegisterSignal(new_participant, COMSIG_LADDER_TRAVEL, PROC_REF(on_try_ladder))
	RegisterSignal(new_participant, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_pre_move))
	RegisterSignal(new_participant, COMSIG_MOVABLE_POST_TELEPORT, PROC_REF(on_teleport))
	RegisterSignal(new_participant, COMSIG_LIVING_DEATH, PROC_REF(on_participant_death))
	to_chat(new_participant, span_hypnophrase("The arena claims you as its own! There is no escape until blood is shed."))

/// Catch any living human who enters the field after arena creation and enlist them.
/datum/proximity_monitor/advanced/heretic_arena/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(!istype(movable, /mob/living/carbon/human))
		return
	enlist_participant(movable)

/datum/proximity_monitor/advanced/heretic_arena/Destroy()
	for(var/mob/living/carbon/human/mob in contained_mobs)
		mob.remove_traits(given_immunities, HERETIC_ARENA_TRAIT)
		mob.remove_status_effect(/datum/status_effect/arena_tracker)
		UnregisterSignal(mob, list(COMSIG_CAN_Z_MOVE, COMSIG_LADDER_TRAVEL, COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_POST_TELEPORT, COMSIG_LIVING_DEATH))
		if(mob.mind?.has_antag_datum(/datum/antagonist/heretic_arena_participant))
			mob.mind.remove_antag_datum(/datum/antagonist/heretic_arena_participant)
	for(var/turf/to_restore in border_walls)
		to_restore.ChangeTurf(border_walls[to_restore])
	for(var/obj/to_refund as anything in welfare_blades)
		qdel(to_refund)
	arena_caster = null
	return ..()

/datum/proximity_monitor/advanced/heretic_arena/setup_edge_turf(turf/target)
	. = ..()
	var/old_turf = target.type
	target.ChangeTurf(/turf/closed/indestructible/heretic_wall)
	border_walls += target
	border_walls[target] += old_turf

/datum/proximity_monitor/advanced/heretic_arena/field_edge_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(!isliving(movable))
		return
	var/mob/living/living_mob = movable
	addtimer(CALLBACK(living_mob, TYPE_PROC_REF(/mob/living, remove_status_effect), /datum/status_effect/arena_tracker), 10 SECONDS)
	living_mob.remove_traits(given_immunities, HERETIC_ARENA_TRAIT)
	if(living_mob == arena_caster)
		QDEL_IN(host, 3 SECONDS)

/// Extends the arena by 20 seconds when a participant dies
/datum/proximity_monitor/advanced/heretic_arena/proc/on_participant_death(mob/living/deceased)
	SIGNAL_HANDLER
	if(deceased == arena_caster)
		return // Caster death is handled separately via on_caster_crit
	var/obj/effect/abstract/heretic_arena/arena_obj = host
	if(QDELETED(arena_obj))
		return

	// Heal surviving participants (not corpses, not dead, not cybernetic-hearted)
	var/static/list/blood_feast_messages = list(
		"One sheep has fallen... The slaughter must continue!",
		"The arena drinks deep. You feel your wounds close.",
		"A soul offered to the Mansus... Fight on, survivor!",
		"Blood feeds the arena. The arena feeds you.",
		"Another falls. The wolf is pleased.",
	)
	var/heal_message = pick(blood_feast_messages)
	for(var/mob/living/carbon/human/survivor in contained_mobs)
		if(survivor == deceased)
			continue
		if(survivor.stat == DEAD)
			continue
		var/obj/item/organ/heart = survivor.get_organ_slot(ORGAN_SLOT_HEART)
		if(istype(heart, /obj/item/organ/heart/cybernetic))
			continue
		// Base damage heal
		survivor.heal_overall_damage(50, 50)
		survivor.adjust_tox_loss(-50, forced = TRUE)
		survivor.adjust_oxy_loss(-50)
		// Heal all wounds (includes fractures)
		for(var/datum/wound/wound as anything in survivor.all_wounds)
			wound.remove_wound()
		// Restore blood volume
		survivor.blood_volume = BLOOD_VOLUME_NORMAL
		// Restore nutrition to full
		survivor.set_nutrition(NUTRITION_LEVEL_FULL)
		survivor.balloon_alert(survivor, "the arena heals you!")
		to_chat(survivor, span_hypnophrase(heal_message))

	// Notify everyone (including non-healed) about the extension
	for(var/mob/living/mob in contained_mobs)
		to_chat(mob, span_hypnophrase("The arena hungers for more blood - the end is delayed!"))
	arena_obj.extend_duration(20 SECONDS)

/// Prevents using ladders
/datum/proximity_monitor/advanced/heretic_arena/proc/on_try_ladder(mob/climber)
	SIGNAL_HANDLER
	return LADDER_TRAVEL_BLOCK

/// If we try to enter a space turf that has a mirage, we will block the movement
/datum/proximity_monitor/advanced/heretic_arena/proc/on_pre_move(atom/movable/mover, atom/newloc)
	if(locate(/atom/movable/mirage_holder) in newloc.contents)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// Blocks Z movement to new z levels
/datum/proximity_monitor/advanced/heretic_arena/proc/on_try_z_move(atom/movable/source, turf/start, turf/destination)
	SIGNAL_HANDLER
	if(start.z == destination.z)
		return
	return COMPONENT_CANT_Z_MOVE

/// If our caster teleports away (after winning presumably) we'll collapse the arena so that it doens't needlessly linger.
/// For non-caster participants who were force-teleported out (e.g. via permanent/force portals), we yank them back in.
/// Exception: participants being sent to the Mansus via heretic sacrifice are released from the arena gracefully.
/datum/proximity_monitor/advanced/heretic_arena/proc/on_teleport(atom/teleportee, atom/destination, channel)
	SIGNAL_HANDLER
	if(teleportee == arena_caster)
		qdel(host)
		return
	// Regular portals (force_teleport = FALSE) are already blocked by TRAIT_NO_TELEPORT.
	// This handles edge cases where force_teleport portals bypass TRAIT_NO_TELEPORT and exile the participant.
	var/turf/current_turf = get_turf(teleportee)
	if(!(current_turf in field_turfs))
		// If the participant was sacrificed mid-arena and sent to the Mansus, release them gracefully.
		// This lets the sacrifice chain proceed normally while still blocking other forced teleports.
		if(istype(get_area(teleportee), /area/centcom/heretic_sacrifice))
			release_participant(teleportee)
			return
		to_chat(teleportee, span_warning("The arena's grasp is inescapable - no portal can ferry you from this place!"))
		INVOKE_ASYNC(src, PROC_REF(yank_back_to_arena), teleportee)

/// Releases a single participant from the arena cleanly (unregisters signals, removes traits and status).
/// Used when a participant is legitimately removed mid-arena, e.g. sacrificed to the Mansus.
/datum/proximity_monitor/advanced/heretic_arena/proc/release_participant(mob/living/carbon/human/participant)
	if(!(participant in contained_mobs))
		return
	participant.remove_traits(given_immunities, HERETIC_ARENA_TRAIT)
	participant.remove_status_effect(/datum/status_effect/arena_tracker)
	UnregisterSignal(participant, list(COMSIG_CAN_Z_MOVE, COMSIG_LADDER_TRAVEL, COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_POST_TELEPORT, COMSIG_LIVING_DEATH))
	if(participant.mind?.has_antag_datum(/datum/antagonist/heretic_arena_participant))
		participant.mind.remove_antag_datum(/datum/antagonist/heretic_arena_participant)
	contained_mobs -= participant

/// Forcibly teleports an escaped participant back to the arena center. Called asynchronously to avoid signal re-entrancy.
/datum/proximity_monitor/advanced/heretic_arena/proc/yank_back_to_arena(atom/movable/escapee)
	if(QDELETED(escapee) || QDELETED(src))
		return
	do_teleport(escapee, get_turf(host), 0, no_effects = FALSE, channel = TELEPORT_CHANNEL_MAGIC, forced = TRUE)

/datum/proximity_monitor/advanced/heretic_arena/proc/set_caster(atom/caster)
	arena_caster = caster

/turf/closed/indestructible/heretic_wall
	name = "eldritch wall"
	desc = "A wall penning in the sheep amongst the wolves. It glows with malevolent energy - prodding it is likely unwise."
	icon = 'icons/turf/walls.dmi'
	icon_state = "eldritch_forcewall"
	opacity = FALSE
	pass_flags_self = NONE // No PASSCLOSEDTURF because only arena victors are allowed to go in or out

/turf/closed/indestructible/heretic_wall/CanAllowThrough(atom/movable/mover, border_dir)
	if(isliving(mover))
		var/mob/living/living_mover = mover
		var/datum/status_effect/arena_tracker/tracker = living_mover.has_status_effect(/datum/status_effect/arena_tracker)
		if(tracker?.arena_victor)
			return TRUE
		return FALSE // All living non-victors are blocked: both outsiders and trapped participants
	return ..()

/turf/closed/indestructible/heretic_wall/Bumped(atom/movable/bumped_atom)
	. = ..()
	if(!isliving(bumped_atom))
		return
	var/mob/living/living_mob = bumped_atom
	var/atom/target = get_edge_target_turf(living_mob, get_dir(src, get_step_away(living_mob, src)))
	living_mob.throw_at(target, 4, 5)
	to_chat(living_mob, span_userdanger("The wall repels you with tremendous force!"))

/// Called when you crit somebody to update your crown
/datum/status_effect/arena_tracker/proc/on_crit_somebody()
	owner.cut_overlay(crown_overlay)
	crown_overlay = mutable_appearance('icons/mob/effects/crown.dmi', "arena_victor", -HALO_LAYER)
	crown_overlay.pixel_z = 24
	owner.add_overlay(crown_overlay)
	owner.remove_traits(list(TRAIT_ELDRITCH_ARENA_PARTICIPANT, TRAIT_NO_TELEPORT), TRAIT_STATUS_EFFECT(id))

	// The mansus celebrates your efforts
	if(IS_HERETIC(owner))
		owner.heal_overall_damage(60, 60, 60)
		owner.adjust_tox_loss(-60, forced = TRUE) // Slime heretics everywhere...
		owner.adjust_oxy_loss(-60)
		if(iscarbon(owner))
			var/mob/living/carbon/carbon_owner = owner
			for(var/datum/wound/wound as anything in carbon_owner.all_wounds)
				wound.remove_wound()

	if(arena_victor) // No need to spam if we've already killed at least 1 person
		return
	if(IS_HERETIC(owner))
		to_chat(owner, span_big(span_hypnophrase("The mansus is pleased with your performance, you may leave now.")))
	else
		to_chat(owner, span_big(span_hypnophrase("You have done well, you may leave now.")))
	arena_victor = TRUE

/**
 * Status applied to every mob in the heretic arena.
 * Tracks the last person to damage owner.
 * When owner enters crit, we send a signal to last_attacker status so they can leave the arena
 */

/datum/status_effect/arena_tracker
	id = "arena_tracker"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	/// Tracks the last person who dealt damage to this mob
	var/datum/weakref/last_attacker
	/// If our mob is free to leave, set to true
	var/arena_victor = FALSE
	/// The overlay for our mob, changes color to indicate that they are a victor and are free to leave
	var/mutable_appearance/crown_overlay

/datum/status_effect/arena_tracker/on_apply()
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_CRITICAL_CONDITION), PROC_REF(on_enter_crit))
	RegisterSignal(owner, COMSIG_MOVABLE_IMPACT_ZONE, PROC_REF(on_impact_zone))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(damage_taken))
	RegisterSignal(owner, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_weapon_equipped))
	owner.add_traits(list(TRAIT_ELDRITCH_ARENA_PARTICIPANT, TRAIT_NO_TELEPORT), TRAIT_STATUS_EFFECT(id))
	crown_overlay = mutable_appearance('icons/mob/effects/crown.dmi', "arena_fighter", -HALO_LAYER)
	crown_overlay.pixel_z = 24
	owner.add_overlay(crown_overlay)
	// Non-heretic debuffs: weapon restriction, slowdown, speed cap
	if(!IS_HERETIC(owner))
		INVOKE_ASYNC(src, PROC_REF(strip_forbidden_held_items))
		owner.add_movespeed_modifier(/datum/movespeed_modifier/heretic_arena_slowdown)
	return TRUE

/datum/status_effect/arena_tracker/on_remove()
	UnregisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_CRITICAL_CONDITION), COMSIG_MOB_APPLY_DAMAGE, COMSIG_MOB_EQUIPPED_ITEM))
	owner.remove_traits(list(TRAIT_ELDRITCH_ARENA_PARTICIPANT, TRAIT_NO_TELEPORT), TRAIT_STATUS_EFFECT(id))
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/heretic_arena_slowdown)
	owner.cut_overlay(crown_overlay)
	crown_overlay = null

// If our last attacker is an arena participant, we let them know they've scored a critical hit
/datum/status_effect/arena_tracker/proc/on_enter_crit(mob/owner)
	SIGNAL_HANDLER
	if(!last_attacker)
		return // Safety check in case they somehow enter crit with *nobody* attacking them
	var/mob/living/our_attacker = last_attacker.resolve()
	if(!isliving(our_attacker) || our_attacker == owner) // We don't allow people to crit themselves as a valid way to escape
		return
	var/datum/status_effect/arena_tracker/their_tracker = our_attacker.has_status_effect(/datum/status_effect/arena_tracker)
	if(!their_tracker)
		return // Somebody killed us who isn't an arena participant
	their_tracker.on_crit_somebody()

/datum/status_effect/arena_tracker/proc/damage_taken(
	datum/source,
	damage_amount,
	damagetype,
	def_zone,
	blocked,
	wound_bonus,
	exposed_wound_bonus,
	sharpness,
	attack_direction,
	attacking_item,
	wound_clothing,
)
	SIGNAL_HANDLER
	if(isnull(attacking_item))
		return
	if(!isobj(attacking_item))
		return
	var/obj/attacking_object = attacking_item

	// Track being hit by a mob holding a stick
	if(ismob(attacking_object.loc))
		last_attacker = WEAKREF(attacking_object.loc)
		return

	// Edge case. If our attacking_item is a gun which the owner has dropped we need to find out who shot us
	// Track being hit by a mob shooting a stick
	if(isprojectile(attacking_object))
		var/obj/projectile/attacking_projectile = attacking_object
		if(ismob(attacking_projectile.firer))
			last_attacker = WEAKREF(attacking_projectile.firer)

/// Drops any held items that are not a melee weapon, called once on arena entry.
/datum/status_effect/arena_tracker/proc/strip_forbidden_held_items()
	if(QDELETED(owner))
		return
	for(var/obj/item/held in owner.held_items)
		if(istype(held, /obj/item/melee))
			continue
		force_drop_weapon(held)

/**
 * Signal proc for [COMSIG_MOB_EQUIPPED_ITEM].
 * Prevents non-heretic arena participants from equipping anything other than a training blade in their hands.
 * The forbidden weapon is forcibly dropped to the ground with a short delay to avoid mid-signal re-entrancy.
 */
/datum/status_effect/arena_tracker/proc/on_weapon_equipped(mob/living/source, obj/item/equipped_item, slot)
	SIGNAL_HANDLER
	if(IS_HERETIC(owner))
		return // Heretics may wield anything
	if(!(slot & ITEM_SLOT_HANDS))
		return // Only police hand slots
	if(istype(equipped_item, /obj/item/melee))
		return // Any melee weapon is permitted
	INVOKE_ASYNC(src, PROC_REF(force_drop_weapon), equipped_item)

/datum/status_effect/arena_tracker/proc/force_drop_weapon(obj/item/weapon)
	if(QDELETED(weapon) || QDELETED(owner))
		return
	owner.balloon_alert(owner, "melee only!")
	to_chat(owner, span_warning("A mysterious force wrenches the weapon from your grasp - only melee weapons are permitted here!"))
	weapon.forceMove(get_turf(owner))

///Called when impacted by something thrown at us, setting the last attacker to the person throwing the item.
/datum/status_effect/arena_tracker/proc/on_impact_zone(atom/source, mob/living/hitby, zone, blocked, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	// Track being hit by a mob throwing a stick
	if(!isitem(throwingdatum.thrownthing))
		return
	var/thrown_by = throwingdatum?.get_thrower()
	if(ismob(thrown_by))
		last_attacker = WEAKREF(thrown_by)

/datum/antagonist/heretic_arena_participant
	name = "Arena Participant"
	show_in_roundend = FALSE
	replace_banned = FALSE
	objectives = list()
	antag_hud_name = "brainwashed"
	antag_flags = ANTAG_FAKE

/**
 * Override to enforce the heretic arena speed cap for trapped non-heretic participants.
 * This runs AFTER the zubbers /mob/living override (which applies the 0.7 floor),
 * so our cap reliably takes effect regardless of speed buffs like meth.
 */
/mob/living/carbon/human/update_movespeed()
	. = ..()
	if(HAS_TRAIT(src, TRAIT_ELDRITCH_ARENA_PARTICIPANT) && !IS_HERETIC(src))
		cached_multiplicative_slowdown = max(cached_multiplicative_slowdown, HERETIC_ARENA_SPEED_CAP)

#undef HERETIC_ARENA_SPEED_CAP

/datum/antagonist/heretic_arena_participant/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/heretic_arena_participant/forge_objectives()
	var/datum/objective/survive = new /datum/objective
	survive.owner = owner
	survive.explanation_text = "You have been trapped in an arena. The only way out is to slaughter someone else. Kill your captor, or betray your friends - the choice is yours."
	objectives += survive
	var/datum/objective/fight_to_escape = new /datum/objective
	fight_to_escape.owner = owner
	fight_to_escape.explanation_text = "Escape is impossible. The only way out is to defeat another participant in this battle to the death. \
		A weapon has been bestowed unto you, granting you a fighting chance, it would be quite a shame were you to attempt to break it."
	objectives += fight_to_escape
