/datum/quirk/item_quirk/fluoride_stare
	name = "Fluoride Stare(Флюоридный взгляд)"
	desc = "Ты потерял веки в ужасной аварии, или, по крайней мере, так ты говоришь другим. Тебе нужно времея от времени вручную смачивать глаза солевым раствором!"
	icon = FA_ICON_EYE_DROPPER
	value = -6
	gain_text = span_danger("Глаза зудят и становятся сухими...")
	lose_text = span_notice("Ты понимаешь, что внезапная тьма, которая только что окутала тебя, была всего лишь вашими отросшими веками.")
	medical_record_text = "Пациент лишился век в результате тяжелого несчастного случая. Радуюсь что он хоть не моргает вертикально..."
	hardcore_value = 6
	quirk_flags = QUIRK_HUMAN_ONLY
	mail_goodies = list(/obj/item/reagent_containers/cup/bottle/salglu_solution, /obj/item/light/bulb)

/datum/quirk/item_quirk/fluoride_stare/is_species_appropriate(datum/species/mob_species)
	if(ispath(mob_species, /datum/species/dullahan))
		return FALSE
	return ..()

/datum/quirk/item_quirk/fluoride_stare/add_unique(client/client_source)
	var/obj/item/reagent_containers/cup/bottle/salglu_solution/saline = new(get_turf(quirk_holder))
	give_item_to_holder(saline, list(
		LOCATION_LPOCKET,
		LOCATION_RPOCKET,
		LOCATION_BACKPACK,
		LOCATION_HANDS,
	))
	var/obj/item/reagent_containers/dropper/dropper = new(get_turf(quirk_holder))
	give_item_to_holder(dropper, list(
		LOCATION_LPOCKET,
		LOCATION_RPOCKET,
		LOCATION_BACKPACK,
		LOCATION_HANDS,
	))

/datum/quirk/item_quirk/fluoride_stare/add(client/client_source)
	ADD_TRAIT(quirk_holder, TRAIT_NO_EYELIDS, QUIRK_TRAIT)
	quirk_holder.AddComponent(/datum/component/manual_blinking, 0.5, 3 MINUTES, 30 SECONDS, FALSE)

/datum/quirk/item_quirk/fluoride_stare/remove()
	REMOVE_TRAIT(quirk_holder, TRAIT_NO_EYELIDS, QUIRK_TRAIT)
	if (!HAS_TRAIT(quirk_holder, TRAIT_NO_EYELIDS))
		qdel(quirk_holder.GetComponent(/datum/component/manual_blinking))
