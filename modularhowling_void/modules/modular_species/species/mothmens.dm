#define ACTIONSPEED_ID_HOWLING_MOTH_LIGHTSTRIDE "howling_moth_lightstride"
#define ACTIONSPEED_ID_HOWLING_MOTH_DARKDRAG "howling_moth_darkdrag"
#define MOOD_CATEGORY_HOWLING_MOTH_LIGHT "howling_moth_light"

/datum/species/moth
	/// Species-granted action tracked for cleanup.
	var/tmp/list/species_lamp_sense_action = list()
	/// Species-granted action tracked for cleanup.
	var/tmp/list/species_powder_burst_action = list()

/datum/species/moth/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()

	if(!istype(human_who_gained_species))
		return

	RegisterSignal(human_who_gained_species, COMSIG_MOVABLE_MOVED, PROC_REF(on_moth_moved))

	var/datum/action/cooldown/moth_lamp_sense/old_action = species_lamp_sense_action[human_who_gained_species]
	if(old_action)
		old_action.Remove(human_who_gained_species)
		qdel(old_action)
	species_lamp_sense_action[human_who_gained_species] = null

	var/datum/action/cooldown/moth_lamp_sense/new_action = new()
	new_action.Grant(human_who_gained_species)
	species_lamp_sense_action[human_who_gained_species] = new_action

	var/datum/action/cooldown/moth_powder_burst/old_burst = species_powder_burst_action[human_who_gained_species]
	if(old_burst)
		old_burst.Remove(human_who_gained_species)
		qdel(old_burst)
	species_powder_burst_action[human_who_gained_species] = null

	var/datum/action/cooldown/moth_powder_burst/new_burst = new()
	new_burst.Grant(human_who_gained_species)
	species_powder_burst_action[human_who_gained_species] = new_burst

	update_moth_light_state(human_who_gained_species)

/datum/species/moth/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	. = ..()

	if(!istype(human))
		return

	UnregisterSignal(human, COMSIG_MOVABLE_MOVED)
	human.remove_actionspeed_modifier(ACTIONSPEED_ID_HOWLING_MOTH_LIGHTSTRIDE)
	human.remove_actionspeed_modifier(ACTIONSPEED_ID_HOWLING_MOTH_DARKDRAG)
	human.clear_mood_event(MOOD_CATEGORY_HOWLING_MOTH_LIGHT)

	var/datum/action/cooldown/moth_lamp_sense/action = species_lamp_sense_action[human]
	if(action)
		action.Remove(human)
		qdel(action)
	species_lamp_sense_action[human] = null

	var/datum/action/cooldown/moth_powder_burst/burst = species_powder_burst_action[human]
	if(burst)
		burst.Remove(human)
		qdel(burst)
	species_powder_burst_action[human] = null

/datum/species/moth/proc/on_moth_moved(mob/living/carbon/human/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	update_moth_light_state(source)

/datum/species/moth/proc/update_moth_light_state(mob/living/carbon/human/source)
	if(!istype(source))
		return

	var/turf/current_turf = get_turf(source)
	if(!istype(current_turf))
		return

	var/light_amount = current_turf.get_lumcount()

	if(light_amount >= 0.5)
		source.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/moth_lightstride, multiplicative_slowdown = -0.18)
		source.remove_actionspeed_modifier(ACTIONSPEED_ID_HOWLING_MOTH_DARKDRAG)
		source.add_mood_event(MOOD_CATEGORY_HOWLING_MOTH_LIGHT, /datum/mood_event/moth_basked_in_light)
		return

	if(light_amount <= 0.15)
		source.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/moth_darkdrag, multiplicative_slowdown = 0.12)
		source.remove_actionspeed_modifier(ACTIONSPEED_ID_HOWLING_MOTH_LIGHTSTRIDE)
		source.add_mood_event(MOOD_CATEGORY_HOWLING_MOTH_LIGHT, /datum/mood_event/moth_stuck_in_darkness)
		return

	source.remove_actionspeed_modifier(ACTIONSPEED_ID_HOWLING_MOTH_LIGHTSTRIDE)
	source.remove_actionspeed_modifier(ACTIONSPEED_ID_HOWLING_MOTH_DARKDRAG)
	source.clear_mood_event(MOOD_CATEGORY_HOWLING_MOTH_LIGHT)

/datum/species/moth/create_pref_unique_perks()
	. = ..()
	. += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "lightbulb",
			SPECIES_PERK_NAME = "Phototaxis",
			SPECIES_PERK_DESC = "Moths gain morale and move faster in bright light, and can use Lamp Sense to find the brightest nearby direction.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "moon",
			SPECIES_PERK_NAME = "Dark Drag",
			SPECIES_PERK_DESC = "Deep darkness slows moths down and worsens their mood.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Powder Burst",
			SPECIES_PERK_DESC = "Moths can burst wing dust in a short radius, causing brief blur and coughing on nearby targets.",
		),
	)

