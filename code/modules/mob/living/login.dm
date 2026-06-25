/mob/living/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	if(ckey && is_banned_from(ckey, BAN_PACIFICATION))
		ADD_TRAIT(src, TRAIT_PACIFISM, ROUNDSTART_TRAIT)

	//Mind updates
	sync_mind()

	update_damage_hud()
	update_health_hud()

	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)

	//Vents
	notify_ventcrawler_on_login()

	med_hud_set_status()

	update_fov_client()
