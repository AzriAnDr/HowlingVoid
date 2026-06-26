/obj/item/clothing/glasses/hud
	gender = NEUTER
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags_1 = null //doesn't protect eyes because it's a monocle, duh
	actions_types = list(/datum/action/item_action/toggle_wearable_hud)
	/// Whether the HUD info is on or off
	var/display_active = TRUE

/obj/item/clothing/glasses/hud/emp_act(severity)
	. = ..()
	if(obj_flags & EMAGGED || . & EMP_PROTECT_SELF)
		return
	obj_flags |= EMAGGED
	desc = "[desc] The display is flickering slightly."

/obj/item/clothing/glasses/hud/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	balloon_alert(user, "display scrambled")
	desc = "[desc] The display is flickering slightly."
	return TRUE

/obj/item/clothing/glasses/hud/suicide_act(mob/living/user)
	if(user.is_blind())
		return SHAME
	var/mob/living/living_user = user
	user.visible_message(span_suicide("[user] looks through [src] and looks overwhelmed with the information! It looks like [user.p_theyre()] trying to commit suicide!"))
	if(living_user.get_organ_loss(ORGAN_SLOT_BRAIN) >= BRAIN_DAMAGE_SEVERE)
		var/mob/thing = pick((/mob in view()) - user)
		if(thing)
			user.say("VALID MAN IS WANTER, ARREST HE!!")
			user.pointed(thing)
		else
			user.say("WHY IS THERE A BAR ON MY HEAD?!!")
	return OXYLOSS

/obj/item/clothing/glasses/hud/equipped(mob/living/user, slot)
	. = ..()
	display_active = TRUE

/obj/item/clothing/glasses/hud/proc/toggle_hud_display(mob/living/carbon/eye_owner)
	if(display_active)
		display_active = FALSE
		for(var/hud_trait in clothing_traits)
			REMOVE_CLOTHING_TRAIT(eye_owner, hud_trait)
		balloon_alert(eye_owner, "hud disabled")
		return

	display_active = TRUE
	for(var/hud_trait in clothing_traits)
		ADD_CLOTHING_TRAIT(eye_owner, hud_trait)
	balloon_alert(eye_owner, "hud enabled")

/obj/item/clothing/glasses/hud/health
	name = "health scanner HUD"
	desc = "A heads-up display that scans the humanoids in view and provides accurate data about their health status."
	icon_state = "healthhud"
	clothing_traits = list(TRAIT_MEDICAL_HUD)
	glass_colour_type = /datum/client_colour/glass_colour/lightblue

/obj/item/clothing/glasses/hud/health/prescription
	name = "prescription health scanner HUD"
	desc = "A heads-up display that scans the humanoids in view and provides accurate data about their health status. This one has prescription lenses."
	icon = 'icons/huds/huds.dmi'
	icon_state = "glasses_healthhud"
	worn_icon = 'icons/huds/hudeyes.dmi'

/obj/item/clothing/glasses/hud/health/prescription/Initialize(mapload)
	LAZYADD(clothing_traits, TRAIT_NEARSIGHTED_CORRECTED)
	return ..()

/obj/item/clothing/glasses/hud/medsechud
	name = "health scanner security HUD"
	desc = "A heads-up display that scans the humanoids in view and provides accurate data about their health status, ID status and security records."
	icon_state = "medsechud"
	clothing_traits = list(TRAIT_MEDICAL_HUD, TRAIT_SECURITY_HUD)

/obj/item/clothing/glasses/hud/health/night
	name = "night vision health scanner HUD"
	desc = "An advanced medical heads-up display that allows doctors to find patients in complete darkness."
	icon_state = "healthhudnight"
	inhand_icon_state = "glasses"
	flash_protect = FLASH_PROTECTION_SENSITIVE
	flags_cover = GLASSESCOVERSEYES
	// Blue green, dark
	color_cutoffs = list(20, 20, 45)
	glass_colour_type = /datum/client_colour/glass_colour/lightgreen
	actions_types = list(/datum/action/item_action/toggle_nv)

/obj/item/clothing/glasses/hud/health/night/update_icon_state()
	. = ..()
	icon_state = length(color_cutoffs) ? initial(icon_state) : "night_off"

/obj/item/clothing/glasses/hud/health/night/meson
	name = "night vision meson health scanner HUD"
	desc = "Truly combat ready."
	vision_flags = SEE_TURFS

/obj/item/clothing/glasses/hud/health/night/science
	name = "night vision medical science scanner HUD"
	desc = "A clandestine medical science heads-up display that allows operatives to find \
		both dying captains and the perfect poison to finish them off, all in complete darkness."
	clothing_traits = list(TRAIT_REAGENT_SCANNER, TRAIT_MEDICAL_HUD)

