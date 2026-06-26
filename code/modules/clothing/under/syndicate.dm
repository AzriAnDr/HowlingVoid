/obj/item/clothing/under/syndicate
	name = "tactical turtleneck"
	desc = "A nondescript and slightly suspicious looking turtleneck with digital camouflage cargo pants."
	icon_state = "syndicate"
	inhand_icon_state = "bl_suit"
	has_sensor = NO_SENSORS
	armor_type = /datum/armor/clothing_under/syndicate
	alt_covers_chest = TRUE
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	worn_icon = 'icons/mob/clothing/under/syndicate.dmi'

/datum/armor/clothing_under/syndicate
	melee = 10
	fire = 50
	acid = 40
	wound = 10

/obj/item/clothing/under/syndicate/skirt
	name = "tactical skirtleneck"
	desc = "A nondescript and slightly suspicious looking skirtleneck."
	icon_state = "syndicate_skirt"
	inhand_icon_state = "bl_suit"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/syndicate/bloodred
	name = "blood-red sneaksuit"
	desc = "It still counts as stealth if there are no witnesses."
	icon_state = "bloodred_pajamas"
	inhand_icon_state = "bl_suit"
	armor_type = /datum/armor/clothing_under/syndicate_bloodred
	resistance_flags = FIRE_PROOF | ACID_PROOF
	can_adjust = FALSE
	supports_variations_flags = NONE

/obj/item/clothing/under/syndicate/bloodred/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/adjust_fishing_difficulty, -4) //extra-tactical

/datum/armor/clothing_under/syndicate_bloodred
	melee = 10
	bullet = 10
	laser = 10
	energy = 10
	fire = 50
	acid = 40
	wound = 10

/obj/item/clothing/under/syndicate/bloodred/sleepytime
	name = "blood-red pajamas"
	desc = "Do operatives dream of nuclear sheep?"
	icon_state = "bloodred_pajamas"
	inhand_icon_state = "bl_suit"
	armor_type = /datum/armor/clothing_under/bloodred_sleepytime

/datum/armor/clothing_under/bloodred_sleepytime
	fire = 50
	acid = 40

/obj/item/clothing/under/syndicate/tacticool
	name = "tacticool turtleneck"
	desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-."
	icon_state = "tactifool"
	inhand_icon_state = "bl_suit"
	has_sensor = HAS_SENSORS
	armor_type = /datum/armor/clothing_under/syndicate_tacticool
	stubborn_stains = TRUE

/datum/armor/clothing_under/syndicate_tacticool
	fire = 50
	acid = 40

/obj/item/clothing/under/syndicate/tacticool/examine(mob/user)
	. = ..()
	. += "It has a label that says cleaning this 'genuine' Waffle Corp. product with cleaning solutions other than Grime Liberator telelocational podcrystals will void the warranty."
	. += "What on earth is a <font color='red'>tele</font>locational pod<font color='red'>crystal</font>?"

/obj/item/clothing/under/syndicate/tacticool/dye_item(dye_color, dye_key_override)
	if(dye_color == DYE_SYNDICATE)
		if(dying_key == DYE_REGISTRY_JUMPSKIRT)
			special_wash(/obj/item/clothing/under/syndicate/skirt)
		else
			special_wash(/obj/item/clothing/under/syndicate)
		qdel(src)
		return
	return ..()

/obj/item/clothing/under/syndicate/tacticool/proc/special_wash(obj/item/clothing/under/syndicate/our_jumpsuit)
	new our_jumpsuit(loc)

/obj/item/clothing/under/syndicate/tacticool/skirt
	name = "tacticool skirtleneck"
	desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-."
	icon_state = "tactifool_skirt"
	inhand_icon_state = "bl_suit"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/syndicate/sniper
	name = "tactical turtleneck suit"
	desc = "A double seamed tactical turtleneck disguised as a civilian-grade silk suit. Intended for the most formal operator. The collar is really sharp."
	icon_state = "tactical_suit"
	inhand_icon_state = "bl_suit"
	can_adjust = FALSE
	supports_variations_flags = NONE

