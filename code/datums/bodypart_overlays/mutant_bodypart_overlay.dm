///Variant of bodypart_overlay meant to work synchronously with external organs. Gets imprinted upon Insert in on_species_gain
/datum/bodypart_overlay/mutant
	///Sprite datum we use to draw on the bodypart
	var/datum/sprite_accessory/sprite_datum

	///Defines what kind of 'organ' we're looking at. Sprites have names like 'm_mothwings_firemoth_ADJ'. 'mothwings' would then be feature_key
	var/feature_key = ""

	///The color this organ draws with. Updated by bodypart/inherit_color()
	var/draw_color
	///Override of the color of the organ, from dye sprays
	var/dye_color
	///Can this bodypart overlay be dyed?
	var/dyable = FALSE

	///Where does this organ inherit its color from?
	var/color_source = ORGAN_COLOR_INHERIT
	///Take on the dna/preference from whoever we're gonna be inserted in
	var/imprint_on_next_insertion = TRUE
	draw_on_husks = TRUE

/datum/bodypart_overlay/mutant/New(obj/item/organ/attached_organ)
	. = ..()

	RegisterSignal(attached_organ, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_mob_insert))

/datum/bodypart_overlay/mutant/proc/on_mob_insert(obj/item/organ/parent, mob/living/carbon/receiver)
	SIGNAL_HANDLER

	if (isalien(receiver))
		return // Xenomorphs have no dna or other features required to support this, maybe one day

	if(!should_visual_organ_apply_to(parent.type, receiver))
		stack_trace("adding a [parent.type] to a [receiver.type] when it shouldn't be!")

	if(imprint_on_next_insertion) //We only want this set *once*
		if(set_appearance_from_dna(receiver.dna))
			imprint_on_next_insertion = FALSE
			return

		var/feature_name = receiver.dna.features[feature_key] || receiver.dna.species.mutant_organs[parent.type]
		if (isnull(feature_name))
		/* // NOVA EDIT REMOVAL START - Customization
			stack_trace("[type] has no default feature name for organ [parent.type]!")
			feature_name = get_consistent_feature_entry(get_global_feature_list()) //fallback to something
		*/ // NOVA EDIT REMOVAL END
		// NOVA EDIT ADDITION START
			if(!set_appearance_from_dna(receiver.dna))
				set_appearance_from_name(receiver.dna.species.mutant_organs[parent.type] || pick(get_global_feature_list()))
		// NOVA EDIT ADDITION END
		// NOVA EDIT CHANGE START - Puts the following line in an else block
		else
			set_appearance_from_name(feature_name)
		// NOVA EDIT CHANGE END
		imprint_on_next_insertion = FALSE

/datum/bodypart_overlay/mutant/get_overlay(layer, obj/item/bodypart/limb)
	inherit_color(limb) // If draw_color is not set yet, go ahead and do that
	return ..()

///Completely random image and color generation (obeys what a player can choose from)
/datum/bodypart_overlay/mutant/proc/randomize_appearance()
	randomize_sprite()
	draw_color = "#[random_color()]"
	imprint_on_next_insertion = FALSE

///Grab a random sprite
/datum/bodypart_overlay/mutant/proc/randomize_sprite()
	sprite_datum = get_random_appearance()

///Grab a random appearance datum (thats not locked)
/datum/bodypart_overlay/mutant/proc/get_random_appearance() as /datum/sprite_accessory
	RETURN_TYPE(/datum/sprite_accessory)
	var/list/valid_restyles = list()
	var/list/feature_list = get_global_feature_list()
	for(var/accessory in feature_list)
		var/datum/sprite_accessory/accessory_datum = feature_list[accessory]
		if(initial(accessory_datum.locked)) //locked is for stuff that shouldn't appear here
			continue
		if(!initial(accessory_datum.natural_spawn))
			continue
		valid_restyles += accessory_datum
	return pick(valid_restyles)

///Return the BASE icon state of the sprite datum (so not the gender, layer, feature_key)
/datum/bodypart_overlay/mutant/proc/get_base_icon_state()
	return sprite_datum.icon_state