/obj/item/clothing/glasses/hud/health/sunglasses
	gender = PLURAL
	name = "medical HUDSunglasses"
	desc = "Sunglasses with a medical HUD."
	icon_state = "sunhudmed"
	flash_protect = FLASH_PROTECTION_FLASH
	flags_cover = GLASSESCOVERSEYES
	tint = 1
	glass_colour_type = /datum/client_colour/glass_colour/blue
	custom_materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.55, /datum/material/iron = SMALL_MATERIAL_AMOUNT / 2)

/obj/item/clothing/glasses/hud/health/sunglasses/Initialize(mapload)
	. = ..()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/hudsunmedremoval)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/obj/item/clothing/glasses/hud/diagnostic
	name = "diagnostic HUD"
	desc = "A heads-up display capable of analyzing the integrity and status of robotics and exosuits."
	icon_state = "diagnostichud"
	clothing_traits = list(TRAIT_DIAGNOSTIC_HUD)
	glass_colour_type = /datum/client_colour/glass_colour/lightorange

/obj/item/clothing/glasses/hud/diagnostic/prescription
	name = "prescription diagnostic HUD"
	desc = "A heads-up display capable of analyzing the integrity and status of robotics and exosuits. This one has prescription lenses."
	icon = 'icons/huds/huds.dmi'
	icon_state = "glasses_diagnostichud"
	worn_icon = 'icons/huds/hudeyes.dmi'

/obj/item/clothing/glasses/hud/diagnostic/prescription/Initialize(mapload)
	LAZYADD(clothing_traits, TRAIT_NEARSIGHTED_CORRECTED)
	return ..()

/obj/item/clothing/glasses/hud/diagnostic/night
	name = "night vision diagnostic HUD"
	desc = "A robotics diagnostic HUD fitted with a light amplifier."
	icon_state = "diagnostichudnight"
	inhand_icon_state = "glasses"
	flash_protect = FLASH_PROTECTION_SENSITIVE
	flags_cover = GLASSESCOVERSEYES
	// Pale yellow
	color_cutoffs = list(25, 15, 5)
	glass_colour_type = /datum/client_colour/glass_colour/lightyellow
	actions_types = list(/datum/action/item_action/toggle_nv)

/obj/item/clothing/glasses/hud/diagnostic/night/update_icon_state()
	. = ..()
	icon_state = length(color_cutoffs) ? initial(icon_state) : "night_off"

/obj/item/clothing/glasses/hud/diagnostic/sunglasses
	gender = PLURAL
	name = "diagnostic sunglasses"
	desc = "Sunglasses with a diagnostic HUD."
	icon_state = "sunhuddiag"
	inhand_icon_state = "glasses"
	flash_protect = FLASH_PROTECTION_FLASH
	flags_cover = GLASSESCOVERSEYES
	tint = 1
	custom_materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.55, /datum/material/iron = SMALL_MATERIAL_AMOUNT / 2)

/obj/item/clothing/glasses/hud/diagnostic/sunglasses/Initialize(mapload)
	. = ..()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/hudsundiagremoval)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/obj/item/clothing/glasses/hud/security
	name = "security HUD"
	desc = "A heads-up display that scans the humanoids in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	clothing_traits = list(TRAIT_SECURITY_HUD)
	glass_colour_type = /datum/client_colour/glass_colour/red

/obj/item/clothing/glasses/hud/security/prescription
	name = "prescription security HUD"
	desc = "A heads-up display that scans the humanoids in view and provides accurate data about their ID status and security records. This one has prescription lenses."
	icon = 'icons/huds/huds.dmi'
	icon_state = "glasses_securityhud"
	worn_icon = 'icons/huds/hudeyes.dmi'

/obj/item/clothing/glasses/hud/security/prescription/Initialize(mapload)
	LAZYADD(clothing_traits, TRAIT_NEARSIGHTED_CORRECTED)
	return ..()

/obj/item/clothing/glasses/hud/security/prescription/setup_reskins()
	return

/datum/atom_skin/security_hudglasses
	abstract_type = /datum/atom_skin/security_hudglasses
	new_icon = 'icons/obj/clothing/glasses_additions.dmi'
	new_worn_icon = 'icons/mob/clothing/eyes_additions.dmi'

/datum/atom_skin/security_hudglasses/red
	preview_name = "Red HUD"
	new_icon = 'icons/obj/clothing/glasses.dmi'
	new_icon_state = "securityhud"
	new_worn_icon = 'icons/mob/clothing/eyes.dmi'

/datum/atom_skin/security_hudglasses/blue
	preview_name = "Blue HUD"
	new_icon_state = "security_hud"

