/datum/ert
	///Antag datum team for this type of ERT.
	var/team = /datum/team/ert
	///Do we open the doors to the "high-impact" weapon/explosive cabinets? Used for combat-focused ERTs.
	var/opendoors = TRUE
	///Alternate antag datum given to the leader of the squad.
	var/leader_role = /datum/antagonist/ert/commander
	///Do we humanize all spawned players or keep them the species in their current character prefs?
	var/enforce_human = TRUE
	///A list of roles distributed to the selected candidates that are not the leader.
	var/roles = list(/datum/antagonist/ert/security, /datum/antagonist/ert/medic, /datum/antagonist/ert/engineer)
	///The custom name assigned to this team, for their antag datum/roundend reporting.
	var/rename_team
	///Defines the color/alert code of the response team. Unused if a polldesc is defined.
	var/code
	///The mission given to this ERT type in their flavor text.
	var/mission = "Assist the station."
	///The number of players for consideration.
	var/teamsize = 5
	///The "would you like to play as XXX" message used when polling for players.
	var/polldesc
	/// If TRUE, gives the team members "[role] [random last name]" style names
	var/random_names = TRUE
	/// If TRUE, the admin who created the response team will be spawned in the briefing room in their preferred briefing outfit (assuming they're a ghost)
	var/spawn_admin = FALSE
	/// If TRUE, we try and pick one of the most experienced players who volunteered to fill the leader slot
	var/leader_experience = TRUE
	///NOVA EDIT: Do we want to notify the players of this ERT?
	var/notify_players = TRUE
	/// A custom map template to spawn the ERT at. If this is null or use_custom_shuttle is FALSE, the ERT will spawn at Centcom.
	var/datum/map_template/ert_template
	/// If we should actually _use_ the ert_template custom shuttle
	var/use_custom_shuttle = TRUE
	/// Used for spawning bodies for your ERT. Unless customized in the Summon-ERT verb settings, will be overridden and should not be defined at the datum level.
	var/mob/living/carbon/human/mob_type

/datum/ert/New()
	if (!polldesc)
		polldesc = "a Code [code] Nanotrasen Emergency Response Team"

/datum/ert/blue
	opendoors = FALSE
	code = "Blue"

/datum/ert/amber
	code = "Amber"

/datum/ert/red
	leader_role = /datum/antagonist/ert/commander/red
	roles = list(/datum/antagonist/ert/security/red, /datum/antagonist/ert/medic/red, /datum/antagonist/ert/engineer/red)
	code = "Red"

/datum/ert/deathsquad
	roles = list(/datum/antagonist/ert/deathsquad)
	leader_role = /datum/antagonist/ert/deathsquad/leader
	rename_team = "Deathsquad"
	code = "Delta"
	mission = "Leave no witnesses."
	polldesc = "an elite Nanotrasen Strike Team"

/datum/ert/marine
	leader_role = /datum/antagonist/ert/marine
	roles = list(/datum/antagonist/ert/marine/security, /datum/antagonist/ert/marine/engineer, /datum/antagonist/ert/marine/medic)
	rename_team = "Marine Squad"
	polldesc = "an 'elite' Nanotrasen Strike Team"
	opendoors = FALSE

/datum/ert/centcom_official
	code = "Green"
	teamsize = 1
	opendoors = FALSE
	leader_role = /datum/antagonist/ert/official
	roles = list(/datum/antagonist/ert/official)
	rename_team = "CentCom Officials"
	polldesc = "a CentCom Official"
	random_names = FALSE
	leader_experience = FALSE

/datum/ert/centcom_official/New()
	mission = "Conduct a routine performance review of [station_name()] and its Captain."

/datum/ert/inquisition
	roles = list(/datum/antagonist/ert/chaplain/inquisitor, /datum/antagonist/ert/security/inquisitor, /datum/antagonist/ert/medic/inquisitor)
	leader_role = /datum/antagonist/ert/commander/inquisitor
	rename_team = "Inquisition"
	mission = "Destroy any traces of paranormal activity aboard the station."
	polldesc = "a Nanotrasen paranormal response team"

