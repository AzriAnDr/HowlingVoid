
//lava hermit

//Malfunctioning cryostasis sleepers: Spawns in makeshift shelters in lavaland. Ghosts become hermits with knowledge of how they got to where they are now.
/obj/effect/mob_spawn/ghost_role/human/hermit
	name = "malfunctioning cryostasis sleeper"
	desc = "A humming sleeper with a silhouetted occupant inside. Its stasis function is broken and it's likely being used as a bed."
	prompt_name = "a stranded hermit"
	icon = 'icons/obj/mining_zones/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	outfit = /datum/outfit/hermit
	you_are_text = "You've been stranded in this godless prison of a planet for longer than you can remember."
	flavour_text = "Each day you barely scrape by, and between the terrible conditions of your makeshift shelter, \
	the hostile creatures, and the ash drakes swooping down from the cloudless skies, all you can wish for is the feel of soft grass between your toes and \
	the fresh air of Earth. These thoughts are dispelled by yet another recollection of how you got here... "
	spawner_job_path = /datum/job/hermit
	allow_custom_character = ALL

/obj/effect/mob_spawn/ghost_role/human/hermit/Initialize(mapload)
	. = ..()
	outfit = new outfit //who cares equip outfit works with outfit as a path or an instance
	var/arrpee = rand(1,4)
	switch(arrpee)
		if(1)
			flavour_text += "you were a [pick("arms dealer", "shipwright", "docking manager")]'s assistant on a small trading station several sectors from here. Raiders attacked, and there was \
			only one pod left when you got to the escape bay. You took it and launched it alone, and the crowd of terrified faces crowding at the airlock door as your pod's engines burst to \
			life and sent you to this hell are forever branded into your memory."
			outfit.uniform = /obj/item/clothing/under/misc/assistantformal
		if(2)
			flavour_text += "you're an exile from the Tiger Cooperative. Their technological fanaticism drove you to question the power and beliefs of the Exolitics, and they saw you as a \
			heretic and subjected you to hours of horrible torture. You were hours away from execution when a high-ranking friend of yours in the Cooperative managed to secure you a pod, \
			scrambled its destination's coordinates, and launched it. You awoke from stasis when you landed and have been surviving - barely - ever since."
			outfit.uniform = /obj/item/clothing/under/rank/prisoner
			outfit.shoes = /obj/item/clothing/shoes/sneakers/orange
		if(3)
			flavour_text += "you were a doctor on one of Nanotrasen's space stations, but you left behind that damn corporation's tyranny and everything it stood for. From a metaphorical hell \
			to a literal one, you find yourself nonetheless missing the recycled air and warm floors of what you left behind... but you'd still rather be here than there."
			outfit.uniform = /obj/item/clothing/under/rank/medical/doctor
			outfit.suit = /obj/item/clothing/suit/toggle/labcoat
			outfit.back = /obj/item/storage/backpack/medic
		if(4)
			flavour_text += "you were always joked about by your friends for \"not playing with a full deck\", as they so kindly put it. It seems that they were right when you, on a tour \
			at one of Nanotrasen's state-of-the-art research facilities, were in one of the escape pods alone and saw the red button. It was big and shiny, and it caught your eye. You pressed \
			it, and after a terrifying and fast ride for days, you landed here. You've had time to wisen up since then, and you think that your old friends wouldn't be laughing now."

/obj/effect/mob_spawn/ghost_role/human/hermit/Destroy()
	new/obj/structure/fluff/empty_cryostasis_sleeper(get_turf(src))
	return ..()

/datum/outfit/hermit
	name = "Lavaland Hermit"
	uniform = /obj/item/clothing/under/color/grey/ancient
	back = /obj/item/storage/backpack
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/sneakers/black
	l_pocket = /obj/item/tank/internals/emergency_oxygen
	r_pocket = /obj/item/flashlight/glowstick

