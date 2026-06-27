/datum/job/security_medic
	title = JOB_SECURITY_MEDIC
	description = "Patch up officers and prisoners, keep the brig alive, and coordinate with Medical when the situation outgrows your kit."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_HOS
	minimal_player_age = 7
	exp_requirements = 120
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_MEDICAL
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "SECURITY_MEDIC"
	antagonist_restricted = TRUE

	outfit = /datum/outfit/job/security_medic
	plasmaman_outfit = /datum/outfit/plasmaman/security

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SEC

	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_SECURITY_MEDIC
	bounty_types = CIV_JOB_SEC
	departments_list = list(
		/datum/job_department/security,
		/datum/job_department/medical,
	)

	family_heirlooms = list(/obj/item/clothing/neck/stethoscope, /obj/item/book/manual/wiki/security_space_law)

	mail_goodies = list(
		/obj/item/reagent_containers/hypospray/medipen = 20,
		/obj/item/reagent_containers/hypospray/medipen/oxandrolone = 10,
		/obj/item/reagent_containers/hypospray/medipen/salacid = 10,
		/obj/item/reagent_containers/hypospray/medipen/salbutamol = 10,
		/obj/item/reagent_containers/hypospray/medipen/penacid = 10,
		/obj/item/reagent_containers/hypospray/medipen/survival/luxury = 5,
		/obj/item/storage/box/bandages = 5,
	)
	rpg_title = "Battle Cleric"
	job_flags = STATION_JOB_FLAGS | JOB_ANTAG_PROTECTED

/datum/outfit/job/security_medic
	name = "Security Medic"
	jobtype = /datum/job/security_medic

	id_trim = /datum/id_trim/job/security_medic
	uniform = /obj/item/clothing/under/rank/security/security_medic
	suit = /obj/item/clothing/suit/armor/vest/security_medic
	suit_store = /obj/item/gun/energy/e_gun/advtaser
	belt = /obj/item/modular_computer/pda/security
	ears = /obj/item/radio/headset/headset_medsec
	gloves = /obj/item/clothing/gloves/latex/nitrile
	glasses = /obj/item/clothing/glasses/hud/medsechud/sunglasses
	head = /obj/item/clothing/head/beret/sec/security_medic
	shoes = /obj/item/clothing/shoes/jackboots/sec
	l_hand = /obj/item/storage/backpack/duffelbag/deforest_surgical/stocked

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	messenger = /obj/item/storage/backpack/messenger/sec

	box = /obj/item/storage/box/survival/security
	implants = list(/obj/item/implant/mindshield)

/obj/effect/landmark/start/security_medic
	name = "Security Medic"
	icon_state = "Security Medic"

/obj/effect/landmark/start/security_officer/Initialize(mapload)
	. = ..()
	new /obj/effect/landmark/start/security_medic(get_turf(src))

/datum/controller/subsystem/job/setup_occupations()
	. = ..()

	var/list/security_exp_jobs = experience_jobs_map[EXP_TYPE_SECURITY]
	for(var/datum/job/job_type as anything in security_exp_jobs)
		if(!istype(job_type, /datum/job/security_medic))
			continue

		LAZYREMOVE(security_exp_jobs, job_type)
		break
