/datum/species/synthetic/get_scream_sound(mob/living/carbon/human/synthetic)
	return 'sound/emotes/voice/scream_silicon.ogg'

/datum/species/android/get_scream_sound(mob/living/carbon/human/android)
	return 'sound/emotes/voice/scream_silicon.ogg'

/datum/species/lizard/get_scream_sound(mob/living/carbon/human/lizard)
	return pick(
		'sound/emotes/voice/scream_lizard.ogg',
		'sound/mobs/humanoids/lizard/lizard_scream_1.ogg',
		'sound/mobs/humanoids/lizard/lizard_scream_2.ogg',
		'sound/mobs/humanoids/lizard/lizard_scream_3.ogg',
	)

/datum/species/skeleton/get_scream_sound(mob/living/carbon/human/skeleton)
	return 'sound/emotes/voice/scream_skeleton.ogg'

/datum/species/fly/get_scream_sound(mob/living/carbon/human/fly)
	return 'sound/mobs/humanoids/moth/scream_moth.ogg'

/datum/species/moth/get_scream_sound(mob/living/carbon/human/moth)
	return 'sound/mobs/humanoids/moth/scream_moth.ogg'

/datum/species/insect/get_scream_sound(mob/living/carbon/human/insect)
	return 'sound/mobs/humanoids/moth/scream_moth.ogg'

/datum/species/jelly/get_scream_sound(mob/living/carbon/human/jelly)
	return 'sound/emotes/emotes/jelly_scream.ogg'

/datum/species/vox/get_scream_sound(mob/living/carbon/human/vox)
	return 'sound/emotes/emotes/voxscream.ogg'

/datum/species/vox_primalis/get_scream_sound(mob/living/carbon/human/vox_primalis)
	return 'sound/emotes/emotes/voxscream.ogg'

/datum/species/xeno/get_scream_sound(mob/living/carbon/human/xeno)
	return 'sound/mobs/non-humanoids/hiss/hiss6.ogg'

/datum/species/zombie/get_scream_sound(mob/living/carbon/human/teshari)
	return 'sound/emotes/emotes/zombie_scream.ogg'

/datum/species/teshari/get_scream_sound(mob/living/carbon/human/teshari)
	return 'sound/emotes/emotes/raptorscream.ogg'
