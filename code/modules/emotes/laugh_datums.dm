GLOBAL_LIST_EMPTY(laugh_types)

/datum/laugh_type
	var/name
	var/list/male_laughsounds
	var/list/female_laughsounds

/datum/laugh_type/none //Why would you want this?
	name = "No Laugh"
	male_laughsounds = null
	female_laughsounds = null

/datum/laugh_type/human
	name = "Human Laugh"
	male_laughsounds = list('sound/mobs/humanoids/human/laugh/manlaugh1.ogg',,
						'sound/mobs/humanoids/human/laugh/manlaugh2.ogg',)
	female_laughsounds = list('sound/emotes/emotes/female/female_giggle_1.ogg',
					'sound/emotes/emotes/female/female_giggle_2.ogg')

/datum/laugh_type/felinid
	name = "Felinid Laugh"
	male_laughsounds = list('sound/emotes/emotes/nyahaha1.ogg',
			'sound/emotes/emotes/nyahaha2.ogg',
			'sound/emotes/emotes/nyaha.ogg',
			'sound/emotes/emotes/nyahehe.ogg')
	female_laughsounds = null

/datum/laugh_type/moth
	name = "Insect Laugh (Moth)"
	male_laughsounds = list('sound/mobs/humanoids/moth/moth_laugh1.ogg')
	female_laughsounds = null

/datum/laugh_type/lizard
	name = "Lizard Laugh"
	male_laughsounds = list('sound/mobs/humanoids/lizard/lizard_laugh1.ogg')
	female_laughsounds = null

/datum/laugh_type/skrell
	name = "Skrell Laugh"
	male_laughsounds = list(
		'sound/emotes/emotes/skrelllaugh1.ogg',
		'sound/emotes/emotes/skrelllaugh2.ogg',
	)
	female_laughsounds = null

/datum/laugh_type/slugcat
	name = "Slugcat Laugh"
	male_laughsounds = list('sound/emotes/voice/scuglaugh_1.ogg')
	female_laughsounds = null
