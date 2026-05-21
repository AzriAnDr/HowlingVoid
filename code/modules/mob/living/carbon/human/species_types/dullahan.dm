/datum/species/dullahan
	name = "Dullahan"
	id = SPECIES_DULLAHAN
	examine_limb_id = SPECIES_HUMAN
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_NOHUNGER,
		TRAIT_USES_SKINTONES,
		TRAIT_ADVANCEDTOOLUSER, // Normally applied by brain but we don't have one
		TRAIT_LITERATE,
		TRAIT_CAN_STRIP,
		TRAIT_BRAINLESS_CARBON,
	)
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/dullahan,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest,
	)
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	mutantbrain = /obj/item/organ/brain/dullahan
	mutanteyes = /obj/item/organ/eyes/dullahan
	mutanttongue = /obj/item/organ/tongue/dullahan
	mutantears = /obj/item/organ/ears/dullahan
	mutantstomach = null
	mutantlungs = null
	skinned_type = /obj/item/stack/sheet/animalhide/carbon/human
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

	/// The dullahan relay that's associated with the owner, used to handle many things such as talking and hearing.
	var/obj/item/dullahan_relay/my_head
	/// Did our owner's first client connection get handled yet? Useful for when some proc needs to be called once we're sure that a client has moved into our owner, like for Dullahans.
	var/owner_first_client_connection_handled = FALSE

/datum/species/dullahan/check_roundstart_eligible()
	if(check_holidays(HALLOWEEN))
		return TRUE
	return ..()

/datum/species/dullahan/on_species_gain(mob/living/carbon/human/human, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	human.lose_hearing_sensitivity(TRAIT_GENERIC)
	RegisterSignal(human, COMSIG_CARBON_ATTACH_LIMB, PROC_REF(on_gained_part))
	RegisterSignal(human, COMSIG_CARBON_DEFIB_BRAIN_CHECK, PROC_REF(defib_check))

	var/obj/item/bodypart/head/head = human.get_bodypart(BODY_ZONE_HEAD)
	head.speech_span = null
	if(isnull(human.drop_location()))
		return
	head?.drop_limb()
	if(QDELETED(head)) //drop_limb() deletes the limb if no drop location exists and character setup dummies are located in nullspace.
		return
	my_head = new /obj/item/dullahan_relay(head, human)
	human.put_in_hands(head)

	// We want to give the head some boring old eyes just so it doesn't look too jank on the head sprite.
	var/obj/item/organ/eyes/eyes = new /obj/item/organ/eyes(head)
	eyes.eye_color_left = human.eye_color_left
	eyes.eye_color_right = human.eye_color_right
	eyes.bodypart_insert(head)
	human.update_body()
	head.update_limb()
	head.update_icon_dropped()
	RegisterSignal(head, COMSIG_QDELETING, PROC_REF(on_head_destroyed))
	RegisterSignal(my_head, COMSIG_MOVABLE_MOVED, PROC_REF(on_relay_move))

/// If we gained a new body part, it had better not be a head
/datum/species/dullahan/proc/on_gained_part(mob/living/carbon/human/dullahan, obj/item/bodypart/part)
	SIGNAL_HANDLER
	if(part.body_zone != BODY_ZONE_HEAD)
		return
	if(isnull(dullahan.drop_location()))
		return // don't gib nullspace
	my_head = null
	dullahan.investigate_log("has been gibbed by having an illegal head put on [dullahan.p_their()] shoulders.", INVESTIGATE_DEATHS)
	dullahan.gib(DROP_ALL_REMAINS) // Yeah so giving them a head on their body is really not a good idea, so their original head will remain but uh, good luck fixing it after that.

/// If our head is destroyed, so are we
/datum/species/dullahan/proc/on_head_destroyed()
	SIGNAL_HANDLER
	var/mob/living/human = my_head?.owner
	if(QDELETED(human))
		return // guess we already died
	my_head = null
	human.investigate_log("has been gibbed by the loss of [human.p_their()] head.", INVESTIGATE_DEATHS)
	human.gib(DROP_ALL_REMAINS)

/// Head was butchered? No more dullahan
/datum/species/dullahan/proc/on_relay_move()
	SIGNAL_HANDLER
	if(QDELETED(my_head?.owner) || !isdullahan(my_head?.owner))
		return
	my_head.owner.gib(DROP_ALL_REMAINS)
	QDEL_NULL(my_head)

/datum/species/dullahan/proc/defib_check(mob/living/carbon/human/human)
	SIGNAL_HANDLER
	return human.can_defib_brain(locate(/obj/item/organ/brain) in my_head.loc) || DEFIB_POSSIBLE

/datum/species/dullahan/on_species_loss(mob/living/carbon/human/human)
	. = ..()
	if(my_head)
		var/obj/item/bodypart/head/detached_head = my_head.loc
		UnregisterSignal(detached_head, COMSIG_QDELETING)
		my_head.owner = null
		QDEL_NULL(my_head)
		if(detached_head)
			qdel(detached_head)

	UnregisterSignal(human, COMSIG_CARBON_ATTACH_LIMB)
	UnregisterSignal(human, COMSIG_CARBON_DEFIB_BRAIN_CHECK)
	human.regenerate_limb(BODY_ZONE_HEAD, FALSE)
	human.become_hearing_sensitive()
	prevent_perspective_change = FALSE
	human.reset_perspective(human)

/datum/species/dullahan/proc/update_vision_perspective(mob/living/carbon/human/human)
	var/obj/item/organ/eyes/eyes = human.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes)
		human.update_tint()
		if(eyes.tint)
			prevent_perspective_change = FALSE
			human.reset_perspective(human, TRUE)
		else
			human.reset_perspective(my_head, TRUE)
			prevent_perspective_change = TRUE

