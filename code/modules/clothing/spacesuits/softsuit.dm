	//NASA Voidsuit
/obj/item/clothing/head/helmet/space/nasavoid
	name = "NASA Void Helmet"
	desc = "An old, NASA CentCom branch designed, dark red space suit helmet."
	icon_state = "void"
	inhand_icon_state = "void_helmet"

/obj/item/clothing/suit/space/nasavoid
	name = "NASA Voidsuit"
	icon_state = "void"
	inhand_icon_state = "void_suit"
	desc = "An old, NASA CentCom branch designed, dark red space suit."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

/obj/item/clothing/head/helmet/space/nasavoid/old
	name = "Engineering Void Helmet"
	desc = "A CentCom engineering dark red space suit helmet. While old and dusty, it still gets the job done."
	icon_state = "void"
	visor_dirt = "void_dirt"

/obj/item/clothing/suit/space/nasavoid/old
	name = "Engineering Voidsuit"
	icon_state = "void"
	inhand_icon_state = "void_suit"
	desc = "A CentCom engineering dark red space suit. Age has degraded the suit making it difficult to move around in."
	slowdown = 4
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

	//EVA suit
/obj/item/clothing/suit/space/eva
	name = "EVA suit"
	icon_state = "space"
	inhand_icon_state = "s_suit"
	desc = "A lightweight space suit with the basic ability to protect the wearer from the vacuum of space during emergencies."
	armor_type = /datum/armor/space_eva

/obj/item/clothing/head/helmet/space/eva
	name = "EVA helmet"
	icon_state = "space"
	inhand_icon_state = "space_helmet"
	desc = "A lightweight space helmet with the basic ability to protect the wearer from the vacuum of space during emergencies."
	flash_protect = FLASH_PROTECTION_NONE
	armor_type = /datum/armor/space_eva
	visor_dirt = "space_dirt"

/datum/armor/space_eva
	bio = 100
	fire = 50
	acid = 65

/obj/item/clothing/head/helmet/space/eva/examine(mob/user)
	. = ..()
	. += span_notice("You can start constructing a critter sized mecha with a [span_bold("cyborg leg")].")

/obj/item/clothing/head/helmet/space/eva/attackby(obj/item/attacked_with, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(.)
		return
	if(!istype(attacked_with, /obj/item/bodypart/leg/left/robot) && !istype(attacked_with, /obj/item/bodypart/leg/right/robot))
		return
	if(ismob(loc))
		user.balloon_alert(user, "drop the helmet first!")
		return
	user.balloon_alert(user, "leg attached")
	new /obj/item/bot_assembly/vim(loc)
	qdel(attacked_with)
	qdel(src)

#define EMERGENCY_SUIT_MIN_TEMP_PROTECT 237
#define EMERGENCY_SUIT_MAX_TEMP_PROTECT 100
#define EMERGENCY_HELMET_MIN_TEMP_PROTECT 2.0
#define EMERGENCY_HELMET_MAX_TEMP_PROTECT 100

/obj/item/clothing/suit/space/emergency
	name = "emergency space suit"
	desc = "A fragile looking emergency spacesuit for limited use in space."
	icon_state = "syndicate-orange"
	inhand_icon_state = "syndicate-orange"
	heat_protection = NONE
	min_cold_protection_temperature = EMERGENCY_SUIT_MIN_TEMP_PROTECT
	max_heat_protection_temperature = EMERGENCY_SUIT_MAX_TEMP_PROTECT
	armor_type = /datum/armor/space_emergency
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT
	actions_types = null
	show_hud = FALSE
	max_integrity = 100
	slowdown = 3
	/// Whether the suit has torn from damage.
	var/torn = FALSE

/datum/armor/space_emergency
	bio = 20

/obj/item/clothing/suit/space/emergency/equipped(mob/user, slot)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(user_damaged))

/obj/item/clothing/suit/space/emergency/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_APPLY_DAMAGE)

/obj/item/clothing/suit/space/emergency/proc/user_damaged(datum/source, damage, damagetype, def_zone)
	SIGNAL_HANDLER

	if(damage && !torn && prob(50))
		balloon_alert_to_viewers("[src] tears!")
		clothing_flags &= ~STOPSPRESSUREDAMAGE
		torn = TRUE
		playsound(src, 'sound/items/weapons/slashmiss.ogg', 50, TRUE)
		playsound(src, 'sound/effects/refill.ogg', 50, TRUE)
		update_appearance()

/obj/item/clothing/suit/space/emergency/update_name(updates)
	. = ..()
	if(torn)
		name = "torn [src]"

/obj/item/clothing/suit/space/emergency/examine(mob/user)
	. = ..()
	if(torn)
		. += span_danger("It looks torn and useless!")

/obj/item/clothing/head/helmet/space/emergency
	name = "emergency space helmet"
	desc = "A fragile looking emergency spacesuit helmet for limited use in space."
	icon_state = "syndicate-helm-orange"
	inhand_icon_state = "syndicate-helm-orange"
	heat_protection = NONE
	armor_type = /datum/armor/space_emergency
	flash_protect = FLASH_PROTECTION_NONE
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT
	min_cold_protection_temperature = EMERGENCY_HELMET_MIN_TEMP_PROTECT
	max_heat_protection_temperature = EMERGENCY_HELMET_MAX_TEMP_PROTECT

#undef EMERGENCY_SUIT_MIN_TEMP_PROTECT
#undef EMERGENCY_SUIT_MAX_TEMP_PROTECT
#undef EMERGENCY_HELMET_MIN_TEMP_PROTECT
#undef EMERGENCY_HELMET_MAX_TEMP_PROTECT

	//Emergency suit
/obj/item/clothing/head/helmet/space/fragile
	name = "emergency space helmet"
	desc = "A bulky, airtight helmet meant to protect the user during emergency situations. It doesn't look very durable."
	icon_state = "syndicate-helm-orange"
	inhand_icon_state = "syndicate-helm-orange" //resprite?
	armor_type = /datum/armor/space_fragile
	strip_delay = 6.5 SECONDS

/obj/item/clothing/suit/space/fragile
	name = "emergency space suit"
	desc = "A bulky, airtight suit meant to protect the user during emergency situations. It doesn't look very durable."
	var/torn = FALSE
	icon_state = "syndicate-orange"
	inhand_icon_state = "syndicate-orange"
	slowdown = 2
	armor_type = /datum/armor/space_fragile
	strip_delay = 6.5 SECONDS

/datum/armor/space_fragile
	melee = 5

/obj/item/clothing/suit/space/fragile/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(!torn && prob(50))
		to_chat(owner, span_warning("[src] tears from the damage, breaking the airtight seal!"))
		clothing_flags &= ~STOPSPRESSUREDAMAGE
		name = "torn [src]."
		desc = "A bulky suit meant to protect the user during emergency situations, at least until someone tore a hole in the suit."
		torn = TRUE
		playsound(loc, 'sound/items/weapons/slashmiss.ogg', 50, TRUE)
		playsound(loc, 'sound/effects/refill.ogg', 50, TRUE)
