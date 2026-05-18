#define SPELLBLADE_TEMPORAL_FINISHER_THRESHOLD 7
#define SPELLBLADE_REATTUNE_COOLDOWN 2 MINUTES

/obj/item/melee/spellblade
	parent_type = /obj/item/katana
	name = "spellblade"
	desc = "An enchanted blade with a series of runes etched along the side."
	icon = 'icons/obj/weapons/guns/magic.dmi'
	icon_state = "spellblade"
	inhand_icon_state = "spellblade"
	worn_icon_state = "spellblade"
	force = 25
	armour_penetration = 50
	throw_range = 7
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	slot_flags = NONE
	/// Unique enchantment currently bound to the blade.
	var/datum/spellblade_enchantment/enchant
	/// Multiplier used by special reward variants to tune enchant strength.
	var/power = 1
	/// Cooldown before an already attuned spellblade can change enchantment again.
	COOLDOWN_DECLARE(reattune_cooldown)

/obj/item/melee/spellblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
		speed = 1.5 SECONDS, \
		effectiveness = 125, \
		bonus_modifier = 0, \
		butcher_sound = hitsound, \
	)

/obj/item/melee/spellblade/Destroy()
	if(isliving(loc))
		var/mob/living/holder = loc
		enchant?.on_drop(src, holder)
	QDEL_NULL(enchant)
	return ..()

/obj/item/melee/spellblade/examine(mob/user)
	. = ..()
	if(enchant && (IS_WIZARD(user) || IS_CULTIST(user)))
		. += span_notice("The runes read: [enchant.desc].")
		if(COOLDOWN_FINISHED(src, reattune_cooldown))
			. += span_notice("The runes are ready to be retuned.")
		else
			. += span_notice("The runes can be retuned again in [DisplayTimeText(COOLDOWN_TIMELEFT(src, reattune_cooldown))].")

/obj/item/melee/spellblade/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		enchant?.on_pickup(src, user)

/obj/item/melee/spellblade/dropped(mob/user, silent = FALSE)
	. = ..()
	enchant?.on_drop(src, user)

/obj/item/melee/spellblade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(attack_type == OVERWHELMING_ATTACK || attack_type == LEAP_ATTACK)
		final_block_chance = 0
	return ..()

/obj/item/melee/spellblade/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	if(enchant && !COOLDOWN_FINISHED(src, reattune_cooldown))
		to_chat(user, span_notice("[src] can change attunement again in [DisplayTimeText(COOLDOWN_TIMELEFT(src, reattune_cooldown))]."))
		return

	var/list/choices = spellblade_radial_choices()
	var/static/list/options_to_type = list(
		"Lightning" = /datum/spellblade_enchantment/lightning,
		"Fire" = /datum/spellblade_enchantment/fire,
		"Bluespace" = /datum/spellblade_enchantment/bluespace,
		"Forcewall" = /datum/spellblade_enchantment/forcewall,
		"Temporal Slash" = /datum/spellblade_enchantment/time_slash,
	)

	var/choice = show_radial_menu(user, src, choices, require_near = TRUE, tooltips = TRUE)
	if(!choice || QDELETED(src))
		return

	var/selected_enchant = options_to_type[choice]
	if(enchant?.type == selected_enchant)
		balloon_alert(user, "already attuned")
		return

	var/changing_existing_enchant = !!enchant
	add_enchantment(selected_enchant, user)
	if(changing_existing_enchant)
		COOLDOWN_START(src, reattune_cooldown, SPELLBLADE_REATTUNE_COOLDOWN)

/obj/item/melee/spellblade/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(enchant?.pre_hit(interacting_with, user, src, modifiers))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/melee/spellblade/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!isliving(target))
		return

	var/mob/living/living_target = target
	enchant?.on_hit(living_target, user, src, modifiers, attack_modifiers)

/obj/item/melee/spellblade/proc/reset_blade_stats()
	force = initial(force)
	armour_penetration = initial(armour_penetration)
	throw_range = initial(throw_range)

