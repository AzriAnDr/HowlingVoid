/obj/item/clothing/under/rank/cargo
	icon = 'icons/obj/clothing/under/cargo.dmi'
	worn_icon = 'icons/mob/clothing/under/cargo.dmi'
	abstract_type = /obj/item/clothing/under/rank/cargo

/obj/item/clothing/under/rank/cargo/qm
	name = "quartermaster's uniform"
	desc = "A brown dress shirt, coupled with a pair of black slacks. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"
	inhand_icon_state = "lb_suit"

/obj/item/clothing/under/rank/cargo/qm/skirt
	name = "quartermaster's skirt"
	desc = "A brown dress shirt, coupled with a long pleated black skirt. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm_skirt"
	inhand_icon_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/rank/cargo/tech
	name = "cargo technician's jumpsuit"
	desc = "A jumpsuit from the previous supply-department, a tag on the collar says, 'Production Line: 2557, Product of Nanotrasen.'"
	icon_state = "cargotech"
	inhand_icon_state = "lb_suit"

/obj/item/clothing/under/rank/cargo/tech/alt
	name = "cargo technician's shorts"
	desc = "I like shooooorts! They're comfy and easy to wear!"
	icon_state = "cargotech_alt"
	inhand_icon_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/cargo/tech/skirt
	name = "cargo technician's jumpskirt"
	desc = "A jumpskirt from the previous supply-department, a tag on the collar says, 'Production Line: 2557, Product of Nanotrasen.'"
	icon_state = "cargo_skirt"
	inhand_icon_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/rank/cargo/tech/skirt/alt
	name = "cargo technician's shortskirt"
	desc = "I like skiiiiirts! They're comfy and easy to wear!"
	icon_state = "cargo_skirt_alt"

/obj/item/clothing/under/rank/cargo/miner
	name = "shaft miner's jumpsuit"
	desc = "It's a snappy jumpsuit with a sturdy set of overalls. It is very dirty."
	icon_state = "miner"
	inhand_icon_state = null
	armor_type = /datum/armor/clothing_under/cargo_miner
	resistance_flags = NONE

/datum/armor/clothing_under/cargo_miner
	fire = 80
	wound = 10

/obj/item/clothing/under/rank/cargo/miner/lavaland
	name = "shaft miner's jumpsuit"
	desc = "A grey uniform for operating in hazardous environments."
	icon_state = "explorer"
	inhand_icon_state = null

/obj/item/clothing/under/rank/cargo/bitrunner
	name = "bitrunner's jumpsuit"
	desc = "It's a leathery jumpsuit worn by a bitrunner. Tacky, but comfortable to wear if sitting for prolonged periods of time."
	icon_state = "bitrunner"
	inhand_icon_state = "w_suit"


// BEGIN NOVA CORE MIGRATION: code/modules/clothing/under/jobs/cargo.dm
/obj/item/clothing/under/rank/cargo
	worn_icon_digi = 'icons/mob/clothing/under/cargo_digi.dmi'

/obj/item/clothing/under/rank/cargo/tech/nova
	icon = 'icons/obj/clothing/under/cargo_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/cargo_additions.dmi'

/obj/item/clothing/under/rank/cargo/qm/nova
	icon = 'icons/obj/clothing/under/cargo_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/cargo_additions.dmi'

// Add a /obj/item/clothing/under/rank/cargo/miner/nova if you add miner uniforms

/*
*	CARGO TECH
*/

/obj/item/clothing/under/rank/cargo/tech/nova/utility
	name = "supply utility uniform"
	desc = "A utility uniform worn by employees of the Supply department."
	icon_state = "util_cargo"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_BIG_LEGS_MASK
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/cargo/tech/nova/utility/syndicate
	armor_type = /datum/armor/clothing_under/utility_syndicate
	has_sensor = NO_SENSORS

/obj/item/clothing/under/rank/cargo/tech/nova/long
	name = "cargo technician's long jumpsuit"
	desc = "For crate-pushers who'd rather protect their legs than show them off."
	icon_state = "cargo_long"
	alt_covers_chest = FALSE

/obj/item/clothing/under/rank/cargo/tech/nova/gorka
	name = "supply gorka"
	desc = "A rugged, utilitarian gorka worn by the Supply department."
	icon_state = "gorka_cargo"
	can_adjust = FALSE

