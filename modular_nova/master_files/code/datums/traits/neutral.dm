GLOBAL_VAR_INIT(DNR_trait_overlay, generate_DNR_trait_overlay())

/// Instantiates GLOB.DNR_trait_overlay by creating a new mutable_appearance instance of the overlay.
/proc/generate_DNR_trait_overlay()
	RETURN_TYPE(/mutable_appearance)

	var/mutable_appearance/DNR_trait_overlay = mutable_appearance('modular_nova/modules/indicators/icons/DNR_trait_overlay.dmi', "DNR", FLY_LAYER)
	DNR_trait_overlay.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	return DNR_trait_overlay


// NOVA NEUTRAL TRAITS
/datum/quirk/excitable
	name = "Excitable!(Возбудимый!)"
	desc = "Если погладить по голове, хвост завиляет! Ты очень возбудимый!"
	gain_text = span_notice("Вам не терпится погладить кого-нибудь по голове!")
	lose_text = span_notice("Тебя больше не волнуют похлопывания по голове.")
	medical_record_text = "Пациент, по-видимому, легко возбуждается."
	value = 0
	mob_trait = TRAIT_EXCITABLE
	icon = FA_ICON_LAUGH_BEAM

/datum/quirk/affectionaversion
	name = "Affection Aversion(Отвращение к ласкам)"
	desc = "Вы отказываетесь быть облизываемым или обнюхиваемым четвероногим киборгом."
	gain_text = span_notice("Вас добавили в реестры «Не облизывайте» и «Не нюхайте».")
	lose_text = span_notice("Вас исключили из реестров «Не облизывайте» и «Не нюхайте».")
	medical_record_text = "Пациент внесен в реестры «Не облизывать» и «Не нюхать»."
	value = 0
	mob_trait = TRAIT_AFFECTION_AVERSION
	icon = FA_ICON_CIRCLE_EXCLAMATION

/datum/quirk/personalspace
	name = "Personal Space(Личное пространство)"
	desc = "Вы бы предпочли, чтобы люди держали руки подальше от вашей задницы."
	gain_text = span_notice("Тебе бы хотелось, чтобы люди не лезли к твоей заднице.")
	lose_text = span_notice("Вас меньше волнуют прикосновения к вашей заднице.")
	medical_record_text = "Пациент отрицательно реагирует на прикосновения к ягодицам."
	value = 0
	mob_trait = TRAIT_PERSONALSPACE
	icon = FA_ICON_HAND_PAPER

/datum/quirk/dnr
	name = "Do Not Revive(Не возрождать)"
	desc = "По какой-то причине вас невозможно оживить никаким способом."
	gain_text = span_notice("Ваш дух слишком напуган, чтобы принять возрождение.")
	lose_text = span_notice("Вы снова почувствуете, как ваша душа исцеляется.")
	medical_record_text = "Пациенту отказано в реанимации, и его невозможно реанимировать никаким способом."
	value = 0
	mob_trait = TRAIT_DNR
	icon = FA_ICON_SKULL_CROSSBONES

/datum/quirk/dnr/add(client/client_source)
	. = ..()

	quirk_holder.update_dnr_hud()

/datum/quirk/dnr/remove()
	var/mob/living/old_holder = quirk_holder

	. = ..()

	old_holder.update_dnr_hud()

/mob/living/prepare_data_huds()
	. = ..()

	update_dnr_hud()

/// Adds the DNR HUD element if src has TRAIT_DNR. Removes it otherwise.
/mob/living/proc/update_dnr_hud()
	set_hud_image_state(DNR_HUD, "hud_dnr")
	if(HAS_TRAIT(src, TRAIT_DNR))
		set_hud_image_active(DNR_HUD)
	else
		set_hud_image_inactive(DNR_HUD)

/mob/living/carbon/human/examine(mob/user)
	. = ..()

	if(stat != DEAD && HAS_TRAIT(src, TRAIT_DNR) && (HAS_TRAIT(user, TRAIT_SECURITY_HUD) || HAS_TRAIT(user, TRAIT_MEDICAL_HUD)))
		. += "\n[span_boldwarning("Эту личность невозможно оживить, и если ей позволить умереть, она может умереть навсегда!")]"

/datum/atom_hud/data/human/dnr
	hud_icons = list(DNR_HUD)

