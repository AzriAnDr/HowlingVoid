/*
 * Contains:
 * Security
 * Detective
 * Navy uniforms
 */

/*
 * Security
 */

/obj/item/clothing/under/rank/security
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	worn_icon_digi = 'icons/mob/clothing/under/security_digi.dmi'
	abstract_type = /obj/item/clothing/under/rank/security
	armor_type = /datum/armor/clothing_under/rank_security
	strip_delay = 5 SECONDS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/datum/armor/clothing_under/rank_security
	melee = 10
	fire = 30
	acid = 30
	wound = 10

/obj/item/clothing/under/rank/security/officer
	name = "security uniform"
	desc = "A tactical security jumpsuit for officers complete with Nanotrasen belt buckle."
	icon_state = "rsecurity"
	inhand_icon_state = "r_suit"

/obj/item/clothing/under/rank/security/officer/grey
	name = "grey security jumpsuit"
	desc = "A tactical relic of years past before Nanotrasen decided it was cheaper to dye the suits red instead of washing out the blood."
	icon_state = "security"
	inhand_icon_state = "gy_suit"

/obj/item/clothing/under/rank/security/officer/skirt
	name = "security skirt"
	desc = "A \"tactical\" security uniform with the legs replaced by a skirt."
	icon_state = "secskirt"
	inhand_icon_state = "r_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/officer/blueshirt
	name = "blue shirt and tie"
	desc = "I'm a little busy right now, Calhoun."
	icon_state = "blueshift"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/officer/formal
	name = "security officer's formal uniform"
	desc = "The latest in fashionable security outfits."
	icon_state = "officerblueclothes"
	inhand_icon_state = null
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/constable
	name = "constable outfit"
	desc = "A British-looking outfit."
	icon_state = "constable"
	inhand_icon_state = null
	can_adjust = FALSE
	custom_price = PAYCHECK_COMMAND


/obj/item/clothing/under/rank/security/warden
	name = "security suit"
	desc = "A formal security suit for officers complete with Nanotrasen belt buckle."
	icon_state = "rwarden"
	inhand_icon_state = "r_suit"

/obj/item/clothing/under/rank/security/warden/grey
	name = "grey security suit"
	desc = "A formal relic of years past before Nanotrasen decided it was cheaper to dye the suits red instead of washing out the blood."
	icon_state = "warden"
	inhand_icon_state = "gy_suit"

/obj/item/clothing/under/rank/security/warden/skirt
	name = "warden's suitskirt"
	desc = "A formal security suitskirt for officers complete with Nanotrasen belt buckle."
	icon_state = "rwarden_skirt"
	inhand_icon_state = "r_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/warden/formal
	desc = "The insignia on this uniform tells you that this uniform belongs to the Warden."
	name = "warden's formal uniform"
	icon_state = "wardenblueclothes"
	inhand_icon_state = null
	alt_covers_chest = TRUE

/*
 * Detective
 */
/obj/item/clothing/under/rank/security/detective
	name = "hard-worn suit"
	desc = "Someone who wears this means business."
	icon_state = "detective"
	inhand_icon_state = "det"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/detective/skirt
	name = "detective's suitskirt"
	desc = "Someone who wears this means business."
	icon_state = "detective_skirt"
	inhand_icon_state = "det"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alt_covers_chest = TRUE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/detective/noir
	name = "noir suit"
	desc = "A hard-boiled private investigator's dark suit, complete with tie clip."
	icon_state = "noirdet"
	inhand_icon_state = null
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/detective/noir/skirt
	name = "noir suitskirt"
	desc = "A hard-boiled private investigator's grey suitskirt, complete with tie clip."
	icon_state = "noirdet_skirt"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alt_covers_chest = TRUE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/*
 * Head of Security
 */
/obj/item/clothing/under/rank/security/head_of_security
	name = "head of security's uniform"
	desc = "A security jumpsuit decorated for those few with the dedication to achieve the position of Head of Security."
	icon_state = "rhos"
	inhand_icon_state = "r_suit"
	armor_type = /datum/armor/clothing_under/security_head_of_security
	strip_delay = 6 SECONDS

/datum/armor/clothing_under/security_head_of_security
	melee = 10
	fire = 50
	acid = 50
	wound = 10

/obj/item/clothing/under/rank/security/head_of_security/skirt
	name = "head of security's skirt"
	desc = "A security jumpskirt decorated for those few with the dedication to achieve the position of Head of Security."
	icon_state = "rhos_skirt"
	inhand_icon_state = "r_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/head_of_security/grey
	name = "head of security's grey jumpsuit"
	desc = "There are old men, and there are bold men, but there are very few old, bold men."
	icon_state = "hos"
	inhand_icon_state = "gy_suit"

