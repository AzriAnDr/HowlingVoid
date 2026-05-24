#define REGENERATION_DAMAGE_THRESHOLD 75
#define REGENERATION_BRUTE_HEAL 0.5
#define REGENERATION_BURN_HEAL 0.5
#define REGENERATION_TOX_HEAL 0.3

/datum/quirk/regeneration
	name = "Regeneration"
	desc = "Your body can slowly recover from light to moderate injuries. Critical injuries, wounds, and genetic damage still require medical attention."
	value = 14
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	gain_text = span_notice("A restorative vitality settles into your body.")
	lose_text = span_notice("Your regenerative vitality fades away.")
	medical_record_text = "Patient possesses a self-reconstructive condition. Medical care is only required under severe circumstances."
	mob_trait = TRAIT_REGENERATION
	hardcore_value = -14
	icon = FA_ICON_HEART_PULSE
	maximum_process_stat = SOFT_CRIT

/datum/quirk/regeneration/is_species_appropriate(datum/species/mob_species)
	var/datum/species/species_prototype = ispath(mob_species) ? GLOB.species_prototypes[mob_species] : mob_species
	if(isnull(species_prototype) || !(species_prototype.inherent_biotypes & (MOB_ORGANIC|MOB_ROBOTIC)))
		return FALSE
	return ..()

/datum/quirk/regeneration/process(seconds_per_tick)
	if(!(quirk_holder.mob_biotypes & (MOB_ORGANIC|MOB_ROBOTIC)))
		return

	if(quirk_holder.stat >= SOFT_CRIT || quirk_holder.health <= quirk_holder.crit_threshold)
		return

	if(quirk_holder.health >= quirk_holder.maxHealth)
		return

	var/need_mob_update = FALSE

	if(quirk_holder.get_brute_loss() <= REGENERATION_DAMAGE_THRESHOLD)
		need_mob_update += quirk_holder.adjust_brute_loss(-REGENERATION_BRUTE_HEAL * seconds_per_tick, updating_health = FALSE, required_bodytype = (BODYTYPE_ORGANIC|BODYTYPE_ROBOTIC))

	if(quirk_holder.get_fire_loss() <= REGENERATION_DAMAGE_THRESHOLD)
		need_mob_update += quirk_holder.adjust_fire_loss(-REGENERATION_BURN_HEAL * seconds_per_tick, updating_health = FALSE, required_bodytype = (BODYTYPE_ORGANIC|BODYTYPE_ROBOTIC))

	if(quirk_holder.get_tox_loss() <= REGENERATION_DAMAGE_THRESHOLD)
		need_mob_update += quirk_holder.adjust_tox_loss(-REGENERATION_TOX_HEAL * seconds_per_tick, updating_health = FALSE, forced = TRUE)

	if(need_mob_update)
		quirk_holder.updatehealth()

#undef REGENERATION_DAMAGE_THRESHOLD
#undef REGENERATION_BRUTE_HEAL
#undef REGENERATION_BURN_HEAL
#undef REGENERATION_TOX_HEAL
