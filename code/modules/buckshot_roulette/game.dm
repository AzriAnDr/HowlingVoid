#define TIME_TO_TURN (1 MINUTES)
#define ITEM_BOX_TIMEOUT (1 MINUTES)
#define CRT_DEFIB_DELAY (1 SECONDS)
#define LIFE_LOSS_DELAY (6 SECONDS)
#define MAX_BUCKSHOT_LIVES 3
#define SHOOT_RESULT_LIVE "live"
#define SHOOT_RESULT_BLANK "blank"

/datum/buckshoot_roulette_party
	var/id
	VAR_PRIVATE/list/players
	VAR_PRIVATE/list/chairs
	VAR_FINAL/datum/weakref/shotgun_weakref
	VAR_FINAL/datum/weakref/table_weakref
	VAR_FINAL/death_round_threshold = 3
	var/game_started = FALSE
	var/can_free_exit = FALSE
	var/awaiting_players = list()
	var/registration = FALSE
	var/should_say_rules = TRUE
	var/static/list/rules = list(
		"1. Each round loads the shotgun with live and blank shells in a random order.",
		"2. On your turn, shoot yourself or another player.",
		"3. If you shoot yourself with a blank, you keep the turn.",
		"4. Dead players are revived by the CRT while they still have charges.",
		"5. The last living player wins.",
	)

	var/list/player_by_names = list() // assoc list(mob/living/carbon/human => string)

	var/round = 0
	var/is_last_round = FALSE
	var/round_started = FALSE
	var/current_turn_start_time = 0
	var/current_turn_player = null
	var/last_turn_player = null
	var/list/turn_order = list()
	var/turn_transition_in_progress = FALSE
	var/turn_time = TIME_TO_TURN

	var/list/all_items = list()
	var/list/items_by_players = list() // assoc list(mob/living/carbon/human => list(obj/item))
	var/list/pending_item_boxes = list()

	var/loading_ammo = FALSE
	var/ammo_declared = FALSE
	var/pause = FALSE

/datum/buckshoot_roulette_party/New(obj/structure/table/game_table)
	. = ..()
	table_weakref = WEAKREF(game_table)
	id = generate_uuid()
	detect_game_objects()

/datum/buckshoot_roulette_party/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/buckshoot_roulette_party/proc/detect_game_objects()
	chairs = list()
	var/obj/structure/table/table = table_weakref?.resolve()
	if(!table)
		return
	for(var/obj/structure/chair/buckshot/chair_instance in orange(2, table))
		if(!chair_instance.party)
			var/datum/weakref/chair_weakref = WEAKREF(chair_instance)
			chairs += chair_weakref
			chair_instance.party = src

/datum/buckshoot_roulette_party/proc/generate_uuid()
	return "[num2hex(rand(0,65535),4)]-[num2hex(rand(0,65535),4)]-[num2hex(rand(0,65535),4)]"


/datum/buckshoot_roulette_party/proc/attempt_start_game(mob/user)
	if(game_started)
		return
	if(registration)
		to_chat(user, span_warning("Player registration is already in progress."))
		return
	if(length(awaiting_players))
		to_chat(user, span_warning("Other players are still registering."))
		return
	awaiting_players = detect_candidates(user)
	if(length((awaiting_players)) < 2)
		to_chat(user, span_warning("Not enough players to start the game."))
		awaiting_players = null
		return

	var/ask = tgui_alert(user, "Start a game of Buckshoot Roulette?", "Start game?", list("Yes", "No"))
	if(ask != "Yes")
		awaiting_players = null
		return


	registration = TRUE
	for(var/mob/living/carbon/human/player in awaiting_players)
		var/obj/structure/crt_mechanims/ctr = get_ctr_for_player(player)
		player.AddComponent(/datum/component/buckshoot_roulette_participant, src, ctr)
	addtimer(CALLBACK(src, PROC_REF(check_ready), TRUE), 2 MINUTES)

/datum/buckshoot_roulette_party/proc/detect_candidates(mob/user)
	if(game_started)
		return
	if(!length(chairs))
		detect_game_objects()
	var/list/to_register = list()
	for(var/datum/weakref/chair_weakref in chairs)
		var/obj/structure/chair/buckshot/chair_instance = chair_weakref?.resolve()
		if(!chair_instance)
			continue
		var/mob/living/carbon/human/player = chair_instance.get_current_player()
		if(!player)
			continue
		if(!can_be_participant(player))
			continue
		to_register += player
	return to_register

