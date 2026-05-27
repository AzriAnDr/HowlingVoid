/mob/living/carbon/human
	var/arousal = 0
	var/pleasure = 0
	var/pain = 0

	var/pain_limit = 0
	var/arousal_status = AROUSAL_NONE

	// Add variables for slots to the human class
	var/obj/item/vagina = null
	var/obj/item/anus = null
	var/obj/item/nipples = null
	var/obj/item/penis = null


/*
*	This code needed to determine if the human is naked in that part of body or not
*	You can use this for your own stuff if you want, haha.
*/

/// Are we wearing something that covers our chest?
/mob/living/carbon/human/proc/is_topless()
	if((wear_suit && wear_suit.body_parts_covered & CHEST) || (w_uniform && w_uniform.body_parts_covered & CHEST))
		return FALSE

	if(istype(wear_suit, /obj/item/clothing/suit/toggle/labcoat/nova/surgical_gown))
		return FALSE

	if(undershirt != "Nude" && !(underwear_visibility & UNDERWEAR_HIDE_SHIRT))
		return FALSE

	if(underwear != "Nude" && !(underwear_visibility & UNDERWEAR_HIDE_UNDIES))
		var/datum/sprite_accessory/underwear/worn_underwear = SSaccessories.underwear_list[underwear]
		if(worn_underwear?.hides_breasts)
			return FALSE

	if(bra != "Nude" && !(underwear_visibility & UNDERWEAR_HIDE_BRA))
		return FALSE

	return TRUE

/// Are we wearing something that covers our groin?
/mob/living/carbon/human/proc/is_bottomless()
	if((wear_suit && wear_suit.body_parts_covered & GROIN) || (w_uniform && w_uniform.body_parts_covered & GROIN))
		return FALSE

	if(istype(wear_suit, /obj/item/clothing/suit/toggle/labcoat/nova/surgical_gown))
		return FALSE

	if(undershirt != "Nude" && !(underwear_visibility & UNDERWEAR_HIDE_SHIRT))
		var/datum/sprite_accessory/undershirt/worn_undershirt = SSaccessories.undershirt_list[undershirt]
		if(worn_undershirt?.hides_groin)
			return FALSE

	if(underwear != "Nude" && !(underwear_visibility & UNDERWEAR_HIDE_UNDIES))
		return FALSE

	return TRUE

/// Are we wearing something that covers our shoes?
/mob/living/carbon/human/proc/is_barefoot()
	return !(shoes?.body_parts_covered & FEET)

/mob/living/carbon/human/proc/is_hands_uncovered()
	return (gloves?.body_parts_covered & ARMS)

/mob/living/carbon/human/proc/is_head_uncovered()
	return (head?.body_parts_covered & HEAD)

/// Returns true if the human has an accessible penis for the parameter. Accepts any of the `REQUIRE_GENITAL_` defines.
/mob/living/carbon/human/proc/has_penis(required_state = REQUIRE_GENITAL_ANY)
	var/obj/item/organ/genital/genital = get_organ_slot(ORGAN_SLOT_PENIS)
	if(!genital)
		return FALSE

	switch(required_state)
		if(REQUIRE_GENITAL_ANY)
			return TRUE
		if(REQUIRE_GENITAL_EXPOSED)
			return genital.is_exposed()
		if(REQUIRE_GENITAL_UNEXPOSED)
			return !genital.is_exposed()
		else
			return TRUE

/// Returns true if the human has a accessible balls for the parameter. Accepts any of the `REQUIRE_GENITAL_` defines.
/mob/living/carbon/human/proc/has_balls(required_state = REQUIRE_GENITAL_ANY)
	var/obj/item/organ/genital/genital = get_organ_slot(ORGAN_SLOT_TESTICLES)
	if(!genital)
		return FALSE

	switch(required_state)
		if(REQUIRE_GENITAL_ANY)
			return TRUE
		if(REQUIRE_GENITAL_EXPOSED)
			return genital.is_exposed()
		if(REQUIRE_GENITAL_UNEXPOSED)
			return !genital.is_exposed()
		else
			return TRUE

