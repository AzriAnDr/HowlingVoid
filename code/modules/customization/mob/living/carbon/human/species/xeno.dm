/datum/species/xeno
	// A cloning mistake, crossing human and xenomorph DNA
	name = "Xenomorph Hybrid"
	id = SPECIES_XENO
	family_heirlooms = list(
		/obj/item/toy/plush/rouny,
		/obj/item/clothing/mask/facehugger/toy
		)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_MUTANT_COLORS,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutantbrain = /obj/item/organ/brain/xeno_hybrid
	mutanttongue = /obj/item/organ/tongue/xeno_hybrid
	mutantliver = /obj/item/organ/liver/xeno_hybrid
	mutantstomach = /obj/item/organ/stomach/xeno_hybrid
	mutant_organs = list(
		/obj/item/organ/alien/plasmavessel/roundstart,
		/obj/item/organ/alien/resinspinner/roundstart,
		/obj/item/organ/alien/hivenode,
		)
	exotic_bloodtype = BLOOD_TYPE_XENO
	heatmod = 2.5

	payday_modifier = 1.0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/mutant/xenohybrid,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/mutant/xenohybrid,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/mutant/xenohybrid,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/mutant/xenohybrid,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade/xenohybrid,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade/xenohybrid,
	)

	meat = /obj/item/food/meat/slab/xeno
	skinned_type = /obj/item/stack/sheet/animalhide/xeno
	death_sound = 'sound/mobs/non-humanoids/hiss/hiss6.ogg'
	gib_anim = "gibbed-a"

/datum/species/xeno/get_default_mutant_bodyparts()
	return list(
		FEATURE_EARS = MUTPART_BLUEPRINT(SPRITE_ACCESSORY_NONE, is_randomizable = FALSE),
		FEATURE_TAIL = MUTPART_BLUEPRINT("Xenomorph Tail", is_randomizable = FALSE),
		FEATURE_XENODORSAL = MUTPART_BLUEPRINT("Standard", is_randomizable = TRUE),
		FEATURE_XENOHEAD = MUTPART_BLUEPRINT("Standard", is_randomizable = TRUE),
		FEATURE_LEGS = MUTPART_BLUEPRINT(DIGITIGRADE_LEGS, is_randomizable = FALSE, is_feature = TRUE),
		FEATURE_TAUR = MUTPART_BLUEPRINT(SPRITE_ACCESSORY_NONE, is_randomizable = FALSE),
	)

/datum/species/xeno/get_species_description()
	return placeholder_description

/datum/species/xeno/get_species_lore()
	return list(placeholder_lore)

/datum/species/xeno/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "biohazard",
		SPECIES_PERK_NAME = "Xenomorphic Biology",
		SPECIES_PERK_DESC = "Xeno-hybrids inherit organs from their primal ascendants."
	))

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "fire",
		SPECIES_PERK_NAME = "High Temperature Weakness",
		SPECIES_PERK_DESC = "A partial silicone structure and acid blood make the xeno-hybrid species extremely weak to heat."
	))

	return to_add

/datum/species/xeno/prepare_human_for_preview(mob/living/carbon/human/xeno)
	var/xeno_color = "#525288"
	xeno.dna.features[FEATURE_MUTANT_COLOR] = xeno_color
	xeno.set_eye_color( "#30304F")
	xeno.dna.mutant_bodyparts[FEATURE_TAIL] = build_mutant_part("Xenomorph Tail", list(xeno_color, xeno_color, xeno_color))
	xeno.dna.mutant_bodyparts[FEATURE_XENODORSAL] = build_mutant_part("Standard", list(xeno_color))
	xeno.dna.mutant_bodyparts[FEATURE_XENOHEAD] = build_mutant_part("Standard", list(xeno_color, xeno_color, xeno_color))
	regenerate_organs(xeno, src, visual_only = TRUE)
	xeno.update_body(TRUE)

///Xenomorph organs modified to suit roundstart styling
#define BUILD_DURATION 0.5 SECONDS

//Plasma vessel
/obj/item/organ/alien/plasmavessel/roundstart
	stored_plasma = 55
	max_plasma = 55
	plasma_rate = 2
	heal_rate = 1.5
	actions_types = list(
		/datum/action/cooldown/alien/make_structure/plant_weeds/roundstart,
		/datum/action/cooldown/alien/transfer,
	)