/obj/item/clothing/glasses/hud/security/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/security_hudglasses)

/obj/item/clothing/glasses/hud/security/chameleon
	name = "chameleon security HUD"
	desc = "A stolen security HUD integrated with Syndicate chameleon technology. Provides flash protection."
	flash_protect = FLASH_PROTECTION_FLASH
	actions_types = list(/datum/action/item_action/chameleon/change/glasses/no_preset)

/obj/item/clothing/glasses/hud/security/sunglasses/eyepatch
	name = "eyepatch HUD"
	desc = "The cooler looking cousin of HUDSunglasses."
	icon_state = "hudpatch"
	base_icon_state = "hudpatch"
	actions_types = list(/datum/action/item_action/flip)

/datum/atom_skin/security_eyepatch
	abstract_type = /datum/atom_skin/security_eyepatch

/datum/atom_skin/security_eyepatch/red
	preview_name = "Red Eyepatches"
	new_icon_state = "hudpatch"

/datum/atom_skin/security_eyepatch/blue
	preview_name = "Blue Eyepatches"
	new_icon = 'icons/obj/clothing/glasses_additions.dmi'
	new_icon_state = "hudpatch"
	new_worn_icon = 'icons/mob/clothing/eyes_additions.dmi'

/obj/item/clothing/glasses/hud/security/sunglasses/eyepatch/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/security_eyepatch)

/obj/item/clothing/glasses/hud/security/sunglasses/eyepatch/attack_self(mob/user, modifiers)
	. = ..()
	icon_state = (icon_state == base_icon_state) ? "[base_icon_state]_flipped" : base_icon_state
	user.update_worn_glasses()

/obj/item/clothing/glasses/hud/security/sunglasses
	gender = PLURAL
	name = "security HUDSunglasses"
	desc = "Sunglasses with a security HUD."
	icon_state = "sunhudsec"
	flash_protect = FLASH_PROTECTION_FLASH
	flags_cover = GLASSESCOVERSEYES
	tint = 1
	glass_colour_type = /datum/client_colour/glass_colour/darkred
	custom_materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.55, /datum/material/iron = SMALL_MATERIAL_AMOUNT / 2)

/obj/item/clothing/glasses/hud/security/sunglasses/setup_reskins()
	return

/datum/atom_skin/security_hud_sunglasses
	abstract_type = /datum/atom_skin/security_hud_sunglasses

/datum/atom_skin/security_hud_sunglasses/dark
	preview_name = "Dark-Tint Blue Sunglasses"
	new_icon = 'icons/obj/clothing/glasses_additions.dmi'
	new_icon_state = "security_hud_blue_black"
	new_worn_icon = 'icons/mob/clothing/eyes_additions.dmi'

/datum/atom_skin/security_hud_sunglasses/light
	preview_name = "Light-Tint Blue Sunglasses"
	new_icon = 'icons/obj/clothing/glasses_additions.dmi'
	new_icon_state = "security_hud_blue"
	new_worn_icon = 'icons/mob/clothing/eyes_additions.dmi'

/obj/item/clothing/glasses/hud/security/sunglasses/blue
	icon = 'icons/obj/clothing/glasses_additions.dmi'
	worn_icon = 'icons/mob/clothing/eyes_additions.dmi'
	icon_state = "security_hud_blue_black"
	worn_icon_state = "security_hud_blue_black"

/obj/item/clothing/glasses/hud/security/sunglasses/blue/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/security_hud_sunglasses)

/obj/item/clothing/glasses/hud/security/sunglasses/peacekeeper
	name = "peacekeeper hud glasses"
	icon = 'icons/obj/clothing/glasses_additions.dmi'
	worn_icon = 'icons/mob/clothing/eyes_additions.dmi'
	icon_state = "peacekeeperglasses"

/obj/item/clothing/glasses/hud/security/sunglasses/Initialize(mapload)
	. = ..()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/hudsunsecremoval)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/obj/item/clothing/glasses/hud/security/night
	name = "night vision security HUD"
	desc = "An advanced heads-up display that provides ID data and vision in complete darkness."
	icon_state = "securityhudnight"
	flash_protect = FLASH_PROTECTION_SENSITIVE
	flags_cover = GLASSESCOVERSEYES
	// Red with a tint of green
	color_cutoffs = list(40, 15, 10)
	glass_colour_type = /datum/client_colour/glass_colour/lightred
	actions_types = list(/datum/action/item_action/toggle_nv)

/obj/item/clothing/glasses/hud/security/night/setup_reskins()
	return

/obj/item/clothing/glasses/hud/security/night/update_icon_state()
	. = ..()
	icon_state = length(color_cutoffs) ? initial(icon_state) : "night_off"

