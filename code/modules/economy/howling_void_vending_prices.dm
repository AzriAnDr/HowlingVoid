// Howling Void vending price rebalance.
//
// Crew-facing vending balance is explicit on purpose. Machine defaults set the
// broad category price; item custom_price overrides are used where one machine
// sells both cheap basics and premium or high-impact goods. A stable brand
// variation is applied in vending pricing so similar products still land on
// different shelf prices before the economic price index moves them together.

// Vending price table
/obj/machinery/vending/wardrobe
	default_price = 8
	extra_price = 18

/obj/machinery/vending/sustenance
	default_price = 2
	extra_price = 4

/obj/machinery/vending/hotdog
	default_price = 5
	extra_price = 9

/obj/machinery/vending/dinnerware
	default_price = 4
	extra_price = 8

/obj/machinery/vending/wallmed
	default_price = 4
	extra_price = 10

/obj/machinery/vending/hydronutrients
	default_price = 4
	extra_price = 8

/obj/machinery/vending/engineering
	default_price = 14
	extra_price = 34

/obj/machinery/vending/access
	default_price = 24
	extra_price = 60

/obj/machinery/vending/snack
	default_price = 7
	extra_price = 12

/obj/machinery/vending/cola
	default_price = 6
	extra_price = 11

/obj/machinery/vending/coffee
	default_price = 5
	extra_price = 10

/obj/machinery/vending/cigarette
	default_price = 9
	extra_price = 28

/obj/machinery/vending/clothing
	default_price = 10
	extra_price = 28

/obj/machinery/vending/imported
	default_price = 7
	extra_price = 13

/obj/machinery/vending/imported/tiziran
	default_price = 8
	extra_price = 14

/obj/machinery/vending/imported/yangyu
	default_price = 8
	extra_price = 14

/obj/machinery/vending/sovietsoda
	default_price = 4
	extra_price = 8

/obj/machinery/vending/clothing/bitrunning
	default_price = 12
	extra_price = 20

/obj/machinery/vending/autodrobe
	default_price = 16
	extra_price = 42

/obj/machinery/vending/autodrobe/bitrunning
	default_price = 16
	extra_price = 42

/obj/machinery/vending/games
	default_price = 10
	extra_price = 42

/obj/machinery/vending/donksofttoyvendor
	default_price = 14
	extra_price = 65

/obj/machinery/vending/boozeomat
	default_price = 12
	extra_price = 34

/obj/machinery/vending/dorms
	default_price = 18
	extra_price = 60

/obj/machinery/vending/security
	default_price = 35
	extra_price = 110

/obj/machinery/vending/engivend
	default_price = 18
	extra_price = 55

/obj/machinery/vending/robotics
	default_price = 24
	extra_price = 75

/obj/machinery/vending/modularpc
	default_price = 20
	extra_price = 70

/obj/machinery/vending/tool
	default_price = 10
	extra_price = 55

/obj/machinery/vending/medical
	default_price = 5
	extra_price = 12

/obj/machinery/vending/drugs
	default_price = 10
	extra_price = 22

/obj/machinery/vending/donksnack
	default_price = 8
	extra_price = 16

/obj/machinery/vending/deforest_medvend
	default_price = 12
	extra_price = 70

/obj/machinery/vending/wardrobe/sec_wardrobe
	default_price = 16
	extra_price = 44

/obj/machinery/vending/wardrobe/engi_wardrobe
	default_price = 10
	extra_price = 20

/obj/machinery/vending/wardrobe/atmos_wardrobe
	default_price = 10
	extra_price = 20

/obj/machinery/vending/wardrobe/cargo_wardrobe
	default_price = 9
	extra_price = 18

/obj/machinery/vending/wardrobe/robo_wardrobe
	default_price = 12
	extra_price = 55

/obj/machinery/vending/wardrobe/science_wardrobe
	default_price = 12
	extra_price = 36

/obj/machinery/vending/wardrobe/gene_wardrobe
	default_price = 12
	extra_price = 36

/obj/machinery/vending/wardrobe/jani_wardrobe
	default_price = 8
	extra_price = 16

/obj/machinery/vending/wardrobe/chef_wardrobe
	default_price = 8
	extra_price = 16

