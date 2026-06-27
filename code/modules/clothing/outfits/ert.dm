/datum/outfit/centcom
	name = "CentCom Base"

/datum/outfit/centcom/post_equip(mob/living/carbon/human/centcom_member, visuals_only = FALSE)
	if(visuals_only)
		return
	var/obj/item/implant/mindshield/mindshield = new /obj/item/implant/mindshield(centcom_member)//hmm lets have centcom officials become revs
	mindshield.implant(centcom_member, null, silent = TRUE)

/datum/outfit/centcom/ert
	name = "ERT Common"

	uniform = /obj/item/clothing/under/rank/centcom/officer
	ears = /obj/item/radio/headset/headset_cent/alt
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer
	shoes = /obj/item/clothing/shoes/combat/swat
	var/additional_radio

/datum/outfit/centcom/ert/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return

	var/obj/item/radio/headset/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = RADIO_FREQENCY_LOCKED
	if(additional_radio)
		R.keyslot2 = new additional_radio()
		R.recalculateChannels()

	var/obj/item/card/id/W = H.wear_id
	if(W)
		W.registered_name = H.real_name
		W.update_label()
		W.update_icon()
	return ..()

/datum/outfit/centcom/ert/commander
	name = "ERT Commander"

	id = /obj/item/card/id/advanced/centcom/ert/commander
	back = /obj/item/mod/control/pre_equipped/responsory/commander
	l_hand = /obj/item/gun/energy/e_gun
	box = /obj/item/storage/box/survival/centcom
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded = 1,
	)
	belt = /obj/item/storage/belt/security/full
	ears = /obj/item/radio/headset/headset_cent/alt/leader
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/switchblade
	additional_radio = /obj/item/encryptionkey/heads/captain

/datum/outfit/centcom/ert/commander/alert
	name = "ERT Commander - High Alert"

	l_hand = /obj/item/gun/energy/disabler/smg
	backpack_contents = list(
		/obj/item/gun/energy/pulse/pistol/loyalpin = 1,
		/obj/item/melee/baton/security/loaded = 1,
	)
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	l_pocket = /obj/item/melee/energy/sword/saber
	suit_store = /obj/item/gun/energy/laser/assault

/datum/outfit/centcom/ert/security
	name = "ERT Security"

	id = /obj/item/card/id/advanced/centcom/ert/security
	back = /obj/item/mod/control/pre_equipped/responsory/security
	l_hand = /obj/item/gun/energy/e_gun/stun
	box = /obj/item/storage/box/survival/centcom
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/storage/box/handcuffs = 1,
	)
	belt = /obj/item/storage/belt/security/full
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	additional_radio = /obj/item/encryptionkey/heads/hos

/datum/outfit/centcom/ert/security/alert
	name = "ERT Security - High Alert"

	l_hand = /obj/item/gun/energy/pulse/carbine/loyalpin
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/storage/box/handcuffs = 1,
	)

/datum/outfit/centcom/ert/medic
	name = "ERT Medic"

	id = /obj/item/card/id/advanced/centcom/ert/medical
	back = /obj/item/mod/control/pre_equipped/responsory/medic
	box = /obj/item/storage/box/survival/centcom
	backpack_contents = list(
		/obj/item/gun/medbeam = 1,
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/reagent_containers/hypospray/combat = 1,
		/obj/item/storage/box/hug/plushes = 1,
	)
	belt = /obj/item/storage/belt/medical/ert
	glasses = /obj/item/clothing/glasses/hud/health
	l_hand = /obj/item/storage/medkit/regular
	r_hand = /obj/item/gun/energy/e_gun
	l_pocket = /obj/item/healthanalyzer/advanced
	additional_radio = /obj/item/encryptionkey/heads/cmo

	skillchips = list(/obj/item/skillchip/entrails_reader)

/datum/outfit/centcom/ert/medic/alert
	name = "ERT Medic - High Alert"

	backpack_contents = list(
		/obj/item/gun/energy/pulse/pistol/loyalpin = 1,
		/obj/item/gun/medbeam = 1,
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/reagent_containers/hypospray/combat/nanites = 1,
		/obj/item/storage/box/hug/plushes = 1,
	)
	mask = /obj/item/clothing/mask/gas/sechailer/swat

/datum/outfit/centcom/ert/engineer
	name = "ERT Engineer"

	id = /obj/item/card/id/advanced/centcom/ert/engineer
	back = /obj/item/mod/control/pre_equipped/responsory/engineer
	l_hand = /obj/item/gun/energy/e_gun
	box = /obj/item/storage/box/survival/centcom
	backpack_contents = list(
		/obj/item/construction/rcd/loaded/upgraded = 1,
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/pipe_dispenser = 1,
	)
	belt = /obj/item/storage/belt/utility/full/powertools
	glasses = /obj/item/clothing/glasses/meson/engine
	l_pocket = /obj/item/rcd_ammo/large
	additional_radio = /obj/item/encryptionkey/heads/ce

	skillchips = list(/obj/item/skillchip/job/engineer)

/datum/outfit/centcom/ert/engineer/alert
	name = "ERT Engineer - High Alert"

	backpack_contents = list(
		/obj/item/construction/rcd/combat = 1,
		/obj/item/gun/energy/pulse/pistol/loyalpin = 1,
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/pipe_dispenser = 1,
	)

/datum/outfit/centcom/centcom_official
	name = "CentCom Official"

	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/official
	uniform = /obj/item/clothing/under/rank/centcom/official
	back = /obj/item/storage/backpack/satchel
	box = /obj/item/storage/box/survival
	backpack_contents = list(
		/obj/item/stamp/centcom = 1,
	)
	belt = /obj/item/gun/energy/e_gun
	ears = /obj/item/radio/headset/headset_cent
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/sneakers/black
	l_pocket = /obj/item/pen
	r_pocket = /obj/item/modular_computer/pda/heads
	l_hand = /obj/item/clipboard

/datum/outfit/centcom/centcom_official/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return

	var/obj/item/modular_computer/pda/heads/pda = H.r_store
	pda.imprint_id(H.real_name, "CentCom Official")

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()
	return ..()

/datum/outfit/prison_transport_officer
	name = "Prisoner Transport Officer"

	ears = /obj/item/radio/headset/headset_cent/alt/with_key
	glasses = /obj/item/clothing/glasses/sunglasses/big
	uniform = /obj/item/clothing/under/rank/security/officer
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	belt = /obj/item/storage/belt/security
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/prison_transport

/datum/outfit/centcom/ert/commander/inquisitor
	name = "Inquisition Commander"

	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/commander
	r_hand = /obj/item/nullrod/claymore/talking/chainsword
	backpack_contents = null