// uncontrollable laughter
/datum/quirk/item_quirk/joker
	name = "Pseudobulbar Affect(Псевдобульбарный аффект)"
	desc = "Время от времени вы испытываете неконтролируемые приступы смеха. Хоакин Феникс?"
	value = 0
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	medical_record_text = "Пациент страдает от внезапных и неконтролируемых приступов смеха."
	var/pcooldown = 0
	var/pcooldown_time = 60 SECONDS
	icon = FA_ICON_GRIN_TEARS

/datum/quirk/item_quirk/joker/add_unique(client/client_source)
	give_item_to_holder(/obj/item/paper/joker, list(LOCATION_BACKPACK, LOCATION_HANDS))

/datum/quirk/item_quirk/joker/process()
	if(pcooldown > world.time)
		return
	pcooldown = world.time + pcooldown_time
	var/mob/living/carbon/human/user = quirk_holder
	if(user && istype(user))
		if(user.stat == CONSCIOUS)
			if(prob(20))
				user.emote("laugh")
				addtimer(CALLBACK(user, /mob/proc/emote, "laugh"), 5 SECONDS)
				addtimer(CALLBACK(user, /mob/proc/emote, "laugh"), 10 SECONDS)

/obj/item/paper/joker
	name = "карта инвалидности"
	icon = 'modular_nova/master_files/icons/obj/card.dmi'
	icon_state = "joker"
	desc = "Улыбнись, даже если твое сердце болит."
	default_raw_text = "<i>\
			<div style='border-style:solid;text-align:center;border-width:5px;margin: 20px;margin-bottom:0px'>\
			<div style='margin-top:20px;margin-bottom:20px;font-size:150%;'>\
			Прости мой смех:<br>\
			У меня есть заболевание.\
			</div>\
			</div>\
			</i>\
			<br>\
			<center>\
			<b>\
			БОЛЬШЕ НА ОБОРОТЕ\
			</b>\
			</center>"
	/// Whether or not the card is currently flipped.
	var/flipped = FALSE
	/// The flipped version of default_raw_text.
	var/flipside_default_raw_text = "<i>\
			<div style='border-style:solid;text-align:center;border-width:5px;margin: 20px;margin-bottom:0px'>\
			<div style='margin-top:20px;margin-bottom:20px;font-size:100%;'>\
			<b>\
			Это заболевание, вызывающее внезапную,<br>\
			частый и неконтролируемый смех, который<br>\
			не соответствует тому, что вы чувствуете.<br>\
			Это может произойти у людей с травмой головного мозга<br>\
			или определенные неврологические состояния.<br>\
			</b>\
			</div>\
			</div>\
			</i>\
			<br>\
			<center>\
			<b>\
			Пожалуйста, верните эту карту.\
			</b>\
			</center>"
	/// Flipside version of raw_text_inputs.
	var/list/datum/paper_input/flipside_raw_text_inputs
	/// Flipside version of raw_stamp_data.
	var/list/datum/paper_stamp/flipside_raw_stamp_data
	/// Flipside version of raw_field_input_data.
	var/list/datum/paper_field/flipside_raw_field_input_data
	/// Flipside version of input_field_count
	var/flipside_input_field_count = 0


/obj/item/paper/joker/Initialize(mapload)
	. = ..()
	if(flipside_default_raw_text)
		add_flipside_raw_text(flipside_default_raw_text)


/**
 * This is an unironic copy-paste of add_raw_text(), meant to have the same functionalities, but for the flipside.
 *
 * This simple helper adds the supplied raw text to the flipside of the paper, appending to the end of any existing contents.
 *
 * This a God proc that does not care about paper max length and expects sanity checking beforehand if you want to respect it.
 *
 * The caller is expected to handle updating icons and appearance after adding text, to allow for more efficient batch adding loops.
 * * Arguments:
 * * text - The text to append to the paper.
 * * font - The font to use.
 * * color - The font color to use.
 * * bold - Whether this text should be rendered completely bold.
 */
/obj/item/paper/joker/proc/add_flipside_raw_text(text, font, color, bold)
	var/new_input_datum = new /datum/paper_input(
		text,
		font,
		color,
		bold,
	)

	flipside_input_field_count += get_input_field_count(text)

	LAZYADD(flipside_raw_text_inputs, new_input_datum)


/obj/item/paper/joker/update_icon()
	..()
	icon_state = "joker"

