/datum/quirk/item_quirk/chronic_illness
	name = "Eradicative Chronic Illness(Хроническая болезнь)"
	desc = "У тебя аномальное хроническое заболевание, требующее постоянного приема лекарств для его контроля или вызывающее коррекцию потока времени."
	icon = FA_ICON_DISEASE
	value = -12
	gain_text = span_danger("Ты чувствуешь, как будто исчезаете...")
	lose_text = span_notice("Ты внезапно чувствуешь себя более живым.")
	medical_record_text = "У пациента аномальное хроническое заболевание, требующее постоянного приема лекарств для контроля. А не ВИЧ ли это?"
	hardcore_value = 12
	mail_goodies = list(/obj/item/storage/pill_bottle/sansufentanyl)

/datum/quirk/item_quirk/chronic_illness/add(client/client_source)
	var/datum/disease/chronic_illness/hms = new /datum/disease/chronic_illness()
	quirk_holder.ForceContractDisease(hms)

/datum/quirk/item_quirk/chronic_illness/add_unique(client/client_source)
	give_item_to_holder(/obj/item/storage/pill_bottle/sansufentanyl, list(LOCATION_BACKPACK), flavour_text = "Вам выписали лекарство для контроля вашего состояния. Принимайте его регулярно, чтобы избежать осложнений.", notify_player = TRUE)
	give_item_to_holder(/obj/item/healthanalyzer/simple/disease, list(LOCATION_BACKPACK))
