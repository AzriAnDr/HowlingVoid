// LOADOUT ITEM DATUMS FOR BOTH IN-HANDS SLOTS

/datum/loadout_category/inhands
	tab_order = /datum/loadout_category/shoes::tab_order + 1

/datum/loadout_item/inhand/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	// if no hands are available then put in backpack
	if(initial(outfit_important_for_life.r_hand) && initial(outfit_important_for_life.l_hand))
		if(!visuals_only)
			LAZYADD(outfit.backpack_contents, item_path)
		return TRUE

/datum/loadout_item/inhand/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(outfit.l_hand && !outfit.r_hand)
		outfit.r_hand = item_path
	else
		if(outfit.l_hand)
			LAZYADD(outfit.backpack_contents, outfit.l_hand)
		outfit.l_hand = item_path

/*
*	ITEMS BELOW HERE
*/

/datum/loadout_item/inhand/pet
	abstract_type = /datum/loadout_item/inhand/pet

/datum/loadout_item/inhand/pet/post_equip_item(datum/preferences/preference_source, mob/living/carbon/human/equipper)
	var/obj/item/mob_holder/pet/equipped_pet = locate(item_path) in equipper.get_all_gear()
	equipped_pet.held_mob.befriend(equipper)

/*
PLASMAMAN ENVIROSUIT KITS
SPECIES RESTRICTED
*/

/datum/loadout_item/inhand/envirokit_security
	name = "Alternate Envirosuit Kit: Security Officer"
	item_path = /obj/item/storage/box/envirosuit/security
	species_whitelist = list(SPECIES_PLASMAMAN)
	restricted_roles = list(JOB_WARDEN, JOB_DETECTIVE, JOB_SECURITY_MEDIC, JOB_SECURITY_OFFICER, JOB_HEAD_OF_SECURITY, JOB_CORRECTIONS_OFFICER)
	group = "Species-Unique"

/datum/loadout_item/inhand/guncase_large
	name = "Empty Gun Case (Black, Large)"
	item_path = /obj/item/storage/toolbox/guncase/nova
