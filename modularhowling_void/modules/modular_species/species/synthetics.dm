/datum/species/synthetic/on_species_gain(mob/living/carbon/human/transformer, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if(!istype(transformer))
		return
	ADD_TRAIT(transformer, TRAIT_RESISTHIGHPRESSURE, REF(src))
	ADD_TRAIT(transformer, TRAIT_RESISTLOWPRESSURE, REF(src))
	transformer.AddComponent(/datum/component/anti_magic/synthetic, ALL_MAGIC_RESISTANCE)

/datum/species/synthetic/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	if(istype(human))
		REMOVE_TRAIT(human, TRAIT_RESISTHIGHPRESSURE, REF(src))
		REMOVE_TRAIT(human, TRAIT_RESISTLOWPRESSURE, REF(src))
		qdel(human.GetComponent(/datum/component/anti_magic/synthetic))
	. = ..()

/datum/component/anti_magic/synthetic/block_receiving_magic(mob/living/carbon/source, casted_magic_flags, charge_cost, list/antimagic_sources)
	if(casted_magic_flags & MAGIC_RESISTANCE_SYNTHETIC_ALLOWED)
		return NONE

	return ..()

/datum/component/anti_magic/synthetic/restrict_casting_magic(mob/user, magic_flags)
	return NONE

/mob/living/carbon/human/proc/howling_synthetic_unarmed_feedback(mob/living/carbon/human/attacker, obj/item/bodypart/attacking_bodypart, attack_effect, limb_sharpness, damage)
	if(attacker == src || !issynthetic(src) || !istype(attacker) || !isbodypart(attacking_bodypart))
		return

	if(attacking_bodypart.bodytype & (BODYTYPE_ROBOTIC|BODYTYPE_SYNTHETIC))
		return

	var/self_damage = (attack_effect == ATTACK_EFFECT_BITE) ? rand(3, 6) : rand(2, 5)
	attacker.apply_damage(self_damage, BRUTE, attacking_bodypart, wound_bonus = CANT_WOUND)

	var/break_chance = 8
	var/recoil_message = "[attacker]'s [attacking_bodypart.plaintext_zone] slams painfully into [src]'s hard chassis!"
	var/user_message = "Pain shoots through your [attacking_bodypart.plaintext_zone] as you strike [src]'s hard chassis!"
	var/wound_message = "[attacker]'s [attacking_bodypart.plaintext_zone] gives with a sickening crack!"
	var/user_wound_message = "Something in your [attacking_bodypart.plaintext_zone] cracks against [src]'s chassis!"

	if(attack_effect == ATTACK_EFFECT_BITE)
		break_chance = 12
		recoil_message = "[attacker]'s teeth scrape painfully against [src]'s hard chassis!"
		user_message = "Your teeth ache as they scrape against [src]'s hard chassis!"
		wound_message = "[attacker]'s teeth crack against [src]'s chassis!"
		user_wound_message = "Your teeth crack against [src]'s chassis!"
	else if(limb_sharpness)
		break_chance = 10
		recoil_message = "[attacker]'s claws scrape painfully against [src]'s hard chassis!"
		user_message = "Your claws scrape painfully against [src]'s hard chassis!"
		wound_message = "[attacker]'s claws crack against [src]'s chassis!"
		user_wound_message = "Your claws crack against [src]'s chassis!"

	if(damage >= 9)
		break_chance += 5

	visible_message(span_warning("[recoil_message]"), ignored_mobs = attacker)
	to_chat(attacker, span_userdanger("[user_message]"))

	if(!prob(break_chance))
		return

	playsound(attacker, 'sound/effects/wounds/crack1.ogg', 60, TRUE)
	visible_message(span_danger("[wound_message]"), ignored_mobs = attacker)
	to_chat(attacker, span_userdanger("[user_wound_message]"))
	attacker.cause_wound_of_type_and_severity(WOUND_BLUNT, attacking_bodypart, WOUND_SEVERITY_MODERATE, wound_source = "synthetic chassis")
