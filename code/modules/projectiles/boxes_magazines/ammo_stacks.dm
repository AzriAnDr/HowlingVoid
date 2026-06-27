/// Object for holding stacks of loose ammo as a handful of shells
/obj/item/ammo_box/magazine/ammo_stack
	name = "ammo stack"
	desc = "A stack of ammo."
	icon = 'icons/obj/weapons/ammo_stacks.dmi'
	icon_state = "stack_regular"
	base_icon_state = "ammo_stack"
	appearance_flags = parent_type::appearance_flags | KEEP_TOGETHER
	w_class = WEIGHT_CLASS_SMALL
	multiple_sprites = AMMO_BOX_ONE_SPRITE
	ammo_box_multiload = AMMO_BOX_MULTILOAD_NONE
	start_empty = TRUE
	max_ammo = 12
	/// Spacing between random w offsets of casings. Change based on the size of the casing being put into the stack.
	var/casing_w_spacing = 1
	/// How much space vertically should we leave for casings in random casing z pixel shifts.
	var/casing_z_padding = 3

/obj/item/ammo_box/magazine/ammo_stack/attack_self(mob/user)
	. = ..()
	check_empty()

/obj/item/ammo_box/magazine/ammo_stack/attackby(obj/item/A, mob/user, params, silent = FALSE, replace_spent = 0)
	. = ..()
	check_empty()

/obj/item/ammo_box/magazine/ammo_stack/empty_magazine()
	. = ..()
	check_empty()

/obj/item/ammo_box/magazine/ammo_stack/Exited(atom/movable/gone, direction)
	. = ..()
	check_empty()

/obj/item/ammo_box/magazine/ammo_stack/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(.) // They caught all the bullets. Powerful.
		return
	scatter(hit_atom, 48)

/obj/item/ammo_box/magazine/ammo_stack/onZImpact(turf/impacted_turf, levels, impact_flags)
	. = ..()
	scatter(impacted_turf, 48)

/obj/item/ammo_box/magazine/ammo_stack/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	scatter(target, 48)

/// Checks the shells in the ammo stack to make sure it isn't empty, if it is, the stack is deleted
/obj/item/ammo_box/magazine/ammo_stack/proc/check_empty()
	if(!ammo_count(TRUE) && !QDELETED(src))
		spawn(0) // We are doing this to yield execution to the rest of the call chain to avoid a race condition. Hacky but avoids nonmodular messes.
			qdel(src)

/// Iterates through every casing in this ammo stack, scattering it and moving it out of the ammo stack, in the event this was thrown.
/obj/item/ammo_box/magazine/ammo_stack/proc/scatter(atom/hit_atom, pixel_distance = 48)
	var/turf/scatter_turf = get_turf(hit_atom)
	if(!hit_atom.CanPass(src, get_dir(src, hit_atom))) //Object is too dense to fall apart on
		scatter_turf = get_turf(src)

	var/generator/scatter_gen = generator(GEN_CIRCLE, 0, pixel_distance, NORMAL_RAND)
	for(var/obj/item/ammo_casing/scattered_casing as anything in ammo_list())
		scattered_casing.forceMove(scatter_turf)
		var/list/scatter_vector = scatter_gen.Rand()
		scatter_individual_casing(scattered_casing, scatter_vector[1], scatter_vector[2])

	playsound(scatter_turf, 'sound/items/weapons/gun/general/mag_bullet_remove.ogg', 60, TRUE)
	check_empty()

/// Scatters an individual casing, bouncing and pixel-moving it about.
/obj/item/ammo_box/magazine/ammo_stack/proc/scatter_individual_casing(obj/item/ammo_casing/scattered_casing, pixel_x_offset = 0, pixel_y_offset = 0)
	if(prob(50)) // Randomize order, avoid bias to one axis if stepping is blocked
		pixelmove_casing(scattered_casing, pixel_y_offset, x_axis = FALSE)
		pixelmove_casing(scattered_casing, pixel_x_offset, x_axis = TRUE)
	else
		pixelmove_casing(scattered_casing, pixel_x_offset, x_axis = TRUE)
		pixelmove_casing(scattered_casing, pixel_y_offset, x_axis = FALSE)
	scattered_casing.bounce_away(FALSE, rand(0, 3))