/datum/action/cooldown/alien/make_structure/plant_weeds
	var/build_duration = 0 SECONDS //regular aliens can build instantly

/datum/action/cooldown/alien/make_structure/plant_weeds/roundstart
	build_duration = BUILD_DURATION //hybrids are a bit slower

/datum/action/cooldown/alien/make_structure/plant_weeds/Activate(atom/target)
	if(build_duration && !do_after(owner, build_duration))
		owner.balloon_alert(owner, "interrupted!")
		return
	return ..()

//Resin spinner
/obj/item/organ/alien/resinspinner/roundstart
	actions_types = list(/datum/action/cooldown/alien/make_structure/resin/roundstart)

/datum/action/cooldown/alien/make_structure/resin
	var/build_duration = 0 SECONDS

/datum/action/cooldown/alien/make_structure/resin/roundstart
	build_duration = BUILD_DURATION
	//Non-modularly checked in `code\modules\mob\living\carbon\alien\adult\alien_powers.dm`

//Organ resprites
/obj/item/organ/brain/xeno_hybrid
	icon_state = "brain-x" //rebranding

/obj/item/organ/brain/xeno_hybrid/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/bubble_icon_override, "alien", BUBBLE_ICON_PRIORITY_ORGAN)

/obj/item/organ/stomach/xeno_hybrid
	icon_state = "stomach-x"

/obj/item/organ/liver/xeno_hybrid
	icon_state = "liver-x"

//Liver modification (xenohybrids can process plasma!)
/obj/item/organ/liver/xeno_hybrid/handle_chemical(mob/living/carbon/owner, datum/reagent/toxin/chem, seconds_per_tick)
	. = ..()
	if(. & COMSIG_MOB_STOP_REAGENT_TICK)
		return
	if(chem.type == /datum/reagent/toxin/plasma)
		chem.toxpwr = 0

#undef BUILD_DURATION

///Xenohybrid gib and dust tweaks
/mob/living/carbon/human/spawn_gibs(drop_bitflags=NONE)
	if(!isxenohybrid(src))
		return ..()
	if(drop_bitflags & DROP_BODYPARTS)
		new /obj/effect/gibspawner/xeno(drop_location(), src, get_static_viruses())
	else
		new /obj/effect/gibspawner/xeno/bodypartless(drop_location(), src, get_static_viruses())

/mob/living/carbon/human/spawn_dust(just_ash = FALSE)
	if(!isxenohybrid(src))
		return ..()
	if(just_ash)
		new /obj/effect/decal/cleanable/ash(loc)
	else
		new /obj/effect/decal/remains/xeno(loc)

// HowlingVoid xenohybrid mechanics integration.
/datum/species/xeno
	species_language_holder = /datum/language_holder/xenohybrid
	// Strip alien organ toolkit: no plasma vessel, no hive node, no resin spinner, no acid gland.
	mutant_organs = list()
	// Disable plasma-safe liver behavior from base xeno-hybrid species.
	mutantliver = /obj/item/organ/liver
	/// Matches standard antagonist xenomorph plasma vessel healing on resin.
	var/resin_heal_rate = /obj/item/organ/alien/plasmavessel::heal_rate
	/// Species-granted pounce action tracked for cleanup.
	var/tmp/list/species_pounce_action = list()
	/// Species-granted free resin action tracked for cleanup.
	var/tmp/list/species_resin_action = list()
	/// Species-granted speech synthesizer implant tracked for cleanup.
	var/tmp/list/species_speech_implant = list()

