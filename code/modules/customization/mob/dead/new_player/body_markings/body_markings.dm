//This datum is quite close to the sprite accessory one, containing a bit of copy pasta code
//Those DO NOT have a customizable cases for rendering, or any special stuff, and are meant to be simpler than accessories
//One definition can stand for a whole set of accessories, make sure to set affected bodyparts
/datum/body_marking
	///The icon file the body markign is located in
	var/icon
	///The icon_state of the body marking
	var/icon_state
	///The preview name of the body marking. NEEDS A UNIQUE NAME
	var/name
	///The color the marking defaults to, important for randomisations. either a hex color ie."#FFFFFF" or a define like DEFAULT_PRIMARY
	var/default_color
	///Which bodyparts does the marking affect in BITFLAGS!! (HEAD, CHEST, ARM_LEFT, ARM_RIGHT, HAND_LEFT, HAND_RIGHT, LEG_RIGHT, LEG_LEFT)
	var/affected_bodyparts
	///Which species is this marking recommended to. Important for randomisations.
	var/list/recommended_species = list(SPECIES_MAMMAL = TRUE)
	///If this is on the color customization will show up despite the pref settings, it will also cause the marking to not reset colors to match the defaults
	var/always_color_customizable
	///Whether the body marking sprite is the same for both sexes or not. Only relevant for chest right now.
	var/gendered = TRUE
	/// Legacy flag. Marking render order is controlled by the saved marking layer.
	var/above_hair = FALSE

/datum/body_marking/New()
	if(!default_color)
		default_color = "#FFFFFF"
	if(recommended_species)
		recommended_species = string_assoc_list(recommended_species)

/datum/body_marking/proc/get_default_color(list/features, datum/species/species) //Needs features for the color information
	var/list/colors
	switch(default_color)
		if(DEFAULT_PRIMARY)
			colors = features[FEATURE_MUTANT_COLOR]
		if(DEFAULT_SECONDARY)
			colors = features[FEATURE_MUTANT_COLOR_TWO]
		if(DEFAULT_TERTIARY)
			colors = features[FEATURE_MUTANT_COLOR_THREE]
		if(DEFAULT_SKIN_OR_PRIMARY)
			if(species && !(TRAIT_USES_SKINTONES in species.inherent_traits))
				colors = features[FEATURE_SKIN_COLOR]
			else
				colors = features[FEATURE_MUTANT_COLOR]
		else
			colors = default_color

	return colors

//Use this one for things with pre-set default colors, I guess
/datum/body_marking/other
	icon = 'icons/mob/body_markings/other_markings.dmi'
	recommended_species = null

/datum/body_marking/other/drake_bone
	name = "Drake Bone"
	icon_state = "drakebone"
	default_color = "#CCCCCC"
	affected_bodyparts = CHEST | HAND_LEFT | HAND_RIGHT
	gendered = FALSE

/datum/body_marking/other/tonage
	name = "Body Tonage"
	icon_state = "tonage"
	default_color = "#555555"
	affected_bodyparts = CHEST
	gendered = FALSE

/datum/body_marking/other/belly_slim_toned
	name = "Belly Slim (Alt) + Tonage"
	icon_state = "bellyslimtoned"
	default_color = "#555555"
	affected_bodyparts = CHEST
	gendered = FALSE

/datum/body_marking/other/flushed_cheeks
	name = "Flushed Cheeks"
	icon_state = "flushed_cheeks"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD

/datum/body_marking/other/cyclops
	name = "Cyclopean Eye"
	icon_state = "cyclops"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD

/datum/body_marking/other/cyclops_alt
	name = "Eyes - Cyclopean"
	icon_state = "cyclops"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD
	above_hair = TRUE

/datum/body_marking/other/blank_face
	name = "Blank round face (use with monster mouth)"
	icon_state = "blankface"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD

/datum/body_marking/other/blank_face2
	name = "Blank Round Face, Alt"
	icon_state = "blankface2"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD

/datum/body_marking/other/monster_mouth
	name = "Monster Mouth"
	icon_state = "monster"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD

/datum/body_marking/other/monster_mouth_white
	name = "Monster Mouth (White)"
	icon_state = "monster_white"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD

/datum/body_marking/other/monster_mouth_white2
	name = "Monster Mouth (White, eye-compatible)"
	icon_state = "monster_white2"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD
//you're welcome -- iska

/datum/body_marking/other/monster_mouth2
	name = "Monster Mouth 2"
	icon_state = "monster2"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD

/datum/body_marking/other/nose_blemish
	name = "Nose Blemish"
	icon_state = "nose_blemish"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD

/datum/body_marking/other/brows
	name = "Brows"
	icon_state = "brows"
	affected_bodyparts = HEAD

/datum/body_marking/other/ears
	name = "Ears"
	icon_state = "ears"
	affected_bodyparts = HEAD

/datum/body_marking/other/insect_antennae
	name = "Insect Antennae"
	icon_state = "insect_antennae"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD

/datum/body_marking/other/eyeliner
	name = "Eyeliner"
	icon_state = "eyeliner"
	affected_bodyparts = HEAD

/datum/body_marking/other/topscars
	name = "Top Surgery Scars"
	icon_state = "topscars"
	affected_bodyparts = CHEST

/datum/body_marking/other/weight
	name = "Body Weight"
	icon_state = "weight"
	default_color = DEFAULT_PRIMARY
	affected_bodyparts = CHEST

/datum/body_marking/other/weight2
	name = "Body Weight (Greyscale)"
	icon_state = "weight2"
	default_color = DEFAULT_PRIMARY
	affected_bodyparts = CHEST

/datum/body_marking/other/pilot
	name = "Pilot"
	icon_state = "pilot"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT

/datum/body_marking/other/pilot_alt
	name = "Pilot Alt"
	icon_state = "pilot"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT

