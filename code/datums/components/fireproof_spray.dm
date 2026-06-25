/datum/component/spray_fireproofed
	/// How much fire protection we have left before it wears off.
	var/spray_health = 1000
	/// The amount of time the item can be in fire safely. -1 makes it permanent.
	var/fire_immunity_time
	/// The time it takes for the item to cool off and grant fire resistance again.
	var/cooling_off_time
	/// Whether the spray is cooling down.
	var/cooling_down
	/// Timer id for the fire immunity.
	var/fire_immunity_timer
	/// The cooldown it takes for the item to cool off once it reaches its resistance threshold.
	COOLDOWN_DECLARE(cool_off_cd)

/datum/component/spray_fireproofed/Initialize(immunity_time = 60 SECONDS, cooloff_time = 5 SECONDS)
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/clothing/clothing_parent = parent
	if(clothing_parent.resistance_flags & FIRE_PROOF)
		stack_trace("Tried to add /datum/component/spray_fireproofed to an item ([clothing_parent.type]) that was already fireproof!")
		return COMPONENT_INCOMPATIBLE

	if(immunity_time == -1)
		add_fireproofing()
		return COMPONENT_REDUNDANT

	fire_immunity_time = immunity_time
	cooling_off_time = cooloff_time

/datum/component/spray_fireproofed/Destroy(force)
	if(!QDELETED(parent))
		var/obj/item/clothing/clothing_parent = parent
		var/mob/parent_loc = clothing_parent.loc
		if(!force && istype(parent_loc))
			parent_loc.balloon_alert(parent_loc, "fireproof spray wears off of [parent]!")
	deltimer(fire_immunity_timer)
	return ..()

/datum/component/spray_fireproofed/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_PRE_FIRE_ACT, PROC_REF(on_pre_fire_act))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

	add_fireproofing()

/datum/component/spray_fireproofed/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_PRE_FIRE_ACT,
		COMSIG_ATOM_EXAMINE,
	))
	remove_fireproofing()

/datum/component/spray_fireproofed/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, cool_off_cd))
		return

	cooling_down = FALSE
	STOP_PROCESSING(SSburning, src)

/datum/component/spray_fireproofed/proc/add_fireproofing()
	var/obj/item/clothing/clothing_parent = parent
	clothing_parent.resistance_flags |= FIRE_PROOF
	clothing_parent.name = "fireproofed " + clothing_parent.name

/datum/component/spray_fireproofed/proc/remove_fireproofing()
	var/obj/item/clothing/clothing_parent = parent
	if(!QDELETED(clothing_parent))
		clothing_parent.resistance_flags &= ~FIRE_PROOF
		clothing_parent.name = replacetext(clothing_parent.name, "fireproofed ", "")

/datum/component/spray_fireproofed/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("It is coated with fireproofing material.[spray_health <= 500 ? " It is beginning to wear off." : ""]")

/datum/component/spray_fireproofed/proc/on_pre_fire_act(obj/source, exposed_temperature, exposed_volume)
	SIGNAL_HANDLER

	if(!cooling_down && !timeleft(fire_immunity_timer))
		fire_immunity_timer = addtimer(CALLBACK(src, PROC_REF(end_fire_immunity)), fire_immunity_time, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE|TIMER_DELETE_ME)
		return

	if(cooling_down && exposed_temperature >= FIRE_MINIMUM_TEMPERATURE_TO_SPREAD)
		spray_health -= min(10, exposed_temperature / 100)

	if(spray_health <= 0)
		qdel(src)
		return

	if(cooling_down && !COOLDOWN_FINISHED(src, cool_off_cd))
		COOLDOWN_START(src, cool_off_cd, cooling_off_time)

/datum/component/spray_fireproofed/proc/end_fire_immunity()
	COOLDOWN_START(src, cool_off_cd, cooling_off_time)
	cooling_down = TRUE
	START_PROCESSING(SSburning, src)