/datum/actionspeed_modifier/moth_lightstride
	id = ACTIONSPEED_ID_HOWLING_MOTH_LIGHTSTRIDE
	variable = TRUE

/datum/actionspeed_modifier/moth_darkdrag
	id = ACTIONSPEED_ID_HOWLING_MOTH_DARKDRAG
	variable = TRUE

/datum/action/cooldown/moth_lamp_sense
	name = "Lamp Sense"
	desc = "Focus your antennae and lock onto the brightest nearby direction."
	button_icon = 'icons/effects/particles/notes/note_light.dmi'
	button_icon_state = "power_10"
	cooldown_time = 14 SECONDS
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/cooldown/moth_lamp_sense/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/turf/origin = get_turf(H)
	if(!istype(origin))
		return FALSE

	var/obj/machinery/light/best_lamp
	var/best_lamp_distance = 999
	var/best_lamp_brightness = -1

	for(var/obj/machinery/light/lamp in view(8, H))
		if(!lamp.on || lamp.status != LIGHT_OK)
			continue
		if(!can_see(H, lamp, 8))
			continue

		var/turf/lamp_turf = get_turf(lamp)
		if(!istype(lamp_turf))
			continue

		var/lamp_distance = get_dist(origin, lamp_turf)
		if(lamp_distance <= 0)
			continue

		if(lamp_distance > best_lamp_distance)
			continue
		if(lamp_distance == best_lamp_distance && lamp.brightness <= best_lamp_brightness)
			continue

		best_lamp = lamp
		best_lamp_distance = lamp_distance
		best_lamp_brightness = lamp.brightness

	if(best_lamp)
		var/turf/lamp_turf = get_turf(best_lamp)
		var/direction = dir2text(get_dir(H, lamp_turf))
		var/area_text
		switch(best_lamp_distance)
			if(1 to 2)
				area_text = "very close"
			if(3 to 5)
				area_text = "nearby"
			else
				area_text = "farther away"

		to_chat(H, span_notice("Your antennae lock onto an active lamp [area_text], to the [direction]."))
		H.balloon_alert(H, "lamp: [direction]")
		if(H.hud_used)
			new /atom/movable/screen/navigate_arrow/scent(null, H.hud_used, lamp_turf, COLOR_CYAN)
		StartCooldown()
		return TRUE

	to_chat(H, span_notice("Your antennae twitch, but you can't sense any active lamps nearby."))
	StartCooldown(4 SECONDS)
	return FALSE

/datum/action/cooldown/moth_powder_burst
	name = "Powder Burst"
	desc = "Shake wing dust into the air, briefly disorienting nearby targets."
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "blessed"
	cooldown_time = 26 SECONDS
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/cooldown/moth_powder_burst/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	H.visible_message(
		span_warning("[H] bursts a cloud of shimmering wing dust!"),
		span_notice("You burst a cloud of wing dust around you."),
	)
	H.balloon_alert(H, "powder burst")

	for(var/turf/nearby_turf in range(1, H))
		new /obj/effect/temp_visual/moth_pollen(nearby_turf)
		new /obj/effect/temp_visual/moth_pollen/deep(nearby_turf)

	for(var/mob/living/target_mob in range(1, H))
		if(target_mob == H)
			continue
		if(target_mob.stat == DEAD)
			continue
		if(!can_see(H, target_mob, 1))
			continue

		target_mob.adjust_eye_blur_up_to(2.5 SECONDS, 3 SECONDS)
		INVOKE_ASYNC(target_mob, TYPE_PROC_REF(/mob, emote), "cough")
		to_chat(target_mob, span_warning("Fine wing dust gets into your eyes and throat!"))

	StartCooldown()
	return TRUE

/obj/effect/temp_visual/moth_pollen
	name = "wing dust"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE
	duration = 6
	alpha = 180

/obj/effect/temp_visual/moth_pollen/Initialize(mapload)
	. = ..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(-6, 6)
	color = "#FFD166"
	animate(src, alpha = 0, pixel_y = pixel_y + rand(2, 6), time = duration)

/obj/effect/temp_visual/moth_pollen/deep
	duration = 7
	alpha = 150

/obj/effect/temp_visual/moth_pollen/deep/Initialize(mapload)
	. = ..()
	color = "#E0B84A"
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)

#undef ACTIONSPEED_ID_HOWLING_MOTH_LIGHTSTRIDE
#undef ACTIONSPEED_ID_HOWLING_MOTH_DARKDRAG
#undef MOOD_CATEGORY_HOWLING_MOTH_LIGHT
