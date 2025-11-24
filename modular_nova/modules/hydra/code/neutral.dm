/datum/quirk/hydra
	name = "Hydra Heads(Гидра)"
	desc = "Вы — трёхголовое существо. Чтобы использовать, форматируйте имя так: (Рыкс-Сыкс-Дыкс)"
	value = 0
	mob_trait = TRAIT_HYDRA_HEADS
	gain_text = span_notice("Вы слышите два других голоса в своей голове.")
	lose_text = span_danger("Все ваши умы становятся едиными.")
	medical_record_text = "К одному телу прикреплено несколько голов и личностей."
	icon = FA_ICON_HORSE_HEAD
	// remember what the name was before activation
	var/original_name

/datum/quirk/hydra/is_species_appropriate(datum/species/mob_species)
	if(ispath(mob_species, /datum/species/dullahan))
		return FALSE
	return ..()

/datum/quirk/hydra/add(client/client_source)
	var/mob/living/carbon/human/hydra = quirk_holder
	var/datum/action/innate/hydra/spell = new(hydra)
	var/datum/action/innate/hydrareset/resetspell = new(hydra)
	spell.Grant(hydra)
	spell.owner = hydra
	resetspell.Grant(hydra)
	resetspell.owner = hydra

/datum/action/innate/hydra
	name = "Переключатель головы"
	desc = "Переключайтесь между головами на вашем теле."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "art_summon"

/datum/action/innate/hydrareset
	name = "Сбросить речь"
	desc = "Вернуть всё как было."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "art_summon"

/datum/action/innate/hydrareset/Activate()
	var/mob/living/carbon/human/hydra = owner
	var/datum/quirk/hydra/hydra_quirk = hydra.get_quirk(/datum/quirk/hydra)
	if(!hydra_quirk.original_name) // sets the archived 'real' name if not set.
		hydra_quirk.original_name = hydra.real_name
	hydra.real_name = hydra_quirk.original_name
	hydra.visible_message(span_notice("[hydra.name] выдвигает все три головы вперед; кажется, они разговаривают как один коллектив."), \
							span_notice("Вы сейчас говорите как [hydra_quirk.original_name]!"), ignored_mobs=owner)

/datum/action/innate/hydra/Activate() //Oops, all hydra!
	var/mob/living/carbon/human/hydra = owner
	var/datum/quirk/hydra/hydra_quirk = hydra.get_quirk(/datum/quirk/hydra)
	if(!hydra_quirk.original_name) // sets the archived 'real' name if not set.
		hydra_quirk.original_name = hydra.real_name
	var/list/names = splittext(hydra_quirk.original_name,"-")
	var/selhead = input("От имени кого бы вы хотели выступить?","Головы:") in names
	hydra.real_name = selhead
	hydra.visible_message(span_notice("[hydra.name] оттягивает остальную часть их голов назад и выдвигает [selhead] вперед."), \
							span_notice("Вы сейчас говорите как [selhead]!"), ignored_mobs=owner)
