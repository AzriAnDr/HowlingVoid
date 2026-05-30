/datum/unit_test/underwear_rendered_under_clothes

/datum/unit_test/underwear_rendered_under_clothes/Run()
	var/mob/living/carbon/human/test_mob = allocate(/mob/living/carbon/human/consistent)

	test_mob.underwear = "Briefs"
	test_mob.undershirt = "Shirt"
	test_mob.bra = "Bra"
	test_mob.socks = "Normal (Greyscale)"

	TEST_ASSERT_NOTNULL(SSaccessories.underwear_list[test_mob.underwear], "Test underwear accessory is missing.")
	TEST_ASSERT_NOTNULL(SSaccessories.undershirt_list[test_mob.undershirt], "Test undershirt accessory is missing.")
	TEST_ASSERT_NOTNULL(SSaccessories.bra_list[test_mob.bra], "Test bra accessory is missing.")
	TEST_ASSERT_NOTNULL(SSaccessories.socks_list[test_mob.socks], "Test socks accessory is missing.")

	test_mob.update_underwear()
	TEST_ASSERT_EQUAL(length(test_mob.overlays_standing[BODY_LAYER]), 4, "Expected all underwear overlays before equipping clothes.")

	var/obj/item/clothing/under/color/grey/uniform = allocate(/obj/item/clothing/under/color/grey)
	test_mob.equip_to_slot_or_del(uniform, ITEM_SLOT_ICLOTHING)

	TEST_ASSERT(test_mob.underwear_hidden(), "Uniform-covered underwear should still be mechanically hidden.")
	TEST_ASSERT(test_mob.undershirt_hidden(), "Uniform-covered undershirts should still be mechanically hidden.")
	TEST_ASSERT(test_mob.bra_hidden(), "Uniform-covered bras should still be mechanically hidden.")
	TEST_ASSERT_EQUAL(length(test_mob.overlays_standing[BODY_LAYER]), 4, "Uniform coverage should not remove underwear render overlays.")

	uniform.flags_inv |= HIDEUNDERWEAR
	test_mob.update_underwear(FALSE)
	TEST_ASSERT_EQUAL(length(test_mob.overlays_standing[BODY_LAYER]), 0, "HIDEUNDERWEAR should explicitly remove underwear render overlays.")
