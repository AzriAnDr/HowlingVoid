/obj/item/clothing/under/rank/medical
	icon = 'icons/obj/clothing/under/medical.dmi'
	worn_icon = 'icons/mob/clothing/under/medical.dmi'
	abstract_type = /obj/item/clothing/under/rank/medical
	armor_type = /datum/armor/clothing_under/rank_medical

/datum/armor/clothing_under/rank_medical
	bio = 50

/obj/item/clothing/under/rank/medical/doctor
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a cross on the chest denoting that the wearer is trained medical personnel."
	name = "medical doctor's jumpsuit"
	icon_state = "medical"
	inhand_icon_state = "w_suit"

/obj/item/clothing/under/rank/medical/doctor/skirt
	name = "medical doctor's jumpskirt"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a cross on the chest denoting that the wearer is trained medical personnel."
	icon_state = "medical_skirt"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/medical/chief_medical_officer
	desc = "It's a jumpsuit worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	name = "chief medical officer's jumpsuit"
	icon_state = "cmo"
	inhand_icon_state = "w_suit"

/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt
	name = "chief medical officer's jumpskirt"
	desc = "It's a jumpskirt worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmo_skirt"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/medical/chief_medical_officer/scrubs
	name = "chief medical officer's scrubs"
	desc = "A distinctive set of white and turquoise scrubs given to chief medical officers who desire a clinical look."
	icon_state = "scrubscmo"
	inhand_icon_state = "w_suit"

/obj/item/clothing/under/rank/medical/chief_medical_officer/scrubs/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/adjust_fishing_difficulty, -3) //FISH DOCTOR?!

/obj/item/clothing/under/rank/medical/chief_medical_officer/turtleneck
	name = "chief medical officer's turtleneck"
	desc = "A light blue turtleneck and tan khakis, for a chief medical officer with a superior sense of style."
	icon_state = "cmoturtle"
	inhand_icon_state = "b_suit"
	can_adjust = TRUE
	alt_covers_chest = TRUE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/rank/medical/chief_medical_officer/turtleneck/skirt
	name = "chief medical officer's turtleneck skirt"
	desc = "A light blue turtleneck and tan khaki skirt, for a chief medical officer with a superior sense of style."
	icon_state = "cmoturtle_skirt"
	inhand_icon_state = "b_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/medical/virologist
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a virologist rank stripe on it."
	name = "virologist's jumpsuit"
	icon_state = "virology"
	inhand_icon_state = "w_suit"

/obj/item/clothing/under/rank/medical/virologist/skirt
	name = "virologist's jumpskirt"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a virologist rank stripe on it."
	icon_state = "virologywhite_skirt"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/medical/scrubs
	name = "medical scrubs"

/obj/item/clothing/under/rank/medical/scrubs/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/adjust_fishing_difficulty, -3) //FISH DOCTOR?!

/obj/item/clothing/under/rank/medical/scrubs/blue
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in baby blue."
	icon_state = "scrubsblue"

/obj/item/clothing/under/rank/medical/scrubs/green
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in dark green."
	icon_state = "scrubsgreen"

/obj/item/clothing/under/rank/medical/scrubs/purple
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in deep purple."
	icon_state = "scrubswine"

/obj/item/clothing/under/rank/medical/coroner
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a white cross turned sideways on the chest, denoting that the wearer is a trained coroner."
	name = "coroner jumpsuit"
	icon_state = "coroner"
	inhand_icon_state = "w_suit"

/obj/item/clothing/under/rank/medical/coroner/skirt
	name = "coroner jumpskirt"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a white cross turned sideways on the chest, denoting that the wearer is a trained coroner."
	icon_state = "coroner_skirt"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/medical/scrubs/coroner
	name = "coroner scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is as dark as an emo's poetry."
	icon_state = "scrubsblack"

/obj/item/clothing/under/rank/medical/chemist
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a chemist rank stripe on it."
	name = "chemist's jumpsuit"
	icon_state = "chemistry"
	inhand_icon_state = "w_suit"
	armor_type = /datum/armor/clothing_under/medical_chemist

/datum/armor/clothing_under/medical_chemist
	fire = 50
	acid = 65

/obj/item/clothing/under/rank/medical/chemist/skirt
	name = "chemist's jumpskirt"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a chemist rank stripe on it."
	icon_state = "chemistrywhite_skirt"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/medical/paramedic
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a dark blue cross on the chest denoting that the wearer is a trained paramedic."
	name = "paramedic jumpsuit"
	icon_state = "paramedic"
	inhand_icon_state = "w_suit"

/obj/item/clothing/under/rank/medical/paramedic/skirt
	name = "paramedic jumpskirt"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a dark blue cross on the chest denoting that the wearer is a trained paramedic."
	icon_state = "paramedic_skirt"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/medical/doctor/nurse
	desc = "It's a jumpsuit commonly worn by nursing staff in the medical department."
	name = "nurse's suit"
	icon_state = "nursesuit"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE


