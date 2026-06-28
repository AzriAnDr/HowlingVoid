/**
 * Xenobiological Slime Hybrid
 *
 * Port of the Xenobiological Slime Hybrid species from EndlessSpace13 (originally Skyrat).
 * Preserves ES13 gameplay feel:
 *   - Alter Form ability (change appearance freely, inherited from HV jelly)
 *   - Limb Regeneration ability (regrow missing limbs using jelly, inherited from TG base)
 *   - Toggle Transparency ability (opaque/translucent toggle)
 *   - Jelly/blood mechanics from TG base (nutrition-based jelly regen, limb cannibalization)
 *   - No HV-exclusive additions: no core ejection, no passive HP healing, no slime washing,
 *     no hydrophobia toggle, no core GPS signal, no wetness-based water damage.
 */

#define BODYPART_ICON_XENOSLIME 'icons/mob/human/species/slime_parts_greyscale.dmi'
#define XENOSLIME_BLEED_MOD 1.5
#define XENOSLIME_JELLY_REGEN_RATE 0.5

// ============================================================
// BODYPART TYPES — 6 regular + 2 digitigrade
// ============================================================

/obj/item/bodypart/head/jelly/slime/roundstart/xenoslime
	icon_greyscale = BODYPART_ICON_XENOSLIME

/obj/item/bodypart/chest/jelly/slime/roundstart/xenoslime
	icon_greyscale = BODYPART_ICON_XENOSLIME

/obj/item/bodypart/arm/left/jelly/slime/roundstart/xenoslime
	icon_greyscale = BODYPART_ICON_XENOSLIME

/obj/item/bodypart/arm/right/jelly/slime/roundstart/xenoslime
	icon_greyscale = BODYPART_ICON_XENOSLIME

/obj/item/bodypart/leg/left/jelly/slime/roundstart/xenoslime
	icon_greyscale = BODYPART_ICON_XENOSLIME
	digitigrade_type = /obj/item/bodypart/leg/left/digitigrade/jelly/slime/roundstart/xenoslime

/obj/item/bodypart/leg/right/jelly/slime/roundstart/xenoslime
	icon_greyscale = BODYPART_ICON_XENOSLIME
	digitigrade_type = /obj/item/bodypart/leg/right/digitigrade/jelly/slime/roundstart/xenoslime

/// Digitigrade leg variants — use xenoslime sprites from BODYPART_ICON_XENOSLIME.
/obj/item/bodypart/leg/left/digitigrade/jelly/slime/roundstart/xenoslime
	icon_greyscale = BODYPART_ICON_XENOSLIME

/obj/item/bodypart/leg/right/digitigrade/jelly/slime/roundstart/xenoslime
	icon_greyscale = BODYPART_ICON_XENOSLIME

// ============================================================
// SPECIES DEFINITION
// ============================================================

/datum/species/jelly/xenoslime
	name = "Xenobiological Slime Hybrid"
	plural_form = "Xenoslimes"
	id = SPECIES_XENOSLIME
	examine_limb_id = SPECIES_SLIMEPERSON
	coldmod = 3
	heatmod = 1
	specific_alpha = 155
	markings_alpha = 130 // Lower so stacked alpha values don't over-opaque markings
	mutanteyes = /obj/item/organ/eyes/xenoslime              // 10x decay eyes
	mutanttongue = /obj/item/organ/tongue/jelly/xenoslime    // 10x decay jelly tongue
	mutantlungs = null                                        // No lungs — breathes via TRAIT_NOBREATH
	mutantbrain = /obj/item/organ/brain/xenoslime             // Slime Core — custom name, icon, 10x decay
	mutantliver = /obj/item/organ/liver/xenoslime             // Metabolic gel matrix — distributed biology
	mutantstomach = /obj/item/organ/stomach/xenoslime         // Digestive gel matrix — distributed biology
	mutantears = /obj/item/organ/ears/xenoslime               // 10x decay ears
	mutantappendix = null                                     // No appendix
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_TOXINLOVER,
		TRAIT_NOBREATH,
		TRAIT_NO_BONE_WOUNDS,
	)
	bodypart_overrides = list(
		BODY_ZONE_HEAD =  /obj/item/bodypart/head/jelly/slime/roundstart/xenoslime,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/jelly/slime/roundstart/xenoslime,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/jelly/slime/roundstart/xenoslime,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/jelly/slime/roundstart/xenoslime,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/jelly/slime/roundstart/xenoslime,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/jelly/slime/roundstart/xenoslime,
	)
	/// Whether this species can freely toggle their transparency.
	var/can_toggle_transparency = TRUE
	/// Tracked Toggle Transparency action instance.
	var/datum/action/innate/slime_toggle_transparency/toggle_transparency
	/// Skip HV jelly's passive healing and wetness water damage — not present in ES13.
	skip_hv_spec_life = TRUE
	jelly_regen_rate = XENOSLIME_JELLY_REGEN_RATE
	blood_deficiency_drain_rate = XENOSLIME_JELLY_REGEN_RATE + BLOOD_DEFICIENCY_MODIFIER

