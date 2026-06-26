//the suit voucher
/obj/item/suit_voucher
	name = "suit voucher"
	desc = "A token to redeem a new suit. Use it on a mining equipment vendor."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_voucher"
	w_class = WEIGHT_CLASS_TINY


/datum/voucher_set/mining_suits/seva
	name = "SEVA Suit"
	description = "Contains a whole new mining starter kit for one crewmember, consisting of a proto-kinetic accelerator, a survival knife, a seclite, an explorer's suit, mesons, an automatic mining scanner, a mining satchel, a gas mask, a mining radio key and a special ID card with a basic mining access."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "seva"
	set_items = list(
		/obj/item/clothing/suit/hooded/seva,
		/obj/item/clothing/mask/gas/seva,
	)

/datum/voucher_set/mining_suits/explorer
	name = "Explorer Suit"
	description = "Contains a whole new mining starter kit for one crewmember, consisting of a proto-kinetic accelerator, a survival knife, a seclite, an explorer's suit, mesons, an automatic mining scanner, a mining satchel, a gas mask, a mining radio key and a special ID card with a basic mining access."
	icon = 'icons/obj/clothing/suits/utility.dmi'
	icon_state = "explorer"
	set_items = list(
		/obj/item/clothing/suit/hooded/explorer,
		/obj/item/clothing/mask/gas/explorer,
	)

/datum/voucher_set/mining_suits/carota
	name = "Bunny Suit"
	description = "Designed for Miners on the planet of Carota, while you might get some odd looks from your co-workers, decency is a foreign word around here."
	icon = 'icons/mob/simple/rabbit.dmi'
	icon_state = "rabbit_white"
	set_items = list(
		/obj/item/clothing/head/playbunnyears/miner,
		/obj/item/clothing/neck/tie/bunnytie/miner,
		/obj/item/clothing/suit/jacket/tailcoat/miner,
		/obj/item/clothing/under/rank/cargo/miner/bunnysuit,
		/obj/item/clothing/shoes/workboots/mining/heeled,
		/obj/item/clothing/mask/gas/explorer,
	)

/obj/machinery/computer/order_console/mining/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/voucher_redeemer, /obj/item/suit_voucher, /datum/voucher_set/mining_suits)
