/datum/quirk/night_vision
	name = "Night Vision(Ночное зрение)"
	desc = "Вы видите чуть лучше полной темноте, чем большинство людей."
	icon = FA_ICON_MOON
	value = 4
	mob_trait = TRAIT_NIGHT_VISION
	gain_text = span_notice("Тени кажутся немного менее тёмными.")
	lose_text = span_danger("Всё вокруг кажется чуть темнее.")
	medical_record_text = "Глаза пациента демонстрируют повышенную адаптацию к темноте."
	mail_goodies = list(
		/obj/item/flashlight/flashdark,
		/obj/item/food/grown/mushroom/glowshroom/shadowshroom,
		/obj/item/skillchip/light_remover,
	)

/datum/quirk/night_vision/add(client/client_source)
	refresh_quirk_holder_eyes()

/datum/quirk/night_vision/remove()
	refresh_quirk_holder_eyes()

/datum/quirk/night_vision/proc/refresh_quirk_holder_eyes()
	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	var/obj/item/organ/eyes/eyes = human_quirk_holder.get_organ_by_type(/obj/item/organ/eyes)
	if(!eyes)
		return

	// NIGHT VISION ADJUSTMENT - adjusts color cutoffs based on chosen quirk color, or left eye colour if not available
	nv_color_cutoffs = calculate_color_cutoffs(nv_color)
	eyes.color_cutoffs = nv_color_cutoffs
	// We've either added or removed TRAIT_NIGHT_VISION before calling this proc. Just refresh the eyes.
	eyes.refresh()