//Icebox version of hermit
/obj/effect/mob_spawn/ghost_role/human/hermit/icemoon
	name = "cryostasis bed"
	desc = "A humming sleeper with a silhouetted occupant inside. Its stasis function is broken and it's likely being used as a bed."
	prompt_name = "a grumpy old man"
	icon = 'icons/obj/mining_zones/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	outfit = /datum/outfit/hermit
	you_are_text = "You've been hunting polar bears for 40 years now! What do these 'NaniteTrans' newcomers want?"
	flavour_text = "You were fine hunting polar bears and taming wolves out here on your own, \
		but now that there are corporate stooges around, you need to watch your step. "
	spawner_job_path = /datum/job/hermit

//beach dome

/obj/effect/mob_spawn/ghost_role/human/beach
	prompt_name = "a beach bum"
	name = "beach bum sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	you_are_text = "You're, like, totally a dudebro, bruh."
	flavour_text = "Ch'yea. You came here, like, on spring break, hopin' to pick up some bangin' hot chicks, y'knaw?"
	spawner_job_path = /datum/job/beach_bum
	outfit = /datum/outfit/beachbum
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE

/obj/effect/mob_spawn/ghost_role/human/beach/lifeguard
	you_are_text = "You're a spunky lifeguard!"
	flavour_text = "It's up to you to make sure nobody drowns or gets eaten by sharks and stuff."
	name = "lifeguard sleeper"
	outfit = /datum/outfit/beachbum/lifeguard
	allow_custom_character = NONE

/obj/effect/mob_spawn/ghost_role/human/beach/lifeguard/special(mob/living/carbon/human/lifeguard, mob/mob_possessor, apply_prefs)
	. = ..()
	lifeguard.gender = FEMALE
	lifeguard.update_body()

/datum/outfit/beachbum
	name = "Beach Bum"
	id = /obj/item/card/id/advanced
	uniform = /obj/item/clothing/under/pants/jeans
	glasses = /obj/item/clothing/glasses/sunglasses
	l_pocket = /obj/item/food/pizzaslice/dank
	r_pocket = /obj/item/storage/wallet/random

/datum/outfit/beachbum/post_equip(mob/living/carbon/human/bum, visuals_only = FALSE)
	. = ..()
	if(visuals_only)
		return
	bum.dna.add_mutation(/datum/mutation/stoner, MUTATION_SOURCE_GHOST_ROLE)

/datum/outfit/beachbum/lifeguard
	name = "Beach Lifeguard"
	id_trim = /datum/id_trim/lifeguard
	uniform = /obj/item/clothing/under/shorts/red

/obj/effect/mob_spawn/ghost_role/human/bartender
	name = "bartender sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "a space bartender"
	you_are_text = "You are a space bartender!"
	flavour_text = "Time to mix drinks and change lives. Smoking space drugs makes it easier to understand your patrons' odd dialect."
	spawner_job_path = /datum/job/space_bartender
	outfit = /datum/outfit/spacebartender
	allow_custom_character = ALL

/datum/outfit/spacebartender
	name = "Space Bartender"
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/space_bartender
	neck = /obj/item/clothing/neck/bowtie
	uniform = /obj/item/clothing/under/costume/buttondown/slacks/service
	suit = /obj/item/clothing/suit/armor/vest
	back = /obj/item/storage/backpack
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	shoes = /obj/item/clothing/shoes/sneakers/black

/datum/outfit/spacebartender/post_equip(mob/living/carbon/human/bartender, visuals_only = FALSE)
	. = ..()
	var/obj/item/card/id/id_card = bartender.wear_id
	if(bartender.age < AGE_MINOR)
		id_card.registered_age = AGE_MINOR
		to_chat(bartender, span_notice("You're not technically old enough to access or serve alcohol, but your ID has been discreetly modified to display your age as [AGE_MINOR]. Try to keep that a secret!"))

