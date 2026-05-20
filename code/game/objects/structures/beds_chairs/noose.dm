/// A hanging noose built from cable.
/obj/structure/chair/noose
	name = "noose"
	desc = "A noose suspended from above, waiting for a neck."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "noose"
	layer = FLY_LAYER
	item_chair = null
	buildstacktype = null
	buildstackamount = 0
	custom_materials = null
	fishing_modifier = 0
	/// Overlay displayed above the hanging victim.
	var/image/noose_overlay
	/// Whether someone is currently hanging from the noose.
	var/in_use = FALSE

/obj/structure/chair/noose/Initialize(mapload)
	. = ..()
	name = initial(name)
	pixel_y += 16
	noose_overlay = image(icon, "noose_overlay")
	noose_overlay.layer = FLY_LAYER
	add_overlay(noose_overlay)
	register_context()

/obj/structure/chair/noose/Destroy()
	STOP_PROCESSING(SSobj, src)
	in_use = FALSE
	noose_overlay = null
	return ..()

/obj/structure/chair/noose/MakeRotate()
	return

/obj/structure/chair/noose/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(held_item?.tool_behaviour == TOOL_WIRECUTTER && user?.buckled != src)
		context[SCREENTIP_CONTEXT_LMB] = "Cut noose"
		return CONTEXTUAL_SCREENTIP_SET

	if(!held_item && has_buckled_mobs())
		context[SCREENTIP_CONTEXT_LMB] = "Unbuckle"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/structure/chair/noose/handle_layer()
	layer = in_use ? MOB_LAYER : initial(layer)

/obj/structure/chair/noose/wrench_act_secondary(mob/living/user, obj/item/weapon)
	to_chat(user, span_warning("You need wirecutters to take the noose down."))
	return NONE

/obj/structure/chair/noose/wirecutter_act(mob/living/user, obj/item/tool)
	if(user?.buckled == src)
		to_chat(user, span_warning("You can't reach the noose while you're hanging in it!"))
		return ITEM_INTERACT_BLOCKING

	user.visible_message(
		span_notice("[user] cuts the noose."),
		span_notice("You cut the noose."),
	)

	if(has_buckled_mobs())
		for(var/mob/living/buckled_mob as anything in buckled_mobs)
			if(!buckled_mob.has_gravity())
				continue

			buckled_mob.visible_message(
				span_danger("[buckled_mob] falls to the floor!"),
				span_userdanger("You fall to the floor!"),
			)
			buckled_mob.adjust_brute_loss(10)

	var/obj/item/stack/cable_coil/cable = new(get_turf(src))
	cable.amount = 25
	tool.play_tool_sound(src)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/chair/noose/post_buckle_mob(mob/living/target)
	in_use = TRUE
	handle_layer()
	START_PROCESSING(SSobj, src)
	target.dir = SOUTH
	animate(target, pixel_y = target.base_pixel_y + 8, time = 8, easing = LINEAR_EASING)

/obj/structure/chair/noose/post_unbuckle_mob(mob/living/target)
	in_use = FALSE
	STOP_PROCESSING(SSobj, src)
	handle_layer()

	if(isnull(target))
		return

	target.pixel_x = target.base_pixel_x
	target.pixel_y = target.base_pixel_y
	pixel_x = initial(pixel_x)

/obj/structure/chair/noose/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(!has_buckled_mobs())
		return FALSE

	if(buckled_mob != user && user)
		user.visible_message(
			span_notice("[user] starts loosening the noose around [buckled_mob]'s neck..."),
			span_notice("You start loosening the noose around [buckled_mob]'s neck..."),
		)
		if(!do_after(user, 10 SECONDS, buckled_mob))
			return FALSE

		user.visible_message(
			span_notice("[user] loosens the noose around [buckled_mob]'s neck!"),
			span_notice("You loosen the noose around [buckled_mob]'s neck!"),
		)
	else
		buckled_mob.visible_message(
			span_warning("[buckled_mob] struggles to get out of the noose!"),
			span_notice("You struggle to get out of the noose..."),
		)
		if(!do_after(buckled_mob, 15 SECONDS, target = src))
			if(buckled_mob?.buckled)
				to_chat(buckled_mob, span_warning("You fail to free yourself!"))
			return FALSE
		if(!buckled_mob.buckled)
			return FALSE

		buckled_mob.visible_message(
			span_warning("[buckled_mob] removes the noose from [buckled_mob.p_their()] neck."),
			span_notice("You remove the noose from your neck!"),
		)
		buckled_mob.Knockdown(6 SECONDS)

	unbuckle_mob(buckled_mob, force = TRUE)
	add_fingerprint(user)
	return TRUE

