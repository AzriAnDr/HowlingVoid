/datum/keybinding/mob/pixel_tilt
	hotkey_keys = list("N")
	name = "pixel_tilt"
	full_name = "Pixel Tilt"
	description = "Rotate your character's sprite. Hold and use arrow keys."
	category = CATEGORY_MOVEMENT
	keybind_signal = COMSIG_KB_MOB_PIXEL_TILT_DOWN

/datum/keybinding/mob/pixel_tilt/down(client/user)
	. = ..()
	if(.)
		return

	var/datum/component/pixel_tilt/tilt_component = user.mob.GetComponent(/datum/component/pixel_tilt)
	if(tilt_component)
		tilt_component.reset_tilt_and_remove()
	else
		user.mob.add_pixel_tilt_component()

/mob/proc/add_pixel_tilt_component()
	return

/mob/living/add_pixel_tilt_component()
	AddComponent(/datum/component/pixel_tilt)