/// Pixel-moves a casing around based on offsets, in tandem with casing scattering when this ammo stack is thrown.
/obj/item/ammo_box/magazine/ammo_stack/proc/pixelmove_casing(obj/item/ammo_casing/scattered_casing, pixel_offset = 0, x_axis = TRUE)
	var/positive_dir = x_axis ? EAST : NORTH
	var/negative_dir = x_axis ? WEST : SOUTH
	var/per_step = x_axis ? ICON_SIZE_X : ICON_SIZE_Y
	var/half_step = per_step / 2

	if(abs(pixel_offset) > half_step)
		var/positive_offset = (pixel_offset > 0)
		var/offset_correction = positive_offset ? -half_step : half_step
		var/step_dir = positive_offset ? positive_dir : negative_dir
		for(var/i in 1 to floor(abs(pixel_offset) + half_step) / per_step)
			step(scattered_casing, step_dir)
		pixel_offset = (pixel_offset % half_step) + offset_correction

	if(x_axis)
		scattered_casing.pixel_x = pixel_offset
	else
		scattered_casing.pixel_y = pixel_offset

/obj/item/ammo_box/magazine/ammo_stack/update_appearance()
	. = ..()
	if(!ammo_count())
		return
	icon_state = base_icon_state

/obj/item/ammo_box/magazine/ammo_stack/update_overlays()
	. = ..()
	if(!ammo_count())
		return

	for(var/obj/item/ammo_casing/iterated_casing as anything in stored_ammo)
		var/mutable_appearance/overlayed_casing = mutable_appearance(icon = iterated_casing.icon, icon_state = "[initial(iterated_casing.icon_state)]-live")
		overlayed_casing.pixel_w = rand(-2, 2) * casing_w_spacing
		var/z_offset_range = 16 - casing_z_padding
		overlayed_casing.pixel_z = rand(-z_offset_range, z_offset_range)
		. += overlayed_casing

// Allows ammo casings to be attacked together to make a new stack
/obj/item/ammo_casing
	/// What this casing can be stacked into
	var/obj/item/ammo_box/magazine/ammo_stack_type

/obj/item/ammo_casing/examine(mob/user)
	. = ..()
	if(ammo_stack_type)
		. += span_notice("[src] can be stacked with other casings of a similar type.")
	return .

/obj/item/ammo_casing/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/ammo_casing))
		return NONE

	var/obj/item/ammo_casing/used_casing = tool
	if(!used_casing.ammo_stack_type)
		balloon_alert(user, "used casing can't stack")
		return ITEM_INTERACT_BLOCKING
	if(!ammo_stack_type)
		balloon_alert(user, "target can't stack!")
		return ITEM_INTERACT_BLOCKING
	if(ammo_stack_type != used_casing.ammo_stack_type)
		balloon_alert(user, "can't stack together!")
		return ITEM_INTERACT_BLOCKING
	if(!loaded_projectile || !used_casing.loaded_projectile)
		balloon_alert(user, "can't stack empty casings!")
		return ITEM_INTERACT_BLOCKING

	var/obj/item/ammo_box/magazine/ammo_stack = new ammo_stack_type(drop_location())
	ammo_stack.give_round(src)
	ammo_stack.give_round(used_casing)
	user.put_in_hands(ammo_stack)
	ammo_stack.update_appearance()
// Special ammo

// .980 grenades

/obj/item/ammo_box/magazine/ammo_stack/c980
	name = ".980 Tydhouer grenades"
	desc = "A stack of .980 Tydhouer grenades."
	caliber = CALIBER_980TYDHOUER
	ammo_type = /obj/item/ammo_casing/c980grenade
	casing_phrasing = "shell"
	max_ammo = 6
	casing_w_spacing = 3
	casing_z_padding = 9

/obj/item/ammo_box/magazine/ammo_stack/c980/prefilled
	name = ".980 Tydhouer practice grenades"
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/c980/prefilled/smoke
	name = ".980 Tydhouer smoke grenades"
	ammo_type = /obj/item/ammo_casing/c980grenade/smoke

/obj/item/ammo_box/magazine/ammo_stack/c980/prefilled/gas
	name = ".980 Tydhouer tear gas grenades"
	ammo_type = /obj/item/ammo_casing/c980grenade/riot

/obj/item/ammo_box/magazine/ammo_stack/c980/prefilled/shrap
	name = ".980 Tydhouer shrapnel grenades"
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel
	icon_state = "stack_spec"

