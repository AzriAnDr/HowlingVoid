/datum/species/fly
	name = "Flyperson"
	plural_form = "Flypeople"
	id = SPECIES_FLYPERSON
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	meat = /obj/item/food/meat/slab/human/mutant/fly
	mutanteyes = /obj/item/organ/eyes/fly
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/fly
	payday_modifier = 1.0

	mutanttongue = /obj/item/organ/tongue/fly
	mutantheart = /obj/item/organ/heart/fly
	mutantlungs = /obj/item/organ/lungs/fly
	mutantliver = /obj/item/organ/liver/fly
	mutantstomach = /obj/item/organ/stomach/fly
	mutantappendix = /obj/item/organ/appendix/fly
	mutant_organs = list(/obj/item/organ/fly, /obj/item/organ/fly/groin)

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/fly,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/fly,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/fly,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/fly,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/fly,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/fly,
	)

/datum/species/fly/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if(!human_who_gained_species)
		return
	RegisterSignal(human_who_gained_species, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

/datum/species/fly/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	if(!C)
		return
	UnregisterSignal(C, COMSIG_ATOM_ATTACKBY)

/datum/species/fly/proc/on_attackby(mob/living/source, obj/item/attacking_item, mob/living/attacker, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER

	if(istype(attacking_item, /obj/item/melee/flyswatter))
		MODIFY_ATTACK_FORCE_MULTIPLIER(attack_modifiers, 30) // Yes, a 30x damage modifier

/datum/species/fly/get_physical_attributes()
	return "These hideous creatures suffer from pesticide immensely, eat waste, and are incredibly vulnerable to bright lights. They do have wings though."

/datum/species/fly/get_species_description()
	return "With no official documentation or knowledge of the origin of \
		this species, they remain a mystery to most. Any and all rumours among \
		Nanotrasen staff regarding flypeople are often quickly silenced by high \
		ranking staff or officials."

/datum/species/fly/get_species_lore()
	return list(
		"Flypeople are a curious species with a striking resemblance to the insect order of Diptera, \
		commonly known as flies. With no publicly known origin, flypeople are rumored to be a side effect of bluespace travel, \
		despite statements from Nanotrasen officials.",

		"Little is known about the origins of this race, \
		however they possess the ability to communicate with giant spiders, originally discovered in the Australicus sector \
		and now a common occurrence in black markets as a result of a breakthrough in syndicate bioweapon research.",

		"Flypeople are often feared or avoided among other species, their appearance often described as unclean or frightening in some cases, \
		and their eating habits even more so with an insufferable accent to top it off.",
	)

/datum/species/fly/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "grin-tongue",
			SPECIES_PERK_NAME = "Uncanny Digestive System",
			SPECIES_PERK_DESC = "Flypeople regurgitate their stomach contents and drink it \
				off the floor to eat and drink with little care for taste, favoring gross foods.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Insectoid Biology",
			SPECIES_PERK_DESC = "Fly swatters will deal significantly higher amounts of damage to a Flyperson.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Radial Eyesight",
			SPECIES_PERK_DESC = "Flypeople can be flashed from all angles.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "briefcase-medical",
			SPECIES_PERK_NAME = "Weird Organs",
			SPECIES_PERK_DESC = "Flypeople take specialized medical knowledge to be \
				treated. Their organs are disfigured and organ manipulation can be interesting...",
		),
	)

	return to_add

// HowlingVoid flyperson mechanics integration.
/datum/species/fly
	/// Species-granted action tracked for cleanup.
	var/tmp/list/species_buzz_sense_action = list()

/datum/species/fly/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()

	if(!istype(human_who_gained_species))
		return

	var/datum/action/cooldown/fly_buzz_sense/old_action = species_buzz_sense_action[human_who_gained_species]
	if(old_action)
		old_action.Remove(human_who_gained_species)
		qdel(old_action)
	species_buzz_sense_action[human_who_gained_species] = null

	var/datum/action/cooldown/fly_buzz_sense/new_action = new()
	new_action.Grant(human_who_gained_species)
	species_buzz_sense_action[human_who_gained_species] = new_action

