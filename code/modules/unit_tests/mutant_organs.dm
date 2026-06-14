/**
 * Iterates over all species to ensure that organs are valid after being set to a mutant species.
 */
/datum/unit_test/mutant_organs

/datum/unit_test/mutant_organs/Run()
	var/list/ignore = list(
		/datum/species/dullahan,
	)
	var/list/species = subtypesof(/datum/species) - ignore
	var/static/list/organs_we_care_about = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_TONGUE,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_APPENDIX,
	)

	for(var/datum/species/species_type as anything in species)
		// get our dummy
		var/mob/living/carbon/human/consistent/dummy = allocate(/mob/living/carbon/human/consistent)

		// change them to the species
		dummy.set_species(species_type)

		// check all their organs
		for(var/organ_slot in organs_we_care_about)
			var/expected_type = dummy.dna.species.get_mutant_organ_type_for_slot(organ_slot)
			var/obj/item/organ/actual_organ = dummy.get_organ_slot(organ_slot)
			if(isnull(actual_organ))
				if(!isnull(expected_type))
					TEST_FAIL("[species_type] did not update their [organ_slot] organ to [expected_type], no organ was found")
					continue
			else
				if(isnull(expected_type))
					TEST_FAIL("[species_type] did not remove their [organ_slot] organ")
					continue

				if(actual_organ.type != expected_type)
					TEST_FAIL("[species_type] did not update their [organ_slot] organ to [expected_type], instead it was [actual_organ.type]")
					continue

/datum/unit_test/lizard_custom_mutant_organs_apply

/datum/unit_test/lizard_custom_mutant_organs_apply/Run()
	var/mob/living/carbon/human/consistent/lizard = allocate(/mob/living/carbon/human/consistent)
	var/list/tail_colors = list("#05f610", "#16486b", "#cadc83")
	var/list/snout_colors = list("#30bc52", "#267fb6", "#c7ffb4")

	lizard.dna.mutant_bodyparts[FEATURE_TAIL] = build_mutant_part("Light Tiger", tail_colors)
	lizard.dna.mutant_bodyparts[FEATURE_SNOUT] = build_mutant_part("Mammal, Long", snout_colors)
	lizard.dna.features[FEATURE_TAIL] = SPRITE_ACCESSORY_NONE
	lizard.dna.features[FEATURE_SNOUT] = SPRITE_ACCESSORY_NONE
	lizard.set_species(/datum/species/lizard, icon_update = FALSE)

	var/obj/item/organ/tail/lizard/tail = lizard.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(isnull(tail))
		TEST_FAIL("Lizard did not receive a tail organ.")
		return
	var/list/applied_tail_colors = tail.bodypart_overlay?.draw_color
	TEST_ASSERT_EQUAL(tail.bodypart_overlay?.sprite_datum?.name, "Light Tiger", "Lizard tail did not use the selected sprite accessory.")
	TEST_ASSERT_EQUAL(applied_tail_colors?[1], tail_colors[1], "Lizard tail did not use the selected primary color.")

	var/obj/item/organ/snout/snout = lizard.get_organ_slot(ORGAN_SLOT_EXTERNAL_SNOUT)
	if(isnull(snout))
		TEST_FAIL("Lizard did not receive a snout organ.")
		return
	var/list/applied_snout_colors = snout.bodypart_overlay?.draw_color
	TEST_ASSERT_EQUAL(snout.bodypart_overlay?.sprite_datum?.name, "Mammal, Long", "Lizard snout did not use the selected sprite accessory.")
	TEST_ASSERT_EQUAL(applied_snout_colors?[1], snout_colors[1], "Lizard snout did not use the selected primary color.")

/datum/unit_test/lizard_preview_custom_mutant_organs_apply

