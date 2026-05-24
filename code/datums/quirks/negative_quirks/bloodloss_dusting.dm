/datum/quirk/bloodloss_dusting
	name = "Dusting Sickness"
	desc = "If you run out of blood to the point where a normal person would die, you turn to dust."
	value = -8
	gain_text = span_danger("You start to worry even more about running out of blood.")
	lose_text = span_notice("You feel like running out of blood isn't quite as scary.")
	medical_record_text = "Patient's body has an extreme reaction to blood loss, crumbling to dust when blood levels fall too low."
	icon = FA_ICON_DROPLET_SLASH

/datum/quirk/bloodloss_dusting/is_species_appropriate(datum/species/mob_species)
	var/datum/species/species_prototype
	if(ispath(mob_species))
		species_prototype = GLOB.species_prototypes[mob_species]
	else if(istext(mob_species))
		species_prototype = GLOB.species_prototypes[GLOB.species_list[mob_species]]
	else
		species_prototype = mob_species

	if(isnull(species_prototype) || species_prototype.id == SPECIES_SYNTH)
		return FALSE

	if(species_prototype.inherent_traits && (TRAIT_NOBLOOD in species_prototype.inherent_traits))
		return FALSE

	return ..()

/datum/quirk/bloodloss_dusting/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(on_handle_blood))

/datum/quirk/bloodloss_dusting/remove()
	UnregisterSignal(quirk_holder, COMSIG_HUMAN_ON_HANDLE_BLOOD)

/datum/quirk/bloodloss_dusting/proc/on_handle_blood(mob/living/carbon/human/source, seconds_per_tick)
	SIGNAL_HANDLER

	if(!istype(source) || source.stat == DEAD || !CAN_HAVE_BLOOD(source) || source.get_blood_volume() >= BLOOD_VOLUME_SURVIVE)
		return

	to_chat(source, span_danger("You ran out of blood!"))
	source.investigate_log("has been dusted by a lack of blood caused by the [name] quirk.", INVESTIGATE_DEATHS)
	source.dust()
