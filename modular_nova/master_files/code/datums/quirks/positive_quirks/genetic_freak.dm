/// Assoc list of mutation names to list of restricted species typepaths
/// Add more entries here to restrict additional mutations from specific species
GLOBAL_LIST_INIT(genetic_mutation_species_restrictions, list(
	"Restorative Metabolism" = list(
		/datum/species/jelly,
		/datum/species/hemophage,
		/datum/species/pod,
		/datum/species/shadekin,
	),
	"Cold Adaptation" = list(
		/datum/species/jelly,
	),
))

GLOBAL_LIST_INIT(genetic_mutation_choice, list(
	"Antenna" = /datum/mutation/antenna,
	"Autotomy" = /datum/mutation/self_amputation,
	"Glowy" = /datum/mutation/glow,
	"Anti-Glowy" = /datum/mutation/glow/anti,
	"Strength" = /datum/mutation/strong,
	"Stimmed" = /datum/mutation/stimmed,
	"Geladikinesis" = /datum/mutation/geladikinesis,
	"Cindikinesis" = /datum/mutation/cindikinesis,
	"Transcendent Olfaction" = /datum/mutation/olfaction,
	"Elastic Arms" = /datum/mutation/elastic_arms,
	"Webbing" = /datum/mutation/webbing,
	"Mending Touch" = /datum/mutation/lay_on_hands,
	"Pressure Adaptation" = /datum/mutation/adaptation/pressure,
	"Cold Adaptation" = /datum/mutation/adaptation/cold,
	"Heat Adaptation" = /datum/mutation/adaptation/heat,
	"Restorative Metabolism" = /datum/mutation/restorative_metabolism,
))

/datum/quirk/genetic_mutation
	name = "Genetic Mutation"
	desc = "For some reason or another, you've got an unusual genetic mutation, the rest is up to fate."
	icon = FA_ICON_RECEIPT
	value = 6
	gain_text = "If everyone's super, no one is."
	lose_text = "You feel like everyone else might be super after all."
	medical_record_text = "Patient has unusual genetic sequences."
	/// The mutation that's applied to the mob, for ease of removal
	var/applied_mutation

/datum/quirk_constant_data/genetic_mutation
	associated_typepath = /datum/quirk/genetic_mutation

/datum/quirk/genetic_mutation/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	applied_mutation = pick_random_mutation(human_holder.dna.species.type)
	if(isnull(applied_mutation))
		stack_trace("Genetic Mutation could not find a valid mutation for [human_holder] with species [human_holder.dna.species.type].")
		return

	human_holder.dna.add_mutation(applied_mutation, MUTATION_SOURCE_MUTATOR)

/datum/quirk/genetic_mutation/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.dna.remove_mutation(applied_mutation, MUTATION_SOURCE_MUTATOR)

/datum/quirk/genetic_mutation/proc/pick_random_mutation(datum/species/species_type)
	var/list/valid_mutation_names = list()

	for(var/mutation_name in GLOB.genetic_mutation_choice)
		if(is_mutation_restricted_for_species(mutation_name, species_type))
			continue
		valid_mutation_names += mutation_name

	if(!length(valid_mutation_names))
		return null

	return GLOB.genetic_mutation_choice[pick(valid_mutation_names)]

/// Helper proc to check if a mutation is restricted for a given species
/// Returns TRUE if the mutation is restricted (not allowed), FALSE otherwise
/proc/is_mutation_restricted_for_species(mutation_name, datum/species/mob_species)
	var/list/restrictions = GLOB.genetic_mutation_species_restrictions[mutation_name]
	if(!restrictions)
		return FALSE

	for(var/restricted_type in restrictions)
		if(ispath(mob_species, restricted_type))
			return TRUE

	return FALSE