/datum/species/jelly/xenoslime/on_species_gain(mob/living/carbon/new_jellyperson, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	// The parent chain grants: regenerate_limbs (TG base), slime_blood signal (TG base),
	// soft_landing (TG base), alter_form (HV jelly), slime_washing (HV jelly),
	// slime_hydrophobia (HV jelly), core_signal (HV jelly).
	// Remove the HV-exclusive actions that don't exist in ES13:
	if(slime_washing)
		slime_washing.Remove(new_jellyperson)
		qdel(slime_washing)
		slime_washing = null
	if(slime_hydrophobia)
		slime_hydrophobia.Remove(new_jellyperson)
		qdel(slime_hydrophobia)
		slime_hydrophobia = null
	if(core_signal)
		core_signal.Remove(new_jellyperson)
		qdel(core_signal)
		core_signal = null
	// Xenoslime is more vulnerable to extreme pressure
	if(ishuman(new_jellyperson))
		var/mob/living/carbon/human/H = new_jellyperson
		H.physiology.pressure_mod *= 3
		H.physiology.bleed_mod *= XENOSLIME_BLEED_MOD
	// Grant the ES13-style transparency toggle
	if(can_toggle_transparency && ishuman(new_jellyperson))
		toggle_transparency = new
		toggle_transparency.transparent_alpha = specific_alpha
		toggle_transparency.Grant(new_jellyperson)
		toggle_transparency.sync_with_owner()
	// Transparency is applied per-bodypart via specific_alpha during update_body_parts()

/datum/species/jelly/xenoslime/on_species_loss(mob/living/carbon/former_jellyperson, datum/species/new_species, pref_load)
	if(toggle_transparency)
		specific_alpha = toggle_transparency.transparent_alpha
		toggle_transparency.Remove(former_jellyperson)
		toggle_transparency = null
	if(ishuman(former_jellyperson))
		var/mob/living/carbon/human/H = former_jellyperson
		H.physiology.pressure_mod /= 3  // Revert pressure vulnerability
		H.physiology.bleed_mod /= XENOSLIME_BLEED_MOD

	return ..()

/datum/species/jelly/xenoslime/spec_life(mob/living/carbon/human/H, seconds_per_tick)
	. = ..()
	if(!H.reagents?.total_volume)
		return
	// Accelerated metabolism: all reagents are consumed 3x faster.
	// Toxins (damage reagents): metabolize_reagent called 2 extra times per tick.
	// Non-toxins (medicines, food, etc.): extra volume removed without effects.
	for(var/datum/reagent/reagent in H.reagents.reagent_list.Copy())
		if(QDELETED(reagent) || QDELETED(reagent.holder))
			continue
		if(istype(reagent, /datum/reagent/toxin))
			H.reagents.metabolize_reagent(H, reagent, seconds_per_tick)
			if(!QDELETED(reagent) && !QDELETED(reagent.holder))
				H.reagents.metabolize_reagent(H, reagent, seconds_per_tick)
		else
			H.reagents.remove_reagent(reagent.type, reagent.metabolization_rate * seconds_per_tick * 2)

/datum/species/jelly/xenoslime/create_pref_unique_perks()
	var/list/to_add = list()
	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "biohazard",
		SPECIES_PERK_NAME = "Squishy Form",
		SPECIES_PERK_DESC = "Being made of slime, you have the ability to alter your physical form to be whatever you choose! \
			You may grow ears, change your hair, and even become a taur-like if you so choose, at the press of a button and the snap of a finger!",
	))
	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "bone",
		SPECIES_PERK_NAME = "Gelatinous Anatomy",
		SPECIES_PERK_DESC = "Your flexible body cannot suffer fractures, dislocations, or other bone and joint wounds, \
			but open wounds leak jelly 50% faster.",
	))
	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "heart",
		SPECIES_PERK_NAME = "Heartless",
		SPECIES_PERK_DESC = "Your body lacks a conventional heart. Cardiac arrest and heart attacks are impossible for you. \
			Standard and cybernetic hearts cannot be inserted into your body, but special hearts \
			(cursed heart, heart of darkness, demon heart, fleshy mass) remain compatible with your biology.",
	))
	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "wind",
		SPECIES_PERK_NAME = "No Lungs",
		SPECIES_PERK_DESC = "Your gelatinous body exchanges gases through its surface and requires no lungs. \
			You are completely immune to suffocation, toxic atmospheres, and other breathing-related hazards.",
	))
	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "diagnoses",
		SPECIES_PERK_NAME = "Distributed Biology",
		SPECIES_PERK_DESC = "You lack discrete internal organs — no liver, stomach, or appendix. \
			Your biological functions are distributed throughout your gelatinous body, making organ-targeted \
			surgery and certain chemicals largely ineffective against you.",
	))
	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "bolt",
		SPECIES_PERK_NAME = "Accelerated Metabolism",
		SPECIES_PERK_DESC = "Reagents metabolize in your body 3x faster than normal. \
			Toxins and harmful substances act 3x faster at full potency. \
			Medicines are flushed out 3x faster without healing faster — each dose provides only a third of its normal total benefit.",
	))
	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "exclamation-triangle",
		SPECIES_PERK_NAME = "Pressure Sensitivity",
		SPECIES_PERK_DESC = "Your gelatinous composition offers little structural resistance to extreme pressure. \
			You take 3x normal brute damage from both very high and very low pressure environments.",
	))
	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "skull",
		SPECIES_PERK_NAME = "Rapid Organ Decay",
		SPECIES_PERK_DESC = "Your internal biology degrades 10x faster than normal outside of a living body — \
			both in your corpse and when organs are removed. Fortunately, your distributed biology self-repairs \
			these organs as long as you are alive.",
	))
	return to_add

