/obj/effect/mob_spawn/ghost_role/robot
	name = "Ghost Role Robot"
	prompt_name = "a robot"
	you_are_text = "You are a robot. This probably shouldn't be happening."
	flavour_text = "You are a robot. This probably shouldn't be happening."
	mob_type = /mob/living/silicon/robot

/obj/effect/mob_spawn/ghost_role/robot/ghostcafe
	name = "Cafe Robotic Storage"
	prompt_name = "a ghost cafe robot"
	infinite_use = TRUE
	deletes_on_zero_uses_left = FALSE
	icon = 'icons/ghostcafe/robot_storage.dmi'
	icon_state = "robostorage"
	anchored = TRUE
	density = FALSE
	spawner_job_path = /datum/job/ghostcafe
	you_are_text = "You are a Cafe Robot!"
	flavour_text = "Who could have thought? This awesome local cafe accepts cyborgs too!"
	mob_type = /mob/living/silicon/robot/model/roleplay
	loadout_enabled = TRUE
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE

/obj/effect/mob_spawn/ghost_role/robot/ghostcafe/special(mob/living/silicon/robot/spawned_robot, mob/mob_possessor, apply_prefs)
	. = ..()
	if(spawned_robot.client)
		spawned_robot.custom_name = null
		spawned_robot.updatename(spawned_robot.client)
		spawned_robot.transfer_silicon_prefs(spawned_robot.client)
		spawned_robot.gender = NEUTER
		var/area/A = get_area(src)
		//spawned_robot.AddElement(/datum/element/ghost_role_eligibility, free_ghosting = TRUE) SKYRAT PORT -- Needs to be completely rewritten
		spawned_robot.AddElement(/datum/element/dusts_on_catatonia)
		spawned_robot.AddElement(/datum/element/dusts_on_leaving_area, list(A.type) + GLOB.ghost_cafe_areas)
		spawned_robot.RegisterSignal(spawned_robot, COMSIG_MOVABLE_USING_RADIO, TYPE_PROC_REF(/mob/living, on_using_radio))
		ADD_TRAIT(spawned_robot, TRAIT_SIXTHSENSE, TRAIT_GHOSTROLE)
		ADD_TRAIT(spawned_robot, TRAIT_FREE_GHOST, TRAIT_GHOSTROLE)
		to_chat(spawned_robot,span_warning("<b>Ghosting is free!</b>"))
		var/datum/action/toggle_dead_chat_mob/D = new(spawned_robot)
		D.Grant(spawned_robot)

/obj/effect/mob_spawn/ghost_role/human/ghostcafe
	name = "Cafe Sleeper"
	prompt_name = "a ghost cafe human"
	infinite_use = TRUE
	deletes_on_zero_uses_left = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	density = FALSE
	spawner_job_path = /datum/job/ghostcafe
	outfit = /datum/outfit/ghostcafe
	you_are_text = "You are a Cafe Visitor!"
	flavour_text = "You are off-duty and have decided to visit your favourite cafe. Enjoy yourself."
	allow_custom_character = GHOSTROLE_TAKE_PREFS_APPEARANCE
	loadout_enabled = TRUE
	quirks_enabled = TRUE

