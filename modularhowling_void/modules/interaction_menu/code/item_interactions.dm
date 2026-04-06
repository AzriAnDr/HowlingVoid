/datum/interaction/howling_item
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
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/vibrate.ogg')

/datum/interaction/howling_item/vibrator/chest
	name = "Press Vibrator To Chest"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.chest.name"
	description = "Run a vibrator across their chest."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.chest.description"
	target_required_parts = list("chest")
	message = list(
		"presses %ITEM% to %TARGET%'s chest.",
		"glides %ITEM% over %TARGET%'s chest.",
		"runs %ITEM% slowly along %TARGET%'s chest."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/vibrator/nipples
	name = "Tease Nipples With Vibrator"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.nipples.name"
	description = "Hold a vibrator against their nipples."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.nipples.description"
	target_required_parts = list("breasts")
	message = list(
		"teases %TARGET%'s nipples with %ITEM%.",
		"buzzes %ITEM% over %TARGET%'s nipples.",
		"holds %ITEM% against %TARGET%'s sensitive nipples."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/vibrator/clit
	name = "Circle Clit With Vibrator"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.clit.name"
	description = "Circle a vibrator over their clit."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.clit.description"
	target_required_parts = list("vagina")
	message = list(
		"circles %ITEM% over %TARGET%'s clit.",
		"moves %ITEM% against %TARGET%'s clit in tight circles.",
		"presses %ITEM% to %TARGET%'s clit and keeps it humming there."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/vibrator/cock
	name = "Run Vibrator Along Cock"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.cock.name"
	description = "Buzz a vibrator against their cock."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.cock.description"
	target_required_parts = list("penis")
	message = list(
		"runs %ITEM% along %TARGET%'s cock.",
		"presses %ITEM% beneath %TARGET%'s shaft.",
		"buzzes %ITEM% over %TARGET%'s cock from base to tip."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/vibrator/balls
	name = "Vibrate Their Balls"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.balls.name"
	description = "Press a vibrator under their balls."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.balls.description"
	target_required_parts = list("balls")
	message = list(
		"presses %ITEM% under %TARGET%'s balls.",
		"keeps %ITEM% buzzing against %TARGET%'s sack.",
		"teases %TARGET%'s balls with the trembling tip of %ITEM%."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/vibrator/ass
	name = "Press Vibrator To Ass"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.ass.name"
	description = "Buzz a vibrator against their rear."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.ass.description"
	target_required_parts = list("butt")
	message = list(
		"presses %ITEM% to %TARGET%'s ass.",
		"runs %ITEM% over %TARGET%'s rear in slow circles.",
		"keeps %ITEM% humming against %TARGET%'s asscheeks."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(2, 4)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/vibrator/lips
	name = "Press Vibrator To Lips"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.lips.name"
	description = "Press a vibrator to their lips."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.lips.description"
	target_required_parts = list("mouth")
	message = list(
		"presses %ITEM% to %TARGET%'s lips.",
		"presses %ITEM% to %TARGET%'s mouth and lets it hum there.",
		"holds the trembling tip of %ITEM% against %TARGET%'s lips."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/vibrator/tongue
	name = "Tease Tongue With Vibrator"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.tongue.name"
	description = "Touch a vibrator to their tongue."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.tongue.description"
	target_required_parts = list("mouth")
	message = list(
		"teases %TARGET%'s tongue with %ITEM%.",
		"presses %ITEM% to %TARGET%'s tongue and lets it buzz there.",
		"holds %ITEM% at %TARGET%'s open mouth until their tongue meets it."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/vibrator/snout
	name = "Press Vibrator To Snout"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.snout.name"
	description = "Press a vibrator to their snout."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.snout.description"
	target_required_parts = list("snout")
	message = list(
		"presses %ITEM% to %TARGET%'s snout.",
		"runs %ITEM%'s humming tip along %TARGET%'s snout.",
		"holds %ITEM% against %TARGET%'s muzzle and lets it buzz there."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/vibrator/hands
	name = "Vibrate Their Hands"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.hands.name"
	description = "Press a vibrator into their palms and fingers."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.hands.description"
	target_required_parts = list("hands")
	message = list(
		"presses %ITEM% into %TARGET%'s palms.",
		"runs %ITEM% along %TARGET%'s fingers and hands.",
		"lets %ITEM% buzz in %TARGET%'s grasp."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/vibrator/ears
	name = "Buzz Their Ears"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.ears.name"
	description = "Hold a vibrator against their ears."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.ears.description"
	target_required_parts = list("ears")
	message = list(
		"buzzes %ITEM% against %TARGET%'s ears.",
		"presses %ITEM% to %TARGET%'s ear and lets it hum there.",
		"runs the trembling tip of %ITEM% along %TARGET%'s ear."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/vibrator/armpits
	name = "Press Vibrator To Armpits"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.armpits.name"
	description = "Run a vibrator into their armpits."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.armpits.description"
	target_required_parts = list("armpits")
	message = list(
		"presses %ITEM% into %TARGET%'s armpit.",
		"runs %ITEM% along the sensitive hollow of %TARGET%'s armpit.",
		"lets %ITEM% buzz against %TARGET%'s armpit."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/vibrator/tail
	name = "Run Vibrator Along Tail"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.tail.name"
	description = "Run a vibrator along their tail."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.tail.description"
	target_required_parts = list("tail")
	message = list(
		"runs %ITEM% along %TARGET%'s tail.",
		"presses %ITEM% to %TARGET%'s tail and lets it buzz there.",
		"guides %ITEM%'s humming tip from the base of %TARGET%'s tail outward."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/vibrator/groin
	name = "Press Vibrator To Groin"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.groin.name"
	description = "Press a vibrator against their groin without focusing on one spot."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.groin.description"
	target_required_parts = list("groin")
	message = list(
		"presses %ITEM% to %TARGET%'s groin.",
		"works %ITEM% over the heat of %TARGET%'s groin.",
		"holds %ITEM% against %TARGET%'s groin and lets it hum there."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/vibrator/body
	name = "Run Vibrator Over Body"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.body.name"
	description = "Drag a vibrator over their body in broad teasing passes."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.body.description"
	target_required_parts = list("body")
	message = list(
		"runs %ITEM% over %TARGET%'s body.",
		"draws %ITEM%'s humming tip over %TARGET%'s body in slow passes.",
		"teases %TARGET%'s body with the steady buzz of %ITEM%."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/vibrator/pin_nipples
	name = "Pin Vibrator To Nipples"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.pin_nipples.name"
	description = "Hold the vibrator firmly against their nipples."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.pin_nipples.description"
	target_required_parts = list("breasts")
	message = list(
		"pins %ITEM% to %TARGET%'s nipples.",
		"holds %ITEM% firmly against %TARGET%'s nipples.",
		"keeps %ITEM% pressed hard to %TARGET%'s sensitive nipples."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/vibrator/grind_clit
	name = "Grind Vibrator On Clit"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.grind_clit.name"
	description = "Grind the vibrator against their clit in short presses."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.grind_clit.description"
	target_required_parts = list("vagina")
	message = list(
		"grinds %ITEM% against %TARGET%'s clit.",
		"presses %ITEM% into %TARGET%'s clit in short hard nudges.",
		"rocks %ITEM% against %TARGET%'s clit and keeps it there."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/wand
	category = "Magic Wand"
	category_translation_key = "ui.interaction_panel.category.toy.magic_wand"
	user_required_item_paths = list(/obj/item/clothing/sextoy/magic_wand)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/vibrate.ogg')

/datum/interaction/howling_item/wand/breasts
	name = "Buzz Their Breasts"
	translation_key = "ui.interaction_panel.interaction.toy.wand.breasts.name"
	description = "Sweep a wand over their breasts."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.breasts.description"
	target_required_parts = list("breasts")
	message = list(
		"sweeps %ITEM% over %TARGET%'s breasts.",
		"presses the head of %ITEM% into %TARGET%'s breasts.",
		"draws %ITEM%'s buzzing head across %TARGET%'s chest and nipples."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(3, 5)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/wand/pussy
	name = "Glide Wand Over Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.wand.pussy.name"
	description = "Work a wand over their pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.pussy.description"
	target_required_parts = list("vagina")
	message = list(
		"glides %ITEM% over %TARGET%'s pussy.",
		"presses %ITEM% into %TARGET%'s folds and clit.",
		"draws slow vibrating circles over %TARGET%'s pussy with %ITEM%."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/wand/cock
	name = "Buzz Their Cock"
	translation_key = "ui.interaction_panel.interaction.toy.wand.cock.name"
	description = "Use a wand on their cock."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.cock.description"
	target_required_parts = list("penis")
	message = list(
		"buzzes %ITEM% against %TARGET%'s cock.",
		"presses %ITEM% under %TARGET%'s shaft until it hums against them.",
		"runs %ITEM% up and down %TARGET%'s cock."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/wand/ass
	name = "Buzz Their Ass"
	translation_key = "ui.interaction_panel.interaction.toy.wand.ass.name"
	description = "Press a wand against their rear."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.ass.description"
	target_required_parts = list("butt")
	message = list(
		"presses %ITEM% into %TARGET%'s asscheeks.",
		"holds %ITEM% against %TARGET%'s rear and lets it vibrate there.",
		"drags %ITEM%'s buzzing head over %TARGET%'s ass."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(3, 5)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/wand/lips
	name = "Press Wand To Lips"
	translation_key = "ui.interaction_panel.interaction.toy.wand.lips.name"
	description = "Press the head of a wand to their lips."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.lips.description"
	target_required_parts = list("mouth")
	message = list(
		"presses %ITEM% to %TARGET%'s lips.",
		"holds %ITEM%'s buzzing head at %TARGET%'s mouth.",
		"lets %ITEM% hum against %TARGET%'s lips in a teasing offer."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/wand/tongue
	name = "Buzz Their Tongue"
	translation_key = "ui.interaction_panel.interaction.toy.wand.tongue.name"
	description = "Press a wand to their tongue."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.tongue.description"
	target_required_parts = list("mouth")
	message = list(
		"buzzes %ITEM% against %TARGET%'s tongue.",
		"presses %ITEM% into %TARGET%'s open mouth and onto their tongue.",
		"holds %ITEM%'s head against %TARGET%'s tongue while it hums."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/wand/nipples
	name = "Press Wand To Nipples"
	translation_key = "ui.interaction_panel.interaction.toy.wand.nipples.name"
	description = "Work a wand insistently over their nipples."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.nipples.description"
	target_required_parts = list("breasts")
	message = list(
		"presses %ITEM% firmly to %TARGET%'s nipples.",
		"pins %ITEM%'s buzzing head against %TARGET%'s nipples.",
		"leans %ITEM% hard into %TARGET%'s nipples and keeps it there."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/wand/snout
	name = "Buzz Their Snout"
	translation_key = "ui.interaction_panel.interaction.toy.wand.snout.name"
	description = "Sweep a wand over their snout."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.snout.description"
	target_required_parts = list("snout")
	message = list(
		"sweeps %ITEM% over %TARGET%'s snout.",
		"presses %ITEM%'s buzzing head to %TARGET%'s muzzle.",
		"draws %ITEM% along %TARGET%'s snout and lets it hum there."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/wand/hands
	name = "Buzz Their Hands"
	translation_key = "ui.interaction_panel.interaction.toy.wand.hands.name"
	description = "Run a wand across their palms and fingers."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.hands.description"
	target_required_parts = list("hands")
	message = list(
		"buzzes %ITEM% over %TARGET%'s hands.",
		"presses %ITEM% into %TARGET%'s palm and drags it over their fingers.",
		"lets %ITEM%'s head hum through %TARGET%'s hands."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/wand/ears
	name = "Press Wand To Ears"
	translation_key = "ui.interaction_panel.interaction.toy.wand.ears.name"
	description = "Press a wand to their ears."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.ears.description"
	target_required_parts = list("ears")
	message = list(
		"presses %ITEM% to %TARGET%'s ear.",
		"holds %ITEM%'s buzzing head along %TARGET%'s ear.",
		"works %ITEM% around %TARGET%'s ear and lets it hum there."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/wand/armpits
	name = "Buzz Their Armpits"
	translation_key = "ui.interaction_panel.interaction.toy.wand.armpits.name"
	description = "Sweep a wand into their armpits."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.armpits.description"
	target_required_parts = list("armpits")
	message = list(
		"sweeps %ITEM% into %TARGET%'s armpit.",
		"presses %ITEM%'s head into the hollow of %TARGET%'s armpit.",
		"lets %ITEM% hum against %TARGET%'s armpit."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/wand/tail
	name = "Buzz Their Tail"
	translation_key = "ui.interaction_panel.interaction.toy.wand.tail.name"
	description = "Sweep a wand over their tail."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.tail.description"
	target_required_parts = list("tail")
	message = list(
		"sweeps %ITEM% over %TARGET%'s tail.",
		"presses %ITEM%'s head to %TARGET%'s tail and lets it buzz there.",
		"draws %ITEM% along %TARGET%'s tail in a slow humming stroke."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/wand/groin
	name = "Buzz Their Groin"
	translation_key = "ui.interaction_panel.interaction.toy.wand.groin.name"
	description = "Work a wand over their groin without settling on one spot."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.groin.description"
	target_required_parts = list("groin")
	message = list(
		"buzzes %ITEM% over %TARGET%'s groin.",
		"presses %ITEM%'s head into the heat of %TARGET%'s groin.",
		"works %ITEM% across %TARGET%'s groin in slow teasing passes."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/wand/body
	name = "Sweep Wand Over Body"
	translation_key = "ui.interaction_panel.interaction.toy.wand.body.name"
	description = "Drag a wand over their body in broad teasing strokes."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.body.description"
	target_required_parts = list("body")
	message = list(
		"sweeps %ITEM% over %TARGET%'s body.",
		"draws %ITEM%'s buzzing head over %TARGET%'s body in slow passes.",
		"teases %TARGET%'s body with the humming weight of %ITEM%."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/wand/clit
	name = "Press Wand To Clit"
	translation_key = "ui.interaction_panel.interaction.toy.wand.clit.name"
	description = "Hold the head of the wand directly to their clit."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.clit.description"
	target_required_parts = list("vagina")
	message = list(
		"presses %ITEM% directly to %TARGET%'s clit.",
		"holds %ITEM%'s head against %TARGET%'s clit without moving it away.",
		"pins %ITEM% to %TARGET%'s clit and lets it hum there."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

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
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/champ_fingering.ogg')

/datum/interaction/howling_item/dildo/tease_pussy
	name = "Tease Pussy With Dildo"
	translation_key = "ui.interaction_panel.interaction.toy.dildo.tease_pussy.name"
	description = "Tease their pussy with the tip of a dildo."
	description_translation_key = "ui.interaction_panel.interaction.toy.dildo.tease_pussy.description"
	target_required_parts = list("vagina")
	message = list(
		"teases %TARGET%'s pussy with %ITEM%.",
		"rubs the tip of %ITEM% through %TARGET%'s folds.",
		"drags %ITEM% over %TARGET%'s pussy without quite pushing it in."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/dildo/pussy
	name = "Slide Dildo Into Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.dildo.pussy.name"
	description = "Push a dildo into their pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.dildo.pussy.description"
	target_required_parts = list("vagina")
	message = list(
		"slides %ITEM% into %TARGET%'s pussy.",
		"pushes %ITEM% into %TARGET%'s folds a little at a time.",
		"rocks %ITEM% inside %TARGET%'s pussy."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/dildo/tease_ass
	name = "Tease Ass With Dildo"
	translation_key = "ui.interaction_panel.interaction.toy.dildo.tease_ass.name"
	description = "Brush a dildo over their ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.dildo.tease_ass.description"
	target_required_parts = list("anus")
	message = list(
		"teases %TARGET%'s ass with %ITEM%.",
		"circles %ITEM% against %TARGET%'s entrance.",
		"rubs the tip of %ITEM% over %TARGET%'s ass."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/dildo/ass
	name = "Slide Dildo Into Ass"
	translation_key = "ui.interaction_panel.interaction.toy.dildo.ass.name"
	description = "Push a dildo into their ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.dildo.ass.description"
	target_required_parts = list("anus")
	message = list(
		"slides %ITEM% into %TARGET%'s ass.",
		"eases %ITEM% into %TARGET%'s rear.",
		"eases %ITEM% past %TARGET%'s entrance and into their ass."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)
	target_pain = list(0, 2)

/datum/interaction/howling_item/dildo/lips
	name = "Press Dildo To Lips"
	translation_key = "ui.interaction_panel.interaction.toy.dildo.lips.name"
	description = "Press a dildo to their lips."
	description_translation_key = "ui.interaction_panel.interaction.toy.dildo.lips.description"
	target_required_parts = list("mouth")
	message = list(
		"presses %ITEM% to %TARGET%'s lips.",
		"taps %ITEM% against %TARGET%'s mouth in a teasing offer.",
		"holds %ITEM% at %TARGET%'s lips and lets them feel its shape."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/dildo/mouth
	name = "Feed Dildo To Mouth"
	translation_key = "ui.interaction_panel.interaction.toy.dildo.mouth.name"
	description = "Work a dildo past their lips."
	description_translation_key = "ui.interaction_panel.interaction.toy.dildo.mouth.description"
	target_required_parts = list("mouth")
	message = list(
		"feeds %ITEM% to %TARGET%'s mouth.",
		"eases %ITEM% past %TARGET%'s lips.",
		"guides %ITEM% into %TARGET%'s mouth a little at a time."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/dildo/thighs
	name = "Rub Dildo Between Thighs"
	translation_key = "ui.interaction_panel.interaction.toy.dildo.thighs.name"
	description = "Grind a dildo between their thighs."
	description_translation_key = "ui.interaction_panel.interaction.toy.dildo.thighs.description"
	target_required_parts = list("thighs")
	message = list(
		"rubs %ITEM% between %TARGET%'s thighs.",
		"grinds %ITEM% along the heat between %TARGET%'s thighs.",
		"presses %ITEM% between %TARGET%'s legs and rocks it there."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/dildo/clit
	name = "Ride Dildo Over Clit"
	translation_key = "ui.interaction_panel.interaction.toy.dildo.clit.name"
	description = "Work a dildo over their clit without pushing it in."
	description_translation_key = "ui.interaction_panel.interaction.toy.dildo.clit.description"
	target_required_parts = list("vagina")
	message = list(
		"rides %ITEM% over %TARGET%'s clit.",
		"grinds %ITEM% over %TARGET%'s clit and folds.",
		"works %ITEM% against %TARGET%'s clit without slipping it inside."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/fleshlight
	category = "Fleshlight"
	category_translation_key = "ui.interaction_panel.category.toy.fleshlight"
	user_required_item_paths = list(/obj/item/clothing/sextoy/fleshlight)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/champ_fingering.ogg')

/datum/interaction/howling_item/fleshlight/work_cock
	name = "Take Cock Into Fleshlight"
	translation_key = "ui.interaction_panel.interaction.toy.fleshlight.work_cock.name"
	description = "Take their cock into a fleshlight."
	description_translation_key = "ui.interaction_panel.interaction.toy.fleshlight.work_cock.description"
	target_required_parts = list("penis")
	message = list(
		"works %TARGET%'s cock into %ITEM%.",
		"guides %ITEM% down %TARGET%'s shaft.",
		"takes %TARGET%'s cock into %ITEM% and starts stroking."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/fleshlight/stroke_cock
	name = "Stroke Cock With Fleshlight"
	translation_key = "ui.interaction_panel.interaction.toy.fleshlight.stroke_cock.name"
	description = "Stroke their cock with a fleshlight."
	description_translation_key = "ui.interaction_panel.interaction.toy.fleshlight.stroke_cock.description"
	target_required_parts = list("penis")
	message = list(
		"strokes %TARGET%'s cock with %ITEM%.",
		"pumps %ITEM% along %TARGET%'s shaft.",
		"slides %ITEM% up and down %TARGET%'s cock."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/fleshlight/tease_tip
	name = "Tease Tip With Fleshlight"
	translation_key = "ui.interaction_panel.interaction.toy.fleshlight.tease_tip.name"
	description = "Work only the tip of their cock into a fleshlight."
	description_translation_key = "ui.interaction_panel.interaction.toy.fleshlight.tease_tip.description"
	target_required_parts = list("penis")
	message = list(
		"teases the tip of %TARGET%'s cock with %ITEM%.",
		"works only the head of %TARGET%'s cock into %ITEM%.",
		"drags %ITEM% over %TARGET%'s tip in short teasing strokes."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/fleshlight/balls
	name = "Rub Fleshlight Under Balls"
	translation_key = "ui.interaction_panel.interaction.toy.fleshlight.balls.name"
	description = "Press a fleshlight beneath their balls."
	description_translation_key = "ui.interaction_panel.interaction.toy.fleshlight.balls.description"
	target_required_parts = list("balls")
	message = list(
		"rubs %ITEM% under %TARGET%'s balls.",
		"presses %ITEM% up against %TARGET%'s sack.",
		"works the soft edge of %ITEM% beneath %TARGET%'s balls."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(2, 4)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/strapon
	category = "Strap-On"
	category_translation_key = "ui.interaction_panel.category.toy.strap_on"
	user_required_item_paths = list(/obj/item/strapon_dildo)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'modular_nova/modules/modular_items/lewd_items/sounds/bang1.ogg',
		'modular_nova/modules/modular_items/lewd_items/sounds/bang2.ogg',
		'modular_nova/modules/modular_items/lewd_items/sounds/bang3.ogg'
	)

/datum/interaction/howling_item/strapon/grind_pussy
	name = "Grind Strap-On Against Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.strapon.grind_pussy.name"
	description = "Grind the strap-on over their pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.strapon.grind_pussy.description"
	target_required_parts = list("vagina")
	message = list(
		"grinds %ITEM% against %TARGET%'s pussy.",
		"rubs %ITEM% through %TARGET%'s folds.",
		"presses %ITEM% to %TARGET%'s pussy and rolls their hips."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/strapon/fuck_pussy
	name = "Slide Strap-On Into Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.strapon.fuck_pussy.name"
	description = "Push the strap-on into their pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.strapon.fuck_pussy.description"
	target_required_parts = list("vagina")
	message = list(
		"pushes %ITEM% into %TARGET%'s pussy.",
		"works %ITEM% into %TARGET%'s folds a little at a time.",
		"thrusts %ITEM% into %TARGET%'s folds."
	)
	user_pleasure = list(1, 3)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/strapon/grind_ass
	name = "Grind Strap-On Against Ass"
	translation_key = "ui.interaction_panel.interaction.toy.strapon.grind_ass.name"
	description = "Grind the strap-on over their rear."
	description_translation_key = "ui.interaction_panel.interaction.toy.strapon.grind_ass.description"
	target_required_parts = list("butt")
	message = list(
		"grinds %ITEM% against %TARGET%'s ass.",
		"rubs %ITEM% between %TARGET%'s cheeks.",
		"presses %ITEM% to %TARGET%'s rear and grinds slowly."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(2, 4)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/strapon/fuck_ass
	name = "Slide Strap-On Into Ass"
	translation_key = "ui.interaction_panel.interaction.toy.strapon.fuck_ass.name"
	description = "Push the strap-on into their ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.strapon.fuck_ass.description"
	target_required_parts = list("anus")
	message = list(
		"pushes %ITEM% into %TARGET%'s ass.",
		"eases %ITEM% into %TARGET%'s rear a little at a time.",
		"thrusts %ITEM% into %TARGET%'s rear."
	)
	user_pleasure = list(1, 3)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)
	target_pain = list(0, 2)

/datum/interaction/howling_item/strapon/lips
	name = "Press Strap-On To Lips"
	translation_key = "ui.interaction_panel.interaction.toy.strapon.lips.name"
	description = "Hold the strap-on at their lips."
	description_translation_key = "ui.interaction_panel.interaction.toy.strapon.lips.description"
	target_required_parts = list("mouth")
	message = list(
		"presses %ITEM% to %TARGET%'s lips.",
		"holds %ITEM% at %TARGET%'s mouth in a blunt offer.",
		"taps %ITEM% against %TARGET%'s lips and waits for them to part."
	)
	user_arousal = list(2, 4)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/strapon/mouth
	name = "Feed Strap-On To Mouth"
	translation_key = "ui.interaction_panel.interaction.toy.strapon.mouth.name"
	description = "Work the strap-on into their mouth."
	description_translation_key = "ui.interaction_panel.interaction.toy.strapon.mouth.description"
	target_required_parts = list("mouth")
	message = list(
		"feeds %ITEM% to %TARGET%'s mouth.",
		"eases %ITEM% past %TARGET%'s lips.",
		"guides %ITEM% into %TARGET%'s mouth in slow thrusting pushes."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/whip
	category = "Whip"
	category_translation_key = "ui.interaction_panel.category.toy.whip"
	user_required_item_paths = list(/obj/item/clothing/mask/leatherwhip)
	sound_use = TRUE
	sound_range = 2
	sound_possible = list('sound/items/weapons/slap.ogg')

/datum/interaction/howling_item/whip/chest
	name = "Trace Whip Over Chest"
	translation_key = "ui.interaction_panel.interaction.toy.whip.chest.name"
	description = "Trail a whip over their chest."
	description_translation_key = "ui.interaction_panel.interaction.toy.whip.chest.description"
	target_required_parts = list("chest")
	message = list(
		"trails %ITEM% over %TARGET%'s chest.",
		"draws the length of %ITEM% across %TARGET%'s chest.",
		"slides %ITEM% over %TARGET%'s chest in a slow stroke."
	)
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_item/whip/thighs
	name = "Lash Their Thighs"
	translation_key = "ui.interaction_panel.interaction.toy.whip.thighs.name"
	description = "Snap a whip across their thighs."
	description_translation_key = "ui.interaction_panel.interaction.toy.whip.thighs.description"
	target_required_parts = list("thighs")
	message = list(
		"lashes %TARGET%'s thighs with %ITEM%.",
		"snaps %ITEM% across %TARGET%'s thighs.",
		"strikes %TARGET%'s thighs with %ITEM%."
	)
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)
	target_pain = list(2, 4)

/datum/interaction/howling_item/whip/ass
	name = "Snap Whip Across Ass"
	translation_key = "ui.interaction_panel.interaction.toy.whip.ass.name"
	description = "Crack a whip against their ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.whip.ass.description"
	target_required_parts = list("butt")
	message = list(
		"snaps %ITEM% across %TARGET%'s ass.",
		"cracks %ITEM% against %TARGET%'s rear.",
		"lashes %TARGET%'s ass with %ITEM%."
	)
	user_arousal = list(2, 4)
	target_arousal = list(1, 3)
	target_pain = list(3, 5)

/datum/interaction/howling_item/spanking_pad
	category = "Spanking"
	category_translation_key = "ui.interaction_panel.category.toy.spanking"
	user_required_item_paths = list(/obj/item/spanking_pad)
	sound_use = TRUE
	sound_range = 2
	sound_possible = list('sound/effects/emotes/assslap.ogg')

/datum/interaction/howling_item/spanking_pad/ass
	name = "Spank Their Ass"
	translation_key = "ui.interaction_panel.interaction.toy.spanking.ass.name"
	description = "Smack their ass with a spanking pad."
	description_translation_key = "ui.interaction_panel.interaction.toy.spanking.ass.description"
	target_required_parts = list("butt")
	message = list(
		"spanks %TARGET%'s ass with %ITEM%.",
		"smacks %ITEM% across %TARGET%'s rear.",
		"slaps %TARGET%'s ass with %ITEM%."
	)
	user_arousal = list(2, 4)
	target_arousal = list(1, 3)
	target_pain = list(2, 4)

/datum/interaction/howling_item/spanking_pad/thighs
	name = "Smack Their Thighs"
	translation_key = "ui.interaction_panel.interaction.toy.spanking.thighs.name"
	description = "Smack their thighs with a spanking pad."
	description_translation_key = "ui.interaction_panel.interaction.toy.spanking.thighs.description"
	target_required_parts = list("thighs")
	message = list(
		"smacks %ITEM% against %TARGET%'s thighs.",
		"spanks %TARGET%'s thighs with %ITEM%.",
		"brings %ITEM% down across %TARGET%'s thighs."
	)
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)
	target_pain = list(2, 4)

/datum/interaction/howling_item/feather
	category = "Feather"
	category_translation_key = "ui.interaction_panel.category.toy.feather"
	user_required_item_paths = list(/obj/item/tickle_feather)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/hug.ogg')

/datum/interaction/howling_item/feather/chest
	name = "Trail Feather Over Chest"
	translation_key = "ui.interaction_panel.interaction.toy.feather.chest.name"
	description = "Drag a feather over their chest."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.chest.description"
	target_required_parts = list("chest")
	message = list(
		"trails %ITEM% over %TARGET%'s chest.",
		"draws %ITEM%'s tip down %TARGET%'s chest.",
		"teases %TARGET%'s chest with slow strokes from %ITEM%."
	)
	user_arousal = list(0, 2)
	target_pleasure = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_item/feather/pussy
	name = "Tease Pussy With Feather"
	translation_key = "ui.interaction_panel.interaction.toy.feather.pussy.name"
	description = "Tickle their pussy with a feather."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.pussy.description"
	target_required_parts = list("vagina")
	message = list(
		"teases %TARGET%'s pussy with %ITEM%.",
		"brushes %ITEM% through %TARGET%'s folds.",
		"tickles %TARGET%'s clit and pussy with %ITEM%."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/feather/feet
	name = "Trace Their Feet With Feather"
	translation_key = "ui.interaction_panel.interaction.toy.feather.feet.name"
	description = "Run a feather over their feet."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.feet.description"
	target_required_parts = list("feet")
	message = list(
		"traces %TARGET%'s feet with %ITEM%.",
		"brushes %ITEM% over %TARGET%'s soles.",
		"teases %TARGET%'s feet with the tip of %ITEM%."
	)
	user_arousal = list(0, 2)
	target_pleasure = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_item/feather/thighs
	name = "Trail Feather Between Thighs"
	translation_key = "ui.interaction_panel.interaction.toy.feather.thighs.name"
	description = "Tease the insides of their thighs with a feather."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.thighs.description"
	target_required_parts = list("thighs")
	message = list(
		"trails %ITEM% between %TARGET%'s thighs.",
		"brushes %ITEM% up the insides of %TARGET%'s thighs.",
		"teases the sensitive skin between %TARGET%'s legs with %ITEM%."
	)
	user_arousal = list(0, 2)
	target_pleasure = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/feather/neck
	name = "Brush Feather Along Neck"
	translation_key = "ui.interaction_panel.interaction.toy.feather.neck.name"
	description = "Run a feather over their neck."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.neck.description"
	target_required_parts = list("neck")
	message = list(
		"brushes %ITEM% along %TARGET%'s neck.",
		"skims %ITEM% over %TARGET%'s throat and neck.",
		"teases %TARGET%'s neck with light feathery strokes."
	)
	user_arousal = list(0, 2)
	target_pleasure = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_item/feather/snout
	name = "Brush Feather Over Snout"
	translation_key = "ui.interaction_panel.interaction.toy.feather.snout.name"
	description = "Trace a feather over their snout."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.snout.description"
	target_required_parts = list("snout")
	message = list(
		"brushes %ITEM% over %TARGET%'s snout.",
		"traces %ITEM%'s tip along %TARGET%'s muzzle.",
		"teases %TARGET%'s snout with the light touch of %ITEM%."
	)
	user_arousal = list(0, 2)
	target_pleasure = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_item/feather/hands
	name = "Trace Their Hands With Feather"
	translation_key = "ui.interaction_panel.interaction.toy.feather.hands.name"
	description = "Run a feather over their palms and fingers."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.hands.description"
	target_required_parts = list("hands")
	message = list(
		"traces %TARGET%'s hands with %ITEM%.",
		"brushes %ITEM% over %TARGET%'s palms and fingers.",
		"teases %TARGET%'s hands with the soft tip of %ITEM%."
	)
	user_arousal = list(0, 2)
	target_pleasure = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_item/feather/ears
	name = "Brush Feather Over Ears"
	translation_key = "ui.interaction_panel.interaction.toy.feather.ears.name"
	description = "Tease their ears with a feather."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.ears.description"
	target_required_parts = list("ears")
	message = list(
		"brushes %ITEM% over %TARGET%'s ears.",
		"traces %ITEM%'s tip along %TARGET%'s ear.",
		"teases %TARGET%'s ears with feathery little strokes."
	)
	user_arousal = list(0, 2)
	target_pleasure = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_item/feather/armpits
	name = "Tease Armpits With Feather"
	translation_key = "ui.interaction_panel.interaction.toy.feather.armpits.name"
	description = "Tickle their armpits with a feather."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.armpits.description"
	target_required_parts = list("armpits")
	message = list(
		"teases %TARGET%'s armpit with %ITEM%.",
		"brushes %ITEM% into the hollow of %TARGET%'s armpit.",
		"tickles %TARGET%'s armpit with the tip of %ITEM%."
	)
	user_arousal = list(0, 2)
	target_pleasure = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_item/feather/tail
	name = "Brush Feather Along Tail"
	translation_key = "ui.interaction_panel.interaction.toy.feather.tail.name"
	description = "Trace a feather along their tail."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.tail.description"
	target_required_parts = list("tail")
	message = list(
		"brushes %ITEM% along %TARGET%'s tail.",
		"traces %ITEM%'s tip down %TARGET%'s tail.",
		"teases %TARGET%'s tail with light feathery strokes."
	)
	user_arousal = list(0, 2)
	target_pleasure = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_item/feather/groin
	name = "Tease Groin With Feather"
	translation_key = "ui.interaction_panel.interaction.toy.feather.groin.name"
	description = "Tickle their groin with a feather."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.groin.description"
	target_required_parts = list("groin")
	message = list(
		"teases %TARGET%'s groin with %ITEM%.",
		"brushes %ITEM% over the sensitive heat of %TARGET%'s groin.",
		"tickles %TARGET%'s groin with the tip of %ITEM%."
	)
	user_arousal = list(0, 2)
	target_pleasure = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_item/feather/body
	name = "Trail Feather Over Body"
	translation_key = "ui.interaction_panel.interaction.toy.feather.body.name"
	description = "Drag a feather over their body in long teasing strokes."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.body.description"
	target_required_parts = list("body")
	message = list(
		"trails %ITEM% over %TARGET%'s body.",
		"draws %ITEM%'s tip across %TARGET%'s body in long strokes.",
		"teases %TARGET%'s body with the light touch of %ITEM%."
	)
	user_arousal = list(0, 2)
	target_pleasure = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_item/shocker
	category = "Shocker"
	category_translation_key = "ui.interaction_panel.category.toy.shocker"
	user_required_item_paths = list(/obj/item/kinky_shocker)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/effects/sparks/sparks1.ogg')

/datum/interaction/howling_item/shocker/nipples
	name = "Shock Their Nipples"
	translation_key = "ui.interaction_panel.interaction.toy.shocker.nipples.name"
	description = "Touch a shocker to their nipples."
	description_translation_key = "ui.interaction_panel.interaction.toy.shocker.nipples.description"
	target_required_parts = list("breasts")
	message = list(
		"touches %ITEM% to %TARGET%'s nipples.",
		"zaps %TARGET%'s nipples with %ITEM%.",
		"holds %ITEM% to %TARGET%'s sensitive nipples and lets it crackle there."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)
	target_pain = list(2, 4)

/datum/interaction/howling_item/shocker/cock
	name = "Shock Their Cock"
	translation_key = "ui.interaction_panel.interaction.toy.shocker.cock.name"
	description = "Press a shocker to their cock."
	description_translation_key = "ui.interaction_panel.interaction.toy.shocker.cock.description"
	target_required_parts = list("penis")
	message = list(
		"presses %ITEM% to %TARGET%'s cock.",
		"zaps %TARGET%'s shaft with %ITEM%.",
		"holds %ITEM% to %TARGET%'s cock and lets it crackle there."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)
	target_pain = list(2, 4)

/datum/interaction/howling_item/shocker/pussy
	name = "Shock Their Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.shocker.pussy.name"
	description = "Press a shocker to their pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.shocker.pussy.description"
	target_required_parts = list("vagina")
	message = list(
		"presses %ITEM% to %TARGET%'s pussy.",
		"zaps %TARGET%'s folds with %ITEM%.",
		"holds %ITEM% to %TARGET%'s pussy and lets it crackle there."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)
	target_pain = list(2, 4)

/datum/interaction/howling_item/shocker/ass
	name = "Shock Their Ass"
	translation_key = "ui.interaction_panel.interaction.toy.shocker.ass.name"
	description = "Press a shocker to their ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.shocker.ass.description"
	target_required_parts = list("anus")
	message = list(
		"presses %ITEM% to %TARGET%'s ass.",
		"zaps %TARGET%'s entrance with %ITEM%.",
		"holds %ITEM% to %TARGET%'s rear and lets it crackle there."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)
	target_pain = list(2, 4)

/datum/interaction/howling_item/candle
	category = "Wax Play"
	category_translation_key = "ui.interaction_panel.category.toy.wax_play"
	user_required_item_paths = list(/obj/item/bdsm_candle)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/items/weapons/slap.ogg')

/datum/interaction/howling_item/candle/chest
	name = "Drip Wax On Chest"
	translation_key = "ui.interaction_panel.interaction.toy.wax_play.chest.name"
	description = "Drip warm wax over their chest."
	description_translation_key = "ui.interaction_panel.interaction.toy.wax_play.chest.description"
	target_required_parts = list("chest")
	message = list(
		"drips wax from %ITEM% over %TARGET%'s chest.",
		"tilts %ITEM% and lets warm wax spatter %TARGET%'s chest.",
		"trails hot droplets from %ITEM% down %TARGET%'s chest."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)
	target_pain = list(1, 3)

/datum/interaction/howling_item/candle/thighs
	name = "Drip Wax On Thighs"
	translation_key = "ui.interaction_panel.interaction.toy.wax_play.thighs.name"
	description = "Drip warm wax over their thighs."
	description_translation_key = "ui.interaction_panel.interaction.toy.wax_play.thighs.description"
	target_required_parts = list("thighs")
	message = list(
		"drips wax from %ITEM% over %TARGET%'s thighs.",
		"lets warm droplets from %ITEM% patter across %TARGET%'s thighs.",
		"tilts %ITEM% and traces hot wax over %TARGET%'s legs."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)
	target_pain = list(1, 3)

/datum/interaction/howling_item/candle/butt
	name = "Drip Wax On Ass"
	translation_key = "ui.interaction_panel.interaction.toy.wax_play.butt.name"
	description = "Drip warm wax over their ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.wax_play.butt.description"
	target_required_parts = list("butt")
	message = list(
		"drips wax from %ITEM% over %TARGET%'s ass.",
		"lets warm wax fall over %TARGET%'s rear from %ITEM%.",
		"tilts %ITEM% and traces hot droplets over %TARGET%'s ass."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)
	target_pain = list(1, 3)

/datum/interaction/howling_item/plug
	category = "Buttplug"
	category_translation_key = "ui.interaction_panel.category.toy.buttplug"
	user_required_item_paths = list(/obj/item/clothing/sextoy/buttplug)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/champ_fingering.ogg')

/datum/interaction/howling_item/plug/tease_ass
	name = "Tease Ass With Plug"
	translation_key = "ui.interaction_panel.interaction.toy.buttplug.tease_ass.name"
	description = "Circle a plug over their rear."
	description_translation_key = "ui.interaction_panel.interaction.toy.buttplug.tease_ass.description"
	target_required_parts = list("anus")
	message = list(
		"teases %TARGET%'s ass with %ITEM%.",
		"circles %ITEM% against %TARGET%'s entrance.",
		"rubs the rounded tip of %ITEM% over %TARGET%'s ass."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(2, 4)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/plug/insert_ass
	name = "Ease Plug Into Ass"
	translation_key = "ui.interaction_panel.interaction.toy.buttplug.insert_ass.name"
	description = "Work a plug into their ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.buttplug.insert_ass.description"
	target_required_parts = list("anus")
	message = list(
		"eases %ITEM% into %TARGET%'s ass.",
		"eases %ITEM% into %TARGET%'s rear a little at a time.",
		"presses %ITEM% past %TARGET%'s entrance until it settles in place."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)
	target_pain = list(0, 2)

/datum/interaction/howling_item/plug/insert_pussy
	name = "Ease Plug Into Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.buttplug.insert_pussy.name"
	description = "Work a plug into their pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.buttplug.insert_pussy.description"
	target_required_parts = list("vagina")
	message = list(
		"eases %ITEM% into %TARGET%'s pussy.",
		"works %ITEM% into %TARGET%'s folds until it settles in place.",
		"presses %ITEM% into %TARGET%'s pussy and leaves it snug inside."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/plug/grind_ass
	name = "Grind Plug Between Cheeks"
	translation_key = "ui.interaction_panel.interaction.toy.buttplug.grind_ass.name"
	description = "Rub a plug between their asscheeks."
	description_translation_key = "ui.interaction_panel.interaction.toy.buttplug.grind_ass.description"
	target_required_parts = list("butt")
	message = list(
		"grinds %ITEM% between %TARGET%'s cheeks.",
		"rubs %ITEM% along %TARGET%'s asscheeks and rear.",
		"presses %ITEM% between %TARGET%'s cheeks and rocks it there."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(2, 4)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/plug/press_pussy
	name = "Press Plug To Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.buttplug.press_pussy.name"
	description = "Press the rounded plug to their folds."
	description_translation_key = "ui.interaction_panel.interaction.toy.buttplug.press_pussy.description"
	target_required_parts = list("vagina")
	message = list(
		"presses %ITEM% to %TARGET%'s pussy.",
		"rubs %ITEM% through %TARGET%'s folds.",
		"works the smooth curve of %ITEM% over %TARGET%'s clit and pussy."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/plug/lips
	name = "Press Plug To Lips"
	translation_key = "ui.interaction_panel.interaction.toy.buttplug.lips.name"
	description = "Press the plug to their lips."
	description_translation_key = "ui.interaction_panel.interaction.toy.buttplug.lips.description"
	target_required_parts = list("mouth")
	message = list(
		"presses %ITEM% to %TARGET%'s lips.",
		"holds the rounded tip of %ITEM% at %TARGET%'s mouth.",
		"taps %ITEM% against %TARGET%'s lips in a teasing offer."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/egg
	category = "Egg Vibrator"
	category_translation_key = "ui.interaction_panel.category.toy.egg_vibrator"
	user_required_item_paths = list(/obj/item/clothing/sextoy/eggvib)
	user_blocked_item_paths = list(/obj/item/clothing/sextoy/eggvib/signalvib)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/vibrate.ogg')

/datum/interaction/howling_item/egg/clit
	name = "Hum Egg Over Clit"
	translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.clit.name"
	description = "Work an egg vibrator over their clit."
	description_translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.clit.description"
	target_required_parts = list("vagina")
	message = list(
		"works %ITEM% over %TARGET%'s clit.",
		"presses %ITEM% into %TARGET%'s folds and keeps it humming there.",
		"glides %ITEM% over %TARGET%'s clit in tight circles."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/egg/insert_pussy
	name = "Slip Egg Into Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.insert_pussy.name"
	description = "Push an egg vibrator into their pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.insert_pussy.description"
	target_required_parts = list("vagina")
	message = list(
		"slips %ITEM% into %TARGET%'s pussy.",
		"works %ITEM% into %TARGET%'s folds until it disappears inside.",
		"presses %ITEM% into %TARGET%'s pussy and lets it thrum there."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/egg/insert_ass
	name = "Slip Egg Into Ass"
	translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.insert_ass.name"
	description = "Push an egg vibrator into their ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.insert_ass.description"
	target_required_parts = list("anus")
	message = list(
		"slips %ITEM% into %TARGET%'s ass.",
		"works %ITEM% into %TARGET%'s rear until it settles inside.",
		"presses %ITEM% into %TARGET%'s ass and leaves it trembling there."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)
	target_pain = list(0, 2)

/datum/interaction/howling_item/egg/nipples
	name = "Buzz Nipples With Egg"
	translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.nipples.name"
	description = "Hold the egg against their nipples."
	description_translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.nipples.description"
	target_required_parts = list("breasts")
	message = list(
		"buzzes %ITEM% over %TARGET%'s nipples.",
		"holds %ITEM% to %TARGET%'s sensitive nipples.",
		"presses the humming curve of %ITEM% against %TARGET%'s breasts."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/egg/lips
	name = "Buzz Lips With Egg"
	translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.lips.name"
	description = "Hold the egg vibrator to their lips."
	description_translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.lips.description"
	target_required_parts = list("mouth")
	message = list(
		"buzzes %ITEM% at %TARGET%'s lips.",
		"holds %ITEM%'s humming curve to %TARGET%'s mouth.",
		"presses %ITEM% to %TARGET%'s lips and lets it thrum there."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/ring
	category = "Vibrating Ring"
	category_translation_key = "ui.interaction_panel.category.toy.vibrating_ring"
	user_required_item_paths = list(/obj/item/clothing/sextoy/vibroring)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/vibrate.ogg')

/datum/interaction/howling_item/ring/cock
	name = "Roll Ring Along Cock"
	translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.cock.name"
	description = "Work a vibrating ring over their cock."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.cock.description"
	target_required_parts = list("penis")
	message = list(
		"rolls %ITEM% along %TARGET%'s cock.",
		"works %ITEM% up %TARGET%'s shaft in slow passes.",
		"presses %ITEM% over %TARGET%'s cock and lets it buzz there."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/ring/tip
	name = "Buzz Tip With Ring"
	translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.tip.name"
	description = "Hold a vibrating ring against their tip."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.tip.description"
	target_required_parts = list("penis")
	message = list(
		"buzzes %ITEM% against %TARGET%'s tip.",
		"holds %ITEM% to the head of %TARGET%'s cock.",
		"presses the humming edge of %ITEM% over %TARGET%'s slit and tip."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/ring/clit
	name = "Press Ring To Clit"
	translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.clit.name"
	description = "Use the vibrating ring on their clit."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.clit.description"
	target_required_parts = list("vagina")
	message = list(
		"presses %ITEM% to %TARGET%'s clit.",
		"works %ITEM% over %TARGET%'s clit and folds.",
		"keeps %ITEM% humming against %TARGET%'s clit in short teasing presses."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/ring/balls
	name = "Buzz Balls With Ring"
	translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.balls.name"
	description = "Work the vibrating ring under their balls."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.balls.description"
	target_required_parts = list("balls")
	message = list(
		"buzzes %ITEM% beneath %TARGET%'s balls.",
		"presses %ITEM% under %TARGET%'s sack and lets it hum there.",
		"works %ITEM%'s vibrating edge beneath %TARGET%'s balls."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/clamps
	category = "Nipple Clamps"
	category_translation_key = "ui.interaction_panel.category.toy.nipple_clamps"
	user_required_item_paths = list(/obj/item/clothing/sextoy/nipple_clamps)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/hug.ogg')

/datum/interaction/howling_item/clamps/attach
	name = "Clamp Their Nipples"
	translation_key = "ui.interaction_panel.interaction.toy.nipple_clamps.attach.name"
	description = "Fasten the clamps onto their nipples."
	description_translation_key = "ui.interaction_panel.interaction.toy.nipple_clamps.attach.description"
	target_required_parts = list("breasts")
	message = list(
		"clamps %ITEM% onto %TARGET%'s nipples.",
		"fastens %ITEM% onto %TARGET%'s sensitive nipples.",
		"attaches %ITEM% to %TARGET%'s nipples and leaves them pinched there."
	)
	user_arousal = list(2, 4)
	target_arousal = list(2, 4)
	target_pain = list(1, 3)

/datum/interaction/howling_item/clamps/tug
	name = "Tug Nipple Clamps"
	translation_key = "ui.interaction_panel.interaction.toy.nipple_clamps.tug.name"
	description = "Pull on the clamps once they're on."
	description_translation_key = "ui.interaction_panel.interaction.toy.nipple_clamps.tug.description"
	target_required_parts = list("breasts")
	message = list(
		"tugs on %ITEM% where they bite into %TARGET%'s nipples.",
		"gives %ITEM% a sharp pull against %TARGET%'s nipples.",
		"draws %ITEM% out just enough to make %TARGET%'s nipples strain."
	)
	user_arousal = list(2, 4)
	target_arousal = list(2, 4)
	target_pain = list(2, 4)

/datum/interaction/howling_item/clamps/kiss
	name = "Kiss Clamped Nipples"
	translation_key = "ui.interaction_panel.interaction.toy.nipple_clamps.kiss.name"
	description = "Kiss around their clamped nipples."
	description_translation_key = "ui.interaction_panel.interaction.toy.nipple_clamps.kiss.description"
	target_required_parts = list("breasts")
	message = list(
		"kisses around %ITEM% on %TARGET%'s nipples.",
		"presses slow kisses to %TARGET%'s nipples around %ITEM%.",
		"mouths at %TARGET%'s nipples while %ITEM% pinches them tight."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(2, 4)
	target_arousal = list(3, 5)
	target_pain = list(1, 3)

/datum/interaction/howling_item_inserted
	parent_type = /datum/interaction/howling_extra
	color = "pink"

/datum/interaction/howling_item_inserted/plug
	category = "Buttplug"
	category_translation_key = "ui.interaction_panel.category.toy.buttplug"
	target_required_item_slots = list("anus", "vagina")
	target_required_item_paths = list(/obj/item/clothing/sextoy/buttplug)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/champ_fingering.ogg')

/datum/interaction/howling_item_inserted/plug/rock
	name = "Rock Their Plug"
	translation_key = "ui.interaction_panel.interaction.toy.buttplug.rock.name"
	description = "Work the plug already inside them."
	description_translation_key = "ui.interaction_panel.interaction.toy.buttplug.rock.description"
	message = list(
		"rocks %ITEM% inside %TARGET%.",
		"works %ITEM% in slow motions inside %TARGET%.",
		"presses against %ITEM% and makes it shift inside %TARGET%."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(3, 5)
	target_arousal = list(3, 5)

/datum/interaction/howling_item_inserted/plug/pull
	name = "Ease Plug Partway Out"
	translation_key = "ui.interaction_panel.interaction.toy.buttplug.pull.name"
	description = "Draw the plug out partway before pressing it back in."
	description_translation_key = "ui.interaction_panel.interaction.toy.buttplug.pull.description"
	message = list(
		"eases %ITEM% partway out of %TARGET%, then presses it back in.",
		"draws %ITEM% out of %TARGET% just enough to tease.",
		"pulls %ITEM% almost free before easing it back inside %TARGET%."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)
	target_pain = list(0, 2)

/datum/interaction/howling_item_inserted/plug/kiss
	name = "Kiss Around Plug"
	translation_key = "ui.interaction_panel.interaction.toy.buttplug.kiss.name"
	description = "Kiss around the plug while it stays inside."
	description_translation_key = "ui.interaction_panel.interaction.toy.buttplug.kiss.description"
	message = list(
		"kisses around %ITEM% where it sits inside %TARGET%.",
		"presses kisses around %ITEM% while it stays snug inside %TARGET%.",
		"mouths at %TARGET% around %ITEM% without pulling it free."
	)
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	user_arousal = list(1, 3)
	target_pleasure = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_item_inserted/egg
	category = "Egg Vibrator"
	category_translation_key = "ui.interaction_panel.category.toy.egg_vibrator"
	target_required_item_slots = list("vagina", "anus")
	target_required_item_paths = list(/obj/item/clothing/sextoy/eggvib)
	target_blocked_item_paths = list(/obj/item/clothing/sextoy/eggvib/signalvib)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/vibrate.ogg')

/datum/interaction/howling_item_inserted/egg/pulse
	name = "Pulse Inserted Egg"
	translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.pulse.name"
	description = "Enjoy the egg already tucked inside them."
	description_translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.pulse.description"
	message = list(
		"lets %ITEM% pulse inside %TARGET%.",
		"keeps %ITEM% humming inside %TARGET%.",
		"draws out the trembling hum of %ITEM% inside %TARGET%."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item_inserted/egg/grind
	name = "Grind Against Inserted Egg"
	translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.grind.name"
	description = "Grind them around the egg already inside."
	description_translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.grind.description"
	message = list(
		"grinds %TARGET% around the shape of %ITEM% inside them.",
		"presses %TARGET% into the trembling shape of %ITEM% inside them.",
		"works %TARGET%'s body around %ITEM% while it hums inside."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item_inserted/egg/pull
	name = "Tease Egg At Entrance"
	translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.pull.name"
	description = "Draw the egg to the edge before slipping it back in."
	description_translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.pull.description"
	message = list(
		"teases %ITEM% at %TARGET%'s entrance before slipping it back in.",
		"draws %ITEM% almost free from %TARGET%, then eases it back inside.",
		"lets %ITEM% drag at %TARGET%'s entrance before pressing it deep again."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)
	target_pain = list(0, 1)

/datum/interaction/howling_item_inserted/ring
	category = "Vibrating Ring"
	category_translation_key = "ui.interaction_panel.category.toy.vibrating_ring"
	target_required_item_slots = list("penis")
	target_required_item_paths = list(/obj/item/clothing/sextoy/vibroring)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/vibrate.ogg')

/datum/interaction/howling_item_inserted/ring/stroke
	name = "Stroke Ringed Cock"
	translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.stroke.name"
	description = "Work their cock while the vibrating ring stays on."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.stroke.description"
	message = list(
		"strokes %TARGET%'s cock with %ITEM% still snug around it.",
		"works %TARGET%'s ringed cock in slow strokes.",
		"pumps %TARGET%'s cock while %ITEM% hums around it."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item_inserted/ring/tip
	name = "Work Tip Through Ring"
	translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.ring_tip.name"
	description = "Focus on the head while the ring stays in place."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.ring_tip.description"
	message = list(
		"works %TARGET%'s tip through %ITEM%.",
		"strokes %TARGET%'s head while %ITEM% hugs the shaft beneath it.",
		"teases %TARGET%'s tip while %ITEM% keeps buzzing lower down."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item_inserted/ring/balls
	name = "Cup Ringed Cock And Balls"
	translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.ring_balls.name"
	description = "Hold them around the vibrating ring and the rest of their package."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.ring_balls.description"
	message = list(
		"cups %TARGET%'s cock and balls around %ITEM%.",
		"holds %TARGET%'s ringed cock and sack together in one firm grip.",
		"cradles %TARGET%'s cock and balls while %ITEM% keeps humming."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(3, 5)
	target_arousal = list(3, 5)

/datum/interaction/howling_item_inserted/clamps
	category = "Nipple Clamps"
	category_translation_key = "ui.interaction_panel.category.toy.nipple_clamps"
	target_required_item_slots = list("nipples")
	target_required_item_paths = list(/obj/item/clothing/sextoy/nipple_clamps)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/hug.ogg')

/datum/interaction/howling_item_inserted/clamps/tug
	name = "Tug Attached Clamps"
	translation_key = "ui.interaction_panel.interaction.toy.nipple_clamps.attached_tug.name"
	description = "Pull on the clamps already fastened to them."
	description_translation_key = "ui.interaction_panel.interaction.toy.nipple_clamps.attached_tug.description"
	message = list(
		"tugs on %ITEM% where they hang from %TARGET%'s nipples.",
		"gives %ITEM% a sharp pull from %TARGET%'s nipples.",
		"draws %ITEM% taut and makes %TARGET%'s nipples strain beneath them."
	)
	user_arousal = list(2, 4)
	target_arousal = list(2, 4)
	target_pain = list(2, 4)

/datum/interaction/howling_item_inserted/clamps/lick
	name = "Lick Clamped Nipples"
	translation_key = "ui.interaction_panel.interaction.toy.nipple_clamps.lick.name"
	description = "Lick at their nipples while the clamps stay on."
	description_translation_key = "ui.interaction_panel.interaction.toy.nipple_clamps.lick.description"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	message = list(
		"licks at %TARGET%'s nipples around %ITEM%.",
		"laps slowly at %TARGET%'s clamped nipples.",
		"teases %TARGET%'s nipples with tongue and lips while %ITEM% keeps pinching them."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(2, 4)
	target_arousal = list(3, 5)
	target_pain = list(1, 3)

/datum/interaction/howling_item_inserted/clamps/twist
	name = "Twist Attached Clamps"
	translation_key = "ui.interaction_panel.interaction.toy.nipple_clamps.twist.name"
	description = "Twist the clamps without removing them."
	description_translation_key = "ui.interaction_panel.interaction.toy.nipple_clamps.twist.description"
	message = list(
		"twists %ITEM% where they cling to %TARGET%'s nipples.",
		"rolls %ITEM% against %TARGET%'s nipples in a tight turn.",
		"works %ITEM% around %TARGET%'s nipples without taking them off."
	)
	user_arousal = list(2, 4)
	target_arousal = list(2, 4)
	target_pain = list(2, 4)

/datum/interaction/howling_item/condom
	category = "Condom"
	category_translation_key = "ui.interaction_panel.category.toy.condom"
	user_required_item_paths = list(/obj/item/clothing/sextoy/condom)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/latex.ogg')

/datum/interaction/howling_item/condom/apply
	name = "Roll Condom Onto Cock"
	translation_key = "ui.interaction_panel.interaction.toy.condom.apply.name"
	description = "Unroll a condom down their cock."
	description_translation_key = "ui.interaction_panel.interaction.toy.condom.apply.description"
	target_required_parts = list("penis")
	message = list(
		"rolls %ITEM% onto %TARGET%'s cock.",
		"stretches %ITEM% over %TARGET%'s tip and rolls it down.",
		"fits %ITEM% over %TARGET%'s cock in one slow smooth pull."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item/condom/lips
	name = "Tease Cock With Condom"
	translation_key = "ui.interaction_panel.interaction.toy.condom.lips.name"
	description = "Brush the wrapped condom over their tip before rolling it on."
	description_translation_key = "ui.interaction_panel.interaction.toy.condom.lips.description"
	target_required_parts = list("penis")
	message = list(
		"teases %TARGET%'s tip with %ITEM%.",
		"brushes %ITEM% over %TARGET%'s tip before rolling it on.",
		"lets the slick rim of %ITEM% drag across %TARGET%'s head."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item_inserted/condom
	category = "Condom"
	category_translation_key = "ui.interaction_panel.category.toy.condom"
	target_required_item_slots = list("penis")
	target_required_item_paths = list(/obj/item/clothing/sextoy/condom)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/champ_fingering.ogg')

/datum/interaction/howling_item_inserted/condom/stroke
	name = "Stroke Condomed Cock"
	translation_key = "ui.interaction_panel.interaction.toy.condom.stroke.name"
	description = "Work their cock while the condom stays on."
	description_translation_key = "ui.interaction_panel.interaction.toy.condom.stroke.description"
	message = list(
		"strokes %TARGET%'s condom-sheathed cock.",
		"works %TARGET%'s cock through %ITEM% in slow slick strokes.",
		"slides a hand over %TARGET%'s cock with %ITEM% stretched tight over it."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(3, 5)

/datum/interaction/howling_item_inserted/condom/tip
	name = "Rub Covered Tip"
	translation_key = "ui.interaction_panel.interaction.toy.condom.tip.name"
	description = "Focus on the head through the condom."
	description_translation_key = "ui.interaction_panel.interaction.toy.condom.tip.description"
	message = list(
		"rubs %TARGET%'s tip through %ITEM%.",
		"presses at %TARGET%'s head through %ITEM%'s thin latex.",
		"works %TARGET%'s sensitive tip through the tight stretch of %ITEM%."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)

/datum/interaction/howling_item_inserted/condom/mouth
	name = "Suck Condomed Cock"
	translation_key = "ui.interaction_panel.interaction.toy.condom.mouth.name"
	description = "Use your mouth on their condom-covered cock."
	description_translation_key = "ui.interaction_panel.interaction.toy.condom.mouth.description"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	message = list(
		"mouths %TARGET%'s cock through %ITEM%.",
		"takes %TARGET%'s condom-covered cock into %USER_PRONOUN_THEIR% mouth.",
		"slides lips and tongue over %ITEM% stretched tight around %TARGET%'s cock."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)

/datum/interaction/howling_item_inserted/signal_egg
	category = "Signal Egg"
	category_translation_key = "ui.interaction_panel.category.toy.signal_egg"
	target_required_item_slots = list("vagina", "anus", "nipples", "penis")
	target_required_item_paths = list(/obj/item/clothing/sextoy/eggvib/signalvib)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/vibrate.ogg')

/datum/interaction/howling_item_inserted/signal_egg/trigger
	name = "Trigger Remote Egg"
	translation_key = "ui.interaction_panel.interaction.toy.signal_egg.trigger.name"
	description = "Set off the signal-controlled toy already on them."
	description_translation_key = "ui.interaction_panel.interaction.toy.signal_egg.trigger.description"
	message = list(
		"triggers %ITEM% where it sits on %TARGET%.",
		"sets %ITEM% humming inside %TARGET% with a remote signal.",
		"activates %ITEM% and makes %TARGET% jolt at the sudden vibration."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item_inserted/signal_egg/pulse
	name = "Keep Remote Egg Humming"
	translation_key = "ui.interaction_panel.interaction.toy.signal_egg.pulse.name"
	description = "Hold them in that remote-controlled vibration."
	description_translation_key = "ui.interaction_panel.interaction.toy.signal_egg.pulse.description"
	message = list(
		"keeps %ITEM% humming on %TARGET%.",
		"draws out the remote pulse of %ITEM% on %TARGET%.",
		"keeps %ITEM% thrumming on %TARGET% without giving them a break."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item_inserted/double_dildo
	category = "Double Dildo"
	category_translation_key = "ui.interaction_panel.category.toy.double_dildo"
	target_required_item_slots = list("vagina", "anus")
	target_required_item_paths = list(/obj/item/clothing/sextoy/dildo/double_dildo)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/bang1.ogg')

/datum/interaction/howling_item_inserted/double_dildo/rock
	name = "Rock Double Dildo"
	translation_key = "ui.interaction_panel.interaction.toy.double_dildo.rock.name"
	description = "Work the double dildo already seated inside them."
	description_translation_key = "ui.interaction_panel.interaction.toy.double_dildo.rock.description"
	message = list(
		"rocks %ITEM% inside %TARGET%.",
		"works %ITEM% inside %TARGET% in deep rolling motions.",
		"presses against %ITEM% and makes it shift deep inside %TARGET%."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item_inserted/double_dildo/pull
	name = "Draw Double Dildo To Edge"
	translation_key = "ui.interaction_panel.interaction.toy.double_dildo.pull.name"
	description = "Pull the double dildo almost free before easing it back."
	description_translation_key = "ui.interaction_panel.interaction.toy.double_dildo.pull.description"
	message = list(
		"draws %ITEM% almost free from %TARGET% before easing it back in.",
		"teases %TARGET% by pulling %ITEM% to the edge and pressing it back deep.",
		"works %ITEM% out of %TARGET% just enough to make them feel every inch."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)
	target_pain = list(0, 2)

/datum/interaction/howling_item_inserted/double_dildo/grind
	name = "Grind On Double Dildo"
	translation_key = "ui.interaction_panel.interaction.toy.double_dildo.grind.name"
	description = "Grind them down on the double dildo."
	description_translation_key = "ui.interaction_panel.interaction.toy.double_dildo.grind.description"
	message = list(
		"grinds %TARGET% down on %ITEM%.",
		"works %TARGET%'s body around %ITEM% in deep rolling motions.",
		"presses %TARGET% hard against %ITEM% and makes them ride it out."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/custom_dildo
	category = "Custom Dildo"
	category_translation_key = "ui.interaction_panel.category.toy.custom_dildo"
	user_required_item_paths = list(/obj/item/clothing/sextoy/dildo/custom_dildo)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/champ_fingering.ogg')

/datum/interaction/howling_item/custom_dildo/size_pussy
	name = "Size Up Their Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.custom_dildo.size_pussy.name"
	description = "Use the custom dildo to test how much they can take."
	description_translation_key = "ui.interaction_panel.interaction.toy.custom_dildo.size_pussy.description"
	target_required_parts = list("vagina")
	message = list(
		"sizes up %TARGET%'s pussy with %ITEM%.",
		"works %ITEM% against %TARGET%'s folds to see how much they can take.",
		"tests %TARGET%'s pussy with %ITEM% in slow deliberate pushes."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/custom_dildo/stretch_pussy
	name = "Stretch Pussy With Custom Dildo"
	translation_key = "ui.interaction_panel.interaction.toy.custom_dildo.stretch_pussy.name"
	description = "Use the custom dildo to stretch their pussy wider."
	description_translation_key = "ui.interaction_panel.interaction.toy.custom_dildo.stretch_pussy.description"
	target_required_parts = list("vagina")
	message = list(
		"stretches %TARGET%'s pussy with %ITEM%.",
		"works %ITEM% into %TARGET%'s pussy in slow widening thrusts.",
		"presses %ITEM% deep into %TARGET%'s folds and makes them take the full shape."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)
	target_pain = list(0, 1)

/datum/interaction/howling_item/custom_dildo/stretch_ass
	name = "Stretch Ass With Custom Dildo"
	translation_key = "ui.interaction_panel.interaction.toy.custom_dildo.stretch_ass.name"
	description = "Use the custom dildo to open their ass wider."
	description_translation_key = "ui.interaction_panel.interaction.toy.custom_dildo.stretch_ass.description"
	target_required_parts = list("anus")
	message = list(
		"stretches %TARGET%'s ass with %ITEM%.",
		"works %ITEM% into %TARGET%'s rear in slow widening pushes.",
		"presses %ITEM% deeper into %TARGET%'s ass and makes them take its full size."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)
	target_pain = list(1, 3)

/datum/interaction/howling_item/custom_dildo/mouth
	name = "Feed Custom Dildo To Mouth"
	translation_key = "ui.interaction_panel.interaction.toy.custom_dildo.mouth.name"
	description = "Feed the custom dildo past their lips."
	description_translation_key = "ui.interaction_panel.interaction.toy.custom_dildo.mouth.description"
	target_required_parts = list("mouth")
	message = list(
		"feeds %ITEM% to %TARGET%'s mouth.",
		"eases %ITEM% past %TARGET%'s lips in slow measured pushes.",
		"guides %ITEM% into %TARGET%'s mouth and makes them feel its size."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/double_dildo
	category = "Double Dildo"
	category_translation_key = "ui.interaction_panel.category.toy.double_dildo"
	user_required_item_paths = list(/obj/item/clothing/sextoy/dildo/double_dildo)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'modular_nova/modules/modular_items/lewd_items/sounds/bang1.ogg',
		'modular_nova/modules/modular_items/lewd_items/sounds/bang2.ogg'
	)

/datum/interaction/howling_item/double_dildo/pussy
	name = "Seat Double Dildo In Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.double_dildo.pussy.name"
	description = "Push one end of the double dildo into their pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.double_dildo.pussy.description"
	target_required_parts = list("vagina")
	message = list(
		"seats one end of %ITEM% in %TARGET%'s pussy.",
		"pushes one side of %ITEM% into %TARGET%'s folds.",
		"works one end of %ITEM% into %TARGET%'s pussy until it sits snug."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/double_dildo/ass
	name = "Seat Double Dildo In Ass"
	translation_key = "ui.interaction_panel.interaction.toy.double_dildo.ass.name"
	description = "Push one end of the double dildo into their ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.double_dildo.ass.description"
	target_required_parts = list("anus")
	message = list(
		"seats one end of %ITEM% in %TARGET%'s ass.",
		"pushes one side of %ITEM% into %TARGET%'s rear.",
		"works one end of %ITEM% into %TARGET%'s ass until it settles there."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)
	target_pain = list(0, 2)

/datum/interaction/howling_item/double_dildo/thighs
	name = "Drag Double Dildo Between Thighs"
	translation_key = "ui.interaction_panel.interaction.toy.double_dildo.thighs.name"
	description = "Use the length of the double dildo between their thighs."
	description_translation_key = "ui.interaction_panel.interaction.toy.double_dildo.thighs.description"
	target_required_parts = list("thighs")
	message = list(
		"drags %ITEM% between %TARGET%'s thighs.",
		"works the length of %ITEM% through the heat between %TARGET%'s legs.",
		"presses %ITEM% between %TARGET%'s thighs and rocks it there."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/double_dildo/mouth
	name = "Feed Double Dildo To Mouth"
	translation_key = "ui.interaction_panel.interaction.toy.double_dildo.mouth.name"
	description = "Guide one end of the double dildo into their mouth."
	description_translation_key = "ui.interaction_panel.interaction.toy.double_dildo.mouth.description"
	target_required_parts = list("mouth")
	message = list(
		"feeds one end of %ITEM% to %TARGET%'s mouth.",
		"guides one side of %ITEM% past %TARGET%'s lips.",
		"works one end of %ITEM% into %TARGET%'s mouth in slow teasing pushes."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/signal_egg
	category = "Signal Egg"
	category_translation_key = "ui.interaction_panel.category.toy.signal_egg"
	user_required_item_paths = list(/obj/item/clothing/sextoy/eggvib/signalvib)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('modular_nova/modules/modular_items/lewd_items/sounds/vibrate.ogg')

/datum/interaction/howling_item/signal_egg/insert_pussy
	name = "Slip Remote Egg Into Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.signal_egg.insert_pussy.name"
	description = "Push the signal-controlled egg into their pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.signal_egg.insert_pussy.description"
	target_required_parts = list("vagina")
	message = list(
		"slips %ITEM% into %TARGET%'s pussy.",
		"works %ITEM% into %TARGET%'s folds until the remote toy disappears inside.",
		"presses %ITEM% into %TARGET%'s pussy and leaves it ready to be triggered."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)

/datum/interaction/howling_item/signal_egg/insert_ass
	name = "Slip Remote Egg Into Ass"
	translation_key = "ui.interaction_panel.interaction.toy.signal_egg.insert_ass.name"
	description = "Push the signal-controlled egg into their ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.signal_egg.insert_ass.description"
	target_required_parts = list("anus")
	message = list(
		"slips %ITEM% into %TARGET%'s ass.",
		"works %ITEM% into %TARGET%'s rear and leaves it ready to be triggered.",
		"presses %ITEM% into %TARGET%'s ass and settles it there for later remote play."
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)
	target_pain = list(0, 2)

/datum/interaction/howling_item/signal_egg/nipples
	name = "Set Remote Egg On Nipples"
	translation_key = "ui.interaction_panel.interaction.toy.signal_egg.nipples.name"
	description = "Fasten the remote egg against their nipples."
	description_translation_key = "ui.interaction_panel.interaction.toy.signal_egg.nipples.description"
	target_required_parts = list("breasts")
	message = list(
		"sets %ITEM% against %TARGET%'s nipples.",
		"fastens %ITEM% against %TARGET%'s sensitive nipples.",
		"places %ITEM% on %TARGET%'s breasts and leaves it ready to be triggered."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/signal_egg/penis
	name = "Set Remote Egg On Cock"
	translation_key = "ui.interaction_panel.interaction.toy.signal_egg.penis.name"
	description = "Set the remote egg against their cock."
	description_translation_key = "ui.interaction_panel.interaction.toy.signal_egg.penis.description"
	target_required_parts = list("penis")
	message = list(
		"sets %ITEM% against %TARGET%'s cock.",
		"positions %ITEM% along %TARGET%'s shaft for later remote play.",
		"presses %ITEM% to %TARGET%'s cock and leaves it ready to be triggered."
	)
	user_arousal = list(1, 3)
	target_pleasure = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_item/signal_egg/press_lips
	name = "Press Remote Egg To Lips"
	translation_key = "ui.interaction_panel.interaction.toy.signal_egg.press_lips.name"
	description = "Press the remote egg to their lips before using it elsewhere."
	description_translation_key = "ui.interaction_panel.interaction.toy.signal_egg.press_lips.description"
	target_required_parts = list("mouth")
	message = list(
		"teases %TARGET%'s lips with %ITEM%.",
		"presses %ITEM% to %TARGET%'s lips and lets them feel its shape.",
		"taps %ITEM% at %TARGET%'s mouth in a teasing promise of what's next."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_item_self/vibrator
	parent_type = /datum/interaction/howling_item/vibrator
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/vibrator/nipples
	name = "Tease Your Nipples With Vibrator"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_nipples.name"
	description = "Hold a vibrator against your own nipples."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_nipples.description"
	user_required_parts = list("breasts")
	message = list(
		"teases their own nipples with %ITEM%.",
		"buzzes %ITEM% over their nipples.",
		"holds %ITEM% against their sensitive nipples."
	)
	user_pleasure = list(2, 4)
	user_arousal = list(3, 5)

/datum/interaction/howling_item_self/vibrator/clit
	name = "Circle Your Clit With Vibrator"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_clit.name"
	description = "Circle a vibrator over your clit."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_clit.description"
	user_required_parts = list("vagina")
	message = list(
		"circles %ITEM% over their clit.",
		"moves %ITEM% against their clit in tight circles.",
		"presses %ITEM% to their clit and keeps it humming there."
	)
	user_pleasure = list(4, 6)
	user_arousal = list(4, 6)

/datum/interaction/howling_item_self/vibrator/cock
	name = "Run Vibrator Along Your Cock"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_cock.name"
	description = "Buzz a vibrator against your cock."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_cock.description"
	user_required_parts = list("penis")
	message = list(
		"runs %ITEM% along their cock.",
		"presses %ITEM% beneath their shaft.",
		"buzzes %ITEM% over their cock from base to tip."
	)
	user_pleasure = list(3, 5)
	user_arousal = list(4, 6)

/datum/interaction/howling_item_self/vibrator/ass
	name = "Press Vibrator To Your Ass"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_ass.name"
	description = "Buzz a vibrator against your rear."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_ass.description"
	user_required_parts = list("butt")
	message = list(
		"presses %ITEM% to their ass.",
		"runs %ITEM% over their rear in slow circles.",
		"keeps %ITEM% humming against their asscheeks."
	)
	user_pleasure = list(2, 4)
	user_arousal = list(2, 4)

/datum/interaction/howling_item_self/vibrator/lips
	name = "Press Vibrator To Your Lips"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_lips.name"
	description = "Hold a vibrator to your lips."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_lips.description"
	user_required_parts = list("mouth")
	message = list(
		"presses %ITEM% to their lips.",
		"holds %ITEM%'s humming tip against their lips.",
		"teases their lips with the vibration of %ITEM%."
	)
	user_pleasure = list(1, 3)
	user_arousal = list(2, 4)

/datum/interaction/howling_item_self/vibrator/ears
	name = "Buzz Your Ears"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_ears.name"
	description = "Hold a vibrator against your ears."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_ears.description"
	user_required_parts = list("ears")
	message = list(
		"buzzes %ITEM% against their ears.",
		"runs %ITEM%'s trembling tip along their ear.",
		"lets %ITEM% hum softly against their ears."
	)
	user_arousal = list(1, 3)

/datum/interaction/howling_item_self/vibrator/armpits
	name = "Press Vibrator To Your Armpits"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_armpits.name"
	description = "Press a vibrator into your armpits."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_armpits.description"
	user_required_parts = list("armpits")
	message = list(
		"presses %ITEM% into their armpit.",
		"runs %ITEM% along the hollow of their armpit.",
		"lets %ITEM% buzz against the sensitive skin of their armpit."
	)
	user_pleasure = list(0, 2)
	user_arousal = list(2, 4)

/datum/interaction/howling_item_self/vibrator/groin
	name = "Press Vibrator To Your Groin"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_groin.name"
	description = "Work a vibrator over your groin."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_groin.description"
	user_required_parts = list("groin")
	message = list(
		"presses %ITEM% to their groin.",
		"works %ITEM% over the heat of their groin.",
		"holds %ITEM% against their groin and lets it hum there."
	)
	user_pleasure = list(2, 4)
	user_arousal = list(3, 5)

/datum/interaction/howling_item_self/vibrator/body
	name = "Run Vibrator Over Your Body"
	translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_body.name"
	description = "Trail the vibrator over your body."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrator.self_body.description"
	user_required_parts = list("chest")
	message = list(
		"runs %ITEM% over their body.",
		"glides %ITEM% over their skin in slow teasing passes.",
		"lets %ITEM% hum across their body."
	)
	user_pleasure = list(1, 3)
	user_arousal = list(2, 4)

/datum/interaction/howling_item_self/wand
	parent_type = /datum/interaction/howling_item/wand
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/wand/breasts
	name = "Buzz Your Breasts"
	translation_key = "ui.interaction_panel.interaction.toy.wand.self_breasts.name"
	description = "Sweep a wand over your breasts."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.self_breasts.description"
	user_required_parts = list("breasts")
	message = list(
		"sweeps %ITEM% over their breasts.",
		"works %ITEM% over their chest in broad buzzing passes.",
		"holds the head of %ITEM% against their breasts."
	)
	user_pleasure = list(2, 4)
	user_arousal = list(3, 5)

/datum/interaction/howling_item_self/wand/pussy
	name = "Glide Wand Over Your Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.wand.self_pussy.name"
	description = "Work a wand over your pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.self_pussy.description"
	user_required_parts = list("vagina")
	message = list(
		"glides %ITEM% over their pussy.",
		"works %ITEM% over their folds in steady teasing motions.",
		"holds %ITEM% to their pussy and lets it thrum there."
	)
	user_pleasure = list(4, 6)
	user_arousal = list(4, 6)

/datum/interaction/howling_item_self/wand/cock
	name = "Buzz Your Cock"
	translation_key = "ui.interaction_panel.interaction.toy.wand.self_cock.name"
	description = "Use a wand on your cock."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.self_cock.description"
	user_required_parts = list("penis")
	message = list(
		"runs %ITEM% along their cock.",
		"presses the head of %ITEM% to their shaft.",
		"lets %ITEM% thrum against their cock."
	)
	user_pleasure = list(3, 5)
	user_arousal = list(4, 6)

/datum/interaction/howling_item_self/wand/lips
	name = "Brush Wand Over Your Lips"
	translation_key = "ui.interaction_panel.interaction.toy.wand.self_lips.name"
	description = "Brush the wand over your lips."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.self_lips.description"
	user_required_parts = list("mouth")
	message = list(
		"brushes %ITEM% over their lips.",
		"holds %ITEM%'s broad head against their lips.",
		"lets %ITEM% thrum lightly against their mouth."
	)
	user_pleasure = list(1, 3)
	user_arousal = list(2, 4)

/datum/interaction/howling_item_self/wand/ears
	name = "Press Wand To Your Ears"
	translation_key = "ui.interaction_panel.interaction.toy.wand.self_ears.name"
	description = "Hold the wand to your ears."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.self_ears.description"
	user_required_parts = list("ears")
	message = list(
		"presses %ITEM% to their ears.",
		"holds %ITEM%'s head to their ear and lets it hum there.",
		"works %ITEM% along their ears in soft buzzing passes."
	)
	user_arousal = list(1, 3)

/datum/interaction/howling_item_self/wand/groin
	name = "Sweep Wand Over Your Groin"
	translation_key = "ui.interaction_panel.interaction.toy.wand.self_groin.name"
	description = "Sweep the wand over your groin."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.self_groin.description"
	user_required_parts = list("groin")
	message = list(
		"sweeps %ITEM% over their groin.",
		"works %ITEM% over the heat between their legs.",
		"lets %ITEM% thrum against their groin in broad passes."
	)
	user_pleasure = list(2, 4)
	user_arousal = list(3, 5)

/datum/interaction/howling_item_self/wand/body
	name = "Sweep Wand Over Your Body"
	translation_key = "ui.interaction_panel.interaction.toy.wand.self_body.name"
	description = "Run the wand across your body."
	description_translation_key = "ui.interaction_panel.interaction.toy.wand.self_body.description"
	user_required_parts = list("chest")
	message = list(
		"sweeps %ITEM% over their body.",
		"guides %ITEM%'s broad head across their skin.",
		"lets %ITEM% thrum across their body in lazy passes."
	)
	user_pleasure = list(1, 3)
	user_arousal = list(2, 4)

/datum/interaction/howling_item_self/dildo
	parent_type = /datum/interaction/howling_item/dildo
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/dildo/pussy
	name = "Slide Dildo Into Your Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.dildo.self_pussy.name"
	description = "Push a dildo into your pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.dildo.self_pussy.description"
	user_required_parts = list("vagina")
	message = list(
		"slides %ITEM% into their pussy.",
		"works %ITEM% into their folds and sinks it inside.",
		"pushes %ITEM% into their own wet sex."
	)
	user_pleasure = list(4, 6)
	user_arousal = list(5, 7)

/datum/interaction/howling_item_self/dildo/ass
	name = "Slide Dildo Into Your Ass"
	translation_key = "ui.interaction_panel.interaction.toy.dildo.self_ass.name"
	description = "Push a dildo into your ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.dildo.self_ass.description"
	user_required_parts = list("anus")
	message = list(
		"slides %ITEM% into their ass.",
		"presses %ITEM% into their rear and takes it deeper.",
		"works %ITEM% into their own ass."
	)
	user_pleasure = list(3, 5)
	user_arousal = list(4, 6)
	user_pain = list(0, 2)

/datum/interaction/howling_item_self/fleshlight
	parent_type = /datum/interaction/howling_item/fleshlight
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/fleshlight/cock
	name = "Take Your Cock Into Fleshlight"
	translation_key = "ui.interaction_panel.interaction.toy.fleshlight.self_cock.name"
	description = "Work a fleshlight over your cock."
	description_translation_key = "ui.interaction_panel.interaction.toy.fleshlight.self_cock.description"
	user_required_parts = list("penis")
	message = list(
		"works %ITEM% over their cock.",
		"slides their shaft into %ITEM% and strokes themself with it.",
		"uses %ITEM% to milk their own cock."
	)
	user_pleasure = list(4, 6)
	user_arousal = list(4, 6)

/datum/interaction/howling_item_self/buttplug
	parent_type = /datum/interaction/howling_item/plug
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/buttplug/insert_ass
	name = "Ease Plug Into Your Ass"
	translation_key = "ui.interaction_panel.interaction.toy.buttplug.self_insert_ass.name"
	description = "Work a plug into your ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.buttplug.self_insert_ass.description"
	user_required_parts = list("anus")
	message = list(
		"eases %ITEM% into their ass.",
		"presses %ITEM% into their rear until the plug settles in place.",
		"works %ITEM% into their own ass."
	)
	user_pleasure = list(3, 5)
	user_arousal = list(4, 6)
	user_pain = list(0, 2)

/datum/interaction/howling_item_self/buttplug/adjust_ass
	name = "Adjust Plug At Your Entrance"
	translation_key = "ui.interaction_panel.interaction.toy.buttplug.self_adjust_ass.name"
	description = "Tease the plug against your entrance without fully taking it."
	description_translation_key = "ui.interaction_panel.interaction.toy.buttplug.self_adjust_ass.description"
	user_required_parts = list("anus")
	message = list(
		"nudges %ITEM% at their entrance.",
		"teases their rear with the rounded tip of %ITEM%.",
		"presses %ITEM% to their ass and adjusts it in small motions."
	)
	user_pleasure = list(2, 4)
	user_arousal = list(3, 5)

/datum/interaction/howling_item_self/buttplug/rock_ass
	name = "Rock Plug Against Yourself"
	translation_key = "ui.interaction_panel.interaction.toy.buttplug.self_rock_ass.name"
	description = "Rock the plug at your entrance in slow motions."
	description_translation_key = "ui.interaction_panel.interaction.toy.buttplug.self_rock_ass.description"
	user_required_parts = list("anus")
	message = list(
		"rocks %ITEM% against their entrance.",
		"works %ITEM% in slow teasing motions against their rear.",
		"rolls %ITEM% over their ass without pushing it fully inside."
	)
	user_pleasure = list(2, 4)
	user_arousal = list(3, 5)

/datum/interaction/howling_item_self/buttplug/hold_ass
	name = "Hold Plug In Place"
	translation_key = "ui.interaction_panel.interaction.toy.buttplug.self_hold_ass.name"
	description = "Keep the plug pressed in place and enjoy the pressure."
	description_translation_key = "ui.interaction_panel.interaction.toy.buttplug.self_hold_ass.description"
	user_required_parts = list("anus")
	message = list(
		"holds %ITEM% in place at their rear.",
		"keeps %ITEM% pressed firmly against their ass.",
		"rests %ITEM% at their entrance and savors the pressure."
	)
	user_pleasure = list(2, 4)
	user_arousal = list(3, 5)

/datum/interaction/howling_item_self/egg
	parent_type = /datum/interaction/howling_item/egg
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/egg/insert_pussy
	name = "Slip Egg Into Your Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.self_insert_pussy.name"
	description = "Push a vibrating egg into your pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.self_insert_pussy.description"
	user_required_parts = list("vagina")
	message = list(
		"slips %ITEM% into their pussy.",
		"works %ITEM% into their folds until it disappears inside.",
		"pushes %ITEM% into their pussy and leaves it humming there."
	)
	user_pleasure = list(4, 6)
	user_arousal = list(4, 6)

/datum/interaction/howling_item_self/egg/insert_ass
	name = "Slip Egg Into Your Ass"
	translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.self_insert_ass.name"
	description = "Push a vibrating egg into your ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.self_insert_ass.description"
	user_required_parts = list("anus")
	message = list(
		"slips %ITEM% into their ass.",
		"works %ITEM% into their rear and keeps it there.",
		"presses %ITEM% into their ass and leaves it buzzing inside."
	)
	user_pleasure = list(3, 5)
	user_arousal = list(4, 6)
	user_pain = list(0, 2)

/datum/interaction/howling_item_self/egg/adjust_pussy
	name = "Tease Egg At Your Entrance"
	translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.self_adjust_pussy.name"
	description = "Tease the egg at your entrance before slipping it in."
	description_translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.self_adjust_pussy.description"
	user_required_parts = list("vagina")
	message = list(
		"teases %ITEM% at their entrance.",
		"drags %ITEM% over their folds without pushing it in yet.",
		"holds %ITEM% at their entrance and teases themself with it."
	)
	user_pleasure = list(2, 4)
	user_arousal = list(3, 5)

/datum/interaction/howling_item_self/egg/hold_pussy
	name = "Hold Egg Against Your Clit"
	translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.self_hold_pussy.name"
	description = "Keep the humming egg pressed to your clit."
	description_translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.self_hold_pussy.description"
	user_required_parts = list("vagina")
	message = list(
		"holds %ITEM% against their clit.",
		"keeps %ITEM% pressed to their folds and lets it hum there.",
		"rests %ITEM% to their clit and savors the vibration."
	)
	user_pleasure = list(3, 5)
	user_arousal = list(4, 6)

/datum/interaction/howling_item_self/egg/adjust_ass
	name = "Tease Egg At Your Rear"
	translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.self_adjust_ass.name"
	description = "Tease the egg at your rear before taking it."
	description_translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.self_adjust_ass.description"
	user_required_parts = list("anus")
	message = list(
		"teases %ITEM% at their rear.",
		"presses %ITEM% to their ass and rolls it in small circles.",
		"holds %ITEM% at their entrance and teases themself with it."
	)
	user_pleasure = list(2, 4)
	user_arousal = list(3, 5)

/datum/interaction/howling_item_self/egg/hold_ass
	name = "Hold Egg Against Your Ass"
	translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.self_hold_ass.name"
	description = "Keep the egg pressed to your rear and feel it hum."
	description_translation_key = "ui.interaction_panel.interaction.toy.egg_vibrator.self_hold_ass.description"
	user_required_parts = list("anus")
	message = list(
		"holds %ITEM% against their ass.",
		"keeps %ITEM% pressed to their rear and lets it buzz there.",
		"rests %ITEM% at their entrance and savors the trembling hum."
	)
	user_pleasure = list(2, 4)
	user_arousal = list(3, 5)

/datum/interaction/howling_item_self/signal_egg
	parent_type = /datum/interaction/howling_item/signal_egg
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/signal_egg/insert_pussy
	name = "Slip Remote Egg Into Your Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.signal_egg.self_insert_pussy.name"
	description = "Push the signal-controlled egg into your pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.signal_egg.self_insert_pussy.description"
	user_required_parts = list("vagina")
	message = list(
		"slips %ITEM% into their pussy.",
		"works %ITEM% into their folds until the remote toy disappears inside.",
		"presses %ITEM% into their pussy and leaves it ready to be triggered."
	)
	user_pleasure = list(4, 6)
	user_arousal = list(4, 6)

/datum/interaction/howling_item_self/signal_egg/insert_ass
	name = "Slip Remote Egg Into Your Ass"
	translation_key = "ui.interaction_panel.interaction.toy.signal_egg.self_insert_ass.name"
	description = "Push the signal-controlled egg into your ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.signal_egg.self_insert_ass.description"
	user_required_parts = list("anus")
	message = list(
		"slips %ITEM% into their ass.",
		"works %ITEM% into their rear and leaves it ready to be triggered.",
		"presses %ITEM% into their ass and settles it there for later remote play."
	)
	user_pleasure = list(3, 5)
	user_arousal = list(4, 6)
	user_pain = list(0, 2)

/datum/interaction/howling_item_self/ring
	parent_type = /datum/interaction/howling_item/ring
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/ring/cock
	name = "Fit Ring On Your Cock"
	translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.self_fit_cock.name"
	description = "Slip the ring onto your cock."
	description_translation_key = "ui.interaction_panel.interaction.toy.vibrating_ring.self_fit_cock.description"
	user_required_parts = list("penis")
	message = list(
		"fits %ITEM% onto their cock.",
		"works %ITEM% down their shaft until it sits snugly in place.",
		"slides %ITEM% onto their own cock."
	)
	user_pleasure = list(2, 4)
	user_arousal = list(3, 5)

/datum/interaction/howling_item_self/clamps
	parent_type = /datum/interaction/howling_item/clamps
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/clamps/attach
	name = "Attach Clamps To Yourself"
	translation_key = "ui.interaction_panel.interaction.toy.nipple_clamps.self_attach.name"
	description = "Fasten nipple clamps onto yourself."
	description_translation_key = "ui.interaction_panel.interaction.toy.nipple_clamps.self_attach.description"
	user_required_parts = list("breasts")
	message = list(
		"fastens %ITEM% onto their nipples.",
		"clips %ITEM% onto their sensitive nipples.",
		"attaches %ITEM% to their own chest."
	)
	user_pleasure = list(1, 3)
	user_arousal = list(3, 5)
	user_pain = list(1, 3)

/datum/interaction/howling_item_self/strapon
	parent_type = /datum/interaction/howling_item/strapon
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/strapon/grind_pussy
	name = "Grind Strap-On Against Yourself"
	translation_key = "ui.interaction_panel.interaction.toy.strapon.self_grind_pussy.name"
	description = "Grind the strap-on over your pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.strapon.self_grind_pussy.description"
	user_required_parts = list("vagina")
	message = list(
		"grinds %ITEM% against their pussy.",
		"rubs %ITEM% through their folds.",
		"presses %ITEM% to their pussy and rolls their hips."
	)
	user_pleasure = list(3, 5)
	user_arousal = list(3, 5)

/datum/interaction/howling_item_self/strapon/fuck_pussy
	name = "Slide Strap-On Into Yourself"
	translation_key = "ui.interaction_panel.interaction.toy.strapon.self_fuck_pussy.name"
	description = "Push the strap-on into your pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.strapon.self_fuck_pussy.description"
	user_required_parts = list("vagina")
	message = list(
		"pushes %ITEM% into their pussy.",
		"works %ITEM% into their folds a little at a time.",
		"thrusts %ITEM% into their own wet sex."
	)
	user_pleasure = list(4, 6)
	user_arousal = list(4, 6)

/datum/interaction/howling_item_self/strapon/grind_ass
	name = "Grind Strap-On Against Your Ass"
	translation_key = "ui.interaction_panel.interaction.toy.strapon.self_grind_ass.name"
	description = "Grind the strap-on over your rear."
	description_translation_key = "ui.interaction_panel.interaction.toy.strapon.self_grind_ass.description"
	user_required_parts = list("butt")
	message = list(
		"grinds %ITEM% against their ass.",
		"rubs %ITEM% between their cheeks.",
		"presses %ITEM% to their rear and grinds slowly."
	)
	user_pleasure = list(2, 4)
	user_arousal = list(2, 4)

/datum/interaction/howling_item_self/strapon/fuck_ass
	name = "Slide Strap-On Into Your Ass"
	translation_key = "ui.interaction_panel.interaction.toy.strapon.self_fuck_ass.name"
	description = "Push the strap-on into your ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.strapon.self_fuck_ass.description"
	user_required_parts = list("anus")
	message = list(
		"pushes %ITEM% into their ass.",
		"eases %ITEM% into their rear a little at a time.",
		"thrusts %ITEM% into their own ass."
	)
	user_pleasure = list(3, 5)
	user_arousal = list(4, 6)
	user_pain = list(0, 2)

/datum/interaction/howling_item_self/custom_dildo
	parent_type = /datum/interaction/howling_item/custom_dildo
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/custom_dildo/pussy
	name = "Stretch Yourself With Custom Dildo"
	translation_key = "ui.interaction_panel.interaction.toy.custom_dildo.self_pussy.name"
	description = "Work the custom dildo into your pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.custom_dildo.self_pussy.description"
	user_required_parts = list("vagina")
	message = list(
		"works %ITEM% into their pussy.",
		"stretches their folds around %ITEM%.",
		"uses %ITEM% to slowly open themself up."
	)
	user_pleasure = list(4, 6)
	user_arousal = list(5, 7)

/datum/interaction/howling_item_self/custom_dildo/ass
	name = "Stretch Your Ass With Custom Dildo"
	translation_key = "ui.interaction_panel.interaction.toy.custom_dildo.self_ass.name"
	description = "Work the custom dildo into your ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.custom_dildo.self_ass.description"
	user_required_parts = list("anus")
	message = list(
		"works %ITEM% into their ass.",
		"stretches their rear around %ITEM%.",
		"uses %ITEM% to slowly open up their own ass."
	)
	user_pleasure = list(3, 5)
	user_arousal = list(4, 6)
	user_pain = list(1, 3)

/datum/interaction/howling_item_self/double_dildo
	parent_type = /datum/interaction/howling_item/double_dildo
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/double_dildo/pussy
	name = "Seat Double Dildo In Your Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.double_dildo.self_pussy.name"
	description = "Seat the double dildo in your pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.double_dildo.self_pussy.description"
	user_required_parts = list("vagina")
	message = list(
		"seats %ITEM% in their pussy.",
		"guides %ITEM% into their folds and rocks against it.",
		"works %ITEM% into their own pussy."
	)
	user_pleasure = list(4, 6)
	user_arousal = list(5, 7)

/datum/interaction/howling_item_self/double_dildo/ass
	name = "Seat Double Dildo In Your Ass"
	translation_key = "ui.interaction_panel.interaction.toy.double_dildo.self_ass.name"
	description = "Seat the double dildo in your ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.double_dildo.self_ass.description"
	user_required_parts = list("anus")
	message = list(
		"seats %ITEM% in their ass.",
		"guides %ITEM% into their rear and rocks against it.",
		"works %ITEM% into their own ass."
	)
	user_pleasure = list(3, 5)
	user_arousal = list(4, 6)
	user_pain = list(1, 3)

/datum/interaction/howling_item_self/whip
	parent_type = /datum/interaction/howling_item/whip
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/whip/chest
	name = "Trace Whip Over Your Chest"
	translation_key = "ui.interaction_panel.interaction.toy.whip.self_chest.name"
	description = "Trail the whip over your chest."
	description_translation_key = "ui.interaction_panel.interaction.toy.whip.self_chest.description"
	user_required_parts = list("chest")
	message = list(
		"trails %ITEM% over their chest.",
		"draws the length of %ITEM% across their chest.",
		"slides %ITEM% over their chest in a slow stroke."
	)
	user_arousal = list(1, 3)

/datum/interaction/howling_item_self/whip/thighs
	name = "Lash Your Thighs"
	translation_key = "ui.interaction_panel.interaction.toy.whip.self_thighs.name"
	description = "Snap the whip across your thighs."
	description_translation_key = "ui.interaction_panel.interaction.toy.whip.self_thighs.description"
	user_required_parts = list("thighs")
	message = list(
		"lashes their thighs with %ITEM%.",
		"snaps %ITEM% across their thighs.",
		"strikes their thighs with %ITEM%."
	)
	user_arousal = list(1, 3)
	user_pain = list(2, 4)

/datum/interaction/howling_item_self/whip/ass
	name = "Snap Whip Across Your Ass"
	translation_key = "ui.interaction_panel.interaction.toy.whip.self_ass.name"
	description = "Crack the whip against your ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.whip.self_ass.description"
	user_required_parts = list("butt")
	message = list(
		"snaps %ITEM% across their ass.",
		"cracks %ITEM% against their rear.",
		"lashes their ass with %ITEM%."
	)
	user_arousal = list(2, 4)
	user_pain = list(3, 5)

/datum/interaction/howling_item_self/spanking_pad
	parent_type = /datum/interaction/howling_item/spanking_pad
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/spanking_pad/ass
	name = "Spank Your Ass"
	translation_key = "ui.interaction_panel.interaction.toy.spanking.self_ass.name"
	description = "Smack your ass with the spanking pad."
	description_translation_key = "ui.interaction_panel.interaction.toy.spanking.self_ass.description"
	user_required_parts = list("butt")
	message = list(
		"spanks their ass with %ITEM%.",
		"smacks %ITEM% across their rear.",
		"slaps their ass with %ITEM%."
	)
	user_arousal = list(1, 3)
	user_pain = list(2, 4)

/datum/interaction/howling_item_self/spanking_pad/thighs
	name = "Smack Your Thighs"
	translation_key = "ui.interaction_panel.interaction.toy.spanking.self_thighs.name"
	description = "Smack your thighs with the spanking pad."
	description_translation_key = "ui.interaction_panel.interaction.toy.spanking.self_thighs.description"
	user_required_parts = list("thighs")
	message = list(
		"smacks %ITEM% against their thighs.",
		"spanks their thighs with %ITEM%.",
		"brings %ITEM% down across their thighs."
	)
	user_arousal = list(1, 3)
	user_pain = list(2, 4)

/datum/interaction/howling_item_self/feather
	parent_type = /datum/interaction/howling_item/feather
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/feather/pussy
	name = "Tease Yourself With Feather"
	translation_key = "ui.interaction_panel.interaction.toy.feather.self_pussy.name"
	description = "Tickle your pussy with the feather."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.self_pussy.description"
	user_required_parts = list("vagina")
	message = list(
		"teases their pussy with %ITEM%.",
		"brushes %ITEM% through their folds.",
		"tickles their clit and pussy with %ITEM%."
	)
	user_pleasure = list(1, 3)
	user_arousal = list(2, 4)

/datum/interaction/howling_item_self/feather/thighs
	name = "Trail Feather Between Your Thighs"
	translation_key = "ui.interaction_panel.interaction.toy.feather.self_thighs.name"
	description = "Tease the insides of your thighs with the feather."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.self_thighs.description"
	user_required_parts = list("thighs")
	message = list(
		"trails %ITEM% between their thighs.",
		"brushes %ITEM% up the insides of their thighs.",
		"teases the sensitive skin between their legs with %ITEM%."
	)
	user_pleasure = list(0, 2)
	user_arousal = list(2, 4)

/datum/interaction/howling_item_self/feather/neck
	name = "Brush Feather Along Your Neck"
	translation_key = "ui.interaction_panel.interaction.toy.feather.self_neck.name"
	description = "Run the feather over your neck."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.self_neck.description"
	user_required_parts = list("neck")
	message = list(
		"brushes %ITEM% along their neck.",
		"skims %ITEM% over their throat and neck.",
		"teases their neck with light feathery strokes."
	)
	user_pleasure = list(0, 2)
	user_arousal = list(1, 3)

/datum/interaction/howling_item_self/feather/tail
	name = "Brush Feather Along Your Tail"
	translation_key = "ui.interaction_panel.interaction.toy.feather.self_tail.name"
	description = "Trace the feather along your tail."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.self_tail.description"
	user_required_parts = list("tail")
	message = list(
		"brushes %ITEM% along their tail.",
		"traces %ITEM%'s tip down their tail.",
		"teases their tail with light feathery strokes."
	)
	user_pleasure = list(0, 2)
	user_arousal = list(1, 3)

/datum/interaction/howling_item_self/feather/lips
	name = "Brush Feather Over Your Lips"
	translation_key = "ui.interaction_panel.interaction.toy.feather.self_lips.name"
	description = "Brush the feather over your lips."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.self_lips.description"
	user_required_parts = list("mouth")
	message = list(
		"brushes %ITEM% over their lips.",
		"teases their lips with %ITEM%'s soft tip.",
		"lets the feather skim over their mouth."
	)
	user_pleasure = list(0, 2)
	user_arousal = list(1, 3)

/datum/interaction/howling_item_self/feather/ears
	name = "Brush Feather Over Your Ears"
	translation_key = "ui.interaction_panel.interaction.toy.feather.self_ears.name"
	description = "Trace the feather over your ears."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.self_ears.description"
	user_required_parts = list("ears")
	message = list(
		"brushes %ITEM% over their ears.",
		"traces the feather along their ear.",
		"lets %ITEM% tickle the edge of their ears."
	)
	user_pleasure = list(0, 2)
	user_arousal = list(1, 3)

/datum/interaction/howling_item_self/feather/armpits
	name = "Tease Your Armpits With Feather"
	translation_key = "ui.interaction_panel.interaction.toy.feather.self_armpits.name"
	description = "Tickle your armpits with the feather."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.self_armpits.description"
	user_required_parts = list("armpits")
	message = list(
		"teases their armpits with %ITEM%.",
		"brushes %ITEM% through the hollow of their armpit.",
		"lets %ITEM% tickle their sensitive armpits."
	)
	user_pleasure = list(0, 2)
	user_arousal = list(1, 3)

/datum/interaction/howling_item_self/feather/groin
	name = "Tease Your Groin With Feather"
	translation_key = "ui.interaction_panel.interaction.toy.feather.self_groin.name"
	description = "Tease your groin with the feather without focusing on one spot."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.self_groin.description"
	user_required_parts = list("groin")
	message = list(
		"teases their groin with %ITEM%.",
		"trails %ITEM% over the heat between their legs.",
		"brushes %ITEM% over their groin in light strokes."
	)
	user_pleasure = list(1, 3)
	user_arousal = list(2, 4)

/datum/interaction/howling_item_self/feather/body
	name = "Trail Feather Over Your Body"
	translation_key = "ui.interaction_panel.interaction.toy.feather.self_body.name"
	description = "Trail the feather over your body."
	description_translation_key = "ui.interaction_panel.interaction.toy.feather.self_body.description"
	user_required_parts = list("chest")
	message = list(
		"trails %ITEM% over their body.",
		"brushes %ITEM% over their skin in soft teasing strokes.",
		"lets %ITEM% drift over their body."
	)
	user_pleasure = list(0, 2)
	user_arousal = list(1, 3)

/datum/interaction/howling_item_self/shocker
	parent_type = /datum/interaction/howling_item/shocker
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/shocker/nipples
	name = "Shock Your Nipples"
	translation_key = "ui.interaction_panel.interaction.toy.shocker.self_nipples.name"
	description = "Touch the shocker to your nipples."
	description_translation_key = "ui.interaction_panel.interaction.toy.shocker.self_nipples.description"
	user_required_parts = list("breasts")
	message = list(
		"touches %ITEM% to their nipples.",
		"zaps their nipples with %ITEM%.",
		"holds %ITEM% to their sensitive nipples and lets it crackle there."
	)
	user_arousal = list(2, 4)
	user_pain = list(2, 4)

/datum/interaction/howling_item_self/shocker/cock
	name = "Shock Your Cock"
	translation_key = "ui.interaction_panel.interaction.toy.shocker.self_cock.name"
	description = "Press the shocker to your cock."
	description_translation_key = "ui.interaction_panel.interaction.toy.shocker.self_cock.description"
	user_required_parts = list("penis")
	message = list(
		"presses %ITEM% to their cock.",
		"zaps their shaft with %ITEM%.",
		"holds %ITEM% to their cock and lets it crackle there."
	)
	user_arousal = list(2, 4)
	user_pain = list(2, 4)

/datum/interaction/howling_item_self/shocker/pussy
	name = "Shock Your Pussy"
	translation_key = "ui.interaction_panel.interaction.toy.shocker.self_pussy.name"
	description = "Press the shocker to your pussy."
	description_translation_key = "ui.interaction_panel.interaction.toy.shocker.self_pussy.description"
	user_required_parts = list("vagina")
	message = list(
		"presses %ITEM% to their pussy.",
		"zaps their folds with %ITEM%.",
		"holds %ITEM% to their pussy and lets it crackle there."
	)
	user_arousal = list(2, 4)
	user_pain = list(2, 4)

/datum/interaction/howling_item_self/shocker/ass
	name = "Shock Your Ass"
	translation_key = "ui.interaction_panel.interaction.toy.shocker.self_ass.name"
	description = "Press the shocker to your ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.shocker.self_ass.description"
	user_required_parts = list("anus")
	message = list(
		"presses %ITEM% to their ass.",
		"zaps their entrance with %ITEM%.",
		"holds %ITEM% to their rear and lets it crackle there."
	)
	user_arousal = list(2, 4)
	user_pain = list(2, 4)

/datum/interaction/howling_item_self/candle
	parent_type = /datum/interaction/howling_item/candle
	usage = INTERACTION_SELF

/datum/interaction/howling_item_self/candle/chest
	name = "Drip Wax On Your Chest"
	translation_key = "ui.interaction_panel.interaction.toy.wax_play.self_chest.name"
	description = "Drip warm wax over your chest."
	description_translation_key = "ui.interaction_panel.interaction.toy.wax_play.self_chest.description"
	user_required_parts = list("chest")
	message = list(
		"drips wax from %ITEM% over their chest.",
		"tilts %ITEM% and lets warm wax spatter their chest.",
		"trails hot droplets from %ITEM% down their chest."
	)
	user_arousal = list(2, 4)
	user_pain = list(1, 3)

/datum/interaction/howling_item_self/candle/thighs
	name = "Drip Wax On Your Thighs"
	translation_key = "ui.interaction_panel.interaction.toy.wax_play.self_thighs.name"
	description = "Drip warm wax over your thighs."
	description_translation_key = "ui.interaction_panel.interaction.toy.wax_play.self_thighs.description"
	user_required_parts = list("thighs")
	message = list(
		"drips wax from %ITEM% over their thighs.",
		"lets warm droplets from %ITEM% patter across their thighs.",
		"tilts %ITEM% and traces hot wax over their legs."
	)
	user_arousal = list(2, 4)
	user_pain = list(1, 3)

/datum/interaction/howling_item_self/candle/butt
	name = "Drip Wax On Your Ass"
	translation_key = "ui.interaction_panel.interaction.toy.wax_play.self_butt.name"
	description = "Drip warm wax over your ass."
	description_translation_key = "ui.interaction_panel.interaction.toy.wax_play.self_butt.description"
	user_required_parts = list("butt")
	message = list(
		"drips wax from %ITEM% over their ass.",
		"lets warm wax fall over their rear from %ITEM%.",
		"tilts %ITEM% and traces hot droplets over their ass."
	)
	user_arousal = list(2, 4)
	user_pain = list(1, 3)
