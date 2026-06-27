/*
Future guncoder, turn back before you are overwhelmed by the horrifically scattered nature of ammunition in this codebase.
Or don't, and suffer for your hubris. In all seriousness, ammo overrides are horrendously scattered, and you're going to
have to jump through a lot of different files in case you're doing something stupid, like a categorization project
that tags every bullet with a category for rebalancing the ammo bench, or something vaguely among those lines.

In case that doesn't stop you, you're going to want to look through:
- The entirety of this module, specifically the ammo.dm files
- code/modules/shotgunrebalance/shotgun.dm
- More to be listed as we go along.
*/


/obj/item/ammo_casing/foam_dart
	ammo_categories = AMMO_CLASS_NONE

/obj/item/ammo_casing/c160smart
	ammo_categories = AMMO_CLASS_LETHAL // surplus gun has it rough enough already

/*
*	.38 Special
*/

/obj/item/ammo_casing/c38/trac
	ammo_categories = AMMO_CLASS_NICHE_LTL // tracking implant bullets
	custom_materials = AMMO_MATS_TRAC

/obj/item/ammo_casing/c38/match
	ammo_categories = AMMO_CLASS_NICHE // ricocheting as a gimmick. tight tolerances

/obj/item/ammo_casing/c38/match/bouncy
	ammo_categories = AMMO_CLASS_NONE // less-lethal so no categories needed
	harmful = FALSE

/obj/item/ammo_casing/c38/match/true
	ammo_categories = AMMO_CLASS_NICHE // less damage but funkier ricochets than match

/obj/item/ammo_casing/c38/dumdum
	ammo_categories = AMMO_CLASS_PLUS // sucks against armor but embeds good? basically HP

/obj/item/ammo_casing/c38/hotshot
	ammo_categories = AMMO_CLASS_NICHE // temp bullets.
	custom_materials = AMMO_MATS_TEMP

/obj/item/ammo_casing/c38/iceblox
	ammo_categories = AMMO_CLASS_NICHE // temp bullets.
	custom_materials = AMMO_MATS_TEMP

/obj/item/ammo_casing/c38/holy
	can_be_printed = FALSE // it's the chaplain's

/obj/item/ammo_casing/c38/haywire
	name = ".38 Haywire bullet casing"
	desc = "A .38 Haywire bullet casing, with an electromagnetic generator in the tip.\
		<br><br>\
		<i>HAYWIRE: Electromagnetic pulse ammo. Deals little damage, but causes a small electromagnetic pulse.</i>"
	projectile_type = /obj/projectile/bullet/c38/haywire
	ammo_categories = AMMO_CLASS_NICHE
	custom_materials = AMMO_MATS_EMP

// ammo boxes
/obj/item/ammo_box/speedloader/c38
	caliber = CALIBER_38

/obj/item/ammo_box/speedloader/c38/haywire
	name = "speed loader (.38 Haywire)"
	desc = "Designed to quickly reload revolvers. These rounds create small electromagnetic pulses upon impact."
	ammo_type = /obj/item/ammo_casing/c38/haywire
	ammo_band_color = COLOR_AMMO_EMP

/obj/item/ammo_box/magazine/m38/haywire
	name = "battle rifle magazine (.38 Haywire)"
	desc = parent_type::desc + " These bullets create small electromagnetic pulses on impact; devastating against electronics."
	ammo_type = /obj/item/ammo_casing/c38/haywire
	ammo_band_color = COLOR_AMMO_EMP

/*
*	.357 Magnum
*/

/obj/item/ammo_casing/c357/match
	desc = "A .357 bullet casing, manufactured to exceedingly high standards.\
		<br><br>\
		<i>MATCH: Ricochets everywhere. Like crazy.</i>"
	ammo_categories = AMMO_CLASS_NICHE // ricocheting as a gimmick. tight tolerances

/obj/item/ammo_casing/c357/phasic
	desc = "A .357 phasic bullet casing.\
		<br><br>\
		<i>PHASIC: Ignores all surfaces except organic matter.</i>"
	ammo_categories = AMMO_CLASS_ESOTERIC
	custom_materials = AMMO_MATS_PHASIC