/obj/machinery/vending/wardrobe/chap_wardrobe
	default_price = 8
	extra_price = 16

/obj/machinery/vending/barbervend
	default_price = 10
	extra_price = 40

/obj/machinery/vending/imported/nt
	default_price = 5
	extra_price = 10

/obj/machinery/vending/hydroseeds
	default_price = 5
	extra_price = 10

/obj/machinery/vending/access/command
	default_price = 30
	extra_price = 75

/obj/machinery/vending/access/solfed
	default_price = 35
	extra_price = 85

/obj/machinery/vending/assist
	default_price = 4
	extra_price = 8

/obj/machinery/vending/cart
	default_price = 8
	extra_price = 16

/obj/machinery/vending/cytopro
	default_price = 16
	extra_price = 60

/obj/machinery/vending/custom
	default_price = 12
	extra_price = 40

/obj/machinery/vending/magivend
	default_price = 16
	extra_price = 60

/obj/machinery/vending/plasmaresearch
	default_price = 24
	extra_price = 80

/obj/machinery/vending/liberationstation
	default_price = 60
	extra_price = 180

/obj/machinery/vending/toyliberationstation
	default_price = 25
	extra_price = 90

/obj/machinery/vending/runic_vendor
	default_price = 30
	extra_price = 90

/obj/machinery/vending/syndichem
	default_price = 80
	extra_price = 200

/obj/machinery/vending/subtype_vendor
	default_price = 12
	extra_price = 24

/obj/machinery/vending/primitive_catgirl_clothing_vendor
	default_price = 10
	extra_price = 18

/obj/machinery/vending/ashclothingvendor
	default_price = 0
	extra_price = 0

// Basic food and drink cleanup for standard vendors.
/obj/item/reagent_containers/cup/glass/waterbottle
	custom_price = 4

/obj/item/reagent_containers/cup/soda_cans/cola
	custom_price = 6

/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind
	custom_price = 7

/obj/item/reagent_containers/cup/soda_cans/dr_gibb
	custom_price = 6

/obj/item/reagent_containers/cup/soda_cans/starkist
	custom_price = 7

/obj/item/reagent_containers/cup/soda_cans/space_up
	custom_price = 6

/obj/item/reagent_containers/cup/soda_cans/lemon_lime
	custom_price = 5

/obj/item/reagent_containers/cup/soda_cans/sol_dry
	custom_price = 7

/obj/item/reagent_containers/cup/soda_cans/pwr_game
	custom_price = 8

/obj/item/reagent_containers/cup/soda_cans/volt_energy
	custom_price = 10

/obj/item/reagent_containers/cup/glass/bottle/mushi_kombucha
	custom_price = 9

/obj/item/reagent_containers/cup/soda_cans/thirteenloko
	custom_price = 12

/obj/item/reagent_containers/cup/soda_cans/shamblers
	custom_price = 12

/obj/item/reagent_containers/cup/soda_cans/wellcheers
	custom_price = 11

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/nuka_cola
	custom_price = 20

/obj/item/reagent_containers/cup/soda_cans/air
	custom_price = 18

/obj/item/reagent_containers/cup/soda_cans/monkey_energy
	custom_price = 16

/obj/item/reagent_containers/cup/soda_cans/grey_bull
	custom_price = 16

/obj/item/reagent_containers/cup/glass/bottle/rootbeer
	custom_price = 16

/obj/item/reagent_containers/cup/glass/coffee
	custom_price = 5

/obj/item/reagent_containers/cup/glass/mug/tea
	custom_price = 4

/obj/item/reagent_containers/cup/glass/mug/coco
	custom_price = 6

/obj/item/reagent_containers/cup/glass/dry_ramen
	custom_price = 7

/obj/item/storage/box/gum
	custom_price = 4

/obj/item/food/candy
	custom_price = 4

/obj/item/food/chips
	custom_price = 6

/obj/item/food/chips/shrimp
	custom_price = 7

/obj/item/food/cheesiehonkers
	custom_price = 6

/obj/item/food/spacetwinkie
	custom_price = 6

/obj/item/food/cornchips
	custom_price = 6

/obj/item/food/sosjerky
	custom_price = 8

/obj/item/food/no_raisin
	custom_price = 5

