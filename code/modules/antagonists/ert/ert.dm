//Both ERT and DS are handled by the same datums since they mostly differ in equipment in objective.
/datum/team/ert
	name = "Emergency Response Team"
	var/datum/objective/mission //main mission

/datum/antagonist/ert
	name = "Emergency Response Officer"
	can_elimination_hijack = ELIMINATION_PREVENT
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused
	antagpanel_category = ANTAG_GROUP_ERT
	suicide_cry = "FOR NANOTRASEN!!"
	// Not 'true' antags, this disables certain interactions that assume the owner is a baddie
	antag_flags = ANTAG_FAKE|ANTAG_SKIP_GLOBAL_LIST
	desensitized_modifier = DESENSITIZED_THRESHOLD * 0.5
	var/datum/team/ert/ert_team
	var/leader = FALSE
	var/datum/outfit/outfit = /datum/outfit/centcom/ert/security
	var/datum/outfit/plasmaman_outfit = /datum/outfit/plasmaman/centcom_official
	var/role = "Security Officer"
	var/list/name_source
	var/random_names = TRUE
	var/rip_and_tear = FALSE
	var/equip_ert = TRUE
	var/forge_objectives_for_ert = TRUE
	/// Typepath indicating the kind of job datum this ert member will have.
	var/ert_job_path = /datum/job/ert_generic


/datum/antagonist/ert/on_gain()
	if(random_names)
		update_name()
	if(forge_objectives_for_ert)
		forge_objectives()
	if(equip_ert)
		equipERT()
	owner?.current.add_faction(FACTION_ERT) // NOVA EDIT ADDITION
	. = ..()

/datum/antagonist/ert/get_team()
	return ert_team

/datum/antagonist/ert/New()
	. = ..()
	name_source = GLOB.last_names

/datum/antagonist/ert/proc/update_name()
	owner.current.fully_replace_character_name(owner.current.real_name,"[role] [pick(name_source)]")

/datum/antagonist/ert/official
	name = "CentCom Official"
	show_name_in_check_antagonists = TRUE
	var/datum/objective/mission
	role = "Inspector"
	random_names = FALSE
	outfit = /datum/outfit/centcom/centcom_official

/datum/antagonist/ert/official/greet()
	. = ..()
	if (ert_team)
		to_chat(owner, "<span class='warningplain'>Central Command is sending you to [station_name()] with the task: [ert_team.mission.explanation_text]</span>")
	else
		to_chat(owner, "<span class='warningplain'>Central Command is sending you to [station_name()] with the task: [mission.explanation_text]</span>")

/datum/antagonist/ert/official/forge_objectives()
	if (ert_team)
		return ..()
	if(mission)
		return
	var/datum/objective/missionobj = new ()
	missionobj.owner = owner
	missionobj.explanation_text = "Conduct a routine performance review of [station_name()] and its Captain."
	missionobj.completed = TRUE
	mission = missionobj
	objectives |= mission

/datum/antagonist/ert/security // kinda handled by the base template but here for completion

/datum/antagonist/ert/security/red
	outfit = /datum/outfit/centcom/ert/security/alert

/datum/antagonist/ert/engineer
	role = "Engineer"
	outfit = /datum/outfit/centcom/ert/engineer

/datum/antagonist/ert/engineer/red
	outfit = /datum/outfit/centcom/ert/engineer/alert

/datum/antagonist/ert/medic
	role = "Medical Officer"
	outfit = /datum/outfit/centcom/ert/medic

/datum/antagonist/ert/medic/red
	outfit = /datum/outfit/centcom/ert/medic/alert

/datum/antagonist/ert/commander
	role = "Commander"
	outfit = /datum/outfit/centcom/ert/commander
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_commander

/datum/antagonist/ert/commander/red
	outfit = /datum/outfit/centcom/ert/commander/alert

/datum/antagonist/ert/janitor
	role = "Janitor"
	outfit = /datum/outfit/centcom/ert/janitor

/datum/antagonist/ert/janitor/heavy
	role = "Heavy Duty Janitor"
	outfit = /datum/outfit/centcom/ert/janitor/heavy

/datum/antagonist/ert/deathsquad
	name = "Deathsquad Trooper"
	outfit = /datum/outfit/centcom/death_commando
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_commander
	role = "Trooper"
	rip_and_tear = TRUE

/datum/antagonist/ert/deathsquad/New()
	. = ..()
	name_source = GLOB.commando_names

/datum/antagonist/ert/deathsquad/leader
	name = "Deathsquad Officer"
	outfit = /datum/outfit/centcom/death_commando/officer
	role = "Officer"

/datum/antagonist/ert/medic/inquisitor
	outfit = /datum/outfit/centcom/ert/medic/inquisitor

