/obj/item/clothing/suit
	name = "suit"
	icon = 'icons/obj/clothing/suits/default.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	abstract_type = /obj/item/clothing/suit
	var/fire_resist = T0C+100
	allowed = list(
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/tank/jetpack/captain,
		/obj/item/storage/belt/holster,
		/obj/item/cane, // NOVA EDIT ADDITION
	)
	armor_type = /datum/armor/none
	drop_sound = 'sound/items/handling/cloth/cloth_drop1.ogg'
	pickup_sound = 'sound/items/handling/cloth/cloth_pickup1.ogg'
	slot_flags = ITEM_SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	limb_integrity = 0 // disabled for most exo-suits

/obj/item/clothing/suit/worn_overlays(mutable_appearance/standing, isinhands = FALSE, file2use = null, mutant_styles = NONE) // NOVA EDIT CHANGE - TAURS AND TESHIS - ORIGINAL: /obj/item/clothing/suit/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return

	if(damaged_clothes)
		//. += mutable_appearance('icons/effects/item_damage.dmi', "damaged[blood_overlay_type]") // NOVA EDIT REMOVAL
		// NOVA EDIT ADDITION BEGIN
		var/damagefile2use = (mutant_styles & STYLE_TAUR_ALL) ? 'icons/mob/64x32_item_damage.dmi' : 'icons/effects/item_damage.dmi'
		. += mutable_appearance(damagefile2use, "damaged[blood_overlay_type]")
		//NOVA EDIT ADDITION END

	var/mob/living/carbon/human/wearer = loc
	if(!ishuman(wearer) || !wearer.w_uniform)
		return
	var/obj/item/clothing/under/undershirt = wearer.w_uniform
	if(!istype(undershirt) || !LAZYLEN(undershirt.attached_accessories))
		return

	var/obj/item/clothing/accessory/displayed = undershirt.attached_accessories[1]
	if(displayed.above_suit && undershirt.accessory_overlay)
		. += undershirt.modify_accessory_overlay() // NOVA EDIT CHANGE - ORIGINAL: . += undershirt.accessory_overlay

/obj/item/clothing/suit/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands = FALSE, icon_file, mutant_styles) // NOVA EDIT CHANGE - ORIGINAL: separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands = FALSE, icon_file)
	. = ..()
	if (isinhands)
		return
	var/blood_overlay = get_blood_overlay(blood_overlay_type, mutant_styles) // NOVA EDIT CHANGE - ORIGINAL: var/blood_overlay = get_blood_overlay(blood_overlay_type)
	if (blood_overlay)
		. += blood_overlay

/obj/item/clothing/suit/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_worn_oversuit()

/obj/item/clothing/suit/generate_digitigrade_icons(icon/base_icon, greyscale_colors)
	var/icon/legs = icon(SSgreyscale.GetColoredIconByType(/datum/greyscale_config/digitigrade, greyscale_colors), "oversuit_worn")
	return replace_icon_legs(base_icon, legs)


// BEGIN NOVA CORE MIGRATION: code/modules/clothing/suits/_suits.dm
/obj/item/clothing/suit
	/// Does this object get cropped when worn by a taur on their suit or uniform slot?
	var/gets_cropped_on_taurs = TRUE

// taur suit blood overlays
/obj/item/clothing/suit/get_blood_overlay(blood_state, mutant_styles)
	if(!(mutant_styles & STYLE_TAUR_ALL))
		return ..()
	if(!GET_ATOM_BLOOD_DNA_LENGTH(src))
		return

	var/mutable_appearance/blood_overlay = mutable_appearance('icons/mob/64x32_blood.dmi', "[blood_overlay_type]blood")
	if(!has_taur_worn_icon(mutant_styles))
		blood_overlay.pixel_w = -16

	blood_overlay.color = get_blood_dna_color()

	var/emissive_alpha = get_blood_emissive_alpha(is_worn = TRUE)
	if (emissive_alpha)
		var/mutable_appearance/emissive_overlay = emissive_appearance(blood_overlay.icon, blood_overlay.icon_state, src, alpha = emissive_alpha)
		blood_overlay.overlays += emissive_overlay

	return blood_overlay

/obj/item/clothing/suit/proc/has_taur_worn_icon(mutant_styles)
	if((mutant_styles & STYLE_TAUR_SNAKE) && worn_icon_taur_snake)
		return TRUE
	if((mutant_styles & STYLE_TAUR_PAW) && worn_icon_taur_paw)
		return TRUE
	if((mutant_styles & STYLE_TAUR_HOOF) && worn_icon_taur_hoof)
		return TRUE
	return FALSE

//Define worn_icon_digi below here for suits so we don't have to make whole new .dm files for each
/obj/item/clothing/suit/armor
	worn_icon_digi = 'icons/mob/clothing/suits/armor_digi.dmi'

/obj/item/clothing/suit/bio_suit
	worn_icon_digi = 'icons/mob/clothing/suits/bio_digi.dmi'

/obj/item/clothing/suit/wizrobe
	worn_icon_digi = 'icons/mob/clothing/suits/wizard_digi.dmi'
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/suit/toggle/labcoat
	worn_icon_digi = 'icons/mob/clothing/suits/labcoat_digi.dmi'

