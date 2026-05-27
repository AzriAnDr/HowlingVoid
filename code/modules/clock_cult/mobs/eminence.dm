/mob/living/eminence
	name = "Eminence"
	real_name = "Eminence"
	desc = "An entity bound to Ratvar, acting upon his will."
	icon = 'icons/clock_cult/clockwork_effects.dmi'
	icon_state = "eminence"
	mob_biotypes = MOB_SPIRIT
	mouse_opacity = MOUSE_OPACITY_ICON
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	see_invisible = SEE_INVISIBLE_LIVING
	density = FALSE
	move_force = INFINITY
	move_resist = INFINITY
	status_flags = NONE
	incorporeal_move = INCORPOREAL_MOVE_BASIC
	initial_language_holder = /datum/language_holder/universal
	hud_possible = list(ANTAG_HUD)
	lighting_cutoff_red = 35
	lighting_cutoff_green = 20
	lighting_cutoff_blue = 0
	var/obj/item/radio/internal_radio
	var/cogs = 0
	var/datum/weakref/marked_servant
	COOLDOWN_DECLARE(command_sound_cooldown)

/mob/living/eminence/Initialize(mapload)
	. = ..()
	if(!GLOB.current_eminence)
		GLOB.current_eminence = src
	internal_radio = new /obj/item/radio/intercom/reebe(src)
	internal_radio.should_be_listening = TRUE
	internal_radio.should_be_broadcasting = FALSE
	cogs = GLOB.clock_installed_cogs
	add_traits(list(TRAIT_GODMODE, TRAIT_BLOCK_SHUTTLE_MOVEMENT), INNATE_TRAIT)
	grant_all_languages()

/mob/living/eminence/Destroy()
	if(GLOB.current_eminence == src)
		GLOB.current_eminence = null
	QDEL_NULL(internal_radio)
	return ..()

/mob/living/eminence/ClickOn(atom/clicked_on, params)
	. = ..()
	clicked_on.eminence_act(src)

/mob/living/eminence/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof, message_range, datum/saymode/saymode, list/message_mods = list())
	if(!message || stat)
		return

	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, span_boldwarning("You cannot send IC messages (muted)."))
			return
		if(!(ignore_spam || forced) && client.handle_spam_prevention(message, MUTE_IC))
			return

	send_clock_message(src, message, "<span class='big_brass'>")
	COOLDOWN_START(src, command_sound_cooldown, 40 SECONDS)

/mob/living/eminence/get_status_tab_items()
	. = ..()
	. += "Cogs: [cogs]"

/mob/living/eminence/start_pulling(atom/movable/AM, state, force, supress_message)
	return

/mob/living/eminence/canUseStorage()
	return FALSE

/mob/living/eminence/ignite_mob(silent)
	return

/mob/living/eminence/fire_act()
	return

/mob/living/eminence/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	return FALSE

/mob/living/eminence/dust(just_ash, drop_items, give_moodlet, force)
	if(!force)
		return FALSE
	return ..()

/mob/living/eminence/gib(no_brain, no_organs, no_bodyparts, safe_gib = TRUE)
	return

/atom/proc/eminence_act(mob/living/eminence/user)
	return

/mob/living/eminence_act(mob/living/eminence/user)
	. = ..()
	if(user != src && IS_CLOCK(src))
		user.marked_servant = WEAKREF(src)
		to_chat(user, span_brass("You mark [src]."))

/obj/structure/closet/eminence_act(mob/living/eminence/user)
	. = ..()
	if(do_after(user, 5 SECONDS, src))
		open(user, TRUE)

/obj/machinery/door/airlock/eminence_act(mob/living/eminence/user)
	. = ..()
	if(!do_after(user, 5 SECONDS, src))
		return
	if(locked || welded || !density)
		return
	open(BYPASS_DOOR_CHECKS)

/obj/machinery/door/window/eminence_act(mob/living/eminence/user)
	. = ..()
	if(hasPower())
		open(BYPASS_DOOR_CHECKS)

/obj/machinery/light/eminence_act(mob/living/eminence/user)
	. = ..()
	break_light_tube()
