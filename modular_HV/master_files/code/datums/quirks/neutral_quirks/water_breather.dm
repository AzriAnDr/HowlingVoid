/datum/quirk/item_quirk/breather/water_breather/is_species_appropriate(datum/species/mob_species)
	if(istype(mob_species, /datum/species/akula))
		return FALSE
	else
		return ..()
