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

/datum/loadout_item/under/jumpsuit/paddedunder
	name = "Feathered Serenity Suit"
	item_path = /obj/item/clothing/under/padded
	ckeywhitelist = list("thedragmeme")

/datum/loadout_item/neck/padded
	name = "Feathered Serenity Cloak"
	item_path = /obj/item/clothing/neck/padded
	ckeywhitelist = list("thedragmeme", "SomeNetwork")

/datum/loadout_item/under/jumpsuit/lannese
	name = "Lannese Dress"
	item_path = /obj/item/clothing/under/custom/lannese
	ckeywhitelist = list("kathrinbailey")

/datum/loadout_item/toys/plush/plushie_razurath
	name = "Science Shark Plushie"
	item_path = /obj/item/toy/plush/nova/donator/plushie_razurath
	ckeywhitelist = list("razurath")
