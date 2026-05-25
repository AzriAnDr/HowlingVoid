/datum/emote/living/carbon/human
	mob_type_allowed_typecache = list(/mob/living/carbon/human)

/datum/emote/living/carbon/human/dap
	key = "dap"
	key_third_person = "daps"
	message = "sadly can't find anybody to give daps to, and daps themself. Shameful."
	message_param = "gives daps to %t."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	message = "raises an eyebrow."

/datum/emote/living/carbon/human/glasses
	key = "glasses"
	key_third_person = "glasses"
	message = "pushes up their glasses."
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/glasses/can_run_emote(mob/user, status_check = TRUE, intentional, params)
	var/obj/eyes_slot = user.get_item_by_slot(ITEM_SLOT_EYES)
	if(istype(eyes_slot, /obj/item/clothing/glasses/regular) || istype(eyes_slot, /obj/item/clothing/glasses/sunglasses))
		return ..()
	return FALSE

/datum/emote/living/carbon/human/glasses/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/image/emote_animation = image('icons/mob/human/emote_visuals.dmi', user, "glasses")
	flick_overlay_global(emote_animation, GLOB.clients, 1.6 SECONDS)

/datum/emote/living/carbon/human/grumble
	key = "grumble"
	key_third_person = "grumbles"
	message = "grumbles!"
	message_mime = "grumbles silently!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/handshake
	key = "handshake"
	message = "shakes their own hands."
	message_param = "shakes hands with %t."
	hands_use_check = TRUE
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/hug
	key = "hug"
	key_third_person = "hugs"
	message = "hugs themself."
	message_param = "hugs %t."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/mumble
	key = "mumble"
	key_third_person = "mumbles"
	message = "mumbles!"
	message_mime = "mumbles silently!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/screech // basically scream 2.0
	key = "screech"
	key_third_person = "screeches"
	message = "screeches!"
	message_mime = "screeches silently."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	specific_emote_audio_cooldown = 10 SECONDS
	vary = FALSE

/datum/emote/living/carbon/human/screech/get_sound(mob/living/carbon/human/user)
	var/scream_sound = get_selected_scream_sound(user)
	if(scream_sound)
		return scream_sound
	scream_sound = user.dna?.species?.get_scream_sound(user)
	if(scream_sound)
		return scream_sound
	return get_default_scream_sound(user)

/datum/emote/living/scream/get_sound_variants(mob/living/user)
	return list(
		"male 1" = 'sound/mobs/humanoids/human/scream/malescream_1.ogg',
		"male 2" = 'sound/mobs/humanoids/human/scream/malescream_2.ogg',
		"male 3" = 'sound/mobs/humanoids/human/scream/malescream_3.ogg',
		"male 4" = 'sound/mobs/humanoids/human/scream/malescream_4.ogg',
		"male 5" = 'sound/mobs/humanoids/human/scream/malescream_5.ogg',
		"male 6" = 'sound/mobs/humanoids/human/scream/malescream_6.ogg',
		"female 1" = 'sound/mobs/humanoids/human/scream/femalescream_1.ogg',
		"female 2" = 'sound/mobs/humanoids/human/scream/femalescream_2.ogg',
		"female 3" = 'sound/mobs/humanoids/human/scream/femalescream_3.ogg',
		"female 4" = 'sound/mobs/humanoids/human/scream/femalescream_4.ogg',
		"female 5" = 'sound/mobs/humanoids/human/scream/femalescream_5.ogg',
	)

/datum/emote/living/carbon/human/pale
	key = "pale"
	message = "goes pale for a second."

/datum/emote/living/carbon/human/raise
	key = "raise"
	key_third_person = "raises"
	message = "raises a hand."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/salute
	key = "salute"
	key_third_person = "salutes"
	message = "salutes."
	message_param = "salutes to %t."
	hands_use_check = TRUE
	sound = 'sound/mobs/humanoids/human/salute/salute.ogg'

/datum/emote/living/carbon/human/slit
	key = "slit"
	key_third_person = "slits"
	message = "drags a finger across their neck."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/scratch_h
	key = "scratch_h"
	message = "scratches their head."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/thumb_up
	key = "thumb_u"
	message = "gives a thumbs up."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/thumb_down
	key = "thumb_d"
	message = "gives a thumbs down."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/time
	key = "time"
	message = "checks the time."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/tap
	key = "tap"
	key_third_person = "taps"
	message = "taps their foot impatiently."

