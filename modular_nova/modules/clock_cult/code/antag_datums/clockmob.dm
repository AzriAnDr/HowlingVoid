/datum/antagonist/clock_cultist/clockmob
	name = "Cogscarab"
	show_in_antagpanel = FALSE
	give_slab = FALSE
	can_convert = FALSE
	var/datum/action/cooldown/clock_cult/clockmob_warp/warp = new

/datum/antagonist/clock_cultist/clockmob/Destroy()
	QDEL_NULL(warp)
	return ..()

/datum/antagonist/clock_cultist/clockmob/greet()
	to_chat(owner.current, boxed_message("[span_bigbrass("You are a Cogscarab, a small construct of Ratvar.")]<br>[span_brass("Build, repair, and defend Reebe and the servants of the Engine.")]"))

/datum/antagonist/clock_cultist/clockmob/apply_innate_effects(mob/living/mob_override)
	. = ..()
	warp.Grant(owner.current)

/datum/antagonist/clock_cultist/clockmob/remove_innate_effects(mob/living/mob_override)
	. = ..()
	warp.Remove(owner.current)
