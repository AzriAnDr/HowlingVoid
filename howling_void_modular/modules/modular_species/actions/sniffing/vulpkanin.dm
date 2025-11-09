/datum/action/cooldown/scent_scan/vulp
	sniffable_categories = list(
		DETSCAN_CATEGORY_FINGERS,
		DETSCAN_CATEGORY_FIBER,
		DETSCAN_CATEGORY_BLOOD,
	)


/datum/action/cooldown/scent_scan/vulp/perform_scan(mob/living/carbon/human/H, atom/target)
	if(ishuman(target))
		var/mob/living/carbon/human/sniffing = target

		var/damage_amount = sniffing.getBruteLoss() + sniffing.getFireLoss()
		var/health_message = "На [sniffing.get_visible_name()] "
		switch(damage_amount)
			if (0 to 15)
				health_message += "нет никаких ранений"
			if (16 to 35)
				health_message += "виднеются небольшие ссадины"
			if (36 to 55)
				health_message += "заметны свежие раны"
			if (56 to 85)
				health_message += "[sniffing.get_visible_name()] сильно ранен[sniffing.gender == FEMALE ? "а" : ""]"
			if (86 to 120)
				health_message = "[sniffing.get_visible_name()] имеет крайне много ранений"
			if (130 to INFINITY)
				health_message = "[sniffing.get_visible_name()] одной ногой в могиле"

		to_chat(H, span_info("[health_message][LAZYLEN(sniffing.diseases) ? ", возможно [sniffing.gender == FEMALE ? "она больна." : "он болен."] ": "."]"))
		StartCooldown()
		return
	return ..()
