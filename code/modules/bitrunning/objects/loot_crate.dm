/obj/structure/closet/crate/secure/bitrunning // Base class. Do not spawn this.
	name = "base class cache"
	desc = "Talk to a coder."
	icon_state = "bitrunning"
	base_icon_state = "bitrunning"

/// The virtual domain - side of the bitrunning crate. Deliver to the send location.
/obj/structure/closet/crate/secure/bitrunning/encrypted
	name = "encrypted cache"
	desc = "Needs to be decrypted at the safehouse to be opened."
	locked = TRUE
	damage_deflection = 30
	resistance_flags =  INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/closet/crate/secure/bitrunning/encrypted/can_unlock(mob/living/user, obj/item/card/id/player_id, obj/item/card/id/registered_id)
	return FALSE

/// The bitrunner den - side of the bitrunning crate. Appears in the receive location.
/obj/structure/closet/crate/secure/bitrunning/decrypted
	name = "decrypted cache"
	desc = "Compiled from the virtual domain. The reward of a successful bitrunner."
	locked = FALSE
	/// Ore payout data entries that define the stack type and its multiplier
	var/static/list/ore_reward_table = list(
		list(
			"path" = /obj/item/stack/ore/iron,
			"multiplier" = 3,
		),
		list(
			"path" = /obj/item/stack/ore/glass,
			"multiplier" = 3,
		),
		list(
			"path" = /obj/item/stack/ore/gold,
			"multiplier" = 0.8,
		),
		list(
			"path" = /obj/item/stack/ore/uranium,
			"multiplier" = 0.5,
		),
		list(
			"path" = /obj/item/stack/ore/titanium,
			"multiplier" = 0.5,
		),
		list(
			"path" = /obj/item/stack/ore/silver,
			"multiplier" = 1,
		),
		list(
			"path" = /obj/item/stack/ore/diamond,
			"multiplier" = 0.2,
		),
		list(
			"path" = /obj/item/stack/ore/bluespace_crystal,
			"multiplier" = 0.2,
		),
		list(
			"path" = /obj/item/stack/ore/plasma,
			"multiplier" = 1,
		),
	)
	/// Final ore payouts keyed by ore path
	var/list/ore_payout_summary

/obj/structure/closet/crate/secure/bitrunning/decrypted/Initialize(
	mapload,
	datum/lazy_template/virtual_domain/completed_domain,
	rewards_multiplier = 1,
	grade = "D",
	obj/machinery/byteforge/source_forge,
	)
	. = ..()
	playsound(src, 'sound/effects/magic/blink.ogg', 50, TRUE)

	if(isnull(completed_domain))
		return

	var/ore_yield_multiplier = 1
	var/duplication_chance = 0

	if(source_forge)
		ore_yield_multiplier = source_forge.get_ore_yield_multiplier()
		duplication_chance = source_forge.get_ore_duplication_chance()

	PopulateContents(completed_domain, rewards_multiplier, grade, ore_yield_multiplier, duplication_chance)

/obj/structure/closet/crate/secure/bitrunning/decrypted/PopulateContents(
	datum/lazy_template/virtual_domain/completed_domain,
	rewards_multiplier,
	grade,
	ore_yield_multiplier,
	duplication_chance,
	)
	. = ..()
	if(completed_domain)
		spawn_loot(completed_domain.completion_loot)

	var/grade_value = get_grade_value(grade)
	var/difficulty_value = completed_domain ? get_difficulty_value(completed_domain.difficulty) : 0
	LAZYINITLIST(ore_payout_summary)
	ore_payout_summary.Cut()

	var/should_duplicate = duplication_chance > 0 && prob(duplication_chance)

	for(var/list/entry as anything in ore_reward_table)
		if(!islist(entry))
			continue

		var/ore_path = entry["path"]
		if(!ispath(ore_path))
			continue

		var/ore_modifier = entry["multiplier"]
		if(!isnum(ore_modifier))
			continue

		var/amount = calculate_ore_amount(grade_value, difficulty_value, ore_modifier, rewards_multiplier, ore_yield_multiplier)
		if(should_duplicate)
			amount *= 2
		var/obj/item/stack/ore/new_stack = new ore_path(src, amount)
		var/list/payout_entry = list(
			"name" = new_stack.name,
			"amount" = amount,
		)
		ore_payout_summary[ore_path] = payout_entry

/obj/structure/closet/crate/secure/bitrunning/decrypted/proc/update_manifest_with_ore_totals()
	var/obj/item/paper/reward_manifest = manifest?.resolve()
	if(isnull(reward_manifest) || !LAZYLEN(ore_payout_summary))
		return

	var/text = "\n\n---\n\n### Ore Rewards\n"

	for(var/ore_path as anything in ore_payout_summary)
		var/list/ore_info = ore_payout_summary[ore_path]
		if(!islist(ore_info))
			continue

		var/ore_amount = ore_info["amount"]
		if(!ore_amount)
			continue

		var/ore_name = ore_info["name"]
		if(isnull(ore_name))
			ore_name = "Unknown"
		text += "- **[ore_name]:** [ore_amount]\n"

	reward_manifest.add_raw_text(text)
	reward_manifest.update_appearance()

/// Returns the numeric value associated with the completion grade
/obj/structure/closet/crate/secure/bitrunning/decrypted/proc/get_grade_value(grade)
	PRIVATE_PROC(TRUE)

	if(istext(grade))
		switch(uppertext(grade))
			if("S")
				return 3
			if("A")
				return 2
			if("B")
				return 1.5
			if("C")
				return 1
			if("D")
				return 0.5

	return 1

/// Returns the numeric modifier based on domain difficulty
/obj/structure/closet/crate/secure/bitrunning/decrypted/proc/get_difficulty_value(difficulty)
	PRIVATE_PROC(TRUE)

	switch(difficulty)
		if(BITRUNNER_DIFFICULTY_EXTREME)
			return 3
		if(BITRUNNER_DIFFICULTY_HIGH)
			return 1.5
		if(BITRUNNER_DIFFICULTY_MEDIUM)
			return 1
		if(BITRUNNER_DIFFICULTY_LOW)
			return 0.5
		else
			return 0

/// Calculates the ore stack size based on grade, difficulty and modifiers
/obj/structure/closet/crate/secure/bitrunning/decrypted/proc/calculate_ore_amount(
	grade_value,
	difficulty_value,
	ore_modifier,
	rewards_multiplier,
	ore_yield_multiplier,
	)
	PRIVATE_PROC(TRUE)

	var/base_value = 1 + grade_value + difficulty_value
	var/result = base_value * max(ore_modifier, 0)
	result *= max(rewards_multiplier, 0)
	result *= max(ore_yield_multiplier, 0)

	return max(CEILING(result, 1), 1)

/// Handles spawning completion loot. This tries to handle bad flat and assoc lists
/obj/structure/closet/crate/secure/bitrunning/decrypted/proc/spawn_loot(list/completion_loot)
	for(var/path in completion_loot)
		if(!ispath(path))
			return FALSE

		if(isnull(completion_loot[path]))
			return FALSE

		for(var/i in 1 to completion_loot[path])
			new path(src)

	return TRUE