///Get the image we need to draw on the person. Called from get_overlay() which is called from _bodyparts.dm. Limb can be null
/datum/bodypart_overlay/mutant/get_image(image_layer, obj/item/bodypart/limb)
	if(!sprite_datum)
		CRASH("Trying to call get_image() on [type] while it didn't have a sprite_datum. This shouldn't happen, report it as soon as possible.")

	var/gender = limb?.limb_gender || "m"
	var/list/icon_state_builder = list()
	icon_state_builder += sprite_datum.gender_specific ? gender : "m" //Male is default because sprite accessories are so ancient they predate the concept of not hardcoding gender
	icon_state_builder += feature_key
	icon_state_builder += get_base_icon_state()
	icon_state_builder += mutant_bodyparts_layertext(image_layer)

	var/finished_icon_state = icon_state_builder.Join("_")

	var/mutable_appearance/appearance = mutable_appearance(sprite_datum.icon, finished_icon_state, layer = image_layer)

	if(sprite_datum.center)
		center_image(appearance, sprite_datum.dimension_x, sprite_datum.dimension_y)

	return appearance

/datum/bodypart_overlay/mutant/color_image(image/overlay, layer, obj/item/bodypart/limb)
	// NOVA EDIT ADDITION - Apply limb transparency to external organ overlays
	if(limb && limb.alpha != 255)
		overlay.alpha = limb.alpha
	// NOVA EDIT END
	overlay.color = sprite_datum.color_src ? (dye_color || draw_color) : null

/datum/bodypart_overlay/mutant/added_to_limb(obj/item/bodypart/limb)
	inherit_color(limb)

///Change our accessory sprite, using the accesssory type. If you need to change the sprite for something, use simple_change_sprite()
/datum/bodypart_overlay/mutant/set_appearance(accessory_type)
	sprite_datum = fetch_sprite_datum(accessory_type)
	cache_key = jointext(generate_icon_cache(), "_")

///In a lot of cases, appearances are stored in DNA as the Name, instead of the path. Use set_appearance instead of possible
/datum/bodypart_overlay/mutant/proc/set_appearance_from_name(accessory_name)
	sprite_datum = fetch_sprite_datum_from_name(accessory_name)
	cache_key = jointext(generate_icon_cache(), "_")

///Generate a unique key based on our sprites. So that if we've aleady drawn these sprites, they can be found in the cache and wont have to be drawn again (blessing and curse, but mostly curse)
/datum/bodypart_overlay/mutant/generate_icon_cache()
	. = list()
	. += "[get_base_icon_state()]"
	. += "[feature_key]"
	. += "[dye_color || draw_color]"
	return .

///Return a dumb glob list for this specific feature (called from parse_sprite)
/datum/bodypart_overlay/mutant/proc/get_global_feature_list()
	var/list/feature_list = SSaccessories.feature_list[feature_key]
	if(isnull(feature_list))
		stack_trace("External organ has no feature list, it will render invisible")
		return list()
	return feature_list

///Give the organ its color. Force will override the existing one.
/datum/bodypart_overlay/mutant/proc/inherit_color(obj/item/bodypart/bodypart_owner, force)
	if(isnull(bodypart_owner))
		draw_color = null
		alpha = 255 // NOVA EDIT ADDITION - Mutant bodyparts transparency are based on limb transparency
		return TRUE

	if(draw_color && !force)
		return FALSE

	alpha = bodypart_owner.alpha // NOVA EDIT ADDITION - Mutant bodyparts transparency are based on limb transparency
	switch(color_source)
		if(ORGAN_COLOR_OVERRIDE)
			draw_color = override_color(bodypart_owner)
		if(ORGAN_COLOR_INHERIT)
			draw_color = bodypart_owner.draw_color
		if(ORGAN_COLOR_HAIR)
			var/datum/species/species = bodypart_owner.owner?.dna?.species
			var/fixed_color = species?.get_fixed_hair_color(bodypart_owner.owner)
			if(!ishuman(bodypart_owner.owner))
				draw_color = fixed_color
				return
			var/mob/living/carbon/human/human_owner = bodypart_owner.owner
			var/obj/item/bodypart/head/my_head = human_owner.get_bodypart(BODY_ZONE_HEAD) //not always the same as bodypart_owner
			//head hair color takes priority, owner hair color is a backup if we lack a head or something
			if(!my_head)
				draw_color = fixed_color || human_owner.hair_color
				return
			if(my_head.head_flags & (HEAD_HAIR|HEAD_FACIAL_HAIR))
				draw_color = my_head.fixed_hair_color || my_head.hair_color
			else //inherit mutant color of the bodypart if the owner doesn't have hair.
				draw_color = bodypart_owner.draw_color

	return TRUE

