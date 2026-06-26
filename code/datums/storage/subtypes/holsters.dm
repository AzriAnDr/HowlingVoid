///Holster
/datum/storage/holster
	max_slots = 3
	max_total_storage = WEIGHT_CLASS_NORMAL + (WEIGHT_CLASS_SMALL * 2)
	open_sound = 'sound/items/handling/holster_open.ogg'
	open_sound_vary = TRUE
	rustle_sound = 'sound/sec_haul/holsterin.ogg'
	remove_rustle_sound = 'sound/sec_haul/holsterout.ogg'
	var/list/limited_hold_types = list(
		/obj/item/gun,
	)
	/// How many restricted items are currently stored in this holster.
	var/limited_held = 0
	/// How many restricted items this holster can hold at most.
	var/max_limited_store = 1

/datum/storage/holster/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound, list/holdables)
	. = ..()
	if(length(holdables))
		set_holdable(holdables)
		return

	set_holdable(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/revolver,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/dueling,
		/obj/item/food/grown/banana,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/laser/pistol,
		/obj/item/gun/ballistic/rifle/boltaction, //fits if you make it an obrez
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
		// NOVA EDIT ADDITION START
		/obj/item/gun/energy/e_gun, // covers e_gun/mini, e_gun/hos,
		/obj/item/gun/energy/laser, // covers laser/captain, laser/thermal
		/obj/item/ammo_box/magazine, // Just magazine, because the sec-belt can hold these aswell
		/obj/item/ammo_box/speedloader,
		/obj/item/gun/energy/recharge/kinetic_accelerator/variant/glock,
		// NOVA EDIT ADDITION END
	))

/datum/storage/holster/handle_enter(datum/source, obj/item/arrived)
	. = ..()
	if(is_type_in_list(arrived, limited_hold_types))
		limited_held++

/datum/storage/holster/handle_exit(datum/source, obj/item/gone)
	. = ..()
	if(is_type_in_list(gone, limited_hold_types))
		playsound(parent, 'sound/sec_haul/holsterout.ogg', 50, rustle_vary, -5)
		limited_held = max(limited_held - 1, 0)

/datum/storage/holster/can_insert(obj/item/to_insert, mob/user, messages, force)
	. = ..()
	if(is_type_in_list(to_insert, limited_hold_types) && (limited_held >= max_limited_store))
		user.balloon_alert(user, "no suitable space!")
		return FALSE

/datum/storage/holster/open_storage(mob/to_show, can_reach_target)
	var/atom/resolve_parent = parent
	if(!resolve_parent)
		return
	if(isobserver(to_show))
		show_contents(to_show)
		return

	if(!resolve_parent.IsReachableBy(to_show))
		resolve_parent.balloon_alert(to_show, "can't reach!")
		return FALSE

	if(!isliving(to_show) || to_show.incapacitated)
		return FALSE

	var/obj/item/gun/gun_to_draw = locate() in real_location
	if(!gun_to_draw)
		return ..()
	resolve_parent.add_fingerprint(to_show)
	INVOKE_ASYNC(to_show, TYPE_PROC_REF(/mob, put_in_hands), gun_to_draw)
	to_show.visible_message(span_warning("[to_show] draws [gun_to_draw] from [resolve_parent]!"), span_notice("You draw [gun_to_draw] from [resolve_parent]."))

///Energy holster
/datum/storage/holster/energy
	max_slots = 3
	max_limited_store = 2
	max_total_storage = (WEIGHT_CLASS_NORMAL * 2) + WEIGHT_CLASS_SMALL
	/// Typecache of things we can charge. If anything we insert is one of these types, start processing our parent for charging.
	var/static/list/charge_typecache = typecacheof(list(
		/obj/item/gun/energy,
		/obj/item/ammo_box/magazine/recharge,
		/obj/item/gun/ballistic/automatic/pistol/plasma_marksman,
		/obj/item/gun/ballistic/automatic/pistol/plasma_thrower,
	))
	/// Typecache of things ignored for empty checks. `get_all_contents()` includes the source holster itself.
	var/static/list/empty_check_typecache = typecacheof(list(
		/obj/item/storage/belt/holster/energy,
		/obj/item/stock_parts/power_store/cell,
	))

