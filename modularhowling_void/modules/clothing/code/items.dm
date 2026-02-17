/*
*
*			ОБУВЬ
*
*/

/obj/item/clothing/shoes/jackboots/toeless
	name = "toe-less jackboots"
	desc = "Modified pair of jackboots, particularly friendly to those species whose toes hold claws."
	icon = 'modularhowling_void/modules/clothing/icons/obj/shoes.dmi'
	icon_state = "jackboots-toeless"
	worn_icon = 'modularhowling_void/modules/clothing/icons/mob/shoes.dmi'
	worn_icon_digi = 'modularhowling_void/modules/clothing/icons/mob/shoes_digi.dmi'

/obj/item/clothing/shoes/workboots/toeless
	name = "toe-less workboots"
	desc = "A pair of toe-less work boots designed for use in industrial settings. Modified for species whose toes have claws."
	icon = 'modularhowling_void/modules/clothing/icons/obj/shoes.dmi'
	icon_state = "workboots-toeless"
	worn_icon = 'modularhowling_void/modules/clothing/icons/mob/shoes.dmi'
	worn_icon_digi = 'modularhowling_void/modules/clothing/icons/mob/shoes_digi.dmi'

/obj/item/clothing/shoes/jackboots/tall
	name = "tall jackboots"
	desc = "A pair of knee-high jackboots, complete with heels. All style, all the time."
	icon = 'modularhowling_void/modules/clothing/icons/obj/shoes.dmi'
	icon_state = "jackboots-tall"
	worn_icon = 'modularhowling_void/modules/clothing/icons/mob/shoes.dmi'
	worn_icon_digi = 'modularhowling_void/modules/clothing/icons/mob/shoes_digi.dmi'

/obj/item/clothing/shoes/jackboots/tall/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('modularhowling_void/modules/clothing/sounds/footstep/highheel1.ogg' = 1,'modularhowling_void/modules/clothing/sounds/footstep/highheel2.ogg' = 1), 20)

/*
*
*			УНИФОРМА
*
*/

/obj/item/clothing/under/dress/bubber
	worn_icon = 'modularhowling_void/modules/clothing/icons/mob/skirts_dresses.dmi'
	icon = 'modularhowling_void/modules/clothing/icons/obj/skirts_dresses.dmi'
	name = "formal evening gown"
	desc = "A richly made dress of quality fabrics, but not much of them."
	icon_state = "dress_strapped"
	body_parts_covered = CHEST|GROIN|LEGS

/obj/item/clothing/under/dress/performer
	name = "colorable performers one piece"
	icon = 'modularhowling_void/modules/clothing/icons/obj/uniforms.dmi'
	worn_icon = 'modularhowling_void/modules/clothing/icons/mob/uniform.dmi'
	icon_state = "poly"
	can_adjust = FALSE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	flags_1 = IS_PLAYER_COLORABLE_1