/datum/ert/janitor
	roles = list(/datum/antagonist/ert/janitor, /datum/antagonist/ert/janitor/heavy)
	leader_role = /datum/antagonist/ert/janitor/heavy
	teamsize = 4
	opendoors = FALSE
	rename_team = "Janitor"
	mission = "Clean up EVERYTHING."
	polldesc = "a Nanotrasen Janitorial Response Team"

/datum/ert/intern
	roles = list(/datum/antagonist/ert/intern)
	leader_role = /datum/antagonist/ert/intern/leader
	teamsize = 7
	opendoors = FALSE
	rename_team = "Horde of Interns"
	mission = "Assist in conflict resolution."
	polldesc = "an unpaid internship opportunity with Nanotrasen"
	random_names = FALSE

/datum/ert/intern/unarmed
	roles = list(/datum/antagonist/ert/intern/unarmed)
	leader_role = /datum/antagonist/ert/intern/leader/unarmed
	rename_team = "Unarmed Horde of Interns"

/datum/ert/erp
	roles = list(/datum/antagonist/ert/security/party, /datum/antagonist/ert/clown/party, /datum/antagonist/ert/engineer/party, /datum/antagonist/ert/janitor/party)
	leader_role = /datum/antagonist/ert/commander/party
	opendoors = FALSE
	rename_team = "Emergency Response Party"
	mission = "Create entertainment for the crew."
	polldesc = "a Code Rainbow Nanotrasen Emergency Response Party"
	code = "Rainbow"

/datum/ert/bounty_hunters
	roles = list(/datum/antagonist/ert/bounty_armor, /datum/antagonist/ert/bounty_hook, /datum/antagonist/ert/bounty_synth)
	leader_role = /datum/antagonist/ert/bounty_armor
	teamsize = 3
	opendoors = FALSE
	rename_team = "Bounty Hunters"
	mission = "Assist the station in catching perps, dead or alive."
	polldesc = "a Centcom-hired bounty hunting gang"
	random_names = FALSE
	ert_template = /datum/map_template/shuttle/ert/bounty

/datum/ert/militia
	roles = list(/datum/antagonist/ert/militia)
	leader_role = /datum/antagonist/ert/militia/general
	teamsize = 4
	opendoors = FALSE
	rename_team = "Frontier Militia"
	mission = "Having heard the station's request for aid, assist the crew in defending themselves."
	polldesc = "an independent station defense militia"
	random_names = TRUE

/datum/ert/medical
	opendoors = FALSE
	teamsize = 4
	leader_role = /datum/antagonist/ert/medical_commander
	enforce_human = FALSE //All the best doctors I know are moths and cats
	roles = list(/datum/antagonist/ert/medical_technician)
	rename_team = "EMT Squad"
	code = "Violet"
	mission = "Provide emergency medical services to the crew."
	polldesc = "an emergency medical response team"


// BEGIN NOVA CORE MIGRATION: code/datums/ert.dm
/*
*	Use this file to add
*	Modular ERT datums
*/

/datum/ert/asset_protection
	roles = list(/datum/antagonist/ert/asset_protection)
	leader_role = /datum/antagonist/ert/asset_protection/leader
	rename_team = "Asset Protection Team"
	code = "Red"
	mission = "Protect Nanotrasen's assets; crew are assets."
	polldesc = "a Nanotrasen asset protection team"

/// A mix of officials
/datum/ert/solfed
	roles = list(/datum/antagonist/ert/solfed, /datum/antagonist/ert/solfed/social, /datum/antagonist/ert/solfed/civil)
	leader_role = /datum/antagonist/ert/solfed/leader

	notify_players = FALSE
	opendoors = FALSE
	ert_template = /datum/map_template/shuttle/ert/solfed/official

	rename_team = "SolFed Officials"
	teamsize = 5
	code = "FEDERAL"
	mission = "Audit the station, write reports, and look for any violations of Federal regulations."
	polldesc = "a Sol Federation Official"

