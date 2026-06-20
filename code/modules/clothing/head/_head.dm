/obj/item/clothing/head
	name = BODY_ZONE_HEAD
	icon = 'icons/obj/clothing/head/default.dmi'
	worn_icon = 'icons/mob/clothing/head/default.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/hats_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/hats_righthand.dmi'
	abstract_type = /obj/item/clothing/head
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_HEAD

///Special throw_impact for hats to frisbee hats at people to place them on their heads/attempt to de-hat them.
/obj/item/clothing/head/throw_impact(atom/hit_atom, datum/thrownthing/thrownthing)
	. = ..()
	///if the thrown object's target zone isn't the head
	if(thrownthing.target_zone != BODY_ZONE_HEAD)
		return
	///ignore any hats with the tinfoil counter-measure enabled
	if(clothing_flags & ANTI_TINFOIL_MANEUVER)
		return
	///if the hat happens to be capable of holding contents and has something in it. mostly to prevent super cheesy stuff like stuffing a mini-bomb in a hat and throwing it
	if(LAZYLEN(contents))
		return
	if(iscarbon(hit_atom))
		var/mob/living/carbon/H = hit_atom
		if(istype(H.head, /obj/item))
			var/obj/item/WH = H.head
			///check if the item has NODROP
			if(HAS_TRAIT(WH, TRAIT_NODROP))
				H.visible_message(span_warning("[src] bounces off [H]'s [WH.name]!"), span_warning("[src] bounces off your [WH.name], falling to the floor."))
				return
			///check if the item is an actual clothing head item, since some non-clothing items can be worn
			if(istype(WH, /obj/item/clothing/head))
				var/obj/item/clothing/head/WHH = WH
				///SNUG_FIT hats are immune to being knocked off
				if(WHH.clothing_flags & SNUG_FIT)
					H.visible_message(span_warning("[src] bounces off [H]'s [WHH.name]!"), span_warning("[src] bounces off your [WHH.name], falling to the floor."))
					return
			///if the hat manages to knock something off
			if(H.dropItemToGround(WH))
				H.visible_message(span_warning("[src] knocks [WH] off [H]'s head!"), span_warning("[WH] is suddenly knocked off your head by [src]!"))
		if(H.equip_to_slot_if_possible(src, ITEM_SLOT_HEAD, 0, 1, 1))
			H.visible_message(span_notice("[src] lands neatly on [H]'s head!"), span_notice("[src] lands perfectly onto your head!"))
			H.update_held_items() //force update hands to prevent ghost sprites appearing when throw mode is on
		return
	if(iscyborg(hit_atom))
		var/mob/living/silicon/robot/R = hit_atom
		var/obj/item/worn_hat = R.hat
		if(worn_hat && HAS_TRAIT(worn_hat, TRAIT_NODROP))
			R.visible_message(span_warning("[src] bounces off [worn_hat], without an effect!"), span_warning("[src] bounces off your mighty [worn_hat.name], falling to the floor in defeat."))
			return
		if(is_type_in_typecache(src, GLOB.blacklisted_borg_hats))//hats in the borg's blacklist bounce off
			R.visible_message(span_warning("[src] bounces off [R]!"), span_warning("[src] bounces off you, falling to the floor."))
			return
		else
			R.visible_message(span_notice("[src] lands neatly on top of [R]!"), span_notice("[src] lands perfectly on top of you."))
			R.place_on_head(src) //hats aren't designed to snugly fit borg heads or w/e so they'll always manage to knock eachother off

/obj/item/clothing/head/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return
	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damagedhelmet")

/obj/item/clothing/head/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file, mutant_styles) // NOVA EDIT CHANGE - ORIGINAL: /obj/item/clothing/gloves/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file)
	. = ..()
	if (isinhands)
		return
	var/blood_overlay = get_blood_overlay("helmet")
	if (blood_overlay)
		. += blood_overlay

/obj/item/clothing/head/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_worn_head()


// BEGIN NOVA CORE MIGRATION: code/modules/clothing/head/_head.dm
//Define worn_icon_muzzled below here for suits so we don't have to make whole new .dm files for each

/// For making sure that snouts with the (Top) suffix have their gear layered correctly
/// Also handles hiding the ear slot properly after equipping a hat
/obj/item/clothing/head/visual_equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(!istype(user))
		return
	if(slot & ITEM_SLOT_HEAD)
		if(user.ears && (flags_inv & HIDEEARS))
			user.update_worn_ears()
		if(!(user.bodyshape & BODYSHAPE_ALT_FACEWEAR_LAYER))
			return
		if(!isnull(alternate_worn_layer) && alternate_worn_layer < BODY_FRONT_LAYER) // if the alternate worn layer was already lower than snouts then leave it be
			return

		alternate_worn_layer = ABOVE_BODY_FRONT_HEAD_LAYER
		user.update_worn_head()

/obj/item/clothing/head/dropped(mob/living/carbon/human/user)
	alternate_worn_layer = initial(alternate_worn_layer)
	return ..()

/obj/item/clothing/head/bio_hood
	worn_icon_muzzled = 'icons/mob/clothing/head/bio_muzzled.dmi'

/obj/item/clothing/head/helmet
	worn_icon_muzzled = 'icons/mob/clothing/head/helmet_muzzled.dmi'