/obj/item/melee/spellblade/proc/add_enchantment(datum/spellblade_enchantment/new_enchant, mob/living/user = null, intentional = TRUE)
	var/mob/living/holder = isliving(loc) ? loc : null
	if(enchant)
		enchant.on_drop(src, holder)
		qdel(enchant)
	reset_blade_stats()

	enchant = new new_enchant
	enchant.power *= power
	enchant.on_apply_to_blade(src)
	enchant.on_gain(src, user)

	if(user && (src in user.held_items))
		enchant.on_pickup(src, user)
	else if(holder && (src in holder.held_items))
		enchant.on_pickup(src, holder)

	if(intentional)
		SSblackbox.record_feedback("nested tally", "spellblade_enchants", 1, list("[enchant.name]"))
		if(user)
			to_chat(user, span_notice("[src]'s runes flare with [enchant.name] magic."))

/obj/item/melee/spellblade/proc/spellblade_radial_choices()
	var/static/list/choices
	if(choices)
		return choices

	choices = list()

	var/datum/radial_menu_choice/lightning = new()
	lightning.image = image(icon = 'icons/effects/effects.dmi', icon_state = "lightning1")
	lightning.info = "Shock target and chain lightning to nearby victims every 3 seconds."
	choices["Lightning"] = lightning

	var/datum/radial_menu_choice/fire = new()
	fire.image = image(icon = 'icons/effects/fire.dmi', icon_state = "heavy")
	fire.info = "Ignite a fiery blast around your victim every 8 seconds."
	choices["Fire"] = fire

	var/datum/radial_menu_choice/bluespace = new()
	bluespace.image = image(icon = 'icons/effects/effects.dmi', icon_state = "bluestream_fade")
	bluespace.info = "Click a visible target at range to blink beside them and strike."
	choices["Bluespace"] = bluespace

	var/datum/radial_menu_choice/forcewall = new()
	forcewall.image = image(icon = 'icons/effects/effects.dmi', icon_state = "shield-old")
	forcewall.info = "Landing hits wraps you in a ward that shrugs off stuns and softens damage."
	choices["Forcewall"] = forcewall

	var/datum/radial_menu_choice/temporal = new()
	temporal.image = image(icon = 'icons/effects/effects.dmi', icon_state = "chronofield")
	temporal.info = "Cuts faster but weaker, then time catches up in a delayed flurry."
	choices["Temporal Slash"] = temporal

	return choices

/obj/item/melee/spellblade/random
	power = 0.5

/obj/item/melee/spellblade/random/Initialize(mapload)
	. = ..()
	var/list/options = list(
		/datum/spellblade_enchantment/lightning,
		/datum/spellblade_enchantment/fire,
		/datum/spellblade_enchantment/forcewall,
		/datum/spellblade_enchantment/bluespace,
		/datum/spellblade_enchantment/time_slash,
	)
	add_enchantment(pick(options), null, FALSE)

/datum/spellblade_enchantment
	/// Blackbox and flavor name.
	var/name = "unknown"
	/// Rune text shown to the magically literate.
	var/desc = "The runes are unreadable."
	/// Numeric strength used by subtypes.
	var/power = 1
	/// Whether the enchant can trigger from non-adjacent clicks.
	var/ranged = FALSE
	/// Time between activations.
	var/cooldown = 0
	/// Whether hand-applied traits are currently active on the wielder.
	var/applied_traits = FALSE
	COOLDOWN_DECLARE(enchant_cooldown)

/datum/spellblade_enchantment/proc/on_hit(mob/living/target, mob/living/user, obj/item/melee/spellblade/spellblade, list/modifiers, list/attack_modifiers)
	if(!COOLDOWN_FINISHED(src, enchant_cooldown) || !istype(target) || QDELETED(target) || target.stat == DEAD)
		return FALSE
	return TRUE

/datum/spellblade_enchantment/proc/pre_hit(atom/target, mob/living/user, obj/item/melee/spellblade/spellblade, list/modifiers)
	if(!ranged || !isliving(target))
		return FALSE
	if(!COOLDOWN_FINISHED(src, enchant_cooldown))
		return FALSE

	var/mob/living/living_target = target
	if(QDELETED(living_target) || living_target.stat == DEAD)
		return FALSE
	return TRUE

/datum/spellblade_enchantment/proc/on_gain(obj/item/melee/spellblade/spellblade, mob/living/user)
	return

/datum/spellblade_enchantment/proc/on_pickup(obj/item/melee/spellblade/spellblade, mob/living/user)
	return

