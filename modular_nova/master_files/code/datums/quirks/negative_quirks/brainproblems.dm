// Re-labels TG brainproblems to be more generic. There never was a tumor anyways!
/datum/quirk/item_quirk/brainproblems
	name = "Brain Degeneration(Проблемы с мозгом)"
	desc = "У вас смертельно опасное заболевание мозга, которое медленно его разрушает. Лучше возьмите с собой маннитол!"
	medical_record_text = "У пациента смертельно опасное заболевание мозга, которое постепенно приводит к его смерти."
	icon = FA_ICON_BRAIN
	species_quirks = list(/datum/species/synthetic = /datum/quirk/item_quirk/brainproblems/synth)

// Override of Brain Tumor quirk for species with artificial brains.
// Does not appear in TGUI or the character preferences window.
/datum/quirk/item_quirk/brainproblems/synth
	name = "Позитронная каскадная аномалия"
	gain_text = span_danger("Ты глючишь.")
	lose_text = span_notice("Баг исчез.")
	mail_goodies = list(/obj/item/storage/pill_bottle/liquid_solder/braintumor)
	abstract_parent_type = /datum/quirk/item_quirk/brainproblems/synth

// Adds custom medical flavortext for synthetic brains.
/datum/quirk/item_quirk/brainproblems/synth/add()
	. = ..()
	var/obj/item/organ/brain/synth/synth_brain = quirk_holder.get_organ_slot(ORGAN_SLOT_BRAIN)
	switch(synth_brain.type)
		if(/obj/item/organ/brain/synth)
			name = "Позитронная каскадная аномалия"
		if(/obj/item/organ/brain/synth/mmi)
			name = "Синдром отторжения интерфейса"
		if(/obj/item/organ/brain/synth/circuit)
			name = "Ошибка прошивки процессора"
		if(/obj/item/organ/brain/synth/circuit/hyperboard)
			name = "Ошибка прошивки процессора"
		if(/obj/item/organ/brain/synth/circuit/limaengine)
			name = "Аномалия нестабильности жидкого ядра"
		if(/obj/item/organ/brain/synth/circuit/disk)
			name = "Короткое замыкание оборудования"
		if(/obj/item/organ/brain/synth/circuit/neuroboard)
			name = "Нарушение работы нервной системы"
		if(/obj/item/organ/brain/synth/circuit/condensed)
			name = "Дестабилизация кристаллов"
		if(/obj/item/organ/brain/synth/circuit/cyberdeck)
			name = "Дестабилизация системы"

	medical_record_text = "У пациента обнаружен сбой в работе [synth_brain.name], который постепенно приводит к смерти мозга."

// Synthetics get liquid_solder with Brain Tumor instead of mannitol.
/datum/quirk/item_quirk/brainproblems/add_unique(client/client_source)
	if(!issynthetic(quirk_holder))
		return ..()
	give_item_to_holder(
		/obj/item/storage/pill_bottle/liquid_solder/braintumor,
		list(
			LOCATION_LPOCKET,
			LOCATION_RPOCKET,
			LOCATION_BACKPACK,
			LOCATION_HANDS,
		),
		flavour_text = "Эти таблетки помогут вам продержаться до тех пор, пока вы не раздобудете лекарства. Не полагайтесь на них слишком сильно!",
		notify_player = TRUE,
	)
