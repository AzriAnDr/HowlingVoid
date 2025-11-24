/datum/quirk/floating_items
	name = "Psionic Holding(Псионический телекинез)"
	desc = "Тебе неудобно держать предметы руками, и вместо этого используешь силу мысли."
	value = 0
	icon = FA_ICON_METEOR
	medical_record_text = "Разум субъекта способен на крайне ограниченный телекинез."
	gain_text = "Кажется, что разум может поднимать тяжести!"
	lose_text = "Такое ощущение, будто вы отупели."
	mob_trait = TRAIT_FLOATING_HELD

/datum/quirk_constant_data/floating_items
	associated_typepath = /datum/quirk/floating_items
	customization_options = list(/datum/preference/color/floating_items)

/datum/preference/color/floating_items
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "floating_items"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/color/floating_items/apply_to_human(mob/living/carbon/human/target, value)
	target.held_hover_color = value

/datum/quirk/floating_items/add(client/client_source)
	. = ..()
	var/datum/action/innate/toggle_floating_items/toggle = new
	toggle.Grant(quirk_holder)

/datum/preference/color/floating_items/create_default_value()
	return "#FF99FF"

/datum/action/innate/toggle_floating_items
	name = "Toggle Psionic Holding(Переключить псионический телекинез)"
	button_icon = 'modular_nova/master_files/icons/effects/tele_effects.dmi'
	button_icon_state = "telekinesishead"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS

/datum/action/innate/toggle_floating_items/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	if(owner)
		if(HAS_TRAIT(owner, TRAIT_FLOATING_HELD))
			REMOVE_TRAIT(owner, TRAIT_FLOATING_HELD, QUIRK_TRAIT)
			if(ishuman(owner))
				var/mob/living/carbon/human/owner_human = owner
				owner_human.update_held_items()
			to_chat(owner, span_notice("Ты перестаёшь фокусироваться на перемещении объектов силой мысли."))
		else
			ADD_TRAIT(owner, TRAIT_FLOATING_HELD, QUIRK_TRAIT)
			if(ishuman(owner))
				var/mob/living/carbon/human/owner_human = owner
				owner_human.update_held_items()
			to_chat(owner, span_notice("Ты готов двигать предметы силой мысли."))
	return TRUE
