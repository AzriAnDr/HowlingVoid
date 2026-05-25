/obj/structure/destructible/clockwork/eminence_beacon
	name = "Eminence Spire"
	desc = "An ancient brass spire that holds the spirit of a powerful entity conceived by Ratvar to oversee his servants."
	icon_state = "tinkerers_daemon"
	clockwork_desc = "Allows the servants to awaken the Eminence, either by electing one of their own or calling a ghost."
	resistance_flags = INDESTRUCTIBLE
	var/vote_active = FALSE
	var/vote_timer
	var/polling = FALSE

/obj/structure/destructible/clockwork/eminence_beacon/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!IS_CLOCK(user))
		return

	if(vote_active)
		if(vote_timer)
			deltimer(vote_timer)
			vote_timer = null
		vote_active = FALSE
		send_clock_message(null, "[user] has cancelled the Eminence vote.", msg_ghosts = FALSE)
		return

	if(GLOB.current_eminence)
		to_chat(user, span_brass("The Eminence has already been released."))
		return

	var/option = tgui_alert(user, "Becoming the Eminence destroys your old form. Who shall control the Eminence?", "Who shall control the Eminence?", list("Yourself", "A ghost", "Cancel"))
	if(vote_active || option == "Cancel")
		return

	if(option == "Yourself")
		send_clock_message(null, span_bigbrass("[user] has elected themselves to become the Eminence. Interact with \the [src] to object."), msg_ghosts = FALSE)
		vote_timer = addtimer(CALLBACK(src, PROC_REF(vote_succeed), user), 60 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)
	else if(option == "A ghost")
		send_clock_message(null, span_bigbrass("[user] has elected for a ghost to become the Eminence. Interact with \the [src] to object."), msg_ghosts = FALSE)
		vote_timer = addtimer(CALLBACK(src, PROC_REF(vote_succeed)), 60 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)

	vote_active = TRUE

/obj/structure/destructible/clockwork/eminence_beacon/proc/vote_succeed(mob/living/chosen_eminence)
	vote_active = FALSE
	vote_timer = null
	if(polling)
		return

	if(GLOB.current_eminence)
		message_admins("[type] tried to create an Eminence while one already exists.")
		return

	polling = TRUE
	if(!chosen_eminence)
		var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
			"Do you want to play as the Eminence?",
			check_jobban = ROLE_CLOCK_CULTIST,
			role = ROLE_CLOCK_CULTIST,
			poll_time = 10 SECONDS,
			alert_pic = /mob/living/eminence,
			role_name_text = "Eminence",
		)
		if(length(candidates))
			chosen_eminence = pick(candidates)
	polling = FALSE

	if(!chosen_eminence?.client)
		send_clock_message(null, "The Eminence remains in slumber, for now. Try waking it again soon.", msg_ghosts = FALSE)
		return

	var/mob/living/eminence/new_mob = new(get_turf(src))
	if(isobserver(chosen_eminence))
		new_mob.PossessByPlayer(chosen_eminence.key)
		new_mob.mind_initialize()
	else
		var/datum/antagonist/clock_cultist/servant_datum = chosen_eminence.mind?.has_antag_datum(/datum/antagonist/clock_cultist)
		if(servant_datum)
			servant_datum.silent = TRUE
			servant_datum.on_removal()
		chosen_eminence.mind.transfer_to(new_mob, TRUE)
		chosen_eminence.dust(TRUE, TRUE, TRUE)

	new_mob.mind.add_antag_datum(/datum/antagonist/clock_cultist/eminence, GLOB.main_clock_cult)
	send_clock_message(null, span_bigbrass("The Eminence has risen!"), msg_ghosts = FALSE)
