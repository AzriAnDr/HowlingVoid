/datum/quirk/item_quirk/breather/nitrogen_breather
	name = "Nitrogen Breather(Дышащий азотом)"
	desc = "Вы дышите азотом, даже если обычно вам это не свойственно. Кислород для вас — яд."
	alert_text = "Не забудьте надеть испаритель, иначе вы можете задохнуться!"
	medical_record_text = "Пациент способен дышать только азотом."
	gain_text = span_notice("Внезапно вы с трудом можете дышать чем-то, кроме азота.")
	lose_text = span_danger("Вы неожиданно понимаете, что больше не привязаны к азоту.")
	value = 0
	breathing_tank = /obj/item/tank/internals/nitrogen/belt/full
	breath_type = "nitrogen"


/datum/quirk/item_quirk/breather/nitrogen_breather/is_species_appropriate(datum/species/mob_species)
	if(ispath(mob_species, /datum/species/vox))
		return FALSE
	else
		return ..()

/datum/quirk/item_quirk/breather/nitrogen_breather/add_adaptation()
	// this proc is guaranteed to be called multiple times
	var/obj/item/organ/lungs/target_lungs = quirk_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!target_lungs)
		return
	// set lung vars
	target_lungs.safe_oxygen_min = 0 //Dont need oxygen
	target_lungs.safe_oxygen_max = 2 //But it is quite toxic
	target_lungs.safe_nitro_min = 10 // Atleast 10 nitrogen
	target_lungs.oxy_damage_type = TOX
	target_lungs.oxy_breath_dam_min = 6
	target_lungs.oxy_breath_dam_max = 20
	// update lung procs
	target_lungs.add_gas_reaction(/datum/gas/nitrogen, always = TYPE_PROC_REF(/obj/item/organ/lungs, breathe_nitro))
	target_lungs.add_gas_reaction(/datum/gas/oxygen, while_present = TYPE_PROC_REF(/obj/item/organ/lungs, too_much_oxygen))
	target_lungs.add_gas_reaction(/datum/gas/oxygen, on_loss = TYPE_PROC_REF(/obj/item/organ/lungs, safe_oxygen))
	// reflect correct lung flags
	target_lungs.respiration_type = RESPIRATION_N2

/datum/quirk/item_quirk/breather/nitrogen_breather/remove()
	. = ..()
	quirk_holder.clear_alert(ALERT_NOT_ENOUGH_N2O)
	quirk_holder.clear_alert(ALERT_TOO_MUCH_OXYGEN)
