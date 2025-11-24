/datum/quirk/quadruple_amputee
	name = "Quadruple Amputee(Четырёхкратный ампутант)"
	desc = "Упс! Всё протезы! Из-за какого-то поистине жестокого космического наказания все ваши конечности были заменены лишними протезами."
	icon = "tg-prosthetic-full"
	value = -6
	medical_record_text = "При физикальном обследовании у пациента обнаружено наличие всех малобюджетных протезов конечностей."
	hardcore_value = 6
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/weldingtool/mini, /obj/item/stack/cable_coil/five)

/datum/quirk/quadruple_amputee/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.del_and_replace_bodypart(new /obj/item/bodypart/arm/left/robot/surplus, special = TRUE)
	human_holder.del_and_replace_bodypart(new /obj/item/bodypart/arm/right/robot/surplus, special = TRUE)
	human_holder.del_and_replace_bodypart(new /obj/item/bodypart/leg/left/robot/surplus, special = TRUE)
	human_holder.del_and_replace_bodypart(new /obj/item/bodypart/leg/right/robot/surplus, special = TRUE)

/datum/quirk/quadruple_amputee/post_add()
	to_chat(quirk_holder, span_bolddanger("Все ваши конечности заменены лишними протезами. Они хрупкие и легко развалятся под давлением. \
	Кроме того, для их ремонта вам придется использовать сварочный аппарат и кабели, а не пластыри и мазь."))

/datum/quirk/quadruple_amputee/remove()
	if(QDELING(quirk_holder))
		return

	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.reset_to_original_bodypart(BODY_ZONE_L_ARM)
	human_holder.reset_to_original_bodypart(BODY_ZONE_R_ARM)
	human_holder.reset_to_original_bodypart(BODY_ZONE_L_LEG)
	human_holder.reset_to_original_bodypart(BODY_ZONE_R_LEG)