/obj/item/ammo_casing/c357/heartseeker
	desc = "A .357 heartseeker bullet casing.\
		<br><br>\
		<i>HEARTSEEKER: Has homing capabilities, methodology unknown.</i>"
	ammo_categories = AMMO_CLASS_ESOTERIC
	custom_materials = AMMO_MATS_HOMING // meme ammo. meme print cost

/obj/item/ammo_casing/c357/haywire
	name = ".357 Haywire+ bullet casing"
	desc = "A .357 Haywire+ bullet casing, with a high-efficiency electromagnetic generator in the tip.\
		<br><br>\
		<i>HAYWIRE+: Electromagnetic pulse ammo. Deals moderate damage, and cause a small, but powerful, electromagnetic pulse.</i>"
	projectile_type = /obj/projectile/bullet/c357/haywire
	ammo_categories = AMMO_CLASS_NICHE
	custom_materials = AMMO_MATS_EMP

// ammo boxes

/obj/item/ammo_box/speedloader/c357/haywire
	name = "speed loader (.357 Haywire+)"
	desc = "Designed to quickly reload revolvers. These rounds create small, but powerful electromagnetic pulses upon impact."
	ammo_type = /obj/item/ammo_casing/c357/haywire
	ammo_band_color = COLOR_AMMO_EMP

/*
*	.45
*/

/obj/item/ammo_casing/c45/ap
	desc = "An armor-piercing .45 bullet casing.\
		<br><br>\
		<i>ARMOR PIERCING: Increased armor piercing capabilities. Reduced stopping power.</i>"
	custom_materials = AMMO_MATS_AP
	ammo_categories = AMMO_CLASS_PLUS

/obj/item/ammo_casing/c45/hp
	desc = "A hollow-point .45 bullet casing.\
		<br><br>\
		<i>HOLLOW-POINT: Very lethal against unarmored opponents. Suffers against armor.</i>"
	ammo_categories = AMMO_CLASS_PLUS

/obj/item/ammo_casing/c45/inc
	desc = "An incendiary .45 bullet casing.\
		<br><br>\
		<i>INCENDIARY: Leaves a trail of fire when shot, sets targets aflame.</i>"
	custom_materials = AMMO_MATS_TEMP
	ammo_categories = AMMO_CLASS_NICHE

/obj/item/ammo_casing/c45/rubber
	name = ".45 rubber bullet casing"
	desc = "A .45 rubber bullet casing.\
		<br><br>\
		<i>RUBBER: Less than lethal ammo. Deals both stamina damage and regular damage.</i>"
	projectile_type = /obj/projectile/bullet/c45/rubber
	ammo_categories = AMMO_CLASS_NONE
	harmful = FALSE

/obj/item/ammo_box/c45/large
	name = "deluxe ammo box (.45)"
	max_ammo = 60

/*
*	9mm
*/

/obj/item/ammo_casing/c9mm/ap
	desc = "A 9mm armor-piercing bullet casing.\
		<br><br>\
		<i>ARMOR PIERCING: Increased armor piercing capabilities. Reduced stopping power.</i>"
	ammo_categories = AMMO_CLASS_PLUS
	custom_materials = AMMO_MATS_AP

/obj/item/ammo_casing/c9mm/hp
	desc = "A 9mm hollow-point bullet casing.\
		<br><br>\
		<i>HOLLOW-POINT: Very lethal against unarmored opponents. Suffers against armor.</i>"
	ammo_categories = AMMO_CLASS_PLUS

/obj/item/ammo_casing/c9mm/fire
	desc = "A 9mm incendiary bullet casing.\
		<br><br>\
		<i>INCENDIARY: Leaves a trail of fire when shot, sets targets aflame.</i>"
	ammo_categories = AMMO_CLASS_NICHE
	custom_materials = AMMO_MATS_TEMP

/obj/item/ammo_casing/c9mm/ihdf
	name = "9mm IHDF bullet casing"
	desc = "A 9mm IHDF bullet casing.\
		<br><br>\
		<i>INTELLIGENT HIGH-IMPACT DISPERSAL FOAM: Deals only stamina damage.</i>"
	projectile_type = /obj/projectile/bullet/c9mm/ihdf
	ammo_categories = AMMO_CLASS_NONE
	harmful = FALSE

