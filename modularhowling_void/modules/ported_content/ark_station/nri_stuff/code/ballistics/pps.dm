/obj/item/gun/ballistic/automatic/pps // Dont Use in GunCargo
	name = "\improper SSG-43"
	desc = "A very cheap, barely reliable reproduction of a personal defense weapon based on the original Soviet model. Not nearly as infamous as the Mosin."
	icon = 'modularhowling_void/modules/ported_content/ark_station/nri_stuff/icons/guns/gunsgalore_guns40x32.dmi'
	icon_state = "pps"
	lefthand_file = 'modularhowling_void/modules/ported_content/ark_station/nri_stuff/icons/guns/gunsgalore_lefthand.dmi'
	righthand_file = 'modularhowling_void/modules/ported_content/ark_station/nri_stuff/icons/guns/gunsgalore_righthand.dmi'
	inhand_icon_state = "pps"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/pps
	weapon_weight = WEAPON_HEAVY
	can_suppress = FALSE
	fire_delay = 3
	projectile_damage_multiplier = 3.0 // makes base 7.62x25 (damage=5) -> ~15 for SSG-43
	worn_icon = 'modularhowling_void/modules/ported_content/ark_station/nri_stuff/icons/guns/gunsgalore_back.dmi'
	worn_icon_state = "pps"
	fire_sound = 'modularhowling_void/modules/ported_content/ark_station/nri_stuff/sound/guns/fire/pps_fire.ogg'
	fire_sound_volume = 100

	rack_sound = 'modularhowling_void/modules/ported_content/ark_station/nri_stuff/sound/guns/interact/smg_cock.ogg'
	load_sound = 'modularhowling_void/modules/ported_content/ark_station/nri_stuff/sound/guns/interact/smg_magin.ogg'
	load_empty_sound = 'modularhowling_void/modules/ported_content/ark_station/nri_stuff/sound/guns/interact/smg_magin.ogg'
	eject_sound = 'modularhowling_void/modules/ported_content/ark_station/nri_stuff/sound/guns/interact/smg_magout.ogg'

/obj/item/gun/ballistic/automatic/pps/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/ammo_box/magazine/pps
	name = "pps magazine (7.62x25mm)"
	icon = 'modularhowling_void/modules/ported_content/ark_station/nri_stuff/icons/guns/gunsgalore_items.dmi'
	icon_state = "pps"
	ammo_type = /obj/item/ammo_casing/realistic/a762x25
	caliber = "a762x25"
	max_ammo = 35
	multiple_sprites = AMMO_BOX_FULL_EMPTY
