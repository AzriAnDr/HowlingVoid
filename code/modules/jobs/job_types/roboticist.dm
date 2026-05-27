/datum/job/roboticist
	title = JOB_ROBOTICIST
	description = "Build and repair the AI and cyborgs, create mechs."
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = SUPERVISOR_RD
	exp_requirements = 60
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	bounty_types = CIV_JOB_ROBO
	config_tag = "ROBOTICIST"

	outfit = /datum/outfit/job/roboticist
	plasmaman_outfit = /datum/outfit/plasmaman/robotics
	departments_list = list(
		/datum/job_department/science,
		)

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SCI

	display_order = JOB_DISPLAY_ORDER_ROBOTICIST

	mail_goodies = list(
		/obj/item/storage/box/flashes = 20,
		/obj/item/stack/sheet/iron/twenty = 15,
		/obj/item/modular_computer/laptop = 5,
		/obj/item/mmi/posibrain/sphere = 5,
	)

	family_heirlooms = list(/obj/item/toy/plush/pkplush)
	rpg_title = "Necromancer"
	job_flags = STATION_JOB_FLAGS


/datum/job/roboticist/New()
	. = ..()
	family_heirlooms += subtypesof(/obj/item/toy/mecha)

/datum/outfit/job/roboticist
	name = "Roboticist"
	jobtype = /datum/job/roboticist

	id_trim = /datum/id_trim/job/roboticist
	uniform = /obj/item/clothing/under/rank/rnd/roboticist
	suit = /obj/item/clothing/suit/toggle/labcoat/roboticist
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/headset_medsci // NOVA EDIT CHANGE - ORIGINAL: /obj/item/radio/headset/headset_sci
	l_pocket = /obj/item/modular_computer/pda/roboticist

	pda_slot = ITEM_SLOT_LPOCKET
	skillchips = list(/obj/item/skillchip/job/roboticist)

/datum/outfit/job/roboticist/mod
	name = "Roboticist (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/standard
	suit = null
	mask = /obj/item/clothing/mask/breath
	internals_slot = ITEM_SLOT_SUITSTORE


// BEGIN NOVA CORE MIGRATION: code/modules/jobs/job_types/roboticist.dm
/datum/outfit/job/roboticist
	backpack = /obj/item/storage/backpack/science/robo
	satchel = /obj/item/storage/backpack/satchel/science/robo
	duffelbag = /obj/item/storage/backpack/duffelbag/science/robo
	messenger = /obj/item/storage/backpack/messenger/science/robo

	glasses = /obj/item/clothing/glasses/hud/diagnostic
	gloves = /obj/item/clothing/gloves/color/black

	l_hand = /obj/item/storage/medkit/robotic_repair/preemo/stocked

/datum/job/roboticist
	description = "Build cyborgs, mechs, AIs, and maintain them all. Create MODsuits for those that wish. Try to remind medical that you're \
	actually a lot better at treating synthetic crew members than them."

/datum/outfit/job/roboticist/New()
	. = ..()

	LAZYINITLIST(backpack_contents)
	backpack_contents[/obj/item/clothing/head/utility/welding] = 1

/datum/job/roboticist/New()
	. = ..()

	mail_goodies += list(
		/obj/item/healthanalyzer/advanced = 15,
		/obj/item/screwdriver/power/science = 6,
		/obj/item/crowbar/power/science = 6,
		/obj/item/weldingtool/experimental = 2, // a lot rarer since it's relatively powerful
		/obj/item/scalpel/advanced = 6,
		/obj/item/retractor/advanced = 6,
		/obj/item/cautery/advanced = 6,
		/obj/item/storage/pill_bottle/liquid_solder = 6,
		/obj/item/storage/pill_bottle/system_cleaner = 6,
		/obj/item/storage/pill_bottle/nanite_slurry = 6,
		/obj/item/reagent_containers/spray/hercuri/chilled = 8,
		/obj/item/reagent_containers/spray/dinitrogen_plasmide = 8,
	)
// END NOVA CORE MIGRATION: code/modules/jobs/job_types/roboticist.dm