/datum/species/jelly/xenoslime/apply_supplementary_body_changes(mob/living/carbon/human/target, datum/preferences/preferences, visuals_only = FALSE)
	if(preferences?.read_preference(/datum/preference/toggle/allow_mismatched_hair_color))
		target.dna.species.hair_color_mode = null

/// Xenoslime already describes no-breath in the "No Lungs" unique perk — skip the auto-generated duplicate.
/datum/species/jelly/xenoslime/create_pref_traits_perks()
	var/list/perks = ..() || list()
	for(var/list/perk as anything in perks)
		if(perk[SPECIES_PERK_NAME] == "No Respiration")
			perks -= list(perk)
			break
	return perks

// ============================================================
// TOGGLE TRANSPARENCY ACTION (ported from ES13 / Skyrat)
// ============================================================

/**
 * Allows the Xenobiological Slime Hybrid to toggle between their natural translucency
 * and a fully opaque form that hides their inner anatomy.
 */
/datum/action/innate/slime_toggle_transparency
	name = "Toggle Transparency"
	desc = "Focus your body to become opaque, hiding your inner workings, or relax to regain your natural translucent sheen."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_nif.dmi'
	button_icon_state = "slime"
	background_icon_state = "bg_alien"
	/// Alpha value used when the slime is translucent (their natural state).
	var/transparent_alpha = 155
	/// Alpha value used when the slime is fully opaque.
	var/opaque_alpha = 255

/datum/action/innate/slime_toggle_transparency/Grant(mob/grant_to)
	. = ..()
	sync_with_owner()

/datum/action/innate/slime_toggle_transparency/proc/sync_with_owner()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/slime = owner
	var/datum/species/species = slime.dna?.species
	if(!species)
		return
	active = (species.specific_alpha >= opaque_alpha)
	overlay_icon_state = active ? "bg_alien_border" : null
	build_all_button_icons(UPDATE_BUTTON_OVERLAY | UPDATE_BUTTON_STATUS)

/datum/action/innate/slime_toggle_transparency/Activate()
	var/change_state = apply_alpha_to_owner(opaque_alpha)
	if(isnull(change_state))
		return
	if(!change_state)
		sync_with_owner()
		return
	to_chat(owner, span_notice("You concentrate and solidify your body, hiding its inner workings."))
	sync_with_owner()

/datum/action/innate/slime_toggle_transparency/Deactivate()
	var/change_state = apply_alpha_to_owner(transparent_alpha)
	if(isnull(change_state))
		return
	if(!change_state)
		sync_with_owner()
		return
	to_chat(owner, span_notice("You relax, letting your body become translucent once more."))
	sync_with_owner()

/datum/action/innate/slime_toggle_transparency/proc/apply_alpha_to_owner(desired_alpha)
	if(!ishuman(owner))
		return null
	var/mob/living/carbon/human/slime = owner
	var/datum/species/species = slime.dna?.species
	if(!species)
		return null
	if(species.specific_alpha == desired_alpha)
		return FALSE
	species.specific_alpha = desired_alpha
	slime.update_body()
	return TRUE

// ============================================================
// XENOSLIME ORGAN TYPES
// ============================================================

/// Brain replacement — the xenoslime's neural core. Custom name, sprite, and 10x decay rate.
/obj/item/organ/brain/xenoslime
	name = "slime core"
	desc = "The crystallized neural core of a slime hybrid. Dense with compressed memories and consciousness."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "slime_core"
	decay_factor = STANDARD_ORGAN_DECAY * 5  // Brain base is 0.5x STANDARD; 10x = 5x STANDARD