/datum/antagonist/ert/medic/inquisitor/on_gain()
	. = ..()
	owner.set_holy_role(HOLY_ROLE_PRIEST)

/datum/antagonist/ert/security/inquisitor
	outfit = /datum/outfit/centcom/ert/security/inquisitor

/datum/antagonist/ert/security/inquisitor/on_gain()
	. = ..()
	owner.set_holy_role(HOLY_ROLE_PRIEST)

/datum/antagonist/ert/chaplain
	role = "Chaplain"
	outfit = /datum/outfit/centcom/ert/chaplain

/datum/antagonist/ert/chaplain/inquisitor
	outfit = /datum/outfit/centcom/ert/chaplain/inquisitor

/datum/antagonist/ert/chaplain/on_gain()
	. = ..()
	owner.set_holy_role(HOLY_ROLE_PRIEST)

/datum/antagonist/ert/commander/inquisitor
	outfit = /datum/outfit/centcom/ert/commander/inquisitor

/datum/antagonist/ert/commander/inquisitor/on_gain()
	. = ..()
	owner.set_holy_role(HOLY_ROLE_PRIEST)

/datum/antagonist/ert/intern
	name = "CentCom Intern"
	outfit = /datum/outfit/centcom/centcom_intern
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_intern
	random_names = FALSE
	role = "Intern"
	suicide_cry = "FOR MY INTERNSHIP!!"

/datum/antagonist/ert/intern/leader
	name = "CentCom Head Intern"
	outfit = /datum/outfit/centcom/centcom_intern/leader
	random_names = FALSE
	role = "Head Intern"

/datum/antagonist/ert/intern/unarmed
	outfit = /datum/outfit/centcom/centcom_intern/unarmed

/datum/antagonist/ert/intern/leader/unarmed
	outfit = /datum/outfit/centcom/centcom_intern/leader/unarmed

/datum/antagonist/ert/clown
	role = "Clown"
	outfit = /datum/outfit/centcom/ert/clown
	plasmaman_outfit = /datum/outfit/plasmaman/party_comedian

/datum/antagonist/ert/clown/New()
	. = ..()
	name_source = GLOB.clown_names

/datum/antagonist/ert/janitor/party
	role = "Party Cleaning Service"
	outfit = /datum/outfit/centcom/ert/janitor/party
	plasmaman_outfit = /datum/outfit/plasmaman/party_janitor

/datum/antagonist/ert/security/party
	role = "Party Bouncer"
	outfit = /datum/outfit/centcom/ert/security/party
	plasmaman_outfit = /datum/outfit/plasmaman/party_bouncer

/datum/antagonist/ert/engineer/party
	role = "Party Constructor"
	outfit = /datum/outfit/centcom/ert/engineer/party
	plasmaman_outfit = /datum/outfit/plasmaman/party_constructor

/datum/antagonist/ert/clown/party
	role = "Party Comedian"
	outfit = /datum/outfit/centcom/ert/clown/party

/datum/antagonist/ert/commander/party
	role = "Party Coordinator"
	outfit = /datum/outfit/centcom/ert/commander/party

/datum/antagonist/ert/create_team(datum/team/ert/new_team)
	if(istype(new_team))
		ert_team = new_team

/datum/antagonist/ert/bounty_armor
	role = "Armored Bounty Hunter"
	outfit = /datum/outfit/bountyarmor/ert

/datum/antagonist/ert/bounty_hook
	role = "Hookgun Bounty Hunter"
	outfit = /datum/outfit/bountyhook/ert

/datum/antagonist/ert/bounty_synth
	role = "Synthetic Bounty Hunter"
	outfit = /datum/outfit/bountysynth/ert

/datum/antagonist/ert/forge_objectives()
	if(ert_team)
		objectives |= ert_team.objectives

/datum/antagonist/ert/proc/equipERT()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return

	if(isplasmaman(H))
		H.dna.species.outfit_important_for_life = plasmaman_outfit

	H.dna.species.give_important_for_life(H)
	H.equipOutfit(outfit)

	if(isplasmaman(H))
		var/obj/item/mod/control/our_modsuit = locate() in H.get_equipped_items()
		if(our_modsuit)
			our_modsuit.install(new /obj/item/mod/module/plasma_stabilizer)

/datum/antagonist/ert/greet()
	if(!ert_team)
		return

	to_chat(owner, "<span class='warningplain'><B><font size=3 color=red>You are the [name].</font></B></span>")

	var/missiondesc = "Your squad is being sent on a mission to [station_name()] by Nanotrasen's Security Division."
	if(leader) //If Squad Leader
		missiondesc += " Lead your squad to ensure the completion of the mission. Board the shuttle when your team is ready."
	else
		missiondesc += " Follow orders given to you by your squad leader."
	if(!rip_and_tear)
		missiondesc += " Avoid civilian casualties when possible."

	missiondesc += "<span class='warningplain'><BR><B>Your Mission</B> : [ert_team.mission.explanation_text]</span>"
	to_chat(owner,missiondesc)

