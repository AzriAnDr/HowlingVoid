/datum/interaction/howling_item
	register_in_menu = FALSE
	parent_type = /datum/interaction/howling_extra
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)

/datum/interaction/howling_item_self
	parent_type = /datum/interaction/howling_item
	usage = INTERACTION_SELF

/datum/interaction/howling_item/vibrator
	category = "Vibrator"
	category_translation_key = "ui.interaction_panel.category.toy.vibrator"
	user_required_item_paths = list(/obj/item/clothing/sextoy/vibrator)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/vibrate.ogg')

/datum/interaction/howling_item/wand
	category = "Magic Wand"
	category_translation_key = "ui.interaction_panel.category.toy.magic_wand"
	user_required_item_paths = list(/obj/item/clothing/sextoy/magic_wand)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/vibrate.ogg')

/datum/interaction/howling_item/dildo
	category = "Dildo"
	category_translation_key = "ui.interaction_panel.category.toy.dildo"
	user_required_item_paths = list(/obj/item/clothing/sextoy/dildo)
	user_blocked_item_paths = list(
		/obj/item/clothing/sextoy/dildo/custom_dildo,
		/obj/item/clothing/sextoy/dildo/double_dildo,
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')

/datum/interaction/howling_item/fleshlight
	category = "Fleshlight"
	category_translation_key = "ui.interaction_panel.category.toy.fleshlight"
	user_required_item_paths = list(/obj/item/clothing/sextoy/fleshlight)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')

/datum/interaction/howling_item/strapon
	category = "Strap-On"
	category_translation_key = "ui.interaction_panel.category.toy.strap_on"
	user_required_item_paths = list(/obj/item/strapon_dildo)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)

/datum/interaction/howling_item/whip
	category = "Whip"
	category_translation_key = "ui.interaction_panel.category.toy.whip"
	user_required_item_paths = list(/obj/item/clothing/mask/leatherwhip)
	sound_use = TRUE
	sound_range = 2
	sound_possible = list('sound/items/weapons/slap.ogg')

/datum/interaction/howling_item/spanking_pad
	category = "Spanking"
	category_translation_key = "ui.interaction_panel.category.toy.spanking"
	user_required_item_paths = list(/obj/item/spanking_pad)
	sound_use = TRUE
	sound_range = 2
	sound_possible = list('sound/effects/emotes/assslap.ogg')

/datum/interaction/howling_item/feather
	category = "Feather"
	category_translation_key = "ui.interaction_panel.category.toy.feather"
	user_required_item_paths = list(/obj/item/tickle_feather)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')

/datum/interaction/howling_item/shocker
	category = "Shocker"
	category_translation_key = "ui.interaction_panel.category.toy.shocker"
	user_required_item_paths = list(/obj/item/kinky_shocker)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/effects/sparks/sparks1.ogg')

/datum/interaction/howling_item/candle
	category = "Wax Play"
	category_translation_key = "ui.interaction_panel.category.toy.wax_play"
	user_required_item_paths = list(/obj/item/bdsm_candle)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/items/weapons/slap.ogg')

/datum/interaction/howling_item/plug
	category = "Buttplug"
	category_translation_key = "ui.interaction_panel.category.toy.buttplug"
	user_required_item_paths = list(/obj/item/clothing/sextoy/buttplug)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')

/datum/interaction/howling_item/egg
	category = "Egg Vibrator"
	category_translation_key = "ui.interaction_panel.category.toy.egg_vibrator"
	user_required_item_paths = list(/obj/item/clothing/sextoy/eggvib)
	user_blocked_item_paths = list(/obj/item/clothing/sextoy/eggvib/signalvib)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/vibrate.ogg')

/datum/interaction/howling_item/ring
	category = "Vibrating Ring"
	category_translation_key = "ui.interaction_panel.category.toy.vibrating_ring"
	user_required_item_paths = list(/obj/item/clothing/sextoy/vibroring)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/vibrate.ogg')

/datum/interaction/howling_item/clamps
	category = "Nipple Clamps"
	category_translation_key = "ui.interaction_panel.category.toy.nipple_clamps"
	user_required_item_paths = list(/obj/item/clothing/sextoy/nipple_clamps)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')

/datum/interaction/howling_item_inserted
	register_in_menu = FALSE
	parent_type = /datum/interaction/howling_extra
	color = "pink"