/datum/buckshoot_roulette_party/proc/can_be_participant(mob/living/carbon/human/player)
	if(players && (WEAKREF(player) in players))
		return FALSE
	if(!ishuman(player))
		return FALSE
	if(HAS_TRAIT(player, TRAIT_PACIFISM))
		return FALSE
	return TRUE

/datum/buckshoot_roulette_party/proc/check_ready(force_start = FALSE)
	if(game_started)
		return
	for(var/datum/weakref/chair_weakref in chairs)
		var/obj/structure/chair/buckshot/chair_instance = chair_weakref?.resolve()
		if(!chair_instance)
			continue
		var/mob/living/carbon/human/player = chair_instance.get_current_player()
		if(!player)
			continue
		var/found = FALSE
		for(var/datum/weakref/player_ref in players)
			var/mob/living/carbon/human/existing_player = player_ref?.resolve()
			var/datum/component/buckshoot_roulette_participant/participant = existing_player?.GetComponent(/datum/component/buckshoot_roulette_participant)
			if(!participant)
				continue
			if(participant.player == player)
				found = TRUE
				break
		if(!found && !force_start)
			return

	awaiting_players = null
	registration = FALSE
	INVOKE_ASYNC(src, PROC_REF(start_game))


/datum/buckshoot_roulette_party/proc/register_player(mob/living/carbon/human/player, name)
	for(var/datum/weakref/player_ref in players)
		var/mob/living/carbon/human/existing_player = player_ref?.resolve()
		var/datum/component/buckshoot_roulette_participant/participant = existing_player?.GetComponent(/datum/component/buckshoot_roulette_participant)
		if(!participant)
			continue
		if(!participant.player)
			continue
		if(participant.player != player && participant.player_name == name)
			to_chat(player, span_warning("A player with that name is already in this game. Choose another name."))
			return FALSE

	LAZYADD(players, WEAKREF(player))
	player_by_names[player] = name
	to_chat(player, span_notice("You successfully registered for the game."))
	check_ready()
	return TRUE

/datum/buckshoot_roulette_party/proc/is_participant(mob/living/carbon/human/player)
	for(var/datum/weakref/player_ref in players)
		var/mob/living/carbon/human/existing_player = player_ref?.resolve()
		if(existing_player == player)
			return TRUE
	return FALSE

/datum/buckshoot_roulette_party/proc/start_game()
	if(game_started)
		return
	var/obj/structure/table/table = table_weakref?.resolve()
	if(!table)
		return
	play_game_sound('sound/buckshot_roulette/defib_bootup.ogg', 60)
	if(should_say_rules)
		for(var/rule in rules)
			table.say(rule)
			sleep(3 SECONDS)
		sleep(3 SECONDS)
	game_started = TRUE
	build_turn_order()
	SEND_SIGNAL(src, COMSIG_BUCKSHOOT_GAME_STARTED, rules)
	START_PROCESSING(SSobj, src)
	next_round()

/datum/buckshoot_roulette_party/proc/end_game()
	if(!game_started)
		return
	STOP_PROCESSING(SSobj, src)
	SEND_SIGNAL(src, COMSIG_BUCKSHOOT_GAME_ENDED)
	game_started = FALSE
	can_free_exit = TRUE
	return_shotgun_to_table()
	qdel(get_shotgun())
	shotgun_weakref = null
	var/obj/structure/table/table = table_weakref?.resolve()
	if(table)
		table.say("Game over!")
	player_by_names = list()
	players = list()
	last_turn_player = null
	current_turn_player = null
	turn_order = list()
	current_turn_start_time = 0
	round = 0
	pending_item_boxes = list()

/datum/buckshoot_roulette_party/proc/get_players()
	var/list/to_return = list()
	for(var/datum/weakref/player_ref in players)
		var/mob/living/carbon/human/player = player_ref?.resolve()
		if(player)
			to_return += player
	return to_return

/datum/buckshoot_roulette_party/proc/play_game_sound(soundin, volume = 75)
	var/list/notified_clients = list()
	for(var/mob/living/carbon/human/player in get_players())
		var/client/listener = player.client
		if(!listener)
			listener = player.mind?.current?.client
		if(listener)
			notified_clients |= listener
			SEND_SOUND(listener, sound(soundin, volume = volume))
	var/obj/structure/table/table = table_weakref?.resolve()
	if(!table)
		return
	for(var/mob/listening_mob as anything in hearers(7, table))
		if(!listening_mob.client || (listening_mob.client in notified_clients))
			continue
		SEND_SOUND(listening_mob.client, sound(soundin, volume = volume))

