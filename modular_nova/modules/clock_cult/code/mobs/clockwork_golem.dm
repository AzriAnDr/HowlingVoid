/datum/species/golem/clockwork
	name = "Clockwork Golem"
	id = SPECIES_GOLEM_CLOCKWORK
	meat = /obj/item/stack/sheet/bronze
	fixed_mut_color = "#BE8700"
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/clockwork/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	ADD_TRAIT(human_who_gained_species, TRAIT_FASTER_SLAB_INVOKE, SPECIES_TRAIT)
	human_who_gained_species.physiology.damage_resistance += 15
	human_who_gained_species.physiology.knockdown_mod *= 0.85

/datum/species/golem/clockwork/on_species_loss(mob/living/carbon/human/human_who_lost_species, datum/species/new_species, pref_load)
	REMOVE_TRAIT(human_who_lost_species, TRAIT_FASTER_SLAB_INVOKE, SPECIES_TRAIT)
	human_who_lost_species.physiology.damage_resistance -= 15
	human_who_lost_species.physiology.knockdown_mod /= 0.85
	return ..()

/datum/species/golem/clockwork/spec_life(mob/living/carbon/human/source, seconds_per_tick)
	. = ..()
	var/turf/source_turf = get_turf(source)
	if(!istype(source_turf, /turf/open/floor/bronze) && !istype(source_turf, /turf/open/indestructible/reebe_void))
		return

	source.heal_ordered_damage(0.5 * seconds_per_tick, list(TOX, BRUTE, BURN))
