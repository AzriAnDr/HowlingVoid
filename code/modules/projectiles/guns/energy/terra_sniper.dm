/**
 * Terra Experimental Laser Sniper Rifle
 * Ported from RuTGMC-Reborn
 *
 * A high-powered laser sniper rifle with multiple firing modes:
 * - Standard: Balanced damage and penetration
 * - Heat: Incendiary rounds that set targets on fire
 * - Overcharge: High damage, high penetration, slow fire rate with charge-up (hitscan)
 *
 * Features:
 * - Requires two-handed wielding to fire
 * - 40% movement slowdown when wielded
 * - Right-clicking the rifle in hand switches firing modes
 * - attack_self toggles wielded stance
 */

// ========== PROJECTILES ==========

/obj/projectile/beam/laser/terra_sniper
	name = "sniper laser"
	icon_state = "heavylaser"
	damage = 60
	armour_penetration = 60
	range = 40
	speed = 2
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = COLOR_SOFT_RED
	wound_bonus = 10
	exposed_wound_bonus = 20

/obj/projectile/beam/laser/terra_sniper/heat
	name = "heat laser"
	icon_state = "heavylaser"
	damage = 40
	armour_penetration = 60
	light_color = COLOR_MOSTLY_PURE_ORANGE

/obj/projectile/beam/laser/terra_sniper/heat/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.adjust_fire_stacks(3)
		living_target.ignite_mob()

/obj/projectile/beam/laser/terra_sniper/overcharge
	name = "overcharged sniper laser"
	damage = 95
	armour_penetration = 100
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/terra_overcharge
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = COLOR_DARK_PURPLE
	wound_bonus = 20
	exposed_wound_bonus = 30
	hitscan_light_color_override = COLOR_DARK_PURPLE
	hitscan_light_intensity = 2
	hitscan_light_range = 1

/obj/effect/projectile/tracer/terra_overcharge
	name = "overcharged beam"
	icon = 'icons/effects/beam.dmi'
	icon_state = "darkbeam"

// ========== AMMO CASINGS ==========

/obj/item/ammo_casing/energy/laser/terra_sniper
	projectile_type = /obj/projectile/beam/laser/terra_sniper
	e_cost = LASER_SHOTS(12, STANDARD_CELL_CHARGE)
	select_name = "standard"
	fire_sound = 'sound/items/weapons/gun/laser_sniper/standard.ogg'

/obj/item/ammo_casing/energy/laser/terra_sniper/heat
	projectile_type = /obj/projectile/beam/laser/terra_sniper/heat
	e_cost = LASER_SHOTS(8, STANDARD_CELL_CHARGE)
	select_name = "heat"
	fire_sound = 'sound/items/weapons/laser3.ogg'

/obj/item/ammo_casing/energy/laser/terra_sniper/overcharge
	projectile_type = /obj/projectile/beam/laser/terra_sniper/overcharge
	e_cost = LASER_SHOTS(4, STANDARD_CELL_CHARGE)
	select_name = "overcharge"
	fire_sound = 'sound/items/weapons/gun/laser_sniper/overcharge_fire.ogg'

// ========== THE GUN ==========

/obj/item/gun/energy/laser/terra_sniper
	name = "\improper Terra Experimental laser sniper rifle"
	desc = "The T-ES, a Terra Experimental standard issue laser sniper rifle. It features an integrated charge selector for standard, heat, and overcharge firing modes. \
		Uses standard power cells. The lightweight alloy construction and lack of physical ammunition makes it surprisingly manageable for its size. \
		Must be wielded with both hands to fire."
	icon = 'icons/obj/weapons/guns/terra/terra_sniper.dmi'
	icon_state = "tes"
	inhand_icon_state = "tes"
	worn_icon_state = "tes"
	lefthand_file = 'icons/mob/inhands/weapons/guns/terra/lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns/terra/righthand.dmi'
	worn_icon = 'icons/mob/clothing/back.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	inhand_x_dimension = 64
	inhand_y_dimension = 32
	weapon_weight = WEAPON_MEDIUM
	force = 15
	ammo_type = list(
		/obj/item/ammo_casing/energy/laser/terra_sniper,
		/obj/item/ammo_casing/energy/laser/terra_sniper/heat,
		/obj/item/ammo_casing/energy/laser/terra_sniper/overcharge,
	)
	shaded_charge = FALSE
	automatic_charge_overlays = FALSE
	ammo_x_offset = 1
	charge_sections = 4
	light_color = COLOR_SOFT_RED

	/// Fire delay for standard mode
	var/standard_fire_delay = 0.8 SECONDS
	/// Fire delay for heat mode
	var/heat_fire_delay = 1 SECONDS
	/// Fire delay for overcharge mode
	var/overcharge_fire_delay = 3 SECONDS
	/// Windup delay for overcharge
	var/overcharge_windup = 2 SECONDS
	/// Are we currently charging an overcharge shot?
	var/charging_overcharge = FALSE
	/// Movement slowdown when wielded (40%)
	var/wielded_slowdown = 0.4

	selfcharge = TRUE
	self_charge_amount = 0.01 * STANDARD_CELL_CHARGE
	charge_delay = 0

