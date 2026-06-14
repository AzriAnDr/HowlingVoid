/obj/item/gun/ballistic/automatic/akm
	name = "\improper KAR-84 carbine"
	desc = "An ancient and well-known Kalashnikov design, modified in 2384. The only change since 1974 is the addition of new materials that help the weapon withstand the harsh conditions of alien worlds. The rifle was used by Slavic colonists and later by the Imperial army. The weapon is engraved with the word \"Zaryan.\""
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_guns40x32.dmi'
	icon_state = "akm"
	lefthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_lefthand.dmi'
	righthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_righthand.dmi'
	inhand_icon_state = "akm"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	accepted_magazine_type = /obj/item/ammo_box/magazine/akm
	can_suppress = FALSE
	fire_delay = 2.5
	actions_types = list()
	worn_icon = 'icons/obj/weapons/guns/surplus/gunsgalore_back.dmi'
	worn_icon_state = "akm"
	fire_sound = 'sound/items/weapons/gun/surplus/fire/akm_fire.ogg'
	rack_sound = 'sound/items/weapons/gun/surplus/interact/ltrifle_cock.ogg'
	load_sound = 'sound/items/weapons/gun/surplus/interact/ltrifle_magin.ogg'
	load_empty_sound = 'sound/items/weapons/gun/surplus/interact/ltrifle_magin.ogg'
	eject_sound = 'sound/items/weapons/gun/surplus/interact/ltrifle_magout.ogg'
	burst_size = 1

/obj/item/gun/ballistic/automatic/akm/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/// VARIETIES ///
/// INTEQ NEW
/obj/item/gun/ballistic/automatic/akm/modern
	name = "\improper KAR-19 carbine"
	desc = "A modification of the Kalashnikov 2419 assault rifle for special forces and imperial private military companies. It uses more durable and expensive materials in its construction. It boasts a higher rate of fire and features tactical adjustments that improve the rifle's ergonomics. Its main drawback is its high cost. The weapon is engraved with a <font color='#FFD700'>golden eagle</font> and the inscription <font color='green'>\"Zvirdnyansky Arms Factory\"</font>."
	icon_state = "akm_modern"
	inhand_icon_state = "akm"
	worn_icon_state = "akm"
	fire_delay = 1.75
	fire_sound = 'sound/items/weapons/gun/surplus/fire/ak12_fire.ogg'

/// INTEQ CIV
/obj/item/gun/ballistic/automatic/akm/civvie
	name = "\improper Sabel carbine"
	desc = "A civilian version of the AK-19. Developed by the Zaryansky Rifle Concern as a weapon for the imperial police and private security companies. It differs from the military-grade original in that it has a smaller magazine and a lower rate of fire. It is not compatible with military magazines. The weapon is engraved with the emblem of the Ministry of Internal Affairs and the inscription \"Zaryan Rifle Concern\"."
	icon_state = "akm_civ"
	inhand_icon_state = "akm_civ"
	accepted_magazine_type = /obj/item/ammo_box/magazine/akm/civvie
	fire_delay = 3.5
	dual_wield_spread = 15
	spread = 5
	worn_icon_state = "akm_civ"
	recoil = 0.2

/// NRI
/obj/item/gun/ballistic/automatic/akm/nri
	name = "\improper IKAR-19 carbine"
	desc = "The Imperial Kalashnikov assault rifle. A modification of the AK-19 for the Imperial Army. Adopted by the Imperial Army in 2436, it utilizes advanced materials and ergonomic innovations, taking into account numerous conflicts: the magazine position has been changed, and a less expensive version of the AK-19 sight has been added. Despite these innovations, most of the parts and magazines are compatible with older models. It combines innovation, reliability, and an affordable production cost. The rifle is engraved with a golden eagle and the inscription \"Svarog Factory\"."
	icon_state = "akm_nri"
	inhand_icon_state = "akm_nri"
	worn_icon_state = "akm_nri"
	can_suppress = TRUE

/obj/item/gun/ballistic/automatic/akm/nri/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, CARGO_COMPANY_NRI_SURPLUS)

/// AMMO ///
/obj/item/ammo_box/magazine/akm
	name = "KAR magazine"
	desc = "a banana-shaped double-stack magazine able to hold 30 rounds of 5.6mm ammo."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_items.dmi'
	icon_state = "akm"
	ammo_type = /obj/item/ammo_casing/realistic/a762x39
	caliber = "a762x39"
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/akm/ricochet
	name = "KAR magazine (MATCH)"
	desc = "a banana-shaped double-stack magazine able to hold 30 rounds of 5.6mm ammo. Contains highly ricocheting ammunition."
	icon_state = "akm_ricochet"
	ammo_type = /obj/item/ammo_casing/realistic/a762x39/ricochet