/obj/item/clothing/head/helmet/toggleable/riot
	flags_inv = HIDEEARS|HIDEFACE //Removes HIDESNOUT so that transparent helmets still show the snout

/obj/item/clothing/head/helmet/space
	worn_icon_muzzled = 'icons/mob/clothing/head/spacehelm_muzzled.dmi'
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR //Removes HIDESNOUT so that transparent helmets still show the snout

/obj/item/clothing/head/helmet/chaplain
	worn_icon_muzzled = 'icons/mob/clothing/head/chaplain_muzzled.dmi'

/obj/item/clothing/head/hooded/monkhabit
	icon = 'icons/map_icons/clothing/head/_head.dmi'
	icon_state = "/obj/item/clothing/head/hooded/monkhabit"
	post_init_icon_state = "monkhood"
	greyscale_config = /datum/greyscale_config/monk_habit_hood
	greyscale_config_worn = /datum/greyscale_config/monk_habit_hood/worn
	greyscale_colors = "#8C531A#9C7132"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/chaplain/nun_hood
	icon = 'icons/map_icons/clothing/head/_head.dmi'
	icon_state = "/obj/item/clothing/head/chaplain/nun_hood"
	post_init_icon_state = "nun_hood"
	greyscale_config = /datum/greyscale_config/nun_hood
	greyscale_config_worn = /datum/greyscale_config/nun_hood/worn
	greyscale_colors = "#373548#FFFFFF"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/chaplain/habit_veil
	icon = 'icons/map_icons/clothing/head/_head.dmi'
	icon_state = "/obj/item/clothing/head/chaplain/habit_veil"
	post_init_icon_state = "nun_hood_alt"
	greyscale_config = /datum/greyscale_config/nun_veil
	greyscale_config_worn = /datum/greyscale_config/nun_veil/worn
	greyscale_colors = "#373548#FFFFFF"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/collectable/welding
	worn_icon_muzzled = 'icons/mob/clothing/head_muzzled.dmi'
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION

//Re-adds HIDESNOUT to whatever needs it, and marks them NONE so they don't look for muzzled sprites
//TODO - this needs a better method, can we do this as a SQUISH thing like digitigrade?
/obj/item/clothing/head/helmet/space/changeling
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	supports_variations_flags = NONE

/obj/item/clothing/head/helmet/space/freedom
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	supports_variations_flags = NONE

/obj/item/clothing/head/helmet/space/santahat
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	supports_variations_flags = NONE

// Former clothing variation overrides.
/obj/item/clothing/head/hats
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/helmet/gladiator
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/utility/chefhat
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/soft/paramedic
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/hooded/explorer
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/wizard/red
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/wizard
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/costume/crown
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/utility/hardhat
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/beanie
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/helmet/abductor
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/hooded/winterhood
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/beret
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/soft
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/flatcap
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/costume/pirate
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/costume/rice_hat
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/costume/ushanka
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/collectable
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/fedora
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/costume/rabbitears
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/costume/mailman
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/costume/nursehat
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/costume/cueball
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/costume/pirate/bandana
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/cowboy
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/costume/scarecrow_hat
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/helmet/blueshirt
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/helmet/space/beret
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/helmet/swat
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/costume/spacepolice
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/costume/sombrero
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON
	flags_inv = HIDEHAIR | SHOWSPRITEEARS

/obj/item/clothing/head/costume/santa
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/helmet/space/santahat/beardless
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/helmet/durathread
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/hooded/cloakhood/drake
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/hooded/cloakhood/goliath
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/helmet/knight/greyscale
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/hooded/cult_hoodie/void
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/hooded/berserker
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/hooded/cloakhood/godslayer
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/changeling
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/costume/irs
	supports_variations_flags = NONE

/obj/item/clothing/head/costume/tmc
	supports_variations_flags = NONE

/obj/item/clothing/head/costume/deckers
	supports_variations_flags = NONE

/obj/item/clothing/head/costume/fancy
	supports_variations_flags = NONE

/obj/item/clothing/head/costume/allies
	supports_variations_flags = NONE

/obj/item/clothing/head/costume/yuri
	supports_variations_flags = NONE

/obj/item/clothing/head/costume/football_helmet
	supports_variations_flags = NONE

/obj/item/clothing/head/helmet/alt
	supports_variations_flags = NONE

/obj/item/clothing/head/costume/xenos
	supports_variations_flags = NONE

/obj/item/clothing/head/cone
	supports_variations_flags = NONE

/obj/item/clothing/head/hooded/techpriest
	supports_variations_flags = NONE

/obj/item/clothing/head/utility/hardhat/welding/atmos
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION | CLOTHING_SNOUTED_VOX_VARIATION

/obj/item/clothing/head/wig
	flags_inv = HIDEHAIR | SHOWSPRITEEARS

/obj/item/clothing/head/mothcap
	flags_inv = HIDEHAIR | SHOWSPRITEEARS

/obj/item/clothing/head/helmet/chaplain
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION

/obj/item/clothing/head/helmet/chaplain/witchunter_hat
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/helmet/chaplain/adept
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/helmet/chaplain/cage
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION_NO_NEW_ICON
// END NOVA CORE MIGRATION: code/modules/clothing/head/_head.dm
