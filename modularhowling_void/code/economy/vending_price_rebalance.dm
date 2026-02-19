// Howling Void pricing doctrine:
// 1) Basic survival is accessible.
// 2) Comfort costs more.
// 3) Luxury hurts.
// 4) Weapons and advanced equipment are expensive and limited.
// 5) Routine medicine should not bankrupt.
// 6) Advanced medicine should be noticeably pricier.

// Basic survival
/obj/machinery/vending/wardrobe // Fallback for all drobes not explicitly overridden below
	default_price = 16
	extra_price = 28

/obj/machinery/vending/sustenance
	default_price = 8
	extra_price = 5

/obj/machinery/vending/hotdog
	default_price = 12
	extra_price = 20

/obj/machinery/vending/dinnerware // Plasteel Chef's Dinnerware Vendor
	default_price = 9
	extra_price = 16

/obj/machinery/vending/wallmed
	default_price = 8
	extra_price = 18

/obj/machinery/vending/hydronutrients
	default_price = 8
	extra_price = 14

/obj/machinery/vending/engineering
	default_price = 20
	extra_price = 34

/obj/machinery/vending/access // command/faction access-vendors fallback
	default_price = 24
	extra_price = 40

// Comfort
// Getmore Chocolate Corp
/obj/machinery/vending/snack
	default_price = 16
	extra_price = 26

/obj/machinery/vending/cola
	default_price = 14
	extra_price = 24

/obj/machinery/vending/coffee
	default_price = 12
	extra_price = 20

/obj/machinery/vending/cigarette
	default_price = 18
	extra_price = 28

/obj/machinery/vending/clothing
	default_price = 20
	extra_price = 30

// Imported snack/meal vendors (Nova)
/obj/machinery/vending/imported
	default_price = 14
	extra_price = 24

// Tizirian Imported Delicacies
/obj/machinery/vending/imported/tiziran
	default_price = 16
	extra_price = 26

// Fudobenda
/obj/machinery/vending/imported/yangyu
	default_price = 16
	extra_price = 26

// BODA
/obj/machinery/vending/sovietsoda
	default_price = 10
	extra_price = 18

// Explicit subtype override to ensure map/vendor variants pick up the same pricing.
/obj/machinery/vending/clothing/bitrunning
	default_price = 20
	extra_price = 30

// Luxury
/obj/machinery/vending/autodrobe
	default_price = 35
	extra_price = 50

// Explicit subtype override to ensure map/vendor variants pick up the same pricing.
/obj/machinery/vending/autodrobe/bitrunning
	default_price = 35
	extra_price = 50

/obj/machinery/vending/games
	default_price = 24
	extra_price = 36

/obj/machinery/vending/donksofttoyvendor
	default_price = 28
	extra_price = 42

/obj/machinery/vending/boozeomat
	default_price = 26
	extra_price = 44

// LustWish is a separate machine path in Nova.
/obj/machinery/vending/dorms
	default_price = 24
	extra_price = 42

// Weapons and advanced equipment
/obj/machinery/vending/security
	default_price = 28
	extra_price = 48

/obj/machinery/vending/engivend
	default_price = 26
	extra_price = 44

/obj/machinery/vending/robotics
	default_price = 34
	extra_price = 58

/obj/machinery/vending/modularpc
	default_price = 28
	extra_price = 48

/obj/machinery/vending/tool
	default_price = 20
	extra_price = 36

// Medicine
/obj/machinery/vending/medical
	default_price = 10
	extra_price = 18

/obj/machinery/vending/drugs
	default_price = 18
	extra_price = 30

// Explicit machine mappings requested for station pricing pass
/obj/machinery/vending/donksnack // Donk Co Vendor
	default_price = 18
	extra_price = 32

/obj/machinery/vending/deforest_medvend // DeForest Med-Vend
	default_price = 14
	extra_price = 28

/obj/machinery/vending/wardrobe/sec_wardrobe // SecDrobe
	default_price = 24
	extra_price = 40

/obj/machinery/vending/wardrobe/engi_wardrobe // EngiDrobe
	default_price = 18
	extra_price = 30

/obj/machinery/vending/wardrobe/atmos_wardrobe // AtmosDrobe
	default_price = 18
	extra_price = 30

/obj/machinery/vending/wardrobe/cargo_wardrobe // CargoDrobe
	default_price = 18
	extra_price = 30

/obj/machinery/vending/wardrobe/robo_wardrobe // RoboDrobe
	default_price = 20
	extra_price = 34

/obj/machinery/vending/wardrobe/science_wardrobe // SciDrobe
	default_price = 20
	extra_price = 34

/obj/machinery/vending/wardrobe/gene_wardrobe // GeneDrobe
	default_price = 20
	extra_price = 34

/obj/machinery/vending/wardrobe/jani_wardrobe // JaniDrobe
	default_price = 16
	extra_price = 28

/obj/machinery/vending/wardrobe/chef_wardrobe // ChefDrobe
	default_price = 16
	extra_price = 28

/obj/machinery/vending/wardrobe/chap_wardrobe // DeusVend
	default_price = 16
	extra_price = 28

/obj/machinery/vending/barbervend // Fab-O-Vend
	default_price = 24
	extra_price = 40

/obj/machinery/vending/imported/nt // NT Sustenance Supplier
	default_price = 12
	extra_price = 20

/obj/machinery/vending/hydroseeds // MegaSeed Servitor
	default_price = 10
	extra_price = 18

/obj/machinery/vending/access/command // CommDrobe / Command
	default_price = 26
	extra_price = 44

/obj/machinery/vending/access/solfed // SolfedDrobe
	default_price = 28
	extra_price = 48

/obj/machinery/vending/assist // Assist
	default_price = 10
	extra_price = 16

/obj/machinery/vending/cart // Cart
	default_price = 12
	extra_price = 20

/obj/machinery/vending/cytopro // CytoPro
	default_price = 16
	extra_price = 30

/obj/machinery/vending/custom // Custo / custom machine
	default_price = 20
	extra_price = 32

/obj/machinery/vending/magivend
	default_price = 28
	extra_price = 48

/obj/machinery/vending/plasmaresearch
	default_price = 26
	extra_price = 44

/obj/machinery/vending/liberationstation
	default_price = 40
	extra_price = 70

/obj/machinery/vending/toyliberationstation
	default_price = 30
	extra_price = 54

/obj/machinery/vending/runic_vendor
	default_price = 34
	extra_price = 60

/obj/machinery/vending/syndichem
	default_price = 45
	extra_price = 80

/obj/machinery/vending/subtype_vendor
	default_price = 20
	extra_price = 32

/obj/machinery/vending/primitive_catgirl_clothing_vendor
	default_price = 20
	extra_price = 30

/obj/machinery/vending/ashclothingvendor // Ashland Clothing Storage
	default_price = 0
	extra_price = 0
