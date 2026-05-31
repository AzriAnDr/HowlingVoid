/obj/structure/flora/biolumi
	name = "glowing plants"
	desc = "Several sticks with bulbous, bioluminescent tips."
	icon = 'icons/jungle/jungleflora.dmi'
	icon_state = "stick"
	gender = PLURAL
	light_system = OVERLAY_LIGHT
	light_range = 15
	light_power = 0.5
	max_integrity = 50
	var/variants = 9
	var/base_icon
	var/list/random_light = list("#6AFF00","#00FFEE", "#D9FF00", "#FFC800")

/obj/structure/flora/biolumi/Initialize(mapload)
	. = ..()
	base_icon = "[initial(icon_state)][rand(1,variants)]"
	icon_state = base_icon
	if(random_light)
		set_light_color(pick(random_light))
	apply_mapped_light()
	update_appearance()

/obj/structure/flora/biolumi/proc/apply_mapped_light()
	set_light_range(light_range)
	set_light_power(light_power)
	set_light_on(TRUE)

/obj/structure/flora/biolumi/update_overlays()
	. = ..()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	var/obj/effect/overlay/vis/overlay = SSvis_overlays.add_vis_overlay(src, icon, "[base_icon]_light", 0, ABOVE_LIGHTING_PLANE, null, 255, NONE, TRUE)
	if(light_color)
		overlay.color = light_color

/obj/structure/flora/biolumi/mine
	name = "glowing plant"
	desc = "Glowing sphere encased in jungle leaves."
	icon_state = "mine"
	variants = 4
	random_light = list("#FF0066","#00FFEE", "#D9FF00", "#FFC800")

/obj/structure/flora/biolumi/flower
	name = "glowing flower"
	desc = "Beautiful, bioluminescent flower."
	icon_state = "flower"
	variants = 2
	random_light = list("#6F00FF","#00FFEE", "#D9FF00", "#FF73D5")

/obj/structure/flora/biolumi/lamp
	name = "plant lamp"
	desc = "Bioluminescent plant much in a shape of a street lamp."
	icon_state = "lamp"
	variants = 2
	random_light = list("#6AFF00","#00FFEE", "#D9FF00", "#FFC800")

/obj/structure/flora/biolumi/mine/weaklight
	light_power = 0.3

/obj/structure/flora/biolumi/flower/weaklight
	light_power = 0.3

/obj/structure/flora/biolumi/lamp/weaklight
	light_power = 0.3