/obj/item/food/peanuts
	custom_price = 5

/obj/item/food/cnds
	custom_price = 5

/obj/item/food/semki
	custom_price = 5

/obj/item/food/energybar
	custom_price = 8

/obj/item/food/hot_shots
	custom_price = 8

/obj/item/food/sticko
	custom_price = 6

/obj/item/food/shok_roks
	custom_price = 7

/obj/item/food/syndicake
	custom_price = 14

/obj/item/food/spacers_sidekick
	custom_price = 12

/obj/item/food/pistachios
	custom_price = 10

/obj/item/food/swirl_lollipop
	custom_price = 9

// Tools, engineering, robotics, and computer parts.
/obj/item/stack/cable_coil
	custom_price = 6

/obj/item/crowbar
	custom_price = 11

/obj/item/screwdriver
	custom_price = 8

/obj/item/wrench
	custom_price = 10

/obj/item/wirecutters
	custom_price = 12

/obj/item/weldingtool
	custom_price = 16

/obj/item/analyzer
	custom_price = 14

/obj/item/t_scanner
	custom_price = 14

/obj/item/flashlight
	custom_price = 8

/obj/item/flashlight/glowstick
	custom_price = 3

/obj/item/flashlight/glowstick/red
	custom_price = 3

/obj/item/clothing/ears/earmuffs
	custom_price = 6

/obj/item/storage/belt/utility
	custom_price = 45

/obj/item/multitool
	custom_price = 35

/obj/item/weldingtool/hugetank
	custom_price = 45

/obj/item/clothing/head/utility/welding
	custom_price = 28

/obj/item/clothing/glasses/welding
	custom_price = 18

/obj/item/clothing/glasses/meson/engine
	custom_price = 35

/obj/item/clothing/gloves/color/yellow
	custom_price = 90

/obj/item/clothing/gloves/color/fyellow
	custom_price = 120

/obj/item/multitool/fock
	custom_price = 65

/obj/item/screwdriver/omni_drill
	custom_price = 120

/obj/item/weldingtool/electric/arc_welder
	custom_price = 90

/obj/item/pickaxe/drill/compact
	custom_price = 140

/obj/item/crowbar/large/doorforcer
	custom_price = 95

/obj/item/stock_parts/power_store/cell
	custom_price = 18

/obj/item/stock_parts/power_store/battery
	custom_price = 18

/obj/item/stock_parts/power_store/cell/high
	custom_price = 45

/obj/item/stock_parts/power_store/battery/high
	custom_price = 45

/obj/item/electronics/airlock
	custom_price = 18

/obj/item/electronics/apc
	custom_price = 20

/obj/item/electronics/airalarm
	custom_price = 18

/obj/item/electronics/firealarm
	custom_price = 18

/obj/item/electronics/firelock
	custom_price = 18

/obj/item/grenade/chem_grenade/smart_metal_foam
	custom_price = 35

/obj/item/storage/box/smart_metal_foam
	custom_price = 80

/obj/item/geiger_counter
	custom_price = 25

/obj/item/construction/rcd/loaded
	custom_price = 110

/obj/item/storage/pouch/material
	custom_price = 35

/obj/item/storage/bag/construction
	custom_price = 45

/obj/item/stock_parts/scanning_module
	custom_price = 22

/obj/item/stock_parts/micro_laser
	custom_price = 24

/obj/item/stock_parts/matter_bin
	custom_price = 26

/obj/item/stock_parts/servo
	custom_price = 24

/obj/item/disk/computer
	custom_price = 18

/obj/item/modular_computer/pda
	custom_price = 35

/obj/item/modular_computer/laptop
	custom_price = 90

/obj/item/pai_card
	custom_price = 95

/obj/item/assembly/flash/handheld
	custom_price = 28

/obj/item/assembly/prox_sensor
	custom_price = 24

/obj/item/assembly/signaler
	custom_price = 24

/obj/item/scalpel
	custom_price = 28

/obj/item/circular_saw
	custom_price = 42

/obj/item/bonesetter
	custom_price = 35

/obj/item/tank/internals/anesthetic
	custom_price = 32

// Medical basics, advanced treatment, and DeForest products.
/obj/item/stack/medical/bandage
	custom_price = 4