/datum/outfit/centcom/ert/security/inquisitor
	name = "Inquisition Security"

	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/security
	backpack_contents = list(
		/obj/item/construction/rcd/loaded = 1,
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/storage/box/handcuffs = 1,
	)

/datum/outfit/centcom/ert/medic/inquisitor
	name = "Inquisition Medic"

	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/medic
	backpack_contents = list(
		/obj/item/gun/medbeam = 1,
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/reagent_containers/hypospray/combat = 1,
		/obj/item/reagent_containers/hypospray/combat/heresypurge = 1,
	)

/datum/outfit/centcom/ert/chaplain
	name = "ERT Chaplain"

	id = /obj/item/card/id/advanced/centcom/ert/chaplain
	back = /obj/item/mod/control/pre_equipped/responsory/chaplain
	l_hand = /obj/item/gun/energy/e_gun
	belt = /obj/item/storage/belt/soulstone
	glasses = /obj/item/clothing/glasses/hud/health
	box = /obj/item/storage/box/survival/centcom
	backpack_contents = list(
		/obj/item/nullrod = 1,
	)
	additional_radio = /obj/item/encryptionkey/heads/hop

/datum/outfit/centcom/ert/chaplain/inquisitor
	name = "Inquisition Chaplain"

	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/chaplain
	backpack_contents = list(
		/obj/item/grenade/chem_grenade/holy = 1,
		/obj/item/nullrod = 1,
	)
	belt = /obj/item/storage/belt/soulstone/full/chappy

/datum/outfit/centcom/ert/janitor
	name = "ERT Janitor"

	id = /obj/item/card/id/advanced/centcom/ert/janitor
	back = /obj/item/mod/control/pre_equipped/responsory/janitor
	box = /obj/item/storage/box/survival/centcom
	backpack_contents = list(
		/obj/item/grenade/clusterbuster/cleaner = 1,
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/mop/advanced = 1,
		/obj/item/reagent_containers/cup/bucket = 1,
		/obj/item/storage/box/lights/mixed = 1,
	)
	belt = /obj/item/storage/belt/janitor/full
	glasses = /obj/item/clothing/glasses/night
	l_pocket = /obj/item/grenade/chem_grenade/cleaner
	r_pocket = /obj/item/grenade/chem_grenade/cleaner
	l_hand = /obj/item/storage/bag/trash/bluespace
	additional_radio = /obj/item/encryptionkey/heads/hop

/datum/outfit/centcom/ert/janitor/heavy
	name = "ERT Janitor - Heavy Duty"

	backpack_contents = list(
		/obj/item/grenade/clusterbuster/cleaner = 3,
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/storage/box/lights/mixed = 1,
	)
	ears = /obj/item/radio/headset/headset_cent/alt/leader
	r_hand = /obj/item/reagent_containers/spray/chemsprayer/janitor

/datum/outfit/centcom/ert/clown
	name = "ERT Clown"

	id = /obj/item/card/id/advanced/centcom/ert/clown
	back = /obj/item/mod/control/pre_equipped/responsory/clown
	box = /obj/item/storage/box/survival/centcom
	backpack_contents = list(
		/obj/item/gun/ballistic/revolver/reverse = 1,
		/obj/item/melee/energy/sword/bananium = 1,
		/obj/item/shield/energy/bananium = 1,
	)
	belt = /obj/item/storage/belt/champion
	glasses = /obj/item/clothing/glasses/trickblindfold
	mask = /obj/item/clothing/mask/gas/clown_hat
	shoes = /obj/item/clothing/shoes/clown_shoes/combat
	l_pocket = /obj/item/food/grown/banana
	r_pocket = /obj/item/bikehorn/golden
	additional_radio = /obj/item/encryptionkey/heads/hop

/datum/outfit/centcom/ert/clown/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	if(visuals_only)
		return
	ADD_TRAIT(H.mind, TRAIT_NAIVE, INNATE_TRAIT)
	H.dna.add_mutation(/datum/mutation/clumsy, MUTATION_SOURCE_CLOWN_CLUMSINESS)

/datum/outfit/centcom/centcom_intern
	name = "CentCom Intern"

	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/intern
	uniform = /obj/item/clothing/under/rank/centcom/intern
	back = /obj/item/storage/backpack/satchel
	box = /obj/item/storage/box/survival
	belt = /obj/item/melee/baton
	ears = /obj/item/radio/headset/headset_cent
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/sneakers/black
	l_pocket = /obj/item/ammo_box/speedloader/strilka310
	r_pocket = /obj/item/ammo_box/speedloader/strilka310
	l_hand = /obj/item/gun/ballistic/rifle/boltaction

/datum/outfit/centcom/centcom_intern/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()
	return ..()

/datum/outfit/centcom/centcom_intern/unarmed
	name = "CentCom Intern (Unarmed)"

	belt = null
	l_pocket = null
	r_pocket = null
	l_hand = null

/datum/outfit/centcom/centcom_intern/leader
	name = "CentCom Head Intern"

	suit = /obj/item/clothing/suit/armor/vest
	suit_store = /obj/item/gun/ballistic/rifle/boltaction
	belt = /obj/item/melee/baton/security/loaded
	head = /obj/item/clothing/head/hats/intern
	l_hand = /obj/item/megaphone

/datum/outfit/centcom/centcom_intern/leader/unarmed // i'll be nice and let the leader keep their baton and vest
	name = "CentCom Head Intern (Unarmed)"

	suit_store = null
	l_pocket = null
	r_pocket = null

/datum/outfit/centcom/ert/janitor/party
	name = "ERP Cleaning Service"

	uniform = /obj/item/clothing/under/misc/overalls
	suit = /obj/item/clothing/suit/apron
	suit_store = null
	back = /obj/item/storage/backpack/ert/janitor
	backpack_contents = list(
		/obj/item/mop/advanced = 1,
		/obj/item/reagent_containers/cup/bucket = 1,
		/obj/item/storage/box/lights/mixed = 1,
	)
	belt = /obj/item/storage/belt/janitor/full
	glasses = /obj/item/clothing/glasses/meson
	mask = /obj/item/clothing/mask/bandana/blue
	l_pocket = /obj/item/grenade/chem_grenade/cleaner
	r_pocket = /obj/item/grenade/chem_grenade/cleaner
	l_hand = /obj/item/storage/bag/trash

/datum/outfit/centcom/ert/security/party
	name = "ERP Bouncer"

	uniform = /obj/item/clothing/under/misc/bouncer
	suit = /obj/item/clothing/suit/armor/vest
	suit_store = null
	back = /obj/item/storage/backpack/ert/security
	backpack_contents = list(
		/obj/item/clothing/head/hats/warden/police = 1,
		/obj/item/storage/box/handcuffs = 1,
	)
	belt = /obj/item/melee/baton/telescopic
	l_pocket = /obj/item/assembly/flash
	r_pocket = /obj/item/storage/wallet

