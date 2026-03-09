/datum/species
	/// Additional quirk points granted by species.
	var/quirk_points_bonus = 0

/proc/get_species_quirk_points_bonus(species_type)
	if(ispath(species_type, /datum/species))
		return initial(species_type:quirk_points_bonus) || 0
	if(istype(species_type, /datum/species))
		var/datum/species/species_datum = species_type
		return species_datum.quirk_points_bonus || 0
	return 0


/datum/species/human
 	quirk_points_bonus = 6

/datum/species/humanoid
 	quirk_points_bonus = 4

/datum/species/insectoid
 	quirk_points_bonus = 4

/datum/species/mammal
	quirk_points_bonus = 4
