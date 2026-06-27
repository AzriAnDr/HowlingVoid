/datum/market_item/weapon
	category = "Weapons"
	abstract_path = /datum/market_item/weapon

/datum/market_item/weapon/bear_trap
	name = "Bear Trap"
	desc = "Get the janitor back at his own game with this affordable prank kit."
	item = /obj/item/restraints/legcuffs/beartrap

	price_min = CARGO_CRATE_VALUE * 1.5
	price_max = CARGO_CRATE_VALUE * 2.75
	stock_max = 3
	availability_prob = 40

/datum/market_item/weapon/shotgun_dart
	name = "Box of XL Shotgun Darts"
	desc = "These handy darts can be filled up with any chemical and be shot with a shotgun! \
		Prank your friends by shooting them with laughter! \
		Not recommended for commercial use."
	item = /obj/item/storage/box/large_dart

	price_min = CARGO_CRATE_VALUE * 1.375
	price_max = CARGO_CRATE_VALUE * 2.875
	stock_max = 4
	availability_prob = 40

/datum/market_item/weapon/buckshot
	name = "Box of Buckshot Shells"
	desc = "It wasn't easy since buckshot is so heavily taxed nowadays, but we managed to find \
		a large cache of it... somewhere. A word of caution, the stuff may be a tad old."
	stock_max = 7
	availability_prob = 35
	item = /obj/effect/spawner/random/armory/buckshot/sketchy
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/weapon/strilka
	name = "Ammobox of .310 Strilka"
	desc = "Listen, .310 Strilka isn't exactly rare, but if you want it to come through \
		any source that isn't the Third Soviet diehards, then you get what you get. \
		Some of this is the good stuff. Some of it is surplus. We make no promises, okay?"
	stock_max = 7
	availability_prob = 35
	item = /obj/effect/spawner/random/armory/strilka
	price_min = CARGO_CRATE_VALUE
	price_max = CARGO_CRATE_VALUE * 2

/datum/market_item/weapon/sks_kit
	name = "Sakhno SKS semi-automatic rifle"
	desc = "That's right baby, it's a SKS parts kit! Okay, not one of those ancient originals, but it \
		may as well be ancient at this point. Just slap it together in some corner in maint and you've \
		got yourself a fully constructed SKS! It doesn't even jam! Why the fuck did they make those Third \
		Soviet soldiers use the Sakhno M2442 Army anyway? This thing is the shit! That means good. BUY IT."
	item = /obj/item/weaponcrafting/gunkit/sks
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 3
	stock_max = 5
	availability_prob = 90

/datum/market_item/weapon/bone_spear
	name = "Bone Spear"
	desc = "Authentic tribal spear, made from real bones! A steal at any price, especially if you're a caveman."
	item = /obj/item/spear/bonespear

	price_min = CARGO_CRATE_VALUE
	price_max = CARGO_CRATE_VALUE * 1.5
	stock_max = 3
	availability_prob = 60

/datum/market_item/weapon/chainsaw
	name = "Chainsaw"
	desc = "A lumberjack's best friend, perfect for cutting trees or limbs efficiently."
	item = /obj/item/chainsaw

	price_min = CARGO_CRATE_VALUE * 1.75
	price_max = CARGO_CRATE_VALUE * 3
	stock_max = 1
	availability_prob = 35

/datum/market_item/weapon/switchblade
	name = "Switchblade"
	desc = "Tunnel Snakes rule!"
	item = /obj/item/switchblade

	price_min = CARGO_CRATE_VALUE * 1.25
	price_max = CARGO_CRATE_VALUE * 1.75
	stock_max = 3
	availability_prob = 45

/datum/market_item/weapon/carpenter_hammer
	name = "Carpenter hammer"
	desc = "When you really want to look like a psycho..."
	item = /obj/item/carpenter_hammer

	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 1.25
	stock_max = 2
	availability_prob = 65