/obj/effect/mob_spawn/ghost_role/human/ghostcafe/special(mob/living/spawned_human, mob/mob_possessor, apply_prefs)
	. = ..()
	if(spawned_human.client)
		var/area/A = get_area(src)
		spawned_human.AddElement(/datum/element/dusts_on_catatonia)
		spawned_human.AddElement(/datum/element/dusts_on_leaving_area, list(A.type) + GLOB.ghost_cafe_areas)
		spawned_human.RegisterSignal(spawned_human, COMSIG_MOVABLE_USING_RADIO, TYPE_PROC_REF(/mob/living, on_using_radio))
		ADD_TRAIT(spawned_human, TRAIT_SIXTHSENSE, TRAIT_GHOSTROLE)
		ADD_TRAIT(spawned_human, TRAIT_FREE_GHOST, TRAIT_GHOSTROLE)
		ADD_TRAIT(spawned_human, TRAIT_NOBREATH, TRAIT_GHOSTROLE)
		to_chat(spawned_human,span_warning("<b>Ghosting is free!</b>"))
		var/datum/action/toggle_dead_chat_mob/dchat_toggle_ability = new(spawned_human)
		dchat_toggle_ability.Grant(spawned_human)
		// HowlingVoid has no thirst system. Kept commented in case hydration supply is restored later.
		// var/datum/action/innate/ghostcafe_supply/hydration/hydration_toggle = new(spawned_human)
		// hydration_toggle.Grant(spawned_human)
		var/datum/action/innate/ghostcafe_supply/nutrition/nutrition_toggle = new(spawned_human)
		nutrition_toggle.Grant(spawned_human)
		var/datum/action/innate/ghostcafe_supply/blood/blood_toggle = new(spawned_human)
		blood_toggle.Grant(spawned_human)

/mob/living/proc/on_using_radio(atom/movable/talking_movable)
	SIGNAL_HANDLER

	var/area/target_area = get_area(talking_movable)
	if(target_area.type in GLOB.ghost_cafe_areas)
		return COMPONENT_CANNOT_USE_RADIO

/datum/outfit/ghostcafe
	name = "Cafe Visitor"
	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/sneakers/black
	id = /obj/item/card/id/advanced/chameleon/ghost_cafe
	back = /obj/item/storage/backpack/chameleon
	backpack_contents = list(/obj/item/storage/box/syndie_kit/chameleon/ghostcafe = 1)

/datum/outfit/ghostcafe/pre_equip(mob/living/carbon/human/visitor, visuals_only = FALSE)
	..()
	if (isplasmaman(visitor))
		backpack_contents += list(/obj/item/tank/internals/plasmaman/belt/full = 2)
	if(isvox(visitor) || isvoxprimalis(visitor))
		backpack_contents += list(/obj/item/tank/internals/nitrogen/belt/full = 2)

/datum/action/toggle_dead_chat_mob
	button_icon = 'icons/mob/simple/mob.dmi'
	button_icon_state = "ghost"
	name = "Toggle deadchat"
	desc = "Turn off or on your ability to hear ghosts."

/datum/action/toggle_dead_chat_mob/Trigger(trigger_flags)
	if(!..())
		return 0
	var/mob/M = target
	if(HAS_TRAIT_FROM(M,TRAIT_SIXTHSENSE,TRAIT_GHOSTROLE))
		REMOVE_TRAIT(M,TRAIT_SIXTHSENSE,TRAIT_GHOSTROLE)
		to_chat(M,span_notice("You're no longer hearing deadchat."))
	else
		ADD_TRAIT(M,TRAIT_SIXTHSENSE,TRAIT_GHOSTROLE)
		to_chat(M,span_notice("You're once again hearing deadchat."))

/datum/action/innate/ghostcafe_supply
	/// Status effect that this toggle will add or remove.
	var/datum/status_effect/supply_effect_type
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_LYING
	/// Use the default HUD background so we can leverage its active variant.
	background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND
	/// Keep the icon set consistent with the hunger/thirst HUD sprites.
	button_icon = 'icons/hud/screen_gen.dmi'
	/// Avoid noisy balloon alerts when the action is unavailable.
	transparent_when_unavailable = FALSE

/datum/action/innate/ghostcafe_supply/IsAvailable(feedback = FALSE)
	return ..(FALSE)

/datum/action/innate/ghostcafe_supply/is_action_active(atom/movable/screen/movable/action_button/current_button)
	if(!istype(owner, /mob/living))
		return FALSE
	return owner.has_status_effect(supply_effect_type)

/datum/action/innate/ghostcafe_supply/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	. = ..()
	if(is_action_active(button) && IsAvailable())
		button.color = COLOR_LIME

