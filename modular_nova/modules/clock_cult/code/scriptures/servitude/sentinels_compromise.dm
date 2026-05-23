#define HEALED_PER_LOOP 10

/datum/scripture/slab/sentinels_compromise
	name = "Sentinel's Compromise"
	desc = "Continuously heals non-toxin damage on a clock servant, then converts part of the healed damage into toxin damage on you."
	tip = "Heal a servant at a cost."
	power_cost = STANDARD_CELL_CHARGE * 0.15
	cogs_required = 1
	invocation_time = 1 SECONDS
	invocation_text = list("By the light of the Engine...")
	button_icon_state = "Sentinel's Compromise"
	category = SPELLTYPE_SERVITUDE
	slab_overlay = "compromise"
	use_time = 15 SECONDS
	recital_sound = 'sound/effects/magic/magic_missile.ogg'

/datum/scripture/slab/sentinels_compromise/check_special_requirements(mob/user)
	if(issilicon(user))
		invocation_time = 10 * initial(invocation_time)
	else
		invocation_time = initial(invocation_time)

	return ..()

/datum/scripture/slab/sentinels_compromise/apply_effects(mob/living/healed_mob)
	if(!istype(healed_mob) || !IS_CLOCK(invoker) || !IS_CLOCK(healed_mob))
		return FALSE

	if(istype(invoker, /mob/living/basic/drone/cogscarab))
		to_chat(invoker, span_warning("Your form is too frail to take the burden of another."))
		return FALSE

	if(!do_after(invoker, invocation_time, target = healed_mob))
		return FALSE

	healed_mob.cure_husk()
	if(healed_mob.stat == DEAD)
		return FALSE

	healed_mob.blood_volume = BLOOD_VOLUME_NORMAL
	healed_mob.set_nutrition(NUTRITION_LEVEL_FULL)
	healed_mob.bodytemperature = BODYTEMP_NORMAL

	if(apply_heal(healed_mob))
		while(do_after(invoker, invocation_time, target = healed_mob))
			if(!apply_heal(healed_mob))
				break

	clockwork_say(invoker, "Wounds will close.", TRUE)
	new /obj/effect/temp_visual/heal(get_turf(healed_mob), "#1E8CE1")
	return TRUE

/datum/scripture/slab/sentinels_compromise/proc/apply_heal(mob/living/healed_mob)
	var/healed_amount = healed_mob.heal_ordered_damage(HEALED_PER_LOOP, list(BRUTE, BURN, OXY, BRAIN))
	healed_mob.adjust_stamina_loss(-HEALED_PER_LOOP)
	healed_mob.reagents?.remove_reagent(/datum/reagent/water/holywater, HEALED_PER_LOOP)

	if(!healed_amount)
		return FALSE

	invoker.adjust_tox_loss(healed_amount * 0.8, forced = TRUE)
	if(invoker.get_tox_loss() > 80 || healed_amount < HEALED_PER_LOOP)
		return FALSE

	return TRUE

#undef HEALED_PER_LOOP
