/datum/emote/living/carbon/meow1
	key = "meow1"
	key_third_person = "meows!"
	message = "meows in a different tone!"
	sound = 'sound/mobs/non-humanoids/cat/cat_meow_vibe.ogg'
	vary = TRUE
	message_mime = "meows silently."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/carbon/meow1/can_run_emote(mob/living/carbon/user, status_check = TRUE , intentional, params)
	if(!iscarbon(user) || (!istype(user.get_organ_slot(ORGAN_SLOT_TONGUE), /obj/item/organ/tongue/cat)))
		return FALSE
	return ..()
