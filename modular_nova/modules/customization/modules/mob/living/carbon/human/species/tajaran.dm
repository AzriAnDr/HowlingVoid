/datum/species/tajaran
	name = "Tajaran"
	id = SPECIES_TAJARAN
	//display_name = "Таяран"
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_HATED_BY_DOGS,
		TRAIT_MUTANT_COLORS,
		TRAIT_CATLIKE_GRACE,
		TRAIT_WATER_HATER,
		TRAIT_FELINE,
		TRAIT_SENSITIVE_HEARING,
		TRAIT_NIGHT_VISION,
		TRAIT_FREERUNNING,
		TRAIT_HARD_SOLES,
		TRAIT_SHARP_CLAWS,
	)
	mutanttongue = /obj/item/organ/tongue/cat/tajaran
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	// === Шерсть ===
	bodytemp_normal = 308
	bodytemp_cold_damage_limit = 238.15   // начинают мёрзнуть при -35°C
	bodytemp_heat_damage_limit = 325.15   // перегреваются при +52°C
	mutant_bodyparts = list()
	payday_modifier = 1.0
	species_language_holder = /datum/language_holder/tajaran
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	examine_limb_id = SPECIES_MAMMAL
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/mutant,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/mutant,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/mutant,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/mutant,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/mutant,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/mutant,
	)

/datum/species/tajaran/get_default_mutant_bodyparts()
	return list(
		"tail" = list("Cat (Big)", TRUE),
		"snout" = list("Mammal, Short", TRUE),
		"ears" = list("Cat, Alert", TRUE),
		"legs" = list("Normal Legs", FALSE),
	)

/obj/item/organ/tongue/cat/tajaran
	liked_foodtypes = GRAIN | MEAT
	disliked_foodtypes = CLOTH


/datum/species/tajaran/randomize_features()
	var/list/features = ..()
	var/main_color
	var/second_color
	var/random = rand(1,5)
	//Choose from a variety of mostly coldish, animal, matching colors
	switch(random)
		if(1)
			main_color = "#BBAA88"
			second_color = "#AAAA99"
		if(2)
			main_color = "#777766"
			second_color = "#888877"
		if(3)
			main_color = "#AA9988"
			second_color = "#AAAA99"
		if(4)
			main_color = "#EEEEDD"
			second_color = "#FFEEEE"
		if(5)
			main_color = "#DDCC99"
			second_color = "#DDCCAA"
	features["mcolor"] = main_color
	features["mcolor2"] = second_color
	features["mcolor3"] = second_color
	return features

/datum/species/tajaran/get_random_body_markings(list/passed_features)
	var/name = pick("Tajaran", "Floof", "Floofer")
	var/datum/body_marking_set/BMS = GLOB.body_marking_sets[name]
	var/list/markings = list()
	if(BMS)
		markings = assemble_body_markings_from_set(BMS, passed_features, src)
	return markings

/datum/species/tajaran/get_species_description()
	return placeholder_description

/datum/species/tajaran/get_species_lore()
	return list(placeholder_lore)

/datum/species/tajaran/prepare_human_for_preview(mob/living/carbon/human/cat)
	var/main_color = "#AA9988"
	var/second_color = "#AAAA99"

	cat.dna.features["mcolor"] = main_color
	cat.dna.features["mcolor2"] = second_color
	cat.dna.features["mcolor3"] = second_color
	cat.dna.mutant_bodyparts["snout"] = list(MUTANT_INDEX_NAME = "Mammal, Short", MUTANT_INDEX_COLOR_LIST = list(main_color, main_color, main_color))
	cat.dna.mutant_bodyparts["tail"] = list(MUTANT_INDEX_NAME = "Cat", MUTANT_INDEX_COLOR_LIST = list(second_color, main_color, main_color))
	cat.dna.mutant_bodyparts["ears"] = list(MUTANT_INDEX_NAME = "Cat, Alert", MUTANT_INDEX_COLOR_LIST = list(main_color, second_color, second_color))
	regenerate_organs(cat, src, visual_only = TRUE)
	cat.update_body(TRUE)


