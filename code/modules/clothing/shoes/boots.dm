/obj/item/clothing/shoes/combat //basic syndicate combat boots for nuke ops and mob corpses
	name = "combat boots"
	desc = "High speed, low drag combat boots."
	icon = 'icons/obj/clothing/shoes_additions.dmi'
	worn_icon = 'icons/mob/clothing/feet_additions.dmi'
	icon_state = "combat"
	inhand_icon_state = "jackboots"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	body_parts_covered = FEET|LEGS
	armor_type = /datum/armor/shoes_combat
	strip_delay = 4 SECONDS
	resistance_flags = NONE
	lace_time = 12 SECONDS

/datum/armor/shoes_combat
	melee = 25
	bullet = 25
	laser = 25
	energy = 25
	bomb = 50
	bio = 90
	fire = 70
	acid = 50

/obj/item/clothing/shoes/combat/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/shoes)
	AddElement(/datum/element/ignites_matches)

/obj/item/clothing/shoes/combat/swat //overpowered boots for death squads
	name = "\improper SWAT boots"
	desc = "High speed, no drag combat boots."
	clothing_traits = list(TRAIT_NO_SLIP_WATER)
	armor_type = /datum/armor/combat_swat

/datum/armor/combat_swat
	melee = 40
	bullet = 30
	laser = 25
	energy = 25
	bomb = 50
	bio = 100
	fire = 90
	acid = 50

/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "jackboots"
	inhand_icon_state = "jackboots"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	clothing_traits = list(TRAIT_SILENT_FOOTSTEPS)
	strip_delay = 3 SECONDS
	equip_delay_other = 5 SECONDS
	resistance_flags = NONE
	armor_type = /datum/armor/shoes_jackboots
	fastening_type = SHOES_SLIPON
	body_parts_covered = FEET|LEGS

/datum/armor/shoes_jackboots
	bio = 90

/obj/item/clothing/shoes/jackboots/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/shoes)
	AddElement(/datum/element/ignites_matches)
	AddComponent(/datum/component/squeak, list('sound/effects/footstep1.ogg' = 1, 'sound/effects/footstep2.ogg' = 1, 'sound/effects/footstep3.ogg' = 1), 100)

/obj/item/clothing/shoes/jackboots/fast
	slowdown = -1

/obj/item/clothing/shoes/jackboots/sec
	icon_state = "jackboots_sec"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/datum/atom_skin/security_jackboots
	abstract_type = /datum/atom_skin/security_jackboots

/datum/atom_skin/security_jackboots/blue_trim
	preview_name = "Blue-Trimmed Variant"
	new_icon_state = "security_boots"

/datum/atom_skin/security_jackboots/white_trim
	preview_name = "White-Trimmed Variant"
	new_icon_state = "security_boots_white"

/datum/atom_skin/security_jackboots/fullwhite
	preview_name = "Full White Variant"
	new_icon_state = "security_boots_fullwhite"

/obj/item/clothing/shoes/jackboots/sec/blue
	icon = 'icons/obj/clothing/shoes_additions.dmi'
	worn_icon = 'icons/mob/clothing/feet_additions.dmi'
	icon_state = "security_boots"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/shoes/jackboots/sec/blue/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/security_jackboots)

/obj/item/clothing/shoes/jackboots/peacekeeper
	name = "peacekeeper boots"
	desc = "High speed, low drag combat boots."
	icon = 'icons/obj/clothing/shoes_additions.dmi'
	worn_icon = 'icons/mob/clothing/feet_additions.dmi'
	icon_state = "peacekeeper"

/obj/item/clothing/shoes/jackboots/tall
	name = "tall jackboots"
	desc = "A pair of knee-high jackboots, complete with heels. All style, all the time."
	icon_state = "jackboots-tall"
	worn_icon_digi = DIGITIGRADE_SHOES_FILE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/shoes/jackboots/tall/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/footstep/highheel1.ogg' = 1, 'sound/effects/footstep/highheel2.ogg' = 1), 20)

/obj/item/clothing/shoes/jackboots/floortile
	name = "floortile camouflage jackboots"
	desc = "Is it just me or is there a pair of jackboots on the floor?"
	icon_state = "ftc_boots"
	inhand_icon_state = null
	supports_variations_flags = NONE

/obj/item/clothing/shoes/jackboots/floortile/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/adjust_fishing_difficulty, -5) //tacticool

/obj/item/clothing/shoes/winterboots
	name = "winter boots"
	desc = "Boots lined with 'synthetic' animal fur."
	icon_state = "winterboots"
	inhand_icon_state = null
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	armor_type = /datum/armor/shoes_winterboots
	cold_protection = FEET|LEGS
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET|LEGS
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	lace_time = 8 SECONDS

/datum/armor/shoes_winterboots
	bio = 80

/obj/item/clothing/shoes/winterboots/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/shoes)
	AddElement(/datum/element/ignites_matches)

