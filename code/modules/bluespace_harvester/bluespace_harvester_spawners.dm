/**
 * Bluespace Harvester Random Spawners
 *
 * Various loot pools for the harvester rewards.
 */

/obj/effect/spawner/random/bluespace_tap
	name = "bluespace harvester reward spawner"

/obj/effect/spawner/random/bluespace_tap/clothes_common
	name = "exotic common clothing"
	loot = list(
		/obj/item/clothing/head/collectable/chef,
		/obj/item/clothing/head/collectable/paper,
		/obj/item/clothing/head/collectable/tophat,
		/obj/item/clothing/head/collectable/captain,
		/obj/item/clothing/head/collectable/beret,
		/obj/item/clothing/head/collectable/welding,
		/obj/item/clothing/head/collectable/flatcap,
		/obj/item/clothing/head/collectable/pirate,
		/obj/item/clothing/head/costume/crown/fancy,
		/obj/item/clothing/head/collectable/wizard,
		/obj/item/clothing/head/collectable/hardhat,
		/obj/item/clothing/head/collectable/hos,
		/obj/item/clothing/head/collectable/thunderdome,
		/obj/item/clothing/head/collectable/swat,
		/obj/item/clothing/head/collectable/slime,
		/obj/item/clothing/head/collectable/police,
		/obj/item/clothing/head/collectable/xenom,
		/obj/item/clothing/head/collectable/petehat,
		/obj/item/clothing/under/costume/jabroni,
	)

/obj/effect/spawner/random/bluespace_tap/clothes_uncommon
	name = "exotic uncommon clothing"
	loot = list(
		/obj/item/clothing/head/collectable/kitty,
		/obj/item/clothing/head/collectable/rabbitears,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/clothing/suit/armor/riot,
		/obj/item/clothing/suit/armor/vest/alt,
		/obj/item/clothing/suit/armor/bulletproof,
		/obj/item/clothing/suit/hooded/cloak/goliath,
		/obj/item/clothing/under/chameleon,
		/obj/item/clothing/glasses/chameleon,
		/obj/item/clothing/gloves/chameleon,
		/obj/item/clothing/head/chameleon,
		/obj/item/clothing/mask/chameleon,
		/obj/item/clothing/shoes/chameleon,
		/obj/item/storage/belt/chameleon,
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/helmet/toggleable/riot,
		/obj/item/clothing/head/helmet/alt,
	)

/obj/effect/spawner/random/bluespace_tap/clothes_rare
	name = "exotic rare clothing"
	loot = list(
		/obj/item/clothing/suit/armor/laserproof,
		/obj/item/clothing/suit/hooded/cloak/drake,
		/obj/item/clothing/head/helmet/swat,
		/obj/item/mod/control/pre_equipped/standard,
		/obj/item/mod/control/pre_equipped/engineering,
		/obj/item/mod/control/pre_equipped/atmospheric,
		/obj/item/mod/control/pre_equipped/loader,
		/obj/item/mod/control/pre_equipped/mining,
		/obj/item/mod/control/pre_equipped/rescue,
		/obj/item/mod/control/pre_equipped/security,
		/obj/item/mod/control/pre_equipped/cosmohonk,
	)

/obj/effect/spawner/random/bluespace_tap/cultural_common
	name = "common cultural artifacts"
	loot = list(
		/obj/item/grenade/clusterbuster,
		/obj/item/stack/sheet/mineral/abductor,
		/obj/item/toy/balloon/syndicate,
		/obj/item/lighter/greyscale,
		/obj/item/clothing/head/costume/kitty,
		/obj/item/coin/antagtoken,
		/obj/item/bedsheet/patriot,
		/obj/item/bedsheet/rainbow,
		/obj/item/bedsheet/captain,
		/obj/item/bikehorn/golden,
		/obj/item/toy/sword,
		/obj/item/toy/foamblade,
		/obj/item/stack/sheet/mineral/bananium,
	)

