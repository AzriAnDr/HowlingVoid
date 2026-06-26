/// Adds manufacturer information to the attached atom's examine text.
/datum/element/manufacturer_examine
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Examine text to append, usually one of the strings in code/__DEFINES/~nova_defines/manufacturer_strings.dm.
	var/company_string

/datum/element/manufacturer_examine/Attach(atom/target, given_company_string)
	. = ..()

	if(!istype(target))
		return ELEMENT_INCOMPATIBLE
	if(!given_company_string)
		return ELEMENT_INCOMPATIBLE

	company_string = given_company_string
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/element/manufacturer_examine/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_EXAMINE)

/datum/element/manufacturer_examine/proc/on_examine(obj/item/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	examine_list += "<br>[company_string]"