/// Returns true if the human has an accessible vagina for the parameter. Accepts any of the `REQUIRE_GENITAL_` defines.
/mob/living/carbon/human/proc/has_vagina(required_state = REQUIRE_GENITAL_ANY)
	var/obj/item/organ/genital/genital = get_organ_slot(ORGAN_SLOT_VAGINA)
	if(!genital)
		return FALSE

	switch(required_state)
		if(REQUIRE_GENITAL_ANY)
			return TRUE
		if(REQUIRE_GENITAL_EXPOSED)
			return genital.is_exposed()
		if(REQUIRE_GENITAL_UNEXPOSED)
			return !genital.is_exposed()
		else
			return TRUE

/// Returns true if the human has a accessible breasts for the parameter. Accepts any of the `REQUIRE_GENITAL_` defines.
/mob/living/carbon/human/proc/has_breasts(required_state = REQUIRE_GENITAL_ANY)
	var/obj/item/organ/genital/genital = get_organ_slot(ORGAN_SLOT_BREASTS)
	if(!genital)
		return FALSE

	switch(required_state)
		if(REQUIRE_GENITAL_ANY)
			return TRUE
		if(REQUIRE_GENITAL_EXPOSED)
			return genital.visibility_preference == GENITAL_ALWAYS_SHOW || is_topless()
		if(REQUIRE_GENITAL_UNEXPOSED)
			return genital.visibility_preference != GENITAL_ALWAYS_SHOW && !is_topless()
		else
			return TRUE

/// Returns true if the human has breasts and lactation is enabled. Accepts any of the `REQUIRE_GENITAL_` defines.
/mob/living/carbon/human/proc/has_lactating_breasts(required_state = REQUIRE_GENITAL_ANY)
	var/obj/item/organ/genital/breasts/genital = get_organ_slot(ORGAN_SLOT_BREASTS)
	if(!genital || !genital.lactates)
		return FALSE

	switch(required_state)
		if(REQUIRE_GENITAL_ANY)
			return TRUE
		if(REQUIRE_GENITAL_EXPOSED)
			return genital.visibility_preference == GENITAL_ALWAYS_SHOW || is_topless()
		if(REQUIRE_GENITAL_UNEXPOSED)
			return genital.visibility_preference != GENITAL_ALWAYS_SHOW && !is_topless()
		else
			return TRUE

/// Returns true if the human has an accessible anus for the parameter. Accepts any of the `REQUIRE_GENITAL_` defines.
/mob/living/carbon/human/proc/has_anus(required_state = REQUIRE_GENITAL_ANY)
	if(issilicon(src))
		return TRUE
	var/obj/item/organ/genital/genital = get_organ_slot(ORGAN_SLOT_ANUS)
	if(!genital)
		return FALSE

	switch(required_state)
		if(REQUIRE_GENITAL_ANY)
			return TRUE
		if(REQUIRE_GENITAL_EXPOSED)
			return genital.is_exposed()
		if(REQUIRE_GENITAL_UNEXPOSED)
			return !genital.is_exposed()
		else
			return TRUE

/// Returns true if the human has a accessible feet for the parameter, returning the number of feet the human has if they do. Accepts any of the `REQUIRE_GENITAL_` defines.
/mob/living/carbon/human/proc/has_arms(required_state = REQUIRE_GENITAL_ANY)
	var/hand_count = 0
	var/covered = 0
	var/is_covered = FALSE
	for(var/obj/item/bodypart/arm/left/left_arm in bodyparts)
		hand_count++
	for(var/obj/item/bodypart/arm/right/right_arm in bodyparts)
		hand_count++
	if(get_item_by_slot(ITEM_SLOT_HANDS))
		var/obj/item/clothing/gloves/worn_gloves = get_item_by_slot(ITEM_SLOT_HANDS)
		covered = worn_gloves.body_parts_covered
	if(covered & HANDS)
		is_covered = TRUE
	switch(required_state)
		if(REQUIRE_GENITAL_ANY)
			return hand_count
		if(REQUIRE_GENITAL_EXPOSED)
			if(is_covered)
				return FALSE
			else
				return hand_count
		if(REQUIRE_GENITAL_UNEXPOSED)
			if(!is_covered)
				return FALSE
			else
				return hand_count
		else
			return hand_count

