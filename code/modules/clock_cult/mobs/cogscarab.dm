#define CLOCK_DRONE_MAX_ITEM_FORCE 15

/mob/living/basic/drone/cogscarab
	name = "Cogscarab"
	desc = "A mechanical device filled with twisting cogs and brass parts, built to maintain Reebe."
	icon_state = "drone_clock"
	icon_living = "drone_clock"
	icon_dead = "drone_clock_dead"
	health = 35
	maxHealth = 35
	speed = 1
	faction = list(FACTION_NEUTRAL, FACTION_SILICON, FACTION_TURRET, FACTION_CLOCK)
	default_storage = /obj/item/storage/belt/utility/clock
	visualAppearance = CLOCKDRONE
	bubble_icon = "clock"
	picked = TRUE
	flavortext = span_brass("You are a cogscarab, an intricate machine granted sentience by Ratvar. Build defenses, repair Reebe, and support the servants.")
	laws = "You have been granted the gift of sentience by Ratvar. You are not bound by station law; serve Ratvar."
	initial_language_holder = /datum/language_holder/clockmob
	shy = FALSE
	pass_flags = PASSTABLE | PASSMOB

/mob/living/basic/drone/cogscarab/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NOGUNS, "cogscarab")
	GLOB.cogscarabs += src

/mob/living/basic/drone/cogscarab/death(gibbed)
	GLOB.cogscarabs -= src
	return ..()

/mob/living/basic/drone/cogscarab/Destroy()
	GLOB.cogscarabs -= src
	return ..()

/mob/living/basic/drone/cogscarab/transferItemToLoc(obj/item/item, newloc, force, silent, animated)
	return (force || (item.force <= CLOCK_DRONE_MAX_ITEM_FORCE)) && ..()

/obj/effect/mob_spawn/ghost_role/drone/cogscarab
	name = "cogscarab construct"
	desc = "The shell of an ancient construction drone, loyal to Ratvar."
	icon = 'icons/clock_cult/clockwork_objects.dmi'
	icon_state = "cogscarab_shell"
	mob_name = "cogscarab"
	mob_type = /mob/living/basic/drone/cogscarab
	role_ban = ROLE_CLOCK_CULTIST
	prompt_name = "a cogscarab"
	you_are_text = "You are a Cogscarab!"
	flavour_text = "You are a tiny building construct of Ratvar. Use your tools to construct and maintain defenses for the servants."

/obj/effect/mob_spawn/ghost_role/drone/cogscarab/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clockwork_description, "Cogscarabs can gain a soul in marked areas or on Reebe.")

/obj/effect/mob_spawn/ghost_role/drone/cogscarab/special(mob/living/spawned_mob, mob/mob_possessor)
	. = ..()
	spawned_mob.mind.add_antag_datum(/datum/antagonist/clock_cultist/clockmob, GLOB.main_clock_cult)
	LAZYADD(spawned_mob.mind.special_roles, ROLE_CLOCK_CULTIST)

/obj/effect/mob_spawn/ghost_role/drone/cogscarab/allow_spawn(mob/user, silent)
	if(length(GLOB.cogscarabs) >= MAXIMUM_COGSCARABS)
		to_chat(user, span_notice("The Ark cannot support any more cogscarabs."))
		return FALSE

	var/area/current_area = get_area(src)
	if(!GLOB.clock_marked_areas[current_area] && !istype(current_area, /area/ruin/powered/reebe))
		to_chat(user, span_notice("Cogscarabs can only awaken in marked areas or on Reebe."))
		return FALSE

	return TRUE

#undef CLOCK_DRONE_MAX_ITEM_FORCE