/obj/item/stack/medical/wrap/gauze
	custom_price = 5

/obj/item/stack/medical/ointment
	custom_price = 5

/obj/item/stack/medical/suture
	custom_price = 8

/obj/item/stack/medical/bone_gel
	custom_price = 12

/obj/item/stack/medical/wrap/sticky_tape/surgical
	custom_price = 10

/obj/item/stack/medical/wrap/sticky_tape/duct
	custom_price = 8

/obj/item/reagent_containers/syringe
	custom_price = 5

/obj/item/reagent_containers/dropper
	custom_price = 3

/obj/item/healthanalyzer/simple
	custom_price = 10

/obj/item/healthanalyzer
	custom_price = 20

/obj/item/wrench/medical
	custom_price = 8

/obj/item/cane/crutch
	custom_price = 12

/obj/item/cane/white
	custom_price = 10

/obj/item/clothing/glasses/eyepatch/medical
	custom_price = 8

/obj/item/storage/box/bandages
	custom_price = 18

/obj/item/storage/box/triage_cards
	custom_price = 8

/obj/item/pinpointer/crew
	custom_price = 45

/obj/item/reagent_containers/hypospray/medipen
	custom_price = 35

/obj/item/storage/belt/medical
	custom_price = 55

/obj/item/sensor_device
	custom_price = 40

/obj/item/storage/medkit/advanced
	custom_price = 90

/obj/item/shears
	custom_price = 45

/obj/item/tourniquet
	custom_price = 12

/obj/item/storage/organbox
	custom_price = 50

/obj/item/reagent_containers/applicator/patch/libital
	custom_price = 19

/obj/item/reagent_containers/applicator/patch/aiuri
	custom_price = 18

/obj/item/reagent_containers/applicator/pill/insulin
	custom_price = 8

/obj/item/reagent_containers/cup/bottle/multiver
	custom_price = 24

/obj/item/reagent_containers/cup/bottle/syriniver
	custom_price = 28

/obj/item/reagent_containers/cup/bottle/calomel
	custom_price = 30

/obj/item/reagent_containers/cup/bottle/epinephrine
	custom_price = 28

/obj/item/reagent_containers/cup/bottle/morphine
	custom_price = 35

/obj/item/reagent_containers/cup/bottle/potass_iodide
	custom_price = 18

/obj/item/reagent_containers/cup/bottle/salglu_solution
	custom_price = 18

/obj/item/reagent_containers/syringe/antiviral
	custom_price = 20

/obj/item/reagent_containers/medigel/libital
	custom_price = 25

/obj/item/reagent_containers/medigel/aiuri
	custom_price = 24

/obj/item/reagent_containers/medigel/sterilizine
	custom_price = 14

/obj/item/reagent_containers/medigel/synthflesh
	custom_price = 60

/obj/item/storage/pill_bottle/psicodine
	custom_price = 60

/obj/item/storage/pill_bottle/sansufentanyl
	custom_price = 95

/obj/item/inhaler/albuterol
	custom_price = 45

/obj/item/stack/medical/wound_recovery
	custom_price = 70

/obj/item/stack/medical/wound_recovery/rapid_coagulant
	custom_price = 65

/obj/item/stack/medical/ointment/red_sun
	custom_price = 14

/obj/item/stack/medical/wrap/gauze/sterilized
	custom_price = 12

/obj/item/stack/medical/suture/coagulant
	custom_price = 14

/obj/item/reagent_containers/hypospray/medipen/deforest
	custom_price = 35

/obj/item/reagent_containers/hypospray/medipen/deforest/morpital
	custom_price = 44

/obj/item/reagent_containers/hypospray/medipen/deforest/lipital
	custom_price = 47

/obj/item/reagent_containers/hypospray/medipen/deforest/calopine
	custom_price = 56

/obj/item/reagent_containers/hypospray/medipen/deforest/lepoturi
	custom_price = 54

/obj/item/reagent_containers/hypospray/medipen/deforest/psifinil
	custom_price = 58

/obj/item/reagent_containers/hypospray/medipen/deforest/synephrine
	custom_price = 85

/obj/item/reagent_containers/hypospray/medipen/deforest/krotozine
	custom_price = 85