/// Returns true if the human has a accessible feet for the parameter, returning the number of feet the human has if they do. Accepts any of the `REQUIRE_GENITAL_` defines.
/mob/living/carbon/human/proc/has_feet(required_state = REQUIRE_GENITAL_ANY)
	var/feet_count = 0

	for(var/obj/item/bodypart/leg/left/left_leg in bodyparts)
		feet_count++
	for(var/obj/item/bodypart/leg/right/right_leg in bodyparts)
		feet_count++

	switch(required_state)
		if(REQUIRE_GENITAL_ANY)
			return feet_count
		if(REQUIRE_GENITAL_EXPOSED)
			if(!is_barefoot())
				return FALSE
			else
				return feet_count
		if(REQUIRE_GENITAL_UNEXPOSED)
			if(is_barefoot())
				return FALSE
			else
				return feet_count
		else
			return feet_count

/// Gets the number of feet the human has.
/mob/living/carbon/human/proc/get_num_feet()
	return has_feet(REQUIRE_GENITAL_ANY)

/// Returns true if the human has exposed paw-like feet or digitigrade legs that fit paw/pad interactions.
/mob/living/carbon/human/proc/has_paw_feet(required_state = REQUIRE_GENITAL_ANY)
	if(!has_feet(REQUIRE_GENITAL_ANY))
		return FALSE

	var/has_paws = FALSE
	for(var/obj/item/bodypart/leg/leg as anything in bodyparts)
		if((leg.bodyshape & BODYSHAPE_DIGITIGRADE) || leg.footprint_sprite == FOOTPRINT_SPRITE_PAWS)
			has_paws = TRUE
			break

	if(!has_paws)
		return FALSE

	switch(required_state)
		if(REQUIRE_GENITAL_EXPOSED)
			return has_feet(REQUIRE_GENITAL_EXPOSED)
		if(REQUIRE_GENITAL_UNEXPOSED)
			return has_feet(REQUIRE_GENITAL_UNEXPOSED)
		else
			return TRUE

/// Returns true if the human has a accessible ears for the parameter. Accepts any of the `REQUIRE_GENITAL_` defines.
/mob/living/carbon/human/proc/has_ears(required_state = REQUIRE_GENITAL_ANY)
	var/obj/item/organ/genital = get_organ_slot(ORGAN_SLOT_EARS)
	if(!genital)
		return FALSE

	switch(required_state)
		if(REQUIRE_GENITAL_ANY)
			return TRUE
		if(REQUIRE_GENITAL_EXPOSED)
			return !get_item_by_slot(ITEM_SLOT_EARS) && !get_item_by_slot(ITEM_SLOT_EARS_RIGHT)
		if(REQUIRE_GENITAL_UNEXPOSED)
			return get_item_by_slot(ITEM_SLOT_EARS) || get_item_by_slot(ITEM_SLOT_EARS_RIGHT)
		else
			return TRUE

/// Returns true if the human has accessible eyes for the parameter. Accepts any of the `REQUIRE_GENITAL_` defines.
/mob/living/carbon/human/proc/has_eyes(required_state = REQUIRE_GENITAL_ANY)
	var/obj/item/organ/genital = get_organ_slot(ORGAN_SLOT_EYES)
	if(!genital)
		return FALSE

	switch(required_state)
		if(REQUIRE_GENITAL_ANY)
			return TRUE
		if(REQUIRE_GENITAL_EXPOSED)
			return !get_item_by_slot(ITEM_SLOT_EYES)
		if(REQUIRE_GENITAL_UNEXPOSED)
			return get_item_by_slot(ITEM_SLOT_EYES)
		else
			return TRUE

/// Returns true if the human has accessible tail for the parameter. Accepts any of the `REQUIRE_GENITAL_` defines.
/mob/living/carbon/human/proc/has_tail(required_state = REQUIRE_GENITAL_ANY)
	var/obj/item/organ/genital = get_organ_slot(ORGAN_SLOT_TAIL)
	if(!genital)
		return FALSE

	switch(required_state)
		if(REQUIRE_GENITAL_ANY)
			return TRUE
		if(REQUIRE_GENITAL_EXPOSED)
			return !get_item_by_slot(ORGAN_SLOT_TAIL)
		if(REQUIRE_GENITAL_UNEXPOSED)
			return get_item_by_slot(ORGAN_SLOT_TAIL)
		else
			return TRUE