/obj/item/clothing/under/rank/security/head_of_security/alt
	name = "head of security's turtleneck"
	desc = "A stylish alternative to the normal head of security jumpsuit, complete with tactical pants."
	icon_state = "hosalt"
	inhand_icon_state = "bl_suit"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/head_of_security/alt/skirt
	name = "head of security's turtleneck skirt"
	desc = "A stylish alternative to the normal head of security jumpsuit, complete with a tactical skirt."
	icon_state = "hosalt_skirt"
	inhand_icon_state = "bl_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alt_covers_chest = TRUE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/head_of_security/parade
	name = "head of security's parade uniform"
	desc = "A male head of security's luxury-wear, for special occasions."
	icon_state = "hos_parade_male"
	inhand_icon_state = "r_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/head_of_security/parade/female
	name = "head of security's formal uniform"
	desc = "A female head of security's luxury-wear, for special occasions."
	icon_state = "hos_parade_fem"
	inhand_icon_state = "r_suit"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/head_of_security/formal
	desc = "The insignia on this uniform tells you that this uniform belongs to the Head of Security."
	name = "head of security's formal uniform"
	icon_state = "hosblueclothes"
	inhand_icon_state = null
	alt_covers_chest = TRUE

/*
 *Spacepol
 */

/obj/item/clothing/under/rank/security/officer/spacepol
	name = "police uniform"
	desc = "Space not controlled by megacorporations, planets, or pirates is under the jurisdiction of Spacepol."
	icon_state = "spacepol"
	inhand_icon_state = null
	can_adjust = FALSE
	armor_type = /datum/armor/clothing_under/sec_uniform_spacepol

/datum/armor/clothing_under/sec_uniform_spacepol
	fire = 10
	acid = 10
	melee = 10
	wound = 10

/obj/item/clothing/under/rank/prisoner
	name = "prison jumpsuit"
	desc = "Standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon = 'icons/map_icons/clothing/under/_under.dmi'
	icon_state = "/obj/item/clothing/under/rank/prisoner"
	post_init_icon_state = "jumpsuit"
	inhand_icon_state = "jumpsuit"
	greyscale_config = /datum/greyscale_config/jumpsuit/prison
	greyscale_config_worn = /datum/greyscale_config/jumpsuit/prison/worn
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit/prison/inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit/prison/inhand_right
	greyscale_colors = "#ff8300"
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/prisoner/nosensor
	desc = "Standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"OFF\" position."
	has_sensor = NO_SENSORS
	sensor_mode = SENSOR_OFF
	flags_1 = parent_type::flags_1 | NO_NEW_GAGS_PREVIEW_1

/obj/item/clothing/under/rank/prisoner/skirt
	name = "prison jumpskirt"
	desc = "Standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon = 'icons/map_icons/clothing/under/_under.dmi'
	icon_state = "/obj/item/clothing/under/rank/prisoner/skirt"
	post_init_icon_state = "jumpskirt"
	greyscale_config = /datum/greyscale_config/jumpsuit/prison
	greyscale_config_worn = /datum/greyscale_config/jumpsuit/prison/worn
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit/prison/inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit/prison/inhand_right
	greyscale_colors = "#ff8300"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/officer/beatcop
	name = "space police uniform"
	desc = "A police uniform often found in the lines at donut shops."
	icon_state = "spacepolice_families"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/detective/disco
	name = "superstar cop uniform"
	desc = "Flare cut trousers and a dirty shirt that might have been classy before someone took a piss in the armpits. It's the dress of a superstar."
	icon_state = "jamrock_suit"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/detective/kim
	name = "aerostatic suit"
	desc = "A crisp and well-pressed suit; professional, comfortable and curiously authoritative."
	icon_state = "aerostatic_suit"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/nova
	icon = 'icons/obj/clothing/under/security_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/security_additions.dmi'
	worn_icon_digi = 'icons/mob/clothing/under/security_digi.dmi'

/obj/item/clothing/under/rank/security/warden/nova
	icon = 'icons/obj/clothing/under/security_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/security_additions.dmi'
	worn_icon_digi = 'icons/mob/clothing/under/security_digi.dmi'

/obj/item/clothing/under/rank/security/head_of_security/nova
	icon = 'icons/obj/clothing/under/security_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/security_additions.dmi'
	worn_icon_digi = 'icons/mob/clothing/under/security_digi.dmi'