/obj/item/ammo_box/magazine/akm/fire
	name = "KR magazine (INCENDIARY)"
	desc = "a banana-shaped double-stack magazine able to hold 30 rounds of 5.6mm ammo. Contains incendiary ammunition."
	icon_state = "akm_fire"
	ammo_type = /obj/item/ammo_casing/realistic/a762x39/fire

/obj/item/ammo_box/magazine/akm/ap
	name = "KAR magazine (ARMOR PIERCING)"
	desc = "a banana-shaped double-stack magazine able to hold 30 rounds of 5.6mm ammo. Contains armor-piercing ammunition."
	icon_state = "akm_ap"
	ammo_type = /obj/item/ammo_casing/realistic/a762x39/ap

/obj/item/ammo_box/magazine/akm/emp
	name = "KAR magazine (EMP)"
	desc = "a banana-shaped double-stack magazine able to hold 30 rounds of 5.6mm ammo. Contains ion ammunition, good for disrupting electronics and wrecking mechas."
	icon_state = "akm_emp"
	ammo_type = /obj/item/ammo_casing/realistic/a762x39/emp

/obj/item/ammo_box/magazine/akm/rubber
	name = "KAR magazine (RUBBER)"
	desc = "a banana-shaped double-stack magazine able to hold 30 rounds of 5.6mm ammo. Contains less-than-lethal rubber ammunition."
	icon_state = "akm_rubber"
	ammo_type = /obj/item/ammo_casing/realistic/a762x39/civilian/rubber
	caliber = "a762x39civ"

/obj/item/ammo_box/magazine/akm/banana
	name = "KAR extended magazine"
	desc = "a banana-shaped double-stack magazine able to hold 45 rounds of 5.6x40mm ammunition. It's meant to be used on a light machine gun, but it's just a longer KAR magazine."
	max_ammo = 45

/obj/item/ammo_box/magazine/akm/civvie
	name = "Sabel magazine"
	desc = "a shortened double-stack magazine able to hold 15 rounds of civilian-grade 5.6mm ammo."
	icon_state = "akm_civ"
	max_ammo = 15
	ammo_type = /obj/item/ammo_casing/realistic/a762x39/civilian
	caliber = "a762x39civ"

/obj/item/gun/ballistic/automatic/fg42
	name = "\improper FG-42 rifle"
	desc = "A long-barreled rifle designed for long range shooting in 7.92x57mm caliber."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_guns40x32.dmi'
	icon_state = "fg42"
	lefthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_lefthand.dmi'
	righthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_righthand.dmi'
	inhand_icon_state = "fg42"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	accepted_magazine_type = /obj/item/ammo_box/magazine/fg42
	can_suppress = FALSE
	burst_size = 1
	spread = 0
	fire_delay = 3
	projectile_damage_multiplier = 2.8571429 // makes 7.92x57 base 7 -> ~20 per shot
	worn_icon = 'icons/obj/weapons/guns/surplus/gunsgalore_back.dmi'
	worn_icon_state = "fg42"
	fire_sound = 'sound/items/weapons/gun/surplus/fire/fg42_fire.ogg'

	rack_sound = 'sound/items/weapons/gun/surplus/interact/batrifle_cock.ogg'
	load_sound = 'sound/items/weapons/gun/surplus/interact/batrifle_magin.ogg'
	load_empty_sound = 'sound/items/weapons/gun/surplus/interact/batrifle_magin.ogg'
	eject_sound = 'sound/items/weapons/gun/surplus/interact/batrifle_magout.ogg'
	eject_empty_sound = 'sound/items/weapons/gun/surplus/interact/batrifle_magout.ogg'

/obj/item/gun/ballistic/automatic/fg42/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/scope, range_modifier = 1)
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/ammo_box/magazine/fg42
	name = "FG-42 magazine (7.92x57mm)"
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_items.dmi'
	icon_state = "fg42"
	ammo_type = /obj/item/ammo_casing/realistic/a792x57
	caliber = "a792x57"
	max_ammo = 20
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/pistol/luger
	name = "\improper Luger"
	desc = "A small, light-weight reproduction of the Luger P08 from the 20th century, manufactured by the Oldarms division of the Armadyne Corporation. Chambered in 9x25mm."
	icon_state = "luger"
	inhand_icon_state = "luger"
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_guns.dmi'
	lefthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_lefthand.dmi'
	righthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_righthand.dmi'
	fire_sound = 'sound/items/weapons/gun/surplus/fire/luger_fire.ogg'
	load_sound = 'sound/items/weapons/gun/surplus/fire/luger_mag_insert.ogg'
	load_empty_sound = 'sound/items/weapons/gun/surplus/fire/luger_mag_insert.ogg'
	eject_sound = 'sound/items/weapons/gun/surplus/fire/luger_mag_release.ogg'
	eject_empty_sound = 'sound/items/weapons/gun/surplus/fire/luger_mag_release.ogg'
	rack_sound =  'sound/items/weapons/gun/surplus/fire/luger_rack.ogg'
	fire_sound_volume = 100
	suppressor_x_offset = 14