/// Returns TRUE if a visual mutant part is hidden by clothing, explicit hide toggles, or global external organ hiding.
/mob/living/carbon/human/proc/is_external_part_hidden(hide_flags = NONE, hide_feature_keys = null)
	if(HAS_TRAIT(src, TRAIT_HIDE_EXTERNAL_ORGANS))
		return TRUE

	if(hide_flags && (obscured_slots & hide_flags))
		return TRUE

	if(isnull(hide_feature_keys) || !LAZYLEN(try_hide_mutant_parts))
		return FALSE

	if(islist(hide_feature_keys))
		for(var/feature_key in hide_feature_keys)
			if(feature_key in try_hide_mutant_parts)
				return TRUE
		return FALSE

	return hide_feature_keys in try_hide_mutant_parts

/// Returns the state for a visual external organ that is either visible or hidden.
/mob/living/carbon/human/proc/get_external_part_state(organ_slot, hide_flags = NONE, hide_feature_keys = null)
	var/obj/item/organ/organ = get_organ_slot(organ_slot)
	if(!organ)
		return null

	return is_external_part_hidden(hide_flags, hide_feature_keys) ? "closed" : "open"

/// Returns the exposure state for a supported lewd body part key or slot.
/mob/living/carbon/human/proc/get_lewd_part_state(part_key)
	switch(part_key)
		if("chest")
			return is_topless() ? "open" : "closed"
		if("groin")
			return is_bottomless() ? "open" : "closed"
		if("neck")
			if(!get_bodypart(BODY_ZONE_HEAD))
				return null
			return (wear_neck || (obscured_slots & HIDENECK)) ? "closed" : "open"
		if("armpit", "armpits")
			if(!has_arms(REQUIRE_GENITAL_ANY))
				return null
			return is_topless() ? "open" : "closed"
		if("thigh", "thighs", "legs")
			if(!has_feet(REQUIRE_GENITAL_ANY))
				return null
			return is_bottomless() ? "open" : "closed"
		if("hands")
			if(!has_arms(REQUIRE_GENITAL_ANY))
				return null
			return has_arms(REQUIRE_GENITAL_EXPOSED) ? "open" : "closed"
		if("feet")
			if(!has_feet(REQUIRE_GENITAL_ANY))
				return null
			return has_feet(REQUIRE_GENITAL_EXPOSED) ? "open" : "closed"
		if("pawpads", "paw_pads", "pads", "paws")
			if(!has_paw_feet(REQUIRE_GENITAL_ANY))
				return null
			return has_paw_feet(REQUIRE_GENITAL_EXPOSED) ? "open" : "closed"
		if("mouth", ORGAN_SLOT_TONGUE)
			var/obj/item/organ/tongue/tongue = get_organ_slot(ORGAN_SLOT_TONGUE)
			if(!tongue || !get_bodypart(BODY_ZONE_HEAD))
				return null
			return is_mouth_covered() ? "closed" : "open"
		if("tentacle", "tentacles")
			var/obj/item/organ/genital/penis/tentacle_penis = get_organ_slot(ORGAN_SLOT_PENIS)
			if(tentacle_penis?.genital_type == "tentacle")
				return tentacle_penis.is_exposed() ? "open" : "closed"
			var/obj/item/organ/genital/vagina/tentacle_vagina = get_organ_slot(ORGAN_SLOT_VAGINA)
			if(tentacle_vagina?.genital_type == "tentacle")
				return tentacle_vagina.is_exposed() ? "open" : "closed"
			return null
		if("ears", ORGAN_SLOT_EARS)
			if(!has_ears(REQUIRE_GENITAL_ANY))
				return null
			return has_ears(REQUIRE_GENITAL_EXPOSED) ? "open" : "closed"
		if("eyes", ORGAN_SLOT_EYES)
			if(!has_eyes(REQUIRE_GENITAL_ANY))
				return null
			return has_eyes(REQUIRE_GENITAL_EXPOSED) ? "open" : "closed"
		if("cap", "mushroom_cap", ORGAN_SLOT_EXTERNAL_CAP)
			return get_external_part_state(ORGAN_SLOT_EXTERNAL_CAP, HIDEHAIR, FEATURE_MUSH_CAP)
		if("snout", ORGAN_SLOT_EXTERNAL_SNOUT)
			return get_external_part_state(ORGAN_SLOT_EXTERNAL_SNOUT, HIDESNOUT, FEATURE_SNOUT)
		if("horn", "horns", ORGAN_SLOT_EXTERNAL_HORNS)
			return get_external_part_state(ORGAN_SLOT_EXTERNAL_HORNS, HIDEHAIR, FEATURE_HORNS)
		if("frill", "frills", ORGAN_SLOT_EXTERNAL_FRILLS)
			return get_external_part_state(ORGAN_SLOT_EXTERNAL_FRILLS, HIDEEARS, FEATURE_FRILLS)
		if("fluff", ORGAN_SLOT_EXTERNAL_FLUFF)
			return get_external_part_state(ORGAN_SLOT_EXTERNAL_FLUFF, HIDEHAIR, FEATURE_FLUFF)
		if("moth_antenna", "moth_antennae", "moth antenna", "moth antennae", ORGAN_SLOT_EXTERNAL_ANTENNAE)
			return get_external_part_state(ORGAN_SLOT_EXTERNAL_ANTENNAE, HIDEHAIR | HIDEANTENNAE, FEATURE_MOTH_ANTENNAE)
		if("neck_accessory", "neck accessory", ORGAN_SLOT_EXTERNAL_NECK_ACCESSORY)
			return get_external_part_state(ORGAN_SLOT_EXTERNAL_NECK_ACCESSORY, HIDEHAIR | HIDENECK, FEATURE_NECK_ACCESSORY)
		if("skrell_hair", "skrell hair", ORGAN_SLOT_EXTERNAL_SKRELL_HAIR)
			return get_external_part_state(ORGAN_SLOT_EXTERNAL_SKRELL_HAIR, HIDEHAIR, FEATURE_SKRELL_HAIR)
		if("synth_antenna", "synth antenna", ORGAN_SLOT_EXTERNAL_SYNTH_ANTENNA)
			return get_external_part_state(ORGAN_SLOT_EXTERNAL_SYNTH_ANTENNA, HIDEHAIR | HIDEANTENNAE, FEATURE_SYNTH_ANTENNA)
		if("spine", "spines", ORGAN_SLOT_EXTERNAL_SPINES)
			return get_external_part_state(ORGAN_SLOT_EXTERNAL_SPINES, HIDEJUMPSUIT | HIDETAIL, FEATURE_SPINES)
		if("tail", ORGAN_SLOT_TAIL)
			var/obj/item/organ/tail/tail = get_organ_slot(ORGAN_SLOT_TAIL)
			if(!tail)
				return null
			return tail.is_exposed() ? "open" : "closed"
		if("wings", ORGAN_SLOT_EXTERNAL_WINGS)
			return get_external_part_state(ORGAN_SLOT_EXTERNAL_WINGS, HIDEJUMPSUIT, list(FEATURE_WINGS, FEATURE_WINGS_FUNCTIONAL, FEATURE_WINGS_OPEN))
		if("taur", ORGAN_SLOT_EXTERNAL_TAUR)
			var/obj/item/organ/taur_body/taur_body = get_organ_slot(ORGAN_SLOT_EXTERNAL_TAUR)
			if(!taur_body)
				return null
			if(taur_body.hide_self || is_external_part_hidden(HIDETAIL, FEATURE_TAUR))
				return "closed"
			return "open"
		if("xeno_head", "xeno head", "xenohead", ORGAN_SLOT_EXTERNAL_XENOHEAD)
			return get_external_part_state(ORGAN_SLOT_EXTERNAL_XENOHEAD, NONE, FEATURE_XENOHEAD)
		if("xenodorsal", ORGAN_SLOT_EXTERNAL_XENODORSAL)
			return get_external_part_state(ORGAN_SLOT_EXTERNAL_XENODORSAL, HIDEJUMPSUIT, FEATURE_XENODORSAL)
		if("breasts", ORGAN_SLOT_BREASTS)
			var/obj/item/organ/genital/breasts = get_organ_slot(ORGAN_SLOT_BREASTS)
			if(!breasts)
				return null
			return breasts.is_exposed() ? "open" : "closed"
		if("penis", ORGAN_SLOT_PENIS)
			var/obj/item/organ/genital/penis = get_organ_slot(ORGAN_SLOT_PENIS)
			if(!penis)
				return null
			return penis.is_exposed() ? "open" : "closed"
		if("knot", "knotted_penis")
			var/obj/item/organ/genital/penis/knotted_penis = get_organ_slot(ORGAN_SLOT_PENIS)
			if(!knotted_penis)
				return null
			if(!(knotted_penis.genital_type in list("knotted", "barbknot", "hemiknot")))
				return null
			return knotted_penis.is_exposed() ? "open" : "closed"
		if("balls", "testicles", ORGAN_SLOT_TESTICLES)
			var/obj/item/organ/genital/testicles/balls = get_organ_slot(ORGAN_SLOT_TESTICLES)
			if(!balls)
				return null
			return balls.is_exposed() ? "open" : "closed"
		if("vagina", ORGAN_SLOT_VAGINA)
			var/obj/item/organ/genital/vagina = get_organ_slot(ORGAN_SLOT_VAGINA)
			if(!vagina)
				return null
			return vagina.is_exposed() ? "open" : "closed"
		if("womb", ORGAN_SLOT_WOMB)
			var/obj/item/organ/genital/womb/womb = get_organ_slot(ORGAN_SLOT_WOMB)
			if(!womb)
				return null
			return womb.is_exposed() ? "open" : "closed"
		if("anus", "asshole", ORGAN_SLOT_ANUS)
			var/obj/item/organ/genital/anus = get_organ_slot(ORGAN_SLOT_ANUS)
			if(!anus)
				return null
			return anus.is_exposed() ? "open" : "closed"
		if("butt", ORGAN_SLOT_BUTT)
			var/obj/item/organ/genital/butt = get_organ_slot(ORGAN_SLOT_BUTT)
			if(!butt)
				return null
			return butt.is_exposed() ? "open" : "closed"
		if("belly", ORGAN_SLOT_BELLY)
			var/obj/item/organ/genital/belly = get_organ_slot(ORGAN_SLOT_BELLY)
			if(!belly)
				return null
			return belly.is_exposed() ? "open" : "closed"
		if("nipples", ORGAN_SLOT_NIPPLES)
			var/chest_state = get_lewd_part_state(ORGAN_SLOT_BREASTS)
			if(chest_state)
				return chest_state
			return is_topless() ? "open" : "closed"

	var/obj/item/organ/organ = get_organ_slot(part_key)
	if(!organ || !hascall(organ, "is_exposed"))
		return null

	return call(organ, "is_exposed")() ? "open" : "closed"

