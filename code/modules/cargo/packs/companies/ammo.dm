/datum/supply_pack/companies/mags_and_ammo
	group = "★ Magazines and Ammo"
	discountable = SUPPLY_PACK_NOT_DISCOUNTABLE

// Sol fed Mags -  These supplant the NT ones

/datum/supply_pack/companies/mags_and_ammo/sol_fed
	cost = CARGO_CRATE_VALUE * 0.25

/datum/supply_pack/companies/mags_and_ammo/sol_fed/dumdum38
	name = ".38 DumDum Speedloader Single-Pack"
	desc = "Contains one speedloader of .38 DumDum ammunition, good for embedding in soft targets."
	contains = list(/obj/item/ammo_box/speedloader/c38/dumdum)
	auto_name = FALSE

/datum/supply_pack/companies/mags_and_ammo/sol_fed/match38
	name = ".38 Match Grade Speedloader Single-Pack"
	desc = "Contains one speedloader of match grade .38 ammunition, perfect for showing off trickshots."
	contains = list(/obj/item/ammo_box/speedloader/c38/match)
	auto_name = FALSE

/datum/supply_pack/companies/mags_and_ammo/sol_fed/rubber
	name = ".38 Rubber Speedloader Single-Pack"
	desc = "Contains one speedloader of bouncy rubber .38 ammunition, for when you want to bounce your shots off anything and everything."
	cost = CARGO_CRATE_VALUE * 0.2
	auto_name = FALSE
	contains = list(/obj/item/ammo_box/speedloader/c38/match/bouncy)

/datum/supply_pack/companies/mags_and_ammo/sol_fed/dumdum38br
	name = ".38 DumDum Magazine Single-Pack"
	desc = "Contains one magazine of .38 DumDum ammunition, good for embedding in soft targets."
	auto_name = FALSE
	contains = list(/obj/item/ammo_box/magazine/m38/dumdum)

/datum/supply_pack/companies/mags_and_ammo/sol_fed/match38br
	name = ".38 Match Grade Magazine Single-Pack"
	desc = "Contains one magazine of match grade .38 ammunition, perfect for showing off trickshots."
	auto_name = FALSE
	contains = list(/obj/item/ammo_box/magazine/m38/match)

/datum/supply_pack/companies/mags_and_ammo/sol_fed/m38rubber
	name = ".38 Rubber Magazine Single-Pack"
	desc = "Contains one magazine of bouncy rubber .38 ammunition, for when you want to bounce your shots off anything and everything."
	cost = CARGO_CRATE_VALUE * 0.2
	auto_name = FALSE
	contains = list(/obj/item/ammo_box/magazine/m38/match/bouncy)

/datum/supply_pack/companies/mags_and_ammo/sol_fed/scar
	contains = list(/obj/item/ammo_box/magazine/scar)
	cost = CARGO_CRATE_VALUE * 0.5
	order_flags = ORDER_GOODY | ORDER_CONTRABAND

/datum/supply_pack/companies/mags_and_ammo/sol_fed/m16
	contains = list(/obj/item/ammo_box/magazine/m16)
	cost = CARGO_CRATE_VALUE * 0.5
	order_flags = ORDER_GOODY | ORDER_CONTRABAND

/datum/supply_pack/companies/mags_and_ammo/sol_fed/m16vintage
	contains = list(/obj/item/ammo_box/magazine/m16/vintage)
	cost = CARGO_CRATE_VALUE * 0.25
	order_flags = ORDER_GOODY | ORDER_CONTRABAND

/datum/supply_pack/companies/mags_and_ammo/sol_fed/m16patriot
	contains = list(/obj/item/ammo_box/magazine/m16/patriot)
	cost = CARGO_CRATE_VALUE * 1.5
	order_flags = ORDER_GOODY | ORDER_CONTRABAND

/datum/supply_pack/companies/mags_and_ammo/sol_fed/c35_mag
	contains = list(/obj/item/ammo_box/magazine/c35sol_pistol/starts_empty)

/datum/supply_pack/companies/mags_and_ammo/sol_fed/c35_extended
	contains = list(/obj/item/ammo_box/magazine/c35sol_pistol/stendo/starts_empty)