/datum/body_marking/other/pilot_jaw
	name = "Pilot Jaw"
	icon_state = "pilot_jaw"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD

/datum/body_marking/other/pilot_jaw_alt
	name = "Pilot Jaw Alt"
	icon_state = "pilot_jaw"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD

/datum/body_marking/other/drake_eyes
	name = "Drake Eyes"
	icon_state = "drakeeyes"
	default_color = "#FF0000"
	affected_bodyparts = HEAD
	always_color_customizable = TRUE

/datum/body_marking/other/drake_eyes_alt
	name = "Eyes - Drake"
	icon_state = "drakeeyes"
	default_color = "#FF0000"
	affected_bodyparts = HEAD
	always_color_customizable = TRUE
	above_hair = TRUE

/datum/body_marking/other/big_ol_eyes
	name = "Large Eyes"
	icon_state = "bigoleyes"
	default_color = "#FF0000"
	affected_bodyparts = HEAD
	always_color_customizable = TRUE

/datum/body_marking/other/three_eyes
	name = "Three Eyes"
	icon_state = "3eyes"
	default_color = "#FF0000"
	affected_bodyparts = HEAD
	always_color_customizable = TRUE

/datum/body_marking/other/four_eyes
	name = "Four Eyes"
	icon_state = "4eyes"
	default_color = "#FF0000"
	affected_bodyparts = HEAD
	always_color_customizable = TRUE

/datum/body_marking/other/sclera
	name = "Sclera"
	icon_state = "sclera"
	default_color = "#FF0000"
	affected_bodyparts = HEAD
	always_color_customizable = TRUE

/datum/body_marking/other/anime_inner
	name = "Anime Eyes (Inner)"
	icon_state = "anime_inner"
	default_color = "#FF0000"
	affected_bodyparts = HEAD
	always_color_customizable = TRUE

/datum/body_marking/other/anime_outer
	name = "Anime Eyes (Outer)"
	icon_state = "anime_outer"
	default_color = "#FF0000"
	affected_bodyparts = HEAD
	always_color_customizable = TRUE

/datum/body_marking/other/claws
	name = "Claw Tips"
	icon_state = "claws"
	affected_bodyparts = HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT
	gendered = FALSE

/datum/body_marking/other/harpy_upper
	name = "Harpy Upper Legs"
	icon_state = "harpy_upper"
	affected_bodyparts = LEG_RIGHT | LEG_LEFT
	gendered = FALSE

/datum/body_marking/other/harpy_lower
	name = "Harpy Lower Legs"
	icon_state = "harpy_lower"
	affected_bodyparts = LEG_RIGHT | LEG_LEFT
	gendered = FALSE

/datum/body_marking/other/harpy_claws
	name = "Harpy Claws"
	icon_state = "harpy_claws"
	affected_bodyparts = LEG_RIGHT | LEG_LEFT
	gendered = FALSE

/datum/body_marking/other/critter_legs
	name = "Critter Legs"
	icon_state = "critterleg"
	affected_bodyparts = LEG_RIGHT | LEG_LEFT
	gendered = FALSE


/datum/body_marking/other/splotches
	name = "Splotches"
	icon_state = "splotches"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/other/splotcheswap
	name = "Splotches Swapped"
	icon_state = "splotcheswap"
	affected_bodyparts = HEAD

/datum/body_marking/other/bands
	name = "Color Bands"
	icon_state = "bands"
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/other/chitin
	name = "Chitin"
	icon_state = "chitin"
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/other/bands_foot
	name = "Color Bands (Foot)"
	icon_state = "bands_foot"
	affected_bodyparts = LEG_RIGHT | LEG_LEFT

/datum/body_marking/other/anklet
	name = "Anklet"
	icon_state = "anklet"
	affected_bodyparts = LEG_RIGHT | LEG_LEFT

/datum/body_marking/other/legband
	name = "Leg Band"
	icon_state = "legband"
	affected_bodyparts = LEG_RIGHT | LEG_LEFT

/datum/body_marking/other/protogenlegs
	name = "Protogen Leg - Digitigrade"
	icon_state = "protogen"
	affected_bodyparts = LEG_RIGHT | LEG_LEFT

/datum/body_marking/other/protogenarms
	name = "Protogen Arm"
	icon_state = "protogen"
	affected_bodyparts = ARM_RIGHT | ARM_LEFT

/datum/body_marking/other/protogenchest
	name = "Protogen Chest"
	icon_state = "protogen"
	affected_bodyparts = CHEST

/datum/body_marking/other/jackal_fur
	name = "Jackal Back Fur"
	icon_state = "jackalfur"
	affected_bodyparts = CHEST | ARM_RIGHT | ARM_LEFT
	gendered = FALSE

/datum/body_marking/other/jackal_back
	name = "Jackal Back Fur Accents"
	icon_state = "jackalback"
	affected_bodyparts = CHEST | ARM_RIGHT | ARM_LEFT
	gendered = FALSE

/datum/body_marking/other/sixnips
	name = "Six Nips"
	icon_state = "nips"
	affected_bodyparts = CHEST
	gendered = FALSE

/datum/body_marking/other/chemlight
	name = "Bands and Stripes"
	icon_state = "chemlight"
	affected_bodyparts = ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/other/back_stripe
	name = "Back Stripe"
	icon_state = "backstripe"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/secondary
	icon = 'icons/mob/body_markings/secondary_markings.dmi'
	default_color = DEFAULT_SECONDARY

/datum/body_marking/secondary/teshari
	name = "Teshari"
	icon_state = "teshari"
	recommended_species = list(SPECIES_TESHARI = 1)
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT

