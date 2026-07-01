/**
 * Code-driven map rotation definitions.
 *
 * Adjust this list to change whether maps appear in map votes and which
 * population bounds they require, without editing config files.
 *
 * Recognized keys per entry:
 * - id (required): filename stem for the map JSON.
 * - directory (optional): directory containing the map JSON, defaults to MAP_DIRECTORY_MAPS.
 * - min_players / max_players (optional): population bounds for the map.
 * - vote_weight (optional): multiplier applied to votes for this map.
 * - votable (optional): whether the map can appear in map votes.
 * - default (optional): marks this map as the default map.
 * - feedback_link / webmap_url (optional): URLs shown to players.
 * - enabled (optional): set to FALSE to skip loading without removing the definition.
 */

/datum/controller/configuration/proc/get_code_map_definitions()
	return list(
		list(
			"id" = "deltastation",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "icebox",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "catwalkstation",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "metastation",
			"min_players" = 0,
			"votable" = TRUE,
			"default" = TRUE,
		),
		list(
			"id" = "tramstation",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "nebulastation",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "wawastation",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "voidraptor",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "blueshift",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "ouroboros",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "serenitystation",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "snowglobe",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "oceanpubby",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "border_station",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "athlantis",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "kurchatovsk",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "waterkilostation",
			"min_players" = 0,
			"votable" = TRUE,
		),
		list(
			"id" = "gateway_test",
		),
		list(
			"id" = "multiz_debug",
		),
		list(
			"id" = "runtimestation",
		),
		list(
			"id" = "meta_event",
		),
	)

/datum/controller/configuration/proc/load_coded_maplist()
	log_config("Loading map list from code definitions...")
	maplist = list()
	defaultmap = null

	var/list/map_definitions = get_code_map_definitions()
	if(!islist(map_definitions) || !length(map_definitions))
		log_config("No code map definitions were provided. No maps will be available for voting.")
		return

	for(var/definition_index in 1 to length(map_definitions))
		var/list/map_definition = map_definitions[definition_index]
		if(!islist(map_definition))
			log_config("Skipping map definition #[definition_index]; value was not a list.")
			continue

		if(("enabled" in map_definition) && !map_definition["enabled"])
			continue

		var/map_id = map_definition["id"]
		if(!istext(map_id) || !length(map_id))
			log_config("Skipping map definition #[definition_index]; missing 'id'.")
			continue

		var/map_directory = map_definition["directory"]
		if(!istext(map_directory) || !(map_directory in MAP_DIRECTORY_WHITELIST))
			map_directory = MAP_DIRECTORY_MAPS

		var/datum/map_config/currentmap = load_map_config(map_id, map_directory)
		if(currentmap.defaulted)
			var/error_message = "Failed to load map config for [map_id]!"
			log_config(error_message)
			log_mapping(error_message, TRUE)
			continue

		if("min_players" in map_definition)
			currentmap.config_min_users = map_definition["min_players"]

		if("max_players" in map_definition)
			currentmap.config_max_users = map_definition["max_players"]

		if("vote_weight" in map_definition)
			currentmap.voteweight = map_definition["vote_weight"]

		if("votable" in map_definition)
			currentmap.votable = map_definition["votable"] ? TRUE : FALSE

		if("feedback_link" in map_definition)
			currentmap.feedback_link = map_definition["feedback_link"]

		if("webmap_url" in map_definition)
			currentmap.mapping_url = map_definition["webmap_url"]

		maplist[currentmap.map_name] = currentmap

		if(map_definition["default"])
			defaultmap = currentmap

	if(!defaultmap && length(maplist))
		log_config("No default map defined in code map definitions.")
