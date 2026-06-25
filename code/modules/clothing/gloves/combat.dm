/obj/item/clothing/gloves/combat
	name = "combat gloves"
	desc = "These tactical gloves are fireproof and electrically insulated."
	icon = 'icons/obj/clothing/gloves_additions.dmi'
	worn_icon = 'icons/mob/clothing/hands_additions.dmi'
	icon_state = "combat"
	worn_icon_teshari = TESHARI_HANDS_ICON
	greyscale_colors = "#2f2e31"
	siemens_coefficient = 0
	strip_delay = 8 SECONDS
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor_type = /datum/armor/gloves_combat
	clothing_traits = list(TRAIT_FAST_CUFFING)

/datum/armor/gloves_combat
	bio = 90
	fire = 80
	acid = 50

/obj/item/clothing/gloves/combat/maid
	name = "combat maid sleeves"
	desc = "These 'tactical' gloves and sleeves are fireproof and electrically insulated. Warm to boot."
	icon_state = "syndimaid_arms"

/obj/item/clothing/gloves/tactical_maid
	name = "tactical maid sleeves"
	desc = "These 'tactical' gloves and heavy and warm."
	icon = 'icons/obj/clothing/gloves_additions.dmi'
	worn_icon = 'icons/mob/clothing/hands_additions.dmi'
	icon_state = "syndimaid_arms"

/obj/item/clothing/gloves/kaza_ruk/combatglovesplus
	icon = 'icons/obj/clothing/gloves_additions.dmi'
	worn_icon = 'icons/mob/clothing/hands_additions.dmi'
	icon_state = "combat"

/obj/item/clothing/gloves/kaza_ruk/combatglovesplus/maa
	name = "master at arms' combat gloves"
	desc = "A set of combat gloves plus emblazoned with red knuckles, showing dedication to the trade while also hiding any blood left after use."
	icon_state = "maagloves"

/obj/item/clothing/gloves/combat/peacekeeper
	name = "peacekeeper gloves"
	desc = "These tactical gloves are fireproof."
	icon = 'icons/obj/clothing/gloves_additions.dmi'
	worn_icon = 'icons/mob/clothing/hands_additions.dmi'
	icon_state = "black_blue_gloves"
	worn_icon_state = "black_blue"
	siemens_coefficient = 0.5
	strip_delay = 20
	cold_protection = 0
	min_cold_protection_temperature = null
	heat_protection = 0
	max_heat_protection_temperature = null
	resistance_flags = FLAMMABLE
	armor_type = /datum/armor/none
	cut_type = null

/obj/item/clothing/gloves/combat/peacekeeper/stormtrooper
	name = "stormtrooper gloves"
	desc = "White gloves with some limited reflective armor."
	icon = 'icons/stormtrooper/items.dmi'
	worn_icon = 'icons/stormtrooper/hands.dmi'
	icon_state = "stormtrooper_gloves"
	worn_icon_state = "stormtrooper_gloves"

/obj/item/clothing/gloves/combat/armadyne
	name = "armadyne combat gloves"
	desc = "Tactical and sleek. Worn by Armadyne representatives."
	icon = 'icons/obj/clothing/gloves_additions.dmi'
	worn_icon = 'icons/mob/clothing/hands_additions.dmi'
	icon_state = "armadyne_gloves"
	worn_icon_state = "armadyne_gloves"
	cut_type = null

/obj/item/clothing/gloves/combat/wizard
	name = "enchanted gloves"
	desc = "These gloves have been enchanted with a spell that makes them electrically insulated and fireproof."
	icon = 'icons/obj/clothing/gloves.dmi'
	worn_icon = null
	icon_state = "wizard"
	greyscale_colors = null
	inhand_icon_state = null

/obj/item/clothing/gloves/combat/wizard/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/adjust_fishing_difficulty, -5) //something something wizard casting

/obj/item/clothing/gloves/combat/floortile
	name = "floortile camouflage gloves"
	desc = "Is it just me or is there a pair of gloves on the floor?"
	icon = 'icons/obj/clothing/gloves.dmi'
	worn_icon = null
	icon_state = "ftc_gloves"
	inhand_icon_state = "greyscale_gloves"

/obj/item/clothing/gloves/combat/floortile/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/adjust_fishing_difficulty, -5) //tacticool