/obj/item/clothing/suit/space
	worn_icon_digi = 'icons/mob/clothing/suits/spacesuit_digi.dmi'

/obj/item/clothing/suit/syndicatefake
	worn_icon_digi = 'icons/mob/clothing/suits/spacesuit_digi.dmi'

/obj/item/clothing/suit/chaplainsuit
	worn_icon_digi = 'icons/mob/clothing/suits/chaplain_digi.dmi'

/obj/item/clothing/suit/hooded/chaplainsuit
	worn_icon_digi = 'icons/mob/clothing/suits/chaplain_digi.dmi'

/obj/item/clothing/suit/chaplainsuit/habit
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/chaplainsuit/habit"
	post_init_icon_state = "habit"
	greyscale_config = /datum/greyscale_config/chappy_habit
	greyscale_config_worn = /datum/greyscale_config/chappy_habit/worn
	greyscale_colors = "#373548#FFFFFF#D29722"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/hooded/chaplainsuit/monkhabit
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/hooded/chaplainsuit/monkhabit"
	post_init_icon_state = "monkfrock"
	greyscale_config = /datum/greyscale_config/monk_habit
	greyscale_config_worn = /datum/greyscale_config/monk_habit/worn
	greyscale_colors = "#8C531A#9C7132"
	flags_1 = IS_PLAYER_COLORABLE_1

// Monk habit hood needs to match; code pulled from wintercoats.
/obj/item/clothing/suit/hooded/chaplainsuit/monkhabit/set_greyscale(list/colors, new_config, new_worn_config, new_inhand_left, new_inhand_right)
	. = ..()
	if(!hood)
		return
	var/list/coat_colors = SSgreyscale.ParseColorString(greyscale_colors)
	var/list/new_coat_colors = coat_colors.Copy(1,3)
	hood.set_greyscale(new_coat_colors) //Adopt the suit's grayscale coloring for visual clarity.
	hood.update_slot_icon()

//But also keep old method in case the hood is (re-)created later
/obj/item/clothing/suit/hooded/chaplainsuit/monkhabit/on_hood_created(obj/item/clothing/head/hooded/hood)
	. = ..()
	var/list/coat_colors = (SSgreyscale.ParseColorString(greyscale_colors))
	var/list/new_coat_colors = coat_colors.Copy(1,3)
	hood.set_greyscale(new_coat_colors) //Adopt the suit's grayscale coloring for visual clarity.

// Former clothing variation overrides.
/obj/item/clothing/suit/bio_suit/plaguedoctorsuit
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/toggle/chef
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/toggle/jacket/trenchcoat
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/toggle/jacket/det_trench
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/toggle/lawyer
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/toggle/suspenders
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/toggle/labcoat/paramedic
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/jacket/miljacket
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/jacket
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/costume/wellworn_shirt
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/suit/costume/poncho
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/suit/wizrobe
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/hooded/bee_costume
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/chaplainsuit/holidaypriest
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/hazardvest
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/costume/pirate/captain
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/jacket/curator
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/jacket/oversized
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/suit/mothcoat/winter
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/suit/hooded/chaplain_hoodie
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/hooded/chaplainsuit
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/chaplainsuit
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/hooded/cultrobes/void
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/hooded/cultrobes/eldritch
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/armor/hos/trenchcoat
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/armor/vest
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/armor/reactive
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/changeling
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/costume/whitedress
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/hooded/ethereal_raincoat
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/costume/snowman
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/costume/hawaiian
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/costume/tmc
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/costume/pg
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/costume/soviet
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/jacket/fancy
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/space/officer
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/space/changeling
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/hooded/wintercoat
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/suit/toggle/cargo_tech
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/jacket/quartermaster
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/armor/changeling
	supports_variations_flags = NONE

/obj/item/clothing/suit/armor/vest/ctf
	supports_variations_flags = NONE

/obj/item/clothing/suit/space/hunter
	supports_variations_flags = NONE

/obj/item/clothing/suit/costume/deckers
	supports_variations_flags = NONE

/obj/item/clothing/suit/costume/yuri
	supports_variations_flags = NONE

/obj/item/clothing/suit/costume/football_armor
	supports_variations_flags = NONE

/obj/item/clothing/suit/hooded/cloak/godslayer
	supports_variations_flags = NONE

/obj/item/clothing/suit/hooded/techpriest
	supports_variations_flags = NONE

/obj/item/clothing/suit/hooded/explorer/syndicate
	supports_variations_flags = NONE

/obj/item/clothing/suit/wizrobe/magusblue
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/wizrobe/magusred
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/wizrobe/santa
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/apron/overalls
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/armor/vest/capcarapace/captains_formal
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/armor/vest/warden
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/armor/vest/leather
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/armor/vest/marine/security
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/armor/vest/marine/engineer
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/armor/riot
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/hooded/explorer
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/chaplainsuit/armor/studentuni
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/chaplainsuit/armor/clock
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/chaplainsuit/armor/templar
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/chaplainsuit/armor/ancient
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/chaplainsuit/shrinehand
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
// END NOVA CORE MIGRATION: code/modules/clothing/suits/_suits.dm