//Preserved terrarium/seed vault: Spawns in seed vault structures in lavaland. Ghosts become plantpeople and are advised to begin growing plants in the room near them.
/obj/effect/mob_spawn/ghost_role/human/seed_vault
	name = "preserved terrarium"
	desc = "An ancient machine that seems to be used for storing plant matter. The glass is obstructed by a mat of vines."
	prompt_name = "lifebringer"
	icon = 'icons/obj/mining_zones/spawners.dmi'
	icon_state = "terrarium"
	density = TRUE
	mob_species = /datum/species/pod
	you_are_text = "You are a sentient ecosystem, an example of the mastery over life that your creators possessed."
	flavour_text = "Your masters, benevolent as they were, created uncounted seed vaults and spread them across \
	the universe to every planet they could chart. You are in one such seed vault. \
	Your goal is to protect the vault you are assigned to, cultivate the seeds passed onto you, \
	and eventually bring life to this desolate planet while waiting for contact from your creators. \
	Estimated time of last contact: Deployment, 5000 millennia ago."
	spawner_job_path = /datum/job/lifebringer

/obj/effect/mob_spawn/ghost_role/human/seed_vault/Initialize(mapload)
	. = ..()
	mob_name = pick("Tomato", "Potato", "Broccoli", "Carrot", "Ambrosia", "Pumpkin", "Ivy", "Kudzu", "Banana", "Moss", "Flower", "Bloom", "Root", "Bark", "Glowshroom", "Petal", "Leaf", \
	"Venus", "Sprout","Cocoa", "Strawberry", "Citrus", "Oak", "Cactus", "Pepper", "Juniper")

/obj/effect/mob_spawn/ghost_role/human/seed_vault/Destroy()
	new/obj/structure/fluff/empty_terrarium(get_turf(src))
	return ..()

//Ash walker eggs: Spawns in ash walker dens in lavaland. Ghosts become unbreathing lizards that worship the Necropolis and are advised to retrieve corpses to create more ash walkers.

/obj/structure/ash_walker_eggshell
	name = "ash walker egg"
	desc = "A man-sized yellow egg, spawned from some unfathomable creature. A humanoid silhouette lurks within. The egg shell looks resistant to temperature but otherwise rather brittle."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | FREEZE_PROOF
	max_integrity = 80
	var/obj/effect/mob_spawn/ghost_role/human/ash_walker/egg