/datum/supply_pack/companies/mags_and_ammo/sol_fed/c585_mag
	contains = list(/obj/item/ammo_box/magazine/c585trappiste_pistol/spawns_empty)

/datum/supply_pack/companies/mags_and_ammo/sol_fed/sol_rifle_short
	contains = list(/obj/item/ammo_box/magazine/c40sol_rifle/starts_empty)

/datum/supply_pack/companies/mags_and_ammo/sol_fed/br38
	contains = list(/obj/item/ammo_box/magazine/m38/empty)

/datum/supply_pack/companies/mags_and_ammo/sol_fed/kineticballs
	contains = list(/obj/item/ammo_box/magazine/kineticballs/starts_empty)

/datum/supply_pack/companies/mags_and_ammo/sol_fed/kineticballsbig
	contains = list(/obj/item/ammo_box/magazine/kineticballsbig/starts_empty)

/datum/supply_pack/companies/mags_and_ammo/sol_fed/sol_rifle_standard
	contains = list(/obj/item/ammo_box/magazine/c40sol_rifle/standard/starts_empty)
	cost = CARGO_CRATE_VALUE * 0.5

/datum/supply_pack/companies/mags_and_ammo/sol_fed/sol_grenade_standard
	contains = list(/obj/item/ammo_box/magazine/c980_grenade/starts_empty)
	cost = CARGO_CRATE_VALUE

/datum/supply_pack/companies/mags_and_ammo/sol_fed/sol_grenade_drum
	contains = list(/obj/item/ammo_box/magazine/c980_grenade/drum/starts_empty)
	cost = CARGO_CRATE_VALUE * 0.75
	access_view = ACCESS_WEAPONS
	express_lock = TRUE
	order_flags = ORDER_GOODY

/datum/supply_pack/companies/mags_and_ammo/sol_fed/jager_shotgun_regular
	contains = list(/obj/item/ammo_box/magazine/jager/empty)
	access_view = ACCESS_WEAPONS
	express_lock = TRUE
	order_flags = ORDER_GOODY

/datum/supply_pack/companies/mags_and_ammo/sol_fed/jager_shotgun_Large
	contains = list(/obj/item/ammo_box/magazine/jager/large/empty)
	cost = CARGO_CRATE_VALUE * 0.75
	access_view = ACCESS_WEAPONS
	express_lock = TRUE
	order_flags = ORDER_GOODY

/datum/supply_pack/companies/mags_and_ammo/sol_fed/mp5
	contains = list(/obj/item/ammo_box/magazine/mp5)
	cost = CARGO_CRATE_VALUE * 0.3

// HC Mags

/datum/supply_pack/companies/mags_and_ammo/hc_surplus
	cost = CARGO_CRATE_VALUE * 0.25

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/plasma_battery
	contains = list(/obj/item/ammo_box/magazine/recharge/plasma_battery)

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/zaibas
	contains = list(/obj/item/ammo_box/magazine/pulse/spawns_empty)
	cost = CARGO_CRATE_VALUE * 0.5

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/zashch
	contains = list(/obj/item/ammo_box/magazine/zashch/spawns_empty)

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/miecz
	contains = list(/obj/item/ammo_box/magazine/miecz/spawns_empty)

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/napad
	contains = list(/obj/item/ammo_box/magazine/napad/spawns_empty)

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/sakhno
	contains = list(/obj/item/ammo_box/speedloader/strilka310)

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/lanca
	contains = list(/obj/item/ammo_box/magazine/lanca/spawns_empty)

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/amr_magazine
	contains = list(/obj/item/ammo_box/magazine/wylom)
	cost = CARGO_CRATE_VALUE * 0.75

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/bison
	contains = list(/obj/item/ammo_box/magazine/bison)
	cost = CARGO_CRATE_VALUE * 0.35

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/akm
	contains = list(/obj/item/ammo_box/magazine/akm)
	cost = CARGO_CRATE_VALUE * 0.4

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/akmricochet
	contains = list(/obj/item/ammo_box/magazine/akm/ricochet)
	cost = CARGO_CRATE_VALUE * 0.4

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/akmfire
	contains = list(/obj/item/ammo_box/magazine/akm/fire)
	cost = CARGO_CRATE_VALUE * 0.4

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/akmap
	contains = list(/obj/item/ammo_box/magazine/akm/ap)
	cost = CARGO_CRATE_VALUE * 0.4

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/akmemp
	contains = list(/obj/item/ammo_box/magazine/akm/emp)
	cost = CARGO_CRATE_VALUE * 0.4

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/akmrubber
	contains = list(/obj/item/ammo_box/magazine/akm/rubber)
	cost = CARGO_CRATE_VALUE * 0.4

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/akmbanana
	contains = list(/obj/item/ammo_box/magazine/akm/banana)
	cost = CARGO_CRATE_VALUE * 0.4