/datum/antagonist/ert/marine
	name = "Marine Commander"
	outfit = /datum/outfit/centcom/ert/marine
	role = "Commander"

/datum/antagonist/ert/marine/security
	name = "Marine Heavy"
	outfit = /datum/outfit/centcom/ert/marine/security
	role = "Trooper"

/datum/antagonist/ert/marine/engineer
	name = "Marine Engineer"
	outfit = /datum/outfit/centcom/ert/marine/engineer
	role = "Engineer"

/datum/antagonist/ert/marine/medic
	name = "Marine Medic"
	outfit = /datum/outfit/centcom/ert/marine/medic
	role = "Medical Officer"

/datum/antagonist/ert/militia
	name = "Frontier Militia"
	outfit = /datum/outfit/centcom/militia
	role = "Volunteer"

/datum/antagonist/ert/militia/general
	name = "Frontier Militia General"
	outfit = /datum/outfit/centcom/militia/general
	role = "General"

/datum/antagonist/ert/medical_commander
	role = "Chief EMT"
	outfit = /datum/outfit/centcom/ert/medical_commander
	plasmaman_outfit = /datum/outfit/plasmaman/medical_commander

/datum/antagonist/ert/medical_technician
	role = "Emergency Medical Technician"
	outfit = /datum/outfit/centcom/ert/medical_technician
	plasmaman_outfit = /datum/outfit/plasmaman/medical_technician


// BEGIN NOVA CORE MIGRATION: code/modules/antagonists/ert/ert.dm
/datum/antagonist/ert/asset_protection
	name = "Asset Protection Specialist"
	outfit = /datum/outfit/centcom/asset_protection
	role = "Specialist"
	rip_and_tear = TRUE

/datum/antagonist/ert/asset_protection/New()
	. = ..()
	name_source = GLOB.commando_names

/datum/antagonist/ert/asset_protection/leader
	name = "Asset Protection Officer"
	outfit = /datum/outfit/centcom/asset_protection
	role = "Officer"

/datum/antagonist/ert/solfed
	name = "SolFed Auditor"
	outfit = /datum/outfit/solfed/lowrank
	role = "Auditor"
	suicide_cry = "FOR THE FEDERATION!!!!"

/datum/antagonist/ert/solfed/social
	outfit = /datum/outfit/solfed/social
	role = "Social Worker"

/datum/antagonist/ert/solfed/civil
	outfit = /datum/outfit/solfed/civil
	role = "Civil Services Worker"

/datum/antagonist/ert/solfed/leader
	name = "Lead SolFed Auditor"
	outfit = /datum/outfit/solfed
	role = "Lead Auditor"
	leader = TRUE

/datum/antagonist/ert/solfed/espatier
	name = "SolFed Espatier"
	outfit = /datum/outfit/solfed/espatier
	role = "Rifleman"

/datum/antagonist/ert/solfed/espatier/New()
	. = ..()
	name_source = GLOB.last_names

/datum/antagonist/ert/solfed/espatier/engineer
	name = "SolFed Espatier Engineer"
	outfit = /datum/outfit/solfed/espatier/engineer
	role = "Engineer"

/datum/antagonist/ert/solfed/espatier/corpsman
	name = "SolFed Espatier Corpsman"
	outfit = /datum/outfit/solfed/espatier/corpsman
	role = "Corpsman"

/datum/antagonist/ert/solfed/espatier/leader
	name = "SolFed Espatier Squad Leader"
	outfit = /datum/outfit/solfed/espatier/squadleader
	role = "Squad Leader"
	leader = TRUE

/datum/antagonist/ert/solfed/espatier/greet()
	var/missiondesc =  ""
	missiondesc += "<B><font size=5 color=red>You are NOT a Nanotrasen Employee. You serve the Sol Federation as the [name].</font></B>"
	if(leader) //If Squad Leader
		missiondesc += "<BR><B>Lead your squad to ensure the completion of the mission. Board the shuttle when your team is ready.</B>"
	if(!leader)
		missiondesc += "<BR><B><font size=2 color=yellow>Follow orders given to you by your squad leader.</font></B>"
	missiondesc += "<BR><B>Your Duties</B>:"
	missiondesc += "<BR> <B>1.</B> Contact the Sol Federation Ground Teams and the First Responders via your headset to get the situation from them."
	missiondesc += "<BR> <B>2.</B> Locate Survivors and Assume Control of the station, and prepare to initiate evacuation procedures should the situation call for it."
	missiondesc += "<BR> <B>3.</B> Should all else fail, evacuating the civilians becomes your top priority."
	missiondesc += "<BR> <B>4.</B> Lethal force is authorized, however identify before you shoot and watch who you're shooting, civilian casualties by Federation hands are NOT TOLERATED."

	missiondesc += "<span class='warningplain'><BR><B>Your Mission</B> : [ert_team.mission.explanation_text]</span>"
	to_chat(owner,missiondesc)