/datum/outfit/centcom/ert/engineer/party
	name = "ERP Constructor"

	uniform = /obj/item/clothing/under/rank/engineering/engineer/hazard
	suit = /obj/item/clothing/suit/hazardvest
	suit_store = null
	back = /obj/item/storage/backpack/ert/engineer
	backpack_contents = list(
		/obj/item/construction/rcd/loaded = 1,
		/obj/item/etherealballdeployer = 1,
		/obj/item/stack/light_w = 30,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/stack/sheet/plasteel/twenty = 1,
	)
	head = /obj/item/clothing/head/utility/hardhat/welding
	mask = /obj/item/clothing/mask/gas/atmos
	l_hand = /obj/item/blueprints

/datum/outfit/centcom/ert/clown/party
	name = "ERP Comedian"

	uniform = /obj/item/clothing/under/rank/civilian/clown
	suit = /obj/item/clothing/suit/chameleon
	suit_store = null
	back = /obj/item/storage/backpack/ert/clown
	backpack_contents = list(
		/obj/item/instrument/piano_synth = 1,
		/obj/item/shield/energy/bananium = 1,
	)
	glasses = /obj/item/clothing/glasses/chameleon
	head = /obj/item/clothing/head/chameleon

/datum/outfit/centcom/ert/commander/party
	name = "ERP Coordinator"

	uniform = /obj/item/clothing/under/misc/coordinator
	suit = /obj/item/clothing/suit/coordinator
	suit_store = null
	back = /obj/item/storage/backpack/ert
	backpack_contents = list(
		/obj/item/food/cake/birthday = 1,
		/obj/item/storage/box/fireworks = 3,
	)
	belt = /obj/item/storage/belt/sheath/sabre
	head = /obj/item/clothing/head/hats/coordinator
	l_pocket = /obj/item/knife/kitchen
	l_hand = /obj/item/toy/balloon

/datum/outfit/centcom/death_commando
	name = "Death Commando"

	id = /obj/item/card/id/advanced/black/deathsquad
	id_trim = /datum/id_trim/centcom/deathsquad
	uniform = /obj/item/clothing/under/rank/centcom/commander
	back = /obj/item/mod/control/pre_equipped/apocryphal
	box = /obj/item/storage/box/survival/centcom
	backpack_contents = list(
		/obj/item/ammo_box/speedloader/c357 = 1,
		/obj/item/flashlight = 1,
		/obj/item/grenade/c4/x4 = 1,
		/obj/item/storage/box/flashbangs = 1,
		/obj/item/storage/medkit/regular = 1,
	)
	belt = /obj/item/gun/ballistic/revolver/mateba
	ears = /obj/item/radio/headset/headset_cent/alt
	glasses = /obj/item/clothing/glasses/hud/toggle/thermal
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	shoes = /obj/item/clothing/shoes/combat/swat
	l_pocket = /obj/item/melee/energy/sword/saber
	r_pocket = /obj/item/shield/energy/advanced
	l_hand = /obj/item/gun/energy/pulse/loyalpin

	skillchips = list(
		/obj/item/skillchip/disk_verifier,
	)

/datum/outfit/centcom/death_commando/post_equip(mob/living/carbon/human/squaddie, visuals_only = FALSE)
	if(visuals_only)
		return

	var/obj/item/radio/radio = squaddie.ears
	radio.set_frequency(FREQ_CENTCOM)
	radio.freqlock = RADIO_FREQENCY_LOCKED
	var/obj/item/card/id/id = squaddie.wear_id
	id.registered_name = squaddie.real_name
	id.update_label()
	id.update_icon()
	return ..()

/datum/outfit/centcom/death_commando/officer
	name = "Death Commando Officer"

	back = /obj/item/mod/control/pre_equipped/apocryphal/officer
	ears = /obj/item/radio/headset/headset_cent/alt/leader

/datum/outfit/centcom/death_commando/officer/post_equip(mob/living/carbon/human/squaddie, visuals_only = FALSE)
	. = ..()
	var/obj/item/mod/control/mod = squaddie.back
	if(!istype(mod))
		return
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	var/obj/item/clothing/head/helmet/space/beret/beret = new(helmet)
	var/datum/component/hat_stabilizer/component = helmet.GetComponent(/datum/component/hat_stabilizer)
	component.attach_hat(beret)
	squaddie.update_clothing(helmet.slot_flags)

/datum/outfit/centcom/ert/marine
	name = "Marine Commander"

	id = /obj/item/card/id/advanced/centcom/ert/commander
	suit = /obj/item/clothing/suit/armor/vest/marine
	suit_store = /obj/item/gun/ballistic/automatic/ar/modular/m44a/grenadelauncher
	back = /obj/item/mod/control/pre_equipped/marine
	belt = /obj/item/storage/belt/military/assault/full/m44a
	ears = /obj/item/radio/headset/headset_cent/alt/leader
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch
	l_pocket = /obj/item/knife/combat
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	uniform = /obj/item/clothing/under/rank/centcom/military
	mask = /obj/item/clothing/mask/gas/sechailer
	head = /obj/item/clothing/head/helmet/marine
	additional_radio = /obj/item/encryptionkey/heads/captain
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer/marine = 1,
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/ammo_box/a40mm = 2,
	)
	l_hand = null
	r_hand = null

/datum/outfit/centcom/ert/marine/security
	name = "Marine Heavy"

	id = /obj/item/card/id/advanced/centcom/ert/security
	suit = /obj/item/clothing/suit/armor/vest/marine/security
	suit_store = /obj/item/gun/ballistic/automatic/ar/modular/m44a/shotgun
	back = /obj/item/mod/control/pre_equipped/marine
	belt = /obj/item/storage/belt/military/assault/full/m44a
	ears = /obj/item/radio/headset/headset_cent/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	head = /obj/item/clothing/head/helmet/marine/security
	additional_radio = /obj/item/encryptionkey/heads/hos
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer/marine = 1,
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/ammo_box/advanced/s12gauge/buckshot = 2,
	)
	l_hand = null
	r_hand = null

	skillchips = null

