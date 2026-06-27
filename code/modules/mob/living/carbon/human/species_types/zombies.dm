/datum/species/zombie
	// 1spooky
	name = "High-Functioning Zombie"
	id = SPECIES_ZOMBIE
	sexes = FALSE
	meat = /obj/item/food/meat/slab/human/mutant/zombie
	mutanttongue = /obj/item/organ/tongue/zombie
	inherent_traits = list(
		// SHARED WITH ALL ZOMBIES
		TRAIT_BLOODY_MESS,
		TRAIT_EASILY_WOUNDED,
		TRAIT_EASYDISMEMBER,
		TRAIT_FAKEDEATH,
		TRAIT_LIMBATTACHMENT,
		TRAIT_LIVERLESS_METABOLISM,
		TRAIT_NOBREATH,
		TRAIT_NODEATH,
		TRAIT_NOCRITDAMAGE,
		TRAIT_NOHUNGER,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_ZOMBIFY,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TOXIMMUNE,
		// HIGH FUNCTIONING UNIQUE
		TRAIT_NOBLOOD,
		TRAIT_SUCCUMB_OVERRIDE,
	)
	mutantstomach = null
	mutantheart = null
	mutantliver = null
	mutantlungs = null
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN
	bodytemp_normal = T0C // They have no natural body heat, the environment regulates body temp
	bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_EXIST // Take damage at fire temp
	bodytemp_cold_damage_limit = MINIMUM_TEMPERATURE_TO_MOVE // take damage below minimum movement temp

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/zombie,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/zombie,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/zombie,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/zombie,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/zombie,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/zombie
	)

	/// Spooky growls we sometimes play while alive
	var/static/list/spooks = list(
		'sound/effects/hallucinations/growl1.ogg',
		'sound/effects/hallucinations/growl2.ogg',
		'sound/effects/hallucinations/growl3.ogg',
		'sound/effects/hallucinations/veryfar_noise.ogg',
		'sound/effects/hallucinations/wail.ogg',
	)

/// Zombies do not stabilize body temperature they are the walking dead and are cold blooded
/datum/species/zombie/body_temperature_core(mob/living/carbon/human/humi, seconds_per_tick)
	return

/datum/species/zombie/check_roundstart_eligible()
	if(check_holidays(HALLOWEEN))
		return TRUE
	return ..()

/datum/species/zombie/get_physical_attributes()
	return "Zombies are undead, and thus completely immune to any environmental hazard, or any physical threat besides blunt force trauma and burns. \
		Their limbs are easy to pop off their joints, but they can somehow just slot them back in."

/datum/species/zombie/get_species_description()
	return "A rotting zombie! They descend upon Space Station Thirteen Every year to spook the crew! \"Sincerely, the Zombies!\""

/datum/species/zombie/get_species_lore()
	return list("Zombies have long lasting beef with Botanists. Their last incident involving a lawn with defensive plants has left them very unhinged.")

// Override for the default temperature perks, so we can establish that they don't care about temperature very much
/datum/species/zombie/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "thermometer-half",
		SPECIES_PERK_NAME = "No Body Temperature",
		SPECIES_PERK_DESC = "Having long since departed, Zombies do not have anything \
			regulating their body temperature anymore. This means that \
			the environment decides their body temperature - which they don't mind at \
			all, until it gets a bit too hot.",
	))

	return to_add

/datum/species/zombie/infectious
	name = "Infectious Zombie"
	id = SPECIES_ZOMBIE_INFECTIOUS
	examine_limb_id = SPECIES_ZOMBIE
	damage_modifier = 20 // 120 damage to KO a zombie, which kills it
	mutanteyes = /obj/item/organ/eyes/zombie
	mutantbrain = /obj/item/organ/brain/zombie
	mutanttongue = /obj/item/organ/tongue/zombie
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

	inherent_traits = list(
		// SHARED WITH ALL ZOMBIES
		TRAIT_BLOODY_MESS,
		TRAIT_EASILY_WOUNDED,
		TRAIT_EASYDISMEMBER,
		TRAIT_FAKEDEATH,
		TRAIT_LIMBATTACHMENT,
		TRAIT_LIVERLESS_METABOLISM,
		TRAIT_NOBREATH,
		TRAIT_NOCRITDAMAGE,
		TRAIT_NODEATH,
		TRAIT_NOHUNGER,
		TRAIT_NO_DNA_COPY,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TOXIMMUNE,
		// INFECTIOUS UNIQUE
		TRAIT_STABLEHEART, // Replacement for noblood. Infectious zombies can bleed but don't need their heart.
		TRAIT_STABLELIVER, // Not necessary but for consistency with above
	)

	// Infectious zombies have slow legs
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/zombie,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/zombie,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/zombie,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/zombie,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/zombie/infectious,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/zombie/infectious,
	)