/obj/item/clothing/under/syndicate/camo
	name = "camouflage fatigues"
	desc = "A green military camouflage uniform."
	icon_state = "camogreen"
	inhand_icon_state = "g_suit"
	can_adjust = FALSE
	supports_variations_flags = NONE

/obj/item/clothing/under/syndicate/floortilecamo
	name = "floortile camouflage fatigues"
	desc = "The newest floortile camouflage fatigues used for hallway warfare. \
		The best breathability, flexibility and comfort. Designed by Camo-J's."
	icon_state = "camofloortile"
	inhand_icon_state = "gy_suit"
	can_adjust = FALSE
	supports_variations_flags = NONE

/obj/item/clothing/under/syndicate/floortilecamo/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/adjust_fishing_difficulty, -5) //tacticool

/obj/item/clothing/under/syndicate/soviet
	name = "Ratnik 5 tracksuit"
	desc = "Badly translated labels tell you to clean this in Vodka. Great for squatting in."
	icon_state = "trackpants"
	can_adjust = FALSE
	supports_variations_flags = NONE
	armor_type = /datum/armor/clothing_under/syndicate_soviet
	resistance_flags = NONE

/datum/armor/clothing_under/syndicate_soviet
	melee = 10

/obj/item/clothing/under/syndicate/combat
	name = "combat uniform"
	desc = "With a suit lined with this many pockets, you are ready to operate."
	icon_state = "syndicate_combat"
	can_adjust = FALSE
	supports_variations_flags = NONE

/obj/item/clothing/under/syndicate/rus_army
	name = "advanced military tracksuit"
	desc = "Military grade tracksuits for frontline squatting."
	icon_state = "rus_under"
	can_adjust = FALSE
	supports_variations_flags = NONE
	armor_type = /datum/armor/clothing_under/syndicate_rus_army
	resistance_flags = NONE

/datum/armor/clothing_under/syndicate_rus_army
	melee = 5

/obj/item/clothing/under/syndicate/scrubs
	name = "tactical scrubs"
	desc = "A deep burgundy set of scrubs, made tactically for tactical reasons."
	icon = 'icons/obj/clothing/under/medical.dmi'
	worn_icon = 'icons/mob/clothing/under/medical.dmi'
	icon_state = "scrubswine"
	can_adjust = FALSE
	supports_variations_flags = NONE
	armor_type = /datum/armor/clothing_under/syndicate_scrubs

/obj/item/clothing/under/syndicate/scrubs/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/adjust_fishing_difficulty, -3) //FISH DOCTOR?!

/datum/armor/clothing_under/syndicate_scrubs
	melee = 10
	bio = 50
	fire = 50
	acid = 40

/obj/item/clothing/under/plasmaman/syndicate
	name = "tacticool envirosuit"
	desc = "A sinister looking envirosuit, for the boniest of operatives."
	icon_state = "syndie_envirosuit"
	has_sensor = NO_SENSORS
	resistance_flags = FIRE_PROOF
	inhand_icon_state = null


// BEGIN NOVA CORE MIGRATION: code/modules/clothing/under/syndicate.dm
#define RESKIN_CHARCOAL "Charcoal"
#define RESKIN_NT "NT Blue"
#define RESKIN_SYNDIE "Syndicate Red"

/obj/item/clothing/under/syndicate
	worn_icon_digi = 'icons/mob/clothing/under/syndicate_digi.dmi'

/obj/item/clothing/under/syndicate/nova
	icon = 'icons/obj/clothing/under/syndicate_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/syndicate_additions.dmi'
	//These are pre-set for ease and reference, as syndie under items SHOULDNT have sensors and should have similar stats; also it's better to start with adjust = false
	has_sensor = NO_SENSORS
	can_adjust = FALSE

//Related files:
// code\modules\novaya_ert\uniform.dm (HC uniform(s))

/*
*	TACTICOOL
*/

//This is an overwrite, not a fully new item, but still fits best here.

/datum/atom_skin/tacticool_turtleneck
	abstract_type = /datum/atom_skin/tacticool_turtleneck

/datum/atom_skin/tacticool_turtleneck/blue
	preview_name = RESKIN_NT
	new_icon_state = "tactifool_blue"

