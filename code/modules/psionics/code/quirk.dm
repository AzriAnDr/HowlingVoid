/datum/quirk/psionic_sensitivity
	name = "Psionic Sensitivity"
	desc = "Your Zona Bovinae is active enough to manifest a few weak psionic abilities."
	value = 8
	gain_text = span_horizonblue("A faint psionic current starts humming at the edge of your thoughts.")
	lose_text = span_notice("The faint psionic current in your mind falls quiet.")
	medical_record_text = "Subject exhibits low-grade psionic sensitivity."
	icon = FA_ICON_BRAIN
	var/datum/weakref/granted_psionic_ref

/datum/quirk/psionic_sensitivity/add(client/client_source)
	var/mob/living/current_holder = quirk_holder
	if(current_holder.get_psionic())
		return

	current_holder.add_psionic(/datum/psionic/nascent)
	granted_psionic_ref = WEAKREF(current_holder.get_psionic())

/datum/quirk/psionic_sensitivity/remove()
	var/datum/psionic/granted_psionic = granted_psionic_ref?.resolve()
	if(granted_psionic && quirk_holder.get_psionic() == granted_psionic)
		quirk_holder.remove_psionic()
	granted_psionic_ref = null