/datum/species/dullahan/on_owner_login(mob/living/carbon/human/owner)
	var/obj/item/organ/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(owner_first_client_connection_handled)
		if(!eyes.tint)
			owner.reset_perspective(my_head, TRUE)
			prevent_perspective_change = TRUE
		return

	// As it's the first time there's a client in our mob, we can finally update its vision to place it in the head instead!
	var/datum/action/item_action/organ_action/dullahan/eyes_toggle_perspective_action = locate() in eyes?.actions

	eyes_toggle_perspective_action?.Trigger()
	owner_first_client_connection_handled = TRUE

/datum/species/dullahan/get_physical_attributes()
	return "A dullahan is much like a human, but their head is detached from their body and must be carried around."

/datum/species/dullahan/get_species_description()
	return "An angry spirit, hanging onto the land of the living for \
		unfinished business. Or that's what the books say. They're quite nice \
		when you get to know them."

/datum/species/dullahan/get_species_lore()
	return list(
		"\"No wonder they're all so grumpy! Their hands are always full! I used to think, \
		\"Wouldn't this be cool?\" but after watching these creatures suffer from their head \
		getting dunked down disposals for the nth time, I think I'm good.\" - Captain Larry Dodd"
	)

/datum/species/dullahan/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "horse-head",
		SPECIES_PERK_NAME = "Headless and Horseless",
		SPECIES_PERK_DESC = "Dullahans must lug their head around in their arms. While \
			many creative uses can come out of your head being independent of your \
			body, Dullahans will find it mostly a pain.",
	))

	return to_add

// There isn't a "Minor Undead" biotype, so we have to explain it in an override (see: vampires)
/datum/species/dullahan/create_pref_biotypes_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "skull",
		SPECIES_PERK_NAME = "Minor Undead",
		SPECIES_PERK_DESC = "[name] are minor undead. \
			Minor undead enjoy some of the perks of being dead, like \
			not needing to breathe or eat, but do not get many of the \
			environmental immunities involved with being fully undead.",
	))

	return to_add

/obj/item/organ/brain/dullahan
	decoy_override = TRUE
	organ_flags = ORGAN_ORGANIC //not vital

/obj/item/organ/tongue/dullahan
	zone = BODY_ZONE_CHEST
	organ_flags = parent_type::organ_flags | ORGAN_UNREMOVABLE
	modifies_speech = TRUE

/obj/item/organ/tongue/dullahan/handle_speech(datum/source, list/speech_args)
	if(ishuman(owner))
		var/mob/living/carbon/human/human = owner
		if(isdullahan(human))
			var/datum/species/dullahan/dullahan_species = human.dna.species
			if(isobj(dullahan_species.my_head.loc))
				var/obj/head = dullahan_species.my_head.loc
				// NOVA EDIT ADDITION START
				if(speech_args[SPEECH_MODS][MODE_HEADSET] || speech_args[SPEECH_MODS][RADIO_EXTENSION])
					human.radio(message = speech_args[SPEECH_MESSAGE], message_mods = speech_args[SPEECH_MODS], spans = speech_args[SPEECH_SPANS], language = speech_args[SPEECH_LANGUAGE])
				// NOVA EDIT ADDITION END
				if(speech_args[SPEECH_MODS][WHISPER_MODE]) // whisper away
					speech_args[SPEECH_SPANS] |= SPAN_ITALICS
				head.say(speech_args[SPEECH_MESSAGE], spans = speech_args[SPEECH_SPANS], sanitize = FALSE, language = speech_args[SPEECH_LANGUAGE], message_range = speech_args[SPEECH_RANGE], message_mods = speech_args[SPEECH_MODS])
	speech_args[SPEECH_MESSAGE] = ""

