//Chameleon causes the owner to slowly become transparent when not moving.
/datum/mutation/chameleon
	name = "Chameleon"
	desc = "A genome that causes the holder's skin to become transparent over time."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = span_notice("You feel one with your surroundings.")
	text_lose_indication = span_notice("You feel oddly exposed.")
	instability = POSITIVE_INSTABILITY_MAJOR
	power_coeff = 1

/datum/mutation/chameleon/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	/// NOVA EDIT ADDITION  BEGIN
	if(HAS_TRAIT(owner, TRAIT_CHAMELEON_SKIN))
		return
	ADD_TRAIT(owner, TRAIT_CHAMELEON_SKIN, GENETIC_MUTATION)
	/// NOVA EDIT ADDITION END
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(owner, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_attack_hand))

/datum/mutation/chameleon/on_life(seconds_per_tick)
	/// NOVA EDIT ADDITION BEGIN
	if(!HAS_TRAIT(owner, TRAIT_CHAMELEON_SKIN))
		return
	/// NOVA EDIT ADDITION END
	owner.alpha = max(owner.alpha - (12.5 * (GET_MUTATION_POWER(src)) * seconds_per_tick), 0)

//Upgraded mutation of the base variant, used for changelings. No instability and better power_coeff
/datum/mutation/chameleon/changeling
	instability = 0
	power_coeff = 2.5
	locked = TRUE

/**
 * Resets the alpha of the host to the chameleon default if they move.
 *
 * Arguments:
 * - [source][/atom/movable]: The source of the signal. Presumably the host mob.
 * - [old_loc][/atom]: The location the host mob used to be in.
 * - move_dir: The direction the host mob moved in.
 * - forced: Whether the movement was caused by a forceMove or moveToNullspace.
 * - [old_locs][/list/atom]: The locations the host mob used to be in.
 */
/datum/mutation/chameleon/proc/on_move(atom/movable/source, atom/old_loc, move_dir, forced, list/atom/old_locs)
	SIGNAL_HANDLER

	/// NOVA EDIT BEGIN
	if(HAS_TRAIT(owner, TRAIT_CHAMELEON_SKIN))
		owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY
	else
		owner.alpha = 255
		/// NOVA EDIT END

/**
 * Resets the alpha of the host if they click on something nearby.
 *
 * Arguments:
 * - [source][/mob/living/carbon/human]: The host mob that just clicked on something.
 * - [target][/atom]: The thing the host mob clicked on.
 * - proximity: Whether the host mob can physically reach the thing that they clicked on.
 * - [modifiers][/list]: The set of click modifiers associated with this attack chain call.
 */
/datum/mutation/chameleon/proc/on_attack_hand(mob/living/carbon/human/source, atom/target, proximity, list/modifiers)
	SIGNAL_HANDLER

	if(!proximity) //stops tk from breaking chameleon
		return

	/// NOVA EDIT BEGIN
	if(HAS_TRAIT(owner, TRAIT_CHAMELEON_SKIN))
		owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY
	else
		owner.alpha = 255
	/// NOVA EDIT END

/datum/mutation/chameleon/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.alpha = 255
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_UNARMED_ATTACK))
	/// NOVA EDIT BEGIN
	REMOVE_TRAIT(owner, TRAIT_CHAMELEON_SKIN, GENETIC_MUTATION)
	/// NOVA EDIT END


// BEGIN NOVA CORE MIGRATION: code/datums/mutations/chameleon.dm
// toggleable chameleon skin
/datum/mutation/chameleon
	power_path = /datum/action/cooldown/spell/chameleon_skin_activate

/datum/action/cooldown/spell/chameleon_skin_activate
	name = "Activate Chameleon Skin"
	desc = "The chromatophores in your skin adjust to your surroundings, as long as you stay still."
	spell_requirements = NONE
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"

/datum/action/cooldown/spell/chameleon_skin_activate/cast(list/targets, mob/user = usr)
	. = ..()

	if(HAS_TRAIT(user,TRAIT_CHAMELEON_SKIN))
		chameleon_skin_deactivate(user)
		return

	ADD_TRAIT(user, TRAIT_CHAMELEON_SKIN, GENETIC_MUTATION)
	to_chat(user, "The pigmentation of your skin shifts and starts to take on the colors of your surroundings.")

/datum/action/cooldown/spell/chameleon_skin_activate/proc/chameleon_skin_deactivate(mob/user = usr)
	if(!HAS_TRAIT_FROM(user,TRAIT_CHAMELEON_SKIN, GENETIC_MUTATION))
		return

	REMOVE_TRAIT(user, TRAIT_CHAMELEON_SKIN, GENETIC_MUTATION)
	user.alpha = 255
	to_chat(user, text("Your skin shifts as it shimmers back into its original colors."))
// END NOVA CORE MIGRATION: code/datums/mutations/chameleon.dm
