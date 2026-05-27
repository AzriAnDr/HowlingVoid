/obj/item/buckshot_game
	name = "buckshot game item"
	var/use_desc = "This item is used to manage a game of buckshot roulette."
	var/mob/living/carbon/human/owner_player = null
	var/datum/buckshoot_roulette_party/party = null
	var/use_on_death = FALSE

	obj_flags = INDESTRUCTIBLE|BOMB_PROOF|LAVA_PROOF|FIRE_PROOF

/obj/item/buckshot_game/Initialize(mapload, mob/living/carbon/human/owner, datum/buckshoot_roulette_party/party_instance)
	. = ..()
	owner_player = owner
	party = party_instance


/obj/item/buckshot_game/examine(mob/user)
	. = ..()
	. += "\n" + span_notice(use_desc)


/obj/item/buckshot_game/attempt_pickup(mob/living/user, skip_grav)
	if(!party)
		return ..()
	if(user != owner_player)
		to_chat(user, span_warning("This is not your item!"))
		return FALSE
	if(!party.game_started)
		return FALSE
	return ..()


/obj/item/buckshot_game/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ishuman(interacting_with) && !istype(interacting_with, /obj/item/gun/ballistic/shotgun/buckshot_game))
		return ..()

	if(!party.game_started)
		to_chat(user, span_warning("The game has not started yet!"))
		return ITEM_INTERACT_SUCCESS
	if(user != owner_player)
		to_chat(user, span_warning("This is not your item!"))
		return ITEM_INTERACT_SUCCESS
	if(party.current_turn_player != user)
		to_chat(user, span_warning("It is not your turn!"))
		return ITEM_INTERACT_SUCCESS
	if(istype(interacting_with, /obj/item/gun/ballistic/shotgun/buckshot_game))
		use_on_shotgun(interacting_with, user)
	if(istype(interacting_with, /mob/living/carbon/human))
		var/mob/living/carbon/human/player = interacting_with
		if(!party.is_participant(player))
			to_chat(user, span_warning("That player is not in the game!"))
			return ITEM_INTERACT_SUCCESS
		if(player.stat == DEAD && !use_on_death)
			to_chat(user, span_warning("You cannot use this on a dead player!"))
			return ITEM_INTERACT_SUCCESS
		if(player == user)
			use_on_self(player)
		else
			use_on_other(user, player)
	return ITEM_INTERACT_SUCCESS

/obj/item/buckshot_game/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ishuman(interacting_with) && !istype(interacting_with, /obj/item/gun/ballistic/shotgun/buckshot_game))
		return ..()
	if(!party.game_started)
		to_chat(user, span_warning("The game has not started yet!"))
		return ITEM_INTERACT_SUCCESS
	if(ishuman(interacting_with))
		var/mob/living/carbon/human/player = interacting_with
		if(!party.is_participant(player))
			to_chat(user, span_warning("That player is not in the game!"))
			return ITEM_INTERACT_SUCCESS
		if(player == user)
			use_on_self(player)
		else
			use_on_other(user, player)

/obj/item/buckshot_game/proc/use_on_other(mob/living/carbon/human/player, mob/living/carbon/human/other_player)
	return


/obj/item/buckshot_game/proc/use_on_self(mob/living/carbon/human/player)
	return


/obj/item/buckshot_game/proc/use_on_shotgun(obj/item/gun/ballistic/shotgun/buckshot_game/gun, mob/living/carbon/human/player)
	return


/obj/item/buckshot_game/cigarettes
	name = "premium cigarettes"
	desc = "A pack of cigarettes."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "robust"
	use_desc = "Restores one CRT charge."


/obj/item/buckshot_game/cigarettes/use_on_self(mob/living/carbon/human/player)
	player.balloon_alert_to_viewers("smokes a cigarette")
	var/datum/component/buckshoot_roulette_participant/participant = player.GetComponent(/datum/component/buckshoot_roulette_participant)
	if(!participant)
		to_chat(player, span_warning("You are not in the game!"))
		return
	if(participant.lives >= 3)
		to_chat(player, span_warning("You already have the maximum number of lives!"))
		return
	party.play_game_sound('sound/buckshot_roulette/item_cigarettes.ogg', 70)
	if(!do_after(player, 5 SECONDS))
		return
	participant.add_lives(1)
	qdel(src)


/obj/item/buckshot_game/glass
	name = "Magnifying glass"
	desc = "A Magnifying glass."
	use_desc = "Lets you inspect the shell currently chambered in the shotgun."
	icon = 'icons/primitive_production/prim_fun.dmi'
	icon_state = "magnifying_glass"

/obj/item/buckshot_game/glass/use_on_shotgun(obj/item/gun/ballistic/shotgun/buckshot_game/gun, mob/living/carbon/human/player)
	. = ..()
	if(!gun.chambered)
		to_chat(player, span_warning("There is no shell in the chamber!"))
		return
	player.balloon_alert_to_viewers("inspects the chamber")
	party.play_game_sound('sound/buckshot_roulette/item_magnifier.ogg', 70)
	if(!do_after(player, 3 SECONDS))
		return
	var/obj/item/ammo_casing/shotgun/buckshoot/round = gun.chambered
	var/msg = "The chamber holds "
	if(istype(round, /obj/item/ammo_casing/shotgun/buckshoot/live))
		msg += "a live shell."
	else if(istype(round, /obj/item/ammo_casing/shotgun/buckshoot/blank))
		msg += "a blank shell."
	else
		msg += "an unknown shell."
	to_chat(player, span_notice(msg))
	qdel(src)


/obj/item/buckshot_game/beer
	name = "space beer"
	desc = "Canned beer. In space."
	icon = 'icons/obj/drinks/soda.dmi'
	icon_state = "space_beer"
	use_desc = "Lets you rack the shotgun."

/obj/item/buckshot_game/beer/use_on_shotgun(obj/item/gun/ballistic/shotgun/buckshot_game/gun, mob/living/carbon/human/player)
	. = ..()
	party.play_game_sound('sound/buckshot_roulette/item_beer.ogg', 70)
	player.balloon_alert_to_viewers("drinks beer")
	if(!do_after(player, 5 SECONDS))
		return
	gun.rack(player)
	qdel(src)