/datum/emote/living/carbon/human/halt
	key = "halt"
	key_third_person = "halts"
	message = "holds up their palm, signaling to stop."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/shush
	key = "shush"
	key_third_person = "shushes"
	message = "holds a finger to their lips."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/listen
	key = "listen"
	key_third_person = "listens"
	message = "cups a hand to their ear."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/think
	key = "think"
	key_third_person = "thinks"
	message = "taps their head, thinking."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/beckon
	key = "beckon"
	key_third_person = "beckons"
	message = "waves a hand for someone to come closer."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/airquote
	key = "airquote"
	key_third_person = "airquotes"
	message = "makes air quotes."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/crazy
	key = "crazy"
	message = "twirls a finger next to their head."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/squint
	key = "squint"
	key_third_person = "squints"
	message = "squints."

/datum/emote/living/carbon/human/rub
	key = "rub"
	key_third_person = "rubs"
	message = "rubs their chin."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/shrug
	key = "shrug"
	key_third_person = "shrugs"
	message = "shrugs."

/datum/emote/living/carbon/human/wag
	key = "wag"
	key_third_person = "wags"
	message = "their tail."

/datum/emote/living/carbon/human/wag/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/obj/item/organ/tail/oranges_accessory = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	//I am so sorry my son
	//We bypass helpers here cause we already have the tail
	if(oranges_accessory.wag_flags & WAG_WAGGING) //We verified the tail exists in can_run_emote()
		oranges_accessory.stop_wag(user)
	else
		oranges_accessory.start_wag(user)

/datum/emote/living/carbon/human/wag/select_message_type(mob/user, intentional)
	. = ..()
	var/obj/item/organ/tail/oranges_accessory = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(oranges_accessory.wag_flags & WAG_WAGGING)
		. = "stops wagging " + message
	else
		. = "wags " + message

/datum/emote/living/carbon/human/wag/can_run_emote(mob/user, status_check, intentional, params)
	var/obj/item/organ/tail/tail = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(tail?.wag_flags & WAG_ABLE)
		return ..()
	return FALSE

/datum/emote/living/carbon/human/wing
	key = "wing"
	key_third_person = "wings"
	message = "their wings."

/datum/emote/living/carbon/human/wing/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/obj/item/organ/wings/functional/wings = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	if(isnull(wings))
		CRASH("[type] ran on a mob that has no wings!")
	if(wings.wings_open)
		wings.close_wings()
	else
		wings.open_wings()

/datum/emote/living/carbon/human/wing/select_message_type(mob/user, intentional)
	var/obj/item/organ/wings/functional/wings = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	var/emote_verb = wings.wings_open ? "closes" : "opens"
	return "[emote_verb] [message]"

/datum/emote/living/carbon/human/wing/can_run_emote(mob/user, status_check = TRUE, intentional, params)
	if(!istype(user.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS), /obj/item/organ/wings/functional))
		return FALSE
	return ..()

/datum/emote/living/carbon/human/clear_throat
	key = "clear"
	key_third_person = "clears throat"
	message = "clears their throat."

/datum/emote/living/carbon/human/blink
	key = "blink"
	key_third_person = "blinks"
	message = "blinks."

/datum/emote/living/carbon/human/blink/can_run_emote(mob/living/carbon/human/user, status_check, intentional, params)
	if (!ishuman(user) || HAS_TRAIT(user, TRAIT_PREVENT_BLINKING) || HAS_TRAIT(user, TRAIT_NO_EYELIDS))
		return FALSE
	var/obj/item/organ/eyes/eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	if (!eyes)
		return FALSE
	return ..()

/datum/emote/living/carbon/human/blink/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	. = ..()
	var/obj/item/organ/eyes/eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	eyes.blink()

/datum/emote/living/carbon/human/blink_r
	key = "blink_r"
	name = "blink (Rapid)"
	message = "blinks rapidly."

/datum/emote/living/carbon/human/blink_r/can_run_emote(mob/living/carbon/human/user, status_check, intentional, params)
	if (!ishuman(user) || HAS_TRAIT(user, TRAIT_PREVENT_BLINKING) || HAS_TRAIT(user, TRAIT_NO_EYELIDS))
		return FALSE
	var/obj/item/organ/eyes/eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	if (!eyes)
		return FALSE
	return ..()