/datum/atom_skin/security_uniform_black
	abstract_type = /datum/atom_skin/security_uniform_black

/datum/atom_skin/security_uniform_black/black
	preview_name = "Black Variant"
	new_icon_state = "security_black"
	new_worn_icon = 'icons/mob/clothing/under/security_additions.dmi'

/datum/atom_skin/security_uniform_black/white
	preview_name = "White Variant"
	new_icon_state = "security_white"
	new_worn_icon = 'icons/mob/clothing/under/security_additions.dmi'

/obj/item/clothing/under/rank/security/nova/officer/black
	icon_state = "security_black"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/nova/officer/black/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/security_uniform_black)

/datum/atom_skin/security_uniform_blue
	abstract_type = /datum/atom_skin/security_uniform_blue

/datum/atom_skin/security_uniform_blue/black
	preview_name = "Black Variant"
	new_icon_state = "security_blue_black"

/datum/atom_skin/security_uniform_blue/blue
	preview_name = "Blue Variant"
	new_icon_state = "security_blue"

/datum/atom_skin/security_uniform_blue/white
	preview_name = "White Variant"
	new_icon_state = "security_white"

/obj/item/clothing/under/rank/security/nova/officer
	name = "security uniform"
	desc = "A tactical security uniform for officers complete with Nanotrasen belt buckle."
	icon_state = "security_blue_black"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/nova/officer/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/security_uniform_blue)

/obj/item/clothing/under/rank/security/nova/formal
	name = "security formal suit"
	desc = "A formal security suit for officers complete with Nanotrasen belt buckle."
	icon_state = "formal"

/obj/item/clothing/under/rank/security/nova/formal/blue
	icon_state = "formal_blue"

/datum/atom_skin/security_jumpskirt
	abstract_type = /datum/atom_skin/security_jumpskirt

/datum/atom_skin/security_jumpskirt/blue
	preview_name = "Blue Variant"
	new_icon_state = "jumpskirt_blue"

/datum/atom_skin/security_jumpskirt/black
	preview_name = "Black Variant"
	new_icon_state = "jumpskirt_black"

/obj/item/clothing/under/rank/security/nova/skirt
	name = "security jumpskirt"
	desc = "A \"tactical\" security uniform with the legs replaced by a skirt."
	icon_state = "jumpskirt_blue"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/under/rank/security/nova/skirt/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/security_jumpskirt, infinite = TRUE)

/datum/atom_skin/security_plain_skirt
	abstract_type = /datum/atom_skin/security_plain_skirt

/datum/atom_skin/security_plain_skirt/blue
	preview_name = "Blue Variant"
	new_icon_state = "plain_skirt_blue"

/datum/atom_skin/security_plain_skirt/black
	preview_name = "Black Variant"
	new_icon_state = "plain_skirt_black"

/obj/item/clothing/under/rank/security/nova/skirt/plain
	name = "security plain skirt"
	desc = "Plain-shirted uniform commonly worn by Nanotrasen officers, attached with a skirt."
	icon_state = "plain_skirt_blue"

/obj/item/clothing/under/rank/security/nova/skirt/plain/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/security_plain_skirt)

/datum/atom_skin/security_miniskirt
	abstract_type = /datum/atom_skin/security_miniskirt

/datum/atom_skin/security_miniskirt/red
	preview_name = "Red Variant"
	new_icon_state = "miniskirt"

/datum/atom_skin/security_miniskirt/black
	preview_name = "Black Variant"
	new_icon_state = "miniskirt_black"

/obj/item/clothing/under/rank/security/nova/skirt/mini
	name = "security miniskirt"
	desc = "This miniskirt was originally featured in a gag calendar, but entered official use once they realized its potential for arid climates."
	icon_state = "miniskirt"
	body_parts_covered = GROIN|LEGS
	can_adjust = FALSE
	female_sprite_flags = FEMALE_UNIFORM_NO_BREASTS

/obj/item/clothing/under/rank/security/nova/skirt/mini/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/security_miniskirt)

/datum/atom_skin/security_miniskirt_blue
	abstract_type = /datum/atom_skin/security_miniskirt_blue

/datum/atom_skin/security_miniskirt_blue/blue
	preview_name = "Blue Variant"
	new_icon_state = "miniskirt_blue"

/datum/atom_skin/security_miniskirt_blue/black
	preview_name = "Black Variant"
	new_icon_state = "miniskirt_blue_black"