/obj/item/gun/ballistic/automatic/m16
	name = "\improper M-61 rifle"
	desc = "Developed in 2250, this rifle was based on the M-16. It was used by the armed forces of the Solar Federation during the unification of the Solar System. The design was chosen due to the large number of ancient assault rifles in Earth warehouses that had been modernized for the needs of a modern military. The rifle utilized space-resistant materials. The rifle's sale began after the end of the border wars and the Great Economic Crisis. The Solar Federation sells the remaining units to its allies or private military companies. The rifle is engraved with the words \"United Americas\"."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_guns40x32.dmi'
	icon_state = "m16"
	lefthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_lefthand.dmi'
	righthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_righthand.dmi'
	inhand_icon_state = "m16"
	worn_icon = 'icons/obj/weapons/guns/surplus/gunsgalore_back.dmi'
	worn_icon_state = "m16"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	accepted_magazine_type = /obj/item/ammo_box/magazine/m16
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 2
	projectile_damage_multiplier = 0.57
	fire_sound = 'sound/items/weapons/gun/surplus/fire/m16_fire.ogg'
	fire_sound_volume = 50
	rack_sound = 'sound/items/weapons/gun/surplus/interact/sfrifle_cock.ogg'
	load_sound = 'sound/items/weapons/gun/surplus/interact/sfrifle_magin.ogg'
	load_empty_sound = 'sound/items/weapons/gun/surplus/interact/sfrifle_magin.ogg'
	eject_sound = 'sound/items/weapons/gun/surplus/interact/sfrifle_magout.ogg'

/obj/item/ammo_box/magazine/m16
	name = "\improper M-61 magazine"
	desc = "A double-stack translucent polymer magazine for use with the M-61 rifles. Holds 30 rounds of .277 Aestus."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_items.dmi'
	icon_state = "m16e"
	ammo_type = /obj/item/ammo_casing/a223
	caliber = CALIBER_A223
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/m16/vintage
	name = "m61 short magazine"
	desc = "A double-stack solid magazine that looks rather dated. Holds 20 rounds of .277 Aestus."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_items.dmi'
	icon_state = "m16"
	max_ammo = 20
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/// SOLFED
/obj/item/gun/ballistic/automatic/m16/modern
	name = "\improper M-61 Solar rifle"
	desc = "A modernized version of the M61 rifle for planetary garrisons. It differs from the original in that it features an automatic fire mode and materials more resistant to alien conditions. These rifles were issued to military units guarding worlds of the Solar Federation. Parts and magazines are compatible with the original M61. Even after the border wars and the Great Economic Crisis, the rifle remained in service with the Solar Federation and planets that had previously belonged to it but seceded. Stockpiles are sold to allies and private security companies. The rifle is engraved with a four-star star and the inscription \"Armdyne-Technology\"."
	icon_state = "m16_modern"
	inhand_icon_state = "m16"
	worn_icon_state = "m16"
	spread = 0.5
	burst_size = 1
	fire_delay = 1.90

/obj/item/gun/ballistic/automatic/m16/modern/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, CARGO_COMPANY_SOL_DEFENSE)


/obj/item/gun/ballistic/automatic/m16/modern/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/// INTEQ SHORT
/obj/item/gun/ballistic/automatic/m16/modern/v2
	name = "\improper M-61A1 rifle"
	desc = "An expertly modified, super-compact M-61 rifle designed for operating in tight corridors of ships. You're a mercenary, finish your mission!"
	icon_state = "m16_modern2"
	inhand_icon_state = "m16"
	worn_icon_state = "m16"
	accepted_magazine_type = /obj/item/ammo_box/magazine/m16/patriot
	fire_delay = 1.65
	projectile_damage_multiplier = 0.28

