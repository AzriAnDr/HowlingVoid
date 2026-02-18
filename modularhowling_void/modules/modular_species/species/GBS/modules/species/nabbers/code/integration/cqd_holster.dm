/obj/item/clothing/accessory/cqd_holster/on_uniform_equipped(obj/item/clothing/under/U, user)
	icon_state = initial(icon_state)

	if(isteshari(user))
		icon_state = initial(icon_state) + "_hidden"
	if(isnabber(user))
		icon_state = initial(icon_state) + "_hidden"

	return ..()
