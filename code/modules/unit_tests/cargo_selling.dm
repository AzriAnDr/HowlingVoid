/// Makes sure exports work and things can be sold
/datum/unit_test/cargo_selling

/obj/item/cargo_unit_test_container

/obj/item/cargo_unit_test_container/Initialize(mapload)
	. = ..()
	new /obj/item/cargo_unit_test_content(src)

/obj/item/cargo_unit_test_content

/datum/export/cargo_unit_test_container
	cost = PAYCHECK_LOWER
	export_types = list(/obj/item/cargo_unit_test_container)

/datum/export/cargo_unit_test_content
	cost = PAYCHECK_COMMAND
	export_types = list(/obj/item/cargo_unit_test_content)

/datum/unit_test/cargo_selling/Run()
	for(var/datum/export/subtype as anything in valid_subtypesof(/datum/export))
		if(subtype::k_recovery_time < SSprocessing.wait)
			TEST_FAIL("[subtype] should have k_recovery time >= [SSprocessing.wait]")
		var/datum/export/sell = new subtype
		if(!length(sell.export_types))
			TEST_FAIL("[subtype] has no export types")
		qdel(sell)

	var/obj/item/cargo_unit_test_container/box = allocate(/obj/item/cargo_unit_test_container)
	var/obj/item/cargo_unit_test_container/box_skip_content = allocate(/obj/item/cargo_unit_test_container)

	var/datum/export_report/report_one = export_item_and_contents(box, apply_elastic = FALSE)
	if(isnull(report_one))
		TEST_FAIL("called 'export_item_and_contents', but no export report was returned.")
	var/value = counterlist_sum(report_one.total_value)
	TEST_ASSERT_EQUAL(value, PAYCHECK_LOWER + PAYCHECK_COMMAND, "'export_item_and_contents' value didn't match expected value")

	var/datum/export_report/report_two = export_single_item(box_skip_content, apply_elastic = FALSE)
	if(isnull(report_two))
		TEST_FAIL("called 'export_single_item', but no export report was returned.")
	value = counterlist_sum(report_two.total_value)
	TEST_ASSERT_EQUAL(value, PAYCHECK_LOWER, "'export_single_item' value didn't match expected value")

	var/obj/item/documents/syndicate/red/secret_documents = allocate(/obj/item/documents/syndicate/red)
	var/datum/export_report/secret_documents_report = export_single_item(secret_documents, apply_elastic = FALSE)
	value = counterlist_sum(secret_documents_report.total_value)
	TEST_ASSERT_EQUAL(value, CARGO_CRATE_VALUE * 10, "Secret documents should sell for 2000 credits.")

	var/obj/item/documents/photocopy/copied_documents = allocate(/obj/item/documents/photocopy)
	var/datum/export_report/copied_documents_report = export_single_item(copied_documents, apply_elastic = FALSE)
	value = counterlist_sum(copied_documents_report.total_value)
	TEST_ASSERT_EQUAL(value, 0, "Photocopied secret documents should not be exportable.")

	var/obj/item/disk/design_disk/bepis/remove_tech/reformatted_disk = allocate(/obj/item/disk/design_disk/bepis/remove_tech)
	var/datum/export_report/reformatted_disk_report = export_single_item(reformatted_disk, apply_elastic = FALSE)
	value = counterlist_sum(reformatted_disk_report.total_value)
	TEST_ASSERT_EQUAL(value, CARGO_CRATE_VALUE * 5, "Unused reformatted technology disks should sell for 1000 credits.")

	var/mob/living/carbon/human/consistent/scientist = allocate(/mob/living/carbon/human/consistent)
	var/obj/machinery/computer/rdconsole/rd_console = allocate(/obj/machinery/computer/rdconsole)
	var/obj/item/disk/design_disk/bepis/remove_tech/spent_reformatted_disk = allocate(/obj/item/disk/design_disk/bepis/remove_tech)
	scientist.put_in_hands(spent_reformatted_disk)
	rd_console.item_interaction(scientist, spent_reformatted_disk, list())
	TEST_ASSERT(spent_reformatted_disk.rnd_console_inserted, "Reformatted technology disks should be marked after insertion into an R&D console.")

	var/datum/export_report/spent_reformatted_disk_report = export_single_item(spent_reformatted_disk, apply_elastic = FALSE)
	value = counterlist_sum(spent_reformatted_disk_report.total_value)
	TEST_ASSERT_EQUAL(value, 0, "Reformatted technology disks inserted into an R&D console should sell for 0 credits.")