/obj/item/paper/joker/click_alt(mob/user)
	var/list/datum/paper_input/old_raw_text_inputs = raw_text_inputs
	var/list/datum/paper_stamp/old_raw_stamp_data = raw_stamp_data
	var/list/datum/paper_stamp/old_raw_field_input_data = raw_field_input_data
	var/old_input_field_count = input_field_count

	raw_text_inputs = flipside_raw_text_inputs
	raw_stamp_data = flipside_raw_stamp_data
	raw_field_input_data = flipside_raw_field_input_data
	input_field_count = flipside_input_field_count

	flipside_raw_text_inputs = old_raw_text_inputs
	flipside_raw_stamp_data = old_raw_stamp_data
	flipside_raw_field_input_data = old_raw_field_input_data
	flipside_input_field_count = old_input_field_count

	flipped = !flipped
	update_static_data()

	balloon_alert(user, "card flipped")
	return CLICK_ACTION_SUCCESS

/datum/quirk/feline_aspect
	name = "Feline Aspect(Кошачьи черты)"
	desc = "Ты, по какой-то причине, ведёшь себя как кошка. Это заменит большинство других речевых особенностей, связанных с языком."
	gain_text = span_notice("Ня! Сейчас бы попробовать кошачью мяту...")
	lose_text = span_notice("Вы чувствуете меньшее влечение к лазерам.")
	medical_record_text = "Похоже, поведение пациента во многом напоминает поведение кошки."
	mob_trait = TRAIT_FELINE
	icon = FA_ICON_CAT

/datum/quirk/feline_aspect/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/organ/tongue/cat/new_tongue = new(get_turf(human_holder))

	ADD_TRAIT(human_holder, TRAIT_WATER_HATER, QUIRK_TRAIT)

	new_tongue.copy_traits_from(human_holder.get_organ_slot(ORGAN_SLOT_TONGUE), human_holder)
	new_tongue.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/datum/quirk/feline_aspect/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/organ/tongue/new_tongue = new human_holder.dna.species.mutanttongue

	REMOVE_TRAIT(human_holder, TRAIT_WATER_HATER, QUIRK_TRAIT)

	new_tongue.copy_traits_from(human_holder.get_organ_slot(ORGAN_SLOT_TONGUE), human_holder)
	new_tongue.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/datum/quirk/canine_aspect
	name = "Canine Aspect(Собачьи черты)"
	desc = "Гав! Кажется, ты почему-то ведёшь себя как собака. Это заменит большинство других речевых особенностей, связанных с языком."
	gain_text = span_notice("Б-.. бекон...")
	lose_text = span_notice("Вы меньше чувствуете себя брошенным.")
	mob_trait = TRAIT_CANINE
	icon = FA_ICON_DOG
	value = 0
	medical_record_text = "Пациента видели роющимся в мусорном баке. Следите за ним."

/datum/quirk/canine_aspect/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/organ/tongue/dog/new_tongue = new(get_turf(human_holder))

	new_tongue.copy_traits_from(human_holder.get_organ_slot(ORGAN_SLOT_TONGUE), human_holder)
	new_tongue.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/datum/quirk/canine_aspect/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/organ/tongue/new_tongue = new human_holder.dna.species.mutanttongue

	new_tongue.copy_traits_from(human_holder.get_organ_slot(ORGAN_SLOT_TONGUE), human_holder)
	new_tongue.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/datum/quirk/avian_aspect
	name = "Avian Aspect(Птичьи черты)"
	desc = "Вы — птичий мозг, или у вас птичий мозг. Это заменит большинство других особенностей речи, связанных с языком."
	gain_text = span_notice("БВАК... БВА-АК.. ОСТАВЬ ГАРНИТУРУ БВАК...")
	lose_text = span_notice("У вас меньше желания сидеть на яйцах.")
	mob_trait = TRAIT_AVIAN
	icon = FA_ICON_KIWI_BIRD
	value = 0
	medical_record_text = "Пациент проявляет манеры, свойственные птицам."

