// === Визуальный предмет в руке во время принюхивания ===
/obj/item/hand_item/scent_focus
	name = "scent focus"
	icon = 'modular_nova/modules/organs/icons/cyber_tongue.dmi'
	icon_state = "cybertongue"
	inhand_icon_state = "nothing"
	flags_1 = NONE

/obj/item/hand_item/scent_focus/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/datum/action/cooldown/scent_scan/ability = locate(/datum/action/cooldown/scent_scan) in user.actions
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
/obj/item/hand_item/scent_focus/Destroy(force)
	if(ishuman(loc))
		var/mob/living/carbon/human/user = loc
		var/datum/action/cooldown/scent_scan/ability = locate(/datum/action/cooldown/scent_scan) in user.actions
		if(ability)
			ability.StartCooldown(2 SECONDS)
	return ..()

// ============================================================================
//  scent tracking system — full version
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

/datum/action/cooldown/scent_scan
	name = "Охотничий нюх"
	desc = "Таяры принюхиваются, улавливая кровь, волокна, отпечатки и частицы. Если найдены отпечатки — можно выследить носителя."
	button_icon = 'modular_nova/modules/organs/icons/cyber_tongue.dmi'
	button_icon_state = "cybertongue"
	cooldown_time = 6 SECONDS
	check_flags = AB_CHECK_CONSCIOUS

	var/list/sniffable_categories = list()

/datum/action/cooldown/scent_scan/Destroy()
	sniffable_categories = null
	return ..()

/datum/action/cooldown/scent_scan/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!H)
		return FALSE
	//Если игрок уже что-то держит
	if(!isnull(H.get_active_held_item()))
		return FALSE

	H.put_in_active_hand(new /obj/item/hand_item/scent_focus)
	return TRUE

// --- ОСНОВА СКАНА  ---
/datum/action/cooldown/scent_scan/proc/perform_scan(mob/living/carbon/human/H, atom/target)
	var/list/messages = list()
// ищем подходящую цель по отпечаткам (на этом же Z)
	var/list/clues_found = list()

	for(var/atom/A in get_turf(target))
		var/list/log_entry = gather_forensic_data(A)
		if(!LAZYLEN(log_entry))
			continue

		var/list/formatted = format_forensic_message(A, log_entry)
		if(LAZYLEN(formatted))
			messages += formatted

		var/datum/action/cooldown/scent_tracking/ability = locate(/datum/action/cooldown/scent_tracking) in H.actions

		var/list/prints = log_entry[DETSCAN_CATEGORY_FINGERS]
		if(LAZYLEN(prints) && ability)
			//Отдельное добавление списков нужно чтобы у игрока не пропадали новые запахи из-за старого таймера
			for(var/p in prints)
				if(istext(p) && !(p in clues_found))
					clues_found += p

		var/list/bloods = log_entry[DETSCAN_CATEGORY_BLOOD]
		if(LAZYLEN(bloods) && ability)
			for(var/blood in bloods)
				if(!(blood in clues_found))
					clues_found += blood
		if(LAZYLEN(clues_found))
			//Добавление в конец списка
			LAZYADD(ability.scent_targets, clues_found)
			addtimer(CALLBACK(ability, TYPE_PROC_REF(/datum/action/cooldown/scent_tracking, clear_tajaran_scent_target), LAZYLEN(clues_found) + 1), 30 SECONDS)

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
/datum/action/cooldown/scent_scan/proc/gather_forensic_data(atom/A)
	if(!A)
		return list()

	var/list/log_entry = list()

	// Волокна: используем макрос из кодовой базы
	if(DETSCAN_CATEGORY_FIBER in sniffable_categories)
		var/list/fibers = GET_ATOM_FIBRES(A)
		if(LAZYLEN(fibers))
			LAZYSET(log_entry, DETSCAN_CATEGORY_FIBER, fibers.Copy())

	// Кровь по DNA
	if(DETSCAN_CATEGORY_BLOOD in sniffable_categories)
		var/list/blood = GET_ATOM_BLOOD_DNA(A)
		if(LAZYLEN(blood))
			LAZYSET(log_entry, DETSCAN_CATEGORY_BLOOD, blood.Copy())

	// Отпечатки
	if(DETSCAN_CATEGORY_FINGERS in sniffable_categories)
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
	if(DETSCAN_CATEGORY_REAGENTS in sniffable_categories)
		if(A.reagents)
			for(var/datum/reagent/R as anything in A.reagents.reagent_list)
				if(!log_entry[DETSCAN_CATEGORY_REAGENTS])
					log_entry[DETSCAN_CATEGORY_REAGENTS] = list()
				log_entry[DETSCAN_CATEGORY_REAGENTS][R.name] = R.volume

	return log_entry

// --- Дебаг ФОРМАТИРОВАНИЕ ВЫВОДА ---
/datum/action/cooldown/scent_scan/proc/format_forensic_message(atom/A, list/log_entry)
	if(!LAZYLEN(log_entry))
		return null

	var/list/lines = list("<b>[A]</b>")

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
			blood_lines += "[t]"// ([t])
		lines += "&bull; Следы крови: [blood_lines.Join(", ")]"
