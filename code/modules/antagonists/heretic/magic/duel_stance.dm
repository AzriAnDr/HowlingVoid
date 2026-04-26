/**
 * # Duel Stance
 *
 * Blade path tier 2 knowledge, grants a defensive buff when dual-wielding blades.
 */
/datum/heretic_knowledge/duel_stance
	name = "Duel Stance"
	desc = "Teaching yourself the Duel Stance grants you increased resistance and mobility when \
		you are dual wielding two blades. Being hit while in this stance will counter-attack your attacker."
	gain_text = "My great grandfather was a master of the blade... and with my knowledge, so am I."
	cost = 2
	drafting_tier = 0

/datum/heretic_knowledge/duel_stance/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(user, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine_more))

/datum/heretic_knowledge/duel_stance/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, list(COMSIG_ATOM_EXAMINE, COMSIG_ATOM_EXAMINE_MORE))

/datum/heretic_knowledge/duel_stance/proc/on_examine(mob/living/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	if(!IS_HERETIC(examiner))
		return

	if(!is_dual_wielding(source))
		return

	examine_list += span_notice("[source] appears to be in a duel stance.")

/datum/heretic_knowledge/duel_stance/proc/on_examine_more(mob/living/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	if(!IS_HERETIC(examiner))
		return

	if(!is_dual_wielding(source))
		return

	examine_list += span_notice("While in duel stance, they have increased resistance and counter-attacks.")

/datum/heretic_knowledge/duel_stance/proc/is_dual_wielding(mob/living/carbon/human/heretic)
	if(!istype(heretic))
		return FALSE

	var/obj/item/left_hand = heretic.get_inactive_held_item()
	var/obj/item/right_hand = heretic.get_active_held_item()

	if(!left_hand || !right_hand)
		return FALSE

	if(!istype(left_hand, /obj/item/melee/sickly_blade) || !istype(right_hand, /obj/item/melee/sickly_blade))
		return FALSE

	return TRUE