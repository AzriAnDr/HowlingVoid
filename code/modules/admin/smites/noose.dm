/// Drops a noose from above and hangs the target.
/datum/smite/noose
	name = "Noose"
	smite_flags = SMITE_DIVINE | SMITE_STUN
	/// Whether the victim can escape on their own.
	var/can_self_escape = FALSE
	/// Whether the noose should carry the victim away permanently.
	var/fly_to_heaven = FALSE

/datum/smite/noose/configure(client/user)
	var/escape_input = tgui_alert(user, "Can the victim escape on their own?", "Self Escape", list("Yes", "No"))
	if(isnull(escape_input))
		return FALSE
	can_self_escape = escape_input == "Yes"

	var/heaven_input = tgui_alert(user, "Should the noose fly to heaven after hanging? This permanently removes the victim.", "Fly To Heaven", list("Yes", "No"))
	if(isnull(heaven_input))
		return FALSE
	fly_to_heaven = heaven_input == "Yes"
	return TRUE

/datum/smite/noose/effect(client/user, mob/living/target)
	if(!iscarbon(target))
		to_chat(user, span_warning("[target] is not a carbon mob and cannot be hanged with a noose."))
		return

	if(!target.get_bodypart(BODY_ZONE_HEAD))
		to_chat(user, span_warning("[target] has no head to put a noose around."))
		return

	var/turf/target_turf = get_turf(target)
	if(isnull(target_turf))
		return

	. = ..()
	ADD_TRAIT(target, TRAIT_IMMOBILIZED, "smite_noose")
	ADD_TRAIT(target, TRAIT_HANDS_BLOCKED, "smite_noose")
	to_chat(target, span_userdanger("You feel a dark presence looming above you..."))

	new /obj/effect/temp_visual/noose_descending(target_turf)
	addtimer(CALLBACK(src, PROC_REF(hang_target), target, can_self_escape, fly_to_heaven), 5 SECONDS)

/datum/smite/noose/proc/hang_target(mob/living/target, allow_self_escape, ascend_to_heaven)
	if(QDELETED(target))
		return

	REMOVE_TRAIT(target, TRAIT_IMMOBILIZED, "smite_noose")
	REMOVE_TRAIT(target, TRAIT_HANDS_BLOCKED, "smite_noose")

	if(!iscarbon(target) || !target.get_bodypart(BODY_ZONE_HEAD))
		return

	var/turf/target_turf = get_turf(target)
	if(isnull(target_turf))
		return

	var/obj/structure/chair/noose/spawned_noose
	if(ascend_to_heaven)
		spawned_noose = new /obj/structure/chair/noose/heavenly(target_turf)
	else if(allow_self_escape)
		spawned_noose = new /obj/structure/chair/noose(target_turf)
		spawned_noose.name = "divine noose"
		spawned_noose.desc = "A noose that descended from the heavens."
	else
		spawned_noose = new /obj/structure/chair/noose/divine(target_turf)

	if(!spawned_noose.buckle_mob(target, force = TRUE))
		qdel(spawned_noose)
		return

	playsound(target_turf, 'sound/effects/noose/noosed.ogg', 70, FALSE)

	if(ascend_to_heaven)
		target.visible_message(
			span_userdanger("A noose descends from above and yanks [target] into it! The noose begins ascending back to the heavens!"),
			span_userdanger("A noose descends from above and yanks you into it! The gods are taking you to heaven!"),
		)
	else
		target.visible_message(
			span_userdanger("A noose descends from above and yanks [target] into it!"),
			span_userdanger("A noose descends from above and yanks you into it! The gods have judged you!"),
		)

/// Visual effect of a noose descending from above.
/obj/effect/temp_visual/noose_descending
	name = "descending noose"
	desc = "A noose descending from the heavens..."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "noose"
	layer = FLY_LAYER
	duration = 4.5 SECONDS
	pixel_y = 200

/obj/effect/temp_visual/noose_descending/Initialize(mapload)
	. = ..()
	animate(src, pixel_y = 16, time = duration, easing = SINE_EASING)
