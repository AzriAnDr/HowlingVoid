/proc/hot_lips_abduction(mob/living/romance_target, duration = 5 SECONDS)
	if(isobserver(romance_target))
		return

	var/turf/target_turf = get_turf(romance_target)
	var/list/nearby_open_turfs = list()
	for(var/turf/open/possible_turf in RANGE_TURFS(1, target_turf))
		if(possible_turf != target_turf)
			nearby_open_turfs += possible_turf

	if(!length(nearby_open_turfs))
		romance_target.gib()
		return

	ADD_TRAIT(romance_target, TRAIT_NO_TELEPORT, SMITE_TRAIT)
	romance_target.Stun(200 SECONDS, ignore_canstun = TRUE)
	romance_target.mobility_flags = NONE
	GLOB.move_manager.stop_looping(romance_target)
	romance_target.density = FALSE
	romance_target.layer = 0
	romance_target.move_resist = MOVE_RESIST_DEFAULT * 1000

	var/turf/open/the_turf = pick(nearby_open_turfs)
	romance_target.visible_message(
		span_danger("[romance_target]'s foot catches in a floor crack. The tile begins to slide away."),
		span_bolddanger("Your foot catches in a floor crack, and the tile beside you slowly slides open..."),
		blind_message = span_hear("You hear a floor tile scrape across the deck."),
	)
	playsound(the_turf, 'sound/effects/smites/floor_clown_ambience.ogg', 45, TRUE)

	var/mob/living/carbon/human/floor_romantic = new(the_turf)
	floor_romantic.name = "floor romantic"
	floor_romantic.real_name = "floor romantic"
	floor_romantic.gender = MALE
	floor_romantic.skin_tone = "african2"
	floor_romantic.hair_color = COLOR_BLACK
	floor_romantic.facial_hair_color = COLOR_BLACK
	floor_romantic.set_hairstyle("Bald", update = FALSE)
	floor_romantic.set_facial_hairstyle("Shaved", update = FALSE)
	floor_romantic.update_body(is_creating = TRUE)
	floor_romantic.set_active_language(/datum/language/common)
	var/obj/item/clothing/under/pants/slacks/orange_pants = new(floor_romantic)
	orange_pants.name = "orange pants"
	orange_pants.desc = "A pair of deeply romantic orange pants."
	orange_pants.greyscale_colors = "#ff8c19#b85b00#ffb45c"
	orange_pants.update_greyscale()
	floor_romantic.equip_to_slot_or_del(orange_pants, ITEM_SLOT_ICLOTHING, initial = TRUE)
	floor_romantic.pixel_y = -8
	floor_romantic.plane = -7
	floor_romantic.layer = 0
	floor_romantic.move_resist = MOVE_RESIST_DEFAULT * 1000
	floor_romantic.mobility_flags = NONE
	GLOB.move_manager.stop_looping(floor_romantic)
	floor_romantic.density = FALSE
	floor_romantic.add_traits(list(TRAIT_GODMODE, TRAIT_NO_TELEPORT), SMITE_TRAIT)

	animate_slide(the_turf, 0, -24, duration)
	sleep(1 SECONDS)
	if(!floor_romantic || QDELETED(floor_romantic))
		animate_slide(the_turf, 0, 0, duration)
		romance_target.gib()
		return

	floor_romantic.say("Иди сюда и поцелуй меня в жаркие уста.", forced = "floor romance smite")
	sleep(1 SECONDS)
	floor_romantic.say("Романтики хочется.", forced = "floor romance smite")
	floor_romantic.point_at(romance_target)
	sleep(2 SECONDS)
	if(!floor_romantic || QDELETED(floor_romantic))
		animate_slide(the_turf, 0, 0, duration)
		romance_target.gib()
		return

	romance_target.visible_message(
		span_bolddanger("[floor_romantic] pulls [romance_target] beneath [the_turf]!"),
		span_bolddanger("[floor_romantic] pulls you beneath [the_turf]!"),
		blind_message = span_hear("You hear a longing whisper and scraping hands."),
	)
	romance_target.Move(the_turf)
	romance_target.layer = 0
	romance_target.plane = -7
	romance_target.Stun(200 SECONDS, ignore_canstun = TRUE)
	romance_target.mobility_flags = NONE
	GLOB.move_manager.stop_looping(romance_target)
	romance_target.density = FALSE
	romance_target.layer = 0
	romance_target.move_resist = MOVE_RESIST_DEFAULT * 1000
	romance_target.anchored = TRUE

	animate_slide(the_turf, 0, 0, duration)
	sleep(1 SECONDS)
	for(var/i = 1 to 8)
		playsound(the_turf, 'sound/effects/emotes/kiss.ogg', 35, TRUE)
		sleep(0.35 SECONDS)
	playsound(the_turf, 'sound/effects/cartoon_sfx/cartoon_pop.ogg', 60, TRUE)
	romance_target.ghostize()
	qdel(romance_target)
	qdel(floor_romantic)

/datum/smite/floor_hot_lips
	name = "Floor hot lips gib"

/datum/smite/floor_hot_lips/effect(client/user, mob/living/target)
	if(!isliving(target))
		return
	if(!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return
	. = ..()

	hot_lips_abduction(target)