// Уворот от пуль
/datum/species/tajaran/proc/on_tajaran_bullet_hit(mob/living/carbon/human/tajaran, obj/projectile/hit_projectile)
	SIGNAL_HANDLER

	if(prob(25) && tajaran.stat == CONSCIOUS) //25% шанса, если цель всё еще жива и не в крите
		tajaran.visible_message(span_danger("[tajaran.get_visible_name()] [tajaran.gender == FEMALE ? "уклонилась" : "уклонился"] от пули!"))
		INVOKE_ASYNC(tajaran, TYPE_PROC_REF(/mob, emote), "jump")
		INVOKE_ASYNC(tajaran, TYPE_PROC_REF(/mob, emote), "hiss")
		playsound(tajaran.loc, "sound/items/weapons/effects/ric[rand(1, 5)]", 25, TRUE, -1)
		return PROJECTILE_INTERRUPT_HIT


// Зов месы
/datum/species/tajaran
	var/death_count = 0
	var/death_count_max = 8 // В результате ровно 9 смертей

/datum/species/tajaran/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	H.physiology.heat_mod *= 1.25
	H.physiology.cold_mod *= 0.81
	var/datum/action/cooldown/tajaran_scent_tracking/track = new()
	track.Grant(H)
	if(!H)
		return
	// === Счётчик смертей и уворот от пуль ===
	RegisterSignal(H, COMSIG_LIVING_DEATH, PROC_REF(on_tajaran_death))
	RegisterSignal(H, COMSIG_PROJECTILE_PREHIT, PROC_REF(on_tajaran_bullet_hit))
	RegisterSignal(H, COMSIG_LIVING_DODGE_MELEE, PROC_REF(tajaran_dodge_melee))

	// === Квирки (ночное зрение и фотофобия) ===
	if(!H.quirks)
		H.quirks = list()

	var/found_photophobia = FALSE
	var/found_nightvision = FALSE
	for(var/datum/quirk/Q in H.quirks)
		if(istype(Q, /datum/quirk/photophobia))
			found_photophobia = TRUE
		if(istype(Q, /datum/quirk/night_vision))
			found_nightvision = TRUE

	if(!found_photophobia)
		var/datum/quirk/photophobia/P = new()
		P.quirk_holder = H
		H.quirks += P
		P.add(H.client)

	if(!found_nightvision)
		var/datum/quirk/night_vision/N = new()
		N.quirk_holder = H
		H.quirks += N
		N.add(H.client)

	// === Способность слуха ===
	var/obj/item/organ/ears/ears = H.get_organ_slot(ORGAN_SLOT_EARS)
	if(ears)
		var/datum/action/cooldown/spell/teshari_hearing/hearing_action = new
		hearing_action.Grant(H)

	// === Способность вылизываться ===
	var/datum/action/cooldown/tajaran_grooming/G = new()
	G.Grant(H)

	// === Кошачий нюх ===
	var/datum/action/cooldown/tajaran_scent_scan/scent = new()
	scent.Grant(H)

/datum/species/tajaran/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()

	if(!H)
		return
	H.physiology.cold_mod /= 0.81
	H.physiology.heat_mod /= 1.25
	UnregisterSignal(H, list(COMSIG_LIVING_DEATH, COMSIG_PROJECTILE_PREHIT))

	var/obj/item/organ/ears/ears = H.get_organ_slot(ORGAN_SLOT_EARS)
	if(ears)
		ears.damage_multiplier = initial(ears.damage_multiplier)


// === Счётчик смертей ===
/datum/species/tajaran/proc/on_tajaran_death(mob/living/carbon/human/tajaran)
	SIGNAL_HANDLER
	death_count++
	if(death_count == death_count_max)
		to_chat(tajaran, span_danger("Ты чувствуешь, что это твоя последняя жизнь..."))
	if(death_count < death_count_max)
		return
	if(!HAS_TRAIT(tajaran, TRAIT_DNR))
		tajaran.visible_message(span_warning("[tajaran.get_visible_name()] исчерпал все свои жизни и больше не встанет."))
		ADD_TRAIT(tajaran, TRAIT_DNR, ADMIN_TRAIT)

