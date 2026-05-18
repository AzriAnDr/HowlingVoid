/datum/loadout_item/suit/rax_officer_jacket
	name = "Officer jacket"
	item_path = /obj/item/clothing/suit/armor/vest/warden/rax
	ckeywhitelist = list("raxraus")
	restricted_roles = list(ALL_JOBS_SEC)

/datum/loadout_item/under/jumpsuit/rax_banded_uniform
	name = "Banded Uniform"
	item_path = /obj/item/clothing/under/rank/security/rax
	ckeywhitelist = list("raxraus")
	restricted_roles = list(ALL_JOBS_SEC)

/datum/loadout_item/under/jumpsuit/plasmaman_jax
	name = "XuraCorp Biohazard Underfitting"
	item_path = /obj/item/clothing/under/plasmaman/jax2
	ckeywhitelist = list("candlejax")
	restricted_roles = list(ALL_JOBS_SCI, JOB_VIROLOGIST)

/datum/loadout_item/suit/jacket
	abstract_type = /datum/loadout_item/suit/jacket

/datum/loadout_item/suit/caligram_parka_vest_tan
	name = "Caligram Armored Tan Parka"
	item_path = /obj/item/clothing/suit/armor/vest/caligram_parka_vest
	restricted_roles = list(JOB_CAPTAIN,JOB_BRIDGE_ASSISTANT, ALL_JOBS_DEPTGUARD, ALL_JOBS_SEC)

/datum/loadout_item/glasses/redgigagar
	name = "Red-tinted Giga HUD Gar Glasses"
	item_path = /obj/item/clothing/glasses/hud/security/sunglasses/gars/giga/roselia
	ckeywhitelist = list("ultimarifox")
	restricted_roles = list(ALL_JOBS_DEPTGUARD, ALL_JOBS_SEC,)