/obj/item/ammo_box/magazine/m16/patriot
	name = "\improper M-61A1 drum magazine"
	desc = "A double-stack solid polymer drum made for use with the M-61A1 rifle. Holds 50 rounds of .277 ammo."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_items.dmi'
	icon_state = "m16"
	max_ammo = 50
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/mg34
	name = "\improper MG-34"
	desc = "An Old Empire machine gun that was also used in the Civil War. InteQ mercenaries took the old designs and put this old gun into circulation."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_guns40x32.dmi'
	lefthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_lefthand.dmi'
	righthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_righthand.dmi'
	worn_icon = 'icons/obj/weapons/guns/surplus/gunsgalore_back.dmi'
	icon_state = "mg34"
	base_icon_state = "mg34"
	worn_icon_state = "mg34"
	inhand_icon_state = "mg34"
	fire_sound = 'sound/items/weapons/gun/surplus/fire/mg34_fire.ogg'
	rack_sound = 'sound/items/weapons/gun/l6/l6_rack.ogg'
	suppressed_sound = 'sound/items/weapons/gun/general/heavy_shot_suppressed.ogg'
	fire_sound_volume = 70
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	spread = 15
	accepted_magazine_type = /obj/item/ammo_box/magazine/mg34
	can_suppress = FALSE
	fire_delay = 1.25
	projectile_damage_multiplier = 0.9 // unified moderate: damage -10%
	bolt_type = BOLT_TYPE_OPEN
	show_bolt_icon = FALSE
	tac_reloads = FALSE
	var/cover_open = FALSE
	burst_size = 1

/obj/item/gun/ballistic/automatic/mg34/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/automatic/mg34/examine(mob/user)
	. = ..()
	. += "<b>RMB with an empty hand</b> to [cover_open ? "close" : "open"] the dust cover."
	if(cover_open && magazine)
		. += span_notice("It seems like you could use an <b>empty hand</b> to remove the magazine.")

/obj/item/gun/ballistic/automatic/mg34/attack_hand_secondary(mob/user, list/modifiers)
	if(!user.can_perform_action(src))
		return
	cover_open = !cover_open
	to_chat(user, span_notice("You [cover_open ? "open" : "close"] [src]'s cover."))
	playsound(src, 'sound/items/weapons/gun/l6/l6_door.ogg', 60, TRUE)
	update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/gun/ballistic/automatic/mg34/update_overlays()
	. = ..()
	. += "[base_icon_state]_door_[cover_open ? "open" : "closed"]"

/obj/item/gun/ballistic/automatic/mg34/can_shoot()
	if(cover_open)
		balloon_alert_to_viewers("cover open!")
		return FALSE
	return chambered

/obj/item/gun/ballistic/automatic/mg34/eject_magazine(mob/user, display_message = TRUE, obj/item/ammo_box/magazine/tac_load = null)
	if(!cover_open)
		to_chat(user, span_warning("The cover is closed! Open it before ejecting the magazine!"))
		return
	return ..()

/obj/item/gun/ballistic/automatic/mg34/attackby(obj/item/A, mob/user, params)
	if(!cover_open && istype(A, accepted_magazine_type))
		to_chat(user, span_warning("[src]'s dust cover prevents a magazine from being fit."))
		return
	..()

/obj/item/ammo_box/magazine/mg34
	name = "MG-34 drum (7.92x57mm)"
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_items.dmi'
	icon_state = "mg34_drum"
	ammo_type = /obj/item/ammo_casing/realistic/a792x57
	caliber = "a792x57"
	max_ammo = 75
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/mg34/packapunch //INFINITY GUNNNNNNNN
	name = "\improper MG-34 UBER"
	desc = "Here, there, seems like everywhere. Nasty things are happening, now everyone is scared. Old Jeb Brown the Blacksmith, he saw his mother die. A critter took a bite from her and now she's in the sky. "
	fire_delay = 0.04
	burst_size = 5
	spread = 5
	accepted_magazine_type = /obj/item/ammo_box/magazine/mg34/packapunch

/obj/item/ammo_box/magazine/mg34/packapunch
	max_ammo = 999
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/gun/ballistic/automatic/mg34/packapunch/process_chamber(user = user, empty_chamber, from_firing, chamber_next_round)
	. = ..()
	magazine.top_off()

/// BIGGER BROTHER
#define SPREAD_UNDEPLOYED 17
#define SPREAD_DEPLOYED 6
#define HEAT_PER_SHOT 1.5
#define TIME_TO_COOLDOWN (20 SECONDS)
#define BARREL_COOLDOWN_RATE 2

/obj/item/gun/ballistic/automatic/mg34/mg42
	name = "\improper MG-42"
	desc = "An Old Empire machine gun that was also used in the Civil War. InteQ mercenaries took the old designs and put this old gun into circulation. It has a bipod for better stability when deployed."
	icon_state = "mg42"
	base_icon_state = "mg42"
	worn_icon_state = "mg42"
	inhand_icon_state = "mg42"
	fire_sound_volume = 100
	fire_delay = 0.625
	projectile_damage_multiplier = 0.9 // unified moderate applied to MG-42 subtype
	fire_sound = 'sound/items/weapons/gun/surplus/fire/mg42_fire.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/mg42
	spread = SPREAD_UNDEPLOYED
	/// If we are resting, the bipod is deployed.
	var/bipod_deployed = FALSE
	/// How hot the barrel is, 0 - 100
	var/barrel_heat = 0
	/// Have we overheated?
	var/overheated = FALSE