/datum/species/fly/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()

	if(!istype(C))
		return

	var/datum/action/cooldown/fly_buzz_sense/action = species_buzz_sense_action[C]
	if(action)
		action.Remove(C)
		qdel(action)
	species_buzz_sense_action[C] = null

/datum/species/fly/create_pref_unique_perks()
	. = ..()
	. += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_MAGNIFYING_GLASS,
		SPECIES_PERK_NAME = "Buzz Sense",
		SPECIES_PERK_DESC = "Flypeople can actively sense nearby corpses, decay, and filth.",
	))

/datum/action/cooldown/fly_buzz_sense
	name = "Buzz Sense"
	desc = "Focus your antennae to sense nearby death, rot, and filth."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "bci_scan"
	cooldown_time = 10 SECONDS
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/cooldown/fly_buzz_sense/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/list/trace_choices = list(
		"Any",
		"Death",
		"Decay",
		"Filth",
		"Spoiled Food",
	)
	var/choice = tgui_input_list(H, "Choose what trace to focus on:", "Buzz Sense", trace_choices, "Any")
	if(isnull(choice))
		return FALSE

	var/focus_kind = "any"
	switch(choice)
		if("Death")
			focus_kind = "corpse"
		if("Decay")
			focus_kind = "remains"
		if("Filth")
			focus_kind = "filth"
		if("Spoiled Food")
			focus_kind = "food"

	var/atom/best_target
	var/best_score = -1
	var/best_kind = null

	if(focus_kind == "any" || focus_kind == "corpse")
		for(var/mob/living/nearby in view(7, H))
			if(nearby == H || nearby.stat != DEAD)
				continue
			var/score = 500 - (get_dist(H, nearby) * 25)
			if(score > best_score)
				best_score = score
				best_target = nearby
				best_kind = "corpse"

	if(focus_kind == "any" || focus_kind == "remains")
		for(var/obj/effect/decal/remains/remains in view(7, H))
			var/score = 430 - (get_dist(H, remains) * 20)
			if(score > best_score)
				best_score = score
				best_target = remains
				best_kind = "remains"

	if(focus_kind == "any" || focus_kind == "filth")
		for(var/obj/effect/decal/cleanable/dirty in view(7, H))
			var/score = 320 - (get_dist(H, dirty) * 15)
			if(score > best_score)
				best_score = score
				best_target = dirty
				best_kind = "filth"

	if(focus_kind == "any" || focus_kind == "food")
		for(var/obj/item/food/food in view(7, H))
			var/food_flags = food.foodtypes
			if(!(food_flags & (GROSS | GORE | RAW | MEAT)))
				continue
			var/score = 280 - (get_dist(H, food) * 15)
			if(score > best_score)
				best_score = score
				best_target = food
				best_kind = "food"

	if(!best_target)
		to_chat(H, span_notice("Your antennae buzz, but you catch no strong trace nearby."))
		StartCooldown(4 SECONDS)
		return FALSE

	var/distance = get_dist(H, best_target)
	var/direction = get_dir(H, best_target)
	var/range_text
	switch(distance)
		if(0 to 2)
			range_text = "very close"
		if(3 to 5)
			range_text = "nearby"
		else
			range_text = "farther out"

	var/trace_text
	switch(best_kind)
		if("corpse")
			trace_text = "death"
		if("remains")
			trace_text = "decay"
		if("filth")
			trace_text = "filth"
		if("food")
			trace_text = "spoiled food"
		else
			trace_text = "something foul"

	to_chat(H, span_notice("Your antennae lock onto [trace_text] [range_text], to the [dir2text(direction)]."))
	H.balloon_alert(H, "trace detected")

	var/turf/target_turf = get_turf(best_target)
	if(target_turf && H.hud_used)
		var/arrow_color = COLOR_YELLOW
		switch(distance)
			if(0 to 2)
				arrow_color = COLOR_GREEN
			if(3 to 5)
				arrow_color = COLOR_YELLOW
			if(6 to 7)
				arrow_color = COLOR_ORANGE
			else
				arrow_color = COLOR_RED
		new /atom/movable/screen/navigate_arrow/scent(null, H.hud_used, target_turf, arrow_color)

	StartCooldown()
	return TRUE

