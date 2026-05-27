/datum/market_item/clothing
	category = "Clothing"
	abstract_path = /datum/market_item/clothing

/datum/market_item/clothing/ninja_mask
	name = "Space Ninja Mask"
	desc = "Apart from being acid, lava, fireproof and being hard to take off someone it does nothing special on its own."
	item = /obj/item/clothing/mask/gas/ninja

	price_min = CARGO_CRATE_VALUE
	price_max = CARGO_CRATE_VALUE * 2.5
	stock_max = 3
	availability_prob = 40

/datum/market_item/clothing/durathread_vest
	name = "Durathread Vest"
	desc = "Don't let them tell you this stuff is \"Like asbestos\" or \"Pulled from the market for safety concerns\". It could be the difference between a robusting and a retaliation."
	item = /obj/item/clothing/suit/armor/vest/durathread

	price_min = CARGO_CRATE_VALUE
	price_max = CARGO_CRATE_VALUE * 2
	stock_max = 4
	availability_prob = 50

/datum/market_item/clothing/durathread_helmet
	name = "Durathread Helmet"
	desc = "Customers ask why it's called a helmet when it's just made from armoured fabric and I always say the same thing: No refunds."
	item = /obj/item/clothing/head/helmet/durathread

	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE
	stock_max = 4
	availability_prob = 50

/datum/market_item/tool/medsechud
	name = "MedSec HUD"
	desc = "A mostly defunct combination of security and health scanner HUDs. They don't produce these around anymore."
	item = /obj/item/clothing/glasses/hud/medsechud

	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 3.5
	stock_max = 3
	availability_prob = 50

/datum/market_item/clothing/full_spacesuit_set
	name = "\improper Nanotrasen Branded Spacesuit Box"
	desc = "A few boxes of \"Old Style\" space suits fell off the back of a space truck."
	item = /obj/item/storage/box

	price_min = CARGO_CRATE_VALUE * 1.875
	price_max = CARGO_CRATE_VALUE * 4
	stock_max = 3
	availability_prob = 30

/datum/market_item/clothing/full_spacesuit_set/spawn_item(loc)
	var/obj/item/storage/box/B = ..()
	B.name = "Spacesuit Box"
	B.desc = "It has an NT logo on it."
	new /obj/item/clothing/suit/space(B)
	new /obj/item/clothing/head/helmet/space(B)
	return B

/datum/market_item/clothing/chameleon_hat
	name = "Chameleon Hat"
	desc = "Pick any hat you want with this Handy device. Not Quality Tested."
	item = /obj/item/clothing/head/chameleon/broken

	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE
	stock_max = 2
	availability_prob = 70

/datum/market_item/clothing/rocket_boots
	name = "Rocket Boots"
	desc = "We found a pair of jump boots and overclocked the hell out of them. No liability for grievous harm to or with a body."
	item = /obj/item/clothing/shoes/bhop/rocket

	price_min = CARGO_CRATE_VALUE * 5
	price_max = CARGO_CRATE_VALUE * 10
	stock_max = 1
	availability_prob = 40

/datum/market_item/clothing/anti_sec_pin
	name = "Subversive Pin"
	desc = "Exclusive and fashionable red pin from a limited run, proclaiming your allegiance to enemies of the Nanotrasen corporation. \
		Contains an RFID chip which interferes with common scanning equipment, to ensure that they know you are serious. Share them with your friends!"
	item = /obj/item/clothing/accessory/anti_sec_pin

	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE * 1.5
	stock_max = 5
	availability_prob = 70

/datum/market_item/clothing/floortileset
	name = "Floor-tile Camouflage Uniform"
	desc = "Hey there, looking to surprise somebody? Spy? Steal? Then you're lucky, meet our newest \
		floor-tile 'NT SCUM' styled camouflage fatigues. This is the ultimate \
		espionage uniform used by the very best. Providing the best \
		flexibility, with our latest Camo-tech threads. Perfect for \
		risky espionage hallway operations. Enjoy our product!"
	item = /obj/item/storage/box/floor_camo
	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE
	stock_max = 3
	availability_prob = 40
