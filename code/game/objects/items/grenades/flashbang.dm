/obj/item/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	possible_fuse_time = list("3", "4", "5")
	//how many tiles away the mob will be affected by the flashbang.
	var/flashbang_range = 7
	//The devision for the sweetspot culations. if set to 1, the sweetspot is ostensibly the flashbang range.
	var/sweetspot_divider = 3
	//The light emitted by this flashbang to indicate the sweetspot.
	var/flashbang_light = LIGHT_COLOR_INTENSE_RED

/obj/item/grenade/flashbang/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/grenade/flashbang/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!is_currently_forbidden(user))
		return

	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Break Company Policy! There will be consequences..."
	return CONTEXTUAL_SCREENTIP_SET

/// If the company policy currently forbids flashbangs during green alert.
/obj/item/grenade/flashbang/proc/is_currently_forbidden(mob/user)
	if(!CONFIG_GET(flag/flashbangs_forbidden_during_green))
		return FALSE

	if(SSsecurity_level.get_current_level_as_number() != SEC_LEVEL_GREEN)
		return FALSE

	if(!(user.mind?.assigned_role.departments_bitflags & (DEPARTMENT_BITFLAG_SECURITY|DEPARTMENT_BITFLAG_COMMAND)))
		return FALSE

	return TRUE

// Security members are not supposed to use flashbangs during green alert, as per company policy.
// Disobeying this policy will result in IC consequences.
/obj/item/grenade/flashbang/attack_self(mob/user, modifiers, breaking_policy = FALSE)
	if(active || HAS_TRAIT(src, TRAIT_NODROP) || !is_currently_forbidden(user))
		return ..()

	if(breaking_policy)
		var/crew_to_alert = list(
			JOB_CAPTAIN,
			JOB_WARDEN,
			JOB_DETECTIVE,
			JOB_HEAD_OF_SECURITY,
		)
		var/message = "<span class='doyourjobidiot'><b>\n\nWARNING: Breach of company policy detected!:</b></span>\n\n[user], \
		<b>[user.mind?.assigned_role.title]</b> has armed a flashbang during security level green! \
		This is a violation of corporate regulations, and should be investigated immediately."
		silent_alert(user, src, crew_to_alert, message)
		return ..()

	to_chat(user, span_doyourjobidiot("The use of flashbangs when the security level is green is a violation of company policy!\nTo \
	bypass this restriction and arm the flashbang anyway, CTRL + Click it (be prepared to have a good reason for doing this!)."))

// CTRL + Click to willingly bypass the green alert restriction.
/obj/item/grenade/flashbang/item_ctrl_click(mob/user)
	attack_self(user, breaking_policy = TRUE)
	return CLICK_ACTION_SUCCESS

/// Sends a silent alert message to certain crew members' PDAs.
/proc/silent_alert(mob/sender, atom/source, crew_to_alert, message)
	var/list/base_title_by_alt_title = list()
	for(var/job_title in crew_to_alert)
		var/datum/job/job_datum = SSjob.get_job(job_title)
		for(var/alt_job_title in job_datum.alt_titles)
			base_title_by_alt_title[alt_job_title] = job_title

	for(var/messenger_ref in GLOB.pda_messengers)
		var/datum/computer_file/program/messenger/messenger = GLOB.pda_messengers[messenger_ref]
		if(!length(crew_to_alert))
			break
		if(sender.name == messenger.computer.saved_identification)
			continue
		if(!(base_title_by_alt_title[messenger.computer.saved_job] in crew_to_alert))
			continue

		var/datum/signal/subspace/messaging/tablet_message/signal = new(source, list(
			"fakename" = "Nanotrasen Corp Alerts",
			"fakejob" = "Flashbang Watchdog",
			"message" = message,
			"targets" = list(messenger),
			"automated" = TRUE,
		))
		signal.send_to_receivers()
		sender.log_message("(PDA: Flashbang Alerts) sent \"[message]\" to [signal.format_target()]", LOG_PDA)

	return TRUE