/datum/interaction/howling_item_inserted/dildo
	category = "Dildo"
	category_translation_key = "ui.interaction_panel.category.toy.dildo"
	target_required_item_slots = list("vagina", "anus")
	target_required_item_paths = list(/obj/item/clothing/sextoy/dildo)
	target_blocked_item_paths = list(
		/obj/item/clothing/sextoy/dildo/custom_dildo,
		/obj/item/clothing/sextoy/dildo/double_dildo,
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')

/datum/interaction/howling_item_inserted/plug
	category = "Buttplug"
	category_translation_key = "ui.interaction_panel.category.toy.buttplug"
	target_required_item_slots = list("anus", "vagina")
	target_required_item_paths = list(/obj/item/clothing/sextoy/buttplug)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')

/datum/interaction/howling_item_inserted/egg
	category = "Egg Vibrator"
	category_translation_key = "ui.interaction_panel.category.toy.egg_vibrator"
	target_required_item_slots = list("vagina", "anus")
	target_required_item_paths = list(/obj/item/clothing/sextoy/eggvib)
	target_blocked_item_paths = list(/obj/item/clothing/sextoy/eggvib/signalvib)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/vibrate.ogg')

/datum/interaction/howling_item_inserted/ring
	category = "Vibrating Ring"
	category_translation_key = "ui.interaction_panel.category.toy.vibrating_ring"
	target_required_item_slots = list("penis")
	target_required_item_paths = list(/obj/item/clothing/sextoy/vibroring)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/vibrate.ogg')

/datum/interaction/howling_item_inserted/clamps
	category = "Nipple Clamps"
	category_translation_key = "ui.interaction_panel.category.toy.nipple_clamps"
	target_required_item_slots = list("nipples")
	target_required_item_paths = list(/obj/item/clothing/sextoy/nipple_clamps)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')

/datum/interaction/howling_item/condom
	category = "Condom"
	category_translation_key = "ui.interaction_panel.category.toy.condom"
	user_required_item_paths = list(/obj/item/clothing/sextoy/condom)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/latex.ogg')

/datum/interaction/howling_item_inserted/condom
	category = "Condom"
	category_translation_key = "ui.interaction_panel.category.toy.condom"
	target_required_item_slots = list("penis")
	target_required_item_paths = list(/obj/item/clothing/sextoy/condom)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')

/datum/interaction/howling_item_inserted/signal_egg
	category = "Signal Egg"
	category_translation_key = "ui.interaction_panel.category.toy.signal_egg"
	target_required_item_slots = list("vagina", "anus", "nipples", "penis")
	target_required_item_paths = list(/obj/item/clothing/sextoy/eggvib/signalvib)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/vibrate.ogg')

/datum/interaction/howling_item_inserted/double_dildo
	category = "Double Dildo"
	category_translation_key = "ui.interaction_panel.category.toy.double_dildo"
	target_required_item_slots = list("vagina", "anus")
	target_required_item_paths = list(/obj/item/clothing/sextoy/dildo/double_dildo)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/bang1.ogg')

/datum/interaction/howling_item_self_inserted/double_dildo
	parent_type = /datum/interaction/howling_item_inserted/double_dildo
	usage = INTERACTION_SELF

/datum/interaction/howling_item/custom_dildo
	category = "Custom Dildo"
	category_translation_key = "ui.interaction_panel.category.toy.custom_dildo"
	user_required_item_paths = list(/obj/item/clothing/sextoy/dildo/custom_dildo)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')

/datum/interaction/howling_item/double_dildo
	category = "Double Dildo"
	category_translation_key = "ui.interaction_panel.category.toy.double_dildo"
	user_required_item_paths = list(/obj/item/clothing/sextoy/dildo/double_dildo)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg'
	)

/datum/interaction/howling_item/signal_egg
	category = "Signal Egg"
	category_translation_key = "ui.interaction_panel.category.toy.signal_egg"
	user_required_item_paths = list(/obj/item/clothing/sextoy/eggvib/signalvib)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/vibrate.ogg')

/datum/interaction/howling_item_self/vibrator
	parent_type = /datum/interaction/howling_item/vibrator
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/wand
	parent_type = /datum/interaction/howling_item/wand
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/dildo
	parent_type = /datum/interaction/howling_item/dildo
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/fleshlight
	parent_type = /datum/interaction/howling_item/fleshlight
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/buttplug
	parent_type = /datum/interaction/howling_item/plug
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/egg
	parent_type = /datum/interaction/howling_item/egg
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/signal_egg
	parent_type = /datum/interaction/howling_item/signal_egg
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/ring
	parent_type = /datum/interaction/howling_item/ring
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/clamps
	parent_type = /datum/interaction/howling_item/clamps
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/strapon
	parent_type = /datum/interaction/howling_item/strapon
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/custom_dildo
	parent_type = /datum/interaction/howling_item/custom_dildo
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/double_dildo
	parent_type = /datum/interaction/howling_item/double_dildo
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/whip
	parent_type = /datum/interaction/howling_item/whip
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/spanking_pad
	parent_type = /datum/interaction/howling_item/spanking_pad
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/feather
	parent_type = /datum/interaction/howling_item/feather
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/shocker
	parent_type = /datum/interaction/howling_item/shocker
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/candle
	parent_type = /datum/interaction/howling_item/candle
	usage = INTERACTION_SELF
