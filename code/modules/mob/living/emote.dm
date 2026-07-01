
/* EMOTE DATUMS */
/datum/emote/living
	abstract_type = /datum/emote/living
	mob_type_allowed_typecache = /mob/living
	mob_type_blacklist_typecache = list(/mob/living/brain)

/datum/emote/living/proc/get_selected_scream_sound(mob/living/carbon/human/human_user)
	var/datum/scream_type/selected_scream = human_user.selected_scream
	if(isnull(selected_scream))
		return
	if(human_user.gender == FEMALE && LAZYLEN(selected_scream.female_screamsounds))
		return pick(selected_scream.female_screamsounds)
	if(LAZYLEN(selected_scream.male_screamsounds))
		return pick(selected_scream.male_screamsounds)
	if(LAZYLEN(selected_scream.female_screamsounds))
		return pick(selected_scream.female_screamsounds)

/datum/emote/living/proc/get_default_scream_sound(mob/living/carbon/human/human_user)
	if(human_user.gender == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/scream/femalescream_1.ogg',
			'sound/mobs/humanoids/human/scream/femalescream_2.ogg',
			'sound/mobs/humanoids/human/scream/femalescream_3.ogg',
			'sound/mobs/humanoids/human/scream/femalescream_4.ogg',
			'sound/mobs/humanoids/human/scream/femalescream_5.ogg',
		)
	if(prob(1))
		return 'sound/mobs/humanoids/human/scream/wilhelm_scream.ogg'
	return pick(
		'sound/mobs/humanoids/human/scream/malescream_1.ogg',
		'sound/mobs/humanoids/human/scream/malescream_2.ogg',
		'sound/mobs/humanoids/human/scream/malescream_3.ogg',
		'sound/mobs/humanoids/human/scream/malescream_4.ogg',
		'sound/mobs/humanoids/human/scream/malescream_5.ogg',
		'sound/mobs/humanoids/human/scream/malescream_6.ogg',
	)

/datum/emote/living/proc/get_selected_laugh_sound(mob/living/carbon/human/human_user)
	var/datum/laugh_type/selected_laugh = human_user.selected_laugh
	if(isnull(selected_laugh))
		return
	if(human_user.gender == FEMALE && LAZYLEN(selected_laugh.female_laughsounds))
		return pick(selected_laugh.female_laughsounds)
	if(LAZYLEN(selected_laugh.male_laughsounds))
		return pick(selected_laugh.male_laughsounds)
	if(LAZYLEN(selected_laugh.female_laughsounds))
		return pick(selected_laugh.female_laughsounds)

/datum/emote/living/proc/get_default_laugh_sound(mob/living/carbon/human/human_user)
	if(human_user.gender == FEMALE)
		return pick(
			'sound/emotes/emotes/female/female_giggle_1.ogg',
			'sound/emotes/emotes/female/female_giggle_2.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/laugh/manlaugh1.ogg',
		'sound/mobs/humanoids/human/laugh/manlaugh2.ogg',
	)

/datum/emote/living/proc/get_default_cough_sound(mob/living/carbon/human/human_user)
	if(human_user.gender == FEMALE)
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

/datum/emote/living/proc/get_default_cry_sound(mob/living/carbon/human/human_user)
	if(human_user.gender == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cry/female_cry1.ogg',
			'sound/mobs/humanoids/human/cry/female_cry2.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cry/male_cry1.ogg',
		'sound/mobs/humanoids/human/cry/male_cry2.ogg',
		'sound/mobs/humanoids/human/cry/male_cry3.ogg',
	)

/datum/emote/living/proc/get_default_sigh_sound(mob/living/carbon/human/human_user)
	if(human_user.gender == FEMALE)
		return SFX_FEMALE_SIGH
	return SFX_MALE_SIGH

/datum/emote/living/proc/get_default_sneeze_sound(mob/living/carbon/human/human_user)
	if(human_user.gender == FEMALE)
		return 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg'
	return 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg'

/datum/emote/living/proc/get_default_snore_sound(mob/living/carbon/human/human_user)
	if(human_user.gender == FEMALE)
		return SFX_SNORE_FEMALE
	return SFX_SNORE_MALE

/datum/emote/living/taunt
	key = "taunt"
	key_third_person = "taunts"
	message = "taunts!"
	cooldown = 1.6 SECONDS //note when changing this- this is used by the matrix taunt to block projectiles.

/datum/emote/living/taunt/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	user.spin(TAUNT_EMOTE_DURATION, 0.1 SECONDS)

/datum/emote/living/tongue
	key = "tongue"
	key_third_person = "tongues"
	message = "sticks their tongue out."

/datum/emote/living/tongue/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/carbon/human/human_user = user
	if(istype(human_user) && !human_user.get_organ_slot(ORGAN_SLOT_TONGUE))
		to_chat(human_user, span_warning("You don't have a tongue!"))
		return
	. = ..()
	QDEL_IN(human_user.give_emote_overlay(/datum/bodypart_overlay/simple/emote/tongue), 5.2 SECONDS)

/datum/emote/living/blush
	key = "blush"
	key_third_person = "blushes"
	message = "blushes."
	has_custom_emote_effect = TRUE

/datum/emote/living/blush/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	QDEL_IN(human_user.give_emote_overlay(/datum/bodypart_overlay/simple/emote/blush), 5.2 SECONDS)

/datum/emote/living/sing_tune
	key = "tunesing"
	key_third_person = "sings a tune"
	message = "sings a tune."

/datum/emote/living/bow
	key = "bow"
	key_third_person = "bows"
	message = "bows."
	message_param = "bows to %t."
	hands_use_check = TRUE

/datum/emote/living/burp
	key = "burp"
	key_third_person = "burps"
	message = "burps."
	message_mime = "acts out a burp."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/choke
	key = "choke"
	key_third_person = "chokes"
	message = "chokes!"
	message_mime = "chokes silently!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/choke/get_sound(mob/living/user)
	if(!iscarbon(user))
		return
	return pick(
		'sound/mobs/humanoids/human/gag_vomit/gag1.ogg',
		'sound/mobs/humanoids/human/gag_vomit/gag2.ogg',
		'sound/mobs/humanoids/human/gag_vomit/gag3.ogg',
		'sound/mobs/humanoids/human/gag_vomit/gag4.ogg',
		'sound/mobs/humanoids/human/gag_vomit/gag5.ogg',
	)

/datum/emote/living/cross
	key = "cross"
	key_third_person = "crosses"
	message = "crosses their arms."
	hands_use_check = TRUE

/datum/emote/living/chuckle
	key = "chuckle"
	key_third_person = "chuckles"
	message = "chuckles."
	message_mime = "acts out chuckling."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/collapse
	key = "collapse"
	key_third_person = "collapses"
	message = "collapses!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	has_custom_emote_effect = TRUE

/datum/emote/living/collapse/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(isliving(user))
		var/mob/living/living = user
		living.Unconscious(4 SECONDS)