/datum/action/innate/ghostcafe_supply/Trigger(trigger_flags)
	if(!..())
		return FALSE
	if(!istype(owner, /mob/living))
		return FALSE
	var/mob/living/L = owner

	if(L.has_status_effect(supply_effect_type))
		L.remove_status_effect(supply_effect_type)
		to_chat(L, span_notice("Supply disabled."))
	else
		L.apply_status_effect(supply_effect_type)
		to_chat(L, span_notice("Supply enabled."))
	return TRUE

// HowlingVoid has no thirst system. Kept commented in case hydration supply is restored later.
// /datum/action/innate/ghostcafe_supply/hydration
// 	name = "Toggle Hydration Supply"
// 	desc = "Slowly refill your thirst while in the cafe."
// 	button_icon = 'icons/obj/drinks/mixed_drinks.dmi'
// 	button_icon_state = "singulo"
// 	supply_effect_type = /datum/status_effect/ghostcafe_supply/hydration

/datum/action/innate/ghostcafe_supply/nutrition
	name = "Toggle Nutrition Supply"
	desc = "Slowly refill your hunger while in the cafe."
	button_icon = 'icons/obj/food/burgerbread.dmi'
	button_icon_state = "superbiteburger"
	supply_effect_type = /datum/status_effect/ghostcafe_supply/nutrition

/datum/action/innate/ghostcafe_supply/blood
	name = "Toggle Blood Supply"
	desc = "Slowly refill your blood while in the cafe. Useful for hemophages!"
	button_icon = 'icons/obj/medical/bloodpack.dmi'
	button_icon_state = "bloodpack"
	supply_effect_type = /datum/status_effect/ghostcafe_supply/blood

/datum/status_effect/ghostcafe_supply
	id = "ghostcafe_supply_base"
	status_type = STATUS_EFFECT_UNIQUE
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 2 SECONDS
	processing_speed = STATUS_EFFECT_FAST_PROCESS
	/// We control alerts per child; default to no generic placeholder.
	alert_type = null

/datum/status_effect/ghostcafe_supply/on_apply()
	if(QDELETED(owner))
		return FALSE
	return TRUE

// HowlingVoid has no thirst system. Kept commented in case hydration supply is restored later.
// /datum/status_effect/ghostcafe_supply/hydration
// 	id = "ghostcafe_supply_hydration"
// 	/// Amount of hydration restored per second when active.
// 	var/hydration_per_second = 6
// 	alert_type = /atom/movable/screen/alert/status_effect/ghostcafe_supply/hydration

// /datum/status_effect/ghostcafe_supply/hydration/tick(seconds_between_ticks)
// 	if(QDELETED(owner) || owner.stat == DEAD)
// 		qdel(src)
// 		return
// 	if(!owner.can_replenish_thirst())
// 		return
// 	if(owner.water_level >= 600)
// 		return
// 	owner.adjust_thirst(hydration_per_second * seconds_between_ticks, 600)

/datum/status_effect/ghostcafe_supply/nutrition
	id = "ghostcafe_supply_nutrition"
	/// Amount of nutrition restored per second when active.
	var/nutrition_per_second = 4
	alert_type = /atom/movable/screen/alert/status_effect/ghostcafe_supply/nutrition

/datum/status_effect/ghostcafe_supply/nutrition/tick(seconds_between_ticks)
	if(QDELETED(owner) || owner.stat == DEAD)
		qdel(src)
		return
	var/target_nutrition = NUTRITION_LEVEL_FULL
	if(owner.nutrition >= target_nutrition)
		return
	var/amount = min(nutrition_per_second * seconds_between_ticks, target_nutrition - owner.nutrition)
	owner.adjust_nutrition(amount)

/datum/status_effect/ghostcafe_supply/blood
	id = "ghostcafe_supply_blood"
	/// Amount of blood restored per second when active.
	var/blood_per_second = 10
	alert_type = /atom/movable/screen/alert/status_effect/ghostcafe_supply/blood