/datum/supply_pack/companies/mags_and_ammo/hc_surplus/akmcivvie
	contains = list(/obj/item/ammo_box/magazine/akm/civvie)
	cost = CARGO_CRATE_VALUE * 0.25

// Vitezstv★ Boxes of non-shotgun ammo

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes
	cost = CARGO_CRATE_VALUE * 0.25

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/peacekeeper_lethal
	contains = list(/obj/item/ammo_box/c9mm)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/peacekeeper_hp
	contains = list(/obj/item/ammo_box/c9mm/hp)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/peacekeeper_ap
	contains = list(/obj/item/ammo_box/c9mm/ap)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/peacekeeper_rubber
	contains = list(/obj/item/ammo_box/c9mm/rubber)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/auto10mm_lethal
	contains = list(/obj/item/ammo_box/c10mm)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/auto10mm_hp
	contains = list(/obj/item/ammo_box/c10mm/hp)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/auto10mm_ap
	contains = list(/obj/item/ammo_box/c10mm/ap)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/auto10mm_rubber
	contains = list(/obj/item/ammo_box/c10mm/rubber)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/zaibas_ammo
	contains = list(/obj/item/ammo_box/pulse_cargo_box)
	//It's like, a lot of ammo compared to other packages; high-capacity universal ammo for all pulse plasma guns.
	cost = CARGO_CRATE_VALUE

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/strilka_lethal
	contains = list(/obj/item/ammo_box/c310_cargo_box)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/strilka_rubber
	contains = list(/obj/item/ammo_box/c310_cargo_box/rubber)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/strilka_ap
	contains = list(/obj/item/ammo_box/c310_cargo_box/piercing)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/cesarzowa_lethal
	contains = list(/obj/item/ammo_box/c27_54cesarzowa)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/cesarzowa_rubber
	contains = list(/obj/item/ammo_box/c27_54cesarzowa/rubber)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/sol35
	contains = list(/obj/item/ammo_box/c35sol)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/sol35_disabler
	contains = list(/obj/item/ammo_box/c35sol/incapacitator)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/sol35_ripper
	contains = list(/obj/item/ammo_box/c35sol/ripper)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/sol40
	contains = list(/obj/item/ammo_box/c40sol)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/sol40_disabler
	contains = list(/obj/item/ammo_box/c40sol/fragmentation)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/sol40_flame
	contains = list(/obj/item/ammo_box/c40sol/incendiary)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/sol40_pierce
	contains = list(/obj/item/ammo_box/c40sol/pierce)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/trappiste585
	contains = list(/obj/item/ammo_box/c585trappiste)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/trappiste585_disabler
	contains = list(/obj/item/ammo_box/c585trappiste/incapacitator)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/trappiste585_incendiary
	contains = list(/obj/item/ammo_box/c585trappiste/incendiary)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/ammo_boxes/kineticballs
	contains = list(/obj/item/ammo_box/advanced/kineticballs)

// Revolver speedloaders

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/speedloader
	cost = CARGO_CRATE_VALUE * 0.25

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/speedloader/detective_lethal
	contains = list(/obj/item/ammo_box/speedloader/c38)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/speedloader/detective_dumdum
	contains = list(/obj/item/ammo_box/speedloader/c38/dumdum)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/speedloader/detective_bouncy
	contains = list(/obj/item/ammo_box/speedloader/c38/match)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/speedloader/c35sol
	contains = list(/obj/item/ammo_box/speedloader/c35sol)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/speedloader/c585trappiste
	contains = list(/obj/item/ammo_box/speedloader/c585trappiste)

