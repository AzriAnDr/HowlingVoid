/obj/item/organ/brain/aquatic
	name = "Azulean Brain"
	icon = 'modularhowling_void/modules/modular_species/organs/aquatic/icons/aquatic_organs.dmi'
	icon_state = "brain_aquatic"

/obj/item/organ/heart/aquatic
	name = "Azulean Heart"
	icon = 'modularhowling_void/modules/modular_species/organs/aquatic/icons/aquatic_organs.dmi'
	icon_state = "heart_aquatic"

/obj/item/organ/lungs/aquatic
	name = "Azulean Lungs"
	icon = 'modularhowling_void/modules/modular_species/organs/aquatic/icons/aquatic_organs.dmi'
	icon_state = "lungs_aquatic"

/obj/item/organ/stomach/aquatic
	name = "Azulean Stomach"
	icon = 'modularhowling_void/modules/modular_species/organs/aquatic/icons/aquatic_organs.dmi'
	icon_state = "stomach_aquatic"

/obj/item/organ/liver/aquatic
	name = "Azulean Liver"
	icon = 'modularhowling_void/modules/modular_species/organs/aquatic/icons/aquatic_organs.dmi'
	icon_state = "liver_aquatic"


/obj/item/organ/heart/aquatic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_blocker)
