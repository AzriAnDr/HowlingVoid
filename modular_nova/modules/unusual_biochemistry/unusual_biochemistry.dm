GLOBAL_LIST_INIT(possible_unusual_biochem_blood_types, list(
	/datum/blood_type/haemocyanin,
	/datum/blood_type/chlorocruorin,
	/datum/blood_type/hemerythrin,
	/datum/blood_type/pinnaglobin,
	/datum/blood_type/exotic,
))

/datum/quirk/unusual_biochemistry
	name = "Unusual Biochemistry"
	desc = "Химический состав вашей крови отличается от состава обычного члена экипажа."
	icon = FA_ICON_DROPLET
	value = 0
	mob_trait = TRAIT_UNUSUAL_BIOCHEMISTRY
	gain_text = span_notice("У вас необычная биохимия.")
	lose_text = span_danger("Ваша биохимия стала... нормальной.")
	medical_record_text = "Пациент обладает необычной биохимией. Для переливания крови может потребоваться помощь химика."
	quirk_flags = QUIRK_HUMAN_ONLY
	/// Выбранный необычный тип крови (через настройки трейта)
	var/datum/blood_type/blood_type


/datum/quirk_constant_data/unusual_biochemistry
	associated_typepath = /datum/quirk/unusual_biochemistry
	customization_options = list(/datum/preference/choiced/unusual_biochemistry)

/datum/quirk/unusual_biochemistry/add(client/client_source)
	blood_type = get_blood_type(client_source?.prefs.read_preference(/datum/preference/choiced/unusual_biochemistry))
	if(!istype(blood_type))
		blood_type = get_blood_type(pick(GLOB.possible_unusual_biochem_blood_types)) // no client/prefs for some reason? pick a random one

	var/mob/living/carbon/human/human_holder = quirk_holder

	// Get rid of any exotic blood that we used to have
	human_holder.dna.species.exotic_bloodtype = null

	human_holder.set_blood_type(blood_type)