/obj/item/ammo_casing/c9mm/rubber
	name = "9mm rubber bullet casing"
	desc = "A 9mm rubber bullet casing.\
		<br><br>\
		<i>RUBBER: Less than lethal ammo. Deals both stamina damage and regular damage.</i>"
	projectile_type = /obj/projectile/bullet/c9mm/rubber
	ammo_categories = AMMO_CLASS_NONE
	harmful = FALSE

/*
*	10mm Auto
*/

/obj/item/ammo_casing/c10mm/ap
	desc = "A 10mm armor-piercing bullet casing.\
		<br><br>\
		<i>ARMOR PIERCING: Increased armor piercing capabilities. Reduced stopping power.</i>"
	ammo_categories = AMMO_CLASS_PLUS
	custom_materials = AMMO_MATS_AP

/obj/item/ammo_casing/c10mm/hp
	desc = "A 10mm hollow-point bullet casing.\
		<br><br>\
		<i>HOLLOW-POINT: Very lethal against unarmored opponents. Suffers against armor.</i>"
	ammo_categories = AMMO_CLASS_PLUS

/obj/item/ammo_casing/c10mm/fire
	desc = "A 10mm incendiary bullet casing.\
		<br><br>\
		<i>INCENDIARY: Leaves a trail of fire when shot, sets targets aflame.</i>"
	ammo_categories = AMMO_CLASS_NICHE
	custom_materials = AMMO_MATS_TEMP

/obj/item/ammo_casing/c10mm/ihdf
	name = "10mm IHDF bullet casing"
	desc = "A 10mm IHDF bullet casing.\
		<br><br>\
		<i>INTELLIGENT HIGH-IMPACT DISPERSAL FOAM: Deals only stamina damage.</i>"
	projectile_type = /obj/projectile/bullet/c10mm/ihdf
	ammo_categories = AMMO_CLASS_NONE
	harmful = FALSE

/obj/item/ammo_casing/c10mm/rubber
	name = "10mm rubber bullet casing"
	desc = "A 10mm rubber bullet casing.\
		<br><br>\
		<i>RUBBER: Less than lethal ammo. Deals both stamina damage and regular damage.</i>"
	projectile_type = /obj/projectile/bullet/c10mm/rubber
	ammo_categories = AMMO_CLASS_NONE
	harmful = FALSE

/obj/item/ammo_casing/c10mm/downer
	name = "10mm downer bullet casing"
	desc = "A 10mm downer bullet casing.\
		<br><br>\
		<i>DOWNER: Nonlethal ammo. Deals heavy stamina damage. Fully exhausted targets go to sleep. \
		Partially exhausted targets have a chance to sleep, scaling with how much exhaustion they have. \
		Inflicts drowsiness, regardless.</i>"
	projectile_type = /obj/projectile/bullet/c10mm/downer
	ammo_categories = AMMO_CLASS_SUPER_LTL
	harmful = FALSE

/obj/item/ammo_casing/c10mm/reaper
	can_be_printed = FALSE
	// it's a hitscan 50 damage 40 AP bullet designed to be fired out of a gun with a 2rnd burst and 1.25x damage multiplier
	// Let's Not

/obj/item/ammo_box/c10mm/large
	name = "deluxe ammo box (10mm)"
	max_ammo = 48 // multiple of 8, multiple of 12


/*
*	4.6x30mm
*/

/obj/item/ammo_casing/c46x30mm/ap
	desc = "A 4.6x30mm armor-piercing bullet casing.\
		<br><br>\
		<i>ARMOR PIERCING: Increased armor piercing capabilities. Reduced stopping power.</i>"
	ammo_categories = AMMO_CLASS_PLUS
	custom_materials = AMMO_MATS_AP

/obj/item/ammo_casing/c46x30mm/inc
	desc = "A 4.6x30mm incendiary bullet casing.\
		<br><br>\
		<i>INCENDIARY: Leaves a trail of fire when shot, sets targets aflame.</i>"
	ammo_categories = AMMO_CLASS_NICHE
	custom_materials = AMMO_MATS_TEMP