/obj/item/organ/ears/dullahan
	zone = BODY_ZONE_CHEST
	organ_flags = parent_type::organ_flags | ORGAN_UNREMOVABLE
	decay_factor = 0

/obj/item/organ/eyes/dullahan
	name = "head vision"
	desc = "An abstraction."
	actions_types = list(/datum/action/item_action/organ_action/dullahan)
	zone = BODY_ZONE_CHEST
	organ_flags = parent_type::organ_flags | ORGAN_UNREMOVABLE
	decay_factor = 0
	tint = INFINITY // to switch the vision perspective to the head on species_gain() without issue.

/datum/action/item_action/organ_action/dullahan
	name = "Toggle Perspective"
	desc = "Switch between seeing normally from your head, or blindly from your body."

/datum/action/item_action/organ_action/dullahan/do_effect(trigger_flags)
	var/obj/item/organ/eyes/dullahan/dullahan_eyes = target
	dullahan_eyes.tint = dullahan_eyes.tint ? NONE : INFINITY
	if(!isdullahan(owner))
		return FALSE
	var/mob/living/carbon/human/human = owner
	var/datum/species/dullahan/dullahan_species = human.dna.species
	dullahan_species.update_vision_perspective(human)
	return TRUE


/obj/item/dullahan_relay
	name = "dullahan relay"
	/// The mob (a dullahan) that owns this relay.
	var/mob/living/owner

/obj/item/dullahan_relay/Initialize(mapload, mob/living/carbon/human/new_owner)
	. = ..()
	if(!new_owner)
		return INITIALIZE_HINT_QDEL
	var/obj/item/bodypart/head/detached_head = loc
	if (!istype(detached_head))
		return INITIALIZE_HINT_QDEL
	owner = new_owner
	START_PROCESSING(SSobj, src)
	RegisterSignal(owner, COMSIG_CARBON_REGENERATE_LIMBS, PROC_REF(unlist_head))
	RegisterSignal(owner, COMSIG_LIVING_REVIVE, PROC_REF(retrieve_head))
	RegisterSignal(owner, COMSIG_HUMAN_PREFS_APPLIED, PROC_REF(on_prefs_loaded))
	become_hearing_sensitive(ROUNDSTART_TRAIT)

/obj/item/dullahan_relay/Destroy()
	lose_hearing_sensitivity(ROUNDSTART_TRAIT)
	owner = null
	return ..()

/// Updates our names after applying name prefs
/obj/item/dullahan_relay/proc/on_prefs_loaded(mob/living/carbon/human/headless)
	SIGNAL_HANDLER
	var/obj/item/bodypart/head/detached_head = loc
	if (!istype(detached_head))
		return // It's so over
	detached_head.real_name = headless.real_name
	name = headless.real_name
	detached_head.voice = headless.voice
	detached_head.pitch = pitch
	var/obj/item/organ/brain/brain = locate(/obj/item/organ/brain) in detached_head
	brain.name = "[headless.name]'s brain"

	detached_head.copy_appearance_from(headless, overwrite_eyes = TRUE)
	detached_head.update_icon_dropped()

/obj/item/dullahan_relay/Hear(atom/movable/speaker, message_language, raw_message, radio_freq, radio_freq_name, radio_freq_color, list/spans, list/message_mods = list(), message_range)
	. = ..()
	var/dist = get_dist(speaker, src) - message_range
	if(dist > 0 && dist <= EAVESDROP_EXTRA_RANGE)
		raw_message = stars(raw_message)
	if(message_range != INFINITY && dist > EAVESDROP_EXTRA_RANGE)
		return FALSE
	if(!owner)
		return FALSE
	return owner.Hear(speaker, message_language, raw_message, radio_freq, radio_freq_name, radio_freq_color, spans, message_mods, message_range = INFINITY)