/datum/emote/living/dance
	key = "dance"
	key_third_person = "dances"
	message = "dances around happily."
	hands_use_check = TRUE

/datum/emote/living/deathgasp
	key = "deathgasp"
	key_third_person = "deathgasps"
	message = "seizes up and falls limp, their eyes dead and lifeless..."
	message_robot = "shudders violently for a moment before falling still, its eyes slowly darkening."
	message_AI = "screeches, its screen flickering as its systems slowly halt."
	message_alien = "lets out a waning guttural screech, and collapses onto the floor..."
	message_larva = "lets out a sickly hiss of air and falls limply to the floor..."
	message_monkey = "lets out a faint chimper as it collapses and stops moving..."
	message_animal_or_basic = "stops moving..."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE | EMOTE_IMPORTANT
	cooldown = (15 SECONDS)
	stat_allowed = HARD_CRIT

/datum/emote/living/deathgasp/run_emote(mob/living/user, params, type_override, intentional)
	if(!is_type_in_typecache(user, mob_type_allowed_typecache))
		return
	var/custom_message = user.death_message
	if(custom_message)
		message_animal_or_basic = custom_message
	. = ..()
	message_animal_or_basic = initial(message_animal_or_basic)
	if(!user.can_speak() || user.get_oxy_loss() >= 50)
		return //stop the sound if oxyloss too high/cant speak
	var/mob/living/carbon/carbon_user = user
	// For masks that give unique death sounds
	if(istype(carbon_user) && isclothing(carbon_user.wear_mask) && carbon_user.wear_mask.unique_death)
		playsound(carbon_user, carbon_user.wear_mask.unique_death, 200, TRUE, TRUE)
		return
	if(user.death_sound)
		playsound(user, user.death_sound, 200, TRUE, TRUE)

/datum/emote/living/drool
	key = "drool"
	key_third_person = "drools"
	message = "drools."
	has_custom_emote_effect = TRUE

/datum/emote/living/faint
	key = "faint"
	key_third_person = "faints"
	message = "faints."
	has_custom_emote_effect = TRUE

/datum/emote/living/faint/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(isliving(user))
		var/mob/living/living = user
		living.SetSleeping(20 SECONDS)

/datum/emote/living/flap
	key = "flap"
	key_third_person = "flaps"
	message = "flaps their wings."
	hands_use_check = TRUE
	has_custom_emote_effect = TRUE
	var/wing_time = 0.35 SECONDS

/datum/emote/living/flap/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	var/obj/item/organ/wings/wings = human_user.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)

	// play a flapping noise if the wing has this implemented
	if(!istype(wings))
		return
	wings.make_flap_sound(human_user)

	// open/close functional wings
	var/obj/item/organ/wings/functional/wings_functional = wings
	if(!istype(wings_functional))
		return
	var/open = FALSE
	if(wings_functional.wings_open)
		open = TRUE
		wings_functional.close_wings()
	else
		wings_functional.open_wings()
	addtimer(CALLBACK(wings_functional, open ? TYPE_PROC_REF(/obj/item/organ/wings/functional, open_wings) : TYPE_PROC_REF(/obj/item/organ/wings/functional, close_wings)), wing_time)

/datum/emote/living/flap/aflap
	key = "aflap"
	key_third_person = "aflaps"
	name = "flap (Angry)"
	message = "flaps their wings ANGRILY!"
	hands_use_check = TRUE
	wing_time = 10

/datum/emote/living/frown
	key = "frown"
	key_third_person = "frowns"
	message = "frowns."

/datum/emote/living/gag
	key = "gag"
	key_third_person = "gags"
	message = "gags."
	message_mime = "gags silently."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/gag/get_sound(mob/living/user)
	if(!iscarbon(user))
		return
	return pick(
		'sound/mobs/humanoids/human/gag_vomit/gag1.ogg',
		'sound/mobs/humanoids/human/gag_vomit/gag2.ogg',
		'sound/mobs/humanoids/human/gag_vomit/gag3.ogg',
		'sound/mobs/humanoids/human/gag_vomit/gag4.ogg',
		'sound/mobs/humanoids/human/gag_vomit/gag5.ogg',
	)

/datum/emote/living/gasp
	key = "gasp"
	key_third_person = "gasps"
	message = "gasps!"
	message_mime = "gasps silently!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	stat_allowed = HARD_CRIT

/datum/emote/living/gasp/get_sound(mob/living/user)
	if(HAS_MIND_TRAIT(user, TRAIT_MIMING))
		return
	if(isxenohybrid(user))
		return pick(
			'sound/mobs/non-humanoids/hiss/lowHiss2.ogg',
			'sound/mobs/non-humanoids/hiss/lowHiss3.ogg',
			'sound/mobs/non-humanoids/hiss/lowHiss4.ogg',
		)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	if(human_user.gender == FEMALE) // NOVA EDIT CHANGE - ORIGINAL: if(human_user.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/gasp/gasp_female1.ogg',
			'sound/mobs/humanoids/human/gasp/gasp_female2.ogg',
			'sound/mobs/humanoids/human/gasp/gasp_female3.ogg',
			)
	return pick(
		'sound/mobs/humanoids/human/gasp/gasp_male1.ogg',
		'sound/mobs/humanoids/human/gasp/gasp_male2.ogg',
		)

/datum/emote/living/gasp/shock
	key = "gaspshock"
	key_third_person = "gaspsshock"
	name = "gasp (Shock)"
	message = "gasps in shock!"
	message_mime = "gasps in silent shock!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	stat_allowed = SOFT_CRIT

/datum/emote/living/giggle
	key = "giggle"
	key_third_person = "giggles"
	message = "giggles."
	message_mime = "giggles silently!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/giggle/get_sound(mob/living/user)
	var/mob/living/carbon/human/human_user = user
	if(!istype(human_user))
		return
	var/giggle_sound = get_selected_laugh_sound(human_user)
	if(giggle_sound)
		return giggle_sound
	return get_default_laugh_sound(human_user)

/datum/emote/living/glare
	key = "glare"
	key_third_person = "glares"
	message = "glares."
	message_param = "glares at %t."

/datum/emote/living/grin
	key = "grin"
	key_third_person = "grins"
	message = "grins."

/datum/emote/living/groan
	key = "groan"
	key_third_person = "groans"
	message = "groans!"
	message_mime = "appears to groan!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/grimace
	key = "grimace"
	key_third_person = "grimaces"
	message = "grimaces."

/datum/emote/living/kiss
	key = "kiss"
	key_third_person = "kisses"
	cooldown = 3 SECONDS
	has_custom_emote_effect = TRUE

