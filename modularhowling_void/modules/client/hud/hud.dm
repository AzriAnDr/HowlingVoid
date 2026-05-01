/atom/movable/screen/human/toggle/sub
	name = "toggle extra"
	base_icon_state = "toggle_extra"
	icon_state = "toggle_extra"

/atom/movable/screen/human/toggle/sub/Click()
	var/mob/targetmob = usr

	if(isobserver(usr))
		if(ishuman(usr.client.eye) && (usr.client.eye != usr))
			var/mob/M = usr.client.eye
			targetmob = M

	if(usr.hud_used.sub_inventory_shown && targetmob.hud_used)
		usr.hud_used.sub_inventory_shown = FALSE
		usr.client.screen -= targetmob.hud_used.toggleable_sub_inventory
	else
		usr.hud_used.sub_inventory_shown = TRUE
		if(usr.hud_used.inventory_shown)
			usr.client.screen += targetmob.hud_used.toggleable_sub_inventory

	targetmob.hud_used.hidden_sub_inventory_update(usr)
	update_appearance()

/atom/movable/screen/human/toggle/sub/update_icon_state()
	SHOULD_CALL_PARENT(FALSE)
	icon_state = base_icon_state

/datum/hud/proc/hidden_sub_inventory_update(mob/living/carbon/screenmob, show = TRUE)
	if(!mymob)
		return
	screenmob = screenmob || mymob

	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob

		for(var/atom/movable/screen/inventory/inv in toggleable_sub_inventory)
			inv.update_icon()

		var/should_show = show && screenmob.hud_used && screenmob.hud_used.inventory_shown && screenmob.hud_used.sub_inventory_shown && screenmob.hud_used.hud_shown
		if(should_show)
			if(H.w_underwear)
				H.w_underwear.screen_loc = ui_boxers
				screenmob.client.screen += H.w_underwear
			if(H.w_socks)
				H.w_socks.screen_loc = ui_socks
				screenmob.client.screen += H.w_socks
			if(H.w_shirt)
				H.w_shirt.screen_loc = ui_shirt
				screenmob.client.screen += H.w_shirt
			if(H.w_bra)
				H.w_bra.screen_loc = ui_bra
				screenmob.client.screen += H.w_bra
			if(H.hand_accessory)
				H.hand_accessory.screen_loc = ui_hand
				screenmob.client.screen += H.hand_accessory
			if(H.ears_extra)
				H.ears_extra.screen_loc = ui_ears_extra
				screenmob.client.screen += H.ears_extra
			if(H.wrists)
				H.wrists.screen_loc = ui_wrists
				screenmob.client.screen += H.wrists
		else
			if(H.w_underwear)
				screenmob.client.screen -= H.w_underwear
			if(H.w_socks)
				screenmob.client.screen -= H.w_socks
			if(H.w_shirt)
				screenmob.client.screen -= H.w_shirt
			if(H.w_bra)
				screenmob.client.screen -= H.w_bra
			if(H.hand_accessory)
				screenmob.client.screen -= H.hand_accessory
			if(H.ears_extra)
				screenmob.client.screen -= H.ears_extra
			if(H.wrists)
				screenmob.client.screen -= H.wrists
		return

	if(show)
		if(screenmob.shoes)
			screenmob.shoes.screen_loc = ui_shoes
			screenmob.client.screen += screenmob.shoes
	else
		if(screenmob.shoes)
			screenmob.client.screen -= screenmob.shoes