/datum/quirk/avian_aspect/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/organ/tongue/avian/new_tongue = new(get_turf(human_holder))

	new_tongue.copy_traits_from(human_holder.get_organ_slot(ORGAN_SLOT_TONGUE), human_holder)
	new_tongue.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/datum/quirk/avian_aspect/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/organ/tongue/new_tongue = new human_holder.dna.species.mutanttongue

	new_tongue.copy_traits_from(human_holder.get_organ_slot(ORGAN_SLOT_TONGUE), human_holder)
	new_tongue.Insert(human_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

#define SEVERITY_STUN 1
#define SEVERITY_SNEEZE 2
#define SEVERITY_KNOCKDOWN 3
#define SEVERITY_BLEP 4

GLOBAL_LIST_INIT(possible_snout_sensitivities, list(
	"Stun" = SEVERITY_STUN,
	"Sneeze" = SEVERITY_SNEEZE, //Includes a stun
	"Collapse" = SEVERITY_KNOCKDOWN,
	"Blep" = SEVERITY_BLEP,
))

/datum/quirk/sensitivesnout
	name = "Sensitive Snout (Чувствительная морда)"
	desc = "Твоя морда всегда была чувствительной, и тебе очень больно, когда его кто-то тыкает!"
	gain_text = span_notice("У тебя ужасно чувствительная морда.")
	lose_text = span_notice("Морда онемела.")
	medical_record_text = "У пациента, по-видимому, имеется скопление нервов на кончике носа, поэтому он не рекомендует контактировать с ним напрямую."
	value = 0
	mob_trait = TRAIT_SENSITIVESNOUT
	icon = FA_ICON_FINGERPRINT
	var/severity = SEVERITY_KNOCKDOWN
	COOLDOWN_DECLARE(emote_cooldown)

/datum/quirk_constant_data/sensitive_snout
	associated_typepath = /datum/quirk/sensitivesnout
	customization_options = list(/datum/preference/choiced/snout_sensitivity)

/datum/quirk/sensitivesnout/add(client/client_source)
	var/desired_severity = GLOB.possible_snout_sensitivities[client_source?.prefs?.read_preference(/datum/preference/choiced/snout_sensitivity)]
	severity = isnum(desired_severity) ? desired_severity : 1

/datum/quirk/sensitivesnout/proc/get_booped(attacker)
	var/can_emote = FALSE
	if(COOLDOWN_FINISHED(src, emote_cooldown))
		can_emote = TRUE
		COOLDOWN_START(src, emote_cooldown, 5 SECONDS)
	if (ishuman(quirk_holder) && can_emote)
		var/mob/living/carbon/human/human_holder = quirk_holder
		human_holder.force_say()
	switch(severity)
		if(SEVERITY_STUN)
			to_chat(quirk_holder, span_warning("[attacker] тычет тебя по вашему чувствительному носу, заставляя замереть на месте!"))
			quirk_holder.Stun(1 SECONDS)
		if(SEVERITY_SNEEZE)
			quirk_holder.Stun(1 SECONDS)
			if(can_emote)
				to_chat(quirk_holder, span_warning("[attacker] тычет по твоему чувствительному носу! Ты не можешь сдержать чихание!"))
				quirk_holder.emote("sneeze")
		if(SEVERITY_KNOCKDOWN)
			to_chat(quirk_holder, span_warning("[attacker] тычет тебя по чувствительному носу, и ты падаешь на землю!"))
			quirk_holder.Knockdown(1 SECONDS)
			quirk_holder.apply_damage(30, STAMINA)
		if(SEVERITY_BLEP)
			if(can_emote)
				to_chat(quirk_holder, span_warning("[attacker] тычет тебя по чувствительному носу! Ты рефлекторно высовываешь язык!"))
				quirk_holder.emote("blep")

#undef SEVERITY_STUN
#undef SEVERITY_SNEEZE
#undef SEVERITY_KNOCKDOWN
#undef SEVERITY_BLEP

/datum/quirk/overweight
	name = "Overweight(Избыточный вес)"
	desc = "Вы весите больше, чем среднестатистический человек вашего размера, вы уже к этому привыкли."
	gain_text = span_notice("Ваше тело кажется тяжелым.")
	lose_text = span_notice("Вы внезапно чувствуете себя легче!")
	value = 0
	icon = FA_ICON_HAMBURGER // I'm very hungry. Give me the burger!
	medical_record_text = "Я знаю пять толстых людей: четверо из них - этот пациент"
	mob_trait = TRAIT_OFF_BALANCE_TACKLER

/datum/quirk/overweight/add(client/client_source)
	quirk_holder.add_movespeed_modifier(/datum/movespeed_modifier/overweight)

/datum/quirk/overweight/remove()
	quirk_holder.remove_movespeed_modifier(/datum/movespeed_modifier/overweight)

/datum/movespeed_modifier/overweight
	multiplicative_slowdown = 0.5 //Around that of a dufflebag, enough to be impactful but not debilitating.

/datum/mood_event/fat/New(mob/parent_mob, ...)
	. = ..()
	if(HAS_TRAIT_FROM(parent_mob, TRAIT_OFF_BALANCE_TACKLER, QUIRK_TRAIT))
		mood_change = 0 // They are probably used to it, no reason to be viscerally upset about it.
		description = "<b>Я жирный....</b>"
