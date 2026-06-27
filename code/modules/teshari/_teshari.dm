#define TESHARI_TEMP_OFFSET -30 // K, added to comfort/damage limit etc
#define TESHARI_HEATMOD 1.3
#define TESHARI_COLDMOD 0.67 // Except cold.

/datum/species/teshari
	name = "Teshari"
	id = SPECIES_TESHARI
	no_gender_shaping = TRUE // Female uniform shaping breaks Teshari worn sprites, so this is disabled. This will not affect anything else in regards to gender however.
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_MUTANT_COLORS,
	)
	digitigrade_customization = DIGITIGRADE_NEVER
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	payday_modifier = 1.0
	mutanttongue = /obj/item/organ/tongue/teshari
	custom_worn_icons = list(
		LOADOUT_ITEM_HEAD = TESHARI_HEAD_ICON,
		LOADOUT_ITEM_MASK = TESHARI_MASK_ICON,
		LOADOUT_ITEM_NECK = TESHARI_NECK_ICON,
		LOADOUT_ITEM_SUIT = TESHARI_SUIT_ICON,
		LOADOUT_ITEM_UNIFORM = TESHARI_UNIFORM_ICON,
		LOADOUT_ITEM_HANDS =  TESHARI_HANDS_ICON,
		LOADOUT_ITEM_SHOES = TESHARI_FEET_ICON,
		LOADOUT_ITEM_GLASSES = TESHARI_EYES_ICON,
		LOADOUT_ITEM_BELT = TESHARI_BELT_ICON,
		LOADOUT_ITEM_MISC = TESHARI_BACK_ICON,
		LOADOUT_ITEM_ACCESSORY = TESHARI_ACCESSORIES_ICON,
		LOADOUT_ITEM_EARS = TESHARI_EARS_ICON
	)
	coldmod = TESHARI_COLDMOD
	heatmod = TESHARI_HEATMOD
	bodytemp_normal = BODYTEMP_NORMAL + TESHARI_TEMP_OFFSET
	bodytemp_heat_damage_limit = (BODYTEMP_HEAT_DAMAGE_LIMIT + TESHARI_TEMP_OFFSET)
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT + TESHARI_TEMP_OFFSET)
	species_language_holder = /datum/language_holder/teshari
	mutantears = /obj/item/organ/ears/teshari
	body_size_restricted = TRUE
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/mutant/teshari,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/mutant/teshari,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/mutant/teshari,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/mutant/teshari,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/mutant/teshari,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/mutant/teshari,
	)

/datum/species/teshari/get_species_description()
	return placeholder_description

/datum/species/teshari/get_species_lore()
	return list(placeholder_lore)

/datum/species/teshari/get_default_mutant_bodyparts()
	return list(
		FEATURE_TAIL = MUTPART_BLUEPRINT("Teshari (Default)", is_randomizable = TRUE),
		FEATURE_EARS = MUTPART_BLUEPRINT("Teshari Regular", is_randomizable = TRUE),
		FEATURE_LEGS = MUTPART_BLUEPRINT(NORMAL_LEGS, is_randomizable = FALSE, is_feature = TRUE),
	)

/obj/item/organ/tongue/teshari
	liked_foodtypes = MEAT | GORE | RAW
	disliked_foodtypes = GROSS | GRAIN

/datum/species/teshari/prepare_human_for_preview(mob/living/carbon/human/tesh)
	var/base_color = "#c0965f"
	var/ear_color = "#e4c49b"

	tesh.dna.features[FEATURE_MUTANT_COLOR] = base_color
	tesh.dna.mutant_bodyparts[FEATURE_EARS] = build_mutant_part("Teshari Feathers Upright", list(ear_color, ear_color, ear_color))
	tesh.dna.mutant_bodyparts[FEATURE_TAIL] = build_mutant_part("Teshari (Default)", list(base_color, base_color, ear_color))
	regenerate_organs(tesh, src, visual_only = TRUE)
	tesh.update_body(TRUE)