/*
*	.223
*/

/obj/item/ammo_casing/a223/weak
	can_be_printed = FALSE

/obj/item/ammo_casing/a223/phasic
	desc = "A .223 phasic bullet casing.\
		<br><br>\
		<i>PHASIC: Ignores all surfaces except organic matter.</i>"
	ammo_categories = AMMO_CLASS_ESOTERIC
	custom_materials = AMMO_MATS_PHASIC

/obj/item/ammo_casing/a223/rubber
	name = ".223 rubber bullet casing"
	desc = "A .223 rubber bullet casing.\
		<br><br>\
		<i>RUBBER: Less than lethal ammo. Deals both stamina damage and regular damage.</i>"
	ammo_categories = AMMO_CLASS_NONE
	projectile_type = /obj/projectile/bullet/a223/rubber
	harmful = FALSE

/obj/item/ammo_casing/a223/ap
	name = ".223 armor-piercing bullet casing"
	desc = "A .223 armor-piercing bullet casing.\
		<br><br>\
		<i>ARMOR PIERCING: Increased armor piercing capabilities.</i>"
	projectile_type = /obj/projectile/bullet/a223/ap
	ammo_categories = AMMO_CLASS_PLUS
	custom_materials = AMMO_MATS_AP

/obj/projectile/bullet/a223/ap
	name = ".223 armor-piercing bullet"
	damage = 30
	armour_penetration = 60

/*
*	7mm (L6 SAW)
*/

/obj/item/ammo_casing/m7mm/ap
	ammo_categories = AMMO_CLASS_PLUS
	custom_materials = AMMO_MATS_AP

/obj/item/ammo_casing/m7mm/hollow
	ammo_categories = AMMO_CLASS_PLUS

/obj/item/ammo_casing/m7mm/incen
	ammo_categories = AMMO_CLASS_NICHE
	custom_materials = AMMO_MATS_TEMP

/obj/item/ammo_casing/m7mm/match
	ammo_categories = AMMO_CLASS_NICHE

/obj/item/ammo_casing/m7mm/bouncy
	ammo_categories = AMMO_CLASS_NICHE

/*
*	.50 BMG
*/

/obj/item/ammo_casing/p50
	ammo_categories = AMMO_CLASS_SUPER
	custom_materials = AMMO_MATS_HEAVY

/obj/item/ammo_casing/p50/surplus
	desc = "A .50 BMG surplus bullet casing.\
		<br><br>\
		<i>SURPLUS: Lacks innate armor penetration, contact-stun, or innate dismemberment ability. Still incredibly painful to be hit by.</i>"
	ammo_categories = AMMO_CLASS_LETHAL

/obj/item/ammo_casing/p50/disruptor
	desc = "A .50 BMG disruptor bullet casing.\
		<br><br>\
		<i>DISRUPTOR: Forces humanoid targets to sleep, does heavy damage against cyborgs, EMPs struck targets.</i>"
	ammo_categories = AMMO_CLASS_SUPER | AMMO_CLASS_NICHE
	custom_materials = AMMO_MATS_HEAVY

/obj/item/ammo_casing/p50/incendiary
	desc = "A .50 BMG incendiary bullet casing.\
		<br><br>\
		<i>INCENDIARY: Lacks innate dismemberment ability and contact-stun. Creates hotspots on impact. Sets people very on fire.</i>"
	projectile_type = /obj/projectile/bullet/p50/incendiary
	ammo_categories = AMMO_CLASS_SUPER | AMMO_CLASS_NICHE
	custom_materials = AMMO_MATS_HEAVY

/obj/item/ammo_casing/p50/penetrator
	desc = "A .50 BMG penetrator bullet casing.\
		<br><br>\
		<i>PENETRATOR: Goes through basically everything. Lacks innate dismemberment ability and contact-stun.</i>"
	ammo_categories = AMMO_CLASS_SUPER | AMMO_CLASS_NICHE
	custom_materials = AMMO_MATS_HEAVY