/obj/structure/ash_walker_eggshell/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0) //lifted from xeno eggs
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/blob/attackblob.ogg', 100, TRUE)
			else
				playsound(src, 'sound/items/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			if(damage_amount)
				playsound(loc, 'sound/items/tools/welder.ogg', 100, TRUE)

/obj/structure/ash_walker_eggshell/attack_ghost(mob/user) //Pass on ghost clicks to the mob spawner
	if(egg)
		egg.attack_ghost(user)
	. = ..()

/obj/structure/ash_walker_eggshell/Destroy()
	if(!egg)
		return ..()
	var/mob/living/carbon/human/yolk = new(get_turf(src))
	yolk.set_species(/datum/species/lizard/ashwalker)
	yolk.fully_replace_character_name(null, yolk.generate_random_mob_name(TRUE))
	yolk.underwear = "Nude"
	yolk.equipOutfit(/datum/outfit/ashwalker)//this is an authentic mess we're making
	yolk.update_body()
	yolk.gib(DROP_ALL_REMAINS)
	QDEL_NULL(egg)
	return ..()

/obj/effect/mob_spawn/ghost_role/human/ash_walker
	name = "ash walker egg"
	desc = "A man-sized yellow egg, spawned from some unfathomable creature. A humanoid silhouette lurks within."
	prompt_name = "necropolis ash walker"
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	mob_species = /datum/species/lizard/ashwalker
	outfit = /datum/outfit/ashwalker
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	you_are_text = "You are an ash walker. Your tribe worships the Necropolis."
	flavour_text = "The wastes are sacred ground, its monsters a blessed bounty. \
	You have seen lights in the distance... they foreshadow the arrival of outsiders that seek to tear apart the Necropolis and its domain. \
	Fresh sacrifices for your nest."
	spawner_job_path = /datum/job/ash_walker
	var/datum/team/ashwalkers/team
	var/obj/structure/ash_walker_eggshell/eggshell

/obj/effect/mob_spawn/ghost_role/human/ash_walker/Destroy()
	eggshell = null
	return ..()

/obj/effect/mob_spawn/ghost_role/human/ash_walker/allow_spawn(mob/user, silent = FALSE)
	if(isnull(team))
		return FALSE
	if(!(user.ckey in team.players_spawned))//one per person unless you get a bonus spawn
		return TRUE
	if(!silent)
		to_chat(user, span_warning("You have exhausted your usefulness to the Necropolis."))
	return FALSE

/obj/effect/mob_spawn/ghost_role/human/ash_walker/special(mob/living/carbon/human/spawned_human, mob/mob_possessor, apply_prefs)
	. = ..()
	spawned_human.fully_replace_character_name(null, spawned_human.generate_random_mob_name(TRUE))
	to_chat(spawned_human, "<b>Drag the corpses of men and beasts to your nest. It will absorb them to create more of your kind. Invade the strange structure of the outsiders if you must. Do not cause unnecessary destruction, as littering the wastes with ugly wreckage is certain to not gain you favor. Glory to the Necropolis!</b>")

	spawned_human.mind.add_antag_datum(/datum/antagonist/ashwalker, team)

	spawned_human.remove_language(/datum/language/common)
	team.players_spawned += (spawned_human.ckey)
	eggshell.egg = null
	QDEL_NULL(eggshell)

/obj/effect/mob_spawn/ghost_role/human/ash_walker/Initialize(mapload, datum/team/ashwalkers/ashteam)
	. = ..()
	var/area/spawner_area = get_area(src)
	team = ashteam
	eggshell = new /obj/structure/ash_walker_eggshell(get_turf(loc))
	eggshell.egg = src
	src.forceMove(eggshell)
	if(spawner_area)
		notify_ghosts(
			"An ash walker egg is ready to hatch in \the [spawner_area.name].",
			source = src,
			header = "Ash Walker Egg",
			click_interact = TRUE,
			ignore_key = POLL_IGNORE_ASHWALKER,
			notify_flags = NOTIFY_CATEGORY_NOFLASH,
		)

/datum/outfit/ashwalker
	name = "Ash Walker"
	head = /obj/item/clothing/head/helmet/gladiator
	uniform = /obj/item/clothing/under/costume/gladiator/ash_walker

/datum/outfit/ashwalker/spear
	name = "Ash Walker - Spear"
	back = /obj/item/spear/bonespear

///Syndicate Listening Post

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate
	name = "Syndicate Bioweapon Scientist"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	prompt_name = "a syndicate science technician"
	you_are_text = "You are a syndicate science technician, employed in a top secret research facility developing biological weapons."
	flavour_text = "Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. Continue your research as best you can, and try to keep a low profile."
	important_text = "The base is rigged with explosives, DO NOT abandon it or let it fall into enemy hands!"
	outfit = /datum/outfit/lavaland_syndicate
	spawner_job_path = /datum/job/lavaland_syndicate
	deletes_on_zero_uses_left = FALSE
	allow_custom_character = ALL

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/special(mob/living/new_spawn, mob/mob_possessor, apply_prefs)
	. = ..()
	new_spawn.grant_language(/datum/language/codespeak, source = LANGUAGE_MIND)

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/comms
	name = "Syndicate Comms Agent"
	prompt_name = "a syndicate comms agent"
	you_are_text = "You are a syndicate comms agent, employed in a top secret research facility developing biological weapons."
	flavour_text = "Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. Monitor enemy activity as best you can, and try to keep a low profile. Use the communication equipment to provide support to any field agents, and sow disinformation to throw Nanotrasen off your trail. Do not let the base fall into enemy hands!"
	important_text = "DO NOT abandon the base."
	outfit = /datum/outfit/lavaland_syndicate/comms

/datum/outfit/lavaland_syndicate
	name = "Lavaland Syndicate Agent"
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/toggle/labcoat
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	ears = /obj/item/radio/headset/syndicate/alt
	shoes = /obj/item/clothing/shoes/combat
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	r_hand = /obj/item/gun/ballistic/rifle/sniper_rifle
	belt = /obj/item/storage/belt/utility/full
	glasses = /obj/item/clothing/glasses/welding/up

	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/lavaland_syndicate/post_equip(mob/living/carbon/human/syndicate, visuals_only = FALSE)
	syndicate.add_faction(ROLE_SYNDICATE)

/datum/outfit/lavaland_syndicate/comms
	name = "Lavaland Syndicate Comms Agent"
	suit = /obj/item/clothing/suit/armor/vest
	mask = /obj/item/clothing/mask/chameleon/gps
	r_hand = /obj/item/melee/energy/sword/saber
	belt = /obj/item/storage/belt/utility/full
	glasses = /obj/item/clothing/glasses/welding/up

/datum/outfit/lavaland_syndicate/comms/icemoon
	name = "Icemoon Syndicate Comms Agent"
	mask = /obj/item/clothing/mask/chameleon
	shoes = /obj/item/clothing/shoes/winterboots/ice_boots/eva

/obj/item/clothing/mask/chameleon/gps/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "Encrypted Signal")

