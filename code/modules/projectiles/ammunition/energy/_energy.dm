/obj/item/ammo_casing/energy
	name = "energy weapon lens"
	desc = "The part of the gun that makes the laser go pew."
	caliber = ENERGY
	projectile_type = /obj/projectile/energy
	slot_flags = null
	var/e_cost = LASER_SHOTS(10, STANDARD_CELL_CHARGE) //The amount of energy a cell needs to expend to create this shot.
	var/select_name = CALIBER_ENERGY
	fire_sound = 'sound/items/weapons/gun/energy/laser.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/red
	newtonian_force = 0.5
	muzzle_flash_color = LIGHT_COLOR_CYAN


// BEGIN NOVA CORE MIGRATION: code/modules/projectiles/ammunition/energy/_energy.dm
/obj/item/ammo_casing/energy
	/// This is the color that shows up when selecting an ammo type. Disabled by default
	var/select_color
// END NOVA CORE MIGRATION: code/modules/projectiles/ammunition/energy/_energy.dm