///Sprite accessories are singletons, stored list("Big Snout" = instance of /datum/sprite_accessory/snout/big), so here we get that singleton
/datum/bodypart_overlay/mutant/proc/fetch_sprite_datum(datum/sprite_accessory/accessory_path)
	return fetch_sprite_datum_from_name(initial(accessory_path.name))

///Get the singleton from the sprite name
/datum/bodypart_overlay/mutant/proc/fetch_sprite_datum_from_name(accessory_name)
	var/list/feature_list = get_global_feature_list()
	var/found = feature_list[accessory_name]
	if(found)
		return found

	if(!length(feature_list))
		CRASH("External organ [type] returned no sprite datums from get_global_feature_list(), so no accessories could be found!")
	else if(accessory_name)
		CRASH("External organ [type] couldn't find sprite accessory [accessory_name]!")
	else
		CRASH("External organ [type] had fetch_sprite_datum called with a null accessory name!")

///From dye sprays. Set the dye_color (draw_color override) of this organ to a new value.
/datum/bodypart_overlay/mutant/proc/set_dye_color(new_color, obj/item/organ/organ)
	dye_color = new_color
	if(organ.owner)
		organ.owner.update_body_parts()
	else
		organ.bodypart_owner?.update_icon_dropped()


// BEGIN NOVA CORE MIGRATION: code/datums/bodypart_overlays/mutant_bodypart_overlay.dm
/// The greatest amount of colors that can be in a matrixed bodypart_overlay.
#define MAX_MATRIXED_COLORS 3
/// Default value for alpha, making it fully opaque.
#define ALPHA_OPAQUE 255

/datum/bodypart_overlay/mutant
	/// Alpha value associated to the overlay, to be inherited from the parent limb.
	var/alpha = ALPHA_OPAQUE
	/// Cached human owner used for MOD-related cache keys.
	var/mob/living/carbon/human/cached_human_owner
	/// An associative list of color indexes (i.e. "1") to boolean that says
	/// whether or not that color should get an emissive overlay. Can be null.
	var/list/emissive_eligibility_by_color_index
	/// A simple list of indexes to color (as we don't want to color emissives, MOD overlays or inner ears)
	var/list/overlay_indexes_to_color
	/// Whether or not this overlay can be affected by MODsuit-related procs.
	var/modsuit_affected = FALSE
	/// Additional information we might want to add to the cache_key, stored into a list.
	/// Should only ever contain strings.
	var/list/cache_key_extra_information
	/// A simple cache of what the last icon_states built were.
	/// It's really only there to help with debugging what's happening.
	var/list/last_built_icon_states


/**
 * Allows us to set the appearance from data that's located within the provided DNA,
 * for a little more control over what exactly is displayed.
 *
 * Arguments:
 * * dna - The `/datum/dna` datum from which we're going to be extracting the data to set the
 * * accessory_name - instead of using the name from mutant_bodyparts[feature_key] you can optionally pass one explicitly
 * * feature_key - same as with accessory_key, you can optionally pass a feature_key explicitly
 * appearance.
 */