/datum/atom_skin/tacticool_turtleneck/charcoal
	preview_name = RESKIN_CHARCOAL
	new_icon_state = "tactifool"
	new_inhand_icon_state = "bl_suit"

/datum/atom_skin/tacticool_turtleneck/charcoal/apply(atom/apply_to, mob/user)
	. = ..()
	var/obj/item/applying_to = apply_to
	applying_to.desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-." //Default decription of the normal tacticool
	applying_to.update_desc()

/obj/item/clothing/under/syndicate/tacticool //Overwrites the 'fake' one. Zero armor, sensors, and default blue. More Balanced to make station-available.
	name = "tacticool turtleneck"
	desc = "A snug turtleneck, in fabulous Nanotrasen-blue. Just looking at it makes you want to buy a NT-certifed coffee, go into the office, and -work-."
	icon = 'icons/obj/clothing/under/syndicate_additions.dmi' //Since its an overwrite it needs new icon linking. Woe.
	worn_icon = 'icons/mob/clothing/under/syndicate_additions.dmi'
	icon_state = "tactifool_blue"
	inhand_icon_state = "b_suit"
	can_adjust = TRUE
	has_sensor = HAS_SENSORS
	armor_type = /datum/armor/clothing_under
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_BIG_LEGS_MASK
	resistance_flags = FLAMMABLE

/obj/item/clothing/under/syndicate/tacticool/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/tacticool_turtleneck)

/obj/item/clothing/under/syndicate/tacticool/skirt //Overwrites the 'fake' one. Zero armor, sensors, and default blue. More Balanced to make station-available.
	name = "tacticool skirtleneck"
	desc = "A snug skirtleneck, in fabulous Nanotrasen-blue. Just looking at it makes you want to buy a NT-certifed coffee, go into the office, and -work-."
	icon_state = "tactifool_blue_skirt"
	gets_cropped_on_taurs = FALSE
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/syndicate/bloodred/sleepytime/sensors //Halloween-only
	has_sensor = HAS_SENSORS
	armor_type = /datum/armor/clothing_under
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_BIG_LEGS_MASK

/obj/item/clothing/under/syndicate/nova/baseball
	name = "syndicate baseball tee"
	desc = "Aaand the Syndicate Snakes are up to bat, ready for one of their signature nuclear home-runs! Lets show these corpos a good time." //NT pitches their plasma/bluespace(something)
	icon_state = "syndicate_baseball"

/obj/item/clothing/under/syndicate/nova/overalls
	name = "utility overalls turtleneck"
	desc = "A pair of spiffy overalls with a turtleneck underneath, useful for both engineering and botanical work."
	icon_state = "syndicate_overalls"
	can_adjust = TRUE

/obj/item/clothing/under/syndicate/nova/overalls/skirt
	name = "utility overalls skirtleneck"
	desc = "A pair of spiffy overalls with a turtleneck underneath, this one is a skirt instead, breezy."
	icon_state = "syndicate_overallskirt"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_BIG_LEGS_MASK

/obj/item/clothing/under/syndicate/nova/maid
	name = "tactical maid outfit"
	desc = "A 'tactical' skirtleneck fashioned to the likeness of a maid outfit. Why the Syndicate has these, you'll never know."
	icon_state = "syndimaid"
	armor_type = /datum/armor/clothing_under
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/syndicate/nova/maid/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/accessory/maidcorset/syndicate/apron = new(src)
	attach_accessory(apron)

/obj/item/clothing/under/syndicate/nova/maid/loadout_maid
	name = "tactical maid outfit"
	desc = "A 'tactical' skirtleneck fashioned to the likeness of a maid outfit"
	has_sensor = HAS_SENSORS
	icon_state = "syndimaid"
	armor_type = /datum/armor/clothing_under
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/syndicate/nova/interdyne
	name = "interdyne turtleneck"
	desc = "A sleek white turtleneck with a hint of interdyne-green, appropriately paired with some charcoal-black cargo pants."
	has_sensor = HAS_SENSORS
	armor_type = /datum/armor/clothing_under/syndicate
	icon_state = "ip_turtleneck"
	can_adjust = TRUE
	alt_covers_chest = TRUE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_BIG_LEGS_MASK