/datum/body_marking/secondary/teshari_plain
	name = "Teshari Plain"
	icon_state = "teshari_plain"
	recommended_species = list(SPECIES_TESHARI = 1)
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/teshari_coat
	name = "Teshari Coat"
	icon_state = "teshari_coat"
	recommended_species = list(SPECIES_TESHARI = 1)
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/teshari_underfluff
	name = "Teshari Underfluff"
	icon_state = "teshari_underfluff"
	recommended_species = list(SPECIES_TESHARI = 1)
	affected_bodyparts = HEAD | CHEST | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/teshari_short
	name = "Teshari Short"
	icon_state = "teshari_short"
	recommended_species = list(SPECIES_TESHARI = 1)
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/teshari_feathers_male
	name = "Teshari Feathers (Male)"
	icon_state = "teshari_feathers_male"
	recommended_species = list(SPECIES_TESHARI = 1)
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/teshari_feathers_female
	name = "Teshari Feathers (Female)"
	icon_state = "teshari_feathers_female"
	recommended_species = list(SPECIES_TESHARI = 1)
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/teshari_lashes
	name = "Teshari Lashes"
	icon_state = "teshari_lashes"
	recommended_species = list(SPECIES_TESHARI = 1)
	affected_bodyparts = HEAD

/datum/body_marking/secondary/tajaran
	name = "Tajaran"
	icon_state = "tajaran"
	affected_bodyparts = HEAD | CHEST //The legs were literally one pixel so I removed them

/datum/body_marking/secondary/sergal
	name = "Sergal"
	icon_state = "sergal"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/secondary/husky
	name = "Husky"
	icon_state = "husky"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/fennec
	name = "Fennec"
	icon_state = "fennec"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/redpanda
	name = "Red Panda"
	icon_state = "redpanda"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/dalmatian
	name = "Dalmatian"
	icon_state = "dalmation"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/shepherd
	name = "Shepherd"
	icon_state = "shepherd"
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/wolf
	name = "Wolf"
	icon_state = "wolf"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/secondary/fox
	name = "Fox"
	icon_state = "fox"
	affected_bodyparts = HEAD | CHEST | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/raccoon
	name = "Raccoon"
	icon_state = "raccoon"
	affected_bodyparts = HEAD | CHEST | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/bovine
	name = "Bovine"
	icon_state = "bovine"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/possum
	name = "Possum"
	icon_state = "possum"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/secondary/corgi
	name = "Corgi"
	icon_state = "corgi"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/leopard1
	name = "Leopard"
	icon_state = "leopard1"
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/leopard2
	name = "Leopard (alt)"
	icon_state = "leopard2"
	affected_bodyparts = CHEST

/datum/body_marking/secondary/skunk
	name = "Skunk"
	icon_state = "skunk"
	affected_bodyparts = HEAD | CHEST | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/panther
	name = "Panther"
	icon_state = "panther"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/tiger
	name = "Tiger Spot"
	icon_state = "tiger"
	affected_bodyparts = HEAD | CHEST | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/otter
	name = "Otter"
	icon_state = "otter"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/secondary/otie
	name = "Otie"
	icon_state = "otie"
	affected_bodyparts = HEAD | CHEST | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/sabresune
	name = "Sabresune"
	icon_state = "sabresune"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/orca
	name = "Orca"
	icon_state = "orca"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/secondary/hawk
	name = "Hawk"
	icon_state = "hawk"
	affected_bodyparts = HEAD | CHEST | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/corvid
	name = "Corvid"
	icon_state = "corvid"
	affected_bodyparts = HEAD | CHEST | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/eevee
	name = "Eevee"
	icon_state = "eevee"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/secondary/shark
	name = "Shark"
	icon_state = "shark"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/secondary/deer
	name = "Deer"
	icon_state = "deer"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/hyena
	name = "Hyena"
	icon_state = "hyena"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/dog
	name = "Dog"
	icon_state = "dog"
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/bat
	name = "Bat"
	icon_state = "bat"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/secondary/floof
	name = "Floof"
	icon_state = "floof"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/secondary/rat
	name = "Rat Paw"
	icon_state = "rat"
	affected_bodyparts = ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/scolipede
	name = "Scolipede"
	icon_state = "scolipede"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/guilmon
	name = "Guilmon"
	icon_state = "guilmon"
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/xeno
	name = "Xeno"
	icon_state = "xeno"
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT | LEG_RIGHT | LEG_LEFT
	recommended_species = list(SPECIES_XENO = 1)

/datum/body_marking/secondary/datashark
	name = "Datashark"
	icon_state = "datashark"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/belly
	name = "Belly"
	icon_state = "belly"
	affected_bodyparts = CHEST

/datum/body_marking/secondary/bellyslim
	name = "Belly Slim"
	icon_state = "bellyslim"
	affected_bodyparts = HEAD | CHEST | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/bellyslimalt
	name = "Belly Slim Alternative"
	icon_state = "bellyslim_alt"
	affected_bodyparts = CHEST

/datum/body_marking/secondary/bellyandbutt
	name = "Belly and Butt"
	icon_state = "bellyandbutt"
	affected_bodyparts = CHEST

/datum/body_marking/secondary/butt
	name = "Butt"
	icon_state = "butt"
	affected_bodyparts = CHEST

/datum/body_marking/secondary/handsfeet
	name = "Hands Feet"
	icon_state = "handsfeet"
	affected_bodyparts = HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/frog
	name = "Frog"
	icon_state = "frog"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/bee
	name = "Bee"
	icon_state = "bee"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/gradient
	name = "Gradient"
	icon_state = "gradient"
	affected_bodyparts = ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/harlequin
	name = "Harlequin"
	icon_state = "harlequin"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | HAND_LEFT | LEG_LEFT

/datum/body_marking/secondary/harlequin_reversed
	name = "Harlequin Reversed"
	icon_state = "harlequin_reversed"
	affected_bodyparts = HEAD | CHEST | ARM_RIGHT | HAND_RIGHT | LEG_RIGHT

