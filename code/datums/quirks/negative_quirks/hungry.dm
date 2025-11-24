#define QUIRK_HUNGRY_MOD 2

/datum/quirk/hungry
	name = "Hungry(Голодный)"
	desc = "У тебя ненасытный аппетит. Другими словами, твой желудок бездонный. Придётся есть гораздо больше, чем другим, чтобы утолить голод."
	value = -2
	icon = FA_ICON_BOWL_FOOD
	gain_text = span_notice("Каждется в желудке чёрная дыра....")
	lose_text = span_notice("Я наконец-то чувствую себя сытым.")
	medical_record_text = "Пациент испытывает голод гораздо быстрее, чем обычно."
	quirk_flags = QUIRK_HUMAN_ONLY
	mail_goodies = list(
		/obj/item/food/chips,
		/obj/item/paper/paperslip/ration_ticket/luxury,
		/obj/item/paper/paperslip/ration_ticket,
		/obj/item/food/chocolatebar,
		/obj/item/storage/box/spaceman_ration/meats,
		/obj/item/reagent_containers/cup/glass/dry_ramen,
	)

/datum/quirk/hungry/is_species_appropriate(datum/species/mob_species)
	if(TRAIT_NOHUNGER in GLOB.species_prototypes[mob_species].inherent_traits)
		return FALSE
	return ..()

/datum/quirk/hungry/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(istype(human_holder))
		human_holder.physiology.hunger_mod *= QUIRK_HUNGRY_MOD

/datum/quirk/hungry/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(istype(human_holder))
		human_holder.physiology.hunger_mod /= QUIRK_HUNGRY_MOD

#undef QUIRK_HUNGRY_MOD