/obj/item/clothing/under/syndicate/nova/interdyne/miner
	name = "interdyne jumpsuit"
	desc = "A black and green Interdyne Pharmaceutics jumpsuit with reinforced fibers."
	armor_type = /datum/armor/clothing_under/cargo_miner
	icon_state = "ip_miner"
	can_adjust = TRUE
	alt_covers_chest = FALSE

/obj/item/clothing/under/syndicate/nova/interdyne/deckofficer
	name = "deck officer's jumpsuit"
	desc = "A black and green Interdyne Pharmaceutics uniform complete with a golden belt buckle."
	armor_type = /datum/armor/clothing_under/syndicate
	icon_state = "ip_deckofficer"
	can_adjust = TRUE
	alt_covers_chest = FALSE

/obj/item/clothing/under/syndicate/unarmoured
	name = "suspicious tactical turtleneck"
	desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants."
	icon_state = "syndicate"
	inhand_icon_state = "bl_suit"
	has_sensor = HAS_SENSORS
	armor_type = /datum/armor/clothing_under

/obj/item/clothing/under/syndicate/unarmoured/skirt
	name = "suspicious tactical skirtleneck"
	desc = "A non-descript and slightly suspicious looking skirtleneck."
	icon_state = "syndicate_skirt"
	gets_cropped_on_taurs = FALSE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_BIG_LEGS_MASK

/obj/item/clothing/under/syndicate/unarmoured/examine_more(mob/user)
	. = ..()
	. += span_notice("The armor has been removed from the fabric.")

/obj/item/clothing/under/syndicate/nova/tactical/unarmoured
	name = "suspicious tactical turtleneck"
	desc = "A snug syndicate-red turtleneck with charcoal-black cargo pants."
	icon_state = "syndicate_red"
	inhand_icon_state = "r_suit"
	has_sensor = HAS_SENSORS
	armor_type = /datum/armor/clothing_under

/obj/item/clothing/under/syndicate/nova/tactical/unarmoured/setup_reskins()
	return

/obj/item/clothing/under/syndicate/nova/tactical/unarmoured/skirt
	name = "suspicious tactical skirtleneck"
	desc = "A pair of spiffy overalls with a turtleneck underneath, this one is a skirt instead, breezy."
	icon_state = "syndicate_red_skirt"
	gets_cropped_on_taurs = FALSE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_BIG_LEGS_MASK

/obj/item/clothing/under/syndicate/nova/tactical/unarmoured/examine_more(mob/user)
	. = ..()
	. += span_notice("The armor has been removed from the fabric.")

/obj/item/clothing/under/syndicate/nova/overalls/unarmoured
	name = "suspicious utility overalls turtleneck"
	desc = "A pair of spiffy overalls with a turtleneck underneath, useful for both engineering and botanical work."
	icon_state = "syndicate_overalls"
	armor_type = /datum/armor/clothing_under
	has_sensor = HAS_SENSORS
	can_adjust = TRUE

/obj/item/clothing/under/syndicate/nova/overalls/unarmoured/skirt
	name = "suspicious utility overalls skirtleneck"
	desc = "A pair of spiffy overalls with a turtleneck underneath, this one is a skirt instead, breezy."
	icon_state = "syndicate_overallskirt"
	gets_cropped_on_taurs = FALSE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_BIG_LEGS_MASK
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/under/syndicate/nova/overalls/unarmoured/examine_more(mob/user)
	. = ..()
	. += span_notice("The armor has been removed from the fabric.")

/obj/item/clothing/mask/neck_gaiter/syndicate
	name = "tactical neck gaiter"
	desc = "For the agent wanting to keep a low profile whilst concealing their identity. Has a small respirator to be used with internals."
	unique_death = 'sound/effects/hacked.ogg'
	icon_state = "/obj/item/clothing/mask/neck_gaiter/syndicate"
	greyscale_colors = "#2c2c2e"

/obj/item/clothing/mask/neck_gaiter/syndicate/tacticool
	name = "tacticool neck gaiter"
	desc = "A techwear mask. Its low-profile design contrasts with the edge. Has a small respirator to be used with internals."
	flags_1 = parent_type::flags_1 | NO_NEW_GAGS_PREVIEW_1