/obj/effect/spawner/random/bluespace_tap/cultural_uncommon
	name = "uncommon cultural artifacts"
	loot = list(
		/obj/item/gun/ballistic/automatic/c20r/toy,
		/obj/item/dualsaber/toy,
		/obj/item/bedsheet/syndie,
		/obj/item/bedsheet/cult,
		/obj/item/clothing/gloves/combat,
		/obj/item/storage/box/syndicate/bundle_a,
		/obj/item/wrench/brass,
		/obj/item/crowbar/brass,
		/obj/item/screwdriver/brass,
		/obj/item/weldingtool/experimental/brass,
		/obj/item/wirecutters/brass,
	)

/obj/effect/spawner/random/bluespace_tap/cultural_rare
	name = "rare cultural artifacts"
	loot = list(
		/obj/item/gun/ballistic/automatic/l6_saw/toy,
		/obj/item/bedsheet/centcom,
		/obj/item/cigarette/cigar,
		/obj/item/melee/baseball_bat/homerun,
		/obj/item/mod/module/dispenser,
		/obj/item/storage/belt/utility/full,
	)

/obj/effect/spawner/random/bluespace_tap/organic_common
	name = "common organic objects"
	loot = list(
		/obj/item/soap/syndie,
		/obj/item/seeds/random,
		/obj/item/organ/monster_core/regenerative_core,
		/obj/item/reagent_containers/cup/bottle/epinephrine,
		/obj/item/reagent_containers/cup/bottle/strange_reagent,
	)

/obj/effect/spawner/random/bluespace_tap/organic_uncommon
	name = "uncommon organic objects"
	loot = list(
		/obj/item/organ/alien/plasmavessel,
		/obj/item/organ/alien/acid,
		/obj/item/organ/alien/hivenode,
		/obj/item/organ/alien/neurotoxin,
		/obj/item/organ/alien/resinspinner,
		/obj/item/organ/alien/eggsac,
		/obj/item/slimepotion/fireproof,
	)

/obj/effect/spawner/random/bluespace_tap/organic_rare
	name = "rare organic objects"
	loot = list(
		/obj/item/food/grown/cherry_bomb,
		/obj/item/implanter/storage,
		/obj/item/slimepotion/sentience,
		/obj/item/slimepotion/transference,
	)

/obj/effect/spawner/random/bluespace_tap/food_common
	name = "common fancy food"
	loot = list(
		/obj/item/food/hotdog,
		/obj/item/food/cookie,
		/obj/item/food/pie/meatpie,
		/obj/item/food/pie/appletart,
		/obj/item/food/burrito,
		/obj/item/food/burger/fish,
		/obj/item/food/cubancarp,
		/obj/item/food/fishandchips,
		/obj/item/food/fortunecookie,
		/obj/item/food/cookie/sugar,
		/obj/item/food/pie/plain,
		/obj/item/food/donut/plain,
		/obj/item/food/pancakes,
		/obj/item/food/chawanmushi,
		/obj/item/food/kebab/tofu,
		/obj/item/food/donkpocket/warm,
		/obj/item/food/tatortot,
		/obj/item/food/waffles,
	)

/obj/effect/spawner/random/bluespace_tap/food_uncommon
	name = "uncommon fancy food"
	loot = list(
		/obj/item/food/cake/cheese,
		/obj/item/food/cake/birthday,
		/obj/item/food/cake/chocolate,
		/obj/item/food/bread/xenomeat,
		/obj/item/food/pie/amanita_pie,
		/obj/item/food/pie/xemeatpie,
		/obj/item/food/pie/pumpkinpie,
		/obj/item/food/donut/chaos,
		/obj/item/food/pizzaslice/meat,
		/obj/item/food/burger/xeno,
		/obj/item/food/burger/spell,
		/obj/item/food/burger/superbite,
		/obj/item/food/burger/crazy,
		/obj/item/food/baguette,
		/obj/item/food/waffles,
	)

/obj/effect/spawner/random/bluespace_tap/food_rare
	name = "rare fancy food"
	loot = list(
		/obj/item/food/burger/brain,
		/obj/item/food/burger/ghost,
		/obj/item/food/burger/human,
		/obj/item/food/sandwich/notasandwich,
		/obj/item/storage/box/papersack,
		/obj/item/food/donkpocket/gondola,
		/obj/item/food/baguette/combat,
	)