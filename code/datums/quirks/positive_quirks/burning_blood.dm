/datum/quirk/burning_blood
	name = "Burning Blood"
	desc = "Your blood clots with supernatural speed, but the heat of the process scorches your flesh."
	icon = FA_ICON_FIRE_FLAME_CURVED
	value = 4
	mob_trait = TRAIT_BURNING_BLOOD
	gain_text = span_notice("Your veins thrum with blistering vitality.")
	lose_text = span_danger("The inferno in your veins finally cools.")
	medical_record_text = "Patient presents hyper-coagulating blood that causes minor thermal damage while clotting."
	quirk_flags = QUIRK_HUMAN_ONLY

/datum/quirk/burning_blood/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(handle_burning_blood))

/datum/quirk/burning_blood/remove()
	UnregisterSignal(quirk_holder, COMSIG_HUMAN_ON_HANDLE_BLOOD)

/datum/quirk/burning_blood/proc/handle_burning_blood(datum/source, seconds_per_tick)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/human_holder = quirk_holder
	if(!istype(human_holder) || human_holder.stat == DEAD || HAS_TRAIT(human_holder, TRAIT_NOBLOOD))
		return

	var/bleeding_limbs = 0
	for(var/obj/item/bodypart/bodypart as anything in human_holder.bodyparts)
		for(var/datum/wound/wound as anything in bodypart.wounds)
			if(wound.blood_flow > 0)
				bleeding_limbs++

	var/clot_multiplier = max(bleeding_limbs, 1)
	var/burn_damage = seconds_per_tick
	var/applied_damage = FALSE

	for(var/obj/item/bodypart/bodypart as anything in human_holder.bodyparts)
		if(!bodypart.can_bleed())
			continue

		var/original_bleed_rate = bodypart.cached_bleed_rate

		if(bodypart.generic_bleedstacks > 0)
			bodypart.adjustBleedStacks(-clot_multiplier, 0)

		var/obj/item/stack/medical/wrap/current_gauze = LAZYACCESS(bodypart.applied_items, LIMB_ITEM_GAUZE)
		var/gauze_power = current_gauze?.absorption_rate
		if(!isnum(gauze_power) || gauze_power <= 0)
			gauze_power = 0
		var/forced_clot_rate = 0.05

		for(var/datum/wound/wound as anything in bodypart.wounds)
			if(wound.blood_flow <= 0)
				continue

			var/clot_rate = wound.vars["clot_rate"]
			if(isnum(clot_rate) && clot_rate > 0)
				wound.adjust_blood_flow(-clot_rate * seconds_per_tick * clot_multiplier)
			else
				wound.adjust_blood_flow(-forced_clot_rate * seconds_per_tick * clot_multiplier)

			if(gauze_power <= 0)
				continue

			var/gauzed_clot_rate = wound.vars["gauzed_clot_rate"]
			if(isnum(gauzed_clot_rate) && gauzed_clot_rate > 0)
				wound.adjust_blood_flow(-gauze_power * gauzed_clot_rate * seconds_per_tick * clot_multiplier)
			else
				wound.adjust_blood_flow(-gauze_power * forced_clot_rate * seconds_per_tick * clot_multiplier)

		if(original_bleed_rate > 0 && bodypart.receive_damage(burn = burn_damage, updating_health = FALSE, wound_bonus = CANT_WOUND, wound_clothing = FALSE))
			applied_damage = TRUE

	if(applied_damage)
		human_holder.updatehealth()
