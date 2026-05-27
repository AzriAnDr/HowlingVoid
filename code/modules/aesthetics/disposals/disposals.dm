/obj/machinery/disposal/bin
	icon = 'icons/aesthetics/disposals/icons/disposals.dmi'

/datum/asset/spritesheet_batched/pipes/create_spritesheets()
	. = ..()
	// Overwritten to have our own pipe sprites in it.
	insert_all_icons("", 'icons/aesthetics/disposals/icons/disposals.dmi', GLOB.alldirs)