/datum/storage/holster/energy/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound, list/holdables)
	holdables = list(
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/dueling,
		/obj/item/food/grown/banana,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/recharge/ebow,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/laser/pistol,
		/obj/item/gun/energy/e_gun/hos,
		// NOVA EDIT START
		/obj/item/gun/energy/e_gun, // covers e_gun/mini, e_gun/hos,
		/obj/item/gun/energy/laser, // covers laser/captain, laser/thermal
		/obj/item/gun/energy/modular_laser_rifle,
		/obj/item/gun/ballistic/automatic/pistol/plasma_marksman,
		/obj/item/gun/ballistic/automatic/pistol/plasma_thrower,
		/obj/item/ammo_box/magazine/recharge/plasma_battery,
		/obj/item/gun/energy/recharge/kinetic_accelerator/variant/glock,
		// NOVA EDIT END
	)

	return ..()

/datum/storage/holster/energy/handle_enter(datum/source, obj/item/arrived)
	. = ..()
	if(is_type_in_typecache(arrived, charge_typecache))
		START_PROCESSING(SSobj, parent)

/datum/storage/holster/energy/handle_exit(datum/source, obj/item/gone)
	. = ..()
	if(!is_type_in_typecache(gone, charge_typecache))
		return
	if(length(parent.get_all_contents_ignoring(empty_check_typecache)))
		return
	STOP_PROCESSING(SSobj, parent)

/datum/storage/holster/energy/onegun
	max_slots = 2
	max_limited_store = 1
	max_total_storage = WEIGHT_CLASS_NORMAL + WEIGHT_CLASS_SMALL

///Detective holster
/datum/storage/holster/detective
	max_slots = 4
	max_total_storage = WEIGHT_CLASS_NORMAL + (WEIGHT_CLASS_SMALL * 3)

/datum/storage/holster/detective/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound, list/holdables)
	holdables = list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/ammo_box/magazine/m9mm, // Pistol magazines.
		/obj/item/ammo_box/magazine/m9mm_aps,
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/ammo_box/magazine/m45,
		/obj/item/ammo_box/magazine/m50,
		/obj/item/gun/ballistic/revolver,
		/obj/item/ammo_box/speedloader, // Speedloaders, which includes stripper clips on a technicality.
		/obj/item/ammo_box/magazine/toy/pistol,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/laser/pistol,
		/obj/item/gun/energy/e_gun/hos,
		/obj/item/gun/ballistic/rifle/boltaction, //fits if you make it an obrez
		// NOVA EDIT ADDITION START
		/obj/item/gun/energy/e_gun, // covers e_gun/mini, e_gun/hos,
		/obj/item/gun/energy/laser, // covers laser/captain, laser/thermal
		/obj/item/food/grown/banana,
		/obj/item/gun/energy/recharge/kinetic_accelerator/variant/glock,
		/obj/item/ammo_box/magazine, // covers all the old magazines (m9mm, m9mm_aps, m10mm, m45, m50)
		// though realistically someone could consider just hand-adding every pistol magazine. including the nova-specific ones.
		// NOVA EDIT ADDITION END
	)

	return ..()

///Chameleon Holster
/datum/storage/holster/chameleon
	max_slots = 2
	silent = TRUE

/datum/storage/holster/chameleon/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound, list/holdables)
	holdables = list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m9mm_aps,
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/ammo_box/magazine/m45,
		/obj/item/ammo_box/magazine/m50,
		/obj/item/gun/ballistic/revolver,
		/obj/item/ammo_box/speedloader,
		/obj/item/ammo_box/magazine/toy/pistol,
		/obj/item/gun/energy/recharge/ebow,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/laser/pistol,
		/obj/item/gun/energy/e_gun/hos,
	)

	return ..()

///Nukie holster
/datum/storage/holster/nukie
	max_slots = 2
	max_specific_storage = WEIGHT_CLASS_BULKY

/datum/storage/holster/nukie/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound, list/holdables)
	holdables = list(
		/obj/item/gun, // ALL guns.
		/obj/item/ammo_box/magazine, // ALL magazines.
		/obj/item/ammo_box/speedloader, // ALL speedloaders (there's 3 types at time of writing so it's probably fine)
		/obj/item/ammo_casing, // For shotgun shells, rockets, launcher grenades, and a few other things.
		/obj/item/grenade, // All regular grenades, the big grenade launcher fires these.
	)

	return ..()

///Nukie cowboy holster
/datum/storage/holster/nukie/cowboy
	max_slots = 3
	max_specific_storage = WEIGHT_CLASS_NORMAL
