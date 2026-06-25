#define SHAPESHIFTER_ACTIONS_ICON_FILE 'icons/shapeshifter_quirk/actions_shapeshift.dmi'

/datum/action/innate/alter_form/quirk
	name = "Shapeshift"
	slime_restricted = FALSE
	button_icon = 'icons/mob/actions/actions_slime_additions.dmi'
	button_icon_state = "dna"
	shapeshift_text = "closes their eyes to focus, their body subtly shifting and contorting."

/datum/action/innate/alter_form/quirk/generate_radial_icons()
	..()
	bodycolours_icon = image(icon = SHAPESHIFTER_ACTIONS_ICON_FILE, icon_state = "transform_all")
	primarycolour_icon = image(icon = SHAPESHIFTER_ACTIONS_ICON_FILE, icon_state = "transform_red")
	secondarycolour_icon = image(icon = SHAPESHIFTER_ACTIONS_ICON_FILE, icon_state = "transform_blue")
	tertiarycolour_icon = image(icon = SHAPESHIFTER_ACTIONS_ICON_FILE, icon_state = "transform_green")
	allcolours_icon = image(icon = SHAPESHIFTER_ACTIONS_ICON_FILE, icon_state = "transform_all")

/datum/quirk/shapeshifter
	name = "Shapeshifter"
	desc = "You are able to shapeshift your body at-will."
	icon = FA_ICON_SHAPES
	gain_text = span_purple("Your body feels alterable, malleable.")
	lose_text = span_notice("Your body loses its alterable feeling.")
	medical_record_text = "Patient has an unusual physiology that allows them to physically transform their body."
	value = 8
	quirk_flags = QUIRK_HUMAN_ONLY

/datum/quirk/shapeshifter/is_species_appropriate(datum/species/mob_species)
	if(ispath(mob_species, /datum/species/dullahan))
		return FALSE
	return ..()

/datum/quirk/shapeshifter/add(client/client_source)
	var/datum/action/innate/alter_form/quirk/shapeshift_action = new
	shapeshift_action.Grant(quirk_holder)

/datum/quirk/shapeshifter/remove()
	var/datum/action/action_to_remove = locate(/datum/action/innate/alter_form/quirk) in quirk_holder.actions
	if(action_to_remove)
		qdel(action_to_remove)

#undef SHAPESHIFTER_ACTIONS_ICON_FILE