/obj/item/reagent_containers/hypospray/medipen/deforest/twitch
	custom_price = 120

/obj/item/reagent_containers/hypospray/medipen/deforest/demoneye
	custom_price = 120

/obj/item/reagent_containers/hypospray/medipen/deforest/aranepaine
	custom_price = 108

/obj/item/reagent_containers/hypospray/medipen/deforest/pentibinin
	custom_price = 110

/obj/item/reagent_containers/hypospray/medipen/deforest/synalvipitol
	custom_price = 112

/obj/item/storage/medkit/civil_defense
	custom_price = 95

/obj/item/storage/medkit/civil_defense/stocked
	custom_price = 140

/obj/item/storage/medkit/civil_defense/comfort/stocked
	custom_price = 120

// Security, access, and weapon-adjacent vending goods.
/obj/item/restraints/handcuffs
	custom_price = 25

/obj/item/restraints/handcuffs/cable/zipties
	custom_price = 14

/obj/item/grenade/flashbang
	custom_price = 60

/obj/item/flashlight/seclite
	custom_price = 20

/obj/item/restraints/legcuffs/bola/energy
	custom_price = 80

/obj/item/clothing/gloves/tackler
	custom_price = 45

/obj/item/holosign_creator/security
	custom_price = 25

/obj/item/gun_maintenance_supplies
	custom_price = 30

/obj/item/storage/box/evidence
	custom_price = 12

/obj/item/clothing/glasses/sunglasses
	custom_price = 30

/obj/item/storage/fancy/donut_box
	custom_price = 18

/obj/item/storage/belt/security/webbing
	custom_price = 70

/obj/item/coin/antagtoken
	custom_price = 150

/obj/item/clothing/head/helmet/blueshirt
	custom_price = 90

/obj/item/clothing/gloves/color/black/security/blu
	custom_price = 55

/obj/item/clothing/suit/armor/vest/blueshirt
	custom_price = 160

/obj/item/grenade/stingbang
	custom_price = 120

/obj/item/watertank/pepperspray
	custom_price = 100

/obj/item/storage/belt/holster/energy
	custom_price = 160

/obj/item/storage/pouch/ammo
	custom_price = 35

/obj/item/storage/barricade
	custom_price = 45

/obj/item/ammo_box/magazine/kineticballs
	custom_price = 55

/obj/item/ammo_box/advanced/kineticballs
	custom_price = 80

/obj/item/ammo_box/magazine/pepperball
	custom_price = 65

/obj/item/ammo_box/advanced/pepperballs
	custom_price = 90

/obj/item/gun/ballistic/automatic/pistol/type207
	custom_price = 350

/obj/item/gun/ballistic/automatic/pistol/pepperball
	custom_price = 260

/obj/item/nifsoft_remover
	custom_price = 90

// Hydroponics and service supplies.
/obj/item/seeds/random
	custom_price = 12

/obj/item/seeds/cannabis
	custom_price = 18

/obj/item/seeds/amanita
	custom_price = 14

/obj/item/seeds/glowshroom
	custom_price = 14

/obj/item/seeds/liberty
	custom_price = 18

/obj/item/reagent_containers/spray/waterflower
	custom_price = 35

/obj/item/cultivator
	custom_price = 10

/obj/item/plant_analyzer
	custom_price = 18

/obj/item/reagent_containers/cup/jerrycan/eznutriment
	custom_price = 12

/obj/item/reagent_containers/cup/jerrycan/left4zed
	custom_price = 16

/obj/item/reagent_containers/cup/jerrycan/robustharvest
	custom_price = 22

/obj/item/reagent_containers/spray/pestspray
	custom_price = 8

/obj/item/secateurs
	custom_price = 14

/obj/item/shovel/spade
	custom_price = 12

/obj/item/storage/bag/plants
	custom_price = 24

/obj/item/soil_sack
	custom_price = 35

/obj/item/soil_sack/vermaculite
	custom_price = 45

/obj/item/soil_sack/gel
	custom_price = 45

// Entertainment, cigarettes, alcohol, and dorm goods.
/obj/item/storage/fancy/cigarettes
	custom_price = 10

/obj/item/storage/fancy/cigarettes/cigpack_candy
	custom_price = 11

