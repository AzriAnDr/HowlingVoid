#define JUMP_MESSAGE_NOSE "broke his nose"
#define JUMP_MESSAGE_HIT "hit self slightly"

/atom/proc/try_jump(atom/target, mob/living/carbon/human/user)
	if(!isliving(user) || !ishuman(user) || !user.has_gravity() || !user.Adjacent(user) || !(user.stat == CONSCIOUS) || user.body_position == LYING_DOWN || user.buckled) // ТЫ ЕБЛАН?
		return

	var/jump_message = prob(40) ? JUMP_MESSAGE_NOSE : JUMP_MESSAGE_HIT

	if(QDELETED(src) || QDELETED(user)) // ТЫ НЕ СУЩЕСТВУЕШЬ, ЕБЛИЩЕ.
		return

	for(var/obj/item/bodypart/leg/missing_limb as anything in user.get_missing_limbs())
		if(missing_limb in GLOB.leg_zones) // Проверка на ноги. Нехуй прыгать инвалидам.
			to_chat(user, span_notice("I have no legs!"))
			user.emote("cry") // НУ ЗАПЛАЧЬ.
			return

	if(user.legcuffed) // Если Ноги связаны (Болой к примеру)
		if(user.handcuffed) // А если ещё и руки.
			user.visible_message(span_alert("[user] had tried to jump while being tied, so [user.p_they()] fell and [jump_message]."))
			if(jump_message == JUMP_MESSAGE_NOSE) // Если зарандомил ломание носа.
				user.adjust_stamina_loss(30)
				user.Paralyze(30)
				user.adjust_brute_loss(30)
				user.AdjustUnconscious(10 SECONDS)
				user.emote("scream")
				user.overlay_fullscreen("flash_void", /atom/movable/screen/fullscreen/flash/black)
				sleep(6 SECONDS)
				user.clear_fullscreen("flash_void", rand(15, 60))
				return
			else // Повезло просто удариться.
				user.adjust_stamina_loss(20)
				user.adjust_brute_loss(10)
				user.Paralyze(10)
				return
		user.visible_message(span_alert("[user] tried to jump with [user.p_their()] feet tied."))
		user.adjust_stamina_loss(20)
		user.Paralyze(10)
		return

// Проверки на Пуллы
	if(user.pulledby)
		to_chat(user, span_warning("I can't jump while I'm being pulled."))
		return

	if(user.pulling)
		to_chat(user, span_warning("I can't jump while I'm pulling someone."))
		return
//

	if(user.staminaloss >= 60) // ПРЕДУПРЕЖДАЕМ ЧТО НЕКСТ ПРЫЖОК 100% БУДЕТ ЛЕЖАЧИМ.
		to_chat(user, span_warning("My legs really hurt..."))

	if(user.staminaloss >= 90) // ПЕРЕПРЫГАЛ? ПОЛУЧАЙ НАХУЙ ИНСУЛЬТ.
		to_chat(user, span_notice("Tired muscles are unable to lift your carcass into the air and you fall to the floor."))
		user.Paralyze(15)
		user.adjust_stamina_loss(10)

	if(!HAS_TRAIT(user, TRAIT_MIMING))
		playsound(user, user.gender == MALE ? 'modular_HV/modules/ported_content/ark_station/now-we-can-jump/jump_male.ogg' : 'modular_HV/modules/ported_content/ark_station/now-we-can-jump/jump_female.ogg', 25, 0, 1)
	user.visible_message("<span class='danger'>[user] jumps.</span>", \
					"<span class='warning'> I jump at the [loc]!</span>")
	user.adjust_stamina_loss(rand(30,50))
	user.throw_at(target, 3, 1, user, spin = (HAS_TRAIT(user, TRAIT_CLUMSY) ? TRUE : FALSE), force = MOVE_FORCE_EXTREMELY_WEAK, gentle = TRUE)

#undef JUMP_MESSAGE_NOSE
#undef JUMP_MESSAGE_HIT
