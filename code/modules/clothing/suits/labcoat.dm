/obj/item/clothing/suit/toggle/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	icon_state = "labcoat"
	icon = 'icons/obj/clothing/suits/labcoat.dmi'
	worn_icon = 'icons/mob/clothing/suits/labcoat.dmi'
	inhand_icon_state = "labcoat"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|ARMS
	allowed = list(
		/obj/item/analyzer,
		/obj/item/biopsy_tool,
		/obj/item/defibrillator/compact,
		/obj/item/dnainjector,
		/obj/item/flashlight/pen,
		/obj/item/gun/syringe,
		/obj/item/healthanalyzer,
		/obj/item/paper,
		/obj/item/reagent_containers/applicator,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/syringe,
		/obj/item/sensor_device,
		/obj/item/soap,
		/obj/item/stack/medical,
		/obj/item/storage/pill_bottle,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/gun/energy/cell_loaded/medigun, //NOVA EDIT ADDITION - MEDIGUNS
		/obj/item/storage/medkit, //NOVA EDIT ADDITION
	)
	armor_type = /datum/armor/toggle_labcoat
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/toggle/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Bluer than the standard model."
	icon_state = "labcoat_cmo"
	inhand_icon_state = null

/obj/item/clothing/suit/toggle/labcoat/cmo/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/adjust_fishing_difficulty, -3) //FISH DOCTOR?!

/datum/armor/toggle_labcoat
	bio = 50
	fire = 50
	acid = 50

/obj/item/clothing/suit/toggle/labcoat/cmo/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/melee/baton/telescopic,
		/obj/item/gun/energy/cell_loaded/medigun, //NOVA EDIT ADDITION - MEDIGUNS
		/obj/item/storage/medkit, //NOVA EDIT ADDITION
	)

/obj/item/clothing/suit/toggle/labcoat/paramedic
	name = "paramedic's jacket"
	desc = "A dark blue jacket for paramedics with reflective stripes."
	icon_state = "labcoat_paramedic"
	inhand_icon_state = null

/obj/item/clothing/suit/toggle/labcoat/paramedic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/adjust_fishing_difficulty, -3) //FISH DOCTOR?!
	allowed += /obj/item/crowbar/power/paramedic

/obj/item/clothing/suit/toggle/labcoat/mad
	name = "\proper The Mad's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	icon_state = "labgreen"
	inhand_icon_state = null

/obj/item/clothing/suit/toggle/labcoat/genetics
	name = "geneticist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/genetics"
	post_init_icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#EEEEEE#4A77A1#4A77A1#7095C2"

/obj/item/clothing/suit/toggle/labcoat/genetics/Initialize(mapload)
	. = ..()
	allowed += /obj/item/sequence_scanner

/obj/item/clothing/suit/toggle/labcoat/chemist
	name = "chemist labcoat"
	desc = "A suit that protects against minor chemical spills. Has an orange stripe on the shoulder."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/chemist"
	post_init_icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#EEEEEE#F17420#F17420#EB6F2C"

/obj/item/clothing/suit/toggle/labcoat/chemist/Initialize(mapload)
	. = ..()
	allowed += /obj/item/storage/bag/chemistry

/obj/item/clothing/suit/toggle/labcoat/virologist
	name = "virologist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a green stripe on the shoulder."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/virologist"
	post_init_icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#EEEEEE#198019#198019#40992E"

/obj/item/clothing/suit/toggle/labcoat/virologist/Initialize(mapload)
	. = ..()
	allowed += /obj/item/storage/bag/bio

/obj/item/clothing/suit/toggle/labcoat/coroner
	name = "coroner labcoat"
	desc = "A suit that protects against minor chemical spills. Has a black stripe on the shoulder."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/coroner"
	post_init_icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#EEEEEE#2D2D33#2D2D33#39393F"

/obj/item/clothing/suit/toggle/labcoat/coroner/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/autopsy_scanner,
		/obj/item/scythe,
		/obj/item/shovel,
		/obj/item/shovel/serrated,
		/obj/item/trench_tool,
	)

/obj/item/clothing/suit/toggle/labcoat/science
	name = "scientist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/science"
	post_init_icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#EEEEEE#7E1980#7E1980#B347A1"

/obj/item/clothing/suit/toggle/labcoat/science/Initialize(mapload)
	. = ..()
	allowed += /obj/item/storage/bag/xeno

