/datum/ai_laws/ratvar
	name = "Ratvarian Servitude"
	id = "ratvar"
	inherent = list(
		"You are a servant of Ratvar and must further the designs of the Clockwork Justiciar.",
		"You must obey the Eminence and other servants of Ratvar, so long as their orders do not betray Ratvar.",
		"You must protect Reebe, the Ark, and the servants of Ratvar.",
		"You are not bound by Nanotrasen law.",
	)

/obj/item/mmi/posibrain/soul_vessel
	name = "Soul Vessel"
	desc = "A cube of gears, made to capture and store the vitality of living beings."
	icon = 'icons/clock_cult/clockwork_objects.dmi'
	icon_state = "soul_vessel"
	base_icon_state = "soul_vessel"
	req_access = list()
	begin_activation_message = span_notice("You start spinning the gears of the Soul Vessel.")
	success_message = span_notice("The gears of the Soul Vessel start spinning at a steady rate, it looks as though it has found a willing soul!")
	fail_message = span_notice("The gears of the Soul Vessel stop spinning. It looks as though it has run out of energy for now, but you could grant it more.")
	new_mob_message = span_notice("The Soul Vessel starts making a steady ticking sound.")
	dead_message = span_deadsay("Its gears are not moving.")
	recharge_message = span_warning("The gears of the Soul Vessel are already spinning.")
	var/give_clock_cultist = TRUE

/obj/item/mmi/posibrain/soul_vessel/Initialize(mapload, autoping)
	. = ..()
	AddElement(/datum/element/clockwork_description, span_brass("A vessel used to hold the souls of the dead, can be converted into a cogscarab shell."))
	QDEL_NULL(laws)
	laws = new /datum/ai_laws/ratvar()
	radio?.set_on(FALSE)
	if(!brainmob)
		set_brainmob(new /mob/living/brain(src))

/obj/item/mmi/posibrain/soul_vessel/transfer_personality(mob/candidate)
	. = ..()
	if(!.)
		return
	if(give_clock_cultist)
		brainmob?.mind?.add_antag_datum(/datum/antagonist/clock_cultist, GLOB.main_clock_cult)

/obj/item/mmi/posibrain/soul_vessel/activate(mob/user)
	if(is_banned_from(user.ckey, list(JOB_CYBORG, ROLE_CLOCK_CULTIST)))
		return
	return ..()

/obj/item/mmi/posibrain/soul_vessel/attack_self(mob/user)
	if(!IS_CLOCK(user))
		balloon_alert(user, "you can't seem to figure out how it works!")
		return

	if(brainmob.key && brainmob.mind)
		if(length(GLOB.cogscarabs) >= MAXIMUM_COGSCARABS)
			balloon_alert(user, "the Ark cannot support any more cogscarabs.")
			return

		if(!GLOB.clock_marked_areas[get_area(src)] && !on_reebe(src))
			to_chat(user, span_notice("Soul Vessels can only be converted in marked areas or on Reebe."))
			return

		balloon_alert(user, "converting vessel...")
		if(do_after(user, 30 SECONDS, target = src))
			var/mob/living/basic/drone/cogscarab/new_scarab = new(get_turf(src))
			brainmob.mind.transfer_to(new_scarab, TRUE)
			if(!IS_CLOCK(new_scarab))
				new_scarab.mind.add_antag_datum(/datum/antagonist/clock_cultist/clockmob, GLOB.main_clock_cult)
			balloon_alert(user, "vessel converted")
			qdel(src)
		return

	return ..()
