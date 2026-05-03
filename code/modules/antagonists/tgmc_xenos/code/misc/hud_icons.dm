GLOBAL_VAR_INIT(merged_huds, merge_huds())

/proc/merge_huds()
	var/icon/huds = icon('modular_nova/master_files/icons/mob/huds/hud.dmi')
	var/icon/xeno_huds = icon('code/modules/antagonists/tgmc_xenos/icons/xeno_hud.dmi')

	for(var/state in icon_states(xeno_huds))
		huds.Insert(icon(xeno_huds, state), state)

	return huds
