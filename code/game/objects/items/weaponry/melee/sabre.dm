/obj/item/melee/sabre
	name = "officer's sabre"
	desc = "An elegant weapon, its monomolecular edge is capable of cutting through flesh and bone with ease."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "sabre"
	inhand_icon_state = "sabre"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY | UNIQUE_RENAME
	force = 20
	throwforce = 10
	demolition_mod = 0.75 //but not metal
	w_class = WEIGHT_CLASS_BULKY
	block_chance = 50
	armour_penetration = 75
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("slashes", "cuts")
	attack_verb_simple = list("slash", "cut")
	block_sound = 'sound/items/weapons/parry.ogg'
	hitsound = 'sound/items/weapons/rapierhit.ogg'
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT)
	wound_bonus = 10
	exposed_wound_bonus = 25

/obj/item/melee/sabre/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/cuffable_item) //closed sword guard
	AddComponent(/datum/component/jousting)
	//fast and effective, but as a sword, it might damage the results.
	AddComponent(/datum/component/butchering, \
		speed = 3 SECONDS, \
		effectiveness = 95, \
		bonus_modifier = 5, \
	)
	// The weight of authority comes down on the tider's crimes.
	AddElement(/datum/element/bane, target_type = /mob/living/carbon/human, damage_multiplier = 0.35)
	RegisterSignal(src, COMSIG_OBJECT_PRE_BANING, PROC_REF(attempt_bane))
	RegisterSignal(src, COMSIG_OBJECT_ON_BANING, PROC_REF(bane_effects))

/**
 * If the target reeks of maintenance, the blade can tear through their body with a total of 20 damage.
 */
/obj/item/melee/sabre/proc/attempt_bane(element_owner, mob/living/carbon/criminal)
	SIGNAL_HANDLER
	var/obj/item/organ/liver/liver = criminal.get_organ_slot(ORGAN_SLOT_LIVER)
	if(isnull(liver) || !HAS_TRAIT(liver, TRAIT_MAINTENANCE_METABOLISM))
		return COMPONENT_CANCEL_BANING

/**
 * Assistants should fear this weapon.
 */
/obj/item/melee/sabre/proc/bane_effects(element_owner, mob/living/carbon/human/baned_target)
	SIGNAL_HANDLER
	baned_target.visible_message(
		span_warning("[src] tears through [baned_target] with unnatural ease!"),
		span_userdanger("As [src] tears into your body, you feel the weight of authority collapse into your wounds!"),
	)
	INVOKE_ASYNC(baned_target, TYPE_PROC_REF(/mob/living/carbon/human, emote), "scream")