/datum/unit_test/lizard_preview_custom_mutant_organs_apply/Run()
	var/mob/living/carbon/human/dummy/consistent/lizard = allocate(/mob/living/carbon/human/dummy/consistent)
	var/list/tail_colors = list("#de97c7", "#037eca", "#cfc4bf")
	var/list/snout_colors = list("#8ab0ef", "#f9d421", "#2bb3a1")

	lizard.dna.mutant_bodyparts[FEATURE_TAIL] = build_mutant_part("Short (Two-Tone)", tail_colors)
	lizard.dna.mutant_bodyparts[FEATURE_SNOUT] = build_mutant_part("Vulpkanin Two", snout_colors)
	lizard.dna.features[FEATURE_TAIL] = SPRITE_ACCESSORY_NONE
	lizard.dna.features[FEATURE_SNOUT] = SPRITE_ACCESSORY_NONE
	lizard.set_species(/datum/species/lizard, icon_update = TRUE)
	lizard.dna.species.regenerate_organs(lizard, lizard.dna.species, replace_current = TRUE, visual_only = TRUE)
	TEST_ASSERT_NOTNULL(lizard.dna.mutant_bodyparts[FEATURE_TAIL], "Preview lizard lost tail DNA while replacing its tail organ.")
	TEST_ASSERT_NOTNULL(lizard.dna.mutant_bodyparts[FEATURE_SNOUT], "Preview lizard lost snout DNA while replacing its snout organ.")

	var/obj/item/organ/tail/lizard/tail = lizard.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(isnull(tail))
		TEST_FAIL("Preview lizard did not receive a tail organ.")
		return
	var/list/applied_tail_colors = tail.bodypart_overlay?.draw_color
	TEST_ASSERT_EQUAL(tail.bodypart_overlay?.sprite_datum?.name, "Short (Two-Tone)", "Preview lizard tail did not use the selected sprite accessory.")
	TEST_ASSERT_EQUAL(applied_tail_colors?[1], tail_colors[1], "Preview lizard tail did not use the selected primary color.")

	var/obj/item/organ/snout/snout = lizard.get_organ_slot(ORGAN_SLOT_EXTERNAL_SNOUT)
	if(isnull(snout))
		TEST_FAIL("Preview lizard did not receive a snout organ.")
		return
	var/list/applied_snout_colors = snout.bodypart_overlay?.draw_color
	TEST_ASSERT_EQUAL(snout.bodypart_overlay?.sprite_datum?.name, "Vulpkanin Two", "Preview lizard snout did not use the selected sprite accessory.")
	TEST_ASSERT_EQUAL(applied_snout_colors?[1], snout_colors[1], "Preview lizard snout did not use the selected primary color.")

/datum/unit_test/lizard_preview_harvest_keeps_pending_mutant_organs

/datum/unit_test/lizard_preview_harvest_keeps_pending_mutant_organs/Run()
	var/mob/living/carbon/human/dummy/consistent/lizard = allocate(/mob/living/carbon/human/dummy/consistent)
	var/list/old_tail_colors = list("#de97c7", "#037eca", "#cfc4bf")
	var/list/old_snout_colors = list("#8ab0ef", "#f9d421", "#2bb3a1")

	lizard.dna.mutant_bodyparts[FEATURE_TAIL] = build_mutant_part("Short (Two-Tone)", old_tail_colors)
	lizard.dna.mutant_bodyparts[FEATURE_SNOUT] = build_mutant_part("Vulpkanin Two", old_snout_colors)
	lizard.set_species(/datum/species/lizard, icon_update = TRUE)
	lizard.dna.species.regenerate_organs(lizard, lizard.dna.species, replace_current = TRUE, visual_only = TRUE)

	TEST_ASSERT_NOTNULL(lizard.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL), "Preview setup did not create the old tail organ.")
	TEST_ASSERT_NOTNULL(lizard.get_organ_slot(ORGAN_SLOT_EXTERNAL_SNOUT), "Preview setup did not create the old snout organ.")

	var/list/new_tail_colors = list("#05f610", "#16486b", "#cadc83")
	var/list/new_snout_colors = list("#30bc52", "#267fb6", "#c7ffb4")
	lizard.dna.mutant_bodyparts = list()
	lizard.dna.mutant_bodyparts[FEATURE_TAIL] = build_mutant_part("Light Tiger", new_tail_colors)
	lizard.dna.mutant_bodyparts[FEATURE_SNOUT] = build_mutant_part("Mammal, Long", new_snout_colors)
	lizard.set_species(/datum/species/lizard, icon_update = FALSE, pref_load = TRUE)
	lizard.dna.species.regenerate_organs(lizard, lizard.dna.species, replace_current = TRUE, visual_only = TRUE)

	var/obj/item/organ/tail/lizard/tail = lizard.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(isnull(tail))
		TEST_FAIL("Preview lizard lost the pending tail preference while harvesting the previous preview organ.")
		return
	TEST_ASSERT_EQUAL(tail.bodypart_overlay?.sprite_datum?.name, "Light Tiger", "Preview lizard tail did not survive dummy organ harvesting.")

	var/obj/item/organ/snout/snout = lizard.get_organ_slot(ORGAN_SLOT_EXTERNAL_SNOUT)
	if(isnull(snout))
		TEST_FAIL("Preview lizard lost the pending snout preference while harvesting the previous preview organ.")
		return
	TEST_ASSERT_EQUAL(snout.bodypart_overlay?.sprite_datum?.name, "Mammal, Long", "Preview lizard snout did not survive dummy organ harvesting.")

/datum/unit_test/lizard_preview_disabled_mutant_organs_stay_removed