/datum/species/zombie/infectious/on_species_gain(mob/living/carbon/human/new_zombie, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	new_zombie.set_combat_mode(TRUE)
	// Needs to be added after combat mode is set
	ADD_TRAIT(new_zombie, TRAIT_COMBAT_MODE_LOCK, SPECIES_TRAIT)

	// Deal with the source of this zombie corruption
	// Infection organ needs to be handled separately from mutant_organs
	// because it persists through species transitions
	var/obj/item/organ/zombie_infection/infection = new_zombie.get_organ_slot(ORGAN_SLOT_ZOMBIE)
	if(isnull(infection))
		infection = new()
		infection.Insert(new_zombie)

	new_zombie.AddComponent( \
		/datum/component/mutant_hands, \
		mutant_hand_path = /obj/item/mutant_hand/zombie, \
	)
	new_zombie.AddComponent( \
		/datum/component/regenerator, \
		regeneration_delay = 6 SECONDS, \
		brute_per_second = 0.5, \
		burn_per_second = 0.5, \
		tox_per_second = 0.5, \
		oxy_per_second = 0.25, \
		heals_wounds = TRUE, \
	)

/datum/species/zombie/infectious/on_species_loss(mob/living/carbon/human/was_zombie, datum/species/new_species, pref_load)
	. = ..()
	REMOVE_TRAIT(was_zombie, TRAIT_COMBAT_MODE_LOCK, SPECIES_TRAIT)
	qdel(was_zombie.GetComponent(/datum/component/mutant_hands))
	qdel(was_zombie.GetComponent(/datum/component/regenerator))

/datum/species/zombie/infectious/check_roundstart_eligible()
	return FALSE

/datum/species/zombie/infectious/spec_stun(mob/living/carbon/human/H,amount)
	return min(2 SECONDS, amount)

/datum/species/zombie/infectious/spec_life(mob/living/carbon/carbon_mob, seconds_per_tick)
	. = ..()
	if(!HAS_TRAIT(carbon_mob, TRAIT_CRITICAL_CONDITION) && SPT_PROB(2, seconds_per_tick))
		playsound(carbon_mob, pick(spooks), 50, TRUE, 10)

/obj/item/mutant_hand/zombie
	name = "zombie claw"
	desc = "A zombie's claw is its primary tool, capable of infecting \
		humans, butchering all other living things to \
		sustain the zombie, smashing open airlock doors and opening \
		child-safe caps on bottles."
	hitsound = 'sound/effects/hallucinations/growl1.ogg'
	force = 21
	wound_bonus = -30
	exposed_wound_bonus = 15
	sharpness = SHARP_EDGED

/obj/item/mutant_hand/zombie/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	if(QDELETED(target))
		return
	if(ishuman(target))
		try_to_zombie_infect(target, user, user.zone_selected)
	else if(isliving(target))
		check_feast(target, user)

/obj/item/mutant_hand/zombie/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is ripping [user.p_their()] brains out! It looks like [user.p_theyre()] trying to commit suicide!"))
	var/obj/item/bodypart/head = user.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.dismember()
	return BRUTELOSS

/obj/item/mutant_hand/zombie/proc/check_feast(mob/living/target, mob/living/user)
	if(target.stat != DEAD)
		return
	var/hp_gained = target.maxHealth
	target.investigate_log("has been devoured by a zombie.", INVESTIGATE_DEATHS)
	target.gib(DROP_ALL_REMAINS)
	var/need_mob_update
	need_mob_update = user.adjust_brute_loss(-hp_gained, updating_health = FALSE)
	need_mob_update += user.adjust_tox_loss(-hp_gained, updating_health = FALSE)
	need_mob_update += user.adjust_fire_loss(-hp_gained, updating_health = FALSE)
	need_mob_update += user.adjust_organ_loss(ORGAN_SLOT_BRAIN, -hp_gained)
	user.set_nutrition(min(user.nutrition + hp_gained, NUTRITION_LEVEL_FULL))
	if(need_mob_update)
		user.updatehealth()

/proc/try_to_zombie_infect(mob/living/carbon/human/target, mob/living/user, def_zone = BODY_ZONE_CHEST)
	CHECK_DNA_AND_SPECIES(target)

	if(!target.get_bodypart(BODY_ZONE_HEAD))
		return
	if(HAS_TRAIT(target, TRAIT_NO_ZOMBIFY))
		return
	if(HAS_TRAIT(target, TRAIT_VIRUS_RESISTANCE) && !HAS_TRAIT(target, TRAIT_IMMUNODEFICIENCY) && prob(75))
		return

	var/obj/item/bodypart/actual_limb = target.get_bodypart(def_zone)
	if(!actual_limb)
		return

	var/limb_damage = actual_limb.get_damage()
	var/limb_armor = max(0, target.getarmor(actual_limb, BIO) - 25)
	for(var/obj/item/clothing/iter_clothing in target.get_clothing_on_part(actual_limb))
		if(iter_clothing.clothing_flags & THICKMATERIAL)
			limb_armor += 25

	if(limb_armor > limb_damage)
		return

	var/obj/item/organ/zombie_infection/infection = target.get_organ_slot(ORGAN_SLOT_ZOMBIE)
	if(!infection)
		infection = new()
		infection.Insert(target)
		to_chat(user, span_alien("You see [target] twitch for a moment as [target.p_their()] head is covered in \a [infection] - [target.p_Theyve()] been infected."))

/obj/item/organ/zombie_infection
	name = "festering ooze"
	desc = "A black web of pus and viscera."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_ZOMBIE
	icon_state = "blacktumor"
	var/causes_damage = TRUE
	var/datum/species/old_species = /datum/species/human
	var/living_transformation_time = 3 SECONDS
	var/converts_living = FALSE
	var/revive_time_min = 45 SECONDS
	var/revive_time_max = 70 SECONDS
	var/timer_id

/obj/item/organ/zombie_infection/Initialize(mapload)
	. = ..()
	if(iscarbon(loc))
		Insert(loc)
	GLOB.zombie_infection_list += src

/obj/item/organ/zombie_infection/Destroy()
	GLOB.zombie_infection_list -= src
	. = ..()

/obj/item/organ/zombie_infection/feel_for_damage(self_aware)
	return ""

/obj/item/organ/zombie_infection/on_mob_insert(mob/living/carbon/new_owner, special = FALSE, movement_flags)
	. = ..()
	RegisterSignal(new_owner, COMSIG_LIVING_DEATH, PROC_REF(organ_owner_died))
	START_PROCESSING(SSobj, src)

/obj/item/organ/zombie_infection/on_mob_remove(mob/living/carbon/new_owner, special = FALSE, movement_flags)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	if(iszombie(new_owner) && old_species && !special)
		spawn(0)
			new_owner.set_species(old_species)
	if(timer_id)
		deltimer(timer_id)
	UnregisterSignal(new_owner, COMSIG_LIVING_DEATH)

/obj/item/organ/zombie_infection/proc/organ_owner_died(mob/living/carbon/source, gibbed)
	SIGNAL_HANDLER
	if(iszombie(source))
		qdel(src)

/obj/item/organ/zombie_infection/on_find(mob/living/finder)
	to_chat(finder, span_warning("Inside the head is a disgusting black \
		web of pus and viscera, bound tightly around the brain like some \
		biological harness."))

/obj/item/organ/zombie_infection/process(seconds_per_tick)
	if(!owner)
		return
	if(!(src in owner.organs))
		Remove(owner)
	if(owner.mob_biotypes & MOB_MINERAL)
		return
	if(causes_damage && !iszombie(owner) && owner.stat != DEAD)
		owner.adjust_tox_loss(0.5 * seconds_per_tick)
		if(SPT_PROB(5, seconds_per_tick))
			to_chat(owner, span_danger("You feel sick..."))
	if(timer_id || HAS_TRAIT(owner, TRAIT_SUICIDED) || !owner.get_organ_by_type(/obj/item/organ/brain))
		return
	if(owner.stat != DEAD && !converts_living)
		return
	if(!iszombie(owner))
		to_chat(owner, span_cult_large("You can feel your heart stopping, but something isn't right... \
		life has not abandoned your broken form. You can only feel a deep and immutable hunger that \
		not even death can stop, you will rise again!"))
	var/revive_time = rand(revive_time_min, revive_time_max)
	timer_id = addtimer(CALLBACK(src, PROC_REF(zombify), owner), revive_time, TIMER_STOPPABLE)

/obj/item/organ/zombie_infection/proc/zombify(mob/living/carbon/target)
	timer_id = null
	if(!converts_living && owner.stat != DEAD)
		return

	if(!iszombie(owner))
		old_species = owner.dna.species.type
		target.set_species(/datum/species/zombie/infectious)

	var/stand_up = (target.stat == DEAD) || (target.stat == UNCONSCIOUS)
	if(!target.heal_and_revive(0, span_danger("[target] suddenly convulses, as [target.p_they()][stand_up ? " stagger to [target.p_their()] feet and" : ""] gain a ravenous hunger in [target.p_their()] eyes!")))
		return

	to_chat(target, span_alien("You HUNGER!"))
	to_chat(target, span_alertalien("You are now a zombie! Do not seek to be cured, do not help any non-zombies in any way, do not harm your zombie brethren and spread the disease by killing others. You are a creature of hunger and violence."))
	playsound(target, 'sound/effects/hallucinations/far_noise.ogg', 50, TRUE)
	target.do_jitter_animation(living_transformation_time)
	target.Stun(living_transformation_time)

/obj/item/organ/zombie_infection/nodamage
	causes_damage = FALSE

// Your skin falls off
/datum/species/human/krokodil_addict
	name = "\improper Krokodil Human"
	id = SPECIES_ZOMBIE_KROKODIL
	examine_limb_id = SPECIES_HUMAN
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/zombie,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/zombie,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/zombie,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/zombie,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/zombie,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/zombie
	)