/obj/item/clothing/shoes/winterboots/ice_boots
	name = "ice hiking boots"
	desc = "A pair of winter boots with special grips on the bottom, designed to prevent slipping on frozen surfaces."
	icon_state = "iceboots"
	inhand_icon_state = null
	clothing_traits = list(TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE)

// A pair of ice boots intended for general crew EVA use - see EVA winter coat for comparison.
/obj/item/clothing/shoes/winterboots/ice_boots/eva
	name = "\proper Endotherm hiking boots"
	desc = "A heavy pair of boots with grips applied to the bottom to keep the wearer vertical while walking in freezing conditions."
	icon_state = "iceboots_eva"
	w_class = WEIGHT_CLASS_BULKY
	slowdown = 0.25
	armor_type = /datum/armor/ice_boots_eva
	strip_delay = 4 SECONDS
	equip_delay_other = 4 SECONDS
	clothing_flags = parent_type::clothing_flags | THICKMATERIAL
	body_parts_covered = FEET|LEGS
	resistance_flags = NONE

/datum/armor/ice_boots_eva
	melee = 10
	laser = 10
	energy = 10
	bio = 50
	fire = 50
	acid = 10

/obj/item/clothing/shoes/workboots
	name = "work boots"
	desc = "Nanotrasen-issue Engineering lace-up work boots for the especially blue-collar."
	icon_state = "workboots"
	inhand_icon_state = "jackboots"
	armor_type = /datum/armor/shoes_workboots
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	strip_delay = 2 SECONDS
	equip_delay_other = 4 SECONDS
	lace_time = 8 SECONDS

/datum/armor/shoes_workboots
	bio = 80

/obj/item/clothing/shoes/workboots/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/shoes)
	AddElement(/datum/element/ignites_matches)

/obj/item/clothing/shoes/workboots/mining
	name = "mining boots"
	desc = "Steel-toed mining boots for mining in hazardous environments. Very good at keeping toes uncrushed."
	icon_state = "explorer"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/shoes/workboots/black
	name = "tactical work boots"
	desc = "Lace-up work boots to protect the average grey-collar worker from stepping on hazards, from broken glass to dropped pens."
	icon_state = "workboots_black"

/obj/item/clothing/shoes/russian
	name = "russian boots"
	desc = "Comfy shoes."
	icon_state = "rus_shoes"
	inhand_icon_state = null
	lace_time = 8 SECONDS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/shoes/russian/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/shoes)
	AddElement(/datum/element/ignites_matches)

/obj/item/clothing/shoes/discoshoes
	name = "green lizardskin shoes"
	desc = "They may have lost some of their lustre over the years, but these green lizardskin shoes fit you perfectly."
	icon_state = "lizardskin_shoes"
	inhand_icon_state = null

/obj/item/clothing/shoes/jackboots/kim
	name = "aerostatic boots"
	desc = "A crisp, clean set of boots for working long hours on the beat."
	icon_state = "aerostatic_boots"
	inhand_icon_state = null

/obj/item/clothing/shoes/jackboots/armadyne
	name = "armadyne combat boots"
	desc = "Tactical and sleek. Worn by Armadyne representatives."
	icon = 'icons/obj/clothing/shoes_additions.dmi'
	worn_icon = 'icons/mob/clothing/feet_additions.dmi'
	icon_state = "armadyne_boots"
	inhand_icon_state = "jackboots"
	worn_icon_state = "armadyne_boots"

/obj/item/clothing/shoes/pirate
	name = "pirate boots"
	desc = "Yarr."
	icon_state = "pirateboots"
	inhand_icon_state = null

/obj/item/clothing/shoes/pirate/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/adjust_fishing_difficulty, -4)

/obj/item/clothing/shoes/pirate/armored
	armor_type = /datum/armor/shoes_pirate
	strip_delay = 4 SECONDS
	resistance_flags = NONE
	lace_time = 12 SECONDS
	body_parts_covered = FEET|LEGS

/datum/armor/shoes_pirate
	melee = 25
	bullet = 25
	laser = 25
	energy = 25
	bomb = 50
	bio = 90
	fire = 70
	acid = 50


// BEGIN NOVA CORE MIGRATION: code/modules/clothing/shoes/boots.dm
/obj/item/clothing/shoes/gunboots/dm
	projectile_type = /obj/projectile/beam/laser

/obj/item/clothing/shoes/combat/stormtrooper
	name = "stormtrooper boots"
	desc = "A pair of white boots."
	icon = 'icons/stormtrooper/items.dmi'
	worn_icon = 'icons/stormtrooper/feet.dmi'
	icon_state = "stormtrooper_boots"
	armor_type = /datum/armor/none
	strip_delay = 30
	equip_delay_other = 50
	resistance_flags = NONE
	fastening_type = SHOES_SLIPON
	supports_variations_flags = NONE
// END NOVA CORE MIGRATION: code/modules/clothing/shoes/boots.dm
