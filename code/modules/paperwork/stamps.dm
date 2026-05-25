/obj/item/stamp
	name = "rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/service/bureaucracy.dmi'
	abstract_type = /obj/item/stamp
	worn_icon_state = "nothing"
	inhand_icon_state = "stamp"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.6)
	pressure_resistance = 2
	attack_verb_continuous = list("stamps")
	attack_verb_simple = list("stamp")

/obj/item/stamp/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] stamps 'VOID' on [user.p_their()] forehead, then promptly falls over, dead."))
	playsound(src, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)
	return OXYLOSS

/obj/item/stamp/get_writing_implement_details()
	var/datum/asset/spritesheet_batched/sheet = get_asset_datum(/datum/asset/spritesheet/simple/stamps)
	return list(
		interaction_mode = MODE_STAMPING,
		stamp_icon_state = icon_state,
		stamp_icon = icon,
		stamp_class = sheet.icon_class_name(icon_state)
	)

/obj/item/stamp/law
	name = "law office's rubber stamp"
	icon_state = "stamp-law"
	dye_color = DYE_LAW

/obj/item/stamp/head
	abstract_type = /obj/item/stamp/head

/obj/item/stamp/head/Initialize(mapload)
	. = ..()
	// All maps should have at least 1 of each head of staff stamp
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)

/obj/item/stamp/head/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"
	dye_color = DYE_CAPTAIN

/obj/item/stamp/head/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"
	dye_color = DYE_HOP

/obj/item/stamp/head/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"
	dye_color = DYE_HOS

/obj/item/stamp/head/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"
	dye_color = DYE_CE

/obj/item/stamp/head/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"
	dye_color = DYE_RD

/obj/item/stamp/head/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"
	dye_color = DYE_CMO

/obj/item/stamp/head/qm
	name = "quartermaster's rubber stamp"
	icon_state = "stamp-qm"
	dye_color = DYE_QM

/obj/item/stamp/granted
	name = "\improper GRANTED rubber stamp"
	icon_state = "stamp-ok"
	dye_color = DYE_GREEN

/obj/item/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"
	dye_color = DYE_REDCOAT

/obj/item/stamp/void
	name = "VOID rubber stamp"
	icon_state = "stamp-void"

/obj/item/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	dye_color = DYE_CLOWN

/obj/item/stamp/clown/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CLOWN, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 0)

/obj/item/stamp/mime
	name = "mime's rubber stamp"
	icon_state = "stamp-mime"
	dye_color = DYE_MIME

/obj/item/stamp/chap
	name = "chaplain's rubber stamp"
	icon_state = "stamp-chap"
	dye_color = DYE_CHAP

/obj/item/stamp/centcom
	name = "CentCom rubber stamp"
	icon_state = "stamp-centcom"
	dye_color = DYE_CENTCOM

/obj/item/stamp/syndicate
	name = "Syndicate rubber stamp"
	icon_state = "stamp-syndicate"
	dye_color = DYE_SYNDICATE

/obj/item/stamp/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)


// BEGIN NOVA CORE MIGRATION: code/modules/paperwork/stamps.dm
/obj/item/stamp/cat
	name = "\improper Official Cat Stamp"
	desc = "A rubber stamp for stamping documents of questionable importance."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-cat_blue"
	inhand_icon_state = "stamp"
// Radial menu options
	var/static/cat_blue = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "radial_cat_blue")
	var/static/paw_blue = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "radial_paw_blue")
	var/static/cat_red = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "radial_cat_red")
	var/static/paw_red = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "radial_paw_red")
	var/static/cat_orange = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "radial_cat_orange")
	var/static/paw_orange = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "radial_paw_orange")
	var/static/cat_green = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "radial_cat_green")
	var/static/paw_green = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "radial_paw_green")
// Choices for the radial menu
	var/static/list/radial_options = list(
		"cat_blue" = cat_blue,
		"paw_blue" = paw_blue,
		"cat_red" = cat_red,
		"paw_red" = paw_red,
		"cat_orange" = cat_orange,
		"paw_orange" = paw_orange,
		"cat_green" = cat_green,
		"paw_green" = paw_green
	)

/obj/item/stamp/cat/ui_interact(mob/user)
	. = ..()
	var/choice = show_radial_menu(user, src, radial_options)
	switch(choice)
		if("cat_blue")
			icon_state = "stamp-cat_blue"
			dye_color = DYE_HOP
			name = "\improper Official Cat Stamp"
		if("paw_blue")
			icon_state = "stamp-paw_blue"
			dye_color = DYE_HOP
			name = "\improper Paw Stamp"

		if("cat_red")
			icon_state = "stamp-cat_red"
			dye_color = DYE_HOS
			name = "\improper Official Cat Stamp"
		if("paw_red")
			icon_state = "stamp-paw_red"
			dye_color = DYE_HOS
			name = "\improper Paw Stamp"

		if("cat_orange")
			icon_state = "stamp-cat_orange"
			dye_color = DYE_QM
			name = "\improper Official Cat Stamp"
		if("paw_orange")
			icon_state = "stamp-paw_orange"
			dye_color = DYE_QM
			name = "\improper Paw Stamp"

		if("cat_green")
			icon_state = "stamp-cat_green"
			dye_color = DYE_CENTCOM
			name = "\improper Official Cat Stamp"
		if("paw_green")
			icon_state = "stamp-paw_green"
			dye_color = DYE_CENTCOM
			name = "\improper Paw Stamp"

		else
			return

/obj/item/stamp/nri
	name = "\improper Novaya Rossiyskaya Imperia stamp"
	desc = "A rubber stamp for stamping important documents. Used in various NRI documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-nri"
	dye_color = DYE_CENTCOM

/obj/item/stamp/solfed
	name = "\improper Solar Federation stamp"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-solfed"
	dye_color = DYE_CE

/obj/item/stamp/tarkon
	name = "Port Tarkon rubber stamp"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-tarkon"
	dye_color = DYE_QM

/obj/item/stamp/warden
	name = "warden's rubber stamp"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-warden"
	dye_color = DYE_HOS
// END NOVA CORE MIGRATION: code/modules/paperwork/stamps.dm