/datum/ert/solfed/espatier
	roles = list(/datum/antagonist/ert/solfed/espatier, /datum/antagonist/ert/solfed/espatier/corpsman, /datum/antagonist/ert/solfed/espatier/engineer)
	leader_role = /datum/antagonist/ert/solfed/espatier/leader

	ert_template = /datum/map_template/shuttle/ert/solfed

	notify_players = TRUE
	rename_team = "SolFed Espatier Detachment"
	teamsize = 6
	code = "FEDERAL"
	mission = "Rescue survivors, and bring order to chaos. Glory to the Federation."
	polldesc = "a Sol Federation Espatier"


/// A variant of spawning, they spawn with a smaller more assaultlike ship, with no compartments (no medical compartment, engineering, atmos, just what they have on their back)
/datum/ert/solfed/espatier/assault
	ert_template = /datum/map_template/shuttle/ert/solfed/assault

/// Corpsman only spawn
/datum/ert/solfed/espatier/assault/corpsman_only
	roles = list(/datum/antagonist/ert/solfed/espatier)
	polldesc = "a Sol Federation Truama Team"

/// Rifleman only spawn
/datum/ert/solfed/espatier/assault/rifleman_only
	roles = list(/datum/antagonist/ert/solfed/espatier/corpsman)
	polldesc = "a Sol Federation Rifleman"

/// Engineering only spawn
/datum/ert/solfed/espatier/assault/engineering_only
	roles = list(/datum/antagonist/ert/solfed/espatier/engineer)

/// A variant of spawning, they basically spawn with the mobile garrison/armory.
/datum/ert/solfed/espatier/armory
	ert_template = /datum/map_template/shuttle/ert/solfed/armory

/// Forces the true helljumpers (basically all infantry, no medics)
/datum/ert/solfed/espatier/armory/rifleman_only
	roles = list(/datum/antagonist/ert/solfed/espatier)

/// A variant of spawning, they basically spawn with the mobile Hospital.
/datum/ert/solfed/espatier/medical
	ert_template = /datum/map_template/shuttle/ert/solfed/medical

/// A variant of spawning, they basically spawn with the mobile Engineering Bay.
/datum/ert/solfed/espatier/engineer
	ert_template = /datum/map_template/shuttle/ert/solfed/engineer

/// Forces this shuttle type to be engineering only
/datum/ert/solfed/espatier/engineer/engineering_only
	roles = list(/datum/antagonist/ert/solfed/espatier/engineer)

/// Forces the crew to be oops all corpsmans! (medics/doctors)
/datum/ert/solfed/espatier/medical/corpsman_only
	roles = list(/datum/antagonist/ert/solfed/espatier/corpsman)

/// Solfed Officals shuttle, but more fancy.
/datum/ert/solfed/fancy
	ert_template = /datum/map_template/shuttle/ert/solfed/fancy
/*

GRAND RESPONSE VARIANTS OF ESPATIERS, USE ONLY IF SOMEONE ROYALLY FUCKED UP

*/
/datum/ert/solfed/grand_espatier
	roles = list(/datum/antagonist/ert/solfed/grand_espatier, /datum/antagonist/ert/solfed/grand_espatier/corpsman, /datum/antagonist/ert/solfed/grand_espatier/engineer)
	leader_role = /datum/antagonist/ert/solfed/grand_espatier/leader

	ert_template = /datum/map_template/shuttle/ert/solfed

	notify_players = TRUE
	rename_team = "SolFed Espatier Detachment"
	teamsize = 6
	code = "FEDERAL"
	mission = "Rescue survivors, and bring order to chaos. Glory to the Federation."
	polldesc = "a Sol Federation Grand Response Espatier"


/// A variant of spawning, they spawn with a smaller more assaultlike ship, with no compartments (no medical compartment, engineering, atmos, just what they have on their back)
/datum/ert/solfed/grand_espatier/assault
	ert_template = /datum/map_template/shuttle/ert/solfed/assault

