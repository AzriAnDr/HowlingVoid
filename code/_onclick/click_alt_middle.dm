/mob/proc/AltMiddleClickOn(atom/target)
	target.AltMiddleClick(src)
	return

/atom/proc/AltMiddleClick(mob/living/carbon/user)
	try_jump(src, user)
	return

/atom/proc/try_jump(atom/target, mob/living/carbon/human/user)
	if(!ishuman(user) || !user.has_gravity() || user.stat != CONSCIOUS || user.body_position == LYING_DOWN || user.buckled)
		return

	for(var/obj/item/bodypart/leg/missing_limb as anything in user.get_missing_limbs())
		if(missing_limb in GLOB.leg_zones)
			to_chat(user, span_notice("I have no legs!"))
			user.emote("cry")
			return

	var/broke_nose = prob(40)
	var/jump_message = broke_nose ? "broke [user.p_their()] nose" : "hit [user.p_them()]self slightly"
	if(user.legcuffed)
		if(user.handcuffed)
			user.visible_message(span_alert("[user] tried to jump while being tied, fell, and [jump_message]."))
			if(broke_nose)
				user.adjust_stamina_loss(30)
				user.Paralyze(30)
				user.adjust_brute_loss(30)
				user.AdjustUnconscious(10 SECONDS)
				user.emote("scream")
				user.overlay_fullscreen("jump_flash", /atom/movable/screen/fullscreen/flash/black)
				sleep(6 SECONDS)
				user.clear_fullscreen("jump_flash", rand(15, 60))
				return
			user.adjust_stamina_loss(20)
			user.adjust_brute_loss(10)
			user.Paralyze(10)
			return
		user.visible_message(span_alert("[user] tried to jump with [user.p_their()] feet tied."))
		user.adjust_stamina_loss(20)
		user.Paralyze(10)
		return

	if(user.pulledby)
		to_chat(user, span_warning("I can't jump while I'm being pulled."))
		return

	if(user.pulling)
		to_chat(user, span_warning("I can't jump while I'm pulling someone."))
		return

	if(user.staminaloss >= 60)
		to_chat(user, span_warning("My legs really hurt..."))

	if(user.staminaloss >= 90)
		to_chat(user, span_notice("Tired muscles are unable to lift your body into the air, and you fall to the floor."))
		user.Paralyze(15)
		user.adjust_stamina_loss(10)
		return

	if(!HAS_TRAIT(user, TRAIT_MIMING))
		playsound(user, user.gender == MALE ? 'sound/effects/jump_male.ogg' : 'sound/effects/jump_female.ogg', 25, 0, 1)

	user.visible_message(span_danger("[user] jumps."), span_warning("I jump at [target]!"))
	user.adjust_stamina_loss(rand(30, 50))
	user.throw_at(target, 3, 1, user, spin = HAS_TRAIT(user, TRAIT_CLUMSY), force = MOVE_FORCE_EXTREMELY_WEAK, gentle = TRUE)