/datum/buckshoot_roulette_party/proc/build_turn_order()
	var/obj/structure/table/buckshot/table = table_weakref?.resolve()
	if(!table)
		turn_order = shuffle(get_players())
		return

	var/list/players_by_direction = list()
	for(var/mob/living/carbon/human/player in get_players())
		var/direction = table.get_cardinal_direction_to(player)
		if(!direction)
			continue
		players_by_direction["[direction]"] = player

	var/list/clockwise_players = list()
	for(var/direction in list(NORTH, EAST, SOUTH, WEST))
		var/mob/living/carbon/human/player = players_by_direction["[direction]"]
		if(player)
			clockwise_players += player

	if(!length(clockwise_players))
		turn_order = shuffle(get_players())
		return

	var/start_index = rand(1, length(clockwise_players))
	turn_order = list()
	for(var/i in 0 to length(clockwise_players) - 1)
		turn_order += clockwise_players[((start_index + i - 1) % length(clockwise_players)) + 1]


/datum/buckshoot_roulette_party/proc/create_shotgun()
	var/obj/structure/table/table = table_weakref?.resolve()
	if(!table)
		return null
	var/obj/item/gun/ballistic/shotgun/buckshot_game/shotgun = new(get_turf(table), src)
	shotgun_weakref = WEAKREF(shotgun)
	return shotgun


/datum/buckshoot_roulette_party/proc/get_ctr_for_player(mob/living/carbon/human/player)
	var/obj/structure/table/buckshot/table = table_weakref?.resolve()
	if(!table)
		return null
	return table.get_ctr_for_player(player)

/datum/buckshoot_roulette_party/proc/get_shotgun()
	if(!shotgun_weakref)
		return create_shotgun()
	return shotgun_weakref?.resolve()

/datum/buckshoot_roulette_party/proc/load_ammo()
	ammo_declared = FALSE
	loading_ammo = TRUE
	var/obj/structure/table/buckshot/table = table_weakref?.resolve()
	var/obj/item/gun/ballistic/shotgun/buckshot_game/shotgun = get_shotgun()
	return_shotgun_to_table()
	table.on_shotgun_begin_reload(shotgun)

	var/base = clamp(length(players) + 1, 4, 8)
	var/extra = min(round, 4)
	var/total_ammo = clamp(base + extra, 4, 8)

	var/live_shell = rand(max(1, total_ammo - 4), total_ammo - 2)
	var/blank_shell = total_ammo - live_shell
	if(total_ammo == 1)
		live_shell = 1

	if(shotgun)
		shotgun.load_rounds(live_shell, blank_shell)
	if(table)
		table.say("[live_shell] live and [blank_shell] blank.")
	table.on_shotgun_reloaded(shotgun)
	sleep(1 SECONDS)
	ammo_declared = TRUE
	loading_ammo = FALSE
	if(current_turn_player)
		table.move_shotgun_to_player(shotgun, current_turn_player)

/datum/buckshoot_roulette_party/proc/all_blank()
	if(!ammo_declared)
		return TRUE
	var/obj/item/gun/ballistic/shotgun/buckshot_game/shotgun = get_shotgun()
	if(!shotgun)
		return FALSE
	if(istype(shotgun.chambered, /obj/item/ammo_casing/shotgun/buckshoot/live))
		return FALSE
	for(var/obj/item/ammo_casing/casing in shotgun.chambers)
		if(istype(casing, /obj/item/ammo_casing/shotgun/buckshoot/live))
			return FALSE
	return TRUE

