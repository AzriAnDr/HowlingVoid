/obj/item/clothing/under/costume
	icon = 'icons/obj/clothing/under/costume.dmi'
	worn_icon = 'icons/mob/clothing/under/costume.dmi'

/obj/item/clothing/under/costume/roman
	name = "\improper Roman armor"
	desc = "Ancient Roman armor. Made of metallic and leather straps."
	icon_state = "roman"
	inhand_icon_state = "armor"
	can_adjust = FALSE
	strip_delay = 10 SECONDS
	resistance_flags = NONE

/obj/item/clothing/under/costume/jabroni
	name = "jabroni outfit"
	desc = "The leather club is two sectors down."
	icon_state = "darkholme"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/owl
	name = "owl uniform"
	desc = "A soft brown jumpsuit made of synthetic feathers and strong conviction."
	icon_state = "owl"
	inhand_icon_state = "owl"
	can_adjust = FALSE

/obj/item/clothing/under/costume/griffin
	name = "griffon uniform"
	desc = "A soft brown jumpsuit with a white feather collar made of synthetic feathers and a lust for mayhem."
	icon_state = "griffin"
	can_adjust = FALSE

/obj/item/clothing/under/costume/seifuku
	name = "schoolgirl uniform"
	desc = "It's just like one of my Japanese animes!"
	greyscale_colors = "#942737#4A518D#EBEBEB"
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/seifuku"
	post_init_icon_state = "seifuku"
	greyscale_config_inhand_left = /datum/greyscale_config/seifuku_inhands_left
	greyscale_config_inhand_right = /datum/greyscale_config/seifuku_inhands_right
	inhand_icon_state = "seifuku"
	greyscale_config = /datum/greyscale_config/seifuku
	greyscale_config_worn = /datum/greyscale_config/seifuku/worn
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alternate_worn_layer = UNDER_SUIT_LAYER

/obj/item/clothing/under/costume/seifuku/red
	icon_state = "/obj/item/clothing/under/costume/seifuku/red"
	greyscale_colors = "#3F4453#BB2E2E#EBEBEB"

/obj/item/clothing/under/costume/seifuku/teal
	icon_state = "/obj/item/clothing/under/costume/seifuku/teal"
	greyscale_colors = "#942737#2BA396#EBEBEB"

/obj/item/clothing/under/costume/seifuku/tan
	icon_state = "/obj/item/clothing/under/costume/seifuku/tan"
	greyscale_colors = "#87502E#B9A56A#EBEBEB"

/obj/item/clothing/under/costume/pirate
	name = "pirate outfit"
	desc = "Yarr."
	icon_state = "pirate"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/soviet
	name = "soviet uniform"
	desc = "For the Motherland!"
	icon_state = "soviet"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/redcoat
	name = "redcoat uniform"
	desc = "Looks old."
	icon_state = "redcoat"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/kilt
	name = "kilt"
	desc = "Includes shoes and plaid."
	icon_state = "kilt"
	inhand_icon_state = "kilt"
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	can_adjust = FALSE

/obj/item/clothing/under/costume/kilt/highlander
	desc = "You're the only one worthy of this kilt."

/obj/item/clothing/under/costume/kilt/highlander/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HIGHLANDER_TRAIT)

/obj/item/clothing/under/costume/gladiator
	name = "gladiator uniform"
	desc = "Are you not entertained? Is that not why you are here?"
	icon_state = "gladiator"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = NO_FEMALE_UNIFORM
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/gladiator/ash_walker
	desc = "This gladiator uniform appears to be covered in ash and fairly dated."
	has_sensor = NO_SENSORS

/obj/item/clothing/under/costume/maid
	name = "maid costume"
	desc = "Maid in China."
	greyscale_colors = "#494955#EEEEEE"
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/maid"
	post_init_icon_state = "maid"
	greyscale_config = /datum/greyscale_config/maid
	greyscale_config_worn = /datum/greyscale_config/maid/worn
	greyscale_config_inhand_left = /datum/greyscale_config/maid_inhands_left
	greyscale_config_inhand_right = /datum/greyscale_config/maid_inhands_right
	inhand_icon_state = "maid"
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|GROIN
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	alternate_worn_layer = UNDER_SUIT_LAYER
	can_adjust = FALSE
	clothing_flags = parent_type::clothing_flags | CARP_STYLE_FACTOR //weebs are gonna love this

