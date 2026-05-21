/datum/species/dwarf
	name = "Dwarf"
	id = SPECIES_DWARF
	examine_limb_id = SPECIES_HUMAN
	inherent_traits = list(
		TRAIT_DWARF,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_USES_SKINTONES,
	)
	mutanttongue = /obj/item/organ/tongue/dwarven
	skinned_type = /obj/item/stack/sheet/animalhide/carbon/human
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	payday_modifier = 1.0
	body_size_restricted = TRUE

/datum/species/dwarf/get_species_description()
	return placeholder_description

/datum/species/dwarf/get_species_lore()
	return list(placeholder_lore)

/datum/species/dwarf/prepare_human_for_preview(mob/living/carbon/human/human)
	human.facial_hairstyle = "Beard (Dwarf)"
	human.facial_hair_color = "#a55310"
	regenerate_organs(human, src, visual_only = TRUE)
	human.update_body(TRUE)

// HowlingVoid dwarf mechanics integration.
/datum/species/dwarf
	inherent_traits = list(
		TRAIT_DWARF,
		TRAIT_FRIENDLY,
		TRAIT_ALCOHOL_TOLERANCE,
		TRAIT_STUBBY_BODY,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_USES_SKINTONES,
	)

/datum/species/dwarf/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	if(!istype(H))
		return

	H.physiology.cold_mod *= 0.8
	H.add_movespeed_mod_immunities(REF(src), list(
		/datum/movespeed_modifier/equipment_speedmod,
		/datum/movespeed_modifier/equipment_speedmod/immutable,
	), update = FALSE)
	H.update_equipment_speed_mods()
	RegisterSignal(H, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_dwarf_item_attack))
	RegisterSignal(H, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(on_dwarf_shield_reflect))
	RegisterSignal(H, COMSIG_MOB_FIRED_GUN, PROC_REF(on_dwarf_fired_gun))
	RegisterSignal(H, COMSIG_MOB_UPDATE_HELD_ITEMS, PROC_REF(update_clan_arms_bonus))
	update_clan_arms_bonus(H)

/datum/species/dwarf/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	if(!istype(H))
		return

	H.physiology.cold_mod /= 0.8
	H.remove_movespeed_mod_immunities(REF(src), list(
		/datum/movespeed_modifier/equipment_speedmod,
		/datum/movespeed_modifier/equipment_speedmod/immutable,
	), update = FALSE)
	H.update_equipment_speed_mods()
	UnregisterSignal(H, COMSIG_MOB_ITEM_ATTACK)
	UnregisterSignal(H, COMSIG_LIVING_CHECK_BLOCK)
	UnregisterSignal(H, COMSIG_MOB_FIRED_GUN)
	UnregisterSignal(H, COMSIG_MOB_UPDATE_HELD_ITEMS)
	REMOVE_TRAIT(H, TRAIT_GRABRESISTANCE, REF(src))

/datum/species/dwarf/spec_life(mob/living/carbon/human/H, seconds_per_tick)
	. = ..()

/datum/species/dwarf/proc/on_dwarf_fired_gun(mob/living/carbon/human/source, obj/item/gun/gun_fired, atom/target, params, zone_override, list/bonus_spread_values)
	SIGNAL_HANDLER

	if(!istype(source))
		return

	var/drunkenness = source.get_drunk_amount()
	// Drunken Vision: being fully sober makes dwarven aiming less steady.
	if(drunkenness < 12)
		bonus_spread_values[MIN_BONUS_SPREAD_INDEX] += 6
		bonus_spread_values[MAX_BONUS_SPREAD_INDEX] += 18

/datum/species/dwarf/proc/update_clan_arms_bonus(mob/living/carbon/human/H)
	SIGNAL_HANDLER

	if(!istype(H))
		return

	var/has_shield = FALSE
	for(var/obj/item/held_item as anything in H.held_items)
		if(istype(held_item, /obj/item/shield))
			has_shield = TRUE
			break

	if(has_shield)
		ADD_TRAIT(H, TRAIT_GRABRESISTANCE, REF(src))
	else
		REMOVE_TRAIT(H, TRAIT_GRABRESISTANCE, REF(src))