/obj/item/ammo_box/magazine/ammo_stack/c980/prefilled/fire
	name = ".980 Tydhouer phosphor grenades"
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel/phosphor
	icon_state = "stack_spec"

/obj/item/ammo_box/magazine/ammo_stack/c980/prefilled/conc
	name = ".980 Tydhouer kinetic concussive grenades"
	ammo_type = /obj/item/ammo_casing/c980grenade/concussive
	icon_state = "stack_spec"

// 12ga shotgun shells

/obj/item/ammo_casing/shotgun
	ammo_stack_type = /obj/item/ammo_box/magazine/ammo_stack/s12gauge

/obj/item/ammo_box/magazine/ammo_stack/s12gauge
	name = "12 gauge shells"
	desc = "A stack of 12 gauge shells."
	caliber = CALIBER_SHOTGUN
	ammo_type = /obj/item/ammo_casing/shotgun
	casing_phrasing = "shell"
	max_ammo = 8
	casing_w_spacing = 3
	casing_z_padding = 4

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled
	name = "12 gauge slug shells"
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/antitide
	name = "12 gauge lighting shot shells"
	ammo_type = /obj/item/ammo_casing/shotgun/antitide
	icon_state = "stack_spec"

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/beanbag
	name = "12 gauge beanbag shells"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/beehive
	name = "12 gauge hornet shells"
	ammo_type = /obj/item/ammo_casing/shotgun/beehive
	icon_state = "stack_spec"

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/breacher
	name = "12 gauge breaching shells"
	ammo_type = /obj/item/ammo_casing/shotgun/breacher
	icon_state = "stack_spec"

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/buckshot
	name = "12 gauge buckshot shells"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/dragonsbreath
	name = "12 gauge dragonsbreath shells"
	ammo_type = /obj/item/ammo_casing/shotgun/dragonsbreath
	icon_state = "stack_spec"

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/express
	name = "12 gauge express shells"
	ammo_type = /obj/item/ammo_casing/shotgun/express

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/flechette
	name = "12 gauge ripper flechette shells"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette_nova
	icon_state = "stack_spec"

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/frag12
	name = "12 gauge frag shells"
	ammo_type = /obj/item/ammo_casing/shotgun/frag12
	icon_state = "stack_spec"

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/hunter
	name = "12 gauge hunter shells"
	ammo_type = /obj/item/ammo_casing/shotgun/hunter
	icon_state = "stack_spec"

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/incendiary
	name = "12 gauge incendiary shells"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary
	icon_state = "stack_spec"

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/magnum
	name = "12 gauge magnum shells"
	ammo_type = /obj/item/ammo_casing/shotgun/magnum

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/rubbershot
	name = "12 gauge rubbershot shells"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/milspec
	name = "12 gauge milspec slug shells"
	ammo_type = /obj/item/ammo_casing/shotgun/milspec

/obj/item/ammo_box/magazine/ammo_stack/s12gauge/prefilled/buckshot/milspec
	name = "12 gauge milspec buckshot shells"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/milspec

// Pistol ammo

// .35 sol short

/obj/item/ammo_box/magazine/ammo_stack/c35_sol
	name = ".35 Sol Short casings"
	desc = "A stack of .35 Sol Short cartridges."
	caliber = CALIBER_SOL35SHORT
	ammo_type = /obj/item/ammo_casing/c35sol
	max_ammo = 12
	casing_w_spacing = 2
	casing_z_padding = 6

/obj/item/ammo_box/magazine/ammo_stack/c35_sol/prefilled
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/c35_sol/prefilled/incapacitator
	name = ".35 Sol Short incapacitator casings"
	ammo_type = /obj/item/ammo_casing/c35sol/incapacitator
	icon_state = "stack_spec"

/obj/item/ammo_box/magazine/ammo_stack/c35_sol/prefilled/ripper
	name = ".35 Sol Short ripper casings"
	ammo_type = /obj/item/ammo_casing/c35sol/ripper
	icon_state = "stack_spec"

// .27-54 Cesarzowa

/obj/item/ammo_box/magazine/ammo_stack/c27_54cesarzowa
	name = ".27-54 Cesarzowa casings"
	desc = "A stack of .27-54 Cesarzowa cartridges."
	caliber = CALIBER_CESARZOWA
	ammo_type = /obj/item/ammo_casing/c27_54cesarzowa
	max_ammo = 18
	casing_w_spacing = 2
	casing_z_padding = 6

