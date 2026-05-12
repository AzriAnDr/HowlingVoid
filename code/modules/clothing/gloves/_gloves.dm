/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/clothing/gloves.dmi'
	inhand_icon_state = "greyscale_gloves"
	lefthand_file = 'icons/mob/inhands/clothing/gloves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/gloves_righthand.dmi'
	abstract_type = /obj/item/clothing/gloves
	greyscale_colors = null
	greyscale_config_inhand_left = /datum/greyscale_config/gloves_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/gloves_inhand_right
	siemens_coefficient = 0.5
	body_parts_covered = HANDS
	slot_flags = ITEM_SLOT_GLOVES
	drop_sound = 'sound/items/handling/glove_drop.ogg'
	pickup_sound = 'sound/items/handling/glove_pick_up.ogg'
	attack_verb_continuous = list("challenges")
	attack_verb_simple = list("challenge")
	strip_delay = 2 SECONDS
	equip_delay_other = 4 SECONDS
	article = "a pair of"

	// Path variable. If defined, will produced the type through interaction with wirecutters.
	var/cut_type = null
	/// Used for handling bloody gloves leaving behind bloodstains on objects. Will be decremented whenever a bloodstain is left behind, and be incremented when the gloves become bloody.
	var/transfer_blood = 0
	/// Maximum number of rings that can be attached to these gloves.
	var/max_rings = 1
	/// List of rings currently attached to these gloves.
	var/list/obj/item/clothing/gloves/ring/attached_rings
	/// Ring currently worn under these gloves.
	var/obj/item/clothing/gloves/ring/covered_ring
	/// Overlay appearance used when a ring is attached.
	var/mutable_appearance/ring_overlay

/obj/item/clothing/gloves/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/clothing/gloves/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()
	var/changed = FALSE
	if(istype(held_item, /obj/item/clothing/gloves/ring) && LAZYLEN(attached_rings) < max_rings)
		context[SCREENTIP_CONTEXT_LMB] = "Attach ring"
		changed = TRUE
	if(LAZYLEN(attached_rings))
		context[SCREENTIP_CONTEXT_ALT_RMB] = "Remove ring"
		changed = TRUE
	return changed ? CONTEXTUAL_SCREENTIP_SET : .

/obj/item/clothing/gloves/apply_fantasy_bonuses(bonus)
	. = ..()
	siemens_coefficient = modify_fantasy_variable("siemens_coefficient", siemens_coefficient, -bonus / 10)

/obj/item/clothing/gloves/remove_fantasy_bonuses(bonus)
	siemens_coefficient = reset_fantasy_variable("siemens_coefficient", siemens_coefficient)
	return ..()

/obj/item/clothing/gloves/wash(clean_types)
	. = ..()
	if((clean_types & CLEAN_TYPE_BLOOD) && transfer_blood > 0)
		transfer_blood = 0
		. |= COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP

/obj/item/clothing/gloves/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("\the [src] are forcing [user]'s hands around [user.p_their()] neck! It looks like the gloves are possessed!"))
	return OXYLOSS

/obj/item/clothing/gloves/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return
	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damagedgloves")
	if(LAZYLEN(attached_rings))
		var/obj/item/clothing/gloves/ring/ring = attached_rings[1]
		var/overlay_state = ring.worn_icon_state ? ring.worn_icon_state : ring.icon_state
		var/mutable_appearance/worn_ring_overlay = mutable_appearance(ring.worn_icon, overlay_state)
		worn_ring_overlay.alpha = ring.alpha
		worn_ring_overlay.color = ring.color
		. += worn_ring_overlay

/obj/item/clothing/gloves/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file, mutant_styles) // NOVA EDIT CHANGE - ORIGINAL: /obj/item/clothing/gloves/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file)
	. = ..()
	if (isinhands)
		return
	var/blood_overlay = get_blood_overlay("glove")
	if (blood_overlay)
		. += blood_overlay

/obj/item/clothing/gloves/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_worn_gloves()

/obj/item/clothing/gloves/proc/can_cut_with(obj/item/tool)
	if(!cut_type)
		return FALSE
	if(icon_state != initial(icon_state))
		return FALSE // We don't want to cut dyed gloves.
	return TRUE