/obj/item/clothing/under/costume/geisha
	name = "geisha suit"
	desc = "Cute space ninja senpai not included."
	icon_state = "geisha"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	clothing_flags = parent_type::clothing_flags | CARP_STYLE_FACTOR

/obj/item/clothing/under/costume/yukata
	name = "black yukata"
	desc = "A comfortable black cotton yukata inspired by traditional designs, perfect for a non-formal setting."
	icon_state = "yukata1"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	clothing_flags = parent_type::clothing_flags | CARP_STYLE_FACTOR
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/costume/yukata/green
	name = "green yukata"
	desc = "A comfortable green cotton yukata inspired by traditional designs, perfect for a non-formal setting."
	icon_state = "yukata2"

/obj/item/clothing/under/costume/yukata/white
	name = "white yukata"
	desc = "A comfortable white cotton yukata inspired by traditional designs, perfect for a non-formal setting."
	icon_state = "yukata3"

/obj/item/clothing/under/costume/kimono
	name = "black kimono"
	desc = "A luxurious black silk kimono with traditional flair, ideal for elegant festive occasions."
	icon_state = "kimono1"
	inhand_icon_state = "yukata1"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	clothing_flags = parent_type::clothing_flags | CARP_STYLE_FACTOR
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/costume/kimono/red
	name = "red kimono"
	desc = "A luxurious red silk kimono with traditional flair, ideal for elegant festive occasions."
	icon_state = "kimono2"
	inhand_icon_state = "kimono2"

/obj/item/clothing/under/costume/kimono/purple
	name = "purple kimono"
	desc = "A luxurious purple silk kimono with traditional flair, ideal for elegant festive occasions."
	icon_state = "kimono3"
	inhand_icon_state = "kimono3"

/obj/item/clothing/under/costume/villain
	name = "villain suit"
	desc = "A change of wardrobe is necessary if you ever want to catch a real superhero."
	icon_state = "villain"
	can_adjust = FALSE

/obj/item/clothing/under/costume/sailor
	name = "sailor suit"
	desc = "Skipper's in the wardroom drinkin' gin."
	icon_state = "sailor"
	inhand_icon_state = "b_suit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/singer
	abstract_type = /obj/item/clothing/under/costume/singer
	desc = "Just looking at this makes you want to sing."
	body_parts_covered = CHEST|GROIN|ARMS
	alternate_worn_layer = ABOVE_SHOES_LAYER
	can_adjust = FALSE

/obj/item/clothing/under/costume/singer/yellow
	name = "yellow performer's outfit"
	icon_state = "ysing"
	inhand_icon_state = null
	female_sprite_flags = NO_FEMALE_UNIFORM

/obj/item/clothing/under/costume/singer/blue
	name = "blue performer's outfit"
	icon_state = "bsing"
	inhand_icon_state = null
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/costume/singer/red
	name = "red performer's outfit"
	icon_state = "rsing"
	inhand_icon_state = null
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/costume/mummy
	name = "mummy wrapping"
	desc = "Return the slab or suffer my stale references."
	icon_state = "mummy"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/scarecrow
	name = "scarecrow clothes"
	desc = "Perfect camouflage for hiding in botany."
	icon_state = "scarecrow"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/draculass
	name = "draculass coat"
	desc = "A dress inspired by the ancient \"Victorian\" era."
	icon_state = "draculass"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	can_adjust = FALSE

/obj/item/clothing/under/costume/drfreeze
	name = "doctor freeze's jumpsuit"
	desc = "A modified scientist jumpsuit to look extra cool."
	icon_state = "drfreeze"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/lobster
	name = "foam lobster suit"
	desc = "Who beheaded the college mascot?"
	icon_state = "lobster"
	inhand_icon_state = null
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/costume/gondola
	name = "gondola hide suit"
	desc = "Now you're cooking."
	icon_state = "gondola"
	inhand_icon_state = "lb_suit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/skeleton
	name = "skeleton jumpsuit"
	desc = "A black jumpsuit with a white bone pattern printed on it. Spooky!"
	icon_state = "skeleton"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