/datum/market_item/weapon/emp_grenade
	name = "EMP Grenade"
	desc = "Use this grenade for SHOCKING results!"
	item = /obj/item/grenade/empgrenade

	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE * 2
	stock_max = 2
	availability_prob = 50

/datum/market_item/weapon/fisher
	name = "SC/FISHER Saboteur Handgun"
	desc = "A self-recharging, compact pistol that disrupts lights, cameras, APCs, turrets and more, if only temporarily. Also usable in melee."
	item = /obj/item/gun/energy/recharge/fisher

	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 4
	stock_max = 1
	availability_prob = 75

/datum/market_item/weapon/dimensional_bomb
	name = "Multi-Dimensional Bomb Core"
	desc = "A special bomb core, one of a kind, for all your 'terraforming gone wrong' purposes."
	item = /obj/item/bombcore/dimensional
	price_min = CARGO_CRATE_VALUE * 40
	price_max = CARGO_CRATE_VALUE * 50
	stock_max = 1
	availability_prob = 15

/datum/market_item/weapon/giant_wrench_parts
	name = "Big Slappy parts"
	desc = "Cheap illegal Big Slappy parts. The fastest and statistically most dangerous wrench."
	item = /obj/item/weaponcrafting/giant_wrench
	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 5
	stock_max = 1
	availability_prob = 25

/datum/market_item/weapon/liberator
	name = "illegal 3D printer designs"
	desc = "Designs for a dirt cheap 3D printable gun, well known for exploding in unfortunate assistants' hands."
	item = /obj/item/disk/design_disk/liberator
	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 5
	stock_max = 1
	availability_prob = 35

/datum/market_item/weapon/surplus_esword
	name = "Pattern I 'Iaito' Energy Sword"
	desc = "A mass-produced energy sword. It is functionally worse than a milspec energy sword commonly found amongst paramilitary organizations. \
		But hey, better than nothing. Does have some power supply problems, but nothing that a bit of percussive maintenance can't fix."
	item = /obj/item/melee/energy/sword/surplus
	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 5
	stock_max = 2
	availability_prob = 80


// BEGIN NOVA CORE MIGRATION: code/modules/cargo/markets/market_items/weapons.dm
/datum/market_item/weapon/mosin_pro
	name = "Xhihao 'Rengo' Precision Rifle Stock"
	desc = "Sure, it doesn't come with any of the actual bits that go bang, but who's gonna be laughing when you spook 'em with five more rounds?"
	item = /obj/item/crafting_conversion_kit/mosin_pro
	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 4
	stock_max = 3
	availability_prob = 80

/datum/market_item/weapon/ablative_bat
	name = "Ablative Baseball Bat"
	desc = "A baseball bat made completely out of metal, its seller informs you this once belonged to a famous sportsman and won't be sold for cheap..."
	item = /obj/item/melee/baseball_bat/ablative
	price_min = CARGO_CRATE_VALUE * 6
	price_max = CARGO_CRATE_VALUE * 10
	stock_max = 1
	availability_prob = 55

/datum/market_item/weapon/edagger
	name = "Inconspicuous Pen"
	desc = "A seemingly normal pen with some sort of generator installed in the cam (the bit that toggles the tip)."
	item = /obj/item/pen/edagger
	price_min = CARGO_CRATE_VALUE * 3
	price_max = CARGO_CRATE_VALUE * 7
	stock_max = 1
	availability_prob = 25

/datum/market_item/weapon/telescopic_bronze
	name = "Bronze-capped Telescopic Baton"
	desc = "A reinforced telescopic baton, likely stolen from some unfortunate Quartermaster."
	item = /obj/item/melee/baton/telescopic/bronze
	price_min = CARGO_CRATE_VALUE * 8
	price_max = CARGO_CRATE_VALUE * 13
	stock_max = 1
	availability_prob = 45

