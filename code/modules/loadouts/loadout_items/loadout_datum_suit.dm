// LOADOUT ITEM DATUMS FOR THE SUIT SLOT
/datum/loadout_item/suit/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE) // don't bother storing in backpack, can't fit
	if(initial(outfit_important_for_life.suit))
		return TRUE

/datum/loadout_item/suit/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.suit)
			LAZYADD(outfit.backpack_contents, outfit.suit)
		outfit.suit = item_path
	else
		outfit.suit = item_path

/*
*	ITEMS BELOW HERE
*/

/datum/loadout_item/suit/frontierjacket
	abstract_type = /datum/loadout_item/suit/frontierjacket

/datum/loadout_item/suit/hoodie
	abstract_type = /datum/loadout_item/suit/hoodie

/datum/loadout_item/suit/overall
	name = "Overalls (Recolorable)" // can't have both job palettes and player coloring, so we prefer player colors
	loadout_flags = LOADOUT_FLAG_ALLOW_NAMING
	group = "Workwear"

/datum/loadout_item/suit/tailcoatengi
	name = "Engineer's Tailcoat"
	item_path = /obj/item/clothing/suit/jacket/tailcoat/engineer
	restricted_roles = list(ALL_JOBS_ENGI)
	group = "Job-Locked"

/datum/loadout_item/suit/tailcoatengiatmos
	name = "Atmos Tech's Tailcoat"
	item_path = /obj/item/clothing/suit/utility/fire/atmos_tech_tailcoat
	restricted_roles = list(ALL_JOBS_ENGI)
	group = "Job-Locked"

//MED
/datum/loadout_item/suit/british_jacket
	name = "Security British Coat"
	item_path = /obj/item/clothing/suit/british_officer
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/suit/navybluejacketofficer
	name = "Security Formal Jacket (Navy Blue)"
	item_path = /obj/item/clothing/suit/jacket/officer/blue
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/suit/brit
	name = "Security High Vis Armored Vest"
	item_path = /obj/item/clothing/suit/armor/vest/brit
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/suit/vested_jacket
	name = "Vested Security Jacket"
	item_path = /obj/item/clothing/suit/armor/vest/vested_jacket
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/suit/security_medic_armor
	name = "Security Medic Armor Vest"
	item_path = /obj/item/clothing/suit/armor/vest/security_medic
	restricted_roles = list(JOB_SECURITY_MEDIC)
	group = "Job-Locked"

/datum/loadout_item/suit/security_medic_labcoat
	name = "Security Medic Labcoat"
	item_path = /obj/item/clothing/suit/toggle/labcoat/security_medic
	restricted_roles = list(JOB_SECURITY_MEDIC)
	group = "Job-Locked"

/datum/loadout_item/suit/security_medic_labcoat/blue
	name = "Security Medic Labcoat (Blue)"
	item_path = /obj/item/clothing/suit/toggle/labcoat/security_medic/blue

/datum/loadout_item/suit/security_medic_vest
	name = "Security Medic Vest"
	item_path = /obj/item/clothing/suit/hazardvest/security_medic
	restricted_roles = list(JOB_SECURITY_MEDIC)
	group = "Job-Locked"

/datum/loadout_item/suit/security_medic_vest/blue
	name = "Security Medic Vest (Blue)"
	item_path = /obj/item/clothing/suit/hazardvest/security_medic/blue

/datum/loadout_item/suit/security_wintercoat
	name = "Security Winter Jacket"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/security
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/suit/security_wintercoat_blue
	name = "Security Winter Coat (Blue)"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/security/blue
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/suit/security_jacket
	name = "Security Work Jacket"
	item_path = /obj/item/clothing/suit/toggle/jacket/nova/colorable_bomber/sec
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/suit/tailcoatsec
	name = "Security's Tailcoat"
	item_path = /obj/item/clothing/suit/armor/security_tailcoat
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/suit/tailcoatsecdept
	name = "Security's Deputy Tailcoat"
	item_path = /obj/item/clothing/suit/armor/security_tailcoat/assistant
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/suit/tailcoatsecmedic
	name = "Security's Medicated Tailcoat"
	item_path = /obj/item/clothing/suit/toggle/labcoat/nova/security_medic/doctor_tailcoat
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

//Detective
/datum/loadout_item/suit/donator
	abstract_type = /datum/loadout_item/suit/donator
	donator_only = TRUE

/datum/loadout_item/suit/donator/digicoat
	abstract_type = /datum/loadout_item/suit/donator/digicoat

/datum/loadout_item/suit/winter_coat
	name = "Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat

/datum/loadout_item/suit/winter_coat/christmas
	name = "Winter Coat - Christmas"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/nova/christmas

/datum/loadout_item/suit/frontierjacket/short
	name = "Frontier Jacket (Short)"
	item_path = /obj/item/clothing/suit/jacket/frontier_colonist/short

/datum/loadout_item/suit/leather_jacket
	name = "Leather Jacket"
	item_path = /obj/item/clothing/suit/jacket/leather
