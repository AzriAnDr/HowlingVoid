/obj/machinery/telecomms/relay/preset/reebe
	id = "Hierophant Relay"
	hide = TRUE
	icon = 'icons/clock_cult/clockwork_objects.dmi'
	icon_state = "relay"
	broadcasting = FALSE
	resistance_flags = INDESTRUCTIBLE
	soundloop = null

/obj/machinery/telecomms/relay/preset/reebe/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/encryptionkey) && GLOB.current_eminence?.internal_radio)
		var/obj/item/encryptionkey/key = attacking_item
		for(var/channel in key.channels)
			key.channels[channel] = 1
		GLOB.current_eminence.internal_radio.attackby(key, user, modifiers, attack_modifiers)
	return ..()

/obj/item/radio/intercom/reebe
	name = "Listening Device"
	freerange = TRUE