/obj/item/gun/ballistic/automatic/mg34/mg42/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_GUN_FIRED, PROC_REF(process_heat))
	START_PROCESSING(SSobj, src)

/obj/item/gun/ballistic/automatic/mg34/mg42/process(seconds_per_tick)
	if(barrel_heat > 0)
		barrel_heat -= BARREL_COOLDOWN_RATE * seconds_per_tick
		update_appearance()

/obj/item/gun/ballistic/automatic/mg34/mg42/examine(mob/user)
	. = ..()
	switch(barrel_heat)
		if(50 to 75)
			. += span_warning("The barrel looks hot.")
		if(75 to INFINITY)
			. += span_warning("The barrel looks moulten!")
	if(overheated)
		. += span_danger("It is heatlocked!")

/obj/item/gun/ballistic/automatic/mg34/mg42/can_shoot()
	if(cover_open)
		balloon_alert_to_viewers("cover open!")
		return FALSE
	if(overheated)
		balloon_alert_to_viewers("overheated!")
		shoot_with_empty_chamber()
		return FALSE
	return chambered

/obj/item/gun/ballistic/automatic/mg34/mg42/pickup(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_LIVING_UPDATED_RESTING, PROC_REF(deploy_bipod))

/obj/item/gun/ballistic/automatic/mg34/mg42/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_LIVING_UPDATED_RESTING)
	bipod_deployed = FALSE
	spread = SPREAD_UNDEPLOYED
	update_appearance()

/obj/item/gun/ballistic/automatic/mg34/mg42/proc/deploy_bipod(datum/datum_source, resting)
	SIGNAL_HANDLER
	if(resting)
		bipod_deployed = TRUE
		spread = SPREAD_DEPLOYED
	else
		bipod_deployed = FALSE
		spread = SPREAD_UNDEPLOYED
	playsound(src, 'sound/items/weapons/gun/surplus/fire/mg42_bipod.ogg', 100)
	balloon_alert_to_viewers("bipod [bipod_deployed ? "deployed" : "undeployed"]!")
	update_appearance()

/obj/item/gun/ballistic/automatic/mg34/mg42/proc/process_heat()
	SIGNAL_HANDLER
	if(overheated)
		return
	barrel_heat += HEAT_PER_SHOT
	if(barrel_heat >= 100)
		overheated = TRUE
		playsound(src, 'sound/items/weapons/gun/surplus/fire/mg_overheat.ogg', 100)
		addtimer(CALLBACK(src, PROC_REF(reset_overheat)), TIME_TO_COOLDOWN)
	update_appearance()

/obj/item/gun/ballistic/automatic/mg34/mg42/proc/reset_overheat()
	overheated = FALSE
	update_appearance()

/obj/item/gun/ballistic/automatic/mg34/mg42/update_overlays()
	. = ..()
	. += "[base_icon_state]_[bipod_deployed ? "bipod_deployed" : "bipod"]"

	switch(barrel_heat)
		if(50 to 75)
			. += "[base_icon_state]_barrel_hot"
		if(75 to INFINITY)
			. += "[base_icon_state]_barrel_overheat"

#undef SPREAD_UNDEPLOYED
#undef SPREAD_DEPLOYED
#undef HEAT_PER_SHOT
#undef TIME_TO_COOLDOWN
#undef BARREL_COOLDOWN_RATE

/obj/item/ammo_box/magazine/mg42
	name = "MG-42 drum (7.92x57mm)"
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_items.dmi'
	icon_state = "mg42_drum"
	ammo_type = /obj/item/ammo_casing/realistic/a792x57
	caliber = "a792x57"
	max_ammo = 150 // It's a lot, but the gun overheats.
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/mp40
	name = "\improper MP-40"
	desc = "The instantly recognizable 'kraut gun'. Extremely outdated SMG that has only seen service during Sol-3's second World War. This one's a poor, unlicensed reproduction."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_guns40x32.dmi'
	icon_state = "mp40"
	lefthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_lefthand.dmi'
	righthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_righthand.dmi'
	inhand_icon_state = "mp40"
	worn_icon = 'icons/obj/weapons/guns/surplus/gunsgalore_back.dmi'
	worn_icon_state = "mp40"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/mp40
	weapon_weight = WEAPON_HEAVY
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 1.7
	projectile_damage_multiplier = 0.5333333 // makes 9mm base 30 -> ~16 for MP-40
	fire_sound = 'sound/items/weapons/gun/surplus/fire/mp40_fire.ogg'
	fire_sound_volume = 100
	rack_sound = 'sound/items/weapons/gun/surplus/interact/smg_cock.ogg'
	load_sound = 'sound/items/weapons/gun/surplus/interact/smg_magin.ogg'
	load_empty_sound = 'sound/items/weapons/gun/surplus/interact/smg_magin.ogg'
	eject_sound = 'sound/items/weapons/gun/surplus/interact/smg_magout.ogg'