/*
	// Отпечатки
	var/list/prints = log_entry[DETSCAN_CATEGORY_FINGERS]
	if(LAZYLEN(prints))
		lines += "&bull; Отпечатки: [prints.Join(", ")]"
*/
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
/datum/action/cooldown/scent_tracking
	name = "Нюх — След"
	desc = "Попробуй определить направление к запомненному запаху."
	background_icon_state = "bg_default"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "nose"
	cooldown_time = 2 SECONDS
	check_flags = AB_CHECK_CONSCIOUS
	var/list/scent_targets = list()
	var/mob/living/carbon/human/scent_target = null

/datum/action/cooldown/scent_tracking/PreActivate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!LAZYLEN(scent_targets))
		return FALSE
	//Общий список информации, который увидит игрок
	var/list/built_radial_list = list()
	if(!(scent_target in scent_targets))
		scent_target = null
	//Заготовка списка. Здесь можно обработать иконки и инфо штук
	for(var/clue in scent_targets)
		var/mob/living/carbon/human/human_target = find_best_target(H, clue)
		if(!human_target)
			continue
		var/datum/radial_menu_choice/option = new
		option.name = "[human_target.gender]"
		option.image = image(icon = 'icons/mob/actions/actions_items.dmi', icon_state = "bci_question")
		//Лишнее? Может будет проще для игрока заранее узнать как далеко цель
		option.info = get_scent_balloon(H, human_target)
		built_radial_list[human_target] = option

	scent_target = show_radial_menu(H, H, built_radial_list, radius = 42)
	if(!scent_target)
		return FALSE
	return ..()

// === Вызываем стрелку при активации нюха ===
/datum/action/cooldown/scent_tracking/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!H)
		return FALSE
	// ищем подходящую цель
	/*
	if(scent_target)
		to_chat(H, span_notice("Ты запоминаешь запах [scent_target.real_name]."))
	else
		to_chat(H, span_warning("Ты не можешь определить источник запаха."))
		return FALSE
*/
	var/mob/living/carbon/human/T = scent_target
	if(QDELETED(T))
		scent_target = null
		H.balloon_alert(H, "след пропал")
		return TRUE

	var/msg = get_scent_balloon(H, T)
	H.balloon_alert(H, msg)
	show_scent_arrow(H, T)
	StartCooldown()
	return TRUE

// --- ПОИСК ЖИВОЙ ЦЕЛИ ---
/datum/action/cooldown/scent_tracking/proc/find_best_target(mob/living/carbon/human/H, clue)
	if(!H || !clue)
		return null

	var/turf/tH = get_turf(H)
	for(var/mob/living/carbon/human/M as anything in GLOB.human_list)
		if(M == H || QDELETED(M) || M.stat == DEAD || !M.dna?.unique_identity)
			continue
		var/turf/tM = get_turf(M)
		if(!tM || !tH || tM.z != tH.z)
			continue
		//Отпечатки
		if(md5(M.dna.unique_identity) == clue)
			return M
		//Кровь игрока
		if(clue in M.get_blood_dna_list())
			return M
	return null

/datum/action/cooldown/scent_tracking/proc/clear_tajaran_scent_target(cut_up_to)
	if(!cut_up_to)
		return FALSE
	var/mob/living/carbon/human/H = owner

	scent_targets.Cut(1, cut_up_to)
	//Если нынешняя цель находится в удаляемом списке
	if(!(scent_target in scent_targets))
		scent_target = null
	H.balloon_alert(H, "следы выветрились")

// --- ПОДСКАЗКА НАПРАВЛЕНИЯ ---
/datum/action/cooldown/scent_tracking/proc/get_scent_balloon(mob/living/you, mob/living/them)
	var/turf/yt = get_turf(you)
	var/turf/tt = get_turf(them)
	if(!yt || !tt)
		return "не понятно где!"
	if(yt.z != tt.z)
		return "кажется на другом этаже!"
	var/dist = get_dist(yt, tt)
	var/d = get_dir(yt, tt)
	switch(dist)
		if(0 to 8)   return "очень близко, [dir2text(d)]!"
		if(9 to 16)  return "близко, [dir2text(d)]!"
		if(17 to 64) return "далеко, [dir2text(d)]!"
		else		 return "очень далеко!"

// === Визуальная стрелка направления запаха ===
// Цвет меняется в зависимости от дистанции.

/// Спавнит стрелку на экране игрока, указывающую на цель
/datum/action/cooldown/scent_tracking/proc/show_scent_arrow(mob/living/carbon/human/owner, mob/living/carbon/human/target)
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
		new /atom/movable/screen/navigate_arrow/scent(null, owner.hud_used, their_turf, arrow_color)


// Наш подтип стрелки
/atom/movable/screen/navigate_arrow/scent
	icon = 'icons/effects/96x96.dmi'
	name = "scent arrow"
	icon_state = "navigate_arrow_appear"
	pixel_x = -32
	pixel_y = -32
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