/datum/emote/living/carbon/human/blink_r/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/obj/item/organ/eyes/eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	for (var/i in 1 to 3)
		addtimer(CALLBACK(eyes, TYPE_PROC_REF(/obj/item/organ/eyes, blink), 0.1 SECONDS, FALSE), i * 0.2 SECONDS)
	eyes.animate_eyelids(user)

///Snowflake emotes only for le epic chimp
/datum/emote/living/carbon/human/monkey

/datum/emote/living/carbon/human/monkey/can_run_emote(mob/user, status_check = TRUE, intentional, params)
	if(ismonkey(user))
		return ..()
	return FALSE

/datum/emote/living/carbon/human/monkey/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "gnarls and shows its teeth..."
	message_mime = "gnarls silently, baring its teeth..."

/datum/emote/living/carbon/human/monkey/roll
	key = "roll"
	key_third_person = "rolls"
	message = "rolls."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/monkey/scratch
	key = "scratch"
	key_third_person = "scratches"
	message = "scratches."
	hands_use_check = TRUE

/datum/emote/living/carbon/human/monkey/screech/roar
	key = "roar"
	key_third_person = "roars"
	message = "roars!"
	message_mime = "acts out a roar."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/monkey/tail
	key = "tail"
	message = "waves their tail."

/datum/emote/living/carbon/human/monkey/sign
	key = "sign"
	key_third_person = "signs"
	message_param = "signs the number %t."
	hands_use_check = TRUE

/// emotes for glowy goobers
/datum/emote/living/carbon/human/glow
	key = "glow"
	key_third_person = "glows"
	message = "glows brightly!"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/glow/can_run_emote(mob/living/carbon/human/user, status_check = TRUE , intentional, params)
	if(!isethereal(user))
		return FALSE
	return ..()

/datum/emote/living/carbon/human/glow/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	. = ..()
	var/datum/species/ethereal/goober = user.dna.species
	goober.handle_glow_emote(user, 1.75, 1.2)

/datum/emote/living/carbon/human/flare
	key = "flare"
	key_third_person = "flares"
	message = "flares up to a dazzling intensity!"
	emote_type = EMOTE_VISIBLE
	sound = "sound/mobs/humanoids/ethereal/ethereal_hiss.ogg"

/datum/emote/living/carbon/human/flare/can_run_emote(mob/living/carbon/human/user, status_check = TRUE , intentional, params)
	if(!isethereal(user))
		return FALSE
	return ..()

/datum/emote/living/carbon/human/flare/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	. = ..()
	var/datum/species/ethereal/goober = user.dna.species
	goober.handle_glow_emote(user, 12, 6, flare = TRUE, duration = 2 SECONDS, flare_time = 10 SECONDS)

/datum/emote/living/carbon/human/flicker
	key = "flicker"
	key_third_person = "flicker"
	message = "flickers."
	emote_type = EMOTE_VISIBLE
	sound = "sound/effects/sparks/sparks4.ogg"

/datum/emote/living/carbon/human/flicker/can_run_emote(mob/living/carbon/human/user, status_check = TRUE , intentional, params)
	if(!isethereal(user))
		return FALSE
	return ..()

/datum/emote/living/carbon/human/flicker/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	. = ..()
	var/datum/species/ethereal/goober = user.dna.species
	goober.start_flicker(user)

// === XENO EMOTES (for roleplay purposes) ===

/datum/emote/living/carbon/human/alien_hiss_1
	name = "Xeno Hiss 1"
	key = "ahiss1"
	key_third_person = "ahiss1"
	message = "hisses!"
	sound = 'sound/mobs/xenomorphs/talk1.ogg'
	cooldown = 3 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/alien_hiss_2
	name = "Xeno Hiss 2"
	key = "ahiss2"
	key_third_person = "ahiss2"
	message = "hisses gutturally..."
	cooldown = 3 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/alien_hiss_2/get_sound(mob/living/user)
	return pick(
		'sound/mobs/xenomorphs/talk2.ogg',
		'sound/mobs/xenomorphs/talk3.ogg',
		'sound/mobs/xenomorphs/talk4.ogg',
	)