// Mech suit skins
/datum/atom_skin/mech_suit
	abstract_type = /datum/atom_skin/mech_suit

/datum/atom_skin/mech_suit/red
	preview_name = "Red"
	new_icon_state = "red_mech_suit"

/datum/atom_skin/mech_suit/white
	preview_name = "White"
	new_icon_state = "white_mech_suit"

/datum/atom_skin/mech_suit/blue
	preview_name = "Blue"
	new_icon_state = "blue_mech_suit"

/datum/atom_skin/mech_suit/black
	preview_name = "Black"
	new_icon_state = "black_mech_suit"

/obj/item/clothing/under/costume/mech_suit
	name = "mech pilot's suit"
	desc = "A mech pilot's suit. Might make your butt look big."
	icon_state = "red_mech_suit"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	female_sprite_flags = NO_FEMALE_UNIFORM
	alternate_worn_layer = GLOVES_LAYER //covers hands but gloves can go over it. This is how these things work in my head.
	can_adjust = FALSE

/obj/item/clothing/under/costume/mech_suit/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/mech_suit)

/obj/item/clothing/under/costume/russian_officer
	name = "\improper Russian officer's uniform"
	desc = "The latest in fashionable russian outfits."
	icon = 'icons/obj/clothing/under/security.dmi'
	icon_state = "hostanclothes"
	inhand_icon_state = null
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	alt_covers_chest = TRUE
	armor_type = /datum/armor/clothing_under/costume_russian_officer
	strip_delay = 5 SECONDS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	can_adjust = FALSE

/datum/armor/clothing_under/costume_russian_officer
	melee = 10
	fire = 30
	acid = 30

/obj/item/clothing/under/costume/buttondown
	gender = PLURAL
	female_sprite_flags = NO_FEMALE_UNIFORM
	custom_price = PAYCHECK_CREW
	icon = 'icons/obj/clothing/under/shorts_pants_shirts.dmi'
	worn_icon = 'icons/mob/clothing/under/shorts_pants_shirts.dmi'
	species_exception = list(/datum/species/golem)
	can_adjust = TRUE
	alt_covers_chest = TRUE
	clothing_flags = parent_type::clothing_flags | CARP_STYLE_FACTOR

/obj/item/clothing/under/costume/buttondown/slacks
	name = "button-down shirt with slacks"
	desc = "A fancy button-down shirt with slacks."
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/buttondown/slacks"
	post_init_icon_state = "buttondown_slacks"
	greyscale_config = /datum/greyscale_config/buttondown_slacks
	greyscale_config_worn = /datum/greyscale_config/buttondown_slacks/worn
	greyscale_config_worn_digi = /datum/greyscale_config/buttondown_slacks/worn/digi //NOVA EDIT ADDITION - Mutant Greyscale
	greyscale_colors = "#EEEEEE#EE8E2E#222227#D8D39C"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/buttondown/slacks/service //preset one to be a formal white shirt and black pants
	icon_state = "/obj/item/clothing/under/costume/buttondown/slacks/service"
	greyscale_colors = "#EEEEEE#CBDBFC#17171B#222227"