// Vitezstv★ Shotgun boxes

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/shot_shells
	cost = CARGO_CRATE_VALUE * 0.25

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/shot_shells/slugs
	contains = list(/obj/item/ammo_box/advanced/s12gauge)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/shot_shells/buckshot
	contains = list(/obj/item/ammo_box/advanced/s12gauge/buckshot)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/shot_shells/beanbag_slugs
	contains = list(/obj/item/ammo_box/advanced/s12gauge/bean)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/shot_shells/rubbershot
	contains = list(/obj/item/ammo_box/advanced/s12gauge/rubber)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/shot_shells/magnum_buckshot
	contains = list(/obj/item/ammo_box/advanced/s12gauge/magnum)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/shot_shells/express_buckshot
	contains = list(/obj/item/ammo_box/advanced/s12gauge/express)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/shot_shells/hunter_slug
	contains = list(/obj/item/ammo_box/advanced/s12gauge/hunter)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/shot_shells/flechettes
	contains = list(/obj/item/ammo_box/advanced/s12gauge/flechette)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/shot_shells/hornet_nest
	contains = list(/obj/item/ammo_box/advanced/s12gauge/beehive)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/shot_shells/lighting
	contains = list(/obj/item/ammo_box/advanced/s12gauge/antitide)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/shot_shells/confetti
	contains = list(/obj/item/ammo_box/advanced/s12gauge/honkshot)

// Boxes of kiboko launcher ammo

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/grenade_shells
	cost = CARGO_CRATE_VALUE * 0.5

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/grenade_shells/practice
	contains = list(/obj/item/ammo_box/c980grenade)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/grenade_shells/smoke
	contains = list(/obj/item/ammo_box/c980grenade/smoke)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/grenade_shells/riot
	contains = list(/obj/item/ammo_box/c980grenade/riot)

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/grenade_shells/shrapnel
	contains = list(/obj/item/ammo_box/c980grenade/shrapnel)
	access_view = ACCESS_WEAPONS
	express_lock = TRUE
	order_flags = ORDER_GOODY

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/grenade_shells/phosphor
	contains = list(/obj/item/ammo_box/c980grenade/shrapnel/phosphor)
	access_view = ACCESS_WEAPONS
	express_lock = TRUE
	order_flags = ORDER_GOODY

/datum/supply_pack/companies/mags_and_ammo/vitezstvi/grenade_shells/concussion
	contains = list(/obj/item/ammo_box/c980grenade/concussive)
	access_view = ACCESS_WEAPONS
	express_lock = TRUE
	order_flags = ORDER_GOODY

//Blacksteel Ammo

/datum/supply_pack/companies/mags_and_ammo/blacksteel

/datum/supply_pack/companies/mags_and_ammo/blacksteel/quiver
	contains = list(/obj/item/storage/bag/quiver/full)
	name = "Quiver"
	desc = "Holds arrows for your bow. Good, because while pocketing arrows is possible, it surely can't be pleasant. Comes with 10 arrows!"
	cost = CARGO_CRATE_VALUE * 1.5
	auto_name = FALSE

// Donk

/datum/supply_pack/companies/mags_and_ammo/donk/foamforce_ammo
	cost = CARGO_CRATE_VALUE * 0.25

/datum/supply_pack/companies/mags_and_ammo/donk/foamforce_ammo/darts
	contains = list(/obj/item/ammo_box/foambox)
	cost = CARGO_CRATE_VALUE * 0.2

/datum/supply_pack/companies/mags_and_ammo/donk/foamforce_ammo/riot_darts
	contains = list(/obj/item/ammo_box/foambox/riot)
	cost = CARGO_CRATE_VALUE * 0.75

/datum/supply_pack/companies/mags_and_ammo/donk/foamforce_ammo/pistol_mag
	contains = list(/obj/item/ammo_box/magazine/toy/pistol)

/datum/supply_pack/companies/mags_and_ammo/donk/foamforce_ammo/smg_mag
	contains = list(/obj/item/ammo_box/magazine/toy/smg)

/datum/supply_pack/companies/mags_and_ammo/donk/foamforce_ammo/smgm45_mag
	contains = list(/obj/item/ammo_box/magazine/toy/smgm45)

/datum/supply_pack/companies/mags_and_ammo/donk/foamforce_ammo/m762_mag
	contains = list(/obj/item/ammo_box/magazine/toy/m762)