/datum/market_item/weapon/Assasin_kit
	name = "Assassin Starter Kit"
	desc = "An extremely illegal gun kit that somehow ended up on the black market. Seller claims no responsibility for the contents of the kit, their functionality, or the actions of future owners."
	item = /obj/item/storage/toolbox/guncase/nova/pistol/opfor/makarov
	price_min = CARGO_CRATE_VALUE * 15
	price_max = CARGO_CRATE_VALUE * 25
	stock_max = 1
	availability_prob = 5

/datum/market_item/weapon/hollowpoint9mm
	name = "9mm HP Magazine"
	desc = "8-round magazine of 9mm hollowpoint. Obviously, this is illegally acquired, and likely made to fit into an even more illegal weapon."
	item = /obj/item/ammo_box/magazine/m9mm/hp
	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE * 0.7
	stock_max = 3
	availability_prob = 15

/datum/market_item/weapon/sord
	name = "SORD"
	desc = "This thing is so unspeakably shitty that the only thing more foolish than trying to sell it, is to buy it."
	item = /obj/item/sord
	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE * 0.7
	stock_max = 1
	availability_prob = 100

/datum/market_item/weapon/carrotshiv
	name = "Carrot Shiv"
	desc = "Unlike other carrots, you should probably keep this far away from your eyes."
	item = /obj/item/knife/shiv/carrot
	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE * 0.7
	stock_max = 5
	availability_prob = 75

/datum/market_item/weapon/ultranif
	name = "Blood Steal NIFsoft"
	desc = "Reverse-engineered nanite template smuggled through so many customs and bounty hunters you're lucky to even see one. Won't go for cheap - it took us too much to get them."
	item = /obj/item/disk/nifsoft_uploader/mil_grade/blood_steal
	price_min = CARGO_CRATE_VALUE * 12
	price_max = CARGO_CRATE_VALUE * 24
	availability_prob = 40
	stock_max = 2

// Makes this even more expensive
/datum/market_item/weapon/dimensional_bomb
	price_min = CARGO_CRATE_VALUE * 180
	price_max = CARGO_CRATE_VALUE * 200

/datum/market_item/weapon/milspec_buck
	name = "Mil-Spec Buckshot Box"
	desc = "A standard-sized box of 15 Scarborough-manufactured, hot-loaded buckshot shells, for those with a penchant for grievous bodily harm."
	item = /obj/item/ammo_box/advanced/s12gauge/buckshot/milspec
	price_min = CARGO_CRATE_VALUE * 3
	price_max = CARGO_CRATE_VALUE * 6
	availability_prob = 40
	stock_max = 3

/datum/market_item/weapon/milspec_slugs
	name = "Mil-Spec Slug Box"
	desc = "A standard-sized box of 15 Scarborough-manufactured, hot-loaded slug shells, for those with a penchant for grievous bodily harm."
	item = /obj/item/ammo_box/advanced/s12gauge/milspec
	price_min = CARGO_CRATE_VALUE * 3
	price_max = CARGO_CRATE_VALUE * 6
	availability_prob = 40
	stock_max = 3

/datum/market_item/weapon/wt550
	name = "WT-550 Autorifle"
	desc = "*!&@#FANCY SEEING YOU HERE, AGENT! YOU KNOW THE OFFER - AN AUTORIFLE, FOR YOUR USE AND ENJOYMENT!#@*$"
	item = /obj/item/gun/ballistic/automatic/wt550
	price_min = CARGO_CRATE_VALUE * 0.75
	price_max = CARGO_CRATE_VALUE * 3
	stock_max = 3
	availability_prob = 60

/datum/market_item/weapon/wt550/ammo
	name = "WT-550 Autorifle Ammunition"
	desc = "'Enumerate with your WT-550: Projectile Thrown Weapon. Container has 6 REAL WT-550 Magazine Ammunitions and hours of fun!'"
	item = /obj/item/storage/toolbox/ammobox/wt550
	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 5
	stock_max = 4
	stock_min = 2
	availability_prob = 90
// END NOVA CORE MIGRATION: code/modules/cargo/markets/market_items/weapons.dm