/datum/outfit/centcom/ert/marine/medic
	name = "Marine Medic"

	id = /obj/item/card/id/advanced/centcom/ert/medical
	suit = /obj/item/clothing/suit/armor/vest/marine/medic
	suit_store = /obj/item/gun/ballistic/automatic/ar/modular/m44a/scoped
	back = /obj/item/mod/control/pre_equipped/marine
	l_pocket = /obj/item/healthanalyzer
	head = /obj/item/clothing/head/helmet/marine/medic
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer/marine = 1,
		/obj/item/reagent_containers/hypospray/combat = 1,
		/obj/item/storage/medkit/regular = 1,
		/obj/item/storage/medkit/advanced = 1,
		/obj/item/sensor_device = 1,
		/obj/item/stack/medical/wrap/gauze/twelve = 1,
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 1,
		/obj/item/stack/medical/wrap/sticky_tape/surgical = 1,
	)
	belt = /obj/item/storage/belt/military/assault/full/m44a
	ears = /obj/item/radio/headset/headset_cent/alt
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	additional_radio = /obj/item/encryptionkey/heads/cmo
	l_hand = /obj/item/gun/medbeam
	r_hand = null

	skillchips = list(/obj/item/skillchip/entrails_reader)

/datum/outfit/centcom/ert/marine/engineer
	name = "Marine Engineer"

	id = /obj/item/card/id/advanced/centcom/ert/engineer
	suit = /obj/item/clothing/suit/armor/vest/marine/engineer
	suit_store = /obj/item/melee/breaching_hammer
	head = /obj/item/clothing/head/helmet/marine/engineer
	back = /obj/item/mod/control/pre_equipped/marine/engineer
	uniform = /obj/item/clothing/under/rank/centcom/military/eng
	belt = /obj/item/storage/belt/utility/full/powertools/rcd
	ears = /obj/item/radio/headset/headset_cent/alt
	glasses = /obj/item/clothing/glasses/hud/diagnostic/sunglasses
	additional_radio = /obj/item/encryptionkey/heads/ce
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer/marine = 1,
		/obj/item/ammo_box/magazine/smartgun_drum = 4,
	)
	l_hand = null
	r_hand = null

	skillchips = list(/obj/item/skillchip/job/engineer)

/datum/outfit/centcom/militia
	name = "Militia Man"

	id = /obj/item/card/id/advanced/centcom/ert/militia
	belt = /obj/item/storage/belt/holster/energy/smoothbore
	suit = /obj/item/clothing/suit/armor/militia
	suit_store = /obj/item/gun/energy/laser/musket
	head = /obj/item/clothing/head/cowboy/black
	uniform = /obj/item/clothing/under/rank/centcom/military
	shoes = /obj/item/clothing/shoes/cowboy
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/satchel/leather
	box = /obj/item/storage/box/survival
	l_pocket = /obj/item/switchblade
	r_pocket = /obj/item/reagent_containers/hypospray/medipen/salacid
	ears = /obj/item/radio/headset
	backpack_contents = list(
		/obj/item/storage/medkit/emergency = 1,
		/obj/item/crowbar = 1,
		/obj/item/restraints/handcuffs = 1,
	)

/datum/outfit/centcom/militia/general
	name = "Militia General"

	id = /obj/item/card/id/advanced/centcom/ert/militia/general
	belt = /obj/item/gun/energy/disabler/smoothbore/prime
	head = /obj/item/clothing/head/beret/militia
	l_hand = /obj/item/megaphone
	suit_store = /obj/item/gun/energy/laser/musket/prime

/datum/outfit/centcom/ert/medical_commander
	name = "Chief EMT"
	id = /obj/item/card/id/advanced/centcom/ert/medical
	uniform = /obj/item/clothing/under/rank/medical/chief_medical_officer
	l_pocket = /obj/item/healthanalyzer/advanced
	shoes = /obj/item/clothing/shoes/sneakers/white
	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/combat = 1,
		/obj/item/storage/medkit/regular = 1,
		/obj/item/storage/medkit/advanced = 1,
		/obj/item/melee/baton/telescopic = 1,
		/obj/item/gun/energy/pulse/pistol/loyalpin = 1,
		/obj/item/stack/medical/poultice = 1, //These stacks contain 15 by default. Great for getting corpses to defib range without surgery.
	)
	belt = /obj/item/storage/belt/medical/ert
	ears = /obj/item/radio/headset/headset_cent/alt
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	additional_radio = /obj/item/encryptionkey/heads/cmo
	mask = /obj/item/clothing/mask/surgical
	back = /obj/item/mod/control/pre_equipped/emergency_medical/corpsman
	gloves = null
	suit = null
	head = null
	suit_store = /obj/item/tank/internals/oxygen

/datum/outfit/centcom/ert/medical_technician
	name = "EMT Paramedic"
	id = /obj/item/card/id/advanced/centcom/ert/medical
	uniform = /obj/item/clothing/under/rank/medical/scrubs/blue
	l_pocket = /obj/item/healthanalyzer
	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/combat = 1,
		/obj/item/storage/medkit/regular = 1,
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 1,
		/obj/item/reagent_containers/medigel/sterilizine = 1,
		/obj/item/bodybag = 2,
	)
	mask = /obj/item/clothing/mask/surgical
	belt = /obj/item/storage/belt/medical/ert
	glasses = /obj/item/clothing/glasses/hud/health
	additional_radio = /obj/item/encryptionkey/heads/cmo
	shoes = /obj/item/clothing/shoes/sneakers/blue
	back = /obj/item/mod/control/pre_equipped/emergency_medical
	gloves = null
	suit = null
	head = null
	suit_store = /obj/item/tank/internals/oxygen

/obj/item/mod/control/pre_equipped/emergency_medical
	theme = /datum/mod_theme/medical
	starting_frequency = MODLINK_FREQ_CENTCOM
	applied_cell = /obj/item/stock_parts/power_store/cell/hyper
	applied_modules = list(
		/obj/item/mod/module/organizer,
		/obj/item/mod/module/defibrillator,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/health_analyzer,
		/obj/item/mod/module/surgical_processor/emergency,
		/obj/item/mod/module/storage/large_capacity,
	)

/obj/item/mod/control/pre_equipped/emergency_medical/corpsman
	theme = /datum/mod_theme/medical/corpsman

///Identical to medical MODsuit, but uses the alternate skin by default.
/datum/mod_theme/medical/corpsman
	default_skin = "corpsman"


// BEGIN NOVA CORE MIGRATION: code/modules/clothing/outfits/ert.dm
/*
*	NOVA MODULAR OUTFITS FILE
*	PUT ANY NEW ERT OUTFITS HERE
*/

/datum/outfit/centcom/asset_protection
	name = "Asset Protection"

	uniform = /obj/item/clothing/under/rank/centcom/commander
	back = /obj/item/mod/control/pre_equipped/apocryphal
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	glasses = /obj/item/clothing/glasses/hud/toggle/thermal
	l_pocket = /obj/item/flashlight
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	belt = /obj/item/storage/belt/security/full
	l_hand = /obj/item/gun/energy/pulse/carbine/loyalpin // if this is still bulky make it not bulky and storable on belt/back/bag/exosuit
	id = /obj/item/card/id/advanced/centcom/ert
	ears = /obj/item/radio/headset/headset_cent/alt

	skillchips = list(/obj/item/skillchip/disk_verifier)

	backpack_contents = list(/obj/item/storage/box/survival/engineer = 1,\
		/obj/item/storage/medkit/regular = 1,\
		/obj/item/storage/box/handcuffs = 1,\
		/obj/item/crowbar/power = 1, // this is their "all access" pass lmao
		)

