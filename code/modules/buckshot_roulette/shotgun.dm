// Buckshoot Roulette Ammunition

/obj/projectile/bullet/shotgun_slug/buckshoot
	name = "buckshot slug"
	damage = 300
	damage_type = OXY
	armour_penetration = 100
	icon_state = "slug"

/obj/projectile/bullet/shotgun_slug/blankshoot
	name = "buckshot blank slug"
	damage = 0
	damage_type = OXY
	armour_penetration = 0
	icon_state = "slug"

/obj/item/ammo_casing/shotgun/buckshoot
	name = "buckshoot shell"
	desc = "A mysterious shotgun shell used in Buckshoot Roulette."
	caliber = CALIBER_SHOTGUN
	pellets = 1
	variance = 0

/obj/item/ammo_casing/shotgun/buckshoot/blank
	name = "buckshot blank shell"
	desc = "A harmless blank shotgun shell for Buckshoot Roulette."
	icon_state = "bshell"
	projectile_type = /obj/projectile/bullet/shotgun_slug/blankshoot

/obj/item/ammo_casing/shotgun/buckshoot/blank/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	// playsound(fired_from || get_turf(src), 'sound/weapons/gun/revolver/empty.ogg', 100, TRUE)
	..()

/obj/item/ammo_casing/shotgun/buckshoot/live
	name = "buckshot live shell"
	desc = "A deadly live shotgun shell for Buckshoot Roulette."
	icon_state = "gshell"
	projectile_type = /obj/projectile/bullet/shotgun_slug/buckshoot

// Buckshoot Roulette Shotgun

/obj/item/gun/ballistic/shotgun/buckshot_game
	name = "\improper Buckshot shotgun"
	desc = "A modified shotgun designed for the Buckshoot Roulette game. It features a unique internal mechanism that loads and cycles a shuffled mix of live and blank rounds."
	icon_state = "dshotgun_l"
	worn_icon_state = "shotgun_combat"
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 2 SECONDS
	can_be_sawn_off = TRUE
	var/list/chambers = list()
	var/datum/weakref/party_ref = null
	var/static/list/possible_ammo_types = list(
		/obj/item/ammo_casing/shotgun/buckshoot/live,
		/obj/item/ammo_casing/shotgun/buckshoot/blank
	)

	var/last_shoot_result = ""
	var/shotingself = FALSE
	var/shot_in_progress = FALSE

/obj/item/gun/ballistic/shotgun/buckshot_game/Initialize(mapload, datum/buckshoot_roulette_party/party)
	. = ..()
	if(party)
		party_ref = WEAKREF(party)
	chambers.Cut()
	chambered = null
	magazine = null

/obj/item/gun/ballistic/shotgun/buckshot_game/examine(mob/user)
	if(length(chambers))
		. += span_notice("It has [length(chambers)] rounds left.")


/obj/item/gun/ballistic/shotgun/buckshot_game/attempt_pickup(mob/living/user, skip_grav)
	if(!party_ref)
		return ..()
	var/datum/buckshoot_roulette_party/party = party_ref.resolve()
	if(!party)
		return ..()
	if(!party.game_started)
		return ..()
	if(party.current_turn_player != user)
		to_chat(user, span_warning("It is not your turn!"))
		return FALSE
	return ..()

/obj/item/gun/ballistic/shotgun/buckshot_game/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	if(shotingself || shot_in_progress)
		return TRUE
	INVOKE_ASYNC(src, PROC_REF(try_fire_gun), target, user, modifiers)
	return TRUE

