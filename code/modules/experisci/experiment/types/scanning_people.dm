/// An experiment where you scan your fellow humans
/datum/experiment/scanning/people
	allowed_experimentors = list(/obj/item/experi_scanner, /obj/item/scanner_wand)
	/// Number of people you need to scan
	var/required_count = 2
	/// Does the scanned target need to have a mind?
	var/mind_required = FALSE
	/// How do we describe the people you need to scan?
	var/required_traits_desc = ""

/datum/experiment/scanning/people/New()
	required_atoms = list(/mob/living/carbon/human = required_count)
	return ..()

/datum/experiment/scanning/people/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, atom/target, typepath)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(target))
		return FALSE
	return is_valid_scan_target(target, experiment_handler)

/// Checks that the passed mob is valid human to scan
/datum/experiment/scanning/people/proc/is_valid_scan_target(mob/living/carbon/human/check, datum/component/experiment_handler/experiment_handler)
	SHOULD_CALL_PARENT(TRUE)
	if(!mind_required || !isnull(check.mind))
		return TRUE
	if(isliving(usr))
		experiment_handler.announce_message("Subject is mindless!")
	return FALSE

/datum/experiment/scanning/people/serialize_progress_stage(atom/target, list/seen_instances)
	return EXPERIMENT_PROG_INT("Scan unique individuals with [required_traits_desc].", \
		seen_instances.len, required_atoms[target])

/// Scan dead players who still have a soul (ckey attached). Tracks unique ckeys to prevent duplicates.
/datum/experiment/scanning/people/dead_soulled
	name = "Cadaver Neural Mapping"
	description = "Scan the neural patterns of recently deceased individuals whose soul remains tethered to their body. \
		Understanding the transition between life and death is key to developing automated revival technology."
	required_count = 7
	mind_required = FALSE
	required_traits_desc = "recently deceased individuals"
	/// Tracks ckeys already scanned to avoid double-counting the same person.
	var/list/scanned_ckeys = list()

/datum/experiment/scanning/people/dead_soulled/New()
	required_atoms = list(/mob/living/carbon/human = required_count)
	return ..()

/datum/experiment/scanning/people/dead_soulled/is_valid_scan_target(mob/living/carbon/human/check, datum/component/experiment_handler/experiment_handler)
	if(!..())
		return FALSE
	if(check.stat != DEAD)
		if(isliving(usr))
			experiment_handler.announce_message("Subject must be deceased for neural pattern capture.")
		return FALSE
	if(!check.ckey)
		if(isliving(usr))
			experiment_handler.announce_message("No soul signature detected \u2014 subject is mindless.")
		return FALSE
	if(check.ckey in scanned_ckeys)
		if(isliving(usr))
			experiment_handler.announce_message("Neural pattern for this individual already recorded.")
		return FALSE
	scanned_ckeys += check.ckey
	return TRUE
