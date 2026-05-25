/obj/item/clothing/under/rank/rnd
	icon = 'icons/obj/clothing/under/rnd.dmi'
	worn_icon = 'icons/mob/clothing/under/rnd.dmi'
	abstract_type = /obj/item/clothing/under/rank/rnd

/datum/armor/clothing_under/science
	bomb = 10
	bio = 40

/obj/item/clothing/under/rank/rnd/research_director
	desc = "It's a suit worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	name = "research director's vest suit"
	icon_state = "director"
	inhand_icon_state = "lb_suit"
	armor_type = /datum/armor/clothing_under/rnd_research_director
	can_adjust = FALSE

/datum/armor/clothing_under/rnd_research_director
	bomb = 10
	bio = 50
	acid = 35

/obj/item/clothing/under/rank/rnd/research_director/doctor_hilbert
	desc = "A Research Director jumpsuit belonging to the late and great Doctor Hilbert. The suit sensors have long since fizzled out from the stress of the Hilbert's Hotel."
	has_sensor = NO_SENSORS
	random_sensor = FALSE

/obj/item/clothing/under/rank/rnd/research_director/skirt
	name = "research director's vest suitskirt"
	desc = "It's a suitskirt worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	icon_state = "director_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/rnd/research_director/alt
	name = "research director's tan suit"
	desc = "Maybe you'll engineer your own half-man, half-pig creature some day. Its fabric provides minor protection from biological contaminants."
	icon = 'icons/map_icons/clothing/under/_under.dmi'
	worn_icon = 'icons/mob/clothing/under/shorts_pants_shirts.dmi'
	icon_state = "/obj/item/clothing/under/rank/rnd/research_director/alt"
	post_init_icon_state = "buttondown_slacks"
	greyscale_config = /datum/greyscale_config/buttondown_slacks
	greyscale_config_worn = /datum/greyscale_config/buttondown_slacks/worn
	greyscale_colors = "#ffeeb6#c2d3da#402912#615233"
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/rnd/research_director/alt/skirt
	name = "research director's tan suitskirt"
	icon = 'icons/map_icons/clothing/under/_under.dmi'
	icon_state = "/obj/item/clothing/under/rank/rnd/research_director/alt/skirt"
	post_init_icon_state = "buttondown_skirt"
	greyscale_config = /datum/greyscale_config/buttondown_skirt
	greyscale_config_worn = /datum/greyscale_config/buttondown_skirt/worn
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/rnd/research_director/turtleneck
	desc = "A Nanotrasen-purple turtleneck and black jeans, for a director with a superior sense of style."
	name = "research director's turtleneck"
	icon_state = "rdturtle"
	inhand_icon_state = "p_suit"
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt
	name = "research director's turtleneck skirt"
	desc = "A Nanotrasen-purple turtleneck and a black skirt, for a director with a superior sense of style."
	icon_state = "rdturtle_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/rnd/scientist
	name = "scientist's jumpsuit"
	desc = "It's made of a special fiber that provides minor protection against explosives. It has markings that denote the wearer as a scientist."
	icon_state = "science"
	inhand_icon_state = "w_suit"
	armor_type = /datum/armor/clothing_under/science

/obj/item/clothing/under/rank/rnd/scientist/skirt
	name = "scientist's jumpskirt"
	icon_state = "science_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/rnd/roboticist
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	name = "roboticist's jumpsuit"
	icon_state = "robotics"
	inhand_icon_state = null
	resistance_flags = NONE

/obj/item/clothing/under/rank/rnd/roboticist/skirt
	name = "roboticist's jumpskirt"
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	icon_state = "robotics_skirt"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/rnd/geneticist
	name = "geneticist's jumpsuit"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a genetics rank stripe on it."
	icon_state = "genetics"
	inhand_icon_state = "w_suit"

/obj/item/clothing/under/rank/rnd/geneticist/skirt
	name = "geneticist's jumpskirt"
	icon_state = "genetics_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON


// BEGIN NOVA CORE MIGRATION: code/modules/clothing/under/jobs/rnd.dm
/*
 *	GENETICIST (TO-DO)
 *  Add geneticist icons!!!
 */

/*
/obj/item/clothing/under/rank/rnd/geneticist/nova/utility
	name = "genetics utility uniform"
	desc = "A utility uniform worn by NT-certified Genetics staff."
	icon_state = "util_gene"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	can_adjust = FALSE

/obj/item/clothing/under/rank/rnd/geneticist/nova/utility/syndicate
	desc = "A utility uniform worn by Genetics staff."
	armor_type = /datum/armor/clothing_under/utility_syndicate
	has_sensor = NO_SENSORS
*/

/*
 *	SCIENTIST
 */
/obj/item/clothing/under/rank/rnd/scientist/nova/utility
	name = "science utility uniform"
	desc = "A utility uniform worn by NT-certified Science staff."
	icon_state = "util_sci"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_BIG_LEGS_MASK
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/rnd/scientist/nova/utility/syndicate
	desc = "A utility uniform worn by Science staff."
	armor_type = /datum/armor/clothing_under/utility_syndicate
	has_sensor = NO_SENSORS

/obj/item/clothing/under/rank/rnd/scientist/nova/hlscience
	name = "science team uniform"
	desc = "A simple semi-formal uniform consisting of a grayish-blue shirt and off-white slacks, paired with a ridiculous, but mandatory, tie."
	icon_state = "hl_scientist"
	can_adjust = FALSE

/obj/item/clothing/under/rank/rnd/scientist/nova
	icon = 'icons/obj/clothing/under/rnd_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/rnd_additions.dmi'
	icon_state = null //debug item

/*
 *	ROBOTICIST
 */
/obj/item/clothing/under/rank/rnd/roboticist/nova
	icon = 'icons/obj/clothing/under/rnd_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/rnd_additions.dmi'
	icon_state = null //debug item

/*
 *	RESEARCH DIRECTOR
 */
/obj/item/clothing/under/imperial/rd
	desc = "An off-white naval suit over black pants, with a rank badge denoting the Officer of the Internal Science Division. It's a peaceful life."
	name = "research director's naval jumpsuit"
	icon_state = "/obj/item/clothing/under/imperial/rd"
	greyscale_colors = "#ededed#39393f#7e1980#373741#FFFFFF#a80100#fac719"
	flags_1 = NONE

/obj/item/clothing/under/imperialskirt/rd
	desc = "An off-white naval skirt, with a rank badge denoting the Officer of the Internal Science Division. It's a peaceful life."
	name = "research director's naval skirt"
	icon_state = "/obj/item/clothing/under/imperialskirt/rd"
	greyscale_colors = "#ededed#7e1980#373741#FFFFFF#a80100#fac719"
	flags_1 = NONE


/obj/item/clothing/under/rank/rnd/research_director/nova
	icon = 'icons/obj/clothing/under/rnd_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/rnd_additions.dmi'
	icon_state = null //debug item

/obj/item/clothing/under/rank/rnd/research_director/alt
	greyscale_config_worn_digi = /datum/greyscale_config/buttondown_slacks/worn/digi

/obj/item/clothing/under/rank/rnd
	worn_icon_digi = 'icons/mob/clothing/under/rnd_digi.dmi'
// END NOVA CORE MIGRATION: code/modules/clothing/under/jobs/rnd.dm