/obj/item/grenade/flashbang/apply_grenade_fantasy_bonuses(quality)
	flashbang_range = modify_fantasy_variable("flashbang_range", flashbang_range, quality)

/obj/item/grenade/flashbang/remove_grenade_fantasy_bonuses(quality)
	flashbang_range = reset_fantasy_variable("flashbang_range", flashbang_range)

/obj/item/grenade/flashbang/arm_grenade(mob/user, delayoverride, msg = TRUE, volume = 60)
	. = ..()
	if(!.)
		return

	var/sweetspot_range = clamp(CEILING(flashbang_range/sweetspot_divider, 1), 0, flashbang_range)
	set_light(sweetspot_range, sweetspot_range, flashbang_light)

/obj/item/grenade/flashbang/detonate(mob/living/lanced_by)
	. = ..()
	if(!.)
		return

	update_mob()
	var/turf/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return

	//Check that there's enough pressure on the detonation turf for the 'bang' part of the flashbang to work.
	var/datum/gas_mixture/environment = flashbang_turf.return_air()
	var/pressure = environment?.return_pressure()
	var/soundbang = pressure >= SOUND_MINIMUM_PRESSURE

	do_sparks(rand(5, 9), FALSE, src)
	playsound(flashbang_turf, 'sound/items/weapons/flashbang.ogg', 100, TRUE, 8, 0.9)
	new /obj/effect/dummy/lighting_obj (flashbang_turf, flashbang_range + 2, 4, COLOR_WHITE, 2)
	for(var/mob/living/living_mob in get_hearers_in_view(flashbang_range, flashbang_turf))
		bang(get_turf(living_mob), living_mob, soundbang)
	qdel(src)

/obj/item/grenade/flashbang/proc/bang(turf/turf, mob/living/living_mob, soundbang = TRUE)
	if(living_mob.stat == DEAD) //They're dead!
		return
	living_mob.show_message(span_warning("BANG"), MSG_AUDIBLE)
	var/distance = get_dist(get_turf(src), turf)
	var/sweetspot_range = clamp(CEILING(flashbang_range/sweetspot_divider, 1), 0, flashbang_range)

	//Flash
	var/attempt_flash = living_mob.flash_act(affect_silicon = 1)
	if(attempt_flash == FLASH_COMPLETED)
		if(distance <= sweetspot_range || issilicon(living_mob))
			living_mob.Paralyze(max(20/max(1, distance), 5))
			living_mob.Knockdown(max(200/max(1, distance), 60))
		else
			living_mob.adjust_dizzy_up_to(max(200/max(1, distance), 5), 20 SECONDS)
		living_mob.dropItemToGround(living_mob.get_active_held_item())
		living_mob.dropItemToGround(living_mob.get_inactive_held_item())

	//Bang
	if(!soundbang && distance)
		return

	if(!distance)
		living_mob.soundbang_act(SOUNDBANG_OVERWHELMING, 20 SECONDS, 10, 15)
		return

	if(distance <= 1) // Adds more stun as to not prime n' pull (#45381)
		living_mob.soundbang_act(SOUNDBANG_STRONG, 3 SECONDS, 5)
		return

	if(distance <= sweetspot_range)
		living_mob.soundbang_act(SOUNDBANG_NORMAL, max(20 SECONDS / max(1, distance), 60), rand(0, 5))
		return

	if(!living_mob.soundbang_act(SOUNDBANG_NORMAL, 0, rand(0, 2)))
		return

	living_mob.adjust_staggered_up_to(max(200/max(1, distance), 5), 10 SECONDS)
	living_mob.dropItemToGround(living_mob.get_active_held_item())
	living_mob.dropItemToGround(living_mob.get_inactive_held_item())


/obj/item/grenade/stingbang
	name = "stingbang"
	icon_state = "timeg_locked"
	base_icon_state = "timeg"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/flashbang_range = 1 //how many tiles away the mob will be stunned.
	shrapnel_type = /obj/projectile/bullet/pellet/stingball
	shrapnel_radius = 5
	custom_premium_price = PAYCHECK_COMMAND * 3.5 // mostly gotten through cargo, but throw in one for the sec vendor ;)