/datum/emote/living/kiss/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	var/kiss_type = /obj/item/hand_item/kisser

	if(HAS_TRAIT(user, TRAIT_GARLIC_BREATH))
		kiss_type = /obj/item/hand_item/kisser/french

	if(HAS_TRAIT(user, TRAIT_CHEF_KISS))
		kiss_type = /obj/item/hand_item/kisser/chef

	if(HAS_TRAIT(user, TRAIT_SYNDIE_KISS))
		kiss_type = /obj/item/hand_item/kisser/syndie

	if(HAS_TRAIT(user, TRAIT_KISS_OF_DEATH))
		kiss_type = /obj/item/hand_item/kisser/death

	var/datum/action/cooldown/ink_spit/ink_action = locate() in user.actions
	if(ink_action?.IsAvailable())
		kiss_type = /obj/item/hand_item/kisser/ink
	else
		ink_action = null

	var/obj/item/kiss_blower = new kiss_type(user)
	if(user.put_in_hands(kiss_blower))
		to_chat(user, span_notice("You ready your kiss-blowing hand."))
		ink_action?.StartCooldown()
		return

	qdel(kiss_blower)
	to_chat(user, span_warning("You're incapable of blowing a kiss in your current state."))

/datum/emote/living/laugh
	key = "laugh"
	key_third_person = "laughs"
	message = "laughs."
	message_mime = "laughs silently!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	specific_emote_audio_cooldown = 8 SECONDS
	vary = TRUE

/datum/emote/living/laugh/can_run_emote(mob/living/user, status_check = TRUE , intentional, params)
	return ..() && user.can_speak(allow_mimes = TRUE)

/datum/emote/living/laugh/get_sound(mob/living/user)
	var/mob/living/carbon/human/human_user = user
	if(!istype(human_user))
		return
	var/laugh_sound = get_selected_laugh_sound(human_user)
	if(laugh_sound)
		return laugh_sound
	laugh_sound = human_user.dna?.species?.get_laugh_sound(human_user)
	if(laugh_sound)
		return laugh_sound
	return get_default_laugh_sound(human_user)

/datum/emote/living/look
	key = "look"
	key_third_person = "looks"
	message = "looks."
	message_param = "looks at %t."

/datum/emote/living/nod
	key = "nod"
	key_third_person = "nods"
	message = "nods."
	message_param = "nods at %t."

/datum/emote/living/point
	key = "point"
	key_third_person = "points"
	message = "points."
	message_param = "points at %t."
	cooldown = 1 SECONDS
	// don't put hands use check here, everything is handled in run_emote