/obj/item/clothing/under/costume/buttondown/shorts
	name = "button-down shirt with shorts"
	desc = "A fancy button-down shirt with shorts."
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/buttondown/shorts"
	post_init_icon_state = "buttondown_shorts"
	greyscale_config = /datum/greyscale_config/buttondown_shorts
	greyscale_config_worn = /datum/greyscale_config/buttondown_shorts/worn
	greyscale_config_worn_digi = /datum/greyscale_config/buttondown_shorts/worn/digi //NOVA EDIT ADDITION - Mutant Greyscale
	greyscale_colors = "#EEEEEE#EE8E2E#222227#D8D39C"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/buttondown/skirt
	name = "button-down shirt with skirt"
	desc = "A fancy button-down shirt with skirt."
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/buttondown/skirt"
	post_init_icon_state = "buttondown_skirt"
	greyscale_config = /datum/greyscale_config/buttondown_skirt
	greyscale_config_worn = /datum/greyscale_config/buttondown_skirt/worn
	greyscale_colors = "#EEEEEE#EE8E2E#222227#D8D39C"
	body_parts_covered = CHEST|GROIN|ARMS
	flags_1 = IS_PLAYER_COLORABLE_1
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/costume/buttondown/skirt/service //preset one to be a formal white shirt and black skirt
	icon_state = "/obj/item/clothing/under/costume/buttondown/skirt/service"
	greyscale_colors = "#EEEEEE#CBDBFC#17171B#222227"

/obj/item/clothing/under/costume/jackbros
	name = "jack bros outfit"
	desc = "For when it's time to hee some hos."
	icon_state = "JackFrostUniform"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/deckers
	name = "deckers outfit"
	icon_state = "decker_jumpsuit"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/football_suit
	name = "football uniform"
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/football_suit"
	post_init_icon_state = "football_suit"
	can_adjust = FALSE
	greyscale_config = /datum/greyscale_config/football_suit
	greyscale_config_worn = /datum/greyscale_config/football_suit/worn
	greyscale_config_worn_digi = /datum/greyscale_config/football_suit/worn/digi //NOVA EDIT ADDITION - Mutant Greyscale
	greyscale_colors = "#D74722"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/swagoutfit
	name = "Swag outfit"
	desc = "Why don't you go secure some bitches?"
	icon_state = "SwagOutfit"
	inhand_icon_state = null
	can_adjust = FALSE
	clothing_flags = parent_type::clothing_flags | CARP_STYLE_FACTOR

/obj/item/clothing/under/costume/referee
	name = "referee uniform"
	desc = "A standard black and white striped uniform to signal authority."
	icon_state = "referee"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/joker
	name = "comedian suit"
	desc = "The worst part of having a mental illness is people expect you to behave as if you don't."
	icon_state = "joker"
	can_adjust = FALSE

/obj/item/clothing/under/costume/yuri
	name = "yuri initiate jumpsuit"
	icon_state = "yuri_uniform"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/dutch
	name = "dutch's suit"
	desc = "You can feel a <b>god damn plan</b> coming on."
	icon_state = "DutchUniform"
	inhand_icon_state = null
	can_adjust = FALSE

// For the nuke-ops cowboy fit. Sadly no Lone Ranger fit & I don't wanna bloat costume files further.
/obj/item/clothing/under/costume/dutch/syndicate
	desc = "You can feel a <b>god damn plan</b> coming on, and the armor lining in this suit'll do wonders in makin' it work."
	armor_type = /datum/armor/clothing_under/syndicate

/obj/item/clothing/under/costume/osi
	name = "O.S.I. jumpsuit"
	icon_state = "osi_jumpsuit"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/tmc
	name = "Lost MC clothing"
	icon_state = "tmc_jumpsuit"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/gi
	name = "martial gi"
	desc = "Assistant, nukie, whatever. You can beat anyone; it's called hard work!"
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/gi"
	post_init_icon_state = "martial_arts_gi"
	greyscale_config = /datum/greyscale_config/gi
	greyscale_config_worn = /datum/greyscale_config/gi/worn
	greyscale_colors = "#f1eeee#000000"
	flags_1 = IS_PLAYER_COLORABLE_1
	inhand_icon_state = null
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	clothing_flags = parent_type::clothing_flags | CARP_STYLE_FACTOR

/obj/item/clothing/under/costume/gi/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/gags_recolorable)
	update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/under/costume/gi/goku
	name = "sacred gi"
	desc = "Created by a man who touched the hearts and lives of many."
	icon_state = "/obj/item/clothing/under/costume/gi/goku"
	post_init_icon_state = "martial_arts_gi_goku"
	greyscale_colors = "#f89925#3e6dd7"