/datum/spellblade_enchantment/proc/on_drop(obj/item/melee/spellblade/spellblade, mob/living/user)
	return

/datum/spellblade_enchantment/proc/on_apply_to_blade(obj/item/melee/spellblade/spellblade)
	return

/datum/spellblade_enchantment/lightning
	name = "lightning"
	desc = "This blade conducts arcane energy that arcs between its victims. It also shields the wielder from shocks."
	power = 20
	cooldown = 3 SECONDS

/datum/spellblade_enchantment/lightning/on_pickup(obj/item/melee/spellblade/spellblade, mob/living/user)
	if(applied_traits || !isliving(user))
		return
	ADD_TRAIT(user, TRAIT_SHOCKIMMUNE, REF(src))
	applied_traits = TRUE

/datum/spellblade_enchantment/lightning/on_drop(obj/item/melee/spellblade/spellblade, mob/living/user)
	if(!applied_traits || !isliving(user))
		return
	REMOVE_TRAIT(user, TRAIT_SHOCKIMMUNE, REF(src))
	applied_traits = FALSE

/datum/spellblade_enchantment/lightning/on_hit(mob/living/target, mob/living/user, obj/item/melee/spellblade/spellblade, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!.)
		return
	zap(target, user, list(user), power)
	COOLDOWN_START(src, enchant_cooldown, cooldown)

