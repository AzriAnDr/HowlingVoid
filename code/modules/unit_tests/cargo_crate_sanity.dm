/**
 * This unit test loops through all cargo crates that are available to purchase, and confirms that they're below the expected sanity minimum when sold.
 * This prevents us from merging a crate that sells for more that it costs to buy.
 */

/datum/unit_test/cargo_crate_sanity

/datum/unit_test/cargo_crate_sanity/Run()

	for(var/crate in subtypesof(/datum/supply_pack))
		var/datum/supply_pack/new_crate = allocate(crate)
		if(new_crate.test_ignored)
			continue // We can safely ignore custom supply packs like the stock market or mining supply crates, or packs that have innate randomness.
		if(!new_crate?.crate_type)
			continue
		var/obj/crate_type = allocate(new_crate.crate_type)
		var/turf/open/floor/testing_floor = get_turf(crate_type)
		var/datum/export_report/minimum_cost = export_item_and_contents(crate_type, delete_unsold = TRUE, dry_run = TRUE)
		var/crate_value = counterlist_sum(minimum_cost.total_value)

		var/obj/results = new_crate.generate(testing_floor)
		if(!results)
			TEST_FAIL("Cargo crate [new_crate.type] failed to generate an object to export.")
		var/datum/export_report/export_log = export_item_and_contents(results, apply_elastic = TRUE, delete_unsold = TRUE, export_markets = list(EXPORT_MARKET_STATION))

		// The value of the crate and all of it's contents.
		var/value = counterlist_sum(export_log.total_value)

		// We're selling the crate and it's contents for more value than it's supply_pack costs.
		if(value > new_crate.get_cost())
			TEST_FAIL("Cargo crate [new_crate.type] had a sale value of [value], Selling for more than [new_crate.get_cost()], the cost to buy")

		// We're selling the crate & it's contents for less than the value of it's own crate, meaning you can buy and infinite number
		if(crate_value > new_crate.get_cost())
			TEST_FAIL("Cargo crate [new_crate.type] container sells for [crate_value], Selling for more than [new_crate.get_cost()], the cost to buy")
		for(var/atom/stuff as anything in results.contents)
			qdel(stuff)
			stuff = null

		qdel(results)
		results =  null
		new_crate = null
		minimum_cost = null
		export_log = null

/datum/unit_test/cargo_private_delivery_owner