/obj/item/clothing/under/costume/traditional
	name = "traditional suit"
	desc = "A full, vibrantly coloured suit. Likely with traditional purposes. Maybe the colours represent a family, clan, or rank, who knows."
	icon_state = "tradition"
	inhand_icon_state = null
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/costume/loincloth
	name = "leather loincloth"
	desc = "Just a piece of leather to cover private areas. Itchy to the touch. Whoever made this must have been desperate, or savage."
	icon_state = "loincloth"
	inhand_icon_state = null
	body_parts_covered = GROIN
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/costume/henchmen
	name = "henchmen jumpsuit"
	desc = "A very gaudy jumpsuit for a proper Henchman. Guild regulations, you understand."
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	worn_icon = 'icons/mob/clothing/under/syndicate.dmi'
	icon_state = "henchmen"
	inhand_icon_state = null
	can_adjust = FALSE
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS|HEAD
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEEARS|HIDEEYES|HIDEHAIR

/obj/item/clothing/under/costume/gamberson
	name = "re-enactor's gambeson"
	desc = "A colorful set of clothes made to look like a medieval gambeson."
	icon_state = "gamberson"
	inhand_icon_state = null
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/costume/gamberson/military
	name = "swordsman's gambeson"
	desc = "A padded medieval gambeson. Has enough woolen layers to dull a strike from any small weapon."
	armor_type = /datum/armor/clothing_under/rank_security
	has_sensor = NO_SENSORS

/obj/item/clothing/under/costume/captain
	name = "captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "green_suit"
	inhand_icon_state = "dg_suit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/captain/skirt
	name = "green suitskirt"
	desc = "A green suitskirt and yellow necktie. Exemplifies authority."
	icon_state = "green_suit_skirt"
	inhand_icon_state = "dg_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/costume/head_of_personnel
	name = "head of personnel's suit"
	desc = "A teal suit and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "teal_suit"
	inhand_icon_state = "g_suit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/head_of_personnel/skirt
	name = "teal suitskirt"
	desc = "A teal suitskirt and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "teal_suit_skirt"
	inhand_icon_state = "g_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON


// BEGIN NOVA CORE MIGRATION: code/modules/clothing/under/costume.dm
/obj/item/clothing/under/costume
	worn_icon_digi = 'icons/mob/clothing/under/costume_digi.dmi'

/obj/item/clothing/under/costume/russian_officer
	worn_icon_digi = 'icons/mob/clothing/under/security_digi.dmi'

/obj/item/clothing/under/costume/nova
	icon = 'icons/obj/clothing/under/costume_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/costume_additions.dmi'
	can_adjust = FALSE

//My least favorite file. Just... try to keep it sorted. And nothing over the top

/*
*	UNSORTED
*/
/obj/item/clothing/under/costume/nova/cavalry
	name = "cavalry uniform"
	desc = "Dedicate yourself to something better. To loyalty, honour, for it only dies when everyone abandons it."
	icon_state = "cavalry" //specifically an 1890s US Army Cavalry Uniform

/obj/item/clothing/under/costume/deckers/alt //not even going to bother re-pathing this one because it's such a unique case of 'TGs item has something but this alt doesnt'
	name = "deckers maskless outfit"
	desc = "A decker jumpsuit with neon blue coloring."
	icon = 'icons/obj/clothing/under/costume_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/costume_additions.dmi'
	worn_icon_digi = 'icons/mob/clothing/under/costume_digi.dmi'
	icon_state = "decking_jumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/nova/bathrobe
	name = "bathrobe"
	desc = "A warm fluffy bathrobe, perfect for relaxing after finally getting clean."
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/nova/bathrobe"
	post_init_icon_state = "robes"
	worn_icon = 'icons/GAGS/suit/suit.dmi'
	worn_icon_teshari = 'icons/GAGS/suit/suit_teshari.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	greyscale_colors = "#ffffff"
	greyscale_config = /datum/greyscale_config/bathrobe
	greyscale_config_worn = /datum/greyscale_config/bathrobe/worn
	greyscale_config_worn_teshari = /datum/greyscale_config/bathrobe/worn/teshari
	greyscale_config_worn_better_vox = /datum/greyscale_config/bathrobe/worn/newvox
	greyscale_config_worn_vox = /datum/greyscale_config/bathrobe/worn/oldvox
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	greyscale_colors = "#434d7a" //THATS RIGHT, FUCK YOU! THE BATHROBE CAN BE RECOLORED!
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/dutch
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/dutch"
	post_init_icon_state = "dutchsuit"
	greyscale_config = /datum/greyscale_config/dutch_outfit
	greyscale_config_worn = /datum/greyscale_config/dutch_outfit/worn
	greyscale_config_worn_digi = /datum/greyscale_config/dutch_outfit/worn/digi
	greyscale_colors = "#333333#f8f8f8#ff0000#ffcc00"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/dutch/syndicate
	post_init_icon_state = null
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digi = null
	greyscale_colors = null

