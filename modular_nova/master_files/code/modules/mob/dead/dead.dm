/mob/dead/get_status_tab_items()
	. = ..()
	if(SSticker.HasRoundStarted())
		return
	if(SSstoryteller?.is_roundstart_prep_active())
		var/prep_remaining = SSstoryteller.get_roundstart_prep_remaining()
		. += "Time To Start: Storyteller prep ([round(prep_remaining / 10)]s)"
		. += "Round Preparation: Finalizing the dynamic round setup"
	else
		var/time_remaining = SSticker.GetTimeLeft()
		if(time_remaining > 0)
			. += "Time To Start: [round(time_remaining/10)]s"
		else if(time_remaining == -10)
			. += "Time To Start: DELAYED"
		else
			. += "Time To Start: SOON"

	. += "Players: [LAZYLEN(GLOB.clients)]"
	if(client.holder)
		. += "Players Ready: [SSticker.totalPlayersReady]"
		. += "Admins Ready: [SSticker.total_admins_ready] / [length(GLOB.admins)]"
	if(length(SSstatpanels.player_ready_data) || length(SSstatpanels.assistant_player_ready_data) || length(SSstatpanels.command_player_ready_data))
		. += SSstatpanels.get_job_estimation(src)