/*
*	This code needed for changing character's gender by chems
*/

/// Sets the gender of the human, respecting prefs unless it's forced. Do not force in non-admin operations.
/mob/living/carbon/human/proc/set_gender(ngender = NEUTER, silent = FALSE, update_icon = TRUE, forced = FALSE)
	var/bender = gender != ngender
	if((!client?.prefs?.read_preference(/datum/preference/toggle/erp/gender_change) && !forced) || !dna || !bender)
		return FALSE

	if(ngender == MALE || ngender == FEMALE)
		dna.features["body_model"] = ngender
		if(!silent)
			var/adj = ngender == MALE ? "masculine" : "feminine"
			visible_message(span_boldnotice("[src] suddenly looks more [adj]!"), span_boldwarning("You suddenly feel more [adj]!"))
	else if(ngender == NEUTER)
		dna.features["body_model"] = MALE
	gender = ngender
	if(update_icon)
		update_body()

/*
*	ICON UPDATING EXTENTION
*/

/// Updating vagina slot
/mob/living/carbon/human/proc/update_inv_vagina()
	// on_mob stuff
	remove_overlay(VAGINA_LAYER)

	var/obj/item/clothing/sextoy/sex_toy = vagina

	if(wear_suit && (wear_suit.flags_inv & HIDESEXTOY)) // You can add proper flags here if required
		return

	var/icon_file = vagina?.worn_icon
	var/mutable_appearance/vagina_overlay

	if(!vagina_overlay)
		vagina_overlay = sex_toy?.build_worn_icon(default_layer = VAGINA_LAYER, default_icon_file = 'icons/mob/clothing/under/default.dmi', isinhands = FALSE, override_file = icon_file)

	var/obj/item/bodypart/chest/chest_part = get_bodypart(BODY_ZONE_CHEST)
	chest_part?.worn_uniform_offset?.apply_offset(vagina_overlay) // every day we stray further and further from god
	overlays_standing[VAGINA_LAYER] = vagina_overlay

	apply_overlay(VAGINA_LAYER)
	update_body_parts()