/datum/species/tajaran/proc/tajaran_dodge_melee(mob/living/carbon/human/tajaran)
	SIGNAL_HANDLER

	if(prob(25))
		INVOKE_ASYNC(tajaran, TYPE_PROC_REF(/mob/living/carbon/human, emote), "jump")
		INVOKE_ASYNC(tajaran, TYPE_PROC_REF(/mob/living/carbon/human, emote), "hiss")
		return COMPONENT_DODGE_SUCCEEDED
	return COMPONENT_DODGE_FAILED

// === Вылизывание ===
/datum/action/cooldown/tajaran_grooming
	name = "Уход за собой"
	desc = "Ты вылизываешь шерсть, смывая кровь и грязь. Может остановить кровотечение и немного лечит."
	button_icon = 'modular_nova/modules/organs/icons/cyber_tongue.dmi'
	button_icon_state = "cybertongue"
	cooldown_time = 1 SECONDS

/datum/action/cooldown/tajaran_grooming/Activate(mob/living/carbon/human/H)
	if(!H)
		return

	H.visible_message(
		span_notice("[H] вылизывается!"),
		span_notice("Ты вылизываешься!")
	)
	if(!do_after(H, 15 SECONDS, H))
		if(H.gender == FEMALE)
			to_chat(H, span_warning("Ты отвлеклась и перестала вылизываться..."))
		else
			to_chat(H, span_warning("Ты отвлёкся и перестал вылизываться..."))
		return

	H.wash(CLEAN_TYPE_BLOOD)
	var/heal_brute = 1
	var/heal_burn = 0
	var/obj/item/bodypart/target_BP = H.get_bodypart(H.zone_selected)
	if(target_BP)
		if(target_BP.heal_damage(heal_brute, heal_burn))
			H.update_damage_overlays()
		if(target_BP.wounds)
			for(var/datum/wound/W in target_BP.wounds)
				if(W.blood_flow > 0 && prob(45))
					W.blood_flow = 0

	var/self_msg = ""
	var/around_msg = ""
	if(H.gender == FEMALE)
		self_msg = "Ты вылизалась!"
		around_msg = "[H] вылизалась!"
	else
		self_msg = "Ты вылизался!"
		around_msg = "[H] вылизался!"

	H.visible_message(span_notice(around_msg), span_notice(self_msg))

// === Визуальный предмет в руке во время принюхивания ===
/obj/item/hand_item/tajaran_scent_focus
	name = "scent focus"
	icon = 'modular_nova/modules/organs/icons/cyber_tongue.dmi'
	icon_state = "cybertongue"
	inhand_icon_state = "nothing"
	flags_1 = NONE

/obj/item/hand_item/tajaran_scent_focus/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/datum/action/cooldown/tajaran_scent_scan/ability = locate(/datum/action/cooldown/tajaran_scent_scan) in user.actions
	if(ability)
		if(get_dist(get_turf(interacting_with), get_turf(user)) > 1)
			to_chat(user, span_warning("Слишком далеко, чтобы уловить запах."))
			ability.StartCooldown(3 SECONDS)
		else
			user.visible_message(
			span_notice("[user] принюхивается к [interacting_with], вдыхая запахи."),
			span_notice("Ты принюхиваешься к [interacting_with]...")
			)

			if(!do_after(user, 2.5 SECONDS, user, max_interact_count = 1))
				to_chat(user, span_warning("Ты теряешь след."))
				ability.StartCooldown(2 SECONDS)
			else
				ability.perform_scan(user, interacting_with)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

//Прок в случае потери нюхала каким либо образом
/obj/item/hand_item/tajaran_scent_focus/Destroy(force)
	if(ishuman(loc))
		var/mob/living/carbon/human/user = loc
		var/datum/action/cooldown/tajaran_scent_scan/ability = locate(/datum/action/cooldown/tajaran_scent_scan) in user.actions
		if(ability)
			ability.StartCooldown(2 SECONDS)
	return ..()

