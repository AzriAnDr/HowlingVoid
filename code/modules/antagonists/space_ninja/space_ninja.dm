/datum/antagonist/ninja
	name = "\improper Space Ninja"
	antagpanel_category = ANTAG_GROUP_NINJAS
	pref_flag = ROLE_NINJA
	antag_hud_name = "ninja"
	hijack_speed = 1
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused
	suicide_cry = "FOR THE SPIDER CLAN!!"
	preview_outfit = /datum/outfit/ninja_preview
	can_assign_self_objectives = TRUE
	ui_name = "AntagInfoNinja"
	default_custom_objective = "Destroy vital station infrastructure, without being seen."
	desensitized_modifier = DESENSITIZED_THRESHOLD
	/// Whether or not this ninja will obtain objectives.
	var/give_objectives = TRUE

/**
 * Proc that equips the space ninja outfit on a given individual. By default this is the owner of the antagonist datum.
 *
 * Arguments:
 * * ninja - The human to receive the gear.
 * * Returns a proc call on the given human which will equip them with all the gear.
 */
/datum/antagonist/ninja/proc/equip_space_ninja(mob/living/carbon/human/ninja = owner.current)
	return ninja.equip_species_outfit(/datum/outfit/ninja)

/**
 * Proc that adds the ninja starting memories to the owner of the antagonist datum.
 */
/datum/antagonist/ninja/proc/addMemories()
	antag_memory += "I am an elite operative executing a co-ordinated strike for the benefit of Cybersun Industries."
	antag_memory += "Precision is my weapon. Shadows are my armor. Without them, I am nothing."

/datum/objective/cyborg_hijack
	explanation_text = "(Optional) Use your gloves to convert a cyborg to aid you."

/datum/objective/assassinate/headhunter
	name = "head-hunter"

/datum/objective/assassinate/headhunter/check_completion()
	if(completed)
		return TRUE
	if(!considered_alive(target) || considered_afk(target))
		return TRUE
	return FALSE

