/datum/action/cooldown/alien/hide
	name = "Hide"
	desc = "Allows you to hide beneath tables and certain objects."
	button_icon_state = "alien_hide"
	plasma_cost = 0
	/// The layer we are on while hiding
	var/hide_layer = ABOVE_NORMAL_TURF_LAYER

/datum/action/cooldown/alien/hide/Activate(atom/target)
	if(owner.layer == hide_layer)
		owner.layer = initial(owner.layer)
		owner.visible_message(
			span_notice("[owner] slowly peeks up from the ground..."),
			span_noticealien("You stop hiding."),
		)
		ADD_TRAIT(owner, TRAIT_IGNORE_ELEVATION, ACTION_TRAIT)

	else
		owner.layer = hide_layer
		owner.visible_message(
			span_name("[owner] scurries to the ground!"),
			span_noticealien("You are now hiding."),
		)
		REMOVE_TRAIT(owner, TRAIT_IGNORE_ELEVATION, ACTION_TRAIT)

	return TRUE

/datum/action/cooldown/alien/larva_evolve
	name = "Evolve"
	desc = "Evolve into a higher alien caste."
	button_icon_state = "alien_evolve_larva"
	plasma_cost = 0

/datum/action/cooldown/alien/larva_evolve/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!islarva(owner))
		return FALSE

	var/mob/living/carbon/alien/larva/larva = owner
	if(larva.handcuffed || larva.legcuffed) // Cuffing larvas ? Eh ?
		return FALSE
	if(larva.amount_grown < larva.max_grown)
		return FALSE
	if(larva.movement_type & VENTCRAWLING)
		return FALSE

	return TRUE

/datum/action/cooldown/alien/larva_evolve/Activate(atom/target)
	var/mob/living/carbon/alien/larva/larva = owner
	var/static/list/caste_options
	if(!caste_options)
		caste_options = list()

		// This can probably be genericized in the future.
		var/mob/runner_path = /mob/living/carbon/alien/adult/tgmc/runner
		var/datum/radial_menu_choice/runner = new()
		runner.name = "Runner"
		runner.image  = image(icon = initial(runner_path.icon), icon_state = initial(runner_path.icon_state))
		runner.info = span_info("Runners are the most agile caste, with great speed, projectile evasion, and a path toward ravager.")

		caste_options["Runner"] = runner

		var/mob/sentinel_path = /mob/living/carbon/alien/adult/tgmc/sentinel
		var/datum/radial_menu_choice/sentinel = new()
		sentinel.name = "Sentinel"
		sentinel.image  = image(icon = initial(sentinel_path.icon), icon_state = initial(sentinel_path.icon_state))
		sentinel.info = span_info("Sentinels are ranged hive defenders that can later evolve into spitters.")

		caste_options["Sentinel"] = sentinel

		var/mob/defender_path = /mob/living/carbon/alien/adult/tgmc/defender
		var/datum/radial_menu_choice/defender = new()
		defender.name = "Defender"
		defender.image  = image(icon = initial(defender_path.icon), icon_state = initial(defender_path.icon_state))
		defender.info = span_info("Defenders are slow, tough frontliners that can later evolve into crushers.")

		caste_options["Defender"] = defender

		var/mob/drone_path = /mob/living/carbon/alien/adult/tgmc/drone
		var/datum/radial_menu_choice/drone = new()
		drone.name = "Drone"
		drone.image  = image(icon = initial(drone_path.icon), icon_state = initial(drone_path.icon_state))
		drone.info = span_info("Drones are support xenomorphs that maintain the hive and can later evolve toward praetorian or queen.")

		caste_options["Drone"] = drone

	var/alien_caste = show_radial_menu(owner, owner, caste_options, radius = 38, require_near = TRUE, tooltips = TRUE)
	if(QDELETED(src) || QDELETED(owner) || !IsAvailable(feedback = TRUE) || isnull(alien_caste))
		return

	var/mob/living/carbon/alien/adult/tgmc/new_xeno
	switch(alien_caste)
		if("Runner")
			new_xeno = new /mob/living/carbon/alien/adult/tgmc/runner(larva.loc)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/adult/tgmc/sentinel(larva.loc)
		if("Defender")
			new_xeno = new /mob/living/carbon/alien/adult/tgmc/defender(larva.loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/adult/tgmc/drone(larva.loc)
		else
			CRASH("Alien evolve was given an invalid / incorrect alien cast type. Got: [alien_caste]")

	larva.alien_evolve(new_xeno)
	return TRUE
