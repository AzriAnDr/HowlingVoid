/obj/structure/destructible/clockwork/gear_base/stargazer
	name = "stargazer"
	desc = "A small pedestal glowing with divine energy."
	clockwork_desc = "Place a weapon or protective garment upon it to grant a simple clockwork enchantment."
	icon_state = "stargazer"
	anchored = TRUE
	break_message = span_warning("The stargazer collapses.")
	var/obj/effect/stargazer_light/light_effect
	var/stargazer_cooldown = 3 MINUTES
	COOLDOWN_DECLARE(use_cooldown)

/obj/structure/destructible/clockwork/gear_base/stargazer/Initialize(mapload)
	. = ..()
	light_effect = new(get_turf(src))
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/clockwork/gear_base/stargazer/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(light_effect)
	return ..()

/obj/structure/destructible/clockwork/gear_base/stargazer/process(seconds_per_tick)
	if(QDELETED(light_effect))
		return
	for(var/mob/living/viewing_mob in viewers(2, get_turf(src)))
		if(IS_CLOCK(viewing_mob))
			if(!light_effect.is_open)
				light_effect.open()
			return
	if(light_effect.is_open)
		light_effect.close()

/obj/structure/destructible/clockwork/gear_base/stargazer/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!.)
		return
	if(anchored && !light_effect)
		light_effect = new(get_turf(src))
	else if(light_effect)
		QDEL_NULL(light_effect)

/obj/structure/destructible/clockwork/gear_base/stargazer/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!IS_CLOCK(user))
		return ..()
	if(!anchored)
		to_chat(user, span_brass("You need to anchor \the [src] to the floor first."))
		return
	if(!enchanting_checks(attacking_item, user))
		return

	to_chat(user, span_brass("You begin placing \the [attacking_item] onto [src]."))
	if(!do_after(user, 6 SECONDS, src))
		return
	if(!enchanting_checks(attacking_item, user))
		return
	if(upgrade_item(attacking_item, user))
		COOLDOWN_START(src, use_cooldown, stargazer_cooldown)
		return
	to_chat(user, span_brass("You cannot upgrade \the [attacking_item]."))

/obj/structure/destructible/clockwork/gear_base/stargazer/proc/enchanting_checks(obj/item/checked_item, mob/living/user)
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		to_chat(user, span_brass("\The [src] is still warming up; it will be ready in [DisplayTimeText(COOLDOWN_TIMELEFT(src, use_cooldown))]."))
		return FALSE
	if(HAS_TRAIT(checked_item, TRAIT_STARGAZED))
		to_chat(user, span_brass("\The [checked_item] has already been enchanted!"))
		return FALSE
	return TRUE

/obj/structure/destructible/clockwork/gear_base/stargazer/proc/upgrade_item(obj/item/upgraded_item, mob/living/user)
	if(!istype(upgraded_item, /obj/item/clothing) && !upgraded_item.force)
		return FALSE

	ADD_TRAIT(upgraded_item, TRAIT_STARGAZED, STARGAZER_TRAIT)
	upgraded_item.add_atom_colour(rgb(243, 227, 183), ADMIN_COLOUR_PRIORITY)
	upgraded_item.name = "stargazed [upgraded_item.name]"
	if(upgraded_item.force)
		upgraded_item.force += 5
		upgraded_item.throwforce += 3
	else if(istype(upgraded_item, /obj/item/clothing))
		upgraded_item.AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY)
	to_chat(user, span_notice("\The [upgraded_item] glows with a brilliant light!"))
	return TRUE

/obj/effect/stargazer_light
	icon = 'modular_nova/modules/clock_cult/icons/clockwork_objects.dmi'
	icon_state = "stargazer_closed"
	pixel_y = 10
	layer = ABOVE_OBJ_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 160
	var/is_open = FALSE
	var/active_timer

/obj/effect/stargazer_light/ex_act()
	return

/obj/effect/stargazer_light/Destroy(force)
	cancel_timer()
	return ..()

/obj/effect/stargazer_light/proc/finish_opening()
	icon_state = "stargazer_light"
	active_timer = null

/obj/effect/stargazer_light/proc/finish_closing()
	icon_state = "stargazer_closed"
	active_timer = null

/obj/effect/stargazer_light/proc/open()
	icon_state = "stargazer_opening"
	cancel_timer()
	active_timer = addtimer(CALLBACK(src, PROC_REF(finish_opening)), 2, TIMER_STOPPABLE | TIMER_UNIQUE)
	is_open = TRUE

/obj/effect/stargazer_light/proc/close()
	icon_state = "stargazer_closing"
	cancel_timer()
	active_timer = addtimer(CALLBACK(src, PROC_REF(finish_closing)), 2, TIMER_STOPPABLE | TIMER_UNIQUE)
	is_open = FALSE

/obj/effect/stargazer_light/proc/cancel_timer()
	if(active_timer)
		deltimer(active_timer)
		active_timer = null
