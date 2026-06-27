/obj/item/modular_computer/laptop/preset/civilian
	desc = "A low-end laptop often used for personal recreation."
	starting_programs = list(
		/datum/computer_file/program/chatclient,
	)

//Used for Mafia testing purposes.
/obj/item/modular_computer/laptop/preset/mafia
	starting_programs = list(
		/datum/computer_file/program/mafia,
	)


// BEGIN NOVA CORE MIGRATION: code/modules/computers/modular/computers/item/laptop_presets.dm
/obj/item/modular_computer/laptop/preset/civilian/closed
	start_open = FALSE
// END NOVA CORE MIGRATION: code/modules/computers/modular/computers/item/laptop_presets.dm

