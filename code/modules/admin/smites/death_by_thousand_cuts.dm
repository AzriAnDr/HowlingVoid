/// Opens a series of carp rifts that carve every bodypart open.
/datum/smite/death_by_thousand_cuts
	name = "Death by a Thousand Cuts"

/datum/smite/death_by_thousand_cuts/effect(client/user, mob/living/target)
	. = ..()

	if(!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return

	var/mob/living/carbon/carbon_target = target
	var/list/bodyparts_to_cut = shuffle(carbon_target.get_bodyparts())
	if(!length(bodyparts_to_cut))
		to_chat(user, span_warning("[target] has no bodyparts to cut."), confidential = TRUE)
		return

	carbon_target.visible_message(
		span_danger("Shimmering rifts open around [carbon_target], carving into [carbon_target.p_their()] body!"),
		span_userdanger("Shimmering rifts open around you, carving into your body!"),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)

	var/delay = 0
	for(var/obj/item/bodypart/limb as anything in bodyparts_to_cut)
		addtimer(CALLBACK(src, PROC_REF(cut_bodypart), carbon_target, limb), delay)
		delay += 0.4 SECONDS

/datum/smite/death_by_thousand_cuts/proc/cut_bodypart(mob/living/carbon/target, obj/item/bodypart/limb)
	if(QDELETED(target) || QDELETED(limb) || limb.owner != target)
		return

	var/turf/target_turf = get_turf(target)
	if(target_turf)
		var/obj/effect/temp_visual/lesser_carp_rift/rift = new(target_turf)
		var/matrix/rift_transform = matrix(rift.transform)
		rift_transform.Turn(rand(0, 70))
		rift.transform = rift_transform

	var/datum/wound/wound_type = pick(
		/datum/wound/slash/flesh/severe,
		/datum/wound/slash/flesh/critical,
	)
	limb.force_wound_upwards(wound_type, smited = TRUE, wound_source = name)
