#define CRYSTAL_SHIELD_DELAY 50 SECONDS
#define CRYSTAL_CHARGING 0
#define CRYSTAL_LOCATION_ANNOUNCED 1
#define CRYSTAL_FULLY_CHARGED 2
#define SHIELD_ACTIVE "active"
#define SHIELD_DEFLECT "deflect"
#define SHIELD_BREAK "break"
#define SHIELD_BROKEN "broken"

/obj/structure/destructible/clockwork/anchoring_crystal
	name = "Anchoring Crystal"
	desc = "A strange brass-veined crystal that is difficult to focus on."
	icon_state = "obelisk"
	break_message = span_warning("As the Anchoring Crystal shatters you swear you hear a faint scream.")
	break_sound = 'sound/machines/clockcult/ark_deathrattle.ogg'
	immune_to_servant_attacks = TRUE
	clockwork_desc = "Anchors Reebe to this realm. The Ark will not open until enough Anchoring Crystals have fully charged."
	resistance_flags = FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	armor_type = /datum/armor/anchoring_crystal
	max_integrity = 250
	var/shields = 3
	var/charge_state = CRYSTAL_CHARGING
	var/area/crystal_area
	var/charging_for = 0
	var/overlay_state = SHIELD_ACTIVE
	COOLDOWN_DECLARE(recently_hit_cd)

/datum/armor/anchoring_crystal
	bio = 100
	bomb = 100
	energy = 100
	fire = 100
	acid = 100
	melee = -15
	laser = 60
	bullet = 30

/obj/structure/destructible/clockwork/anchoring_crystal/Initialize(mapload)
	. = ..()
	crystal_area = get_area(src)
	GLOB.clock_anchoring_crystals[src] = FALSE
	GLOB.clock_marked_areas[crystal_area] = TRUE

	AddComponent(/datum/component/brass_spreader, range = 6)
	priority_announce("Reality-warping object detected aboard [station_name()]. Emergency shuttle uplink instability is possible.", "Higher Dimensional Affairs")
	send_clock_message(null, span_bigbrass(span_bold("An Anchoring Crystal has been created at [crystal_area], defend it!")), msg_ghosts = FALSE)
	START_PROCESSING(SSobj, src)
	RegisterSignal(src, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	update_icon()

/obj/structure/destructible/clockwork/anchoring_crystal/Destroy()
	if(charge_state == CRYSTAL_FULLY_CHARGED)
		GLOB.charged_anchoring_crystals = max(GLOB.charged_anchoring_crystals - 1, 0)
	GLOB.clock_anchoring_crystals -= src
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(src, COMSIG_ATOM_UPDATE_OVERLAYS)
	send_clock_message(null, span_bigbrass(span_bold("The Anchoring Crystal at [crystal_area] has been destroyed!")), msg_ghosts = FALSE)
	return ..()

/obj/structure/destructible/clockwork/anchoring_crystal/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	COOLDOWN_START(src, recently_hit_cd, CRYSTAL_SHIELD_DELAY)
	if(shields >= 1)
		shields--
		visible_message(span_warning("The attack is deflected by the shield of [src]."))
		overlay_state = shields > 0 ? SHIELD_DEFLECT : SHIELD_BREAK
		do_sparks(2, TRUE, src)
		update_icon()
		damage_amount = 0
	return ..()

/obj/structure/destructible/clockwork/anchoring_crystal/process(seconds_per_tick)
	if(charge_state == CRYSTAL_FULLY_CHARGED)
		GLOB.clock_power = min(GLOB.clock_power + (5 * seconds_per_tick), GLOB.max_clock_power)
		return

	charging_for = min(charging_for + (seconds_per_tick SECONDS), ANCHORING_CRYSTAL_CHARGE_DURATION)

	if(shields < initial(shields) && COOLDOWN_FINISHED(src, recently_hit_cd))
		playsound(src, 'sound/effects/magic/charge.ogg', 50, TRUE)
		shields++
		overlay_state = SHIELD_ACTIVE
		update_icon()

	if(charging_for >= ANCHORING_CRYSTAL_CHARGE_DURATION)
		finish_charging()
		return

	if(charge_state < CRYSTAL_LOCATION_ANNOUNCED && charging_for >= 30 SECONDS)
		charge_state = CRYSTAL_LOCATION_ANNOUNCED
		priority_announce("Reality-warping object located in [crystal_area].", "Central Command Higher Dimensional Affairs")

/obj/structure/destructible/clockwork/anchoring_crystal/examine(mob/user)
	. = ..()
	if(IS_CLOCK(user) || isobserver(user))
		. += span_brass(charge_state == CRYSTAL_FULLY_CHARGED ? "It is fully charged and effectively indestructible." : "It will be fully charged in [DisplayTimeText(ANCHORING_CRYSTAL_CHARGE_DURATION - charging_for)].")

/obj/structure/destructible/clockwork/anchoring_crystal/proc/finish_charging()
	if(charge_state == CRYSTAL_FULLY_CHARGED)
		return

	charge_state = CRYSTAL_FULLY_CHARGED
	GLOB.clock_anchoring_crystals[src] = TRUE
	GLOB.charged_anchoring_crystals++
	GLOB.max_clock_power += 2500
	GLOB.clock_power = GLOB.max_clock_power
	resistance_flags |= INDESTRUCTIBLE
	atom_integrity = INFINITY
	desc += " Reality around it shimmers, making it effectively impervious to damage."
	send_clock_message(null, span_bigbrass(span_bold("The Anchoring Crystal at [crystal_area] has fully charged! [anchoring_crystal_charge_message()]")), msg_ghosts = FALSE)
	priority_announce("Reality in [crystal_area] has been destabilized. Personnel are advised to avoid the area.", "Central Command Higher Dimensional Affairs")

/obj/structure/destructible/clockwork/anchoring_crystal/proc/on_update_overlays(atom/crystal, list/overlays)
	SIGNAL_HANDLER

	var/mutable_appearance/shield_appearance = mutable_appearance('icons/clock_cult/clockwork_effects.dmi', overlay_state == SHIELD_BROKEN ? "broken" : "clock_shield", ABOVE_OBJ_LAYER)
	if(overlay_state == SHIELD_DEFLECT)
		shield_appearance.icon_state = "clock_shield_deflect"
		overlay_state = SHIELD_ACTIVE
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 3)
	else if(overlay_state == SHIELD_BREAK)
		shield_appearance.icon_state = "clock_shield_break"
		overlay_state = SHIELD_BROKEN
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 2)
	overlays += shield_appearance

/proc/anchoring_crystal_charge_message()
	var/charged_crystals = min(GLOB.charged_anchoring_crystals, ANCHORING_CRYSTALS_TO_SUMMON)
	var/crystals_remaining = max(ANCHORING_CRYSTALS_TO_SUMMON - charged_crystals, 0)
	var/progress_text = "([charged_crystals]/[ANCHORING_CRYSTALS_TO_SUMMON])"

	if(!crystals_remaining)
		return "All required Anchoring Crystals are charged [progress_text]. Create the Ark and strike it with a Clockwork Slab to open the way for Ratvar."

	return "[crystals_remaining] more Anchoring Crystal[crystals_remaining == 1 ? "" : "s"] must be charged before the Ark can open [progress_text]."

#undef CRYSTAL_SHIELD_DELAY
#undef CRYSTAL_CHARGING
#undef CRYSTAL_LOCATION_ANNOUNCED
#undef CRYSTAL_FULLY_CHARGED
#undef SHIELD_ACTIVE
#undef SHIELD_DEFLECT
#undef SHIELD_BREAK
#undef SHIELD_BROKEN