/datum/species/xeno/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	if(!istype(H))
		return

	ADD_TRAIT(H, TRAIT_VENTCRAWLER_ALWAYS, REF(src))
	ADD_TRAIT(H, TRAIT_XENO_IMMUNE, REF(src))
	RegisterSignal(H, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_xenohybrid_item_attack))
	RegisterSignal(H, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_xenohybrid_attacked))

	var/datum/action/cooldown/xenohybrid_pounce/old_pounce = species_pounce_action[H]
	if(old_pounce)
		old_pounce.Remove(H)
		qdel(old_pounce)
	species_pounce_action[H] = null

	var/datum/action/cooldown/xenohybrid_pounce/new_pounce = new()
	new_pounce.Grant(H)
	species_pounce_action[H] = new_pounce

	var/datum/action/cooldown/xenohybrid_resin/old_resin = species_resin_action[H]
	if(old_resin)
		old_resin.Remove(H)
		qdel(old_resin)
	species_resin_action[H] = null

	var/datum/action/cooldown/xenohybrid_resin/new_resin = new()
	new_resin.Grant(H)
	species_resin_action[H] = new_resin

	for(var/obj/item/implant/gas_sol_speaker/existing_synth as anything in H.implants)
		existing_synth.apply_speech_synth(H)

	var/obj/item/implant/gas_sol_speaker/old_synth = species_speech_implant[H]
	if(old_synth)
		qdel(old_synth)
	species_speech_implant[H] = null

	var/obj/item/implant/gas_sol_speaker/new_synth = new()
	if(new_synth.implant(H, silent = TRUE, force = TRUE))
		species_speech_implant[H] = new_synth
	else
		qdel(new_synth)

	// Speaks Xenocommon by default, while still understanding Sol Common.
	H.get_language_holder()?.selected_language = /datum/language/xenocommon

/datum/species/xeno/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	if(istype(H))
		for(var/obj/item/implant/gas_sol_speaker/speech_synth as anything in H.implants)
			speech_synth.remove_speech_synth(H)

	. = ..()
	if(!istype(H))
		return

	REMOVE_TRAIT(H, TRAIT_VENTCRAWLER_ALWAYS, REF(src))
	REMOVE_TRAIT(H, TRAIT_XENO_IMMUNE, REF(src))
	UnregisterSignal(H, COMSIG_MOB_ITEM_ATTACK)
	UnregisterSignal(H, COMSIG_ATOM_WAS_ATTACKED)

	var/datum/action/cooldown/xenohybrid_pounce/pounce = species_pounce_action[H]
	if(pounce)
		pounce.Remove(H)
		qdel(pounce)
	species_pounce_action[H] = null

	var/datum/action/cooldown/xenohybrid_resin/resin = species_resin_action[H]
	if(resin)
		resin.Remove(H)
		qdel(resin)
	species_resin_action[H] = null

	var/obj/item/implant/gas_sol_speaker/synth = species_speech_implant[H]
	if(synth)
		qdel(synth)
	species_speech_implant[H] = null

/datum/species/xeno/spec_life(mob/living/carbon/human/H, seconds_per_tick)
	. = ..()
	if(!istype(H))
		return

	if(locate(/obj/structure/alien/weeds) in H.loc)
		H.add_mood_event("area_beauty", /datum/mood_event/xenohybrid_resin)
		var/need_mob_update = FALSE
		need_mob_update += H.adjust_brute_loss(-resin_heal_rate * seconds_per_tick, updating_health = FALSE)
		need_mob_update += H.adjust_fire_loss(-resin_heal_rate * seconds_per_tick, updating_health = FALSE)
		need_mob_update += H.adjust_oxy_loss(-resin_heal_rate * seconds_per_tick, updating_health = FALSE)
		if(need_mob_update)
			H.updatehealth()

/datum/species/xeno/proc/xenohybrid_heat_burst(mob/living/carbon/human/victim)
	if(!istype(victim))
		return

	victim.visible_message(
		span_danger("[victim]'s overheated tissues rupture in a spray of acidic gore!"),
		span_userdanger("Your overheated tissues rupture in a spray of acidic gore!"),
	)
	if(victim.stat < UNCONSCIOUS)
		INVOKE_ASYNC(victim, TYPE_PROC_REF(/mob, emote), "scream")
	victim.spawn_gibs()
	victim.gib_animation()
	victim.drop_all_held_items()
	victim.set_fire_stacks(0)
	victim.extinguish_mob()
	victim.bodytemperature = BODYTEMP_NORMAL
	victim.coretemperature = BODYTEMP_NORMAL

/datum/species/xeno/proc/should_heat_burst(mob/living/carbon/human/victim)
	if(!istype(victim))
		return FALSE
	return victim.on_fire || victim.bodytemperature > victim.get_body_temp_heat_damage_limit() || victim.coretemperature > victim.get_body_temp_heat_damage_limit() || victim.get_fire_loss() >= victim.maxHealth

/mob/living/carbon/human/death(gibbed)
	if(!gibbed && isxenohybrid(src))
		var/datum/species/xeno/xeno_species = dna?.species
		if(istype(xeno_species) && xeno_species.should_heat_burst(src))
			xeno_species.xenohybrid_heat_burst(src)
	return ..()