/// Handled by COMSIG_CARBON_GAIN_WOUND to check if wounds applied to the target are objective completing.
/datum/objective/assassinate/headhunter/proc/check_wound(datum/source, datum/wound/wound, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/human = source
	if(!istype(human))
		return
	if(!istype(wound, /datum/wound/cranial_fissure) || !istype(limb, /obj/item/bodypart/head))
		return

	UnregisterSignal(human, COMSIG_CARBON_GAIN_WOUND)
	wound.remove_wound_from_victim()
	limb.dismember(BRUTE, FALSE, WOUND_SLASH)
	completed = TRUE

/datum/objective/assassinate/headhunter/update_explanation_text()
	. = ..()
	if(target?.current)
		explanation_text = "Assassinate the [target.assigned_role.title], [target.name]; by dismembering [target.current.p_their()] head with your katana."
	else
		explanation_text = "Objective revoked."

/// Find a valid command member to target.
/datum/objective/assassinate/headhunter/find_target(dupe_search_range, list/blacklist)
	var/list/possible_targets = list()
	var/list/existing_targets = list()

	for(var/datum/objective/assassinate/headhunter/objective in owner.objectives)
		existing_targets |= objective.target

	for(var/mob/living/possible_target in get_active_player_list(TRUE, TRUE, TRUE))
		if(possible_target.mind in existing_targets)
			continue
		if(!is_valid_target(possible_target.mind))
			continue
		possible_targets += possible_target.mind

	target = pick(possible_targets)
	RegisterSignal(target.current, COMSIG_CARBON_GAIN_WOUND, PROC_REF(check_wound))
	update_explanation_text()
	return target

/datum/objective/assassinate/headhunter/is_valid_target(datum/mind/possible_target)
	var/target_in_command_dept = FALSE
	if(!possible_target)
		return FALSE
	for(var/department in possible_target.assigned_role.departments_list)
		if(department == /datum/job_department/central_command)
			return FALSE
		if(department == /datum/job_department/command)
			target_in_command_dept = TRUE
			break
	if(!target_in_command_dept)
		return FALSE
	return ..()

/datum/objective/door_jack
	/// How many doors that need to be opened using the gloves to pass the objective.
	var/doors_required = 0

/datum/objective/plant_explosive
	var/area/detonation_location

/datum/objective/security_scramble
	explanation_text = "Use your gloves on a security console to set everyone to arrest at least once.  Note that the AI will be alerted once you begin!"

/datum/objective/terror_message
	explanation_text = "Use your gloves on a communication console in order to bring another threat to the station.  Note that the AI will be alerted once you begin!"

/datum/objective/research_secrets
	explanation_text = "Use your gloves on a research & development server to sabotage research efforts.  Note that the AI will be alerted once you begin!"

/**
 * Proc that adds all the ninja's objectives to the antag datum. Called when the datum is gained.
 */
/datum/antagonist/ninja/proc/addObjectives()
	var/list/command_targets = list()
	for(var/mob/living/crew as anything in get_active_player_list(TRUE, TRUE, TRUE))
		if(/datum/job_department/central_command in crew.mind?.assigned_role.departments_list)
			continue
		if(/datum/job_department/command in crew.mind?.assigned_role.departments_list)
			command_targets |= crew.mind

	if(length(command_targets) >= 3)
		var/lethality = rand(1, 3)
		for(var/i in 1 to lethality)
			var/datum/objective/assassinate/headhunter/strike_fear = new()
			strike_fear.owner = owner
			strike_fear.find_target()
			objectives += strike_fear

		var/datum/objective/cyborg_hijack/hijack = new()
		objectives += hijack
	else
		var/datum/objective/research_secrets/sabotage_research = new()
		objectives += sabotage_research

	// Survival until end.
	var/datum/objective/survival = new /datum/objective/survive()
	survival.owner = owner
	objectives += survival

/datum/antagonist/ninja/roundend_report()
	var/list/report = list()
	if(!owner)
		CRASH("Antagonist datum without owner")
	report += printplayer(owner)

	var/objectives_complete = TRUE
	if(length(objectives))
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(istype(objective, /datum/objective/cyborg_hijack))
				continue
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	if(!length(objectives) || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful at spreading fear among NT!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed the Cybersun!</span>"
	return report.Join("<br>")

/datum/antagonist/ninja/greet()
	SEND_SOUND(owner.current, sound('sound/music/antag/ninja_greeting.ogg'))
	to_chat(owner.current, span_danger("I am an elite operative executing a co-ordinated strike for the benefit of Cybersun Industries."))
	to_chat(owner.current, span_warning("Precision is my weapon. Shadows are my armor. Without them, I am nothing."))
	to_chat(owner.current, span_notice("The station is located to your [dir2text(get_dir(owner.current, locate(world.maxx/2, world.maxy/2, owner.current.z)))]. A thrown ninja star will be a great way to get there."))
	owner.announce_objectives()

/datum/antagonist/ninja/on_gain()
	if(give_objectives)
		addObjectives()
	addMemories()
	equip_space_ninja(owner.current)
	owner.current.add_quirk(/datum/quirk/freerunning, announce = FALSE)
	owner.current.add_quirk(/datum/quirk/light_step, announce = FALSE)
	owner.current.mind.set_assigned_role(SSjob.get_job_type(/datum/job/space_ninja))
	return ..()

/datum/antagonist/ninja/admin_add(datum/mind/new_owner, mob/admin)
	new_owner.set_assigned_role(SSjob.get_job_type(/datum/job/space_ninja))
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has ninja'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has ninja'ed [key_name(new_owner)].")

/datum/antagonist/ninja/on_respawn(mob/new_character)
	equip_space_ninja()
	var/turf/spawnpoint = find_space_spawn()
	if(spawnpoint)
		new_character.forceMove(spawnpoint)
	return TRUE