/obj/item/clothing/under/rank/security/nova/skirt/mini/blue
	icon_state = "miniskirt_blue"

/obj/item/clothing/under/rank/security/nova/skirt/mini/blue/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/security_miniskirt_blue)

/obj/item/clothing/under/rank/security/nova/utility
	name = "security utility uniform"
	desc = "A utility uniform worn by trained Security officers."
	icon_state = "util_sec"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_BIG_LEGS_MASK
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/nova/utility/blue
	icon_state = "util_sec_blue"

/obj/item/clothing/under/rank/security/nova/dress
	name = "security battle dress"
	desc = "An asymmetrical, unisex uniform with the legs replaced by a utility skirt."
	icon_state = "security_skirt"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alt_covers_chest = FALSE

/obj/item/clothing/under/rank/security/nova/dress/setup_reskins()
	return

/obj/item/clothing/under/rank/security/nova/dress/blue
	icon_state = "security_skirt_blue"

/datum/atom_skin/security_shorts
	abstract_type = /datum/atom_skin/security_shorts

/datum/atom_skin/security_shorts/red
	preview_name = "Red Variant"
	new_icon_state = "cargoshorts"

/datum/atom_skin/security_shorts/red
	preview_name = "Blue Variant"
	new_icon_state = "cargoshorts_blue"

/datum/atom_skin/security_shorts/white
	preview_name = "White Variant"
	new_icon_state = "cargoshorts_white"

/datum/atom_skin/security_shorts/black
	preview_name = "Black Variant"
	new_icon_state = "cargoshorts_black"

/obj/item/clothing/under/rank/security/nova/trousers/shorts
	name = "cargo shorts"
	desc = "Some \"combat\" shorts. Please don't actually wear these."
	icon_state = "cargoshorts"

/obj/item/clothing/under/rank/security/nova/trousers/shorts/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/security_shorts)

/datum/atom_skin/security_trousers
	abstract_type = /datum/atom_skin/security_trousers

/datum/atom_skin/security_trousers/red
	preview_name = "Red Variant"
	new_icon_state = "cargopants"

/datum/atom_skin/security_trousers/blue
	preview_name = "Blue Variant"
	new_icon_state = "cargopants_blue"

/datum/atom_skin/security_trousers/white
	preview_name = "White Variant"
	new_icon_state = "cargopants_white"

/datum/atom_skin/security_trousers/black
	preview_name = "Black Variant"
	new_icon_state = "cargopants_black"

/obj/item/clothing/under/rank/security/nova/trousers
	name = "pair of security trousers"
	desc = "Some \"combat\" trousers. Probably should pair it with a vest for safety."
	icon_state = "cargopants"
	body_parts_covered = GROIN|LEGS
	can_adjust = FALSE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	female_sprite_flags = FEMALE_UNIFORM_NO_BREASTS

/obj/item/clothing/under/rank/security/nova/trousers/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/security_trousers)

/datum/atom_skin/security_modskin
	abstract_type = /datum/atom_skin/security_modskin

/obj/item/clothing/under/rank/security/nova/modskin
	name = "security M.O.D. skinsuit"
	desc = "A M.O.D. skinsuit worn by trained Security officers."
	icon_state = "modsec"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/datum/atom_skin/security_modskin/red
	preview_name = "Red Variant"
	new_icon_state = "modsec"

/datum/atom_skin/security_modskin/blue
	preview_name = "Blue Variant"
	new_icon_state = "modsec_blue"

/datum/atom_skin/security_modskin/white
	preview_name = "White Variant"
	new_icon_state = "modsec_white"

/datum/atom_skin/security_modskin/black
	preview_name = "Black Variant"
	new_icon_state = "modsec_black"

/obj/item/clothing/under/rank/security/nova/modskin/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/security_modskin)

/obj/item/clothing/under/rank/security/nova/turtleneck
	name = "security turtleneck"
	desc = "Turtleneck sweater commonly worn by trained Officers, attached with pants."
	icon_state = "secturtleneck"
	can_adjust = TRUE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_BIG_LEGS_MASK
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/rank/security/nova/turtleneck/blue
	icon_state = "secturtleneck_blue"

/obj/item/clothing/under/rank/security/warden/nova
	icon_state = "warden_black"

/obj/item/clothing/under/rank/security/warden/nova/blue
	icon_state = "warden_blue_black"

/obj/item/clothing/under/rank/security/warden/nova/suit
	name = "warden's suit"
	desc = "A formal security suit for officers complete with Nanotrasen belt buckle."
	icon_state = "formal_warden"