/obj/item/ammo_casing/p50/marksman
	desc = "A .50 BMG marksman bullet casing.\
		<br><br>\
		<i>MARKSMAN: Bullets have <b>no</b> travel time, and can ricochet once. Does slightly less damage, lacks innate dismemberment and contact-stun.</i>"
	ammo_categories = AMMO_CLASS_SUPER | AMMO_CLASS_NICHE
	custom_materials = AMMO_MATS_HEAVY_FAST

/*
*	.310 Strilka
*/
/obj/item/ammo_casing/strilka310/surplus
	can_be_printed = FALSE

/obj/item/ammo_casing/strilka310/lionhunter
	name = "hunter's rifle round"
	can_be_printed = FALSE // trust me bro you dont wanna give security homing wallhack Better Rubbers

/obj/item/ammo_casing/strilka310/enchanted
	name = "enchanted rifle round"
	can_be_printed = FALSE // these are Really Really Better Rubbers

/obj/item/ammo_casing/strilka310/phasic
	ammo_categories = AMMO_CLASS_SUPER | AMMO_CLASS_ESOTERIC
	custom_materials = AMMO_MATS_PHASIC

/obj/item/ammo_casing/strilka310/rubber
	name = ".310 Strilka rubber bullet casing"
	desc = "A .310 rubber bullet casing. Casing is a bit of a fib, there isn't one.\
		<br><br>\
		<i>RUBBER: Less than lethal ammo. Deals both stamina damage and regular damage.</i>"

	icon = 'icons/obj/weapons/ammo/xhihao_light_arms/ammo.dmi'
	icon_state = "310-casing-rubber"

	projectile_type = /obj/projectile/bullet/strilka310/rubber
	ammo_categories = AMMO_CLASS_NONE
	harmful = FALSE

/obj/projectile/bullet/strilka310
	damage = 45 // Upstream, the crew-guns that use this have a notable delay on firing, and jam so this has to be dropped a bit

/obj/projectile/bullet/strilka310/rubber
	name = ".310 rubber bullet"
	damage = 15
	stamina = 35
	ricochets_max = 5
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embed_data = null

/obj/item/ammo_casing/strilka310/ap
	name = ".310 Strilka armor-piercing bullet casing"
	desc = "A .310 armor-piercing bullet casing. Casing is a bit of a fib, there isn't one.\
		<br><br>\
		<i>ARMOR-PIERCING: Improved armor-piercing capabilities, in return for less outright damage.</i>"

	icon = 'icons/obj/weapons/ammo/xhihao_light_arms/ammo.dmi'
	icon_state = "310-casing-ap"

	projectile_type = /obj/projectile/bullet/strilka310/ap
	ammo_categories = AMMO_CLASS_PLUS
	custom_materials = AMMO_MATS_AP

/obj/projectile/bullet/strilka310/ap
	name = ".310 armor-piercing bullet"
	damage = 35
	armour_penetration = 60

/*
*	40mm (yes, the grenade)
*/
/obj/item/ammo_casing/a40mm
	ammo_categories = AMMO_CLASS_SUPER
	custom_materials = AMMO_MATS_HEAVY

/obj/item/ammo_casing/a40mm/rubber
	ammo_categories = AMMO_CLASS_NICHE_LTL


// .38

/obj/projectile/bullet/c38
	// tg base damage 25, wound bonus -20
	// 25*1.35 = 35
	damage = 25
	wound_bonus = -10

/obj/projectile/bullet/c38/match/bouncy
	// tg base damage 10, stamina 30
	// 10*1.35 = 13.5, rounded up
	// stamina mildly buffed for funsies
	damage = 12
	stamina = 35

/obj/projectile/bullet/c38/match/true
	// tg base damage 15
	// 15*1.35 = 20.25, rounded down
	damage = 15

/obj/projectile/bullet/c38/dumdum
	// tg base damage 15, embed falloff -15
	damage = 15
	embed_falloff_tile = -10

/datum/embedding/bullet/c38/dumdum
	// tg base embed chance 75
	embed_chance = 85

/obj/projectile/bullet/c38/hotshot
	// tg base damage 20
	// 20*1.35 = 27, rounding up
	damage = 20

/obj/projectile/bullet/c38/iceblox
	damage = 20 // originally 20 on TG

