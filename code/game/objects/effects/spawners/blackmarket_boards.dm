/*
Black market board mapping helper.

Usage:
- Place /obj/effect/spawner/blackmarket_board on the map.
- Set board_kind in StrongDMM or VV to one of:
  "circuit_imprinter", "mechfab", "rdconsole", "rdserver", "techfab"

This stays as a single generic spawner on purpose. Local testing showed that
adding child spawner types for each board variant could crash DreamDaemon
during startup with a stack overflow.
*/
/obj/effect/spawner/blackmarket_board
	name = "black market board spawner"
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "circuit_map"
	/// Which black market board variant to create on mapload.
	var/board_kind

/obj/effect/spawner/blackmarket_board/Initialize(mapload)
	. = ..()
	var/obj/item/circuitboard/board = create_board()
	if(!board)
		stack_trace("[type] is missing a valid board_kind")
		return

	// Configure a normal board into its black market variant at runtime.
	configure_board(board)

/obj/effect/spawner/blackmarket_board/proc/create_board()
	switch(board_kind)
		if("circuit_imprinter")
			return new /obj/item/circuitboard/machine/circuit_imprinter(loc)
		if("mechfab")
			return new /obj/item/circuitboard/machine/mechfab(loc)
		if("rdconsole")
			return new /obj/item/circuitboard/computer/rdconsole(loc)
		if("rdserver")
			return new /obj/item/circuitboard/machine/rdserver(loc)
		if("techfab")
			return new /obj/item/circuitboard/machine/techfab(loc)

	return null

/obj/effect/spawner/blackmarket_board/proc/configure_board(obj/item/circuitboard/board)
	switch(board_kind)
		if("circuit_imprinter")
			var/obj/item/circuitboard/machine/circuit_imprinter/configured_circuit_imprinter = board
			if(istype(configured_circuit_imprinter))
				configured_circuit_imprinter.configure_blackmarket()
		if("mechfab")
			var/obj/item/circuitboard/machine/mechfab/configured_mechfab = board
			if(istype(configured_mechfab))
				configured_mechfab.configure_blackmarket()
		if("rdconsole")
			var/obj/item/circuitboard/computer/rdconsole/configured_rdconsole = board
			if(istype(configured_rdconsole))
				configured_rdconsole.configure_blackmarket()
		if("rdserver")
			var/obj/item/circuitboard/machine/rdserver/configured_rdserver = board
			if(istype(configured_rdserver))
				configured_rdserver.configure_blackmarket()
		if("techfab")
			var/obj/item/circuitboard/machine/techfab/configured_techfab = board
			if(istype(configured_techfab))
				configured_techfab.configure_blackmarket()