// BEGIN NOVA CORE MIGRATION: code/modules/clothing/under/jobs/medical.dm
/obj/item/clothing/under/rank/medical
	worn_icon_digi = 'icons/mob/clothing/under/medical_digi.dmi'

/obj/item/clothing/under/rank/medical/doctor/nurse
	can_adjust = FALSE
	icon = 'icons/obj/clothing/under/medical_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/medical_additions.dmi'
	worn_icon_digi = 'icons/mob/clothing/under/medical_digi.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	alternate_worn_layer = ABOVE_SHOES_LAYER

/obj/item/clothing/under/rank/medical/doctor/nurse/seriouser
	can_adjust = FALSE
	icon_state = "nursesuit_alt"
	icon = 'icons/obj/clothing/under/medical_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/medical_additions.dmi'
	worn_icon_digi = 'icons/mob/clothing/under/medical_digi.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	alternate_worn_layer = ABOVE_SHOES_LAYER

/obj/item/clothing/under/rank/medical/doctor/nova
	icon = 'icons/obj/clothing/under/medical_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/medical_additions.dmi'

/obj/item/clothing/under/syndicate/scrubs
	worn_icon_digi = 'icons/mob/clothing/under/medical_digi.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/medical/scrubs/nova
	icon = 'icons/obj/clothing/under/medical_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/medical_additions.dmi'
	icon_state = "scrubswhite" // Because for some reason TG's scrubs dont have an icon on their basetype
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one seems to be the original Scrub."
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/medical/chemist/nova
	icon = 'icons/obj/clothing/under/medical_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/medical_additions.dmi'

// Add a 'medical/virologist/nova' here if you make Virologist uniforms

/obj/item/clothing/under/rank/medical/paramedic/nova
	icon = 'icons/obj/clothing/under/medical_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/medical_additions.dmi'

/obj/item/clothing/under/rank/medical/chief_medical_officer/nova
	icon = 'icons/obj/clothing/under/medical_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/medical_additions.dmi'

/*
*	DOCTOR
*/

/obj/item/clothing/under/rank/medical/doctor/nova/utility
	name = "medical utility uniform"
	desc = "A utility uniform worn by Medical doctors."
	icon_state = "util_med"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_BIG_LEGS_MASK
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/medical/doctor/nova/utility/syndicate
	armor_type = /datum/armor/clothing_under/utility_syndicate
	has_sensor = NO_SENSORS

/*
*	SCRUBS
*/

/obj/item/clothing/under/rank/medical/scrubs/nova/red
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in a deep red."
	icon_state = "scrubsred"

/obj/item/clothing/under/rank/medical/scrubs/nova/white
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in a cream white colour."
	icon_state = "scrubswhite"

/*
*	CHEMIST
*/

/obj/item/clothing/under/rank/medical/chemist/nova/formal
	name = "chemist's formal jumpsuit"
	desc = "A white shirt with left-aligned buttons and an orange stripe, lined with protection against chemical spills."
	icon_state = "pharmacologist"

/obj/item/clothing/under/rank/medical/chemist/nova/formal/skirt
	name = "chemist's formal jumpskirt"
	icon_state = "pharmacologist_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_BIG_LEGS_MASK
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/under/rank/medical/chemist/skirt
	gets_cropped_on_taurs = FALSE

/*
*	PARAMEDIC
*/

/obj/item/clothing/under/rank/medical/paramedic/nova/light
	name = "light paramedic uniform"
	desc = "A brighter variant of the typical Paramedic uniform made with special fibers that provide minor protection against biohazards, this one has the reflective strips removed."
	icon_state = "paramedic_light"

/obj/item/clothing/under/rank/medical/paramedic/nova/light/skirt
	name = "light paramedic skirt"
	desc = "A brighter variant of the typical Paramedic uniform made with special fibers that provide minor protection against biohazards, this one has had its legs replaced with a skirt."
	icon_state = "paramedic_light_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_BIG_LEGS_MASK
	gets_cropped_on_taurs = FALSE

/*
*	CHIEF MEDICAL OFFICER
*/

/obj/item/clothing/under/imperial/cmo
	desc = "A teal, sterile naval suit with a rank badge denoting the Officer of the Medical Corps. Doesn't protect against blaster fire."
	name = "chief medical officer's naval jumpsuit"
	icon_state = "/obj/item/clothing/under/imperial/cmo"
	greyscale_colors = "#5EB8B8#5EB8B8#5EB8B8#373741#FFFFFF#2979cd#bc2626"
	flags_1 = NONE

/obj/item/clothing/under/imperialskirt/cmo
	desc = "A teal, sterile naval skirt with a rank badge denoting the Officer of the Medical Corps. Doesn't protect against blaster fire."
	name = "chief medical officer's naval skirt"
	icon_state = "/obj/item/clothing/under/imperialskirt/cmo"
	greyscale_colors = "#5EB8B8#5EB8B8#373741#FFFFFF#2979cd#bc2626"
	flags_1 = NONE
// END NOVA CORE MIGRATION: code/modules/clothing/under/jobs/medical.dm