/datum/status_effect/ghostcafe_supply/blood/on_apply()
	. = ..()
	if(!.)
		return
	update_blood_display()

/datum/status_effect/ghostcafe_supply/blood/tick(seconds_between_ticks)
	if(QDELETED(owner) || owner.stat == DEAD)
		qdel(src)
		return
	if(HAS_TRAIT(owner, TRAIT_NOBLOOD))
		return
	if(owner.blood_volume >= BLOOD_VOLUME_MAXIMUM)
		update_blood_display()
		return
	owner.blood_volume = min(owner.blood_volume + blood_per_second * seconds_between_ticks, BLOOD_VOLUME_MAXIMUM)
	update_blood_display()

/// Updates the blood level display on the alert icon
/datum/status_effect/ghostcafe_supply/blood/proc/update_blood_display()
	var/atom/movable/screen/alert/status_effect/ghostcafe_supply/blood/blood_alert = linked_alert
	if(!blood_alert)
		return
	var/blood_value = round(owner.blood_volume)
	blood_alert.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:10px; left:0px'><font face='Small Fonts' color='#ce0202'>[blood_value]</font></div>")

// Alerts for supply status effects
// HowlingVoid has no thirst system. Kept commented in case hydration supply is restored later.
// /atom/movable/screen/alert/status_effect/ghostcafe_supply/hydration
// 	name = "Hydration Supply"
// 	desc = "You feel your thirst saturated."
// 	icon = 'icons/obj/drinks/mixed_drinks.dmi'
// 	icon_state = "singulo"

/atom/movable/screen/alert/status_effect/ghostcafe_supply/nutrition
	name = "Nutrition Supply"
	desc = "You feel your hunger saturated."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "superbiteburger"

/atom/movable/screen/alert/status_effect/ghostcafe_supply/blood
	name = "Blood Supply"
	desc = "You feel your blood replenishing."
	icon = 'icons/obj/medical/bloodpack.dmi'
	icon_state = "bloodpack"
	maptext_width = 32
	maptext_height = 32

/obj/item/storage/box/syndie_kit/chameleon/ghostcafe
	name = "cafe costuming kit"
	desc = "Look just the way you did in life - or better!"
	icon_state = "ghostcostuming"
	storage_type = /datum/storage/chameleon_cafe

/datum/storage/chameleon_cafe
	max_specific_storage = WEIGHT_CLASS_HUGE // This is ghost cafe only, balance is not given a shit about.
	max_slots = 14 // Holds all the starting stuff, plus a bit of change.
	max_total_storage = 50 // To actually acommodate the stuff being added.

/obj/item/storage/box/syndie_kit/chameleon/ghostcafe/PopulateContents() // Doesn't contain a PDA, for isolation reasons.
	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/suit/chameleon(src)
	new /obj/item/clothing/gloves/chameleon(src)
	new /obj/item/clothing/shoes/chameleon(src)
	new /obj/item/clothing/glasses/chameleon(src)
	new /obj/item/clothing/head/chameleon(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/clothing/neck/chameleon(src)
	new /obj/item/storage/belt/chameleon(src)
	new /obj/item/hhmirror/syndie(src)

/obj/item/card/id/advanced/chameleon/ghost_cafe
	name = "\improper Cafe ID"
	desc = "A card used to provide ID and determine access across the Cafe."
	icon_state = "card_grey"
	assigned_icon_state = null
	registered_age = null
	trim = /datum/id_trim/admin/ghost_cafe
	wildcard_slots = WILDCARD_LIMIT_ADMIN

/datum/id_trim/admin/ghost_cafe
	assignment = "Cafe Visitor"
	trim_icon = 'icons/obj/card_additions.dmi'
	trim_state = "trim_cafe"
	department_color = COLOR_PALE_GREEN
	subdepartment_color = COLOR_PALE_GREEN