/obj/item/clothing/under/rank/security/warden/nova/suit/blue
	icon_state = "formal_warden_blue"

/obj/item/clothing/under/rank/security/head_of_security/nova
	icon_state = "hos_black"

/obj/item/clothing/under/rank/security/head_of_security/nova/blue
	icon_state = "hos_blue_black"

/obj/item/clothing/under/rank/security/head_of_security/nova/formal
	name = "head of security's formal suit"
	desc = "A security suit decorated for those few with the dedication to achieve the position of Head of Security."
	icon_state = "formal_hos"

/obj/item/clothing/under/rank/security/head_of_security/nova/formal/blue
	icon_state = "formal_hos_blue"

/obj/item/clothing/under/imperialvest/hos
	name = "head of security's naval jumpsuit"
	desc = "A tar black naval suit with a rank badge denoting the officer of The Internal Security Division. Be careful your underlings don't bump their head on a door."
	icon_state = "/obj/item/clothing/under/imperialvest/hos"
	greyscale_colors = "#39393f#39393f#39393f#373741#f8d860#21212B#f8d860#a52f29"
	flags_1 = NONE

/obj/item/clothing/under/imperialskirtvest/hos
	name = "head of security's naval jumpsuit"
	desc = "A tar black naval skirt with a rank badge denoting the officer of The Internal Security Division. Be careful your underlings don't bump their head on a door."
	greyscale_colors = "#39393f#39393f#373741#f8d860#21212B#f8d860#a52f29"
	icon_state = "/obj/item/clothing/under/imperialskirtvest/hos"
	flags_1 = NONE

/obj/item/clothing/under/rank/security/head_of_security/nova/parade
	name = "head of security's parade uniform"
	desc = "A male head of security's luxury-wear, for special occasions."
	icon_state = "hos_parade_male_blue"
	inhand_icon_state = "r_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/head_of_security/nova/parade/female
	name = "head of security's formal uniform"
	desc = "A female head of security's luxury-wear, for special occasions."
	icon_state = "hos_parade_fem_blue"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/rank/security/head_of_security/nova/alt
	name = "head of security's turtleneck"
	desc = "A stylish alternative to the normal head of security jumpsuit, complete with tactical pants."
	icon_state = "hosalt_blue"
	inhand_icon_state = "bl_suit"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/head_of_security/nova/alt/skirt
	name = "head of security's turtleneck skirt"
	desc = "A stylish alternative to the normal head of security jumpsuit, complete with a tactical skirt."
	icon_state = "hosalt_skirt_blue"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/under/rank/security/nova/utility/syndicate
	armor_type = /datum/armor/clothing_under/sec_syndicate
	has_sensor = NO_SENSORS

/datum/armor/clothing_under/sec_syndicate
	melee = 10
	fire = 50
	acid = 40

/obj/item/clothing/under/rank/security/corrections_officer
	name = "corrections officer's suit"
	desc = "A white satin shirt with some bronze rank pins at the neck."
	icon = 'icons/obj/clothing/under/security_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/security_additions.dmi'
	icon_state = "corrections_officer"
	armor_type = /datum/armor/clothing_under/security_corrections_officer
	can_adjust = FALSE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/datum/armor/clothing_under/security_corrections_officer
	melee = 10

/obj/item/clothing/under/rank/security/corrections_officer/skirt
	name = "corrections officer's skirt"
	desc = "A white satin shirt with some bronze rank pins at the neck."
	icon_state = "corrections_officerw"
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/under/rank/security/corrections_officer/sweater
	name = "corrections officer's sweater"
	desc = "A black combat sweater thrown over the standard issue shirt, perfect for wake up calls."
	icon_state = "corrections_officer_sweat"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/corrections_officer/sweater/skirt
	icon_state = "corrections_officer_sweatw"
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/under/rank/security/armadyne
	name = "armadyne corporate uniform"
	desc = "A sleek uniform worn by Armadyne corporate. Its metallic red belt buckle is made in the shape of the Armadyne logo."
	icon_state = "armadyne_shirt"
	worn_icon_state = "armadyne_shirt"
	icon = 'icons/obj/clothing/under/centcom_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/centcom_additions.dmi'
	worn_icon_digi = 'icons/mob/clothing/under/centcom_digi.dmi'

/obj/item/clothing/under/rank/security/armadyne/tactical
	name = "armadyne tactical uniform"
	desc = "A robust tactical uniform worn by Armadyne corporate."
	icon_state = "armadyne_tac"
	worn_icon_state = "armadyne_tac"