/datum/body_marking/secondary/plain
	name = "Plain"
	icon_state = "plain"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/upper_limb
	name = "Upper Limb"
	icon_state = "upper_limb"
	affected_bodyparts = ARM_LEFT | ARM_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/lower_limb
	name = "Lower Limb"
	icon_state = "lower_limb"
	affected_bodyparts = ARM_LEFT | ARM_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/insectoid
	name = "Insectoid"
	icon_state = "insect"
	affected_bodyparts = CHEST

/datum/body_marking/secondary/bellyoutline
	name = "Belly Outline"
	icon_state = "chembelly_trim"
	affected_bodyparts = CHEST

/datum/body_marking/tertiary
	icon = 'icons/mob/body_markings/tertiary_markings.dmi'
	default_color = DEFAULT_TERTIARY

/datum/body_marking/tertiary/redpanda
	name = "Red Panda Head"
	icon_state = "redpanda"
	affected_bodyparts = HEAD

/datum/body_marking/tertiary/shepherd
	name = "Shepherd Spot"
	icon_state = "shepherd"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/tertiary/wolf
	name = "Wolf Spot"
	icon_state = "wolf"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/fox
	name = "Fox Sock"
	icon_state = "fox"
	affected_bodyparts = ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/goat
	name = "Goat Hoof"
	icon_state = "goat"
	affected_bodyparts = HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/raccoon
	name = "Raccoon Spot"
	icon_state = "raccoon"
	affected_bodyparts = HEAD | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/bovine
	name = "Bovine Spot"
	icon_state = "bovine"
	affected_bodyparts = HEAD | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/possum
	name = "Possum Sock"
	icon_state = "possum"
	affected_bodyparts = HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/tiger
	name = "Tiger Stripe"
	icon_state = "tiger"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/otter
	name = "Otter Head"
	icon_state = "otter"
	affected_bodyparts = HEAD

/datum/body_marking/tertiary/otie
	name = "Otie Spot"
	icon_state = "otie"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/hawk
	name = "Hawk Talon"
	icon_state = "hawk"
	affected_bodyparts = LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/corvid
	name = "Corvid Talon"
	icon_state = "corvid"
	affected_bodyparts = LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/deer
	name = "Deer Hoof"
	icon_state = "deer"
	affected_bodyparts = HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/hyena
	name = "Hyena Side"
	icon_state = "hyena"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/tertiary/dog
	name = "Dog Spot"
	icon_state = "dog"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/bat
	name = "Bat Mark"
	icon_state = "bat"
	affected_bodyparts = CHEST

/datum/body_marking/tertiary/floofer
	name = "Floofer Sock"
	icon_state = "floofer"
	affected_bodyparts = ARM_LEFT | ARM_RIGHT | LEG_RIGHT | LEG_LEFT | HAND_LEFT | HAND_RIGHT

/datum/body_marking/tertiary/rat
	name = "Rat Spot"
	icon_state = "rat"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/sloth
	name = "Sloth Head"
	icon_state = "sloth"
	affected_bodyparts = HEAD

/datum/body_marking/tertiary/scolipede
	name = "Scolipede Spikes"
	icon_state = "scolipede"
	affected_bodyparts = CHEST

/datum/body_marking/tertiary/guilmon
	name = "Guilmon Mark"
	icon_state = "guilmon"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/xeno
	name = "Xeno Head"
	icon_state = "xeno"
	affected_bodyparts = HEAD
	recommended_species = list(SPECIES_XENO = 1)

/datum/body_marking/tertiary/dtiger
	name = "Dark Tiger Body"
	icon_state = "dtiger"
	affected_bodyparts = CHEST

/datum/body_marking/tertiary/ltiger
	name = "Light Tiger Body"
	icon_state = "ltiger"
	affected_bodyparts = CHEST

/datum/body_marking/tertiary/lbelly
	name = "Light Belly"
	icon_state = "lbelly"
	affected_bodyparts = CHEST

/datum/body_marking/tertiary/insectoid
	name = "Insectoid Trim"
	icon_state = "insect_trim"
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT | LEG_LEFT | LEG_RIGHT

/datum/body_marking/tertiary/chemlight
	name = "Bands and Stripes (Alt)"
	icon_state = "chem_light"
	affected_bodyparts = ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tattoo
	icon = 'icons/mob/body_markings/tattoo_markings.dmi'
	recommended_species = null
	default_color = "#112222" //slightly faded ink.
	always_color_customizable = 1
	gendered = FALSE

/datum/body_marking/tattoo/heart
	name = "Tattoo - Heart"
	icon_state = "tat_heart"
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT

/datum/body_marking/tattoo/heart_groin
	name = "Tattoo - Heart (Groin)"
	icon_state = "tat_heart_groin"
	affected_bodyparts = CHEST

/datum/body_marking/tattoo/hive
	name = "Tattoo - Hive"
	icon_state = "tat_hive"
	affected_bodyparts = CHEST
	gendered = TRUE

/datum/body_marking/tattoo/nightling
	name = "Tattoo - Nightling"
	icon_state = "tat_nightling"
	affected_bodyparts = CHEST

/datum/body_marking/tattoo/circuit
	name = "Tattoo - Circuit"
	icon_state = "tat_campbell"
	affected_bodyparts = ARM_LEFT | ARM_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tattoo/silverburgh //dunno what this is.
	name = "Tattoo - Silverburgh"
	icon_state = "tat_silverburgh"
	affected_bodyparts = LEG_RIGHT | LEG_LEFT

/datum/body_marking/tattoo/tiger
	name = "Tattoo - Tiger"
	icon_state = "tat_tiger"
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT
	gendered = TRUE

/datum/body_marking/tattoo/tiger_groin
	name = "Tattoo - Tiger (Groin)"
	icon_state = "tat_tiger_groin"
	affected_bodyparts = CHEST