/// Updating anus slot
/mob/living/carbon/human/proc/update_inv_anus()
	// on_mob stuff
	remove_overlay(ANUS_LAYER)

	var/obj/item/clothing/sextoy/sex_toy = anus

	if(wear_suit && (wear_suit.flags_inv & HIDESEXTOY)) // You can add proper flags here if required
		return

	var/icon_file = anus?.worn_icon
	var/mutable_appearance/anus_overlay

	if(!anus_overlay)
		anus_overlay = sex_toy?.build_worn_icon(default_layer = ANUS_LAYER, default_icon_file = 'icons/mob/clothing/under/default.dmi', isinhands = FALSE, override_file = icon_file)

	var/obj/item/bodypart/chest/chest_part = get_bodypart(BODY_ZONE_CHEST)

	chest_part?.worn_uniform_offset?.apply_offset(anus_overlay) // and i keep on asking myself... why? why do we do this?
	overlays_standing[ANUS_LAYER] = anus_overlay

	apply_overlay(ANUS_LAYER)
	update_body_parts()

/// Updating nipples slot
/mob/living/carbon/human/proc/update_inv_nipples()
	// on_mob stuff
	remove_overlay(NIPPLES_LAYER)

	var/obj/item/clothing/sextoy/sex_toy = nipples

	if(wear_suit && (wear_suit.flags_inv & HIDESEXTOY)) // You can add proper flags here if required
		return

	var/icon_file = nipples?.worn_icon
	var/mutable_appearance/nipples_overlay

	if(!nipples_overlay)
		nipples_overlay = sex_toy?.build_worn_icon(default_layer = NIPPLES_LAYER, default_icon_file = 'icons/mob/clothing/under/default.dmi', isinhands = FALSE, override_file = icon_file)

	var/obj/item/bodypart/chest/chest_part = get_bodypart(BODY_ZONE_CHEST)
	chest_part?.worn_uniform_offset?.apply_offset(nipples_overlay) // then i realised something, something horrific

	overlays_standing[NIPPLES_LAYER] = nipples_overlay

	apply_overlay(NIPPLES_LAYER)
	update_body_parts()

