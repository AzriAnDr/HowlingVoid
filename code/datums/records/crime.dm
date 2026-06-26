/**
 * Crime data. Used to store information about crimes.
 */
/datum/crime
	/// Name of the crime
	var/name
	/// Details about the crime
	var/details
	/// Player that wrote the crime
	var/author
	/// Time of the crime
	var/time
	/// Whether the crime is active or not
	var/valid = TRUE
	/// Player that marked the crime as invalid
	var/voider

/datum/crime/New(name = "Crime", details = "No details provided.", author = "Anonymous")
	src.author = author
	src.details = details
	src.name = name
	src.time = station_time_timestamp()

/datum/crime/citation
	/// Fine for the crime
	var/fine
	/// Amount of money paid for the crime
	var/paid
	/// Bank account ID of the person who issued this citation.
	var/author_account_id

/datum/crime/citation/New(name = "Citation", details = "No details provided.", author = "Anonymous", fine = 0)
	. = ..()
	src.fine = fine
	src.paid = 0

/// Pays off a fine and attempts to fix any weird values.
/datum/crime/citation/proc/pay_fine(amount)
	if(amount <= 0)
		return FALSE

	paid += amount
	if(paid > fine)
		paid = fine

	fine -= amount
	if(fine < 0)
		fine = 0

	return TRUE

/// Stores the issuing officer's bank account for fine commission payouts.
/datum/crime/citation/proc/set_author_account_from_mob(mob/living/issuer)
	if(!issuer)
		return FALSE

	var/obj/item/card/id/issuer_id
	if(ishuman(issuer))
		var/mob/living/carbon/human/human_issuer = issuer
		issuer_id = human_issuer.wear_id?.GetID()
	if(!issuer_id)
		issuer_id = issuer.get_idcard(TRUE)

	if(!issuer_id?.registered_account)
		return FALSE

	author_account_id = issuer_id.registered_account.account_id
	return TRUE

/// Finds the bank account that should receive the citation author commission.
/datum/crime/citation/proc/get_author_account()
	if(author_account_id)
		var/datum/bank_account/stored_account = SSeconomy.bank_accounts_by_id["[author_account_id]"]
		if(stored_account)
			return stored_account

	if(isliving(author))
		var/mob/living/author_mob = author
		var/obj/item/card/id/author_id
		if(ishuman(author_mob))
			var/mob/living/carbon/human/human_author = author_mob
			author_id = human_author.wear_id?.GetID()
		if(!author_id)
			author_id = author_mob.get_idcard(TRUE)
		return author_id?.registered_account

	if(istext(author))
		for(var/account_id in SSeconomy.bank_accounts_by_id)
			var/datum/bank_account/account = SSeconomy.bank_accounts_by_id[account_id]
			if(account?.account_holder == author)
				return account

	return null

/// Sends a citation alert message to the target's PDA.
/datum/crime/citation/proc/alert_owner(mob/sender, atom/source, target_name, message)
	for(var/messenger_ref in GLOB.pda_messengers)
		var/datum/computer_file/program/messenger/messenger = GLOB.pda_messengers[messenger_ref]
		if(messenger.computer.saved_identification != target_name)
			continue

		var/datum/signal/subspace/messaging/tablet_message/signal = new(source, list(
			"fakename" = "Security Citation",
			"fakejob" = "Citation Server",
			"message" = message,
			"targets" = list(messenger),
			"automated" = TRUE
		))
		signal.send_to_receivers()
		sender.log_message("(PDA: Citation Server) sent \"[message]\" to [signal.format_target()]", LOG_PDA)
		break

	return TRUE