/datum/bodypart_overlay/mutant/proc/set_appearance_from_dna(datum/dna/dna, accessory_name, feature_key)
	if(isnull(feature_key)) // if not explicitly set, just use the feature_key of the bodypart_overlay
		feature_key = src.feature_key
	var/list/mutantparts_list = dna.mutant_bodyparts
	if(isnull(mutantparts_list[feature_key]))
		return FALSE
	var/datum/mutant_bodypart/mutant_part = mutantparts_list[feature_key]
	sprite_datum = fetch_sprite_datum_from_name(accessory_name ? accessory_name : mutant_part.name)
	modsuit_affected = sprite_datum.use_custom_mod_icon
	draw_color = mutant_part.get_colors()
	emissive_eligibility_by_color_index = mutant_part.get_emissive_tri_bool_list()
	cache_key = jointext(generate_icon_cache(), "_")
	return TRUE

// We do this here like this so that we handle matrixed color bodypart overlays and emissives.
/datum/bodypart_overlay/mutant/get_overlay(layer, obj/item/bodypart/limb)
	layer = bitflag_to_layer(layer)
	. = get_images(layer, limb)
	color_images(., layer, limb)
	. = add_emissives(., limb)


/// Generate a unique key based on our sprites. So that if we've aleady drawn these sprites,
/// they can be found in the cache and wont have to be drawn again (blessing and curse, but mostly curse)
/datum/bodypart_overlay/mutant/generate_icon_cache()
	. = list()
	. += "[get_base_icon_state()]"
	. += "[get_feature_key_for_overlay()]"

	. += cache_key_extra_information // We can do it like this because it's meant to be a list of strings anyway. BYOND list operations actually being useful for once.
	append_mod_hardlight_cache_key(.)

	if(islist(draw_color))
		for(var/sub_color in draw_color)
			. += "[sub_color]"

	else
		. += "[draw_color]"

	if(alpha != ALPHA_OPAQUE)
		. += "[alpha]"

	if(emissive_eligibility_by_color_index)
		for(var/emissive_boolean in emissive_eligibility_by_color_index)
			. += emissive_boolean

	return .


/datum/bodypart_overlay/mutant/proc/get_active_mod_hardlight_control(mob/living/carbon/human/human_owner = cached_human_owner)
	if(!modsuit_affected || !istype(human_owner))
		return null

	return sprite_datum?.get_mod_hardlight_control(human_owner)


/datum/bodypart_overlay/mutant/proc/append_coloration_cache_key(list/cache_key, coloration)
	if(isnull(coloration))
		return
	if(islist(coloration))
		for(var/color_value in coloration)
			cache_key += "[color_value]"
		return
	cache_key += "[coloration]"


/datum/bodypart_overlay/mutant/proc/append_mod_hardlight_cache_key(list/cache_key)
	var/obj/item/mod/control/modsuit_control = get_active_mod_hardlight_control()
	if(!modsuit_control)
		return

	cache_key += "MOD"
	if(modsuit_control.color || modsuit_control.cached_color_filter)
		cache_key += "MOD_COLOR"
		append_coloration_cache_key(cache_key, modsuit_control.color)
		if(modsuit_control.cached_color_filter)
			cache_key += "MOD_FILTER"
			cache_key += "[modsuit_control.cached_color_filter["space"]]"
			append_coloration_cache_key(cache_key, modsuit_control.cached_color_filter["color"])
		return

	cache_key += "[modsuit_control.theme?.hardlight_theme]"


/**
 * Helper to fetch the `feature_key` of the bodypart_overlay, so that it can be
 * overriden in the cases where `feature_key` is not what we want to use here.
 */
/datum/bodypart_overlay/mutant/proc/get_feature_key_for_overlay()
	return sprite_datum?.feature_key_override || feature_key


/datum/bodypart_overlay/mutant/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/human = bodypart_owner.owner
	cached_human_owner = istype(human) ? human : null
	if(!istype(human))
		return TRUE
	return !isnull(sprite_datum) && !sprite_datum.is_hidden(human)