// ============================================================================
// Tajaran scent tracking system — full version
// ============================================================================
/*
// === forensic defines ===
#define DETSCAN_CATEGORY_FIBER     "fibers"
#define DETSCAN_CATEGORY_BLOOD     "blood"
#define DETSCAN_CATEGORY_FINGERS   "prints"
#define DETSCAN_CATEGORY_REAGENTS  "reagents"
*/

// ============================================================================
// === SCENT SCAN ABILITY ===
// ============================================================================

/datum/action/cooldown/tajaran_scent_scan
	name = "Охотничий нюх"
	desc = "Таяры принюхиваются, улавливая кровь, волокна, отпечатки и частицы. Если найдены отпечатки — можно выследить носителя."
	button_icon = 'modular_nova/modules/organs/icons/cyber_tongue.dmi'
	button_icon_state = "cybertongue"
	cooldown_time = 6 SECONDS
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/cooldown/tajaran_scent_scan/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!H)
		return FALSE
	//Если игрок уже что-то держит
	if(!isnull(H.get_active_held_item()))
		return FALSE

	H.put_in_active_hand(new /obj/item/hand_item/tajaran_scent_focus)
	return TRUE

// --- ОСНОВА СКАНА  ---
/datum/action/cooldown/tajaran_scent_scan/proc/perform_scan(mob/living/carbon/human/H, atom/target)
	var/list/messages = list()
// ищем подходящую цель по отпечаткам (на этом же Z)
	var/list/fingerprints_found = list()

	for(var/atom/A in get_turf(target))
		var/list/log_entry = gather_forensic_data(A)
		if(!LAZYLEN(log_entry))
			continue

		var/list/formatted = format_forensic_message(A, log_entry)
		if(LAZYLEN(formatted))
			messages += formatted

		var/datum/action/cooldown/tajaran_scent_tracking/ability = locate(/datum/action/cooldown/tajaran_scent_tracking) in H.actions

		var/list/prints = log_entry[DETSCAN_CATEGORY_FINGERS]
		if(LAZYLEN(prints) && ability)
			//Отдельное добавление списков нужно чтобы у игрока не пропадали новые запахи из-за старого таймера
			for(var/p in prints)
				if(istext(p) && !(p in fingerprints_found))
					fingerprints_found += p
			if(LAZYLEN(fingerprints_found))
				//Добавление в конец списка
				LAZYADD(ability.scent_targets, fingerprints_found)
				addtimer(CALLBACK(ability, TYPE_PROC_REF(/datum/action/cooldown/tajaran_scent_tracking, clear_tajaran_scent_target), LAZYLEN(fingerprints_found) + 1), 30 SECONDS)

	if(!LAZYLEN(messages))
		to_chat(H, span_notice("Ты не чуешь ничего особенного."))
	else
		H.balloon_alert(H, "запах уловлен")
		to_chat(H, span_notice("<b>Ты улавливаешь запахи вокруг:</b>"))
		for(var/line in messages)
			to_chat(H, span_info(line))

	StartCooldown()
	return TRUE

