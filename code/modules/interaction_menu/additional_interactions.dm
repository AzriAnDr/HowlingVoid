/datum/interaction/howling_extra
	lewd = TRUE
	color = "pink"

/datum/interaction/howling_extra/telekinesis
	category = "Telekinesis"
	distance_allowed = TRUE
	interaction_requires = list(INTERACTION_REQUIRE_SELF_TK)
	sound_use = TRUE
	sound_range = 3
	sound_possible = list('sound/items/weapons/thudswoosh.ogg')

/datum/interaction/howling_extra/telekinesis/apply_effects(mob/living/carbon/human/user, mob/living/carbon/human/target)
	..()
	new /obj/effect/temp_visual/telekinesis(get_turf(user))
	if(target != user)
		new /obj/effect/temp_visual/telekinesis(get_turf(target))

/datum/interaction/howling_extra/telekinesis/grope_breasts
	name = "TK Grope Breasts"
	description = "Use telekinesis to squeeze their breasts from afar."
	target_required_parts = list("breasts")
	message = list(
		"makes invisible force cup %TARGET%'s breasts.",
		"telekinetically kneads %TARGET%'s chest.",
		"has an unseen grip squeeze %TARGET%'s breasts."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/items/weapons/thudswoosh.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/telekinesis/grope_ass
	name = "TK Grope Ass"
	description = "Use telekinesis to grab their ass from afar."
	target_required_parts = list("butt")
	message = list(
		"makes an unseen force grab %TARGET%'s ass.",
		"telekinetically squeezes %TARGET%'s rear.",
		"has invisible fingers knead %TARGET%'s ass."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/items/weapons/thudswoosh.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/telekinesis/grope_thighs
	name = "TK Grope Thighs"
	description = "Use telekinesis to caress their thighs from afar."
	target_required_parts = list("thighs")
	message = list(
		"makes invisible hands stroke along %TARGET%'s thighs.",
		"telekinetically squeezes %TARGET%'s thighs.",
		"has an unseen touch roam over %TARGET%'s legs."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/items/weapons/thudswoosh.ogg')
	user_arousal = list(0, 2)
	target_pleasure = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/telekinesis/grope_balls
	name = "TK Grope Balls"
	description = "Use telekinesis to tease their balls from afar."
	target_required_parts = list("balls")
	message = list(
		"makes an invisible grip cradle %TARGET%'s balls.",
		"telekinetically rolls %TARGET%'s balls in a teasing squeeze.",
		"has unseen fingers toy with %TARGET%'s sack."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/items/weapons/thudswoosh.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(2, 4)
	target_pain = list(0, 2)

/datum/interaction/howling_extra/telekinesis/stroke_cock
	name = "TK Stroke Cock"
	description = "Use telekinesis to stroke their cock from afar."
	target_required_parts = list("penis")
	message = list(
		"makes invisible fingers stroke %TARGET%'s cock.",
		"telekinetically pumps %TARGET%'s shaft.",
		"has an unseen touch work %TARGET%'s cock up and down."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/items/weapons/thudswoosh.ogg')
	user_pleasure = list(0, 2)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/telekinesis/tease_pussy
	name = "TK Tease Pussy"
	description = "Use telekinesis to tease their pussy from afar."
	target_required_parts = list("vagina")
	message = list(
		"makes invisible fingertips tease %TARGET%'s pussy.",
		"telekinetically parts %TARGET%'s folds and rubs at their clit.",
		"has an unseen touch toy with %TARGET%'s sensitive sex."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/items/weapons/thudswoosh.ogg')
	user_pleasure = list(0, 2)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/telekinesis/pull_tail
	name = "TK Pull Tail"
	description = "Use telekinesis to tug their tail from afar."
	target_required_parts = list("tail")
	message = list(
		"makes %TARGET%'s tail twitch with an invisible tug.",
		"telekinetically toys with %TARGET%'s tail.",
		"has an unseen force teasingly pull %TARGET%'s tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/items/weapons/thudswoosh.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/kiss
	name = "Kiss"
	description = "Kiss them deeply."
	category = "Foreplay"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH, INTERACTION_REQUIRE_TARGET_MOUTH)
	message = list(
		"gives %TARGET% a lingering kiss.",
		"kisses %TARGET% deeply.",
		"presses their lips against %TARGET%'s.",
		"slides their tongue into %TARGET%'s mouth."
	)
	user_messages = list(
		"%TARGET%'s lips feel warm against yours.",
		"You taste %TARGET%'s breath on your lips."
	)
	target_messages = list(
		"%USER%'s lips press against yours.",
		"%USER%'s tongue brushes against your mouth."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/kiss1.ogg',
		'sound/lewd/sounds/kiss2.ogg',
		'sound/lewd/sounds/kiss3.ogg',
		'sound/lewd/sounds/kiss4.ogg',
		'sound/lewd/sounds/kiss5.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/cheek_kiss
	name = "Cheek Kiss"
	description = "Kiss them on the cheek."
	category = "Foreplay"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	message = list(
		"kisses %TARGET% on the cheek.",
		"plants a soft kiss on %TARGET%'s cheek.",
		"leans in and brushes %TARGET%'s cheek with their lips."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/kiss1.ogg',
		'sound/lewd/sounds/kiss2.ogg',
		'sound/lewd/sounds/kiss3.ogg'
	)
	user_arousal = list(0, 2)
	target_arousal = list(0, 2)

/datum/interaction/howling_extra/neck_kiss
	name = "Neck Kiss"
	description = "Kiss their neck."
	category = "Neck"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	message = list(
		"kisses %TARGET%'s neck.",
		"leaves a slow kiss against %TARGET%'s throat.",
		"trails soft kisses along %TARGET%'s neck."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/kiss2.ogg',
		'sound/lewd/sounds/kiss4.ogg',
		'sound/lewd/sounds/kiss5.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/lip_kiss
	name = "Kiss Lips"
	description = "Kiss their lips softly."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("mouth")
	message = list(
		"kisses %TARGET%'s lips softly.",
		"presses a slow kiss to %TARGET%'s lips.",
		"brushes %TARGET%'s lips with a lingering kiss."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/kiss1.ogg',
		'sound/lewd/sounds/kiss2.ogg',
		'sound/lewd/sounds/kiss3.ogg'
	)
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/lip_nibble
	name = "Nibble Lips"
	description = "Nibble on their lip."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("mouth")
	message = list(
		"catches %TARGET%'s lip in a teasing nibble.",
		"nibbles softly at %TARGET%'s lower lip.",
		"teases %TARGET%'s lip between their teeth."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss4.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/lick_lips
	name = "Lick Lips"
	description = "Lick across their lips."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("mouth")
	message = list(
		"drags their tongue slowly across %TARGET%'s lips.",
		"licks over %TARGET%'s lips in a teasing stroke.",
		"traces %TARGET%'s lips with the tip of their tongue."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/tongue_tease
	name = "Tongue Tease"
	description = "Tease them with your tongue."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH, INTERACTION_REQUIRE_TARGET_MOUTH)
	message = list(
		"teases %TARGET%'s mouth with the tip of their tongue.",
		"lets their tongue play slowly against %TARGET%'s lips.",
		"coaxes %TARGET%'s mouth open with a teasing tongue."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/kiss4.ogg',
		'sound/lewd/sounds/oral1.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/tongue_kiss
	name = "Tongue Kiss"
	description = "Kiss them with tongue."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH, INTERACTION_REQUIRE_TARGET_MOUTH)
	message = list(
		"slides their tongue slowly into %TARGET%'s mouth.",
		"kisses %TARGET% with a slow, deep tongue kiss.",
		"works their tongue teasingly against %TARGET%'s."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/kiss4.ogg',
		'sound/lewd/sounds/kiss5.ogg'
	)
	user_arousal = list(2, 4)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/breathe_on_lips
	name = "Breathe Over Lips"
	description = "Breathe warm air against their lips."
	category = "Mouth"
	target_required_parts = list("mouth")
	message = list(
		"breathes warm air against %TARGET%'s lips.",
		"lets their breath ghost slowly over %TARGET%'s mouth.",
		"hovers close enough for %TARGET% to feel their breath on their lips."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/thumb_lip
	name = "Thumb Their Lip"
	description = "Brush your thumb over their lip."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("mouth")
	message = list(
		"brushes a thumb slowly over %TARGET%'s lip.",
		"drags their thumb across %TARGET%'s lower lip.",
		"teases %TARGET%'s mouth with a slow thumb stroke."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/part_lips
	name = "Part Their Lips"
	description = "Part their lips with your fingers."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("mouth")
	message = list(
		"parts %TARGET%'s lips with slow fingers.",
		"uses their fingers to tease %TARGET%'s lips open.",
		"coaxes %TARGET%'s mouth open with a gentle touch."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/trace_teeth
	name = "Trace Their Teeth"
	description = "Trace along their teeth with your tongue."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH, INTERACTION_REQUIRE_TARGET_MOUTH)
	message = list(
		"traces their tongue along %TARGET%'s teeth.",
		"teases the edges of %TARGET%'s teeth with their tongue.",
		"lets their tongue slide slowly over %TARGET%'s teeth."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/spit_into_mouth
	name = "Spit Into Mouth"
	description = "Spit into their mouth."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH, INTERACTION_REQUIRE_TARGET_MOUTH)
	message = list(
		"spits slowly into %TARGET%'s mouth.",
		"lets a strand of spit fall into %TARGET%'s open mouth.",
		"feeds a slow spit-string into %TARGET%'s mouth."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral2.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/mouth_to_fingers
	name = "Take Their Fingers Into Mouth"
	description = "Take their fingers into your mouth."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("hands")
	message = list(
		"draws %TARGET%'s fingers slowly into their mouth.",
		"wraps warm lips around %TARGET%'s fingers.",
		"teases %TARGET%'s fingers with their mouth and tongue."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/feed_fingers_to_mouth
	name = "Guide Fingers Between Lips"
	description = "Guide their fingers to your mouth."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH, INTERACTION_REQUIRE_TARGET_HAND)
	target_required_parts = list("hands")
	message = list(
		"guides %TARGET%'s fingers to their lips and parts them slowly.",
		"draws %TARGET%'s fingers into their mouth.",
		"takes %TARGET%'s hand and feeds their fingers past their lips."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/suck_tongue
	name = "Suck Tongue"
	description = "Suck on their tongue."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH, INTERACTION_REQUIRE_TARGET_MOUTH)
	message = list(
		"draws %TARGET%'s tongue into their mouth and sucks on it.",
		"sucks softly on %TARGET%'s tongue.",
		"works %TARGET%'s tongue between their lips in a slow suck."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral2.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/bite_lip
	name = "Bite Lip"
	description = "Bite their lip."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("mouth")
	message = list(
		"bites down teasingly on %TARGET%'s lip.",
		"catches %TARGET%'s lip in a sharp little bite.",
		"nips %TARGET%'s lip between their teeth."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss4.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)
	target_pain = list(0, 2)

/datum/interaction/howling_extra/kiss_teeth
	name = "Kiss Their Teeth"
	description = "Kiss along their teeth."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH, INTERACTION_REQUIRE_TARGET_MOUTH)
	message = list(
		"kisses along %TARGET%'s teeth through parted lips.",
		"brushes their lips and tongue over %TARGET%'s teeth.",
		"teases %TARGET%'s teeth with a slow mouth-to-mouth kiss."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss3.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/breathe_into_mouth
	name = "Breathe Into Mouth"
	description = "Exhale slowly into their mouth."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH, INTERACTION_REQUIRE_TARGET_MOUTH)
	message = list(
		"exhales slowly into %TARGET%'s open mouth.",
		"lets their breath spill warm into %TARGET%'s mouth.",
		"breathes directly into %TARGET%'s parted lips."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/lick_teeth
	name = "Lick Teeth"
	description = "Lick along their teeth."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH, INTERACTION_REQUIRE_TARGET_MOUTH)
	message = list(
		"drags their tongue slowly over %TARGET%'s teeth.",
		"licks across %TARGET%'s teeth through parted lips.",
		"teases %TARGET%'s teeth with a slow lick."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/spit_on_tongue
	name = "Spit On Tongue"
	description = "Spit onto their tongue."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH, INTERACTION_REQUIRE_TARGET_MOUTH)
	message = list(
		"spits slowly onto %TARGET%'s tongue.",
		"lets a strand of spit fall onto %TARGET%'s waiting tongue.",
		"feeds spit onto %TARGET%'s tongue through their open mouth."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral2.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/suck_lip
	name = "Suck Lip"
	description = "Suck on their lip."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("mouth")
	message = list(
		"draws %TARGET%'s lip slowly between their lips and sucks on it.",
		"sucks softly at %TARGET%'s lower lip.",
		"works %TARGET%'s lip in a slow, teasing suck."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/thumb_teeth
	name = "Thumb Their Teeth"
	description = "Brush your thumb over their teeth."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("mouth")
	message = list(
		"brushes a thumb slowly over %TARGET%'s teeth.",
		"teases %TARGET%'s mouth by dragging a thumb along their teeth.",
		"parts %TARGET%'s lips and runs a thumb over their teeth."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/hook_tongue
	name = "Hook Their Tongue"
	description = "Hook their tongue with your fingers."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("mouth")
	message = list(
		"hooks slow fingers under %TARGET%'s tongue.",
		"teases %TARGET%'s tongue with careful fingers.",
		"parts %TARGET%'s lips and toys with their tongue."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/hold_jaw
	name = "Hold Their Jaw"
	description = "Hold their jaw and keep their mouth open."
	category = "Mouth"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("mouth")
	message = list(
		"holds %TARGET%'s jaw and keeps their mouth open.",
		"cups %TARGET%'s jaw and parts their lips.",
		"keeps a steady hand on %TARGET%'s jaw while their mouth hangs open."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/body_caress
	name = "Caress Body"
	description = "Let your hands wander over their body."
	category = "Body"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	message = list(
		"lets their hands wander across %TARGET%'s body.",
		"roams over %TARGET%'s body with slow, hungry touches.",
		"gives %TARGET%'s body a lingering caress."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/chest_caress
	name = "Caress Chest"
	description = "Caress their chest."
	category = "Chest"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("chest")
	message = list(
		"caresses %TARGET%'s chest with warm hands.",
		"glides their touch over %TARGET%'s chest.",
		"gives %TARGET%'s chest a lingering caress."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/chest_stroke
	name = "Stroke Chest"
	description = "Stroke their chest."
	category = "Chest"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("chest")
	message = list(
		"strokes over %TARGET%'s chest in unhurried passes.",
		"runs their hands across %TARGET%'s chest.",
		"works a slow stroke across %TARGET%'s chest."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/chest_massage
	name = "Massage Chest"
	description = "Massage their chest and ribs."
	category = "Chest"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("chest")
	message = list(
		"massages %TARGET%'s chest with steady pressure.",
		"works their hands over %TARGET%'s chest and ribs.",
		"gives %TARGET%'s chest a careful massage."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/chest_kiss
	name = "Kiss Chest"
	description = "Kiss their chest."
	category = "Chest"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("chest")
	message = list(
		"kisses %TARGET%'s chest softly.",
		"presses slow kisses along %TARGET%'s chest.",
		"trails warm kisses over %TARGET%'s upper chest."
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/kiss1.ogg',
		'sound/lewd/sounds/kiss2.ogg'
	)

/datum/interaction/howling_extra/chest_lick
	name = "Lick Chest"
	description = "Lick along their chest."
	category = "Chest"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("chest")
	message = list(
		"drags their tongue over %TARGET%'s chest.",
		"licks a warm line across %TARGET%'s chest.",
		"tastes %TARGET%'s chest in a long pass."
	)
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')

/datum/interaction/howling_extra/trace_sternum
	name = "Trace Sternum"
	description = "Trace the center of their chest."
	category = "Chest"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("chest")
	message = list(
		"traces slow fingers down the center of %TARGET%'s chest.",
		"draws a teasing line along %TARGET%'s sternum.",
		"lets their fingertips drift down the middle of %TARGET%'s chest."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/trace_ribs
	name = "Trace Ribs"
	description = "Trace your fingers over their ribs."
	category = "Chest"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("chest")
	message = list(
		"traces their fingers slowly over %TARGET%'s ribs.",
		"lets their touch drift along %TARGET%'s ribline.",
		"teases %TARGET%'s ribs with light fingertips."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/palm_chest_bare
	name = "Palm Over Chest"
	description = "Press warm palms over their chest."
	category = "Chest"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("chest")
	message = list(
		"presses warm palms over %TARGET%'s chest.",
		"settles both hands against %TARGET%'s chest.",
		"holds their palms flat against %TARGET%'s chest."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/listen_heartbeat
	name = "Listen To Heart"
	description = "Press close and listen to their heartbeat."
	category = "Chest"
	target_required_parts = list("chest")
	message = list(
		"presses in close and listens to %TARGET%'s heartbeat.",
		"rests against %TARGET%'s chest to hear their heartbeat.",
		"leans close enough to listen to %TARGET%'s chest."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/mouth_to_chest
	name = "Taste Chest"
	description = "Work your mouth over their chest."
	category = "Chest"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("chest")
	message = list(
		"works their mouth slowly over %TARGET%'s chest.",
		"covers %TARGET%'s chest with lips and tongue.",
		"teases %TARGET%'s chest with warm mouth-play."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/breathe_on_chest
	name = "Breathe Over Chest"
	description = "Breathe warm air across their chest."
	category = "Chest"
	target_required_parts = list("chest")
	message = list(
		"breathes warm air over %TARGET%'s chest.",
		"lets their breath ghost across %TARGET%'s chest.",
		"hovers close and teases %TARGET%'s chest with warm breath."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/rub_chest
	name = "Rub Chest"
	description = "Rub against their chest."
	category = "Chest"
	target_required_parts = list("chest")
	message = list(
		"rubs close against %TARGET%'s chest.",
		"presses in and lets their body tease over %TARGET%'s chest.",
		"slides slowly against %TARGET%'s chest."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/body_stroke
	name = "Stroke Body"
	description = "Stroke their body with your hands."
	category = "Body"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	message = list(
		"strokes %TARGET%'s body in long, careful passes.",
		"runs their hands along %TARGET%'s body.",
		"gently works over %TARGET%'s sides and torso."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/body_massage
	name = "Massage Body"
	description = "Massage their body."
	category = "Body"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	message = list(
		"massages %TARGET%'s body with steady pressure.",
		"works their hands over %TARGET%'s shoulders, sides, and back.",
		"gives %TARGET%'s body a careful massage."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/trace_under_eyes
	name = "Trace Beneath Eyes"
	description = "Trace your fingers beneath their eyes."
	category = "Eyes"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("eyes")
	message = list(
		"traces slow fingertips beneath %TARGET%'s eyes.",
		"brushes careful fingers under %TARGET%'s eyes.",
		"lets their touch drift softly beneath %TARGET%'s gaze."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/thumb_under_eye
	name = "Thumb Beneath Eye"
	description = "Brush a thumb under their eye."
	category = "Eyes"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("eyes")
	message = list(
		"brushes a thumb slowly beneath %TARGET%'s eye.",
		"drags a careful thumb under %TARGET%'s eye.",
		"teases %TARGET%'s gaze with a slow thumb stroke."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/kiss_eyelids
	name = "Kiss Eyelids"
	description = "Kiss their eyelids softly."
	category = "Eyes"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("eyes")
	message = list(
		"kisses %TARGET%'s eyelids softly.",
		"presses feather-light kisses to %TARGET%'s closed eyes.",
		"leans in and kisses along %TARGET%'s eyelids."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/kiss_corner_of_eye
	name = "Kiss Eye Corner"
	description = "Kiss the corner of their eye."
	category = "Eyes"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("eyes")
	message = list(
		"kisses the corner of %TARGET%'s eye.",
		"presses a soft kiss beside %TARGET%'s eye.",
		"leans close and kisses the edge of %TARGET%'s gaze."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/lick_corner_of_eye
	name = "Lick Eye Corner"
	description = "Lick lightly near the corner of their eye."
	category = "Eyes"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("eyes")
	message = list(
		"drags their tongue lightly near the corner of %TARGET%'s eye.",
		"teases the edge of %TARGET%'s eye with a careful lick.",
		"lets the tip of their tongue brush near %TARGET%'s eye."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/lick_lashes
	name = "Lick Lashes"
	description = "Lick lightly over their lashes."
	category = "Eyes"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("eyes")
	message = list(
		"teases %TARGET%'s lashes with a careful lick.",
		"lets their tongue brush lightly over %TARGET%'s lashes.",
		"drags a delicate lick across %TARGET%'s closed lashes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/brush_lashes
	name = "Brush Lashes"
	description = "Brush your fingers over their lashes."
	category = "Eyes"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("eyes")
	message = list(
		"brushes careful fingers over %TARGET%'s lashes.",
		"teases %TARGET%'s lashes with a feather-light touch.",
		"lets their fingertips drift over %TARGET%'s lashes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/body_kiss
	name = "Kiss Body"
	description = "Cover their body in kisses."
	category = "Body"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	message = list(
		"presses soft kisses over %TARGET%'s body.",
		"trails kisses down %TARGET%'s body.",
		"covers %TARGET%'s skin in lingering kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/kiss1.ogg',
		'sound/lewd/sounds/kiss2.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/neck_caress
	name = "Caress Neck"
	description = "Caress their neck."
	category = "Neck"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("neck")
	message = list(
		"caresses %TARGET%'s neck with soft fingers.",
		"lets their hand wander over %TARGET%'s throat and neck.",
		"gives %TARGET%'s neck a lingering caress."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/neck_stroke
	name = "Stroke Neck"
	description = "Stroke their neck."
	category = "Neck"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("neck")
	message = list(
		"strokes along %TARGET%'s neck.",
		"runs careful fingers up %TARGET%'s throat and neck.",
		"draws a slow stroke down %TARGET%'s neck."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/neck_massage
	name = "Massage Neck"
	description = "Massage their neck."
	category = "Neck"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("neck")
	message = list(
		"massages %TARGET%'s neck with slow pressure.",
		"works their thumbs into %TARGET%'s neck.",
		"gives %TARGET%'s neck a careful massage."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/neck_lick
	name = "Lick Neck"
	description = "Lick their neck."
	category = "Neck"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("neck")
	message = list(
		"drags their tongue over %TARGET%'s neck.",
		"licks a teasing line up %TARGET%'s throat.",
		"works a warm lick along %TARGET%'s neck."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/neck_nibble
	name = "Nibble Neck"
	description = "Nibble on their neck."
	category = "Neck"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("neck")
	message = list(
		"nibbles softly at %TARGET%'s neck.",
		"catches a spot on %TARGET%'s neck between their teeth.",
		"teases %TARGET%'s throat with a gentle nibble."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss4.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/breathe_on_neck
	name = "Breathe Over Neck"
	description = "Breathe warm air over their neck."
	category = "Neck"
	target_required_parts = list("neck")
	message = list(
		"breathes warm air across %TARGET%'s neck.",
		"lets their breath ghost over %TARGET%'s throat.",
		"hovers close enough for %TARGET% to feel their breath on their neck."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/thumb_throat
	name = "Thumb Their Throat"
	description = "Brush your thumb over their throat."
	category = "Neck"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("neck")
	message = list(
		"brushes a thumb slowly over %TARGET%'s throat.",
		"drags a slow thumb stroke along %TARGET%'s neck.",
		"teases %TARGET%'s throat with a careful thumb."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/trace_throat
	name = "Trace Their Throat"
	description = "Trace your fingers along their throat."
	category = "Neck"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("neck")
	message = list(
		"traces their fingers slowly along %TARGET%'s throat.",
		"draws a teasing line over %TARGET%'s throat.",
		"lets their fingertips drift down %TARGET%'s neck."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/kiss_throat
	name = "Kiss Their Throat"
	description = "Kiss their throat."
	category = "Neck"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("neck")
	message = list(
		"kisses %TARGET%'s throat softly.",
		"presses slow kisses to %TARGET%'s throat.",
		"lingers with a warm kiss against %TARGET%'s throat."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/hold_neck
	name = "Hold Their Neck"
	description = "Hold their neck."
	category = "Neck"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("neck")
	message = list(
		"rests a steady hand at %TARGET%'s neck.",
		"holds %TARGET%'s neck with a slow, possessive touch.",
		"cups %TARGET%'s neck and keeps them close."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/pin_neck
	name = "Pin Their Neck"
	description = "Pin them by the neck."
	category = "Neck"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("neck")
	message = list(
		"pins %TARGET% in place with a hand at their neck.",
		"holds %TARGET% steady by the neck.",
		"keeps %TARGET% pressed in place with a firm grip at their neck."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/lips_to_neck
	name = "Taste Neck"
	description = "Work your lips and tongue over their neck."
	category = "Neck"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("neck")
	message = list(
		"works their lips and tongue over %TARGET%'s neck.",
		"covers %TARGET%'s neck in mouth-play.",
		"teases %TARGET%'s throat with lips and tongue."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/body_lick
	name = "Lick Body"
	description = "Lick along their body."
	category = "Body"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	message = list(
		"drags their tongue along %TARGET%'s body.",
		"licks a warm line over %TARGET%'s skin.",
		"tastes %TARGET%'s body in a long pass."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/press_close
	name = "Press Bodies Together"
	description = "Press yourself close to them."
	category = "Body"
	message = list(
		"presses close against %TARGET%.",
		"draws %TARGET% into close body contact.",
		"leans into %TARGET% until their bodies meet."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/hold_close
	name = "Hold Them Close"
	description = "Hold them close."
	category = "Body"
	message = list(
		"holds %TARGET% close against them.",
		"pulls %TARGET% into a close embrace.",
		"keeps %TARGET% tucked close to their body."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(0, 2)

/datum/interaction/howling_extra/rub_against
	name = "Rub Against"
	description = "Rub your body against theirs."
	category = "Body"
	message = list(
		"rubs their body against %TARGET% in a slow grind.",
		"grinds lightly against %TARGET%.",
		"slides their body against %TARGET%'s in a teasing pass."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/trace_sides
	name = "Trace Their Sides"
	description = "Trace your fingers along their sides."
	category = "Body"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	message = list(
		"traces their fingers along %TARGET%'s sides.",
		"drags light fingertips over %TARGET%'s waist and sides.",
		"maps %TARGET%'s sides with a teasing touch."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/rub_sides
	name = "Rub Their Sides"
	description = "Rub their sides slowly."
	category = "Body"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	message = list(
		"rubs along %TARGET%'s sides.",
		"works their hands over %TARGET%'s waist and sides.",
		"gives %TARGET%'s sides a lingering rub."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/mouth_sides
	name = "Taste Their Sides"
	description = "Work your lips and tongue over their sides."
	category = "Body"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	message = list(
		"works their lips and tongue over %TARGET%'s sides.",
		"covers %TARGET%'s sides in teasing mouth-play.",
		"drags warm lips and tongue along %TARGET%'s sides."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/trace_navel
	name = "Trace Their Navel"
	description = "Trace around their navel."
	category = "Body"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	message = list(
		"traces a slow circle around %TARGET%'s navel.",
		"teases %TARGET%'s navel with careful fingertips.",
		"lets their finger drift around %TARGET%'s belly button."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/kiss_navel
	name = "Kiss Their Navel"
	description = "Kiss their navel."
	category = "Body"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	message = list(
		"kisses %TARGET%'s navel softly.",
		"presses a slow kiss to %TARGET%'s belly button.",
		"lingers with a warm kiss over %TARGET%'s navel."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/lick_navel
	name = "Lick Their Navel"
	description = "Lick at their navel."
	category = "Body"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	message = list(
		"teases %TARGET%'s navel with a slow lick.",
		"drags their tongue around %TARGET%'s belly button.",
		"works a warm lick over %TARGET%'s navel."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/trail_fingers
	name = "Trail Fingers Over Body"
	description = "Trail your fingers over their body."
	category = "Body"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	message = list(
		"trails their fingers slowly over %TARGET%'s body.",
		"lets their fingertips wander over %TARGET%'s skin.",
		"draws a slow line of touch over %TARGET%'s body."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/pin_to_body
	name = "Pin Against Body"
	description = "Pin them against your body."
	category = "Body"
	message = list(
		"pins %TARGET% against their body.",
		"holds %TARGET% tight against them and keeps them there.",
		"uses their body to keep %TARGET% pressed in place."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/bang1.ogg', 'sound/lewd/sounds/bang2.ogg', 'sound/lewd/sounds/bang3.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/palm_chest
	name = "Palm Their Torso"
	description = "Run your hands over their chest and torso."
	category = "Body"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	message = list(
		"palms %TARGET%'s chest and torso slowly.",
		"runs their hands over %TARGET%'s chest and stomach.",
		"presses warm palms over %TARGET%'s upper body."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/full_body_tease
	name = "Tease Their Body"
	description = "Tease them all over."
	category = "Body"
	message = list(
		"teases %TARGET% from head to toe with slow touches.",
		"lets their attention roam over all of %TARGET%'s body.",
		"works %TARGET% over with a slow, full-body tease."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/groin_caress
	name = "Caress Groin"
	description = "Caress their groin."
	category = "Groin"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("groin")
	message = list(
		"caresses %TARGET%'s groin with teasing touches.",
		"lets their hand drift over %TARGET%'s groin.",
		"gives %TARGET%'s groin a lingering caress."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/groin_stroke
	name = "Stroke Groin"
	description = "Stroke their groin with your hand."
	category = "Groin"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("groin")
	message = list(
		"strokes %TARGET%'s groin.",
		"runs their hand teasingly over %TARGET%'s groin.",
		"works steady strokes over %TARGET%'s groin."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/groin_massage
	name = "Massage Groin"
	description = "Massage their groin gently."
	category = "Groin"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("groin")
	message = list(
		"gently massages %TARGET%'s groin.",
		"works careful pressure into %TARGET%'s inner groin.",
		"gives %TARGET%'s groin a slow, careful massage."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/groin_kiss
	name = "Kiss Groin"
	description = "Kiss their groin."
	category = "Groin"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("groin")
	message = list(
		"kisses %TARGET%'s groin softly.",
		"presses a slow kiss to %TARGET%'s groin.",
		"trails teasing kisses over %TARGET%'s groin."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/groin_lick
	name = "Lick Groin"
	description = "Lick their groin."
	category = "Groin"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("groin")
	message = list(
		"drags their tongue over %TARGET%'s groin.",
		"licks a teasing line along %TARGET%'s groin.",
		"works a slow lick over %TARGET%'s groin."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/palm_groin
	name = "Palm Their Groin"
	description = "Cup their groin in your hand."
	category = "Groin"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("groin")
	message = list(
		"cups %TARGET%'s groin in their hand.",
		"palms %TARGET%'s groin with a warm, steady touch.",
		"holds their hand over %TARGET%'s groin and presses in slowly."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/trace_groin
	name = "Trace Their Groin"
	description = "Trace your fingers over their groin."
	category = "Groin"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("groin")
	message = list(
		"traces slow fingertips over %TARGET%'s groin.",
		"draws a teasing line of touch across %TARGET%'s groin.",
		"lets their fingers wander over %TARGET%'s groin."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/rub_groin
	name = "Rub Their Groin"
	description = "Rub against their groin."
	category = "Groin"
	target_required_any_parts = list("groin")
	message = list(
		"rubs against %TARGET%'s groin.",
		"presses close and grinds lightly against %TARGET%'s groin.",
		"presses in and teases against %TARGET%'s groin."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/hold_at_groin
	name = "Hold Close At Their Groin"
	description = "Hold them close at the groin."
	category = "Groin"
	target_required_any_parts = list("groin")
	message = list(
		"holds %TARGET% close with their body pressed at the groin.",
		"draws %TARGET% in until their groins meet.",
		"keeps %TARGET% close in a slow groin-to-groin press."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/groin_tease
	name = "Tease Groin"
	description = "Tease their groin all over."
	category = "Groin"
	target_required_any_parts = list("groin")
	message = list(
		"teases %TARGET%'s groin with slow, deliberate attention.",
		"keeps their focus lingering on %TARGET%'s groin.",
		"works %TARGET%'s groin over in a patient tease."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/hand_caress
	name = "Caress Hands"
	description = "Caress their hands."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("hands")
	message = list(
		"caresses %TARGET%'s hands with gentle touches.",
		"lets their fingers drift over %TARGET%'s hands.",
		"gives %TARGET%'s hands a soft caress."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/hold_hands
	name = "Hold Hands"
	description = "Take their hands in yours."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("hands")
	message = list(
		"takes %TARGET%'s hands in theirs.",
		"holds %TARGET%'s hands gently.",
		"threads their fingers through %TARGET%'s hands."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(0, 2)

/datum/interaction/howling_extra/kiss_hand
	name = "Kiss Hand"
	description = "Kiss their hand."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("hands")
	message = list(
		"kisses %TARGET%'s hand softly.",
		"presses a slow kiss to %TARGET%'s knuckles.",
		"lifts %TARGET%'s hand and kisses it."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/lick_fingers
	name = "Lick Their Fingers"
	description = "Lick their fingers."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("hands")
	message = list(
		"drags their tongue over %TARGET%'s fingers.",
		"teases %TARGET%'s fingertips with a slow lick.",
		"licks along %TARGET%'s fingers one by one."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/stroke_arms
	name = "Stroke Their Arms"
	description = "Stroke their arms."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	message = list(
		"strokes along %TARGET%'s arms.",
		"runs their hands up and down %TARGET%'s arms.",
		"gives %TARGET%'s arms a careful stroke."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/massage_shoulders
	name = "Massage Their Shoulders"
	description = "Massage their shoulders."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	message = list(
		"massages %TARGET%'s shoulders with steady pressure.",
		"works their thumbs into %TARGET%'s shoulders.",
		"gives %TARGET%'s shoulders a careful massage."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/trace_collarbone
	name = "Trace Their Collarbone"
	description = "Trace your fingers over their collarbone."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	message = list(
		"traces their fingertips over %TARGET%'s collarbone.",
		"draws a line along %TARGET%'s clavicle.",
		"teases %TARGET%'s collarbone with a light touch."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/palm_shoulders
	name = "Palm Their Shoulders"
	description = "Rest your hands on their shoulders."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	message = list(
		"rests both hands on %TARGET%'s shoulders.",
		"palms %TARGET%'s shoulders and keeps them there.",
		"settles their hands warmly on %TARGET%'s shoulders."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(0, 2)

/datum/interaction/howling_extra/guide_wrist
	name = "Guide Their Wrist"
	description = "Guide them by the wrist."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("hands")
	message = list(
		"takes %TARGET%'s wrist and guides them closer.",
		"hooks gentle fingers around %TARGET%'s wrist.",
		"leads %TARGET% by the wrist."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/trail_fingers_arms
	name = "Trail Fingers Along Their Arms"
	description = "Trail your fingers along their arms and shoulders."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	message = list(
		"trails their fingers along %TARGET%'s arms and shoulders.",
		"lets their fingertips wander from %TARGET%'s wrist up to their shoulder.",
		"draws a line of touch over %TARGET%'s arms."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/kiss_palm
	name = "Kiss Their Palm"
	description = "Kiss their palm softly."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("hands")
	message = list(
		"kisses %TARGET%'s palm softly.",
		"presses a slow kiss into %TARGET%'s open palm.",
		"turns %TARGET%'s hand and kisses their palm."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/squeeze_hand
	name = "Squeeze Their Hand"
	description = "Give their hand a slow squeeze."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("hands")
	message = list(
		"gives %TARGET%'s hand a slow squeeze.",
		"squeezes %TARGET%'s hand and holds it for a moment.",
		"closes their fingers around %TARGET%'s hand in a gentle squeeze."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(0, 2)

/datum/interaction/howling_extra/massage_palm
	name = "Massage Their Palm"
	description = "Massage their palm."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("hands")
	message = list(
		"massages %TARGET%'s palm with their thumb.",
		"works slow circles into %TARGET%'s palm.",
		"rubs a careful massage into %TARGET%'s palm."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/massage_fingers
	name = "Massage Their Fingers"
	description = "Massage their fingers one by one."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("hands")
	message = list(
		"massages %TARGET%'s fingers one by one.",
		"works careful pressure through %TARGET%'s fingers.",
		"rolls %TARGET%'s fingers between their own in a slow massage."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/rub_wrist
	name = "Rub Their Wrist"
	description = "Rub their wrist slowly."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("hands")
	message = list(
		"rubs %TARGET%'s wrist with a slow thumb stroke.",
		"traces slow circles around %TARGET%'s wrist.",
		"lets their fingers linger around %TARGET%'s wrist."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/kiss_wrist
	name = "Kiss Their Wrist"
	description = "Kiss their wrist."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("hands")
	message = list(
		"kisses %TARGET%'s wrist softly.",
		"presses their lips to the inside of %TARGET%'s wrist.",
		"lifts %TARGET%'s wrist and leaves a slow kiss there."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/lick_palm
	name = "Lick Their Palm"
	description = "Lick their palm."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("hands")
	message = list(
		"drags their tongue over %TARGET%'s palm.",
		"gives %TARGET%'s palm a slow lick.",
		"teases %TARGET%'s palm with a warm, wet stroke of their tongue."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/guide_hand_to_body
	name = "Guide Hand Over Body"
	description = "Guide their hand over your body."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND, INTERACTION_REQUIRE_TARGET_HAND)
	target_required_parts = list("hands")
	message = list(
		"guides %TARGET%'s hand slowly over their body.",
		"takes %TARGET%'s hand and presses it to themself.",
		"draws %TARGET%'s hand across their body in a teasing motion."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/trace_knuckles
	name = "Trace Their Knuckles"
	description = "Trace your fingers over their knuckles."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("hands")
	message = list(
		"traces slow fingertips over %TARGET%'s knuckles.",
		"draws a teasing line across %TARGET%'s knuckles.",
		"lets their touch linger over %TARGET%'s knuckles."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/kiss_knuckles
	name = "Kiss Their Knuckles"
	description = "Kiss their knuckles."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("hands")
	message = list(
		"kisses %TARGET%'s knuckles softly.",
		"presses a slow kiss over %TARGET%'s knuckles.",
		"lifts %TARGET%'s hand and kisses their knuckles."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/brush_fingertips
	name = "Brush Their Fingertips"
	description = "Brush your fingertips against theirs."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("hands")
	message = list(
		"brushes their fingertips against %TARGET%'s.",
		"lets their fingertips ghost lightly over %TARGET%'s fingers.",
		"teases %TARGET%'s fingertips with a feather-light touch."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/press_palm
	name = "Press Their Palm"
	description = "Press your palm against theirs."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("hands")
	message = list(
		"presses their palm slowly against %TARGET%'s.",
		"holds %TARGET%'s palm against their own.",
		"meets %TARGET%'s hand in a warm palm-to-palm press."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(0, 2)

/datum/interaction/howling_extra/pin_wrist
	name = "Pin Their Wrist"
	description = "Pin their wrist in place."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("hands")
	message = list(
		"pins %TARGET%'s wrist in place with a steady hand.",
		"closes a firm grip around %TARGET%'s wrist and holds it there.",
		"keeps %TARGET%'s wrist trapped under their hand."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/lift_hand
	name = "Lift Their Hand"
	description = "Lift their hand and hold it up."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("hands")
	message = list(
		"lifts %TARGET%'s hand slowly.",
		"raises %TARGET%'s hand and keeps it suspended for a moment.",
		"takes %TARGET%'s hand and draws it upward."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/raise_arm
	name = "Raise Their Arm"
	description = "Guide their arm up."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("hands")
	message = list(
		"guides %TARGET%'s arm up with a slow pull.",
		"lifts %TARGET%'s arm overhead.",
		"draws %TARGET%'s arm upward in a teasing motion."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/stroke_forearms
	name = "Stroke Their Forearms"
	description = "Stroke their forearms slowly."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("hands")
	message = list(
		"strokes slowly along %TARGET%'s forearms.",
		"runs their hands down %TARGET%'s forearms in a careful pass.",
		"teases %TARGET%'s forearms with a slow stroke."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/lick_wrist
	name = "Lick Their Wrist"
	description = "Lick their wrist."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("hands")
	message = list(
		"drags their tongue over %TARGET%'s wrist.",
		"gives %TARGET%'s wrist a slow lick.",
		"teases the inside of %TARGET%'s wrist with their tongue."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/guide_hand_to_neck
	name = "Guide Hand To Their Neck"
	description = "Guide their hand to your neck."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND, INTERACTION_REQUIRE_TARGET_HAND)
	user_required_parts = list("neck")
	target_required_parts = list("hands")
	message = list(
		"guides %TARGET%'s hand up to their neck.",
		"takes %TARGET%'s hand and presses it to their throat.",
		"draws %TARGET%'s hand to rest against their neck."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/guide_hand_to_chest
	name = "Guide Hand To Their Chest"
	description = "Guide their hand to your chest."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND, INTERACTION_REQUIRE_TARGET_HAND)
	user_required_parts = list("chest")
	target_required_parts = list("hands")
	message = list(
		"guides %TARGET%'s hand over their chest.",
		"takes %TARGET%'s hand and presses it to their chest.",
		"draws %TARGET%'s hand across their upper body."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/guide_hand_to_groin
	name = "Guide Hand To Their Groin"
	description = "Guide their hand to your groin."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND, INTERACTION_REQUIRE_TARGET_HAND)
	user_required_parts = list("groin")
	target_required_parts = list("hands")
	message = list(
		"guides %TARGET%'s hand down to their groin.",
		"takes %TARGET%'s hand and presses it teasingly to their groin.",
		"draws %TARGET%'s hand over their groin and keeps it there."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/stroke_ears
	name = "Stroke Ears"
	description = "Stroke their ears gently."
	category = "Ears"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("ears")
	message = list(
		"strokes %TARGET%'s ears.",
		"rubs %TARGET%'s ears between their fingers.",
		"gently pets %TARGET%'s ears."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/items/weapons/slap.ogg')
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/ear_lick
	name = "Ear Lick"
	description = "Lick their ear."
	category = "Ears"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("ears")
	message = list(
		"licks %TARGET%'s ear.",
		"drags their tongue across %TARGET%'s ear.",
		"teases %TARGET%'s ear with a wet lick."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/caress_ears
	name = "Caress Their Ears"
	description = "Caress their ears."
	category = "Ears"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("ears")
	message = list(
		"caresses %TARGET%'s ears with careful fingers.",
		"pets slowly over %TARGET%'s ears.",
		"lets their fingers wander over %TARGET%'s ears in soft strokes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/rub_ears
	name = "Rub Their Ears"
	description = "Rub their ears between your fingers."
	category = "Ears"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("ears")
	message = list(
		"rubs %TARGET%'s ears between thumb and forefinger.",
		"works slow little rubs over %TARGET%'s ears.",
		"massages the length of %TARGET%'s ears between their fingers."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/trace_ear_edges
	name = "Trace Their Ear Edges"
	description = "Trace along the edges of their ears."
	category = "Ears"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("ears")
	message = list(
		"traces a fingertip along the edge of %TARGET%'s ear.",
		"lets their nail lightly skim %TARGET%'s ear edge.",
		"outlines %TARGET%'s ears in delicate little passes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/tug_ears
	name = "Tug Their Ears"
	description = "Give their ears a teasing tug."
	category = "Ears"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("ears")
	message = list(
		"gives %TARGET%'s ears a playful tug.",
		"hooks their fingers around %TARGET%'s ears and tugs gently.",
		"teases %TARGET% with a soft little pull at their ears."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/kiss_ears
	name = "Kiss Their Ears"
	description = "Kiss their ears."
	category = "Ears"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("ears")
	message = list(
		"presses little kisses along %TARGET%'s ears.",
		"kisses the soft edge of %TARGET%'s ear.",
		"teases %TARGET%'s ears with warm little kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/kiss_earlobes
	name = "Kiss Their Earlobes"
	description = "Kiss their earlobes."
	category = "Ears"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("ears")
	message = list(
		"kisses %TARGET%'s earlobe in slow little presses.",
		"lingers at %TARGET%'s earlobe with soft kisses.",
		"teases %TARGET%'s earlobe with warm, patient kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss3.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/nibble_ears
	name = "Nibble Their Ears"
	description = "Nibble on their ears."
	category = "Ears"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("ears")
	message = list(
		"nibbles lightly at %TARGET%'s ear.",
		"catches the edge of %TARGET%'s ear between their teeth in a teasing nibble.",
		"works little nibbles along %TARGET%'s ear."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss4.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/suck_earlobes
	name = "Suck Their Earlobes"
	description = "Suck gently on their earlobes."
	category = "Ears"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("ears")
	message = list(
		"takes %TARGET%'s earlobe between their lips and sucks gently.",
		"suckles at %TARGET%'s earlobe in slow little pulls.",
		"wraps their lips around %TARGET%'s earlobe with a teasing suck."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(2, 4)
	target_pleasure = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/breathe_on_ears
	name = "Breathe Over Their Ears"
	description = "Breathe warm air over their ears."
	category = "Ears"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("ears")
	message = list(
		"breathes warm air over %TARGET%'s ears.",
		"lets a slow, warm breath wash over %TARGET%'s ear.",
		"teases %TARGET%'s ears with the heat of their breath."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/lap_ears
	name = "Lap At Their Ears"
	description = "Lap lightly at their ears."
	category = "Ears"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("ears")
	message = list(
		"laps lightly at %TARGET%'s ears with the tip of their tongue.",
		"lets quick, teasing licks dance over %TARGET%'s ears.",
		"flicks their tongue against %TARGET%'s ears in playful little passes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/grope_ass
	name = "Grope Ass"
	description = "Grope their ass."
	category = "Butt"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("butt")
	message = list(
		"gropes %TARGET%'s ass.",
		"squeezes %TARGET%'s butt.",
		"grabs %TARGET%'s rear in their hand."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/effects/emotes/assslap.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/caress_ass
	name = "Caress Their Ass"
	description = "Let your hands roam over their ass."
	category = "Butt"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("butt")
	message = list(
		"caresses %TARGET%'s ass with wandering hands.",
		"lets their palms drift over %TARGET%'s rear.",
		"pets %TARGET%'s ass in slow, teasing strokes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/effects/emotes/assslap.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/massage_ass
	name = "Massage Their Ass"
	description = "Work a slow massage into their ass."
	category = "Butt"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("butt")
	message = list(
		"massages %TARGET%'s ass with both hands.",
		"kneads %TARGET%'s rear in slow circles.",
		"works a firm, lingering massage into %TARGET%'s ass."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/effects/emotes/assslap.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/knead_ass
	name = "Knead Their Ass"
	description = "Knead their ass in both hands."
	category = "Butt"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("butt")
	message = list(
		"kneads %TARGET%'s ass with eager hands.",
		"works both palms into %TARGET%'s cheeks with a slow squeeze.",
		"gives %TARGET%'s ass a greedy, kneading grip."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/effects/emotes/assslap.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/squeeze_ass
	name = "Squeeze Their Ass"
	description = "Squeeze their ass."
	category = "Butt"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("butt")
	message = list(
		"squeezes %TARGET%'s ass hard in both hands.",
		"gives %TARGET%'s butt a firm, possessive squeeze.",
		"grabs %TARGET%'s cheeks and squeezes them together."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/effects/emotes/assslap.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/pinch_ass
	name = "Pinch Their Ass"
	description = "Pinch their ass through whatever they're wearing."
	category = "Butt"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("butt")
	message = list(
		"pinches %TARGET%'s ass through the fabric.",
		"catches a cheek of %TARGET%'s ass in a quick pinch.",
		"gives %TARGET%'s rear a teasing pinch."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/effects/emotes/assslap.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)
	target_pain = list(0, 1)

/datum/interaction/howling_extra/rub_ass
	name = "Rub Their Ass"
	description = "Rub your hands over their ass."
	category = "Butt"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("butt")
	message = list(
		"rubs their hands over %TARGET%'s ass in lingering passes.",
		"slides their palms across %TARGET%'s rear.",
		"works teasing rubs over %TARGET%'s asscheeks."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/effects/emotes/assslap.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/spread_asscheeks
	name = "Spread Their Asscheeks"
	description = "Part their asscheeks with your hands."
	category = "Butt"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("butt")
	message = list(
		"spreads %TARGET%'s asscheeks apart with both hands.",
		"hooks their fingers into %TARGET%'s cheeks and pulls them open.",
		"parts %TARGET%'s rear just enough to admire what's between."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/effects/emotes/assslap.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/hold_hips
	name = "Hold Their Hips"
	description = "Take hold of their hips."
	category = "Butt"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("butt")
	message = list(
		"takes hold of %TARGET%'s hips and keeps them close.",
		"plants their hands on %TARGET%'s hips with a possessive grip.",
		"grabs %TARGET%'s hips and guides their body closer."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/pull_closer_by_ass
	name = "Pull Them Closer By Ass"
	description = "Drag them in by the ass."
	category = "Butt"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("butt")
	message = list(
		"grabs %TARGET%'s ass and pulls them in closer.",
		"hooks both hands over %TARGET%'s rear and tugs them flush against their body.",
		"uses %TARGET%'s ass to drag them in tight."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/effects/emotes/assslap.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/kiss_asscheeks
	name = "Kiss Their Asscheeks"
	description = "Kiss their asscheeks."
	category = "Butt"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("butt")
	message = list(
		"presses slow kisses to %TARGET%'s asscheeks.",
		"kisses along the curve of %TARGET%'s rear.",
		"covers %TARGET%'s ass with warm little kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/lick_asscheeks
	name = "Lick Their Asscheeks"
	description = "Lick along their asscheeks."
	category = "Butt"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("butt")
	message = list(
		"drags their tongue over %TARGET%'s asscheeks.",
		"licks a warm trail along %TARGET%'s rear.",
		"tastes %TARGET%'s ass with broad, wet licks."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/press_face_to_ass
	name = "Press Face To Their Ass"
	description = "Press your face into their ass."
	category = "Butt"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("butt")
	message = list(
		"presses their face into %TARGET%'s ass.",
		"buries their cheek against %TARGET%'s rear with a needy nuzzle.",
		"leans in and presses their face between %TARGET%'s asscheeks."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/bury_face_in_ass
	name = "Bury Face In Their Ass"
	description = "Bury your face in their ass."
	category = "Butt"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("butt")
	message = list(
		"buries their face deep in %TARGET%'s asscheeks.",
		"nuzzles right into %TARGET%'s rear and stays there a moment.",
		"shamelessly smothers their face against %TARGET%'s ass."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral2.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/grope_breasts
	name = "Grope Breasts"
	description = "Grope their breasts."
	category = "Breasts"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("breasts")
	message = list(
		"gropes %TARGET%'s breasts.",
		"cups %TARGET%'s chest in their hands.",
		"squeezes %TARGET%'s breasts."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/squelch1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/handjob
	name = "Handjob"
	description = "Jerk them off."
	category = "Penis"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("penis")
	message = list(
		"jerks %TARGET% off.",
		"works %TARGET%'s shaft with their hand.",
		"wanks %TARGET%'s cock hard."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/caress_cock
	name = "Caress Their Cock"
	description = "Let your fingers roam over their cock."
	category = "Penis"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("penis")
	message = list(
		"caresses %TARGET%'s cock with teasing strokes.",
		"lets their fingers wander over %TARGET%'s shaft.",
		"pets %TARGET%'s cock with light, intimate touches."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/stroke_cock
	name = "Stroke Their Cock"
	description = "Work your hand along their cock."
	category = "Penis"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("penis")
	message = list(
		"strokes %TARGET%'s cock in steady motions.",
		"works %TARGET%'s shaft with an easy rhythm.",
		"runs their hand up and down %TARGET%'s cock."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/massage_cock
	name = "Massage Their Cock"
	description = "Massage their shaft with steady pressure."
	category = "Penis"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("penis")
	message = list(
		"massages %TARGET%'s shaft with deliberate pressure.",
		"works a careful massage into %TARGET%'s cock.",
		"uses both hand and thumb to knead at %TARGET%'s shaft."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg'
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/kiss_cock
	name = "Kiss Their Cock"
	description = "Press kisses along their cock."
	category = "Penis"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("penis")
	message = list(
		"presses slow kisses to %TARGET%'s cock.",
		"kisses along %TARGET%'s shaft in lingering little presses.",
		"teases %TARGET%'s cock with warm, needy kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/lick_cock
	name = "Lick Their Cock"
	description = "Taste your way along their cock."
	category = "Penis"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("penis")
	message = list(
		"drags their tongue up %TARGET%'s cock.",
		"licks wet strokes along %TARGET%'s shaft.",
		"works their tongue over %TARGET%'s cock."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bj2.ogg',
		'sound/lewd/sounds/bj5.ogg',
		'sound/lewd/sounds/bj8.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(2, 4)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/tease_cock
	name = "Tease Their Cock"
	description = "Toy with their cock using your fingers."
	category = "Penis"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("penis")
	message = list(
		"teases %TARGET%'s cock with passing touches.",
		"plays their fingertips over %TARGET%'s shaft without giving enough friction.",
		"works teasing strokes over %TARGET%'s cock and leaves them wanting."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg'
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/rub_tip
	name = "Rub Their Tip"
	description = "Rub slow circles over the tip of their cock."
	category = "Penis"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("penis")
	message = list(
		"rubs a thumb over the tip of %TARGET%'s cock.",
		"works small circles over %TARGET%'s head.",
		"teases the sensitive tip of %TARGET%'s cock with careful pressure."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(1, 3)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/thumb_slit
	name = "Thumb Their Slit"
	description = "Drag your thumb over the slit of their cock."
	category = "Penis"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("penis")
	message = list(
		"drags their thumb over the slit of %TARGET%'s cock.",
		"teases %TARGET%'s slit with the pad of their thumb.",
		"works small motions over the tip of %TARGET%'s shaft."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(1, 3)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/lick_tip
	name = "Lick Their Tip"
	description = "Lick at the sensitive tip of their cock."
	category = "Penis"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("penis")
	message = list(
		"licks the tip of %TARGET%'s cock with slow little strokes.",
		"teases %TARGET%'s head with the tip of their tongue.",
		"flicks their tongue over the sensitive tip of %TARGET%'s shaft."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(2, 4)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/suck_tip
	name = "Suck Their Tip"
	description = "Suck gently on the tip of their cock."
	category = "Penis"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("penis")
	message = list(
		"takes just the tip of %TARGET%'s cock into their mouth with a soft suck.",
		"suckles at %TARGET%'s head in teasing pulls.",
		"wraps their lips around the tip of %TARGET%'s cock and sucks gently."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bj1.ogg',
		'sound/lewd/sounds/bj4.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(6, 8)

/datum/interaction/howling_extra/press_cock_to_body
	name = "Press Their Cock To Your Body"
	description = "Pin their cock against your body."
	category = "Penis"
	target_required_parts = list("penis")
	message = list(
		"presses %TARGET%'s cock against their body in a slow grind.",
		"holds %TARGET%'s shaft tight against themself with shameless pressure.",
		"draws %TARGET%'s cock against their body and rubs against it."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg'
	)
	user_arousal = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/grind_on_cock
	name = "Grind On Their Cock"
	description = "Grind yourself against their cock."
	category = "Penis"
	target_required_parts = list("penis")
	message = list(
		"grinds themself against %TARGET%'s cock in needy motions.",
		"presses close and rubs against %TARGET%'s shaft.",
		"works their body against %TARGET%'s cock with shameless pressure."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_arousal = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/finger_pussy
	name = "Finger Pussy"
	description = "Finger their pussy."
	category = "Vagina"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("vagina")
	message = list(
		"fingers %TARGET%'s pussy.",
		"pushes their fingers into %TARGET%'s wet sex.",
		"works %TARGET%'s pussy with their fingers."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(6, 8)

/datum/interaction/howling_extra/caress_pussy
	name = "Caress Their Pussy"
	description = "Let your fingers wander over their pussy."
	category = "Vagina"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("vagina")
	message = list(
		"caresses %TARGET%'s pussy with teasing strokes.",
		"lets their fingers wander over %TARGET%'s soft folds.",
		"pets %TARGET%'s pussy with careful, intimate touches."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/massage_pussy
	name = "Massage Their Pussy"
	description = "Massage their folds with gentle pressure."
	category = "Vagina"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("vagina")
	message = list(
		"massages %TARGET%'s pussy in small circles.",
		"rubs gentle pressure into %TARGET%'s folds.",
		"works %TARGET%'s pussy with soft, patient motions."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/kiss_pussy
	name = "Kiss Their Pussy"
	description = "Press kisses to their pussy."
	category = "Vagina"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("vagina")
	message = list(
		"presses warm kisses to %TARGET%'s pussy.",
		"kisses along %TARGET%'s soft folds.",
		"teases %TARGET%'s pussy with lingering kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/lick_pussy
	name = "Lick Their Pussy"
	description = "Taste your way over their pussy."
	category = "Vagina"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("vagina")
	message = list(
		"drags their tongue over %TARGET%'s pussy.",
		"licks slow, wet strokes along %TARGET%'s folds.",
		"works their tongue teasingly over %TARGET%'s sex."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bj1.ogg',
		'sound/lewd/sounds/bj4.ogg',
		'sound/lewd/sounds/bj7.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(2, 4)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/tease_pussy
	name = "Tease Their Pussy"
	description = "Toy with their pussy using your fingertips."
	category = "Vagina"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("vagina")
	message = list(
		"teases %TARGET%'s pussy with light touches.",
		"works their fingertips over %TARGET%'s folds without quite giving enough.",
		"plays at the entrance of %TARGET%'s pussy in maddening strokes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/part_pussy_lips
	name = "Part Their Pussy Lips"
	description = "Spread their folds with your fingers."
	category = "Vagina"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("vagina")
	message = list(
		"parts %TARGET%'s pussy lips with careful fingers.",
		"spreads %TARGET%'s folds just enough to admire them.",
		"uses two fingers to open %TARGET%'s pussy for a better look."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/rub_clit
	name = "Rub Their Clit"
	description = "Rub slow circles over their clit."
	category = "Vagina"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("vagina")
	message = list(
		"rubs %TARGET%'s clit in slow circles.",
		"works a fingertip over %TARGET%'s clit with careful pressure.",
		"teases %TARGET%'s clit in steady motions."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(2, 4)
	target_pleasure = list(2, 4)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/circle_clit
	name = "Circle Their Clit"
	description = "Circle their clit with a teasing fingertip."
	category = "Vagina"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("vagina")
	message = list(
		"circles %TARGET%'s clit with the tip of their finger.",
		"draws slow circles over %TARGET%'s clit.",
		"teases %TARGET%'s clit with patient circular motions."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(2, 4)
	target_pleasure = list(1, 3)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/suck_clit
	name = "Suck Their Clit"
	description = "Suck gently on their clit."
	category = "Vagina"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("vagina")
	message = list(
		"takes %TARGET%'s clit between their lips with a soft suck.",
		"suckles at %TARGET%'s clit in slow pulls.",
		"wraps their lips around %TARGET%'s clit and sucks gently."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(6, 8)

/datum/interaction/howling_extra/press_fingers_to_pussy
	name = "Press Fingers To Their Pussy"
	description = "Press your fingertips to their folds."
	category = "Vagina"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("vagina")
	message = list(
		"presses two fingers firmly to %TARGET%'s pussy.",
		"holds their fingertips against %TARGET%'s folds with just enough pressure.",
		"pins their fingers to %TARGET%'s pussy in a teasing hold."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/grind_against_pussy
	name = "Grind Against Their Pussy"
	description = "Grind against their pussy."
	category = "Vagina"
	target_required_parts = list("vagina")
	message = list(
		"grinds against %TARGET%'s pussy in needy motions.",
		"presses their body tight and rubs against %TARGET%'s pussy.",
		"works themself against %TARGET%'s folds with shameless pressure."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/bang1.ogg', 'sound/lewd/sounds/bang2.ogg', 'sound/lewd/sounds/bang3.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/hold_pussy_open
	name = "Hold Their Pussy Open"
	description = "Hold their folds open with your fingers."
	category = "Vagina"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("vagina")
	message = list(
		"holds %TARGET%'s pussy open for a long, shameless look.",
		"spreads %TARGET%'s folds and keeps them open under their fingers.",
		"uses both hands to part %TARGET%'s pussy and admire it."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/finger_ass
	name = "Finger Ass"
	description = "Finger their ass."
	category = "Anus"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("anus")
	message = list(
		"fingers %TARGET%'s ass.",
		"slides their fingers into %TARGET%'s asshole.",
		"works a finger into %TARGET%'s rear."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/caress_asshole
	name = "Caress Their Asshole"
	description = "Trace soft touches around their asshole."
	category = "Anus"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("anus")
	message = list(
		"caresses around %TARGET%'s asshole with light fingertips.",
		"lets their fingers trace soft circles around %TARGET%'s rear.",
		"teases %TARGET%'s asshole with delicate touches."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/massage_asshole
	name = "Massage Their Asshole"
	description = "Work careful pressure around their asshole."
	category = "Anus"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("anus")
	message = list(
		"rubs slow circles around %TARGET%'s asshole.",
		"massages %TARGET%'s rear with careful pressure.",
		"works their fingertips around %TARGET%'s asshole in patient motions."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/tease_asshole
	name = "Tease Their Asshole"
	description = "Toy with their asshole using your fingers."
	category = "Anus"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("anus")
	message = list(
		"teases %TARGET%'s asshole with passing touches.",
		"plays their fingertips over %TARGET%'s rear without slipping in.",
		"works teasing pressure over %TARGET%'s asshole and makes them squirm."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/rub_asshole
	name = "Rub Their Asshole"
	description = "Rub slow circles over their asshole."
	category = "Anus"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("anus")
	message = list(
		"rubs a fingertip over %TARGET%'s asshole.",
		"works slow strokes across %TARGET%'s rear entrance.",
		"presses and rubs at %TARGET%'s asshole in circles."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/thumb_asshole
	name = "Thumb Their Asshole"
	description = "Press your thumb against their asshole."
	category = "Anus"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("anus")
	message = list(
		"presses their thumb firmly to %TARGET%'s asshole.",
		"holds their thumb against %TARGET%'s rear in a slow, deliberate push.",
		"works the pad of their thumb over %TARGET%'s asshole."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(2, 4)
	target_pleasure = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/spread_anus
	name = "Spread Their Ass Open"
	description = "Spread their ass open with your fingers."
	category = "Anus"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("anus")
	message = list(
		"spreads %TARGET%'s rear open with both hands.",
		"parts %TARGET%'s cheeks and exposes their asshole.",
		"pulls %TARGET%'s ass open just enough to admire it."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/hold_ass_open
	name = "Hold Their Ass Open"
	description = "Keep their ass open under your hands."
	category = "Anus"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("anus")
	message = list(
		"holds %TARGET%'s ass open for a long, shameless look.",
		"keeps %TARGET%'s cheeks parted under both hands.",
		"spreads %TARGET%'s rear and makes them stay that way."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/kiss_asshole
	name = "Kiss Their Asshole"
	description = "Kiss their asshole."
	category = "Anus"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("anus")
	message = list(
		"presses a slow kiss to %TARGET%'s asshole.",
		"kisses right against %TARGET%'s rear entrance.",
		"teases %TARGET%'s asshole with warm little kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/rim_asshole
	name = "Rim Their Asshole"
	description = "Rim their asshole."
	category = "Anus"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("anus")
	message = list(
		"circles %TARGET%'s asshole with their tongue.",
		"rims %TARGET%'s rear in slow, wet passes.",
		"works their tongue around %TARGET%'s asshole with hungry attention."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg',
		'sound/lewd/sounds/bj6.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(2, 4)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/press_tongue_to_ass
	name = "Press Tongue To Their Asshole"
	description = "Press your tongue firmly to their asshole."
	category = "Anus"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("anus")
	message = list(
		"presses their tongue firmly to %TARGET%'s asshole.",
		"holds the flat of their tongue against %TARGET%'s rear.",
		"leans in and pushes their tongue against %TARGET%'s asshole in a slow tease."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/grind_against_ass
	name = "Grind Against Their Ass"
	description = "Grind yourself against their ass."
	category = "Anus"
	target_required_parts = list("anus")
	message = list(
		"grinds against %TARGET%'s ass in slow, needy motions.",
		"presses their body tight and rubs against %TARGET%'s rear.",
		"works themself against %TARGET%'s backside with shameless pressure."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/bang1.ogg', 'sound/lewd/sounds/bang2.ogg', 'sound/lewd/sounds/bang3.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/perform_oral
	name = "Perform Oral"
	description = "Go down on them."
	category = "Vagina"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("vagina")
	message = list(
		"buries their face in %TARGET%'s pussy.",
		"goes down on %TARGET%.",
		"works their tongue over %TARGET%'s folds."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bj1.ogg',
		'sound/lewd/sounds/bj4.ogg',
		'sound/lewd/sounds/bj7.ogg',
		'sound/lewd/sounds/bj10.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(6, 8)

/datum/interaction/howling_extra/suck_cock
	name = "Suck Cock"
	description = "Suck them off."
	category = "Penis"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("penis")
	message = list(
		"takes %TARGET%'s cock into their mouth.",
		"wraps their lips around %TARGET%'s cock.",
		"goes down on %TARGET%."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bj2.ogg',
		'sound/lewd/sounds/bj5.ogg',
		'sound/lewd/sounds/bj8.ogg',
		'sound/lewd/sounds/bj11.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(4, 6)
	target_arousal = list(6, 8)

/datum/interaction/howling_extra/lick_ass
	name = "Lick Ass"
	description = "Lick their ass."
	category = "Anus"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("anus")
	message = list(
		"licks %TARGET%'s ass.",
		"drags their tongue over %TARGET%'s asshole.",
		"buries their face against %TARGET%'s rear."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg',
		'sound/lewd/sounds/bj6.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/rub_feet
	name = "Rub Their Feet"
	description = "Rub their feet."
	category = "Foreplay"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("feet")
	message = list(
		"rubs %TARGET%'s feet.",
		"massages %TARGET%'s feet with both hands.",
		"works their fingers over %TARGET%'s soles."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/foot_dry1.ogg',
		'sound/lewd/sounds/foot_dry2.ogg',
		'sound/lewd/sounds/foot_dry3.ogg'
	)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/lick_feet
	name = "Lick Their Feet"
	description = "Lick their feet."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("feet")
	message = list(
		"licks %TARGET%'s feet.",
		"runs their tongue over %TARGET%'s soles.",
		"kisses and licks along %TARGET%'s feet."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/foot_wet1.ogg',
		'sound/lewd/sounds/foot_wet2.ogg',
		'sound/lewd/sounds/foot_wet3.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/caress_feet
	name = "Caress Their Feet"
	description = "Caress their feet gently."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("feet")
	message = list(
		"caresses %TARGET%'s feet with light touches.",
		"lets their fingers drift slowly over %TARGET%'s feet.",
		"gives %TARGET%'s feet a soft caress."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/foot_dry1.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/hold_feet
	name = "Hold Their Feet"
	description = "Take their feet in your hands."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("feet")
	message = list(
		"takes %TARGET%'s feet in their hands.",
		"holds %TARGET%'s feet gently.",
		"cradles %TARGET%'s feet with quiet care."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/foot_dry2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(0, 2)

/datum/interaction/howling_extra/kiss_feet
	name = "Kiss Their Feet"
	description = "Kiss their feet."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("feet")
	message = list(
		"kisses %TARGET%'s feet softly.",
		"presses slow kisses to %TARGET%'s feet.",
		"covers %TARGET%'s feet in light kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/kiss1.ogg',
		'sound/lewd/sounds/kiss2.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/trace_soles
	name = "Trace Their Soles"
	description = "Trace your fingers over their soles."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("feet")
	message = list(
		"traces slow fingers over %TARGET%'s soles.",
		"draws teasing lines across %TARGET%'s soles.",
		"lets their fingertips wander over %TARGET%'s soles."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/foot_dry2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/kiss_toes
	name = "Kiss Their Toes"
	description = "Kiss their toes."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("feet")
	message = list(
		"kisses %TARGET%'s toes one by one.",
		"presses soft kisses to %TARGET%'s toes.",
		"lifts %TARGET%'s foot and kisses their toes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/kiss1.ogg',
		'sound/lewd/sounds/kiss3.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/lick_toes
	name = "Lick Their Toes"
	description = "Lick their toes."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("feet")
	message = list(
		"drags their tongue over %TARGET%'s toes.",
		"teases %TARGET%'s toes with slow licks.",
		"licks between %TARGET%'s toes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/foot_wet1.ogg',
		'sound/lewd/sounds/foot_wet2.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/press_feet
	name = "Press Their Feet"
	description = "Press their feet against your body."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("feet")
	message = list(
		"presses %TARGET%'s feet against their body.",
		"holds %TARGET%'s feet close and presses into them.",
		"draws %TARGET%'s feet against themself in a slow tease."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/foot_dry3.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/knead_feet
	name = "Knead Their Feet"
	description = "Knead their feet slowly."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("feet")
	message = list(
		"kneads %TARGET%'s feet slowly in their hands.",
		"works deep pressure into %TARGET%'s feet.",
		"gives %TARGET%'s feet a slow kneading massage."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/foot_dry3.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/paw_pad_massage
	name = "Massage Paw Pads"
	description = "Massage their paw pads."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("pawpads")
	message = list(
		"massages %TARGET%'s paw pads with slow circles.",
		"works their thumbs into %TARGET%'s soft paw pads.",
		"gives %TARGET%'s paw pads a careful massage."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/foot_dry1.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/kiss_paw_pads
	name = "Kiss Their Paw Pads"
	description = "Kiss their paw pads."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("pawpads")
	message = list(
		"kisses %TARGET%'s paw pads softly.",
		"presses slow kisses to %TARGET%'s paw pads.",
		"covers %TARGET%'s paw pads in light kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/kiss1.ogg',
		'sound/lewd/sounds/kiss2.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/lick_paw_pads
	name = "Lick Their Paw Pads"
	description = "Lick their paw pads."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("pawpads")
	message = list(
		"drags their tongue over %TARGET%'s paw pads.",
		"teases %TARGET%'s paw pads with slow licks.",
		"licks over the soft pads of %TARGET%'s feet."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/foot_wet1.ogg',
		'sound/lewd/sounds/foot_wet2.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/trace_paw_pads
	name = "Trace Their Paw Pads"
	description = "Trace your fingers over their paw pads."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("pawpads")
	message = list(
		"traces their fingers over %TARGET%'s paw pads.",
		"draws slow lines across %TARGET%'s paw pads.",
		"lets their fingertips wander over %TARGET%'s soft paw pads."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/foot_dry2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/press_paw_pads
	name = "Press Their Paw Pads"
	description = "Press into their paw pads."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("pawpads")
	message = list(
		"presses gently into %TARGET%'s paw pads.",
		"works a slow thumb press into %TARGET%'s paw pads.",
		"gives %TARGET%'s paw pads a teasing press."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/foot_dry3.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/massage_toes
	name = "Massage Their Toes"
	description = "Massage their toes one by one."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("feet")
	message = list(
		"massages %TARGET%'s toes one by one.",
		"works careful pressure through %TARGET%'s toes.",
		"rolls %TARGET%'s toes slowly between their fingers."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/foot_dry1.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/suck_toes
	name = "Suck Their Toes"
	description = "Suck on their toes."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("feet")
	message = list(
		"wraps their lips around %TARGET%'s toes.",
		"sucks softly on %TARGET%'s toes.",
		"draws %TARGET%'s toes into their mouth one by one."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/foot_wet2.ogg',
		'sound/lewd/sounds/foot_wet3.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/kiss_ankle
	name = "Kiss Their Ankle"
	description = "Kiss their ankle."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("feet")
	message = list(
		"kisses %TARGET%'s ankle softly.",
		"presses slow kisses around %TARGET%'s ankle.",
		"lifts %TARGET%'s foot and kisses their ankle."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/massage_ankle
	name = "Massage Their Ankle"
	description = "Massage their ankle."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("feet")
	message = list(
		"massages %TARGET%'s ankle with slow circles.",
		"works their thumbs around %TARGET%'s ankle.",
		"gives %TARGET%'s ankle a careful massage."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/foot_dry1.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/rub_arch
	name = "Rub Their Arch"
	description = "Rub the arch of their foot."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("feet")
	message = list(
		"rubs slow circles into the arch of %TARGET%'s foot.",
		"works their thumb along %TARGET%'s arch.",
		"teases the arch of %TARGET%'s foot with a careful rub."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/foot_dry2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/hold_ankle
	name = "Hold Their Ankle"
	description = "Hold their ankle gently."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("feet")
	message = list(
		"wraps a careful hand around %TARGET%'s ankle.",
		"holds %TARGET%'s ankle gently.",
		"keeps %TARGET%'s ankle cradled in their hand."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/foot_dry1.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(0, 2)

/datum/interaction/howling_extra/rub_paw_pads
	name = "Rub Their Paw Pads"
	description = "Rub their paw pads slowly."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("pawpads")
	message = list(
		"rubs %TARGET%'s paw pads in slow circles.",
		"works their thumb over %TARGET%'s soft paw pads.",
		"teases %TARGET%'s paw pads with a careful rub."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/foot_dry2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/suck_paw_pads
	name = "Suck Their Paw Pads"
	description = "Suck on their paw pads."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("pawpads")
	message = list(
		"draws %TARGET%'s paw pads slowly into their mouth.",
		"sucks softly on %TARGET%'s paw pads.",
		"wraps warm lips around the soft pads of %TARGET%'s foot."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/foot_wet2.ogg',
		'sound/lewd/sounds/foot_wet3.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/tail_tease
	name = "Tail Tease"
	description = "Play with their tail."
	category = "Foreplay"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("tail")
	message = list(
		"teases %TARGET%'s tail with their fingers.",
		"strokes %TARGET%'s tail slowly.",
		"runs a hand along %TARGET%'s tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/items/weapons/slap.ogg')
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_lick
	name = "Tail Lick"
	description = "Lick their tail."
	category = "Oral"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("tail")
	message = list(
		"licks along %TARGET%'s tail.",
		"drags their tongue over %TARGET%'s tail.",
		"presses wet kisses to %TARGET%'s tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/tail_massage
	name = "Tail Massage"
	description = "Massage their tail with your hands."
	category = "Foreplay"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("tail")
	message = list(
		"gently massages %TARGET%'s tail with both hands.",
		"works careful fingers along %TARGET%'s tail.",
		"slowly kneads %TARGET%'s tail in their hands."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/tail_base_massage
	name = "Tail Base Massage"
	description = "Massage the base of their tail."
	category = "Foreplay"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("tail")
	message = list(
		"massages the base of %TARGET%'s tail in slow circles.",
		"works their thumbs where %TARGET%'s tail meets their back.",
		"carefully kneads the base of %TARGET%'s tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_stroke_hands
	name = "Stroke Tail"
	description = "Stroke their tail with your hand."
	category = "Foreplay"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("tail")
	message = list(
		"strokes %TARGET%'s tail from base to tip.",
		"runs a slow hand along %TARGET%'s tail.",
		"lets their fingers glide down %TARGET%'s tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/tail_caress_hands
	name = "Caress Tail"
	description = "Caress their tail."
	category = "Foreplay"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("tail")
	message = list(
		"caresses %TARGET%'s tail with light touches.",
		"cups %TARGET%'s tail and pets it slowly.",
		"gives %TARGET%'s tail a soft, careful caress."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/tail_hold_hands
	name = "Hold Tail"
	description = "Hold their tail gently."
	category = "Foreplay"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("tail")
	message = list(
		"gently takes %TARGET%'s tail in their hands.",
		"holds %TARGET%'s tail with quiet care.",
		"cradles %TARGET%'s tail and keeps it close."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(0, 2)

/datum/interaction/howling_extra/finger_pussy_self
	name = "Finger Yourself"
	description = "Pleasure your own pussy with your fingers."
	category = "Masturbation"
	usage = INTERACTION_SELF
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	user_required_parts = list("vagina")
	message = list(
		"fingers their pussy.",
		"pushes their fingers into their own pussy.",
		"works their own wet sex with their fingers."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_pleasure = list(4, 6)
	user_arousal = list(6, 8)

/datum/interaction/howling_extra/finger_ass_self
	name = "Finger Your Ass"
	description = "Pleasure your own ass with your fingers."
	category = "Masturbation"
	usage = INTERACTION_SELF
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	user_required_parts = list("anus")
	message = list(
		"fingers their ass.",
		"slides their fingers into their own asshole.",
		"works a finger into their rear."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/champ_fingering.ogg')
	user_pleasure = list(3, 5)
	user_arousal = list(5, 7)

/datum/interaction/howling_extra/jack_off_self
	name = "Jack Off"
	description = "Stroke your own cock."
	category = "Masturbation"
	usage = INTERACTION_SELF
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	user_required_parts = list("penis")
	message = list(
		"jerks themself off.",
		"strokes their own cock.",
		"works their shaft with one hand."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_pleasure = list(4, 6)
	user_arousal = list(6, 8)

/datum/interaction/howling_extra/lick_pussy_self
	name = "Lick Yourself"
	description = "Pleasure your own pussy with your tongue."
	category = "Masturbation"
	usage = INTERACTION_SELF
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	user_required_parts = list("vagina")
	message = list(
		"licks their own pussy.",
		"pleasures themself with their tongue.",
		"goes down on themself."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bj1.ogg',
		'sound/lewd/sounds/bj5.ogg',
		'sound/lewd/sounds/bj9.ogg'
	)
	user_pleasure = list(4, 6)
	user_arousal = list(6, 8)

/datum/interaction/howling_extra/selfsuck
	name = "Selfsuck"
	description = "Suck yourself off."
	category = "Masturbation"
	usage = INTERACTION_SELF
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	user_required_parts = list("penis")
	message = list(
		"wraps their lips around their own cock.",
		"sucks their own cock eagerly.",
		"gives themself head."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bj2.ogg',
		'sound/lewd/sounds/bj6.ogg',
		'sound/lewd/sounds/bj10.ogg'
	)
	user_pleasure = list(4, 6)
	user_arousal = list(6, 8)

/datum/interaction/howling_extra/grope_breasts_self
	name = "Grope Yourself"
	description = "Massage your own breasts."
	category = "Masturbation"
	usage = INTERACTION_SELF
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	user_required_parts = list("breasts")
	message = list(
		"gropes their own breasts.",
		"squeezes their own chest.",
		"teases their own nipples with their fingers."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/squelch1.ogg')
	user_pleasure = list(1, 3)
	user_arousal = list(3, 5)

/datum/interaction/howling_extra/suck_nipples_self
	name = "Suck Your Nipples"
	description = "Bend down and suck at your own nipples."
	category = "Masturbation"
	usage = INTERACTION_SELF
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	user_required_parts = list("breasts")
	message = list(
		"sucks on their own nipples.",
		"bends down to lick and suck at their own chest.",
		"teases their own nipples with their tongue."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_pleasure = list(2, 4)
	user_arousal = list(4, 6)

/datum/interaction/howling_extra/lick_armpit
	name = "Lick Armpit"
	description = "Lick their armpit."
	category = "Armpits"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("armpits")
	message = list(
		"licks %TARGET%'s armpit.",
		"runs their tongue along %TARGET%'s underarm.",
		"plants their face in %TARGET%'s pit."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(2, 4)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/armpit_smother
	name = "Armpit Smother"
	description = "Press your armpit against their face."
	category = "Armpits"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list("armpits")
	message = list(
		"presses their armpit against %TARGET%'s face.",
		"smothers %TARGET%'s face with their pit.",
		"pins %TARGET%'s head under their arm."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg'
	)
	user_arousal = list(2, 4)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/armpit_fuck
	name = "Armpit Fuck"
	description = "Fuck their armpit."
	category = "Armpits"
	user_required_parts = list("penis", "armpits")
	target_required_parts = list("armpits")
	message = list(
		"slides their cock into %TARGET%'s underarm.",
		"thrusts into %TARGET%'s pit.",
		"fucks %TARGET%'s armpit."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_pleasure = list(2, 4)
	user_arousal = list(4, 6)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/pitjob
	name = "Give Pitjob"
	description = "Jerk them off with your armpit."
	category = "Armpits"
	user_required_parts = list("armpits")
	target_required_parts = list("penis")
	message = list(
		"works %TARGET%'s cock with their armpit.",
		"squeezes %TARGET%'s shaft between their arm and chest.",
		"jerks %TARGET% off with their pit."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_arousal = list(1, 3)
	target_pleasure = list(2, 4)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/caress_armpits
	name = "Caress Their Armpits"
	description = "Caress their armpits."
	category = "Armpits"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("armpits")
	message = list(
		"caresses %TARGET%'s armpits with slow fingers.",
		"lets their fingertips wander through %TARGET%'s underarms.",
		"softly pets %TARGET%'s armpits in teasing strokes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/rub_armpits
	name = "Rub Their Armpits"
	description = "Rub over their armpits."
	category = "Armpits"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("armpits")
	message = list(
		"rubs %TARGET%'s armpits with slow little motions.",
		"works their fingertips through %TARGET%'s underarms in teasing circles.",
		"slides their hand over %TARGET%'s armpits again and again."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/tickle_armpits
	name = "Tickle Their Armpits"
	description = "Tease their armpits with tickling fingers."
	category = "Armpits"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("armpits")
	message = list(
		"tickles %TARGET%'s armpits with playful fingers.",
		"lets teasing little touches dance through %TARGET%'s underarms.",
		"works light, maddening tickles over %TARGET%'s armpits."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/nuzzle_armpits
	name = "Nuzzle Their Armpits"
	description = "Nuzzle into their armpits."
	category = "Armpits"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("armpits")
	message = list(
		"nuzzles into %TARGET%'s armpit with a needy little sound.",
		"buries their face against %TARGET%'s underarm.",
		"presses close and nuzzles %TARGET%'s armpit shamelessly."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/kiss_armpits
	name = "Kiss Their Armpits"
	description = "Kiss their armpits."
	category = "Armpits"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("armpits")
	message = list(
		"presses little kisses into %TARGET%'s armpit.",
		"kisses slowly along %TARGET%'s underarm.",
		"teases %TARGET%'s armpit with warm, lingering kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/nibble_armpits
	name = "Nibble Their Armpits"
	description = "Nibble lightly at their armpits."
	category = "Armpits"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("armpits")
	message = list(
		"nibbles lightly at %TARGET%'s underarm.",
		"teases %TARGET%'s armpit with little bites and nips.",
		"works playful nibbles into the sensitive skin of %TARGET%'s armpit."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/lap_armpits
	name = "Lap At Their Armpits"
	description = "Lap lightly at their armpits."
	category = "Armpits"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("armpits")
	message = list(
		"laps lightly at %TARGET%'s armpit with the tip of their tongue.",
		"teases %TARGET%'s underarm with quick little licks.",
		"lets playful licks dance through %TARGET%'s armpit."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/breathe_on_armpits
	name = "Breathe Over Their Armpits"
	description = "Breathe warm air over their armpits."
	category = "Armpits"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("armpits")
	message = list(
		"breathes warm air into %TARGET%'s armpit.",
		"lets a slow, heated breath wash over %TARGET%'s underarm.",
		"teases %TARGET%'s armpit with the warmth of their breath."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/hold_arms_up
	name = "Hold Their Arms Up"
	description = "Hold their arms up to expose their armpits."
	category = "Armpits"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("armpits")
	message = list(
		"holds %TARGET%'s arms up and exposes their armpits.",
		"pins %TARGET%'s arms high enough to bare their underarms.",
		"guides %TARGET%'s arms up and leaves their armpits open."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/bellyfuck
	name = "Bellyfuck"
	description = "Rub your cock against their belly."
	category = "Sex"
	user_required_parts = list("penis")
	target_required_parts = list("belly")
	message = list(
		"rubs their cock against %TARGET%'s belly.",
		"grinds their cock on %TARGET%'s stomach.",
		"thrusts against %TARGET%'s belly."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_pleasure = list(2, 4)
	user_arousal = list(4, 6)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/nuzzle_belly
	name = "Nuzzle Belly"
	description = "Nuzzle their belly."
	category = "Foreplay"
	target_required_parts = list("belly")
	message = list(
		"nuzzles %TARGET%'s belly.",
		"rubs their face against %TARGET%'s stomach.",
		"snuggles against %TARGET%'s tummy."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/breast_smother
	name = "Breast Smother"
	description = "Smother them with your breasts."
	category = "Breasts"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list("breasts")
	message = list(
		"presses their breasts against %TARGET%'s face.",
		"smothers %TARGET%'s face with their tits.",
		"forces %TARGET%'s face between their breasts."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg',
		'sound/lewd/sounds/squelch3.ogg'
	)
	user_arousal = list(2, 4)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/breastfeed
	name = "Breastfeed"
	description = "Breastfeed them."
	category = "Breasts"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list("breasts")
	message = list(
		"presses their breasts to %TARGET%'s mouth and feeds them.",
		"lets %TARGET% nurse at their chest.",
		"guides %TARGET%'s mouth to their breast."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_pleasure = list(1, 3)
	user_arousal = list(2, 4)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/breastfeed/allow_act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!..())
		return FALSE
	return user.has_lactating_breasts(REQUIRE_GENITAL_EXPOSED)

/datum/interaction/howling_extra/boobjob
	name = "Give Boobjob"
	description = "Pleasure them with your breasts."
	category = "Breasts"
	user_required_parts = list("breasts")
	target_required_parts = list("penis")
	message = list(
		"wraps their breasts around %TARGET%'s cock.",
		"works %TARGET%'s shaft between their tits.",
		"pleasures %TARGET% with their breasts."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_arousal = list(3, 5)
	target_pleasure = list(3, 5)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/suck_nipples
	name = "Suck Nipples"
	description = "Suck their nipples."
	category = "Nipples"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("breasts")
	message = list(
		"gently sucks on %TARGET%'s nipple.",
		"licks %TARGET%'s nipple.",
		"teases %TARGET%'s nipple with their tongue."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(1, 3)
	target_pleasure = list(2, 4)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/rub_nipples
	name = "Rub Their Nipples"
	description = "Rub slow circles over their nipples."
	category = "Nipples"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("nipples")
	message = list(
		"rubs slow circles over %TARGET%'s nipples.",
		"works their fingertips over %TARGET%'s nipples in teasing motions.",
		"presses and rubs at %TARGET%'s nipples until they harden."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/squelch1.ogg', 'sound/lewd/sounds/squelch2.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/twist_nipples
	name = "Twist Their Nipples"
	description = "Twist their nipples with careful fingers."
	category = "Nipples"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("nipples")
	message = list(
		"twists %TARGET%'s nipples in slow, careful turns.",
		"rolls and twists %TARGET%'s nipples between finger and thumb.",
		"works teasing twists into %TARGET%'s nipples."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/squelch1.ogg', 'sound/lewd/sounds/squelch2.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/flick_nipples
	name = "Flick Their Nipples"
	description = "Snap teasing flicks across their nipples."
	category = "Nipples"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("nipples")
	message = list(
		"flicks %TARGET%'s nipples with a fingertip.",
		"teases %TARGET%'s nipples with quick flicks.",
		"snaps teasing touches across %TARGET%'s nipples."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/squelch1.ogg', 'sound/lewd/sounds/squelch2.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(0, 2)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/pull_nipples
	name = "Pull Their Nipples"
	description = "Catch and tug gently at their nipples."
	category = "Nipples"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("nipples")
	message = list(
		"catches %TARGET%'s nipples between their fingers and pulls gently.",
		"gives %TARGET%'s nipples a slow tug.",
		"draws %TARGET%'s nipples out between finger and thumb."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/squelch1.ogg', 'sound/lewd/sounds/squelch2.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/press_lips_to_nipples
	name = "Press Lips To Their Nipples"
	description = "Hold a warm kiss to their nipples."
	category = "Nipples"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("nipples")
	message = list(
		"presses their lips softly to %TARGET%'s nipples.",
		"holds a warm kiss against %TARGET%'s nipple.",
		"lingers with their lips over %TARGET%'s nipples."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/breathe_on_nipples
	name = "Breathe Over Their Nipples"
	description = "Breathe warm air over their nipples."
	category = "Nipples"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("nipples")
	message = list(
		"breathes warm air over %TARGET%'s nipples.",
		"lets a heated breath wash across %TARGET%'s nipples.",
		"teases %TARGET%'s nipples with the warmth of their breath."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/lap_nipples
	name = "Lap At Their Nipples"
	description = "Tease their nipples with light, playful licks."
	category = "Nipples"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("nipples")
	message = list(
		"laps lightly at %TARGET%'s nipples with the tip of their tongue.",
		"teases %TARGET%'s nipples with quick, playful licks.",
		"lets teasing licks dance across %TARGET%'s nipples."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/suckle_nipples
	name = "Suckle Their Nipples"
	description = "Draw their nipples into your mouth in slow pulls."
	category = "Nipples"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("nipples")
	message = list(
		"suckles slowly at %TARGET%'s nipples.",
		"draws %TARGET%'s nipple into their mouth with a lingering suck.",
		"works %TARGET%'s nipples with slow, needy pulls."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(2, 4)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/caress_breasts
	name = "Caress Their Breasts"
	description = "Let your hands wander over their breasts."
	category = "Breasts"
	user_required_parts = list("hands")
	target_required_any_parts = list("breasts")
	message = list(
		"caresses %TARGET%'s breasts with wandering hands.",
		"lets their palms glide over %TARGET%'s breasts.",
		"softly pets %TARGET%'s chest, savoring the shape of their breasts."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/massage_breasts
	name = "Massage Their Breasts"
	description = "Knead and massage their breasts."
	category = "Breasts"
	user_required_parts = list("hands")
	target_required_any_parts = list("breasts")
	message = list(
		"massages %TARGET%'s breasts in slow circles.",
		"kneads %TARGET%'s breasts with careful pressure.",
		"works their hands over %TARGET%'s breasts in a lingering massage."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg'
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/cup_breasts
	name = "Cup Their Breasts"
	description = "Cup their breasts in your hands."
	category = "Breasts"
	user_required_parts = list("hands")
	target_required_any_parts = list("breasts")
	message = list(
		"cups %TARGET%'s breasts in both hands.",
		"holds %TARGET%'s breasts with an appreciative squeeze.",
		"weighs %TARGET%'s breasts in their palms."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/squelch1.ogg', 'sound/lewd/sounds/squelch2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/rub_breasts
	name = "Rub Their Breasts"
	description = "Rub your hands over their breasts."
	category = "Breasts"
	user_required_parts = list("hands")
	target_required_any_parts = list("breasts")
	message = list(
		"rubs their hands over %TARGET%'s breasts.",
		"slides their palms across %TARGET%'s breasts in lingering passes.",
		"works teasing strokes over %TARGET%'s chest."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/squelch1.ogg', 'sound/lewd/sounds/squelch2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/trace_underbreast
	name = "Trace Their Underbreast"
	description = "Trace the soft curve beneath their breasts."
	category = "Breasts"
	user_required_parts = list("hands")
	target_required_parts = list("breasts")
	message = list(
		"traces a fingertip beneath %TARGET%'s breasts.",
		"lets their fingers skim along the underside of %TARGET%'s breasts.",
		"slowly outlines the curve beneath %TARGET%'s chest."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/squelch1.ogg', 'sound/lewd/sounds/squelch2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/kiss_breasts
	name = "Kiss Their Breasts"
	description = "Kiss their breasts."
	category = "Breasts"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("breasts")
	message = list(
		"kisses %TARGET%'s breasts in slow, lingering presses.",
		"covers %TARGET%'s chest with warm kisses.",
		"presses kiss after kiss over %TARGET%'s breasts."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/lick_breasts
	name = "Lick Their Breasts"
	description = "Taste your way over their breasts."
	category = "Breasts"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("breasts")
	message = list(
		"drags their tongue over %TARGET%'s breasts.",
		"licks warm trails across %TARGET%'s chest.",
		"tastes %TARGET%'s breasts with broad, wet licks."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/kiss_nipples
	name = "Kiss Their Nipples"
	description = "Kiss their nipples."
	category = "Breasts"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("breasts")
	message = list(
		"kisses %TARGET%'s nipples one after the other.",
		"presses warm kisses to %TARGET%'s nipples.",
		"teases %TARGET%'s nipples with soft kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/lick_nipples
	name = "Lick Their Nipples"
	description = "Lick their nipples."
	category = "Breasts"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("breasts")
	message = list(
		"circles %TARGET%'s nipple with their tongue.",
		"licks over %TARGET%'s nipples in slow strokes.",
		"teases %TARGET%'s nipples with the tip of their tongue."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/tease_nipples
	name = "Tease Their Nipples"
	description = "Toy with their nipples using your fingers."
	category = "Breasts"
	user_required_parts = list("hands")
	target_required_parts = list("breasts")
	message = list(
		"teases %TARGET%'s nipples with their fingertips.",
		"works teasing strokes over %TARGET%'s nipples.",
		"plays with %TARGET%'s nipples until they stiffen."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/squelch1.ogg', 'sound/lewd/sounds/squelch2.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/pinch_nipples
	name = "Pinch Their Nipples"
	description = "Pinch their nipples."
	category = "Breasts"
	user_required_parts = list("hands")
	target_required_parts = list("breasts")
	message = list(
		"pinches %TARGET%'s nipples between their fingers.",
		"gives %TARGET%'s nipples a sharp pinch.",
		"rolls a nipple between finger and thumb before pinching it."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/squelch1.ogg', 'sound/lewd/sounds/squelch2.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(0, 2)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/roll_nipples
	name = "Roll Their Nipples"
	description = "Roll their nipples between your fingers."
	category = "Breasts"
	user_required_parts = list("hands")
	target_required_parts = list("breasts")
	message = list(
		"rolls %TARGET%'s nipples between finger and thumb.",
		"works %TARGET%'s nipples in slow, deliberate motions.",
		"plays with %TARGET%'s nipples until they're nice and hard."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/squelch1.ogg', 'sound/lewd/sounds/squelch2.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/press_face_to_breasts
	name = "Press Face To Their Breasts"
	description = "Press your face against their breasts."
	category = "Breasts"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("breasts")
	message = list(
		"buries their face against %TARGET%'s breasts.",
		"presses their cheek between %TARGET%'s breasts.",
		"nuzzles into %TARGET%'s chest with a needy little sound."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/nipplefuck
	name = "Nipplefuck"
	description = "Rub your cock between their breasts and nipples."
	category = "Sex"
	user_required_parts = list("penis")
	target_required_parts = list("breasts")
	message = list(
		"grinds their cock between %TARGET%'s breasts.",
		"presses their shaft along %TARGET%'s nipples.",
		"fucks %TARGET%'s chest."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg'
	)
	user_pleasure = list(3, 5)
	user_arousal = list(6, 8)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/facefuck_vagina
	name = "Facefuck (Vagina)"
	description = "Grind your pussy against their face."
	category = "Oral"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list("vagina")
	message = list(
		"grinds their pussy into %TARGET%'s face.",
		"forces %TARGET% onto their pussy.",
		"slides %TARGET%'s mouth between their legs."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_pleasure = list(4, 6)
	user_arousal = list(7, 9)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/facefuck_penis
	name = "Facefuck (Penis)"
	description = "Fuck their mouth with your cock."
	category = "Oral"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list("penis")
	message = list(
		"roughly fucks %TARGET%'s mouth.",
		"forces their cock down %TARGET%'s throat.",
		"rolls their hips hard into %TARGET%'s mouth."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_pleasure = list(4, 6)
	user_arousal = list(7, 9)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/throatfuck
	name = "Throatfuck"
	description = "Fuck their throat."
	category = "Oral"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list("penis")
	message = list(
		"brutally shoves their cock into %TARGET%'s throat.",
		"chokes %TARGET% on their cock.",
		"slams in and out of %TARGET%'s mouth."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_pleasure = list(6, 8)
	user_arousal = list(9, 11)
	target_arousal = list(1, 3)
	target_pain = list(4, 6)

/datum/interaction/howling_extra/grind_face
	name = "Grind Face"
	description = "Press your feet against their face."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list("feet")
	message = list(
		"grinds their feet into %TARGET%'s face.",
		"presses their soles down on %TARGET%'s face.",
		"plants their feet atop %TARGET%'s face."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/foot_dry1.ogg',
		'sound/lewd/sounds/foot_dry2.ogg',
		'sound/lewd/sounds/foot_dry3.ogg',
		'sound/lewd/sounds/foot_dry4.ogg'
	)
	user_arousal = list(2, 4)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/grind_mouth
	name = "Grind Mouth"
	description = "Force your feet into their mouth."
	category = "Feet"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list("feet")
	message = list(
		"forces their feet into %TARGET%'s mouth.",
		"presses their soles deeper into %TARGET%'s mouth.",
		"shoves their feet past %TARGET%'s lips."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/foot_wet1.ogg',
		'sound/lewd/sounds/foot_wet2.ogg',
		'sound/lewd/sounds/foot_wet3.ogg'
	)
	user_arousal = list(2, 4)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/footjob
	name = "Footjob"
	description = "Jerk them off with your foot."
	category = "Feet"
	user_required_parts = list("feet")
	target_required_parts = list("penis")
	message = list(
		"jerks %TARGET% off with their foot.",
		"rubs their sole on %TARGET%'s shaft.",
		"works their foot up and down on %TARGET%'s cock."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/foot_dry1.ogg',
		'sound/lewd/sounds/foot_dry3.ogg',
		'sound/lewd/sounds/foot_wet1.ogg',
		'sound/lewd/sounds/foot_wet2.ogg'
	)
	target_pleasure = list(3, 5)
	user_arousal = list(2, 4)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/double_footjob
	name = "Double Footjob"
	description = "Jerk them off with both of your feet."
	category = "Feet"
	user_required_parts = list("feet")
	target_required_parts = list("penis")
	message = list(
		"rubs %TARGET%'s cock between their feet.",
		"works %TARGET%'s shaft with both feet.",
		"jerks %TARGET% off with their feet."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/foot_dry1.ogg',
		'sound/lewd/sounds/foot_dry3.ogg',
		'sound/lewd/sounds/foot_wet1.ogg',
		'sound/lewd/sounds/foot_wet2.ogg'
	)
	target_pleasure = list(4, 6)
	user_arousal = list(3, 5)
	target_arousal = list(6, 8)

/datum/interaction/howling_extra/vaginal_footjob
	name = "Vaginal Footjob"
	description = "Rub their pussy with your foot."
	category = "Feet"
	user_required_parts = list("feet")
	target_required_parts = list("vagina")
	message = list(
		"rubs %TARGET%'s clit with their foot.",
		"slides their sole over %TARGET%'s pussy.",
		"works their foot up and down on %TARGET%'s sex."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/foot_dry1.ogg',
		'sound/lewd/sounds/foot_wet1.ogg',
		'sound/lewd/sounds/foot_wet2.ogg'
	)
	user_arousal = list(3, 5)
	target_pleasure = list(3, 5)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/thigh_smother_penis
	name = "Cock Thigh Smother"
	description = "Smother them with your thighs and cock."
	category = "Thighs"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list("penis", "thighs")
	message = list(
		"forces their cock into %TARGET%'s face while pinning them between their thighs.",
		"smothers %TARGET%'s face between their thighs and cock.",
		"presses their weight down on %TARGET%'s face, their cock dragging across it."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bj10.ogg',
		'sound/lewd/sounds/bj3.ogg',
		'sound/lewd/sounds/foot_wet1.ogg',
		'sound/lewd/sounds/foot_dry3.ogg'
	)
	user_pleasure = list(3, 5)
	user_arousal = list(5, 7)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/thigh_smother_vagina
	name = "Sit On Their Face"
	description = "Ride their face with your thighs and pussy."
	category = "Vagina"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list("vagina", "thighs")
	message = list(
		"rides %TARGET%'s face, grinding their pussy all over it.",
		"smothers %TARGET%'s face between their thighs and pussy.",
		"presses their sex into %TARGET%'s face while pinning them with their thighs."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bj10.ogg',
		'sound/lewd/sounds/bj3.ogg',
		'sound/lewd/sounds/foot_wet1.ogg',
		'sound/lewd/sounds/foot_dry3.ogg'
	)
	user_pleasure = list(3, 5)
	user_arousal = list(5, 7)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/thighfuck
	name = "Thighfuck"
	description = "Fuck their thighs."
	category = "Thighs"
	user_required_parts = list("penis")
	target_required_parts = list("thighs")
	message = list(
		"slides their cock between %TARGET%'s thighs.",
		"thrusts between %TARGET%'s legs.",
		"fucks %TARGET%'s thighs."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_pleasure = list(3, 5)
	user_arousal = list(5, 7)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/thighjob
	name = "Thighjob"
	description = "Pleasure them with your thighs."
	category = "Thighs"
	user_required_parts = list("thighs")
	target_required_parts = list("penis")
	message = list(
		"squeezes %TARGET%'s cock between their thighs.",
		"works %TARGET%'s shaft with their legs.",
		"pleasures %TARGET% with their thighs."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_arousal = list(3, 5)
	target_pleasure = list(3, 5)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/thigh_caress
	name = "Caress Thighs"
	description = "Caress their thighs slowly."
	category = "Thighs"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("thighs")
	message = list(
		"caresses %TARGET%'s thighs with slow hands.",
		"lets their touch drift over %TARGET%'s thighs.",
		"gives %TARGET%'s thighs a lingering caress."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/thigh_stroke
	name = "Stroke Thighs"
	description = "Stroke their thighs."
	category = "Thighs"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("thighs")
	message = list(
		"strokes slowly along %TARGET%'s thighs.",
		"runs their hands over %TARGET%'s thighs in teasing passes.",
		"gives %TARGET%'s thighs a slow stroke."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/inner_thigh_tease
	name = "Tease Inner Thighs"
	description = "Tease their inner thighs."
	category = "Thighs"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("thighs")
	message = list(
		"teases the insides of %TARGET%'s thighs with slow fingers.",
		"lets their touch wander up %TARGET%'s inner thighs.",
		"works teasing touches along %TARGET%'s inner thighs."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/kiss_thighs
	name = "Kiss Their Thighs"
	description = "Kiss their thighs."
	category = "Thighs"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("thighs")
	message = list(
		"kisses %TARGET%'s thighs softly.",
		"presses slow kisses along %TARGET%'s thighs.",
		"trails warm kisses over %TARGET%'s thighs."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/lick_thighs
	name = "Lick Their Thighs"
	description = "Lick along their thighs."
	category = "Thighs"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("thighs")
	message = list(
		"drags their tongue slowly over %TARGET%'s thighs.",
		"licks teasing lines along %TARGET%'s thighs.",
		"teases %TARGET%'s thighs with warm licks."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/lick_inner_thighs
	name = "Lick Their Inner Thighs"
	description = "Lick their inner thighs."
	category = "Thighs"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("thighs")
	message = list(
		"licks slowly up %TARGET%'s inner thighs.",
		"drags their tongue teasingly along the inside of %TARGET%'s thighs.",
		"works warm licks over %TARGET%'s inner thighs."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/trace_inner_thighs
	name = "Trace Their Inner Thighs"
	description = "Trace your fingers over their inner thighs."
	category = "Thighs"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("thighs")
	message = list(
		"traces slow fingers over %TARGET%'s inner thighs.",
		"draws teasing lines along the inside of %TARGET%'s thighs.",
		"lets their fingertips wander over %TARGET%'s inner thighs."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/squeeze_thighs
	name = "Squeeze Their Thighs"
	description = "Squeeze their thighs."
	category = "Thighs"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("thighs")
	message = list(
		"squeezes %TARGET%'s thighs firmly.",
		"closes their hands around %TARGET%'s thighs in a slow squeeze.",
		"gives %TARGET%'s thighs a teasing squeeze."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/spread_thighs
	name = "Spread Their Thighs"
	description = "Guide their thighs apart."
	category = "Thighs"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("thighs")
	message = list(
		"guides %TARGET%'s thighs apart slowly.",
		"uses careful hands to part %TARGET%'s thighs.",
		"eases %TARGET%'s thighs open with a teasing touch."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/press_head_between_thighs
	name = "Press Their Head Between Thighs"
	description = "Trap their head between your thighs."
	category = "Thighs"
	target_required_parts = list("thighs")
	message = list(
		"traps %TARGET%'s head between their thighs.",
		"squeezes %TARGET%'s head between their thighs.",
		"presses their thighs tight around %TARGET%'s head."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/rub_thighs
	name = "Rub Their Thighs"
	description = "Rub against their thighs."
	category = "Thighs"
	target_required_any_parts = list("thighs")
	message = list(
		"rubs slowly against %TARGET%'s thighs.",
		"presses close and grinds teasingly against %TARGET%'s thighs.",
		"lets their body slide against %TARGET%'s thighs."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/breathe_on_thighs
	name = "Breathe Over Their Thighs"
	description = "Breathe warm air over their thighs."
	category = "Thighs"
	target_required_parts = list("thighs")
	message = list(
		"breathes warm air across %TARGET%'s thighs.",
		"lets their breath ghost over %TARGET%'s inner thighs.",
		"hovers close enough for %TARGET% to feel their breath on their thighs."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/nuzzle_thighs
	name = "Nuzzle Their Thighs"
	description = "Nuzzle into their thighs."
	category = "Thighs"
	target_required_parts = list("thighs")
	message = list(
		"nuzzles into %TARGET%'s thighs.",
		"presses in close and nuzzles %TARGET%'s thighs.",
		"buries their face against %TARGET%'s thighs in a slow nuzzle."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/frotting
	name = "Frotting"
	description = "Rub your cock against theirs."
	category = "Sex"
	user_required_parts = list("penis")
	target_required_parts = list("penis")
	message = list(
		"rubs their cock against %TARGET%'s.",
		"grinds their shaft against %TARGET%'s penis.",
		"frotts against %TARGET%'s cock."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg'
	)
	user_pleasure = list(5, 7)
	target_pleasure = list(5, 7)
	user_arousal = list(9, 11)
	target_arousal = list(9, 11)

/datum/interaction/howling_extra/tribadism
	name = "Scissor"
	description = "Scissor their pussy with yours."
	category = "Vagina"
	user_required_parts = list("vagina")
	target_required_parts = list("vagina")
	message = list(
		"grinds their pussy against %TARGET%'s.",
		"rubs their cunt against %TARGET%'s pussy.",
		"humps %TARGET%, their pussies grinding together."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg',
		'sound/lewd/sounds/squelch3.ogg'
	)
	user_pleasure = list(5, 7)
	target_pleasure = list(5, 7)
	user_arousal = list(9, 11)
	target_arousal = list(9, 11)

/datum/interaction/howling_extra/pussy_grind
	name = "Pussy Grind"
	description = "Grind your pussy slowly against theirs."
	category = "Vagina"
	user_required_parts = list("vagina")
	target_required_parts = list("vagina")
	message = list(
		"rolls their hips and grinds their pussy slowly against %TARGET%'s.",
		"presses their cunt to %TARGET%'s and rocks against them.",
		"works their pussy against %TARGET%'s in needy little motions."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg'
	)
	user_pleasure = list(4, 6)
	target_pleasure = list(4, 6)
	user_arousal = list(8, 10)
	target_arousal = list(8, 10)

/datum/interaction/howling_extra/scissor_ride
	name = "Scissor Ride"
	description = "Ride against their pussy in a hard scissoring grind."
	category = "Vagina"
	user_required_parts = list("vagina")
	target_required_parts = list("vagina")
	message = list(
		"rides against %TARGET%'s pussy in a hard, wet grind.",
		"locks up with %TARGET% and scissors against them harder.",
		"rocks their hips into %TARGET%'s cunt, grinding fast and desperate."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg',
		'sound/lewd/sounds/squelch3.ogg'
	)
	user_pleasure = list(6, 8)
	target_pleasure = list(6, 8)
	user_arousal = list(10, 12)
	target_arousal = list(10, 12)

/datum/interaction/howling_extra/double_dildo_scissor
	name = "Scissor With Double Dildo"
	description = "Use a double dildo to keep both pussies filled while you scissor together."
	category = "Vagina"
	user_required_parts = list("vagina")
	target_required_parts = list("vagina")
	user_required_item_paths = list(/obj/item/clothing/sextoy/dildo/double_dildo)
	message = list(
		"guides %ITEM% between both pussies and scissors against %TARGET% with it.",
		"works one end of %ITEM% into %TARGET% and the other against themself as they grind together.",
		"uses %ITEM% to keep both sexes filled while scissoring against %TARGET%."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg',
		'sound/lewd/sounds/squelch3.ogg'
	)
	user_pleasure = list(6, 8)
	target_pleasure = list(6, 8)
	user_arousal = list(10, 12)
	target_arousal = list(10, 12)

/datum/interaction/howling_extra/double_dildo_scissor_ride
	name = "Ride Double Dildo In Scissors"
	description = "Ride harder in scissors while the double dildo keeps both of you filled."
	category = "Vagina"
	user_required_parts = list("vagina")
	target_required_parts = list("vagina")
	user_required_item_paths = list(/obj/item/clothing/sextoy/dildo/double_dildo)
	message = list(
		"rides %ITEM% between them and %TARGET% in a desperate scissoring grind.",
		"locks up with %TARGET% and rides %ITEM% harder between both pussies.",
		"grinds fast against %TARGET%, using %ITEM% to thrust into both of them at once."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg',
		'sound/lewd/sounds/squelch3.ogg'
	)
	user_pleasure = list(7, 9)
	target_pleasure = list(7, 9)
	user_arousal = list(11, 13)
	target_arousal = list(11, 13)

/datum/interaction/howling_extra/fuck
	name = "Fuck"
	description = "Fuck their pussy."
	category = "Sex"
	user_required_parts = list("penis")
	target_required_parts = list("vagina")
	message = list(
		"pounds %TARGET%'s pussy.",
		"shoves their cock deep into %TARGET%'s pussy.",
		"goes balls deep into %TARGET%'s sex."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/champ1.ogg',
		'sound/lewd/sounds/champ2.ogg'
	)
	user_pleasure = list(7, 9)
	target_pleasure = list(7, 9)
	user_arousal = list(11, 13)
	target_arousal = list(11, 13)

/datum/interaction/howling_extra/anal_fuck
	name = "Anal Fuck"
	description = "Fuck their ass."
	category = "Sex"
	user_required_parts = list("penis")
	target_required_parts = list("anus")
	message = list(
		"thrusts in and out of %TARGET%'s ass.",
		"pounds %TARGET%'s ass.",
		"goes deep into %TARGET%'s rear."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_pleasure = list(7, 9)
	target_pleasure = list(3, 5)
	user_arousal = list(11, 13)
	target_arousal = list(7, 9)
	target_pain = list(2, 4)

/datum/interaction/howling_extra/breast_fuck
	name = "Breast Fuck"
	description = "Fuck their breasts."
	category = "Sex"
	user_required_parts = list("penis")
	target_required_parts = list("breasts")
	message = list(
		"grinds their cock between %TARGET%'s breasts.",
		"thrusts into %TARGET%'s tits.",
		"presses their cock between %TARGET%'s breasts."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_pleasure = list(3, 5)
	user_arousal = list(7, 9)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/foot_fuck
	name = "Foot Fuck"
	description = "Rub your cock on their foot."
	category = "Feet"
	user_required_parts = list("penis")
	target_required_parts = list("feet")
	message = list(
		"fucks %TARGET%'s foot.",
		"rubs their cock on %TARGET%'s foot.",
		"grinds their cock on %TARGET%'s sole."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/foot_dry1.ogg',
		'sound/lewd/sounds/foot_dry3.ogg',
		'sound/lewd/sounds/foot_wet1.ogg',
		'sound/lewd/sounds/foot_wet2.ogg'
	)
	user_pleasure = list(2, 4)
	user_arousal = list(5, 7)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/double_foot_fuck
	name = "Double Foot Fuck"
	description = "Rub your cock between their feet."
	category = "Feet"
	user_required_parts = list("penis")
	target_required_parts = list("feet")
	message = list(
		"rubs their cock between %TARGET%'s feet.",
		"thrusts between %TARGET%'s soles.",
		"grinds their cock between %TARGET%'s feet."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/foot_dry1.ogg',
		'sound/lewd/sounds/foot_dry3.ogg',
		'sound/lewd/sounds/foot_wet1.ogg',
		'sound/lewd/sounds/foot_wet2.ogg'
	)
	user_pleasure = list(3, 5)
	user_arousal = list(6, 8)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/vaginal_foot_grind
	name = "Vaginal Foot Grind"
	description = "Rub your pussy on their foot."
	category = "Feet"
	user_required_parts = list("vagina")
	target_required_parts = list("feet")
	message = list(
		"grinds their pussy against %TARGET%'s foot.",
		"rubs their clit on %TARGET%'s sole.",
		"ruts on %TARGET%'s foot."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/foot_dry1.ogg',
		'sound/lewd/sounds/foot_wet1.ogg',
		'sound/lewd/sounds/foot_wet2.ogg'
	)
	user_pleasure = list(4, 6)
	user_arousal = list(7, 9)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/mount_vagina
	name = "Mount (Vagina)"
	description = "Mount them with your pussy."
	category = "Sex"
	user_required_parts = list("vagina")
	target_required_parts = list("penis")
	message = list(
		"rides %TARGET%'s cock.",
		"slides their pussy onto %TARGET%'s cock.",
		"impales themself on %TARGET%'s cock."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_pleasure = list(6, 8)
	target_pleasure = list(6, 8)
	user_arousal = list(9, 11)
	target_arousal = list(9, 11)

/datum/interaction/howling_extra/mount_anus
	name = "Mount (Anus)"
	description = "Mount them with your ass."
	category = "Sex"
	user_required_parts = list("anus")
	target_required_parts = list("penis")
	message = list(
		"rides %TARGET%'s cock with their ass.",
		"slides their ass onto %TARGET%'s cock.",
		"impales their rear on %TARGET%'s cock."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_pleasure = list(3, 5)
	target_pleasure = list(6, 8)
	user_arousal = list(7, 9)
	target_arousal = list(9, 11)
	user_pain = list(2, 4)

/datum/interaction/howling_extra/mount_face
	name = "Mount Face"
	description = "Sit on their face."
	category = "Oral"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list("anus")
	message = list(
		"grinds their ass into %TARGET%'s face.",
		"plants their ass right on %TARGET%'s face.",
		"forces %TARGET%'s face into their asscheeks."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg',
		'sound/lewd/sounds/squelch3.ogg'
	)
	user_pleasure = list(2, 4)
	user_arousal = list(4, 6)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/nuts_to_face
	name = "Nuts to Face"
	description = "Put your balls in their face."
	category = "Foreplay"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list("balls")
	message = list(
		"jams their nutsack into %TARGET%'s face.",
		"smothers %TARGET%'s face with their balls.",
		"pulls %TARGET% into their heavy sack."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_pleasure = list(2, 4)
	user_arousal = list(4, 6)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/smack_nuts
	name = "Smack Nuts"
	description = "Smack their nuts."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("balls")
	message = list(
		"smacks %TARGET%'s nuts.",
		"slaps %TARGET%'s balls.",
		"whacks %TARGET% right in the nuts."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/slap.ogg')
	target_pain = list(14, 16)
	user_arousal = list(1, 3)

/datum/interaction/howling_extra/lick_sweat
	name = "Lick Sweat"
	description = "Lick their sweat."
	category = "Oral"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	message = list(
		"licks the sweat off %TARGET%'s skin.",
		"tastes %TARGET%'s salty sweat.",
		"runs their tongue along %TARGET%'s sweaty body."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(2, 4)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/lick_balls
	name = "Lick Balls"
	description = "Lick their balls."
	category = "Oral"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("balls")
	message = list(
		"licks %TARGET%'s balls.",
		"sucks on %TARGET%'s testicles.",
		"worships %TARGET%'s balls with their tongue."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bj1.ogg',
		'sound/lewd/sounds/bj2.ogg',
		'sound/lewd/sounds/bj3.ogg',
		'sound/lewd/sounds/bj4.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(2, 4)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/caress_balls
	name = "Caress Their Balls"
	description = "Caress their balls."
	category = "Balls"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("balls")
	message = list(
		"caresses %TARGET%'s balls with gentle fingers.",
		"lets their hand drift beneath %TARGET%'s sack in a soft hold.",
		"pets %TARGET%'s balls with slow, careful touches."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/bang1.ogg', 'sound/lewd/sounds/bang2.ogg', 'sound/lewd/sounds/bang3.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/cradle_balls
	name = "Cradle Their Balls"
	description = "Cradle their balls in your hand."
	category = "Balls"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("balls")
	message = list(
		"cradles %TARGET%'s balls in one hand.",
		"cups %TARGET%'s sack carefully in their palm.",
		"supports %TARGET%'s balls with a warm, lingering hold."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/bang1.ogg', 'sound/lewd/sounds/bang2.ogg', 'sound/lewd/sounds/bang3.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/weigh_balls
	name = "Weigh Their Balls"
	description = "Weigh their balls in your hand."
	category = "Balls"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("balls")
	message = list(
		"weighs %TARGET%'s balls in their palm.",
		"lets %TARGET%'s sack rest in their hand and gives it an appreciative heft.",
		"slowly bounces %TARGET%'s balls in their palm to feel their weight."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/bang1.ogg', 'sound/lewd/sounds/bang2.ogg', 'sound/lewd/sounds/bang3.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/massage_balls
	name = "Massage Their Balls"
	description = "Massage their balls."
	category = "Balls"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("balls")
	message = list(
		"massages %TARGET%'s balls in slow circles.",
		"rolls %TARGET%'s balls gently in their hand.",
		"works a careful massage into %TARGET%'s sack."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/bang1.ogg', 'sound/lewd/sounds/bang2.ogg', 'sound/lewd/sounds/bang3.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/rub_balls
	name = "Rub Their Balls"
	description = "Rub over their balls."
	category = "Balls"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("balls")
	message = list(
		"rubs %TARGET%'s balls in slow, teasing strokes.",
		"works their fingers over %TARGET%'s sack with gentle pressure.",
		"lets their palm slide over %TARGET%'s balls again and again."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/bang1.ogg', 'sound/lewd/sounds/bang2.ogg', 'sound/lewd/sounds/bang3.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/tease_balls
	name = "Tease Their Balls"
	description = "Tease their balls with your fingers."
	category = "Balls"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("balls")
	message = list(
		"teases %TARGET%'s balls with playful little touches.",
		"flicks and pets at %TARGET%'s sack just enough to make them twitch.",
		"lets their fingertips dance teasingly over %TARGET%'s balls."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/bang1.ogg', 'sound/lewd/sounds/bang2.ogg', 'sound/lewd/sounds/bang3.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/squeeze_balls
	name = "Squeeze Their Balls"
	description = "Squeeze their balls carefully."
	category = "Balls"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("balls")
	message = list(
		"gives %TARGET%'s balls a slow, careful squeeze.",
		"wraps their hand around %TARGET%'s sack and squeezes gently.",
		"tests %TARGET%'s balls with a firm but measured grip."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/bang1.ogg', 'sound/lewd/sounds/bang2.ogg', 'sound/lewd/sounds/bang3.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(0, 2)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/kiss_balls
	name = "Kiss Their Balls"
	description = "Kiss their balls."
	category = "Balls"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("balls")
	message = list(
		"presses soft kisses to %TARGET%'s balls.",
		"kisses along %TARGET%'s sack in lingering little presses.",
		"teases %TARGET%'s balls with warm kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/suck_balls
	name = "Suck Their Balls"
	description = "Suck gently on their balls."
	category = "Balls"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("balls")
	message = list(
		"takes %TARGET%'s balls into their mouth in a soft suck.",
		"suckles %TARGET%'s sack in slow, teasing pulls.",
		"wraps their lips around one of %TARGET%'s balls and sucks gently."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bj1.ogg',
		'sound/lewd/sounds/bj2.ogg',
		'sound/lewd/sounds/bj3.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/slap_ass
	name = "Slap Ass"
	description = "Slap their ass."
	category = "Hands"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_any_parts = list("butt")
	message = list(
		"slaps %TARGET% right on the ass.",
		"spanks %TARGET%'s ass.",
		"lands a stinging slap on %TARGET%'s butt."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/slap.ogg')
	target_pain = list(9, 11)
	user_arousal = list(1, 3)

/datum/interaction/howling_extra/tail_jerk_cock
	name = "Tail. Jerk Cock"
	description = "Use your tail to jerk them off."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("penis")
	message = list(
		"coils their tail around %TARGET%'s cock.",
		"works %TARGET%'s shaft with their tail.",
		"jerks %TARGET% off with their tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg'
	)
	target_pleasure = list(3, 5)
	user_arousal = list(2, 4)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/tail_penetrate_pussy
	name = "Tail. Penetrate Pussy"
	description = "Use your tail to penetrate their pussy."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("vagina")
	message = list(
		"slides their tail into %TARGET%'s pussy.",
		"thrusts their tail into %TARGET%'s sex.",
		"penetrates %TARGET%'s pussy with their tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/champ_fingering.ogg',
		'sound/lewd/sounds/squelch1.ogg'
	)
	target_pleasure = list(4, 6)
	user_arousal = list(3, 5)
	target_arousal = list(6, 8)

/datum/interaction/howling_extra/tail_rub_pussy
	name = "Tail. Rub Pussy"
	description = "Rub their pussy with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("vagina")
	message = list(
		"rubs their tail over %TARGET%'s pussy.",
		"teases %TARGET%'s clit with their tail.",
		"slides their tail along %TARGET%'s sex."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg'
	)
	target_pleasure = list(3, 5)
	user_arousal = list(2, 4)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/tail_penetrate_ass
	name = "Tail. Penetrate Ass"
	description = "Use your tail to penetrate their ass."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("anus")
	message = list(
		"slides their tail into %TARGET%'s ass.",
		"thrusts their tail into %TARGET%'s rear.",
		"penetrates %TARGET%'s ass with their tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/champ_fingering.ogg',
		'sound/lewd/sounds/squelch1.ogg'
	)
	target_pleasure = list(3, 5)
	user_arousal = list(3, 5)
	target_arousal = list(5, 7)
	target_pain = list(1, 3)

/datum/interaction/howling_extra/tail_slide_between_cheeks
	name = "Tail. Slide Between Cheeks"
	description = "Slide your tail between their cheeks."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("butt")
	message = list(
		"slides their tail between %TARGET%'s cheeks.",
		"teases %TARGET%'s ass with their tail.",
		"drags their tail along %TARGET%'s rear."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/slap.ogg',
		'sound/lewd/sounds/squelch1.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/tail_slide_between_breasts
	name = "Tail. Slide Between Breasts"
	description = "Slide your tail between their breasts."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("breasts")
	message = list(
		"slides their tail between %TARGET%'s breasts.",
		"teases %TARGET%'s chest with their tail.",
		"winds their tail through %TARGET%'s cleavage."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg'
	)
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/tail_wrap_waist
	name = "Tail. Wrap Waist"
	description = "Wrap your tail around their waist and pull them closer."
	category = "Tail"
	user_required_parts = list("tail")
	message = list(
		"wraps their tail around %TARGET%'s waist and draws them in.",
		"coils their tail snugly around %TARGET%'s middle.",
		"uses their tail to pull %TARGET% closer."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_pin_hands
	name = "Tail. Pin Hands"
	description = "Use your tail to pin their hands."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("hands")
	message = list(
		"pins %TARGET%'s hands in place with their tail.",
		"coils their tail around %TARGET%'s wrists to hold them still.",
		"uses their tail to restrain %TARGET%'s hands."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_stroke_inner_thighs
	name = "Tail. Stroke Inner Thighs"
	description = "Stroke their inner thighs with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("thighs")
	message = list(
		"slides their tail along %TARGET%'s inner thighs.",
		"teases the insides of %TARGET%'s thighs with their tail.",
		"drags their tail slowly between %TARGET%'s legs."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg'
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/tail_tease_breasts
	name = "Tail. Tease Breasts"
	description = "Tease their breasts with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("breasts")
	message = list(
		"teases %TARGET%'s breasts with their tail.",
		"brushes their tail over %TARGET%'s nipples.",
		"coaxes shivers from %TARGET%'s chest with their tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg'
	)
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/tail_hook_chin
	name = "Tail. Lift Chin"
	description = "Lift their chin with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	message = list(
		"hooks %TARGET%'s chin with their tail and tips their head up.",
		"uses their tail to lift %TARGET%'s chin.",
		"tilts %TARGET%'s face up with a gentle curl of their tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/tail_brush_face
	name = "Tail. Brush Face"
	description = "Brush their face with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	message = list(
		"brushes their tail over %TARGET%'s face.",
		"traces %TARGET%'s cheek and lips with their tail.",
		"lets the tip of their tail drift over %TARGET%'s face."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_brush_snout
	name = "Tail. Brush Snout"
	description = "Brush their snout with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("snout")
	message = list(
		"brushes their tail over %TARGET%'s snout.",
		"teases %TARGET%'s snout with the tip of their tail.",
		"traces %TARGET%'s muzzle with their tail."
	)

	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
/datum/interaction/howling_extra/caress_snout
	name = "Caress Their Snout"
	description = "Caress their snout."
	category = "Snout"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("snout")
	message = list(
		"caresses %TARGET%'s snout with gentle fingers.",
		"pets slowly over %TARGET%'s muzzle.",
		"lets their hand drift over %TARGET%'s snout in soft strokes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/cup_snout
	name = "Cup Their Snout"
	description = "Cup their snout in your hand."
	category = "Snout"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("snout")
	message = list(
		"cups %TARGET%'s snout in one hand.",
		"cradles %TARGET%'s muzzle with a warm palm.",
		"holds %TARGET%'s snout gently and strokes it with their thumb."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/trace_snout
	name = "Trace Their Snout"
	description = "Trace along their snout."
	category = "Snout"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("snout")
	message = list(
		"traces a fingertip along %TARGET%'s snout.",
		"outlines %TARGET%'s muzzle in a slow pass.",
		"lets their fingers drift over the shape of %TARGET%'s snout."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/boop_snout
	name = "Boop Their Snout"
	description = "Give their snout a teasing boop."
	category = "Snout"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("snout")
	message = list(
		"gives %TARGET%'s snout a teasing little boop.",
		"taps the tip of %TARGET%'s nose with one finger.",
		"boops %TARGET%'s snout and grins."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/kiss_snout
	name = "Kiss Their Snout"
	description = "Kiss their snout."
	category = "Snout"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("snout")
	message = list(
		"presses soft kisses to %TARGET%'s snout.",
		"kisses along %TARGET%'s muzzle in lingering little presses.",
		"teases %TARGET%'s snout with warm kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/kiss_nose
	name = "Kiss Their Nose"
	description = "Kiss their nose."
	category = "Snout"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("snout")
	message = list(
		"kisses the tip of %TARGET%'s nose.",
		"presses a sweet little kiss to %TARGET%'s nose.",
		"teases %TARGET%'s nose with a tiny, affectionate kiss."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/lick_snout
	name = "Lick Their Snout"
	description = "Lick over their snout."
	category = "Snout"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("snout")
	message = list(
		"drags their tongue over %TARGET%'s snout.",
		"licks a slow, wet line along %TARGET%'s muzzle.",
		"teases %TARGET%'s snout with broad little licks."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/lick_nose
	name = "Lick Their Nose"
	description = "Lick the tip of their nose."
	category = "Snout"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("snout")
	message = list(
		"flicks their tongue over %TARGET%'s nose.",
		"gives the tip of %TARGET%'s nose a playful lick.",
		"teases %TARGET%'s nose with a quick, warm lick."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/nuzzle_snout
	name = "Nuzzle Their Snout"
	description = "Nuzzle your face against their snout."
	category = "Snout"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("snout")
	message = list(
		"nuzzles their face against %TARGET%'s snout.",
		"presses close and rubs against %TARGET%'s muzzle.",
		"bumps their face softly against %TARGET%'s snout in a needy nuzzle."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/nibble_snout
	name = "Nibble Their Snout"
	description = "Nibble lightly at their snout."
	category = "Snout"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("snout")
	message = list(
		"nibbles lightly at %TARGET%'s snout.",
		"catches %TARGET%'s muzzle in teasing little nips.",
		"works playful little nibbles along %TARGET%'s snout."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/lick_lips_of_snout
	name = "Lick Their Muzzle Lips"
	description = "Lick along their muzzle lips."
	category = "Snout"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("snout")
	message = list(
		"licks slowly along %TARGET%'s muzzle lips.",
		"teases the edge of %TARGET%'s mouth with their tongue.",
		"drags their tongue across %TARGET%'s muzzle in a lingering pass."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(4, 6)
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_coil_leg
	name = "Tail. Coil Leg"
	description = "Coil your tail around their leg."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("thighs")
	message = list(
		"coils their tail around %TARGET%'s leg.",
		"wraps their tail around %TARGET%'s thigh.",
		"winds their tail around %TARGET%'s leg in a slow tease."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_tease_lips
	name = "Tail. Tease Lips"
	description = "Tease their lips with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	message = list(
		"teases %TARGET%'s lips with the tip of their tail.",
		"drags their tail lightly across %TARGET%'s mouth.",
		"brushes %TARGET%'s lips with their tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_press_into_mouth
	name = "Tail. Press Into Mouth"
	description = "Press your tail into their mouth."
	category = "Tail"
	user_required_parts = list("tail")
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	message = list(
		"presses the tip of their tail into %TARGET%'s mouth.",
		"coaxes %TARGET%'s lips around their tail.",
		"feeds the tip of their tail past %TARGET%'s lips."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_arousal = list(1, 3)
	target_pleasure = list(0, 2)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/tail_trace_ears
	name = "Tail. Trace Ears"
	description = "Trace their ears with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("ears")
	message = list(
		"traces their tail around %TARGET%'s ears.",
		"lets the tip of their tail tease %TARGET%'s ears.",
		"brushes %TARGET%'s ears with their tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg', 'sound/lewd/sounds/oral2.ogg')
	user_arousal = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_slap_ass
	name = "Tail. Slap Ass"
	description = "Slap their ass with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_any_parts = list("butt")
	message = list(
		"smacks %TARGET%'s ass with their tail.",
		"lands a sharp tail-slap on %TARGET%'s butt.",
		"swats %TARGET%'s rear with their tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/slap.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)
	target_pain = list(1, 3)

/datum/interaction/howling_extra/tail_caress_ass
	name = "Tail. Caress Ass"
	description = "Caress their ass with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_any_parts = list("butt")
	message = list(
		"caresses %TARGET%'s ass with their tail.",
		"strokes %TARGET%'s rear with a slow sweep of their tail.",
		"rubs their tail over %TARGET%'s butt."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/effects/emotes/assslap.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(0, 2)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_flick_nipples
	name = "Tail. Flick Nipples"
	description = "Flick their nipples with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("breasts")
	message = list(
		"flicks %TARGET%'s nipples with the tip of their tail.",
		"teases %TARGET%'s nipples with playful tail flicks.",
		"draws their tail over %TARGET%'s nipples in sharp little strokes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/squelch1.ogg', 'sound/lewd/sounds/squelch2.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/tail_circle_clit
	name = "Tail. Circle Clit"
	description = "Circle their clit with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("vagina")
	message = list(
		"circles %TARGET%'s clit with the tip of their tail.",
		"teases %TARGET%'s clit in slow tail-drawn circles.",
		"uses the tip of their tail to work over %TARGET%'s clit."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg'
	)
	user_arousal = list(2, 4)
	target_pleasure = list(3, 5)
	target_arousal = list(5, 7)

/datum/interaction/howling_extra/tail_trace_neck
	name = "Tail. Trace Neck"
	description = "Trace their neck with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("neck")
	message = list(
		"traces %TARGET%'s neck with the tip of their tail.",
		"lets their tail drift along %TARGET%'s throat.",
		"draws a slow line over %TARGET%'s neck with their tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_wrap_torso
	name = "Tail. Wrap Torso"
	description = "Wrap your tail around their torso."
	category = "Tail"
	user_required_parts = list("tail")
	message = list(
		"winds their tail around %TARGET%'s torso and holds them close.",
		"coils their tail around %TARGET%'s body in a snug embrace.",
		"uses their tail to bind %TARGET% close against them."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/tail_tease_belly
	name = "Tail. Tease Belly"
	description = "Tease their belly with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("belly")
	message = list(
		"teases %TARGET%'s belly with a slow sweep of their tail.",
		"drags their tail over %TARGET%'s stomach in a playful trace.",
		"lets the tip of their tail circle over %TARGET%'s belly."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_stroke_armpits
	name = "Tail. Stroke Armpits"
	description = "Stroke their armpits with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("armpits")
	message = list(
		"slides their tail teasingly through %TARGET%'s armpits.",
		"brushes the tip of their tail along %TARGET%'s underarms.",
		"works their tail into %TARGET%'s armpits in a slow tease."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/caress_wings
	name = "Caress Their Wings"
	description = "Caress their wings."
	category = "Wings"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("wings")
	message = list(
		"caresses %TARGET%'s wings with gentle hands.",
		"lets their hands drift over %TARGET%'s wings in slow strokes.",
		"softly pets along %TARGET%'s wings."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/stroke_wings
	name = "Stroke Their Wings"
	description = "Stroke along their wings."
	category = "Wings"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("wings")
	message = list(
		"strokes slowly along %TARGET%'s wings.",
		"runs their hands down the length of %TARGET%'s wings.",
		"teases %TARGET%'s wings with slow, careful strokes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/preen_wings
	name = "Preen Their Wings"
	description = "Preen and fuss over their wings."
	category = "Wings"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("wings")
	message = list(
		"preens %TARGET%'s wings with patient fingers.",
		"fusses lovingly over %TARGET%'s wings and smooths them out.",
		"works over %TARGET%'s wings with a careful preening touch."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_pleasure = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/kiss_wings
	name = "Kiss Their Wings"
	description = "Kiss their wings."
	category = "Wings"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("wings")
	message = list(
		"presses warm kisses to %TARGET%'s wings.",
		"kisses slowly along %TARGET%'s feathers.",
		"teases %TARGET%'s wings with soft little kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/nuzzle_wings
	name = "Nuzzle Their Wings"
	description = "Nuzzle into their wings."
	category = "Wings"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("wings")
	message = list(
		"nuzzles against %TARGET%'s wings with shameless affection.",
		"buries their face into %TARGET%'s wings for a needy nuzzle.",
		"presses close and rubs into %TARGET%'s wings."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/pet_fluff
	name = "Pet Their Fluff"
	description = "Pet their fluff."
	category = "Fluff"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("fluff")
	message = list(
		"pets %TARGET%'s fluff with slow, fond strokes.",
		"runs their hand through %TARGET%'s fluffy fur.",
		"buries their fingers in %TARGET%'s fluff and pets them."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/scritch_fluff
	name = "Scritch Their Fluff"
	description = "Scritch at their fluff."
	category = "Fluff"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("fluff")
	message = list(
		"scritches at %TARGET%'s fluff in teasing little motions.",
		"works their fingers through %TARGET%'s fluff in a satisfying scritch.",
		"gives %TARGET%'s fluff a playful, needy scritch."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/nuzzle_fluff
	name = "Nuzzle Their Fluff"
	description = "Nuzzle into their fluff."
	category = "Fluff"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("fluff")
	message = list(
		"nuzzles deep into %TARGET%'s fluff.",
		"buries their face against %TARGET%'s soft fluff.",
		"rubs their cheek into %TARGET%'s fluff with a needy little sound."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/kiss_fluff
	name = "Kiss Their Fluff"
	description = "Kiss into their fluff."
	category = "Fluff"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("fluff")
	message = list(
		"presses little kisses into %TARGET%'s fluff.",
		"kisses through %TARGET%'s soft fluff in lingering passes.",
		"teases %TARGET%'s fluff with warm, hidden kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/trace_horns
	name = "Trace Their Horns"
	description = "Trace along their horns."
	category = "Horns"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("horns")
	message = list(
		"traces a fingertip along %TARGET%'s horns.",
		"lets their hand wander over the curve of %TARGET%'s horns.",
		"follows the shape of %TARGET%'s horns in a slow pass."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/hold_horns
	name = "Hold Their Horns"
	description = "Take hold of their horns."
	category = "Horns"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("horns")
	message = list(
		"takes hold of %TARGET%'s horns in a slow, possessive grip.",
		"wraps their hand around %TARGET%'s horns and keeps them there.",
		"uses %TARGET%'s horns to hold their attention."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/kiss_horns
	name = "Kiss Their Horns"
	description = "Kiss along their horns."
	category = "Horns"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("horns")
	message = list(
		"kisses along the base of %TARGET%'s horns.",
		"presses little kisses to %TARGET%'s horns.",
		"teases %TARGET%'s horns with warm, lingering kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/lick_horns
	name = "Lick Their Horns"
	description = "Lick along their horns."
	category = "Horns"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("horns")
	message = list(
		"drags their tongue along %TARGET%'s horns.",
		"licks teasingly at the base of %TARGET%'s horns.",
		"lets their tongue trace %TARGET%'s horns in slow passes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/stroke_frills
	name = "Stroke Their Frills"
	description = "Stroke their frills."
	category = "Frills"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("frills")
	message = list(
		"strokes slowly through %TARGET%'s frills.",
		"runs careful fingers over %TARGET%'s frills.",
		"teases %TARGET%'s frills with a slow, attentive stroke."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/scritch_frills
	name = "Scritch Their Frills"
	description = "Scritch at their frills."
	category = "Frills"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("frills")
	message = list(
		"scritches lightly through %TARGET%'s frills.",
		"works teasing fingers into %TARGET%'s frills.",
		"gives %TARGET%'s frills a playful, satisfying scritch."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/kiss_frills
	name = "Kiss Their Frills"
	description = "Kiss their frills."
	category = "Frills"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("frills")
	message = list(
		"presses warm kisses to %TARGET%'s frills.",
		"kisses along %TARGET%'s frills in slow passes.",
		"teases %TARGET%'s frills with little, patient kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/lap_frills
	name = "Lap At Their Frills"
	description = "Lap lightly at their frills."
	category = "Frills"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("frills")
	message = list(
		"laps lightly at %TARGET%'s frills with the tip of their tongue.",
		"teases %TARGET%'s frills with playful little licks.",
		"lets quick licks dance over %TARGET%'s frills."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/stroke_antennae
	name = "Stroke Their Antennae"
	description = "Stroke their antennae."
	category = "Antennae"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("moth_antennae")
	message = list(
		"strokes %TARGET%'s antennae with careful fingers.",
		"lets their fingers glide along %TARGET%'s antennae.",
		"teases %TARGET%'s antennae with slow, attentive strokes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/trace_antennae
	name = "Trace Their Antennae"
	description = "Trace along their antennae."
	category = "Antennae"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("moth_antennae")
	message = list(
		"traces a fingertip along %TARGET%'s antennae.",
		"outlines %TARGET%'s antennae in a delicate pass.",
		"follows the line of %TARGET%'s antennae with a teasing touch."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/kiss_antennae
	name = "Kiss Their Antennae"
	description = "Kiss their antennae."
	category = "Antennae"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("moth_antennae")
	message = list(
		"presses little kisses to %TARGET%'s antennae.",
		"kisses along %TARGET%'s twitching antennae.",
		"teases %TARGET%'s antennae with warm little kisses."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/lap_antennae
	name = "Lap At Their Antennae"
	description = "Lap lightly at their antennae."
	category = "Antennae"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("moth_antennae")
	message = list(
		"laps lightly at %TARGET%'s antennae with the tip of their tongue.",
		"teases %TARGET%'s antennae with quick, warm licks.",
		"lets little licks dance across %TARGET%'s antennae."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/oral1.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(4, 6)

/datum/interaction/howling_extra/stroke_synth_antenna
	name = "Stroke Their Synth Antenna"
	description = "Stroke their synth antenna."
	category = "Synth Antenna"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("synth_antenna")
	message = list(
		"strokes %TARGET%'s synth antenna with careful fingers.",
		"runs their fingertips along %TARGET%'s synth antenna.",
		"teases %TARGET%'s synth antenna in a slow, deliberate pass."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/trace_synth_antenna
	name = "Trace Their Synth Antenna"
	description = "Trace along their synth antenna."
	category = "Synth Antenna"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_HAND)
	target_required_parts = list("synth_antenna")
	message = list(
		"traces a fingertip along %TARGET%'s synth antenna.",
		"follows the line of %TARGET%'s synth antenna with a teasing touch.",
		"lets their fingers drift carefully over %TARGET%'s synth antenna."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/kiss_synth_antenna
	name = "Kiss Their Synth Antenna"
	description = "Kiss their synth antenna."
	category = "Synth Antenna"
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	target_required_parts = list("synth_antenna")
	message = list(
		"presses a warm kiss to %TARGET%'s synth antenna.",
		"kisses slowly along %TARGET%'s synth antenna.",
		"teases %TARGET%'s synth antenna with a little kiss."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/kiss1.ogg', 'sound/lewd/sounds/kiss2.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_brush_wings
	name = "Tail. Brush Wings"
	description = "Brush their wings with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("wings")
	message = list(
		"brushes their tail across %TARGET%'s wings.",
		"runs the tip of their tail along %TARGET%'s feathers.",
		"teases %TARGET%'s wings with a slow caress of their tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_tease_frills
	name = "Tail. Tease Frills"
	description = "Tease their frills with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("frills")
	message = list(
		"teases %TARGET%'s frills with the tip of their tail.",
		"brushes their tail across %TARGET%'s frills in a slow pass.",
		"coaxes a shiver through %TARGET%'s frills with their tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_tease_horns
	name = "Tail. Tease Horns"
	description = "Tease their horns with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("horns")
	message = list(
		"traces their tail around %TARGET%'s horns.",
		"hooks the tip of their tail against %TARGET%'s horns in a teasing curl.",
		"lets their tail play around the base of %TARGET%'s horns."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/tail_stroke_antennae
	name = "Tail. Stroke Antennae"
	description = "Stroke their antennae with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("moth_antennae")
	message = list(
		"strokes %TARGET%'s antennae with the tip of their tail.",
		"teases %TARGET%'s antennae in slow, careful passes.",
		"lets their tail trail over %TARGET%'s twitching antennae."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(3, 5)

/datum/interaction/howling_extra/tail_stroke_synth_antenna
	name = "Tail. Stroke Synth Antenna"
	description = "Stroke their synth antenna with your tail."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("synth_antenna")
	message = list(
		"strokes %TARGET%'s synth antenna with a slow curl of their tail.",
		"brushes the tip of their tail along %TARGET%'s synth antenna.",
		"teases %TARGET%'s synth antenna with their tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_coil_tail
	name = "Tail. Coil Tail"
	description = "Coil your tail around theirs."
	category = "Tail"
	user_required_parts = list("tail")
	target_required_parts = list("tail")
	message = list(
		"coils their tail around %TARGET%'s tail.",
		"entwines their tail with %TARGET%'s in a slow tease.",
		"winds their tail together with %TARGET%'s."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)
	target_arousal = list(1, 3)

/datum/interaction/howling_extra/clothesplosion
	name = "Clothesplosion"
	description = "Burst out of your clothes."
	category = "Masturbation"
	usage = INTERACTION_SELF
	message = list(
		"bursts out of their clothes.",
		"explodes out of their outfit.",
		"dramatically tears free of their garments."
	)

	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/items/poster/poster_ripped.ogg')
/datum/interaction/howling_extra/clothesplosion/apply_effects(mob/living/carbon/human/user, mob/living/carbon/human/target)
	..()
	if(!istype(user))
		return
	var/list/to_drop = list(user.wear_suit, user.w_uniform, user.head, user.wear_mask, user.gloves, user.shoes)
	for(var/obj/item/item as anything in to_drop)
		if(item)
			user.dropItemToGround(item, force = TRUE)

/datum/interaction/howling_extra/knotfuck
	name = "Knotfuck"
	description = "Knotfuck their pussy."
	category = "Knotting"
	user_required_parts = list("knotted_penis")
	target_required_parts = list("vagina")
	message = list(
		"pounds %TARGET%'s pussy with their knot.",
		"forces their knot deep into %TARGET%'s pussy.",
		"slams their knot in and out of %TARGET%'s cunt."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/champ1.ogg',
		'sound/lewd/sounds/champ2.ogg'
	)
	user_pleasure = list(9, 11)
	target_pleasure = list(7, 9)
	user_arousal = list(13, 15)
	target_arousal = list(11, 13)
	target_pain = list(2, 4)

/datum/interaction/howling_extra/anal_knotfuck
	name = "Anal Knotfuck"
	description = "Knotfuck their ass."
	category = "Knotting"
	user_required_parts = list("knotted_penis")
	target_required_parts = list("anus")
	message = list(
		"pounds %TARGET%'s ass with their knot.",
		"forces their knot deep into %TARGET%'s ass.",
		"slams their knot in and out of %TARGET%'s rear."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_pleasure = list(7, 9)
	target_pleasure = list(5, 7)
	user_arousal = list(11, 13)
	target_arousal = list(9, 11)
	target_pain = list(5, 7)

/datum/interaction/howling_extra/oral_knotfuck
	name = "Oral Knotfuck"
	description = "Knotfuck their mouth."
	category = "Knotting"
	interaction_requires = list(INTERACTION_REQUIRE_TARGET_MOUTH)
	user_required_parts = list("knotted_penis")
	message = list(
		"shoves their knot into %TARGET%'s throat.",
		"chokes %TARGET% on their knot.",
		"slams their knot in and out of %TARGET%'s mouth."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_pleasure = list(6, 8)
	user_arousal = list(9, 11)
	target_arousal = list(1, 3)
	target_pain = list(6, 8)

/datum/interaction/howling_extra/nipple_knotfuck
	name = "Nipple Knotfuck"
	description = "Knotfuck their breast nipple."
	category = "Knotting"
	user_required_parts = list("knotted_penis")
	target_required_parts = list("breasts")
	message = list(
		"fucks %TARGET%'s nipple with their knot.",
		"slams their knot into %TARGET%'s breast.",
		"pounds %TARGET%'s nipple."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_pleasure = list(3, 5)
	target_pleasure = list(1, 3)
	user_arousal = list(6, 8)
	target_arousal = list(3, 5)
	target_pain = list(2, 4)

/datum/interaction/howling_extra/knotride_vagina
	name = "Knotride (Vagina)"
	description = "Ride their knot with your pussy."
	category = "Knotting"
	user_required_parts = list("vagina")
	target_required_parts = list("knotted_penis")
	message = list(
		"rides %TARGET%'s knot.",
		"forces %TARGET%'s knot into their pussy.",
		"pops %TARGET%'s knot in and out of their pussy."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_pleasure = list(8, 10)
	target_pleasure = list(8, 10)
	user_arousal = list(11, 13)
	target_arousal = list(11, 13)
	user_pain = list(1, 3)

/datum/interaction/howling_extra/knotride_anus
	name = "Knotride (Anus)"
	description = "Ride their knot with your ass."
	category = "Knotting"
	user_required_parts = list("anus")
	target_required_parts = list("knotted_penis")
	message = list(
		"rides %TARGET%'s knot with their ass.",
		"forces %TARGET%'s knot into their rear.",
		"pops %TARGET%'s knot in and out of their ass."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_pleasure = list(4, 6)
	target_pleasure = list(7, 9)
	user_arousal = list(8, 10)
	target_arousal = list(10, 12)
	user_pain = list(3, 5)

/datum/interaction/howling_extra/tentacle_pussy
	name = "Tentacle Pussy"
	description = "Use your tentacles on their pussy."
	category = "Tentacles"
	user_required_parts = list("tentacles")
	target_required_parts = list("vagina")
	message = list(
		"slides their tentacles into %TARGET%'s pussy.",
		"buries their tentacles in %TARGET%'s wet sex.",
		"thrusts their tentacles into %TARGET%'s folds."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/champ1.ogg',
		'sound/lewd/sounds/champ2.ogg'
	)
	user_pleasure = list(5, 7)
	target_pleasure = list(5, 7)
	user_arousal = list(9, 11)
	target_arousal = list(9, 11)

/datum/interaction/howling_extra/tentacle_double
	name = "Tentacle Double"
	description = "Use your tentacles on both of their holes."
	category = "Tentacles"
	user_required_parts = list("tentacles")
	target_required_parts = list("vagina", "anus")
	message = list(
		"works their tentacles into both of %TARGET%'s holes.",
		"drives their tentacles into %TARGET%'s pussy and ass.",
		"thrusts their tentacles through %TARGET%'s openings."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/champ1.ogg',
		'sound/lewd/sounds/champ2.ogg'
	)
	user_pleasure = list(6, 8)
	target_pleasure = list(6, 8)
	user_arousal = list(10, 12)
	target_arousal = list(10, 12)
	target_pain = list(1, 3)

/datum/interaction/howling_extra/tentacle_cock
	name = "Tentacle Cock"
	description = "Use your tentacles on their cock."
	category = "Tentacles"
	user_required_parts = list("tentacles")
	target_required_parts = list("penis")
	message = list(
		"coils their tentacles around %TARGET%'s cock.",
		"wraps %TARGET%'s shaft in slick tentacles.",
		"works %TARGET%'s cock with their tentacles."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg',
		'sound/lewd/sounds/bang3.ogg'
	)
	user_pleasure = list(3, 5)
	target_pleasure = list(5, 7)
	user_arousal = list(7, 9)
	target_arousal = list(9, 11)

/datum/interaction/howling_extra/tentacle_cock_and_ass
	name = "Tentacle Cock + Ass"
	description = "Use your tentacles on their cock and ass."
	category = "Tentacles"
	user_required_parts = list("tentacles")
	target_required_parts = list("penis", "anus")
	message = list(
		"wraps one tentacle around %TARGET%'s cock while another pushes into their ass.",
		"milks %TARGET%'s cock and rear at the same time with their tentacles.",
		"works %TARGET%'s shaft and asshole with slick tentacles."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/champ_fingering.ogg'
	)
	user_pleasure = list(4, 6)
	target_pleasure = list(6, 8)
	user_arousal = list(8, 10)
	target_arousal = list(10, 12)
	target_pain = list(1, 3)

/datum/interaction/howling_extra/tentacle_ass
	name = "Tentacle Ass"
	description = "Use your tentacles on their ass."
	category = "Tentacles"
	user_required_parts = list("tentacles")
	target_required_parts = list("anus")
	message = list(
		"slides their tentacles into %TARGET%'s ass.",
		"buries slick tentacles in %TARGET%'s rear.",
		"thrusts their tentacles into %TARGET%'s ass."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/champ_fingering.ogg',
		'sound/lewd/sounds/squelch1.ogg'
	)
	user_pleasure = list(4, 6)
	target_pleasure = list(4, 6)
	user_arousal = list(8, 10)
	target_arousal = list(8, 10)
	target_pain = list(1, 3)

/datum/interaction/howling_extra/tail_jerk_cock_self
	name = "Tail Jerk Off"
	description = "Use your tail to jerk yourself off."
	category = "Masturbation"
	usage = INTERACTION_SELF
	user_required_parts = list("tail", "penis")
	message = list(
		"coils their tail around their cock.",
		"works their own shaft with their tail.",
		"jerks themself off with their tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/bang1.ogg',
		'sound/lewd/sounds/bang2.ogg'
	)
	user_pleasure = list(3, 5)
	user_arousal = list(5, 7)

/datum/interaction/howling_extra/tail_penetrate_pussy_self
	name = "Tail Into Pussy"
	description = "Use your tail to penetrate your own pussy."
	category = "Masturbation"
	usage = INTERACTION_SELF
	user_required_parts = list("tail", "vagina")
	message = list(
		"slides their tail into their pussy.",
		"thrusts their tail into their own wet sex.",
		"uses their tail to penetrate themself."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/champ_fingering.ogg',
		'sound/lewd/sounds/squelch1.ogg'
	)
	user_pleasure = list(4, 6)
	user_arousal = list(6, 8)

/datum/interaction/howling_extra/tail_rub_pussy_self
	name = "Tail Over Pussy"
	description = "Rub your pussy with your tail."
	category = "Masturbation"
	usage = INTERACTION_SELF
	user_required_parts = list("tail", "vagina")
	message = list(
		"rubs their tail over their pussy.",
		"teases their clit with their tail.",
		"slides their tail along their own sex."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg'
	)
	user_pleasure = list(3, 5)
	user_arousal = list(5, 7)

/datum/interaction/howling_extra/tail_penetrate_ass_self
	name = "Tail Into Ass"
	description = "Use your tail to penetrate your own ass."
	category = "Masturbation"
	usage = INTERACTION_SELF
	user_required_parts = list("tail", "anus")
	message = list(
		"slides their tail into their ass.",
		"thrusts their tail into their own rear.",
		"uses their tail to penetrate themself."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/champ_fingering.ogg',
		'sound/lewd/sounds/squelch1.ogg'
	)
	user_pleasure = list(3, 5)
	user_arousal = list(5, 7)
	user_pain = list(1, 3)

/datum/interaction/howling_extra/tail_slide_between_cheeks_self
	name = "Tail Between Cheeks"
	description = "Slide your tail between your own cheeks."
	category = "Masturbation"
	usage = INTERACTION_SELF
	user_required_parts = list("tail", "butt")
	message = list(
		"slides their tail between their cheeks.",
		"teases their ass with their tail.",
		"drags their tail along their own rear."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/slap.ogg',
		'sound/lewd/sounds/squelch1.ogg'
	)
	user_arousal = list(3, 5)

/datum/interaction/howling_extra/tail_slide_between_breasts_self
	name = "Tail Between Breasts"
	description = "Slide your tail between your own breasts."
	category = "Masturbation"
	usage = INTERACTION_SELF
	user_required_parts = list("tail", "breasts")
	message = list(
		"slides their tail between their breasts.",
		"teases their chest with their tail.",
		"winds their tail through their own cleavage."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/squelch1.ogg',
		'sound/lewd/sounds/squelch2.ogg'
	)
	user_arousal = list(3, 5)

/datum/interaction/howling_extra/wrap_yourself_tail
	name = "Tail-Wrap"
	description = "Wrap your tail around yourself."
	category = "Masturbation"
	usage = INTERACTION_SELF
	user_required_parts = list("tail")
	message = list(
		"wraps their tail around themself.",
		"coils their tail snugly around their body.",
		"draws themself into a slow tail-bound embrace."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)

/datum/interaction/howling_extra/tail_thighs_self
	name = "Tail Over Thighs"
	description = "Rub your thighs with your tail."
	category = "Masturbation"
	usage = INTERACTION_SELF
	user_required_parts = list("tail", "thighs")
	message = list(
		"slides their tail along their inner thighs.",
		"teases their thighs with slow strokes of their tail.",
		"drags their tail between their own legs."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_pleasure = list(1, 3)
	user_arousal = list(3, 5)

/datum/interaction/howling_extra/tail_breasts_self
	name = "Tail Over Breasts"
	description = "Tease your breasts with your tail."
	category = "Masturbation"
	usage = INTERACTION_SELF
	user_required_parts = list("tail", "breasts")
	message = list(
		"teases their breasts with their tail.",
		"brushes their nipples with the tip of their tail.",
		"coaxes shivers from their chest with their tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_pleasure = list(1, 3)
	user_arousal = list(3, 5)

/datum/interaction/howling_extra/tail_face_self
	name = "Tail Over Face"
	description = "Brush your face with your tail."
	category = "Masturbation"
	usage = INTERACTION_SELF
	user_required_parts = list("tail")
	message = list(
		"brushes their tail over their face.",
		"traces their lips and cheek with their tail.",
		"lets the tip of their tail drift over their face."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_waist_self
	name = "Tail Around Waist"
	description = "Wrap your tail around your waist."
	category = "Masturbation"
	usage = INTERACTION_SELF
	user_required_parts = list("tail")
	message = list(
		"wraps their tail around their waist.",
		"coils their tail snugly around their middle.",
		"draws themself into a close tail-bound hold."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(1, 3)

/datum/interaction/howling_extra/tail_belly_self
	name = "Tail Tease Belly"
	description = "Tease your belly with your tail."
	category = "Masturbation"
	usage = INTERACTION_SELF
	user_required_parts = list("tail", "belly")
	message = list(
		"drags their tail over their belly.",
		"teases their stomach with a slow sweep of their tail.",
		"lets the tip of their tail circle across their belly."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_nipples_self
	name = "Tail Tease Nipples"
	description = "Tease your nipples with your tail."
	category = "Masturbation"
	usage = INTERACTION_SELF
	user_required_parts = list("tail", "breasts")
	message = list(
		"teases their nipples with the tip of their tail.",
		"flicks their nipples with playful little tail strokes.",
		"drags their tail across their nipples in slow passes."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_pleasure = list(1, 3)
	user_arousal = list(3, 5)

/datum/interaction/howling_extra/tail_snout_self
	name = "Tail Brush Snout"
	description = "Brush your snout with your tail."
	category = "Masturbation"
	usage = INTERACTION_SELF
	user_required_parts = list("tail", "snout")
	message = list(
		"brushes their tail over their snout.",
		"teases their own snout with the tip of their tail.",
		"traces their muzzle with a slow sweep of their tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(2, 4)

/datum/interaction/howling_extra/tail_neck_self
	name = "Tail Around Neck"
	description = "Wrap your tail around your neck."
	category = "Masturbation"
	usage = INTERACTION_SELF
	user_required_parts = list("tail", "neck")
	message = list(
		"coils their tail loosely around their neck.",
		"lets their tail curl around their throat in a slow tease.",
		"wraps their tail around their neck and holds it there for a moment."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list('sound/lewd/sounds/hug.ogg')
	user_arousal = list(2, 4)

/datum/interaction/howling_extra/lick_tail_self
	name = "Lick Tail"
	description = "Lick your own tail."
	category = "Masturbation"
	usage = INTERACTION_SELF
	interaction_requires = list(INTERACTION_REQUIRE_SELF_MOUTH)
	user_required_parts = list("tail")
	message = list(
		"licks along their own tail.",
		"drags their tongue over their tail.",
		"presses wet kisses to their own tail."
	)
	sound_use = TRUE
	sound_range = 1
	sound_possible = list(
		'sound/lewd/sounds/oral1.ogg',
		'sound/lewd/sounds/oral2.ogg'
	)
	user_pleasure = list(1, 3)
	user_arousal = list(3, 5)
