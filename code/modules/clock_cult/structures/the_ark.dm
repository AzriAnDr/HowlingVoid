GLOBAL_DATUM(clock_ark, /obj/structure/destructible/clockwork/the_ark)

/obj/structure/destructible/clockwork/the_ark
	name = "\improper Ark of the Clockwork Justiciar"
	desc = "A massive, hulking amalgamation of brass and machinery. An unstable bluespace anomaly churns inside it."
	clockwork_desc = "The Ark can open a path for Ratvar. Once activated, it must be protected until the Justiciar arrives."
	icon_state = "prolonging_prism"
	anchored = TRUE
	density = TRUE
	max_integrity = 1000
	immune_to_servant_attacks = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	var/current_state = ARK_STATE_BASE
	var/charging_for = 0
	var/ready_timer_id

/obj/structure/destructible/clockwork/the_ark/Initialize(mapload)
	. = ..()
	if(!GLOB.clock_ark)
		GLOB.clock_ark = src
	SSpoints_of_interest.make_point_of_interest(src)
	update_appearance()

/obj/structure/destructible/clockwork/the_ark/Destroy()
	if(GLOB.clock_ark == src)
		GLOB.clock_ark = null
	if(!GLOB.ratvar_risen)
		send_clock_message(null, span_bigbrass("The Ark has been destroyed. Ratvar remains trapped beyond the veil."), msg_ghosts = FALSE)
		SSshuttle.clearHostileEnvironment(src)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/destructible/clockwork/the_ark/examine(mob/user)
	. = ..()
	if(IS_CLOCK(user) || isobserver(user))
		switch(current_state)
			if(ARK_STATE_BASE)
				. += span_brass("The Ark is dormant. Strike it with a Clockwork Slab to begin the opening ritual.")
			if(ARK_STATE_CHARGING)
				. += span_brass("The Ark is awakening. It will open in [DisplayTimeText(timeleft(ready_timer_id))].")
			if(ARK_STATE_ACTIVE)
				. += span_brass("The Ark is open. Ratvar arrives in [DisplayTimeText(max(ARK_ASSAULT_PERIOD - charging_for, 0))].")
			if(ARK_STATE_SUMMONING)
				. += span_brass("Ratvar is almost here.")

/obj/structure/destructible/clockwork/the_ark/attackby(obj/item/weapon, mob/living/user, params)
	if(istype(weapon, /obj/item/clockwork/clockwork_slab) && IS_CLOCK(user))
		prepare_ark(user)
		return
	return ..()

/obj/structure/destructible/clockwork/the_ark/update_icon_state()
	. = ..()
	switch(current_state)
		if(ARK_STATE_BASE)
			icon_state = "prolonging_prism"
		if(ARK_STATE_CHARGING)
			icon_state = "prolonging_prism_active"
		if(ARK_STATE_ACTIVE, ARK_STATE_SUMMONING, ARK_STATE_FINAL)
			icon_state = "prolonging_prism_active"

/obj/structure/destructible/clockwork/the_ark/update_overlays()
	. = ..()
	var/mutable_appearance/ark_eye = mutable_appearance('icons/clock_cult/clockwork_objects.dmi', "lens_gem", layer = layer + 0.1)
	ark_eye.pixel_y = 14
	ark_eye.alpha = current_state >= ARK_STATE_CHARGING ? 220 : 140
	. += ark_eye

	if(current_state >= ARK_STATE_CHARGING)
		var/mutable_appearance/gateway = mutable_appearance('icons/clock_cult/clockwork_effects.dmi', "spatial_gateway", layer = layer + 0.2)
		gateway.pixel_x = -32
		gateway.pixel_y = -32
		gateway.alpha = current_state >= ARK_STATE_ACTIVE ? 230 : 150
		. += gateway

/obj/structure/destructible/clockwork/the_ark/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	if(current_state == ARK_STATE_FINAL)
		return
	. = ..()
	if(.)
		send_clock_message(null, span_bigbrass("The Ark is taking damage!"), msg_ghosts = FALSE)
		playsound(src, 'sound/machines/clockcult/ark_deathrattle.ogg', 75, FALSE)

/obj/structure/destructible/clockwork/the_ark/process(seconds_per_tick)
	if(current_state < ARK_STATE_ACTIVE || current_state >= ARK_STATE_FINAL)
		return

	charging_for += seconds_per_tick SECONDS
	if(current_state < ARK_STATE_SUMMONING && charging_for >= (ARK_ASSAULT_PERIOD * 0.5))
		current_state = ARK_STATE_SUMMONING
		update_appearance()
		send_to_playing_players(span_warning("Reality strains around you as the ticking grows louder."))

	if(charging_for >= ARK_ASSAULT_PERIOD)
		summon_ratvar()

/obj/structure/destructible/clockwork/the_ark/proc/prepare_ark(mob/living/user)
	if(current_state > ARK_STATE_BASE)
		user?.balloon_alert(user, "already active!")
		return

	if(GLOB.charged_anchoring_crystals < ANCHORING_CRYSTALS_TO_SUMMON)
		user?.balloon_alert(user, "needs crystals!")
		to_chat(user, span_brass("The Ark cannot open yet. [GLOB.charged_anchoring_crystals]/[ANCHORING_CRYSTALS_TO_SUMMON] Anchoring Crystals are fully charged."))
		return

	current_state = ARK_STATE_CHARGING
	update_appearance()
	SSshuttle.registerHostileEnvironment(src)
	send_clock_message(null, span_bigbrass("The Ark's cogs grind to life. It will open in [DisplayTimeText(ARK_READY_PERIOD)]!"), msg_ghosts = FALSE)
	sound_to_playing_players('sound/clock_cult/magic/scripture_tier_up.ogg', 75)
	priority_announce("An anomalous clockwork energy signature has been detected aboard [station_name()]. Engineering and security personnel are advised to investigate.")
	ready_timer_id = addtimer(CALLBACK(src, PROC_REF(open_gateway)), ARK_READY_PERIOD, TIMER_STOPPABLE)

/obj/structure/destructible/clockwork/the_ark/proc/open_gateway()
	if(current_state >= ARK_STATE_ACTIVE || QDELETED(src))
		return

	current_state = ARK_STATE_ACTIVE
	update_appearance()
	charging_for = 0
	send_clock_message(null, span_bigbrass("The Ark is open. Defend it until Ratvar arrives!"), msg_ghosts = FALSE)
	sound_to_playing_players('sound/clock_cult/machinery/ark_scream.ogg', 75)
	priority_announce("Massive bluespace distortions have been detected near [get_area(src)]. Destroy their source before the anomaly reaches critical mass.", "Higher Dimensional Affairs")
	SSsecurity_level.set_level(SEC_LEVEL_DELTA)
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/clockwork/the_ark/proc/summon_ratvar()
	if(current_state >= ARK_STATE_FINAL || QDELETED(src))
		return

	current_state = ARK_STATE_FINAL
	GLOB.ratvar_risen = TRUE
	STOP_PROCESSING(SSobj, src)
	resistance_flags |= INDESTRUCTIBLE
	send_clock_message(null, span_bigbrass("Ratvar approaches. You shall be rewarded for your servitude!"), msg_ghosts = FALSE)
	send_to_playing_players(span_userdanger("THE JUSTICIAR IS HERE."))

	if(GLOB.main_clock_cult)
		for(var/datum/mind/current_mind as anything in GLOB.main_clock_cult.members)
			if(current_mind.current)
				ADD_TRAIT(current_mind.current, TRAIT_GODMODE, "ratvar")

	new /obj/ratvar(get_turf(src))
	qdel(src)