///Icemoon Syndicate Comms Agent

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/comms/icemoon
	name = "Icemoon Comms Agent"
	prompt_name = "a syndicate comms agent"
	you_are_text = "You are a syndicate comms agent, assigned in an underground secret listening post close to your enemy's facility."
	flavour_text = "Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. Monitor enemy activity as best you can, and try to keep a low profile. Use the communication equipment to provide support to any field agents, and sow disinformation to throw Nanotrasen off your trail. Do not let the outpost fall into enemy hands!"
	important_text = "Do NOT let the outpost fall into enemy hands"
	outfit = /datum/outfit/lavaland_syndicate/comms/icemoon


// BEGIN NOVA CORE MIGRATION: code/modules/mob_spawn/ghost_roles/mining_roles.dm
/// Lavaland Hermit

/obj/effect/mob_spawn/ghost_role/human/hermit
	quirks_enabled = TRUE // ghost role quirks
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE // ghost role prefs

/// Maintsroom lost

/obj/effect/mob_spawn/ghost_role/human/maintsroom
	name = "chamenos"
	prompt_name = "A being stuck in between two spaces"
	you_are_text = "You wake up. Your hideout is intact with stuff you gathered yesterday, you are safe in your hideout. Maybe you should go explore, be wary of the red lights."
	flavour_text = "You've been stuck in the Maintsrooms for longer than you can remember, and this place has changed you. Is it madness, insanity, or an infection? Or are you an eldritch being, a monster who was born/created/manifested here? Survival will be challenging, and the Maintsrooms are a very hostile environment, so anything surviving here should have a believable reason to."
	important_text = "YOU ARE NOT HOSTILE YOU SHOULD NOT BE KILLING PEOPLE/CREW IN GENERAL, unless you have admin permission or good IC justification to do so."
	loadout_enabled = TRUE
	quirks_enabled = TRUE // ghost role quirks
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE // ghost role prefs
	deletes_on_zero_uses_left = TRUE

/obj/effect/mob_spawn/ghost_role/human/heretic //specifically staying here for nova so the admins can spawn this if they want, tell me to delete this if you dont want this.
	name = "Security Agent"
	prompt_name = "Become a mysterious agent?"
	you_are_text = "You are an agent for a mysterious clandestine group and the facility you worked for recently got evacuated and you were told to not go in and to prevent other people from going in, you know better than to mess with your boss."
	flavour_text = "You are tasked with maintaining the security of the facility and the people still left inside. You are to not let anybody in but to maintain the front of the resort but tell them the beach is closed, but do your best to still service people as if this was a resort."
	important_text = "You can, and should kill people if they try and get past the wooden barricades and security barrier, however if when you catch them theyre already past the security barrier you are to kill yourself instead, if you kill anybody you are to tend their body then make their death look like an accident and then throw them back through the gateway DO NOT RR PEOPLE OR HIDE THEIR BODIES IN ANY CIRCUMSTANCES, do not loot people either even if its their weapon in the heat of combat, go into this ghost role with the mindset that you are an npc."
	loadout_enabled = TRUE
	quirks_enabled = TRUE // ghost role quirks
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE // ghost role prefs
	deletes_on_zero_uses_left = TRUE

/// Beach Dome

/obj/effect/mob_spawn/ghost_role/human/beach
	quirks_enabled = TRUE
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE

/// Space Bar

/obj/effect/mob_spawn/ghost_role/human/bartender
	quirks_enabled = TRUE
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE

/// Preserved Terrarium

