/obj/item/clothing/under/rank/centcom
	icon = 'icons/obj/clothing/under/centcom.dmi'
	worn_icon = 'icons/mob/clothing/under/centcom.dmi'
	abstract_type = /obj/item/clothing/under/rank/centcom

/obj/item/clothing/under/rank/centcom/commander
	name = "\improper CentCom commander's suit"
	desc = "It's a suit worn by CentCom's highest-tier Commanders."
	icon_state = "centcom"
	inhand_icon_state = "dg_suit"

/obj/item/clothing/under/rank/centcom/official
	name = "\improper CentCom official's suit"
	desc = "A suit worn by CentCom Officials, with a silver belt buckle to indicate their rank from a glance."
	icon_state = "official"
	inhand_icon_state = "dg_suit"

/obj/item/clothing/under/rank/centcom/intern
	name = "\improper CentCom intern's jumpsuit"
	desc = "It's a jumpsuit worn by those interning for CentCom. The top is styled after a polo shirt for easy identification."
	icon_state = "intern"
	inhand_icon_state = "dg_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/centcom/officer
	name = "\improper CentCom turtleneck suit"
	desc = "A casual, yet refined green turtleneck, used by CentCom Officers. It has a fragrance of aloe."
	icon_state = "officer"
	inhand_icon_state = "dg_suit"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/centcom/officer/replica
	name = "\improper CentCom turtleneck replica"
	desc = "A cheap copy of the CentCom turtleneck! A Donk Co. logo can be seen on the collar."

/obj/item/clothing/under/rank/centcom/officer_skirt
	name = "\improper CentCom turtleneck skirt"
	desc = "A skirt version of the CentCom turtleneck, rarer and more sought after than the original."
	icon_state = "officer_skirt"
	inhand_icon_state = "dg_suit"
	alt_covers_chest = TRUE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/centcom/officer_skirt/replica
	name = "\improper CentCom turtleneck skirt replica"
	desc = "A cheap copy of the CentCom turtleneck skirt! A Donk Co. logo can be seen on the collar."

/obj/item/clothing/under/rank/centcom/centcom_skirt
	name = "\improper CentCom commander's suitskirt"
	desc = "It's a suitskirt worn by CentCom's highest-tier Commanders."
	icon_state = "centcom_skirt"
	inhand_icon_state = "dg_suit"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/centcom/military
	name = "tactical combat uniform"
	desc = "A dark colored uniform worn by CentCom's conscripted military forces."
	icon_state = "military"
	inhand_icon_state = "bl_suit"
	can_adjust = FALSE
	armor_type = /datum/armor/clothing_under/centcom_military

/datum/armor/clothing_under/centcom_military
	melee = 10
	fire = 50
	acid = 40
	wound = 10

/obj/item/clothing/under/rank/centcom/military/eng
	name = "tactical engineering uniform"
	desc = "A dark colored uniform worn by CentCom's regular military engineers."
	icon_state = "military_eng"


// BEGIN NOVA CORE MIGRATION: code/modules/clothing/under/jobs/centcom.dm
//This file is for any station-aligned or neutral factions, not JUST Nanotrasen.
//Try to keep them all a subtype of centcom/nova, for file sorting and balance - all faction representatives should have the same/similarly armored uniforms

/obj/item/clothing/under/rank/centcom
	worn_icon_digi = 'icons/mob/clothing/under/centcom_digi.dmi'

/obj/item/clothing/under/rank/centcom/nova
	icon = 'icons/obj/clothing/under/centcom_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/centcom_additions.dmi'

/*
*	NANOTRASEN
*/
//Check code\modules\nanotrasen_naval_command\clothing.dm for more of these! (Or, currently, ALL of these.)

/*
*	LOPLAND (On the chopping block)
*/
/obj/item/clothing/under/rank/centcom/nova/lopland
	name = "\improper Contractor corporate uniform"
	desc = "A sleek jumpsuit worn by a PMC corporate. Its surprisingly well padded."
	icon_state = "lopland_shirt"
	worn_icon_state = "lopland_shirt"

/obj/item/clothing/under/rank/centcom/nova/lopland/instructor
	name = "\improper Contractor instructor's uniform"
	desc = "A over-the-top, militaristic jumpsuit worn by PMC-certified instructors, with a big PMC logo slapped on the back. The amount of pockets could make a space marine cry."
	icon_state = "lopland_tac"
	worn_icon_state = "lopland_tac"


/*
*	MISC
*/
// pizza and other misc ERTs in this file too?
// END NOVA CORE MIGRATION: code/modules/clothing/under/jobs/centcom.dm