/obj/structure/chair/noose/user_buckle_mob(mob/living/target, mob/user, check_loc = TRUE)
	if(!in_range(user, src) || user.incapacitated || !iscarbon(target))
		return FALSE

	if(!target.get_bodypart(BODY_ZONE_HEAD))
		to_chat(user, span_warning("[target] has no head!"))
		return FALSE

	if(target.loc != loc)
		return FALSE

	add_fingerprint(user)

	target.visible_message(
		span_danger("[user] tries to put a noose around [target]'s neck!"),
		span_userdanger("[user] is trying to put a noose around your neck!"),
	)

	if(user != target)
		to_chat(user, span_notice("This will take some time..."))

	var/buckle_time = user == target ? 1 SECONDS : 10 SECONDS
	if(do_after(user, buckle_time, target))
		if(buckle_mob(target))
			if(target == user)
				user.visible_message(
					span_warning("[user] hangs [user.p_them()]self!"),
					span_userdanger("You hang yourself!"),
				)
			else
				user.visible_message(
					span_warning("[user] hangs [target]!"),
					span_userdanger("You hang [target]!"),
				)
				to_chat(target, span_userdanger("[user] hangs you!"))

			playsound(user.loc, 'sound/effects/noose/noosed.ogg', 50, TRUE, -1)
			log_combat(user, target, "hanged", src)
			return TRUE

	user.visible_message(
		span_warning("[user] fails to get the noose around [target]'s neck!"),
		span_warning("You fail to get the noose around [target]'s neck!"),
	)
	log_combat(user, target, "tried to hang", src)
	return FALSE

/obj/structure/chair/noose/process()
	if(!has_buckled_mobs())
		STOP_PROCESSING(SSobj, src)
		return

	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		if(pixel_x >= 0)
			animate(src, pixel_x = -3, time = 45, easing = ELASTIC_EASING)
			animate(buckled_mob, pixel_x = -3, time = 45, easing = ELASTIC_EASING)
		else
			animate(src, pixel_x = 3, time = 45, easing = ELASTIC_EASING)
			animate(buckled_mob, pixel_x = 3, time = 45, easing = ELASTIC_EASING)

		if(!buckled_mob.has_gravity())
			continue

		if(!buckled_mob.get_bodypart(BODY_ZONE_HEAD))
			unbuckle_all_mobs(TRUE)
			STOP_PROCESSING(SSobj, src)
			return

		buckled_mob.adjust_oxy_loss(5)
		buckled_mob.adjust_brute_loss(HAS_TRAIT(buckled_mob, TRAIT_NOBREATH) ? 10 : 2)

		if(prob(40) && buckled_mob.stat == CONSCIOUS)
			buckled_mob.emote("gasp")

		if(prob(20))
			var/list/flavor_text
			if(buckled_mob.stat == DEAD)
				flavor_text = list(
					span_suicide("[buckled_mob] swings sluggishly on the noose."),
					span_suicide("[buckled_mob]'s gaze is fixed on nothing."),
				)
			else
				flavor_text = list(
					span_suicide("[buckled_mob] kicks [buckled_mob.p_their()] legs in agony."),
					span_suicide("[buckled_mob] struggles against the noose."),
					span_suicide("[buckled_mob] sways back and forth, gradually slowing down."),
				)

			if(prob(5))
				buckled_mob.visible_message(pick(flavor_text))

			playsound(buckled_mob.loc, 'sound/effects/noose/noose_idle.ogg', 30, TRUE, -3)

/// Spawned by the admin smite. The victim cannot escape without help.
/obj/structure/chair/noose/divine
	name = "inescapable divine noose"
	desc = "A noose that descended from the heavens. There is no escape without help..."

/obj/structure/chair/noose/divine/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(!has_buckled_mobs())
		return FALSE

	if(buckled_mob == user || !user)
		to_chat(buckled_mob, span_warning("The noose tightens as you struggle! You cannot escape on your own!"))
		return FALSE

	return ..()

/// Spawned by the admin smite. The victim is dragged skyward and removed permanently.
/obj/structure/chair/noose/heavenly
	name = "heavenly noose"
	desc = "A noose that descended from the heavens. It seems to be pulling upwards..."
	/// Whether the noose is currently ascending.
	var/ascending = FALSE
	/// How long the victim hangs before the ascension starts.
	var/ascension_delay = 3 SECONDS
	/// How long the ascension animation takes.
	var/ascension_duration = 4 SECONDS

/obj/structure/chair/noose/heavenly/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(!has_buckled_mobs())
		return FALSE

	if(ascending)
		if(user)
			to_chat(user, span_warning("It's too late! They are already being taken to heaven!"))
		return FALSE

	to_chat(buckled_mob, span_warning("The noose tightens with divine force! There is no escape from heaven's call!"))
	return FALSE