// --- СБОР ДАННЫХ ---
/datum/action/cooldown/tajaran_scent_scan/proc/gather_forensic_data(atom/A)
    if(!A)
        return list()

    var/list/log_entry = list()

    // Волокна: используем макрос из кодовой базы
    var/list/fibers = GET_ATOM_FIBRES(A)
    if(LAZYLEN(fibers))
        LAZYSET(log_entry, DETSCAN_CATEGORY_FIBER, fibers.Copy())

    // Кровь по DNA
    var/list/blood = GET_ATOM_BLOOD_DNA(A)
    if(LAZYLEN(blood))
        LAZYSET(log_entry, DETSCAN_CATEGORY_BLOOD, blood.Copy())

    // Отпечатки
    if(ishuman(A))
        var/mob/living/carbon/human/H = A
        if(!H.gloves && H.dna && H.dna.unique_identity)
            var/fp = md5(H.dna.unique_identity)
            if(fp)
                LAZYSET(log_entry, DETSCAN_CATEGORY_FINGERS, list(fp))
    else if(!ismob(A))
        var/list/prints = GET_ATOM_FINGERPRINTS(A)
        if(LAZYLEN(prints))
            LAZYSET(log_entry, DETSCAN_CATEGORY_FINGERS, prints.Copy())

    // Реагенты
    if(A.reagents)
        for(var/datum/reagent/R as anything in A.reagents.reagent_list)
            if(!log_entry[DETSCAN_CATEGORY_REAGENTS])
                log_entry[DETSCAN_CATEGORY_REAGENTS] = list()
            log_entry[DETSCAN_CATEGORY_REAGENTS][R.name] = R.volume

    return log_entry

// --- ФОРМАТИРОВАНИЕ ВЫВОДА ---
/datum/action/cooldown/tajaran_scent_scan/proc/format_forensic_message(atom/A, list/log_entry)
    if(!LAZYLEN(log_entry))
        return null

    var/list/lines = list("<b>\\The [A]</b>")

    // Волокна
    var/list/fibers = log_entry[DETSCAN_CATEGORY_FIBER]
    if(LAZYLEN(fibers))
        lines += "&bull; Волокна: [english_list(fibers)]"

    // Кровь
    var/list/blood_data = log_entry[DETSCAN_CATEGORY_BLOOD]
    if(LAZYLEN(blood_data))
        var/list/blood_lines = list()
        for(var/id in blood_data)
            var/t = blood_data[id] || "неизвестно"
            blood_lines += "[id] ([t])"
        lines += "&bull; Следы крови: [blood_lines.Join(", ")]"

    // Отпечатки
    var/list/prints = log_entry[DETSCAN_CATEGORY_FINGERS]
    if(LAZYLEN(prints))
        lines += "&bull; Отпечатки: [prints.Join(", ")]"

    // Частицы (реагенты)
    var/list/reagents = log_entry[DETSCAN_CATEGORY_REAGENTS]
    if(LAZYLEN(reagents))
        var/list/rl = list()
        for(var/rname in reagents)
            var/amt = reagents[rname]
            rl += "[rname] ([round(amt, 0.1)]u)"
        lines += "&bull; Частицы: [rl.Join(", ")]"

    return lines



// === СПОСОБНОСТЬ ДЛЯ ОТСЛЕЖИВАНИЯ ===
/datum/action/cooldown/tajaran_scent_tracking
	name = "Нюх — След"
	desc = "Попробуй определить направление к запомненному запаху."
	background_icon_state = "bg_default"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "nose"
	cooldown_time = 2 SECONDS
	check_flags = AB_CHECK_CONSCIOUS
	var/list/scent_targets = list()
	var/mob/living/carbon/human/scent_target = null

/datum/action/cooldown/tajaran_scent_tracking/PreActivate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!LAZYLEN(scent_targets))
		return FALSE
	//Общий список информации, который увидит игрок
	var/list/built_radial_list = list()
	//Список для ссылки на оригинальные цели, чтобы достать их из списка сверху
	var/list/name2subtype = list()
	if(!(scent_target in scent_targets))
		scent_target = null
	//Заготовка списка. Здесь можно обработать иконки и инфо штук
	for(var/fingerprints in scent_targets)
		var/mob/living/carbon/human/human_target = find_best_target(H, fingerprints)
		if(!human_target)
			continue
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = 'icons/mob/actions/actions_items.dmi', icon_state = "bci_question")
		//Лишнее? Может будет проще для игрока заранее узнать как далеко цель
		option.info = get_tajaran_scent_balloon(H, human_target)
		name2subtype[initial(human_target.name)] = human_target
		built_radial_list += list(initial(human_target.name) = option)

	scent_target = name2subtype[show_radial_menu(H, H, built_radial_list, radius = 42)]
	if(!scent_target)
		return FALSE
	return ..()

