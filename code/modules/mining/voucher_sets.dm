/**
 * # Voucher Set
 *
 * A set consisting of a various equipment that can be then used as a reward for redeeming a voucher.
 *
 * See [Voucher Redeemer](/datum/element/voucher_redeemer) for where these sets are handled.
 */
/datum/voucher_set
	/// Required, Name of the set.
	var/name
	/// Optional, description of the set
	var/description
	/// Optional, Icon of the set. Defaults to first item if not set.
	var/icon
	/// Optional, Icon state of the set. Defaults to first item if not set.
	var/icon_state
	/// Required, List of items contained in the set
	var/list/atom/set_items
	/// Optional, what key to use for blackbox feedback. No data will be recorded if not set.
	var/blackbox_key

/datum/voucher_set/New()
	. = ..()
	if(!length(set_items))
		stack_trace("Voucher set [type] has no items set.")
		return
	if(isnull(icon))
		icon = initial(set_items[1].icon)
	if(isnull(icon_state))
		icon_state = initial(set_items[1].icon_state)
	if(isnull(name))
		stack_trace("Voucher set [type] has no name set.")

/datum/voucher_set/proc/spawn_set(atom/spawn_loc)
	for(var/item in set_items)
		new item(spawn_loc)

/datum/voucher_set/mining
	blackbox_key = "mining_voucher_redeemed"

/datum/voucher_set/mining_suits/seva
	name = "SEVA Suit"
	description = "Contains a SEVA suit and mask for exploring hot environments."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "seva"
	set_items = list(
		/obj/item/clothing/suit/hooded/seva,
		/obj/item/clothing/mask/gas/seva,
	)

/datum/voucher_set/mining_suits/explorer
	name = "Explorer Suit"
	description = "Contains an explorer's suit and gas mask."
	icon = 'icons/obj/clothing/suits/utility.dmi'
	icon_state = "explorer"
	set_items = list(
		/obj/item/clothing/suit/hooded/explorer,
		/obj/item/clothing/mask/gas/explorer,
	)

/datum/voucher_set/mining_suits/carota
	name = "Bunny Suit"
	description = "Designed for miners on the planet of Carota. You might get some odd looks from your co-workers."
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

/datum/voucher_set/mining/crusher_kit
	name = "Crusher Kit"
	description = "Contains a crusher conversion kit and a pocket fire extinguisher. The conversion kit will transform into a proto-kinetic crusher variant of one's choice, giving a versatile melee mining tool capable both of mining and fighting local fauna. It is difficult to use effectively for anyone but most skilled and/or suicidal miners."
	icon = 'icons/obj/weapons/crusher_conversion_kit.dmi'
	icon_state = "crusher_kit"
	set_items = list(
		/obj/item/crusher_conversion_kit,
		/obj/item/extinguisher/mini,
	)

/datum/voucher_set/mining/extraction_kit
	name = "Extraction and Rescue Kit"
	description = "Contains a fulton extraction pack and a beacon signaller, which allows you to send back home minerals, items and dead bodies without having to use the mining shuttle. And as a bonus, you get 30 marker beacons to help you better mark your path."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_pack"
	set_items = list(
		/obj/item/extraction_pack,
		/obj/item/fulton_core,
		/obj/item/stack/marker_beacon/thirty,
	)

/datum/voucher_set/mining/resonator_kit
	name = "Resonator Kit"
	description = "Contains a resonator and a pocket fire extinguisher. Resonator is a handheld device that creates small fields of energy that resonate until they detonate, crushing rock. It does increased damage in low pressure."
	icon = 'icons/obj/mining.dmi'
	icon_state = "resonator"
	set_items = list(
		/obj/item/resonator,
		/obj/item/extinguisher/mini,
	)

/datum/voucher_set/mining/survival_capsule
	name = "Survival Capsule and Explorer's Webbing"
	description = "Contains an explorer's webbing, which allows you to carry even more mining equipment and already has a spare shelter capsule in it. It also comes with a set of Kheiral Cuffs to extend the range of sensors."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "explorer1"
	set_items = list(
		/obj/item/storage/belt/mining/vendor,
		/obj/item/clothing/accessory/kheiral_cuffs,
	)

/datum/voucher_set/mining/minebot_kit
	name = "Minebot Kit"
	description = "Contains a little minebot companion that helps you in storing ore and hunting wildlife. Also comes with an upgraded industrial welding tool (80u), a welding mask and a KA modkit that allows shots to pass through the minebot."
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "mining_drone"
	set_items = list(
		/mob/living/basic/mining_drone,
		/obj/item/weldingtool/hugetank,
		/obj/item/clothing/head/utility/welding,
		/obj/item/borg/upgrade/modkit/minebot_passthrough,
	)

/datum/voucher_set/mining/conscription_kit
	name = "Mining Conscription Kit"
	description = "Contains a whole new mining starter kit for one crewmember, consisting of a proto-kinetic accelerator, a survival knife, a seclite, an explorer's suit, mesons, an automatic mining scanner, a mining satchel, a gas mask, a mining radio key and a special ID card with a basic mining access."
	icon = 'icons/obj/storage/backpack.dmi'
	icon_state = "duffel-explorer"
	set_items = list(
		/obj/item/storage/backpack/duffelbag/mining_conscript,
	)

/datum/voucher_set/mining/punching_mitts
	name = "Punching Mitts"
	description = "Contains a pair of punching mitts for turning the local wilderness into the local gravel pit with your BARE HANDS."
	icon = 'icons/obj/clothing/gloves.dmi'
	icon_state = "punch_mitts"
	set_items = list(
		/obj/item/clothing/gloves/fingerless/punch_mitts,
		/obj/item/clothing/head/cowboy,
	)

/datum/voucher_set/mining/bunny
	name = "Bunny Conscription Kit"
	description = "Designed for Miners on the planet of Carota, this kit includes all you need to imitate them! Weapons sold separately."
	icon = 'icons/mob/simple/rabbit.dmi'
	icon_state = "rabbit_white"
	set_items = list(
		/obj/item/storage/backpack/duffelbag/mining_bunny/conscript,
	)
