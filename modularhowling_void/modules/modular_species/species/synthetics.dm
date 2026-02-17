/datum/species/synthetic/on_species_gain(mob/living/carbon/human/transformer, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if(!istype(transformer))
		return
	ADD_TRAIT(transformer, TRAIT_RESISTHIGHPRESSURE, REF(src))
	ADD_TRAIT(transformer, TRAIT_RESISTLOWPRESSURE, REF(src))

/datum/species/synthetic/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	if(istype(human))
		REMOVE_TRAIT(human, TRAIT_RESISTHIGHPRESSURE, REF(src))
		REMOVE_TRAIT(human, TRAIT_RESISTLOWPRESSURE, REF(src))
	. = ..()
