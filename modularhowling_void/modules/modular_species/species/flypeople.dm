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