/datum/species/teshari/on_species_gain(mob/living/carbon/human/new_teshari, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	passtable_on(new_teshari, SPECIES_TRAIT)

/datum/species/teshari/on_species_loss(mob/living/carbon/C, datum/species/new_species, pref_load)
	. = ..()
	passtable_off(C, SPECIES_TRAIT)


// HowlingVoid teshari mechanics integration.
/datum/actionspeed_modifier/teshari_technical_aptitude
	id = ACTIONSPEED_ID_HOWLING_TESHARI_TECH_APTITUDE
	variable = TRUE

/obj/effect/temp_visual/howling_teshari_feathers
	name = "feathers"
	icon = 'icons/lewd/icons/obj/lewd_decals/lewd_decals.dmi'
	icon_state = "feathers"
	duration = 14

/datum/effect_system/basic/howling_teshari_feathers
	effect_type = /obj/effect/temp_visual/howling_teshari_feathers

/datum/species/teshari
	/// Cached feather hit effects per Teshari (key = mob)
	var/tmp/list/teshari_hit_feather_effects = list()

/datum/species/teshari/on_species_gain(mob/living/carbon/human/new_teshari, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if(!istype(new_teshari))
		return

	if(!teshari_hit_feather_effects[new_teshari])
		var/datum/effect_system/basic/howling_teshari_feathers/hit_feathers = new(new_teshari, 2, FALSE)
		hit_feathers.attach(new_teshari)
		teshari_hit_feather_effects[new_teshari] = hit_feathers

	RegisterSignal(new_teshari, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(on_teshari_after_apply_damage))

	// Teshari are naturally fast and precise with interaction-heavy work.
	new_teshari.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/teshari_technical_aptitude, multiplicative_slowdown = -0.12)

/datum/species/teshari/on_species_loss(mob/living/carbon/C, datum/species/new_species, pref_load)
	. = ..()
	if(!istype(C, /mob/living/carbon/human))
		return

	var/mob/living/carbon/human/former_teshari = C
	former_teshari.remove_actionspeed_modifier(ACTIONSPEED_ID_HOWLING_TESHARI_TECH_APTITUDE)
	UnregisterSignal(former_teshari, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	var/datum/effect_system/basic/howling_teshari_feathers/feather_effect = teshari_hit_feather_effects[former_teshari]
	if(feather_effect)
		qdel(feather_effect)
	teshari_hit_feather_effects -= former_teshari

/datum/species/teshari/proc/on_teshari_after_apply_damage(
	mob/living/carbon/human/source,
	damage_dealt,
	damagetype,
	def_zone,
	blocked,
	wound_bonus,
	exposed_wound_bonus,
	sharpness,
	attack_direction,
	obj/item/attacking_item
)
	SIGNAL_HANDLER

	if(!istype(source))
		return
	if(damage_dealt <= 0)
		return
	if(damagetype == STAMINA)
		return

	var/datum/effect_system/basic/howling_teshari_feathers/feather_effect = teshari_hit_feather_effects[source]
	feather_effect?.start()

/datum/species/teshari/get_species_description()
	return "Teshari are lightweight avian sophonts with fast reflexes, compact bodies, and strong adaptation to colder climates."

/datum/species/teshari/get_species_lore()
	return list(
		"Teshari communities are often organized around close-knit flocks, practical cooperation, and technical skill.",
		"Their physiology favors lower temperatures and agility, while heat and prolonged high-temperature exposure are more dangerous for them.",
		"Their small frame helps them navigate tight spaces, and many teshari are known for quick hands and precise tool use.",
	)

/datum/species/teshari/create_pref_unique_perks()
	. = ..()
	. += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Small Frame",
			SPECIES_PERK_DESC = "Teshari can slip through spaces that larger species cannot, making repositioning and escape easier.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "snowflake",
			SPECIES_PERK_NAME = "Cold-Adapted",
			SPECIES_PERK_DESC = "Teshari tolerate cold environments better than baseline humans.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "screwdriver-wrench",
			SPECIES_PERK_NAME = "Technical Aptitude",
			SPECIES_PERK_DESC = "Teshari perform most interaction-based actions about 12% faster.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "ear-listen",
			SPECIES_PERK_NAME = "Sensitive Hearing",
			SPECIES_PERK_DESC = "Teshari can pick up quieter sounds better than many other species.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Heat Fragility",
			SPECIES_PERK_DESC = "Teshari are more vulnerable to heat and overheat faster in hot environments.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "drumstick-bite",
			SPECIES_PERK_NAME = "Sensitive Diet",
			SPECIES_PERK_DESC = "Teshari strongly prefer meat/raw foods and tend to dislike grain-heavy or gross meals.",
		),
	)