/obj/item/gun/energy/laser/terra_sniper/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 3)
	AddComponent(/datum/component/two_handed, \
		icon_wielded = "tes_wielded", \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)))
	update_fire_delay()

/obj/item/gun/energy/laser/terra_sniper/proc/on_wield(obj/item/source, mob/user)
	user.add_movespeed_modifier(/datum/movespeed_modifier/terra_sniper_wielded)
	inhand_icon_state = "tes_w"
	if(user)
		user.update_held_items()

/obj/item/gun/energy/laser/terra_sniper/proc/on_unwield(obj/item/source, mob/user)
	user.remove_movespeed_modifier(/datum/movespeed_modifier/terra_sniper_wielded)
	inhand_icon_state = "tes"
	if(user)
		user.update_held_items()

/datum/movespeed_modifier/terra_sniper_wielded
	multiplicative_slowdown = 0.4

/obj/item/gun/energy/laser/terra_sniper/update_icon_state()
	. = ..()
	if(!cell || cell.charge == 0)
		icon_state = "tes_e"
	else
		icon_state = "tes"

/obj/item/gun/energy/laser/terra_sniper/update_overlays()
	. = ..()
	if(!cell)
		return
	var/charge_percent = cell.percent()
	var/charge_state
	switch(charge_percent)
		if(76 to 100)
			charge_state = "te_100"
		if(51 to 75)
			charge_state = "te_75"
		if(26 to 50)
			charge_state = "te_50"
		if(1 to 25)
			charge_state = "te_25"
		else
			return
	. += mutable_appearance(icon, charge_state)

/obj/item/gun/energy/laser/terra_sniper/attack_self(mob/user, modifiers)
	var/datum/component/two_handed/th_comp = GetComponent(/datum/component/two_handed)
	if(th_comp)
		if(HAS_TRAIT(src, TRAIT_WIELDED))
			th_comp.unwield(user)
		else
			th_comp.wield(user)
	return TRUE

/obj/item/gun/energy/laser/terra_sniper/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(.)
		return
	select_fire(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/gun/energy/laser/terra_sniper/select_fire(mob/living/user)
	. = ..()
	update_fire_delay()

/obj/item/gun/energy/laser/terra_sniper/proc/update_fire_delay()
	var/obj/item/ammo_casing/energy/current = ammo_type[select]
	if(istype(current, /obj/item/ammo_casing/energy/laser/terra_sniper/overcharge))
		fire_delay = overcharge_fire_delay
	else if(istype(current, /obj/item/ammo_casing/energy/laser/terra_sniper/heat))
		fire_delay = heat_fire_delay
	else
		fire_delay = standard_fire_delay

/obj/item/gun/energy/laser/terra_sniper/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		balloon_alert(user, "must wield to fire!")
		return
	if(charging_overcharge)
		return
	var/obj/item/ammo_casing/energy/current = ammo_type[select]
	if(istype(current, /obj/item/ammo_casing/energy/laser/terra_sniper/overcharge))
		charging_overcharge = TRUE
		to_chat(user, span_warning("[src] begins to charge up..."))
		playsound(src, 'sound/items/weapons/gun/laser_sniper/overcharge_charge.ogg', 50, TRUE)
		if(!do_after(user, overcharge_windup, src, IGNORE_USER_LOC_CHANGE))
			charging_overcharge = FALSE
			return
		charging_overcharge = FALSE
		var/datum/component/scope/scope_component = GetComponent(/datum/component/scope)
		if(user.client)
			if(scope_component?.tracker?.given_turf)
				target = scope_component.get_target(scope_component.tracker.given_turf)
			else
				var/atom/new_target = user.client.mouse_object_ref?.resolve()
				if(new_target)
					target = new_target
					params = user.client.mouseParams
				else
					var/atom/loc_target = user.client.mouse_location_ref?.resolve()
					if(loc_target)
						target = loc_target
						params = user.client.mouseParams
	return ..(target, user, message, params, zone_override, bonus_spread)

/obj/item/gun/energy/laser/terra_sniper/examine(mob/user)
	. = ..()
	. += span_notice("It has three firing modes: <b>standard</b>, <b>heat</b>, and <b>overcharge</b>.")
	. += span_notice("Use <b>right-click on [src] in hand</b> to switch fire modes.")
	. += span_notice("Use <b>[src]</b> in hand to toggle two-handed wielding. Must be wielded to fire.")
	. += span_notice("Overcharge mode can be charged <b>while moving</b>.")
	. += span_notice("The rifle slowly <b>self-recharges</b> at 1% per second when not firing.")
	. += span_notice("Use <b>right-click on a target tile</b> to use the scope.")

/obj/item/gun/energy/laser/terra_sniper/syndicate
	name = "\improper Syndicate Terra Experimental laser sniper rifle"
	desc = "A stolen and modified Terra Experimental sniper rifle. This one has been outfitted with a Syndicate implant-linked firing pin."
	pin = /obj/item/firing_pin/implant/pindicate