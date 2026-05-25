/mob/living/carbon/human/species/insectoid
	race = /datum/species/insectoid

/datum/species/insectoid
	name = "\improper Insectoid"
	plural_form = "Insectoid"
	id = SPECIES_INSECTOID
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_WEB_WEAVER,
		TRAIT_WEB_SURFER,
	)
	meat = /obj/item/food/meat/slab/spider
	exotic_bloodtype = "Chlorocruorin" // awkwardly not a define
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	payday_modifier = 1.0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	digitigrade_customization = DIGITIGRADE_OPTIONAL
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/insectoid,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/insectoid,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/insectoid,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/insectoid,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade/insectoid,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade/insectoid,
	)

	mutanteyes = /obj/item/organ/eyes/bug
	mutantstomach = /obj/item/organ/stomach/roach
	mutantliver = /obj/item/organ/liver/roach
	mutantappendix = /obj/item/organ/appendix/roach

/datum/species/insectoid/get_default_mutant_bodyparts()
	return list(
		FEATURE_EARS = MUTPART_BLUEPRINT("Royal Antenna", is_randomizable = FALSE),
		FEATURE_TAIL = MUTPART_BLUEPRINT("Insectoid", is_randomizable = FALSE),
		FEATURE_WINGS = MUTPART_BLUEPRINT("Insectoid II", is_randomizable = FALSE),
		FEATURE_FLUFF = MUTPART_BLUEPRINT("Insectoid", is_randomizable = FALSE),
		FEATURE_LEGS = MUTPART_BLUEPRINT(NORMAL_LEGS, is_randomizable = FALSE, is_feature = TRUE),
		FEATURE_TAUR = MUTPART_BLUEPRINT(SPRITE_ACCESSORY_NONE, is_randomizable = FALSE),
	)

/datum/species/insectoid/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	human_for_preview.dna.features[FEATURE_MUTANT_COLOR] = "#292929"
	human_for_preview.dna.mutant_bodyparts[FEATURE_EARS] = build_mutant_part("Royal Antenna")
	human_for_preview.dna.mutant_bodyparts[FEATURE_FLUFF] = build_mutant_part("Insectoid")
	regenerate_organs(human_for_preview)
	human_for_preview.update_body(is_creating = TRUE)

/datum/species/insectoid/get_species_description()
	return "Nothing yet."

/datum/species/insectoid/get_species_lore()
	return list(
		"Nothing yet.",
	)

/obj/item/organ/eyes/bug
	blink_animation = FALSE

// HowlingVoid insectoid mechanics integration.
/datum/species/insectoid/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	if(!istype(H))
		return

	RegisterSignal(H, COMSIG_MOVABLE_MOVED, PROC_REF(update_web_mobility))
	RegisterSignal(H, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(on_insectoid_damage_modifiers))
	update_web_mobility(H, null)

/datum/species/insectoid/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	if(!istype(H))
		return

	UnregisterSignal(H, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(H, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)
	H.remove_movespeed_modifier(/datum/movespeed_modifier/insectoid_web_stride)

/datum/species/insectoid/proc/update_web_mobility(mob/living/carbon/human/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(!istype(source))
		return

	var/obj/structure/spider/stickyweb/web = locate() in get_turf(source)
	if(web)
		source.add_movespeed_modifier(/datum/movespeed_modifier/insectoid_web_stride)
	else
		source.remove_movespeed_modifier(/datum/movespeed_modifier/insectoid_web_stride)

/datum/species/insectoid/proc/on_insectoid_damage_modifiers(mob/living/carbon/human/source, list/damage_mods, damage, damagetype, def_zone, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER

	if(!istype(source))
		return
	if(damagetype != BURN)
		return

	// Chitinous plates are great utility armor, but dry quickly and scorch easier.
	damage_mods += 1.15

/datum/movespeed_modifier/insectoid_web_stride
	multiplicative_slowdown = -0.2

/datum/species/insectoid/get_species_description()
	return "Insectoids are adaptable arthropod humanoids. Their physiology is tuned for survival through filth, web-work, and tenacity rather than brute durability."

/datum/species/insectoid/get_species_lore()
	return list(
		"Insectoids evolved as communal survivors: practical, tireless, and comfortable in environments most species find revolting.",
		"Their spinnerets and web instincts make them natural trap-layers, route controllers, and maintenance specialists.",
		"Despite their resilience and utility, insectoid bodies are not built for raw punishment and rely on positioning and preparation.",
	)

/datum/species/insectoid/create_pref_unique_perks()
	var/list/perks = list()
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_SPIDER,
		SPECIES_PERK_NAME = "Web Weaver",
		SPECIES_PERK_DESC = "Insectoids can produce webbing and excel at shaping movement paths and choke points.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_SPIDER,
		SPECIES_PERK_NAME = "Web Surfer",
		SPECIES_PERK_DESC = "Insectoids receive a movement speed bonus while standing on webbing, letting them control fights around prepared zones.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_BACTERIA,
		SPECIES_PERK_NAME = "Carrion Metabolism",
		SPECIES_PERK_DESC = "Roach-adapted internal organs reduce disgust from foul foods, but their toxin handling has notable tradeoffs.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_FIRE,
		SPECIES_PERK_NAME = "Dry Carapace",
		SPECIES_PERK_DESC = "Insectoid shells ignite and scorch easier than human skin, making burn damage more punishing.",
	))
	return perks

