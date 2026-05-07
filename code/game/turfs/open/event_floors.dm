/turf/open/misc/asphalt
	name = "Asphalt"
	desc = "Regular asphalt"
	icon = 'icons/turf/asphalt.dmi'
	icon_state = "roof-0"
	base_icon_state = "roof"

	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_FLOOR_ASPHALT
	canSmoothWith = SMOOTH_GROUP_FLOOR_ASPHALT + SMOOTH_GROUP_OPEN_FLOOR

/turf/open/misc/asphalt/no_border
	icon = 'icons/turf/asphalt_noborder.dmi'

/turf/open/moving
	name = "Matrix"
	desc = "You probably shouldn't see this"
	icon = 'icons/turf/trainturf.dmi'
	turf_flags = NO_RUST | IS_SOLID | NOJAUNT
	gender = PLURAL
	tiled_turf = TRUE
	planetary_atmos = TRUE
	rust_resistance = RUST_RESISTANCE_ABSOLUTE
	var/fake = FALSE

/turf/open/moving/snow
	name = "Snow"
	desc = "It looks cold"
	icon_state = "snow_still"
	base_icon_state = "snow"
	slowdown = 2

/turf/open/moving/snow/fake
	fake = TRUE

/turf/open/moving/snow/fake/dense
	density = TRUE

/turf/open/moving/rails
	name = "Rails"
	desc = "It's better not to stand in the way of a train."
	slowdown = 2

/turf/open/moving/rails/l1
	icon_state = "rails_left_1_still"
	base_icon_state = "rails_left_1"

/turf/open/moving/rails/l2
	icon_state = "rails_left_2_still"
	base_icon_state = "rails_left_2"

/turf/open/moving/rails/l3
	icon_state = "rails_left_3_still"
	base_icon_state = "rails_left_3"

/turf/open/moving/rails/l4
	icon_state = "rails_left_4_still"
	base_icon_state = "rails_left_4"

/turf/open/moving/rails/l5
	icon_state = "rails_left_5_still"
	base_icon_state = "rails_left_5"

/turf/open/moving/rails/l6
	icon_state = "rails_left_6_still"
	base_icon_state = "rails_left_6"

/turf/open/moving/rails/l7
	icon_state = "rails_left_7_still"
	base_icon_state = "rails_left_7"

/turf/open/moving/rails/l8
	icon_state = "rails_left_8_still"
	base_icon_state = "rails_left_8"

/turf/open/moving/rails/l9
	icon_state = "rails_left_9_still"
	base_icon_state = "rails_left_9"

/turf/open/moving/rails/l10
	icon_state = "rails_left_10_still"
	base_icon_state = "rails_left_10"

/turf/open/moving/rails/l11
	icon_state = "rails_left_11_still"
	base_icon_state = "rails_left_11"

/turf/open/moving/rails/l12
	icon_state = "rails_left_12_still"
	base_icon_state = "rails_left_12"

/turf/open/moving/rails/l13
	icon_state = "rails_left_13_still"
	base_icon_state = "rails_left_13"

/turf/open/moving/rails/r1
	icon_state = "rails_right_1_still"
	base_icon_state = "rails_right_1"

/turf/open/moving/rails/r2
	icon_state = "rails_right_2_still"
	base_icon_state = "rails_right_2"

/turf/open/moving/rails/r3
	icon_state = "rails_right_3_still"
	base_icon_state = "rails_right_3"

/turf/open/moving/rails/r4
	icon_state = "rails_right_4_still"
	base_icon_state = "rails_right_4"

/turf/open/moving/rails/r5
	icon_state = "rails_right_5_still"
	base_icon_state = "rails_right_5"

/turf/open/moving/rails/r6
	icon_state = "rails_right_6_still"
	base_icon_state = "rails_right_6"

/turf/open/moving/rails/r7
	icon_state = "rails_right_7_still"
	base_icon_state = "rails_right_7"

/turf/open/moving/rails/r8
	icon_state = "rails_right_8_still"
	base_icon_state = "rails_right_8"

/turf/open/moving/rails/r9
	icon_state = "rails_right_9_still"
	base_icon_state = "rails_right_9"

/turf/open/moving/rails/r10
	icon_state = "rails_right_10_still"
	base_icon_state = "rails_right_10"

/turf/open/moving/rails/r11
	icon_state = "rails_right_11_still"
	base_icon_state = "rails_right_11"

/turf/open/moving/rails/r12
	icon_state = "rails_right_12_still"
	base_icon_state = "rails_right_12"

/turf/open/moving/rails/r13
	icon_state = "rails_right_13_still"
	base_icon_state = "rails_right_13"

/turf/open/indestructible/train_platform
	name = "Platform"
	desc = "Railway station platform."
	icon = 'icons/turf/trainturf.dmi'
	icon_state = "platform_middle_still"

/turf/open/indestructible/train_platform/bottom
	icon_state = "platform_bottom_still"

/turf/open/indestructible/train_platform/top
	icon_state = "platform_top_still"