/datum/species/xeno/proc/on_xenohybrid_item_attack(mob/living/carbon/human/source, mob/living/target, mob/living/user, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER

	if(!istype(source) || source != user)
		return
	if(!istype(target))
		return

	var/turf/current_turf = get_turf(source)
	if(!istype(current_turf))
		return

	// Ambush Sense: stronger melee in darkness.
	if(current_turf.get_lumcount() <= 0.2)
		MODIFY_ATTACK_FORCE_MULTIPLIER(attack_modifiers, 1.2)

/datum/species/xeno/proc/on_xenohybrid_attacked(mob/living/carbon/human/source, atom/attacker, attack_flags)
	SIGNAL_HANDLER

	if(!istype(source))
		return
	if(!(attack_flags & ATTACKER_DAMAGING_ATTACK))
		return
	if(!isliving(attacker))
		return

	var/mob/living/living_attacker = attacker
	if(living_attacker == source)
		return
	if(get_dist(source, living_attacker) > 1)
		return
	if(HAS_TRAIT(living_attacker, TRAIT_XENO_IMMUNE))
		return
	if(!prob(40))
		return

	living_attacker.visible_message(
		span_warning("Acidic blood from [source] splashes onto [living_attacker]!"),
		span_userdanger("Acidic blood splashes onto you!"),
	)
	living_attacker.acid_act(45, 25)

/datum/species/xeno/get_species_description()
	return "Xenomorph Hybrids are human-xeno crossbreeds with predatory instincts, vent-crawling mobility, and severe heat vulnerability."

/datum/species/xeno/get_species_lore()
	return list(
		"Xeno-hybrids are the product of unstable bioengineering and cloning accidents, combining human cognition with inherited xenomorph predatory traits.",
		"They retain alien movement instincts and close-quarters burst aggression, but do not maintain full hive organ infrastructure.",
		"Despite their utility and resilience in some niches, their partial silicon-acid physiology performs poorly under high heat and open flames.",
	)

/datum/species/xeno/create_pref_unique_perks()
	var/list/perks = list()
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "biohazard",
		SPECIES_PERK_NAME = "Xenomorphic Biology",
		SPECIES_PERK_DESC = "Xeno-hybrids inherit hardened xenomorphic traits and immunity to implantation by facehuggers.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "person-booth",
		SPECIES_PERK_NAME = "Vent Stalker",
		SPECIES_PERK_DESC = "Can crawl through vents like full xenomorph strains.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "burst",
		SPECIES_PERK_NAME = "Acid Blood",
		SPECIES_PERK_DESC = "Damaging them in melee can splash acidic blood back at the attacker.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "person-falling-burst",
		SPECIES_PERK_NAME = "Predatory Pounce",
		SPECIES_PERK_DESC = "Gain a pounce ability to rapidly close distance and knock targets down.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "biohazard",
		SPECIES_PERK_NAME = "Plant Weeds",
		SPECIES_PERK_DESC = "Can freely plant an alien weeds node that spreads xeno growth.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "moon",
		SPECIES_PERK_NAME = "Ambush Sense",
		SPECIES_PERK_DESC = "Melee attacks are stronger in deep darkness.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "comment-slash",
		SPECIES_PERK_NAME = "Alien Speech Pattern",
		SPECIES_PERK_DESC = "By default they speak Xenocommon, while still being able to speak and understand Sol Common.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "fire",
		SPECIES_PERK_NAME = "High Temperature Weakness",
		SPECIES_PERK_DESC = "Heat and fire are significantly more dangerous to xeno-hybrids.",
	))
	return perks

/datum/action/cooldown/xenohybrid_pounce
	name = "Predatory Pounce"
	desc = "Launch toward a nearby target and knock it down."
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "alien_leap"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	click_to_activate = TRUE
	cooldown_time = 10 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_IMMOBILE | AB_CHECK_INCAPACITATED
	var/max_pounce_dist = 7
	var/pounce_speed = 3