/datum/buckshoot_roulette_party/proc/return_shotgun_to_table()
	var/obj/structure/table/buckshot/table = table_weakref?.resolve()
	if(!table)
		return
	var/obj/item/gun/ballistic/shotgun/buckshot_game/shotgun = get_shotgun()
	if(!shotgun)
		return
	if(istype(shotgun.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/holder = shotgun.loc
		holder.drop_all_held_items()
	shotgun.forceMove(get_turf(table))
	table.on_shotgun_return_to_table(shotgun)


/datum/buckshoot_roulette_party/proc/pick_next_player()
	if(!length(turn_order))
		build_turn_order()
	if(!length(turn_order))
		return null

	if(!last_turn_player)
		for(var/mob/living/carbon/human/candidate as anything in turn_order)
			var/datum/component/buckshoot_roulette_participant/P = candidate?.GetComponent(/datum/component/buckshoot_roulette_participant)
			if(P && P.can_perform_turn())
				return candidate

	var/start_idx = turn_order.Find(last_turn_player)
	if(start_idx == 0)
		start_idx = length(turn_order)

	for(var/i in 1 to length(turn_order))
		var/idx = (start_idx + i - 1) % length(turn_order) + 1
		var/mob/living/carbon/human/candidate = turn_order[idx]
		if(!candidate)
			continue

		var/datum/component/buckshoot_roulette_participant/P = candidate.GetComponent(/datum/component/buckshoot_roulette_participant)
		if(P && P.can_perform_turn())
			return candidate
	return null

/datum/buckshoot_roulette_party/proc/start_next_turn()
	if(turn_transition_in_progress)
		return
	turn_transition_in_progress = TRUE

	return_shotgun_to_table()
	sleep(2 SECONDS)

	current_turn_player = pick_next_player()
	if(!current_turn_player)
		turn_transition_in_progress = FALSE
		return

	last_turn_player = current_turn_player
	current_turn_start_time = world.time

	var/obj/structure/table/buckshot/table = table_weakref?.resolve()
	if(table)
		table.say("[player_by_names[current_turn_player]]'s turn.")

	var/obj/item/gun/ballistic/shotgun/buckshot_game/shotgun = get_shotgun()
	if(shotgun)
		if(shotgun.shotingself)
			shotgun.shotingself = FALSE
		table.move_shotgun_to_player(shotgun, current_turn_player)

	turn_transition_in_progress = FALSE

/datum/buckshoot_roulette_party/proc/turn_timeout()
	if(!current_turn_player)
		return FALSE
	var/elapsed_time = world.time - current_turn_start_time
	if(elapsed_time >= turn_time)
		var/obj/structure/table/table = table_weakref?.resolve()
		if(table)
			table.say("[player_by_names[current_turn_player]] took too long and skips the turn!")
		return TRUE
	return FALSE

/datum/buckshoot_roulette_party/proc/after_player_shoot(mob/living/carbon/human/player, target_player, shot_result)
	var/datum/component/buckshoot_roulette_participant/participant = player.GetComponent(/datum/component/buckshoot_roulette_participant)
	var/obj/item/gun/ballistic/shotgun/buckshot_game/shotgun = get_shotgun()
	shotgun.rack(player)
	shotgun.shot_in_progress = FALSE
	if(!participant)
		return
	if(shot_result == SHOOT_RESULT_BLANK)
		handle_blank_shot(player, target_player)
	else if(shot_result == SHOOT_RESULT_LIVE)
		handle_live_shot(player, target_player)

/datum/buckshoot_roulette_party/proc/handle_blank_shot(mob/living/carbon/human/player, mob/living/carbon/human/target_player)
	if(target_player == player)
		to_chat(player, "Blank shot. You stay in the game and keep the turn.")
		return
	else
		start_next_turn()

/datum/buckshoot_roulette_party/proc/handle_live_shot(mob/living/carbon/human/player, mob/living/carbon/human/target_player)
	var/datum/component/buckshoot_roulette_participant/target_participant = target_player.GetComponent(/datum/component/buckshoot_roulette_participant)
	if(!target_participant)
		return
	if(target_player.stat != DEAD)
		target_player.death(FALSE)
	return_shotgun_to_table()
	current_turn_player = null

/datum/buckshoot_roulette_party/proc/check_round_end()
	var/players_alive = 0
	for(var/datum/weakref/player_ref in players)
		var/mob/living/carbon/human/player = player_ref?.resolve()
		var/datum/component/buckshoot_roulette_participant/participant = player?.GetComponent(/datum/component/buckshoot_roulette_participant)
		if(!participant)
			continue
		if(!participant.player_completely_dead())
			players_alive += 1
	if(players_alive <= 1)
		return TRUE
	return FALSE


/datum/buckshoot_roulette_party/proc/clean_shells()
	var/obj/structure/table/buckshot/table = table_weakref?.resolve()
	var/list/do_delete = list()
	for(var/obj/item/ammo_casing/shotgun/buckshoot/casing in range(4, table))
		do_delete += casing
		casing.forceMove(get_turf(table))
	sleep(1 SECONDS)
	if(length(do_delete))
		QDEL_LIST(do_delete)

/datum/buckshoot_roulette_party/proc/item_gived(obj/item/item, mob/living/carbon/human/player)
	LAZYADD(all_items, item)
	if(!items_by_players[player])
		items_by_players[player] = list()
	LAZYADD(items_by_players[player], item)

/datum/buckshoot_roulette_party/proc/register_item_box(obj/structure/box_with_item/box)
	if(!box)
		return
	LAZYADD(pending_item_boxes, WEAKREF(box))

/datum/buckshoot_roulette_party/proc/unregister_item_box(obj/structure/box_with_item/box)
	for(var/datum/weakref/box_ref as anything in pending_item_boxes)
		if(box_ref?.resolve() == box)
			pending_item_boxes -= box_ref
			return

/datum/buckshoot_roulette_party/proc/get_pending_item_box_count()
	var/valid_boxes = 0
	for(var/datum/weakref/box_ref as anything in pending_item_boxes.Copy())
		var/obj/structure/box_with_item/box = box_ref?.resolve()
		if(!box || QDELETED(box))
			pending_item_boxes -= box_ref
			continue
		valid_boxes += 1
	return valid_boxes

/datum/buckshoot_roulette_party/proc/clear_pending_item_boxes()
	for(var/datum/weakref/box_ref as anything in pending_item_boxes.Copy())
		var/obj/structure/box_with_item/box = box_ref?.resolve()
		if(box && !QDELETED(box))
			qdel(box)
	pending_item_boxes = list()

/datum/buckshoot_roulette_party/proc/give_items()
	var/items_per_player = min(6, 2 * round)
	var/obj/structure/table/buckshot/table = table_weakref?.resolve()
	if(!table || items_per_player <= 0)
		return
	table.say("[items_per_player] item(s) for each player!")
	table.create_item_boxes(items_per_player)

/datum/buckshoot_roulette_party/proc/clean_items()
	QDEL_LIST(all_items)
	all_items = list()
	items_by_players = list()

/datum/buckshoot_roulette_party/proc/next_round()
	round += 1
	ammo_declared = FALSE
	current_turn_player = null
	last_turn_player = null
	var/obj/structure/table/table = table_weakref?.resolve()
	if(round >= death_round_threshold)
		is_last_round = TRUE
	SEND_SIGNAL(src, COMSIG_BUCKSHOOT_NEXT_ROUND, is_last_round)
	if(round > 1)
		give_items()
	var/item_wait_ends_at = world.time + ITEM_BOX_TIMEOUT
	while(get_pending_item_box_count() > 0 && world.time < item_wait_ends_at)
		stoplag(1)
	if(get_pending_item_box_count() > 0)
		if(table)
			table.say("Item selection timed out.")
		clear_pending_item_boxes()
	if(table)
		table.say("Round [round] begins!")
		play_game_sound('sound/buckshot_roulette/new_round.ogg', 60)
		if(is_last_round)
			play_game_sound('sound/buckshot_roulette/crt_turn_off.ogg', 65)
			table.say("Final round. Revival systems are offline!")
	sleep(3 SECONDS)
	pause = FALSE

/datum/buckshoot_roulette_party/proc/end_round()
	pause = TRUE
	var/obj/structure/table/table = table_weakref?.resolve()
	return_shotgun_to_table()
	sleep(1 SECONDS)
	table.say("Clearing shells...")
	clean_shells()
	sleep(2 SECONDS)
	clean_items()
	if(is_last_round)
		end_game()
		return
	if(table)
		table.say("Round [round] is over!")
	sleep(1 SECONDS)
	next_round()

/datum/buckshoot_roulette_party/process(seconds_per_tick)
	if(!game_started)
		return
	if(pause || loading_ammo || turn_transition_in_progress)
		return
	if(!get_shotgun())
		create_shotgun()
	if(check_round_end())
		end_round()
		return
	if(all_blank() && !loading_ammo)
		load_ammo()
		return
	if((!current_turn_player || turn_timeout()) && ammo_declared && !turn_transition_in_progress)
		start_next_turn()


/datum/component/buckshoot_roulette_participant
	VAR_PRIVATE/datum/weakref/party_weakref
	VAR_PRIVATE/datum/weakref/crt_weakref
	var/has_died_in_party = FALSE
	var/mob/living/carbon/human/player
	var/player_name = ""
	var/srcore = 0
	var/lives = MAX_BUCKSHOT_LIVES
	var/crt_enabled = TRUE
	var/pending_life_loss = FALSE
	var/pending_lives_after_loss = 0

	var/static/list/forbiden_names = list(
		"host",
		"admin",
		"moderator",
		"system",
		"bot",
		"player",
		"guest",
		"low3",
		"god",
	)
	var/static/list/dealer_names = list(
		"dealer",
		"croupier",
	)


/datum/component/buckshoot_roulette_participant/Initialize( \
	datum/buckshoot_roulette_party/party, \
	obj/structure/crt_mechanims/crt_instance)


	if(!party || !crt_instance)
		return COMPONENT_INCOMPATIBLE
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	player = parent
	party_weakref = WEAKREF(party)
	crt_weakref = WEAKREF(crt_instance)
	crt_instance.set_participant(src)
	INVOKE_ASYNC(src, PROC_REF(register_player))

/datum/component/buckshoot_roulette_participant/Destroy()
	UnregisterFromParent()
	. = ..()


/datum/component/buckshoot_roulette_participant/RegisterWithParent()
	. = ..()
	var/datum/buckshoot_roulette_party/party_instance = party_weakref?.resolve()
	RegisterSignal(player, COMSIG_LIVING_DEATH, PROC_REF(on_player_death), TRUE)
	RegisterSignal(party_instance, COMSIG_BUCKSHOOT_GAME_STARTED, PROC_REF(on_game_start), TRUE)
	RegisterSignal(party_instance, COMSIG_BUCKSHOOT_GAME_ENDED, PROC_REF(on_game_end), TRUE)
	RegisterSignal(party_instance, COMSIG_BUCKSHOOT_NEXT_ROUND, PROC_REF(on_next_round), TRUE)

/datum/component/buckshoot_roulette_participant/UnregisterFromParent()
	. = ..()
	var/datum/buckshoot_roulette_party/party_instance = party_weakref?.resolve()
	UnregisterSignal(player, list(COMSIG_LIVING_DEATH))
	UnregisterSignal(party_instance, list(COMSIG_BUCKSHOOT_GAME_STARTED, COMSIG_BUCKSHOOT_GAME_ENDED, COMSIG_BUCKSHOOT_NEXT_ROUND))


/datum/component/buckshoot_roulette_participant/proc/generate_random_name()
	var/chars = GLOB.alphabet.Copy()
	var/base = "Player_"
	for(var/i = 0; i < 6; i++)
		base += chars[prob(1.0 / length(chars)) * length(chars)]
	return trimtext(base)

/datum/component/buckshoot_roulette_participant/proc/register_player()
	var/datum/buckshoot_roulette_party/party_instance = party_weakref?.resolve()
	if(!party_instance)
		return
	var/player_name = tgui_input_text(player, "Enter a player name", "Registration", max_length = 6, timeout = 30 SECONDS)
	if(!player_name)
		player_name = generate_random_name()
	if(player_name in forbiden_names)
		to_chat(player, span_warning("That name is forbidden. Pick another name."))
		return register_player()
	if(player_name in dealer_names && !HAS_TRAIT(player, TRAIT_BUCKSHOOT_DEALER))
		to_chat(player, span_warning("That name is forbidden. Pick another name."))
		return register_player()
	if(!party_instance.register_player(player, player_name))
		var/obj/structure/crt_mechanims/crt = crt_weakref?.resolve()
		if(crt)
			crt.set_participant(src)
		CHECK_TICK
		sleep(1)
		register_player()
	else
		RegisterWithParent()


/datum/component/buckshoot_roulette_participant/proc/can_perform_turn()
	if(player_completely_dead())
		return FALSE
	if(player.stat == DEAD)
		return FALSE
	return TRUE

/datum/component/buckshoot_roulette_participant/proc/player_completely_dead()
	var/datum/buckshoot_roulette_party/party = party_weakref?.resolve()
	if(!party || !party.game_started)
		return TRUE
	if(has_died_in_party)
		return TRUE
	if(player.stat == DEAD && lives <= 0)
		return TRUE
	return FALSE


/datum/component/buckshoot_roulette_participant/proc/on_player_death(mob/living/player, gibbed)
	SIGNAL_HANDLER
	var/datum/buckshoot_roulette_party/party = party_weakref?.resolve()
	var/obj/structure/crt_mechanims/crt = crt_weakref?.resolve()
	if(!party || !crt)
		return
	if(pending_life_loss)
		return
	if(lives <= 0)
		has_died_in_party = TRUE
		crt.update_icon_state()
		crt.say("[player_name] is out!")
		to_chat(player, span_userdanger("You are dead. The game is over for you."))
		return

	pending_lives_after_loss = max(0, lives - 1)
	pending_life_loss = TRUE
	crt.say("[player_name]'s CRT is charging.")
	addtimer(CALLBACK(crt, TYPE_PROC_REF(/obj/structure/crt_mechanims, revive_player)), CRT_DEFIB_DELAY)
	addtimer(CALLBACK(src, PROC_REF(apply_life_loss)), CRT_DEFIB_DELAY + LIFE_LOSS_DELAY)

/datum/component/buckshoot_roulette_participant/proc/apply_life_loss()
	var/obj/structure/crt_mechanims/crt = crt_weakref?.resolve()
	if(!crt)
		pending_life_loss = FALSE
		return
	lives = pending_lives_after_loss
	crt.update_icon_state()
	play_game_sound('sound/buckshot_roulette/defib_reduce_health.ogg', 75)
	pending_life_loss = FALSE
	pending_lives_after_loss = 0

	if(lives <= 0)
		crt.say("[player_name]: no lives remaining.")
		to_chat(player, span_userdanger("Your CRT has no lives remaining. The next death is final."))
		return

	crt.say("[player_name]: [lives] lives remaining.")


/datum/component/buckshoot_roulette_participant/proc/on_next_round(datum/buckshoot_roulette_party/party, death_round)
	SIGNAL_HANDLER
	lives = death_round ? 0 : MAX_BUCKSHOT_LIVES
	has_died_in_party = FALSE
	pending_life_loss = FALSE
	pending_lives_after_loss = 0
	crt_enabled = !death_round
	if(death_round)
		to_chat(player, span_userdanger("The revival system is offline. You have no extra lives."))
	var/obj/structure/crt_mechanims/crt_instance = crt_weakref?.resolve()
	if(!crt_instance)
		return
	if(player.stat == DEAD && !pending_life_loss && !has_died_in_party && (death_round || lives > 0))
		addtimer(CALLBACK(crt_instance, TYPE_PROC_REF(/obj/structure/crt_mechanims, revive_player)), 5)
	crt_instance.update_icon_state()

/datum/component/buckshoot_roulette_participant/proc/on_game_start(/datum/buckshoot_roulette_party/party, rules)
	SIGNAL_HANDLER
	ADD_TRAIT(player, TRAIT_BUCKSHOOT_PLAYER, INNATE_TRAIT)
	var/obj/structure/crt_mechanims/crt_instance = crt_weakref?.resolve()
	crt_instance?.update_icon_state()
	to_chat(player, span_big("The game has started! You have [lives] lives."))
	SEND_SOUND(player, sound('sound/buckshot_roulette/crt_display_health.ogg', volume = 75))

/datum/component/buckshoot_roulette_participant/proc/play_game_sound(soundin, volume = 75)
	var/datum/buckshoot_roulette_party/party = party_weakref?.resolve()
	if(party)
		party.play_game_sound(soundin, volume)
	else if(player?.client)
		SEND_SOUND(player, sound(soundin, volume = volume))


/datum/component/buckshoot_roulette_participant/proc/add_lives(num)
	if(!crt_enabled)
		return
	lives = min(MAX_BUCKSHOT_LIVES, lives + num)
	var/obj/structure/crt_mechanims/crt_instance = crt_weakref?.resolve()
	if(crt_instance)
		crt_instance.update_icon_state()
	to_chat(player, span_notice("You gain [num] life. You now have [lives] lives."))

/datum/component/buckshoot_roulette_participant/proc/on_game_end()
	SIGNAL_HANDLER
	REMOVE_TRAIT(player, TRAIT_BUCKSHOOT_PLAYER, INNATE_TRAIT)
	qdel(src)


/datum/component/buckshoot_roulette_participant/proc/get_crt_charges()
	return lives > 0 ? lives : 0
