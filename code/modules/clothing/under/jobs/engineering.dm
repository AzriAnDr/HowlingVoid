//Contains: Engineering department jumpsuits

/obj/item/clothing/under/rank/engineering
	icon = 'icons/obj/clothing/under/engineering.dmi'
	worn_icon = 'icons/mob/clothing/under/engineering.dmi'
	abstract_type = /obj/item/clothing/under/rank/engineering
	armor_type = /datum/armor/clothing_under/rank_engineering
	resistance_flags = NONE

/datum/armor/clothing_under/rank_engineering
	fire = 60
	acid = 20

/obj/item/clothing/under/rank/engineering/chief_engineer
	desc = "It's a high visibility jumpsuit given to those engineers insane enough to achieve the rank of \"Chief Engineer\". Made from fire resistant materials."
	name = "chief engineer's jumpsuit"
	icon_state = "chiefengineer"
	inhand_icon_state = "gy_suit"
	armor_type = /datum/armor/clothing_under/engineering_chief_engineer

/datum/armor/clothing_under/engineering_chief_engineer
	fire = 80
	acid = 40

/obj/item/clothing/under/rank/engineering/chief_engineer/skirt
	name = "chief engineer's jumpskirt"
	desc = "It's a high visibility jumpskirt given to those engineers insane enough to achieve the rank of \"Chief Engineer\". Made from fire resistant materials."
	icon_state = "chief_skirt"
	inhand_icon_state = "gy_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/engineering/chief_engineer/turtleneck
	name = "chief engineer's turtleneck"
	desc = "A yellow turtleneck and white khakis, for a chief engineer with a superior sense of style."
	icon_state = "ceturtle"
	inhand_icon_state = "y_suit"
	can_adjust = TRUE
	alt_covers_chest = TRUE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/rank/engineering/chief_engineer/turtleneck/skirt
	name = "chief engineer's turtleneck skirt"
	desc = "A yellow turtleneck and white khaki skirt, for a chief engineer with a superior sense of style."
	icon_state = "ceturtle_skirt"
	inhand_icon_state = "y_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/engineering/atmospheric_technician
	desc = "It's a jumpsuit worn by atmospheric technicians. Made from fire resistant materials."
	name = "atmospheric technician's jumpsuit"
	icon_state = "atmos"
	inhand_icon_state = "atmos_suit"

/obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt
	name = "atmospheric technician's jumpskirt"
	desc = "It's a jumpskirt worn by atmospheric technicians. Made from fire resistant materials."
	icon_state = "atmos_skirt"
	inhand_icon_state = "atmos_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/engineering/engineer
	desc = "It's an orange high visibility jumpsuit worn by engineers. Made from fire resistant materials."
	name = "engineer's jumpsuit"
	icon_state = "engine"
	inhand_icon_state = "engi_suit"

/obj/item/clothing/under/rank/engineering/engineer/hazard
	name = "engineer's hazard jumpsuit"
	desc = "A high visibility jumpsuit. Made from fire resistant materials."
	icon_state = "hazard"
	inhand_icon_state = "syndicate-orange"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/engineering/engineer/skirt
	name = "engineer's jumpskirt"
	desc = "It's an orange high visibility jumpskirt worn by engineers. Made from fire resistant materials."
	icon_state = "engine_skirt"
	inhand_icon_state = "engi_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON


// BEGIN NOVA CORE MIGRATION: code/modules/clothing/under/jobs/engineering.dm
/obj/item/clothing/under/rank/engineering
	worn_icon_digi = 'icons/mob/clothing/under/engineering_digi.dmi'

/obj/item/clothing/under/rank/engineering/engineer/nova
	icon = 'icons/obj/clothing/under/engineering_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/engineering_additions.dmi'

/obj/item/clothing/under/rank/engineering/chief_engineer/nova
	icon = 'icons/obj/clothing/under/engineering_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/engineering_additions.dmi'

/obj/item/clothing/under/rank/engineering/atmospheric_technician/nova
	icon = 'icons/obj/clothing/under/engineering_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/engineering_additions.dmi'

/*
*	ENGINEER
*/