/obj/effect/mob_spawn/ghost_role/human/seed_vault
	restricted_species = list(/datum/species/pod)
	quirks_enabled = TRUE
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE

/// Ashwalker Camp

/obj/effect/mob_spawn/ghost_role/human/ash_walker
	restricted_species = list(/datum/species/lizard/ashwalker)
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE

/obj/effect/mob_spawn/ghost_role/human/ash_walker/special(mob/living/carbon/human/spawned_human, mob/mob_possessor, apply_prefs)
	spawned_human.fully_replace_character_name(null, spawned_human.generate_random_mob_name(TRUE))
	quirks_enabled = TRUE // ghost role quirks
	. = ..()

/// Listening Outpost

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/comms/space
	outfit = /datum/outfit/lavaland_syndicate/comms/space
	loadout_enabled = TRUE
	quirks_enabled = TRUE
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE

// OUTFITS

/datum/outfit/lavaland_syndicate/comms
	uniform = /obj/item/clothing/under/rank/security/nova/utility/syndicate
	ears = /obj/item/radio/headset/interdyne/comms

/datum/outfit/lavaland_syndicate/comms/space
	ears = /obj/item/radio/headset/syndicate/alt

/// Interdyne Planetary Base(s)

// SPAWNERS

/obj/effect/mob_spawn/ghost_role/human/interdyne_planetary_base
	name = "Interdyne Scientist"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	prompt_name = "an Interdyne scientist"
	computer_area = /area/ruin/interdyne_planetary_base/main
	you_are_text = "You are a science technician employed in an Interdyne research facility developing biological weapons."
	flavour_text = "Interdyne middle management has relayed that Nanotrasen is actively mining in this sector. A deal with the Syndicate remains. A cargo ferry is docked at the rear of your ship and can be used for trade with both factions. Continue your research as best you can, and try to keep out of trouble."
	outfit = /datum/outfit/interdyne_planetary_base
	spawner_job_path = /datum/job/interdyne_planetary_base
	loadout_enabled = TRUE
	allow_mechanical_loadout_items = TRUE
	quirks_enabled = TRUE
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE

/obj/effect/mob_spawn/ghost_role/human/interdyne_planetary_base/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	spawned_mob.grant_language(/datum/language/codespeak, source = LANGUAGE_SPAWNER)

/obj/effect/mob_spawn/ghost_role/human/interdyne_planetary_base/ice
	outfit = /datum/outfit/interdyne_planetary_base/ice
	computer_area = /area/ruin/interdyne_planetary_base/main/dorms
	flavour_text = "Interdyne middle management has relayed that Nanotrasen is actively mining in this sector. A deal with the Syndicate remains, but their starship has left the system, leaving our quantum pad without a purpose. Continue your research as best you can, and try to keep out of trouble."
	spawner_job_path = /datum/job/interdyne_planetary_base_icebox

/obj/effect/mob_spawn/ghost_role/human/interdyne_planetary_base/shaftminer
	name = "Interdyne Shaft Miner"
	prompt_name = "an Interdyne shaft miner"
	you_are_text = "You are a shaft miner, employed in an Interdyne research facility developing biological weapons."
	outfit = /datum/outfit/interdyne_planetary_base/shaftminer
	spawner_job_path = /datum/job/interdyne_planetary_base/mining

/obj/effect/mob_spawn/ghost_role/human/interdyne_planetary_base/shaftminer/ice
	outfit = /datum/outfit/interdyne_planetary_base/shaftminer/ice
	computer_area = /area/ruin/interdyne_planetary_base/main/dorms
	flavour_text = "Interdyne middle management has relayed that Nanotrasen is actively mining in this sector. A deal with the Syndicate remains, but their starship has left the system, leaving our quantum pad without a purpose. Continue your research as best you can, and try to keep out of trouble."
	spawner_job_path = /datum/job/interdyne_planetary_base_icebox/mining

/obj/effect/mob_spawn/ghost_role/human/interdyne_planetary_base/deck_officer
	name = "Interdyne Deck Officer"
	prompt_name = "an Interdyne deck officer"
	you_are_text = "You are a Deck Officer, employed in an Interdyne research facility developing biological weapons."
	outfit = /datum/outfit/interdyne_planetary_base/shaftminer/deckofficer
	spawner_job_path = /datum/job/interdyne_planetary_base/command