/datum/unit_test/lizard_preview_disabled_mutant_organs_stay_removed/Run()
	var/mob/living/carbon/human/dummy/consistent/lizard = allocate(/mob/living/carbon/human/dummy/consistent)

	lizard.dna.mutant_bodyparts[FEATURE_TAIL] = build_mutant_part(SPRITE_ACCESSORY_NONE)
	lizard.dna.mutant_bodyparts[FEATURE_SNOUT] = build_mutant_part(SPRITE_ACCESSORY_NONE)
	lizard.dna.features[FEATURE_TAIL] = "Light Tiger"
	lizard.dna.features[FEATURE_SNOUT] = "Vulpkanin Two"
	lizard.set_species(/datum/species/lizard, icon_update = TRUE)
	lizard.dna.species.regenerate_organs(lizard, lizard.dna.species, replace_current = TRUE, visual_only = TRUE)

	TEST_ASSERT_NULL(lizard.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL), "Preview lizard kept a tail organ with the tail preference disabled.")
	TEST_ASSERT_NULL(lizard.get_organ_slot(ORGAN_SLOT_EXTERNAL_SNOUT), "Preview lizard kept a snout organ with the snout preference disabled.")

/datum/unit_test/admin_rejuvenate_keeps_removed_external_organs_removed

/datum/unit_test/admin_rejuvenate_keeps_removed_external_organs_removed/Run()
	var/mob/living/carbon/human/consistent/lizard = allocate(/mob/living/carbon/human/consistent)

	lizard.dna.mutant_bodyparts[FEATURE_TAIL] = build_mutant_part("Light Tiger")
	lizard.dna.mutant_bodyparts[FEATURE_SNOUT] = build_mutant_part("Mammal, Long")
	lizard.set_species(/datum/species/lizard, icon_update = FALSE)

	var/obj/item/organ/tail = lizard.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	var/obj/item/organ/snout = lizard.get_organ_slot(ORGAN_SLOT_EXTERNAL_SNOUT)
	var/obj/item/organ/eyes = lizard.get_organ_slot(ORGAN_SLOT_EYES)
	if(isnull(tail))
		TEST_FAIL("Test setup failed to create a lizard tail.")
		return
	if(isnull(snout))
		TEST_FAIL("Test setup failed to create a lizard snout.")
		return
	if(isnull(eyes))
		TEST_FAIL("Test setup failed to create lizard eyes.")
		return

	tail.Remove(lizard, special = TRUE, movement_flags = KEEP_IN_MUTANT_BODYPARTS)
	qdel(tail)
	snout.Remove(lizard, special = TRUE, movement_flags = KEEP_IN_MUTANT_BODYPARTS)
	qdel(snout)
	eyes.Remove(lizard, special = TRUE)
	qdel(eyes)

	lizard.admin_rejuvenate()

	TEST_ASSERT_NULL(lizard.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL), "Admin rejuvenate regrew a removed external tail.")
	TEST_ASSERT_NULL(lizard.get_organ_slot(ORGAN_SLOT_EXTERNAL_SNOUT), "Admin rejuvenate regrew a removed external snout.")
	TEST_ASSERT_NOTNULL(lizard.get_organ_slot(ORGAN_SLOT_EYES), "Admin rejuvenate did not restore a missing internal organ.")

/datum/unit_test/ashwalker_disabled_spines_stay_removed

/datum/unit_test/ashwalker_disabled_spines_stay_removed/Run()
	var/mob/living/carbon/human/consistent/ashwalker = allocate(/mob/living/carbon/human/consistent)

	ashwalker.dna.mutant_bodyparts[FEATURE_SPINES] = build_mutant_part(SPRITE_ACCESSORY_NONE)
	ashwalker.dna.features[FEATURE_SPINES] = "Long + Membrane"
	ashwalker.set_species(/datum/species/lizard/ashwalker, icon_update = FALSE)
	ashwalker.dna.species.regenerate_organs(ashwalker, ashwalker.dna.species, replace_current = TRUE)

	TEST_ASSERT_NULL(ashwalker.get_organ_slot(ORGAN_SLOT_EXTERNAL_SPINES), "Ashwalker kept a spines organ with the spines preference disabled.")

/datum/unit_test/dummy_wipe_state_refreshes_obscured_slots

/datum/unit_test/dummy_wipe_state_refreshes_obscured_slots/Run()
	var/mob/living/carbon/human/dummy/consistent/dummy = allocate(/mob/living/carbon/human/dummy/consistent)
	var/obj/item/clothing/suit/space/space_suit = allocate(/obj/item/clothing/suit/space)

	dummy.equip_to_slot_or_del(space_suit, ITEM_SLOT_OCLOTHING)
	TEST_ASSERT(dummy.obscured_slots & HIDETAIL, "Dummy did not record tail coverage from the equipped space suit.")

	dummy.wipe_state()
	TEST_ASSERT_EQUAL(dummy.obscured_slots, NONE, "Dummy kept stale obscured slots after wiping equipment.")