/datum/body_marking/tattoo/tiger_foot
	name = "Tattoo - Tiger (Foot)"
	icon_state = "tat_tiger_foot"
	affected_bodyparts = LEG_RIGHT | LEG_LEFT

/datum/body_marking/tattoo/infinity
	name = "Tattoo - Infinity"
	icon_state = "tat_infinity"
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tattoo/butterfly
	name = "Tattoo - Butterfly"
	icon_state = "tat_butterfly"
	affected_bodyparts = CHEST

// ES13/Zubbers markings
/datum/body_marking/es13
	icon = 'icons/mob/body_markings/other_markings.dmi'
	default_color = "#000000"
	recommended_species = null

/datum/body_marking/es13/face_disc
	name = "Face Disc"
	icon_state = "facedisc"
	affected_bodyparts = HEAD

/datum/body_marking/es13/face_mask
	name = "Facemask"
	icon_state = "facemask"
	affected_bodyparts = HEAD

/datum/body_marking/es13/vertical_stripe
	name = "Vertical Stripe"
	icon_state = "verticalstripe"
	affected_bodyparts = HEAD

/datum/body_marking/es13/lips
	name = "Lips"
	icon_state = "lips"
	affected_bodyparts = HEAD

/datum/body_marking/es13/fangs
	name = "Fangs"
	icon_state = "fangs"
	affected_bodyparts = HEAD

/datum/body_marking/es13/deer_snout
	name = "Deer Snout (Marking)"
	icon_state = "deer"
	affected_bodyparts = HEAD

/datum/body_marking/es13/anime_inner
	name = "Eyes - Anime (Inner)"
	icon_state = "eyesinner"
	affected_bodyparts = HEAD
	above_hair = TRUE

/datum/body_marking/es13/anime_outer
	name = "Eyes - Anime (Outer)"
	icon_state = "eyesouter"
	affected_bodyparts = HEAD
	above_hair = TRUE

/datum/body_marking/es13/clown_cross
	name = "Clown Cross"
	icon_state = "clowncross"
	affected_bodyparts = HEAD
	gendered = FALSE

/datum/body_marking/es13/clown_lips
	name = "Clown Lips"
	icon_state = "clownlips"
	affected_bodyparts = HEAD
	gendered = FALSE

/datum/body_marking/es13/cyclops_sclera
	name = "Cyclops Sclera"
	icon_state = "cyclopssclera"
	affected_bodyparts = HEAD
	gendered = FALSE

/datum/body_marking/es13/longsock
	name = "Longsock"
	icon_state = "longsock"
	affected_bodyparts = LEG_LEFT | LEG_RIGHT

/datum/body_marking/es13/sock
	name = "Sock"
	icon_state = "sock"
	affected_bodyparts = LEG_LEFT | LEG_RIGHT

/datum/body_marking/es13/sleeve
	name = "Sleeve"
	icon_state = "sleeve"
	affected_bodyparts = ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT

/datum/body_marking/es13/glove
	name = "Glove"
	icon_state = "glove"
	affected_bodyparts = HAND_LEFT | HAND_RIGHT

/datum/body_marking/es13/shoulder
	name = "Shoulder"
	icon_state = "shoulder"
	affected_bodyparts = ARM_LEFT | ARM_RIGHT

/datum/body_marking/es13/elbow
	name = "Elbow"
	icon_state = "elbow"
	affected_bodyparts = ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT

/datum/body_marking/es13/hip
	name = "Hip"
	icon_state = "hip"
	affected_bodyparts = LEG_LEFT | LEG_RIGHT

/datum/body_marking/es13/chestplate
	name = "Chestplate"
	icon_state = "chestplate"
	affected_bodyparts = CHEST
	gendered = FALSE

/datum/body_marking/es13/monster_mouth_white_eye_compatible
	name = "Monster Mouth (White, eyes-compatible)"
	icon_state = "monster3"
	default_color = "#CCCCCC"
	affected_bodyparts = HEAD

/datum/body_marking/es13/belly_button
	name = "Belly Button"
	icon_state = "bellybutton"
	default_color = DEFAULT_PRIMARY
	affected_bodyparts = CHEST
	gendered = FALSE

/datum/body_marking/es13/belly_monster
	name = "Belly Monster"
	icon_state = "bellymonster"
	default_color = "#CCCCCC"
	affected_bodyparts = CHEST
	gendered = FALSE

/datum/body_marking/es13/belly_monster_alt
	name = "Belly Monster (Alt)"
	icon_state = "bellymonster_alt"
	default_color = "#CCCCCC"
	affected_bodyparts = CHEST
	gendered = FALSE

/datum/body_marking/es13/talons
	name = "Talons"
	icon_state = "talon"
	affected_bodyparts = LEG_LEFT | LEG_RIGHT

/datum/body_marking/es13/cleavage
	name = "Cleavage"
	icon_state = "cleavage"
	default_color = "#ffffff"
	affected_bodyparts = CHEST
	gendered = FALSE

/datum/body_marking/es13/dome
	name = "Dome"
	icon_state = "dome"
	default_color = "#FFFFFF"
	affected_bodyparts = HEAD

/datum/body_marking/es13/top_scar_variant_one
	name = "Top Scar Variant 1"
	icon_state = "topscars_1"
	affected_bodyparts = CHEST
	default_color = "#FFFFFF"
	gendered = FALSE

/datum/body_marking/es13/top_scar_variant_two
	name = "Top Scar Variant 2"
	icon_state = "topscars_2"
	affected_bodyparts = CHEST
	default_color = "#FFFFFF"
	gendered = FALSE

/datum/body_marking/es13/tall_eyes
	name = "Eyes - Tall"
	icon_state = "talleyes"
	default_color = "#FFFFFF"
	affected_bodyparts = HEAD
	above_hair = TRUE

/datum/body_marking/es13/wide_eyes
	name = "Eyes - Wide"
	icon_state = "wideeyes"
	default_color = "#FFFFFF"
	affected_bodyparts = HEAD
	above_hair = TRUE

