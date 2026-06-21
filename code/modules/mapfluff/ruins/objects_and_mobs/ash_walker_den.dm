#define ASH_WALKER_SPAWN_THRESHOLD 2
#define MEGAFAUNA_MEAT_AMOUNT 20
//The ash walker den consumes corpses or unconscious mobs to create ash walker eggs. For more info on those, check ghost_role_spawners.dm
/obj/structure/lavaland/ash_walker
	name = "necropolis tendril nest"
	desc = "A vile tendril of corruption. It's surrounded by a nest of rapidly growing eggs..."
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	icon_state = "ash_walker_nest"

	move_resist=INFINITY // just killing it tears a massive hole in the ground, let's not move it
	anchored = TRUE
	density = TRUE

	resistance_flags = FIRE_PROOF | LAVA_PROOF
	max_integrity = 200

	faction = list(FACTION_ASHWALKER)

	var/meat_counter = 6
	var/datum/team/ashwalkers/ashies
	var/datum/linked_objective

/obj/structure/lavaland/ash_walker/Initialize(mapload)
	.=..()
	ashies = new /datum/team/ashwalkers()
	var/datum/objective/protect_object/objective = new
	objective.set_target(src)
	objective.team = ashies
	linked_objective = objective
	ashies.objectives += objective
	START_PROCESSING(SSprocessing, src)

/obj/structure/lavaland/ash_walker/Destroy()
	ashies = null
	linked_objective = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/lavaland/ash_walker/atom_deconstruct(disassembled)
	var/core_to_drop = pick(subtypesof(/obj/item/assembly/signaler/anomaly))
	new core_to_drop (get_step(loc, pick(GLOB.alldirs)))
	new /obj/effect/collapse(loc)

/obj/structure/lavaland/ash_walker/process()
	consume()
	spawn_mob()

/obj/structure/lavaland/ash_walker/proc/consume()
	for(var/mob/living/offered_mob in view(src, 1)) //Only for corpses right next to/on the same tile.
		if(!offered_mob.stat)
			continue

		offered_mob.unequip_everything()

		if(issilicon(offered_mob)) //No advantage to sacrificing borgs.
			offered_mob.investigate_log("has been gibbed via ashwalker sacrifice as a borg.", INVESTIGATE_DEATHS)
			offered_mob.gib()
			return

		if(offered_mob.mind?.has_antag_datum(/datum/antagonist/ashwalker) && (offered_mob.ckey || offered_mob.get_ghost(FALSE, TRUE))) //Special interactions for dead lava lizards with ghosts attached.
			revive_ashwalker(offered_mob)
			return

		if(ismegafauna(offered_mob))
			meat_counter += MEGAFAUNA_MEAT_AMOUNT
		else
			meat_counter++

		playsound(get_turf(src), 'sound/effects/magic/demon_consume.ogg', 100, TRUE)
		var/delivery_key = offered_mob.fingerprintslast
		var/mob/living/delivery_mob = get_mob_by_key(delivery_key)

		if(delivery_mob && delivery_mob.mind?.has_antag_datum(/datum/antagonist/ashwalker) && (delivery_key in ashies.players_spawned) && prob(40))
			to_chat(delivery_mob, span_boldwarning("The Necropolis is pleased with your sacrifice. You feel confident your existence after death is secure."))
			ashies.players_spawned -= delivery_key

		offered_mob.investigate_log("has been gibbed via ashwalker sacrifice.", INVESTIGATE_DEATHS)
		offered_mob.gib()
		atom_integrity = min(atom_integrity + max_integrity * 0.05, max_integrity)

		for(var/mob/living/living_observer in view(src, 5))
			if(living_observer.mind?.has_antag_datum(/datum/antagonist/ashwalker))
				living_observer.add_mood_event("oogabooga", /datum/mood_event/sacrifice_good)
			else
				living_observer.add_mood_event("oogabooga", /datum/mood_event/sacrifice_bad)

		ashies.sacrifices_made++

/obj/structure/lavaland/ash_walker/proc/remake_walker(mob/living/carbon/oldmob)
	var/mob/living/carbon/human/newwalker = new /mob/living/carbon/human(get_step(loc, pick(GLOB.alldirs)))
	newwalker.set_species(/datum/species/lizard/ashwalker)
	newwalker.real_name = oldmob.real_name
	newwalker.undershirt = "Nude"
	newwalker.underwear = "Nude"
	newwalker.update_body()
	newwalker.remove_language(/datum/language/common)
	oldmob.mind.transfer_to(newwalker)
	newwalker.mind.grab_ghost()
	to_chat(newwalker, "<b>You have been pulled back from beyond the grave, with a new body and renewed purpose. Glory to the Necropolis!</b>")
	playsound(get_turf(newwalker),'sound/effects/magic/exit_blood.ogg', 100, TRUE)
	qdel(oldmob)

/obj/structure/lavaland/ash_walker/proc/spawn_mob()
	if(meat_counter >= ASH_WALKER_SPAWN_THRESHOLD)
		new /obj/effect/mob_spawn/ghost_role/human/ash_walker(get_step(loc, pick(GLOB.alldirs)), ashies)
		visible_message(span_danger("One of the eggs swells to an unnatural size and tumbles free. It's ready to hatch!"))
		meat_counter -= ASH_WALKER_SPAWN_THRESHOLD
		ashies.eggs_created++

/obj/structure/lavaland/ash_walker_fake
	name = "necropolis tendril nest"
	desc = "A vile tendril of corruption. It's surrounded by a nest of rapidly growing eggs..."
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	icon_state = "ash_walker_nest"
	move_resist = INFINITY
	anchored = TRUE
	resistance_flags = FIRE_PROOF | LAVA_PROOF
	max_integrity = 200

#undef ASH_WALKER_SPAWN_THRESHOLD
#undef MEGAFAUNA_MEAT_AMOUNT