/obj/item/clothing/suit/costume/pg
	icon = 'icons/map_icons/clothing/suit/costume.dmi'
	icon_state = "/obj/item/clothing/suit/costume/pg"
	post_init_icon_state = "powderganger"
	greyscale_config = /datum/greyscale_config/powderganger
	greyscale_config_worn = /datum/greyscale_config/powderganger/worn
	greyscale_colors = "#76502b#c0c0c0"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/chaplainsuit/monkrobeeast
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/chaplainsuit/monkrobeeast"
	post_init_icon_state = "monkrobeeast"
	greyscale_config = /datum/greyscale_config/monkrobeeast
	greyscale_config_worn = /datum/greyscale_config/monkrobeeast/worn
	greyscale_config_worn_digi = /datum/greyscale_config/monkrobeeast/worn/digi
	greyscale_colors = "#EADB83#D98E43#A52F29#212026"
	flags_1 = IS_PLAYER_COLORABLE_1
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/*
*	LUNAR AND JAPANESE CLOTHES
*/

/obj/item/clothing/under/costume/nova/qipao
	name = "qipao"
	desc = "A qipao, traditionally worn in ancient Earth China by women during social events and lunar new years."
	body_parts_covered = CHEST|GROIN|LEGS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	greyscale_colors = "#2b2b2b"
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/nova/qipao"
	post_init_icon_state = "qipao"
	greyscale_config = /datum/greyscale_config/qipao
	greyscale_config_worn = /datum/greyscale_config/qipao/worn
	greyscale_config_worn_digi = /datum/greyscale_config/qipao/worn/digi
	flags_1 = IS_PLAYER_COLORABLE_1
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/under/costume/nova/qipao/customtrim
	greyscale_colors = "#2b2b2b#ffce5b"
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/nova/qipao/customtrim"
	post_init_icon_state = "qipao"
	greyscale_config = /datum/greyscale_config/qipao_customtrim
	greyscale_config_worn = /datum/greyscale_config/qipao_customtrim/worn
	greyscale_config_worn_digi = /datum/greyscale_config/qipao_customtrim/worn/digi

/obj/item/clothing/under/costume/nova/cheongsam
	name = "cheongsam"
	desc = "A cheongsam, traditionally worn in ancient Earth China by men during social events and lunar new years."
	body_parts_covered = CHEST|GROIN|LEGS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	greyscale_colors = "#2b2b2b#353535"
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/nova/cheongsam"
	post_init_icon_state = "cheongsam"
	greyscale_config = /datum/greyscale_config/cheongsam
	greyscale_config_worn = /datum/greyscale_config/cheongsam/worn
	greyscale_config_worn_digi = /datum/greyscale_config/cheongsam/worn/digi
	flags_1 = IS_PLAYER_COLORABLE_1
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/under/costume/nova/cheongsam/customtrim
	greyscale_colors = "#2b2b2b#ffce5b#353535"
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/nova/cheongsam/customtrim"
	post_init_icon_state = "cheongsam"
	greyscale_config = /datum/greyscale_config/cheongsam_customtrim
	greyscale_config_worn = /datum/greyscale_config/cheongsam_customtrim/worn
	greyscale_config_worn_digi = /datum/greyscale_config/cheongsam_customtrim/worn/digi