/datum/action/cooldown/xenohybrid_pounce/Activate(atom/target_atom)
	if(!isliving(target_atom))
		return FALSE

	var/mob/living/carbon/human/pouncer = owner
	if(!istype(pouncer))
		return FALSE

	var/mob/living/target = target_atom
	if(target == pouncer)
		return FALSE

	if(!isturf(pouncer.loc) || !isturf(target.loc))
		return FALSE
	if(get_dist(pouncer, target) > max_pounce_dist)
		pouncer.balloon_alert(pouncer, "too far!")
		return FALSE
	if(!pouncer.has_gravity() || !target.has_gravity())
		pouncer.balloon_alert(pouncer, "needs gravity!")
		return FALSE

	pouncer.visible_message(
		span_danger("[pouncer] lunges at [target]!"),
		span_userdanger("You pounce at [target]!"),
	)
	playsound(pouncer, 'sound/mobs/non-humanoids/hiss/hiss1.ogg', 60, TRUE)
	INVOKE_ASYNC(pouncer, TYPE_PROC_REF(/mob/living/carbon/human, emote), "roar")
	pouncer.throw_at(target, max_pounce_dist, pounce_speed, pouncer, spin = FALSE, force = MOVE_FORCE_EXTREMELY_WEAK, gentle = TRUE)
	var/landing_delay = clamp(get_dist(pouncer, target) * 0.25 SECONDS, 0.2 SECONDS, 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(resolve_pounce), pouncer, target), landing_delay)
	StartCooldown()
	return TRUE

/datum/action/cooldown/xenohybrid_pounce/proc/resolve_pounce(mob/living/carbon/human/pouncer, mob/living/target)
	if(QDELETED(src) || QDELETED(pouncer) || QDELETED(target))
		return
	if(get_dist(pouncer, target) > 1)
		return
	if(target.stat == DEAD)
		return

	target.visible_message(
		span_danger("[pouncer] crashes into [target], knocking [target.p_them()] down!"),
		span_userdanger("[pouncer] slams into you and knocks you down!"),
	)
	var/knockdown_time = 2.5 SECONDS
	var/stamina_damage = 22
	var/turf/target_turf = get_turf(target)
	if(istype(target_turf) && target_turf.get_lumcount() <= 0.2)
		knockdown_time = 3 SECONDS
		stamina_damage = 28
	target.Knockdown(knockdown_time)
	target.apply_damage(stamina_damage, STAMINA, attack_direction = get_dir(pouncer, target), attacking_item = pouncer)

/datum/action/cooldown/xenohybrid_resin
	name = "Plant Weeds"
	desc = "Plant a weeds node for free. It will spread alien growth."
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "alien_plant"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	click_to_activate = TRUE
	cooldown_time = 1 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_IMMOBILE | AB_CHECK_INCAPACITATED
	var/build_duration = 0.5 SECONDS

/datum/action/cooldown/xenohybrid_resin/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!isturf(owner?.loc) || isspaceturf(owner?.loc))
		return FALSE
	if(locate(/obj/structure/alien/weeds/node) in owner.loc)
		if(feedback)
			to_chat(owner, span_warning("There is already a weeds node here!"))
		return FALSE
	return TRUE

/datum/action/cooldown/xenohybrid_resin/proc/check_for_vents()
	var/obj/machinery/atmospherics/components/unary/atmos_thing = locate() in owner.loc
	if(!atmos_thing)
		return TRUE
	var/are_you_sure = tgui_alert(owner, "Planting weeds here may block access to [atmos_thing]. Continue?", "Blocking Atmospheric Component", list("Yes", "No"))
	if(are_you_sure != "Yes")
		return FALSE
	if(QDELETED(src) || QDELETED(owner) || !IsAvailable(feedback = TRUE))
		return FALSE
	return TRUE

/datum/action/cooldown/xenohybrid_resin/Activate(atom/target)
	if(!IsAvailable(feedback = TRUE))
		return FALSE
	if(!check_for_vents())
		return FALSE

	if(QDELETED(src) || QDELETED(owner))
		return FALSE

	owner.visible_message(
		span_alertalien("[owner] plants some alien weeds!"),
		span_noticealien("You plant some alien weeds."),
	)
	if(build_duration && !do_after(owner, build_duration))
		owner.balloon_alert(owner, "interrupted!")
		return FALSE

	new /obj/structure/alien/weeds/node(owner.loc)
	StartCooldown()
	return TRUE

/datum/language_holder/xenohybrid
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM), // Sol Common
		/datum/language/xenocommon = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM), // Sol Common
		/datum/language/xenocommon = list(LANGUAGE_ATOM),
	)
	selected_language = /datum/language/xenocommon
