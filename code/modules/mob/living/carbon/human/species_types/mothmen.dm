/datum/species/moth
	name = "\improper Mothman"
	plural_form = "Mothmen"
	id = SPECIES_MOTH
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	/* NOVA EDIT REMOVAL START - Customization
	body_markings = list(
		/datum/bodypart_overlay/simple/body_marking/moth = SPRITE_ACCESSORY_NONE,
	)
	mutant_organs = list(
		/obj/item/organ/wings/moth = "Plain",
		/obj/item/organ/antennae = "Plain",
	)
	*/ // NOVA EDIT REMOVAL END
	meat = /obj/item/food/meat/slab/human/mutant/moth
	mutanttongue = /obj/item/organ/tongue/moth
	mutanteyes = /obj/item/organ/eyes/moth
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_cookie = /obj/item/food/muffin/moffin
	species_language_holder = /datum/language_holder/moth
	death_sound = 'sound/mobs/humanoids/moth/moth_death.ogg'
	payday_modifier = 1.0
	family_heirlooms = list(/obj/item/flashlight/lantern/heirloom_moth)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/moth,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/moth,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/moth,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/moth,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/moth,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/moth,
	)

/datum/species/moth/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	RegisterSignal(human_who_gained_species, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

/datum/species/moth/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(C, COMSIG_ATOM_ATTACKBY)

/datum/species/moth/proc/on_attackby(mob/living/source, obj/item/attacking_item, mob/living/attacker, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER

	if(istype(attacking_item, /obj/item/melee/flyswatter))
		MODIFY_ATTACK_FORCE_MULTIPLIER(attack_modifiers, 10) // Yes, a 10x damage modifier

/datum/species/moth/randomize_features()
	var/list/features = ..()
	features[FEATURE_MOTH_MARKINGS] = pick(SSaccessories.feature_list[FEATURE_MOTH_MARKINGS])
	return features

/datum/species/moth/get_scream_sound(mob/living/carbon/human/moth)
	return 'sound/mobs/humanoids/moth/scream_moth.ogg'

/datum/species/moth/get_cough_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cough/female_cough1.ogg',
			'sound/mobs/humanoids/human/cough/female_cough2.ogg',
			'sound/mobs/humanoids/human/cough/female_cough3.ogg',
			'sound/mobs/humanoids/human/cough/female_cough4.ogg',
			'sound/mobs/humanoids/human/cough/female_cough5.ogg',
			'sound/mobs/humanoids/human/cough/female_cough6.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cough/male_cough1.ogg',
		'sound/mobs/humanoids/human/cough/male_cough2.ogg',
		'sound/mobs/humanoids/human/cough/male_cough3.ogg',
		'sound/mobs/humanoids/human/cough/male_cough4.ogg',
		'sound/mobs/humanoids/human/cough/male_cough5.ogg',
		'sound/mobs/humanoids/human/cough/male_cough6.ogg',
	)


/datum/species/moth/get_cry_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cry/female_cry1.ogg',
			'sound/mobs/humanoids/human/cry/female_cry2.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cry/male_cry1.ogg',
		'sound/mobs/humanoids/human/cry/male_cry2.ogg',
		'sound/mobs/humanoids/human/cry/male_cry3.ogg',
	)


/datum/species/moth/get_sneeze_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg'
	return 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg'


/datum/species/moth/get_laugh_sound(mob/living/carbon/human/moth)
	return 'sound/mobs/humanoids/moth/moth_laugh1.ogg'

/datum/species/moth/get_sigh_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return SFX_FEMALE_SIGH
	return SFX_MALE_SIGH

/datum/species/moth/get_sniff_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sniff/female_sniff.ogg'
	return 'sound/mobs/humanoids/human/sniff/male_sniff.ogg'

/datum/species/moth/get_physical_attributes()
	return "Moths have large and fluffy wings, which help them navigate the station if gravity is offline by pushing the air around them. \
		Due to that, it isn't of much use out in space. Their eyes are very sensitive."

/datum/species/moth/get_species_description()
	return "Hailing from a planet that was lost long ago, the moths travel \
		the galaxy as a nomadic people aboard a colossal fleet of ships, seeking a new homeland."

/datum/species/moth/get_species_lore()
	return list(
		"Their homeworld lost to the ages, the moths live aboard the Grand Nomad Fleet. \
		Made up of what could be found, bartered, repaired, or stolen the armada is a colossal patchwork \
		built on a history of politely flagging travelers down and taking their things. Occasionally a moth \
		will decide to leave the fleet, usually to strike out for fortunes to send back home.",

		"Nomadic life produces a tight-knit culture, with moths valuing their friends, family, and vessels highly. \
		Moths are gregarious by nature and do best in communal spaces. This has served them well on the galactic stage, \
		maintaining a friendly and personable reputation even in the face of hostile encounters. \
		It seems that the galaxy has come to accept these former pirates.",

		"Surprisingly, living together in a giant fleet hasn't flattened variance in dialect and culture. \
		These differences are welcomed and encouraged within the fleet for the variety that they bring.",
	)

/datum/species/moth/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "feather-alt",
			SPECIES_PERK_NAME = "Precious Wings",
			SPECIES_PERK_DESC = "Moths can fly in pressurized, zero-g environments and safely land short falls using their wings.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "tshirt",
			SPECIES_PERK_NAME = "Meal Plan",
			SPECIES_PERK_DESC = "Moths can eat clothes for nourishment.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Ablazed Wings",
			SPECIES_PERK_DESC = "Moth wings are fragile, and can be easily burnt off.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Bright Lights",
			SPECIES_PERK_DESC = "Moths need an extra layer of flash protection to protect \
				themselves, such as against security officers or when welding. Welding \
				masks will work.",
		),
	)

	return to_add

// HowlingVoid moth mechanics integration.
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