/datum/body_marking/es13/angled_eyes
	name = "Eyes - Angled"
	icon_state = "angledeyes"
	default_color = "#FFFFFF"
	affected_bodyparts = HEAD
	above_hair = TRUE

/datum/body_marking/es13/body_gloss
	icon = 'icons/mob/body_markings/other_markings.dmi'
	icon_state = "gloss"
	name = "Body Gloss"
	default_color = "#ffffff"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | LEG_LEFT | LEG_RIGHT

/datum/body_marking/es13/synth_joints
	icon = 'icons/mob/body_markings/other_markings.dmi'
	icon_state = "joints"
	name = "Synth Joints"
	default_color = "#ffffff"
	gendered = FALSE
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT | LEG_LEFT | LEG_RIGHT | HAND_RIGHT | HAND_LEFT

// HJ markings
/datum/body_marking/plain
	icon = 'icons/mob/body_markings/other_markings.dmi'

/datum/body_marking/plain/head
	name = "Plain - Nape Base"
	icon_state = "nape_base"
	affected_bodyparts = HEAD

/datum/body_marking/plain/head/lower
	name = "Plain - Nape Lower"
	icon_state = "nape_lower"

/datum/body_marking/plain/head/lower/alt
	name = "Plain - Nape Lower (Alt)"
	icon_state = "nape_lower_alt"

/datum/body_marking/plain/head/ears_merge
	name = "Plain - Nape Ears Merge"
	icon_state = "nape_ears_merge"

/datum/body_marking/plain/head/ears_merge/alt
	name = "Plain - Nape Ears Merge (Alt)"
	icon_state = "nape_ears_merge_alt"

/datum/body_marking/plain/head/ears_addition
	name = "Plain - Nape Ears Addition"
	icon_state = "nape_ears_addition"

/datum/body_marking/plain/head/ears_addition/alt
	name = "Plain - Nape Ears Addition (Alt)"
	icon_state = "nape_ears_addition_alt"

/datum/body_marking/plain/torso
	name = "Plain - Torso Highlight 1"
	icon_state = "torso_highlight_1"
	affected_bodyparts = CHEST

/datum/body_marking/plain/torso/chest_highlight_1
	name = "Plain - Chest Highlight 1"
	icon_state = "chest_highlight_1"

/datum/body_marking/plain/torso/abdomen_sides
	name = "Plain - Abdomen Sides"
	icon_state = "abdomen_sides"

/datum/body_marking/plain/torso/abdomen_sides/alt
	name = "Plain - Abdomen Sides (Alt)"
	icon_state = "abdomen_sides_alt"

/datum/body_marking/plain/torso/abdomen_sides/wide
	name = "Plain - Abdomen Sides Wide"
	icon_state = "abdomen_sides_wide"

/datum/body_marking/plain/torso/abdomen_sides/wide/alt
	name = "Plain - Abdomen Sides Wide (Alt)"
	icon_state = "abdomen_sides_wide_alt"

/datum/body_marking/plain/torso/abdomen_sides/narrow
	name = "Plain - Abdomen Sides Narrow"
	icon_state = "abdomen_sides_narrow"

/datum/body_marking/plain/torso/abdomen_sides/line
	name = "Plain - Abdomen Sides Line"
	icon_state = "abdomen_sides_line"

/datum/body_marking/plain/torso/upper_abdoment_gradient
	name = "Plain - Upper Abdomen Gradient (light)"
	icon_state = "upper_abdomen_gradient_light"

/datum/body_marking/plain/torso/upper_chest_gradient
	name = "Plain - Upper Chest Gradient"
	icon_state = "upper_chest_gradient"

/datum/body_marking/plain/torso/upper_chest_gradient_alt_1
	name = "Plain - Upper Chest Gradient (Alt 1)"
	icon_state = "upper_chest_gradient_alt_1"

/datum/body_marking/plain/torso/upper_chest_gradient_alt_2
	name = "Plain - Upper Chest Gradient (Alt 2)"
	icon_state = "upper_chest_gradient_alt_2"

/datum/body_marking/plain/torso/upper_chest_gradient_alt_3
	name = "Plain - Upper Chest Gradient (Alt 3)"
	icon_state = "upper_chest_gradient_alt_3"

/datum/body_marking/plain/torso/abdominals
	name = "Plain - Light Abdominals"
	icon_state = "light_abdominals"

/datum/body_marking/plain/torso/nipples
	name = "Plain - Nipples"
	icon_state = "nipples"

/datum/body_marking/plain/torso/nipples/alt
	name = "Plain - Nipples (Alt)"
	icon_state = "nipples_alt"

/datum/body_marking/plain/torso/back
	name = "Plain - Back"
	icon_state = "back"

/datum/body_marking/plain/torso/back_upper
	name = "Plain - Back (Upper)"
	icon_state = "back_upper"

/datum/body_marking/plain/torso/spine_wide
	name = "Plain - Spine Wide"
	icon_state = "spine_wide"

/datum/body_marking/plain/torso/spine_wide_alt
	name = "Plain - Spine Wide (Alt)"
	icon_state = "spine_wide_alt"

/datum/body_marking/plain/torso/spine_wide_up
	name = "Plain - Spine Wide Up"
	icon_state = "spine_wide_up"

/datum/body_marking/plain/torso/spine_wide_up_alt
	name = "Plain - Spine Wide Up (Alt)"
	icon_state = "spine_wide_up_alt"

/datum/body_marking/plain/torso/spine_wide_shoulders
	name = "Plain - Spine Wide Shoulders"
	icon_state = "spine_wide_shoulders"

/datum/body_marking/plain/torso/spine_wide_shoulders_alt
	name = "Plain - Spine Wide Shoulders (Alt)"
	icon_state = "spine_wide_shoulders_alt"