/obj/item/melee/sabre/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(attack_type == PROJECTILE_ATTACK || attack_type == LEAP_ATTACK || attack_type == OVERWHELMING_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight, and also you aren't going to really block someone full body tackling you with a sword. Or a road roller, if one happened to hit you.
	return ..()

/obj/item/melee/sabre/on_exit_storage(datum/storage/container)
	playsound(container.parent, 'sound/items/unsheath.ogg', 25, TRUE)

/obj/item/melee/sabre/on_enter_storage(datum/storage/container)
	playsound(container.parent, 'sound/items/sheath.ogg', 25, TRUE)

/obj/item/melee/sabre/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is trying to cut off all [user.p_their()] limbs with [src]! it looks like [user.p_theyre()] trying to commit suicide!"))
	var/i = 0
	ADD_TRAIT(src, TRAIT_NODROP, SABRE_SUICIDE_TRAIT)
	if(iscarbon(user))
		var/mob/living/carbon/Cuser = user
		var/obj/item/bodypart/holding_bodypart = Cuser.get_holding_bodypart_of_item(src)
		var/list/limbs_to_dismember
		var/list/arms = list()
		var/list/legs = list()
		var/obj/item/bodypart/bodypart

		for(bodypart in Cuser.get_bodyparts())
			if(bodypart == holding_bodypart)
				continue
			if(bodypart.body_part & ARMS)
				arms += bodypart
			else if (bodypart.body_part & LEGS)
				legs += bodypart

		limbs_to_dismember = arms + legs
		if(holding_bodypart)
			limbs_to_dismember += holding_bodypart

		var/speedbase = abs((4 SECONDS) / limbs_to_dismember.len)
		for(bodypart in limbs_to_dismember)
			i++
			addtimer(CALLBACK(src, PROC_REF(suicide_dismember), user, bodypart), speedbase * i)
	addtimer(CALLBACK(src, PROC_REF(manual_suicide), user), (5 SECONDS) * i)
	return MANUAL_SUICIDE

/obj/item/melee/sabre/proc/suicide_dismember(mob/living/user, obj/item/bodypart/affecting)
	if(!QDELETED(affecting) && !(affecting.bodypart_flags & BODYPART_UNREMOVABLE) && affecting.owner == user && !QDELETED(user))
		playsound(user, hitsound, 25, TRUE)
		affecting.dismember(BRUTE)
		user.adjust_brute_loss(force * 1.25)

/obj/item/melee/sabre/proc/manual_suicide(mob/living/user, originally_nodropped)
	if(!QDELETED(user))
		user.adjust_brute_loss(200)
		user.death(FALSE)
	REMOVE_TRAIT(src, TRAIT_NODROP, SABRE_SUICIDE_TRAIT)


/obj/item/melee/parsnip_sabre
	name = "parsnip sabre"
	desc = "A weird, yet elegant weapon. Surprisingly sharp for something made from a parsnip."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "parsnip_sabre"
	inhand_icon_state = "parsnip_sabre"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 15
	throwforce = 10
	demolition_mod = 0.3
	w_class = WEIGHT_CLASS_BULKY
	block_chance = 40
	armour_penetration = 40
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("slashes", "cuts")
	attack_verb_simple = list("slash", "cut")
	block_sound = 'sound/items/weapons/parry.ogg'
	hitsound = 'sound/items/weapons/rapierhit.ogg'
	custom_materials = null
	wound_bonus = 5
	exposed_wound_bonus = 15

/obj/item/melee/parsnip_sabre/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/cuffable_item) //closed sword guard
	AddComponent(/datum/component/jousting)

/obj/item/melee/parsnip_sabre/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(attack_type == PROJECTILE_ATTACK || attack_type == LEAP_ATTACK || attack_type == OVERWHELMING_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight, and also you aren't going to really block someone full body tackling you with a sword. Or a road roller, if one happened to hit you.
	return ..()

/obj/item/melee/parsnip_sabre/on_exit_storage(datum/storage/container)
	. = ..()
	playsound(container.parent, 'sound/items/unsheath.ogg', 25, TRUE)

/obj/item/melee/parsnip_sabre/on_enter_storage(datum/storage/container)
	. = ..()
	playsound(container.parent, 'sound/items/sheath.ogg', 25, TRUE)


// Sabres, including the cargo variety

/obj/item/storage/belt/sheath/sabre/cargo
	name = "authentic shamshir leather sheath"
	desc = "A good-looking sheath that is advertised as being made of real Venusian black leather. It feels rather plastic-like to the touch, and it looks like it's made to fit a British cavalry sabre."
	icon = 'icons/obj/clothing/belts_additions.dmi'
	worn_icon = 'icons/mob/clothing/belt_additions.dmi'
	stored_blade = /obj/item/melee/sabre/cargo

/obj/item/melee/sabre
	force = 20 // Original: 15
	wound_bonus = 5 // Original: 10
	exposed_wound_bonus = 20 // Original: 25 Both down slightly, to make up for the damage buff, since it'd get a bit wacky ontop of the armor pen.

/obj/item/melee/sabre/cargo
	name = "authentic shamshir sabre"
	desc = "An expertly crafted historical human sword once used by the Persians which has recently gained traction due to Venusian historal recreation sports. One small flaw, the Taj-based company who produces these has mistaken them for British cavalry sabres akin to those used by high ranking Nanotrasen officials. Atleast it cuts the same way!"
	icon_state = "sabre"
	icon = 'icons/obj/weapons/melee/nova_melee.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/melee/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee/swords_righthand.dmi'
	block_chance = 20
	armour_penetration = 25

// This is here so that people can't buy the Sabres and craft them into powercrepes
/datum/crafting_recipe/food/powercrepe
	blacklist = list(/obj/item/melee/sabre/cargo)

// Prevents our common weapons from being used to easily craft stunswords
// Claymore blacklists can be found in code\datums\components\crafting\melee_weapon.dm
/datum/crafting_recipe/stunswordalt
	blacklist = list(/obj/item/katana/weak/curator)

/datum/crafting_recipe/stunswordalt2
	blacklist = list(/obj/item/melee/sabre/cargo)