/obj/item/gun/ballistic/automatic/mp40/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/ammo_box/magazine/mp40
	name = "SSG-56 Modern magazine (9mmx19)"
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_items.dmi'
	icon_state = "mp40"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 32
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/mp40/modern
	name = "\improper SSG-56 Modern"
	desc = "An Old Empire gun that was also used in the Civil War. InteQ mercenaries took the old designs and put this old gun into circulation. Thanks to its short barrel, it was used by pilots and tank crews."
	icon_state = "mp40_modern"
	inhand_icon_state = "mp40"
	worn_icon_state = "mp40"
	burst_size = 1
	fire_delay = 1.5
	projectile_damage_multiplier = 0.6666667 // makes 9mm base 30 -> ~20 for SSG-56 Modern

/obj/item/gun/ballistic/automatic/mp5
	name = "\improper SG-5"
	desc = "A submachine gun based on the MP-5. The weapon uses more wear-resistant materials. It was widely used by pilots and armored vehicle crews of the Solar Federation. It also became widespread among the Solar Federation's security forces. After the Great Economic Crisis and the secession of numerous planets from the Federation, the weapon fell into the hands of local armed groups and bandits. Subsequently, it began to appear on the black market. The weapon is engraved with a four-pointed star and the inscription \"Armdyne-Technology\"."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_guns40x32.dmi'
	icon_state = "mp5"
	lefthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_lefthand.dmi'
	righthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_righthand.dmi'
	inhand_icon_state = "mp5"
	worn_icon = 'icons/obj/weapons/guns/surplus/gunsgalore_back.dmi'
	worn_icon_state = "mp40_modern"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/mp5
	weapon_weight = WEAPON_HEAVY
	can_suppress = FALSE
	fire_delay = 0.23 SECONDS
	burst_size = 1
	fire_sound = 'sound/items/weapons/gun/surplus/fire/mp5_fire.ogg'
	fire_sound_volume = 100
	rack_sound = 'sound/items/weapons/gun/surplus/interact/mp5_cock.ogg'
	load_sound = 'sound/items/weapons/gun/surplus/interact/mp5_magin.ogg'
	load_empty_sound = 'sound/items/weapons/gun/surplus/interact/mp5_magin.ogg'
	eject_sound = 'sound/items/weapons/gun/surplus/interact/mp5_magout.ogg'

/obj/item/gun/ballistic/automatic/mp5/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

// Caliber
/obj/item/ammo_casing/c385
	name = ".385 bullet casing"
	desc = "A .385 bullet casing."
	caliber = ".385"
	projectile_type = /obj/projectile/bullet/c385

/obj/projectile/bullet/c385
	name = ".385 bullet"
	damage = 15
	ricochets_max = 2
	ricochet_chance = 50
	ricochet_auto_aim_angle = 10
	ricochet_auto_aim_range = 3
	wound_bonus = -20
	exposed_wound_bonus = 10
	embed_type = /datum/embedding/bullet/c38
	embed_falloff_tile = -4
//

/obj/item/ammo_box/magazine/mp5
	name = "\improper SG-5 magazine"
	desc = "Magazine with .385 caliber cartridges. Suitable for SG-5."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_items.dmi'
	icon_state = "mp5"
	ammo_type = /obj/item/ammo_casing/c385
	caliber = ".385"
	max_ammo = 25
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/// InteQ Bizon
/obj/item/gun/ballistic/automatic/bison
	name = "\improper Bizon"
	desc = "A submachine gun developed in ancient times, but found use among Slavic militias and later among imperial special forces. The modern version uses modern materials. It is popular among private security forces and police agencies. The weapon is engraved with the word \"Zaryan\"."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_guns.dmi'
	lefthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_lefthand.dmi'
	righthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_righthand.dmi'
	worn_icon = 'icons/obj/weapons/guns/surplus/gunsgalore_back.dmi'
	fire_sound = 'sound/items/weapons/gun/surplus/fire/mp5_fire.ogg'
	fire_sound_volume = 100
	rack_sound = 'sound/items/weapons/gun/surplus/interact/mp5_cock.ogg'
	load_sound = 'sound/items/weapons/gun/surplus/interact/mp5_magin.ogg'
	load_empty_sound = 'sound/items/weapons/gun/surplus/interact/mp5_magin.ogg'
	eject_sound = 'sound/items/weapons/gun/surplus/interact/mp5_magout.ogg'
	burst_size = 1
	icon_state = "bizon"
	inhand_icon_state = "bizon"
	worn_icon_state = "nri_smg"
	fire_delay = 0.3 SECONDS
	accepted_magazine_type = /obj/item/ammo_box/magazine/bison