/obj/item/gun/ballistic/shotgun/buckshot_game/pre_attack_secondary(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	if(shotingself || shot_in_progress)
		return TRUE
	INVOKE_ASYNC(src, PROC_REF(try_fire_gun), target, user, modifiers)
	return TRUE

/obj/item/gun/ballistic/shotgun/buckshot_game/proc/check_gunpoint(mob/living/user, mob/living/target)
	for(var/datum/gunpoint/gunpoint in target.gunpointed)
		if(gunpoint.source == user && gunpoint.target == target)
			return TRUE
	return FALSE

/obj/item/gun/ballistic/shotgun/buckshot_game/proc/can_target_player(mob/living/target, mob/living/user, datum/buckshoot_roulette_party/party)
	if(!party.is_participant(target))
		user.balloon_alert(user, "not in the game!")
		return FALSE
	if(target.stat == DEAD)
		user.balloon_alert(user, "already dead!")
		return FALSE
	var/datum/component/buckshoot_roulette_participant/participant = target.GetComponent(/datum/component/buckshoot_roulette_participant)
	if(!participant || participant.player_completely_dead())
		user.balloon_alert(user, "out of the game!")
		return FALSE
	return TRUE

/obj/item/gun/ballistic/shotgun/buckshot_game/try_fire_gun(atom/target, mob/living/user, params)
	if(!party_ref)
		return ..()
	if(shotingself || shot_in_progress)
		return
	var/datum/buckshoot_roulette_party/party = party_ref.resolve()
	if(!party)
		return ..()
	if(party.game_started && party.current_turn_player != user)
		to_chat(user, span_warning("It is not your turn!"))
		return
	if(!ishuman(target))
		return
	var/mob/living/living_target = target
	if(!can_target_player(living_target, user, party))
		return
	if(target == user && !shotingself)
		attempt_shotself(user)
		return
	return ..()


/obj/item/gun/ballistic/shotgun/buckshot_game/proc/attempt_shotself(mob/living/user)
	if(shotingself)
		return
	shotingself = TRUE
	user.visible_message(span_warning("[user.name] aims [src.name] at [user.p_them()]!"))
	user.balloon_alert(user, "aiming at yourself...")
	var/ask_shoot_self = tgui_alert(user, "Shoot yourself?", "Do you want to shoot yourself?", list("Try your luck", "No"), timeout = 10 SECONDS)
	if(ask_shoot_self != "Try your luck")
		user.balloon_alert(user, "you lower the gun")
		user.visible_message(span_notice("[user.name] decides not to shoot [user.p_them()] with [src.name]."))
		shotingself = FALSE
		return
	fire_gun(user, user)

/obj/item/gun/ballistic/shotgun/buckshot_game/fire_gun(atom/target, mob/living/user, flag, params)
	if(!isliving(target))
		return
	if(shot_in_progress)
		return
	var/mob/living/living_target = target
	var/datum/buckshoot_roulette_party/party = party_ref.resolve()
	if(!party)
		return
	if(party.game_started && party.current_turn_player != user)
		to_chat(user, span_warning("It is not your turn!"))
		return
	var/datum/component/gun_safety/safety_comp = GetComponent(/datum/component/gun_safety)
	if(safety_comp && safety_comp.safety_currently_on)
		safety_comp.toggle_safeties(user)

	if(!can_target_player(living_target, user, party))
		return
	if(living_target != user)
		if(!check_gunpoint(user, living_target))
			user.DoGunpoint(living_target, src)
			user.balloon_alert(user, "ready to fire!")
			return

	shot_in_progress = TRUE
	if(istype(chambered, /obj/item/ammo_casing/shotgun/buckshoot/live))
		last_shoot_result = "live"
	else if(istype(chambered, /obj/item/ammo_casing/shotgun/buckshoot/blank))
		last_shoot_result = "blank"
	else
		last_shoot_result = "empty"

	if(living_target == user && shotingself)
		shotingself = FALSE

	. = ..()
	if(!.)
		shot_in_progress = FALSE
		return
	addtimer(CALLBACK(party, TYPE_PROC_REF(/datum/buckshoot_roulette_party, after_player_shoot), user, living_target, last_shoot_result), 1 SECONDS)

/obj/item/gun/ballistic/shotgun/buckshot_game/attack_self(mob/living/user)
	if(shotingself || shot_in_progress)
		return TRUE
	INVOKE_ASYNC(src, PROC_REF(try_fire_gun), user, user, list())
	return TRUE

/obj/item/gun/ballistic/shotgun/buckshot_game/rack(mob/user)
	. = ..()
	load_chamber()

/obj/item/gun/ballistic/shotgun/buckshot_game/chamber_round(spin_cylinder, replace_new_round)
	return

/obj/item/gun/ballistic/shotgun/buckshot_game/load_gun(obj/item/ammo, mob/living/user)
	return

/obj/item/gun/ballistic/shotgun/buckshot_game/proc/load_chamber()
	if(chambered)
		return
	if(!length(chambers))
		return
	chambered = chambers[1]
	chambers.Cut(1, 2)

/obj/item/gun/ballistic/shotgun/buckshot_game/proc/load_rounds(live_count = 0, blank_count = 0)
	var/datum/buckshoot_roulette_party/party = party_ref?.resolve()
	QDEL_LIST(chambers)
	chambers = list()
	qdel(chambered)
	for(var/i in 1 to live_count)
		chambers += new /obj/item/ammo_casing/shotgun/buckshoot/live(src)
		party?.play_game_sound('sound/buckshot_roulette/load_shell.ogg', 70)
		sleep(0.2 SECONDS)
	for(var/i in 1 to blank_count)
		chambers += new /obj/item/ammo_casing/shotgun/buckshoot/blank(src)
		party?.play_game_sound('sound/buckshot_roulette/load_shell.ogg', 70)
		sleep(0.2 SECONDS)
	for(var/i = 1 to 3)
		chambers = shuffle(chambers)
	load_chamber()
	return TRUE


/obj/item/gun/ballistic/shotgun/buckshot_game/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SAW || I.tool_behaviour == TOOL_WIRECUTTER)
		saw_off(user)
		return
	return ..()

/obj/item/gun/ballistic/shotgun/buckshot_game/proc/saw_off(mob/user)
	sawoff(user, user.get_active_held_item(), FALSE)
