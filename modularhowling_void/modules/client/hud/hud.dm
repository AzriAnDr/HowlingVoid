/atom/movable/screen/human/toggle/sub

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
		usr.client.screen += targetmob.hud_used.toggleable_sub_inventory

	targetmob.hud_used.hidden_sub_inventory_update(usr)
	update_appearance()


/datum/hud/proc/hidden_sub_inventory_update(mob/living/carbon/screenmob, show = TRUE)
	if(!screenmob)
		return

	if(show)
		if(screenmob.shoes)
			screenmob.shoes.screen_loc = ui_shoes
			screenmob.client.screen += screenmob.shoes
	else
		if(screenmob.shoes)
			screenmob.client.screen -= screenmob.shoes