/datum/body_marking/plain/torso/spine_wide_low
	name = "Plain - Spine Wide Low"
	icon_state = "spine_wide_low"

/datum/body_marking/plain/torso/spine_wide_low_alt
	name = "Plain - Spine Wide Low (Alt)"
	icon_state = "spine_wide_low_alt"

/datum/body_marking/plain/torso/spine_narrow
	name = "Plain - Spine Narrow"
	icon_state = "spine_narrow"

/datum/body_marking/plain/torso/spine_narrow_alt
	name = "Plain - Spine Narrow (Alt)"
	icon_state = "spine_narrow_alt"

/datum/body_marking/plain/torso/spine_line
	name = "Plain - Spine Line"
	icon_state = "spine_line"

/datum/body_marking/plain/torso/spine_line_alt
	name = "Plain - Spine Line (Alt)"
	icon_state = "spine_line_alt"

/datum/body_marking/plain/torso/spine_deepth
	name = "Plain - Spine Deepth"
	icon_state = "spine_deepth"

/datum/body_marking/plain/torso/spine_deepth_light
	name = "Plain - Spine Deepth (Light)"
	icon_state = "spine_deepth_light"

/datum/body_marking/plain/arms_outer
	name = "Plain - Arms Outerline"
	icon_state = "arms_outerline"
	affected_bodyparts = ARM_LEFT | ARM_RIGHT

/datum/body_marking/plain/arms_outer/reversed
	name = "Plain - Arms Outerline (Reversed)"
	icon_state = "arms_outerline_reversed"

/datum/body_marking/plain/inner_thighs
	name = "Plain - Inner Thighs"
	icon_state = "inner_thighs"
	affected_bodyparts = CHEST | LEG_RIGHT | LEG_LEFT

/datum/body_marking/plain/inner_thighs/wide
	name = "Plain - Inner Thighs (Wide)"
	icon_state = "inner_thighs_wide"

/datum/body_marking/plain/inner_thighs/narrow
	name = "Plain - Inner Thighs (Narrow)"
	icon_state = "inner_thighs_narrow"

/datum/body_marking/plain/inner_thighs/line
	name = "Plain - Inner Thighs (Line)"
	icon_state = "inner_thighs_line"

/datum/body_marking/plain/tattoo
	name = "Tattoo - Shoulder Lines"
	icon_state = "tattoo_shoulder_lines"
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT

/datum/body_marking/plain/tattoo/upper_torso_lines
	name = "Tattoo - Upper Torso Lines"
	icon_state = "tattoo_upper_torso_lines"
	affected_bodyparts = CHEST

/datum/body_marking/plain/tattoo/upper_torso_lines/short
	name = "Tattoo - Upper Torso Lines (Short)"
	icon_state = "tattoo_upper_torso_lines_short"

/datum/body_marking/plain/tattoo/arms_lines
	name = "Tattoo - Arms Lines"
	icon_state = "tattoo_arm_lines"
	affected_bodyparts = ARM_LEFT | ARM_RIGHT

/datum/body_marking/other/splurt
	icon = 'icons/mob/body_markings/other_markings.dmi'
	default_color = DEFAULT_PRIMARY

/datum/body_marking/secondary/splurt
	icon = 'icons/mob/body_markings/other_markings.dmi'
	default_color = DEFAULT_SECONDARY

/datum/body_marking/tertiary/splurt
	icon = 'icons/mob/body_markings/other_markings.dmi'
	default_color = DEFAULT_TERTIARY

/datum/body_marking/other/splurt/abs
	name = "Abs"
	icon_state = "hj_primary_abs"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/splurt/abs
	name = "Abs 2"
	icon_state = "hj_secondary_abs"
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/splurt/abs
	name = "Abs 3"
	icon_state = "hj_tertiary_abs"
	affected_bodyparts = LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/splurt/pigeon
	name = "Pigeon"
	icon_state = "hj_secondary_pigeon"
	affected_bodyparts = CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT

/datum/body_marking/tertiary/splurt/pigeon
	name = "Pigeon 2"
	icon_state = "hj_tertiary_pigeon"
	affected_bodyparts = ARM_LEFT | ARM_RIGHT

/datum/body_marking/secondary/splurt/shrike
	name = "Shrike 2"
	icon_state = "hj_secondary_shrike"
	affected_bodyparts = HEAD | ARM_LEFT | ARM_RIGHT

/datum/body_marking/tertiary/splurt/shrike
	name = "Shrike"
	icon_state = "hj_tertiary_shrike"
	affected_bodyparts = CHEST | HEAD | ARM_LEFT | ARM_RIGHT

/datum/body_marking/other/splurt/moth
	name = "Moth"
	icon_state = "hj_primary_moth"
	affected_bodyparts = CHEST

/datum/body_marking/secondary/splurt/moth
	name = "Moth 2"
	icon_state = "hj_secondary_moth"
	affected_bodyparts = CHEST

/datum/body_marking/other/splurt/bee
	name = "Bee Alt"
	icon_state = "hj_primary_bee"
	affected_bodyparts = CHEST

/datum/body_marking/secondary/splurt/bee
	name = "Bee Alt 2"
	icon_state = "hj_secondary_bee"
	affected_bodyparts = CHEST

/datum/body_marking/tertiary/splurt/bee
	name = "Bee Alt 3"
	icon_state = "hj_tertiary_bee"
	affected_bodyparts = CHEST

/datum/body_marking/other/splurt/bee_fluff
	name = "Bee Fluff"
	icon_state = "hj_primary_bee_fluff"
	affected_bodyparts = CHEST

/datum/body_marking/secondary/splurt/bee_fluff
	name = "Bee Fluff 2"
	icon_state = "hj_secondary_bee_fluff"
	affected_bodyparts = CHEST