// === Вызываем стрелку при активации нюха ===
/datum/action/cooldown/tajaran_scent_tracking/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!H)
		return FALSE
	// ищем подходящую цель
	if(scent_target)
		to_chat(H, span_notice("Ты запоминаешь запах [scent_target.real_name]."))
	else
		to_chat(H, span_warning("Ты не можешь определить источник запаха."))
		return FALSE

	var/mob/living/carbon/human/T = scent_target
	if(QDELETED(T))
		scent_target = null
		H.balloon_alert(H, "след пропал")
		return TRUE

	var/msg = get_tajaran_scent_balloon(H, T)
	H.balloon_alert(H, msg)
	show_tajaran_scent_arrow(H, T)
	StartCooldown()
	return TRUE

// --- ПОИСК ЖИВОЙ ЦЕЛИ ---
/datum/action/cooldown/tajaran_scent_tracking/proc/find_best_target(mob/living/carbon/human/H, fingerprint)
    if(!H || !fingerprint)
        return null

    var/turf/tH = get_turf(H)

    for(var/mob/living/carbon/human/M as anything in GLOB.human_list)
        if(M == H || QDELETED(M) || M.stat == DEAD || !M.dna?.unique_identity)
            continue
        var/turf/tM = get_turf(M)
        if(!tM || !tH || tM.z != tH.z)
            continue
        if(md5(M.dna.unique_identity) == fingerprint)
            return M
    return null

/datum/action/cooldown/tajaran_scent_tracking/proc/clear_tajaran_scent_target(cut_up_to)
	if(!cut_up_to)
		return FALSE
	var/mob/living/carbon/human/H = owner

	scent_targets.Cut(1, cut_up_to)
	//Если нынешняя цель находится в удаляемом списке
	if(!(scent_target in scent_targets))
		scent_target = null
	H.balloon_alert(H, "следы выветрились")

// --- ПОДСКАЗКА НАПРАВЛЕНИЯ ---
/datum/action/cooldown/tajaran_scent_tracking/proc/get_tajaran_scent_balloon(mob/living/you, mob/living/them)
	var/turf/yt = get_turf(you)
	var/turf/tt = get_turf(them)
	if(!yt || !tt)
		return "в другом секторе!"
	if(yt.z != tt.z)
		return "непонятно где!"
	var/dist = get_dist(yt, tt)
	var/d = get_dir(yt, tt)
	switch(dist)
		if(0 to 8)   return "очень близко, [dir2text(d)]!"
		if(9 to 16)  return "близко, [dir2text(d)]!"
		if(17 to 64) return "далеко, [dir2text(d)]!"
		else         return "очень далеко!"

// === Визуальная стрелка направления запаха ===
// Цвет меняется в зависимости от дистанции.

/// Спавнит стрелку на экране игрока, указывающую на цель
/datum/action/cooldown/tajaran_scent_tracking/proc/show_tajaran_scent_arrow(mob/living/carbon/human/owner, mob/living/carbon/human/target)
    if(!owner || !target) return
    var/turf/our_turf = get_turf(owner)
    var/turf/their_turf = get_turf(target)
    if(!our_turf || !their_turf || our_turf.z != their_turf.z) return

    var/dist = get_dist(our_turf, their_turf)
    var/arrow_color = COLOR_YELLOW
    switch(dist)
        if(0 to 8)    arrow_color = COLOR_GREEN
        if(9 to 16)   arrow_color = COLOR_YELLOW
        if(17 to 64)  arrow_color = COLOR_ORANGE
        else          arrow_color = COLOR_RED

    if(owner.hud_used)
        new /atom/movable/screen/navigate_arrow/tajaran(null, owner.hud_used, their_turf, arrow_color)


// Наш подтип стрелки
/atom/movable/screen/navigate_arrow/tajaran
    icon = 'icons/effects/96x96.dmi'
    name = "scent arrow"
    icon_state = "navigate_arrow_appear"
    pixel_x = -32
    pixel_y = -32
    mouse_opacity = MOUSE_OPACITY_TRANSPARENT