/obj/item/clothing/under/rank/engineering/engineer/nova/utility
	name = "engineering utility uniform"
	desc = "A utility uniform worn by Engineering personnel."
	icon_state = "util_eng"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_BIG_LEGS_MASK
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/engineering/engineer/nova/utility/syndicate
	armor_type = /datum/armor/clothing_under/utility_syndicate
	has_sensor = NO_SENSORS

/obj/item/clothing/under/rank/engineering/engineer/nova/trouser
	name = "engineering trousers"
	desc = "An engineering-orange set of trousers. Their waistband proudly displays an 'anti-radiation' symbol, though the effectiveness of radiation-proof-pants-only is still up for debate."
	icon_state = "workpants_orange"
	body_parts_covered = GROIN|LEGS
	can_adjust = FALSE
	female_sprite_flags = FEMALE_UNIFORM_NO_BREASTS

/obj/item/clothing/under/rank/engineering/engineer/nova/hazard_chem
	name = "chemical hazard jumpsuit"
	desc = "A high visibility jumpsuit with additional protection from gas and chemical hazards, at the cost of less fire-proofing."
	icon_state = "hazard_green"
	armor_type = /datum/armor/clothing_under/nova_hazard_chem
	resistance_flags = ACID_PROOF
	alt_covers_chest = TRUE

/datum/armor/clothing_under/nova_hazard_chem
	fire = 20
	acid = 60

/obj/item/clothing/under/rank/engineering/engineer/nova/hazard_chem/emt
	name = "chemical hazard EMT jumpsuit"
	desc = "An EMT jumpsuit used for first responders in situations involving gas and/or chemical hazards. The label reads, \"Not designed for prolonged exposure\"."
	icon_state = "hazard_white"
	armor_type = /datum/armor/clothing_under/hazard_chem_emt

/datum/armor/clothing_under/hazard_chem_emt
	fire = 10
	acid = 50

/*
*	CHIEF ENGINEER
*/
/obj/item/clothing/under/imperial/ce
	desc = "An olive drab naval suit with a rank badge denoting the Officer of the Internal Engineering Division. Doesn't come with a death machine building guide."
	name = "chief engineer's naval jumpsuit"
	icon_state = "/obj/item/clothing/under/imperial/ce"
	greyscale_colors = "#404429#404429#43443f#373741#ffffff#f48600#5c97e6"
	flags_1 = NONE
	armor_type = /datum/armor/clothing_under/engineering_chief_engineer

/obj/item/clothing/under/imperialskirt/ce
	desc = "An olive drab naval skirt with a rank badge denoting the Officer of the Internal Engineering Division. Doesn't come with a death machine building guide."
	name = "chief engineer's naval skirt"
	icon_state = "/obj/item/clothing/under/imperialskirt/ce"
	greyscale_colors = "#404429#43443f#373741#ffffff#f48600#5c97e6"
	flags_1 = NONE
	armor_type = /datum/armor/clothing_under/engineering_chief_engineer

/*
*	ATMOS TECH
*/
/datum/armor/clothing_under/atmos_adv
	bio = 40
	fire = 70
	acid = 70

/obj/item/clothing/under/rank/engineering/atmospheric_technician/nova/utility/advanced
	name = "advanced atmospherics uniform"
	desc = "A jumpsuit worn by advanced atmospherics crews."
	icon_state = "util_atmos"
	armor_type = /datum/armor/clothing_under/atmos_adv
	icon_state = "util_eng"
	can_adjust = FALSE

/*
*	TELECOMMS SPECIALIST
*/

/obj/item/clothing/under/rank/engineering/engineer/nova/utility/telecomm
	desc = "It's a jumpsuit worn by telecomms specialists. Made from fire resistant materials."
	name = "telecomm jumpsuit"
	icon_state = "telecomm"
	can_adjust = TRUE

/obj/item/clothing/under/rank/engineering/engineer/nova/utility/telecomm/skirt
	desc = "It's a jumpskirt worn by telecomms specialists. Made from fire resistant materials."
	name = "telecomm jumpskirt"
	icon_state = "telecomm_skirt"
	can_adjust = TRUE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	gets_cropped_on_taurs = FALSE
// END NOVA CORE MIGRATION: code/modules/clothing/under/jobs/engineering.dm
