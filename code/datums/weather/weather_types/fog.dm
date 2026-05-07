/datum/weather/fog
	name = "Fog"
	desc = "Thick fog covers the entire area."
	weather_flags = FUNCTIONAL_WEATHER
	turf_thunder_chance = THUNDER_CHANCE_RARE

	telegraph_message = span_danger("The fog is thickening.")
	telegraph_duration = 25 SECONDS
	telegraph_sound = 'sound/effects/air_siren.ogg'
	telegraph_sound_vol = 80
	telegraph_overlay = "fog"

	weather_message = span_userdanger("The fog is thickening around!")
	weather_duration = 20 MINUTES
	weather_duration_lower = 15 MINUTES
	weather_duration_upper = 30 MINUTES
	weather_overlay = "fog"

	end_message = span_danger("The fog is leaving!")
	end_duration = 30 SECONDS
	area_type = /area
	protected_areas = list(/area/space)

/datum/weather/fog/weather_act_mob(mob/living/living)
	if(!can_weather_act_mob(living))
		return

	if(stage == MAIN_STAGE)
		if(!living.GetComponent(/datum/component/in_the_fog))
			living.AddComponent(/datum/component/in_the_fog)
		return

	if(stage == WIND_DOWN_STAGE || stage == END_STAGE)
		var/datum/component/in_the_fog/fog_comp = living.GetComponent(/datum/component/in_the_fog)
		if(fog_comp)
			qdel(fog_comp)

/datum/weather/fog/thunder_act_turf(turf/open/weather_turf)
	return

/datum/weather/fog/generate_overlay_cache()
	if(stage == END_STAGE)
		return list()

	var/weather_state = ""
	switch(stage)
		if(STARTUP_STAGE)
			weather_state = telegraph_overlay
		if(MAIN_STAGE)
			weather_state = weather_overlay
		if(WIND_DOWN_STAGE)
			weather_state = end_overlay

	var/list/gen_overlay_cache = list()
	for(var/offset in 0 to SSmapping.max_plane_offset)
		var/mutable_appearance/new_weather_overlay = mutable_appearance('icons/effects/weather_overlays.dmi', weather_state, overlay_layer, plane = overlay_plane, offset_const = offset)
		new_weather_overlay.color = weather_color
		gen_overlay_cache += new_weather_overlay
	return gen_overlay_cache

/datum/component/in_the_fog
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/original_invisibility
	var/original_see_invisibility

	var/static/fog_invisibility_level = 60
	var/static/fog_overlay_category = "fog_effect"

	var/atom/movable/screen/fullscreen/fog_effect/fog_overlay_screen

/datum/component/in_the_fog/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/in_the_fog/RegisterWithParent()
	var/mob/living/living_parent = parent

	original_invisibility = living_parent.invisibility
	original_see_invisibility = living_parent.see_invisible
	living_parent.invisibility = fog_invisibility_level
	living_parent.see_invisible = max(living_parent.see_invisible, fog_invisibility_level)

	if(living_parent.client)
		fog_overlay_screen = living_parent.overlay_fullscreen(fog_overlay_category, /atom/movable/screen/fullscreen/fog_effect)
		update_fog_overlay()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	START_PROCESSING(SSprocessing, src)

/datum/component/in_the_fog/UnregisterFromParent()
	STOP_PROCESSING(SSprocessing, src)
	var/mob/living/living_parent = parent

	living_parent.invisibility = original_invisibility
	living_parent.see_invisible = original_see_invisibility
	if(fog_overlay_screen)
		living_parent.clear_fullscreen(fog_overlay_category)
		QDEL_NULL(fog_overlay_screen)

/datum/component/in_the_fog/process(seconds_per_tick)
	var/mob/living/living_parent = parent
	update_fog_overlay()

	if(living_parent.invisibility != fog_invisibility_level)
		living_parent.invisibility = fog_invisibility_level
	if(living_parent.see_invisible != fog_invisibility_level)
		living_parent.see_invisible = max(living_parent.see_invisible, fog_invisibility_level)

/datum/component/in_the_fog/proc/on_moved()
	SIGNAL_HANDLER
	update_fog_overlay()

/datum/component/in_the_fog/proc/update_fog_overlay()
	var/mob/living/living_parent = parent
	if(!living_parent.client)
		return

	var/turf/current_turf = get_turf(living_parent)
	if(!current_turf)
		return
	var/light_amount = current_turf.get_lumcount()
	var/is_dense = (light_amount < 0.3)
	if(fog_overlay_screen)
		var/new_icon_state = is_dense ? "fog_dense" : "fog_light"
		if(fog_overlay_screen.icon_state != new_icon_state)
			fog_overlay_screen.icon_state = new_icon_state