/atom/movable/screen/navigate_arrow/tajaran/Initialize(mapload, datum/hud/hud_owner, turf/tracked_turf, arrow_color)
    . = ..()
    var/mob/O = get_mob()
    if(O)
        animate(src, transform = matrix(get_angle(O, tracked_turf), MATRIX_ROTATE), 0.2 SECONDS)
    screen_loc = around_player
    color = arrow_color
    if(hud_owner)
        hud_owner.infodisplay += src
        hud_owner.show_hud(hud_owner.hud_version)
    addtimer(CALLBACK(src, PROC_REF(end_effect_tajaran)), 1.6 SECONDS)

/atom/movable/screen/navigate_arrow/tajaran/proc/end_effect_tajaran()
    icon_state = "navigate_arrow_disappear"
    addtimer(CALLBACK(src, PROC_REF(null_arrow_tajaran)), 0.4 SECONDS)

/atom/movable/screen/navigate_arrow/tajaran/proc/null_arrow_tajaran()
    if(hud)
        hud.infodisplay -= src
        hud.show_hud(hud.hud_version)
    qdel(src)








/datum/species/tajaran/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "grin-tongue",
			SPECIES_PERK_NAME = "Уход за собой",
			SPECIES_PERK_DESC = "Таяры могут зализывать раны, чтобы избавиться от кровотечения, а так же смывать с себя кровь.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_EYE_DROPPER,
			SPECIES_PERK_NAME = "Таярский глаз",
			SPECIES_PERK_DESC = "Таяры видят в темноте лучше, чем люди, но яркий свет их слепит лучше.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_CAT,
			SPECIES_PERK_NAME = "Инстинкт охотника",
			SPECIES_PERK_DESC = "Таяры обладают очень хорошей реакцией. Они имеют шанс уклониться от любой атаки.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_HEADPHONES_SIMPLE,
			SPECIES_PERK_NAME = "Чуткий слух",
			SPECIES_PERK_DESC = "Таяры лучше слышат. Вы можете слышать даже самые тихие звуки, но из-за этого повышается риск повреждения слуха.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_HEADPHONES_SIMPLE,
			SPECIES_PERK_NAME = "Охотничий нюх",
			SPECIES_PERK_DESC = "У таяр - отменный нюх. Вы можете принюхаться, чтобы найти свежие следы поблизости и отследить носителя отпечатков!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_LINES_LEANING,
			SPECIES_PERK_NAME = "Острые когти",
			SPECIES_PERK_DESC = "У вас очень острые когти, которые с большей вероятностью нанесут кровоточащую рану при атаке.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_RUNNING,
			SPECIES_PERK_NAME = "Природная ловкость",
			SPECIES_PERK_DESC = "Вы быстрее и легче лазаете по препятствиям, а так же комфортно себя чувствуете без обуви.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_ANGRY,
			SPECIES_PERK_NAME = "Шерсть",
			SPECIES_PERK_DESC = "Вы хорошо переносите холод, но вам тяжело в жару. Интересный факт, а вы знали что шерсть хорошо горит? :)",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_PERSON_FALLING,
			SPECIES_PERK_NAME = "Мягкая посадка",
			SPECIES_PERK_DESC = "Таяры не страдают от падений с высоты и приземляются на ноги.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_ANGRY,
			SPECIES_PERK_NAME = "Кусаца :3",
			SPECIES_PERK_DESC = "Таяры могут кусаться.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shower",
			SPECIES_PERK_NAME = "Гидрофобия",
			SPECIES_PERK_DESC = "Таяры не любят воду и получают дискомфорт, будучи мокрыми.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_ANGRY,
			SPECIES_PERK_NAME = "Девять жизней",
			SPECIES_PERK_DESC = "Таяры имеют девять жизней. Когда жизни заканчиваются, смерть становится постоянной.",
		),
	)


	return to_add