/obj/item/grenade/stingbang/mega
	name = "mega stingbang"
	icon_state = "timeg_mega_locked"
	base_icon_state = "timeg_mega"
	shrapnel_type = /obj/projectile/bullet/pellet/stingball/mega
	shrapnel_radius = 12

/obj/item/grenade/stingbang/detonate(mob/living/lanced_by)
	if(dud_flags)
		active = FALSE
		update_appearance()
		return FALSE

	if(iscarbon(loc))
		var/mob/living/carbon/user = loc
		var/obj/item/bodypart/bodypart = user.get_holding_bodypart_of_item(src)
		if(bodypart)
			forceMove(get_turf(user))
			var/did_dismember = bodypart.dismember()
			user.visible_message("<b>[span_danger("[src] goes off in [user]'s hand[did_dismember ? ", blowing [user.p_their()] [bodypart.plaintext_zone] to bloody shreds" : ""]!")]</b>", span_userdanger("[src] goes off in your hand[did_dismember ? ", blowing your [bodypart.plaintext_zone] to bloody shreds" : ""]!"))

	. = ..()
	if(!.)
		return


	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	do_sparks(rand(5, 9), FALSE, src)
	playsound(flashbang_turf, 'sound/items/weapons/flashbang.ogg', 50, TRUE, 8, 0.9)
	new /obj/effect/dummy/lighting_obj (flashbang_turf, flashbang_range + 2, 2, COLOR_WHITE, 1)
	for(var/mob/living/living_mob in get_hearers_in_view(flashbang_range, flashbang_turf))
		pop(get_turf(living_mob), living_mob)
	qdel(src)

/obj/item/grenade/stingbang/proc/pop(turf/turf, mob/living/living_mob)
	if(living_mob.stat == DEAD) //They're dead!
		return
	living_mob.show_message(span_warning("POP"), MSG_AUDIBLE)
	var/distance = get_dist(get_turf(src), turf)
//Flash
	if(living_mob.flash_act(affect_silicon = 1))
		living_mob.Paralyze(max(10/max(1, distance), 5))
		living_mob.Knockdown(max(100/max(1, distance), 60))

//Bang
	if(!distance)
		living_mob.Paralyze(2 SECONDS)
		living_mob.Knockdown(20 SECONDS)
		living_mob.soundbang_act(SOUNDBANG_NORMAL, 200, 10, 15)
		if(living_mob.apply_damages(brute = 10, burn = 10))
			to_chat(living_mob, span_userdanger("The blast from \the [src] bruises and burns you!"))

	// only checking if they're on top of the tile, cause being one tile over will be its own punishment

// Grenade that releases more shrapnel the more times you use it in hand between priming and detonation (sorta like the 9bang from MW3), for admin goofs
/obj/item/grenade/primer
	name = "rotfrag grenade"
	desc = "A grenade that generates more shrapnel the more you rotate it in your hand after pulling the pin. This one releases shrapnel shards."
	icon_state = "timeg_locked"
	base_icon_state = "timeg"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/rots_per_mag = 3 /// how many times we need to "rotate" the charge in hand per extra tile of magnitude
	shrapnel_type = /obj/projectile/bullet/shrapnel
	var/rots = 1 /// how many times we've "rotated" the charge

/obj/item/grenade/primer/attack_self(mob/user)
	. = ..()
	if(active)
		user.playsound_local(user, 'sound/misc/box_deploy.ogg', 50, TRUE)
		rots++
		user.changeNext_move(CLICK_CD_RAPID)

/obj/item/grenade/primer/detonate(mob/living/lanced_by)
	shrapnel_radius = round(rots / rots_per_mag)
	. = ..()
	if(!.)
		return

	qdel(src)

/obj/item/grenade/primer/stingbang
	name = "rotsting"
	desc = "A grenade that generates more shrapnel the more you rotate it in your hand after pulling the pin. This one releases stingballs."
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	rots_per_mag = 2
	shrapnel_type = /obj/projectile/bullet/pellet/stingball