/// Get the images we need to draw on the person. Called from get_overlay() which is called from _bodyparts.dm.
/// `limb` can be null.
/// This is different from the base procs as it allows for multiple overlays to
/// be generated for one bodypart_overlay. Useful for matrixed color mutant bodyparts.
/datum/bodypart_overlay/mutant/proc/get_images(image_layer, obj/item/bodypart/limb)
	if(!sprite_datum)
		CRASH("Trying to call get_images() on [type] while it didn't have a sprite_datum. This shouldn't happen, report it as soon as possible.")

	var/returned_images = list()
	var/gender = (limb?.limb_gender == FEMALE) ? "f" : "m"

	overlay_indexes_to_color = list()
	var/index = 1

	var/mob/living/carbon/human/owner = limb?.owner
	var/obj/item/mod/control/modsuit_control = get_active_mod_hardlight_control(owner)
	var/mutable_appearance/mod_overlay

	cache_key_extra_information = list()
	last_built_icon_states = list()

	if(modsuit_control)
		mod_overlay = get_singular_image(image_layer = image_layer, owner = owner, icon_override = sprite_datum.build_mod_hardlight_icon(modsuit_control))

	switch(sprite_datum.color_src)
		if(USE_MATRIXED_COLORS)
			var/list/color_layer_names = get_color_layer_names(build_icon_state(gender, image_layer))

			for (var/color_index in color_layer_names)

				var/mutable_appearance/color_layer_image = get_singular_image(build_icon_state(gender, image_layer, color_layer_names[color_index]), image_layer, owner)
				returned_images += color_layer_image

				overlay_indexes_to_color += index
				index++

				if(mod_overlay)
					mod_overlay.add_overlay(sprite_datum.build_mod_hardlight_icon(modsuit_control, color_layer_image))

		else
			var/mutable_appearance/image_to_return = get_singular_image(build_icon_state(gender, image_layer), image_layer, owner)
			returned_images = list(image_to_return)
			overlay_indexes_to_color += index

			if(mod_overlay)
				mod_overlay.add_overlay(sprite_datum.build_mod_hardlight_icon(modsuit_control, image_to_return))

	if(sprite_datum.has_inner)
		returned_images += get_singular_image(build_icon_state(gender, image_layer, feature_key_suffix = "inner"), image_layer, owner)

	// Gets the icon_state of a single or matrix colored accessory and overlays it with a texture
	if(mod_overlay)
		if(modsuit_control.color)
			mod_overlay.color = modsuit_control.color
		if(modsuit_control.cached_color_filter)
			mod_overlay = filter_appearance_recursive(mod_overlay, modsuit_control.cached_color_filter)
		returned_images += mod_overlay

	return returned_images


/**
 * Returns the color_layer_names of the sprite_datum associated with our datum.
 * Mainly here so that it can be overriden elsewhere to have other effects.
 */
/datum/bodypart_overlay/mutant/proc/get_color_layer_names(icon_state_to_lookup)
	return sprite_datum.color_layer_names


/// Colors the given overlays list. Limb can be null.
/// This is different from the base procs as it allows for multiple overlays to be colored at once.
/// Useful for matrixed color mutant bodyparts.
/datum/bodypart_overlay/mutant/proc/color_images(list/image/overlays, layer, obj/item/bodypart/limb)
	if(!sprite_datum || !overlays)
		return

	if(limb?.is_husked)
		if(sprite_datum.color_src == USE_MATRIXED_COLORS) //Matrixed+husk needs special care, otherwise we get sparkle dogs
			draw_color = HUSK_COLOR_LIST
		else
			draw_color = "#AAA" //The gray husk color

	var/i = 1 // Starts at 1 for color layers.
	alpha = limb?.alpha || ALPHA_OPAQUE

	for(var/index_to_color in overlay_indexes_to_color)
		if(index_to_color > length(overlays))
			break

		var/image/overlay = overlays[index_to_color]

		switch(sprite_datum.color_src)
			if(USE_ONE_COLOR)
				overlay.color = islist(draw_color) ? draw_color[i] : draw_color

			if(USE_MATRIXED_COLORS)
				if (i > length(draw_color))
					overlay.color = islist(draw_color) ? draw_color[length(draw_color)] : draw_color
				else
					overlay.color = islist(draw_color) ? draw_color[i] : draw_color
				i++

			else
				overlay.color = limb?.color

		overlay.alpha = alpha