/obj/item/clothing/under/costume/nova/yukata
	name = "yukata"
	desc = "A traditional ancient Earth Japanese yukata, typically worn in casual settings."
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	greyscale_colors = "#2b2b2b#666666"
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/nova/yukata"
	post_init_icon_state = "yukata"
	greyscale_config = /datum/greyscale_config/yukata
	greyscale_config_worn = /datum/greyscale_config/yukata/worn
	greyscale_config_worn_digi = /datum/greyscale_config/yukata/worn/digi
	flags_1 = IS_PLAYER_COLORABLE_1
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/under/costume/nova/kamishimo
	name = "kamishimo"
	desc = "A traditional ancient Earth Japanese Kamishimo."
	icon_state = "kamishimo"

/obj/item/clothing/under/costume/nova/kimono
	name = "fancy kimono"
	desc = "A traditional ancient Earth Japanese Kimono. Longer and fancier than a yukata."
	icon_state = "kimono"
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/costume/nova/shihakusho
	name = "shihakusho"
	desc = "A traditional ancient Earth Japanese Shihakusho."
	icon_state = "shihakusho"
	body_parts_covered = CHEST|GROIN|ARMS

/obj/item/clothing/under/costume/nova/chima_jeogori
	name = "chima jeogori"
	desc = "Traditional Korean clothes, often worn as formal attire."
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/nova/chima_jeogori"
	post_init_icon_state = "chima_jeogori"
	greyscale_config = /datum/greyscale_config/chima_jeogori
	greyscale_config_worn = /datum/greyscale_config/chima_jeogori/worn
	greyscale_colors = "#a52f29#2ba396#545461#88242d#eeeeee"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alternate_worn_layer = UNDER_SUIT_LAYER
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	flags_1 = IS_PLAYER_COLORABLE_1

/*
*	CHRISTMAS CLOTHES
*/

/obj/item/clothing/under/costume/nova/christmas
	name = "christmas costume"
	desc = "Can you believe it guys? Christmas. Just a lightyear away!" //Lightyear is a measure of distance I hate it being used for this joke :(
	greyscale_colors = "#cc0f0f#c4c2c2"
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	icon_state = "/obj/item/clothing/under/costume/nova/christmas"
	post_init_icon_state = "christmas_male"
	greyscale_config = /datum/greyscale_config/chrimbo
	greyscale_config_worn = /datum/greyscale_config/chrimbo/worn
	greyscale_config_worn_digi = /datum/greyscale_config/chrimbo/worn/digi
	body_parts_covered = CHEST|GROIN|ARMS
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/nova/christmas/croptop
	name = "sexy christmas costume"
	desc = "About 550 years since the release of Mariah Carey's \"All I Want For Christmas is You\", society has yet to properly recover from its repercussions. Some still keep a gun as their christmas mantlepiece, just in case she's heard singing on their rooftop late in the night..."
	greyscale_colors = "#cc0f0f#c4c2c2"
	icon_state = "/obj/item/clothing/under/costume/nova/christmas/croptop"
	post_init_icon_state = "christmas_female"
	greyscale_config = /datum/greyscale_config/chrimbo
	greyscale_config_worn = /datum/greyscale_config/chrimbo/worn
	greyscale_config_worn_digi = /datum/greyscale_config/chrimbo/worn/digi
	body_parts_covered = CHEST|GROIN
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	flags_1 = IS_PLAYER_COLORABLE_1

/*
*	TREK CLOTHES
*/
/obj/item/clothing/under/trek/command
	greyscale_config_worn_digi = /datum/greyscale_config/trek/worn/digi
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/trek/engsec
	greyscale_config_worn_digi = /datum/greyscale_config/trek/worn/digi
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/trek/medsci
	greyscale_config_worn_digi = /datum/greyscale_config/trek/worn/digi
	flags_1 = IS_PLAYER_COLORABLE_1
// END NOVA CORE MIGRATION: code/modules/clothing/under/costume.dm