/datum/outfit/centcom/asset_protection/post_equip(mob/living/carbon/human/person, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/radio/Radio = person.ears
	Radio.set_frequency(FREQ_CENTCOM)
	Radio.freqlock = TRUE
	var/obj/item/card/id/ID = person.wear_id
	ID.assignment = "Asset Protection"
	ID.registered_name = person.real_name
	ID.update_label()
	..()

/datum/outfit/centcom/asset_protection/leader
	name = "Asset Protection Officer"
	head = /obj/item/clothing/head/helmet/space/beret


/// HIGH ALERT SOLFED RERSPONSE
/datum/outfit/solfed/grand_espatier
	name = "SolFed Espatier Rifleman (GRAND RESPONSE)"

	uniform = /obj/item/clothing/under/solfed/marines
	head = /obj/item/clothing/head/helmet/solfed/mk2
	mask = /obj/item/clothing/mask/gas/alt
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/armor/vest/sol/marine/mk2
	shoes = /obj/item/clothing/shoes/jackboots
	belt = /obj/item/storage/belt/military/solfed
	neck = /obj/item/clothing/neck/mantle/solfed
	accessory = null

	back = /obj/item/storage/backpack
	glasses = /obj/item/clothing/glasses/sunglasses/solfed
	ears = /obj/item/radio/headset/headset_solfed/espatier
	l_pocket = /obj/item/tank/internals/emergency_oxygen/double
	r_pocket = /obj/item/flashlight/seclite
	id = /obj/item/card/id/advanced/solfed
	r_hand = /obj/item/gun/ballistic/automatic/sol_rifle
	backpack_contents = list(
		/obj/item/tank/internals/emergency_oxygen/double = 1,
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/storage/box/flashbangs = 1,
		/obj/item/storage/box/nri_flares = 1,
		/obj/item/storage/medkit/frontier/stocked = 1,
	)

	id_trim = /datum/id_trim/solfed/espatier

/datum/outfit/solfed/grand_espatier/engineer
	name = "SolFed Espatier Engineer (GRAND RESPONSE)"
	head = /obj/item/clothing/head/helmet/solfed/mk2/engineer
	belt = /obj/item/storage/belt/utility/full/powertools
	mask = /obj/item/clothing/mask/gas/welding/up
	ears = /obj/item/radio/headset/headset_solfed/espatier/engineer
	backpack_contents = list(
		/obj/item/ammo_box/magazine/c40sol_rifle/standard = 4,
		/obj/item/storage/box/nri_flares = 1,
		/obj/item/storage/box/smart_metal_foam = 1,
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/storage/medkit/frontier/stocked = 1,
	)

/datum/outfit/solfed/grand_espatier/engineer/post_equip(mob/living/carbon/human/person, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/ID = person.wear_id
	ID.assignment = "Solfed Espatier Engineer"
	ID.update_label()
	..()

/datum/outfit/solfed/grand_espatier/corpsman
	name = "SolFed Espatier Corpsman (GRAND RESPONSE)"
	head = /obj/item/clothing/head/helmet/solfed/mk2/corpsman
	ears = /obj/item/radio/headset/headset_solfed/espatier/corpsman
	backpack_contents = list(
		/obj/item/storage/medkit/surgery = 1,
		/obj/item/storage/box/nri_flares = 1,
		/obj/item/storage/medkit/tactical = 1,
	)

/datum/outfit/solfed/espatier/corpsman/post_equip(mob/living/carbon/human/person, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/ID = person.wear_id
	ID.assignment = "Solfed Espatier Corpsman"
	ID.update_label()
	..()

/datum/outfit/solfed/grand_espatier/squadleader
	name = "SolFed Espatier Squad Leader (GRAND RESPONSE)"
	head = /obj/item/clothing/head/helmet/solfed/mk2/squadlead
	ears = /obj/item/radio/headset/headset_solfed/espatier/squadleader

	backpack_contents = list(
		/obj/item/storage/medkit/surgery = 1,
		/obj/item/storage/medkit/tactical_lite = 1,
		/obj/item/ammo_box/magazine/c40sol_rifle/standard = 4,
		/obj/item/storage/box/nri_flares = 1,
		/obj/item/binoculars = 1,
	)

/datum/outfit/solfed/grand_espatier/squadleader/post_equip(mob/living/carbon/human/person, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/ID = person.wear_id
	ID.assignment = "Solfed Espatier Squad Leader"
	ID.update_label()
	..()

/// REGULAR ALERT SOLFED RESPONSE (Used for events/admin shenanagins for lesser threats instead of kill everything)
/datum/outfit/solfed/espatier
	name = "SolFed Espatier Rifleman"

	uniform = /obj/item/clothing/under/solfed/marines
	head = /obj/item/clothing/head/helmet/solfed
	mask = /obj/item/clothing/mask/gas/alt
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/armor/vest/sol/marine
	shoes = /obj/item/clothing/shoes/jackboots
	belt = /obj/item/storage/belt/military/solfed
	neck = /obj/item/clothing/neck/mantle/solfed
	accessory = null

	back = /obj/item/storage/backpack
	glasses = /obj/item/clothing/glasses/sunglasses/solfed
	ears = /obj/item/radio/headset/headset_solfed/espatier
	l_pocket = /obj/item/tank/internals/emergency_oxygen/double
	r_pocket = /obj/item/flashlight/seclite
	id = /obj/item/card/id/advanced/solfed
	r_hand = /obj/item/gun/ballistic/automatic/sol_rifle
	backpack_contents = list(
		/obj/item/tank/internals/emergency_oxygen/double = 1,
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/storage/box/flashbangs = 1,
		/obj/item/storage/box/nri_flares = 1,
		/obj/item/storage/medkit/frontier/stocked = 1,
	)

	id_trim = /datum/id_trim/solfed/espatier

/datum/outfit/solfed/espatier/engineer
	name = "SolFed Espatier Engineer"
	head = /obj/item/clothing/head/helmet/solfed/engineer
	belt = /obj/item/storage/belt/utility/full/powertools
	mask = /obj/item/clothing/mask/gas/welding/up
	ears = /obj/item/radio/headset/headset_solfed/espatier/engineer
	backpack_contents = list(
		/obj/item/ammo_box/magazine/c40sol_rifle/standard = 4,
		/obj/item/storage/box/nri_flares = 1,
		/obj/item/storage/box/smart_metal_foam = 1,
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/storage/medkit/frontier/stocked = 1,
	)

/datum/outfit/solfed/espatier/engineer/post_equip(mob/living/carbon/human/person, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/ID = person.wear_id
	ID.assignment = "Solfed Espatier Engineer"
	ID.update_label()
	..()

/datum/outfit/solfed/espatier/corpsman
	name = "SolFed Espatier Corpsman"
	head = /obj/item/clothing/head/helmet/solfed/corpsman
	ears = /obj/item/radio/headset/headset_solfed/espatier/corpsman
	backpack_contents = list(
		/obj/item/storage/medkit/surgery = 1,
		/obj/item/storage/box/nri_flares = 1,
		/obj/item/storage/medkit/tactical = 1,
	)

/datum/outfit/solfed/espatier/corpsman/post_equip(mob/living/carbon/human/person, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/ID = person.wear_id
	ID.assignment = "Solfed Espatier Corpsman"
	ID.update_label()
	..()

/datum/outfit/solfed/espatier/squadleader
	name = "SolFed Espatier Squad Leader"
	head = /obj/item/clothing/head/helmet/solfed/squadlead
	ears = /obj/item/radio/headset/headset_solfed/espatier/squadleader

	backpack_contents = list(
		/obj/item/storage/medkit/surgery = 1,
		/obj/item/storage/medkit/tactical_lite = 1,
		/obj/item/ammo_box/magazine/c40sol_rifle/standard = 4,
		/obj/item/storage/box/nri_flares = 1,
		/obj/item/binoculars = 1,
	)

/datum/outfit/solfed/espatier/squadleader/post_equip(mob/living/carbon/human/person, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/ID = person.wear_id
	ID.assignment = "Solfed Espatier Squad Leader"
	ID.update_label()
	..()

/datum/outfit/armadyne_rep
	name = "Armadyne Corporate Representative"

	suit_store = /obj/item/modular_computer/pda/security
	ears = /obj/item/radio/headset/headset_cent/commander
	uniform = /obj/item/clothing/under/rank/security/armadyne
	gloves = /obj/item/clothing/gloves/combat/armadyne
	head =  /obj/item/clothing/head/beret/sec/armadyne
	neck = /obj/item/clothing/neck/tie/black
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/armadyne
	suit = /obj/item/clothing/suit/armor/vest/armadyne
	shoes = /obj/item/clothing/shoes/jackboots/armadyne
	belt = /obj/item/storage/belt/security/armadyne
	r_pocket = /obj/item/assembly/flash/handheld
	backpack_contents = list(
		/obj/item/melee/baton/telescopic,
		/obj/item/storage/toolbox/guncase/nova/pistol/trappiste_small_case/skild,
	)
	back = /obj/item/storage/backpack/satchel/leather
	box = /obj/item/storage/box/survival/security
	l_pocket = /obj/item/megaphone/command
	id = /obj/item/card/id/advanced/armadyne/agent

/datum/outfit/armadyne_rep/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	if(W)
		W.registered_name = H.real_name
		W.update_label()
	..()

/datum/outfit/armadyne_security
	name = "Armadyne Corporate Security"

	ears = /obj/item/radio/headset/headset_sec/alt
	uniform = /obj/item/clothing/under/rank/security/armadyne/tactical
	gloves = /obj/item/clothing/gloves/combat/armadyne
	head = /obj/item/clothing/head/helmet
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/armadyne
	mask = /obj/item/clothing/mask/gas/sechailer
	suit = /obj/item/clothing/suit/armor/vest/armadyne/armor
	suit_store = /obj/item/gun/ballistic/automatic/sol_smg
	shoes = /obj/item/clothing/shoes/jackboots/armadyne
	backpack_contents = list(
		/obj/item/storage/toolbox/guncase/nova/pistol/trappiste_small_case/wespe,
		/obj/item/storage/box/handcuffs,
		/obj/item/ammo_box/magazine/c35sol_pistol/stendo,
		/obj/item/modular_computer/pda/security,
	)
	back = /obj/item/storage/backpack/security
	box = /obj/item/storage/box/survival/security
	id = /obj/item/card/id/advanced/armadyne/security

/datum/outfit/armadyne_security/commander
	name = "Armadyne Corporate Security Commander"

	ears = /obj/item/radio/headset/headset_sec/alt
	uniform = /obj/item/clothing/under/rank/security/armadyne/tactical
	gloves = /obj/item/clothing/gloves/combat/armadyne
	head =  /obj/item/clothing/head/beret/sec/armadyne
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/armadyne
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	suit = /obj/item/clothing/suit/armor/vest/armadyne/armor
	suit_store = /obj/item/gun/ballistic/automatic/sol_rifle
	shoes = /obj/item/clothing/shoes/jackboots/armadyne
	belt = /obj/item/storage/belt/security/webbing/armadyne
	backpack_contents = list(
		/obj/item/storage/toolbox/guncase/nova/pistol/trappiste_small_case/wespe,
		/obj/item/storage/box/handcuffs,
		/obj/item/ammo_box/magazine/c40sol_rifle/standard,
		/obj/item/modular_computer/pda/security,
	)
	back = /obj/item/storage/backpack/security
	box = /obj/item/storage/box/survival/security
	l_pocket = /obj/item/megaphone/command
	id = /obj/item/card/id/advanced/armadyne/security

/datum/outfit/armadyne_security/high_alert
	name = "Armadyne Corporate Security (High Alert)"
	belt = /obj/item/storage/belt/security/webbing/armadyne
	suit_store = /obj/item/gun/ballistic/automatic/sol_rifle
	backpack_contents = list(
		/obj/item/melee/baton/telescopic,
		/obj/item/storage/toolbox/guncase/nova/pistol/trappiste_small_case/wespe,
		/obj/item/storage/box/handcuffs,
		/obj/item/ammo_box/magazine/c40sol_rifle/standard = 2,
	)

/datum/outfit/armadyne_security/commander/high_alert
	name = "Armadyne Corporate Security Commander (High Alert)"
	suit_store = /obj/item/gun/ballistic/automatic/sol_rifle
	backpack_contents = list(
		/obj/item/melee/baton/telescopic,
		/obj/item/storage/toolbox/guncase/nova/pistol/trappiste_small_case/skild,
		/obj/item/storage/box/handcuffs,
		/obj/item/ammo_box/magazine/c40sol_rifle/standard = 2,
	)

/datum/outfit/ert
	name = "Default ERT outfit"

/datum/outfit/ert/weedkiller
	name = "Fumigator"
	id = /obj/item/card/id/advanced/centcom/ert
	suit = /obj/item/clothing/suit/apron/waders
	glasses = /obj/item/clothing/glasses/biker
	head = /obj/item/clothing/head/soft/red
	mask = /obj/item/clothing/mask/breathmuzzle/speak
	uniform = /obj/item/clothing/under/rank/civilian/hydroponics
	gloves = /obj/item/clothing/gloves/botanic_leather
	ears = /obj/item/radio/headset/headset_cent/alt
	back = /obj/item/storage/backpack/ert/odst
	backpack_contents = list(
		/obj/item/storage/box/survival,
		/obj/item/hatchet,
		/obj/item/toy/plush/nova/deer,
		/obj/item/reagent_containers/cup/bottle/killer/weedkiller,
		/obj/item/grenade/chem_grenade/antiweed,
	)

/datum/outfit/ert/weedkiller/leader
	name = "Fumigator Leader"
	id = /obj/item/card/id/advanced/centcom/ert
	suit = /obj/item/clothing/suit/bio_suit/scientist
	glasses = /obj/item/clothing/glasses/biker
	head = /obj/item/clothing/head/bio_hood/scientist
	mask = /obj/item/clothing/mask/breathmuzzle/speak
	uniform = /obj/item/clothing/under/rank/civilian/hydroponics
	gloves = /obj/item/clothing/gloves/botanic_leather
	ears = /obj/item/radio/headset/headset_cent/alt
	back = /obj/item/storage/backpack/ert/odst
	backpack_contents = list(
		/obj/item/storage/box/survival,
		/obj/item/melee/tomahawk,
		/obj/item/toy/plush/nova/deer,
		/obj/item/reagent_containers/cup/bottle/killer/weedkiller,
		/obj/item/grenade/chem_grenade/antiweed,
	)

/datum/outfit/centcom/ert/odst
	name = "ODST"
	id = /obj/item/card/id/advanced/centcom/ert
	uniform = /obj/item/clothing/under/syndicate/combat
	glasses = /obj/item/clothing/glasses/hud/security/night
	ears = /obj/item/radio/headset/headset_cent/alt
	gloves = /obj/item/clothing/gloves/combat
	l_hand = /obj/item/gun/ballistic/automatic/sol_rifle/machinegun
	belt = /obj/item/storage/belt/military/odst
	back = /obj/item/mod/control/pre_equipped/responsory/security
	backpack_contents = list(
		/obj/item/storage/box/survival/security,
		/obj/item/melee/baton/security/loaded,
	)
	l_pocket = /obj/item/gun/energy/e_gun/mini
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double

/datum/outfit/centcom/ert/pizza
	name = "Pizza Delivery Boy"
	id = /obj/item/card/id/advanced/centcom/ert
	suit = /obj/item/clothing/suit/toggle/jacket/nova/hoodie/pizza
	glasses = /obj/item/clothing/glasses/regular/modern
	head = /obj/item/clothing/head/soft/red
	mask = /obj/item/clothing/mask/fakemoustache/italian
	uniform = /obj/item/clothing/under/pizza
	ears = /obj/item/radio/headset/headset_cent/alt
	back = /obj/item/storage/backpack/ert/odst
	backpack_contents = list(
		/obj/item/storage/box/survival,
		/obj/item/knife,
		/obj/item/storage/box/ingredients/italian,
	)

/datum/outfit/centcom/ert/pizza/leader
	name = "Pizza Delivery Manager"
	id = /obj/item/card/id/advanced/centcom/ert
	suit = /obj/item/clothing/suit/pizzaleader
	uniform = /obj/item/clothing/under/pizza
	mask = /obj/item/clothing/mask/fakemoustache/italian
	head = /obj/item/clothing/head/pizza
	ears = /obj/item/radio/headset/headset_cent/alt
	back = /obj/item/storage/backpack/ert/odst
	backpack_contents = list(
		/obj/item/storage/box/survival,
		/obj/item/knife/hotknife,
		/obj/item/storage/box/ingredients/italian,
	)

/datum/outfit/centcom/ert/pizza/pre_equip(mob/living/carbon/human/equipped_human, visualsOnly)
	var/list/pizza_list = list(/obj/item/pizzabox/margherita, /obj/item/pizzabox/mushroom, /obj/item/pizzabox/meat, /obj/item/pizzabox/pineapple)
	r_hand = pick(pizza_list)

/datum/outfit/centcom/ert/medic/traumateam
	name = "Trauma Team"
	id = /obj/item/card/id/advanced/centcom/ert/medical/ntrauma
	uniform = /obj/item/clothing/under/rank/medical/paramedic
	suit = /obj/item/clothing/suit/space/ntrauma
	head = /obj/item/clothing/head/helmet/space/ntrauma
	glasses = /obj/item/clothing/glasses/hud/health/night
	ears = /obj/item/radio/headset/headset_cent/alt
	gloves = /obj/item/clothing/gloves/latex/nitrile/ntrauma
	l_hand = /obj/item/gun/energy/e_gun/stun
	r_hand = null
	shoes = /obj/item/clothing/shoes/combat
	belt = /obj/item/storage/belt/medical/ntrauma
	back = /obj/item/storage/backpack/medic
	mask = /obj/item/clothing/mask/breath/medical
	l_pocket = /obj/item/healthanalyzer/advanced
	r_pocket = /obj/item/reagent_containers/hypospray/combat
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded,
		/obj/item/gun/energy/cell_loaded/medigun/upgraded,
		/obj/item/storage/box/plastic/medicells,
		/obj/item/storage/medkit/tactical/ntrauma,
		/obj/item/emergency_bed,
	)

/datum/outfit/centcom/ert/medic/traumateam/leader
	name = "Trauma Team Leader"
	belt = /obj/item/defibrillator/compact/combat/loaded/nanotrasen
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded,
		/obj/item/gun/medbeam,
		/obj/item/storage/medkit/tactical/ntrauma,
		/obj/item/emergency_bed,
		/obj/item/holosign_creator/medical/treatment_zone,
		/obj/item/autosurgeon/syndicate/emaggedsurgerytoolset/single_use,
	)

/obj/item/clothing/mask/breathmuzzle/speak
	name = "fumigator mask"
	desc = "For killing those pesky insects."
	icon_state = "breathmuzzle"
	inhand_icon_state = "breathmuzzle"
	body_parts_covered = NONE
	clothing_flags = MASKINTERNALS

/obj/item/storage/backpack/ert/odst
	name = "odst backpack"
	desc = "A modified backpack that attaches via magnetic harness, removing the need for straps."
	icon = 'icons/obj/clothing/backpacks.dmi'
	icon_state = "ert_odst"
	worn_icon = 'icons/mob/clothing/back_additions.dmi'
	worn_icon_state = "ert_odst"
	inhand_icon_state = "securitypack"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/belt/military/odst
	name = "commando chest rig"
	desc = "A tactical plate carrier."
	icon = 'icons/obj/clothing/belts_additions.dmi'
	worn_icon = 'icons/mob/clothing/belt_additions.dmi'
	icon_state = "ert_odst"
	worn_icon_state = "ert_odst"
	inhand_icon_state = "utility"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/belt/military/odst/PopulateContents()
	new /obj/item/crowbar/red(src)
	new /obj/item/grenade/frag(src)
	new /obj/item/grenade/frag(src)

/obj/item/clothing/head/pizza
	name = "dogginos manager hat"
	desc = "Looks like something a Sol general would wear."
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "dominosleader"

/obj/item/clothing/suit/toggle/jacket/nova/hoodie/pizza
	name = "dogginos hoodie"
	desc = "A hoodie often worn by the delivery boys of this intergalactically known brand of pizza."
	greyscale_colors = "#c40000"

/obj/item/clothing/suit/pizzaleader
	name = "dogginos manager coat"
	desc = "A long, cool, flowing coat in a tasteless red colour."
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "forensics_red_long"

/obj/item/clothing/under/pizza
	name = "dogginos employee uniform"
	desc = "The standard issue for the famous dog-founded pizza brand, Dogginos."
	icon = 'icons/obj/clothing/under/centcom_additions.dmi'
	worn_icon = 'icons/mob/clothing/under/centcom_additions.dmi'
	icon_state = "dominos"

/obj/item/storage/box/plastic/medicells
	name = "box of medicells"
	desc = "A box with a few basic Medicells designed for Vey-Medical CWM cell-powered Mediguns."
	illustration = "medgel"

/obj/item/storage/box/plastic/medicells/PopulateContents()
	. = ..()
	new /obj/item/weaponcell/medical/brute(src)
	new /obj/item/weaponcell/medical/burn(src)
	new /obj/item/weaponcell/medical/toxin/tier_2(src)
	new /obj/item/weaponcell/medical/utility/temperature(src)
	new /obj/item/weaponcell/medical/utility/bed(src)

/datum/id_trim/centcom/ert/medical/ntrauma
	assignment = "Trauma Team Specialist"
	trim_state = "trim_highcleric"
	sechud_icon_state = SECHUD_SCRAMBLED

/obj/item/card/id/advanced/centcom/ert/medical/ntrauma
	registered_name = "Trauma Team Specialist"
	trim = /datum/id_trim/centcom/ert/medical/ntrauma
	icon_state = "battlecruisercaller"
	desc = "A semi-standard, black identification card rigged with what appears to be a small transmitter wired to a small disk, presumably filled with access tokens. Not NT standard, sure, but effectively the same card as their ERTs."

/obj/item/storage/belt/medical/ntrauma
	name = "trauma chest rig"
	desc = "A set of tactical webbing worn by Trauma Response Teams."
	icon = 'icons/obj/clothing/belts_additions.dmi'
	worn_icon = 'icons/mob/clothing/belt_additions.dmi'
	icon_state = "ert_ntrauma"
	worn_icon_state = "ert_ntrauma"

/obj/item/storage/belt/medical/ntrauma/PopulateContents()
	new /obj/item/surgical_drapes(src)
	new /obj/item/scalpel/advanced(src)
	new /obj/item/cautery/advanced(src)
	new /obj/item/retractor/advanced(src)
	new /obj/item/blood_filter/advanced(src)
	new /obj/item/holosign_creator/medical/treatment_zone(src)

/obj/item/storage/medkit/tactical/ntrauma
	name = "trauma medical kit"
	desc = "I hope you've got insurance, because the Trauma Team's premiums are HIGH."

/obj/item/storage/medkit/tactical/ntrauma/PopulateContents()
	new /obj/item/reagent_containers/hypospray/medipen/atropine(src)
	new /obj/item/reagent_containers/hypospray/medipen/atropine(src)
	new /obj/item/stack/medical/wrap/gauze(src)
	new /obj/item/stack/medical/suture/medicated(src)
	new /obj/item/stack/medical/suture/medicated(src)
	new /obj/item/stack/medical/mesh/advanced(src)
	new /obj/item/stack/medical/mesh/advanced(src)
	new /obj/item/sensor_device(src)
	new /obj/item/pinpointer/crew(src)

/obj/item/clothing/gloves/latex/nitrile/ntrauma
	name = "trauma specialist gloves"
	desc = "A pair of nitrile-alternative gloves used by Trauma Team specialists. Sealable to protect from pressure, with a unique acid-repellent coating to prevent damage when handling chemical hazards as well."
	icon = 'icons/obj/clothing/gloves_additions.dmi'
	worn_icon = 'icons/mob/clothing/hands_additions.dmi'
	icon_state = "ert_ntrauma"
	alternate_worn_layer = ABOVE_BODY_FRONT_LAYER
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL

/obj/item/clothing/suit/space/ntrauma
	name = "trauma team softsuit"
	desc = "A lightweight, minimally-armored, and entirely sterile softsuit used by Trauma Teams to operate in potentially hazardous environments of all sorts. It's coated in acid-repellent chemicals."
	icon = 'icons/obj/clothing/suits/spacesuit_additions.dmi'
	worn_icon = 'icons/mob/clothing/suits/spacesuit_additions.dmi'
	worn_icon_digi = 'icons/mob/clothing/suits/spacesuit_digi.dmi'
	icon_state = "ert_ntrauma"
	inhand_icon_state = "syndicate-blue"
	slowdown = 0.3
	armor_type = /datum/armor/space_ntrauma
	resistance_flags = ACID_PROOF
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|FEET
	cell = /obj/item/stock_parts/power_store/cell/hyper
	allowed = list(/obj/item/gun/energy, /obj/item/gun/medbeam, /obj/item/melee/baton, /obj/item/storage/medkit, /obj/item/tank/internals)

/datum/armor/space_ntrauma
	melee = 10
	bullet = 10
	laser = 10
	energy = 10
	bomb = 10
	bio = 100
	fire = 80
	acid = 80

/obj/item/clothing/head/helmet/space/ntrauma
	name = "trauma team helmet"
	desc = "A faceless white helmet fit to seal with a softsuit, used by Trauma Teams to operate in potentially hazardous environments. It's coated in acid-repellent chemicals."
	icon = 'icons/obj/clothing/head/helmet_additions.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet_additions.dmi'
	icon_state = "ert_ntrauma"
	resistance_flags = ACID_PROOF
	supports_variations_flags = NONE
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
// END NOVA CORE MIGRATION: code/modules/clothing/outfits/ert.dm
