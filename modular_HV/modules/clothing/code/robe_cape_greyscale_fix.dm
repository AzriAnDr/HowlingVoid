// HOWLING VOID FIX:
// Force robe cape greyscale configs to use known-valid base json paths.
// This prevents runtime failures when an external/invalid json path is picked up.
/datum/greyscale_config/robe_cape
	name = "Robe Cape"
	icon_file = 'icons/obj/clothing/neck.dmi'
	json_config = 'code/datums/greyscale/json_configs/robe_cape.json'

/datum/greyscale_config/robe_cape/New()
	// Force a valid json path before base greyscale New()/Refresh logic runs.
	json_config = 'code/datums/greyscale/json_configs/robe_cape.json'
	return ..()

/datum/greyscale_config/robe_cape/worn
	name = "Robe Cape"
	icon_file = 'icons/mob/clothing/neck.dmi'
	json_config = 'code/datums/greyscale/json_configs/robe_cape_worn.json'

/datum/greyscale_config/robe_cape/worn/New()
	// Force a valid json path before base greyscale New()/Refresh logic runs.
	json_config = 'code/datums/greyscale/json_configs/robe_cape_worn.json'
	return ..()
