/datum/quirk/bodytemp
	name = "Abnormal body temperature(Аномальная температура тела)"
	desc = "Ваша температура тела отличается от температуры вашего вида, находясь на определённом уровне выше или ниже. Это не рекомендуется для холоднокровных видов. \
		Диапазон причуды составляет от -40 до +70, в зависимости от способа доставки вас на станцию, прием этого вещества в экстремальных дозах может привести к небольшим ожогам."
	value = 0
	gain_text = span_danger("У вас повышенная температура тела.")
	lose_text = span_notice("Температура вашего тела в норме.")
	medical_record_text = "У пациента наблюдается аномальная для его вида температура тела.."
	icon = FA_ICON_THERMOMETER_HALF
	/// The number that will be added to the original quirk_holder's bodytemp_normal
	var/bodytemp_modifier = 0

/datum/quirk_constant_data/bodytemp
	associated_typepath = /datum/quirk/bodytemp
	customization_options = list(
		/datum/preference/numeric/bodytemp_customization/bodytemp,
	)

/datum/preference/numeric/bodytemp_customization
	abstract_type = /datum/preference/numeric/bodytemp_customization
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_identifier = PREFERENCE_CHARACTER
	minimum = -40 //Plasmamen
	maximum = 70 //Skrell

/datum/preference/numeric/bodytemp_customization/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE

/datum/preference/numeric/bodytemp_customization/create_default_value()
	return 20

/datum/preference/numeric/bodytemp_customization/bodytemp
	savefile_key = "bodytemp"

/datum/quirk/bodytemp/add_unique(client/client_source)
	. = ..()

	bodytemp_modifier = client_source?.prefs?.read_preference(/datum/preference/numeric/bodytemp_customization/bodytemp) || 0
	var/mob/living/carbon/human/user = quirk_holder
	user.dna.species.bodytemp_normal += bodytemp_modifier
	user.dna.species.bodytemp_heat_damage_limit += bodytemp_modifier
	user.dna.species.bodytemp_cold_damage_limit += bodytemp_modifier

/datum/quirk/bodytemp/remove()
	. = ..()

	if(QDELETED(quirk_holder))
		return
	var/mob/living/carbon/human/user = quirk_holder
	user.dna.species.bodytemp_normal -= bodytemp_modifier
	user.dna.species.bodytemp_heat_damage_limit -= bodytemp_modifier
	user.dna.species.bodytemp_cold_damage_limit -= bodytemp_modifier
