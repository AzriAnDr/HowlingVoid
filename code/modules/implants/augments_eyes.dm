/obj/item/organ/eyes/night_vision/cyber
	name = "nightvision eyes"
	icon = 'icons/implants/chest.dmi' // Uses the shared chest implant icon file.
	icon_state = "eyes_nvcyber"
	desc = "A pair of eyes with built-in nightvision optics, with the additional bonus of being rad as hell."
	eye_color_left = "#0ffc03"
	eye_color_right = "#ff2700"
	organ_flags = ORGAN_ROBOTIC
	low_light_cutoff = list(0, 15, 20)
	medium_light_cutoff = list(0, 20, 35)
	high_light_cutoff = list(0, 40, 50)