/*
*	TACTICAL (Real)
*/
//The red alts, for BLATANTLY syndicate stuff (Like DS2)
// (Multiple non-syndicate things use the base tactical turtleneck, they cant have it red nor reskinnable. OUR version, however, can be.)
/datum/atom_skin/tactical_turtleneck
	abstract_type = /datum/atom_skin/tactical_turtleneck

/datum/atom_skin/tactical_turtleneck/red
	preview_name = RESKIN_SYNDIE
	new_icon_state = "syndicate_red"

/datum/atom_skin/tactical_turtleneck/charcoal
	preview_name = RESKIN_CHARCOAL
	new_icon_state = "syndicate"
	new_inhand_icon_state = "bl_suit"

/datum/atom_skin/tactical_turtleneck/charcoal/apply(atom/apply_to, mob/user)
	. = ..()
	var/obj/item/applying_to = apply_to
	applying_to.desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants." //(Digital camo? Brown? What?)
	applying_to.update_desc()

/obj/item/clothing/under/syndicate/nova/tactical
	name = "tactical turtleneck"
	desc = "A snug syndicate-red turtleneck with charcoal-black cargo pants. Good luck arguing allegiance with this on."
	icon_state = "syndicate_red"
	inhand_icon_state = "r_suit"
	can_adjust = TRUE
	alt_covers_chest = TRUE
	armor_type = /datum/armor/clothing_under/syndicate
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_BIG_LEGS_MASK

/obj/item/clothing/under/syndicate/nova/tactical/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/tactical_turtleneck)

/datum/atom_skin/tactical_skirtleneck
	abstract_type = /datum/atom_skin/tactical_skirtleneck

/datum/atom_skin/tactical_skirtleneck/red
	preview_name = RESKIN_SYNDIE
	new_icon_state = "syndicate_red_skirt"

/datum/atom_skin/tactical_skirtleneck/charcoal
	preview_name = RESKIN_CHARCOAL
	new_icon_state = "syndicate_skirt"
	new_inhand_icon_state = "bl_suit"

/datum/atom_skin/tactical_skirtleneck/charcoal/apply(atom/apply_to, mob/user)
	. = ..()
	var/obj/item/applying_to = apply_to
	applying_to.desc = "A non-descript and slightly suspicious looking skirtleneck."
	applying_to.update_desc()

/obj/item/clothing/under/syndicate/nova/tactical/skirt
	name = "tactical skirtleneck"
	desc = "A snug syndicate-red skirtleneck with a charcoal-black skirt. Good luck arguing allegiance with this on."
	icon_state = "syndicate_red_skirt"
	inhand_icon_state = "r_suit"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/under/syndicate/nova/tactical/skirt/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/tactical_skirtleneck)

/obj/item/clothing/under/syndicate/skirt/coldres
	name = "insulated tactical turtleneck skirt"
	desc = "A non-descript and slightly suspicious looking skirtleneck. The interior has been padded with special insulation for both warmth and protection."
	armor_type = /datum/armor/clothing_under/syndicate/coldres
	cold_protection = CHEST|GROIN|ARMS|LEGS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT


/*
*	ENCLAVE
*/
/obj/item/clothing/under/syndicate/nova/enclave
	name = "neo-American sergeant uniform"
	desc = "Throughout the stars, rumors of mad scientists and angry drill sergeants run rampant; of creatures in armor black as night, being led by men or women wearing this uniform. They share one thing: a deep, natonalistic zeal of the dream of America."
	icon_state = "enclave"
	can_adjust = TRUE
	armor_type = /datum/armor/clothing_under

/obj/item/clothing/under/syndicate/nova/enclave/officer
	name = "neo-American officer uniform"
	icon_state = "enclaveo"

/obj/item/clothing/under/syndicate/nova/enclave/real
	armor_type = /datum/armor/clothing_under/syndicate

/obj/item/clothing/under/syndicate/nova/enclave/real/officer
	name = "neo-American officer uniform"
	icon_state = "enclaveo"

#undef RESKIN_CHARCOAL
#undef RESKIN_NT
#undef RESKIN_SYNDIE
// END NOVA CORE MIGRATION: code/modules/clothing/under/syndicate.dm
