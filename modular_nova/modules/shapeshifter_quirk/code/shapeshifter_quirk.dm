/datum/quirk/shapeshifter
	name = "Shapeshifter(Оборотень)"
	desc = "Вы способны произвольно изменять форму своего тела."
	icon = FA_ICON_SHAPES
	gain_text = span_purple("Ваше тело кажется изменяемым, податливым.")
	lose_text = span_notice("Ваше тело теряет ощущение податливости.")
	medical_record_text = "У пациента необычная физиология, позволяющая физически преобразовывать своё тело."
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