/datum/unit_test/cargo_private_delivery_owner/Run()
	var/datum/job/station_engineer/engineering_job = allocate(/datum/job/station_engineer)
	var/datum/bank_account/department/engineering_budget = SSeconomy.get_dep_account(ACCOUNT_ENG)
	TEST_ASSERT_NOTNULL(engineering_budget, "Engineering budget was not initialized.")

	var/datum/bank_account/recipient_account = allocate(/datum/bank_account, "Recipient Engineer", engineering_job, 1, FALSE)
	var/datum/bank_account/other_engineer_account = allocate(/datum/bank_account, "Other Engineer", engineering_job, 1, FALSE)
	var/datum/supply_pack/companies/general/hc_surplus/voskhod_refit_kit/company_pack = allocate(/datum/supply_pack/companies/general/hc_surplus/voskhod_refit_kit)
	var/datum/supply_pack/goody/coffee_mug/goody_pack = allocate(/datum/supply_pack/goody/coffee_mug)

	var/datum/supply_order/department_paid_order = allocate(
		/datum/supply_order,
		company_pack,
		"Recipient Engineer",
		"Station Engineer",
		null,
		"Unit test",
		engineering_budget,
		null,
		null,
		TRUE,
		TRUE,
		MONEY_SYMBOL,
		TRUE,
		recipient_account,
	)
	TEST_ASSERT_EQUAL(department_paid_order.paying_account, engineering_budget, "Department-paid imports should keep the department as payer.")
	TEST_ASSERT_EQUAL(department_paid_order.get_private_delivery_account(), recipient_account, "Department-paid imports should use the ordering account as private delivery owner.")
	TEST_ASSERT(!department_paid_order.is_private_purchase(), "Department-paid imports should not count as private purchases.")
	TEST_ASSERT(company_pack.order_flags & ORDER_GOODY, "Test company import pack should retain ORDER_GOODY for catalogue behavior.")
	TEST_ASSERT(department_paid_order.ships_in_goody_case(), "Company imports with ORDER_GOODY should ship in goody cases.")

	var/datum/supply_order/goody_order = allocate(
		/datum/supply_order,
		goody_pack,
		"Goody Buyer",
		"Station Engineer",
		null,
		"Unit test",
		recipient_account,
		null,
		null,
		TRUE,
		TRUE,
		MONEY_SYMBOL,
		TRUE,
	)
	TEST_ASSERT(goody_order.ships_in_goody_case(), "Regular goody packs should still ship in goody cases.")

	var/mob/living/carbon/human/consistent/recipient = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/budget_holder = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/other_engineer = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/card/id/recipient_id = allocate(/obj/item/card/id)
	recipient_id.set_account(recipient_account)
	var/obj/item/card/id/budget_id = allocate(/obj/item/card/id)
	budget_id.set_account(engineering_budget)
	var/obj/item/card/id/other_engineer_id = allocate(/obj/item/card/id)
	other_engineer_id.set_account(other_engineer_account)
	recipient.equip_to_slot_or_del(recipient_id, ITEM_SLOT_ID)
	budget_holder.equip_to_slot_or_del(budget_id, ITEM_SLOT_ID)
	other_engineer.equip_to_slot_or_del(other_engineer_id, ITEM_SLOT_ID)

	var/obj/item/storage/lockbox/order/department_paid_case = new(run_loc_floor_bottom_left, department_paid_order.get_private_delivery_account())
	allocated += department_paid_case
	TEST_ASSERT_EQUAL(department_paid_case.buyer_account, recipient_account, "Department-paid company import goody cases should be owned by the ordering account.")
	TEST_ASSERT(!department_paid_case.can_unlock(budget_holder, budget_id, TRUE), "Department budget card should not unlock a recipient-owned company import goody case.")
	TEST_ASSERT(!department_paid_case.can_unlock(other_engineer, other_engineer_id, TRUE), "Another employee in the same department should not unlock a recipient-owned company import goody case.")
	TEST_ASSERT(department_paid_case.can_unlock(recipient, recipient_id, TRUE), "Recipient ID should unlock a department-paid company import goody case.")

	var/datum/bank_account/self_paid_account = recipient_account
	var/datum/supply_order/self_paid_order = allocate(
		/datum/supply_order,
		company_pack,
		"Self Paid Buyer",
		"Station Engineer",
		null,
		"Unit test",
		self_paid_account,
		null,
		null,
		TRUE,
		TRUE,
		MONEY_SYMBOL,
		TRUE,
		null,
		TRUE,
	)
	TEST_ASSERT_EQUAL(self_paid_order.get_private_delivery_account(), self_paid_account, "Orders without recipient_account should fall back to paying_account.")
	TEST_ASSERT(self_paid_order.is_private_purchase(), "Self-paid imports should count as private purchases.")
	TEST_ASSERT_NOTEQUAL(department_paid_order.get_checkout_group_key(), self_paid_order.get_checkout_group_key(), "Budget-paid and self-paid imports of the same pack should not share a checkout group.")
	TEST_ASSERT_NOTEQUAL(department_paid_order.get_goody_delivery_group_key(), self_paid_order.get_goody_delivery_group_key(), "Budget-paid and self-paid imports of the same pack should not share a goody delivery group.")

	var/datum/supply_order/second_self_paid_order = allocate(
		/datum/supply_order,
		company_pack,
		"Self Paid Buyer",
		"Station Engineer",
		null,
		"Unit test",
		self_paid_account,
		null,
		null,
		TRUE,
		TRUE,
		MONEY_SYMBOL,
		TRUE,
		null,
		TRUE,
	)
	TEST_ASSERT_EQUAL(self_paid_order.get_checkout_group_key(), second_self_paid_order.get_checkout_group_key(), "Matching self-paid imports from the same account should share a checkout group.")
	TEST_ASSERT_EQUAL(self_paid_order.get_goody_delivery_group_key(), second_self_paid_order.get_goody_delivery_group_key(), "Matching self-paid imports from the same account should share a goody delivery group.")

	var/datum/supply_order/other_department_paid_order = allocate(
		/datum/supply_order,
		company_pack,
		"Other Engineer",
		"Station Engineer",
		null,
		"Unit test",
		engineering_budget,
		null,
		null,
		TRUE,
		TRUE,
		MONEY_SYMBOL,
		TRUE,
		other_engineer_account,
	)
	TEST_ASSERT_NOTEQUAL(department_paid_order.get_checkout_group_key(), other_department_paid_order.get_checkout_group_key(), "Budget-paid imports for different recipients should not share a checkout group.")
	TEST_ASSERT_NOTEQUAL(department_paid_order.get_goody_delivery_group_key(), other_department_paid_order.get_goody_delivery_group_key(), "Budget-paid imports for different recipients should not share a goody delivery group.")

	var/list/previous_shopping_list = SSshuttle.shopping_list
	SSshuttle.shopping_list = list(department_paid_order, self_paid_order, second_self_paid_order)
	var/obj/machinery/computer/cargo/cargo_console = allocate(/obj/machinery/computer/cargo)
	var/list/cargo_ui_data = cargo_console.ui_data()
	SSshuttle.shopping_list = previous_shopping_list
	var/list/cart_data = cargo_ui_data["cart"]
	TEST_ASSERT_EQUAL(length(cart_data), 2, "Cart aggregation should split budget-paid and self-paid imports of the same pack.")
	var/private_cart_rows = 0
	var/budget_cart_rows = 0
	for(var/list/cart_entry as anything in cart_data)
		TEST_ASSERT_NOTNULL(cart_entry["cart_key"], "Cart entries should include their grouping key.")
		if(cart_entry["paid"])
			private_cart_rows++
			TEST_ASSERT_EQUAL(cart_entry["amount"], 2, "Matching self-paid imports should stay grouped together.")
		else
			budget_cart_rows++
			TEST_ASSERT_EQUAL(cart_entry["amount"], 1, "Budget-paid import should remain separate from self-paid imports.")
	TEST_ASSERT_EQUAL(private_cart_rows, 1, "Cart should contain one private import row.")
	TEST_ASSERT_EQUAL(budget_cart_rows, 1, "Cart should contain one budget-paid import row.")

	var/obj/item/card/id/self_paid_id = allocate(/obj/item/card/id)
	self_paid_id.set_account(self_paid_account)
	var/mob/living/carbon/human/consistent/self_paid_buyer = allocate(/mob/living/carbon/human/consistent)
	self_paid_buyer.equip_to_slot_or_del(self_paid_id, ITEM_SLOT_ID)
	var/obj/item/storage/lockbox/order/self_paid_case = new(run_loc_floor_bottom_left, self_paid_order.get_private_delivery_account())
	allocated += self_paid_case
	TEST_ASSERT(self_paid_case.can_unlock(self_paid_buyer, self_paid_id, TRUE), "Self-paid fallback owner should unlock their private import goody case.")
