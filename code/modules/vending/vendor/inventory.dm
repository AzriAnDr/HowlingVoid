//================================STOCKING IN ITEMS=================================

// NOVA EDIT ADDITION START - HowlingVoid explicit vending prices
/obj/machinery/vending/proc/get_vending_brand_jitter(obj/item/product_path, adjusted_price)
	SHOULD_BE_PURE(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/price_seed = "[product_path]"
	var/price_hash = 0
	for(var/i in 1 to length(price_seed))
		price_hash += text2ascii(price_seed, i)

	var/jitter_span = 1
	if(adjusted_price >= 10 && adjusted_price <= 50)
		jitter_span = clamp(round(adjusted_price * 0.1), 2, 5)
	else if(adjusted_price > 50)
		jitter_span = clamp(round(adjusted_price * 0.06), 3, 25)

	var/brand_jitter = (price_hash % ((jitter_span * 2) + 1)) - jitter_span
	if(!brand_jitter)
		brand_jitter = (price_hash % 2) ? 1 : -1
	return brand_jitter

/obj/machinery/vending/proc/get_custom_vending_price(obj/item/product_path, custom_price)
	SHOULD_BE_PURE(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(custom_price <= 0)
		return custom_price

	var/adjusted_price = max(round(custom_price * SSeconomy.last_vending_price_index), 1)
	return max(adjusted_price + get_vending_brand_jitter(product_path, adjusted_price), 1)
// NOVA EDIT ADDITION END

/obj/machinery/vending/proc/uses_dynamic_vending_prices()
	if(istype(src, /obj/machinery/vending/custom))
		return FALSE
	if(all_products_free)
		return FALSE
	return onstation

/obj/machinery/vending/proc/refresh_prices_if_needed(force = FALSE)
	if(!uses_dynamic_vending_prices())
		vending_price_generation = SSeconomy.vending_price_generation
		return FALSE
	if(!force && vending_price_generation == SSeconomy.vending_price_generation)
		return FALSE

	reset_prices(product_records, coin_records + hidden_records)
	vending_price_generation = SSeconomy.vending_price_generation
	return TRUE

/**
 * Build the inventory of the vending machine from its product and record lists
 *
 * This builds up a full set of /datum/data/vending_products from the product list of the vending machine type
 * Arguments:
 * * productlist - the list of products that need to be converted
 * * recordlist - the list containing /datum/data/vending_product datums
 * * categories - A list in the format of product_categories to source category from
 * * startempty - should we set vending_product record amount from the product list (so it's prefilled at roundstart)
 * * premium - Whether the ending products shall have premium or default prices
 */
/obj/machinery/vending/proc/get_product_price(obj/item/product_path, premium = FALSE, stock_amount = 1)
	SHOULD_BE_PURE(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	// NOVA EDIT ADDITION START - HowlingVoid explicit vending prices
	var/obj/item/product = product_path
	var/custom_price = initial(product.custom_price)
	if(!isnull(custom_price))
		return get_custom_vending_price(product_path, custom_price)
	// NOVA EDIT ADDITION END

	var/base_price = premium ? extra_price : default_price
	if(base_price <= 0)
		return base_price

	var/stock_multiplier = 1
	var/adjusted_stock = max(stock_amount, 1)
	if(adjusted_stock <= 1)
		stock_multiplier = 1.35
	else if(adjusted_stock == 2)
		stock_multiplier = 1.2
	else if(adjusted_stock <= 4)
		stock_multiplier = 1.05
	else if(adjusted_stock <= 7)
		stock_multiplier = 0.9
	else
		stock_multiplier = 0.8

	var/price_seed = "[product_path]"
	var/price_hash = 0
	for(var/i in 1 to length(price_seed))
		price_hash += text2ascii(price_seed, i)

	var/price_jitter = round(base_price * (((price_hash % 7) - 3) * 0.05))
	return max(round(base_price * stock_multiplier) + price_jitter, 1)

/obj/machinery/vending/proc/build_inventory(list/productlist, list/recordlist, list/categories, start_empty = FALSE, premium = FALSE)
	PRIVATE_PROC(TRUE)

	var/effective_price_index = SSeconomy.last_vending_price_index
	default_price = round(initial(default_price) * effective_price_index)
	extra_price = round(initial(extra_price) * effective_price_index)

	QDEL_LIST(recordlist)

	var/list/product_to_category = list()
	for (var/list/category as anything in categories)
		for (var/product_key in category["products"])
			product_to_category[product_key] = category

	for(var/typepath in productlist)
		// NOVA EDIT ADDITION START
		if(is_type_in_typecache(typepath, excluded_products))
			continue
		// NOVA EDIT ADDITION END
		var/amount = productlist[typepath]

		var/obj/item/temp = typepath
		var/datum/data/vending_product/new_record = new
		new_record.name = initial(temp.name)
		new_record.product_path = typepath
		if(!start_empty)
			new_record.amount = amount
		new_record.max_amount = amount

		new_record.price = get_product_price(typepath, premium, amount)

		new_record.age_restricted = initial(temp.age_restricted)
		new_record.colorable = !!(initial(temp.greyscale_config) && initial(temp.greyscale_colors) && (initial(temp.flags_1) & IS_PLAYER_COLORABLE_1))
		new_record.category = product_to_category[typepath]
		recordlist += new_record

/**
 * Builds all available inventories for the vendor - standard, contraband and premium
 *
 * Arguments
 * start_empty - bool to pass into build_inventory that determines whether a product entry starts with available stock or not
*/
/obj/machinery/vending/proc/build_inventories(start_empty = FALSE)
	build_inventory(products, product_records, product_categories, start_empty)
	build_inventory(contraband, hidden_records, list(list("name" = "Contraband", "icon" = "mask", "products" = contraband)), start_empty, premium = TRUE)
	build_inventory(premium, coin_records, list(list("name" = "Premium", "icon" = "coins", "products" = premium)), start_empty, premium = TRUE)
	vending_price_generation = SSeconomy.vending_price_generation

//Better would be to make constructable child
/obj/machinery/vending/RefreshParts()
	SHOULD_CALL_PARENT(FALSE)

	//compress all product categories into an linear list
	if(product_categories)
		products.Cut()
		for(var/list/category as anything in product_categories)
			products |= category["products"]

	//locate canister
	var/obj/item/vending_refill/canister = refill_canister ? locate(refill_canister) in component_parts : null

	//build the records, if we have a canister make the records empty so we can refill it from the canister else make it max amount
	build_inventories(start_empty = !isnull(canister))

	//fill the records if we have an canister
	if(canister)
		restock(canister)

/**
 * Refill a vending machine from a refill canister
 *
 * This takes the products from the refill canister and then fills the products, contraband and premium product categories
 *
 * Arguments:
 * * canister - the vending canister we are refilling from
 */
/obj/machinery/vending/proc/restock(obj/item/vending_refill/canister)
	refresh_prices_if_needed()
	. = 0

	//to initialize product category & cargo ordered canisters for the 1st time
	if(!canister.products)
		canister.products = products.Copy()
		canister.contraband = contraband.Copy()
		canister.premium = premium.Copy()

	var/list/datum/data/vending_product/record_list
	var/list/canister_list

	for(var/i in 1 to 3)
		switch(i)
			if (1)
				record_list = product_records
				canister_list = canister.products
			if (2)
				record_list = hidden_records
				canister_list = canister.contraband
			else
				record_list = coin_records
				canister_list = canister.premium
		if(!record_list.len || !canister_list.len)
			continue

		for(var/datum/data/vending_product/record as anything in record_list)
			var/diff = min(record.max_amount - record.amount, canister_list[record.product_path] || 0)
			if (diff)
				canister_list[record.product_path] -= diff
				if(!canister_list[record.product_path])
					canister_list -= record.product_path
				record.amount += diff
				. += diff

//===========================VENDING OUT ITEMS================================
/obj/machinery/vending/Exited(atom/movable/gone, direction)
	. = ..()
	for(var/datum/data/vending_product/record in product_records + coin_records + hidden_records)
		if(gone in record.returned_products)
			record.returned_products -= gone
			record.amount -= 1
			break

/**
 * The entire shebang of vending the picked item. Processes the vending and initiates the payment for the item.
 * arguments:
 * greyscale_colors - greyscale config for the item we're about to vend, if any
 */
/obj/machinery/vending/proc/vend(list/params, mob/user, list/greyscale_colors)
	PROTECTED_PROC(TRUE)

	. = TRUE
	refresh_prices_if_needed()
	var/datum/data/vending_product/item_record = locate(params["ref"])
	var/list/record_to_check = product_records + coin_records
	if(extended_inventory)
		record_to_check = product_records + coin_records + hidden_records
	if(!item_record || !istype(item_record) || !item_record.product_path)
		return
	var/price_to_use = item_record.price
	if(item_record in hidden_records)
		if(!extended_inventory)
			return
	else if (!(item_record in record_to_check))
		message_admins("Vending machine exploit attempted by [ADMIN_LOOKUPFLW(user)]!")
		return
	if (item_record.amount <= 0)
		speak("Sold out of [item_record.name].")
		flick(icon_deny, src)
		return
	if(!all_products_free)
		// Here we do additional handing ahead of the payment component's logic, such as age restrictions and additional logging
		var/obj/item/card/id/card_used
		var/mob/living/living_user
		if(isliving(user))
			living_user = user
			card_used = living_user.get_idcard(TRUE)
		if(QDELETED(card_used))
			speak("You do not possess an ID to purchase [item_record.name].")
			return

		if(age_restrictions && item_record.age_restricted && (!card_used.registered_age || card_used.registered_age < AGE_MINOR))
			speak("You are not of legal age to purchase [item_record.name].")
			if(!(user in GLOB.narcd_underages))
				aas_config_announce(/datum/aas_config_entry/vendomat_age_control, list(
					"PERSON" = usr.name,
					"LOCATION" = get_area_name(src),
					"VENDOR" = name,
					"PRODUCT" = item_record.name
				), src, list(RADIO_CHANNEL_SECURITY))
				GLOB.narcd_underages += user
			flick(icon_deny, src)
			return

		if(!proceed_payment(card_used, living_user, item_record, price_to_use, params["discountless"]))
			return

	if(last_shopper != REF(user) || purchase_message_cooldown < world.time)
		var/vend_response = vend_reply || "Thank you for shopping with [src]!"
		speak(vend_response)
		purchase_message_cooldown = world.time + 5 SECONDS
		//This is not the best practice, but it's safe enough here since the chances of two people using a machine with the same ref in 5 seconds is fuck low
		last_shopper = REF(user)
	if(icon_vend) //Show the vending animation if needed
		flick(icon_vend, src)

	// Always give out free returned stuff first, e.g. to avoid walling a traitor objective in a bag behind paid items
	var/obj/item/vended_item = dispense(item_record, get_turf(src), dispense_returned = LAZYLEN(item_record.returned_products))
	if(!vended_item)
		return

	if(greyscale_colors)
		vended_item.set_greyscale(colors=greyscale_colors)
	if(IsReachableBy(user) && user.put_in_hands(vended_item))
		to_chat(user, span_notice("You take [item_record.name] out of the slot."))
		vended_item.do_pickup_animation(user, src)
	else
		to_chat(user, span_warning("[capitalize(format_text(item_record.name))] falls onto the floor!"))
	SSblackbox.record_feedback("nested tally", "vending_machine_usage", 1, list("[type]", "[item_record.product_path]"))

/**
 * Common proc that dispenses an item. Called when the item is vended, or gotten some other way.
 *
 * Arguments
 * * datum/data/vending_product/item_record - the vending record which contains the information of the item to dispense
 * * atom/spawn_location - location to dispense the item to
 * * silent - should we play the vending sound
 * * dispense_returned - are we vending out an returned item
*/
/obj/machinery/vending/proc/dispense(datum/data/vending_product/item_record, atom/spawn_location, silent = FALSE, dispense_returned = FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!silent)
		playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)

	var/obj/item/vended_item = null
	if(dispense_returned)
		vended_item = LAZYACCESS(item_record.returned_products, LAZYLEN(item_record.returned_products)) //first in, last out
		vended_item.forceMove(spawn_location)
	else if(item_record.amount)
		vended_item = new item_record.product_path(spawn_location)
		if(vended_item.type in contraband)
			ADD_TRAIT(vended_item, TRAIT_CONTRABAND, INNATE_TRAIT)
		item_record.amount--

	on_dispense(vended_item, dispense_returned)
	use_energy(active_power_usage)

	SEND_SIGNAL(src, COMSIG_VENDING_DISPENSED, vended_item)

	return vended_item

/**
 * A proc meant to perform custom behavior on newly dispensed items.
 *
 * Arguments
 * * obj/item/vended_item - the item that has just been dispensed
 * * dispense_returned - is this item an returned product
*/
/obj/machinery/vending/proc/on_dispense(obj/item/vended_item, dispense_returned = FALSE)
	PROTECTED_PROC(TRUE)

	return

/**
 * Handles payment processing: discounts, logging, balance change etc.
 * arguments:
 * paying_id_card - the id card that will be billed for the product.
 * mob_paying - the mob that is trying to purchase the item.
 * product_to_vend - the product record of the item we're trying to vend.
 * price_to_use - price of the item we're trying to vend.
 * discountless - whether or not to apply discounts
 */
/obj/machinery/vending/proc/proceed_payment(obj/item/card/id/paying_id_card, mob/living/mob_paying, datum/data/vending_product/product_to_vend, price_to_use, discountless)
	PROTECTED_PROC(TRUE)

	//returned items are free
	if(LAZYLEN(product_to_vend.returned_products))
		return TRUE

	//account to use. optional cause we handle cash on hand transfers as well
	var/datum/bank_account/account = paying_id_card.registered_account

	//deduct money from person
	if(!discountless && account.account_job?.paycheck_department == payment_department)
		price_to_use = max(round(price_to_use * DEPARTMENT_DISCOUNT), 1) //No longer free, but signifigantly cheaper.
	if(attempt_charge(src, mob_paying, price_to_use) & COMPONENT_OBJ_CANCEL_CHARGE)
		speak("You do not possess the funds to purchase [product_to_vend.name].")
		flick(icon_deny,src)
		return FALSE

	//transfer money to machine
	SSblackbox.record_feedback("amount", "vending_spent", price_to_use)
	var/account_holder = account?.account_holder || "unknown account"
	log_econ("[price_to_use] [MONEY_NAME] were inserted into [src] by [account_holder] to buy [product_to_vend].")
	// NOVA EDIT ADDITION START - Corporate economy vending consumption
	if(!istype(src, /obj/machinery/vending/custom))
		SSeconomy.record_consumption("vending", price_to_use, round(price_to_use * SSeconomy.corporate_retail_take_rate))
		if(account)
			SSeconomy.add_audit_entry(account, price_to_use, src)
	// NOVA EDIT ADDITION END
	credits_contained += round(price_to_use * VENDING_CREDITS_COLLECTION_AMOUNT)
	return TRUE