/datum/spellblade_enchantment/lightning/proc/zap(mob/living/target, mob/living/source, list/protected_mobs, voltage)
	if(QDELETED(target) || QDELETED(source))
		return

	source.Beam(target, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
	if(!target.electrocute_act(voltage, "spellblade lightning", flags = SHOCK_TESLA))
		return

	protected_mobs += target
	addtimer(CALLBACK(src, PROC_REF(arc), target, voltage, protected_mobs), 2.5 SECONDS)

/datum/spellblade_enchantment/lightning/proc/arc(mob/living/source, voltage, list/protected_mobs)
	if(QDELETED(source))
		return

	voltage -= 4
	if(voltage <= 0)
		return

	for(var/mob/living/next_target in oview(7, get_turf(source)))
		if(next_target in protected_mobs)
			continue
		zap(next_target, source, protected_mobs, voltage)
		break

/datum/spellblade_enchantment/fire
	name = "fire"
	desc = "This blade erupts in fire on a landed strike, and its wielder is protected from flame."
	cooldown = 8 SECONDS

/datum/spellblade_enchantment/fire/on_pickup(obj/item/melee/spellblade/spellblade, mob/living/user)
	if(applied_traits || !isliving(user))
		return
	ADD_TRAIT(user, TRAIT_RESISTHEAT, REF(src))
	ADD_TRAIT(user, TRAIT_NOFIRE, REF(src))
	applied_traits = TRUE

/datum/spellblade_enchantment/fire/on_drop(obj/item/melee/spellblade/spellblade, mob/living/user)
	if(!applied_traits || !isliving(user))
		return
	REMOVE_TRAIT(user, TRAIT_RESISTHEAT, REF(src))
	REMOVE_TRAIT(user, TRAIT_NOFIRE, REF(src))
	applied_traits = FALSE

/datum/spellblade_enchantment/fire/on_hit(mob/living/target, mob/living/user, obj/item/melee/spellblade/spellblade, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!.)
		return

	var/turf/center = get_turf(target)
	if(!center)
		return

	playsound(center, 'sound/effects/magic/fireball.ogg', 75, TRUE)
	for(var/turf/nearby_turf in range(4, center))
		nearby_turf.hotspot_expose(8000 * power, 500, TRUE)
		new /obj/effect/temp_visual/fire(nearby_turf)

	for(var/mob/living/burned_target in range(4, center))
		if(QDELETED(burned_target) || burned_target.stat == DEAD)
			continue
		burned_target.apply_damage(max(5, 10 * power), BURN, spread_damage = TRUE)
		burned_target.adjust_fire_stacks(max(2, round(4 * power)))
		burned_target.ignite_mob()

	COOLDOWN_START(src, enchant_cooldown, cooldown)

/datum/spellblade_enchantment/forcewall
	name = "forcewall"
	desc = "This blade shields you from stuns and softens incoming pain for a short while after a landed blow."
	cooldown = 4 SECONDS
	power = 2

/datum/spellblade_enchantment/forcewall/on_apply_to_blade(obj/item/melee/spellblade/spellblade)
	cooldown /= power

/datum/spellblade_enchantment/forcewall/on_hit(mob/living/target, mob/living/user, obj/item/melee/spellblade/spellblade, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!.)
		return

	user.apply_status_effect(/datum/status_effect/spellblade_force_shield)
	COOLDOWN_START(src, enchant_cooldown, cooldown)

/datum/spellblade_enchantment/bluespace
	name = "bluespace"
	desc = "This blade cuts through space itself, blinking its wielder beside distant prey for a sudden strike."
	cooldown = 2.5 SECONDS
	ranged = TRUE
	power = 5

/datum/spellblade_enchantment/bluespace/on_hit(mob/living/target, mob/living/user, obj/item/melee/spellblade/spellblade, list/modifiers, list/attack_modifiers)
	return FALSE

/datum/spellblade_enchantment/bluespace/pre_hit(atom/target, mob/living/user, obj/item/melee/spellblade/spellblade, list/modifiers)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/living_target = target
	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(living_target)
	if(!user_turf || !target_turf)
		return FALSE

	if(get_dist(user_turf, target_turf) > 9)
		return FALSE
	if(!((living_target in view(9, user)) || (user.sight & SEE_MOBS)))
		return FALSE

	var/list/turf/possible_turfs = list()
	for(var/turf/adjacent_turf in orange(1, target_turf))
		if(adjacent_turf.is_blocked_turf(exclude_mobs = TRUE, source_atom = user))
			continue
		possible_turfs += adjacent_turf

	if(!length(possible_turfs))
		return FALSE

	var/turf/destination = pick(possible_turfs)
	new /obj/effect/temp_visual/bluespace_fissure(user_turf)
	new /obj/effect/temp_visual/bluespace_fissure(destination)
	if(!do_teleport(user, destination, 0, asoundin = 'sound/effects/phasein.ogg', no_effects = TRUE, channel = TELEPORT_CHANNEL_BLUESPACE))
		return FALSE

	COOLDOWN_START(src, enchant_cooldown, cooldown)
	spellblade.melee_attack_chain(user, living_target, modifiers)
	if(!QDELETED(living_target) && living_target.stat != DEAD)
		living_target.Paralyze(max(0.25 SECONDS, power * 0.1 SECONDS))
		living_target.Knockdown(max(1.5 SECONDS, power * 0.6 SECONDS))

	return TRUE

/datum/spellblade_enchantment/bluespace/on_apply_to_blade(obj/item/melee/spellblade/spellblade)
	cooldown /= spellblade.power

/datum/spellblade_enchantment/time_slash
	name = "temporal"
	desc = "This blade cuts faster but weaker, storing every slice until time snaps back at the victim."
	power = 20

/datum/spellblade_enchantment/time_slash/on_apply_to_blade(obj/item/melee/spellblade/spellblade)
	spellblade.force /= 2

/datum/spellblade_enchantment/time_slash/on_hit(mob/living/target, mob/living/user, obj/item/melee/spellblade/spellblade, list/modifiers, list/attack_modifiers)
	user.changeNext_move(CLICK_CD_MELEE * 0.5)
	. = ..()
	if(!.)
		return
	target.apply_status_effect(/datum/status_effect/spellblade_temporal_slash, power)

/datum/status_effect/spellblade_force_shield
	id = "spellblade_force_shield"
	duration = 10 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/spellblade_force_shield/on_apply()
	owner.add_stun_absorption(
		source = id,
		priority = 4,
		self_message = span_notice("A shimmering ward absorbs the stun!"),
		examine_message = span_notice("%EFFECT_OWNER_THEYRE wrapped in a humming shield."),
	)
	owner.add_filter(id, 2, list("type" = "outline", "color" = "#8bd7ff", "alpha" = 180, "size" = 2))
	new /obj/effect/temp_visual/impact_effect/ion(get_turf(owner))
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.stamina_mod *= 0.1
		human_owner.physiology.brute_mod *= 0.5
		human_owner.physiology.burn_mod *= 0.5
	return TRUE

/datum/status_effect/spellblade_force_shield/on_remove()
	owner.remove_stun_absorption(id)
	owner.remove_filter(id)
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.stamina_mod *= 10
		human_owner.physiology.brute_mod *= 2
		human_owner.physiology.burn_mod *= 2

/datum/status_effect/spellblade_temporal_slash
	id = "spellblade_temporal_slash"
	duration = 3 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	var/cuts = 1
	var/damage_per_cut = 20

/datum/status_effect/spellblade_temporal_slash/on_creation(mob/living/new_owner, cut_damage = 20)
	damage_per_cut = cut_damage
	return ..()

/datum/status_effect/spellblade_temporal_slash/refresh(mob/living/new_owner, cut_damage = 20)
	duration = initial(duration)
	cuts++
	damage_per_cut = cut_damage

/datum/status_effect/spellblade_temporal_slash/on_remove()
	if(!QDELETED(owner) && cuts > 0)
		owner.apply_status_effect(/datum/status_effect/spellblade_temporal_slash_finisher, cuts, damage_per_cut)

/datum/status_effect/spellblade_temporal_slash_finisher
	id = "spellblade_temporal_slash_finisher"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 0.25 SECONDS
	alert_type = null
	var/cuts = 1
	var/damage_per_cut = 20
	var/finishing_cuts = FALSE

/datum/status_effect/spellblade_temporal_slash_finisher/on_creation(mob/living/new_owner, final_cuts = 1, cut_damage = 20)
	cuts = final_cuts
	damage_per_cut = cut_damage
	if(ismegafauna(new_owner))
		damage_per_cut *= 4
	if(cuts >= SPELLBLADE_TEMPORAL_FINISHER_THRESHOLD)
		finishing_cuts = TRUE
	return ..()

/datum/status_effect/spellblade_temporal_slash_finisher/on_apply()
	if(cuts <= 0)
		return FALSE
	owner.visible_message(
		span_warning("Time begins to tear around [owner]!"),
		span_userdanger("Time begins to tear around you!"),
	)
	return TRUE

/datum/status_effect/spellblade_temporal_slash_finisher/tick(seconds_between_ticks)
	if(QDELETED(owner) || owner.stat == DEAD)
		qdel(src)
		return

	playsound(owner, 'sound/items/weapons/rapierhit.ogg', 50, TRUE)
	new /obj/effect/temp_visual/spellblade_temporal_slash(get_turf(owner), owner)

	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		var/hit_zone = carbon_owner.get_random_valid_zone(even_weights = TRUE)
		owner.apply_damage(damage = damage_per_cut, damagetype = BRUTE, def_zone = hit_zone, sharpness = SHARP_EDGED, wound_bonus = 5)
	else
		owner.apply_damage(damage = damage_per_cut, damagetype = BRUTE, sharpness = SHARP_EDGED, wound_bonus = 5)

	cuts--
	if(cuts <= 0)
		qdel(src)

/datum/status_effect/spellblade_temporal_slash_finisher/on_remove()
	if(finishing_cuts && !QDELETED(owner) && owner.stat != DEAD)
		owner.Knockdown(7 SECONDS)

/obj/effect/temp_visual/spellblade_temporal_slash
	name = "temporal slash"
	desc = "A cut through spacetime."
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "arcane_barrage"
	layer = FLY_LAYER
	appearance_flags = PIXEL_SCALE | LONG_GLIDE
	duration = 0.5 SECONDS
	var/list/funky_color_matrix = list(0.4,0,0,0, 0,1.1,0,0, 0,0,1.65,0, -0.3,0.15,0,1, 0,0,0,0)

/obj/effect/temp_visual/spellblade_temporal_slash/Initialize(mapload, atom/target)
	. = ..()
	if(target)
		pixel_x = rand(-12, 12)
		pixel_y = rand(-12, 12)

	var/matrix/transform_matrix = matrix()
	transform_matrix.Scale(1, 2)
	transform_matrix.Turn(rand(0, 360))
	transform = transform_matrix
	color = funky_color_matrix
	animate(src, alpha = 0, time = duration, easing = EASE_OUT)

#undef SPELLBLADE_TEMPORAL_FINISHER_THRESHOLD
#undef SPELLBLADE_REATTUNE_COOLDOWN