/datum/body_marking/tertiary/splurt/bee_fluff
	name = "Bee Fluff 3"
	icon_state = "hj_tertiary_bee_fluff"
	affected_bodyparts = CHEST

/datum/body_marking/secondary/splurt/bug3tone
	name = "Bug 3 Tone"
	icon_state = "hj_secondary_bug3tone"
	affected_bodyparts = CHEST

/datum/body_marking/tertiary/splurt/bug3tone
	name = "Bug 3 Tone 2"
	icon_state = "hj_tertiary_bug3tone"
	affected_bodyparts = CHEST

/datum/body_marking/other/splurt/gloss
	name = "Gloss Alt"
	icon_state = "hj_primary_gloss"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/other/splurt/chemlight
	name = "Chemlight"
	icon_state = "hj_primary_chemlight"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/splurt/chemlight
	name = "Chemlight 2"
	icon_state = "hj_secondary_chemlight"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/splurt/chemlight
	name = "Chemlight 3"
	icon_state = "hj_tertiary_chemlight"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/other/splurt/easternd
	name = "Eastern Dragon"
	icon_state = "hj_primary_easternd"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/splurt/easternd
	name = "Eastern Dragon 2"
	icon_state = "hj_secondary_easternd"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT

/datum/body_marking/other/splurt/raccalt
	name = "Raccoon Alt"
	icon_state = "hj_primary_raccalt"
	affected_bodyparts = HEAD | LEG_RIGHT | LEG_LEFT

/datum/body_marking/secondary/splurt/raccalt
	name = "Raccoon Alt 2"
	icon_state = "hj_secondary_raccalt"
	affected_bodyparts = HEAD

/datum/body_marking/tertiary/splurt/raccalt
	name = "Raccoon Alt 3"
	icon_state = "hj_tertiary_raccalt"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/secondary/splurt/noodledragon
	name = "Noodle Dragon"
	icon_state = "hj_secondary_noodledragon"
	affected_bodyparts = CHEST

/datum/body_marking/tertiary/splurt/noodledragon
	name = "Noodle Dragon 2"
	icon_state = "hj_tertiary_noodledragon"
	affected_bodyparts = CHEST

/datum/body_marking/other/splurt/owlbarn
	name = "Owl Barn"
	icon_state = "hj_primary_owlbarn"
	affected_bodyparts = HEAD

/datum/body_marking/tertiary/splurt/owlbarn
	name = "Owl Barn 2"
	icon_state = "hj_tertiary_owlbarn"
	affected_bodyparts = HEAD

/datum/body_marking/other/splurt/owlhorned
	name = "Owl Horned"
	icon_state = "hj_primary_owlhorned"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/tertiary/splurt/owlhorned
	name = "Owl Horned 2"
	icon_state = "hj_tertiary_owlhorned"
	affected_bodyparts = CHEST

/datum/body_marking/other/splurt/toeclaws
	name = "Toe Claws"
	icon_state = "hj_primary_toeclaws"
	affected_bodyparts = LEG_RIGHT | LEG_LEFT

/datum/body_marking/other/splurt/deoxys
	name = "Deoxys"
	icon_state = "hj_primary_deoxys"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | LEG_RIGHT | LEG_LEFT | HAND_LEFT | HAND_RIGHT

/datum/body_marking/secondary/splurt/deoxys
	name = "Deoxys 2"
	icon_state = "hj_secondary_deoxys"
	affected_bodyparts = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | LEG_RIGHT | LEG_LEFT | HAND_LEFT | HAND_RIGHT

/datum/body_marking/tertiary/splurt/deoxys
	name = "Deoxys 3"
	icon_state = "hj_tertiary_deoxys"
	affected_bodyparts = HEAD | CHEST

/datum/body_marking/tertiary/splurt/pilot_jaw
	name = "Pilot Jaw 2"
	icon_state = "hj_tertiary_pilot_jaw"
	affected_bodyparts = HEAD

/datum/body_marking/secondary/splurt/pilot
	name = "Pilot 2"
	icon_state = "hj_secondary_pilot"
	affected_bodyparts = HEAD

/datum/body_marking/tertiary/splurt/pilot
	name = "Pilot 3"
	icon_state = "hj_tertiary_pilot"
	affected_bodyparts = HEAD

/datum/body_marking/tertiary/splurt/renamon
	name = "Renamon"
	icon_state = "hj_tertiary_renamon"
	affected_bodyparts = HEAD | LEG_RIGHT | LEG_LEFT

/datum/body_marking/tertiary/splurt/succubustattoo
	name = "Succubus Tattoo"
	icon_state = "hj_tertiary_succubustattoo"
	affected_bodyparts = CHEST

/datum/body_marking/tertiary/splurt/colouredlips
	name = "Coloured Lips"
	icon_state = "hj_tertiary_colouredlips"
	affected_bodyparts = HEAD

/datum/body_marking/tertiary/splurt/colourednose
	name = "Coloured Nose"
	icon_state = "hj_tertiary_colourednose"
	affected_bodyparts = HEAD

/datum/body_marking/tertiary/splurt/foreheadmark
	name = "Forehead Mark"
	icon_state = "hj_tertiary_foreheadmark"
	affected_bodyparts = HEAD

/datum/body_marking/tertiary/splurt/blushsmall
	name = "Blush"
	icon_state = "hj_tertiary_blushsmall"
	affected_bodyparts = HEAD

/datum/body_marking/tertiary/splurt/blushsmall_alt
	name = "Blush Small (Alt)"
	icon_state = "hj_tertiary_blushsmallALT"
	affected_bodyparts = HEAD

/datum/body_marking/other/splurt/sloog
	name = "Sloog"
	icon_state = "hj_primary_sloog"
	affected_bodyparts = CHEST

/datum/body_marking/secondary/splurt/sloog
	name = "Sloog 2"
	icon_state = "hj_secondary_sloog"
	affected_bodyparts = CHEST