/obj/item/gun/ballistic/automatic/bison/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/ammo_box/magazine/bison
	name = "\improper SPG-X-19 Bizon magazine"
	desc = "Magazine with .385 caliber cartridges. Suitable for Bizon."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_items.dmi'
	icon_state = "p90"
	ammo_type = /obj/item/ammo_casing/c385
	caliber = ".385"
	max_ammo = 50
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/p90
	name = "\improper FN P-09"
	desc = "A compact Bullpup submachine gun of the pilots and tank crew of the Old Empire. After its collapse, the weapon's blueprints were taken by mercenaries from InteQ."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_guns40x32.dmi'
	icon_state = "p90"
	lefthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_lefthand.dmi'
	righthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_righthand.dmi'
	inhand_icon_state = "p90"
	worn_icon = 'icons/obj/weapons/guns/surplus/gunsgalore_back.dmi'
	worn_icon_state = "p90"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/p90
	weapon_weight = WEAPON_HEAVY
	can_suppress = FALSE
	fire_delay = 2
	burst_size = 1
	fire_sound = 'sound/items/weapons/gun/surplus/fire/p90_fire.ogg'
	fire_sound_volume = 100
	rack_sound = 'sound/items/weapons/gun/surplus/interact/p90_cock.ogg'
	load_sound = 'sound/items/weapons/gun/surplus/interact/p90_magin.ogg'
	load_empty_sound = 'sound/items/weapons/gun/surplus/interact/p90_magin.ogg'
	eject_sound = 'sound/items/weapons/gun/surplus/interact/p90_magout.ogg'

/obj/item/gun/ballistic/automatic/p90/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/ammo_box/magazine/p90
	name = "\improper FN P-09 magazine"
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_items.dmi'
	icon_state = "p90"
	ammo_type = /obj/item/ammo_casing/c385
	caliber = ".385"
	max_ammo = 45
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/pps
	name = "\improper SSG-43"
	desc = "A very cheap, barely reliable reproduction of a personal defense weapon based on the original Soviet model. Not nearly as infamous as the Mosin."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_guns40x32.dmi'
	icon_state = "pps"
	lefthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_lefthand.dmi'
	righthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_righthand.dmi'
	inhand_icon_state = "pps"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/pps
	weapon_weight = WEAPON_HEAVY
	can_suppress = FALSE
	fire_delay = 3
	projectile_damage_multiplier = 3.0 // makes base 7.62x25 (damage=5) -> ~15 for SSG-43
	worn_icon = 'icons/obj/weapons/guns/surplus/gunsgalore_back.dmi'
	worn_icon_state = "pps"
	fire_sound = 'sound/items/weapons/gun/surplus/fire/pps_fire.ogg'
	fire_sound_volume = 100

	rack_sound = 'sound/items/weapons/gun/surplus/interact/smg_cock.ogg'
	load_sound = 'sound/items/weapons/gun/surplus/interact/smg_magin.ogg'
	load_empty_sound = 'sound/items/weapons/gun/surplus/interact/smg_magin.ogg'
	eject_sound = 'sound/items/weapons/gun/surplus/interact/smg_magout.ogg'

/obj/item/gun/ballistic/automatic/pps/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/ammo_box/magazine/pps
	name = "pps magazine (7.62x25mm)"
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_items.dmi'
	icon_state = "pps"
	ammo_type = /obj/item/ammo_casing/realistic/a762x25
	caliber = "a762x25"
	max_ammo = 35
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/ppsh
	name = "\improper SSG-41"
	desc = "A reproduction of a simple Soviet SMG chambered in 7.62x25 Tokarev rounds. Its heavy wooden stock and leather breech buffer help absorb the bolt’s heavy recoil, making it great for spraying and praying. Uraaaa!"
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_guns40x32.dmi'
	icon_state = "ppsh"
	lefthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_lefthand.dmi'
	righthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_righthand.dmi'
	inhand_icon_state = "ppsh"
	worn_icon = 'icons/obj/weapons/guns/surplus/gunsgalore_back.dmi'
	worn_icon_state = "ppsh"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	accepted_magazine_type = /obj/item/ammo_box/magazine/ppsh
	can_suppress = FALSE
	spread = 20
	fire_delay = 0.5
	projectile_damage_multiplier = 3.2 // makes base 7.62x25 (damage=5) -> ~16 for SSG-41
	fire_sound = 'sound/items/weapons/gun/surplus/fire/ppsh_fire.ogg'
	fire_sound_volume = 80
	burst_size = 1
	rack_sound = 'sound/items/weapons/gun/surplus/interact/smg_cock.ogg'
	load_sound = 'sound/items/weapons/gun/surplus/interact/smg_magin.ogg'
	load_empty_sound = 'sound/items/weapons/gun/surplus/interact/smg_magin.ogg'
	eject_sound = 'sound/items/weapons/gun/surplus/interact/smg_magout.ogg'