/obj/item/clothing/under/rank/cargo/tech/nova/turtleneck
	name = "supply turtleneck"
	desc = "A snug turtleneck sweater worn by the Supply department."
	icon_state = "turtleneck_cargo"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/cargo/tech/nova/turtleneck/skirt
	name = "supply skirtleneck"
	desc = "A snug turtleneck sweater worn by Supply, this time with a skirt attached!"
	icon_state = "skirtleneck"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alt_covers_chest = TRUE
	gets_cropped_on_taurs = FALSE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_BIG_LEGS_MASK

/obj/item/clothing/under/rank/cargo/tech/nova/evil
	name = "black cargo uniform"
	desc = "A standard cargo uniform with a more... Venerable touch to it."
	icon_state = "qmsynd"
	can_adjust = FALSE

/obj/item/clothing/under/rank/cargo/tech/nova/casualman
	name = "cargo technician casualwear"
	desc = "A pair of stylish black jeans and a regular sweater for the relaxed technician."
	icon_state = "cargotechjean"
	can_adjust = FALSE

/*
*	QUARTERMASTER
*/

/obj/item/clothing/under/rank/cargo/qm/nova/gorka
	name = "quartermaster's gorka"
	desc = "A rugged, utilitarian gorka with silver markings. Unlike the regular employees', this one is lined with silk on the inside."
	icon_state = "gorka_qm"
	can_adjust = FALSE

/obj/item/clothing/under/imperial/quartermaster
	name = "quartermaster's naval uniform"
	desc = "A uniform of the grand navy questionably granted to Nanotrasen's favorite union representative."
	icon_state = "/obj/item/clothing/under/imperial/quartermaster"
	greyscale_colors = "#8B4C31#8B4C31#3E3E48#373741#ccced1#DEB63D#DEB63D"
	flags_1 = NONE

/obj/item/clothing/under/imperialskirt/quartermaster
	name = "quartermaster's naval skirt"
	desc = "A uniform of the grand navy questionably granted to Nanotrasen's favorite union representative."
	greyscale_colors = "#8B4C31#3E3E48#373741#ccced1#DEB63D#DEB63D"
	icon_state = "/obj/item/clothing/under/imperialskirt/quartermaster"
	flags_1 = NONE

/obj/item/clothing/under/rank/cargo/qm/nova/turtleneck
	name = "quartermaster's turtleneck"
	desc = "A snug turtleneck sweater worn by the Quartermaster, characterized by the expensive-looking pair of suit pants."
	icon_state = "turtleneck_qm"

/obj/item/clothing/under/rank/cargo/qm/nova/turtleneck/skirt
	name = "quartermaster's skirtleneck"
	desc = "A snug turtleneck sweater worn by the Quartermaster, as shown by the elegant double-lining of its silk skirt."
	icon_state = "skirtleneckQM"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/under/rank/cargo/qm/nova/interdyne
	name = "deck officer's jumpsuit"
	desc = "A dark suit with a classic cargo vest. For the ultimate master of all things paper."
	icon_state = "qmsynd"
	has_sensor = NO_SENSORS
	armor_type = /datum/armor/clothing_under/nova_interdyne
	can_adjust = FALSE

/datum/armor/clothing_under/nova_interdyne
	melee = 10
	fire = 50
	acid = 40

/obj/item/clothing/under/rank/cargo/qm/nova/formal
	name = "quartermaster's formal jumpsuit"
	desc = "A western-like alternate uniform for the old fashioned QM."
	icon_state = "supply_chief"
	can_adjust = FALSE

/obj/item/clothing/under/rank/cargo/qm/nova/formal/skirt
	name = "quartermaster's formal jumpskirt"
	desc = "A western-like alternate uniform for the old fashioned QM. Skirt included!"
	icon_state = "supply_chief_skirt"
	can_adjust = FALSE
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/under/rank/cargo/qm/nova/casual
	name = "quartermaster's casualwear"
	desc = "A brown jacket with matching trousers for the relaxed Quartermaster."
	icon_state = "qmc"
// END NOVA CORE MIGRATION: code/modules/clothing/under/jobs/cargo.dm