/datum/species/dwarf/proc/on_dwarf_item_attack(mob/living/carbon/human/source, mob/living/target, mob/living/user, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER

	if(!istype(source) || source != user)
		return
	if(!has_clan_mastery_stance(source))
		return

	MODIFY_ATTACK_FORCE_MULTIPLIER(attack_modifiers, 1.2)

/datum/species/dwarf/proc/has_clan_mastery_stance(mob/living/carbon/human/H)
	if(!istype(H))
		return FALSE

	var/has_shield = FALSE
	for(var/obj/item/held_item as anything in H.held_items)
		if(istype(held_item, /obj/item/shield))
			has_shield = TRUE
			break

	if(!has_shield)
		return FALSE

	return is_clan_weapon(H.get_active_held_item())

/datum/species/dwarf/proc/on_dwarf_shield_reflect(mob/living/carbon/human/source, atom/hit_by, damage, attack_text, attack_type, armour_penetration, damage_type)
	SIGNAL_HANDLER

	if(!istype(source))
		return
	if(attack_type == OVERWHELMING_ATTACK)
		return

	var/obj/item/shield/held_shield = get_held_shield(source)
	if(!held_shield)
		return

	// Dwarves are better at shield counters: slightly boosted block odds for this special check.
	var/final_block_chance = held_shield.block_chance - clamp((armour_penetration - held_shield.armour_penetration) / 2, 0, 100) + round(damage / -3) + 20
	if(!held_shield.hit_reaction(source, hit_by, attack_text, final_block_chance, damage, attack_type, damage_type))
		return

	if(attack_type == MELEE_ATTACK || attack_type == UNARMED_ATTACK || attack_type == LEAP_ATTACK)
		var/mob/living/assailant = GET_ASSAILANT(hit_by)
		if(assailant && assailant != source && prob(45))
			var/reflected_damage = clamp(round(max(damage, 6) * 0.35), 4, 15)
			assailant.apply_damage(reflected_damage, BRUTE, attack_direction = get_dir(source, assailant), attacking_item = held_shield)
			assailant.visible_message(
				span_danger("[source] deflects the blow with [held_shield], and the impact rebounds into [assailant]!"),
				span_userdanger("[source] deflects your strike with [held_shield], and the impact rebounds into you!"),
			)

	return SUCCESSFUL_BLOCK

/datum/species/dwarf/proc/get_held_shield(mob/living/carbon/human/H)
	if(!istype(H))
		return null

	var/obj/item/shield/best_shield = null
	for(var/obj/item/held_item as anything in H.held_items)
		if(!istype(held_item, /obj/item/shield))
			continue
		var/obj/item/shield/held_shield = held_item
		if(!best_shield || held_shield.block_chance > best_shield.block_chance)
			best_shield = held_shield

	return best_shield

/datum/species/dwarf/proc/is_clan_weapon(obj/item/held_item)
	if(!istype(held_item))
		return FALSE

	return istype(held_item, /obj/item/hatchet) \
		|| istype(held_item, /obj/item/fireaxe) \
		|| istype(held_item, /obj/item/melee/breaching_hammer) \
		|| istype(held_item, /obj/item/forging/reagent_weapon/axe) \
		|| istype(held_item, /obj/item/forging/reagent_weapon/hammer) \
		|| istype(held_item, /obj/item/forging/hammer) \
		|| istype(held_item, /obj/item/carpenter_hammer) \
		|| istype(held_item, /obj/item/clockwork/weapon/brass_battlehammer)

/datum/species/dwarf/create_pref_unique_perks()
	var/list/perks = list()
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_PERSON,
		SPECIES_PERK_NAME = "Dwarven Stature",
		SPECIES_PERK_DESC = "Dwarves are naturally short and can squeeze through spaces that normal humans cannot.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_HANDS_HELPING,
		SPECIES_PERK_NAME = "Warm-Hearted",
		SPECIES_PERK_DESC = "Dwarves are naturally friendly and socially open, tending toward kind and supportive interactions.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_BEER_MUG_EMPTY,
		SPECIES_PERK_NAME = "Stout Constitution",
		SPECIES_PERK_DESC = "Dwarven physiology handles alcohol better than most species.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_SHIELD,
		SPECIES_PERK_NAME = "Clan Arms",
		SPECIES_PERK_DESC = "Dwarven culture revolves around axes, hammers and shields. While fighting with an axe or hammer and a shield, your melee strikes hit harder, shield counters are more likely to rebound damage, and heavy armor does not encumber you.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_BACON,
		SPECIES_PERK_NAME = "Dwarven Tongue",
		SPECIES_PERK_DESC = "You bellow when speaking and have distinct food preferences: meat, dairy and alcohol are favored.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "eye",
		SPECIES_PERK_NAME = "Drunken Vision",
		SPECIES_PERK_DESC = "Stone-cold sober dwarves shoot less steadily. A little drink helps them keep aim.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_PERSON,
		SPECIES_PERK_NAME = "Short Stride",
		SPECIES_PERK_DESC = "Climbing up obstacles takes longer for dwarves.",
	))
	return perks

