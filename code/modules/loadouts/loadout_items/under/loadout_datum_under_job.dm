/*
*	WORKWEAR
*	For job gear or otherwise work-related attire. PPE, Department Equipment, or Job-Locked.
*/

/datum/loadout_item/under/jumpsuit/utility
	name = "Utility Uniform"
	item_path = /obj/item/clothing/under/misc/nova/utility
	group = "Workwear"

/*
*	JOB-BLACKLISTED
*	No unique group for this because it's fairly niche
*/

/datum/loadout_item/under/jumpsuit/tarkon //Not alphabetical because this is a base-entry for Tarkon blacklisted_roles
	name = "Tarkon Deck Jumpsuit"
	item_path = /obj/item/clothing/under/tarkon/general
	blacklisted_roles = list(ALL_JOBS_COM, ALL_JOBS_SEC)
	group = "Workwear"

/datum/loadout_item/under/jumpsuit/utility_com
	name = "Command Utility Uniform"
	item_path = /obj/item/clothing/under/rank/captain/nova/utility
	restricted_roles = list(ALL_JOBS_COM)
	group = "Job-Locked"

/datum/loadout_item/under/bunny/medical
	name = "Bunny Suit (Medical)"
	item_path = /obj/item/clothing/under/rank/medical/doctor_bunnysuit
	erp_item = TRUE
	group = "Bunny Suit"
	restricted_roles = list(ALL_JOBS_MED)

/datum/loadout_item/under/bunny/medical/paramed
	name = "Bunny Suit (Paramedic)"
	item_path = /obj/item/clothing/under/rank/medical/paramedic_bunnysuit
	erp_item = TRUE
	group = "Bunny Suit"
	restricted_roles = list(ALL_JOBS_MED)

/datum/loadout_item/under/bunny/medical/chem
	name = "Bunny Suit (Chemist)"
	item_path = /obj/item/clothing/under/rank/medical/chemist/bunnysuit
	erp_item = TRUE
	group = "Bunny Suit"
	restricted_roles = list(ALL_JOBS_MED)

/datum/loadout_item/under/bunny/medical/viro
	name = "Bunny Suit (Virology)"
	item_path = /obj/item/clothing/under/rank/medical/pathologist_bunnysuit
	erp_item = TRUE
	group = "Bunny Suit"
	restricted_roles = list(ALL_JOBS_MED)

/datum/loadout_item/under/bunny/medical/coroner
	name = "Bunny Suit (Coroner)"
	item_path = /obj/item/clothing/under/rank/medical/coroner_bunnysuit
	erp_item = TRUE
	group = "Bunny Suit"
	restricted_roles = list(ALL_JOBS_MED)

/datum/loadout_item/under/bunny/engineer
	name = "Bunny Suit (Engineer)"
	item_path = /obj/item/clothing/under/rank/engineering/engineer_bunnysuit
	erp_item = TRUE
	group = "Bunny Suit"
	restricted_roles = list(ALL_JOBS_ENGI)

/datum/loadout_item/under/bunny/engineer/atmos
	name = "Bunny Suit (Atmos)"
	item_path = /obj/item/clothing/under/rank/engineering/atmos_tech_bunnysuit
	erp_item = TRUE
	group = "Bunny Suit"
	restricted_roles = list(ALL_JOBS_ENGI)

/datum/loadout_item/under/bunny/rnd
	name = "Bunny Suit (Science)"
	item_path = /obj/item/clothing/under/rank/rnd/scientist/bunnysuit
	erp_item = TRUE
	group = "Bunny Suit"
	restricted_roles = list(ALL_JOBS_SCI)

/datum/loadout_item/under/bunny/rnd/robo
	name = "Bunny Suit (Robotics)"
	item_path = /obj/item/clothing/under/rank/rnd/scientist/roboticist_bunnysuit
	erp_item = TRUE
	group = "Bunny Suit"
	restricted_roles = list(ALL_JOBS_SCI)

/datum/loadout_item/under/bunny/rnd/gene
	name = "Bunny Suit (Genetics)"
	item_path = /obj/item/clothing/under/rank/rnd/geneticist/bunnysuit
	erp_item = TRUE
	group = "Bunny Suit"
	restricted_roles = list(ALL_JOBS_SCI)

/datum/loadout_item/under/bunny/rnd/rd
	name = "Bunny Suit (Research Director)"
	item_path = /obj/item/clothing/under/rank/rnd/research_director/bunnysuit
	erp_item = TRUE
	group = "Bunny Suit"
	restricted_roles = list(ALL_JOBS_SCI)

//CARGO
/datum/loadout_item/under/jumpsuit/utility_sec
	name = "Security Utility Uniform"
	item_path = /obj/item/clothing/under/rank/security/nova/utility
	restricted_roles = list(ALL_JOBS_SEC)
	group = "Job-Locked"

/datum/loadout_item/under/bunny/sec
	name = "Bunny Suit (Security)"
	item_path = /obj/item/clothing/under/rank/security/security_bunnysuit
	erp_item = TRUE
	group = "Bunny Suit"
	restricted_roles = list(ALL_JOBS_SEC)

/datum/loadout_item/under/bunny/sec/dept
	name = "Bunny Suit (Deputy)"
	item_path = /obj/item/clothing/under/rank/security/security_assistant_bunnysuit
	erp_item = TRUE
	group = "Bunny Suit"
	restricted_roles = list(ALL_JOBS_SEC)

/datum/loadout_item/under/bunny/sec/med
	name = "Bunny Suit (SecMed)"
	item_path = /obj/item/clothing/under/rank/security/brig_phys_bunnysuit
	erp_item = TRUE
	group = "Bunny Suit"
	restricted_roles = list(ALL_JOBS_SEC)

/datum/loadout_item/under/jumpsuit/security_medic
	name = "Security Medic Turtleneck"
	item_path = /obj/item/clothing/under/rank/security/security_medic
	restricted_roles = list(JOB_SECURITY_MEDIC)
	group = "Job-Locked"

/datum/loadout_item/under/jumpsuit/security_medic/skirt
	name = "Security Medic Skirtleneck"
	item_path = /obj/item/clothing/under/rank/security/security_medic/skirt
	restricted_roles = list(JOB_SECURITY_MEDIC)
	group = "Job-Locked"

/datum/loadout_item/under/jumpsuit/security_medic/alternate
	name = "Security Medic Uniform"
	item_path = /obj/item/clothing/under/rank/security/security_medic/alternate
	restricted_roles = list(JOB_SECURITY_MEDIC)
	group = "Job-Locked"

/datum/loadout_item/under/jumpsuit/cargo
	name = "Cargo Technician's Jumpsuit"
	item_path = /obj/item/clothing/under/rank/cargo/tech
	group = "Workwear"

/datum/loadout_item/under/jumpsuit/cargo/skirt
	name = "Cargo Technician's Skirt"
	item_path = /obj/item/clothing/under/rank/cargo/tech/skirt
	group = "Workwear"

/datum/loadout_item/under/jumpsuit/colonial_uniform
	name = "Colonial Uniform"
	item_path = /obj/item/clothing/under/colonial
	group = "Workwear"
	species_blacklist = list(SPECIES_TESHARI)

/datum/loadout_item/under/bunny/sec/det
	name = "Bunny Suit (Detective)"
	item_path = /obj/item/clothing/under/rank/security/detective_bunnysuit
	erp_item = TRUE
	group = "Bunny Suit"
	restricted_roles = list(JOB_DETECTIVE)