/obj/item/gun/ballistic/automatic/ppsh/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/ammo_box/magazine/ppsh
	name = "SSG-56 magazine (7.62x25mm)"
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_items.dmi'
	icon_state = "ppsh"
	ammo_type = /obj/item/ammo_casing/realistic/a762x25
	caliber = "a762x25"
	max_ammo = 71
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/ppsh/modern
	name = "\improper SSG-56"
	desc = "The old rifle of the Old Empire. It was used during the Civil War. The blueprints were transferred to InteQ mercenaries, and they began to use this weapons as a cheap replacement for new products."
	icon_state = "ppsh_modern"
	worn_icon_state = "ppsh"
	inhand_icon_state = "ppsh"
	spread = 15
	burst_size = 1
	projectile_damage_multiplier = 4.6 // makes base 7.62x25 (damage=5) -> ~23 for SSG-56

/obj/item/gun/ballistic/automatic/scar
	name = "SCAR-L"
	desc = "This rifle was developed to replace the M61 in planetary garrisons of the Solar Federation, but war on multiple fronts prevented sufficient funding for mass production. The weapon's design was acquired by Armdyne Technology. The rifle is currently distributed on the Solar Federation arms market. It is used by military and special forces units in the Solar System. A small number are supplied to private armies and corporate security agencies. The weapon is engraved with a four-pointed star and the inscription \"Armdyne-Technology\"."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_guns40x32.dmi'
	icon_state = "scar"
	lefthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_lefthand.dmi'
	righthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_righthand.dmi'
	inhand_icon_state = "scar"
	worn_icon = 'icons/obj/weapons/guns/surplus/gunsgalore_back.dmi'
	worn_icon_state = "scar"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	accepted_magazine_type = /obj/item/ammo_box/magazine/scar
	can_suppress = FALSE
	fire_delay = 2.4
	fire_sound = 'sound/items/weapons/gun/surplus/fire/scar_fire.ogg'
	fire_sound_volume = 50
	rack_sound = 'sound/items/weapons/gun/surplus/interact/scar_cock.ogg'
	load_sound = 'sound/items/weapons/gun/surplus/interact/scar_mag_out.ogg'
	load_empty_sound = 'sound/items/weapons/gun/surplus/interact/scar_mag_in.ogg'
	eject_sound = 'sound/items/weapons/gun/surplus/interact/scar_mag_out.ogg'
	burst_size = 1
	projectile_damage_multiplier = 0.57

/obj/item/gun/ballistic/automatic/scar/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/ammo_box/magazine/scar
	name = "\improper SCAR-L magazine"
	desc = "A double-stack translucent polymer magazine for use with the M-61 rifles. Holds 30 rounds of .277 Aestus."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_items.dmi'
	icon_state = "stg"
	ammo_type = /obj/item/ammo_casing/a223
	caliber = CALIBER_A223
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/stg
	name = "\improper StG-99"
	desc = "A reproduction of the Sturmgewehr 44 German infantry rifle chambered in 7.92mm, manufactured by the Oldarms division of the Armadyne Corporation."
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_guns40x32.dmi'
	icon_state = "stg"
	lefthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_lefthand.dmi'
	righthand_file = 'icons/obj/weapons/guns/surplus/gunsgalore_righthand.dmi'
	inhand_icon_state = "stg"
	worn_icon = 'icons/obj/weapons/guns/surplus/gunsgalore_back.dmi'
	worn_icon_state = "stg"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	accepted_magazine_type = /obj/item/ammo_box/magazine/stg
	can_suppress = FALSE
	fire_delay = 1.5
	burst_size = 1
	actions_types = list()
	fire_sound = 'sound/items/weapons/gun/surplus/fire/stg_fire.ogg'
	projectile_damage_multiplier = 3.3333333 // makes 7.92x33 base 6 -> ~20 per shot
	fire_sound_volume = 70
	rack_sound = 'sound/items/weapons/gun/surplus/interact/ltrifle_cock.ogg'
	load_sound = 'sound/items/weapons/gun/surplus/interact/ltrifle_magin.ogg'
	load_empty_sound = 'sound/items/weapons/gun/surplus/interact/ltrifle_magin.ogg'
	eject_sound = 'sound/items/weapons/gun/surplus/interact/ltrifle_magout.ogg'

/obj/item/gun/ballistic/automatic/stg/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/ammo_box/magazine/stg
	name = "stg magazine (7.92x33mm)"
	icon = 'icons/obj/weapons/guns/surplus/gunsgalore_items.dmi'
	icon_state = "stg"
	ammo_type = /obj/item/ammo_casing/realistic/a792x33
	caliber = "a792x33"
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY
