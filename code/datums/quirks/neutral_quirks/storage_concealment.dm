/datum/quirk/storage_concealment
	name = "Dorsualiphobic Augmentation"
	desc = "You despise being seen wearing back-mounted storage. A chameleon implant conceals anything worn in your back slot."
	value = 0
	gain_text = span_notice("Your storage concealment implant comes online.")
	lose_text = span_notice("Your storage concealment implant shuts down.")
	medical_record_text = "Patient has expressed significant concern about visible back-mounted storage."
	icon = FA_ICON_BRIEFCASE
	var/datum/weakref/concealment_implant

/datum/quirk/storage_concealment/add_unique(client/client_source)
	var/obj/item/implant/hide_backpack/implant = new
	if(!implant.implant(quirk_holder, null, TRUE, TRUE))
		qdel(implant)
		return

	concealment_implant = WEAKREF(implant)

/datum/quirk/storage_concealment/remove()
	var/obj/item/implant/hide_backpack/implant = concealment_implant?.resolve()
	QDEL_NULL(implant)
	concealment_implant = null
	return ..()