/obj/item/clothing/gloves/attackby(obj/item/tool, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(tool, /obj/item/clothing/gloves/ring))
		return attach_ring(tool, user)
	. = ..()
	if(.)
		return
	if(tool.tool_behaviour != TOOL_WIRECUTTER && !tool.get_sharpness())
		return
	if (!can_cut_with(tool))
		return
	balloon_alert(user, "cutting off fingertips...")

	if(!do_after(user, 3 SECONDS, target=src, extra_checks = CALLBACK(src, PROC_REF(can_cut_with), tool)))
		return
	balloon_alert(user, "cut fingertips off")
	qdel(src)
	user.put_in_hands(new cut_type)
	return TRUE

/// Attach a ring to these gloves.
/obj/item/clothing/gloves/proc/attach_ring(obj/item/clothing/gloves/ring/ring, mob/living/user)
	if(LAZYLEN(attached_rings) >= max_rings)
		if(user)
			balloon_alert(user, "already has a ring!")
		return FALSE
	if(user && !user.temporarilyRemoveItemFromInventory(ring))
		return FALSE
	LAZYADD(attached_rings, ring)
	ring.forceMove(src)
	create_ring_overlay()
	if(user)
		balloon_alert(user, "ring attached")
	update_appearance()
	if(ismob(loc))
		var/mob/M = loc
		M.update_worn_gloves()
	return TRUE

/// Put an already worn ring under these gloves.
/obj/item/clothing/gloves/proc/cover_ring(obj/item/clothing/gloves/ring/ring)
	if(covered_ring || !istype(ring))
		return FALSE
	covered_ring = ring
	ring.forceMove(src)
	return TRUE

/// Remove the ring worn under these gloves.
/obj/item/clothing/gloves/proc/uncover_ring()
	var/obj/item/clothing/gloves/ring/ring = covered_ring
	covered_ring = null
	return ring

/// Remove a ring from these gloves and optionally return it to the user's hands.
/obj/item/clothing/gloves/proc/pop_ring(mob/living/user)
	if(!LAZYLEN(attached_rings))
		return
	var/obj/item/clothing/gloves/ring/ring = attached_rings[1]
	remove_ring(ring)
	if(user)
		user.put_in_hands(ring)
		ring.balloon_alert(user, "ring removed")

/// Remove a specific ring from the attachment list and update overlays.
/obj/item/clothing/gloves/proc/remove_ring(obj/item/clothing/gloves/ring/ring)
	LAZYREMOVE(attached_rings, ring)
	if(ring_overlay)
		cut_overlay(ring_overlay)
	ring_overlay = null
	if(LAZYLEN(attached_rings))
		create_ring_overlay()
	update_appearance()
	if(ismob(loc))
		var/mob/M = loc
		M.update_worn_gloves()

/// Rebuild the ring overlay from the first attached ring.
/obj/item/clothing/gloves/proc/create_ring_overlay()
	var/obj/item/clothing/gloves/ring/ring = attached_rings[1]
	ring_overlay = ring.build_ring_overlay()
	add_overlay(ring_overlay)

/// Drop all attached rings to a location.
/obj/item/clothing/gloves/proc/dump_rings(atom/drop_to = drop_location())
	for(var/obj/item/clothing/gloves/ring/ring as anything in attached_rings)
		ring.forceMove(drop_to)
	attached_rings = null
	if(covered_ring)
		covered_ring.forceMove(drop_to)
		covered_ring = null
	if(ring_overlay)
		cut_overlay(ring_overlay)
	ring_overlay = null

/obj/item/clothing/gloves/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == covered_ring)
		covered_ring = null
	if(istype(gone, /obj/item/clothing/gloves/ring) && (gone in attached_rings))
		LAZYREMOVE(attached_rings, gone)
		if(ring_overlay)
			cut_overlay(ring_overlay)
		ring_overlay = null
		if(LAZYLEN(attached_rings))
			create_ring_overlay()
		update_appearance()
		if(ismob(loc))
			var/mob/M = loc
			M.update_worn_gloves()

/obj/item/clothing/gloves/atom_destruction(damage_flag)
	dump_rings()
	return ..()

/obj/item/clothing/gloves/Destroy()
	covered_ring = null
	attached_rings = null
	return ..()

/obj/item/clothing/gloves/click_alt_secondary(mob/user)
	if(!LAZYLEN(attached_rings))
		balloon_alert(user, "no ring to remove!")
		return
	pop_ring(user)

/obj/item/clothing/gloves/examine(mob/user)
	. = ..()
	if(LAZYLEN(attached_rings))
		. += "Alt-Right-Click to remove [attached_rings[1]]."
	return .
