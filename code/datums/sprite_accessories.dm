/*
 *	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
 *	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
 *	intended to be friendly for people with little to no actual coding experience.
 *	The process of adding in new hairstyles has been made pain-free and easy to do.
 *	Enjoy! - Doohl
 *
 *
 *	Notice: This all gets automatically compiled in a list in dna.dm, so you do not
 *	have to define any UI values for sprite accessories manually for hair and facial
 *	hair. Just add in new hair types and the game will naturally adapt.
 *
 *	!!WARNING!!: changing existing hair information can be VERY hazardous to savefiles,
 *	to the point where you may completely corrupt a server's savefiles. Please refrain
 *	from doing this unless you absolutely know what you are doing, and have defined a
 *	conversion in savefile.dm
 */

/datum/sprite_accessory
	/// The icon file the accessory is located in.
	var/icon
	/// The icon_state of the accessory.
	var/icon_state
	/// The preview name of the accessory.
	var/name
	/// Determines if the accessory will be skipped or included in random hair generations.
	var/gender = NEUTER
	/// Something that can be worn by either gender, but looks different on each.
	var/gender_specific = FALSE
	/// Determines if the accessory will be skipped by color preferences.
	var/use_static
	/**
	 * Currently only used by mutantparts so don't worry about hair and stuff.
	 * This is the source that this accessory will get its color from. Default is MUTCOLOR, but can also be HAIR, FACEHAIR, EYECOLOR and 0 if none.
	 */
	var/color_src = MUTANT_COLOR
	/// Is this part locked from roundstart selection? Used for parts that apply effects.
	var/locked = FALSE
	/// Should we center the sprite?
	var/center = FALSE
	/// The width of the sprite in pixels. Used to center it if necessary.
	var/dimension_x = 32
	/// The height of the sprite in pixels. Used to center it if necessary.
	var/dimension_y = 32
	/// Should this sprite block emissives?
	var/em_block = FALSE
	/// Determines if this is considered "sane" for the purpose of [/proc/randomize_human_normie]
	/// Basically this is to blacklist the extremely wacky stuff from being picked in random human generation.
	var/natural_spawn = TRUE

/datum/sprite_accessory/blank
	name = SPRITE_ACCESSORY_NONE
	icon_state = SPRITE_ACCESSORY_NONE

////////////////
// Hair Masks //
////////////////

/datum/hair_mask
	var/icon/icon = 'icons/mob/human/hair_masks.dmi'
	var/icon_state = ""
	/// Strict coverage zones will always have the hair mask applied to them, even if a piece of hair at that location would normally resist being masked.
	/// If a piece of headware only covers the top of the head, it should only strictly cover the top zone. But a mostly-enclosed helmet might strictly cover almost all zones.
	var/strict_coverage_zones = NONE

/datum/hair_mask/standard_hat_middle
	icon_state = "hide_above_45deg"
	strict_coverage_zones = HAIR_APPENDAGE_TOP

/datum/hair_mask/standard_hat_low
	icon_state = "hide_above_45deg_low"
	strict_coverage_zones = HAIR_APPENDAGE_TOP | HAIR_APPENDAGE_LEFT | HAIR_APPENDAGE_RIGHT | HAIR_APPENDAGE_REAR

/datum/hair_mask/winterhood
	icon_state = "hide_winterhood"
	strict_coverage_zones = HAIR_APPENDAGE_TOP | HAIR_APPENDAGE_LEFT | HAIR_APPENDAGE_RIGHT | HAIR_APPENDAGE_REAR | HAIR_APPENDAGE_HANGING_REAR

//////////////////////
// Hair Definitions //
//////////////////////
// Cache of each hairstyle's icon after being blended with the given masks
// "joined mask types" is each mask's type as a string joined by commas (for no masks, it is the empty string)
// /datum/sprite_accessory/hair path -> list(joined mask types -> icon)
GLOBAL_LIST_EMPTY(blended_hair_icons_cache)

/datum/sprite_accessory/hair
	icon = 'icons/mob/human/human_face.dmi'   // default icon for all hairs
	var/y_offset = 0 // Y offset to apply so we can have hair that reaches above the player sprite's visual bounding box

	// Some hair will have "appendages", such as pony tails, that stick out from certain parts of the head. These can be layered above or below headwear and resist being masked away by hair masks.
	// Lists should be icon_state strings associated with the HAIR_APPENDAGE defines specifying the part of the head they stick out from.
	// hair_appendages_inner contains icon_states that go in the normal hair layer, hair_appendages_outer contains icon_states that go above the layer for headwear.
	// hair_appendages_inner will be masked normally if their HAIR_APPENDAGE zone is strictly masked by a piece of clothing (a fully enclosed helmet with a transparent visor will strictly mask all zones, a small hat will only strictly mask the top, etc.).
	// hair_appendages_outer will never be masked at all and will just not be shown if their zone has strict masking. These should generally not have visible sprites for every dir.
	var/list/hair_appendages_inner = null
	var/list/hair_appendages_outer = null

/// Retrieve the base hair icon with all hair appendeges blended in, with hair masks applied, from the cache, or generate it if it doesn't exist
/datum/sprite_accessory/hair/proc/getCachedIcon(list/hair_masks)
	var/icon/cachedIcon
	var/joinedMasks = LAZYLEN(hair_masks) ? jointext(hair_masks, ",") : ""
	var/list/masks_to_icons = GLOB.blended_hair_icons_cache[type]
	if(!masks_to_icons)
		GLOB.blended_hair_icons_cache[type] = list()
	else
		cachedIcon = masks_to_icons[joinedMasks]

	if(!cachedIcon)
		if(LAZYLEN(hair_masks))
			if(LAZYLEN(hair_appendages_inner))
				// Check if there are any hair appendages in a zone that is not strictly masked
				var/found_mask_dodger = FALSE
				for(var/datum/hair_mask/mask as anything in hair_masks)
					for(var/appendage in hair_appendages_inner)
						var/zone = hair_appendages_inner[appendage]
						if(!(zone & mask.strict_coverage_zones))
							found_mask_dodger = TRUE

				if(found_mask_dodger)
					// We have to process each icon individually
					cachedIcon = icon(icon, icon_state)
					// mask the base icon
					for(var/datum/hair_mask/mask as anything in hair_masks)
						var/icon/mask_icon = icon('icons/mob/human/hair_masks.dmi', mask.icon_state)
						mask_icon.Shift(SOUTH, y_offset)
						cachedIcon.Blend(mask_icon, ICON_ADD)

					// mask the appendages if required and add them to the base icon
					for(var/appendage_icon_state in hair_appendages_inner)
						var/icon/appendage_icon = icon(icon, appendage_icon_state)
						var/zone = hair_appendages_inner[appendage_icon_state]
						for(var/datum/hair_mask/mask as anything in hair_masks)
							if(zone & mask.strict_coverage_zones)
								var/icon/mask_icon = icon('icons/mob/human/hair_masks.dmi', mask.icon_state)
								mask_icon.Shift(SOUTH, y_offset)
								appendage_icon.Blend(mask_icon, ICON_ADD)
						cachedIcon.Blend(appendage_icon, ICON_OVERLAY)
				else
					// No mask dodgers, so we can just mask the full (hopefully cached) icon
					cachedIcon = icon(getCachedIcon())
					for(var/datum/hair_mask/mask as anything in hair_masks)
						var/icon/mask_icon = icon('icons/mob/human/hair_masks.dmi', mask.icon_state)
						mask_icon.Shift(SOUTH, y_offset)
						cachedIcon.Blend(mask_icon, ICON_ADD)
			else
				// No hair appendages, so just apply all hair masks to the base icon
				cachedIcon = icon(icon, icon_state)
				for(var/datum/hair_mask/mask as anything in hair_masks)
					var/icon/mask_icon = icon('icons/mob/human/hair_masks.dmi', mask.icon_state)
					mask_icon.Shift(SOUTH, y_offset)
					cachedIcon.Blend(mask_icon, ICON_ADD)
		else
			// no hair masks
			cachedIcon = icon(icon, icon_state)
			if(LAZYLEN(hair_appendages_inner))
				for(var/appendage_icon_state in hair_appendages_inner)
					var/icon/appendage_icon = icon(icon, appendage_icon_state)
					cachedIcon.Blend(appendage_icon, ICON_OVERLAY)
		// set cache
		GLOB.blended_hair_icons_cache[type][joinedMasks] = cachedIcon
	return cachedIcon


// please make sure they're sorted alphabetically and, where needed, categorized
// try to capitalize the names please~
// try to spell
// you do not need to define _s or _l sub-states, game automatically does this for you

/datum/sprite_accessory/hair/afro
	name = "Afro"
	icon_state = "hair_afro"

/datum/sprite_accessory/hair/afro2
	name = "Afro 2"
	icon_state = "hair_afro2"

/datum/sprite_accessory/hair/afro_large
	name = "Afro (Large)"
	icon_state = "hair_bigafro"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/afro_huge
	name = "Afro (Huge)"
	icon_state = "hair_hugeafro"
	y_offset = 6
	natural_spawn = FALSE

/datum/sprite_accessory/hair/allthefuzz
	name = "All The Fuzz"
	icon_state = "hair_allthefuzz"

/datum/sprite_accessory/hair/antenna
	name = "Ahoge"
	icon_state = "hair_antenna"
	hair_appendages_inner = list("hair_antenna_a1" = HAIR_APPENDAGE_TOP)

/datum/sprite_accessory/hair/bald
	name = "Bald"
	icon_state = null

/datum/sprite_accessory/hair/balding
	name = "Balding Hair"
	icon_state = "hair_e"

/datum/sprite_accessory/hair/bedhead
	name = "Bedhead"
	icon_state = "hair_bedhead"

/datum/sprite_accessory/hair/bedhead2
	name = "Bedhead 2"
	icon_state = "hair_bedheadv2"

/datum/sprite_accessory/hair/bedhead3
	name = "Bedhead 3"
	icon_state = "hair_bedheadv3"

/datum/sprite_accessory/hair/bedheadv4
	name = "Bedhead 4x"
	icon_state = "hair_bedheadv4"

/datum/sprite_accessory/hair/bedheadlong
	name = "Long Bedhead"
	icon_state = "hair_long_bedhead"

/datum/sprite_accessory/hair/bedheadfloorlength
	name = "Floorlength Bedhead"
	icon_state = "hair_floorlength_bedhead"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/badlycut
	name = "Shorter Long Bedhead"
	icon_state = "hair_verybadlycut"

/datum/sprite_accessory/hair/beehive
	name = "Beehive"
	icon_state = "hair_beehive"

/datum/sprite_accessory/hair/beehive2
	name = "Beehive 2"
	icon_state = "hair_beehivev2"

/datum/sprite_accessory/hair/bob
	name = "Bob Hair"
	icon_state = "hair_bob"

/datum/sprite_accessory/hair/bob2
	name = "Bob Hair 2"
	icon_state = "hair_bob2"

/datum/sprite_accessory/hair/bob3
	name = "Bob Hair 3"
	icon_state = "hair_bobcut"

/datum/sprite_accessory/hair/bob4
	name = "Bob Hair 4"
	icon_state = "hair_bob4"

/datum/sprite_accessory/hair/bobcurl
	name = "Bobcurl"
	icon_state = "hair_bobcurl"

/datum/sprite_accessory/hair/boddicker
	name = "Boddicker"
	icon_state = "hair_boddicker"

/datum/sprite_accessory/hair/bowlcut
	name = "Bowlcut"
	icon_state = "hair_bowlcut"

/datum/sprite_accessory/hair/bowlcut2
	name = "Bowlcut 2"
	icon_state = "hair_bowlcut2"