/datum/emote/living/point/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param) // reset
	if(iscarbon(user))
		var/mob/living/carbon/our_carbon = user
		if(our_carbon.usable_hands <= 0 || user.incapacitated & INCAPABLE_RESTRAINTS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
			if(our_carbon.usable_legs > 0)
				var/one_leg = FALSE
				var/has_shoes = our_carbon.get_item_by_slot(ITEM_SLOT_FEET)
				if(our_carbon.usable_legs == 1)
					one_leg = TRUE
				var/success_prob = 65
				if(HAS_TRAIT(our_carbon, TRAIT_FREERUNNING))
					success_prob += 35
				if(one_leg)
					success_prob -= 40
				if(prob(success_prob))
					message_param = "[one_leg ? "jumps into the air and " : ""]points at %t with their [has_shoes ? "leg" : "toes"]!"
				else
					message_param = "[one_leg ? "jumps into the air and " : ""]tries to point at %t with their [has_shoes ? "leg" : "toes"], falling down in the process!"
					our_carbon.Paralyze(2 SECONDS)
				TIMER_COOLDOWN_START(user, "point_verb_emote_cooldown", 1 SECONDS)
			else
				if(our_carbon.get_organ_slot(ORGAN_SLOT_EYES))
					message_param = "gives a meaningful glance at %t!"
					TIMER_COOLDOWN_START(src, "point_verb_emote_cooldown", 1.5 SECONDS)
				else
					if(our_carbon.get_organ_slot(ORGAN_SLOT_TONGUE))
						message_param = "motions their tongue towards %t!"
						TIMER_COOLDOWN_START(src, "point_verb_emote_cooldown", 2 SECONDS)
					else
						message_param = "[span_userdanger("bumps [user.p_their()] head on the ground")] trying to motion towards %t."
						our_carbon.adjust_organ_loss(ORGAN_SLOT_BRAIN, 5)
						playsound(user, 'sound/effects/glass/glassbash.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
						TIMER_COOLDOWN_START(src, "point_verb_emote_cooldown", 2.5 SECONDS)
	return ..()

/datum/emote/living/sneeze
	key = "sneeze"
	key_third_person = "sneezes"
	message = "sneezes."
	message_mime = "acts out an exaggerated silent sneeze."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/sneeze/get_sound(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(isvox(user))
		return 'sound/emotes/emotes/voxsneeze.ogg'
	var/sneeze_sound = user.dna?.species?.get_sneeze_sound(user)
	if(sneeze_sound)
		return sneeze_sound
	return get_default_sneeze_sound(user)

/datum/emote/living/cough
	key = "cough"
	key_third_person = "coughs"
	message = "coughs!"
	message_mime = "acts out an exaggerated cough!"
	vary = TRUE
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE | EMOTE_RUNECHAT

/datum/emote/living/cough/can_run_emote(mob/user, status_check = TRUE , intentional, params)
	return !HAS_TRAIT(user, TRAIT_SOOTHED_THROAT) && ..()

/datum/emote/living/cough/get_sound(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(isvox(user))
		return 'sound/emotes/emotes/voxcough.ogg'
	var/cough_sound = user.dna?.species?.get_cough_sound(user)
	if(cough_sound)
		return cough_sound
	return get_default_cough_sound(user)

/datum/emote/living/wheeze
	key = "wheeze"
	key_third_person = "wheezes"
	message = "wheezes!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/pout
	key = "pout"
	key_third_person = "pouts"
	message = "pouts."
	message_mime = "pouts silently."

/datum/emote/living/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams!"
	message_mime = "acts out a scream!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	mob_type_blacklist_typecache = list(/mob/living/brain)
	sound_wall_ignore = TRUE
	specific_emote_audio_cooldown = 10 SECONDS
	vary = TRUE

/datum/emote/living/scream/run_emote(mob/user, params, type_override, intentional = FALSE)
	if(!intentional && HAS_TRAIT(user, TRAIT_ANALGESIA))
		return
	return ..()

/datum/emote/living/scream/select_message_type(mob/user, message, intentional)
	. = ..()
	if(!intentional && isanimal_or_basicmob(user))
		return "makes a loud and pained whimper."

/datum/emote/living/scream/get_sound(mob/living/user)
	if(issilicon(user))
		var/mob/living/silicon/silicon_user = user
		var/datum/scream_type/selected_scream = silicon_user.selected_scream
		if(!isnull(selected_scream))
			if(silicon_user.gender == FEMALE && LAZYLEN(selected_scream.female_screamsounds))
				return pick(selected_scream.female_screamsounds)
			if(LAZYLEN(selected_scream.male_screamsounds))
				return pick(selected_scream.male_screamsounds)
			if(LAZYLEN(selected_scream.female_screamsounds))
				return pick(selected_scream.female_screamsounds)
		return 'sound/emotes/voice/scream_silicon.ogg'
	if(ismonkey(user))
		return 'sound/emotes/voice/scream_monkey.ogg'
	if(isdrone(user))
		return 'sound/emotes/voice/scream_silicon.ogg'
	if(istype(user, /mob/living/basic/gorilla))
		return 'sound/mobs/non-humanoids/gorilla/gorilla.ogg'
	if(isalien(user))
		return 'sound/mobs/non-humanoids/hiss/hiss6.ogg'
	var/mob/living/carbon/human/human_user = user
	if(!istype(human_user))
		return
	var/scream_sound = get_selected_scream_sound(human_user)
	if(scream_sound)
		return scream_sound
	if(prob(1))
		return 'sound/mobs/humanoids/human/scream/wilhelm_scream.ogg'
	scream_sound = human_user.dna?.species?.get_scream_sound(human_user)
	if(scream_sound)
		return scream_sound
	return get_default_scream_sound(human_user)

/datum/emote/living/scowl
	key = "scowl"
	key_third_person = "scowls"
	message = "scowls."

/datum/emote/living/shake
	key = "shake"
	key_third_person = "shakes"
	message = "shakes their head."

/datum/emote/living/shiver
	key = "shiver"
	key_third_person = "shiver"
	message = "shivers."
	has_custom_emote_effect = TRUE

#define SHIVER_LOOP_DURATION (1 SECONDS)
/datum/emote/living/shiver/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()

	animate(user, pixel_w = 1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	for(var/i in 1 to SHIVER_LOOP_DURATION / (0.2 SECONDS)) //desired total duration divided by the iteration duration to give the necessary iteration count
		animate(pixel_w = -2, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
		animate(pixel_w = 2, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
	animate(pixel_w = -1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)
#undef SHIVER_LOOP_DURATION

/datum/emote/living/sigh
	key = "sigh"
	key_third_person = "sighs"
	message = "sighs."
	message_mime = "acts out an exaggerated silent sigh."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/sigh/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!ishuman(user))
		return
	var/image/emote_animation = image('icons/mob/human/emote_visuals.dmi', user, "sigh")
	flick_overlay_global(emote_animation, GLOB.clients, 2.0 SECONDS)

/datum/emote/living/sigh/get_sound(mob/living/carbon/human/user)
	if(!istype(user))
		return
	var/sigh_sound = user.dna?.species?.get_sigh_sound(user)
	if(sigh_sound)
		return sigh_sound
	return get_default_sigh_sound(user)

/datum/emote/living/sit
	key = "sit"
	key_third_person = "sits"
	message = "sits down."

/datum/emote/living/smile
	key = "smile"
	key_third_person = "smiles"
	message = "smiles."

/datum/emote/living/smug
	key = "smug"
	key_third_person = "smugs"
	message = "grins smugly."

/datum/emote/living/sniff
	key = "sniff"
	key_third_person = "sniffs"
	message = "sniffs."
	message_mime = "sniffs silently."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/sniff/get_sound(mob/living/carbon/human/user)
	if(!istype(user))
		return
	var/snd = user.dna?.species?.get_sniff_sound(user)
	if(snd)
		return snd
	if(user.gender == MALE)
		return 'sound/mobs/humanoids/human/sniff/male_sniff.ogg'
	return 'sound/mobs/humanoids/human/sniff/female_sniff.ogg'

/datum/emote/living/snore
	key = "snore"
	key_third_person = "snores"
	message = "snores."
	message_mime = "sleeps soundly."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	stat_allowed = UNCONSCIOUS

// eventually we want to give species their own "snoring" sounds
/datum/emote/living/snore/get_sound(mob/living/carbon/human/user)
	if(!istype(user))
		return
	var/snore_sound = user.dna?.species?.get_snore_sound(user)
	if(snore_sound)
		return snore_sound
	return get_default_snore_sound(user)

/datum/emote/living/stare
	key = "stare"
	key_third_person = "stares"
	message = "stares."
	message_param = "stares at %t."

/datum/emote/living/strech
	key = "stretch"
	key_third_person = "stretches"
	message = "stretches their arms."

/datum/emote/living/sulk
	key = "sulk"
	key_third_person = "sulks"
	message = "sulks down sadly."

/datum/emote/living/surrender
	key = "surrender"
	key_third_person = "surrenders"
	message = "puts their hands on their head and falls to the ground, they surrender%s!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	has_custom_emote_effect = TRUE

/datum/emote/living/surrender/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(isliving(user))
		var/mob/living/living = user
		living.Paralyze(20 SECONDS)
		living.remove_status_effect(/datum/status_effect/grouped/surrender)

/datum/emote/living/sway
	key = "sway"
	key_third_person = "sways"
	message = "sways around dizzily."
	has_custom_emote_effect = TRUE

/datum/emote/living/sway/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()

	animate(user, pixel_w = 2, time = 0.5 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	for(var/i in 1 to 2)
		animate(pixel_w = -6, time = 1.0 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
		animate(pixel_w = 6, time = 1.0 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
	animate(pixel_w = -2, time = 0.5 SECONDS, flags = ANIMATION_RELATIVE)

/datum/emote/living/tilt
	key = "tilt"
	key_third_person = "tilts"
	message = "tilts their head to the side."

/datum/emote/living/tremble
	key = "tremble"
	key_third_person = "trembles"
	message = "trembles!"
	has_custom_emote_effect = TRUE

#define TREMBLE_LOOP_DURATION (4.4 SECONDS)
/datum/emote/living/tremble/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()

	animate(user, pixel_w = 2, time = 0.2 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	for(var/i in 1 to TREMBLE_LOOP_DURATION / (0.4 SECONDS)) //desired total duration divided by the iteration duration to give the necessary iteration count
		animate(pixel_w = -4, time = 0.2 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
		animate(pixel_w = 4, time = 0.2 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
	animate(pixel_w = -2, time = 0.2 SECONDS, flags = ANIMATION_RELATIVE)
#undef TREMBLE_LOOP_DURATION

/datum/emote/living/twitch
	key = "twitch"
	key_third_person = "twitches"
	message = "twitches violently."
	has_custom_emote_effect = TRUE

/datum/emote/living/twitch/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()

	animate(user, pixel_w = 1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	animate(pixel_w = -2, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)
	animate(time = 0.1 SECONDS)
	animate(pixel_w = 2, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)
	animate(pixel_w = -1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)

/datum/emote/living/twitch_s
	key = "twitch_s"
	name = "twitch (Slight)"
	message = "twitches."
	has_custom_emote_effect = TRUE

/datum/emote/living/twitch_s/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()

	animate(user, pixel_w = -1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	animate(pixel_w = 1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)

/datum/emote/living/wave
	key = "wave"
	key_third_person = "waves"
	message = "waves."

/datum/emote/living/whimper
	key = "whimper"
	key_third_person = "whimpers"
	message = "whimpers."
	message_mime = "appears hurt."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/wsmile
	key = "wsmile"
	key_third_person = "wsmiles"
	name = "smile (Weak)"
	message = "smiles weakly."

/// The base chance for your yawn to propagate to someone else if they're on the same tile as you
#define YAWN_PROPAGATE_CHANCE_BASE 0 // NOVA EDIT - Group yawn no more - ORIGINAL: #define YAWN_PROPAGATE_CHANCE_BASE 20
/// The amount the base chance to propagate yawns falls for each tile of distance
#define YAWN_PROPAGATE_CHANCE_DECAY 4

/datum/emote/living/yawn
	key = "yawn"
	key_third_person = "yawns"
	message = "yawns."
	message_mime = "acts out an exaggerated silent yawn."
	message_robot = "symphathetically yawns."
	message_AI = "symphathetically yawns."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = 5 SECONDS

/datum/emote/living/yawn/get_sound(mob/living/user)
	if(!iscarbon(user))
		return
	return pick(
		'sound/emotes/emotes/yawn_m1.ogg',
		'sound/emotes/emotes/yawn_m2.ogg',
	)

/datum/emote/living/yawn/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!isliving(user))
		return

	if(TIMER_COOLDOWN_FINISHED(user, COOLDOWN_YAWN_PROPAGATION))
		TIMER_COOLDOWN_START(user, COOLDOWN_YAWN_PROPAGATION, cooldown * 3)

	var/mob/living/carbon/carbon_user = user
	if(carbon_user.obscured_slots & HIDEFACE)
		return // if your face is obscured, skip propagation

	var/propagation_distance = user.client ? 5 : 2 // mindless mobs are less able to spread yawns

	for(var/mob/living/iter_living in view(user, propagation_distance))
		if(IS_DEAD_OR_INCAP(iter_living) || TIMER_COOLDOWN_RUNNING(iter_living, COOLDOWN_YAWN_PROPAGATION))
			continue

		var/dist_between = get_dist(user, iter_living)
		var/recently_examined = FALSE // if you yawn just after someone looks at you, it forces them to yawn as well. Tradecraft!

		if(iter_living.client)
			var/examine_time = LAZYACCESS(iter_living.client?.recent_examines, user)
			if(examine_time && (world.time - examine_time < YAWN_PROPAGATION_EXAMINE_WINDOW))
				recently_examined = TRUE

		if(!recently_examined && !prob(YAWN_PROPAGATE_CHANCE_BASE - (YAWN_PROPAGATE_CHANCE_DECAY * dist_between)))
			continue

		var/yawn_delay = rand(0.2 SECONDS, 0.7 SECONDS) * dist_between
		addtimer(CALLBACK(src, PROC_REF(propagate_yawn), iter_living), yawn_delay)

/// This yawn has been triggered by someone else yawning specifically, likely after a delay. Check again if they don't have the yawned recently trait
/datum/emote/living/yawn/proc/propagate_yawn(mob/user)
	if(!istype(user) || TIMER_COOLDOWN_RUNNING(user, COOLDOWN_YAWN_PROPAGATION))
		return
	user.emote("yawn")

// ==================== Ported from ES13 ====================

/datum/emote/living/fox_yip
	key = "foxyip"
	key_third_person = "foxyips"
	message = "yips!"
	sound = 'sound/voice/fox_squeak.ogg'
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/meow5
	key = "meow5"
	key_third_person = "meows"
	message = "meows!"
	sound = 'sound/voice/meow5.ogg'
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/snakedies
	key = "snakedies"
	key_third_person = "dies like a Snake"
	message = "dying like a Snake."
	sound = 'sound/voice/snakedies.ogg'
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/foxtrill
	key = "foxtrill"
	key_third_person = "foxtrills"
	message = "trills like a fox!"
	sound = 'sound/voice/foxtrill2.ogg'
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/fwhine
	key = "fwhine"
	key_third_person = "fwhines"
	message = "whines like a fox"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/fwhine/get_sound(mob/living/user)
	return pick(
		'sound/voice/fox1.ogg',
		'sound/voice/fox2.ogg',
		'sound/voice/fox3.ogg',
		'sound/voice/fox4.ogg',
		'sound/voice/fox5.ogg',
		'sound/voice/fox6.ogg',
		'sound/voice/fox7.ogg',
		'sound/voice/fox8.ogg',
		'sound/voice/fox9.ogg',
		'sound/voice/fox10.ogg',
		'sound/voice/fox11.ogg',
		'sound/voice/fox12.ogg',
		'sound/voice/fox13.ogg',
	)

/datum/emote/living/memee
	key = "memee"
	key_third_person = "memees"
	message = "memees!"
	sound = 'sound/voice/memee.ogg'
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

// Wawa emotes - Madeline's expressions
/datum/emote/living/wachoo
	key = "wachoo"
	key_third_person = "wahs"
	message = "wahs!"
	sound = 'sound/voice/wawa_achoo.ogg'
	emote_type = EMOTE_AUDIBLE
	sound_volume = 30

/datum/emote/living/wachatter
	key = "wachat"
	key_third_person = "wahs"
	message = "wahs!"
	sound = 'sound/voice/wawa_chatter.ogg'
	emote_type = EMOTE_AUDIBLE
	sound_volume = 30

/datum/emote/living/wachillin
	key = "wachillin"
	key_third_person = "wahs"
	message = "wahs!"
	sound = 'sound/voice/wawa_chillin.ogg'
	emote_type = EMOTE_AUDIBLE
	sound_volume = 30

/datum/emote/living/wadepression
	key = "wasad"
	key_third_person = "wahs"
	message = "wahs!"
	sound = 'sound/voice/wawa_depression.ogg'
	emote_type = EMOTE_AUDIBLE
	sound_volume = 30

/datum/emote/living/wadespair
	key = "wadespair"
	key_third_person = "wahs"
	message = "wahs!"
	sound = 'sound/voice/wawa_despair.ogg'
	emote_type = EMOTE_AUDIBLE
	sound_volume = 30

/datum/emote/living/waexclaim
	key = "waexclaim"
	key_third_person = "wahs"
	message = "wahs!"
	sound = 'sound/voice/wawa_exclaim.ogg'
	emote_type = EMOTE_AUDIBLE
	sound_volume = 30

/datum/emote/living/waprotest
	key = "waprotest"
	key_third_person = "wahs"
	message = "wahs!"
	sound = 'sound/voice/wawa_protest.ogg'
	emote_type = EMOTE_AUDIBLE
	sound_volume = 30

/datum/emote/living/wamock
	key = "wamock"
	key_third_person = "wahs"
	message = "wahs!"
	sound = 'sound/voice/wawa_mock.ogg'
	emote_type = EMOTE_AUDIBLE
	sound_volume = 30

/datum/emote/living/waquestion
	key = "waquestion"
	key_third_person = "wahs"
	message = "wahs!"
	sound = 'sound/voice/wawa_question.ogg'
	emote_type = EMOTE_AUDIBLE
	sound_volume = 30

/datum/emote/living/wastate
	key = "wastate"
	key_third_person = "wahs"
	message = "wahs!"
	sound = 'sound/voice/wawa_statement.ogg'
	emote_type = EMOTE_AUDIBLE
	sound_volume = 30

/datum/emote/living/waend
	key = "waend"
	key_third_person = "wahs"
	message = "wahs!"
	sound = 'sound/voice/wawa_the_end.ogg'
	emote_type = EMOTE_AUDIBLE
	sound_volume = 30

/datum/emote/living/wayawn
	key = "wayawn"
	key_third_person = "wahs"
	message = "wahs!"
	sound = 'sound/voice/wawa_yawn.ogg'
	emote_type = EMOTE_AUDIBLE
	sound_volume = 30

// ==================== Ported from ES13 ====================
// === LAUGH VARIANTS ===

/datum/emote/living/laugh2
	key = "laugh2"
	key_third_person = "laugh2"
	message = "laughs in a royally obnoxious manner!"
	message_mime = "laughs silently."
	sound = 'sound/voice/laugh_king.ogg'
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/laugh3
	key = "laugh3"
	key_third_person = "laugh3"
	message = "laughs!"
	message_mime = "laughs silently."
	sound = 'sound/voice/lol.ogg'
	specific_emote_audio_cooldown = 6.1 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/laugh4
	key = "laugh4"
	key_third_person = "laugh4"
	message = "laughs!"
	message_mime = "laughs silently."
	sound = 'sound/voice/laugh_muta.ogg'
	specific_emote_audio_cooldown = 3 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/laugh5
	key = "laugh5"
	key_third_person = "laugh5"
	message = "laughs!"
	message_mime = "laughs silently."
	sound = 'sound/voice/laugh_deman.ogg'
	specific_emote_audio_cooldown = 2.75 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/laugh6
	key = "laugh6"
	key_third_person = "laugh6"
	message = "laughs!"
	message_mime = "laughs silently."
	sound = 'sound/voice/laugh6.ogg'
	specific_emote_audio_cooldown = 4.45 SECONDS
	emote_type = EMOTE_AUDIBLE

// === CAT SOUNDS ===

/datum/emote/living/cathiss
	key = "cathiss"
	key_third_person = "cathisses"
	message = "hisses like a cat!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/cathiss/get_sound(mob/living/user)
	return pick(
		'sound/voice/catpeople/cat_hiss1.ogg',
		'sound/voice/catpeople/cat_hiss2.ogg',
		'sound/voice/catpeople/cat_hiss3.ogg',
	)

/datum/emote/living/coo
	key = "coo"
	key_third_person = "coos"
	message = "coos."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/voice/coo.ogg'

/datum/emote/living/meow4
	key = "meow4"
	key_third_person = "meows"
	message = "meows!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/meow4/get_sound(mob/living/user)
	return pick(
		'sound/voice/catpeople/cat_meow4.ogg',
		'sound/voice/catpeople/cat_meow5.ogg',
		'sound/voice/catpeople/cat_meow6.ogg',
		'sound/voice/catpeople/cat_meow7.ogg',
	)

/datum/emote/living/meow6
	key = "meow6"
	key_third_person = "meows"
	message = "meows."
	sound = 'sound/voice/meow6.ogg'
	emote_type = EMOTE_AUDIBLE

// === WEH/WAA VARIANTS ===

/datum/emote/living/weh2
	key = "weh2"
	key_third_person = "wehs"
	message = "lets out a weh!"
	message_mime = "acts out a weh!"
	sound = 'sound/voice/weh2.ogg'
	specific_emote_audio_cooldown = 0.25 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/weh3
	key = "weh3"
	key_third_person = "wehs"
	message = "lets out a weh!"
	message_mime = "acts out a weh!"
	sound = 'sound/voice/weh3.ogg'
	specific_emote_audio_cooldown = 0.25 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/weh4
	key = "weh4"
	key_third_person = "wehs"
	message = "lets out a surprised weh!"
	message_mime = "acts out a surprised weh!"
	sound = 'sound/voice/weh_s.ogg'
	specific_emote_audio_cooldown = 0.35 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/waa
	key = "waa"
	key_third_person = "waas"
	message = "lets out a waa!"
	message_mime = "acts out a waa!"
	sound = 'sound/voice/waa.ogg'
	specific_emote_audio_cooldown = 3.5 SECONDS
	emote_type = EMOTE_AUDIBLE

// === BARK/CANINE VARIANTS ===

/datum/emote/living/bark2
	key = "bark2"
	key_third_person = "barks"
	message = "barks!"
	message_mime = "acts out a bark!"
	sound = 'sound/voice/bark_alt.ogg'
	specific_emote_audio_cooldown = 0.35 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/yap
	key = "yap"
	key_third_person = "yaps"
	message = "yaps!"
	message_mime = "acts out a yap!"
	sound = 'sound/voice/yap.ogg'
	specific_emote_audio_cooldown = 0.28 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/woof2
	key = "woof2"
	key_third_person = "woofs"
	message = "woofs!"
	sound = 'sound/voice/woof2.ogg'
	specific_emote_audio_cooldown = 0.3 SECONDS
	emote_type = EMOTE_AUDIBLE

// === MEW ===

/datum/emote/living/mew
	key = "mew"
	key_third_person = "mews"
	message = "mews."
	message_mime = "silently mouths a mew."
	sound = 'sound/voice/meow_meme.ogg'
	cooldown = 1 SECONDS
	emote_type = EMOTE_AUDIBLE

// === CHITTER2 ===

/datum/emote/living/chitter2
	key = "chitter2"
	key_third_person = "chitts"
	message = "makes a clicking/chittering sound."
	message_mime = "silently clicks their mouth."
	sound = 'sound/voice/moth/mothchitter2.ogg'
	specific_emote_audio_cooldown = 0.3 SECONDS
	emote_type = EMOTE_AUDIBLE

// === CRY2 ===

/datum/emote/living/cry2
	key = "cry2"
	key_third_person = "cry2"
	message = "cries!"
	message_mime = "cries silently."
	emote_type = EMOTE_AUDIBLE
	specific_emote_audio_cooldown = 1.6 SECONDS

/datum/emote/living/cry2/get_sound(mob/living/user)
	return pick(
		'sound/voice/cry_king.ogg',
		'sound/voice/cry_king2.ogg',
	)

// === WHISTLE TUNES ===

/datum/emote/living/wtune
	key = "whistletune"
	key_third_person = "whistletunes"
	message = "whistles a tune."
	message_mime = "makes an expression as if whistling."
	sound = 'sound/voice/wtune1.ogg'
	specific_emote_audio_cooldown = 4.55 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/bwtune
	key = "badwhistletune"
	key_third_person = "badwhistletunes"
	message = "tries to whistle a tune."
	message_mime = "makes an expression as if whistling."
	sound = 'sound/voice/wtune2.ogg'
	specific_emote_audio_cooldown = 4.55 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/fiufiu
	key = "wolfwhistle"
	key_third_person = "wolfwhistles"
	message = "wolf-whistles!"
	message_mime = "makes an expression as if inappropriately whistling."
	sound = 'sound/voice/wolfwhistle.ogg'
	specific_emote_audio_cooldown = 0.78 SECONDS
	emote_type = EMOTE_AUDIBLE

// === PAIN ===

/datum/emote/living/pain
	key = "pain"
	key_third_person = "cries out in pain"
	message = "cries out in pain!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/pain/get_sound(mob/living/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	if(H.gender == MALE)
		return pick(
			'sound/voice/human_male_pain_1.ogg',
			'sound/voice/human_male_pain_2.ogg',
			'sound/voice/human_male_pain_3.ogg',
			'sound/voice/human_male_pain_rare.ogg',
			'sound/voice/human_male_scream_1.ogg',
			'sound/voice/human_male_scream_2.ogg',
			'sound/voice/human_male_scream_3.ogg',
			'sound/voice/human_male_scream_4.ogg',
		)
	return pick(
		'sound/voice/human_female_pain_1.ogg',
		'sound/voice/human_female_pain_2.ogg',
		'sound/voice/human_female_pain_3.ogg',
		'sound/voice/human_female_scream_2.ogg',
		'sound/voice/human_female_scream_3.ogg',
		'sound/voice/human_female_scream_4.ogg',
	)

// === RAWR ===

/datum/emote/living/rawr2
	key = "rawr"
	key_third_person = "rawr"
	message = "makes RAWR!"
	sound = 'sound/voice/rawr.ogg'
	emote_type = EMOTE_AUDIBLE

// === ZUBBERS EMOTES ===

/datum/emote/living/fpurr
	key = "fpurr"
	key_third_person = "purrs"
	message = "purrs!"
	message_mime = "purrs silently!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/voice/fox_purr.ogg'

/datum/emote/living/meow1
	key = "meow1"
	key_third_person = "meows"
	message = "meows!"
	message_mime = "meows silently!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/emotes/meow1.ogg'

/datum/emote/living/mrowl
	key = "mrowl"
	key_third_person = "mrowls"
	message = "mrowls!"
	message_mime = "mrowls silently!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/emotes/mrowl.ogg'

/datum/emote/living/tail_thump
	key = "tailthump"
	key_third_person = "thumps their tail"
	message = "thumps their tail."
	message_mime = "thumps their tail silently."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/voice/tailthump.ogg'

/datum/emote/living/tail_thump/can_run_emote(mob/living/user, status_check = TRUE, intentional, params)
	if(!user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL))
		return FALSE
	return ..()

/datum/emote/living/squeal
	key = "squeal"
	key_third_person = "squeals"
	message = "squeals!"
	message_mime = "squeals silently!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/voice/squeal.ogg'

/datum/emote/living/yipyip
	key = "yipyip"
	key_third_person = "yipyips"
	message = "yip-yips!"
	message_mime = "yip-yips silently!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/voice/yip_zubbers.ogg'

/datum/emote/living/kweh
	key = "kweh"
	key_third_person = "kwehs"
	message = "kwehs!"
	message_mime = "kwehs silently!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/kweh/get_sound(mob/living/user)
	return pick(
		'sound/mobs/non-humanoids/raptor/raptor_1.ogg',
		'sound/mobs/non-humanoids/raptor/raptor_4.ogg',
		'sound/mobs/non-humanoids/raptor/raptor_5.ogg',
	)

/datum/emote/living/kweh_sad
	key = "skweh"
	key_third_person = "skwehs"
	message = "lets out a sad kweh..."
	message_mime = "skwehs silently!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/kweh_sad/get_sound(mob/living/user)
	return pick(
		'sound/mobs/non-humanoids/raptor/raptor_2.ogg',
		'sound/mobs/non-humanoids/raptor/raptor_3.ogg',
	)

// ==================== Sound Variant Overrides ====================
// These allow the custom emote panel to offer variant-specific sound selection.

/datum/emote/living/fwhine/get_sound_variants(mob/living/user)
	return list(
		"fox 1" = 'sound/voice/fox1.ogg',
		"fox 2" = 'sound/voice/fox2.ogg',
		"fox 3" = 'sound/voice/fox3.ogg',
		"fox 4" = 'sound/voice/fox4.ogg',
		"fox 5" = 'sound/voice/fox5.ogg',
		"fox 6" = 'sound/voice/fox6.ogg',
		"fox 7" = 'sound/voice/fox7.ogg',
		"fox 8" = 'sound/voice/fox8.ogg',
		"fox 9" = 'sound/voice/fox9.ogg',
		"fox 10" = 'sound/voice/fox10.ogg',
		"fox 11" = 'sound/voice/fox11.ogg',
		"fox 12" = 'sound/voice/fox12.ogg',
		"fox 13" = 'sound/voice/fox13.ogg',
	)

/datum/emote/living/cough/get_sound_variants(mob/living/user)
	return list(
		"male 1" = 'sound/mobs/humanoids/human/cough/male_cough1.ogg',
		"male 2" = 'sound/mobs/humanoids/human/cough/male_cough2.ogg',
		"male 3" = 'sound/mobs/humanoids/human/cough/male_cough3.ogg',
		"male 4" = 'sound/mobs/humanoids/human/cough/male_cough4.ogg',
		"male 5" = 'sound/mobs/humanoids/human/cough/male_cough5.ogg',
		"male 6" = 'sound/mobs/humanoids/human/cough/male_cough6.ogg',
		"female 1" = 'sound/mobs/humanoids/human/cough/female_cough1.ogg',
		"female 2" = 'sound/mobs/humanoids/human/cough/female_cough2.ogg',
		"female 3" = 'sound/mobs/humanoids/human/cough/female_cough3.ogg',
		"female 4" = 'sound/mobs/humanoids/human/cough/female_cough4.ogg',
		"female 5" = 'sound/mobs/humanoids/human/cough/female_cough5.ogg',
		"female 6" = 'sound/mobs/humanoids/human/cough/female_cough6.ogg',
	)

/datum/emote/living/sneeze/get_sound_variants(mob/living/user)
	return list(
		"male" = 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg',
		"female" = 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg',
	)

/datum/emote/living/sigh/get_sound_variants(mob/living/user)
	return list(
		"male 1" = 'sound/mobs/humanoids/human/sigh/male_sigh1.ogg',
		"male 2" = 'sound/mobs/humanoids/human/sigh/male_sigh2.ogg',
		"male 3" = 'sound/mobs/humanoids/human/sigh/male_sigh3.ogg',
		"female 1" = 'sound/mobs/humanoids/human/sigh/female_sigh1.ogg',
		"female 2" = 'sound/mobs/humanoids/human/sigh/female_sigh2.ogg',
		"female 3" = 'sound/mobs/humanoids/human/sigh/female_sigh3.ogg',
	)

/datum/emote/living/sniff/get_sound_variants(mob/living/user)
	return list(
		"male" = 'sound/mobs/humanoids/human/sniff/male_sniff.ogg',
		"female" = 'sound/mobs/humanoids/human/sniff/female_sniff.ogg',
	)

/datum/emote/living/snore/get_sound_variants(mob/living/user)
	return list(
		"male 1" = 'sound/mobs/humanoids/human/snore/snore_male1.ogg',
		"male 2" = 'sound/mobs/humanoids/human/snore/snore_male2.ogg',
		"male 3" = 'sound/mobs/humanoids/human/snore/snore_male3.ogg',
		"male 4" = 'sound/mobs/humanoids/human/snore/snore_male4.ogg',
		"male 5" = 'sound/mobs/humanoids/human/snore/snore_male5.ogg',
		"female 1" = 'sound/mobs/humanoids/human/snore/snore_female1.ogg',
		"female 2" = 'sound/mobs/humanoids/human/snore/snore_female2.ogg',
		"female 3" = 'sound/mobs/humanoids/human/snore/snore_female3.ogg',
	)

/datum/emote/living/gasp/get_sound_variants(mob/living/user)
	return list(
		"male 1" = 'sound/mobs/humanoids/human/gasp/gasp_male1.ogg',
		"male 2" = 'sound/mobs/humanoids/human/gasp/gasp_male2.ogg',
		"female 1" = 'sound/mobs/humanoids/human/gasp/gasp_female1.ogg',
		"female 2" = 'sound/mobs/humanoids/human/gasp/gasp_female2.ogg',
		"female 3" = 'sound/mobs/humanoids/human/gasp/gasp_female3.ogg',
	)

/datum/emote/living/laugh/get_sound_variants(mob/living/user)
	return list(
		"male 1" = 'sound/mobs/humanoids/human/laugh/manlaugh1.ogg',
		"male 2" = 'sound/mobs/humanoids/human/laugh/manlaugh2.ogg',
		"female" = 'sound/mobs/humanoids/human/laugh/womanlaugh.ogg',
	)

#undef YAWN_PROPAGATE_CHANCE_BASE
#undef YAWN_PROPAGATE_CHANCE_DECAY

/datum/emote/living/gurgle
	key = "gurgle"
	key_third_person = "gurgles"
	message = "makes an uncomfortable gurgle."
	message_mime = "gurgles silently and uncomfortably."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/custom
	key = "me"
	key_third_person = "custom"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	message = null

/datum/emote/living/custom/can_run_emote(mob/user, status_check, intentional, params)
	. = ..()
	if(!. || !intentional)
		return FALSE

	if(!isnull(user.ckey) && is_banned_from(user.ckey, "Emote"))
		to_chat(user, span_boldwarning("You cannot send custom emotes (banned)."))
		return FALSE

	if(QDELETED(user))
		return FALSE

	if(user.client && user.client.prefs.muted & MUTE_IC)
		to_chat(user, span_boldwarning("You cannot send IC messages (muted)."))
		return FALSE

/datum/emote/living/custom/proc/emote_is_valid(mob/user, input)
	// We're assuming clientless mobs custom emoting is something codebase-driven and not player-driven.
	// If players ever get the ability to force clientless mobs to emote, we'd need to reconsider this.
	if(!user.client)
		return TRUE

	if(CAN_BYPASS_FILTER(user))
		return TRUE

	var/static/regex/stop_bad_mime = regex(@"says|exclaims|yells|asks")
	if(stop_bad_mime.Find(input, 1, 1))
		to_chat(user, span_danger("Invalid emote."))
		return FALSE

	var/list/filter_result = is_ic_filtered(input)

	if(filter_result)
		to_chat(user, span_warning("That emote contained a word prohibited in IC emotes! Consider reviewing the server rules."))
		to_chat(user, span_warning("\"[input]\""))
		REPORT_CHAT_FILTER_TO_USER(user, filter_result)
		log_filter("IC Emote", input, filter_result)
		SSblackbox.record_feedback("tally", "ic_blocked_words", 1, LOWER_TEXT(config.ic_filter_regex.match))
		return FALSE

	filter_result = is_soft_ic_filtered(input)

	if(filter_result)
		if(tgui_alert(user,"Your emote contains \"[filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to emote it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			SSblackbox.record_feedback("tally", "soft_ic_blocked_words", 1, LOWER_TEXT(config.soft_ic_filter_regex.match))
			log_filter("Soft IC Emote", input, filter_result)
			return FALSE

		message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for emote \"[filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Emote: \"[html_encode(input)]\"")
		log_admin_private("[key_name(user)] has passed the soft filter for emote \"[filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Emote: \"[input]\"")
		SSblackbox.record_feedback("tally", "passed_soft_ic_blocked_words", 1, LOWER_TEXT(config.soft_ic_filter_regex.match))
		log_filter("Soft IC Emote (Passed)", input, filter_result)

	return TRUE

/datum/emote/living/custom/get_message_flags(intentional)
	. = ..()
	return .|WITH_EMPHASIS_MESSAGE

/datum/emote/living/custom/proc/get_custom_emote_from_user()
	return stripped_multiline_input(usr, "Choose an emote to display.", "Me" , null, MAX_MESSAGE_LEN) // NOVA EDIT CHANGE - ORIGINAL : return copytext(sanitize(input("Choose an emote to display.") as text|null), 1, MAX_MESSAGE_LEN)

/datum/emote/living/custom/proc/get_custom_emote_type_from_user()
	var/type = input("Is this a visible or hearable emote?") as null|anything in list("Visible", "Hearable", "Both")

	switch(type)
		if("Visible")
			return EMOTE_VISIBLE
		if("Hearable")
			return EMOTE_AUDIBLE
		if("Both")
			return EMOTE_VISIBLE | EMOTE_AUDIBLE
		else
			tgui_alert(usr,"Unable to use this emote, must be either hearable or visible.")
			return FALSE

/datum/emote/living/custom/run_emote(mob/user, params, type_override = null, intentional = FALSE)
	var/our_message = params ? params : get_custom_emote_from_user()

	if(!emote_is_valid(user, our_message))
		return FALSE

	if(!params)
		var/user_emote_type = get_custom_emote_type_from_user()

		if(!user_emote_type)
			return FALSE

		type_override = user_emote_type

	. = ..(user = user, params = our_message, type_override = type_override, intentional = intentional)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.show_emote_speech_bubble(viewers(living_user))

/datum/emote/living/custom/replace_pronoun(mob/user, message)
	return message

/datum/emote/living/inhale
	key = "inhale"
	key_third_person = "inhales"
	message = "breathes in."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/exhale
	key = "exhale"
	key_third_person = "exhales"
	message = "breathes out."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/swear
	key = "swear"
	key_third_person = "swears"
	message = "says a swear word!"
	message_mime = "makes a rude gesture!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/whistle
	key = "whistle"
	key_third_person = "whistles"
	message = "whistles."
	message_mime = "whistles silently!"
	vary = TRUE
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/whistle/get_sound(mob/living/user)
	return 'sound/mobs/humanoids/human/whistle/whistle1.ogg'

// HowlingVoid shadekin emote integration.
/datum/emote/living/mar
	key = "mar"
	key_third_person = "mars"
	message = "lets out a mar!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/mobs/humanoids/shadekin/sound_voice_mar.ogg' // Credit to vorestation
