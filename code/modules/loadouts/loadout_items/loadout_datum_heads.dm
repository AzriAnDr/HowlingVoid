// LOADOUT ITEM DATUMS FOR THE HEAD SLOT

/datum/loadout_item/head/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(initial(outfit_important_for_life.head))
		.. ()
		return TRUE

/datum/loadout_item/head/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.head)
			LAZYADD(outfit.backpack_contents, outfit.head)
		outfit.head = item_path
	else
		outfit.head = item_path

/*
*	ITEMS BELOW HERE
*/

/datum/loadout_item/head/black_beanie
	name = "Beanie (Black)"
	item_path = /obj/item/clothing/head/beanie/black
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/head/dark_blue_beanie
	name = "Beanie (Dark Blue)"
	item_path = /obj/item/clothing/head/beanie/darkblue
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/head/orange_beanie
	name = "Beanie (Orange)"
	item_path = /obj/item/clothing/head/beanie/orange
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/head/red_beanie
	name = "Beanie (Red)"
	item_path = /obj/item/clothing/head/beanie/red
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/head/yellow_beanie
	name = "Beanie (Yellow)"
	item_path = /obj/item/clothing/head/beanie/yellow
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/datum/loadout_item/head/christmas_beanie
	name = "Beanie - Christmas"
	item_path = /obj/item/clothing/head/beanie/christmas
	loadout_flags = parent_type::loadout_flags | LOADOUT_FLAG_BLOCK_GREYSCALING

/*
*	BERETS
*/

/datum/loadout_item/head/delinquent_cap
	name = "Cap - Delinquent"

/datum/loadout_item/head/mail_cap
	name = "Cap - Mail"

/datum/loadout_item/head/flatcap
	name = "Cap - Flat"

/datum/loadout_item/head/tarkon
	name = "Tarkon Welder"
	item_path = /obj/item/clothing/head/utility/welding/hat
	blacklisted_roles = list(ALL_JOBS_SEC, ALL_JOBS_COM, JOB_PRISONER)
	group = "Job-Locked"

/datum/loadout_item/head/geranium
	name = "Flower - Geranium"
	group = "Miscellaneous"

/datum/loadout_item/head/harebell
	name = "Flower - Harebell"
	group = "Miscellaneous"

/datum/loadout_item/head/lily
	name = "Flower - Lily"
	group = "Miscellaneous"

/datum/loadout_item/head/poppy
	name = "Flower - Poppy"
	group = "Miscellaneous"

/datum/loadout_item/head/rose
	name = "Flower - Rose"
	group = "Miscellaneous"

/datum/loadout_item/head/sunflower
	name = "Flower - Sunflower"
	group = "Miscellaneous"

/datum/loadout_item/head/rastafarian
	group = "Costumes"

/datum/loadout_item/head/kitty_ears
	group = "Costumes"

/datum/loadout_item/head/rabbit_ears
	group = "Costumes"

/datum/loadout_item/head/bear_pelt
	name = "Pelt - Bear (Space)"
	group = "Costumes"

/datum/loadout_item/head/maidhead
	name = "Maid Headband - Simple"
	item_path = /obj/item/clothing/head/costume/nova/maid
	group = "Costumes"

/datum/loadout_item/head/maidhead/get_item_information()
	. = ..()
	.[FA_ICON_HAT_COWBOY] = "Top of Head"

/datum/loadout_item/head/maidhead2
	name = "Maid Headband - Frilly"
	item_path = /obj/item/clothing/head/costume/maid_headband
	group = "Costumes"

/datum/loadout_item/head/maidhead2/get_item_information()
	. = ..()
	.[FA_ICON_EAR_DEAF] = "Behind Ears"

//Chaplain
/datum/loadout_item/head/officerberet
	name = "Security Beret"
	item_path = /obj/item/clothing/head/beret/sec/nova
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/head/navyblueofficerberet
	name = "Security Beret (Navy Blue)"
	item_path = /obj/item/clothing/head/beret/sec/navyofficer
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/head/officercap
	name = "Security Cap"
	item_path = /obj/item/clothing/head/security_cap
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/head/officergarrisoncap
	name = "Security Cap - Garrison"
	item_path = /obj/item/clothing/head/security_garrison
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/head/officerpatrolcap
	name = "Security Cap - Patrol"
	item_path = /obj/item/clothing/head/hats/warden/police/patrol
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/head/cowboyhat_sec
	name = "Security Cattleman Hat"
	item_path = /obj/item/clothing/head/cowboy/nova/cattleman/sec
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/head/cowboyhat_secwide
	name = "Security Cattleman Hat - Wide-Brimmed"
	item_path = /obj/item/clothing/head/cowboy/nova/cattleman/wide/sec
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/head/ushanka/sec
	name = "Security Ushanka"
	item_path = /obj/item/clothing/head/costume/ushanka/sec
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/head/security_medic_beret
	name = "Security Medic Beret"
	item_path = /obj/item/clothing/head/beret/sec/security_medic
	restricted_roles = list(JOB_SECURITY_MEDIC)
	group = "Job-Locked"

/datum/loadout_item/head/security_medic_helmet
	name = "Security Medic Helmet"
	item_path = /obj/item/clothing/head/helmet/sec/security_medic
	restricted_roles = list(JOB_SECURITY_MEDIC)
	group = "Job-Locked"

/datum/loadout_item/head/cybergoggles //Cyberpunk-P.I. Outfit
	name = "Detective's Type-34P Forensics Headwear"
	item_path = /obj/item/clothing/head/fedora/det_hat/cybergoggles
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/head/rabbitplaybunnysecdept
	name = "Less Secure Bunny Ears"
	item_path = /obj/item/clothing/head/playbunnyears/security/assistant
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Costumes"

/datum/loadout_item/head/rabbitplaybunnysec
	name = "Secure Bunny Ears"
	item_path = /obj/item/clothing/head/playbunnyears/security
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Costumes"

/datum/loadout_item/head/rabbitplaybunnysecmed
	name = "Secure Medical Bunny Ears"
	item_path = /obj/item/clothing/head/playbunnyears/brig_phys
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Costumes"

/datum/loadout_item/head/donator
	abstract_type = /datum/loadout_item/head/donator
	donator_only = TRUE

/datum/loadout_item/head/donator/rainbow_bunch
	name = "Flower - Rainbow Bunch"
	item_path = /obj/item/food/grown/rainbow_flower
	group = "Miscellaneous"

/datum/loadout_item/head/donator/rainbow_bunch/get_item_information()
	. = ..()
	.[FA_ICON_DICE] = TOOLTIP_RANDOM_COLOR

/datum/loadout_item/head/frontiercap
	name = "Cap - Frontier"
	item_path = /obj/item/clothing/head/soft/frontier_colonist

/datum/loadout_item/head/rabbit
	name = "Playbunny Ears"
	item_path = /obj/item/clothing/head/playbunnyears
	group = "Costumes"