/datum/sprite_accessory/hair/braid
	name = "Braid (Floorlength)"
	icon_state = "hair_braid"
	hair_appendages_inner = list("hair_braid_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_braid_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/braided
	name = "Braided"
	icon_state = "hair_braided"

/datum/sprite_accessory/hair/front_braid
	name = "Braided Front"
	icon_state = "hair_braidfront"
	hair_appendages_inner = list("hair_braidfront_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_braidfront_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/not_floorlength_braid
	name = "Braid (High)"
	icon_state = "hair_braid2"
	hair_appendages_inner = list("hair_braid2_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_braid2_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/lowbraid
	name = "Braid (Low)"
	icon_state = "hair_hbraid"

/datum/sprite_accessory/hair/shortbraid
	name = "Braid (Short)"
	icon_state = "hair_shortbraid"
	hair_appendages_inner = list("hair_shortbraid_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_shortbraid_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/braidtail
	name = "Braided Tail"
	icon_state = "hair_braidtail"
	hair_appendages_inner = list("hair_braidtail_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_braidtail_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/bun
	name = "Bun Head"
	icon_state = "hair_bun"

/datum/sprite_accessory/hair/bun2
	name = "Bun Head 2"
	icon_state = "hair_bunhead2"
	hair_appendages_inner = list("hair_bunhead2_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_bunhead2_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/bun3
	name = "Bun Head 3"
	icon_state = "hair_bun3"

/datum/sprite_accessory/hair/largebun
	name = "Bun (Large)"
	icon_state = "hair_largebun"

/datum/sprite_accessory/hair/manbun
	name = "Bun (Manbun)"
	icon_state = "hair_manbun"
	hair_appendages_inner = list("hair_manbun_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_manbun_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/tightbun
	name = "Bun (Tight)"
	icon_state = "hair_tightbun"

/datum/sprite_accessory/hair/business
	name = "Business Hair"
	icon_state = "hair_business"

/datum/sprite_accessory/hair/business2
	name = "Business Hair 2"
	icon_state = "hair_business2"

/datum/sprite_accessory/hair/business3
	name = "Business Hair 3"
	icon_state = "hair_business3"

/datum/sprite_accessory/hair/business4
	name = "Business Hair 4"
	icon_state = "hair_business4"

/datum/sprite_accessory/hair/buzz
	name = "Buzzcut"
	icon_state = "hair_buzzcut"

/datum/sprite_accessory/hair/chinbob
	name = "Chin-Length Bob Cut"
	icon_state = "hair_chinbob"

/datum/sprite_accessory/hair/comet
	name = "Comet"
	icon_state = "hair_comet"

/datum/sprite_accessory/hair/cia
	name = "CIA"
	icon_state = "hair_cia"

/datum/sprite_accessory/hair/coffeehouse
	name = "Coffee House"
	icon_state = "hair_coffeehouse"

/datum/sprite_accessory/hair/combover
	name = "Combover"
	icon_state = "hair_combover"

/datum/sprite_accessory/hair/cornrows1
	name = "Cornrows"
	icon_state = "hair_cornrows"

/datum/sprite_accessory/hair/cornrows2
	name = "Cornrows 2"
	icon_state = "hair_cornrows2"

/datum/sprite_accessory/hair/cornrowbun
	name = "Cornrow Bun"
	icon_state = "hair_cornrowbun"

/datum/sprite_accessory/hair/cornrowbraid
	name = "Cornrow Braid"
	icon_state = "hair_cornrowbraid"

/datum/sprite_accessory/hair/cornrowdualtail
	name = "Cornrow Tail"
	icon_state = "hair_cornrowtail"
	hair_appendages_inner = list("hair_cornrowtail_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_cornrowtail_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/crew
	name = "Crewcut"
	icon_state = "hair_crewcut"

/datum/sprite_accessory/hair/curls
	name = "Curls"
	icon_state = "hair_curls"

/datum/sprite_accessory/hair/cut
	name = "Cut Hair"
	icon_state = "hair_c"

/datum/sprite_accessory/hair/dandpompadour
	name = "Dandy Pompadour"
	icon_state = "hair_dandypompadour"

/datum/sprite_accessory/hair/devillock
	name = "Devil Lock"
	icon_state = "hair_devilock"

/datum/sprite_accessory/hair/doublebun
	name = "Double Bun"
	icon_state = "hair_doublebun"
	hair_appendages_inner = list("hair_doublebun_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_doublebun_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/dreadlocks
	name = "Dreadlocks"
	icon_state = "hair_dreads"

/datum/sprite_accessory/hair/drillhair
	name = "Drillruru"
	icon_state = "hair_drillruru"
	hair_appendages_inner = list("hair_drillruru_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_drillruru_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/drillhairextended
	name = "Drill Hair (Extended)"
	icon_state = "hair_drillhairextended"
	hair_appendages_inner = list("hair_drillhairextended_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_drillhairextended_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/emo
	name = "Emo"
	icon_state = "hair_emo"

/datum/sprite_accessory/hair/emofrine
	name = "Emo Fringe"
	icon_state = "hair_emofringe"

/datum/sprite_accessory/hair/nofade
	name = "Fade (None)"
	icon_state = "hair_nofade"

/datum/sprite_accessory/hair/highfade
	name = "Fade (High)"
	icon_state = "hair_highfade"

/datum/sprite_accessory/hair/medfade
	name = "Fade (Medium)"
	icon_state = "hair_medfade"

/datum/sprite_accessory/hair/lowfade
	name = "Fade (Low)"
	icon_state = "hair_lowfade"

/datum/sprite_accessory/hair/baldfade
	name = "Fade (Bald)"
	icon_state = "hair_baldfade"

/datum/sprite_accessory/hair/feather
	name = "Feather"
	icon_state = "hair_feather"

/datum/sprite_accessory/hair/father
	name = "Father"
	icon_state = "hair_father"

/datum/sprite_accessory/hair/sargeant
	name = "Flat Top"
	icon_state = "hair_sargeant"

/datum/sprite_accessory/hair/flair
	name = "Flair"
	icon_state = "hair_flair"

/datum/sprite_accessory/hair/bigflattop
	name = "Flat Top (Big)"
	icon_state = "hair_bigflattop"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/flow_hair
	name = "Flow Hair"
	icon_state = "hair_f"

/datum/sprite_accessory/hair/gelled
	name = "Gelled Back"
	icon_state = "hair_gelled"

/datum/sprite_accessory/hair/gentle
	name = "Gentle"
	icon_state = "hair_gentle"

/datum/sprite_accessory/hair/halfbang
	name = "Half-banged Hair"
	icon_state = "hair_halfbang"

/datum/sprite_accessory/hair/halfbang2
	name = "Half-banged Hair 2"
	icon_state = "hair_halfbang2"

/datum/sprite_accessory/hair/halfshaved
	name = "Half-shaved"
	icon_state = "hair_halfshaved"

/datum/sprite_accessory/hair/hedgehog
	name = "Hedgehog Hair"
	icon_state = "hair_hedgehog"

/datum/sprite_accessory/hair/himecut
	name = "Hime Cut"
	icon_state = "hair_himecut"

/datum/sprite_accessory/hair/himecut2
	name = "Hime Cut 2"
	icon_state = "hair_himecut2"

/datum/sprite_accessory/hair/shorthime
	name = "Hime Cut (Short)"
	icon_state = "hair_shorthime"

/datum/sprite_accessory/hair/himeup
	name = "Hime Updo"
	icon_state = "hair_himeup"

/datum/sprite_accessory/hair/hitop
	name = "Hitop"
	icon_state = "hair_hitop"

/datum/sprite_accessory/hair/jade
	name = "Jade"
	icon_state = "hair_jade"

/datum/sprite_accessory/hair/jensen
	name = "Jensen Hair"
	icon_state = "hair_jensen"

/datum/sprite_accessory/hair/joestar
	name = "Joestar"
	icon_state = "hair_joestar"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/keanu
	name = "Keanu Hair"
	icon_state = "hair_keanu"

/datum/sprite_accessory/hair/kusangi
	name = "Kusanagi Hair"
	icon_state = "hair_kusanagi"

/datum/sprite_accessory/hair/long
	name = "Long Hair 1"
	icon_state = "hair_long"
	hair_appendages_inner = list("hair_long_a1" = HAIR_APPENDAGE_HANGING_REAR)

/datum/sprite_accessory/hair/long2
	name = "Long Hair 2"
	icon_state = "hair_long2"
	hair_appendages_inner = list("hair_long2_a1" = HAIR_APPENDAGE_HANGING_REAR)

/datum/sprite_accessory/hair/long3
	name = "Long Hair 3"
	icon_state = "hair_long3"
	hair_appendages_inner = list("hair_long3_a1" = HAIR_APPENDAGE_HANGING_REAR)

/datum/sprite_accessory/hair/long_over_eye
	name = "Long Over Eye"
	icon_state = "hair_longovereye"

/datum/sprite_accessory/hair/longbangs
	name = "Long Bangs"
	icon_state = "hair_lbangs"

/datum/sprite_accessory/hair/longemo
	name = "Long Emo"
	icon_state = "hair_longemo"

/datum/sprite_accessory/hair/longfringe
	name = "Long Fringe"
	icon_state = "hair_longfringe"

/datum/sprite_accessory/hair/sidepartlongalt
	name = "Long Side Part"
	icon_state = "hair_longsidepart"
	hair_appendages_inner = list("hair_longsidepart_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_longsidepart_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/megaeyebrows
	name = "Mega Eyebrows"
	icon_state = "hair_megaeyebrows"

/datum/sprite_accessory/hair/messy
	name = "Messy"
	icon_state = "hair_messy"

/datum/sprite_accessory/hair/modern
	name = "Modern"
	icon_state = "hair_modern"

/datum/sprite_accessory/hair/mohawk
	name = "Mohawk"
	icon_state = "hair_d"
	natural_spawn = FALSE // sorry little one

/datum/sprite_accessory/hair/nitori
	name = "Nitori"
	icon_state = "hair_nitori"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/reversemohawk
	name = "Mohawk (Reverse)"
	icon_state = "hair_reversemohawk"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/shavedmohawk
	name = "Mohawk (Shaved)"
	icon_state = "hair_shavedmohawk"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/unshavenmohawk
	name = "Mohawk (Unshaven)"
	icon_state = "hair_unshaven_mohawk"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/mulder
	name = "Mulder"
	icon_state = "hair_mulder"

/datum/sprite_accessory/hair/odango
	name = "Odango"
	icon_state = "hair_odango"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/ombre
	name = "Ombre"
	icon_state = "hair_ombre"

/datum/sprite_accessory/hair/oneshoulder
	name = "One Shoulder"
	icon_state = "hair_oneshoulder"

/datum/sprite_accessory/hair/over_eye
	name = "Over Eye"
	icon_state = "hair_shortovereye"

/datum/sprite_accessory/hair/hair_overeyetwo
	name = "Over Eye 2"
	icon_state = "hair_overeyetwo"

/datum/sprite_accessory/hair/oxton
	name = "Oxton"
	icon_state = "hair_oxton"

/datum/sprite_accessory/hair/parted
	name = "Parted"
	icon_state = "hair_parted"

/datum/sprite_accessory/hair/partedside
	name = "Parted (Side)"
	icon_state = "hair_part"

/datum/sprite_accessory/hair/kagami
	name = "Pigtails"
	icon_state = "hair_kagami"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/pigtail
	name = "Pigtails 2"
	icon_state = "hair_pigtails"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/pigtail2
	name = "Pigtails 3"
	icon_state = "hair_pigtails2"
	natural_spawn = FALSE
	hair_appendages_inner = list("hair_pigtails2_a1" = HAIR_APPENDAGE_LEFT, "hair_pigtails2_a2" = HAIR_APPENDAGE_RIGHT)

/datum/sprite_accessory/hair/pixie
	name = "Pixie Cut"
	icon_state = "hair_pixie"

/datum/sprite_accessory/hair/pompadour
	name = "Pompadour"
	icon_state = "hair_pompadour"

/datum/sprite_accessory/hair/bigpompadour
	name = "Pompadour (Big)"
	icon_state = "hair_bigpompadour"

/datum/sprite_accessory/hair/ponytail1
	name = "Ponytail"
	icon_state = "hair_ponytail"

/datum/sprite_accessory/hair/ponytail2
	name = "Ponytail 2"
	icon_state = "hair_ponytail2"

/datum/sprite_accessory/hair/ponytail3
	name = "Ponytail 3"
	icon_state = "hair_ponytail3"

/datum/sprite_accessory/hair/ponytail4
	name = "Ponytail 4"
	icon_state = "hair_ponytail4"
	hair_appendages_inner = list("hair_ponytail4_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_ponytail4_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/ponytail5
	name = "Ponytail 5"
	icon_state = "hair_ponytail5"
	hair_appendages_inner = list("hair_ponytail5_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_ponytail5_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/ponytail6
	name = "Ponytail 6"
	icon_state = "hair_ponytail6"
	hair_appendages_inner = list("hair_ponytail6_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_ponytail6_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/ponytail7
	name = "Ponytail 7"
	icon_state = "hair_ponytail7"
	hair_appendages_inner = list("hair_ponytail7_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_ponytail7_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/highponytail
	name = "Ponytail (High)"
	icon_state = "hair_highponytail"
	hair_appendages_inner = list("hair_highponytail_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_highponytail_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/stail
	name = "Ponytail (Short)"
	icon_state = "hair_stail"
	hair_appendages_inner = list("hair_stail_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_stail_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/longponytail
	name = "Ponytail (Long)"
	icon_state = "hair_longstraightponytail"
	hair_appendages_inner = list("hair_longstraightponytail_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_longstraightponytail_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/countryponytail
	name = "Ponytail (Country)"
	icon_state = "hair_country"
	hair_appendages_inner = list("hair_country_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_country_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/fringetail
	name = "Ponytail (Fringe)"
	icon_state = "hair_fringetail"

/datum/sprite_accessory/hair/sidetail
	name = "Ponytail (Side)"
	icon_state = "hair_sidetail"

/datum/sprite_accessory/hair/sidetail2
	name = "Ponytail (Side) 2"
	icon_state = "hair_sidetail2"

/datum/sprite_accessory/hair/sidetail3
	name = "Ponytail (Side) 3"
	icon_state = "hair_sidetail3"
	hair_appendages_inner = list("hair_sidetail3_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_sidetail3_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/sidetail4
	name = "Ponytail (Side) 4"
	icon_state = "hair_sidetail4"
	hair_appendages_inner = list("hair_sidetail4_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_sidetail4_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/spikyponytail
	name = "Ponytail (Spiky)"
	icon_state = "hair_spikyponytail"
	hair_appendages_inner = list("hair_spikyponytail_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_spikyponytail_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/poofy
	name = "Poofy"
	icon_state = "hair_poofy"

/datum/sprite_accessory/hair/quiff
	name = "Quiff"
	icon_state = "hair_quiff"

/datum/sprite_accessory/hair/ronin
	name = "Ronin"
	icon_state = "hair_ronin"

/datum/sprite_accessory/hair/shaved
	name = "Shaved"
	icon_state = "hair_shaved"

/datum/sprite_accessory/hair/shavedpart
	name = "Shaved Part"
	icon_state = "hair_shavedpart"

/datum/sprite_accessory/hair/shortbangs
	name = "Short Bangs"
	icon_state = "hair_shortbangs"

/datum/sprite_accessory/hair/shortbangs2
	name = "Short Bangs 2"
	icon_state = "hair_shortbangs2"

/datum/sprite_accessory/hair/short
	name = "Short Hair"
	icon_state = "hair_a"

/datum/sprite_accessory/hair/shorthair2
	name = "Short Hair 2"
	icon_state = "hair_shorthair2"

/datum/sprite_accessory/hair/shorthair3
	name = "Short Hair 3"
	icon_state = "hair_shorthair3"

/datum/sprite_accessory/hair/shorthair4
	name = "Short Hair 4"
	icon_state = "hair_d"

/datum/sprite_accessory/hair/shorthair5
	name = "Short Hair 5"
	icon_state = "hair_e"

/datum/sprite_accessory/hair/shorthair6
	name = "Short Hair 6"
	icon_state = "hair_f"

/datum/sprite_accessory/hair/shorthair7
	name = "Short Hair 7"
	icon_state = "hair_shorthairg"

/datum/sprite_accessory/hair/shorthaireighties
	name = "Short Hair 80s"
	icon_state = "hair_80s"

/datum/sprite_accessory/hair/rosa
	name = "Short Hair Rosa"
	icon_state = "hair_rosa"

/datum/sprite_accessory/hair/shoulderlength
	name = "Shoulder-length Hair"
	icon_state = "hair_b"

/datum/sprite_accessory/hair/sidecut
	name = "Sidecut"
	icon_state = "hair_sidecut"

/datum/sprite_accessory/hair/skinhead
	name = "Skinhead"
	icon_state = "hair_skinhead"

/datum/sprite_accessory/hair/protagonist
	name = "Slightly Long Hair"
	icon_state = "hair_protagonist"

/datum/sprite_accessory/hair/spiky
	name = "Spiky"
	icon_state = "hair_spikey"

/datum/sprite_accessory/hair/spiky2
	name = "Spiky 2"
	icon_state = "hair_spiky"

/datum/sprite_accessory/hair/spiky3
	name = "Spiky 3"
	icon_state = "hair_spiky2"

/datum/sprite_accessory/hair/swept
	name = "Swept Back Hair"
	icon_state = "hair_swept"

/datum/sprite_accessory/hair/swept2
	name = "Swept Back Hair 2"
	icon_state = "hair_swept2"

/datum/sprite_accessory/hair/thinning
	name = "Thinning"
	icon_state = "hair_thinning"

/datum/sprite_accessory/hair/thinningfront
	name = "Thinning (Front)"
	icon_state = "hair_thinningfront"

/datum/sprite_accessory/hair/thinningrear
	name = "Thinning (Rear)"
	icon_state = "hair_thinningrear"

/datum/sprite_accessory/hair/topknot
	name = "Topknot"
	icon_state = "hair_topknot"

/datum/sprite_accessory/hair/tressshoulder
	name = "Tress Shoulder"
	icon_state = "hair_tressshoulder"
	hair_appendages_inner = list("hair_tressshoulder_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_tressshoulder_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/trimmed
	name = "Trimmed"
	icon_state = "hair_trimmed"

/datum/sprite_accessory/hair/trimflat
	name = "Trim Flat"
	icon_state = "hair_trimflat"

/datum/sprite_accessory/hair/twintails
	name = "Twintails"
	icon_state = "hair_twintail"

/datum/sprite_accessory/hair/undercut
	name = "Undercut"
	icon_state = "hair_undercut"

/datum/sprite_accessory/hair/undercutleft
	name = "Undercut Left"
	icon_state = "hair_undercutleft"

/datum/sprite_accessory/hair/undercutright
	name = "Undercut Right"
	icon_state = "hair_undercutright"

/datum/sprite_accessory/hair/unkept
	name = "Unkept"
	icon_state = "hair_unkept"

/datum/sprite_accessory/hair/updo
	name = "Updo"
	icon_state = "hair_updo"
	hair_appendages_inner = list("hair_updo_a1" = HAIR_APPENDAGE_TOP)

/datum/sprite_accessory/hair/longer
	name = "Very Long Hair"
	icon_state = "hair_vlong"

/datum/sprite_accessory/hair/longest
	name = "Very Long Hair 2"
	icon_state = "hair_longest"

/datum/sprite_accessory/hair/longest2
	name = "Very Long Over Eye"
	icon_state = "hair_longest2"

/datum/sprite_accessory/hair/veryshortovereye
	name = "Very Short Over Eye"
	icon_state = "hair_veryshortovereyealternate"

/datum/sprite_accessory/hair/longestalt
	name = "Very Long with Fringe"
	icon_state = "hair_vlongfringe"

/datum/sprite_accessory/hair/volaju
	name = "Volaju"
	icon_state = "hair_volaju"

/datum/sprite_accessory/hair/wisp
	name = "Wisp"
	icon_state = "hair_wisp"
	hair_appendages_inner = list("hair_wisp_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_wisp_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/ziegler
	name = "Ziegler"
	icon_state = "hair_ziegler"
	hair_appendages_inner = list("hair_ziegler_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_ziegler_a1o" = HAIR_APPENDAGE_REAR)


// Additional hair styles

/datum/sprite_accessory/hair/additional/hair_adhara
	name = "Adhara"
	icon_state = "hair_adhara"

/datum/sprite_accessory/hair/additional/hair_africanpigtails
	name = "African Pigtails"
	icon_state = "hair_africanpigtails"

/datum/sprite_accessory/hair/additional/hair_afro2alt
	name = "Afro 2 (Alt)"
	icon_state = "hair_afro2alt"

/datum/sprite_accessory/hair/additional/hair_afropuffdouble
	name = "Afropuff, Double"
	icon_state = "hair_afropuffdouble"

/datum/sprite_accessory/hair/additional/hair_afropuffleft
	name = "Afropuff, Left"
	icon_state = "hair_afropuffleft"

/datum/sprite_accessory/hair/additional/hair_afropuffright
	name = "Afropuff, Right"
	icon_state = "hair_afropuffright"

/datum/sprite_accessory/hair/additional/alchemist
	name = "Alchemist"
	icon_state = "alchemist"

/datum/sprite_accessory/hair/additional/alpaca
	name = "Alpaca"
	icon_state = "alpaca"

/datum/sprite_accessory/hair/additional/hair_amazon
	name = "Amazon"
	icon_state = "hair_amazon"

/datum/sprite_accessory/hair/additional/hair_angel_s
	name = "Angel"
	icon_state = "hair_angel_s"

/datum/sprite_accessory/hair/additional/hair_anita
	name = "Anita"
	icon_state = "hair_anita"

/datum/sprite_accessory/hair/additional/hair_archedmohawk
	name = "Arched Mohawk"
	icon_state = "hair_archedmohawk"

/datum/sprite_accessory/hair/additional/hair_astolfo
	name = "Astolfo"
	icon_state = "hair_astolfo"

/datum/sprite_accessory/hair/additional/hair_aviancrest
	name = "Avian Crest"
	icon_state = "hair_aviancrest"

/datum/sprite_accessory/hair/additional/hair_baum
	name = "Baum"
	icon_state = "hair_baum"

/datum/sprite_accessory/hair/additional/hair_beachwave
	name = "Beachwave"
	icon_state = "hair_beachwave"

/datum/sprite_accessory/hair/additional/hair_bedheadhline
	name = "Bedhead (+hairline)"
	icon_state = "hair_bedheadhline"

/datum/sprite_accessory/hair/additional/hair_short_bedhead
	name = "Bedhead (short)"
	icon_state = "hair_short_bedhead"

/datum/sprite_accessory/hair/additional/hair_b_alt
	name = "Bee"
	icon_state = "hair_b_alt"

/datum/sprite_accessory/hair/additional/hair_beehive2
	name = "Beehive 2 Alt"
	icon_state = "hair_beehive2"

/datum/sprite_accessory/hair/additional/hair_belenko
	name = "Beleneko"
	icon_state = "hair_belenko"

/datum/sprite_accessory/hair/additional/hair_belenkotied
	name = "Belenko (Tied)"
	icon_state = "hair_belenkotied"

/datum/sprite_accessory/hair/additional/hair_belle
	name = "Belle"
	icon_state = "hair_belle"

/datum/sprite_accessory/hair/additional/hair_longdtails
	name = "Big Tails"
	icon_state = "hair_longdtails"

/datum/sprite_accessory/hair/additional/big_afro
	name = "Bigger Afro"
	icon_state = "big_afro"

/datum/sprite_accessory/hair/additional/hair_bluntbangs
	name = "Blunt Bangs"
	icon_state = "hair_bluntbangs"

/datum/sprite_accessory/hair/additional/hair_bluntbangs_alt
	name = "Blunt Bangs Alt"
	icon_state = "hair_bluntbangs_alt"

/datum/sprite_accessory/hair/additional/hair_bluntbangsalt
	name = "Bluntbangs (Alt)"
	icon_state = "hair_bluntbangsalt"

/datum/sprite_accessory/hair/additional/hair_bobcutalt2
	name = "Bobcut (Alt) 2"
	icon_state = "hair_bobcutalt2"

/datum/sprite_accessory/hair/additional/hair_bobcutalt
	name = "Bobcut ALT"
	icon_state = "hair_bobcutalt"

/datum/sprite_accessory/hair/additional/hair_bobcut_over_eye_1
	name = "Bobcut over eye 1"
	icon_state = "hair_bobcut_over_eye_1"

/datum/sprite_accessory/hair/additional/hair_bobcut_over_eye_2
	name = "Bobcut over eye 2"
	icon_state = "hair_bobcut_over_eye_2"

/datum/sprite_accessory/hair/additional/hair_bobcut_over_eye_3
	name = "Bobcut over eye 3"
	icon_state = "hair_bobcut_over_eye_3"

/datum/sprite_accessory/hair/additional/hair_bonnie
	name = "Bonnie"
	icon_state = "hair_bonnie"

/datum/sprite_accessory/hair/additional/hair_bonnie_2
	name = "Bonnie 2"
	icon_state = "hair_bonnie_2"

/datum/sprite_accessory/hair/additional/hair_bonnie_long
	name = "Bonnie long"
	icon_state = "hair_bonnie_long"

/datum/sprite_accessory/hair/additional/hair_bonnie_2_long
	name = "Bonnie long 2"
	icon_state = "hair_bonnie_2_long"

/datum/sprite_accessory/hair/additional/hair_bonnie_short
	name = "Bonnie short"
	icon_state = "hair_bonnie_short"

/datum/sprite_accessory/hair/additional/hair_bonnie_2_short
	name = "Bonnie short 2"
	icon_state = "hair_bonnie_2_short"

/datum/sprite_accessory/hair/additional/hair_bun_alt
	name = "Bun Head (Alt)"
	icon_state = "hair_bun_alt"

/datum/sprite_accessory/hair/additional/hair_bunhead4
	name = "Bun Head 4"
	icon_state = "hair_bunhead4"

/datum/sprite_accessory/hair/additional/hair_bunhead3
	name = "Bunhead 3"
	icon_state = "hair_bunhead3"

/datum/sprite_accessory/hair/additional/pod_hair_cabbage
	name = "Cabbage"
	icon_state = "pod_hair_cabbage"

/datum/sprite_accessory/hair/additional/hair_choppylong
	name = "Choppy Long"
	icon_state = "hair_choppylong"

/datum/sprite_accessory/hair/additional/hair_ponytail_chunky
	name = "Chunky Ponytail"
	icon_state = "hair_ponytail_chunky"

/datum/sprite_accessory/hair/additional/hair_quadbun_chunky
	name = "Chunky Quad Buns"
	icon_state = "hair_quadbun_chunky"

/datum/sprite_accessory/hair/additional/hair_twinbun_chunky
	name = "Chunky Twin Buns"
	icon_state = "hair_twinbun_chunky"

/datum/sprite_accessory/hair/additional/hair_clean
	name = "Clean"
	icon_state = "hair_clean"

/datum/sprite_accessory/hair/additional/hair_clown
	name = "Clown"
	icon_state = "hair_clown"

/datum/sprite_accessory/hair/additional/hair_combed
	name = "Combed"
	icon_state = "hair_combed"

/datum/sprite_accessory/hair/additional/hair_combedback
	name = "Combed Back"
	icon_state = "hair_combedback"

/datum/sprite_accessory/hair/additional/hair_combedbob
	name = "Combed Bob"
	icon_state = "hair_combedbob"

/datum/sprite_accessory/hair/additional/hair_cotton
	name = "Cotton"
	icon_state = "hair_cotton"

/datum/sprite_accessory/hair/additional/hair_cottonalt
	name = "Cotton (Alt)"
	icon_state = "hair_cottonalt"

/datum/sprite_accessory/hair/additional/hair_country_alt
	name = "Country Alt"
	icon_state = "hair_country_alt"

/datum/sprite_accessory/hair/additional/hair_country_s
	name = "Country Side-Braid"
	icon_state = "hair_country_s"

/datum/sprite_accessory/hair/additional/m_hollyh
	name = "Cowlick"
	icon_state = "m_hollyH"

/datum/sprite_accessory/hair/additional/hair_curly
	name = "Curly"
	icon_state = "hair_curly"

/datum/sprite_accessory/hair/additional/hair_braided_front
	name = "Curly Front"
	icon_state = "hair_braided_front"

/datum/sprite_accessory/hair/additional/hair_curtains
	name = "Curtains"
	icon_state = "hair_curtains"

/datum/sprite_accessory/hair/additional/hair_damsel
	name = "Damsel"
	icon_state = "hair_damsel"

/datum/sprite_accessory/hair/additional/hair_dave
	name = "Dave"
	icon_state = "hair_dave"

/datum/sprite_accessory/hair/additional/hair_dave2
	name = "Dave 2"
	icon_state = "hair_dave2"

/datum/sprite_accessory/hair/additional/hair_dawn
	name = "Dawn"
	icon_state = "hair_dawn"

/datum/sprite_accessory/hair/additional/hair_deathhawk
	name = "Deathhawk"
	icon_state = "hair_deathhawk"

/datum/sprite_accessory/hair/additional/hair_devillock
	name = "Devillock"
	icon_state = "hair_devillock"

/datum/sprite_accessory/hair/additional/hair_diagonal_bangs
	name = "Diagonal Bangs"
	icon_state = "hair_diagonal_bangs"

/datum/sprite_accessory/hair/additional/hair_diagonalbangs
	name = "Diagonal Bangs Alt"
	icon_state = "hair_diagonalbangs"

/datum/sprite_accessory/hair/additional/hair_diagonal_bangs_alt
	name = "Diagonal Bangs Alt Alt"
	icon_state = "hair_diagonal_bangs_alt"

/datum/sprite_accessory/hair/additional/hair_dreads_alt
	name = "Dreadlocks Alt"
	icon_state = "hair_dreads_alt"

/datum/sprite_accessory/hair/additional/hair_dreadtail
	name = "Dreadtail"
	icon_state = "hair_dreadtail"

/datum/sprite_accessory/hair/additional/hair_drillhair
	name = "Drill Hair"
	icon_state = "hair_drillhair"

/datum/sprite_accessory/hair/additional/edgerunner
	name = "Edgerunner"
	icon_state = "edgerunner"

/datum/sprite_accessory/hair/additional/hair_elegantbun
	name = "Elegant Bun"
	icon_state = "hair_elegantbun"

/datum/sprite_accessory/hair/additional/elitesimian
	name = "Elite simian"
	icon_state = "elitesimian"

/datum/sprite_accessory/hair/additional/hair_emma
	name = "Emma"
	icon_state = "hair_emma"

/datum/sprite_accessory/hair/additional/hair_emo2
	name = "Emo 2"
	icon_state = "hair_emo2"

/datum/sprite_accessory/hair/additional/hair_emolong
	name = "Emo Long"
	icon_state = "hair_emolong"

/datum/sprite_accessory/hair/additional/hair_emoshort
	name = "Emo Short"
	icon_state = "hair_emoshort"

/datum/sprite_accessory/hair/additional/hair_emolong_alt
	name = "Emolong Alt"
	icon_state = "hair_emolong_alt"

/datum/sprite_accessory/hair/additional/pod_hair_fig
	name = "Fig"
	icon_state = "pod_hair_fig"

/datum/sprite_accessory/hair/additional/hair_fingerwave
	name = "Fingerwave"
	icon_state = "hair_fingerwave"

/datum/sprite_accessory/hair/additional/hair_flaguardyain
	name = "Flaguardyain"
	icon_state = "hair_flaguardyain"

/datum/sprite_accessory/hair/additional/hair_flatpressed
	name = "Flat Pressed"
	icon_state = "hair_flatpressed"

/datum/sprite_accessory/hair/additional/flippy_fringe
	name = "Flippy Fringe"
	icon_state = "flippy_fringe"

/datum/sprite_accessory/hair/additional/hair_flowerchild
	name = "Flowerchild"
	icon_state = "hair_flowerchild"

/datum/sprite_accessory/hair/additional/hair_flowerchild_ponyless
	name = "Flowerchild (No Ponytail)"
	icon_state = "hair_flowerchild_ponyless"

/datum/sprite_accessory/hair/additional/hair_flowerchild_ponyful
	name = "Flowerchild (Ponytail Only)"
	icon_state = "hair_flowerchild_ponyful"

/datum/sprite_accessory/hair/additional/hair_fluffball
	name = "Fluffball"
	icon_state = "hair_fluffball"

/datum/sprite_accessory/hair/additional/hair_fluffy
	name = "Fluffy"
	icon_state = "hair_fluffy"

/datum/sprite_accessory/hair/additional/hair_fluffy_bangs
	name = "Fluffy Bangs"
	icon_state = "hair_fluffy_bangs"

/datum/sprite_accessory/hair/additional/hair_fluffycurls
	name = "Fluffy Curls"
	icon_state = "hair_fluffycurls"

/datum/sprite_accessory/hair/additional/hair_fluffy_long
	name = "Fluffy long"
	icon_state = "hair_fluffy_long"

/datum/sprite_accessory/hair/additional/hair_fluffy_short
	name = "Fluffy Short"
	icon_state = "hair_fluffy_short"

/datum/sprite_accessory/hair/additional/forelock
	name = "Forelock (Chub)"
	icon_state = "forelock"

/datum/sprite_accessory/hair/additional/hair_fortuneteller
	name = "Fortune Teller"
	icon_state = "hair_fortuneteller"

/datum/sprite_accessory/hair/additional/hair_fortuneteller_alt
	name = "Fortune Teller Alt"
	icon_state = "hair_fortuneteller_alt"

/datum/sprite_accessory/hair/additional/hair_froofy
	name = "Froofy"
	icon_state = "hair_froofy"

/datum/sprite_accessory/hair/additional/hair_froofylong
	name = "Froofy Long"
	icon_state = "hair_froofylong"

/datum/sprite_accessory/hair/additional/hair_geisha
	name = "Geisha"
	icon_state = "hair_geisha"

/datum/sprite_accessory/hair/additional/hair_gentle_alt
	name = "Gentle Alt"
	icon_state = "hair_gentle_alt"

/datum/sprite_accessory/hair/additional/hair_gentle_bun
	name = "Gentle Bun"
	icon_state = "hair_gentle_bun"

/datum/sprite_accessory/hair/additional/hair_gentle_duo_bun
	name = "Gentle Duo Bun"
	icon_state = "hair_gentle_duo_bun"

/datum/sprite_accessory/hair/additional/hair_gentle21
	name = "Gently Brushed"
	icon_state = "hair_gentle21"

/datum/sprite_accessory/hair/additional/giga_fro
	name = "GigAfro"
	icon_state = "giga_fro"

/datum/sprite_accessory/hair/additional/gigapomp
	name = "Gigapompadour"
	icon_state = "gigapomp"

/datum/sprite_accessory/hair/additional/hair_glammetal
	name = "Glam Metal"
	icon_state = "hair_glammetal"

/datum/sprite_accessory/hair/additional/hair_glamourh
	name = "Glamour"
	icon_state = "hair_glamourh"

/datum/sprite_accessory/hair/additional/hair_gloomy
	name = "Gloomy"
	icon_state = "hair_gloomy"

/datum/sprite_accessory/hair/additional/hair_gloomylong
	name = "Gloomy (Long)"
	icon_state = "hair_gloomylong"

/datum/sprite_accessory/hair/additional/hair_grande
	name = "Grande"
	icon_state = "hair_grande"

/datum/sprite_accessory/hair/additional/hair_hairfre
	name = "Hairfre"
	icon_state = "hair_hairfre"

/datum/sprite_accessory/hair/additional/hair_hajime
	name = "Hajime"
	icon_state = "hair_hajime"

/datum/sprite_accessory/hair/additional/hair_hajimealt
	name = "Hajime (Alt)"
	icon_state = "hair_hajimealt"

/datum/sprite_accessory/hair/additional/hair_bob_half
	name = "Half Bob"
	icon_state = "hair_bob_half"

/datum/sprite_accessory/hair/additional/hair_halfshaved_s
	name = "Half Shaved"
	icon_state = "hair_halfshaved_s"

/datum/sprite_accessory/hair/additional/hair_halfshavedemo_s
	name = "Half Shaved Demo"
	icon_state = "hair_halfshavedemo_s"

/datum/sprite_accessory/hair/additional/hair_halfbangalt
	name = "Halfbang ALT"
	icon_state = "hair_halfbangalt"

/datum/sprite_accessory/hair/additional/hair_halfbang_alt
	name = "Half-banged Hair (Alt)"
	icon_state = "hair_halfbang_alt"

/datum/sprite_accessory/hair/additional/hair_halfbang2_alt
	name = "Halfbangs Alt"
	icon_state = "hair_halfbang2_alt"

/datum/sprite_accessory/hair/additional/halfshave_glamorous
	name = "Half-shave glamorous"
	icon_state = "halfshave_glamorous"

/datum/sprite_accessory/hair/additional/halfshave_glamorous_alt
	name = "Half-shave glamorous alt"
	icon_state = "halfshave_glamorous_alt"

/datum/sprite_accessory/hair/additional/hair_halfshave_long
	name = "Half-Shave Long"
	icon_state = "hair_halfshave_long"

/datum/sprite_accessory/hair/additional/hair_halfshave_long_alt
	name = "Half-Shave Long Alt"
	icon_state = "hair_halfshave_long_alt"

/datum/sprite_accessory/hair/additional/halfshave_messylong
	name = "Half-shave long messy"
	icon_state = "halfshave_messylong"

/datum/sprite_accessory/hair/additional/halfshave_messylong_alt
	name = "Half-shave long messy alt"
	icon_state = "halfshave_messylong_alt"

/datum/sprite_accessory/hair/additional/hair_halfshave_messylong
	name = "Half-Shave Messy Long"
	icon_state = "hair_halfshave_messylong"

/datum/sprite_accessory/hair/additional/hair_halfshave_messylong_alt
	name = "Half-Shave Messy Long Alt"
	icon_state = "hair_halfshave_messylong_alt"

/datum/sprite_accessory/hair/additional/hair_halfshave
	name = "Half-shaved 2"
	icon_state = "hair_halfshave"

/datum/sprite_accessory/hair/additional/hair_halfshave_snout
	name = "Half-shaved 2 (clipped)"
	icon_state = "hair_halfshave_snout"

/datum/sprite_accessory/hair/additional/hair_halfshave_alt
	name = "Half-shaved 2 Alt"
	icon_state = "hair_halfshave_alt"

/datum/sprite_accessory/hair/additional/hair_halfshave_glamorous
	name = "Halfshaved Glamorous"
	icon_state = "hair_halfshave_glamorous"

/datum/sprite_accessory/hair/additional/hair_halfshave_glamorous_alt
	name = "Halfshaved Glamorous (Alt)"
	icon_state = "hair_halfshave_glamorous_alt"

/datum/sprite_accessory/hair/additional/halfshave_long
	name = "Half-shaved long"
	icon_state = "halfshave_long"

/datum/sprite_accessory/hair/additional/halfshave_long_alt
	name = "Half-shaved long alt"
	icon_state = "halfshave_long_alt"

/datum/sprite_accessory/hair/additional/hair_halfshave_messy
	name = "Halfshaved Messy"
	icon_state = "hair_halfshave_messy"

/datum/sprite_accessory/hair/additional/halfshave_messy
	name = "Half-shaved messy"
	icon_state = "halfshave_messy"

/datum/sprite_accessory/hair/additional/hair_halfshave_messy_alt
	name = "Halfshaved Messy (Alt)"
	icon_state = "hair_halfshave_messy_alt"

/datum/sprite_accessory/hair/additional/halfshave_messy_alt
	name = "Half-shaved messy alt"
	icon_state = "halfshave_messy_alt"

/datum/sprite_accessory/hair/additional/hair_harold
	name = "Harold"
	icon_state = "hair_harold"

/datum/sprite_accessory/hair/additional/pod_hair_hibiscus
	name = "Hibiscus"
	icon_state = "pod_hair_hibiscus"

/datum/sprite_accessory/hair/additional/hair_hiddeneyes
	name = "Hidden Eyes"
	icon_state = "hair_hiddeneyes"

/datum/sprite_accessory/hair/additional/hair_hiddeneyes_alt2
	name = "Hidden Eyes (Alt 2)"
	icon_state = "hair_hiddeneyes_alt2"

/datum/sprite_accessory/hair/additional/hair_hiddeneyes_alt
	name = "Hidden Eyes (Alt)"
	icon_state = "hair_hiddeneyes_alt"

/datum/sprite_accessory/hair/additional/hair_hightight
	name = "Hightight"
	icon_state = "hair_hightight"

/datum/sprite_accessory/hair/additional/hair_holo_tuber
	name = "Holo Tuber"
	icon_state = "hair_holo_tuber"

/datum/sprite_accessory/hair/additional/hair_honse
	name = "Honse"
	icon_state = "hair_honse"

/datum/sprite_accessory/hair/additional/hair_hyenamane
	name = "Hyena mane"
	icon_state = "hair_hyenamane"

/datum/sprite_accessory/hair/additional/hair_inari
	name = "Inari"
	icon_state = "hair_inari"

/datum/sprite_accessory/hair/additional/hair_inkling
	name = "Inkling"
	icon_state = "hair_inkling"

/datum/sprite_accessory/hair/additional/pod_hair_ivy
	name = "Ivy"
	icon_state = "pod_hair_ivy"

/datum/sprite_accessory/hair/additional/hair_jay
	name = "Jay"
	icon_state = "hair_jay"

/datum/sprite_accessory/hair/additional/hair_jensen_alt
	name = "Jensen Alt"
	icon_state = "hair_jensen_alt"

/datum/sprite_accessory/hair/additional/hair_jessica
	name = "Jessica"
	icon_state = "hair_jessica"

/datum/sprite_accessory/hair/additional/hair_jessica_alt
	name = "Jessica Alt"
	icon_state = "hair_jessica_alt"

/datum/sprite_accessory/hair/additional/hair_judgement
	name = "Judgement"
	icon_state = "hair_judgement"

/datum/sprite_accessory/hair/additional/hair_judgement_alt
	name = "Judgement (Alt)"
	icon_state = "hair_judgement_alt"

/datum/sprite_accessory/hair/additional/hair_judgement_alt_cowlick
	name = "Judgement (Cowlick)"
	icon_state = "hair_judgement_alt_cowlick"

/datum/sprite_accessory/hair/additional/hair_kajam
	name = "Kajam"
	icon_state = "hair_kajam"

/datum/sprite_accessory/hair/additional/kajam2_s
	name = "Kajam (Alt)"
	icon_state = "kajam2_s"

/datum/sprite_accessory/hair/additional/hair_katara_s
	name = "Katara"
	icon_state = "hair_katara_s"

/datum/sprite_accessory/hair/additional/hair_khmuro
	name = "Khmuro"
	icon_state = "hair_khmuro"

/datum/sprite_accessory/hair/additional/hair_kisaragi
	name = "Kisaragi"
	icon_state = "hair_kisaragi"

/datum/sprite_accessory/hair/additional/hair_kleeia
	name = "Kleeia"
	icon_state = "hair_kleeia"

/datum/sprite_accessory/hair/additional/hair_kobeni_1
	name = "Kobeni 1"
	icon_state = "hair_kobeni_1"

/datum/sprite_accessory/hair/additional/hair_kobeni_2
	name = "Kobeni 2"
	icon_state = "hair_kobeni_2"

/datum/sprite_accessory/hair/additional/hair_kusanagi_alt
	name = "Kusanagi Alt"
	icon_state = "hair_kusanagi_alt"

/datum/sprite_accessory/hair/additional/hair_long4
	name = "Long 4"
	icon_state = "hair_long4"

/datum/sprite_accessory/hair/additional/long_messy
	name = "Long and Messy"
	icon_state = "long_messy"

/datum/sprite_accessory/hair/additional/hair_dreadlocks_long
	name = "Long Dreadlocks"
	icon_state = "hair_dreadlocks_long"

/datum/sprite_accessory/hair/additional/hair_gloomy_long
	name = "Long Gloomy Bangs"
	icon_state = "hair_gloomy_long"

/datum/sprite_accessory/hair/additional/hair_longovereyealt
	name = "Long Over Eye (Alt)"
	icon_state = "hair_longovereyealt"

/datum/sprite_accessory/hair/additional/hair_longovereye_alt
	name = "Long Over Eye Alt"
	icon_state = "hair_longovereye_alt"

/datum/sprite_accessory/hair/additional/hair_longsidepart_alt
	name = "Long Side Part Alt"
	icon_state = "hair_longsidepart_alt"

/datum/sprite_accessory/hair/additional/hair_longsidepartstraight
	name = "Long Sideparted"
	icon_state = "hair_longsidepartstraight"

/datum/sprite_accessory/hair/additional/hair_long_smoothy
	name = "Long Smoothy"
	icon_state = "hair_long_smoothy"

/datum/sprite_accessory/hair/additional/hair_thin_ponytail_long
	name = "Long thin ponytail"
	icon_state = "hair_thin_ponytail_long"

/datum/sprite_accessory/hair/additional/hair_twintails_2_long
	name = "Long twintails"
	icon_state = "hair_twintails_2_long"

/datum/sprite_accessory/hair/additional/long_undercut
	name = "Long Undercut"
	icon_state = "long_undercut"

/datum/sprite_accessory/hair/additional/hair_wavylong
	name = "Long Wavy"
	icon_state = "hair_wavylong"

/datum/sprite_accessory/hair/additional/hair_longemo_alt_2
	name = "Longemo"
	icon_state = "hair_longemo_alt_2"

/datum/sprite_accessory/hair/additional/hair_longeralt
	name = "Longer ALT"
	icon_state = "hair_longeralt"

/datum/sprite_accessory/hair/additional/hair_longer_bedhead
	name = "Longer Bedhead"
	icon_state = "hair_longer_bedhead"

/datum/sprite_accessory/hair/additional/hair_loose_slicked
	name = "Loose Slicked"
	icon_state = "hair_loose_slicked"

/datum/sprite_accessory/hair/additional/hair_low_bun
	name = "Low bun"
	icon_state = "hair_low_bun"

/datum/sprite_accessory/hair/additional/hair_low_ponytail
	name = "Low ponytail"
	icon_state = "hair_low_ponytail"

/datum/sprite_accessory/hair/additional/marge
	name = "Marge"
	icon_state = "marge"

/datum/sprite_accessory/hair/additional/hair_mayrain
	name = "May Rain"
	icon_state = "hair_mayrain"

/datum/sprite_accessory/hair/additional/hair_mcsqueeb
	name = "McSqueeb"
	icon_state = "hair_mcsqueeb"

/datum/sprite_accessory/hair/additional/hair_mediumbraid
	name = "Medium Braid"
	icon_state = "hair_mediumbraid"

/datum/sprite_accessory/hair/additional/hair_gloomy_medium
	name = "Medium Gloomy Bangs"
	icon_state = "hair_gloomy_medium"

/datum/sprite_accessory/hair/additional/hair_mermaid
	name = "Mermaid"
	icon_state = "hair_mermaid"

/datum/sprite_accessory/hair/additional/hair_messy2
	name = "Messy2"
	icon_state = "hair_messy2"

/datum/sprite_accessory/hair/additional/hair_bob_half_mirrored
	name = "Mirrored Half Bob"
	icon_state = "hair_bob_half_mirrored"

/datum/sprite_accessory/hair/additional/hair_misshapen
	name = "Misshapen"
	icon_state = "hair_misshapen"

/datum/sprite_accessory/hair/additional/mohawk
	name = "Mohawk (Alt)"
	icon_state = "mohawk"

/datum/sprite_accessory/hair/additional/hair_mohawkshort
	name = "Mohawk Short"
	icon_state = "hair_mohawkshort"

/datum/sprite_accessory/hair/additional/monkey_king
	name = "Monkey king"
	icon_state = "monkey_king"

/datum/sprite_accessory/hair/additional/hair_morning
	name = "Morning"
	icon_state = "hair_morning"

/datum/sprite_accessory/hair/additional/hair_moth_messy
	name = "Moth Hair Messy"
	icon_state = "hair_moth_messy"

/datum/sprite_accessory/hair/additional/hair_moth_short
	name = "Moth Hair Short"
	icon_state = "hair_moth_short"

/datum/sprite_accessory/hair/additional/hair_moth_spiky
	name = "Moth Hair Spiky"
	icon_state = "hair_moth_spiky"

/datum/sprite_accessory/hair/additional/hair_moth_tuft
	name = "Moth Hair Tuft"
	icon_state = "hair_moth_tuft"

/datum/sprite_accessory/hair/additional/hair_moth_ponytail_1
	name = "Moth Ponytail 1"
	icon_state = "hair_moth_ponytail_1"

/datum/sprite_accessory/hair/additional/hair_moth_ponytail_2
	name = "Moth Ponytail 2"
	icon_state = "hair_moth_ponytail_2"

/datum/sprite_accessory/hair/additional/hair_mullet
	name = "Mullet"
	icon_state = "hair_mullet"

/datum/sprite_accessory/hair/additional/hair_newyou
	name = "New You"
	icon_state = "hair_newyou"

/datum/sprite_accessory/hair/additional/hair_nia
	name = "Nia"
	icon_state = "hair_nia"

/datum/sprite_accessory/hair/additional/pod_hair_orchid
	name = "Orchid"
	icon_state = "pod_hair_orchid"

/datum/sprite_accessory/hair/additional/hair_over_ear_1
	name = "Over ear 1"
	icon_state = "hair_over_ear_1"

/datum/sprite_accessory/hair/additional/hair_over_ear_2
	name = "Over ear 2"
	icon_state = "hair_over_ear_2"

/datum/sprite_accessory/hair/additional/hair_over_eye
	name = "Over eye Alt"
	icon_state = "hair_over_eye"

/datum/sprite_accessory/hair/additional/hair_shortovereye_1f
	name = "Over Eye (fract)"
	icon_state = "hair_shortovereye_1f"

/datum/sprite_accessory/hair/additional/hair_immovable
	name = "Ozen"
	icon_state = "hair_immovable"

/datum/sprite_accessory/hair/additional/hair_phoebe
	name = "Phoebe"
	icon_state = "hair_phoebe"

/datum/sprite_accessory/hair/additional/hair_phoenix
	name = "Phoenix"
	icon_state = "hair_phoenix"

/datum/sprite_accessory/hair/additional/hair_phoenix_half_shaven
	name = "Phoenix Half-Shaven"
	icon_state = "hair_phoenix_half_shaven"

/datum/sprite_accessory/hair/additional/hair_pigtailss
	name = "Pigtails 4"
	icon_state = "hair_pigtailss"

/datum/sprite_accessory/hair/additional/hair_pigtails_alt
	name = "Pigtails Alt"
	icon_state = "hair_pigtails_alt"

/datum/sprite_accessory/hair/additional/hair_bowpigtails
	name = "Pigtails with Bows"
	icon_state = "hair_bowpigtails"

/datum/sprite_accessory/hair/additional/hair_plait
	name = "Plait"
	icon_state = "hair_plait"

/datum/sprite_accessory/hair/additional/pod_hair_f
	name = "Pod Female"
	icon_state = "pod_hair_f"

/datum/sprite_accessory/hair/additional/pod_hair_m
	name = "Pod Male"
	icon_state = "pod_hair_m"

/datum/sprite_accessory/hair/additional/polnareff
	name = "Polnareff"
	icon_state = "polnareff"

/datum/sprite_accessory/hair/additional/hair_bigpompadouralt
	name = "Pompadour (Big) (Alt)"
	icon_state = "hair_bigpompadouralt"

/datum/sprite_accessory/hair/additional/hair_sharptail
	name = "Ponytail (Sharp)"
	icon_state = "hair_sharptail"

/datum/sprite_accessory/hair/additional/hair_sidetail5
	name = "Ponytail (Side) 5"
	icon_state = "hair_sidetail5"

/datum/sprite_accessory/hair/additional/hair_spikyponytail_alt
	name = "Ponytail (Spiky) ALT"
	icon_state = "hair_spikyponytail_alt"

/datum/sprite_accessory/hair/additional/hair_ponytail_10
	name = "Ponytail 10"
	icon_state = "hair_ponytail_10"

/datum/sprite_accessory/hair/additional/hair_ponytail_11
	name = "Ponytail 11"
	icon_state = "hair_ponytail_11"

/datum/sprite_accessory/hair/additional/hair_ponytail_12
	name = "Ponytail 12"
	icon_state = "hair_ponytail_12"

/datum/sprite_accessory/hair/additional/hair_ponytail3alt
	name = "Ponytail 3 (Alt)"
	icon_state = "hair_ponytail3alt"

/datum/sprite_accessory/hair/additional/hair_ponytail4alt
	name = "Ponytail 4 (Alt)"
	icon_state = "hair_ponytail4alt"

/datum/sprite_accessory/hair/additional/hair_ponytail_8
	name = "Ponytail 8"
	icon_state = "hair_ponytail_8"

/datum/sprite_accessory/hair/additional/hair_80s_ponytail_alt_2
	name = "Ponytail 80s"
	icon_state = "hair_80s_ponytail_alt_2"

/datum/sprite_accessory/hair/additional/hair_ponytail_9
	name = "Ponytail 9"
	icon_state = "hair_ponytail_9"

/datum/sprite_accessory/hair/additional/hair_ponytailalt
	name = "Ponytail ALT"
	icon_state = "hair_ponytailalt"

/datum/sprite_accessory/hair/additional/hair_ponytailf
	name = "Ponytail Feminine"
	icon_state = "hair_ponytailf"

/datum/sprite_accessory/hair/additional/hair_tails_berly
	name = "Ponytails (Berly)"
	icon_state = "hair_tails_berly"

/datum/sprite_accessory/hair/additional/hair_poofy2
	name = "Poofy 2"
	icon_state = "hair_poofy2"

/datum/sprite_accessory/hair/additional/poooooooooolnareff
	name = "Poooooooooolnareff"
	icon_state = "poooooooooolnareff"

/datum/sprite_accessory/hair/additional/pod_hair_prayer
	name = "Prayer"
	icon_state = "pod_hair_prayer"

/datum/sprite_accessory/hair/additional/hair_quadcurls
	name = "Quad Curls"
	icon_state = "hair_quadcurls"

/datum/sprite_accessory/hair/additional/hair_ring_tails
	name = "Ring Tails"
	icon_state = "hair_ring_tails"

/datum/sprite_accessory/hair/additional/hair_rockstar
	name = "Rockstar"
	icon_state = "hair_rockstar"

/datum/sprite_accessory/hair/additional/pod_hair_rose
	name = "Rose"
	icon_state = "pod_hair_rose"

/datum/sprite_accessory/hair/additional/hair_rowbraid
	name = "Row Braid"
	icon_state = "hair_rowbraid"

/datum/sprite_accessory/hair/additional/hair_rowbun
	name = "Row Bun"
	icon_state = "hair_rowbun"

/datum/sprite_accessory/hair/additional/hair_rowdualtail
	name = "Row Dual Tail"
	icon_state = "hair_rowdualtail"

/datum/sprite_accessory/hair/additional/hair_rows1
	name = "Rows 1"
	icon_state = "hair_rows1"

/datum/sprite_accessory/hair/additional/hair_rows2
	name = "Rows 2"
	icon_state = "hair_rows2"

/datum/sprite_accessory/hair/additional/hair_royalcurl
	name = "Royal Curls"
	icon_state = "hair_royalcurl"

/datum/sprite_accessory/hair/additional/hair_royalcurls
	name = "Royal Curls Alt"
	icon_state = "hair_royalcurls"

/datum/sprite_accessory/hair/additional/royal_curls
	name = "Royal Curls Alt 2"
	icon_state = "royal_curls"

/datum/sprite_accessory/hair/additional/hair_runner
	name = "Runner"
	icon_state = "hair_runner"

/datum/sprite_accessory/hair/additional/hair_runner_bun
	name = "Runner Bun"
	icon_state = "hair_runner_bun"

/datum/sprite_accessory/hair/additional/hair_sabitsuki
	name = "Sabitsuki"
	icon_state = "hair_sabitsuki"

/datum/sprite_accessory/hair/additional/hair_scully
	name = "Scully"
	icon_state = "hair_scully"

/datum/sprite_accessory/hair/additional/hair_sergal_axolotl
	name = "Sergal axolotl"
	icon_state = "hair_sergal_axolotl"

/datum/sprite_accessory/hair/additional/hair_sergal_brushed
	name = "Sergal brushed"
	icon_state = "hair_sergal_brushed"

/datum/sprite_accessory/hair/additional/hair_sergal_bun
	name = "Sergal bun"
	icon_state = "hair_sergal_bun"

/datum/sprite_accessory/hair/additional/hair_sergal_long
	name = "Sergal long"
	icon_state = "hair_sergal_long"

/datum/sprite_accessory/hair/additional/hair_sergal_round
	name = "Sergal round"
	icon_state = "hair_sergal_round"

/datum/sprite_accessory/hair/additional/hair_sergal_shogun
	name = "Sergal shogun"
	icon_state = "hair_sergal_shogun"

/datum/sprite_accessory/hair/additional/hair_sergal_short
	name = "Sergal short"
	icon_state = "hair_sergal_short"

/datum/sprite_accessory/hair/additional/hair_sergal_spiky
	name = "Sergal spiky"
	icon_state = "hair_sergal_spiky"

/datum/sprite_accessory/hair/additional/hair_sergeant
	name = "Sergeant"
	icon_state = "hair_sergeant"

/datum/sprite_accessory/hair/additional/hair_shaggy
	name = "Shaggy"
	icon_state = "hair_shaggy"

/datum/sprite_accessory/hair/additional/hair_shavedbun_s
	name = "Shaved Bun"
	icon_state = "hair_shavedbun_s"

/datum/sprite_accessory/hair/additional/hair_short_bob
	name = "Short (Bob)"
	icon_state = "hair_short_bob"

/datum/sprite_accessory/hair/additional/hair_short_side
	name = "Short (Side)"
	icon_state = "hair_short_side"

/datum/sprite_accessory/hair/additional/hair_shortbedhead
	name = "Short Bed Head"
	icon_state = "hair_shortbedhead"

/datum/sprite_accessory/hair/additional/hair_choppy
	name = "Short Choppy"
	icon_state = "hair_choppy"

/datum/sprite_accessory/hair/additional/hair_ponytail_short
	name = "Short fluffy ponytail"
	icon_state = "hair_ponytail_short"

/datum/sprite_accessory/hair/additional/hair_shorthair4
	name = "Short Hair 4 Alt"
	icon_state = "hair_shorthair4"

/datum/sprite_accessory/hair/additional/hair_shortovereyealt
	name = "Short Over Eye ALT"
	icon_state = "hair_shortovereyealt"

/datum/sprite_accessory/hair/additional/hair_short_tassles
	name = "Short Tassles"
	icon_state = "hair_short_tassles"

/datum/sprite_accessory/hair/additional/hair_twintails_2_short
	name = "Short twintails"
	icon_state = "hair_twintails_2_short"

/datum/sprite_accessory/hair/additional/shrine_priestess
	name = "Shrine Priestess"
	icon_state = "shrine_priestess"

/datum/sprite_accessory/hair/additional/pod_hair_shrub
	name = "Shrub"
	icon_state = "pod_hair_shrub"

/datum/sprite_accessory/hair/additional/hair_shy
	name = "Shy"
	icon_state = "hair_shy"

/datum/sprite_accessory/hair/additional/hair_tailhair2
	name = "Side Hair"
	icon_state = "hair_tailhair2"

/datum/sprite_accessory/hair/additional/hair_straightside
	name = "Side Straight"
	icon_state = "hair_straightside"

/datum/sprite_accessory/hair/additional/hair_sideways_ponytail
	name = "Sideways ponytail"
	icon_state = "hair_sideways_ponytail"

/datum/sprite_accessory/hair/additional/hair_silky
	name = "Silky"
	icon_state = "hair_silky"

/datum/sprite_accessory/hair/additional/hair_simple
	name = "Simple"
	icon_state = "hair_simple"

/datum/sprite_accessory/hair/additional/hair_simple_long
	name = "Simple long"
	icon_state = "hair_simple_long"

/datum/sprite_accessory/hair/additional/hair_simple_ponytail
	name = "Simple Ponytail"
	icon_state = "hair_simple_ponytail"

/datum/sprite_accessory/hair/additional/hair_simple_ponytail_alt
	name = "Simple Ponytail Alt"
	icon_state = "hair_simple_ponytail_alt"

/datum/sprite_accessory/hair/additional/hair_simple_ponytail_alt_two
	name = "Simple Ponytail Alt Two"
	icon_state = "hair_simple_ponytail_alt_2"

/datum/sprite_accessory/hair/additional/hair_simple_short
	name = "Simple short"
	icon_state = "hair_simple_short"

/datum/sprite_accessory/hair/additional/hair_skrell
	name = "Skrell Replicant (Average)"
	icon_state = "hair_skrell"

/datum/sprite_accessory/hair/additional/hair_skrelllong
	name = "Skrell Replicant (Long)"
	icon_state = "hair_skrelllong"

/datum/sprite_accessory/hair/additional/hair_skrellshort
	name = "Skrell Replicant (Short)"
	icon_state = "hair_skrellshort"

/datum/sprite_accessory/hair/additional/hair_skrellvshort
	name = "Skrell Replicant (Very Short)"
	icon_state = "hair_skrellvshort"

/datum/sprite_accessory/hair/additional/hair_sleaze
	name = "Sleaze"
	icon_state = "hair_sleaze"

/datum/sprite_accessory/hair/additional/hair_sleeper
	name = "Sleeper"
	icon_state = "hair_sleeper"

/datum/sprite_accessory/hair/additional/hair_sleeper_alt
	name = "Sleeper (Alt)"
	icon_state = "hair_sleeper_alt"

/datum/sprite_accessory/hair/additional/hair_slightlymessy
	name = "Slightly Messy"
	icon_state = "hair_slightlymessy"

/datum/sprite_accessory/hair/additional/hair_slimedroplet
	name = "Slime Droplet"
	icon_state = "hair_slimedroplet"

/datum/sprite_accessory/hair/additional/hair_slimedropletalt
	name = "Slime Droplet (Alt)"
	icon_state = "hair_slimedropletalt"

/datum/sprite_accessory/hair/additional/hair_slimedroplet_alt
	name = "Slime Droplet Alt"
	icon_state = "hair_slimedroplet_alt"

/datum/sprite_accessory/hair/additional/hair_slimespikes
	name = "Slime Spikes"
	icon_state = "hair_slimespikes"

/datum/sprite_accessory/hair/additional/hair_slimetendrils
	name = "Slime Tendrils"
	icon_state = "hair_slimetendrils"

/datum/sprite_accessory/hair/additional/hair_slimetendrilsalt
	name = "Slime Tendrils (Alt)"
	icon_state = "hair_slimetendrilsalt"

/datum/sprite_accessory/hair/additional/hair_slimetendrils_alt
	name = "Slime Tendrils Alt"
	icon_state = "hair_slimetendrils_alt"

/datum/sprite_accessory/hair/additional/s_hair_longfringe
	name = "Smooth Long Fringe"
	icon_state = "s_hair_longfringe"

/datum/sprite_accessory/hair/additional/hair_spicy
	name = "Spicy"
	icon_state = "hair_spicy"

/datum/sprite_accessory/hair/additional/hair_spicyalt
	name = "Spicy (Alt)"
	icon_state = "hair_spicyalt"

/datum/sprite_accessory/hair/additional/hair_spikey_long
	name = "Spikey Long"
	icon_state = "hair_spikey_long"

/datum/sprite_accessory/hair/additional/pod_hair_spinach
	name = "Spinach"
	icon_state = "pod_hair_spinach"

/datum/sprite_accessory/hair/additional/hair_stacy
	name = "Stacy"
	icon_state = "hair_stacy"

/datum/sprite_accessory/hair/additional/hair_stacy_bun
	name = "Stacy Bun"
	icon_state = "hair_stacy_bun"

/datum/sprite_accessory/hair/additional/hair_straight
	name = "Straight"
	icon_state = "hair_straight"

/datum/sprite_accessory/hair/additional/hair_straightlong
	name = "Straight Long"
	icon_state = "hair_straightlong"

/datum/sprite_accessory/hair/additional/hair_straightshort
	name = "Straight Long Alt"
	icon_state = "hair_straightshort"

/datum/sprite_accessory/hair/additional/hair_straightfloorlength
	name = "Straight Long (Very)"
	icon_state = "hair_straightfloorlength"

/datum/sprite_accessory/hair/additional/hair_straightovereye
	name = "Straight over eye"
	icon_state = "hair_straightovereye"

/datum/sprite_accessory/hair/additional/hair_strict
	name = "Strict"
	icon_state = "hair_strict"

/datum/sprite_accessory/hair/additional/hair_strict_long
	name = "Strict long"
	icon_state = "hair_strict_long"

/datum/sprite_accessory/hair/additional/hair_strict_short
	name = "Strict short"
	icon_state = "hair_strict_short"

/datum/sprite_accessory/hair/additional/hair_styledponytail
	name = "Styled Ponytail"
	icon_state = "hair_styledponytail"

/datum/sprite_accessory/hair/additional/hair_supernova
	name = "Supernova"
	icon_state = "hair_supernova"

/datum/sprite_accessory/hair/additional/hair_tailedmohawk
	name = "Tailed Mohawk"
	icon_state = "hair_tailedmohawk"

/datum/sprite_accessory/hair/additional/ashwalker_goliath_hair
	name = "Tentacle hair"
	icon_state = "ashwalker_goliath_hair"

/datum/sprite_accessory/hair/additional/teshari_ears
	name = "Teshari Alt. Default"
	icon_state = "teshari_ears"

/datum/sprite_accessory/hair/additional/teshari_backstrafe
	name = "Teshari Backstrafe"
	icon_state = "teshari_backstrafe"

/datum/sprite_accessory/hair/additional/teshari_default
	name = "Teshari Default"
	icon_state = "teshari_default"

/datum/sprite_accessory/hair/additional/teshari_droopy
	name = "Teshari Droopy"
	icon_state = "teshari_droopy"

/datum/sprite_accessory/hair/additional/teshari_fluffymohawk
	name = "Teshari Fluffy Mohawk"
	icon_state = "teshari_fluffymohawk"

/datum/sprite_accessory/hair/additional/teshari_longway
	name = "Teshari Long way"
	icon_state = "teshari_longway"

/datum/sprite_accessory/hair/additional/teshari_mane
	name = "Teshari Mane"
	icon_state = "teshari_mane"

/datum/sprite_accessory/hair/additional/hair_teshmohawk
	name = "Teshari Mohawk"
	icon_state = "hair_teshmohawk"

/datum/sprite_accessory/hair/additional/teshari_mohawk
	name = "Teshari Mohawk Alt"
	icon_state = "teshari_mohawk"

/datum/sprite_accessory/hair/additional/hair_teshmohawkalt
	name = "Teshari Mohawk Alt Alt"
	icon_state = "hair_teshmohawkalt"

/datum/sprite_accessory/hair/additional/teshari_mushroom
	name = "Teshari Mushroom"
	icon_state = "teshari_mushroom"

/datum/sprite_accessory/hair/additional/teshari_long
	name = "Teshari Overgrown"
	icon_state = "teshari_long"

/datum/sprite_accessory/hair/additional/teshari_pointy
	name = "Teshari Pointy"
	icon_state = "teshari_pointy"

/datum/sprite_accessory/hair/additional/teshari_burst_short
	name = "Teshari Short Starburst"
	icon_state = "teshari_burst_short"

/datum/sprite_accessory/hair/additional/teshari_spike
	name = "Teshari Spike"
	icon_state = "teshari_spike"

/datum/sprite_accessory/hair/additional/teshari_spiky
	name = "Teshari Spiky"
	icon_state = "teshari_spiky"

/datum/sprite_accessory/hair/additional/teshari_burst
	name = "Teshari Starburst"
	icon_state = "teshari_burst"

/datum/sprite_accessory/hair/additional/teshari_tight
	name = "Teshari Tight"
	icon_state = "teshari_tight"

/datum/sprite_accessory/hair/additional/teshari_tree
	name = "Teshari Tree"
	icon_state = "teshari_tree"

/datum/sprite_accessory/hair/additional/teshari_twies
	name = "Teshari Twies"
	icon_state = "teshari_twies"

/datum/sprite_accessory/hair/additional/teshari_upright
	name = "Teshari Upright"
	icon_state = "teshari_upright"

/datum/sprite_accessory/hair/additional/hair_thefamilyman
	name = "The Family Man"
	icon_state = "hair_thefamilyman"

/datum/sprite_accessory/hair/additional/hair_thick__curly
	name = "Thick (Curly)"
	icon_state = "hair_thick_(curly)"

/datum/sprite_accessory/hair/additional/hair_thick__long_alt
	name = "Thick (Long Alt)"
	icon_state = "hair_thick_(long alt)"

/datum/sprite_accessory/hair/additional/hair_thick__long
	name = "Thick (Long)"
	icon_state = "hair_thick_(long)"

/datum/sprite_accessory/hair/additional/hair_thick__short
	name = "Thick (Short)"
	icon_state = "hair_thick_(short)"

/datum/sprite_accessory/hair/additional/hair_thickponytail
	name = "Thick Ponytail"
	icon_state = "hair_thickponytail"

/datum/sprite_accessory/hair/additional/hair_thin_ponytail
	name = "Thin ponytail"
	icon_state = "hair_thin_ponytail"

/datum/sprite_accessory/hair/additional/hair_tied_flowy
	name = "Tied Flowy"
	icon_state = "hair_tied_flowy"

/datum/sprite_accessory/hair/additional/hair_toriyama
	name = "Toriyama"
	icon_state = "hair_toriyama"

/datum/sprite_accessory/hair/additional/hair_toriyama2
	name = "Toriyama 2"
	icon_state = "hair_toriyama2"

/datum/sprite_accessory/hair/additional/hair_traxsex
	name = "Traxsex Ponytail"
	icon_state = "hair_traxsex"

/datum/sprite_accessory/hair/additional/hair_tressshoulder_alt
	name = "Tress Shoulder Alt"
	icon_state = "hair_tressshoulder_alt"

/datum/sprite_accessory/hair/additional/hair_tri_bun
	name = "Tri Bun"
	icon_state = "hair_tri_bun"

/datum/sprite_accessory/hair/additional/hair_tri_bun_long
	name = "Tri Bun Long"
	icon_state = "hair_tri_bun_long"

/datum/sprite_accessory/hair/additional/hair_twincurls
	name = "Twincurls"
	icon_state = "hair_twincurls"

/datum/sprite_accessory/hair/additional/hair_twintail_floor
	name = "Twintail Floor"
	icon_state = "hair_twintail_floor"

/datum/sprite_accessory/hair/additional/hair_twintails_alt
	name = "Twintails (Alt)"
	icon_state = "hair_twintails_alt"

/datum/sprite_accessory/hair/additional/hair_longstraighttwintails
	name = "Twintails (Long)"
	icon_state = "hair_longstraighttwintails"

/datum/sprite_accessory/hair/additional/hair_twintails_2
	name = "Twintails 2"
	icon_state = "hair_twintails_2"

/datum/sprite_accessory/hair/additional/hair_twintails_alt_long
	name = "Twintails Long (Alt)"
	icon_state = "hair_twintails_alt_long"

/datum/sprite_accessory/hair/additional/hair_twisted
	name = "Twisted"
	icon_state = "hair_twisted"

/datum/sprite_accessory/hair/additional/hair_twistedlong
	name = "Twisted Long"
	icon_state = "hair_twistedlong"

/datum/sprite_accessory/hair/additional/hair_undercut_s
	name = "Undercut Alt"
	icon_state = "hair_undercut_s"

/datum/sprite_accessory/hair/additional/hair_undercut_fem_s
	name = "Undercut Fem"
	icon_state = "hair_undercut_fem_s"

/datum/sprite_accessory/hair/additional/hair_unique_fluffy
	name = "Unique Fluffy"
	icon_state = "hair_unique_fluffy"

/datum/sprite_accessory/hair/additional/hair_unique_fluffy_tail
	name = "Unique Fluffy (Alt 2)"
	icon_state = "hair_unique_fluffy_tail"

/datum/sprite_accessory/hair/additional/hair_unique_fluffy_alt
	name = "Unique Fluffy (Alt)"
	icon_state = "hair_unique_fluffy_alt"

/datum/sprite_accessory/hair/additional/hair_unique_spiky
	name = "Unique Spiky"
	icon_state = "hair_unique_spiky"

/datum/sprite_accessory/hair/additional/hair_unique_spiky_cowlick_alt
	name = "Unique Spiky (Alt Cowlick)"
	icon_state = "hair_unique_spiky_cowlick_alt"

/datum/sprite_accessory/hair/additional/hair_unique_spiky_cowlick
	name = "Unique Spiky (Cowlick)"
	icon_state = "hair_unique_spiky_cowlick"

/datum/sprite_accessory/hair/additional/hair_unkempt
	name = "Unkempt"
	icon_state = "hair_unkempt"

/datum/sprite_accessory/hair/additional/unkempt_curls
	name = "Unkempt Curls"
	icon_state = "unkempt_curls"

/datum/sprite_accessory/hair/additional/hair_upwards
	name = "Upwards"
	icon_state = "hair_upwards"

/datum/sprite_accessory/hair/additional/hair_gloomy_longer
	name = "Very Long Gloomy Bangs"
	icon_state = "hair_gloomy_longer"

/datum/sprite_accessory/hair/additional/hair_vlong_alt
	name = "Very Long Hair (Alt)"
	icon_state = "hair_vlong_alt"

/datum/sprite_accessory/hair/additional/hair_longestalt
	name = "Very Long Hair 2 (Alt)"
	icon_state = "hair_longestalt"

/datum/sprite_accessory/hair/additional/hair_veryshortovereye
	name = "Very Short Over Eye Alt"
	icon_state = "hair_veryshortovereye"

/datum/sprite_accessory/hair/additional/hair_victory
	name = "Victory"
	icon_state = "hair_victory"

/datum/sprite_accessory/hair/additional/pod_hair_vine
	name = "Vine"
	icon_state = "pod_hair_vine"

/datum/sprite_accessory/hair/additional/hair_violet
	name = "Violet"
	icon_state = "hair_violet"

/datum/sprite_accessory/hair/additional/hair_violet_ponytail
	name = "Violet Ponytail"
	icon_state = "hair_violet_ponytail"

/datum/sprite_accessory/hair/additional/hair_viper
	name = "Viper"
	icon_state = "hair_viper"

/datum/sprite_accessory/hair/additional/hair_vivi
	name = "Vivi"
	icon_state = "hair_vivi"

/datum/sprite_accessory/hair/additional/hair_volajupompless
	name = "Volaju Pompless"
	icon_state = "hair_volajupompless"

/datum/sprite_accessory/hair/additional/hair_vox_afro
	name = "Vox Afro"
	icon_state = "hair_vox_afro"

/datum/sprite_accessory/hair/additional/vox_braid
	name = "Vox Braids"
	icon_state = "vox_braid"

/datum/sprite_accessory/hair/additional/hair_vox_crestedquills
	name = "Vox Crested Quills"
	icon_state = "hair_vox_crestedquills"

/datum/sprite_accessory/hair/additional/vox_cropped
	name = "Vox Cropped"
	icon_state = "vox_cropped"

/datum/sprite_accessory/hair/additional/hair_vox_emperorquills
	name = "Vox Emperor Quills"
	icon_state = "hair_vox_emperorquills"

/datum/sprite_accessory/hair/additional/vox_flowing
	name = "Vox Flowing"
	icon_state = "vox_flowing"

/datum/sprite_accessory/hair/additional/hair_vox_horns
	name = "Vox Horns"
	icon_state = "hair_vox_horns"

/datum/sprite_accessory/hair/additional/hair_vox_keelquills
	name = "Vox Keel Quills"
	icon_state = "hair_vox_keelquills"

/datum/sprite_accessory/hair/additional/hair_vox_keetquills
	name = "Vox Keet Quills"
	icon_state = "hair_vox_keetquills"

/datum/sprite_accessory/hair/additional/hair_vox_kingly
	name = "Vox Kingly"
	icon_state = "hair_vox_kingly"

/datum/sprite_accessory/hair/additional/vox_mange
	name = "Vox Mange"
	icon_state = "vox_mange"

/datum/sprite_accessory/hair/additional/hair_vox_mohawk
	name = "Vox Mohawk"
	icon_state = "hair_vox_mohawk"

/datum/sprite_accessory/hair/additional/hair_vox_nights
	name = "Vox Nights"
	icon_state = "hair_vox_nights"

/datum/sprite_accessory/hair/additional/vox_pony
	name = "Vox Ponytail"
	icon_state = "vox_pony"

/datum/sprite_accessory/hair/additional/vox_bayonet_s
	name = "Vox Primalis Bayonet"
	icon_state = "vox_bayonet_s"

/datum/sprite_accessory/hair/additional/vox_classic_s
	name = "Vox Primalis Classic"
	icon_state = "vox_classic_s"

/datum/sprite_accessory/hair/additional/vox_dreads_s
	name = "Vox Primalis Dreads"
	icon_state = "vox_dreads_s"

/datum/sprite_accessory/hair/additional/vox_kingly_s
	name = "Vox Primalis Kingly"
	icon_state = "vox_kingly_s"

/datum/sprite_accessory/hair/additional/vox_kingly_dreads_s
	name = "Vox Primalis Kingly Dreads"
	icon_state = "vox_kingly_dreads_s"

/datum/sprite_accessory/hair/additional/vox_kinglyq_s
	name = "Vox Primalis Kingly Long"
	icon_state = "vox_kinglyq_s"

/datum/sprite_accessory/hair/additional/vox_long_s
	name = "Vox Primalis Long"
	icon_state = "vox_long_s"

/datum/sprite_accessory/hair/additional/vox_long_dreads_s
	name = "Vox Primalis Long Dreads"
	icon_state = "vox_long_dreads_s"

/datum/sprite_accessory/hair/additional/vox_punk_s
	name = "Vox Primalis Punk"
	icon_state = "vox_punk_s"

/datum/sprite_accessory/hair/additional/vox_razor_s
	name = "Vox Primalis Razor"
	icon_state = "vox_razor_s"

/datum/sprite_accessory/hair/additional/vox_rome_s
	name = "Vox Primalis Rome"
	icon_state = "vox_rome_s"

/datum/sprite_accessory/hair/additional/vox_shortquills_s
	name = "Vox Primalis Shortquills"
	icon_state = "vox_shortquills_s"

/datum/sprite_accessory/hair/additional/vox_whip_s
	name = "Vox Primalis Whip"
	icon_state = "vox_whip_s"

/datum/sprite_accessory/hair/additional/hair_vox_razor
	name = "Vox Razor"
	icon_state = "hair_vox_razor"

/datum/sprite_accessory/hair/additional/hair_vox_razorclipped
	name = "Vox Razor Clipped"
	icon_state = "hair_vox_razorclipped"

/datum/sprite_accessory/hair/additional/vox_rows
	name = "Vox Rows"
	icon_state = "vox_rows"

/datum/sprite_accessory/hair/additional/vox_ruffhawk
	name = "Vox Ruffhawk"
	icon_state = "vox_ruffhawk"

/datum/sprite_accessory/hair/additional/hair_vox_shortquills
	name = "Vox Short Quills"
	icon_state = "hair_vox_shortquills"

/datum/sprite_accessory/hair/additional/vox_surf
	name = "Vox Surf"
	icon_state = "vox_surf"

/datum/sprite_accessory/hair/additional/hair_vox_tielquills
	name = "Vox Tiel Quills"
	icon_state = "hair_vox_tielquills"

/datum/sprite_accessory/hair/additional/vox_wise_braid
	name = "Vox Wise Braids"
	icon_state = "vox_wise_braid"

/datum/sprite_accessory/hair/additional/hair_vox_yasu
	name = "Vox Yasu"
	icon_state = "hair_vox_yasu"

/datum/sprite_accessory/hair/additional/anita
	name = "Vulp Anita"
	icon_state = "anita"

/datum/sprite_accessory/hair/additional/jagged
	name = "Vulp Jagged"
	icon_state = "jagged"

/datum/sprite_accessory/hair/additional/jagged_s
	name = "Vulp Jagged Alt"
	icon_state = "jagged_s"

/datum/sprite_accessory/hair/additional/kajam1
	name = "Vulp Kajam 1"
	icon_state = "kajam1"

/datum/sprite_accessory/hair/additional/kajam2
	name = "Vulp Kajam 2"
	icon_state = "kajam2"

/datum/sprite_accessory/hair/additional/keid
	name = "Vulp Keid"
	icon_state = "keid"

/datum/sprite_accessory/hair/additional/keid_s
	name = "Vulp Keid Alt"
	icon_state = "keid_s"

/datum/sprite_accessory/hair/additional/mizar
	name = "Vulp Mizar"
	icon_state = "mizar"

/datum/sprite_accessory/hair/additional/mizar_s
	name = "Vulp Mizar Alt"
	icon_state = "mizar_s"

/datum/sprite_accessory/hair/additional/raine
	name = "Vulp Raine"
	icon_state = "raine"

/datum/sprite_accessory/hair/additional/raine_s
	name = "Vulp Raine Alt"
	icon_state = "raine_s"

/datum/sprite_accessory/hair/additional/hair_wavyovereye
	name = "Wavy over eye"
	icon_state = "hair_wavyovereye"

/datum/sprite_accessory/hair/additional/hair_wicked
	name = "Wicked"
	icon_state = "hair_wicked"

/datum/sprite_accessory/hair/additional/hair_wife
	name = "Wife"
	icon_state = "hair_wife"

/datum/sprite_accessory/hair/additional/hair_ponytail_kzero
	name = "'Zero' Ponytail"
	icon_state = "hair_ponytail_kzero"

/datum/sprite_accessory/hair/additional/hair_zoey
	name = "Zoey"
	icon_state = "hair_zoey"

/datum/sprite_accessory/hair/additional/hair_zone
	name = "Zone"
	icon_state = "hair_zone"

/*
/////////////////////////////////////
/  =---------------------------=    /
/  == Gradient Hair Definitions ==  /
/  =---------------------------=    /
/////////////////////////////////////
*/

/datum/sprite_accessory/gradient
	icon = 'icons/mob/human/species/hair_gradients.dmi'
	///whether this gradient applies to hair and/or beards. Some gradients do not work well on beards.
	var/gradient_category = GRADIENT_APPLIES_TO_HAIR|GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"

/datum/sprite_accessory/gradient/full
	name = "Full"
	icon_state = "full"

/datum/sprite_accessory/gradient/fadeup
	name = "Fade Up"
	icon_state = "fadeup"

/datum/sprite_accessory/gradient/fadedown
	name = "Fade Down"
	icon_state = "fadedown"

/datum/sprite_accessory/gradient/vertical_split
	name = "Vertical Split"
	icon_state = "vsplit"

/datum/sprite_accessory/gradient/horizontal_split
	name = "Horizontal Split"
	icon_state = "bottomflat"

/datum/sprite_accessory/gradient/reflected
	name = "Reflected"
	icon_state = "reflected_high"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/reflected/beard
	icon_state = "reflected_high_beard"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/reflected_inverse
	name = "Reflected Inverse"
	icon_state = "reflected_inverse_high"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/reflected_inverse/beard
	icon_state = "reflected_inverse_high_beard"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/wavy
	name = "Wavy"
	icon_state = "wavy"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/long_fade_up
	name = "Long Fade Up"
	icon_state = "long_fade_up"

/datum/sprite_accessory/gradient/long_fade_down
	name = "Long Fade Down"
	icon_state = "long_fade_down"

/datum/sprite_accessory/gradient/short_fade_up
	name = "Short Fade Up"
	icon_state = "short_fade_up"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/short_fade_up/beard
	icon_state = "short_fade_down"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/short_fade_down
	name = "Short Fade Down"
	icon_state = "short_fade_down_beard"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/short_fade_down/beard
	icon_state = "short_fade_down_beard"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/wavy_spike
	name = "Spiked Wavy"
	icon_state = "wavy_spiked"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/striped
	name = "striped"
	icon_state = "striped"

/datum/sprite_accessory/gradient/striped_vertical
	name = "Striped Vertical"
	icon_state = "striped_vertical"

/////////////////////////////
// Facial Hair Definitions //
/////////////////////////////

/datum/sprite_accessory/facial_hair
	icon = 'icons/mob/human/human_face.dmi'
	gender = MALE // barf (unless you're a dorf, dorfs dig chix w/ beards :P)
	em_block = TRUE

// please make sure they're sorted alphabetically and categorized

/datum/sprite_accessory/facial_hair/abe
	name = "Beard (Abraham Lincoln)"
	icon_state = "facial_abe"

/datum/sprite_accessory/facial_hair/brokenman
	name = "Beard (Broken Man)"
	icon_state = "facial_brokenman"
	natural_spawn = FALSE

/datum/sprite_accessory/facial_hair/chinstrap
	name = "Beard (Chinstrap)"
	icon_state = "facial_chin"

/datum/sprite_accessory/facial_hair/dwarf
	name = "Beard (Dwarf)"
	icon_state = "facial_dwarf"

/datum/sprite_accessory/facial_hair/fullbeard
	name = "Beard (Full)"
	icon_state = "facial_fullbeard"

/datum/sprite_accessory/facial_hair/croppedfullbeard
	name = "Beard (Cropped Fullbeard)"
	icon_state = "facial_croppedfullbeard"

/datum/sprite_accessory/facial_hair/gt
	name = "Beard (Goatee)"
	icon_state = "facial_gt"

/datum/sprite_accessory/facial_hair/hip
	name = "Beard (Hipster)"
	icon_state = "facial_hip"

/datum/sprite_accessory/facial_hair/jensen
	name = "Beard (Jensen)"
	icon_state = "facial_jensen"

/datum/sprite_accessory/facial_hair/neckbeard
	name = "Beard (Neckbeard)"
	icon_state = "facial_neckbeard"

/datum/sprite_accessory/facial_hair/vlongbeard
	name = "Beard (Very Long)"
	icon_state = "facial_wise"

/datum/sprite_accessory/facial_hair/muttonmus
	name = "Beard (Muttonmus)"
	icon_state = "facial_muttonmus"

/datum/sprite_accessory/facial_hair/martialartist
	name = "Beard (Martial Artist)"
	icon_state = "facial_martialartist"
	natural_spawn = FALSE

/datum/sprite_accessory/facial_hair/chinlessbeard
	name = "Beard (Chinless Beard)"
	icon_state = "facial_chinlessbeard"

/datum/sprite_accessory/facial_hair/moonshiner
	name = "Beard (Moonshiner)"
	icon_state = "facial_moonshiner"

/datum/sprite_accessory/facial_hair/longbeard
	name = "Beard (Long)"
	icon_state = "facial_longbeard"

/datum/sprite_accessory/facial_hair/volaju
	name = "Beard (Volaju)"
	icon_state = "facial_volaju"

/datum/sprite_accessory/facial_hair/threeoclock
	name = "Beard (Three o Clock Shadow)"
	icon_state = "facial_3oclock"

/datum/sprite_accessory/facial_hair/fiveoclock
	name = "Beard (Five o Clock Shadow)"
	icon_state = "facial_fiveoclock"

/datum/sprite_accessory/facial_hair/fiveoclockm
	name = "Beard (Five o Clock Moustache)"
	icon_state = "facial_5oclockmoustache"

/datum/sprite_accessory/facial_hair/sevenoclock
	name = "Beard (Seven o Clock Shadow)"
	icon_state = "facial_7oclock"

/datum/sprite_accessory/facial_hair/sevenoclockm
	name = "Beard (Seven o Clock Moustache)"
	icon_state = "facial_7oclockmoustache"

/datum/sprite_accessory/facial_hair/moustache
	name = "Moustache"
	icon_state = "facial_moustache"

/datum/sprite_accessory/facial_hair/pencilstache
	name = "Moustache (Pencilstache)"
	icon_state = "facial_pencilstache"

/datum/sprite_accessory/facial_hair/smallstache
	name = "Moustache (Smallstache)"
	icon_state = "facial_smallstache"

/datum/sprite_accessory/facial_hair/walrus
	name = "Moustache (Walrus)"
	icon_state = "facial_walrus"

/datum/sprite_accessory/facial_hair/fu
	name = "Moustache (Fu Manchu)"
	icon_state = "facial_fumanchu"

/datum/sprite_accessory/facial_hair/hogan
	name = "Moustache (Hulk Hogan)"
	icon_state = "facial_hogan" //-Neek

/datum/sprite_accessory/facial_hair/selleck
	name = "Moustache (Selleck)"
	icon_state = "facial_selleck"

/datum/sprite_accessory/facial_hair/chaplin
	name = "Moustache (Square)"
	icon_state = "facial_chaplin"

/datum/sprite_accessory/facial_hair/vandyke
	name = "Moustache (Van Dyke)"
	icon_state = "facial_vandyke"

/datum/sprite_accessory/facial_hair/watson
	name = "Moustache (Watson)"
	icon_state = "facial_watson"

/datum/sprite_accessory/facial_hair/handlebar
	name = "Moustache (Handlebar)"
	icon_state = "facial_handlebar"

/datum/sprite_accessory/facial_hair/handlebar2
	name = "Moustache (Handlebar 2)"
	icon_state = "facial_handlebar2"

/datum/sprite_accessory/facial_hair/elvis
	name = "Sideburns (Elvis)"
	icon_state = "facial_elvis"

/datum/sprite_accessory/facial_hair/mutton
	name = "Sideburns (Mutton Chops)"
	icon_state = "facial_mutton"

/datum/sprite_accessory/facial_hair/sideburn
	name = "Sideburns"
	icon_state = "facial_sideburn"

/datum/sprite_accessory/facial_hair/shaved
	name = "Shaved"
	icon_state = null
	gender = NEUTER


// Additional facial hair styles

/datum/sprite_accessory/facial_hair/additional/facial_chinhorns
	name = "Chin Horns"
	icon_state = "facial_chinhorns"

/datum/sprite_accessory/facial_hair/additional/facial_fullstub_s
	name = "Full Stub"
	icon_state = "facial_fullstub_s"

/datum/sprite_accessory/facial_hair/additional/facial_goatee
	name = "Goatee"
	icon_state = "facial_goatee"

/datum/sprite_accessory/facial_hair/additional/facial_hornadorns
	name = "Hornadorns"
	icon_state = "facial_hornadorns"

/datum/sprite_accessory/facial_hair/additional/facial_neckfluff
	name = "Neckfluff"
	icon_state = "facial_neckfluff"

/datum/sprite_accessory/facial_hair/additional/facial_sideburns
	name = "Sideburns Alt"
	icon_state = "facial_sideburns"

/datum/sprite_accessory/facial_hair/additional/facial_squid
	name = "Tentacle Beard"
	icon_state = "facial_squid"

/datum/sprite_accessory/facial_hair/additional/teshari_chin
	name = "Teshari Beard"
	icon_state = "teshari_chin"

/datum/sprite_accessory/facial_hair/additional/teshari_gap
	name = "Teshari Chops"
	icon_state = "teshari_gap"

/datum/sprite_accessory/facial_hair/additional/teshari_scraggly
	name = "Teshari Scraggly"
	icon_state = "teshari_scraggly"

/datum/sprite_accessory/facial_hair/additional/facial_tribeard
	name = "Tri-beard"
	icon_state = "facial_tribeard"

/datum/sprite_accessory/facial_hair/additional/facial_vox_beard
	name = "Vox Beard"
	icon_state = "facial_vox_beard"

/datum/sprite_accessory/facial_hair/additional/facial_vox_colonel
	name = "Vox Beard (Colonel)"
	icon_state = "facial_vox_colonel"

/datum/sprite_accessory/facial_hair/additional/facial_vox_fu
	name = "Vox Beard (Fu)"
	icon_state = "facial_vox_fu"

/datum/sprite_accessory/facial_hair/additional/facial_vox_mane
	name = "Vox Mane"
	icon_state = "facial_vox_mane"

/datum/sprite_accessory/facial_hair/additional/facial_vox_neck
	name = "Vox Neck Quills"
	icon_state = "facial_vox_neck"

///////////////////////////
// Underwear Definitions //
///////////////////////////

/datum/sprite_accessory/underwear
	icon = 'icons/mob/clothing/underwear.dmi'
	use_static = FALSE
	em_block = TRUE


//MALE UNDERWEAR
/datum/sprite_accessory/underwear/nude
	name = "Nude"
	icon_state = null
	gender = NEUTER

/datum/sprite_accessory/underwear/male_briefs
	name = "Briefs"
	icon_state = "male_briefs"
	gender = MALE

/datum/sprite_accessory/underwear/male_boxers
	name = "Boxers"
	icon_state = "male_boxers"
	gender = MALE

/datum/sprite_accessory/underwear/male_stripe
	name = "Striped Boxers"
	icon_state = "male_stripe"
	gender = MALE

/datum/sprite_accessory/underwear/male_midway
	name = "Midway Boxers"
	icon_state = "male_midway"
	gender = MALE

/datum/sprite_accessory/underwear/male_longjohns
	name = "Long Johns"
	icon_state = "male_longjohns"
	gender = MALE

/datum/sprite_accessory/underwear/male_kinky
	name = "Jockstrap"
	icon_state = "male_kinky"
	gender = MALE

/datum/sprite_accessory/underwear/male_mankini
	name = "Mankini"
	icon_state = "male_mankini"
	gender = MALE

/datum/sprite_accessory/underwear/male_hearts
	name = "Hearts Boxers"
	icon_state = "male_hearts"
	gender = MALE
	use_static = TRUE

/datum/sprite_accessory/underwear/male_commie
	name = "Commie Boxers"
	icon_state = "male_commie"
	gender = MALE
	use_static = TRUE

/datum/sprite_accessory/underwear/male_usastripe
	name = "Freedom Boxers"
	icon_state = "male_assblastusa"
	gender = MALE
	use_static = TRUE

/datum/sprite_accessory/underwear/male_uk
	name = "UK Boxers"
	icon_state = "male_uk"
	gender = MALE
	use_static = TRUE

/* // NOVA EDIT REMOVAL START - Underwear and bra split
//FEMALE UNDERWEAR
/datum/sprite_accessory/underwear/female_bikini
	name = "Bikini"
	icon_state = "female_bikini"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_lace
	name = "Lace Bikini"
	icon_state = "female_lace"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_bralette
	name = "Bralette w/ Boyshorts"
	icon_state = "female_bralette"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_sport
	name = "Sports Bra w/ Boyshorts"
	icon_state = "female_sport"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_thong
	name = "Thong"
	icon_state = "female_thong"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_strapless
	name = "Strapless Bikini"
	icon_state = "female_strapless"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_babydoll
	name = "Babydoll"
	icon_state = "female_babydoll"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_onepiece
	name = "One-Piece Swimsuit"
	icon_state = "swim_onepiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_strapless_onepiece
	name = "Strapless One-Piece Swimsuit"
	icon_state = "swim_strapless_onepiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_twopiece
	name = "Two-Piece Swimsuit"
	icon_state = "swim_twopiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_strapless_twopiece
	name = "Strapless Two-Piece Swimsuit"
	icon_state = "swim_strapless_twopiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_stripe
	name = "Strapless Striped Swimsuit"
	icon_state = "swim_stripe"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_halter
	name = "Halter Swimsuit"
	icon_state = "swim_halter"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_white_neko
	name = "Neko Bikini (White)"
	icon_state = "female_neko_white"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_black_neko
	name = "Neko Bikini (Black)"
	icon_state = "female_neko_black"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_commie
	name = "Commie Bikini"
	icon_state = "female_commie"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_usastripe
	name = "Freedom Bikini"
	icon_state = "female_assblastusa"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_uk
	name = "UK Bikini"
	icon_state = "female_uk"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_kinky
	name = "Lingerie"
	icon_state = "female_kinky"
	gender = FEMALE
	use_static = TRUE
*/ // NOVA EDIT REMOVAL END

////////////////////////////
// Undershirt Definitions //
////////////////////////////

/datum/sprite_accessory/undershirt
	icon = 'icons/mob/clothing/underwear.dmi'
	em_block = TRUE

/datum/sprite_accessory/undershirt/nude
	name = "Nude"
	icon_state = null
	gender = NEUTER

// please make sure they're sorted alphabetically and categorized

/datum/sprite_accessory/undershirt/bluejersey
	name = "Jersey (Blue)"
	icon_state = "shirt_bluejersey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redjersey
	name = "Jersey (Red)"
	icon_state = "shirt_redjersey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/bluepolo
	name = "Polo Shirt (Blue)"
	icon_state = "bluepolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/grayyellowpolo
	name = "Polo Shirt (Gray-Yellow)"
	icon_state = "grayyellowpolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redpolo
	name = "Polo Shirt (Red)"
	icon_state = "redpolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/whitepolo
	name = "Polo Shirt (White)"
	icon_state = "whitepolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/alienshirt
	name = "Shirt (Alien)"
	icon_state = "shirt_alien"
	gender = NEUTER

/datum/sprite_accessory/undershirt/mondmondjaja
	name = "Shirt (Band)"
	icon_state = "band"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_black
	name = "Shirt (Black)"
	icon_state = "shirt_black"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshirt
	name = "Shirt (Blue)"
	icon_state = "shirt_blue"
	gender = NEUTER

/datum/sprite_accessory/undershirt/clownshirt
	name = "Shirt (Clown)"
	icon_state = "shirt_clown"
	gender = NEUTER

/datum/sprite_accessory/undershirt/commie
	name = "Shirt (Commie)"
	icon_state = "shirt_commie"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshirt
	name = "Shirt (Green)"
	icon_state = "shirt_green"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_grey
	name = "Shirt (Grey)"
	icon_state = "shirt_grey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ian
	name = "Shirt (Ian)"
	icon_state = "ian"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ilovent
	name = "Shirt (I Love NT)"
	icon_state = "ilovent"
	gender = NEUTER

/datum/sprite_accessory/undershirt/lover
	name = "Shirt (Lover)"
	icon_state = "lover"
	gender = NEUTER

/datum/sprite_accessory/undershirt/matroska
	name = "Shirt (Matroska)"
	icon_state = "matroska"
	gender = NEUTER

/datum/sprite_accessory/undershirt/meat
	name = "Shirt (Meat)"
	icon_state = "shirt_meat"
	gender = NEUTER

/datum/sprite_accessory/undershirt/nano
	name = "Shirt (Nanotrasen)"
	icon_state = "shirt_nano"
	gender = NEUTER

/datum/sprite_accessory/undershirt/peace
	name = "Shirt (Peace)"
	icon_state = "peace"
	gender = NEUTER

/datum/sprite_accessory/undershirt/pacman
	name = "Shirt (Pogoman)"
	icon_state = "pogoman"
	gender = NEUTER

/datum/sprite_accessory/undershirt/question
	name = "Shirt (Question)"
	icon_state = "shirt_question"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redshirt
	name = "Shirt (Red)"
	icon_state = "shirt_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/skull
	name = "Shirt (Skull)"
	icon_state = "shirt_skull"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ss13
	name = "Shirt (SS13)"
	icon_state = "shirt_ss13"
	gender = NEUTER

/datum/sprite_accessory/undershirt/stripe
	name = "Shirt (Striped)"
	icon_state = "shirt_stripes"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tiedye
	name = "Shirt (Tie-dye)"
	icon_state = "shirt_tiedye"
	gender = NEUTER

/datum/sprite_accessory/undershirt/uk
	name = "Shirt (UK)"
	icon_state = "uk"
	gender = NEUTER

/datum/sprite_accessory/undershirt/usa
	name = "Shirt (USA)"
	icon_state = "shirt_assblastusa"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_white
	name = "Shirt (White)"
	icon_state = "shirt_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blackshortsleeve
	name = "Short-sleeved Shirt (Black)"
	icon_state = "blackshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshortsleeve
	name = "Short-sleeved Shirt (Blue)"
	icon_state = "blueshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshortsleeve
	name = "Short-sleeved Shirt (Green)"
	icon_state = "greenshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/purpleshortsleeve
	name = "Short-sleeved Shirt (Purple)"
	icon_state = "purpleshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/whiteshortsleeve
	name = "Short-sleeved Shirt (White)"
	icon_state = "whiteshortsleeve"
	gender = NEUTER

/* // NOVA EDIT REMOVAL START - Underwear and bra split
/datum/sprite_accessory/undershirt/sports_bra
	name = "Sports Bra"
	icon_state = "sports_bra"
	gender = NEUTER

/datum/sprite_accessory/undershirt/sports_bra2
	name = "Sports Bra (Alt)"
	icon_state = "sports_bra_alt"
	gender = NEUTER
*/ // NOVA EDIT REMOVAL END

/datum/sprite_accessory/undershirt/blueshirtsport
	name = "Sports Shirt (Blue)"
	icon_state = "blueshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshirtsport
	name = "Sports Shirt (Green)"
	icon_state = "greenshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redshirtsport
	name = "Sports Shirt (Red)"
	icon_state = "redshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_black
	name = "Tank Top (Black)"
	icon_state = "tank_black"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tankfire
	name = "Tank Top (Fire)"
	icon_state = "tank_fire"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_grey
	name = "Tank Top (Grey)"
	icon_state = "tank_grey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/female_midriff
	name = "Tank Top (Midriff)"
	icon_state = "tank_midriff"
	gender = FEMALE

/datum/sprite_accessory/undershirt/tank_red
	name = "Tank Top (Red)"
	icon_state = "tank_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tankstripe
	name = "Tank Top (Striped)"
	icon_state = "tank_stripes"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_white
	name = "Tank Top (White)"
	icon_state = "tank_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redtop
	name = "Top (Red)"
	icon_state = "redtop"
	gender = FEMALE

/datum/sprite_accessory/undershirt/whitetop
	name = "Top (White)"
	icon_state = "whitetop"
	gender = FEMALE

/datum/sprite_accessory/undershirt/tshirt_blue
	name = "T-Shirt (Blue)"
	icon_state = "blueshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tshirt_green
	name = "T-Shirt (Green)"
	icon_state = "greenshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tshirt_red
	name = "T-Shirt (Red)"
	icon_state = "redshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/yellowshirt
	name = "T-Shirt (Yellow)"
	icon_state = "yellowshirt"
	gender = NEUTER

///////////////////////
// Socks Definitions //
///////////////////////

/datum/sprite_accessory/socks
	icon = 'icons/mob/clothing/underwear.dmi'
	em_block = TRUE

/datum/sprite_accessory/socks/nude
	name = "Nude"
	icon_state = null

// please make sure they're sorted alphabetically and categorized

/datum/sprite_accessory/socks/ace_knee
	name = "Knee-high (Ace)"
	icon_state = "ace_knee"

/datum/sprite_accessory/socks/bee_knee
	name = "Knee-high (Bee)"
	icon_state = "bee_knee"

/datum/sprite_accessory/socks/black_knee
	name = "Knee-high (Black)"
	icon_state = "black_knee"

/datum/sprite_accessory/socks/commie_knee
	name = "Knee-High (Commie)"
	icon_state = "commie_knee"

/datum/sprite_accessory/socks/usa_knee
	name = "Knee-High (Freedom)"
	icon_state = "assblastusa_knee"

/datum/sprite_accessory/socks/rainbow_knee
	name = "Knee-high (Rainbow)"
	icon_state = "rainbow_knee"

/datum/sprite_accessory/socks/striped_knee
	name = "Knee-high (Striped)"
	icon_state = "striped_knee"

/datum/sprite_accessory/socks/thin_knee
	name = "Knee-high (Thin)"
	icon_state = "thin_knee"

/datum/sprite_accessory/socks/trans_knee
	name = "Knee-high (Trans)"
	icon_state = "trans_knee"

/datum/sprite_accessory/socks/uk_knee
	name = "Knee-High (UK)"
	icon_state = "uk_knee"

/datum/sprite_accessory/socks/white_knee
	name = "Knee-high (White)"
	icon_state = "white_knee"

/datum/sprite_accessory/socks/fishnet_knee
	name = "Knee-high (Fishnet)"
	icon_state = "fishnet_knee"

/datum/sprite_accessory/socks/black_norm
	name = "Normal (Black)"
	icon_state = "black_norm"

/datum/sprite_accessory/socks/white_norm
	name = "Normal (White)"
	icon_state = "white_norm"

/datum/sprite_accessory/socks/pantyhose
	name = "Pantyhose"
	icon_state = "pantyhose"

/datum/sprite_accessory/socks/black_short
	name = "Short (Black)"
	icon_state = "black_short"

/datum/sprite_accessory/socks/white_short
	name = "Short (White)"
	icon_state = "white_short"

/datum/sprite_accessory/socks/stockings_blue
	name = "Stockings (Blue)"
	icon_state = "stockings_blue"

/datum/sprite_accessory/socks/stockings_cyan
	name = "Stockings (Cyan)"
	icon_state = "stockings_cyan"

/datum/sprite_accessory/socks/stockings_dpink
	name = "Stockings (Dark Pink)"
	icon_state = "stockings_dpink"

/datum/sprite_accessory/socks/stockings_green
	name = "Stockings (Green)"
	icon_state = "stockings_green"

/datum/sprite_accessory/socks/stockings_orange
	name = "Stockings (Orange)"
	icon_state = "stockings_orange"

/datum/sprite_accessory/socks/stockings_programmer
	name = "Stockings (Programmer)"
	icon_state = "stockings_lpink"

/datum/sprite_accessory/socks/stockings_purple
	name = "Stockings (Purple)"
	icon_state = "stockings_purple"

/datum/sprite_accessory/socks/stockings_yellow
	name = "Stockings (Yellow)"
	icon_state = "stockings_yellow"

/datum/sprite_accessory/socks/stockings_fishnet
	name = "Stockings (Fishnet)"
	icon_state = "fishnet_full"

/datum/sprite_accessory/socks/ace_thigh
	name = "Thigh-high (Ace)"
	icon_state = "ace_thigh"

/datum/sprite_accessory/socks/bee_thigh
	name = "Thigh-high (Bee)"
	icon_state = "bee_thigh"

/datum/sprite_accessory/socks/black_thigh
	name = "Thigh-high (Black)"
	icon_state = "black_thigh"

/datum/sprite_accessory/socks/commie_thigh
	name = "Thigh-high (Commie)"
	icon_state = "commie_thigh"

/datum/sprite_accessory/socks/usa_thigh
	name = "Thigh-high (Freedom)"
	icon_state = "assblastusa_thigh"

/datum/sprite_accessory/socks/rainbow_thigh
	name = "Thigh-high (Rainbow)"
	icon_state = "rainbow_thigh"

/datum/sprite_accessory/socks/striped_thigh
	name = "Thigh-high (Striped)"
	icon_state = "striped_thigh"

/datum/sprite_accessory/socks/thin_thigh
	name = "Thigh-high (Thin)"
	icon_state = "thin_thigh"

/datum/sprite_accessory/socks/trans_thigh
	name = "Thigh-high (Trans)"
	icon_state = "trans_thigh"

/datum/sprite_accessory/socks/uk_thigh
	name = "Thigh-high (UK)"
	icon_state = "uk_thigh"

/datum/sprite_accessory/socks/white_thigh
	name = "Thigh-high (White)"
	icon_state = "white_thigh"

/datum/sprite_accessory/socks/fishnet_thigh
	name = "Thigh-high (Fishnet)"
	icon_state = "fishnet_thigh"

/datum/sprite_accessory/socks/thocks
	name = "Thocks"
	icon_state = "thocks"

//////////.//////////////////
// MutantParts Definitions //
/////////////////////////////

/datum/sprite_accessory/lizard_markings
	icon = 'icons/mob/human/species/lizard/lizard_markings.dmi'

/datum/sprite_accessory/lizard_markings/dtiger
	name = "Dark Tiger Body"
	icon_state = "dtiger"
	gender_specific = TRUE

/datum/sprite_accessory/lizard_markings/ltiger
	name = "Light Tiger Body"
	icon_state = "ltiger"
	gender_specific = TRUE

/datum/sprite_accessory/lizard_markings/lbelly
	name = "Light Belly"
	icon_state = "lbelly"
	gender_specific = TRUE

/datum/sprite_accessory/tails
	em_block = TRUE
	/// Describes which tail spine sprites to use, if any.
	var/spine_key = NONE

///Used for fish-infused tails, which come in different flavors.
/datum/sprite_accessory/tails/fish
	icon = 'icons/mob/human/fish_features.dmi'
	color_src = TRUE

/datum/sprite_accessory/tails/fish/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/tails/fish/crescent
	name = "Crescent"
	icon_state = "crescent"

/datum/sprite_accessory/tails/fish/long
	name = "Long"
	icon_state = "long"
	center = TRUE
	dimension_x = 38

/datum/sprite_accessory/tails/fish/shark
	name = "Shark"
	icon_state = "shark"

/datum/sprite_accessory/tails/fish/chonky
	name = "Chonky"
	icon_state = "chonky"
	center = TRUE
	dimension_x = 36

/datum/sprite_accessory/tails/lizard
	icon = 'icons/mob/human/species/lizard/lizard_tails.dmi'
	spine_key = SPINE_KEY_LIZARD

/datum/sprite_accessory/tails/lizard/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"
	natural_spawn = FALSE

/datum/sprite_accessory/tails/lizard/smooth
	name = "Smooth"
	icon_state = "smooth"

/datum/sprite_accessory/tails/lizard/dtiger
	name = "Dark Tiger"
	icon_state = "dtiger"

/datum/sprite_accessory/tails/lizard/ltiger
	name = "Light Tiger"
	icon_state = "ltiger"

/datum/sprite_accessory/tails/lizard/spikes
	name = "Spikes"
	icon_state = "spikes"

/datum/sprite_accessory/tails/lizard/short
	name = "Short"
	icon_state = "short"
	spine_key = NONE

/datum/sprite_accessory/tails/felinid/cat
	name = "Cat"
	icon = 'icons/mob/human/cat_features.dmi'
	icon_state = "default"
	color_src = HAIR_COLOR

/datum/sprite_accessory/tails/monkey

/datum/sprite_accessory/tails/monkey/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"
	natural_spawn = FALSE

/datum/sprite_accessory/tails/monkey/default
	name = "Monkey"
	icon = 'icons/mob/human/species/monkey/monkey_tail.dmi'
	icon_state = "default"
	color_src = FALSE

/datum/sprite_accessory/tails/xeno
	icon_state = "default"
	color_src = FALSE
	center = TRUE

/datum/sprite_accessory/tails/xeno/default
	name = "Xeno"
	icon = 'icons/mob/human/species/alien/tail_xenomorph.dmi'
	dimension_x = 40

/datum/sprite_accessory/tails/xeno/queen
	name = "Xeno Queen"
	icon = 'icons/mob/human/species/alien/tail_xenomorph_queen.dmi'
	dimension_x = 64

/datum/sprite_accessory/pod_hair
	icon = 'icons/mob/human/species/podperson_hair.dmi'
	em_block = TRUE

/datum/sprite_accessory/pod_hair/ivy
	name = "Ivy"
	icon_state = "ivy"

/datum/sprite_accessory/pod_hair/cabbage
	name = "Cabbage"
	icon_state = "cabbage"

/datum/sprite_accessory/pod_hair/spinach
	name = "Spinach"
	icon_state = "spinach"

/datum/sprite_accessory/pod_hair/prayer
	name = "Prayer"
	icon_state = "prayer"

/datum/sprite_accessory/pod_hair/vine
	name = "Vine"
	icon_state = "vine"

/datum/sprite_accessory/pod_hair/shrub
	name = "Shrub"
	icon_state = "shrub"

/datum/sprite_accessory/pod_hair/rose
	name = "Rose"
	icon_state = "rose"

/datum/sprite_accessory/pod_hair/orchid
	name = "Orchid"
	icon_state = "orchid"

/datum/sprite_accessory/pod_hair/fig
	name = "Fig"
	icon_state = "fig"

/datum/sprite_accessory/pod_hair/hibiscus
	name = "Hibiscus"
	icon_state = "hibiscus"

/datum/sprite_accessory/snouts
	icon = 'icons/mob/human/species/lizard/lizard_misc.dmi'
	em_block = TRUE

/datum/sprite_accessory/snouts/sharp
	name = "Sharp"
	icon_state = "sharp"

/datum/sprite_accessory/snouts/round
	name = "Round"
	icon_state = "round"

/datum/sprite_accessory/snouts/sharplight
	name = "Sharp + Light"
	icon_state = "sharplight"

/datum/sprite_accessory/snouts/roundlight
	name = "Round + Light"
	icon_state = "roundlight"

/datum/sprite_accessory/horns
	icon = 'icons/mob/human/species/lizard/lizard_misc.dmi'
	em_block = TRUE

/datum/sprite_accessory/horns/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/horns/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/horns/curled
	name = "Curled"
	icon_state = "curled"

/datum/sprite_accessory/horns/ram
	name = "Ram"
	icon_state = "ram"

/datum/sprite_accessory/horns/angler
	name = "Angeler"
	icon_state = "angler"

/datum/sprite_accessory/ears
	icon = 'icons/mob/human/cat_features.dmi'
	em_block = TRUE

/datum/sprite_accessory/ears/cat
	name = "Cat"
	icon_state = "cat"
	color_src = HAIR_COLOR

/datum/sprite_accessory/ears/cat/big
	name = "Big"
	icon_state = "big"

/datum/sprite_accessory/ears/cat/miqo
	name = "Coeurl"
	icon_state = "miqo"

/datum/sprite_accessory/ears/cat/fold
	name = "Fold"
	icon_state = "fold"

/datum/sprite_accessory/ears/cat/lynx
	name = "Lynx"
	icon_state = "lynx"

/datum/sprite_accessory/ears/cat/round
	name = "Round"
	icon_state = "round"

/datum/sprite_accessory/ears/cat/cybernetic
	name = "Cybernetic"
	icon_state = "cyber"
	locked = TRUE

/datum/sprite_accessory/ears/fox
	icon = 'icons/mob/human/fox_features.dmi'
	name = "Fox"
	icon_state = "fox"
	color_src = HAIR_COLOR
	locked = TRUE

/datum/sprite_accessory/wings
	icon = 'icons/mob/human/species/wings.dmi'
	em_block = TRUE

/datum/sprite_accessory/wings_open
	icon = 'icons/mob/human/species/wings.dmi'
	em_block = TRUE

/datum/sprite_accessory/wings/angel
	name = "Angel"
	icon_state = "angel"
	color_src = FALSE
	dimension_x = 46
	center = TRUE
	dimension_y = 34
	locked = TRUE

/datum/sprite_accessory/wings_open/angel
	name = "Angel"
	icon_state = "angel"
	color_src = FALSE
	dimension_x = 46
	center = TRUE
	dimension_y = 34

/datum/sprite_accessory/wings/dragon
	name = "Dragon"
	icon_state = "dragon"
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/dragon
	name = "Dragon"
	icon_state = "dragon"
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/megamoth
	name = "Megamoth"
	icon_state = "megamoth"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/megamoth
	name = "Megamoth"
	icon_state = "megamoth"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/mothra
	name = "Mothra"
	icon_state = "mothra"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/mothra
	name = "Mothra"
	icon_state = "mothra"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/skeleton
	name = "Skeleton"
	icon_state = "skele"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/skeleton
	name = "Skeleton"
	icon_state = "skele"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/robotic
	name = "Robotic"
	icon_state = "robotic"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/robotic
	name = "Robotic"
	icon_state = "robotic"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/fly
	name = "Fly"
	icon_state = "fly"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/fly
	name = "Fly"
	icon_state = "fly"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/slime
	name = "Slime"
	icon_state = "slime"
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/slime
	name = "Slime"
	icon_state = "slime"
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/frills
	icon = 'icons/mob/human/species/lizard/lizard_misc.dmi'

/datum/sprite_accessory/frills/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/frills/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/frills/aquatic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/spines
	icon = 'icons/mob/human/species/lizard/lizard_spines.dmi'
	em_block = TRUE

/datum/sprite_accessory/tail_spines
	icon = 'icons/mob/human/species/lizard/lizard_spines.dmi'
	em_block = TRUE

/datum/sprite_accessory/spines/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/tail_spines/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/spines/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"

/datum/sprite_accessory/tail_spines/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"

/datum/sprite_accessory/spines/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/tail_spines/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/spines/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"

/datum/sprite_accessory/tail_spines/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"

/datum/sprite_accessory/spines/aquatic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/tail_spines/aquatic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/caps
	icon = 'icons/mob/human/species/mush_cap.dmi'
	color_src = HAIR_COLOR
	em_block = TRUE

/datum/sprite_accessory/caps/round
	name = "Round"
	icon_state = "round"

/datum/sprite_accessory/moth_wings
	icon = 'icons/mob/human/species/moth/moth_wings.dmi'
	color_src = null
	em_block = TRUE

/datum/sprite_accessory/moth_wings/plain
	name = "Plain"
	icon_state = "plain"

/datum/sprite_accessory/moth_wings/monarch
	name = "Monarch"
	icon_state = "monarch"

/datum/sprite_accessory/moth_wings/luna
	name = "Luna"
	icon_state = "luna"

/datum/sprite_accessory/moth_wings/atlas
	name = "Atlas"
	icon_state = "atlas"

/datum/sprite_accessory/moth_wings/reddish
	name = "Reddish"
	icon_state = "redish"

/datum/sprite_accessory/moth_wings/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/moth_wings/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/moth_wings/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/moth_wings/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/moth_wings/burnt_off
	name = "Burnt Off"
	icon_state = "burnt_off"
	locked = TRUE

/datum/sprite_accessory/moth_wings/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/moth_wings/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/moth_wings/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/moth_wings/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/moth_wings/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/moth_wings/snow
	name = "Snow"
	icon_state = "snow"

/datum/sprite_accessory/moth_wings/oakworm
	name = "Oak Worm"
	icon_state = "oakworm"

/datum/sprite_accessory/moth_wings/jungle
	name = "Jungle"
	icon_state = "jungle"

/datum/sprite_accessory/moth_wings/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

/datum/sprite_accessory/moth_wings/rosy
	name = "Rosy"
	icon_state = "rosy"

/datum/sprite_accessory/moth_wings/feathery
	name = "Feathery"
	icon_state = "feathery"

/datum/sprite_accessory/moth_wings/brown
	name = "Brown"
	icon_state = "brown"

/datum/sprite_accessory/moth_wings/plasmafire
	name = "Plasmafire"
	icon_state = "plasmafire"

/datum/sprite_accessory/moth_wings/moffra
	name = "Moffra"
	icon_state = "moffra"

/datum/sprite_accessory/moth_wings/lightbearer
	name = "Lightbearer"
	icon_state = "lightbearer"

/datum/sprite_accessory/moth_wings/dipped
	name = "Dipped"
	icon_state = "dipped"

/datum/sprite_accessory/moth_antennae //Finally splitting the sprite
	icon = 'icons/mob/human/species/moth/moth_antennae.dmi'
	color_src = null

/datum/sprite_accessory/moth_antennae/plain
	name = "Plain"
	icon_state = "plain"

/datum/sprite_accessory/moth_antennae/reddish
	name = "Reddish"
	icon_state = "reddish"

/datum/sprite_accessory/moth_antennae/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/moth_antennae/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/moth_antennae/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/moth_antennae/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/moth_antennae/burnt_off
	name = "Burnt Off"
	icon_state = "burnt_off"

/datum/sprite_accessory/moth_antennae/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/moth_antennae/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/moth_antennae/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/moth_antennae/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/moth_antennae/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/moth_antennae/oakworm
	name = "Oak Worm"
	icon_state = "oakworm"

/datum/sprite_accessory/moth_antennae/jungle
	name = "Jungle"
	icon_state = "jungle"

/datum/sprite_accessory/moth_antennae/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

/datum/sprite_accessory/moth_antennae/regal
	name = "Regal"
	icon_state = "regal"
/datum/sprite_accessory/moth_antennae/rosy
	name = "Rosy"
	icon_state = "rosy"

/datum/sprite_accessory/moth_antennae/feathery
	name = "Feathery"
	icon_state = "feathery"

/datum/sprite_accessory/moth_antennae/brown
	name = "Brown"
	icon_state = "brown"

/datum/sprite_accessory/moth_antennae/plasmafire
	name = "Plasmafire"
	icon_state = "plasmafire"

/datum/sprite_accessory/moth_antennae/moffra
	name = "Moffra"
	icon_state = "moffra"

/datum/sprite_accessory/moth_antennae/lightbearer
	name = "Lightbearer"
	icon_state = "lightbearer"

/datum/sprite_accessory/moth_antennae/dipped
	name = "Dipped"
	icon_state = "dipped"

/datum/sprite_accessory/moth_antennae/greyscale
	icon = 'icons/mob/human/species/moth/moth_antennae_grayscale.dmi'
	color_src = USE_MATRIXED_COLORS

/datum/sprite_accessory/moth_antennae/greyscale/browngrey
	name = "Brown (Greyscale)"
	icon_state = "browngrey"

/datum/sprite_accessory/moth_antennae/greyscale/mothragrey
	name = "Mothra (Greyscale)"
	icon_state = "mothragrey"

/datum/sprite_accessory/moth_antennae/greyscale/plaingrey
	name = "Plain (Greyscale)"
	icon_state = "plaingrey"

/datum/sprite_accessory/moth_antennae/greyscale/firewatchgrey
	name = "Firewatch (Greyscale)"
	icon_state = "firewatchgrey"

/datum/sprite_accessory/moth_antennae/greyscale/regalgrey
	name = "Regal (Greyscale)"
	icon_state = "regalgrey"

/datum/sprite_accessory/moth_antennae/greyscale/poisongrey
	name = "Poison (Greyscale)"
	icon_state = "poisongrey"

/datum/sprite_accessory/moth_antennae/greyscale/featherygrey
	name = "Feathery (Greyscale)"
	icon_state = "featherygrey"

/datum/sprite_accessory/moth_antennae/greyscale/rosygrey
	name = "Rosy (Greyscale)"
	icon_state = "rosygrey"

/datum/sprite_accessory/moth_antennae/greyscale/junglegrey
	name = "Jungle (Greyscale)"
	icon_state = "junglegrey"

/datum/sprite_accessory/moth_antennae/greyscale/moffragrey
	name = "Moffra (Greyscale)"
	icon_state = "moffragrey"

/datum/sprite_accessory/moth_antennae/greyscale/oakwormgrey
	name = "Oakworm (Greyscale)"
	icon_state = "oakwormgrey"

/datum/sprite_accessory/moth_antennae/greyscale/plasmafiregrey
	name = "Plasmafire (Greyscale)"
	icon_state = "plasmafiregrey"

/datum/sprite_accessory/moth_antennae/greyscale/plasmafiregrey
	name = "Plasmafire (Greyscale)"
	icon_state = "plasmafiregrey"

/datum/sprite_accessory/moth_antennae/greyscale/royalgrey
	name = "Royal (Greyscale)"
	icon_state = "royalgrey"

/datum/sprite_accessory/moth_antennae/greyscale/loversgrey
	name = "Lovers (Greyscale)"
	icon_state = "loversgrey"

/datum/sprite_accessory/moth_antennae/greyscale/whiteflygrey
	name = "Whitefly (Greyscale)"
	icon_state = "whiteflygrey"

/datum/sprite_accessory/moth_antennae/greyscale/witchwinggrey
	name = "Witchwing (Greyscale)"
	icon_state = "witchwinggrey"

/datum/sprite_accessory/moth_markings // the markings that moths can have. finally something other than the boring tan
	icon = 'icons/mob/human/species/moth/moth_markings.dmi'
	color_src = null

/datum/sprite_accessory/moth_markings/reddish
	name = "Reddish"
	icon_state = "reddish"

/datum/sprite_accessory/moth_markings/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/moth_markings/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/moth_markings/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/moth_markings/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/moth_markings/burnt_off
	name = "Burnt Off"
	icon_state = "burnt_off"

/datum/sprite_accessory/moth_markings/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/moth_markings/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/moth_markings/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/moth_markings/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/moth_markings/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/moth_markings/oakworm
	name = "Oak Worm"
	icon_state = "oakworm"

/datum/sprite_accessory/moth_markings/jungle
	name = "Jungle"
	icon_state = "jungle"

/datum/sprite_accessory/moth_markings/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

/datum/sprite_accessory/moth_markings/lightbearer
	name = "Lightbearer"
	icon_state = "lightbearer"

/datum/sprite_accessory/moth_markings/dipped
	name = "Dipped"
	icon_state = "dipped"