/obj/item/storage/fancy/cigarettes/cigpack_uplift
	custom_price = 12

/obj/item/storage/fancy/cigarettes/cigpack_robust
	custom_price = 13

/obj/item/storage/fancy/cigarettes/cigpack_carp
	custom_price = 11

/obj/item/storage/fancy/cigarettes/cigpack_midori
	custom_price = 13

/obj/item/storage/box/matches
	custom_price = 4

/obj/item/lighter/greyscale
	custom_price = 8

/obj/item/storage/fancy/rollingpapers
	custom_price = 5

/obj/item/vape
	custom_price = 30

/obj/item/storage/fancy/cigarettes/cigpack_robustgold
	custom_price = 24

/obj/item/storage/box/gum/nicotine
	custom_price = 16

/obj/item/lighter
	custom_price = 20

/obj/item/storage/fancy/cigarettes/cigars
	custom_price = 35

/obj/item/storage/fancy/cigarettes/cigars/havana
	custom_price = 55

/obj/item/storage/fancy/cigarettes/cigars/cohiba
	custom_price = 60

/obj/item/reagent_containers/vapecart
	custom_price = 22

/obj/item/reagent_containers/vapecart/bluekush
	custom_price = 33

/obj/item/reagent_containers/vapecart/reddiesel
	custom_price = 31

/obj/item/reagent_containers/vapecart/pwrgame
	custom_price = 34

/obj/item/reagent_containers/vapecart/cheese
	custom_price = 30

/obj/item/reagent_containers/vapecart/syndicate
	custom_price = 65

/obj/item/reagent_containers/cup/glass/ice
	custom_price = 2

/obj/item/reagent_containers/cup/soda_cans/beer
	custom_price = 8

/obj/item/reagent_containers/cup/soda_cans/beer/rice
	custom_price = 8

/obj/item/reagent_containers/cup/glass/bottle/champagne
	custom_price = 55

/obj/item/reagent_containers/cup/bottle/ethanol
	custom_price = 65

/obj/item/toy/cards/deck
	custom_price = 10

/obj/item/toy/cards/deck/blank
	custom_price = 8

/obj/item/toy/cards/deck/tarot
	custom_price = 14

/obj/item/storage/crayons
	custom_price = 8

/obj/item/chisel
	custom_price = 12

/obj/item/paint_palette
	custom_price = 12

/obj/item/camera
	custom_price = 30

/obj/item/camera_film
	custom_price = 6

/obj/item/cardpack/resin
	custom_price = 8

/obj/item/cardpack/series_one
	custom_price = 8

/obj/item/storage/toolbox/fishing
	custom_price = 45

/obj/item/fishing_rod/telescopic
	custom_price = 60

/obj/item/fish_tank
	custom_price = 50

/obj/item/skillchip/appraiser
	custom_price = 45

/obj/item/skillchip/master_angler
	custom_price = 65

/obj/item/gun/ballistic/revolver/russian
	custom_price = 260

/obj/item/disk/holodisk
	custom_price = 35

/obj/item/rcl
	custom_price = 100

/obj/item/airlock_painter
	custom_price = 90

/obj/item/melee/skateboard/pro
	custom_price = 65

/obj/item/melee/skateboard/hoverboard
	custom_price = 120

/obj/item/card/emagfake
	custom_price = 12

/obj/item/hot_potato/harmless/toy
	custom_price = 12

/obj/item/toy/sword
	custom_price = 18

/obj/item/toy/foamblade
	custom_price = 18

/obj/item/gun/ballistic/automatic/pistol/toy
	custom_price = 35

/obj/item/gun/ballistic/automatic/toy
	custom_price = 45

/obj/item/gun/ballistic/shotgun/toy
	custom_price = 50

/obj/item/ammo_box/foambox/mini
	custom_price = 8

/obj/item/gun/ballistic/shotgun/toy/crossbow
	custom_price = 65

/obj/item/storage/belt/sheath/katana/toy
	custom_price = 55

/obj/item/ammo_box/foambox/riot/mini
	custom_price = 12

/obj/item/dualsaber/toy
	custom_price = 70

/obj/item/storage/box/fakesyndiesuit
	custom_price = 55

/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted
	custom_price = 80

/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted
	custom_price = 95