/// Grand Response variant
/datum/antagonist/ert/solfed/grand_espatier/engineer
	name = "SolFed Espatier Engineer"
	outfit = /datum/outfit/solfed/grand_espatier/engineer
	role = "Engineer"

/datum/antagonist/ert/solfed/grand_espatier/corpsman
	name = "SolFed Espatier Corpsman"
	outfit = /datum/outfit/solfed/grand_espatier/corpsman
	role = "Corpsman"

/datum/antagonist/ert/solfed/grand_espatier/leader
	name = "SolFed Espatier Squad Leader"
	outfit = /datum/outfit/solfed/grand_espatier/squadleader
	role = "Squad Leader"
	leader = TRUE

/datum/antagonist/ert/solfed/grand_espatier/greet()
	var/missiondesc =  ""
	missiondesc += "<B><font size=5 color=red>You are NOT a Nanotrasen Employee. You serve the Sol Federation as the [name].</font></B>"
	if(leader) //If Squad Leader
		missiondesc += "<BR><B>Lead your squad to ensure the completion of the mission. Board the shuttle when your team is ready.</B>"
	if(!leader)
		missiondesc += "<BR><B><font size=2 color=yellow>Follow orders given to you by your squad leader.</font></B>"
	missiondesc += "<BR><B>Your Duties</B>:"
	missiondesc += "<BR> <B>1.</B> Contact the Sol Federation Ground Teams and the First Responders via your headset to get the situation from them."
	missiondesc += "<BR> <B>2.</B> Locate Survivors and Assume Control of the station, and prepare to initiate evacuation procedures should the situation call for it."
	missiondesc += "<BR> <B>3.</B> Should all else fail, evacuating the civilians becomes your top priority."
	missiondesc += "<BR> <B>4.</B> Lethal force is authorized, however identify before you shoot and watch who you're shooting, civilian casualties by Federation hands are NOT TOLERATED."

	missiondesc += "<span class='warningplain'><BR><B>Your Mission</B> : [ert_team.mission.explanation_text]</span>"
	to_chat(owner,missiondesc)

/datum/antagonist/ert/armadyne
	name = "Armadyne Corporate Security"
	outfit = /datum/outfit/armadyne_security
	role = "Security"

/datum/antagonist/ert/armadyne/high_alert
	name = "Armadyne Corporate Security (High Alert)"
	outfit = /datum/outfit/armadyne_security/high_alert
	role = "Security"

/datum/antagonist/ert/armadyne/leader
	name = "Armadyne Corporate Security Commander"
	outfit = /datum/outfit/armadyne_security/commander
	role = "Commander"

/datum/antagonist/ert/armadyne/leader/high_alert
	name = "Armadyne Corporate Security Commander (High Alert)"
	outfit = /datum/outfit/armadyne_security/commander/high_alert
	role = "Commander"

/datum/antagonist/ert/weedkiller
	name = "Fumigator"
	outfit = /datum/outfit/ert/weedkiller
	role = "Exterminator"

/datum/antagonist/ert/weedkiller/leader
	name = "Fumigator Leader"
	outfit = /datum/outfit/ert/weedkiller/leader
	role = "Head Exterminator"

/datum/antagonist/ert/odst
	name = "Orbital Drop Shock Trooper"
	role = "Trooper"
	outfit = /datum/outfit/centcom/ert/odst

/datum/antagonist/ert/odst/on_gain()
	. = ..()
	equip_odst()

/datum/antagonist/ert/odst/proc/equip_odst()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/human_target = owner.current
	human_target.set_species(/datum/species/human)
	return TRUE

/datum/antagonist/ert/odst/leader
	name = "Orbital Drop Shock Trooper Leader"
	role = "Commander"

/datum/antagonist/ert/pizza
	name = "Pizza Delivery Boy"
	outfit = /datum/outfit/centcom/ert/pizza
	role = "Delivery Boy"

/datum/antagonist/ert/pizza/leader
	name = "Dogginos Regional Manager"
	outfit = /datum/outfit/centcom/ert/pizza/leader
	role = "Manager"

/datum/antagonist/ert/traumateam
	name = "Trauma Team Specialist"
	outfit = /datum/outfit/centcom/ert/medic/traumateam
	role = "Specialist"

/datum/antagonist/ert/traumateam/leader
	name = "Trauma Team Leader"
	outfit = /datum/outfit/centcom/ert/medic/traumateam/leader
	role = "Commander"
// END NOVA CORE MIGRATION: code/modules/antagonists/ert/ert.dm