/// Eyes with 10x decay rate.
/obj/item/organ/eyes/xenoslime
	decay_factor = STANDARD_ORGAN_DECAY * 10

/// Eye overlays respect species transparency so the face becomes translucent together with the body.
/obj/item/organ/eyes/xenoslime/generate_body_overlay(mob/living/carbon/human/parent)
	var/list/result = ..()
	var/datum/species/sp = parent.dna?.species
	if(sp && sp.specific_alpha != 255)
		for(var/mutable_appearance/overlay as anything in result)
			if(overlay.alpha > 0)
				overlay.alpha = sp.specific_alpha
	return result

/// Jelly tongue with 10x decay rate.
/obj/item/organ/tongue/jelly/xenoslime
	decay_factor = STANDARD_ORGAN_DECAY * 10

/// Ears with 10x decay rate.
/obj/item/organ/ears/xenoslime
	decay_factor = STANDARD_ORGAN_DECAY * 10

/// Distributed metabolic organ — represents xenoslime liver function.
/obj/item/organ/liver/xenoslime
	name = "metabolic gel matrix"
	desc = "A distributed metabolic structure unique to slime biology. Part of the slime's body."
	decay_factor = 0
	organ_flags = ORGAN_ORGANIC | ORGAN_UNREMOVABLE

/obj/item/organ/liver/xenoslime/show_on_condensed_scans()
	return FALSE

/// Xenoslime biology self-repairs even from total organ failure.
/// Since ORGAN_UNREMOVABLE means no surgical replacement is possible, the organ heals itself
/// rather than permanently failing. ORGAN_FAILING is cleared by apply_organ_damage when
/// damage drops below maxHealth (see check_damage_thresholds).
/obj/item/organ/liver/xenoslime/handle_failing_organs(seconds_per_tick)
	var/healing_amount = healing_factor
	healing_amount += (owner?.satiety > 0) ? (4 * healing_factor * owner.satiety / MAX_SATIETY) : 0
	apply_organ_damage(-healing_amount * maxHealth * seconds_per_tick, damage)

/// Distributed digestive organ — represents xenoslime stomach function.
/obj/item/organ/stomach/xenoslime
	name = "digestive gel matrix"
	desc = "A distributed digestive structure unique to slime biology. Part of the slime's body."
	decay_factor = 0
	organ_flags = ORGAN_ORGANIC | ORGAN_UNREMOVABLE

/obj/item/organ/stomach/xenoslime/show_on_condensed_scans()
	return FALSE

/// Same self-repair logic as the liver — ORGAN_UNREMOVABLE demands a fallback.
/obj/item/organ/stomach/xenoslime/handle_failing_organs(seconds_per_tick)
	var/healing_amount = healing_factor
	healing_amount += (owner?.satiety > 0) ? (4 * healing_factor * owner.satiety / MAX_SATIETY) : 0
	apply_organ_damage(-healing_amount * maxHealth * seconds_per_tick, damage)

// ============================================================
// NO CPR — Xenoslime has TRAIT_NOBREATH as an inherent trait.
// The core do_cpr() check only blocks disease-sourced TRAIT_NOBREATH,
// so we override help() to prevent xenoslimes from performing CPR.
// ============================================================

/datum/species/jelly/xenoslime/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.body_position == STANDING_UP || (target.appears_alive() && target.stat != SOFT_CRIT && target.stat != HARD_CRIT))
		return ..()
	// Xenoslime has no lungs or breath — CPR is impossible.
	user.balloon_alert(user, "you have no lungs to perform CPR!")
	return TRUE

// ============================================================
// HEART COMPATIBILITY — Xenoslime
// mutantheart = null blocks all standard hearts from being auto-generated.
// This override also gates surgical insertion: only special hearts are accepted.
// Allowed: cursed heart, fleshy mass (gland), demon heart, nightmare heart.
// ============================================================

/obj/item/organ/heart/Insert(mob/living/carbon/receiver, special = FALSE, movement_flags)
	if(receiver?.dna?.species && istype(receiver.dna.species, /datum/species/jelly/xenoslime))
		if(!istype(src, /obj/item/organ/heart/cursed) && \
		   !istype(src, /obj/item/organ/heart/gland) && \
		   !istype(src, /obj/item/organ/heart/demon) && \
		   !istype(src, /obj/item/organ/heart/nightmare))
			to_chat(receiver, span_warning("The heart dissolves on contact with your gel — it is incompatible with your biology!"))
			return FALSE
	return ..()

#undef BODYPART_ICON_XENOSLIME
#undef XENOSLIME_BLEED_MOD
#undef XENOSLIME_JELLY_REGEN_RATE