/datum/emote/living/carbon/human/alien_hiss_3
	name = "Xeno Hiss 3"
	key = "ahiss3"
	key_third_person = "ahiss3"
	message = "hisses aggressively!"
	sound = 'sound/mobs/xenomorphs/talk5.ogg'
	cooldown = 3 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/alien_hiss_4
	name = "Xeno Hiss 4"
	key = "ahiss4"
	key_third_person = "ahiss4"
	message = "exhales with a hiss..."
	cooldown = 3 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/alien_hiss_4/get_sound(mob/living/user)
	return pick(
		'sound/mobs/xenomorphs/lowHiss1.ogg',
		'sound/mobs/xenomorphs/lowHiss2.ogg',
		'sound/mobs/xenomorphs/lowHiss3.ogg',
		'sound/mobs/xenomorphs/lowHiss4.ogg',
	)

/datum/emote/living/carbon/human/alien_scream_1
	name = "Xeno Scream 1"
	key = "ascream1"
	key_third_person = "ascream1"
	message = "shrieks aggressively!"
	cooldown = 3 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/alien_scream_1/get_sound(mob/living/user)
	return pick(
		'sound/mobs/xenomorphs/screech1.ogg',
		'sound/mobs/xenomorphs/screech2.ogg',
		'sound/mobs/xenomorphs/screech3.ogg',
		'sound/mobs/xenomorphs/screech4.ogg',
	)

/datum/emote/living/carbon/human/alien_scream_2
	name = "Xeno Scream 2"
	key = "ascream2"
	key_third_person = "ascream2"
	message = "lets out an aggressive roar!"
	cooldown = 2 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/alien_scream_2/get_sound(mob/living/user)
	return pick(
		'sound/mobs/xenomorphs/alien_roar1.ogg',
		'sound/mobs/xenomorphs/alien_roar2.ogg',
	)

/datum/emote/living/carbon/human/alien_scream_pain
	name = "Xeno Pain Scream"
	key = "apscream"
	key_third_person = "apscream"
	message = "screams in pain!"
	cooldown = 3 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/alien_scream_pain/get_sound(mob/living/user)
	return pick(
		'sound/mobs/xenomorphs/hurt1.ogg',
		'sound/mobs/xenomorphs/hurt2.ogg',
	)

/datum/emote/living/carbon/human/alien_sigh
	name = "Xeno Sigh"
	key = "asigh"
	key_third_person = "asigh"
	message = "exhales in irritation!"
	sound = 'sound/mobs/xenomorphs/gnarl1.ogg'
	cooldown = 3 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/alien_growl_1
	name = "Xeno Growl 1"
	key = "agrowl1"
	key_third_person = "agrowl1"
	message = "snaps their teeth aggressively!"
	sound = 'sound/mobs/xenomorphs/growl1.ogg'
	cooldown = 6 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/alien_growl_2
	name = "Xeno Growl 2"
	key = "agrowl2"
	key_third_person = "agrowl2"
	message = "growls with displeasure."
	cooldown = 3 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/alien_growl_2/get_sound(mob/living/user)
	return pick(
		'sound/mobs/xenomorphs/growl2.ogg',
		'sound/mobs/xenomorphs/growl9.ogg',
		'sound/mobs/xenomorphs/growl10.ogg',
	)

/datum/emote/living/carbon/human/alien_growl_3
	name = "Xeno Growl 3"
	key = "agrowl3"
	key_third_person = "agrowl3"
	message = "growls aggressively!"
	cooldown = 6 SECONDS
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/alien_growl_3/get_sound(mob/living/user)
	return pick(
		'sound/mobs/xenomorphs/growl3.ogg',
		'sound/mobs/xenomorphs/growl4.ogg',
		'sound/mobs/xenomorphs/growl5.ogg',
		'sound/mobs/xenomorphs/growl6.ogg',
		'sound/mobs/xenomorphs/growl7.ogg',
		'sound/mobs/xenomorphs/growl8.ogg',
	)

// === SYNTH EMOTES ===

/datum/emote/living/carbon/human/synth_scary
	key = "scary"
	key_third_person = "plays a scary sound"
	message = "plays a scary sound!"
	message_mime = "plays a scary sound silently!"
	sound = 'sound/voice/synth/synth_scary.ogg'
	cooldown = 2 SECONDS
	emote_type = EMOTE_AUDIBLE
	mob_type_allowed_typecache = /mob/living/carbon/human
