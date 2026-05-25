/obj/item/xenoarch/core_sampler
	name = "core sampler"
	desc = "Used to extract geological core samples."
	icon = 'icons/xenoarchartifacts/tools.dmi'
	icon_state = "sampler_empty"
	w_class = 1
	// Did we already take the sample?
	var/used = FALSE
	// The sample of the rock we took
	var/obj/structure/boulder/sample = NONE