///Stops dullahans from gibbing when regenerating limbs
/obj/item/dullahan_relay/proc/unlist_head(datum/source, list/excluded_zones)
	SIGNAL_HANDLER
	excluded_zones |= BODY_ZONE_HEAD

///Retrieving the owner's head for better ahealing.
/obj/item/dullahan_relay/proc/retrieve_head(datum/source, full_heal_flags)
	SIGNAL_HANDLER
	if(!(full_heal_flags & HEAL_ADMIN))
		return

	var/obj/item/bodypart/head/head = loc
	var/turf/body_turf = get_turf(owner)
	if(head && istype(head) && body_turf && !(head in owner.get_all_contents()))
		head.forceMove(body_turf)

// HowlingVoid dullahan mechanics integration.
/datum/movespeed_modifier/dullahan_headless_disorientation
	multiplicative_slowdown = 0.18

/datum/movespeed_modifier/dullahan_headless_severe_disorientation
	multiplicative_slowdown = 0.30

/mob/living/carbon/human
	/// Runtime toggle to avoid repeatedly multiplying/dividing focus modifiers.
	var/tmp/dullahan_focus_active = FALSE
	/// Cooldown for head threat warnings.
	var/tmp/dullahan_next_threat_ping = 0

/datum/species/dullahan
	/// Control resistance multiplier while being a Dullahan.
	var/dullahan_stun_mod = 0.9
	/// How far the body can be from the head before penalties start.
	var/dullahan_safe_head_distance = 1
	/// Distance where disorientation becomes severe.
	var/dullahan_severe_head_distance = 5
	/// Healing effectiveness while the head is separated from the body.
	var/dullahan_separated_heal_multiplier = 0.8
	/// Extra incoming damage on head hits.
	var/dullahan_head_hit_vulnerability = 1.12
	/// Extra incoming damage on head hits while separated.
	var/dullahan_separated_head_hit_vulnerability = 1.22
	/// Threat sensing range around detached head.
	var/dullahan_threat_sense_range = 6
	/// Cooldown in deciseconds between threat warnings.
	var/dullahan_threat_ping_cooldown = 30

/datum/species/dullahan/on_species_gain(mob/living/carbon/human/human, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if(!human)
		return

	human.dullahan_focus_active = FALSE
	human.dullahan_next_threat_ping = 0
	human.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_disorientation)
	human.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_severe_disorientation)

	RegisterSignal(human, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(on_dullahan_damage_modifiers))
	RegisterSignals(human, COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES, PROC_REF(on_dullahan_adjust_healing))

/datum/species/dullahan/on_species_loss(mob/living/carbon/human/human)
	if(human)
		set_focus_state(human, FALSE)
		human.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_disorientation)
		human.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_severe_disorientation)
		UnregisterSignal(human, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)
		UnregisterSignal(human, COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES)
	. = ..()

/datum/species/dullahan/spec_life(mob/living/carbon/human/source, seconds_per_tick)
	. = ..()
	if(!source || QDELETED(source))
		return

	var/head_distance = get_head_distance(source)
	var/head_is_close = (head_distance <= dullahan_safe_head_distance)
	set_focus_state(source, head_is_close)

	if(QDELETED(my_head))
		set_focus_state(source, FALSE)
		source.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_disorientation)
		source.add_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_severe_disorientation)
		source.adjust_confusion_up_to(0.8 SECONDS * seconds_per_tick, 6 SECONDS)
		source.adjust_eye_blur_up_to(0.8 SECONDS * seconds_per_tick, 8 SECONDS)
		return

	if(head_distance > dullahan_severe_head_distance)
		source.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_disorientation)
		source.add_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_severe_disorientation)
		source.adjust_confusion_up_to(0.7 SECONDS * seconds_per_tick, 5 SECONDS)
		source.adjust_eye_blur_up_to(0.7 SECONDS * seconds_per_tick, 6 SECONDS)
		return

	if(head_distance > dullahan_safe_head_distance)
		source.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_severe_disorientation)
		source.add_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_disorientation)
		source.adjust_confusion_up_to(0.5 SECONDS * seconds_per_tick, 4 SECONDS)
		source.adjust_eye_blur_up_to(0.5 SECONDS * seconds_per_tick, 5 SECONDS)
		return

	source.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_disorientation)
	source.remove_movespeed_modifier(/datum/movespeed_modifier/dullahan_headless_severe_disorientation)
	scan_head_for_threats(source)