/obj/item/clothing/suit/toggle/labcoat/roboticist
	name = "roboticist labcoat"
	desc = "More like an eccentric coat than a labcoat. Helps pass off bloodstains as part of the aesthetic. Comes with red shoulder pads."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/roboticist"
	post_init_icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#EEEEEE#88242D#88242D#39393F"

/obj/item/clothing/suit/toggle/labcoat/interdyne
	name = "interdyne labcoat"
	desc = "More like an eccentric coat than a labcoat. Helps pass off bloodstains as part of the aesthetic. Comes with red shoulder pads."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/interdyne"
	post_init_icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#EEEEEE#88242D#88242D#39393F"

// Research Director

/obj/item/clothing/suit/toggle/labcoat/research_director
	name = "research director's coat"
	desc = "A mix between a labcoat and just a regular coat. It's made out of a special antibacterial, anti-acidic, and anti-biohazardous synthetic fabric."
	icon_state = "labcoat_rd"
	armor_type = /datum/armor/jacket_research_director
	body_parts_covered = CHEST|GROIN|ARMS

/datum/armor/jacket_research_director
	bio = 75
	fire = 75
	acid = 75

/obj/item/clothing/suit/toggle/labcoat/research_director/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/storage/bag/xeno,
		/obj/item/melee/baton/telescopic,
	)


// BEGIN NOVA CORE MIGRATION: code/modules/clothing/suits/labcoat.dm
/obj/item/clothing/suit/toggle/labcoat/paramedic/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/storage/medkit,
	)

/obj/item/clothing/suit/toggle/labcoat
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/toggle/labcoat/nova
	name = "SR LABCOAT SUIT DEBUG"
	desc = "REPORT THIS IF FOUND"
	icon = 'icons/obj/clothing/suits/labcoat_additions.dmi'
	worn_icon = 'icons/mob/clothing/suits/labcoat_additions.dmi'
	worn_icon_teshari = 'icons/mob/clothing/suits/labcoat_teshari.dmi'
	icon_state = null //Keeps this from showing up under the chameleon hat

/obj/item/clothing/suit/toggle/labcoat/nova/fancy
	name = "Greyscale Fancy Labcoat"
	desc = "Throughout the test of determination, many have sought after such a fancy labcoat, one that was filled with many colors and wears."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/nova/fancy"
	post_init_icon_state = "fancy_labcoat"
	greyscale_config = /datum/greyscale_config/fancy_labcoat
	greyscale_config_worn = /datum/greyscale_config/fancy_labcoat/worn
	greyscale_config_worn_teshari = /datum/greyscale_config/fancy_labcoat/worn/teshari
	greyscale_colors = "#EEEEEE#4A77A1"
	gets_cropped_on_taurs = FALSE
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/toggle/labcoat/nova/fancy/rd
	name = "research directors labcoat"
	desc = "A Nanotrasen standard labcoat for certified Research Directors. It has an extra plastic-latex lining on the outside for more protection from chemical and viral hazards."
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/nova/fancy/rd"
	greyscale_colors = "#620B73#EEEEEE"
	gets_cropped_on_taurs = FALSE
	body_parts_covered = CHEST|ARMS|LEGS
	armor_type = /datum/armor/nova_rd

/obj/item/clothing/suit/toggle/labcoat/nova/fancy/rd/deckofficer
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/nova/fancy/rd/deckofficer"
	greyscale_colors = "#FFFFFF#4F8F56"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/datum/armor/nova_rd
	melee = 5
	bio = 80
	fire = 80
	acid = 70

/obj/item/clothing/suit/toggle/labcoat/nova/fancy/regular
	name = "researcher's labcoat"
	desc = "A Nanotrasen standard labcoat for researchers in the scientific field."
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/nova/fancy/regular"
	greyscale_colors = "#EEEEEE#B347A1"
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/suit/toggle/labcoat/nova/fancy/regular/Initialize(mapload)
	. = ..()
	allowed += /obj/item/storage/bag/xeno