/obj/projectile/bullet/c38/haywire
	name = ".38 haywire bullet"
	damage = 20
	ricochets_max = 0
	embed_type = null
	/// EMP radius when this bullet hits a target.
	var/emp_radius = 0

/obj/projectile/bullet/c38/haywire/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	empulse(target, 0, emp_radius)
	new /obj/effect/temp_visual/emp/pulse(get_turf(target))

// .357

/obj/projectile/bullet/c357/haywire
	name = ".357 Haywire+ bullet"
	damage = 40
	ricochets_max = 0
	embed_type = null
	/// EMP radius when this bullet hits a target.
	var/emp_radius = 1

/obj/projectile/bullet/c357/haywire/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	empulse(target, emp_radius, emp_radius)
	new /obj/effect/temp_visual/emp/pulse(get_turf(target))

// .45

/obj/projectile/bullet/c45/rubber
	name = ".45 rubber bullet"
	damage = 10
	stamina = 30
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embed_data = null
	wound_bonus = -50

// 9mm

/obj/projectile/bullet/c9mm/ihdf
	name = "9mm IHDF bullet"
	damage = 30
	damage_type = STAMINA
	embed_type = /datum/embedding/c9mm_ihdf

/datum/embedding/c9mm_ihdf
	embed_chance = 0
	fall_chance = 3
	jostle_chance = 4
	pain_mult = 5
	pain_stam_pct = 0.4
	ignore_throwspeed_threshold = TRUE
	jostle_pain_mult = 6
	rip_time = 1 SECONDS

/obj/projectile/bullet/c9mm/rubber
	name = "9mm rubber bullet"
	icon_state = "pellet"
	damage = 5
	stamina = 25
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = null
	sharpness = NONE
	embed_type = null

// 10mm

/obj/projectile/bullet/c10mm/rubber
	name = "10mm rubber bullet"
	damage = 10
	stamina = 35
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = null
	sharpness = NONE
	embed_type = null

/obj/projectile/bullet/c10mm/ihdf
	name = "10mm IHDF bullet"
	damage = 40
	damage_type = STAMINA
	embed_type = /datum/embedding/c10mm_ihdf

/datum/embedding/c10mm_ihdf
	embed_chance = 0
	fall_chance = 3
	jostle_chance = 4
	ignore_throwspeed_threshold = TRUE
	pain_stam_pct = 0.4
	pain_mult = 5
	jostle_pain_mult = 6
	rip_time = 1 SECONDS

/obj/projectile/bullet/c10mm/downer
	name = "10mm downer bullet"
	damage = 45
	damage_type = STAMINA
	embed_type = null

/obj/projectile/bullet/c10mm/downer/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if((blocked != 100) && isliving(target))
		var/mitigate_percent = 1 - (blocked / 100)
		var/mob/living/living_guy = target
		// make them drowsy, scaling with how much was mitigated
		// future todo: revisit this. dizzy/mute on hit? mitigated by armor?
		living_guy.adjust_drowsiness_up_to(6 SECONDS * mitigate_percent, 12 SECONDS)
		// and see if we can just sleep them outright:
		var/stamcritted_target = HAS_TRAIT_FROM(target, TRAIT_INCAPACITATED, STAMINA)
		var/stamina_ratio = (living_guy.get_stamina_loss() / living_guy.getMaxHealth()) * 50 // 100 / 2
		// if they're stamcrit, sleep them
		if(stamcritted_target)
			living_guy.AdjustSleeping(10 SECONDS) // long naptime for you, buddy
			to_chat(living_guy, span_warning("As [src] hits you, you feel the heavy burden of exhaustion quickly set in..."))
			return
		// or, if they're exhausted, roll to sleep them for a very short time
		else if(prob(stamina_ratio))
			living_guy.AdjustSleeping(1 SECONDS * mitigate_percent) // short naptime but it throws them off something fierce
			to_chat(living_guy, span_warning("As [src] hits you, you feel exhaustion set in."))
			return

// .223

/obj/projectile/bullet/a223/rubber
	name = ".223 rubber bullet"
	damage = 10
	armour_penetration = 10
	stamina = 30
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embed_data = null
	wound_bonus = -50