/// Updating penis slot
/mob/living/carbon/human/proc/update_inv_penis()
	// on_mob stuff
	remove_overlay(PENIS_LAYER)

	var/obj/item/clothing/sextoy/sex_toy = penis

	if(wear_suit && (wear_suit.flags_inv & HIDESEXTOY)) // You can add proper flags here if required
		return

	var/icon_file = penis?.worn_icon
	var/mutable_appearance/penis_overlay

	if(!penis_overlay)
		penis_overlay = sex_toy?.build_worn_icon(default_layer = PENIS_LAYER, default_icon_file = 'icons/mob/clothing/under/default.dmi', isinhands = FALSE, override_file = icon_file)

	var/obj/item/bodypart/chest/chest_part = get_bodypart(BODY_ZONE_CHEST)
	chest_part?.worn_uniform_offset?.apply_offset(penis_overlay) // we can never escape, we are forever governed by sex(two)

	overlays_standing[PENIS_LAYER] = penis_overlay

	apply_overlay(PENIS_LAYER)
	update_body_parts()

/// Helper proc for calling all the lewd slot update_inv_ procs.
/mob/living/carbon/human/proc/update_inv_lewd()
	update_inv_vagina()
	update_inv_anus()
	update_inv_nipples()
	update_inv_penis()

/*
*	MISC LOGIC
*/

// Handles breaking out of gloves that restrain people.
/mob/living/carbon/human/resist_restraints()
	if(gloves?.breakouttime)
		changeNext_move(gloves.resist_cooldown)
		last_special = world.time + gloves.resist_cooldown
		cuff_resist(gloves)
	else
		return ..()

/// Checks if the human is wearing a condom, and also hasn't broken it.
/mob/living/carbon/human/proc/is_wearing_condom()
	if(!penis || !istype(penis, /obj/item/clothing/sextoy/condom))
		return FALSE

	var/obj/item/clothing/sextoy/condom/condom = penis
	return condom.condom_state != "broken"

// For handling things that don't already have handcuff handlers.
/mob/living/carbon/human/set_handcuffed(new_value)
	if(wear_suit && istype(wear_suit, /obj/item/clothing/suit/straight_jacket/kinky_sleepbag))
		return FALSE
	return ..()

/// Checks if the tail is exposed.
/obj/item/organ/tail/proc/is_exposed()
	return TRUE // your tail is always exposed, dummy! why are you checking this