/obj/item/clothing/glasses/hud/security/sunglasses/gars
	gender = PLURAL
	name = "\improper HUD gar glasses"
	desc = "GAR glasses with a HUD."
	icon_state = "gar_sec"
	inhand_icon_state = "gar_black"
	alternate_worn_layer = ABOVE_BODY_FRONT_HEAD_LAYER
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb_continuous = list("slices")
	attack_verb_simple = list("slice")
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED

/datum/atom_skin/sec_gars
	abstract_type = /datum/atom_skin/sec_gars

/datum/atom_skin/sec_gars/red
	preview_name = "Red Gars"
	new_icon_state = "gar_sec"

/datum/atom_skin/sec_gars/blue
	preview_name = "Blue Gars"
	new_icon = 'icons/obj/clothing/glasses_additions.dmi'
	new_icon_state = "gar_sec"
	new_worn_icon = 'icons/mob/clothing/eyes_additions.dmi'

/obj/item/clothing/glasses/hud/security/sunglasses/gars/setup_reskins()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/sec_gars)

/obj/item/clothing/glasses/hud/security/sunglasses/gars/giga
	name = "giga HUD gar glasses"
	desc = "GIGA GAR glasses with a HUD."
	icon_state = "gigagar_sec"
	force = 12
	throwforce = 12

/obj/item/clothing/glasses/hud/security/sunglasses/gars/giga/setup_reskins()
	return

/obj/item/clothing/glasses/hud/toggle
	name = "Toggle HUD"
	desc = "A hud with multiple functions."
	flags_cover = GLASSESCOVERSEYES
	actions_types = list(/datum/action/item_action/switch_hud)

/obj/item/clothing/glasses/hud/toggle/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/wearer = user
	if (wearer.glasses != src)
		return

	if (TRAIT_MEDICAL_HUD in clothing_traits)
		detach_clothing_traits(TRAIT_MEDICAL_HUD)
	else if (TRAIT_SECURITY_HUD in clothing_traits)
		detach_clothing_traits(TRAIT_MEDICAL_HUD)
		attach_clothing_traits(TRAIT_SECURITY_HUD)
	else
		detach_clothing_traits(TRAIT_MEDICAL_HUD)
		attach_clothing_traits(TRAIT_SECURITY_HUD)

/datum/action/item_action/switch_hud
	name = "Switch HUD"

/obj/item/clothing/glasses/hud/toggle/thermal
	name = "thermal HUD scanner"
	desc = "Thermal imaging HUD in the shape of glasses."
	icon_state = "thermal"
	vision_flags = SEE_MOBS
	color_cutoffs = list(25, 8, 5)
	glass_colour_type = /datum/client_colour/glass_colour/red
	clothing_traits = list(TRAIT_SECURITY_HUD)

/obj/item/clothing/glasses/hud/toggle/thermal/attack_self(mob/user)
	..()
	var/hud_type
	if (LAZYLEN(clothing_traits))
		hud_type = clothing_traits[1]
	switch (hud_type)
		if (TRAIT_MEDICAL_HUD)
			icon_state = "meson"
			color_cutoffs = list(5, 15, 5)
			change_glass_color(/datum/client_colour/glass_colour/green)
		if (TRAIT_SECURITY_HUD)
			icon_state = "thermal"
			color_cutoffs = list(25, 8, 5)
			change_glass_color(/datum/client_colour/glass_colour/red)
		else
			icon_state = "purple"
			color_cutoffs = list(15, 0, 25)
			change_glass_color(/datum/client_colour/glass_colour/purple)
	user.update_sight()
	user.update_worn_glasses()

/obj/item/clothing/glasses/hud/toggle/thermal/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	thermal_overload()

/obj/item/clothing/glasses/hud/spacecop
	gender = PLURAL
	name = "police aviators"
	desc = "For thinking you look cool while brutalizing protestors and minorities."
	icon_state = "bigsunglasses"
	flash_protect = FLASH_PROTECTION_FLASH
	flags_cover = GLASSESCOVERSEYES
	tint = 1
	glass_colour_type = /datum/client_colour/glass_colour/gray


/obj/item/clothing/glasses/hud/spacecop/hidden // for the undercover cop
	gender = PLURAL
	name = "sunglasses"
	desc = "These sunglasses are special, and let you view potential criminals."
	icon_state = "sun"
	inhand_icon_state = "sunglasses"

/obj/item/clothing/glasses/hud/security/sunglasses/armadyne
	name = "armadyne hud glasses"
	icon_state = "armadyne_glasses"
	worn_icon = 'icons/mob/clothing/eyes_additions.dmi'
	icon = 'icons/obj/clothing/glasses_additions.dmi'
