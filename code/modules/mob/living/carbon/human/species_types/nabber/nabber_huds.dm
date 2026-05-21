#define NABBER_HUD_Y_SHIFT 16

/mob/living/carbon/human/species/nabber/adjust_hud_position(image/holder, animate_time)
	. = ..()
	holder.pixel_z += NABBER_HUD_Y_SHIFT // adjust_hud_position() can bypass normal HUD image offsets.

#undef NABBER_HUD_Y_SHIFT