/obj/effect/mob_spawn/ghost_role/human/interdyne_planetary_base/deck_officer/ice
	computer_area = /area/ruin/interdyne_planetary_base/main/dorms
	flavour_text = "Interdyne middle management has relayed that Nanotrasen is actively mining in this sector. A deal with the Syndicate remains, but their starship has left the system, leaving our quantum pad without a purpose. Continue your research as best you can, and try to keep out of trouble."
	spawner_job_path = /datum/job/interdyne_planetary_base_icebox/command





/datum/outfit/lavaland_syndicate/shaftminer/deckofficer
	name = "Interdyne Deck Officer"
	uniform = /obj/item/clothing/under/syndicate/nova/interdyne/deckofficer
	head = /obj/item/clothing/head/hats/syndicate/interdyne_deckofficer_black
	suit = /obj/item/clothing/suit/armor/hos/deckofficer
	ears = /obj/item/radio/headset/interdyne/command
	id = /obj/item/card/id/advanced/silver/generic
	id_trim = /datum/id_trim/syndicom/nova/interdyne/deckofficer

/obj/item/radio/headset/interdyne/green
	name = "interdyne branded headset"
	desc = "A bowman headset in interdyne green, has a small 'IP' written on the earpiece. Protects the ears from flashbangs."
	icon_state = "headset_ip"
	worn_icon_state = "headset_ip"
	icon = 'icons/mapping/obj/headset.dmi'
	worn_icon = 'icons/mob/clothing/ears_additions.dmi'


// OUTFITS

/datum/outfit/interdyne_planetary_base
	name = "Interdyne Scientist"
	id = /obj/item/card/id/advanced/chameleon/elite
	id_trim = /datum/id_trim/syndicom/nova/interdyne
	uniform = /obj/item/clothing/under/syndicate/nova/interdyne
	suit = /obj/item/clothing/suit/toggle/labcoat/nova/interdyne_labcoat/white
	head = /obj/item/clothing/head/beret/medical/nova/interdyne
	back = /obj/item/storage/backpack/interdyne
	backpack_contents = list(
		/obj/item/storage/box/survival/interdyne=1,
		/obj/item/storage/box/nif_ghost_box/ghost_role=1,
		/obj/item/healthanalyzer/simple/disease=1,
	)
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	ears = /obj/item/radio/headset/interdyne/green
	shoes = /obj/item/clothing/shoes/combat
	l_pocket = /obj/item/gun/ballistic/automatic/pistol
	r_hand = /obj/item/storage/toolbox/guncase/nova/carwo_large_case/sindano/evil
	implants = list(/obj/item/implant/weapons_auth)
	var/jobtype = /datum/job/interdyne_planetary_base

/datum/outfit/interdyne_planetary_base/post_equip(mob/living/carbon/human/syndicate, visualsOnly = FALSE)
	syndicate.add_faction(ROLE_INTERDYNE_PLANETARY_BASE)

	var/obj/item/card/id/id_card = syndicate.wear_id
	if(istype(id_card))
		id_card.registered_name = syndicate.real_name
		id_card.update_label()
		id_card.update_icon()

	handlebank(syndicate)
	return ..()

/datum/outfit/interdyne_planetary_base/ice
	uniform = /obj/item/clothing/under/syndicate/nova/interdyne
	suit = /obj/item/clothing/suit/hooded/wintercoat/medical/viro/interdyne
	ears = /obj/item/radio/headset/interdyne/green
	head = /obj/item/clothing/head/beret/medical/nova/interdyne
	backpack_contents = list(
		/obj/item/storage/box/survival/interdyne=1,
		/obj/item/storage/box/nif_ghost_box/ghost_role=1,
		/obj/item/healthanalyzer/simple/disease=1,
		/obj/item/clothing/suit/toggle/labcoat/nova/interdyne_labcoat/white=1,
	)