/// Corpsman only spawn
/datum/ert/solfed/grand_espatier/assault/corpsman_only
	roles = list(/datum/antagonist/ert/solfed/grand_espatier)
	polldesc = "a Sol Federation Truama Team"

/// Rifleman only spawn
/datum/ert/solfed/grand_espatier/assault/rifleman_only
	roles = list(/datum/antagonist/ert/solfed/grand_espatier/corpsman)
	polldesc = "a Sol Federation Rifleman"

/// Engineering only spawn
/datum/ert/solfed/grand_espatier/assault/engineering_only
	roles = list(/datum/antagonist/ert/solfed/grand_espatier/engineer)

/// A variant of spawning, they basically spawn with the mobile garrison/armory.
/datum/ert/solfed/grand_espatier/armory
	ert_template = /datum/map_template/shuttle/ert/solfed/armory

/// Forces the true helljumpers (basically all infantry, no medics)
/datum/ert/solfed/grand_espatier/armory/rifleman_only
	roles = list(/datum/antagonist/ert/solfed/grand_espatier)

/// A variant of spawning, they basically spawn with the mobile Hospital.
/datum/ert/solfed/grand_espatier/medical
	ert_template = /datum/map_template/shuttle/ert/solfed/medical

/// A variant of spawning, they basically spawn with the mobile Engineering Bay.
/datum/ert/solfed/grand_espatier/engineer
	ert_template = /datum/map_template/shuttle/ert/solfed/engineer

/// Forces this shuttle type to be engineering only
/datum/ert/solfed/grand_espatier/engineer/engineering_only
	roles = list(/datum/antagonist/ert/solfed/grand_espatier/engineer)

/// Forces the crew to be oops all corpsmans! (medics/doctors)
/datum/ert/solfed/grand_espatier/medical/corpsman_only
	roles = list(/datum/antagonist/ert/solfed/grand_espatier/corpsman)

/datum/ert/armadyne
	roles = list(/datum/antagonist/ert/armadyne)
	leader_role = /datum/antagonist/ert/armadyne/leader
	rename_team = "Armadyne PMC"
	mission = "Assist any Armadyne corporate entities."
	polldesc = "an Armadyne PMC."
	teamsize = 3

/datum/ert/armadyne/high_alert
	roles = list(/datum/antagonist/ert/armadyne/high_alert)
	leader_role = /datum/antagonist/ert/armadyne/leader/high_alert
	rename_team = "Armadyne PMC (High Alert)"

/datum/ert/fullengi
	roles = list(/datum/antagonist/ert/engineer)
	leader_role = /datum/antagonist/ert/engineer/red
	rename_team = "Repairmen"
	code = "Orange"
	mission = "Repair the station."
	polldesc = "a group of engineers"

/datum/ert/weedkiller
	roles = list(/datum/antagonist/ert/weedkiller)
	leader_role = /datum/antagonist/ert/weedkiller/leader
	rename_team = "ERT Pest Control"
	code = "Green"
	mission = "Clear out all insects, weeds, and/or vines."
	polldesc = "a group of exterminators"

/datum/ert/odst
	roles = list(/datum/antagonist/ert/odst)
	leader_role = /datum/antagonist/ert/odst/leader
	rename_team = "ODST"
	code = "Red"
	polldesc = "a squad of specialized ODST"

/datum/ert/pizza
	roles = list(/datum/antagonist/ert/pizza)
	leader_role = /datum/antagonist/ert/pizza/leader
	rename_team = "Dogginos"
	code = "Green"
	mission = "Serve the station with a smile, remember to get a tip!"
	polldesc = "a group of trained pizza delivery boys"

/datum/ert/traumateam
	roles = list(/datum/antagonist/ert/traumateam)
	leader_role = /datum/antagonist/ert/traumateam/leader
	rename_team = "Trauma Team"
	code = "Violet"
	polldesc = "a group of Trauma Team Specialists"
// END NOVA CORE MIGRATION: code/datums/ert.dm
