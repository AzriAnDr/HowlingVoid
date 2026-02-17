/obj/item/organ/brain/aquatic
	name = "Azulean Brain"
	icon = 'modular_HV/modules/modular_species/organs/aquatic/icons/aquatic_organs.dmi'
	icon_state = "brain_aquatic"

/obj/item/organ/heart/aquatic
	name = "Azulean Heart"
	icon = 'modular_HV/modules/modular_species/organs/aquatic/icons/aquatic_organs.dmi'
	icon_state = "heart_aquatic"

/obj/item/organ/lungs/aquatic
	name = "Azulean Lungs"
	icon = 'modular_HV/modules/modular_species/organs/aquatic/icons/aquatic_organs.dmi'
	icon_state = "lungs_aquatic"

/obj/item/organ/stomach/aquatic
	name = "Azulean Stomach"
	icon = 'modular_HV/modules/modular_species/organs/aquatic/icons/aquatic_organs.dmi'
	icon_state = "stomach_aquatic"

/obj/item/organ/liver/aquatic
	name = "Azulean Liver"
	icon = 'modular_HV/modules/modular_species/organs/aquatic/icons/aquatic_organs.dmi'
	icon_state = "liver_aquatic"


/obj/item/organ/heart/aquatic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_blocker)