/datum/outfit/interdyne_planetary_base/shaftminer
	name = "Interdyne Shaft Miner"
	uniform = /obj/item/clothing/under/syndicate/nova/interdyne/miner
	suit = /obj/item/clothing/suit/syndicate/interdyne_jacket
	r_pocket = /obj/item/storage/bag/ore
	id_trim = /datum/id_trim/syndicom/nova/interdyne/shaftminer
	back = /obj/item/storage/backpack/explorer
	skillchips = list(/obj/item/skillchip/job/miner)
	backpack_contents = list(
		/obj/item/storage/box/survival/interdyne=1,
		/obj/item/storage/box/nif_ghost_box/ghost_role=1,
		/obj/item/flashlight/seclite=1,
		/obj/item/knife/combat/survival=1,
		/obj/item/mining_voucher=1,
		/obj/item/t_scanner/adv_mining_scanner/lesser=1,
		/obj/item/gun/energy/recharge/kinetic_accelerator=1,
		/obj/item/stack/marker_beacon/ten=1,\
		/obj/item/card/mining_point_card=1,
	)

/datum/outfit/interdyne_planetary_base/shaftminer/deckofficer
	name = "Interdyne Deck Officer"
	uniform = /obj/item/clothing/under/syndicate/nova/interdyne/deckofficer
	head = /obj/item/clothing/head/hats/syndicate/interdyne_deckofficer_black
	suit = /obj/item/clothing/suit/armor/hos/deckofficer
	ears = /obj/item/radio/headset/interdyne/command
	skillchips = list(/obj/item/skillchip/job/miner)
	id = /obj/item/card/id/advanced/chameleon/elite/black/silver
	id_trim = /datum/id_trim/syndicom/nova/interdyne/deckofficer

/obj/effect/mob_spawn/ghost_role/human/interdyne_planetary_base/deckofficer/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate/captain(get_turf(src))
	return ..()

/datum/outfit/interdyne_planetary_base/shaftminer/ice
	name = "Icemoon Interdyne Shaft Miner"
	uniform = /obj/item/clothing/under/syndicate/nova/interdyne/miner
	suit = /obj/item/clothing/suit/syndicate/interdyne_jacket

// ITEMS

/obj/item/radio/headset/interdyne
	name = "\improper Interdyne headset"
	desc = "A bowman headset with a large red cross on the earpiece, has a small 'IP' written on the top strap. Protects the ears from flashbangs."
	icon_state = "syndie_headset"
	inhand_icon_state = null
	radio_talk_sound = 'sound/radiosound/radio/syndie.ogg'
	keyslot = new /obj/item/encryptionkey/headset_syndicate/interdyne

/obj/item/radio/headset/interdyne/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

/obj/item/radio/headset/interdyne/command
	name = "\improper Interdyne command headset"
	desc = "A commanding headset to gather your underlings. Protects the ears from flashbangs. It has a large red cross on the earpiece, and a small 'IP' written on the top strap. Protects the ears from flashbangs."
	command = TRUE

/obj/item/radio/headset/interdyne/comms
	keyslot = /obj/item/encryptionkey/headset_syndicate/interdyne

// STRUCTURES

/obj/structure/closet/crate/freezer/sansufentanyl
	name = "sansufentanyl crate"
	desc = "A freezer. Contains refrigerated Sansufentanyl, for managing Hereditary Manifold Sickness. A product of Interdyne Pharmaceuticals."

/obj/structure/closet/crate/freezer/sansufentanyl/PopulateContents()
	. = ..()
	for(var/grabbin_pills in 1 to 10)
		new /obj/item/storage/pill_bottle/sansufentanyl(src)

/obj/structure/closet/l3closet/interdyne
	name = "Interdyne level 3 biohazard gear closet"

/obj/structure/closet/l3closet/interdyne/PopulateContents()
	new /obj/item/storage/bag/bio(src)
	new /obj/item/clothing/suit/bio_suit/interdyne(src)
	new /obj/item/clothing/head/bio_hood/interdyne(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/oxygen(src)
	new /obj/item/reagent_containers/syringe/antiviral(src)
// END NOVA CORE MIGRATION: code/modules/mob_spawn/ghost_roles/mining_roles.dm
