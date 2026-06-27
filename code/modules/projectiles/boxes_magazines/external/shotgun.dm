/obj/item/ammo_box/magazine/m12g
	name = "shotgun magazine (12g buckshot shells)"
	desc = "A drum magazine of shotgun shells, suitable for the Bulldog combat shotgun."
	icon_state = "m12gb"
	base_icon_state = "m12gb"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/milspec
	caliber = CALIBER_SHOTGUN
	max_ammo = 8
	casing_phrasing = "shell"
	reload_delay = CLICK_CD_MELEE

/obj/item/ammo_box/magazine/m12g/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[CEILING(ammo_count(FALSE)/8, 1)*8]"

/obj/item/ammo_box/magazine/m12g/stun
	name = "shotgun magazine (12g taser slugs)"
	icon_state = "m12gs"
	base_icon_state = "m12gs"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/magazine/m12g/slug
	name = "shotgun magazine (12g slugs)"
	icon_state = "m12gsl"
	base_icon_state = "m12gsl"
	ammo_type = /obj/item/ammo_casing/shotgun/milspec

/obj/item/ammo_box/magazine/m12g/dragon
	name = "shotgun magazine (12g dragon's breath)"
	icon_state = "m12gf"
	base_icon_state = "m12gf"
	ammo_type = /obj/item/ammo_casing/shotgun/dragonsbreath

/obj/item/ammo_box/magazine/m12g/bioterror
	name = "shotgun magazine (12g bioterror)"
	icon_state = "m12gt"
	base_icon_state = "m12gt"
	ammo_type = /obj/item/ammo_casing/shotgun/dart/bioterror

/obj/item/ammo_box/magazine/m12g/meteor
	name = "shotgun magazine (12g meteor slugs)"
	icon_state = "m12gbc"
	base_icon_state = "m12gbc"
	ammo_type = /obj/item/ammo_casing/shotgun/meteorslug

/obj/item/ammo_box/magazine/m12g/flechette
	name = "shotgun magazine (12g flechette)"
	icon_state = "m12gfl"
	base_icon_state = "m12gfl"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/magazine/m12g/donk
	name = "shotgun magazine (12g Donk Co. 'Donk Spike' flechette)"
	desc = "A drum magazine of shotgun shells, suitable for the Bulldog combat shotgun. It is covered in Donk Co. scratch-and-sniff \
		stickers. You're not sure you want to try and get a whiff..."
	icon_state = "m12gd"
	base_icon_state = "m12gd"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette/donk

/obj/item/ammo_box/magazine/m12g/donk/examine_more(mob/user)
	. = ..()
	if(ishuman(user))
		return

	var/mob/living/carbon/human/human_sniffer = user
	if(!HAS_TRAIT(human_sniffer, TRAIT_ANOSMIA) && human_sniffer.can_perform_action(src, NEED_DEXTERITY|NEED_HANDS|ALLOW_RESTING|FORBID_TELEKINESIS_REACH))
		. += span_notice("You scratch and sniff the stickers.")
		. += span_warning("<i>Oh god, where did they pull this from, a landfill?</i>")
		human_sniffer.add_mood_event("stink-pocket", /datum/mood_event/disgusted)



// BEGIN NOVA CORE MIGRATION: code/modules/projectiles/boxes_magazines/external/shotgun.dm
/obj/item/ammo_box/magazine/m12g/empty
	name = "shotgun magazine (12g)"
	icon_state = "m12gb-0"
	start_empty = TRUE
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/magazine/katyusha/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[LAZYLEN(stored_ammo) ? "full" : "empty"]"

/obj/item/ammo_box/magazine/katyusha/empty
	icon_state = "spikewall_mag-empty"
	start_empty = TRUE

/obj/item/ammo_box/magazine/katyusha
	name = "\improper Katyusha Drum Magazine"
	desc = "A drum magazine of shotgun shells, suitable for the Katyusha combat shotgun."
	icon = 'icons/obj/weapons/ammo/nanotrasen_armories/magazines.dmi'
	icon_state = "spikewall_mag"
	base_icon_state = "spikewall_mag"
	ammo_type = /obj/item/ammo_casing/shotgun
	caliber = CALIBER_SHOTGUN
	max_ammo = 10
	casing_phrasing = "shell"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	reload_delay = CLICK_CD_MELEE

/obj/item/ammo_box/magazine/katyusha/buckshot
	icon = 'icons/obj/weapons/ammo/nanotrasen_armories/magazines.dmi'
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/jager/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[LAZYLEN(stored_ammo) ? "full" : "empty"]"

/obj/item/ammo_box/magazine/jager/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/jager
	name = "\improper Jäger Magazine"
	desc = "A magazine of shotgun shells, suitable for the 'Jäger' combat shotgun."
	icon = 'icons/obj/weapons/ammo/nanotrasen_armories/magazines.dmi'
	icon_state = "jager_mag"
	base_icon_state = "jager_mag"
	ammo_type = /obj/item/ammo_casing/shotgun
	caliber = CALIBER_SHOTGUN
	max_ammo = 4
	reload_delay = CLICK_CD_MELEE

/obj/item/ammo_box/magazine/jager/rubbershot
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/magazine/jager/large
	name = "large Jäger Magazine"
	desc = "A magazine of shotgun shells, suitable for the 'Jager' combat shotgun."
	icon_state = "jager_mag_large"
	base_icon_state = "jager_mag_large"
	max_ammo = 7

/obj/item/ammo_box/magazine/jager/large/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/shitzu/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/shitzu
	name = "\improper Shitzu Shotgun Magazine"
	desc = "A magazine of shotgun shells, suitable for the 'Shitzu' combat shotgun."
	icon = 'icons/obj/weapons/ammo/syndicate_armaments/magazines.dmi'
	icon_state = "shitzu_mag"
	base_icon_state = "shitzu_mag"
	ammo_type = /obj/item/ammo_casing/shotgun
	caliber = CALIBER_SHOTGUN
	max_ammo = 10
	casing_phrasing = "shell"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	reload_delay = CLICK_CD_MELEE

/obj/item/ammo_box/magazine/shitzu/milspec
	ammo_type = /obj/item/ammo_casing/shotgun/milspec

/obj/item/ammo_box/magazine/shitzu/milspec_buckshot
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/milspec
// END NOVA CORE MIGRATION: code/modules/projectiles/boxes_magazines/external/shotgun.dm