/obj/structure/chair/noose/heavenly/post_buckle_mob(mob/living/buckled_mob)
	..()
	addtimer(CALLBACK(src, PROC_REF(begin_ascension)), ascension_delay)

/obj/structure/chair/noose/heavenly/proc/begin_ascension()
	if(!has_buckled_mobs() || ascending)
		return

	ascending = TRUE
	STOP_PROCESSING(SSobj, src)

	for(var/mob/living/victim as anything in buckled_mobs)
		if(QDELETED(victim))
			continue

		ADD_TRAIT(victim, TRAIT_IMMOBILIZED, REF(src))
		victim.dir = SOUTH
		victim.visible_message(
			span_userdanger("The noose begins pulling [victim] upwards towards the heavens!"),
			span_userdanger("You feel yourself being lifted towards the heavens. There is no escape now."),
		)
		playsound(loc, 'sound/effects/noose/noosed.ogg', 50, FALSE)
		animate(src, pixel_y = 400, time = ascension_duration, easing = SINE_EASING | EASE_IN)
		animate(victim, pixel_y = victim.pixel_y + 384, time = ascension_duration, easing = SINE_EASING | EASE_IN)

	addtimer(CALLBACK(src, PROC_REF(complete_ascension)), ascension_duration)

/obj/structure/chair/noose/heavenly/proc/complete_ascension()
	for(var/mob/living/victim as anything in buckled_mobs)
		if(QDELETED(victim))
			continue

		to_chat(victim, span_userdanger("You have been taken to heaven. Your journey on this mortal plane has ended."))
		if(victim.client)
			victim.ghostize(can_reenter_corpse = FALSE)

		log_admin("[key_name(victim)] was permanently removed by heavenly noose ascension.")
		message_admins("[ADMIN_LOOKUPFLW(victim)] was permanently removed by heavenly noose ascension.")
		qdel(victim)

	qdel(src)

/// A noose-trap that audibly reveals itself when spotted and snaps shut on anyone stepping onto it.
/obj/structure/chair/noose/trap
	name = "noose?"
	/// Mobs who can currently see the trap and have already heard its reveal cue.
	var/list/alerted_viewers = list()

/obj/structure/chair/noose/trap/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	START_PROCESSING(SSobj, src)

/obj/structure/chair/noose/trap/Destroy()
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		buckled_mob.cure_blind(REF(src))
	alerted_viewers = null
	return ..()

/obj/structure/chair/noose/trap/post_buckle_mob(mob/living/target)
	..()
	target.become_blind(REF(src))

/obj/structure/chair/noose/trap/post_unbuckle_mob(mob/living/target)
	target?.cure_blind(REF(src))
	..()
	if(!QDELETED(src))
		START_PROCESSING(SSobj, src)

/obj/structure/chair/noose/trap/process()
	if(in_use)
		return ..()

	update_alerted_viewers()

/obj/structure/chair/noose/trap/proc/update_alerted_viewers()
	var/list/current_viewers = list()

	for(var/mob/living/viewer as anything in viewers(maxviewdist(), src))
		if(!viewer.client || viewer.stat != CONSCIOUS || viewer.is_blind())
			continue

		var/view_distance = maxviewdist(viewer.client.view)
		if(!can_see(viewer, src, view_distance))
			continue

		current_viewers += viewer
		if(viewer in alerted_viewers)
			continue

		alerted_viewers += viewer
		viewer.playsound_local(get_turf(src), 'sound/effects/noose/petelka_apears.ogg', 50, FALSE)

	for(var/mob/living/old_viewer as anything in alerted_viewers.Copy())
		if(old_viewer in current_viewers)
			continue
		alerted_viewers -= old_viewer

/obj/structure/chair/noose/trap/proc/on_entered(datum/source, atom/movable/entered_atom)
	SIGNAL_HANDLER

	if(in_use)
		return

	var/mob/living/carbon/target = entered_atom
	if(!istype(target) || target.buckled || target.has_buckled_mobs() || target.incorporeal_move)
		return
	if(!target.get_bodypart(BODY_ZONE_HEAD))
		return

	if(!buckle_mob(target, force = TRUE))
		return

	target.visible_message(
		span_danger("[src] suddenly coils around [target]'s neck and tightens with a sickening snap!"),
		span_userdanger("[src] suddenly coils around your neck and tightens with a sickening snap!"),
	)
	playsound(loc, 'sound/effects/noose/petelka_grabs.ogg', 50, TRUE, -1)
	log_combat(src, target, "suddenly ensnared", addition = "and coiled around [target.p_their()] neck and tightened with a sickening snap")