/**
 * Helper to generate the icon_state for the bodypart_overlay we're trying to draw.
 *
 * Arguments:
 * * gender - The gender of the limb. Can be "f" or "m".
 * * image_layer - The layer on which the icon will be drawn.
 * * color_layer - The color_layer of this icon_state, if any. Should be either "primary", "secondary", "tertiary" or `null`.
 * Defaults to `null`.
 * * feature_key_suffix - A string that will be directly appended to the result
 * of `get_feature_key_for_overlay()`. Defaults to `null`.
 */
/datum/bodypart_overlay/mutant/proc/build_icon_state(gender, image_layer, color_layer = null, feature_key_suffix = null)
	var/list/icon_state_builder = list()

	icon_state_builder += sprite_datum.gender_specific ? gender : "m" //Male is default because sprite accessories are so ancient they predate the concept of not hardcoding gender
	icon_state_builder += get_feature_key_for_overlay() + feature_key_suffix
	icon_state_builder += get_base_icon_state()
	icon_state_builder += mutant_bodyparts_layertext(image_layer)

	if(color_layer)
		icon_state_builder += color_layer

	var/built_icon_state = icon_state_builder.Join("_")

	LAZYADD(last_built_icon_states, built_icon_state)

	return built_icon_state


/**
 * Helper to generate one individual image for a multi-image overlay.
 * Very similar to get_image(), just a little simplified.
 *
 * Arguments:
 * * image_icon_state - The icon_state of the mutable_appearance we want to get.
 * * image_layer - The layer of the mutable_appearance we want to get.
 * * owner - The owner of the limb this is drawn on. Can be null.
 * * icon_override - The icon to use for the mutable_appearance, rather than
 * `sprite_datum.icon`. Default is `null`, and its value will be used if it's
 * anything else.
 */
/datum/bodypart_overlay/mutant/proc/get_singular_image(image_icon_state, image_layer, mob/living/carbon/human/owner, icon_override = null)
	// We get from icon_override if it is filled, and from sprite_datum.icon if not.
	var/mutable_appearance/appearance = mutable_appearance(icon_override || sprite_datum.get_special_icon(owner), image_icon_state, layer = image_layer)

	if(sprite_datum.center)
		center_image(appearance, sprite_datum.special_x_dimension ? sprite_datum.get_special_x_dimension(owner) : sprite_datum.dimension_x, sprite_datum.dimension_y)

	return appearance


/**
 * Helper proc to add the appropriate emissives to the overlays, based on the preferences.
 *
 * Arguments:
 * * overlays - The list of mutable appearances previously generated and colored.
 * * limb - The limb containing this bodypart_overlay. Cannot be null, otherwise
 * there's going to be issues with how the emissives are generated, so it won't
 * add them if the limb is missing, somehow.
 */
/datum/bodypart_overlay/mutant/proc/add_emissives(list/image/overlays, obj/item/bodypart/limb)
	if(!limb || !length(emissive_eligibility_by_color_index))
		return overlays

	var/list/image/emissives
	var/max = min(3, length(overlays)) // only care about the first 3 indexes
	for(var/index = 1 to max)
		if(emissive_eligibility_by_color_index[index])
			LAZYADD(emissives, emissive_appearance_copy(overlays[index], limb))

	return emissives ? (overlays + emissives) : overlays

/**
 * Helper to set the MOD-related info on the overlay, useful for MODsuit overlays.
 *
 * Arguments:
 * * status - boolean of whether or not this overlay should currently be under the
 * effect of MODsuit overlays.
 */
/datum/bodypart_overlay/mutant/proc/set_modsuit_status(status, obj/item/mod/control/modsuit_control)
	return


#undef MAX_MATRIXED_COLORS
#undef ALPHA_OPAQUE
// END NOVA CORE MIGRATION: code/datums/bodypart_overlays/mutant_bodypart_overlay.dm