/obj/item/ammo_box/magazine/ammo_stack/c27_54cesarzowa/prefilled
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/c27_54cesarzowa/prefilled/incapacitator
	name = ".27-54 Cesarzowa rubber casings"
	ammo_type = /obj/item/ammo_casing/c27_54cesarzowa/rubber
	icon_state = "stack_spec"

// .585 trappiste

/obj/item/ammo_box/magazine/ammo_stack/c585_trappiste
	name = ".585 Trappiste casings"
	desc = "A stack of .585 Trappiste casings."
	caliber = CALIBER_585TRAPPISTE
	ammo_type = /obj/item/ammo_casing/c585trappiste
	max_ammo = 6
	casing_w_spacing = 2
	casing_z_padding = 9

/obj/item/ammo_box/magazine/ammo_stack/c585_trappiste/prefilled
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/c585_trappiste/prefilled/incapacitator
	name = ".585 Trappiste flathead casings"
	ammo_type = /obj/item/ammo_casing/c585trappiste/incapacitator
	icon_state = "stack_spec"

/obj/item/ammo_box/magazine/ammo_stack/c585_trappiste/prefilled/incendiary
	name = ".585 Trappiste incendiary casings"
	ammo_type = /obj/item/ammo_casing/c585trappiste/incendiary
	icon_state = "stack_spec"

// Rifle ammo

// .40 sol long

/obj/item/ammo_box/magazine/ammo_stack/c40_sol
	name = ".40 Sol Long casings"
	desc = "A stack of .40 Sol Long cartridges."
	caliber = CALIBER_SOL40LONG
	ammo_type = /obj/item/ammo_casing/c40sol
	max_ammo = 15
	casing_w_spacing = 2
	casing_z_padding = 6

/obj/item/ammo_box/magazine/ammo_stack/c40_sol/prefilled
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/c40_sol/prefilled/frag
	name = ".40 Sol Long fragmentation casings"
	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation
	icon_state = "stack_spec"

/obj/item/ammo_box/magazine/ammo_stack/c40_sol/prefilled/incendiary
	name = ".40 Sol Long incendiary casings"
	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
	icon_state = "stack_spec"

/obj/item/ammo_box/magazine/ammo_stack/c40_sol/prefilled/match
	name = ".40 Sol Long match casings"
	ammo_type = /obj/item/ammo_casing/c40sol/pierce
	icon_state = "stack_spec"

// .310 strilka

/obj/item/ammo_casing/strilka310
	ammo_stack_type = /obj/item/ammo_box/magazine/ammo_stack/c310_strilka

/obj/item/ammo_box/magazine/ammo_stack/c310_strilka
	name = ".310 Strilka casings"
	desc = "A stack of .310 Strilka cartridges."
	caliber = CALIBER_STRILKA310
	ammo_type = /obj/item/ammo_casing/strilka310
	max_ammo = 5
	casing_w_spacing = 2
	casing_z_padding = 8

/obj/item/ammo_box/magazine/ammo_stack/c310_strilka/prefilled
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/c310_strilka/prefilled/incapacitator
	name = ".310 Strilka rubber casings"
	ammo_type = /obj/item/ammo_casing/strilka310/rubber
	icon_state = "stack_spec"

/obj/item/ammo_box/magazine/ammo_stack/c310_strilka/prefilled/dollar_tree
	name = ".310 Strilka surplus casings"
	ammo_type = /obj/item/ammo_casing/strilka310/surplus

/obj/item/ammo_box/magazine/ammo_stack/c310_strilka/prefilled/ap
	name = ".310 Strilka piercing casings"
	ammo_type = /obj/item/ammo_casing/strilka310/ap
	icon_state = "stack_spec"

// .60 strela

/obj/item/ammo_box/magazine/ammo_stack/c60_strela
	name = ".60 Strela casings"
	desc = "A stack of .60 Strela cartridges."
	caliber = CALIBER_60STRELA
	ammo_type = /obj/item/ammo_casing/p60strela
	max_ammo = 6
	casing_w_spacing = 3
	casing_z_padding = 9

/obj/item/ammo_box/magazine/ammo_stack/c60_strela/prefilled
	start_empty = FALSE