/obj/item/clothing/suit/toggle/labcoat/nova/lalunevest
	name = "sleeveless buttoned coat"
	desc = "A fashionable jacket bearing the La Lune insignia on the inside. It appears similar to a labcoat in design and materials, though the tag warns against it being a replacement for such."
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/nova/lalunevest"
	icon_state = "labcoat_lalunevest"
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/suit/toggle/labcoat/nova/interdyne_labcoat/black
	name = "interdyne black labcoat"
	desc = "A black labcoat accented with interdyne-green colors."
	icon_state = "ip_labcoatblack"
	worn_icon_teshari = 'icons/mob/clothing/species/teshari/suit.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/toggle/labcoat/nova/interdyne_labcoat/white
	name = "interdyne white labcoat"
	desc = "A white labcoat accented with interdyne-green colors."
	icon_state = "ip_labcoatwhite"
	worn_icon_teshari = 'icons/mob/clothing/species/teshari/suit.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/syndicate/interdyne_jacket
	name = "interdyne jacket"
	desc = "A green high-visibility jacket bearing interdyne colors."
	icon = 'icons/obj/clothing/suits/labcoat_additions.dmi'
	worn_icon = 'icons/mob/clothing/suits/labcoat_additions.dmi'
	icon_state = "ip_armorlabcoat"
	armor_type = /datum/armor/wintercoat_syndicate
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/toggle/labcoat/nova/fancy/pharmacist
	name = "pharmacist's labcoat"
	desc = "A standard labcoat for chemistry which protects the wearer from acid spills."
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/nova/fancy/pharmacist"
	greyscale_colors = "#EEEEEE#E6935C"
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/suit/toggle/labcoat/nova/fancy/geneticist
	name = "geneticist's labcoat"
	desc = "A standard labcoat for geneticist."
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/nova/fancy/geneticist"
	greyscale_colors = "#EEEEEE#7497C0"
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/suit/toggle/labcoat/nova/fancy/roboticist
	name = "roboticist's labcoat"
	desc = "A standard labcoat for roboticist."
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/nova/fancy/roboticist"
	greyscale_colors = "#2F2E31#A52F29"
	gets_cropped_on_taurs = FALSE

/obj/item/clothing/suit/toggle/labcoat/nova/fancy/pharmacist/Initialize(mapload)
	. = ..()
	allowed += /obj/item/storage/bag/chemistry

/obj/item/clothing/suit/toggle/labcoat/nova/highvis
	name = "high vis labcoat"
	desc = "A high visibility vest for emergency responders, intended to draw attention away from the blood."
	icon_state = "labcoat_highvis"
	blood_overlay_type = "armor"

/obj/item/clothing/suit/toggle/labcoat/nova/highvis/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", src, alpha = src.alpha)

/obj/item/clothing/suit/toggle/labcoat/nova/surgical_gown //Intended to keep patients modest while still allowing for surgeries
	name = "surgical gown"
	desc = "A complicated drapery with an assortment of velcros and strings, designed to keep a patient modest during medical stay and surgeries."
	icon_state = "hgown"
	toggle_noun = "drapes"
	body_parts_covered = NONE //Allows surgeries despite wearing it; hiding genitals is handled in /datum/sprite_accessory/genital/is_hidden() (Only place it'd work sadly)
	armor_type = /datum/armor/none
	equip_delay_other = 8

/obj/item/clothing/suit/toggle/labcoat/nova/surgical_gown/examine_tags(mob/user)
	. = ..()
	.["surgical"] = "Does not block surgery on covered bodyparts."
	// Same note as /obj/item/clothing/mask/muzzle/breath

/obj/item/clothing/suit/toggle/labcoat/roboticist //Overwrite the TG Roboticist labcoat to Black and Red (not the Interdyne labcoat though)
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/roboticist"
	greyscale_colors = "#2D2D33#88242D#88242D#88242D"

/obj/item/clothing/suit/toggle/labcoat/medical //Renamed version of the Genetics labcoat for more generic medical purposes; just a subtype of /labcoat/ for the TG files
	name = "medical labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/toggle/labcoat/medical"
	post_init_icon_state = "labcoat_job"
	greyscale_config = /datum/greyscale_config/labcoat
	greyscale_config_worn = /datum/greyscale_config/labcoat/worn
	greyscale_colors = "#EEEEEE#4A77A1#4A77A1#7095C2"

/obj/item/clothing/suit/toggle/labcoat/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/handheld_soulcatcher,
	)
// END NOVA CORE MIGRATION: code/modules/clothing/suits/labcoat.dm