/** Nova Edit Removal
/datum/market_item/clothing/collar_bomb
	name = "Collar Bomb Kit"
	desc = "An unpatented and questionably ethical kit consisting of a low-yield explosive collar and a remote to trigger it."
	item = /obj/item/storage/box/collar_bomb
	price_min = CARGO_CRATE_VALUE * 3.5
	price_max = CARGO_CRATE_VALUE * 4.5
	stock_max = 3
	availability_prob = 60
**/


// BEGIN NOVA CORE MIGRATION: code/modules/cargo/markets/market_items/clothing.dm
//Clothes
/datum/market_item/clothing/combat_uniform
	name = "Combat Uniform"
	desc = "An outfit with so many pockets, you could hardly keep track of what you're keeping and where you're keeping it."
	item = /obj/item/clothing/under/syndicate/combat
	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE
	stock_max = 3
	availability_prob = 65

/datum/market_item/clothing/syndie_turtleneck
	name = "Tactical Turtleneck"
	desc = "A snug syndicate-red turtleneck with charcoal-black cargo pants. Good luck arguing allegiance with this on."
	item = /obj/item/clothing/under/syndicate/nova/tactical
	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE
	stock_max = 3
	availability_prob = 85

/datum/market_item/clothing/syndie_turtleneck_skirt
	name = "Tactical Turtleneck Skirt"
	desc = "A snug syndicate-red skirtleneck with a charcoal-black skirt. Good luck arguing allegiance with this on."
	item = /obj/item/clothing/under/syndicate/nova/tactical/skirt
	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE
	stock_max = 3
	availability_prob = 85

/datum/market_item/clothing/syndie_duffel
	name = "Syndicate Duffelbag"
	desc = "A duffelbag designed by someone who dedicated their whole life to comfort and wearability - wearing this won't slow you down."
	item = /obj/item/storage/backpack/duffelbag/syndie
	price_min = CARGO_CRATE_VALUE
	price_max = CARGO_CRATE_VALUE * 2
	stock_max = 3
	availability_prob = 85

/datum/market_item/clothing/military_belt
	name = "Old Military Belt"
	desc = "A dusty belt which used to fit a military that's no longer active."
	item = /obj/item/storage/belt/military/nri
	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE
	stock_max = 3
	availability_prob = 75

/datum/market_item/clothing/syndie_mask
	name = "Syndicate Mask"
	desc = "A mask seen often on the adversaries of Nanotrasen, and so - they are mass produced and not hard to get your hands on."
	item = /obj/item/clothing/mask/gas/syndicate
	price_min = CARGO_CRATE_VALUE * 0.25
	price_max = CARGO_CRATE_VALUE * 0.5
	stock_min = 2
	stock_max = 6
	availability_prob = 90

/datum/market_item/clothing/full_spacesuit_set_syndie
	name = "Syndicate Branded Spacesuit Box"
	desc = "A handy box that stores a stowable yet sturdy spacesuit, probably way better than the Nanotrasen branded suit."
	item = /obj/item/storage/box/syndie_kit/space_suit
	price_min = CARGO_CRATE_VALUE
	price_max = CARGO_CRATE_VALUE * 1.5
	stock_min = 2
	stock_max = 4
	availability_prob = 85

//Gear
/datum/market_item/clothing/bulletproof_armour
	name = "Bulletproof Armour Vest"
	desc = "A Type III heavy bulletproof vest that excels in protecting the wearer against traditional projectile weaponry, usually owned by security forces."
	item = /obj/item/clothing/suit/armor/bulletproof
	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE
	stock_max = 4
	availability_prob = 75

/datum/market_item/clothing/eye_contacts
	name = "Anti-Flash Eye-Lenses"
	desc = "A pair of lenses, hardly visible to the naked eye - yet they block out flashes perfectly."
	item = /obj/item/syndicate_contacts
	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 4
	stock_max = 3
	availability_prob = 65

/datum/market_item/clothing/syndicate_hairtie
	name = "Syndicate Hair Tie"
	desc = "An inconspicuous hair tie, able to be slung accurately. Useful to get yourself out of a sticky situation."
	item = /obj/item/clothing/head/hair_tie/syndicate
	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE
	stock_max = 3
	availability_prob = 85
// END NOVA CORE MIGRATION: code/modules/cargo/markets/market_items/clothing.dm