/datum/species/dullahan/proc/get_head_distance(mob/living/carbon/human/source)
	if(!source || QDELETED(source) || QDELETED(my_head))
		return INFINITY

	var/turf/body_turf = get_turf(source)
	var/turf/head_turf = get_turf(my_head)
	if(!body_turf || !head_turf)
		return INFINITY

	return get_dist(body_turf, head_turf)

/datum/species/dullahan/proc/set_focus_state(mob/living/carbon/human/source, enabled)
	if(!source)
		return
	if(enabled == source.dullahan_focus_active)
		return

	if(enabled)
		source.physiology.stun_mod *= dullahan_stun_mod
		source.physiology.knockdown_mod *= dullahan_stun_mod
	else
		source.physiology.stun_mod /= dullahan_stun_mod
		source.physiology.knockdown_mod /= dullahan_stun_mod

	source.dullahan_focus_active = enabled

/datum/species/dullahan/proc/is_head_zone_hit(def_zone)
	if(isbodypart(def_zone))
		var/obj/item/bodypart/part = def_zone
		return part.body_zone == BODY_ZONE_HEAD

	return def_zone == BODY_ZONE_HEAD

/datum/species/dullahan/proc/on_dullahan_damage_modifiers(mob/living/carbon/human/source, list/damage_mods, damage, damagetype, def_zone, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER
	if(!is_head_zone_hit(def_zone))
		return

	var/head_distance = get_head_distance(source)
	if(head_distance > dullahan_safe_head_distance)
		damage_mods += dullahan_separated_head_hit_vulnerability
		return

	damage_mods += dullahan_head_hit_vulnerability

/datum/species/dullahan/proc/on_dullahan_adjust_healing(mob/living/carbon/human/source, type, amount, forced)
	SIGNAL_HANDLER
	if(forced || amount >= 0)
		return
	if(get_head_distance(source) <= dullahan_safe_head_distance)
		return

	var/new_amount = amount * dullahan_separated_heal_multiplier
	switch(type)
		if(BRUTE)
			source.adjust_brute_loss(new_amount, forced = TRUE)
		if(BURN)
			source.adjust_fire_loss(new_amount, forced = TRUE)
		if(OXY)
			source.adjust_oxy_loss(new_amount, forced = TRUE)
		if(TOX)
			source.adjust_tox_loss(new_amount, forced = TRUE)
		else
			return

	return COMPONENT_IGNORE_CHANGE

/datum/species/dullahan/proc/scan_head_for_threats(mob/living/carbon/human/source)
	if(!source || QDELETED(source) || QDELETED(my_head))
		return
	if(!prevent_perspective_change) // Threat sensing only when looking through the detached head.
		return
	if(source.dullahan_next_threat_ping > world.time)
		return

	var/turf/head_turf = get_turf(my_head)
	if(!head_turf)
		return

	for(var/mob/living/potential in orange(dullahan_threat_sense_range, head_turf))
		if(potential == source || potential.stat >= UNCONSCIOUS)
			continue
		if(!potential.combat_mode)
			continue

		var/direction = get_dir(head_turf, get_turf(potential))
		to_chat(source, span_warning("Your detached sight catches hostile movement to the [dir2text(direction)]!"))
		source.dullahan_next_threat_ping = world.time + dullahan_threat_ping_cooldown
		break

/datum/species/dullahan/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_EYE,
			SPECIES_PERK_NAME = "Detached Threat Sense",
			SPECIES_PERK_DESC = "While seeing through the detached head, Dullahans can sense nearby hostile movement around it.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_SHIELD,
			SPECIES_PERK_NAME = "Focused Undead",
			SPECIES_PERK_DESC = "Dullahans are harder to stun or knock down while body and head stay close.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "horse-head",
			SPECIES_PERK_NAME = "Headless and Horseless",
			SPECIES_PERK_DESC = "If body and head are too far apart, Dullahans become disoriented, slower, and less precise.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_BRIEFCASE_MEDICAL,
			SPECIES_PERK_NAME = "Split Recovery",
			SPECIES_PERK_DESC = "Dullahan healing is weaker while body and head are separated.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_BULLSEYE,
			SPECIES_PERK_NAME = "Exposed Head",
			SPECIES_PERK_DESC = "Head hits deal extra damage to Dullahans, especially while separated.",
		),
	)

	return to_add

